SRC = ../../source
APPNAME = app

#grid
OPTS += nx1_make=128
OPTS += nx2_make=64
OPTS += ddx1_make=1
OPTS += ddx2_make=1
OPTS += ngc_make=1

#boundary conditions
OPTS += X1_PERIODIC
OPTS += X2_PERIODIC

#time stepping
OPTS += cfl_make=0.2_rp

#output
OPTS += OUTPUT_DT
OPTS += dt_dump_make=1.0_rp
OPTS += info_terminal_rate_make=100

#stopping criteria
OPTS += tmax_make=8.0_rp

#--------------------------------#

OPTS += nvars_make=4

#include machine-specific configuration
include ${SRC}/../Makefile_af.config 
