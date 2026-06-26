import glob
import os
import re

import h5py
import numpy as np
import scipy
from matplotlib.colors import LogNorm
from matplotlib.pyplot import *
from mpl_toolkits.axes_grid1 import make_axes_locatable
from phleos import *
from scipy.interpolate import interp1d
from scipy.ndimage import zoom

ptwidth = 255.114
ptheight = 705
ptwidthp = 521.5744745987562
inchpt = 0.0138889

width = ptwidth * inchpt
pwidth = ptwidthp * inchpt
height = ptheight * inchpt
scrdpi = 100
savedpi = 300

ichx_g = 10
ichy_g = 10
cb_size_g = 0.4
fontsize = 15
label_fontsize = 1.1 * fontsize
legend_fontsize = 0.9 * fontsize
rcParams["font.size"] = fontsize
rcParams["axes.titlesize"] = label_fontsize
rcParams["axes.labelsize"] = label_fontsize
rcParams["legend.fontsize"] = legend_fontsize
rcParams["legend.labelspacing"] = 0.4
rcParams["xtick.labelsize"] = fontsize
rcParams["ytick.labelsize"] = fontsize
rcParams["legend.frameon"] = True
rcParams["legend.facecolor"] = "white"
rcParams["legend.framealpha"] = 0.8
rcParams["legend.fancybox"] = True
rcParams["legend.edgecolor"] = "lightgray"
rcParams["lines.linewidth"] = 1.0
rc("text", usetex=True)
rc(
    "text.latex",
    preamble=r"\usepackage{txfonts}"
    + r"\usepackage{bm}"
    + r"\newcommand{\mach}[0]{\mathcal{M}}",
)

# ---------------------------------------------------------------------------------------


def generate_grid_free(
    nx, ny, deltax, deltay, dx, dy, aE, aW, aS, aN, single_column=False
):

    px = nx * deltax + (nx - 1) * dx + aE + aW
    py = ny * deltay + (ny - 1) * dy + aN + aS

    s = aS / py
    n = aN / py
    e = aE / px
    w = aW / px

    if single_column:
        fig, axs = subplots(ny, nx, figsize=(px * width, py * width), dpi=scrdpi)
    else:
        fig, axs = subplots(ny, nx, figsize=(px * pwidth, py * pwidth), dpi=scrdpi)

    fig.subplots_adjust(
        bottom=s, top=1 - n, left=w, right=1 - e, wspace=dx / deltax, hspace=dy / deltay
    )

    return fig, axs, [w, s, n, e], px, py

def restrict_average(u):
    return 0.25 * (
    u[0::2, 0::2] +
    u[1::2, 0::2] +
    u[0::2, 1::2] +
    u[1::2, 1::2]
    )

def error(q_fine, q_coarse):

    temp = restrict_average(q_fine)

    return np.mean(np.abs(q_coarse-temp))

def comp_error():
    g30 = h5grid(-1, path = "grids_30")
    g60 = h5grid(-1, path = "grids_60")
    g120 = h5grid(-1, path = "grids_120")
    g240 = h5grid(-1, path = "grids_240")
    g480 = h5grid(-1, path = "grids_480")

    err = [error(g60.temp(), g30.temp()), error(g120.temp(),
            g60.temp()), error(g240.temp(), g120.temp()),
            error(g480.temp(), g240.temp())]
    cells = [30,60,120,240,480]
    eoc = [(np.log(err[i] / err[i+1]))/(np.log(cells[i+1] / cells[i])) for i in range(3)]
    return err, eoc

# ---------------------------------------------------------------------------------------

CONST_RGAS = 8.31446261815324e7  # CONST_R
CONST_RAD = 7.565767381646406e-15  # CONST_A
CONST_GRAV = 6.67428e-8
CONST_RSUN = 6.95660e10
CONST_PI = 3.141592653589793238
CONST_C = 2.99792458e10
CONST_AV = 6.02214076e23
CONST_QE = 4.8032042712e-10
CONST_KB = 1.380650424e-16
CONST_MU = 1.660538782e-24
CONST_H = 6.62606896e-27

# ---------------------------------------------------------------------------------------

#######################################################################################
# h5grid class
#######################################################################################


def file_list(path=""):

    filelist = glob.glob(os.path.join(path, "*.h5"))
    files = []

    for file in filelist:
        f = os.path.basename(file)
        m = re.search("grid_n([0-9]{5,})\\.(h5)$", f)
        if m:
            files.append((int(m.group(1)), f))

    files.sort(key=lambda x: x[0])

    return files


class h5grid:
    def __init__(self, filename, path="./grids", mode="i"):
        if mode == "n":
            filename = os.path.join(path, "grid_n{:05}.h5".format(filename))
        elif mode == "i":
            filename = file_list(path=path)[filename][1]
        else:
            raise ValueError("Unknown mode" + str(mode), ": mode must be n or i")

        filename = os.path.join(path, filename)
        self.grid = h5py.File(filename, "r")["grid"]

        path0 = os.path.join(path, "grid_n{:05}.h5".format(0))
        f0 = h5py.File(path0, "r")
        self.grid0 = f0["grid"]

        self.gamma_gas = self.grid0["gamma_ad"][()]
        self.mub = self.grid0["mu"][()]
        self.x1l = self.grid0["x1l"][()]
        self.x1u = self.grid0["x1u"][()]
        self.x2l = self.grid0["x2l"][()]
        self.x2u = self.grid0["x2u"][()]
        self.nx1 = self.grid0["nx1"][()]
        self.nx2 = self.grid0["nx2"][()]

        self.time = self.grid["time"][()]
        self.dt = self.grid["dt"][()]
        self.step = self.grid["step"][()]

        self.i_rho = 0
        self.i_rhovx1 = 1
        self.i_rhovx2 = 2
        self.i_rhoe = self.i_rhovx2 + 1

    def coords(self):
        return self.vec3d(self.grid0["coords"])

    def rho(self):
        return self.vec2d(self.grid["qbar_cc"][:, :, self.i_rho])

    def mom(self):
        return self.vec3d(self.grid["qbar_cc"][:, :, self.i_rhovx1 : self.i_rhovx2 + 1])

    def vel(self):
        return self.mom() / self.rho()

    def rhoe(self):
        return self.vec2d(self.grid["qbar_cc"][:, :, self.i_rhoe])

    def s(self):
        return self.P() / self.rho() ** self.gamma_gas

    def P(self):
        rho = self.rho()
        vel = self.vel()
        rhoe = self.rhoe()
        rhoeint = rhoe - 0.5 * rho * np.sum(vel**2, axis=0)
        return (self.gamma_gas - 1.0) * rhoeint

    def temp(self):
        return self.vec2d(self.grid["t_cc"][:, :])



    def sound(self):
        return np.sqrt(self.gamma_gas * self.P() / self.rho())

    def abs_vel(self):
        return np.sqrt(np.sum(self.vel() ** 2, axis=0))

    def mach(self):
        return self.abs_vel() / self.sound()

    def vec2d(self, vec):

        tmp = vec[:, :]
        tmp = tmp.transpose(1, 0)

        return tmp

    def vec3d(self, vec):

        tmp = vec[:, :, :]
        tmp = tmp.transpose(2, 1, 0)

        return tmp

    ###############################################################################################
    ## Plotting functions
    ###############################################################################################

    def gridshow(
        self,
        out,
        ichx=ichx_g,
        ichy=ichy_g,
        figdpi=500,
        figname=None,
        axs=None,
        multiplot=False,
        show_cb=True,
        x_lbl=None,
        y_lbl=None,
        cb_lbl="",
        cb_pad=0.05,
        cb_size=cb_size_g,
        cb_pos="right",
        time_in_days=True,
        coords_in_Rsun=True,
        showfig=True,
        Rstar=-1,
        use_latex=False,
        fontsize=fontsize,
        **kwargs,
    ):

        label_fontsize = 1.1 * fontsize
        legend_fontsize = 0.9 * fontsize
        rcParams["font.size"] = fontsize
        rcParams["axes.titlesize"] = label_fontsize
        rcParams["axes.labelsize"] = label_fontsize
        rcParams["legend.fontsize"] = legend_fontsize
        rcParams["legend.labelspacing"] = 0.4
        rcParams["xtick.labelsize"] = fontsize
        rcParams["ytick.labelsize"] = fontsize
        rcParams["legend.frameon"] = True
        rcParams["legend.facecolor"] = "white"
        rcParams["legend.framealpha"] = 0.8
        rcParams["legend.fancybox"] = True
        rcParams["legend.edgecolor"] = "lightgray"
        rcParams["lines.linewidth"] = 1.0
        rc("text", usetex=use_latex)
        rc(
            "text.latex",
            preamble=r"\usepackage{txfonts}"
            + r"\usepackage{bm}"
            + r"\newcommand{\mach}[0]{\mathcal{M}}",
        )

        if showfig:
            ion()
        else:
            ioff()

        if axs is None:
            fig, axs = subplots(figsize=(ichx, ichy))
        else:
            fig = axs.figure

        coords = self.coords()

        x = coords[0]
        y = coords[1]
        xlbl = r"$x$"
        ylbl = r"$y$"

        im = axs.pcolormesh(x, y, out, shading="nearest", **kwargs)
        axs.axes.set_aspect("equal")

        if x_lbl == None:
            x_lbl = xlbl
        if y_lbl == None:
            y_lbl = ylbl

        axs.set_xlabel(x_lbl)
        axs.set_ylabel(y_lbl)

        axs.set_title(r"$t=%.3f\ [\mathrm{s}]$" % (self.time))

        divider = make_axes_locatable(axs)
        cax = divider.append_axes(cb_pos, size=cb_size, pad=cb_pad)

        if cb_pos == "left" or cb_pos == "right":
            orientation = "vertical"
        else:
            orientation = "horizontal"

        if show_cb:
            cb = fig.colorbar(im, cax=cax, label=cb_lbl, orientation=orientation)
        else:
            cax.axis("off")

        if figname != None:
            savefig(figname, dpi=figdpi)

        if showfig:
            show()
        elif multiplot:
            pass
        else:
            close()

        rc("text", usetex=False)

        return fig, axs
