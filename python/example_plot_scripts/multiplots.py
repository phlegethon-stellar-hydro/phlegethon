import matplotlib.pyplot as plt
import phloutput as phl
import numpy as np

plt.rcParams["text.usetex"] = False

plt.rcParams.update({
    "font.size": 16,
    "xtick.labelsize": 14,
    "ytick.labelsize": 14,
})

idx = 1
h = phl.h5grid(idx)

fig, axs = plt.subplots(2, 2, figsize=(12, 10), sharex=True, sharey=True)

# temperature
h.gridshow(
    h.T(),
    coords_in_Rsun=False,
    time_in_days=False,
    showfig=False,
    axs=axs[0, 0],
    multiplot=True,
)

axs[0, 0].set_title('Temperature [K]', fontsize=16)
axs[0, 0].set_ylabel("y [cm]", fontsize=14)

# mach number
h.gridshow(
    h.mach(),
    coords_in_Rsun=False,
    time_in_days=False,
    showfig=False,
    axs=axs[0, 1],
    multiplot=True,
)

axs[0, 1].set_title('Mach number', fontsize=16)

# density
h.gridshow(
    h.rho(),
    coords_in_Rsun=False,
    time_in_days=False,
    showfig=False,
    axs=axs[1, 0],
    multiplot=True,
)

axs[1, 0].set_title('Density [g/cm$^3$]', fontsize=16)
axs[1, 0].set_ylabel("y [cm]", fontsize=14)
axs[1, 0].set_xlabel("x [cm]", fontsize=14)

# ye
h.gridshow(
    h.ye(),
    coords_in_Rsun=False,
    time_in_days=False,
    showfig=False,
    axs=axs[1, 1],
    multiplot=True,
)

axs[1, 1].set_title('Electron Fraction $Y_e$', fontsize=16)
axs[1, 1].set_xlabel("x [cm]", fontsize=14)

# remove inner labels
for row in range(2):
    for col in range(2):
        if col != 0:
            axs[row, col].set_ylabel("")
        if row != 1:
            axs[row, col].set_xlabel("")

fig.suptitle(f"t = {h.time:.2f} s", fontsize=20)
plt.savefig(f"mwe_2x2.png", dpi=300)
plt.close(fig)


# ------------------------------------------------- #

# if you instead want several plots with a shared colorbar, use the following

indices = [0, 1, 2] # grid snapshots which you want to plot

# get min/max so that all plots can use the same colorbar
vmin, vmax = np.inf, -np.inf
for idx in indices:
    h = phl.h5grid(idx)
    data = h.T()
    vmin = min(vmin, np.nanmin(data))
    vmax = max(vmax, np.nanmax(data))

fig, axs = plt.subplots(1, 3, figsize=(18, 6), sharex=True, sharey=True)

for i, idx in enumerate(indices):
    h = phl.h5grid(idx)
    
    h.gridshow(
        h.T(),
        coords_in_Rsun=False,
        time_in_days=False,
        showfig=False,
        axs=axs[i],
        multiplot=True,
        cmap='magma',
        vmin=vmin,
        vmax=vmax,
        show_cb=(i == indices[-1]), # show colorbar only on the last plot
        cb_pad=0.2,
        cb_size="6%",
        cb_lbl='T [K]'
    )
    
    axs[i].set_title(f"t = {h.time:.2f} s", fontsize=16)
    axs[i].set_xlabel("x [cm]", fontsize=14)
    
    if i == 0:
        axs[i].set_ylabel("y [cm]", fontsize=14)
    else:
        axs[i].set_ylabel("")

plt.tight_layout(rect=[0, 0, 0.98, 1]) # adjust whitespace to make enough room for the colorbar
plt.savefig("mwe_timelapse_T.png", dpi=300)
plt.close(fig)
