SRC = ../../source
APPNAME = app

#grid
OPTS += nx1_make=30
OPTS += nx2_make=30
OPTS += ddx1_make=2
OPTS += ddx2_make=2
OPTS += ngc_make=2

#boundary conditions
OPTS += X1_PERIODIC
OPTS += X2_PERIODIC

#time stepping
OPTS += cfl_make=0.2_rp

#output
OPTS += OUTPUT_DT
OPTS += dt_dump_make=5000_rp
OPTS += info_terminal_rate_make=10

#stopping criteria200000_rp
OPTS += tmax_make=20000_rp



#parabolic source term
OPTS += use_pst_make
#use hydro
OPTS += deactivate_hydro_make
#use parabolic time step
OPTS += use_pb_dt_make

#--------------------------------#

OPTS +=nvars_make=4

#include machine-specific configuration
include ${SRC}/../Makefile_af.config
