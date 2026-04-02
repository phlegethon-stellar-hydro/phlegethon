SRC = ../../source
DATA = ../../data
APPNAME = app

#grid
OPTS = sdims_make=2
OPTS += nx1_make=48
OPTS += nx2_make=72
OPTS += nx3_make=1
OPTS += ddx1_make=1
OPTS += ddx2_make=1
OPTS += ddx3_make=1
OPTS += ngc_make=2
OPTS += nas_make=2
OPTS += nspecies_make=2
OPTS += nreacs_make=1

#geometry
OPTS += GEOMETRY_CARTESIAN_UNIFORM

#boundary conditions
OPTS += X1_PERIODIC
OPTS += X3_PERIODIC
OPTS += X2L_REFLECTIVE
OPTS += X2U_REFLECTIVE

#time stepping
OPTS += cfl_make=0.8_rp
OPTS += RK3_STEPPER

#Godunov
OPTS += PPH_REC
OPTS += LHLLC_FLUX
OPTS += Mach_cutoff_make=1.0e-5_rp

#eos
OPTS += ADVECT_SPECIES
OPTS += HELMHOLTZ_EOS
OPTS += path_to_helm_table=\"$(DATA)/helm_table_timmes_x1.dat\"
OPTS += helm_nT_make=101
OPTS += helm_nrho_make=271
OPTS += helm_ltlo_make=3.0_rp
OPTS += helm_lthi_make=13.0_rp
OPTS += helm_ldlo_make=-12.0_rp
OPTS += helm_ldhi_make=15.0_rp
OPTS += USE_FASTEOS

#gravity
OPTS += USE_GRAVITY
OPTS += EVOLVE_ETOT
OPTS += USE_WB

#nuclear network
OPTS += USE_NUCLEAR_NETWORK
OPTS += NUCLEAR_NETWORK_GODUNOV
OPTS += NUCLEAR_NETWORK_BE
OPTS += nn_Tmin_make=1e6_rp
OPTS += nn_nltol_make=1.0e-15_rp
OPTS += nn_ltol_make=1.0e-15_rp

#output
OPTS += OUTPUT_DT
OPTS += dt_dump_make=1.0_rp
OPTS += info_terminal_rate_make=100
OPTS += dt_restart_make=1.0e5_rp

#stopping criteria
OPTS += tmax_make=4.0_rp
OPTS += stepmax_make=10000000
OPTS += wctmax_make=1.0e4_rp

#precision and endianity
OPTS += USE_DOUBLE_PRECISION
OPTS += LITTLE_ENDIAN

#--------------------------------#

OPTS +=nvars_make=sdims_make+2+nas_make

#include machine-specific configuration
include ${SRC}/../Makefile.config




