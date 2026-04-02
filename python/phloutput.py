from matplotlib.pyplot import *
import h5py
import numpy as np
import glob
import os
import re
from mpl_toolkits.axes_grid1 import make_axes_locatable
from scipy.interpolate import interp1d
import scipy
from mpl_toolkits.axes_grid1 import make_axes_locatable
from scipy.ndimage import zoom
from matplotlib.colors import LogNorm
from phleos import *

ptwidth = 255.114
ptheight = 705
ptwidthp = 521.5744745987562 
inchpt = 0.0138889

width = ptwidth * inchpt
pwidth = ptwidthp * inchpt
height = ptheight * inchpt
scrdpi = 100
savedpi = 300

fontsize = 9
label_fontsize = 1.1*fontsize
legend_fontsize = 0.9*fontsize
rcParams['font.size'] = fontsize
rcParams['axes.titlesize'] = label_fontsize
rcParams['axes.labelsize'] = label_fontsize
rcParams['legend.fontsize'] = legend_fontsize
rcParams["legend.labelspacing"] = 0.4
rcParams['xtick.labelsize'] = fontsize
rcParams['ytick.labelsize'] = fontsize
rcParams['legend.frameon'] = True
rcParams['legend.facecolor'] = 'white'
rcParams['legend.framealpha'] = 0.8
rcParams['legend.fancybox'] = True
rcParams['legend.edgecolor'] = 'lightgray'
rcParams['lines.linewidth'] = 1.
rc('text', usetex=True)
rc('text.latex', preamble=r'\usepackage{txfonts}'+ r'\usepackage{bm}'+ r'\newcommand{\mach}[0]{\mathcal{M}}')

#---------------------------------------------------------------------------------------

def generate_grid_free(nx,ny,deltax,deltay,dx,dy,aE,aW,aS,aN,single_column=False):

    px = nx*deltax + (nx-1)*dx + aE + aW
    py = ny*deltay + (ny-1)*dy + aN + aS

    s = aS/py
    n = aN/py
    e = aE/px
    w = aW/px

    if(single_column):
     fig,axs=subplots(ny,nx,\
     figsize=(px*width,py*width), dpi=scrdpi)
    else:
     fig,axs=subplots(ny,nx,\
     figsize=(px*pwidth,py*pwidth), dpi=scrdpi)

    fig.subplots_adjust(bottom=s,top=1-n,left=w,right=1-e,wspace=dx/deltax, hspace=dy/deltay)

    return fig,axs,[w,s,n,e],px,py

#---------------------------------------------------------------------------------------

CONST_RGAS = 8.31446261815324e7
CONST_RAD = 7.565767381646406e-15
CONST_GRAV = 6.67428e-8
CONST_RSUN = 6.95660e10
CONST_PI = 3.141592653589793238
CONST_C = 2.99792458e10
CONST_AV = 6.02214076e23
CONST_QE = 4.8032042712e-10
CONST_KB = 1.380650424e-16
CONST_MU = 1.660538782e-24
CONST_H = 6.62606896e-27

#---------------------------------------------------------------------------------------

try:
 data = os.environ['PHLEGETHONDATA'].split(os.pathsep)[0]
except KeyError:
 data = '../../data/'

#######################################################################################
# point-probe class
#######################################################################################

def read_data(file,n1):
    
    f = open(file,'rb')
    data = np.fromfile(file=f,dtype='f8')
    nvars = round(data.shape[0]/n1)
    shape = (n1,nvars)
    data = data.reshape(shape)
    f.close()
    u = data[:, :]
    del data
    data = u.astype(np.float64, copy=False)
    return data

class Probe:

    def __init__(self,i1,i2,i3,nprobe=1,dire='./'):

        self.nprobe = nprobe
        self.dir = dire

        list_dir = os.listdir(dire)
        probes = [entry for entry in list_dir if entry.startswith("pp%d"%(self.nprobe))]

        idx_probes = []
        for probe in probes:
         nb = re.findall(r'\d+',probe)
         idx_probes.append(int(nb[1]))

        self.idx_probes = np.array(sorted(idx_probes))

    def time_series(self,idx_var=0):

        signal = []
        t = []

        idx_pvs = 0
        for index in self.idx_probes:
          nelmts = index+1-idx_pvs
          idx_pvs = index+1
          pp = read_data('%s/pp%d_%d.dat'%(self.dir,self.nprobe,index),nelmts)
          signal.extend(pp[:,idx_var])
          t.extend(pp[:,-1])

        t = np.array(t)

        self.dt = np.gradient(t)
        self.t = t
        self.signal = np.array(signal)

    def power_spectrum(self,tini,tfin,Nw=11,subtract_base=True):

         ki = np.where((self.t>=tini) &(self.t<=tfin))[0]
         self.t_cut = self.t[ki]
         self.signal_cut = self.signal[ki]
         self.dt_cut = self.dt[ki]

         if(subtract_base):
          c = np.polyfit(self.t_cut,self.signal_cut,2)
          self.signal_cut -= np.poly1d(c)(self.t_cut)

         n = len(self.signal_cut)

         window_func = np.hanning
         window = window_func(n)
         f = np.fft.fftfreq(n, d=self.dt_cut)
         p = np.abs(np.fft.fft(self.signal_cut*window))**2

         sl = np.s_[0:n//2-1]
         self.freq = f[sl]
         p = p[sl]

         self.pow = np.convolve(p, np.ones(Nw)/Nw, mode='same')
                                                                    
#######################################################################################
# h5spj class
#######################################################################################

def spj_list(path=""):

   filelist = glob.glob(os.path.join(path,'*.h5'))
   files = []

   for file in filelist:
     f = os.path.basename(file)
     m = re.search('spj_n([0-9]{5,})\\.(h5)$', f)
     if m:
       files.append((int(m.group(1)), f))

   files.sort(key=lambda x: x[0])

   return files
 
class h5spj:

    def __init__(self,filename,path='./',path_to_grids='./',mode='i',data_path=data,helm_table='helm_table_timmes_x2.dat',pig_table='401x401_pig_table_h2_offset.dat',
    NRHO=541,NT=201,LOGRHOMIN=-12.0,LOGRHOMAX=15.0,LOGTMIN=3.0,LOGTMAX=13.0):

        if(mode=='n'):
            filename = path+'spj_n{:05}.h5'.format(filename)
        if(mode=='i'):
            filename = spj_list(path=path)[filename][1]
        else:
          raise ValueError('Unknown mode' + str(mode),': mode must be n or i')

        filename = path+filename
        self.grid = h5py.File(filename,"r")['grid']

        self.time = self.grid['time'][()]
        self.dt = self.grid['dt'][()]
        self.step = self.grid['step'][()]
        self.r = self.grid['r'][()]
        self.nhydro = self.grid['nhydro'][()]

        self.grid0 = h5grid(0,path=path_to_grids,data_path=data_path,helm_table=helm_table,pig_table=pig_table,
        NRHO=NRHO,NT=NT,LOGRHOMIN=LOGRHOMIN,LOGRHOMAX=LOGRHOMAX,LOGTMIN=LOGTMIN,LOGTMAX=LOGTMAX)

        self.eos_evaluated = False

        self.vars = []
        self.phi = []
        self.theta = []
        self.phi_vec = []
        self.theta_vec = []

        for ir in range(len(self.r)):
 
         self.plane = h5py.File(filename,"r")['plane_{:05}'.format(ir+1)]
         self.phi.append(self.plane['phi'][()])
         self.theta.append(self.plane['theta'][()])
         phiv,thetav = np.meshgrid(self.phi[ir],self.theta[ir])
         self.phi_vec.append(phiv)
         self.theta_vec.append(thetav)
         self.vars.append(self.plane['vars'][()])

    def coords(self,ir=0):
        x = self.r[ir]*np.sin(self.theta_vec[ir])*np.cos(self.phi_vec[ir])
        y = self.r[ir]*np.sin(self.theta_vec[ir])*np.sin(self.phi_vec[ir])
        z = self.r[ir]*np.cos(self.theta_vec[ir])
        self.ir = ir
        return x,y,z

    def prim(self,ir=0):
        self.ir = ir
        return self.vars[ir][:,:,:self.nhydro]

    def bfield(self,ir=0):
        self.ir = ir
        return self.vars[ir][:,:,-3:]

    def br(self,ir=0):

        x,y,z=self.coords(ir=ir)
        b = self.bfield(ir=ir)
        return (x*b[:,:,0]+y*b[:,:,1]+z*b[:,:,2])/self.r[ir]

    def bh(self,ir=0):
        return np.sqrt(self.abs_bfield(ir=ir)**2-self.br(ir=ir)**2)

    def T(self,ir=0):
        self.ir = ir
        return self.vars[ir][:,:,self.nhydro]

    def rho(self,ir=0):
        return self.prim(ir=ir)[:,:,self.grid0.i_rho]

    def vel(self,ir=0):
        return self.prim(ir=ir)[:,:,self.grid0.i_vx1:self.grid0.i_vx3+1]
 
    def vr(self,ir=0):

        x,y,z=self.coords(ir=ir)
        v = self.vel(ir=ir)
        return (x*v[:,:,0]+y*v[:,:,1]+z*v[:,:,2])/self.r[ir]

    def vh(self,ir=0):
        return np.sqrt(self.abs_vel(ir=ir)**2-self.vr(ir=ir)**2)

    def mom(self,ir=0):
        return self.rho(ir=ir)*self.vel(ir=ir)

    def abs_vel(self,ir=0):
        return np.sqrt(np.sum(self.vel(ir=ir)**2,axis=2))
 
    def P(self,ir=0):
        return self.prim(ir=ir)[:,:,self.grid0.i_p]

    def asc(self,ir=0):
        return self.prim(ir=ir)[:,:,self.grid0.i_as1:]

    def X_species(self,ir=0):
        return self.prim(ir=ir)[:,:,self.grid0.i_X1:self.grid0.i_X1+self.grid0.nspecies]

    def ye(self,ir=0):

        if(self.grid0.advect_yeiabar=='true'):
            return self.prim(ir=ir)[:,:,self.grid0.i_ye]
        elif(self.grid0.advect_species=='true'):
          X = self.X_species(ir=ir)
          ye = 0.0
          for i in range(self.grid0.nspecies):
            ye += X[:,:,i]*self.grid0.Z[i]/self.grid0.A[i]
          return ye
        else:
          if(self.grid0.use_pig=='true'):
           return np.ones_like(self.rho(ir=ir))
          else:
           return np.ones_like(self.rho(ir=ir))*0.5

    def abar(self,ir=0):

        if(self.grid0.advect_yeiabar=='true'):
            return 1.0/self.prim(ir=ir)[:,:,self.grid0.i_iabar]
        elif(self.grid0.advect_species=='true'):
          X = self.X_species(ir=ir)
          iabar = 0.0
          for i in range(self.grid0.nspecies):
            iabar += X[:,:,i]/self.grid0.A[i]
          return 1.0/iabar
        else:
          if(self.grid0.use_pig=='true'):
           return np.ones_like(self.rho(ir=ir))
          else:
           return np.ones_like(self.rho(ir=ir))*(self.grid0.mub/(1.0-self.grid0.mub/2.0))

    def zbar(self,ir=0):

        abar = self.abar(ir=ir) 
        ye = self.ye(ir=ir)
        return ye*abar
    
    def mu(self,ir=0):

        if(self.grid0.use_pig=='true'):
         rho = self.rho(ir=ir) 
         T = self.T(ir=ir)
         P = self.P(ir=ir)
         mu = (rho*CONST_RGAS*T)/P
        else:
         abar = self.abar(ir=ir)
         zbar = self.zbar(ir=ir)
         mu = abar / (zbar+1.0)
        return mu

    def emag(self,ir=0):
        return 0.5*np.sum(self.bfield(ir=ir)**2,axis=2)
 
    def abs_bfield(self,ir=0):
        return np.sqrt(2.0*self.emag(ir=ir))
   
    def eint(self,ir=0):

        rho = self.rho(ir=ir)
        T = self.T(ir=ir)
        abar = self.abar(ir=ir)
        zbar = self.zbar(ir=ir)

        self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
        gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)

        return self.full[id_E]

    def enthalpy(self,ir=0):

        rho = self.rho(ir=ir)
        eint = self.eint(ir=ir)
        P = self.P(ir=ir)
        return rho*eint+P

    def ekin(self,ir=0):

        vel = self.vel(ir=ir)
        rho = self.rho(ir=ir)

        return 0.5*rho*np.sum(vel**2,axis=2)

    def sound(self,ir=0):

        rho = self.rho(ir=ir)
        T = self.T(ir=ir)
        abar = self.abar(ir=ir)
        zbar = self.zbar(ir=ir)

        self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
        gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)

        return self.full[id_sound]

    def mach(self,ir=0):
        return self.abs_vel(ir=ir)/self.sound(ir=ir)

    def mach_vec(self,ir=0):
        return self.vel(ir=ir)/self.sound(ir=ir)

    def cp(self,ir=0):

        rho = self.rho(ir=ir)
        T = self.T(ir=ir)
        abar = self.abar(ir=ir)
        zbar = self.zbar(ir=ir)

        self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
        gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)

        return self.full[id_cp]

    def cv(self,ir=0):

        rho = self.rho(ir=ir)
        T = self.T(ir=ir)
        abar = self.abar(ir=ir)
        zbar = self.zbar(ir=ir)

        self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
        gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)

        return self.full[id_cv]

    def nabla_ad(self,ir=0):

        rho = self.rho(ir=ir)
        T = self.T(ir=ir)
        abar = self.abar(ir=ir)
        zbar = self.zbar(ir=ir)

        self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
        gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
        self.eos_evaluated = True

        return self.full[id_nabla_ad]

    def s(self,ir=0):

        rho = self.rho(ir=ir)
        T = self.T(ir=ir)
        abar = self.abar(ir=ir)
        zbar = self.zbar(ir=ir)

        self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
        gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
        self.eos_evaluated = True

        return self.full[id_s]

    def delta(self,ir=0):

        rho = self.rho(ir=ir)
        T = self.T(ir=ir)
        abar = self.abar(ir=ir)
        zbar = self.zbar(ir=ir)

        self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
        gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
        self.eos_evaluated = True

        return self.full[id_delta]

    def phi(self,ir=0):

        rho = self.rho(ir=ir)
        T = self.T(ir=ir)
        abar = self.abar(ir=ir)
        zbar = self.zbar(ir=ir)

        self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
        gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
        self.eos_evaluated = True

        return self.full[id_phi]

    def gamma1(self,ir=0):

        rho = self.rho(ir=ir)
        T = self.T(ir=ir)
        abar = self.abar(ir=ir)
        zbar = self.zbar(ir=ir)

        self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
        gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
        self.eos_evaluated = True

        return self.full[id_gam1]

    def gamma2(self,ir=0):

        rho = self.rho(ir=ir)
        T = self.T(ir=ir)
        abar = self.abar(ir=ir)
        zbar = self.zbar(ir=ir)

        self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
        gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
        self.eos_evaluated = True

        return self.full[id_gam2]

    def gamma3(self,ir=0):

        rho = self.rho(ir=ir)
        T = self.T(ir=ir)
        abar = self.abar(ir=ir)
        zbar = self.zbar(ir=ir)

        self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
        gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
        self.eos_evaluated = True

        return self.full[id_gam3]

    def mollweide(self,out,ichx=12,ichy=6, \
    figdpi=500,figname=None, \
    cb_lbl='',cb_pad=0.05,cb_pos='horizontal', \
    time_in_days=True, \
    coords_in_Rsun=True, \
    showfig=True, \
    showgrid=False, \
    use_latex=False, \
    fontsize=15, \
    **kwargs):

     label_fontsize = 1.1*fontsize
     legend_fontsize = 0.9*fontsize
     rcParams['font.size'] = fontsize
     rcParams['axes.titlesize'] = label_fontsize
     rcParams['axes.labelsize'] = label_fontsize
     rcParams['legend.fontsize'] = legend_fontsize
     rcParams["legend.labelspacing"] = 0.4
     rcParams['xtick.labelsize'] = fontsize
     rcParams['ytick.labelsize'] = fontsize
     rcParams['legend.frameon'] = True
     rcParams['legend.facecolor'] = 'white'
     rcParams['legend.framealpha'] = 0.8
     rcParams['legend.fancybox'] = True
     rcParams['legend.edgecolor'] = 'lightgray'
     rcParams['lines.linewidth'] = 1.
     rc('text', usetex=use_latex)
     rc('text.latex', preamble=r'\usepackage{txfonts}'+ r'\usepackage{bm}'+ r'\newcommand{\mach}[0]{\mathcal{M}}')

     if(showfig):
      ion()
     else:
      ioff()

     fig = figure(figsize=(ichx,ichy))
     axs = fig.add_subplot(111, projection='mollweide')
 
     lon = np.pi-self.phi_vec[self.ir]
     lat = np.pi/2.0-self.theta_vec[self.ir]

     im = axs.pcolormesh(lon,lat,out,shading='nearest',**kwargs)

     if(time_in_days):
       title = r'$t=%.3f\ [\mathrm{d}]$'%(self.time/86400.0) 
     else:
       title = r'$t=%.3f\ [\mathrm{d}]$'%(self.time) 

     if(coords_in_Rsun):
       title += r'$,\ r=%.3f\ [\mathrm{R}_\odot]$'%(self.r[self.ir]/CONST_RSUN)
     else: 
       title += r'$,\ r=%.3f\ [\mathrm{cm}]$'%(self.r[self.ir])
 
     axs.set_title(title)
    
     colorbar(im,orientation=cb_pos,pad=cb_pad,label=cb_lbl)

     if(showgrid):
      grid(True)
      axs.set_xlabel(r'$\phi$')
      axs.set_ylabel(r'$\theta$')
     else:
      grid(False)
      axs.set_xticklabels([])
      axs.set_yticklabels([])

     if(figname!=None):
      savefig(figname,dpi=figdpi)

     if(showfig):
      show()
     else:
      close()

     rc('text', usetex=False)

#######################################################################################
# h5plane class
#######################################################################################

def plane_list(path=""):

   filelist = glob.glob(os.path.join(path,'*.h5'))
   files = []

   for file in filelist:
     f = os.path.basename(file)
     m = re.search('planes_n([0-9]{5,})\\.(h5)$', f)
     if m:
       files.append((int(m.group(1)), f))

   files.sort(key=lambda x: x[0])

   return files

class h5plane:

    def __init__(self,filename,path='./',path_to_grids='./',mode='i',data_path=data,helm_table='helm_table_timmes_x2.dat',pig_table='401x401_pig_table_h2_offset.dat',
    NRHO=541,NT=201,LOGRHOMIN=-12.0,LOGRHOMAX=15.0,LOGTMIN=3.0,LOGTMAX=13.0):
        if(mode=='n'):
            filename = path+'planes_n{:05}.h5'.format(filename)
        if(mode=='i'):
            filename = plane_list(path=path)[filename][1]
        else:
          raise ValueError('Unknown mode' + str(mode),': mode must be n or i')

        filename = path+filename
        self.grid = h5py.File(filename,"r")['grid']

        self.time = self.grid['time'][()]
        self.step = self.grid['step'][()]
        self.dt = self.grid['dt'][()]

        self.nplanes_x1 = self.grid['nplanes_x1'][()]
        self.nplanes_x2 = self.grid['nplanes_x2'][()]
        self.nplanes_x3 = self.grid['nplanes_x3'][()]

        self.planes = {}
        self.planes['x1'] = {}
        self.planes['x2'] = {}
        self.planes['x3'] = {}

        self.planes['x1']['prim'] = []
        self.planes['x1']['temp'] = []
        self.planes['x1']['bfield'] = []

        self.planes['x2']['prim'] = []
        self.planes['x2']['temp'] = []
        self.planes['x2']['bfield'] = []

        self.planes['x3']['prim'] = []
        self.planes['x3']['temp'] = []
        self.planes['x3']['bfield'] = []

        try:
         self.planes_x1_index = np.array(self.grid['planes_x1_index'][()])
        except:
         self.planes_x1_index = None

        try:
         self.planes_x2_index = np.array(self.grid['planes_x2_index'][()])
        except:
         self.planes_x2_index = None

        try:
         self.planes_x3_index = np.array(self.grid['planes_x3_index'][()])
        except:
         self.planes_x3_index = None

        #x1-slices
        for ip in range(self.nplanes_x1):
         self.planes['x1']['prim'].append(self.grid['prim_x1_n{:05d}'.format(ip+1)][()])
         self.planes['x1']['temp'].append(self.grid['temp_x1_n{:05d}'.format(ip+1)][()])
         try:
          self.planes['x1']['bfield'].append(self.grid['bfield_x1_n{:05d}'.format(ip+1)][()])
         except:
          dummy = 0

        #x2-slices
        for ip in range(self.nplanes_x2):
         self.planes['x2']['prim'].append(self.grid['prim_x2_n{:05d}'.format(ip+1)][()])
         self.planes['x2']['temp'].append(self.grid['temp_x2_n{:05d}'.format(ip+1)][()])
         try:
          self.planes['x2']['bfield'].append(self.grid['bfield_x2_n{:05d}'.format(ip+1)][()])
         except:
          dummy = 0

        #x3-slices
        for ip in range(self.nplanes_x3):
         self.planes['x3']['prim'].append(self.grid['prim_x3_n{:05d}'.format(ip+1)][()])
         self.planes['x3']['temp'].append(self.grid['temp_x3_n{:05d}'.format(ip+1)][()])
         try:
          self.planes['x3']['bfield'].append(self.grid['bfield_x3_n{:05d}'.format(ip+1)][()])
         except:
          dummy = 0

        self.eos_evaluated = False
 
        self.grid0 = h5grid(0,path=path_to_grids,data_path=data_path,helm_table=helm_table,pig_table=pig_table,NRHO=NRHO,NT=NT,LOGRHOMIN=LOGRHOMIN,LOGRHOMAX=LOGRHOMAX,LOGTMIN=LOGTMIN,LOGTMAX=LOGTMAX)

    def prim(self,ix=-1,iy=-1,iz=-1):
     self.ix = ix
     self.iy = iy
     self.iz = iz
     if(ix>=0):
      ik = np.where((self.planes_x1_index-1)==ix)[0][0]
      return self.planes['x1']['prim'][ik].transpose(2,1,0)
     if(iy>=0):
      ik = np.where((self.planes_x2_index-1)==iy)[0][0]
      return self.planes['x2']['prim'][ik].transpose(2,1,0)
     if(iz>=0):
      ik = np.where((self.planes_x3_index-1)==iz)[0][0]
      return self.planes['x3']['prim'][ik].transpose(2,1,0)

    def bfield(self,ix=-1,iy=-1,iz=-1):
     self.ix = ix
     self.iy = iy
     self.iz = iz
     if(ix>=0):
      ik = np.where((self.planes_x1_index-1)==ix)[0][0]
      return self.planes['x1']['bfield'][ik].transpose(2,1,0)
     if(iy>=0):
      ik = np.where((self.planes_x2_index-1)==iy)[0][0]
      return self.planes['x2']['bfield'][ik].transpose(2,1,0)
     if(iz>=0):
      ik = np.where((self.planes_x3_index-1)==iz)[0][0]
      return self.planes['x3']['bfield'][ik].transpose(2,1,0)

    def T(self,ix=-1,iy=-1,iz=-1):
     self.ix = ix
     self.iy = iy
     self.iz = iz
     if(ix>=0):
      ik = np.where((self.planes_x1_index-1)==ix)[0][0]
      return self.planes['x1']['temp'][ik].transpose(1,0)
     if(iy>=0):
      ik = np.where((self.planes_x2_index-1)==iy)[0][0]
      return self.planes['x2']['temp'][ik].transpose(1,0)
     if(iz>=0):
      ik = np.where((self.planes_x3_index-1)==iz)[0][0]
      return self.planes['x3']['temp'][ik].transpose(1,0)

    def rho(self,ix=-1,iy=-1,iz=-1):
      return self.prim(ix=ix,iy=iy,iz=iz)[self.grid0.i_rho]

    def vel(self,ix=-1,iy=-1,iz=-1):
      return self.prim(ix=ix,iy=iy,iz=iz)[self.grid0.i_vx1:self.grid0.i_vx3+1]
 
    def mom(self,ix=-1,iy=-1,iz=-1):
        return self.rho(ix=ix,iy=iy,iz=iz)*self.vel(ix=ix,iy=iy,iz=iz)

    def abs_vel(self,ix=-1,iy=-1,iz=-1):
        return np.sqrt(np.sum(self.vel(ix=ix,iy=iy,iz=iz)**2,axis=0))
 
    def vr(self,ix=-1,iy=-1,iz=-1):

      vel = self.vel(ix=ix,iy=iy,iz=iz)
      coords = self.grid0.coords(ix=ix,iy=iy,iz=iz)

      shape_plane = vel[0].shape
      shape_grid = coords[0].shape

      if(shape_plane!=shape_grid):
       coords = zoom(coords, zoom=2, order=1) 

      if(self.grid0.geometry!='cartesian'):
       vr = vel[0]
      elif(self.grid0.geometry=='cartesian') and (self.grid0.use_internal_boundaries=='true'):
       r = self.grid0.r(ix=ix,iy=iy,iz=iz)
       if(shape_plane!=shape_grid):
        r = zoom(r, zoom=2, order=1) 
       if(self.grid0.sdims==2):
         vr = (coords[0]*vel[0]+coords[1]*vel[1])/r
       if(self.grid0.sdims==3):
         vr = (coords[0]*vel[0]+coords[1]*vel[1]+coords[2]*vel[2])/r
      else:
       vr = vel[1]

      return vr
 
    def vh(self,ix=-1,iy=-1,iz=-1):

     vr = self.vr(ix=ix,iy=iy,iz=iz)
     vabs = self.abs_vel(ix=ix,iy=iy,iz=iz)
     return np.sqrt(vabs*vabs-vr*vr)

    def P(self,ix=-1,iy=-1,iz=-1):
      return self.prim(ix=ix,iy=iy,iz=iz)[self.grid0.i_p]

    def asc(self,ix=-1,iy=-1,iz=-1):
      return self.prim(ix=ix,iy=iy,iz=iz)[self.grid0.i_as1:]

    def X_species(self,ix=-1,iy=-1,iz=-1):
      return self.prim(ix=ix,iy=iy,iz=iz)[self.grid0.i_X1:self.grid0.i_X1+self.grid0.nspecies]

    def ye(self,ix=-1,iy=-1,iz=-1):

        if(self.grid0.advect_yeiabar=='true'):
         return self.prim(ix=ix,iy=iy,iz=iz)[self.grid0.i_ye]
        elif(self.grid0.advect_species=='true'):
          X = self.X_species(ix=ix,iy=iy,iz=iz)
          ye = 0.0
          for i in range(self.grid0.nspecies):
            ye += X[i]*self.grid0.Z[i]/self.grid0.A[i]
          return ye
        else:
          if(self.grid0.use_pig=='true'):
           return np.ones_like(self.rho(ix=ix,iy=iy,iz=iz))
          else:
           return np.ones_like(self.rho(ix=ix,iy=iy,iz=iz))*0.5

    def abar(self,ix=-1,iy=-1,iz=-1):

        if(self.grid0.advect_yeiabar=='true'):
         return 1.0/self.prim(ix=ix,iy=iy,iz=iz)[self.grid0.i_iabar]
        elif(self.grid0.advect_species=='true'):
          X = self.X_species(ix=ix,iy=iy,iz=iz)
          iabar = 0.0
          for i in range(self.grid0.nspecies):
            iabar += X[i]/self.grid0.A[i]
          return 1.0/iabar
        else:
          if(self.grid0.use_pig=='true'):
           return np.ones_like(self.rho(ix=ix,iy=iy,iz=iz))
          else:
           return np.ones_like(self.rho(ix=ix,iy=iy,iz=iz))*(self.grid0.mub/(1.0-self.grid0.mub/2.0))

    def zbar(self,ix=-1,iy=-1,iz=-1):

        abar = self.abar(ix=ix,iy=iy,iz=iz) 
        ye = self.ye(ix=ix,iy=iy,iz=iz)
        return ye*abar
    
    def mu(self,ix=-1,iy=-1,iz=-1):

        if(self.grid0.use_pig=='true'):
         rho = self.rho(ix=ix,iy=iy,iz=iz)
         T = self.T(ix=ix,iy=iy,iz=iz)
         P = self.P(ix=ix,iy=iy,iz=iz)
         mu = (rho*CONST_RGAS*T)/P
        else:
         abar = self.abar(ix=ix,iy=iy,iz=iz)
         zbar = self.zbar(ix=ix,iy=iy,iz=iz)
         mu = abar/(zbar+1.0)
        return mu

    def emag(self,ix=-1,iy=-1,iz=-1):
        return 0.5*np.sum(self.bfield(ix=ix,iy=iy,iz=iz)**2,axis=0)
 
    def abs_bfield(self,ix=-1,iy=-1,iz=-1):
        return np.sqrt(2.0*self.emag(ix=ix,iy=iy,iz=iz))
  
    def br(self,ix=-1,iy=-1,iz=-1):

      b = self.bfield(ix=ix,iy=iy,iz=iz)
      coords = self.grid0.coords(ix=ix,iy=iy,iz=iz)

      shape_plane = b[0].shape
      shape_grid = coords[0].shape

      if(shape_plane!=shape_grid):
       coords = zoom(coords, zoom=2, order=1) 

      if(self.grid0.geometry!='cartesian'):
       br = b[0]
      elif(self.grid0.geometry=='cartesian') and (self.grid0.use_internal_boundaries=='true'):
       r = self.grid0.r(ix=ix,iy=iy,iz=iz)
       if(shape_plane!=shape_grid):
        r = zoom(r, zoom=2, order=1) 
       if(self.grid0.sdims==2):
         br = (coords[0]*b[0]+coords[1]*b[1])/r
       if(self.grid0.sdims==3):
         br = (coords[0]*b[0]+coords[1]*b[1]+coords[2]*b[2])/r
      else:
       br = b[1]

      return br
 
    def bh(self,ix=-1,iy=-1,iz=-1):

     br = self.br(ix=ix,iy=iy,iz=iz)
     babs = self.abs_bfield(ix=ix,iy=iy,iz=iz)
     return np.sqrt(babs*babs-br*br)

    def eint(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
         self.eos_evaluated = True

        return self.full[id_E]

    def enthalpy(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        eint = self.eint(ix=ix,iy=iy,iz=iz)
        P = self.P(ix=ix,iy=iy,iz=iz)
        return rho*eint+P

    def ekin(self,ix=-1,iy=-1,iz=-1):

        vel = self.vel(ix=ix,iy=iy,iz=iz)
        rho = self.rho(ix=ix,iy=iy,iz=iz)

        return 0.5*rho*np.sum(vel**2,axis=0)

    def sound(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
         self.eos_evaluated = True

        return self.full[id_sound]

    def mach(self,ix=-1,iy=-1,iz=-1):
        return self.abs_vel(ix=ix,iy=iy,iz=iz)/self.sound(ix=ix,iy=iy,iz=iz)

    def mach_vec(self,ix=-1,iy=-1,iz=-1):
        return self.vel(ix=ix,iy=iy,iz=iz)/self.sound(ix=ix,iy=iy,iz=iz)

    def cp(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
         self.eos_evaluated = True

        return self.full[id_cp]

    def cv(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
         self.eos_evaluated = True

        return self.full[id_cv]

    def nabla_ad(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
         self.eos_evaluated = True

        return self.full[id_nabla_ad]

    def s(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
         self.eos_evaluated = True

        return self.full[id_s]

    def delta(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
         self.eos_evaluated = True

        return self.full[id_delta]

    def phi(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
         self.eos_evaluated = True

        return self.full[id_phi]

    def gamma1(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
         self.eos_evaluated = True

        return self.full[id_gam1]

    def gamma2(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
         self.eos_evaluated = True

        return self.full[id_gam2]

    def gamma3(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.grid0.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.grid0.gamma_gas,eos_mode=self.grid0.eos_mode)
         self.eos_evaluated = True

        return self.full[id_gam3]

    def planeshow(self,out,ichx=12,ichy=6, \
    figdpi=500,figname=None, \
    x_lbl=r'$x$',y_lbl=r'$y$', \
    cb_lbl='',cb_pad=0.05,cb_size="5%",cb_pos='right', \
    time_in_days=True,coords_in_Rsun=True, \
    Rstar=-1, \
    showfig=True, \
    use_latex=False, \
    fontsize=15, \
    **kwargs):

     label_fontsize = 1.1*fontsize
     legend_fontsize = 0.9*fontsize
     rcParams['font.size'] = fontsize
     rcParams['axes.titlesize'] = label_fontsize
     rcParams['axes.labelsize'] = label_fontsize
     rcParams['legend.fontsize'] = legend_fontsize
     rcParams["legend.labelspacing"] = 0.4
     rcParams['xtick.labelsize'] = fontsize
     rcParams['ytick.labelsize'] = fontsize
     rcParams['legend.frameon'] = True
     rcParams['legend.facecolor'] = 'white'
     rcParams['legend.framealpha'] = 0.8
     rcParams['legend.fancybox'] = True
     rcParams['legend.edgecolor'] = 'lightgray'
     rcParams['lines.linewidth'] = 1.
     rc('text', usetex=use_latex)
     rc('text.latex', preamble=r'\usepackage{txfonts}'+ r'\usepackage{bm}'+ r'\newcommand{\mach}[0]{\mathcal{M}}')

     if(showfig):
      ion()
     else:
      ioff()

     fig, axs = subplots(figsize=(ichx,ichy))

     coords = self.grid0.coords(ix=self.ix,iy=self.iy,iz=self.iz)

     if(self.grid0.geometry=='cartesian'):
      if(self.ix>=0):
       x = coords[1]
       y = coords[2]
      if(self.iy>=0):
       x = coords[0]
       y = coords[2]
     if(self.iz>=0):
       x = coords[0]
       y = coords[1]

     if(self.grid0.geometry=='2d-polar' or self.grid0.geometry=='2d-spherical'):
       x = coords[0]
       y = coords[1]

     if(self.grid0.geometry=='3d-spherical'):
      if(self.ix>=0):
       x = coords[0]
       y = coords[1]
      if(self.iy>=0):
       x = coords[1]
       y = coords[0]
      if(self.iz>=0):
       x = np.sqrt(coords[0]**2+coords[1]**2)
       y = coords[2]

     if(coords_in_Rsun):
      x /= CONST_RSUN
      y /= CONST_RSUN
      x_lbl+=r'$\ [\mathrm{R}_\odot]$'
      y_lbl+=r'$\ [\mathrm{R}_\odot]$'
     else:
      if(Rstar>0):
       x /= Rstar
       y /= Rstar
       x_lbl+=r'$\ [\mathrm{R}_\star]$'
       y_lbl+=r'$\ [\mathrm{R}_\star]$'
      else:
       x_lbl+=r'$\ [\mathrm{cm}]$'
       y_lbl+=r'$\ [\mathrm{cm}]$'

     shape_plane = out.shape
     shape_grid = x.shape

     if(shape_plane!=shape_grid):
      x = zoom(x, zoom=2, order=1) 
      y = zoom(y, zoom=2, order=1)

     im = axs.pcolormesh(x,y,out,shading='nearest',**kwargs)
     axs.axes.set_aspect('equal')

     axs.set_xlabel(x_lbl)
     axs.set_ylabel(y_lbl)

     if(time_in_days):
       axs.set_title(r'$t=%.3f\ [\mathrm{d}]$'%(self.time/86400.0))
     else:
      axs.set_title(r'$t=%.3f\ [\mathrm{s}]$'%(self.time))

     divider = make_axes_locatable(axs)
     cax = divider.append_axes(cb_pos,size=cb_size,pad=cb_pad)

     if(cb_pos=='left' or cb_pos=='right'):
      orientation='vertical'
     else:
      orientation='horizontal'

     cb = fig.colorbar(im,cax=cax,label=cb_lbl,orientation=orientation)

     if(figname!=None):
      savefig(figname,dpi=figdpi)

     if(showfig):
      show()
     else:
      close()

     rc('text', usetex=False)

#######################################################################################
# h5grid class
#######################################################################################

def file_list(path=""):

   filelist = glob.glob(os.path.join(path,'*.h5'))
   files = []

   for file in filelist:
     f = os.path.basename(file)
     m = re.search('grid_n([0-9]{5,})\\.(h5)$', f)
     if m:
       files.append((int(m.group(1)), f))

   files.sort(key=lambda x: x[0])

   return files

class h5grid:

    def __init__(self,filename,path='./',mode='i',data_path=data,helm_table='helm_table_timmes_x2.dat',pig_table='401x401_pig_table_h2_offset.dat',
    NRHO=541,NT=201,LOGRHOMIN=-12.0,LOGRHOMAX=15.0,LOGTMIN=3.0,LOGTMAX=13.0):
        if(mode=='n'):
            filename = path+'grid_n{:05}.h5'.format(filename)
        if(mode=='i'):
            filename = file_list(path=path)[filename][1]
        else:
          raise ValueError('Unknown mode' + str(mode),': mode must be n or i')

        filename = path+filename
        self.grid = h5py.File(filename,"r")['grid']
        
        path0 = path+'grid_n{:05}.h5'.format(0)
        f0 = h5py.File(path0,"r")
        self.grid0 = f0['grid']

        self.gamma_gas = self.grid0['gamma_ad'][()]
        self.mub = self.grid0['mu'][()]
        self.x1l = self.grid0['x1l'][()]
        self.x1u = self.grid0['x1u'][()]
        self.x2l = self.grid0['x2l'][()]
        self.x2u = self.grid0['x2u'][()]
        self.x3l = self.grid0['x3l'][()]
        self.x3u = self.grid0['x3u'][()]
        self.sdims = self.grid0['sdims'][()]
        self.nx1 = self.grid0['nx1'][()]
        self.nx2 = self.grid0['nx2'][()]
        self.nx3 = self.grid0['nx3'][()]

        self.advect_yeiabar = self.grid0.attrs['advect_yeiabar'].decode('ASCII')
        self.advect_species = self.grid0.attrs['advect_species'].decode('ASCII')
        self.use_prad = self.grid0.attrs['use_prad'].decode('ASCII')
        self.use_helmholtz = self.grid0.attrs['use_helmholtz'].decode('ASCII')
        try:
         self.use_coulomb_corrections = self.grid0.attrs['use_coulomb_corrections'].decode('ASCII')
        except:
         self.use_coulomb_corrections = 'false'
        try:
         self.use_pig = self.grid0.attrs['use_pig'].decode('ASCII')
        except:
         self.use_pig = 'false'

        try:
         self.use_gravity_solver = self.grid0.attrs['use_gravity_solver'].decode('ASCII')
        except:
         self.use_gravity_solver = 'false'
        try:
         self.use_internal_boundaries = self.grid0.attrs['use_internal_boundaries'].decode('ASCII')
        except:
         self.use_internal_boundaries = 'false'
        self.geometry = self.grid0.attrs['geometry-type'].decode('ASCII')
        if(self.geometry!='cartesian') or (self.use_internal_boundaries=='true'):
           self.r_coords = self.grid0['r'][()]
        else:
           self.r_coords =  self.grid0['coords'][:,:,:,1]
           
        try:
         self.A = np.array(self.grid0['A'][()])
         self.Z = np.array(self.grid0['Z'][()])
         self.nspecies = len(self.A)
        except:
         self.A = 'mass numbers not available'
         self.Z = 'charge numbers not available'
         self.nspecies = 'species not available'

        try:
          self.name_species = [s.decode('utf-8') for s in self.grid0.attrs['name_species']]
          self.name_reacs = [s.decode('utf-8') for s in self.grid0.attrs['name_reacs']]
          self.nreacs = len(self.name_reacs)
        except:
          self.name_species = 'species not available'
          self.name_reacs = 'nuclear reactions not available'

        try: 
         self.update_kappa = self.grid0.attrs['update_kappa'].decode('ASCII')
        except:
         self.update_kappa = 'false'

        self.i_rho = 0
        self.i_vx1 = 1
        self.i_vx2 = 2
        if(self.sdims==3):
         self.i_vx3 = 3
        else:
         self.i_vx3 = 2
        self.i_p = self.i_vx3 + 1
        self.i_as1 = self.i_p + 1

        if(self.advect_yeiabar=='true'):
         self.i_ye = self.i_as1
         self.i_iabar = self.i_ye + 1

        if(self.advect_species=='true'):
          self.i_X1 = self.i_as1 

        helm_table_path = data_path + helm_table
        pig_table_path = data_path + pig_table

        if(self.use_pig=='true'):
         table_path = pig_table_path
        else:
         table_path = helm_table_path

        self.eos_table = eos_fort.eos_fort_mod.load_table(table_path,NRHO,NT,
        LOGRHOMIN,LOGRHOMAX,LOGTMIN,LOGTMAX)
 
        self.eos_evaluated = False
       
        self.eos_mode = ['ideal']

        if (self.use_prad=='true'):
            self.eos_mode = ['ideal','radiation']

        if (self.use_helmholtz=='true'):
            if(self.use_coulomb_corrections=='true'):
             self.eos_mode = ['ions', 'radiation', 'elepos','coulomb']
            else:
             self.eos_mode = ['ions','radiation','elepos']

        if(self.use_pig=='true'):
          self.eos_mode = ['radiation','pig']

        try:
         self.time = self.grid['time'][()]
        except:
         print("'time' not in output")

        try:
         self.dt = self.grid['dt'][()]
        except:
         print("'dt' not in output")

        try:
         self.step = self.grid['step'][()]
        except:
         print("'step' not in output")

    def coords(self,ix=-1,iy=-1,iz=-1):
        return self.vec4d(self.grid0['coords'],ix=ix,iy=iy,iz=iz)
 
    def r(self,ix=-1,iy=-1,iz=-1):
        return self.vec3d(self.r_coords,ix=ix,iy=iy,iz=iz)
 
    def vol(self,ix=-1,iy=-1,iz=-1):
        return self.vec3d(self.grid0['vol'],ix=ix,iy=iy,iz=iz)
 
    def kappa(self,ix=-1,iy=-1,iz=-1):
        if(self.update_kappa=='true'):
         return self.vec3d(self.grid['kappa'],ix=ix,iy=iy,iz=iz)
        else:
         return self.vec3d(self.grid0['kappa'],ix=ix,iy=iy,iz=iz)
 
    def rho(self,ix=-1,iy=-1,iz=-1):
        return self.vec3d(self.grid['prim'][:,:,:,self.i_rho],ix=ix,iy=iy,iz=iz)

    def vel(self,ix=-1,iy=-1,iz=-1):
        return self.vec4d(self.grid['prim'][:,:,:,self.i_vx1:self.i_vx3+1],ix=ix,iy=iy,iz=iz)

    def mom(self,ix=-1,iy=-1,iz=-1):
        return self.rho(ix=ix,iy=iy,iz=iz)*self.vel(ix=ix,iy=iy,iz=iz)

    def abs_vel(self,ix=-1,iy=-1,iz=-1):
        return np.sqrt(np.sum(self.vel(ix=ix,iy=iy,iz=iz)**2,axis=0))
 
    def vr(self,ix=-1,iy=-1,iz=-1):

      vel = self.vel(ix=ix,iy=iy,iz=iz)
      coords = self.coords(ix=ix,iy=iy,iz=iz)

      if(self.geometry!='cartesian'):
       vr = vel[0]
      elif(self.geometry=='cartesian') and (self.use_internal_boundaries=='true'):
       r = self.r(ix=ix,iy=iy,iz=iz)
       if(self.sdims==2):
         vr = (coords[0]*vel[0]+coords[1]*vel[1])/r
       if(self.sdims==3):
         vr = (coords[0]*vel[0]+coords[1]*vel[1]+coords[2]*vel[2])/r
      else:
       vr = vel[1]

      return vr
 
    def vh(self,ix=-1,iy=-1,iz=-1):

     vr = self.vr(ix=ix,iy=iy,iz=iz)
     vabs = self.abs_vel(ix=ix,iy=iy,iz=iz)
     return np.sqrt(vabs*vabs-vr*vr)

    def P(self,ix=-1,iy=-1,iz=-1):
        return self.vec3d(self.grid['prim'][:,:,:,self.i_p],ix=ix,iy=iy,iz=iz)

    def T(self,ix=-1,iy=-1,iz=-1):
        return self.vec3d(self.grid['temp'],ix=ix,iy=iy,iz=iz)
 
    def asc(self,ix=-1,iy=-1,iz=-1):
        return self.vec4d(self.grid['prim'][:,:,:,self.i_as1:],ix=ix,iy=iy,iz=iz)

    def X_species(self,ix=-1,iy=-1,iz=-1):
        return self.vec4d(self.grid['prim'][:,:,:,self.i_X1:self.i_X1+self.nspecies],ix=ix,iy=iy,iz=iz)

    def ye(self,ix=-1,iy=-1,iz=-1):

        if(self.advect_yeiabar=='true'):
         return self.vec3d(self.grid['prim'][:,:,:,self.i_ye],ix=ix,iy=iy,iz=iz)
        elif(self.advect_species=='true'):
          X = self.X_species(ix=ix,iy=iy,iz=iz)
          ye = 0.0
          for i in range(self.nspecies):
            ye += X[i]*self.Z[i]/self.A[i]
          return ye
        else:
          if(self.use_pig=='true'):
           return np.ones_like(self.rho(ix=ix,iy=iy,iz=iz))
          else:
           return np.ones_like(self.rho(ix=ix,iy=iy,iz=iz))*0.5

    def abar(self,ix=-1,iy=-1,iz=-1):

        if(self.advect_yeiabar=='true'):
         return 1.0/self.vec3d(self.grid['prim'][:,:,:,self.i_iabar],ix=ix,iy=iy,iz=iz)
        elif(self.advect_species=='true'):
          X = self.X_species(ix=ix,iy=iy,iz=iz)
          iabar = 0.0
          for i in range(self.nspecies):
            iabar += X[i]/self.A[i]
          return 1.0/iabar
        else:
          if(self.use_pig=='true'):
           return np.ones_like(self.rho(ix=ix,iy=iy,iz=iz))
          else:
           return np.ones_like(self.rho(ix=ix,iy=iy,iz=iz))*(self.mub/(1.0-self.mub/2.0))

    def zbar(self,ix=-1,iy=-1,iz=-1):

        abar = self.abar(ix=ix,iy=iy,iz=iz) 
        ye = self.ye(ix=ix,iy=iy,iz=iz)
        return ye*abar
    
    def mu(self,ix=-1,iy=-1,iz=-1):

        if(self.use_pig=='true'):
         rho = self.rho(ix=ix,iy=iy,iz=iz) 
         T = self.T(ix=ix,iy=iy,iz=iz)
         P = self.P(ix=ix,iy=iy,iz=iz)
         mu = (rho*CONST_RGAS*T)/P
        else:
         abar = self.abar(ix=ix,iy=iy,iz=iz)
         zbar = self.zbar(ix=ix,iy=iy,iz=iz)
         mu = abar / (zbar+1.0)
        return abar/(zbar+1.0)
 
    def bfield(self,ix=-1,iy=-1,iz=-1):
        return self.vec4d(self.grid['bfield'],ix=ix,iy=iy,iz=iz)
 
    def br(self,ix=-1,iy=-1,iz=-1):

      b = self.bfield(ix=ix,iy=iy,iz=iz)
      coords = self.coords(ix=ix,iy=iy,iz=iz)

      if(self.geometry!='cartesian'):
       br = b[0]
      elif(self.geometry=='cartesian') and (self.use_internal_boundaries=='true'):
       r = self.r(ix=ix,iy=iy,iz=iz)
       if(self.sdims==2):
         br = (coords[0]*b[0]+coords[1]*b[1])/r
       if(self.sdims==3):
         br = (coords[0]*b[0]+coords[1]*b[1]+coords[2]*b[2])/r
      else:
       br = b[1]

      return br
 
    def bh(self,ix=-1,iy=-1,iz=-1):

     br = self.br(ix=ix,iy=iy,iz=iz)
     babs = self.abs_bfield(ix=ix,iy=iy,iz=iz)
     return np.sqrt(babs*babs-br*br)

    def emag(self,ix=-1,iy=-1,iz=-1):
        return 0.5*np.sum(self.bfield(ix=ix,iy=iy,iz=iz)**2,axis=0)
 
    def abs_bfield(self,ix=-1,iy=-1,iz=-1):
        return np.sqrt(2.0*self.emag(ix=ix,iy=iy,iz=iz))
   
    def edot_reacs(self,ix=-1,iy=-1,iz=-1):
        return self.vec4d(self.grid['edot_nuc'],ix=ix,iy=iy,iz=iz)[:self.nreacs]
 
    def dXdt_reacs(self,ix=-1,iy=-1,iz=-1):
        return self.vec5d(self.grid['X_species_dot_reacs'],ix=ix,iy=iy,iz=iz)[:self.nspecies,:self.nreacs]
 
    def dXdt(self,ix=-1,iy=-1,iz=-1):
        return self.vec4d(self.grid['X_species_dot'],ix=ix,iy=iy,iz=iz)[:self.nspecies]
   
    def edot_nuc(self,ix=-1,iy=-1,iz=-1):
        return np.sum(self.edot_reacs(ix=ix,iy=iy,iz=iz),axis=0)

    def neuloss(self,ix=-1,iy=-1,iz=-1):
        return self.vec4d(self.grid['edot_nuc'],ix=ix,iy=iy,iz=iz)[-1]

    def grav(self,ix=-1,iy=-1,iz=-1):

        if(self.use_gravity_solver=='true'):
         return self.vec4d(self.grid['grav'],ix=ix,iy=iy,iz=iz)       
        else:
         return self.vec4d(self.grid0['grav'],ix=ix,iy=iy,iz=iz)

    def phipot(self,ix=-1,iy=-1,iz=-1):

        if(self.use_gravity_solver=='true'):
         return self.vec3d(self.grid['phi_cc'],ix=ix,iy=iy,iz=iz)       
        else:
         return self.vec3d(self.grid0['phi_cc'],ix=ix,iy=iy,iz=iz)       

    def epot(self,ix=-1,iy=-1,iz=-1):
        return self.rho(ix=ix,iy=iy,iz=iz)*self.phipot(ix=ix,iy=iy,iz=iz)       

    def eint(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.gamma_gas,eos_mode=self.eos_mode)
         self.eos_evaluated = True

        return self.full[id_E]

    def enthalpy(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        eint = self.eint(ix=ix,iy=iy,iz=iz)
        P = self.P(ix=ix,iy=iy,iz=iz)
        return eint/rho+P
 
    def ekin(self,ix=-1,iy=-1,iz=-1):

        vel = self.vel(ix=ix,iy=iy,iz=iz)
        rho = self.rho(ix=ix,iy=iy,iz=iz)

        return 0.5*rho*np.sum(vel**2,axis=0)
 
    def etot(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        eint = self.eint(ix=ix,iy=iy,iz=iz)
        ekin = self.ekin(ix=ix,iy=iy,iz=iz)
        try:
         epot = self.epot(ix=ix,iy=iy,iz=iz)
        except:
         epot = 0.0
        try:
         emag = self.emag(ix=ix,iy=iy,iz=iz)
        except:
         emag = 0.0

        return rho*eint + ekin + epot + emag

    def sound(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.gamma_gas,eos_mode=self.eos_mode)
         self.eos_evaluated = True

        return self.full[id_sound]

    def mach(self,ix=-1,iy=-1,iz=-1):
        return self.abs_vel(ix=ix,iy=iy,iz=iz)/self.sound(ix=ix,iy=iy,iz=iz)

    def mach_vec(self,ix=-1,iy=-1,iz=-1):
        return self.vel(ix=ix,iy=iy,iz=iz)/self.sound(ix=ix,iy=iy,iz=iz)

    def cp(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.gamma_gas,eos_mode=self.eos_mode)
         self.eos_evaluated = True

        return self.full[id_cp]

    def cv(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.gamma_gas,eos_mode=self.eos_mode)
         self.eos_evaluated = True

        return self.full[id_cv]

    def nabla_ad(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.gamma_gas,eos_mode=self.eos_mode)
         self.eos_evaluated = True

        return self.full[id_nabla_ad]

    def s(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.gamma_gas,eos_mode=self.eos_mode)
         self.eos_evaluated = True

        return self.full[id_s]

    def delta(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.gamma_gas,eos_mode=self.eos_mode)
         self.eos_evaluated = True

        return self.full[id_delta]

    def phi(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.gamma_gas,eos_mode=self.eos_mode)
         self.eos_evaluated = True

        return self.full[id_phi]

    def gamma1(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.gamma_gas,eos_mode=self.eos_mode)
         self.eos_evaluated = True

        return self.full[id_gam1]

    def gamma2(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.gamma_gas,eos_mode=self.eos_mode)
         self.eos_evaluated = True

        return self.full[id_gam2]

    def gamma3(self,ix=-1,iy=-1,iz=-1):

        rho = self.rho(ix=ix,iy=iy,iz=iz)
        T = self.T(ix=ix,iy=iy,iz=iz)
        abar = self.abar(ix=ix,iy=iy,iz=iz)
        zbar = self.zbar(ix=ix,iy=iy,iz=iz)

        if(not self.eos_evaluated):
         self.full = rhoT_given(self.eos_table,rho,T,abar=abar,zbar=zbar,
         gamma_ideal=self.gamma_gas,eos_mode=self.eos_mode)
         self.eos_evaluated = True

        return self.full[id_gam3]

    def edot(self,ix=-1,iy=-1,iz=-1):
        return self.vec3d(self.grid0['edot'],ix=ix,iy=iy,iz=iz)

    def nabla(self,ix=-1,iy=-1,iz=-1):
        dlnT = self.grad_r(np.log(self.T()),ix=ix,iy=iy,iz=iz)
        dlnP = self.grad_r(np.log(self.P()),ix=ix,iy=iy,iz=iz)
        nabla = dlnT/dlnP
        return nabla

    def nabla_mu(self,ix=-1,iy=-1,iz=-1):
        dlnP = self.grad_r(np.log(self.P()),ix=ix,iy=iy,iz=iz)
        dlnmu = self.grad_r(np.log(self.mu()),ix=ix,iy=iy,iz=iz)
        nabla_mu = dlnmu/dlnP
        return nabla_mu
    
    def ledoux_stability(self,relative = True, ix=-1,iy=-1,iz=-1):
         nabla = self.nabla(ix=ix,iy=iy,iz=iz)
         nabla_ad = self.nabla_ad(ix=ix,iy=iy,iz=iz)
         nabla_mu = self.nabla_mu(ix=ix,iy=iy,iz=iz)
         delta = self.delta(ix=ix,iy=iy,iz=iz)
         phi = self.phi(ix=ix,iy=iy,iz=iz)
         stability = nabla_ad + phi/delta*nabla_mu - nabla
         if relative:
             stability = stability / abs(nabla_ad)
         return stability

    def vec3d(self,vec,ix=-1,iy=-1,iz=-1):

        if(self.sdims==2):
         ix = -1
         iy = -1
         iz =  0

        self.ix = ix
        self.iy = iy
        self.iz = iz

        if(ix>=0):
          tmp = vec[:,:,ix]
          tmp = tmp.transpose(1,0)
        elif(iy>=0):
          tmp = vec[:,iy,:]
          tmp = tmp.transpose(1,0)
        elif(iz>=0):
          tmp = vec[iz,:,:]
          tmp = tmp.transpose(1,0)
        else:
          tmp = vec[:,:,:]
          tmp = tmp.transpose(2,1,0)

        return tmp

    def vec4d(self,vec,ix=-1,iy=-1,iz=-1):

        if(self.sdims==2):
          ix = -1
          iy = -1
          iz =  0

        self.ix = ix
        self.iy = iy
        self.iz = iz

        if(ix>=0):
          tmp = vec[:,:,ix,:]
          tmp = tmp.transpose(2,1,0)
        elif(iy>=0):
          tmp = vec[:,iy,:,:]
          tmp = tmp.transpose(2,1,0)
        elif(iz>=0):
          tmp = vec[iz,:,:,:]
          tmp = tmp.transpose(2,1,0)
        else:
          tmp = vec[:,:,:,:]
          tmp = tmp.transpose(3,2,1,0)

        return tmp
 
    def vec5d(self,vec,ix=-1,iy=-1,iz=-1):

        if(self.sdims==2):
          ix = -1
          iy = -1
          iz =  0

        self.ix = ix
        self.iy = iy
        self.iz = iz

        if(ix>=0):
          tmp = vec[:,:,:,ix,:,:]
          tmp = tmp.transpose(3,2,1,0)
        elif(iy>=0):
          tmp = vec[:,iy,:,:,:]
          tmp = tmp.transpose(3,2,1,0)
        elif(iz>=0):
          tmp = vec[iz,:,:,:,:]
          tmp = tmp.transpose(3,2,1,0)
        else:
          tmp = vec[:,:,:,:,:]
          tmp = tmp.transpose(4,3,2,1,0)

        return tmp
 
    def evaluate_expression(self,expr):
      try:
        result = eval(expr)
        return result
      except Exception as e:
        return f"Error: {e}"

##############################################################################################
# helper functions
###############################################################################################

    def radial_profile(self,quant,ib_bins=None,slices=False,s1=-1,s2=-1,s3=-1):
        if ib_bins is None:
            ib_bins = int(self.nx1 * 0.5)
        if slices and self.sdims==3:
           if s1 >= 0:
               quant = quant[s1,:,:]
           elif s2 >= 0:
               quant = quant[:,s2,:]
           elif s3 >= 0:
                quant = quant[:,:,s3]
           elif (s1 < 0 and s2 < 0 and s3 < 0) or (s1 < 0 and s2 < 0) or (s1 < 0 and s3 < 0) or (s2 < 0 and s3 < 0):
               print('Too many slices specified for a 3D grid!')
        elif slices and self.sdims==2:
           print('Cannot take a 2D slice of a 2D grid!')
        if self.geometry=='cartesian':
            if self.use_internal_boundaries=='false':
                if self.sdims==2 or s3>=0:
                    r_profile = np.mean(quant,axis=0)
                elif s1>=0:
                    r_profile = np.mean(quant,axis=1)
                elif self.sdims==3:
                    print(quant.shape)
                    r_profile = np.mean(quant,axis=(0,2))
                elif s2>=0:
                    print('cannot compute radial profile for a slice with constant r')
            else:
                r_coord = self.r_coords
                rr = r_coord[int(self.nx3*0.5),int(self.nx2*0.5),int(self.nx1*0.5):]
                if s3 >= 0:
                    r_coord = r_coord[s3,:,:]
                    rr = r_coord[int(self.nx2*0.5),int(self.nx1*0.5):]
                elif s2 >= 0:
                    r_coord = r_coord[:,s2,:]
                    rr = r_coord[int(self.nx3*0.5),int(self.nx1*0.5):]
                elif s1 >= 0:
                    r_coord = r_coord[:,:,s1]
                    rr = r_coord[int(self.nx3*0.5),int(self.nx2*0.5):]
                r_min = 0
                r_max = abs(self.x1u - self.x1l)/2
                bin_walls = np.linspace(r_min, r_max, ib_bins + 1)
                radial_profile_bins = np.zeros(ib_bins)
                for i in range(len(radial_profile_bins)):
                    mask = (r_coord >= bin_walls[i]) & (r_coord < bin_walls[i+1])
                    if self.sdims == 2:  mask = mask[0,:,:]
                    radial_profile_bins[i] = np.mean(quant[mask])
                r_profile = interp1d(0.5 * (bin_walls[:-1] + bin_walls[1:]), radial_profile_bins,fill_value="extrapolate")(rr)
        elif self.geometry =='2d-polar' or self.geometry=='2d-spherical':
            r_profile = np.mean(quant,axis=1)
        elif self.geometry=='3d-spherical':
            if s1 >= 0:
               print('Cannot compute radial profile for a slice with constant r!')
            elif s2 >= 0 or s3 >= 0:
               r_profile = np.mean(quant,axis=1)
            else:
               r_profile = np.mean(quant,axis=(1,2))
        else: print('radial_profile is not implemented for this geometry!')
        return r_profile

    def r2raxis(self):
       if self.geometry=='cartesian':
          if self.use_internal_boundaries=='false':
            raxis = self.coords(ix=-1,iy=-1,iz=-1)[1,0,:,0]
          if self.use_internal_boundaries=='true':
            raxis = self.r_coords[int(self.nx3*0.5),int(self.nx2*0.5),int(self.nx1*0.5):]
       elif self.geometry=='3d-spherical':
            raxis = self.r_coords[0,0,:]
       elif self.geometry=='2d-polar' or self.geometry=='2d-spherical':
            raxis = self.r_coords[0,0,:]
       else:
            print('r2raxis is not implemented for this geometry!')
            raxis = None
       return raxis
    
    def r2maxis(self):
        rr = self.r2raxis().copy()
        rho_radial = self.radial_profile(self.rho())
        if self.geometry=='cartesian':
           if self.use_internal_boundaries=='true':
              print('This is mass per unit lenght [g/cm^-1].')
              dx = abs(self.x1u - self.x1l)/self.nx1
              #dy = abs(self.x2u - self.x2l)/self.nx2
              mass = rho_radial * dx  * rr**2 * np.pi * 2
              mass_axis = np.cumsum(mass)
        else:
           print('geometry not yetu implemented!')
        return mass_axis             
              
    def grad_r(self,data,ix=-1,iy=-1,iz=-1):
        if self.geometry=='cartesian':
           if self.use_internal_boundaries=='true':
                coords = self.coords(ix=self.ix,iy=self.iy,iz=self.iz)
                if self.sdims==3:
                    x = coords[0]
                    x_1d = x[:,0,0]
                    y = coords[1]
                    y_1d = y[0,:,0]
                    z = coords[2]
                    z_1d = z[0,0,:]
                    r_vec = np.array([x,y,z])
                    r_norm = self.r(ix=ix,iy=iy,iz=iz)
                    unit_r = r_vec / r_norm
                    grad_data_cartesian = np.gradient(data, x_1d, y_1d,z_1d)
                    grad_r = np.sum(unit_r * grad_data_cartesian, axis=0)
                if self.sdims==2:
                    x = coords[0]
                    x_1d = x[:,0]
                    y = coords[1]
                    y_1d = y[0,:]
                    r_vec = np.array([x,y])
                    r_norm = self.r(ix=ix,iy=iy,iz=iz)
                    unit_r = r_vec / r_norm
                    grad_data_cartesian = np.gradient(data, x_1d, y_1d)
                    grad_r = np.sum(unit_r * grad_data_cartesian, axis=0)
                if ix>=0:
                    grad_r = grad_r[ix,:,:]
                elif iy>=0:
                    grad_r = grad_r[:,iy,:]
                elif iz>=0:
                    grad_r = grad_r[:,:,iz]
        else:
            print('grad_r is not implemented for this geometry!')
            grad_r = None
        return grad_r
    
###############################################################################################
## Plotting functions
###############################################################################################

    def gridshow(self,out,ichx=12,ichy=6, \
    figdpi=500,figname=None, \
    axs=None, multiplot=False, show_cb=True,\
    x_lbl=r'$x$',y_lbl=r'$y$', \
    cb_lbl='',cb_pad=0.05,cb_size="5%",cb_pos='right', \
        time_in_days=True,coords_in_Rsun=True, \
    showfig=True, \
    Rstar=-1, \
    use_latex=False, \
    fontsize=15, \
    **kwargs):

     label_fontsize = 1.1*fontsize
     legend_fontsize = 0.9*fontsize
     rcParams['font.size'] = fontsize
     rcParams['axes.titlesize'] = label_fontsize
     rcParams['axes.labelsize'] = label_fontsize
     rcParams['legend.fontsize'] = legend_fontsize
     rcParams["legend.labelspacing"] = 0.4
     rcParams['xtick.labelsize'] = fontsize
     rcParams['ytick.labelsize'] = fontsize
     rcParams['legend.frameon'] = True
     rcParams['legend.facecolor'] = 'white'
     rcParams['legend.framealpha'] = 0.8
     rcParams['legend.fancybox'] = True
     rcParams['legend.edgecolor'] = 'lightgray'
     rcParams['lines.linewidth'] = 1.
     rc('text', usetex=use_latex)
     rc('text.latex', preamble=r'\usepackage{txfonts}'+ r'\usepackage{bm}'+ r'\newcommand{\mach}[0]{\mathcal{M}}')

     if(showfig):
      ion()
     else:
      ioff()

     if axs is None:
        fig, axs = subplots(figsize=(ichx,ichy))
     else:
        fig = axs.figure

     coords = self.coords(ix=self.ix,iy=self.iy,iz=self.iz)

     if(self.geometry=='cartesian'):
      if(self.ix>=0):
       x = coords[1]
       y = coords[2]
      if(self.iy>=0):
       x = coords[0]
       y = coords[2]
     if(self.iz>=0):
       x = coords[0]
       y = coords[1]

     if(self.geometry=='2d-polar' or self.geometry=='2d-spherical'):
       x = coords[0]
       y = coords[1]

     if(self.geometry=='3d-spherical'):
      if(self.ix>=0):
       x = coords[0]
       y = coords[1]
      if(self.iy>=0):
       x = coords[1]
       y = coords[0]
      if(self.iz>=0):
       x = np.sqrt(coords[0]**2+coords[1]**2)
       y = coords[2]

     if(coords_in_Rsun):
      x /= CONST_RSUN
      y /= CONST_RSUN
      x_lbl+=r'$\ [\mathrm{R}_\odot]$'
      y_lbl+=r'$\ [\mathrm{R}_\odot]$'
     else:
      if(Rstar>0):
       x /= Rstar
       y /= Rstar
       x_lbl+=r'$\ [\mathrm{R}_\star]$'
       y_lbl+=r'$\ [\mathrm{R}_\star]$'
      else:
       x_lbl+=r'$\ [\mathrm{cm}]$'
       y_lbl+=r'$\ [\mathrm{cm}]$'

     im = axs.pcolormesh(x,y,out,shading='nearest',**kwargs)
     axs.axes.set_aspect('equal')

     axs.set_xlabel(x_lbl)
     axs.set_ylabel(y_lbl)

     if(time_in_days):
       axs.set_title(r'$t=%.3f\ [\mathrm{d}]$'%(self.time/86400.0))
     else:
      axs.set_title(r'$t=%.3f\ [\mathrm{s}]$'%(self.time))

     divider = make_axes_locatable(axs)
     cax = divider.append_axes(cb_pos,size=cb_size,pad=cb_pad)

     if(cb_pos=='left' or cb_pos=='right'):
      orientation='vertical'
     else:
      orientation='horizontal'

     if show_cb:
      cb = fig.colorbar(im,cax=cax,label=cb_lbl,orientation=orientation)
     else:
      cax.axis('off')
     
     if(figname!=None):
      savefig(figname,dpi=figdpi)

     if(showfig):
      show()
     elif(multiplot):
      pass
     else:
      close()

     rc('text', usetex=False)

    def radialshow(self,quant,ib_bins=None,slices=False,s1=-1,s2=-1,s3=-1, \
                    figdpi=500,figname=None, \
                    x_lbl=r'$r$',y_lbl='$q$', \
                    time_in_days=True,coords_in_Rsun=True, \
                    showfig=True, \
                    use_latex=False, \
                    fontsize=15,ichx=12,ichy=6,**kwargs):
        if ib_bins is None:
            ib_bins = int(self.nx1 * 0.5)
        label_fontsize = 1.1*fontsize
        legend_fontsize = 0.9*fontsize
        rcParams['font.size'] = fontsize
        rcParams['axes.titlesize'] = label_fontsize
        rcParams['axes.labelsize'] = label_fontsize
        rcParams['legend.fontsize'] = legend_fontsize
        rcParams["legend.labelspacing"] = 0.4
        rcParams['xtick.labelsize'] = fontsize
        rcParams['ytick.labelsize'] = fontsize
        rcParams['legend.frameon'] = True
        rcParams['legend.facecolor'] = 'white'
        rcParams['legend.framealpha'] = 0.8
        rcParams['legend.fancybox'] = True
        rcParams['legend.edgecolor'] = 'lightgray'
        rcParams['lines.linewidth'] = 1.
        rc('text', usetex=use_latex)
        rc('text.latex', preamble=r'\usepackage{txfonts}'+ r'\usepackage{bm}'+ r'\newcommand{\mach}[0]{\mathcal{M}}')

        quant_r_profile = self.radial_profile(quant,ib_bins=ib_bins,slices=slices,s1=s1,s2=s2,s3=s3).copy()
        raxis = self.r2raxis().copy()

        if showfig:
           ion()
        else:
           ioff()
        
        fig, axs = subplots(figsize=(ichx,ichy))
        if(coords_in_Rsun==True):
           raxis /= CONST_RSUN
           x_lbl+=r'$\ [\mathrm{R}_\odot]$'
        else:
           x_lbl+=r'$\ [\mathrm{cm}]$'
        axs.plot(raxis,quant_r_profile,**kwargs)
        axs.set_xlabel(x_lbl)
        axs.set_ylabel(y_lbl)
        if(time_in_days):
           axs.set_title(r'$t=%.3f\ [\mathrm{d}]$'%(self.time/86400.0)) 
        else:
           axs.set_title(r'$t=%.3f\ [\mathrm{s}]$'%(self.time))
        
        if(figname!=None):
           savefig(figname,dpi=figdpi)
        if showfig:
            show()
        else:
            close()
            rc('text', usetex=False)
 
###############################################################################################
## Extract time profiles
###############################################################################################
       
def timeprof(expr,i1=0,i2=-1,delta=1,path=""):

    files = file_list(path=path)
    nfiles = len(files)
    t = []
    out = []

    if(i2==-1):
     i2 = len(files)-1
     nfiles = i2
    else:
     nfiles = i2+1-i1

    ic = 0
    for i in range(i1,i2+1,delta):
     print('reading snapshot # %d | advance: %.2f'%(i,ic/nfiles*delta ))     
     grid = h5grid(i,path=path)
     time = grid.time
     out.append(grid.evaluate_expression(expr))
     t.append(time)
     ic += 1

    t = np.array(t)
    out = np.array(out)

    return t,out

