SRC = ../../source/
APPNAME = app

#grid
OPTS = sdims_make=2
OPTS += nx1_make=128
OPTS += nx2_make=128
OPTS += nx3_make=1
OPTS += ddx1_make=2
OPTS += ddx2_make=2
OPTS += ddx3_make=1
OPTS += ngc_make=2
OPTS += nas_make=1

#geometry
OPTS += GEOMETRY_CARTESIAN_UNIFORM

#boundary conditions
OPTS += X1_PERIODIC
OPTS += X2L_REFLECTIVE
OPTS += X2U_REFLECTIVE
OPTS += X3_PERIODIC

#time stepping
OPTS += cfl_make=0.8_rp
OPTS += RK3_STEPPER

#mhd
OPTS += USE_MHD
OPTS += Mach_ct_make=1.0e-4_rp

#Godunov
OPTS += PPH_REC
OPTS += LHLLD_FLUX
OPTS += Mach_cutoff_make=1.0e-4_rp

#gravity
OPTS += USE_GRAVITY
OPTS += EVOLVE_ETOT
OPTS += USE_WB

#heat source
OPTS += USE_EDOT

#output
OPTS += OUTPUT_DT
OPTS += dt_dump_make=5.0_rp
OPTS += info_terminal_rate_make=1000
OPTS += dt_restart_make=1.0e5_rp

#stopping criteria
OPTS += tmax_make=2000.0_rp
OPTS += stepmax_make=10000000
OPTS += wctmax_make=85000.0_rp

#precision and endianity
OPTS += USE_DOUBLE_PRECISION
OPTS += LITTLE_ENDIAN

#restart from last checkpoint
OPTS += RESTART_LAST

#--------------------------------#

OPTS +=nvars_make=sdims_make+2+nas_make

#include machine-specific configuration
include ${SRC}/../Makefile.config 




