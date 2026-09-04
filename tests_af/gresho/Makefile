SRC = ../../source
APPNAME = app

#grid
OPTS += nx1_make=50
OPTS += nx2_make=50
OPTS += ddx1_make=2
OPTS += ddx2_make=2
OPTS += ngc_make=1

#boundary conditions
OPTS += X1_PERIODIC
OPTS += X2_PERIODIC

#time stepping
OPTS += cfl_make=0.2_rp

#output
OPTS += OUTPUT_DT
OPTS += dt_dump_make=0.01_rp
OPTS += info_terminal_rate_make=10

#stopping criteria
OPTS += tmax_make=1.26_rp

#--------------------------------#

OPTS +=nvars_make=4

#include machine-specific configuration
include ${SRC}/../Makefile_af.config 
