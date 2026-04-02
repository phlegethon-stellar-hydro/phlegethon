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
import sys
from scipy.integrate import cumulative_trapezoid as trap

CONST_RGAS = 8.31446261815324e7
CONST_RAD = 7.565767381646406e-15
CONST_GRAV = 6.67428e-8
CONST_RSUN = 6.95660e10
CONST_PI = 3.141592653589793238
CONST_C = 2.99792458e10
CONST_AV = 6.02214076e23

try:
 data = os.environ['PHLEGETHONDATA'].split(os.pathsep)[0]
except KeyError:
 data = '../../data/'

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

class phlgrid:

   def __init__(self,filename,path='./',mode='i',is_0th=False,iY=0):

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
         self.use_gravity_solver = self.grid0.attrs['use_gravity_solver'].decode('ASCII')
        except:
         self.use_gravity_solver = 'false'

        try:
         self.use_internal_boundaries = self.grid0.attrs['use_internal_boundaries'].decode('ASCII')
        except:
         self.use_internal_boundaries = 'false'

        self.geometry = self.grid0.attrs['geometry-type'].decode('ASCII')

        #================================#

        if(is_0th):
         
         self.r = self.grid0['coords'][()][:,iY,:,1]
  
         coords = self.grid0['coords'][()]
         
         self.yref = coords[0,iY,0,1]

        #================================#

        self.i_rho = 0
        self.i_vx1 = 1
        self.i_vx2 = 2
        self.i_vx3 = 3

        try:
         self.time = self.grid['time'][()]
        except:
         dummy = 1
         
        try:
         self.step = self.grid['step'][()]
        except:
         dummy = 1

        prim = self.grid['prim'][()]

        self.rho = prim[:,iY,:,self.i_rho]
        self.vx1 = prim[:,iY,:,self.i_vx1]
        self.vx2 = prim[:,iY,:,self.i_vx2]
        self.vx3 = prim[:,iY,:,self.i_vx3]

        self.nx1 = self.rho.shape[1]
        self.nx3 = self.rho.shape[0]

        try:
         bfield = self.grid['bfield'][()]
         self.bx1 = bfield[:,iY,:,0]
         self.bx2 = bfield[:,iY,:,1]
         self.bx3 = bfield[:,iY,:,2]
         self.bfield_exists = True
        except:
         self.bx1 = 0
         self.bx2 = 0
         self.bx3 = 0
         self.bfield_exists = False
 
def main():

    dump1 = int(sys.argv[1])
    dump2 = int(sys.argv[2])
    delta_dump = int(sys.argv[3])
    iY = int(sys.argv[4])
    path = sys.argv[5]
    savedir = sys.argv[6]

    pg0 = phlgrid(0,path=path,is_0th=True,iY=iY)      
    yref = pg0.yref

    for isnap in range(dump1,dump2,delta_dump):

      print('processing snap # ',isnap)

      pg = phlgrid(isnap,path=path,iY=iY)      

      kx = np.fft.fftshift(np.fft.fftfreq(pg.nx1, 1./pg.nx1))
      kxmax = kx[-1]
      kx = np.transpose(np.tile(kx, (pg.nx3,1)))
      kz = np.fft.fftshift(np.fft.fftfreq(pg.nx3, 1./pg.nx3))
      kzmax = kz[-1]
      kz = np.tile(kz, (pg.nx1,1))
      kk = (kx**2 + kz**2)**0.5
      nbins = 1 + int(np.min((kxmax, kzmax)))
      bin_edges = np.linspace(-0.5, float(nbins) - 0.5, nbins+1)

      vx1_hat = np.fft.fftshift(np.fft.fft2(pg.vx1))/(pg.nx1*pg.nx3) 
      vx2_hat = np.fft.fftshift(np.fft.fft2(pg.vx2))/(pg.nx1*pg.nx3) 
      vx3_hat = np.fft.fftshift(np.fft.fft2(pg.vx3))/(pg.nx1*pg.nx3) 

      ek_hat = 0.5*np.mean(pg.rho)*(np.abs(vx1_hat)**2+np.abs(vx2_hat)**2+np.abs(vx3_hat)**2)
      ek_hat, bin_edges = np.histogram(kk, weights=ek_hat, bins=bin_edges)
      kh = 0.5*(bin_edges[:-1] + bin_edges[1:])
 
      if(pg.bfield_exists):

       bx1_hat = np.fft.fftshift(np.fft.fft2(pg.bx1))/(pg.nx1*pg.nx3) 
       bx2_hat = np.fft.fftshift(np.fft.fft2(pg.bx2))/(pg.nx1*pg.nx3) 
       bx3_hat = np.fft.fftshift(np.fft.fft2(pg.bx3))/(pg.nx1*pg.nx3) 

       eb_hat = 0.5*(np.abs(bx1_hat)**2+np.abs(bx2_hat)**2+np.abs(bx3_hat)**2)
       eb_hat, bin_edges = np.histogram(kk, weights=eb_hat, bins=bin_edges)
 
      else:

       eb_hat = 0.0

      dd = {}

      dd['kh'] = kh
      dd['ek_hat'] = ek_hat
      dd['eb_hat'] = eb_hat

      np.savez('%s/SPECTRA_iY_%d_%d.npz'%(savedir,iY,isnap), \
      time=pg.time, \
      yref=yref, \
      dd=dd, \
      allow_pickle=True)

main()

