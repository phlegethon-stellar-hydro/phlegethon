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

path_to_sim = '/hits/basement/pso/leidigi/cbm-alberto/192x192x192-delta_nabla-0.3-nabla_mu-0.1-b-1.0e-01-no-thermal-eq/' #path to grid snapshots
path_to_output = '/hits/basement/pso/leidigi/Phlegethon/miscellaneous/get_spectra_plane_parallel/data/' #path to repository where to store the power spectra
pycmd = '/hits/basement/pso/leidigi/Phlegethon/miscellaneous/get_spectra_plane_parallel/extract_spectra.py' #python command
ntasks = 50 #number of chunks into which the time series is split
ncores_per_task = 1 #number of cores allocated per task
delta = 1 #pace at which snapshots are read
iYs = [32,64,96] #list of slicing indices in the vertical direction (x2-dir in Phlegethon) at which the spectra are computed
partition = 'rome.p'

#=========================================================================================#

#create directory for storing radial profiles if it does not exist yet
os.makedirs(path_to_output,exist_ok=True)       

#count the number of grid snapshots in simulation repository
grids = [fl for fl in os.listdir(path_to_sim) if fl.startswith("grid_")]
nfiles = len(grids)

#divide the whole series of grid snapshots in chunks
dfiles = int(nfiles/ntasks)

#for every vertical slice chosen
for iY in iYs:
 
 #start counting
 dump1 = 0
 dump2 = dfiles
  
 for ip in range(ntasks):
 
    #open the job script
    sbatch = fileinput.input('./get_spectra.job',inplace=1)
 
    #for every line in the job script
    for line in sbatch:
       
      #choose partition
      if("#SBATCH -p" in line):
        line = "#SBATCH -p %s \n"%(partition)
 
      #allocate the number of cores
      if("#SBATCH -n" in line):
        line = "#SBATCH -n %d \n"%(ncores_per_task)
 
      #overwrite the python command with the updated input parameters
      if("python3" in line):
        line = "python3 %s %d %d %d %d %s %s"%(pycmd,dump1,dump2,delta,iY,path_to_sim,path_to_output)
     
      sys.stdout.write(line)
 
    #close the job script
    sbatch.close()
    
    #submit the job script                            
    cmd = 'sbatch get_spectra.job'
    process = sp.Popen(cmd,shell=True)
    process.wait()
    print('processing dumps: %d --> %d'%(dump1,dump2))
 
    dump1 += dfiles
    if(dump2+dfiles>nfiles):
      dump2 = nfiles
    else:
      dump2 += dfiles
 
 if(dump1<nfiles):
  
    #open the job script
    sbatch = fileinput.input('./get_spectra.job',inplace=1)
 
    #for every line in the job script
    for line in sbatch:
       
      #choose partition
      if("#SBATCH -p" in line):
        line = "#SBATCH -p %s \n"%(partition)
 
      #allocate the number of cores
      if("#SBATCH -n" in line):
        line = "#SBATCH -n %d \n"%(ncores_per_task)
 
      #overwrite the python command with the updated input parameters
      if("python3" in line):
        line = "python3 %s %d %d %d %d %s %s"%(pycmd,dump1,nfiles,delta,iY,path_to_sim,path_to_output)
     
      sys.stdout.write(line)
 
    #close the job script
    sbatch.close()
    
    #submit the job script                            
    cmd = 'sbatch get_spectra.job'
    process = sp.Popen(cmd,shell=True)
    process.wait()
    print('processing dumps: %d --> %d'%(dump1,nfiles))
 
 
