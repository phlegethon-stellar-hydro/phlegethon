SRC = ../../source
APPNAME = app

#grid
OPTS = sdims_make=2
OPTS += nx1_make=64
OPTS += nx2_make=96
OPTS += nx3_make=1
OPTS += ddx1_make=2
OPTS += ddx2_make=2
OPTS += ddx3_make=1
OPTS += ngc_make=3
OPTS += nas_make=2

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
OPTS += LHLLC_FLUX
OPTS += Mach_cutoff_make=1.0e-4_rp

#gravity
OPTS += USE_GRAVITY
OPTS += EVOLVE_ETOT
OPTS += USE_WB

#output
OPTS += OUTPUT_NSTEPS
OPTS += nsteps_dump_make=1000000
OPTS += info_terminal_rate_make=100
OPTS += dt_restart_make=1.0e5_rp

#stopping criteria
OPTS += tmax_make=30.0_rp
OPTS += stepmax_make=1000000
OPTS += wctmax_make=1e4_rp

#precision and endianity
OPTS += USE_DOUBLE_PRECISION
OPTS += LITTLE_ENDIAN

#userdef parameter
OPTS += dAbyA_make=0.1_rp

#--------------------------------#

OPTS +=nvars_make=sdims_make+2+nas_make

#include machine-specific configuration
include ${SRC}/../Makefile.config
