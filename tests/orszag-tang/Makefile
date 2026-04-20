SRC = ../../source
APPNAME = app

#grid
OPTS = sdims_make=2
OPTS += nx1_make=128
OPTS += nx2_make=128
OPTS += nx3_make=1
OPTS += ddx1_make=2
OPTS += ddx2_make=2
OPTS += ddx3_make=1
OPTS += ngc_make=3
OPTS += nas_make=0

#geometry
OPTS += GEOMETRY_CARTESIAN_UNIFORM

#boundary conditions
OPTS += X1_PERIODIC
OPTS += X2_PERIODIC
OPTS += X3_PERIODIC

#time stepping
OPTS += VARIABLE_TIMESTEP
OPTS += cfl_make=0.8_rp
OPTS += RK3_STEPPER

#Godunov
OPTS += LIM5TH_REC
OPTS += HLLD_FLUX
OPTS += Mach_cutoff_make=1.0e-4_rp

#mhd
OPTS += USE_MHD
OPTS += Mach_ct_make=1e-6_rp

#output
OPTS += OUTPUT_DT
OPTS += dt_dump_make=0.1_rp
OPTS += info_terminal_rate_make=100
OPTS += dt_restart_make=1.0e5_rp

#stopping criteria
OPTS += stepmax_make=2000000
OPTS += tmax_make=1.0_rp
OPTS += wctmax_make=10000.0_rp

#precision and endianity
OPTS += USE_DOUBLE_PRECISION
OPTS += LITTLE_ENDIAN

#--------------------------------#

OPTS +=nvars_make=sdims_make+2+nas_make

#include machine-specific configuration
include ${SRC}/../Makefile.config 
