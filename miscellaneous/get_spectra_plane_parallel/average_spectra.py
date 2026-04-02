import h5py
import matplotlib.pyplot as plt
import numpy as np
import math
import os
import time
from scipy.integrate import cumulative_trapezoid as cumtrapz
import subprocess as sp
import sys
import fileinput
import scipy.interpolate as interp1d
from scipy.interpolate import CubicSpline as interp1d
from scipy.optimize import curve_fit
import re

path_to_spectra = '/hits/basement/pso/leidigi/Phlegethon/miscellaneous/get_spectra_plane_parallel/data/' #path to spectra
path_to_output = '/hits/basement/pso/leidigi/Phlegethon/miscellaneous/get_spectra_plane_parallel/data/' #path to repository where to store the time-averaged spectra
iYs = [32,96] #list of slicing indices in the vertical direction (x2-dir in Phlegethon) at which the spectra are computed
t1 = 100.0 #initial time of the averaging window (in code units)
t2 = 400.0 #final time of the averaging window (in code units)

#=========================================================================================#

#create directory for storing the time-averaged spectrum if it does not exist yet
os.makedirs(path_to_output,exist_ok=True)       

#loop over slices
for iY in iYs:

 #count the number of spectra in specified repository
 list_dir = os.listdir(path_to_spectra)
 spectra = [entry for entry in list_dir if entry.startswith("SPECTRA_iY_%d_"%(iY))]
 
 idx_spectra = []
 for spectrum in spectra:
  nb = re.findall(r'\d+',spectrum)
  idx_spectra.append(int(nb[1]))
 
 idx_spectra = np.array(sorted(idx_spectra))
 
 first_checked = False
 last_checked = False
 
 for idx in idx_spectra:
 
   data = np.load(path_to_spectra+'SPECTRA_iY_%d_%d.npz'%(iY,idx),allow_pickle=True)
   time = data['time']
   if(time>t1 and first_checked==False):
    dump1 = idx
    first_checked = True
   if(time>t2 and last_checked==False):
    dump2 = idx
    last_checked = True
 
 eb_hat = 0
 ek_hat = 0

 icnt = 0
 for isp in range(dump1,dump2):

   data = np.load(path_to_spectra+'SPECTRA_iY_%d_%d.npz'%(iY,isp),allow_pickle=True)
   dd = data['dd']
   itm = dd.item()
   ek_hat += itm['ek_hat']
   eb_hat += itm['eb_hat']
   icnt += 1
 
 yref = data['yref']
 ek_hat /= icnt
 eb_hat /= icnt
 kh = itm['kh']
 
 np.savez(path_to_output+'SPECTRA_AVG_iY_%d.npz'%(iY),kh=kh,ek_hat=ek_hat,eb_hat=eb_hat,yref=yref,t1=t1,t2=t2)
      








  
 
 

