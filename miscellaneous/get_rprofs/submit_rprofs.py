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

path_to_sim = '/hits/basement/pso/leidigi/ccsn_progenitor/hydro/' #path to grid snapshots
path_to_output = '/hits/basement/pso/leidigi/ccsn_progenitor/analysis/MHD-512x512x512/' #path to repository where to store the radial profiles
pycmd = '/hits/basement/pso/leidigi/ccsn_progenitor/analysis/extract_rprofs.py' #python command
ntasks = 30 #number of chunks into which the time series is split
ncores_per_task = 32 #number of cores allocated per task
delta = 1 #pace at which snapshots are read
rebin = 0 #0 for False, 1 for True. This option performs a x2 compression on the grid snapshots before computing radial profiles
partition = 'rome.p'

#=========================================================================================#

#create directory for storing radial profiles if it does not exist yet
os.makedirs(path_to_output,exist_ok=True)       

#count the number of grid snapshots in simulation repository
grids = [fl for fl in os.listdir(path_to_sim) if fl.startswith("grid_")]
nfiles = len(grids)

#divide the whole series of grid snapshots in chunks
dfiles = int(nfiles/ntasks)

#start counting
dump1 = 0
dump2 = dfiles
 
for ip in range(ntasks):

   #open the job script
   sbatch = fileinput.input('./get_rprofs.job',inplace=1)

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
       line = "python3 %s %d %d %d %d %s %s"%(pycmd,dump1,dump2,delta,rebin,path_to_sim,path_to_output)
    
     sys.stdout.write(line)

   #close the job script
   sbatch.close()
   
   #submit the job script                            
   cmd = 'sbatch get_rprofs.job'
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
   sbatch = fileinput.input('./get_rprofs.job',inplace=1)

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
       line = "python3 %s %d %d %d %d %s %s"%(pycmd,dump1,nfiles,delta,rebin,path_to_sim,path_to_output)
    
     sys.stdout.write(line)

   #close the job script
   sbatch.close()
   
   #submit the job script                            
   cmd = 'sbatch get_rprofs.job'
   process = sp.Popen(cmd,shell=True)
   process.wait()
   print('processing dumps: %d --> %d'%(dump1,nfiles))


