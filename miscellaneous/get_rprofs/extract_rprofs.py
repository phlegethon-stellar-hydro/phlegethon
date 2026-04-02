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
from phleos import *

try:
 data = os.environ['PHLEGETHONDATA'].split(os.pathsep)[0]
except KeyError:
 data = '../../data/'

def bin_2x2x2_single(arr,sdims):
   
   if(sdims==3):
    binned0 = 0.5*(arr[0::2,:,:] + arr[1::2,:,:])
    binned1 = 0.5*(binned0[:,0::2,:] + binned0[:,1::2,:])
    binned2 = 0.5*(binned1[:,:,0::2] + binned1[:,:,1::2])   
   if(sdims==2):
    binned1 = 0.5*(arr[:,0::2,:] + arr[:,1::2,:])
    binned2 = 0.5*(binned1[:,:,0::2] + binned1[:,:,1::2])  

   return binned2

def bin_2x2x2_multi(arr,sdims):

   if(sdims==3):
    binned0 = 0.5*(arr[0::2,:,:,:] + arr[1::2,:,:,:])
    binned1 = 0.5*(binned0[:,0::2,:,:] + binned0[:,1::2,:,:])
    binned2 = 0.5*(binned1[:,:,0::2,:] + binned1[:,:,1::2,:])
   if(sdims==2):
    binned1 = 0.5*(arr[:,0::2,:,:] + arr[:,1::2,:,:])
    binned2 = 0.5*(binned1[:,:,0::2,:] + binned1[:,:,1::2,:])
   
   return binned2

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

   def __init__(self,filename,path='./',mode='i',data_path=data,helm_table='helm_table_timmes_x1.dat',pig_table='401x401_pig_table_h2_offset.dat',
   NRHO=271,NT=101,LOGRHOMIN=-12.0,LOGRHOMAX=15.0,LOGTMIN=3.0,LOGTMAX=13.0):

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

        if(is_0th):
         
         if(self.geometry!='cartesian') or (self.use_internal_boundaries=='true'):
            self.r = self.grid0['r'][()]
         else:
            self.r = self.grid0['coords'][()][:,:,:,1]
  
         coords = self.grid0['coords'][()]
         if(make_coarse):
          self.r = bin_2x2x2_single(self.r,self.sdims)
          coords = bin_2x2x2_multi(coords,self.sdims)
         
         self.x = coords[:,:,:,0]
         self.y = coords[:,:,:,1]
         if(self.sdims==3):
          self.z = coords[:,:,:,2]
         else:
          self.z = 0.0

         try:
          self.kappa = self.grid0['kappa'][()]
          if(make_coarse):
           self.kappa = bin_2x2x2_single(self.kappa,self.sdims)
          self.kappa_exists = True
         except:
          self.kappa_exists = False
 
         grav = self.grid0['grav'][()]
         if(make_coarse):
          grav = bin_2x2x2_multi(grav,self.sdims)
         self.gx1 = grav[:,:,:,0]
         self.gx2 = grav[:,:,:,1]
         if(self.sdims==3):
          self.gx3 = grav[:,:,:,2]
         else:
          self.gx3 = 0.0

         try:
          self.edot = self.grid0['edot'][()]
          if(make_coarse):
            self.edot = bin_2x2x2_single(self.edot,self.sdims)
          self.edot_exists = True
         except:
          self.edot_exists = False

         try:
          self.epot = self.grid0['phi_cc'][()]
          if(make_coarse):
           self.epot = bin_2x2x2_single(self.epot,self.sdims)
          self.epot_exists = True
         except:
          self.epot = 0.0
          self.epot_exists = False

        try:
         self.A = np.array(self.grid0['A'][()])
         self.Z = np.array(self.grid0['Z'][()])
         self.nspecies = len(self.A)
        except:
         dummy = 1
         
        try:
          self.name_species = [s.decode('utf-8') for s in self.grid0.attrs['name_species']]
          self.name_reacs = [s.decode('utf-8') for s in self.grid0.attrs['name_reacs']]
          self.nreacs = len(self.name_reacs)
        except:
          dummy = 1

        self.i_rho = 0
        self.i_vx1 = 1
        self.i_vx2 = 2
        if(self.sdims==3):
         self.i_vx3 = 3
        else:
         self.i_vx3 = 2
        self.i_P = self.i_vx3 + 1
        self.i_as1 = self.i_P + 1

        if(self.advect_yeiabar=='true'):
         self.i_Ye = self.i_as1
         self.i_iabar = self.i_Ye + 1

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
         dummy = 1
         
        try:
         self.dt = self.grid['dt'][()]
        except:
         dummy = 1

        try:
         self.step = self.grid['step'][()]
        except:
         dummy = 1

        try:
         bfield = self.grid['bfield'][()]
         if(make_coarse):
          bfield = bin_2x2x2_multi(bfield,self.sdims)
         self.bx1 = bfield[:,:,:,0]
         self.bx2 = bfield[:,:,:,1]
         self.bx3 = bfield[:,:,:,2]
         self.mhd_exists = True
        except:
         self.mhd_exists = False

        prim = self.grid['prim'][()]
        if(make_coarse):
         prim = bin_2x2x2_multi(prim,self.sdims)

        nvars = prim.shape[-1]
        self.nas = nvars - self.i_P - 1

        self.rho = prim[:,:,:,self.i_rho]

        self.vx1 = prim[:,:,:,self.i_vx1]
        self.vx2 = prim[:,:,:,self.i_vx2]
        if(self.sdims==3):
         self.vx3 = prim[:,:,:,self.i_vx3]
        else:
         self.vx3 = 0.0
      
        self.P = prim[:,:,:,self.i_P]

        if(self.nas>0):
          self.X = prim[:,:,:,self.i_X1:]

        if(self.advect_yeiabar=='true'):
         self.Ye = prim[:,:,:,self.i_Ye]
        elif(self.advect_species=='true'):
          self.Ye = 0.0
          for i in range(self.nspecies):
              self.Ye += self.X[:,:,:,i]*self.Z[i]/self.A[i]
        else:
          self.Ye = np.ones_like(self.rho)*0.5

        if(self.advect_yeiabar=='true'):
         self.abar = 1.0/prim[:,:,:,self.i_iabar]
        elif(self.advect_species=='true'):
          iabar = 0.0
          for i in range(self.nspecies):
           iabar += self.X[:,:,:,i]/self.A[i]
          self.abar = 1.0/iabar
        else:
          self.abar = np.ones_like(self.rho)*(self.mub/(1.0-self.mub/2.0))

        self.zbar = self.Ye*self.abar

        self.T = self.grid['temp'][()]
        if(make_coarse):
         self.T = bin_2x2x2_single(self.T,self.sdims)

        self.iT = 1.0/self.T

        self.ekin = 0.5*(self.vx1*self.vx1+self.vx2*self.vx2+self.vx3*self.vx3)

        self.full = rhoT_given(self.eos_table,rho,self.T,abar=self.abar,zbar=self.zbar,
        gamma_ideal=self.gamma_gas,eos_mode=self.eos_mode)
        self.eos_evaluated = True

        self.eint = self.full[id_E]

        if(self.mhd_exists):
         self.emag = 0.5*(self.bx1*self.bx1+self.bx2*self.bx2+self.bx3*self.bx3) 
        else:
         self.emag = 0.0

        self.etot = self.eint + self.ekin + self.emag

        self.h = self.eint + self.P/self.rho

        self.s = self.full[id_s]

        try:
         self.edot_reacs = self.grid['edot_nuc'][()]
         if(make_coarse):
           self.edot_reacs = bin_2x2x2_multi(self.edot_reacs,self.sdims)
         self.edot_nuc = np.sum(self.edot_reacs[:,:,:,:self.nreacs],axis=3)
         self.edot_neu = self.edot_reacs[:,:,:,-1]
         self.nuclear_network_exists = True
        except:
         self.nuclear_network_exists = False

        try:
         self.dXdt = self.grid['X_species_dot'][()]
         if(make_coarse):
           self.dXdt = bin_2x2x2_multi(self.dXdt,self.sdims)
         self.dXdt_exists = True
        except:
         self.dXdt_exists = False
 
   def reynolds_barg(self,q):
      
      if(self.geometry!='cartesian'):
       return np.mean(q,axis=(0,1))
      elif(self.geometry=='cartesian') and (self.use_internal_boundaries=='true'):
       val, bin_edges = np.histogram(self.r, weights=q, bins=self.bins, range=(0,self.r[0,self.bins,self.bins])) # FR2808 I added maximum radius cube face
       rbar, qbar = 0.5 * (bin_edges[:-1] + bin_edges[1:]), val/self.num
       return qbar
      else:
       return np.mean(q,axis=(0,2))

def main():

    dump1 = int(sys.argv[1])
    dump2 = int(sys.argv[2])
    delta_dump = int(sys.argv[3])
    make_coarse = int(sys.argv[4])
    if(make_coarse==0):
     make_coarse= False
    elif(make_coarse==1):
     make_coarse = True
    path = sys.argv[5]
    savedir = sys.argv[6]

    pg0 = phlgrid(0,path=path,make_coarse=make_coarse,is_0th=True)      

    x = pg0.x
    y = pg0.y
    z = pg0.z
    r = pg0.r
    ir = 1.0/r

    x1 = x[0,0,:]
    y1 = y[0,:,0]
    if(pg0.sdims==3):
     z1 = z[:,0,0]
    else:
     z1 = 0.0

    if(pg0.geometry!='cartesian'):
     r1 = r[0,0,:]
     if(make_coarse):
      fac = 2
     else:
      fac = 1
    elif(pg0.geometry=='cartesian') and (pg0.use_internal_boundaries=='true'):
     r1 = 0.0
     if(make_coarse):
      fac = 4
     else:
      fac = 2
    else:
     r1 = r[0,:,0]
     if(make_coarse):
      fac = 2
     else:
      fac = 1
 
    num = 0
    bins = 0

    if(pg0.geometry=='cartesian') and (pg0.use_internal_boundaries=='true'):
      bins = pg0.nx1//fac
      num, bin_edges = np.histogram(r, bins=bins, range=(0,r[0,bins,bins]))     
      pg0.num =  num
      pg0.bins = bins

    gx1 = pg0.gx1
    gx2 = pg0.gx2
    gx3 = pg0.gx3

    if(pg0.geometry!='cartesian'):
      gr = gx1 
    elif(pg0.geometry=='cartesian') and (pg0.use_internal_boundaries=='true'):
      gr = (x*gx1+y*gx2+z*gx3)*ir
    else:
      gr = gx2

    r_bar = pg0.reynolds_barg(r)
    
    gr_bar = pg0.reynolds_barg(gr)

    if(pg0.epot_exists):
     epot = pg0.epot
     epot_bar = pg0.reynolds_barg(epot)
    else:
     epot = 0.0
     epot_bar = 0.0

    if(pg0.kappa_exists):
     kappa = pg0.kappa
     kappa_bar = pg0.reynolds_barg(kappa)
    else:
     kappa_bar = 0.0

    if(pg0.edot_exists):
     edot = pg0.edot
     edot_bar = pg0.reynolds_barg(edot)
    else:
     edot = 0.0
     edot_bar = 0.0

    if(pg0.geometry!='cartesian'):
     if(pg0.geometry=='2d-polar'):
      dtheta = (pg0.x2u-pg0.x2l)/(pg0.nx2//fac)
      theta1 = np.linspace(pg0.x2l+dtheta/2.0,pg0.x2u-dtheta/2.0,pg0.nx2//fac)
     elif(pg0.geometry=='2d-spherical'):
      dtheta = (pg0.x2u-pg0.x2l)/(pg0.nx2//fac)
      theta1 = np.linspace(pg0.x2l+dtheta/2.0,pg0.x2u-dtheta/2.0,pg0.nx2//fac) 
      i_r_sin_theta = 1.0/x 
      r2 = r*r
      ir2 = 1.0/r2
      sin_theta = r*i_r_sin_theta
     elif(pg0.geometry=='3d-spherical'):
      dtheta = (pg0.x2u-pg0.x2l)/(pg0.nx2//fac)
      theta1 = np.linspace(pg0.x2l+dtheta/2.0,pg0.x2u-dtheta/2.0,pg0.nx2//fac) 
      dphi = (pg0.x3u-pg0.x3l)/(pg0.nx3//fac)
      phi1 = np.linspace(pg0.x3l+dphi/2.0,pg0.x3u-dphi/2.0,pg0.nx3//fac)
      i_r_sin_theta = 1.0/np.sqrt(x*x+y*y) 
      r2 = r*r
      ir2 = 1.0/r2
      sin_theta = r*i_r_sin_theta

    if(pg0.geometry!='cartesian'):
       if(pg0.geometry=='2d-polar'): 
        area = 2.0*np.pi*r_bar
       elif(pg0.geometry=='2d-spherical'):
        area = 4.0*np.pi*r_bar*r_bar
       elif(pg0.geometry=='3d-spherical'):
        area = 4.0*np.pi*r_bar*r_bar
    elif(pg0.geometry=='cartesian' and pg0.use_internal_boundaries=='true'):
        if(pg0.sdims==2):
         area = 2.0*np.pi*r_bar
        if(pg0.sdims==3):
         area = 4.0*np.pi*r_bar*r_bar
    else:
        area = 1.0

    if(pg0.geometry=='cartesian') and (pg0.use_internal_boundaries=='true'):

       if(pg0.sdims==2):

         phi = np.arctan2(y, x)

         cos_phia = np.cos(phi)
         sin_phia = np.sin(phi)

       if(pg0.sdims==3):

        theta = np.arccos(z / r)
        phi = np.arctan2(y, x)

        cos_thetaa = np.cos(theta)
        sin_thetaa = np.sin(theta)
        cos_phia = np.cos(phi)
        sin_phia = np.sin(phi)

    for isnap in range(dump1,dump2,delta_dump):

      print('processing snap # ',isnap)

      pg = phlgrid(isnap,path=path,make_coarse=make_coarse)      

      pg.r = r

      pg.num = num

      pg.bins = bins

      rho_bar = pg.reynolds_barg(pg.rho)
     
      P_bar = pg.reynolds_barg(pg.P)

      T_bar = pg.reynolds_barg(pg.T)

      s_bar = pg.reynolds_barg(pg.s)

      abar_bar = pg.reynolds_barg(pg.abar)

      Ye_bar = pg.reynolds_barg(pg.Ye)

      zbar_bar = pg.reynolds_barg(pg.zbar)

      rho_rho_bar = pg.reynolds_barg(pg.rho*pg.rho)

      T_T_bar = pg.reynolds_barg(pg.T*pg.T)

      P_P_bar = pg.reynolds_barg(pg.P*pg.P)

      s_s_bar = pg.reynolds_barg(pg.s*pg.s)

      if(pg.geometry!='cartesian'):
       vr = pg.vx1
       vt1 = pg.vx2
       if(pg.sdims==3):
        vt2 = pg.vx3 
      elif(pg.geometry=='cartesian') and (pg.use_internal_boundaries=='true'):
       if(pg.sdims==2):
         vr = cos_phia*pg.vx1+sin_phia*vx2
         vt1 = -sin_phia*pg.vx1+cos_phia*vx2
         vt2 = 0.0
       if(pg.sdims==3):
        vr = sin_thetaa*cos_phia*pg.vx1+sin_thetaa*sin_phia*pg.vx2+cos_thetaa*pg.vx3
        vt1 = cos_thetaa*cos_phia*pg.vx1+cos_thetaa*sin_phia*pg.vx2-sin_thetaa*pg.vx3
        vt2 = -sin_phia*pg.vx1+cos_phia*pg.vx2
        if(pg.mhd_exists):
         br = sin_thetaa*cos_phia*pg.bx1+sin_thetaa*sin_phia*pg.bx2+cos_thetaa*pg.bx3
         bt1 = cos_thetaa*cos_phia*pg.bx1+cos_thetaa*sin_phia*pg.bx2-sin_thetaa*pg.bx3
         bt2 = -sin_phia*pg.bx1+cos_phia*pg.bx2
      else:
       vr = pg.vx2
       vt1 = pg.vx1
       if(pg.sdims==3):
        vt2 = pg.vx2 
 
      abs_vel_bar = pg.reynolds_barg(np.sqrt(2.0*pg.ekin))
       
      abs_vh_bar = pg.reynolds_barg(np.sqrt(2.0*pg.ekin-vr*vr))

      rho_vr_bar = pg.reynolds_barg(pg.rho*vr)

      pg.etot = pg.etot + epot

      rho_eint_bar = pg.reynolds_barg(pg.rho*pg.eint)

      rho_ekin_bar = pg.reynolds_barg(pg.rho*pg.ekin)

      rho_etot_bar = pg.reynolds_barg(pg.rho*pg.etot)

      rho_h_bar = pg.reynolds_barg(pg.rho*pg.h)

      rho_s_bar = pg.reynolds_barg(pg.rho*pg.s)

      rho_eint_vr_bar = pg.reynolds_barg(pg.rho*pg.eint*vr)

      rho_ekin_vr_bar = pg.reynolds_barg(pg.rho*pg.ekin*vr)

      rho_etot_vr_bar = pg.reynolds_barg(pg.rho*pg.etot*vr)

      rho_h_vr_bar = pg.reynolds_barg(pg.rho*pg.h*vr)

      rho_s_vr_bar = pg.reynolds_barg(pg.rho*pg.s*vr)

      if(pg.geometry!='cartesian'):
       if(pg.geometry=='2d-polar'):
        div_vel = (np.gradient(r*pg.vx1,r1,axis=2)+np.gradient(pg.vx2,theta1,axis=1))*ir
       elif(pg.geometry=='2d-spherical'):
        div_vel = np.gradient(r2*pg.vx1,r1,axis=2)*ir2+np.gradient(sin_theta*pg.vx2,theta1,axis=1)*i_r_sin_theta
       elif(pg.geometry=='3d-spherical'):
        div_vel = np.gradient(r2*pg.vx1,r1,axis=2)*ir2+np.gradient(sin_theta*pg.vx2,theta1,axis=1)*i_r_sin_theta + \
        np.gradient(pg.vx3,phi1,axis=0)*i_r_sin_theta
      else:
       div_vel = np.gradient(pg.vx1,x1,axis=2)+np.gradient(pg.vx2,y1,axis=1)
       if(pg.sdims==3):
        div_vel = div_vel + np.gradient(pg.vx3,z1,axis=0)

      div_vel_bar = pg.reynolds_barg(div_vel)

      P_div_vel_bar = pg.reynolds_barg(pg.P*div_vel)

      iT_bar = pg.reynolds_barg(pg.iT)

      vr_bar = pg.reynolds_barg(vr)

      P_vr_bar = pg.reynolds_barg(pg.P*vr)

      T_vr_bar = pg.reynolds_barg(pg.T*vr)

      abar_vr_bar = pg.reynolds_barg(pg.abar*vr)

      zbar_vr_bar = pg.reynolds_barg(pg.zbar*vr)

      g_dot_vel = gx1*pg.vx1+gx2*pg.vx2+gx3*pg.vx3

      rhovel_g_bar = pg.reynolds_barg(pg.rho*g_dot_vel)

      vel_g_bar = pg.reynolds_barg(g_dot_vel)

      if(pg0.kappa_exists):

         Krad = 4.0/3.0*CONST_RAD*CONST_C*pg.T*pg.T*pg.T/(kappa*pg.rho)

         Krad_bar = pg.reynolds_barg(Krad)
         
         if(pg.geometry!='cartesian'):
          dTdr = np.gradient(pg.T,r1,axis=2)
         elif(pg.geometry=='cartesian') and (pg.use_internal_boundaries=='true'):
          dTdr = x*np.gradient(pg.T,x1,axis=2)+y*np.gradient(pg.T,y1,axis=1)
          if(pg.sdims==3):
           dTdr = dTdr + z*np.gradient(pg.T,z1,axis=0)
          dTdr = dTdr*ir
         else:
          dTdr = np.gradient(pg.T,r1,axis=1)

         dTdr_bar = pg.reynolds_barg(dTdr)
         Krad_dTdr_bar = pg.reynolds_barg(Krad*dTdr)

         if(pg.geometry!='cartesian'):
          if(pg.geometry=='2d-polar'):
           fx1 = -Krad*np.gradient(pg.T,r1,axis=2)
           fx2 = -Krad*np.gradient(pg.T,theta1,axis=1)*ir
           div_frad = (np.gradient(r*fx1,r1,axis=2)+np.gradient(fx2,theta1,axis=1))*ir
          elif(pg.geometry=='2d-spherical'):
           fx1 = -Krad*np.gradient(pg.T,r1,axis=2)
           fx2 = -Krad*np.gradient(pg.T,theta1,axis=1)*ir 
           div_frad = np.gradient(r2*fx1,r1,axis=2)*ir2+np.gradient(sin_theta*fx2,theta1,axis=1)*i_r_sin_theta
          elif(pg.geometry=='3d-spherical'):
           fx1 = -Krad*np.gradient(pg.T,r1,axis=2)
           fx2 = -Krad*np.gradient(pg.T,theta1,axis=1)*ir 
           fx3 = -Krad*np.gradient(pg.T,phi1,axis=0)*i_r_sin_theta 
           div_frad = np.gradient(r2*fx1,r1,axis=2)*ir2+np.gradient(sin_theta*fx2,theta1,axis=1)*i_r_sin_theta + \
           np.gradient(fx3,phi1,axis=2)*i_r_sin_theta
         else:
           fx1 = -Krad*np.gradient(pg.T,x1,axis=2)
           fx2 = -Krad*np.gradient(pg.T,y1,axis=1) 
           div_frad = np.gradient(fx1,x1,axis=2)+np.gradient(fx2,y1,axis=1)
           if(pg.sdims==3):
            fx3 = -Krad*np.gradient(pg.T,z1,axis=0)
            div_frad = div_frad + np.gradient(fx3,z1,axis=0)

         div_frad_iT_bar = pg.reynolds_barg(div_frad*pg.iT)

      else:
        
         Krad_bar = 0.0 
         dTdr_bar = 0.0 
         Krad_dTdr_bar = 0.0
         div_frad_iT_bar = 0.0

      if(pg.nuclear_network_exists):
        edot_reacs_bar = np.zeros((pg.nreacs,len(rho_bar)))
        eps_reacs_bar = np.zeros((pg.nreacs,len(rho_bar)))
        for isp in range(pg.nreacs):
          edot_reacs_bar[isp] = pg.reynolds_barg(pg.edot_reacs[:,:,:,isp])
          eps_reacs_bar[isp] = pg.reynolds_barg(pg.edot_reacs[:,:,:,isp]/pg.rho)
        edot_nuc_bar = pg.reynolds_barg(pg.edot_nuc)
        eps_nuc_bar = pg.reynolds_barg(pg.edot_nuc/pg.rho)
        edot_neu_bar = pg.reynolds_barg(pg.edot_neu)
        eps_neu_bar = pg.reynolds_barg(pg.edot_neu/pg.rho)
        edot_nuc_iT_bar = pg.reynolds_barg(pg.edot_nuc*pg.iT)
        eps_nuc_iT_bar = pg.reynolds_barg(pg.edot_nuc*pg.iT/pg.rho)
        edot_neu_iT_bar = pg.reynolds_barg(pg.edot_neu*pg.iT)
        eps_neu_iT_bar = pg.reynolds_barg(pg.edot_neu*pg.iT/pg.rho)
        edot_tot_iT_bar = pg.reynolds_barg(pg.edot_nuc*pg.iT+pg.edot_neu*pg.iT)
        eps_tot_iT_bar = pg.reynolds_barg(pg.edot_nuc*pg.iT/pg.rho+pg.edot_neu*pg.iT/pg.rho)
      else:
        edot_nuc_bar = 0.0
        edot_reacs_bar = 0.0
        edot_neu_bar = 0.0
        edot_nuc_iT_bar = 0.0
        edot_neu_iT_bar = 0.0
        edot_tot_iT_bar = 0.0
        eps_nuc_bar = 0.0
        eps_reacs_bar = 0.0
        eps_neu_bar = 0.0
        eps_nuc_iT_bar = 0.0
        eps_neu_iT_bar = 0.0
        eps_tot_iT_bar = 0.0

      if(pg.dXdt_exists):

       rho_dXdt_bar = np.zeros((pg.nspecies,len(rho_bar)))
       rho_X_dXdt_bar = np.zeros((pg.nspecies,len(rho_bar)))

       for isp in range(pg.nspecies):

        rho_dXdt_bar[isp] = pg.reynolds_barg(pg.rho*pg.dXdt[:,:,:,isp])
        rho_X_dXdt_bar[isp] = pg.reynolds_barg(pg.rho*pg.X[:,:,:,isp]*pg.dXdt[:,:,:,isp])
 
      else:

       rho_dXdt_bar = 0.0
       rho_X_dXdt_bar = 0.0

      if(pg.nas>0):

       rho_X_bar = np.zeros((pg.nas,len(rho_bar)))
       rho_X_X_bar = np.zeros((pg.nas,len(rho_bar)))
       rho_X_X_vr_bar = np.zeros((pg.nas,len(rho_bar)))
       rho_X_vr_bar = np.zeros((pg.nas,len(rho_bar)))

       for isp in range(pg.nas):

        Xi = pg.X[:,:,:,isp]
        rho_X_bar[isp,:] = pg.reynolds_barg(pg.rho*Xi)
        rho_X_X_bar[isp,:] = pg.reynolds_barg(pg.rho*Xi*Xi)
        rho_X_X_vr_bar[isp,:] = pg.reynolds_barg(pg.rho*Xi*Xi*vr)
        rho_X_vr_bar[isp,:] = pg.reynolds_barg(pg.rho*Xi*vr)

      else:
 
       rho_X_bar = 0.0
       rho_X_X_bar = 0.0
       rho_X_X_vr_bar = 0.0
       rho_X_vr_bar = 0.0

      rho_vr_vr_bar = pg.reynolds_barg(pg.rho*vr*vr)

      rho_vt1_bar = pg.reynolds_barg(pg.rho*vt1)
      rho_vt1_vt1_bar = pg.reynolds_barg(pg.rho*vt1*vt1)

      if(pg.sdims==3):
       rho_vt2_bar = pg.reynolds_barg(pg.rho*vt2)
       rho_vt2_vt2_bar = pg.reynolds_barg(pg.rho*vt2*vt2)
      else:
       rho_vt2_bar = 0.0
       rho_vt2_vt2_bar = 0.0

      if(pg.mhd_exists):
       emag_bar = pg.reynolds_barg(pg.emag)
       abs_br_bar = pg.reynolds_barg(np.abs(br))
       abs_bh_bar = pg.reynolds_barg(np.sqrt(bt1*bt1+bt2*bt2))
      else:
       emag_bar = 0.0
       abs_br_bar = 0.0
       abs_bh_bar = 0.0

      dd = {}

      dd['r'] = r_bar
      dd['area'] = area
      dd['gr_bar'] = gr_bar
      dd['epot_bar'] = epot_bar
      dd['kappa_bar'] = kappa_bar
      dd['edot_bar'] = edot_bar
      dd['rho_bar'] = rho_bar
      dd['P_bar'] = P_bar
      dd['T_bar'] = T_bar
      dd['s_bar'] = s_bar
      dd['abar_bar'] = abar_bar
      dd['Ye_bar'] = Ye_bar
      dd['zbar_bar'] = zbar_bar
      dd['rho_rho_bar'] = rho_rho_bar
      dd['T_T_bar'] = T_T_bar
      dd['P_P_bar'] = P_P_bar
      dd['s_s_bar'] = s_s_bar
      dd['abs_vel_bar'] = abs_vel_bar
      dd['abs_vh_bar'] = abs_vh_bar
      dd['rho_vr_bar'] = rho_vr_bar
      dd['rho_eint_bar'] = rho_eint_bar
      dd['rho_ekin_bar'] = rho_ekin_bar
      dd['rho_etot_bar'] = rho_etot_bar
      dd['rho_h_bar'] = rho_h_bar
      dd['rho_s_bar'] = rho_s_bar
      dd['rho_eint_vr_bar'] = rho_eint_vr_bar
      dd['rho_ekin_vr_bar'] = rho_ekin_vr_bar
      dd['rho_etot_vr_bar'] = rho_etot_vr_bar
      dd['rho_h_vr_bar'] = rho_h_vr_bar
      dd['rho_s_vr_bar'] = rho_s_vr_bar
      dd['div_vel_bar'] = div_vel_bar
      dd['P_div_vel_bar'] = P_div_vel_bar
      dd['iT_bar'] = iT_bar
      dd['vr_bar'] = vr_bar
      dd['abar_vr_bar'] = abar_vr_bar
      dd['zbar_vr_bar'] = zbar_vr_bar
      dd['P_vr_bar'] = P_vr_bar
      dd['T_vr_bar'] = T_vr_bar
      dd['rhovel_g_bar'] = rhovel_g_bar
      dd['vel_g_bar'] = vel_g_bar
      dd['dTdr_bar'] = dTdr_bar
      dd['Krad_bar'] = Krad_bar
      dd['Krad_dTdr_bar'] = Krad_dTdr_bar
      dd['div_frad_iT_bar'] = div_frad_iT_bar
      dd['edot_nuc_bar'] = edot_nuc_bar
      dd['edot_reacs_bar'] = edot_reacs_bar
      dd['edot_neu_bar'] = edot_neu_bar
      dd['edot_nuc_iT_bar'] = edot_nuc_iT_bar
      dd['edot_neu_iT_bar'] = edot_neu_iT_bar
      dd['edot_tot_iT_bar'] = edot_tot_iT_bar
      dd['eps_nuc_bar'] = eps_nuc_bar
      dd['eps_reacs_bar'] = eps_reacs_bar
      dd['eps_neu_bar'] = eps_neu_bar
      dd['eps_nuc_iT_bar'] = eps_nuc_iT_bar
      dd['eps_neu_iT_bar'] = eps_neu_iT_bar
      dd['eps_tot_iT_bar'] = eps_tot_iT_bar
      dd['rho_X_bar'] = rho_X_bar
      dd['rho_X_X_bar'] = rho_X_X_bar
      dd['rho_X_X_vr_bar'] = rho_X_X_vr_bar
      dd['rho_X_vr_bar'] = rho_X_vr_bar
      dd['rho_dXdt_bar'] = rho_dXdt_bar
      dd['rho_X_dXdt_bar'] = rho_X_dXdt_bar
      dd['rho_vr_vr_bar'] = rho_vr_vr_bar
      dd['rho_vt1_bar'] = rho_vt1_bar
      dd['rho_vt1_vt1_bar'] = rho_vt1_vt1_bar
      dd['rho_vt2_bar'] = rho_vt2_bar
      dd['rho_vt2_vt2_bar'] = rho_vt2_vt2_bar
      dd['emag_bar'] = emag_bar
      dd['abs_br_bar'] = abs_br_bar
      dd['abs_bh_bar'] = abs_bh_bar

      np.savez('%s/RPROFS_%d.npz'%(savedir,round(pg.time)), \
      time=pg.time, \
      geometry=pg0.geometry, \
      use_internal_boundaries=pg0.use_internal_boundaries, \
      sdims=pg0.sdims, \
      dd=dd, \
      allow_pickle=True)

main()

