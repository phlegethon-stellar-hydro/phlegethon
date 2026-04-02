SRC = ../../source
DATA = ../../data

APPNAME = app

#grid
OPTS = sdims_make=2
OPTS += nx1_make=256
OPTS += nx2_make=256
OPTS += nx3_make=1
OPTS += ddx1_make=2
OPTS += ddx2_make=2
OPTS += ddx3_make=1
OPTS += ngc_make=2
OPTS += nas_make=2

#geometry
OPTS += GEOMETRY_CARTESIAN_UNIFORM

#boundary conditions
OPTS += X1_PERIODIC
OPTS += X2_PERIODIC
OPTS += X3_PERIODIC

#time stepping
OPTS += VARIABLE_TIMESTEP
OPTS += cfl_make=0.4_rp
OPTS += RK2_STEPPER

#eos
OPTS += ADVECT_YE_IABAR
OPTS += HELMHOLTZ_EOS
OPTS += path_to_helm_table=\"$(DATA)/helm_table_timmes_x2.dat\"
OPTS += helm_nT_make=201
OPTS += helm_nrho_make=541
OPTS += helm_ltlo_make=3.0_rp 
OPTS += helm_lthi_make=13.0_rp 
OPTS += helm_ldlo_make=-12.0_rp 
OPTS += helm_ldhi_make=15.0_rp 
OPTS += USE_FASTEOS

#Godunov
OPTS += LIM2ND_REC
OPTS += HLLC_FLUX
OPTS += Mach_cutoff_make=1.0e-4_rp

#output
OPTS += OUTPUT_NSTEPS
OPTS += nsteps_dump_make=100000
OPTS += info_terminal_rate_make=10
OPTS += dt_restart_make=1e4_rp

#stopping criteria
OPTS += tmax_make=1.0_rp
OPTS += wctmax_make=10000.0_rp
OPTS += stepmax_make=4000000

#precision and endianity
OPTS += USE_DOUBLE_PRECISION
OPTS += LITTLE_ENDIAN

#--------------------------------#

OPTS +=nvars_make=sdims_make+2+nas_make

#include machine-specific configuration
include ${SRC}/../Makefile.config
