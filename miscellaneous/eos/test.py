from phleos import *
from phloutput import *

#table parameters
NRHO = 541
NT = 201
LOGRHOMIN = -12.0
LOGRHOMAX = 15.0
LOGTMIN = 3.0
LOGTMAX = 13.0

#load table
eos_table = eos_fort.eos_fort_mod.load_table('%shelm_table_timmes_x2.dat'%(data),NRHO,NT,LOGRHOMIN,LOGRHOMAX,LOGTMIN,LOGTMAX)

#eos mode
eos_mode = ['ions','radiation','elepos','coulomb']

#If you want to use ideal gas law (assuming full ionization) + thermal radiation, you must set
#eos_mode = ['ideal','radiation']

#PIG can either be used alone or in combination with thermal radiation, i.e.,
#eos_mode = ['pig','radiation']

#--------------------------------------------------------------------------------------------

#load a test MESA model
import mesa_reader as mr
mesa_data = './profile1107.data'
names = np.loadtxt(mesa_data,skiprows=5, max_rows=1,dtype=str)
varss = np.loadtxt(mesa_data,skiprows=6)

mesa = {}
for i,name in enumerate(names):
  mesa[name] = varss[::-1,i]
mesa['rmid'] *= CONST_RSUN

rho = 10**mesa['logRho']
T = 10**mesa['logT']
abar = mesa['abar']
zbar = mesa['zbar']
ye = zbar/abar
P = 10**mesa['logP']
s = mesa['entropy']*CONST_RGAS

#EOS CALLS
#--------------------------------------------------------------------------------------------
#density-temperature given
full_eos1 = rhoT_given(eos_table,rho,T,abar=abar,zbar=zbar,gamma_ideal=5.0/3.0,eos_mode=eos_mode)

#density-pressure given (if the guess temperature is not provided, a first estimate is computed using ideal gas law)

full_eos2,T2 = rhoP_given(eos_table,rho,P,Tguess=T,abar=abar,zbar=zbar,gamma_ideal=5.0/3.0,eos_mode=eos_mode)

#pressure-temperature given (if the guess density is not provided, a first estimate is computed using ideal gas law)
full_eos3,rho3 = PT_given(eos_table,P,T,rhoguess=rho,abar=abar,zbar=zbar,gamma_ideal=5.0/3.0,eos_mode=eos_mode)

#pressure-entropy given (this time, guess density and temperature MUST be provided)
full_eos4,rho4,T4 = Ps_given(eos_table,P,s,rho,T,abar=abar,zbar=zbar,gamma_ideal=5.0/3.0,eos_mode=eos_mode)

#--------------------------------------------------------------------------------------------
#prepare figure
nx = 1
ny = 1
deltax = 0.67
deltay = deltax
dx = 0.0
dy = 0.0

aS = 0.2
aN = 0.1
aE = 0.2
aW = 0.2

fig,axs,ex,px,py = generate_grid_free(nx,ny,deltax,deltay,dx,dy,aE,aW,aS,aN,single_column=True)
print('px:',px)

r = mesa['rmid']
axs.loglog(r,mesa['csound'],label=r'$\texttt{MESA}$',c='red')
axs.loglog(r,full_eos1[id_sound],c='black',ls=':',label=r'$\texttt{PHLEGETHON}$',lw=2)
axs.set_ylabel(r'$c_\mathrm{sound}\ [\mathrm{cm\ s^{-1}}]$')
axs.set_xlabel(r'$r\ [\mathrm{cm}]$')
axs.legend()
savefig('sound.png',dpi=500)
show()
