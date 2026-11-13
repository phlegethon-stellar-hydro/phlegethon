SRC = ../../source
APPNAME = app

#grid
OPTS += nx1_make=128
OPTS += nx2_make=192
OPTS += ddx1_make=2
OPTS += ddx2_make=2
OPTS += ngc_make=1

#boundary conditions
OPTS += X1_PERIODIC
OPTS += X2_PERIODIC

#time stepping
OPTS += cfl_make=0.2_rp

#The parameter used in the grid-alignment fix (using an alternative splitting of the eigenvalue matrix)
OPTS += ga_par_make=750.0_rp             #for the hotbubble test, ga_par lower than 500 brings back the minute problematic vertical structure


#gravity
OPTS += USE_GRAVITY
OPTS += WB_DEVIATION       #turn deviation well-balancing on
OPTS += GRID_ALIGNMENT_FIX # turn a fix for the grid alignment issue in hotbubble test on





#output
OPTS += OUTPUT_DT
OPTS += dt_dump_make=10.0_rp
OPTS += info_terminal_rate_make=10

#stopping criteria
OPTS += tmax_make=300.0_rp

#--------------------------------#

OPTS +=nvars_make=4

#include machine-specific configuration
include ${SRC}/../Makefile_af.config 

