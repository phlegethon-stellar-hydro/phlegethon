SRC = ../../source
APPNAME = app

#grid
OPTS = sdims_make=2
OPTS += nx1_make=96
OPTS += nx2_make=96
OPTS += nx3_make=1
OPTS += ddx1_make=2
OPTS += ddx2_make=2
OPTS += ddx3_make=1
OPTS += ngc_make=2
OPTS += nas_make=2

#geometry
OPTS += GEOMETRY_2D_SPHERICAL
OPTS += NONUNIFORM_RADIAL_NODES

#boundary conditions
OPTS += X1L_REFLECTIVE
OPTS += X1U_REFLECTIVE
OPTS += X2_PERIODIC
OPTS += X3_PERIODIC
OPTS += FIX_TEMPERATURE_AT_X1L
OPTS += FIX_TEMPERATURE_AR_X1U

#time stepping
OPTS += VARIABLE_TIMESTEP
OPTS += cfl_make=0.8_rp
OPTS += RK3_STEPPER

#Godunov
OPTS += PPH_REC
OPTS += HLLC_FLUX
OPTS += Mach_cutoff_make=1.0e-4_rp

#eos
OPTS += ADVECT_YE_IABAR
OPTS += USE_PRAD

#gravity
OPTS += USE_GRAVITY
OPTS += EVOLVE_ETOT
OPTS += USE_WB

#radiative diffusion
OPTS += THERMAL_DIFFUSION_STS
OPTS += EVALUATE_PARABOLIC_TIMESTEP
OPTS += BALANCE_THERMAL_DIFFUSION

#output
OPTS += OUTPUT_NSTEPS
OPTS += nsteps_dump_make=100000
OPTS += info_terminal_rate_make=10000
OPTS += dt_restart_make=1.0e5_rp

#stopping criteria
OPTS += tmax_make=2.0_rp
OPTS += stepmax_make=10000000
OPTS += wctmax_make=1.0e4_rp

#precision and endianity
OPTS += USE_DOUBLE_PRECISION
OPTS += LITTLE_ENDIAN

#--------------------------------#

OPTS +=nvars_make=sdims_make+2+nas_make

#include machine-specific configuration
include ${SRC}/../Makefile.config
