module source
 use mpi
 use hdf5

 implicit none

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! TYPES
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 integer, parameter :: &
#ifdef USE_SINGLE_PRECISION
 rp=4
#endif
#ifdef USE_DOUBLE_PRECISION
 rp=8
#endif 

 integer, parameter :: &
#ifdef USE_SINGLE_PRECISION
 MPI_RP=MPI_REAL4
#endif
#ifdef USE_DOUBLE_PRECISION
 MPI_RP=MPI_REAL8
#endif

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! MAKEFILE OPTS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  integer, parameter :: sdims = &
#ifdef sdims_make
  sdims_make
#else
  1
#endif

  integer, parameter :: nx1 = &
#ifdef nx1_make
  nx1_make
#else
  1
#endif

 integer, parameter :: nx2 = &
#ifdef nx2_make
  nx2_make
#else
  1
#endif

 integer, parameter :: nx3 = &
#ifdef nx3_make
  nx3_make
#else
  1
#endif

 integer, parameter :: ddx1 = &
#ifdef ddx1_make
  ddx1_make
#else
  1
#endif

 integer, parameter :: ddx2 = &
#ifdef ddx2_make
  ddx2_make
#else
  1
#endif

 integer, parameter :: ddx3 = &
#ifdef ddx3_make
  ddx3_make
#else
  1
#endif

 integer, parameter :: ngc = &
#ifdef ngc_make
  ngc_make
#else
  2
#endif

 integer, parameter :: nas = &
#ifdef nas_make
  nas_make
#else
  0
#endif

#ifdef ADVECT_SPECIES
 integer, parameter :: nspecies = &
#ifdef nspecies_make
  nspecies_make
#else
  1
#endif
#endif

#ifdef USE_NUCLEAR_NETWORK
 integer, parameter :: nreacs = &
#ifdef nreacs_make
  nreacs_make
#else
  1
#endif
#endif

#ifdef GEOMETRY_CUBED_SPHERE
 real(kind=rp), parameter :: cs_r1 = &
#ifdef cs_r1_make
  cs_r1_make
#else
  1.0_rp
#endif

 real(kind=rp), parameter :: cs_gridexp = &
#ifdef cs_gridexp_make
  cs_gridexp_make
#else
  0.0_rp
#endif

 real(kind=rp), parameter :: cs_alpha = &
#ifdef cs_alpha_make
  cs_alpha_make
#else
  1.0_rp
#endif
#endif

 real(kind=rp), parameter :: cfl = &
#ifdef cfl_make
  cfl_make
#else
  0.8_rp
#endif

 real(kind=rp), parameter :: tmax = &
#ifdef tmax_make
  tmax_make
#else
  30.0_rp
#endif

 integer, parameter :: stepmax = &
#ifdef stepmax_make
  stepmax_make
#else
  100000
#endif

 real(kind=rp), parameter :: wctmax = &
#ifdef wctmax_make
  wctmax_make
#else
  85000.0_rp
#endif

 real(kind=rp), parameter :: stop_at_temp_max = &
#ifdef stop_at_temp_max_make
  stop_at_temp_max_make
#else
  1.0e10_rp
#endif

 real(kind=rp), parameter :: Mach_cutoff = &
#ifdef Mach_cutoff_make
  Mach_cutoff_make
#else
  1e-5_rp
#endif

 real(kind=rp), parameter :: eps_sf = &
#ifdef eps_sf_make
  eps_sf_make
#else
  0.25_rp
#endif

 real(kind=rp), parameter :: Mach_ct = &
#ifdef Mach_ct_make
  Mach_ct_make
#else
  1e-6_rp
#endif

#ifdef HELMHOLTZ_EOS
  integer, parameter :: helm_nT = &
#ifdef helm_nT_make
  helm_nT_make
#else
  101
#endif

 integer, parameter :: helm_nrho = &
#ifdef helm_nrho_make
  helm_nrho_make
#else
  271
#endif

 real(kind=rp), parameter :: helm_ltlo = &
#ifdef helm_ltlo_make
  helm_ltlo_make
#else
  3.0_rp
#endif

 real(kind=rp), parameter :: helm_lthi = &
#ifdef helm_lthi_make
  helm_lthi_make
#else
  13.0_rp
#endif

 real(kind=rp), parameter :: helm_ldlo = &
#ifdef helm_ldlo_make
  helm_ldlo_make
#else
  -12.0_rp
#endif

 real(kind=rp), parameter :: helm_ldhi = &
#ifdef helm_ldhi_make
  helm_ldhi_make
#else
  15.0_rp
#endif
#endif

#ifdef PIG_EOS
  integer, parameter :: pig_nT = &
#ifdef pig_nT_make
  pig_nT_make
#else
  401
#endif

 integer, parameter :: pig_nrho = &
#ifdef pig_nrho_make
  pig_nrho_make
#else
  401
#endif

 real(kind=rp), parameter :: pig_ltlo = &
#ifdef pig_ltlo_make
  pig_ltlo_make
#else
  1.0_rp
#endif

 real(kind=rp), parameter :: pig_lthi = &
#ifdef pig_lthi_make
  pig_lthi_make
#else
  8.0_rp
#endif

 real(kind=rp), parameter :: pig_ldlo = &
#ifdef pig_ldlo_make
  pig_ldlo_make
#else
  -20.0_rp
#endif

 real(kind=rp), parameter :: pig_ldhi = &
#ifdef pig_ldhi_make
  pig_ldhi_make
#else
  0.0_rp
#endif
#endif

 real(kind=rp), parameter :: gs_tol = &
#ifdef gs_tol_make
  gs_tol_make
#else
  1.0e-4_rp
#endif

#ifdef USE_NUCLEAR_NETWORK
 real(kind=rp), parameter :: nn_nltol = &
#ifdef nn_nltol_make
  nn_nltol_make
#else
  1.0e-11_rp
#endif

 real(kind=rp), parameter :: nn_ltol = &
#ifdef nn_ltol_make
  nn_ltol_make
#else
  1.0e-11_rp
#endif

 real(kind=rp), parameter :: nn_Tmin = &
#ifdef nn_Tmin_make
  nn_Tmin_make
#else
  0.0_rp
#endif

 real(kind=rp), parameter :: boost_reacs = &
#ifdef boost_reacs_make
  boost_reacs_make
#else
  100.0_rp
#endif

 real(kind=rp), parameter :: boost_neuloss = &
#ifdef boost_neuloss_make
  boost_neuloss_make
#else
  10.0_rp
#endif
#endif

#ifdef USE_VDAMPING
 real(kind=rp), parameter :: nu_damp = &
#ifdef nu_damp_make
  nu_damp_make
#else
  0.01_rp
#endif

 real(kind=rp), parameter :: rmin_damp = &
#ifdef rmin_damp_make
  rmin_damp_make
#else
  1.0e10_rp
#endif

 real(kind=rp), parameter :: rmax_damp = &
#ifdef rmax_damp_make
  rmax_damp_make
#else
  1.5e10_rp
#endif

 real(kind=rp), parameter :: tmax_damp = &
#ifdef tmax_damp_make
  tmax_damp_make
#else
  1000.0_rp
#endif

 real(kind=rp), parameter :: tend_damp = &
#ifdef tend_damp_make
  tend_damp_make
#else
  1500.0_rp
#endif
#endif

#ifdef USE_VARIABLE_EDOT
 real(kind=rp), parameter :: t_start_edot = &
#ifdef t_start_edot_make
  t_start_edot_make
#else
  0.0_rp
#endif
#endif

#ifdef OUTPUT_NSTEPS
 integer, parameter :: nsteps_dump = &
#ifdef nsteps_dump_make
  nsteps_dump_make
#else
  10
#endif
#endif

#ifdef OUTPUT_DT
 real(kind=rp), parameter :: dt_dump = &
#ifdef dt_dump_make
  dt_dump_make
#else
  1.5_rp
#endif
#endif

 integer, parameter :: info_terminal_rate = &
#ifdef info_terminal_rate_make
  info_terminal_rate_make
#else
  100000
#endif

 real(kind=rp), parameter :: dt_restart = &
#ifdef dt_restart_make
  dt_restart_make
#else
  100.0_rp
#endif

#ifdef SAVE_PLANES
 integer, parameter :: nplanes_x1 = &
#ifdef nplanes_x1_make
  nplanes_x1_make
#else
  1
#endif

 integer, parameter :: nplanes_x2 = &
#ifdef nplanes_x2_make
  nplanes_x2_make
#else
  1
#endif

 integer, parameter :: nplanes_x3 = &
#ifdef nplanes_x3_make
  nplanes_x3_make
#else
  1
#endif

 real(kind=rp), parameter :: planes_dt_dump = &
#ifdef planes_dt_dump_make
  planes_dt_dump_make
#else
  1.0_rp
#endif
#endif

#ifdef SAVE_SPHERICAL_PROJECTIONS
 integer, parameter :: nspj = &
#ifdef nspj_make
  nspj_make
#else
  5
#endif

 real(kind=rp), parameter :: spj_dt_dump = &
#ifdef spj_dt_dump_make
  spj_dt_dump_make
#else
  1.5_rp
#endif
#endif

#ifdef USE_POINT_PROBES
 integer, parameter :: nprobes = &
#ifdef nprobes_make
  nprobes_make
#else
  2
#endif
#endif

 integer, parameter :: nvars = &
#ifdef nvars_make
  nvars_make
#else
  sdims+2+nas
#endif

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! INDEXES
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 integer, parameter :: &
 i_rho = 1, &
 i_vx1 = 2, &
 i_vx2 = 3, &
#if sdims_make==3
 i_vx3 = 4, &
#else
 i_vx3 = i_vx2, &
#endif
 i_p = i_vx3+1, &
 i_rhovx1 = i_vx1, &
 i_rhovx2 = i_vx2, &
 i_rhovx3 = i_vx3, &
 i_rhoe = i_p, &
 i_as1 = 2+sdims+1, &
 i_asl = nvars, &
 i_rhoas1 = i_as1, &
 i_rhoasl = i_asl

 integer, parameter :: &
 i_ye = i_as1, &
 i_iabar = i_as1 + 1, &
 i_rhoye = i_ye, &
 i_rhoiabar = i_iabar
 
 integer, parameter :: &
 nvars_eq = 3, &
 ieq_rho = 1, &
 ieq_p = 2, &
 ieq_T = 3

#ifdef USE_FASTEOS
 integer, parameter :: &
 i_gammae = 1, &
 i_gammac = 2
#endif

 integer, parameter :: master_rank=0
 integer, parameter :: filename_size=256
 integer, parameter :: iunit=21
 integer, parameter :: idummy=0

#ifdef HELMHOLTZ_EOS

 integer, parameter :: &
 id_f = 1, &
 id_dfdT = 2, &
 id_d2fdT2 = 3, & 
 id_dfdrho = 4, &
 id_d2fdrho2 = 5, &
 id_d2fdrhodT = 6, &
 id_d3fdrho2dT = 7, &
 id_d3fdrhodT2 = 8, &
 id_d4fdrho2dT2 = 9

 integer, parameter :: &
 id_c = 1, &
 id_dcdT = 2, &
 id_dcdrho = 3, &
 id_d2cdrhodT = 4

#ifdef USE_TIMMES_KAPPA

 integer, parameter :: &
 id_eta = 1, &
 id_detadT = 2, &
 id_detadrho = 3, & 
 id_d2etadrhodT = 4, & 
 id_xf = 1, &
 id_dxfdT = 2, &
 id_dxfdrho = 3, &
 id_d2xfdrhodT = 4

#endif

 integer, parameter :: helm_nvars=9

 real(kind=rp), save, dimension(1:helm_nvars,1:helm_nrho,1:helm_nT) :: helm_table_var
 real(kind=rp), save, dimension(1:4,1:helm_nrho,1:helm_nT) :: dpdrho_table_var
#ifdef USE_TIMMES_KAPPA
 real(kind=rp), save, dimension(1:4,1:helm_nrho,1:helm_nT) :: eta_table, xf_table
#endif
 real(kind=rp), save, dimension(1:helm_nrho) :: helm_rho
 real(kind=rp), save, dimension(1:helm_nT) :: helm_T
 real(kind=rp), save :: helm_drho,helm_dT
  
#endif

#ifdef PIG_EOS

 integer, parameter :: &
 id_f = 1, &
 id_dfdT = 2, &
 id_d2fdT2 = 3, & 
 id_dfdrho = 4, &
 id_d2fdrho2 = 5, &
 id_d2fdrhodT = 6, &
 id_d3fdrho2dT = 7, &
 id_d3fdrhodT2 = 8, &
 id_d4fdrho2dT2 = 9
  
 integer, parameter :: &
 id_c = 1, &
 id_dcdT = 2, &
 id_dcdrho = 3, &
 id_d2cdrhodT = 4

 integer, parameter :: pig_nvars=9

 real(kind=rp), save, dimension(1:pig_nvars,1:pig_nrho,1:pig_nT) :: pig_table_var
 real(kind=rp), save, dimension(1:4,1:pig_nrho,1:pig_nT) :: dpdrho_table_var
 real(kind=rp), save, dimension(1:pig_nrho) :: pig_rho
 real(kind=rp), save, dimension(1:pig_nT) :: pig_T
 real(kind=rp), save :: pig_drho,pig_dT
  
#endif

#ifdef USE_POINT_PROBES
#ifdef USE_MHD
 integer, parameter :: n_probe_vars = 2 + sdims
#else
 integer, parameter :: n_probe_vars = 2
#endif
#endif

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! PHYSICAL CONSTANTS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 real(kind=rp), parameter :: &
 CONST_RGAS = 8.31446261815324e7_rp, &
 CONST_RAD = 7.565767381646406e-15_rp, &
#ifdef CONST_GRAV_UNITY
 CONST_GRAV = 1.0_rp, &
#else
 CONST_GRAV = 6.67428e-8_rp, &
#endif
 CONST_RSUN = 6.95660e10_rp, &
 CONST_PI = 3.141592653589793238_rp, &
 CONST_C = 2.99792458e10_rp, &
 CONST_C2 = 8.987551787368177e20_rp, &
 CONST_AV = 6.02214076e23_rp, &
 CONST_QE = 4.8032042712e-10_rp, &
 CONST_KB = 1.380650424e-16_rp, & 
 CONST_NAV_MEV_TO_ERG = 9.648533007578216e+17_rp

#ifdef USE_COULOMB_CORRECTIONS
 real(kind=rp), parameter :: &
 cc_a1 = -0.898004_rp, &
 cc_b1 =  0.96786_rp, &
 cc_c1 =  0.220703_rp, &
 cc_d1 = -0.86097_rp, &
 cc_e1 =  2.5269_rp, &
 cc_a2 =  0.29561_rp, &
 cc_b2 =  1.9885_rp, &
 cc_c2 =  0.288675_rp
#endif

#ifdef USE_ELECTRON_SCREENING
 real(kind=rp), parameter :: &
 CONST_S1 = 227470.4169638696_rp,  &
 CONST_S2 = 187909186.719758_rp, &
 CONST_S3 = 4248.708674377861_rp   
#endif

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! NUMBERS 
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 real(kind=rp), parameter :: &
 rph = 0.5_rp, &
 rpoh = 1.5_rp, &
 rpth = 2.5_rp, &
 rp0 = 0.0_rp, &
 rp1 = 1.0_rp, & 
 rp2 = 2.0_rp, & 
 rp3 = 3.0_rp, & 
 rp4 = 4.0_rp, & 
 rp5 = 5.0_rp, & 
 rp6 = 6.0_rp, & 
 rp7 = 7.0_rp, & 
 rp8 = 8.0_rp, & 
 rp9 = 9.0_rp, & 
 rp10 = 10.0_rp, & 
 rp11 = 11.0_rp, &
 rp12 = 12.0_rp, &
 rp13 = 13.0_rp, &
 rp14 = 14.0_rp, &
 rp15 = 15.0_rp, &
 rp16 = 16.0_rp, &
 rp17 = 17.0_rp, &
 rp18 = 18.0_rp, &
 rp19 = 19.0_rp, &
 rp20 = 20.0_rp, &
 rp21 = 21.0_rp, &
 rp25 = 25.0_rp, &
 rp30 = 30.0_rp, &
 rp32 = 32.0_rp, & 
 rp36 = 36.0_rp, &
 rp38 = 38.0_rp, &
 rp60 = 60.0_rp, &
 rp91 = 91.0_rp, &
 rp96 = 96.0_rp, &
 rp120 = 120.0_rp, &
 rp180 = 180.0_rp, &
 rp189 = 189.0_rp, &
 rp329 = 329.0_rp, &
 othird = 1.0_rp/3.0_rp, &
 tthirds = 2.0_rp/3.0_rp, &
 fthirds = 4.0_rp/3.0_rp, &
 fvthirds = 5.0_rp/3.0_rp, &
 oquart = 0.25_rp, &
 tquarts = 0.75_rp, &
 osixth = 1.0_rp/6.0_rp, &
 fvsixth = 5.0_rp/6.0_rp, &
 fvtwelfth = 5.0_rp/12.0_rp, &
 o420 = 1.0_rp/420.0_rp, &
 ep3 = 1.0e3_rp, &
 ep13 = 1.0e13_rp, &
 em9 = 1.0e-9_rp, &
 em11 = 1.0e-11_rp, &
 em14 = 1.0e-14_rp, &
 em15 = 1.0e-15_rp

#ifdef USE_LMP_WEAK_RATES

 real(kind=rp), parameter :: weak_T9(13) = (/ &
 0.01_rp, &
 0.1_rp, &
 0.2_rp, &
 0.4_rp, &
 0.7_rp, &
 1.0_rp, &
 1.5_rp, &
 2.0_rp, &
 3.0_rp, &
 5.0_rp, &
 10.0_rp, &
 30.0_rp, &
 100.0_rp /)

 real(kind=rp), parameter :: weak_logrhoye(11) = (/ &
 1.0_rp, &
 2.0_rp, &
 3.0_rp, &
 4.0_rp, &
 5.0_rp, &
 6.0_rp, &
 7.0_rp, &
 8.0_rp, &
 9.0_rp, &
 10.0_rp, &
 11.0_rp /) 

#endif

#ifdef PIG_EOS
 real(kind=rp), parameter :: &
 Tl_eos = 10**pig_ltlo, &
 Th_eos = 10**pig_lthi, &
 pig_tol=em11
#endif

#ifdef HELMHOLTZ_EOS
 real(kind=rp), parameter :: &
 Tl_eos = 10**helm_ltlo, &
 Th_eos = 10**helm_lthi, &
 rhol_eos = 10**(helm_ldlo), &
 rhoh_eos = 10**(helm_ldhi), &
 helm_tol=em11
#endif

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! RIEMANN SOLVER UTILS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 type p_flux

    real(kind=rp), allocatable, dimension(:) :: val

 end type

#ifdef USE_SHOCK_FLATTENING
 type i_flux

    integer, allocatable, dimension(:) :: val  

 end type
#endif

#ifdef USE_FASTEOS
 type gamma_funcs

    real(kind=rp), allocatable, dimension(:,:) :: val

 end type
#endif

#ifdef GEOMETRY_CUBED_SPHERE
 type vers

    real(kind=rp), allocatable, dimension(:,:) :: val

 end type
#endif

 type r_utils

   integer :: dir

   real(kind=rp) :: gm,mu

#ifdef ADVECT_SPECIES
   real(kind=rp), dimension(1:nspecies) :: A,Z
#endif

   type(p_flux), dimension(sdims) :: pn

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
#ifdef USE_FASTEOS
   type(gamma_funcs), dimension(sdims) :: gammafL,gammafR
#else
   type(p_flux), dimension(sdims) :: guess_temp
#endif
#endif

#ifdef USE_SHOCK_FLATTENING
   type(i_flux), dimension(sdims) :: is_flattened
#endif

#ifdef GEOMETRY_CUBED_SPHERE
   type(vers), dimension(sdims) :: nn
#endif

 end type r_utils

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! MPI UTILS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 type mpigrid

    integer, dimension(3) :: i1,i2,coords_dd,bricks
    logical, dimension(3) :: periodic
    integer :: comm_cart,wsize,rankl,nx1l,nx2l,nx3l
    real(kind=rp) :: wctgi    
    real(kind=rp) :: dummy

 end type mpigrid
 
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! LOCAL GRID
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 type locgrid
    
    real(kind=rp) :: gm,mu,smax
   
    real(kind=rp), allocatable, dimension(:,:,:,:) :: prim

    real(kind=rp), allocatable, dimension(:,:) :: & 
#if sdims_make==3
    qLx3,qRx3,fx3, &
#endif
    qLx1,qRx1,fx1, &
    qLx2,qRx2,fx2

    real(kind=rp), allocatable, dimension(:,:,:,:) :: & 
    state,state0,res,coords,nodes

    real(kind=rp), allocatable, dimension(:,:,:) :: ivol

    real(kind=rp), allocatable, dimension(:,:,:) :: eint,temp

    real(kind=rp), allocatable, dimension(:,:,:,:) :: &
#if sdims_make==3
    coords_x3, &
#endif
    coords_x1, coords_x2

#ifdef GEOMETRY_2D_POLAR
    real(kind=rp), allocatable, dimension(:,:,:) :: r,r_x1,r_x2,r_cor
#ifdef USE_MHD
    real(kind=rp), allocatable, dimension(:,:,:) :: cm
#endif
#endif

#ifdef GEOMETRY_2D_SPHERICAL
    real(kind=rp), allocatable, dimension(:,:,:) :: &
    r,sin_theta,r_x1,r_x2,sin_theta_x2,sin_theta_cor,r_cor
    real(kind=rp), allocatable, dimension(:,:,:) :: cm,dm
#endif

#ifdef GEOMETRY_3D_SPHERICAL
    real(kind=rp), allocatable, dimension(:,:,:) :: &
    sin_theta_cor,r_cor,sin_theta,cos_theta,r,cot_theta,inv_r_sin_theta, &
    r_x1,inv_r_sin_theta_x1, &
    r_x2,sin_theta_x2,&
    r_x3,sin_theta_x3,inv_r_sin_theta_x3
    real(kind=rp), allocatable, dimension(:,:,:) :: cm,dm
#endif

#ifdef GEOMETRY_CUBED_SPHERE
    real(kind=rp), allocatable, dimension(:,:,:,:) :: &
#if sdims_make==3
    n_x3, &
#endif
    n_x1,n_x2
    real(kind=rp), allocatable, dimension(:,:,:) :: &
#if sdims_make==3
    A_x3, &
#endif
    A_x1,A_x2,r 
#endif

    real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u

    real(kind=rp) :: dx1,dx2,inv_dx1,inv_dx2
#if sdims_make==3
    real(kind=rp) :: dx3,inv_dx3
#endif

    real(kind=rp) :: dt,time,tnextoutput,tnextrestart

    integer :: step

    type(r_utils) :: ru

#ifdef USE_GRAVITY

    real(kind=rp), allocatable, dimension(:,:,:,:) :: grav

#if defined(EVOLVE_ETOT) || defined(USE_GRAVITY_SOLVER)
    real(kind=rp), allocatable, dimension(:,:,:) :: &
#if sdims_make==3
    phi_x3, &
#endif       
    phi_x1,phi_x2,phi_cc    
   
    real(kind=rp) :: gs_rho_bg
 
#endif

#ifdef USE_WB
    real(kind=rp), allocatable, dimension(:,:,:,:) :: & 
#if sdims_make==3
    eq_prim_x3, &
#endif
    eq_prim_cc,eq_prim_x1,eq_prim_x2
#ifdef USE_FASTEOS
    real(kind=rp), allocatable, dimension(:,:,:) :: & 
#if sdims_make==3
    eq_gammae_x3, &
#endif
    eq_gammae_cc,eq_gammae_x1,eq_gammae_x2
#endif
#endif

#ifdef USE_GRAVITY_SOLVER
    real(kind=rp), allocatable, dimension(:,:,:) :: &
    r0hat,rgs,v,t,p,s
#endif

#endif

#ifdef USE_EDOT
    real(kind=rp), allocatable, dimension(:,:,:) :: edot
#endif

#ifdef COROTATING_FRAME
    real(kind=rp), dimension(1:3) :: omega_rot
#endif

#ifdef USE_CONSTANT_ACCELERATION
    real(kind=rp), dimension(1:sdims) :: acc
#endif 

#if defined(THERMAL_DIFFUSION_STS) || defined(THERMAL_DIFFUSION_EXPLICIT)

    real(kind=rp), allocatable, dimension(:,:,:) :: kappa
    real(kind=rp), allocatable, dimension(:) :: &
#if sdims_make==3
    fe_x3, &
#endif 
    fe_x1,fe_x2

#endif

#ifdef THERMAL_DIFFUSION_STS

    real(kind=rp) :: dt_par
    real(kind=rp), allocatable, dimension(:,:,:) :: &
    e_0,e_1,e_jm2,e_jm1,Me_0,Me_jm1

#ifdef STS_EVOLVE_TEMP
    real(kind=rp), allocatable, dimension(:,:,:) :: icv
#endif

    real(kind=rp), dimension(1:sdims) :: Tl,Tu

#endif

#ifdef USE_MHD

    real(kind=rp), allocatable, dimension(:,:) :: & 
#if sdims_make==3
    bLx3,bRx3,fbx3, &
#endif
    bLx1,bRx1,fbx1, &
    bLx2,bRx2,fbx2

    real(kind=rp), allocatable, dimension(:,:,:,:) :: b_cc

    real(kind=rp), allocatable, dimension(:,:,:,:) :: &
#if sdims_make==3
    emf_x3, &
#endif
    emf_x1,emf_x2

    real(kind=rp), allocatable, dimension(:,:,:) :: &
#if sdims_make==3
    emfx1_cor,emfx2_cor,sign_frho_x3, &
#endif 
    emfx3_cor,sign_frho_x1,sign_frho_x2

    real(kind=rp), allocatable, dimension(:,:,:) :: &
#if sdims_make==3
    b_x3, &
#endif 
    b_x1,b_x2

    real(kind=rp), allocatable, dimension(:,:,:) :: &
#if sdims_make==3
    b0_x3, &
#endif
    b0_x1,b0_x2

#ifdef USE_RESISTIVITY
    real(kind=rp), allocatable, dimension(:,:,:) :: &
#if sdims_make==3
    eta_cor_x1,eta_cor_x2, &
#endif 
    eta_cor_x3,eta
#endif

#ifdef USE_INTERNAL_BOUNDARIES

    real(kind=rp), allocatable, dimension(:,:,:) :: &
#if sdims_make==3
    fac_x3, &
#endif 
    fac_x1,fac_x2

    integer, allocatable, dimension(:,:,:) :: &
#if sdims_make==3
    is_solid_cor_x1,is_solid_cor_x2, &
#endif 
    is_solid_cor_x3

    real(kind=rp), allocatable, dimension(:,:,:) :: &
#if sdims_make==3
    fac_cor_x1,fac_cor_x2, &
#endif 
    fac_cor_x3

#endif

#endif

#ifdef ADVECT_SPECIES
    real(kind=rp), dimension(1:nspecies) :: A,Z
    character(len=filename_size), dimension(1:nspecies) :: name_species
#endif

#ifdef USE_NUCLEAR_NETWORK
#ifdef PARTITION_FUNCTIONS_FOR_REVERSE_RATES
    real(kind=rp), allocatable, dimension(:,:) :: part
    real(kind=rp), dimension(1:24) :: temp_part
#endif   
#ifdef USE_LMP_WEAK_RATES
    real(kind=rp), allocatable, dimension(:,:,:) :: weak_table
    real(kind=rp), allocatable, dimension(:,:,:) :: weak_neu
    real(kind=rp), allocatable, dimension(:) :: neu_rates
#endif
    real(kind=rp), allocatable, dimension(:,:,:,:) :: edot_nuc
    real(kind=rp), allocatable, dimension(:,:,:,:) :: X_species_dot
    character(len=filename_size), dimension(1:nreacs) :: name_reacs
#ifdef SAVE_SPECIES_FLUXES
    real(kind=rp), allocatable, dimension(:,:,:,:,:) :: X_species_dot_reacs
#endif
#endif

#ifdef USE_POINT_PROBES
    integer, dimension(1:nprobes,1:3) :: pp_index
    logical, dimension(1:nprobes) :: pp_inside_domain
    real(kind=rp), dimension(1:nprobes,10000,i_rho:i_p+n_probe_vars) :: pp_state
#endif

#ifdef SAVE_PLANES
    integer, dimension(1:nplanes_x1) :: planes_x1_index
    integer, dimension(1:nplanes_x2) :: planes_x2_index
    integer, dimension(1:nplanes_x3) :: planes_x3_index
    logical, dimension(1:nplanes_x1) :: planes_x1_inside_domain
    logical, dimension(1:nplanes_x2) :: planes_x2_inside_domain
    logical, dimension(1:nplanes_x3) :: planes_x3_inside_domain
    integer :: planes_dstep_dump, planes_inextoutput 
#endif

#ifdef SAVE_SPHERICAL_PROJECTIONS
    real(kind=rp), dimension(1:nspj) :: spj_r
    integer :: spj_dstep_dump, spj_inextoutput
#endif

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
#ifdef USE_FASTEOS
    real(kind=rp), allocatable, dimension(:,:,:,:) :: gammaf
#endif
#endif

#ifdef USE_INTERNAL_BOUNDARIES
    integer, allocatable, dimension(:,:,:) :: is_solid
    real(kind=rp), allocatable, dimension(:,:,:) :: r
#endif

#ifdef USE_SHOCK_FLATTENING
    integer, allocatable, dimension(:,:,:) :: is_flattened
#endif

 end type locgrid
 
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! HDF5 SPECS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 type h5_file

  character(len=filename_size) :: filename
  
  integer(kind=HID_T) :: file_id,pref_dtypef,pref_dtypei

 end type h5_file

contains
 
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! INITIALIZE MPI AND ALLOCATION OF GRID QUANTITIES
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 subroutine initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)
    type(mpigrid), intent(inout) :: mgrid
    type(locgrid), intent(inout) :: lgrid
    real(kind=rp), intent(in) :: x1l,x1u,x2l,x2u,x3l,x3u
    real(kind=rp), intent(in) :: gamma_ad,mu

    integer :: ierr
    logical :: isinitialized,reorder
    integer :: lx1,ux1,lx2,ux2,lx3,ux3 

    mgrid%bricks(1) = ddx1
    mgrid%bricks(2) = ddx2
    mgrid%bricks(3) = ddx3

    mgrid%nx1l = int(nx1/ddx1)
    mgrid%nx2l = int(nx2/ddx2)
    mgrid%nx3l = int(nx3/ddx3)

#ifdef X1_PERIODIC
    mgrid%periodic(1) = .true.
#else
    mgrid%periodic(1) = .false.
#endif

#ifdef X2_PERIODIC
    mgrid%periodic(2) = .true.
#else
    mgrid%periodic(2) = .false.
#endif

#ifdef X3_PERIODIC
    mgrid%periodic(3) = .true. 
#else
    mgrid%periodic(3) = .false.
#endif

    call mpi_initialized(isinitialized, ierr)
    call mpi_init(ierr)

    reorder = .true.

    call mpi_cart_create(MPI_COMM_WORLD, sdims, mgrid%bricks, mgrid%periodic, reorder, mgrid%comm_cart, ierr)
    
    call mpi_comm_rank(mgrid%comm_cart,mgrid%rankl,ierr)
 
    call mpi_comm_size(mgrid%comm_cart,mgrid%wsize,ierr)
    
    mgrid%coords_dd(:) = 0

    call mpi_cart_coords(mgrid%comm_cart,mgrid%rankl,sdims,mgrid%coords_dd,ierr)
 
    call mpi_barrier(mgrid%comm_cart,ierr)
    mgrid%wctgi = get_wtime(mgrid)

    mgrid%i1(1) = int(mgrid%coords_dd(1)*mgrid%nx1l+1)
    mgrid%i2(1) = int((mgrid%coords_dd(1)+1)*mgrid%nx1l)

    mgrid%i1(2) = int(mgrid%coords_dd(2)*mgrid%nx2l+1)
    mgrid%i2(2) = int((mgrid%coords_dd(2)+1)*mgrid%nx2l)

    mgrid%i1(3) = int(mgrid%coords_dd(3)*mgrid%nx3l+1)
    mgrid%i2(3) = int((mgrid%coords_dd(3)+1)*mgrid%nx3l)

    lx1 = mgrid%i1(1)
    ux1 = mgrid%i2(1)
    lx2 = mgrid%i1(2)
    ux2 = mgrid%i2(2)
    lx3 = mgrid%i1(3)
    ux3 = mgrid%i2(3)

    allocate(lgrid%prim(1:nvars, & 
    lx1-ngc:ux1+ngc, &
    lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

    allocate(lgrid%eint(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

    allocate(lgrid%temp(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

    allocate(lgrid%qLx1(1:nvars,lx1:ux1+1))
    allocate(lgrid%qRx1(1:nvars,lx1:ux1+1))
    allocate(lgrid%fx1(1:nvars,lx1:ux1+1))

    allocate(lgrid%qLx2(1:nvars,lx2:ux2+1))
    allocate(lgrid%qRx2(1:nvars,lx2:ux2+1))
    allocate(lgrid%fx2(1:nvars,lx2:ux2+1))

#if sdims_make==3
    allocate(lgrid%qLx3(1:nvars,lx3:ux3+1))
    allocate(lgrid%qRx3(1:nvars,lx3:ux3+1))
    allocate(lgrid%fx3(1:nvars,lx3:ux3+1))
#endif

    allocate(lgrid%state(1:nvars,lx1:ux1,lx2:ux2,lx3:ux3))

    allocate(lgrid%state0(1:nvars,lx1:ux1,lx2:ux2,lx3:ux3))

#ifdef FIX_BFIELD_AT_X1
    allocate(lgrid%res(1:nvars,lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif
#else
    allocate(lgrid%res(1:nvars,lx1:ux1,lx2:ux2,lx3:ux3))
#endif

    allocate(lgrid%nodes(1:sdims,lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+1+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+1+ngc))
#endif

    allocate(lgrid%ivol(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

    allocate(lgrid%coords(1:sdims,lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

    allocate(lgrid%coords_x1(1:sdims,lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

    allocate(lgrid%coords_x2(1:sdims,lx1-ngc:ux1+ngc,lx2-ngc:ux2+1+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

#if sdims_make==3
    allocate(lgrid%coords_x3(1:sdims,lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3-ngc:ux3+1+ngc))
#endif

#ifdef GEOMETRY_2D_POLAR
    allocate(lgrid%r(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3:ux3))
    allocate(lgrid%r_x1(lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+ngc,lx3:ux3))
    allocate(lgrid%r_x2(lx1-ngc:ux1+ngc,lx2-ngc:ux2+1+ngc,lx3:ux3))
    allocate(lgrid%r_cor(lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+1+ngc,lx3:ux3))
#ifdef USE_MHD
    allocate(lgrid%cm(lx1:ux1,lx2:ux2,lx3:ux3))
#endif
#endif

#ifdef GEOMETRY_2D_SPHERICAL
    allocate(lgrid%r(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3:ux3))
    allocate(lgrid%sin_theta(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3:ux3))
    allocate(lgrid%r_x1(lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+ngc,lx3:ux3))
    allocate(lgrid%r_x2(lx1-ngc:ux1+ngc,lx2-ngc:ux2+1+ngc,lx3:ux3))
    allocate(lgrid%sin_theta_x2(lx1-ngc:ux1+ngc,lx2-ngc:ux2+1+ngc,lx3:ux3))
    allocate(lgrid%r_cor(lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+1+ngc,lx3:ux3))
    allocate(lgrid%sin_theta_cor(lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+1+ngc,lx3:ux3))
#ifdef USE_MHD
    allocate(lgrid%cm(lx1:ux1,lx2:ux2,lx3:ux3))
    allocate(lgrid%dm(lx1:ux1,lx2:ux2,lx3:ux3))
#endif
#endif

#ifdef GEOMETRY_3D_SPHERICAL
    allocate(lgrid%r_cor(lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+1+ngc,lx3-ngc:ux3+1+ngc))
    allocate(lgrid%sin_theta_cor(lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+1+ngc,lx3-ngc:ux3+1+ngc))
    allocate(lgrid%sin_theta(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3-ngc:ux3+ngc))
    allocate(lgrid%cos_theta(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3-ngc:ux3+ngc))
    allocate(lgrid%r(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3-ngc:ux3+ngc))
    allocate(lgrid%cot_theta(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3-ngc:ux3+ngc))
    allocate(lgrid%inv_r_sin_theta(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3-ngc:ux3+ngc))
    allocate(lgrid%r_x1(lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+ngc,lx3-ngc:ux3+ngc))
    allocate(lgrid%inv_r_sin_theta_x1(lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+ngc,lx3-ngc:ux3+ngc))
    allocate(lgrid%r_x2(lx1-ngc:ux1+ngc,lx2-ngc:ux2+1+ngc,lx3-ngc:ux3+ngc))
    allocate(lgrid%sin_theta_x2(lx1-ngc:ux1+ngc,lx2-ngc:ux2+1+ngc,lx3-ngc:ux3+ngc))
    allocate(lgrid%r_x3(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3-ngc:ux3+1+ngc))
    allocate(lgrid%sin_theta_x3(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3-ngc:ux3+1+ngc))
    allocate(lgrid%inv_r_sin_theta_x3(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3-ngc:ux3+1+ngc))
#ifdef USE_MHD
    allocate(lgrid%cm(lx1:ux1,lx2:ux2,lx3:ux3))
    allocate(lgrid%dm(lx1:ux1,lx2:ux2,lx3:ux3))
#endif
#endif

#ifdef GEOMETRY_CUBED_SPHERE

    allocate(lgrid%r(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

    allocate(lgrid%n_x1(1:sdims,lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

    allocate(lgrid%n_x2(1:sdims,lx1-ngc:ux1+ngc,lx2-ngc:ux2+1+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

#if sdims_make==3
    allocate(lgrid%n_x3(1:sdims,lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3-ngc:ux3+1+ngc))
#endif

    allocate(lgrid%A_x1(lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

    allocate(lgrid%A_x2(lx1-ngc:ux1+ngc,lx2-ngc:ux2+1+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

#if sdims_make==3
    allocate(lgrid%A_x3(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc,lx3-ngc:ux3+1+ngc))
#endif

#endif

#ifdef USE_GRAVITY

    allocate(lgrid%grav(1:sdims,lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

#if defined(EVOLVE_ETOT) || defined(USE_GRAVITY_SOLVER)

    allocate(lgrid%phi_cc(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

#ifdef FIX_BFIELD_AT_X1
    allocate(lgrid%phi_x1(lx1:ux1+1,lx2:ux2,lx3:ux3))

    allocate(lgrid%phi_x2(lx1-1:ux1+1,lx2:ux2+1,lx3:ux3))

#if sdims_make==3
    allocate(lgrid%phi_x3(lx1-1:ux1+1,lx2:ux2,lx3:ux3+1))
#endif
#else
    allocate(lgrid%phi_x1(lx1:ux1+1,lx2:ux2,lx3:ux3))

    allocate(lgrid%phi_x2(lx1:ux1,lx2:ux2+1,lx3:ux3))

#if sdims_make==3
    allocate(lgrid%phi_x3(lx1:ux1,lx2:ux2,lx3:ux3+1))
#endif
#endif

#endif

#ifdef USE_WB

    allocate(lgrid%eq_prim_cc(1:nvars_eq,lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif 

#ifdef FIX_BFIELD_AT_X1
    allocate(lgrid%eq_prim_x1(1:nvars_eq,lx1:ux1+1,lx2:ux2,lx3:ux3))

    allocate(lgrid%eq_prim_x2(1:nvars_eq,lx1-1:ux1+1,lx2:ux2+1,lx3:ux3))

#if sdims_make==3
    allocate(lgrid%eq_prim_x3(1:nvars_eq,lx1-1:ux1+1,lx2:ux2,lx3:ux3+1))
#endif
#else
    allocate(lgrid%eq_prim_x1(1:nvars_eq,lx1:ux1+1,lx2:ux2,lx3:ux3))

    allocate(lgrid%eq_prim_x2(1:nvars_eq,lx1:ux1,lx2:ux2+1,lx3:ux3))

#if sdims_make==3
    allocate(lgrid%eq_prim_x3(1:nvars_eq,lx1:ux1,lx2:ux2,lx3:ux3+1))
#endif
#endif

#ifdef USE_FASTEOS

    allocate(lgrid%eq_gammae_cc(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif 

#ifdef FIX_BFIELD_AT_X1
    allocate(lgrid%eq_gammae_x1(lx1:ux1+1,lx2:ux2,lx3:ux3))

    allocate(lgrid%eq_gammae_x2(lx1-1:ux1+1,lx2:ux2+1,lx3:ux3))

#if sdims_make==3
    allocate(lgrid%eq_gammae_x3(lx1-1:ux1+1,lx2:ux2,lx3:ux3+1))
#endif
#else
    allocate(lgrid%eq_gammae_x1(lx1:ux1+1,lx2:ux2,lx3:ux3))

    allocate(lgrid%eq_gammae_x2(lx1:ux1,lx2:ux2+1,lx3:ux3))

#if sdims_make==3
    allocate(lgrid%eq_gammae_x3(lx1:ux1,lx2:ux2,lx3:ux3+1))
#endif
#endif
#endif

#endif

#ifdef USE_GRAVITY_SOLVER
    allocate(lgrid%r0hat(lx1:ux1,lx2:ux2,lx3:ux3))
    allocate(lgrid%rgs(lx1:ux1,lx2:ux2,lx3:ux3))
    allocate(lgrid%v(lx1:ux1,lx2:ux2,lx3:ux3))
    allocate(lgrid%t(lx1:ux1,lx2:ux2,lx3:ux3))

    allocate(lgrid%p(lx1-1:ux1+1,lx2-1:ux2+1, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-1:ux3+1))
#endif 

    allocate(lgrid%s(lx1-1:ux1+1,lx2-1:ux2+1, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-1:ux3+1))
#endif 

#endif

#endif

#ifdef USE_EDOT
    allocate(lgrid%edot(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif
#endif

#if defined(THERMAL_DIFFUSION_STS) || defined(THERMAL_DIFFUSION_EXPLICIT)

    allocate(lgrid%kappa(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

    allocate(lgrid%fe_x1(lx1:ux1+1))
    allocate(lgrid%fe_x2(lx2:ux2+1))
#if sdims_make==3
    allocate(lgrid%fe_x3(lx3:ux3+1))
#endif
    
#endif

#ifdef THERMAL_DIFFUSION_STS

    allocate(lgrid%e_0(lx1:ux1,lx2:ux2,lx3:ux3))

    allocate(lgrid%e_1(lx1:ux1,lx2:ux2,lx3:ux3))

    allocate(lgrid%e_jm2(lx1:ux1,lx2:ux2,lx3:ux3))

    allocate(lgrid%e_jm1(lx1:ux1,lx2:ux2,lx3:ux3))

    allocate(lgrid%Me_0(lx1:ux1,lx2:ux2,lx3:ux3))

    allocate(lgrid%Me_jm1(lx1:ux1,lx2:ux2,lx3:ux3))

#ifdef STS_EVOLVE_TEMP
    allocate(lgrid%icv(lx1:ux1,lx2:ux2,lx3:ux3))
#endif

#endif

#ifdef USE_MHD

    allocate(lgrid%bLx1(1:sdims,lx1:ux1+1))
    allocate(lgrid%bRx1(1:sdims,lx1:ux1+1))
    allocate(lgrid%fbx1(1:sdims,lx1:ux1+1))

    allocate(lgrid%bLx2(1:sdims,lx2:ux2+1))
    allocate(lgrid%bRx2(1:sdims,lx2:ux2+1))
    allocate(lgrid%fbx2(1:sdims,lx2:ux2+1))

#if sdims_make==3
    allocate(lgrid%bLx3(1:sdims,lx3:ux3+1))
    allocate(lgrid%bRx3(1:sdims,lx3:ux3+1))
    allocate(lgrid%fbx3(1:sdims,lx3:ux3+1))
#endif

    allocate(lgrid%b_cc(1:sdims,lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif
   
    allocate(lgrid%emf_x1(1:3,lx1-1:ux1+2,lx2-1:ux2+1, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-1:ux3+1))
#endif
    
    allocate(lgrid%emf_x2(1:3,lx1-1:ux1+1,lx2-1:ux2+2, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-1:ux3+1))
#endif

#if sdims_make==3
    allocate(lgrid%emf_x3(1:3,lx1-1:ux1+1,lx2-1:ux2+1,lx3-1:ux3+2)) 
#endif

    allocate(lgrid%sign_frho_x1(lx1-1:ux1+2,lx2-1:ux2+1, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-1:ux3+1))
#endif

    allocate(lgrid%sign_frho_x2(lx1-1:ux1+1,lx2-1:ux2+2, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-1:ux3+1))
#endif

#if sdims_make==3
    allocate(lgrid%sign_frho_x3(lx1-1:ux1+1,lx2-1:ux2+1,lx3-1:ux3+2))
#endif

    allocate(lgrid%emfx3_cor(lx1:ux1+1,lx2:ux2+1,lx3:ux3))
#if sdims_make==3
    allocate(lgrid%emfx1_cor(lx1:ux1,lx2:ux2+1,lx3:ux3+1)) 
    allocate(lgrid%emfx2_cor(lx1:ux1+1,lx2:ux2,lx3:ux3+1)) 
#endif

    allocate(lgrid%b_x1(lx1-1:ux1+2,lx2-1:ux2+1, &
#if sdims_make==3
    lx3-1:ux3+1))
#else
    lx3:ux3))
#endif

    allocate(lgrid%b_x2(lx1-1:ux1+1,lx2-1:ux2+2, &
#if sdims_make==3
    lx3-1:ux3+1))
#else
    lx3:ux3))
#endif

#if sdims_make==3
    allocate(lgrid%b_x3(lx1-1:ux1+1,lx2-1:ux2+1,lx3-1:ux3+2))
#endif

    allocate(lgrid%b0_x1(lx1:ux1+1,lx2:ux2,lx3:ux3))
    allocate(lgrid%b0_x2(lx1:ux1,lx2:ux2+1,lx3:ux3))
#if sdims_make==3
    allocate(lgrid%b0_x3(lx1:ux1,lx2:ux2,lx3:ux3+1))
#endif

#ifdef USE_RESISTIVITY
#if sdims_make==3
    allocate(lgrid%eta_cor_x1(lx1:ux1,lx2:ux2+1,lx3:ux3+1)) 
    allocate(lgrid%eta_cor_x2(lx1:ux1+1,lx2:ux2,lx3:ux3+1)) 
#endif
    allocate(lgrid%eta_cor_x3(lx1:ux1+1,lx2:ux2+1,lx3:ux3))

    allocate(lgrid%eta(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif
#endif

#ifdef USE_INTERNAL_BOUNDARIES

    allocate(lgrid%fac_x1(lx1:ux1+1,lx2:ux2,lx3:ux3))
    allocate(lgrid%fac_x2(lx1:ux1,lx2:ux2+1,lx3:ux3))
#if sdims_make==3
    allocate(lgrid%fac_x3(lx1:ux1,lx2:ux2,lx3:ux3+1))
#endif

#if sdims_make==3
    allocate(lgrid%is_solid_cor_x1(lx1:ux1,lx2-1:ux2+2,lx3-1:ux3+2)) 
    allocate(lgrid%is_solid_cor_x2(lx1-1:ux1+2,lx2:ux2,lx3-1:ux3+2)) 
#endif
    allocate(lgrid%is_solid_cor_x3(lx1-1:ux1+2,lx2-1:ux2+2,lx3:ux3))

    allocate(lgrid%fac_cor_x3(lx1:ux1+1,lx2:ux2+1,lx3:ux3))
#if sdims_make==3
    allocate(lgrid%fac_cor_x1(lx1:ux1,lx2:ux2+1,lx3:ux3+1)) 
    allocate(lgrid%fac_cor_x2(lx1:ux1+1,lx2:ux2,lx3:ux3+1)) 
#endif

#endif

#endif

#ifdef USE_NUCLEAR_NETWORK
#ifdef USE_NEULOSS
    allocate(lgrid%edot_nuc(1:nreacs+1,lx1:ux1,lx2:ux2,lx3:ux3))
#else
    allocate(lgrid%edot_nuc(1:nreacs,lx1:ux1,lx2:ux2,lx3:ux3))
#endif   
    allocate(lgrid%X_species_dot(1:nspecies,lx1:ux1,lx2:ux2,lx3:ux3))
#ifdef SAVE_SPECIES_FLUXES
    allocate(lgrid%X_species_dot_reacs(1:nspecies,1:nreacs,lx1:ux1,lx2:ux2,lx3:ux3))
#endif
    call extract_network_information(lgrid)
#endif

#ifdef USE_SHOCK_FLATTENING
    allocate(lgrid%is_flattened(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif
#endif

    lgrid%x1l = x1l
    lgrid%x1u = x1u

    lgrid%x2l = x2l
    lgrid%x2u = x2u

    lgrid%x3l = x3l
    lgrid%x3u = x3u

    lgrid%dx1 = (lgrid%x1u - lgrid%x1l) / real(nx1,kind=rp)
    lgrid%dx2 = (lgrid%x2u - lgrid%x2l) / real(nx2,kind=rp)
#if sdims_make==3
    lgrid%dx3 = (lgrid%x3u - lgrid%x3l) / real(nx3,kind=rp)
#endif

    lgrid%inv_dx1 = rp1/lgrid%dx1
    lgrid%inv_dx2 = rp1/lgrid%dx2
#if sdims_make==3
    lgrid%inv_dx3 = rp1/lgrid%dx3
#endif

#ifdef USE_INTERNAL_BOUNDARIES

    allocate(lgrid%r(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

#endif

    call create_geometry(lgrid,mgrid)

    lgrid%time = rp0
    lgrid%step = 0
    lgrid%tnextoutput = rp0
    lgrid%tnextrestart = dt_restart 

    lgrid%gm = gamma_ad
    lgrid%mu = mu

    lgrid%ru%gm = gamma_ad
    lgrid%ru%mu = mu

#ifdef GEOMETRY_CUBED_SPHERE
    allocate(lgrid%ru%nn(1)%val(1:sdims,lx1:ux1+1))
    allocate(lgrid%ru%nn(2)%val(1:sdims,lx2:ux2+1))
#if sdims_make==3
    allocate(lgrid%ru%nn(3)%val(1:sdims,lx3:ux3+1))
#endif
#endif

    allocate(lgrid%ru%pn(1)%val(lx1:ux1+1))
    allocate(lgrid%ru%pn(2)%val(lx2:ux2+1))
#if sdims_make==3
    allocate(lgrid%ru%pn(3)%val(lx3:ux3+1))
#endif

#ifdef ADVECT_SPECIES

    do ierr=1,nspecies
     lgrid%ru%A(ierr) = lgrid%A(ierr) 
     lgrid%ru%Z(ierr) = lgrid%Z(ierr)
    end do

#endif

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)

#ifdef USE_FASTEOS
    allocate(lgrid%gammaf(1:2,lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

    allocate(lgrid%ru%gammafL(1)%val(1:2,lx1:ux1+1))
    allocate(lgrid%ru%gammafR(1)%val(1:2,lx1:ux1+1))
    allocate(lgrid%ru%gammafL(2)%val(1:2,lx2:ux2+1))
    allocate(lgrid%ru%gammafR(2)%val(1:2,lx2:ux2+1))
#if sdims_make==3
    allocate(lgrid%ru%gammafL(3)%val(1:2,lx3:ux3+1))
    allocate(lgrid%ru%gammafR(3)%val(1:2,lx3:ux3+1))
#endif
#endif

#endif

#ifdef HELMHOLTZ_EOS
#ifdef USE_TIMMES_KAPPA
    call load_helm_table(helm_table_var,dpdrho_table_var,eta_table,xf_table,helm_rho,helm_T,helm_drho,helm_dT)
#else
    call load_helm_table(helm_table_var,dpdrho_table_var,helm_rho,helm_T,helm_drho,helm_dT)
#endif
#endif

#ifdef PIG_EOS
    call load_pig_table(pig_table_var,dpdrho_table_var,pig_rho,pig_T,pig_drho,pig_dT)
#endif

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
#ifndef USE_FASTEOS
    allocate(lgrid%ru%guess_temp(1)%val(lx1:ux1+1))
    allocate(lgrid%ru%guess_temp(2)%val(lx2:ux2+1))
#if sdims_make==3
    allocate(lgrid%ru%guess_temp(3)%val(lx3:ux3+1))
#endif
#endif
#endif

#ifdef USE_INTERNAL_BOUNDARIES 

    allocate(lgrid%is_solid(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3))
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc))
#endif

#endif

#ifdef SAVE_PLANES
    lgrid%planes_dstep_dump = 0
    lgrid%planes_inextoutput = 0
#endif

#ifdef SAVE_SPHERICAL_PROJECTIONS
    lgrid%spj_dstep_dump = 0
    lgrid%spj_inextoutput = 0
#endif

#ifdef USE_SHOCK_FLATTENING
    allocate(lgrid%ru%is_flattened(1)%val(lx1:ux1+1))
    allocate(lgrid%ru%is_flattened(2)%val(lx2:ux2+1))
#if sdims_make==3
    allocate(lgrid%ru%is_flattened(3)%val(lx3:ux3+1))
#endif
#endif

    call h5open_f(ierr)
 
 end subroutine initialize_simulation

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! GRID DESTRUCTION
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 subroutine finalize_simulation(lgrid)
    type(locgrid), intent(inout) :: lgrid

    integer :: ierr

    call h5close_f(ierr)

    call mpi_finalize(ierr)

    deallocate(lgrid%prim)
    deallocate(lgrid%eint)
    deallocate(lgrid%temp)

    deallocate(lgrid%qLx1)
    deallocate(lgrid%qRx1)
    deallocate(lgrid%fx1)
    
    deallocate(lgrid%qLx2)
    deallocate(lgrid%qRx2)
    deallocate(lgrid%fx2)

#if sdims_make==3
    deallocate(lgrid%qLx3)
    deallocate(lgrid%qRx3)
    deallocate(lgrid%fx3)
#endif

    deallocate(lgrid%state)
    deallocate(lgrid%state0)
    deallocate(lgrid%res)

#ifdef USE_EDOT
    deallocate(lgrid%edot)
#endif

#ifdef USE_GRAVITY

    deallocate(lgrid%grav)
#if defined(EVOLVE_ETOT) || defined(USE_GRAVITY_SOLVER)
    deallocate(lgrid%phi_cc)
    deallocate(lgrid%phi_x1)
    deallocate(lgrid%phi_x2)
#if sdims_make==3
    deallocate(lgrid%phi_x3)
#endif
#endif

#ifdef USE_WB
    deallocate(lgrid%eq_prim_cc)
    deallocate(lgrid%eq_prim_x1)
    deallocate(lgrid%eq_prim_x2)
#if sdims_make==3
    deallocate(lgrid%eq_prim_x3)
#endif
#ifdef USE_FASTEOS
    deallocate(lgrid%eq_gammae_cc)
    deallocate(lgrid%eq_gammae_x1)
    deallocate(lgrid%eq_gammae_x2)
#if sdims_make==3
    deallocate(lgrid%eq_gammae_x3)
#endif
#endif
#endif

#ifdef USE_GRAVITY_SOLVER
    deallocate(lgrid%r0hat)
    deallocate(lgrid%rgs)
    deallocate(lgrid%v)
    deallocate(lgrid%t)
    deallocate(lgrid%p)
    deallocate(lgrid%s)
#endif

#endif

    deallocate(lgrid%ivol)
    deallocate(lgrid%coords)
    deallocate(lgrid%nodes)
    deallocate(lgrid%coords_x1)
    deallocate(lgrid%coords_x2)
#if sdims_make==3
    deallocate(lgrid%coords_x3)
#endif 

#ifdef GEOMETRY_2D_POLAR
    deallocate(lgrid%r)
    deallocate(lgrid%r_x1)
    deallocate(lgrid%r_x2)
    deallocate(lgrid%r_cor)
#ifdef USE_MHD
    deallocate(lgrid%cm)
#endif
#endif

#ifdef GEOMETRY_2D_SPHERICAL
    deallocate(lgrid%r)
    deallocate(lgrid%sin_theta)
    deallocate(lgrid%r_x1)
    deallocate(lgrid%r_x2)
    deallocate(lgrid%sin_theta_x2)
    deallocate(lgrid%r_cor)
    deallocate(lgrid%sin_theta_cor)
#ifdef USE_MHD
    deallocate(lgrid%cm)
    deallocate(lgrid%dm)
#endif
#endif

#ifdef GEOMETRY_3D_SPHERICAL
    deallocate(lgrid%r_cor)
    deallocate(lgrid%sin_theta_cor)
    deallocate(lgrid%sin_theta)
    deallocate(lgrid%cos_theta)
    deallocate(lgrid%r)
    deallocate(lgrid%cot_theta)
    deallocate(lgrid%inv_r_sin_theta)
    deallocate(lgrid%r_x1)
    deallocate(lgrid%inv_r_sin_theta_x1)
    deallocate(lgrid%r_x2)
    deallocate(lgrid%sin_theta_x2)
    deallocate(lgrid%r_x3)
    deallocate(lgrid%sin_theta_x3)
    deallocate(lgrid%inv_r_sin_theta_x3)
#ifdef USE_MHD
    deallocate(lgrid%cm)
    deallocate(lgrid%dm)
#endif
#endif

#ifdef GEOMETRY_CUBED_SPHERE
    deallocate(lgrid%r)
    deallocate(lgrid%n_x1)
    deallocate(lgrid%n_x2)
    deallocate(lgrid%A_x1)
    deallocate(lgrid%A_x2)
#if sdims_make==3
    deallocate(lgrid%n_x3)
    deallocate(lgrid%A_x3)
#endif
#endif

#if defined(THERMAL_DIFFUSION_STS) || defined(THERMAL_DIFFUSION_EXPLICIT)
    deallocate(lgrid%kappa)
    deallocate(lgrid%fe_x1)
    deallocate(lgrid%fe_x2)
#if sdims_make==3
    deallocate(lgrid%fe_x3)
#endif
#endif

#ifdef THERMAL_DIFFUSION_STS
    deallocate(lgrid%e_0)
    deallocate(lgrid%e_1)
    deallocate(lgrid%e_jm2)
    deallocate(lgrid%e_jm1)
    deallocate(lgrid%Me_0)
    deallocate(lgrid%Me_jm1)

#ifdef STS_EVOLVE_TEMP
    deallocate(lgrid%icv)
#endif

#endif

#ifdef USE_MHD

    deallocate(lgrid%bLx1)
    deallocate(lgrid%bRx1)
    deallocate(lgrid%fbx1)
    
    deallocate(lgrid%bLx2)
    deallocate(lgrid%bRx2)
    deallocate(lgrid%fbx2)

#if sdims_make==3
    deallocate(lgrid%bLx3)
    deallocate(lgrid%bRx3)
    deallocate(lgrid%fbx3)
#endif

    deallocate(lgrid%b_cc)

    deallocate(lgrid%emf_x1)
    deallocate(lgrid%emf_x2)
#if sdims_make==3
    deallocate(lgrid%emf_x3)
#endif
    
    deallocate(lgrid%emfx3_cor)
    deallocate(lgrid%sign_frho_x1)
    deallocate(lgrid%sign_frho_x2)
#if sdims_make==3
    deallocate(lgrid%emfx1_cor)
    deallocate(lgrid%emfx2_cor)
    deallocate(lgrid%sign_frho_x3)
#endif 
    
    deallocate(lgrid%b_x1)
    deallocate(lgrid%b_x2)
#if sdims_make==3
    deallocate(lgrid%b_x3)
#endif 
 
    deallocate(lgrid%b0_x1)
    deallocate(lgrid%b0_x2)
#if sdims_make==3
    deallocate(lgrid%b0_x3)
#endif 

#ifdef USE_RESISTIVITY

#if sdims_make==3
    deallocate(lgrid%eta_cor_x1) 
    deallocate(lgrid%eta_cor_x2) 
    deallocate(lgrid%eta_cor_x3)
#else
    deallocate(lgrid%eta_cor_x3)
#endif

#endif

#ifdef USE_INTERNAL_BOUNDARIES

    deallocate(lgrid%fac_x1)
    deallocate(lgrid%fac_x2)
#if sdims_make==3
    deallocate(lgrid%fac_x3)
#endif

#if sdims_make==3
    deallocate(lgrid%is_solid_cor_x1) 
    deallocate(lgrid%is_solid_cor_x2) 
    deallocate(lgrid%is_solid_cor_x3)
#else
    deallocate(lgrid%is_solid_cor_x3)
#endif

    deallocate(lgrid%fac_cor_x3)
#if sdims_make==3
    deallocate(lgrid%fac_cor_x1) 
    deallocate(lgrid%fac_cor_x2) 
#endif

#endif

#endif

#ifdef USE_NUCLEAR_NETWORK
    deallocate(lgrid%edot_nuc)
    deallocate(lgrid%X_species_dot)
#ifdef PARTITION_FUNCTIONS_FOR_REVERSE_RATES
    deallocate(lgrid%part)
#endif
#ifdef USE_LMP_WEAK_RATES
    deallocate(lgrid%weak_table)
    deallocate(lgrid%weak_neu)
    deallocate(lgrid%neu_rates)
#endif
#ifdef SAVE_SPECIES_FLUXES
    deallocate(lgrid%X_species_dot_reacs)
#endif
#endif

#ifdef USE_SHOCK_FLATTENING
    deallocate(lgrid%is_flattened)
    do ierr=1,sdims
     deallocate(lgrid%ru%is_flattened(ierr)%val)
    end do
#endif

#ifdef GEOMETRY_CUBED_SPHERE
    do ierr=1,sdims
     deallocate(lgrid%ru%nn(ierr)%val)
    end do
#endif

    do ierr=1,sdims
     deallocate(lgrid%ru%pn(ierr)%val)
    end do

#if defined(USE_PRAD) || defined(HELMHOLTZ_EOS) || defined(PIG_EOS)

#ifndef USE_FASTEOS

    do ierr=1,sdims
     deallocate(lgrid%ru%guess_temp(ierr)%val)
    end do

#else

     deallocate(lgrid%gammaf)


     deallocate(lgrid%ru%gammafL(1)%val)
     deallocate(lgrid%ru%gammafR(1)%val)
     deallocate(lgrid%ru%gammafL(2)%val)
     deallocate(lgrid%ru%gammafR(2)%val)
#if sdims_make==3
     deallocate(lgrid%ru%gammafL(3)%val)
     deallocate(lgrid%ru%gammafR(3)%val)
#endif

#endif

#endif

#ifdef USE_INTERNAL_BOUNDARIES
     deallocate(lgrid%is_solid)
     deallocate(lgrid%r)
#endif

 end subroutine finalize_simulation

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! COMMUNICATION SUBROUTINES
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 subroutine communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3,gst,vec,communicate_corners)
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: lx1,ux1,lx2,ux2,lx3,ux3,gst
    real(kind=rp), intent(inout) :: vec( &
    lx1-gst:ux1+gst, &
    lx2-gst:ux2+gst, &
#if sdims_make==2
    lx3:ux3)
#endif
#if sdims_make==3
    lx3-gst:ux3+gst)
#endif
    logical, intent(in) :: communicate_corners

    integer, dimension(3) :: sizes,subsizes,rstarts,sstarts
    integer :: ghost,is,prev_mpi,next_mpi,prev,next,ierror,itmp
    integer :: edge,i,j,k,iv
    integer, dimension(3) :: i1,i2,ri1,ri2,si1,si2
    integer :: sendtype,recvtype

    if(communicate_corners) then
      ghost = gst
    else
      ghost = 0
    endif

    do is=1,sdims

     if ((.not.mgrid%periodic(is)).and.(mgrid%bricks(is)==1)) cycle

     call mpi_cart_shift(mgrid%comm_cart,int(is-1),1,prev_mpi,next_mpi,ierror)
     prev = prev_mpi
     next = next_mpi

     if ((.not.mgrid%periodic(is)).and.(mgrid%coords_dd(is)==mgrid%bricks(is)-1)) &
       next = MPI_PROC_NULL
     if ((.not.mgrid%periodic(is)).and.(mgrid%coords_dd(is)==0)) &
       prev = MPI_PROC_NULL

     i1(1) = lx1
     i1(2) = lx2
     i1(3) = lx3

     i2(1) = ux1
     i2(2) = ux2
     i2(3) = ux3

     do iv=1,3
      si1(iv) = i1(iv)
      si2(iv) = i2(iv)
     end do

     do i=1,sdims
      si1(i) = si1(i) - ghost
      si2(i) = si2(i) + ghost
     end do

     do iv=1,3
      ri1(iv) = si1(iv)
      ri2(iv) = si2(iv)
     end do

     si1(is) = i2(is)-gst+1
     si2(is) = i2(is)

     ri1(is) = i1(is)-gst
     ri2(is) = i1(is)-1

     do edge=1,2

      if ((mgrid%periodic(is)).and.(mgrid%bricks(is)==1)) then

       do k=si1(3),si2(3)
        do j=si1(2),si2(2)
         do i=si1(1),si2(1)

           vec( &
           i-si1(1)+ri1(1), &
           j-si1(2)+ri1(2), &
           k-si1(3)+ri1(3)) = vec(i,j,k)

         end do
        end do
       end do

      else

       sizes(:) = ubound(vec)-lbound(vec)+1

       do iv=1,3
        subsizes(iv) = sizes(iv)
       end do

       subsizes(1:sdims) = subsizes(1:sdims)-2*(gst-ghost)
       subsizes(is) = gst

       sstarts(1) = si1(1)-lbound(vec,1)
       sstarts(2) = si1(2)-lbound(vec,2)
       sstarts(3) = si1(3)-lbound(vec,3)

       rstarts(1) = ri1(1)-lbound(vec,1)
       rstarts(2) = ri1(2)-lbound(vec,2)
       rstarts(3) = ri1(3)-lbound(vec,3)

       call mpi_type_create_subarray(3,sizes,subsizes,sstarts,&
       MPI_ORDER_FORTRAN,MPI_RP,sendtype,ierror)
       call mpi_type_create_subarray(3,sizes,subsizes,rstarts,&
       MPI_ORDER_FORTRAN,MPI_RP,recvtype,ierror)

       call mpi_type_commit(sendtype,ierror)
       call mpi_type_commit(recvtype,ierror)

       call mpi_sendrecv( &
       vec,1,sendtype,next,0, &
       vec,1,recvtype,prev,0, &
       mgrid%comm_cart,MPI_STATUS_IGNORE,ierror)

       call mpi_type_free(sendtype,ierror)
       call mpi_type_free(recvtype,ierror)

      endif

      si1(is) = i1(is)
      si2(is) = i1(is)+gst-1

      ri1(is) = i2(is)+1
      ri2(is) = i2(is)+gst

      itmp = next
      next = prev
      prev = itmp

     end do

    end do

 end subroutine communicate_array

 subroutine communicate_ndarray(mgrid,nv,lx1,ux1,lx2,ux2,lx3,ux3,gst,vec,communicate_corners)
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: nv,lx1,ux1,lx2,ux2,lx3,ux3,gst
    real(kind=rp), intent(inout) :: vec(1:nv, &
    lx1-gst:ux1+gst, &
    lx2-gst:ux2+gst, &
#if sdims_make==2
    lx3:ux3)
#endif
#if sdims_make==3
    lx3-gst:ux3+gst)
#endif
    logical, intent(in) :: communicate_corners

    integer, dimension(4) :: sizes,subsizes,rstarts,sstarts
    integer :: ghost,is,prev_mpi,next_mpi,prev,next,ierror,itmp
    integer :: edge,iv,i,j,k
    integer, dimension(3) :: i1,i2,ri1,ri2,si1,si2
    integer :: sendtype,recvtype

    if(communicate_corners) then
      ghost = gst
    else
      ghost = 0
    endif

    do is=1,sdims

     if ((.not.mgrid%periodic(is)).and.(mgrid%bricks(is)==1)) cycle

     call mpi_cart_shift(mgrid%comm_cart,int(is-1),1,prev_mpi,next_mpi,ierror)
     prev = prev_mpi
     next = next_mpi

     if ((.not.mgrid%periodic(is)).and.(mgrid%coords_dd(is)==mgrid%bricks(is)-1)) &
       next = MPI_PROC_NULL
     if ((.not.mgrid%periodic(is)).and.(mgrid%coords_dd(is)==0)) &
       prev = MPI_PROC_NULL

     i1(1) = lx1
     i1(2) = lx2
     i1(3) = lx3

     i2(1) = ux1
     i2(2) = ux2
     i2(3) = ux3

     do iv=1,3
      si1(iv) = i1(iv)
      si2(iv) = i2(iv)
     end do

     do i=1,sdims
      si1(i) = si1(i) - ghost
      si2(i) = si2(i) + ghost
     end do

     do iv=1,3
      ri1(iv) = si1(iv)
      ri2(iv) = si2(iv)
     end do

     si1(is) = i2(is)-gst+1
     si2(is) = i2(is)

     ri1(is) = i1(is)-gst
     ri2(is) = i1(is)-1

     do edge=1,2

      if ((mgrid%periodic(is)).and.(mgrid%bricks(is)==1)) then

       do k=si1(3),si2(3)
        do j=si1(2),si2(2)
         do i=si1(1),si2(1)

          do iv=1,nv
           vec(iv, &
           i-si1(1)+ri1(1), &
           j-si1(2)+ri1(2), &
           k-si1(3)+ri1(3)) = vec(iv,i,j,k)
          end do

         end do
        end do
       end do

      else

       sizes(:) = ubound(vec)-lbound(vec)+1

       do iv=1,4
        subsizes(iv) = sizes(iv)
       end do

       subsizes(2:sdims+1) = subsizes(2:sdims+1)-2*(gst-ghost)
       subsizes(is+1) = gst

       sstarts(1) = 0
       sstarts(2) = si1(1)-lbound(vec,2)
       sstarts(3) = si1(2)-lbound(vec,3)
       sstarts(4) = si1(3)-lbound(vec,4)

       rstarts(1) = 0
       rstarts(2) = ri1(1)-lbound(vec,2)
       rstarts(3) = ri1(2)-lbound(vec,3)
       rstarts(4) = ri1(3)-lbound(vec,4)

       call mpi_type_create_subarray(4,sizes,subsizes,sstarts,&
       MPI_ORDER_FORTRAN,MPI_RP,sendtype,ierror)
       call mpi_type_create_subarray(4,sizes,subsizes,rstarts,&
       MPI_ORDER_FORTRAN,MPI_RP,recvtype,ierror)

       call mpi_type_commit(sendtype,ierror)
       call mpi_type_commit(recvtype,ierror)

       call mpi_sendrecv( &
       vec,1,sendtype,next,0, &
       vec,1,recvtype,prev,0, &
       mgrid%comm_cart,MPI_STATUS_IGNORE,ierror)

       call mpi_type_free(sendtype,ierror)
       call mpi_type_free(recvtype,ierror)

      endif

      si1(is) = i1(is)
      si2(is) = i1(is)+gst-1

      ri1(is) = i2(is)+1
      ri2(is) = i2(is)+gst

      itmp = next
      next = prev
      prev = itmp

     end do

    end do

 end subroutine communicate_ndarray
 
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! I/O
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 subroutine write_restart(mgrid,lgrid)
    type(mpigrid), intent(in) :: mgrid
    type(locgrid), intent(inout) :: lgrid

    type(h5_file) :: h5

    integer :: error
    integer(HID_T) :: id,plist_id
    
    write(h5%filename, "('restart_n',I0.5,'.h5')") lgrid%step

    call h5pcreate_f(H5P_FILE_ACCESS_F,plist_id,error)

    call h5pset_fapl_mpio_f(plist_id,mgrid%comm_cart,MPI_INFO_NULL,error)

    call h5fcreate_f(h5%filename,H5F_ACC_TRUNC_F,h5%file_id,error,H5P_DEFAULT_F,plist_id)
  
    call h5pclose_f(plist_id,error)

#ifdef USE_SINGLE_PRECISION 
#ifdef LITTLE_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F32LE
#endif
#ifdef BIG_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F32BE
#endif
#endif

#ifdef USE_DOUBLE_PRECISION
#ifdef LITTLE_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F64LE
#endif
#ifdef BIG_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F64BE
#endif
#endif

#ifdef LITTLE_ENDIAN
    h5%pref_dtypei = H5T_STD_I32LE
#endif
#ifdef BIG_ENDIAN
    h5%pref_dtypei = H5T_STD_I32BE
#endif

    call h5gcreate_f(h5%file_id,"grid",id,error)
    call hdf5_annotate_rp(h5,id,"time",lgrid%time)
    call hdf5_annotate_rp(h5,id,"dt",lgrid%dt)
    call hdf5_annotate_rp(h5,id,"smax",lgrid%smax)
    call hdf5_annotate_ip(h5,id,"step",lgrid%step)

#ifdef THERMAL_DIFFUSION_STS
    call hdf5_annotate_rp(h5,id,"dt_par",lgrid%dt_par)
#endif

#ifdef OUTPUT_DT
    call hdf5_annotate_rp(h5,id,"tnextoutput",lgrid%tnextoutput)
#endif

#ifdef SAVE_PLANES
    call hdf5_annotate_ip(h5,id,"planes_inextoutput",lgrid%planes_inextoutput)
    call hdf5_annotate_ip(h5,id,"planes_dstep_dump",lgrid%planes_dstep_dump)
#endif

#ifdef SAVE_SPHERICAL_PROJECTIONS
    call hdf5_annotate_ip(h5,id,"spj_inextoutput",lgrid%spj_inextoutput)
    call hdf5_annotate_ip(h5,id,"spj_dstep_dump",lgrid%spj_dstep_dump)
#endif

    call hdf5_write_ndarray(h5,id,"prim",mgrid,nvars,&
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,.false.,.false.,lgrid%ivol,lgrid%prim)

#ifdef USE_MHD
    call hdf5_write_array(h5,id,"b_x1",mgrid,&
    mgrid%i1(1),mgrid%i2(1)+1,mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),1,.false.,.false.,lgrid%ivol,lgrid%b_x1)

    call hdf5_write_array(h5,id,"b_x2",mgrid,&
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2)+1,mgrid%i1(3),mgrid%i2(3),1,.false.,.false.,lgrid%ivol,lgrid%b_x2)

#if sdims_make==3
    call hdf5_write_array(h5,id,"b_x3",mgrid,&
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3)+1,1,.false.,.false.,lgrid%ivol,lgrid%b_x3)
#endif
#endif

#ifdef USE_GRAVITY
#ifdef USE_GRAVITY_SOLVER
    call hdf5_write_array(h5,id,"phi_cc",mgrid,&
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,.false.,.false.,lgrid%ivol,lgrid%phi_cc)

    call hdf5_write_ndarray(h5,id,"grav",mgrid,sdims,&
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,.false.,.false.,lgrid%ivol,lgrid%grav)
#endif
#ifdef USE_MONOPOLE_GRAVITY
    call hdf5_write_ndarray(h5,id,"grav",mgrid,sdims,&
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,.false.,.false.,lgrid%ivol,lgrid%grav)
#endif
#endif

    call hdf5_write_array(h5,id,"temp",mgrid,&
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,.false.,.false.,lgrid%ivol,lgrid%temp)

    call h5gclose_f(id, error)
    call h5fclose_f(h5%file_id, error)

 end subroutine write_restart

 subroutine read_ip(h5,group_id,dsetname,var)
    type(h5_file),intent(in) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*), intent(in) :: dsetname
    integer, intent(inout) :: var

    integer(kind=HSIZE_T),dimension(1) :: dims
    integer :: error
    integer(HID_T) :: dataset_id

    call h5dopen_f(group_id,dsetname,dataset_id,error)

    call h5dread_f(dataset_id,h5%pref_dtypei,var,dims,error)

    call h5dclose_f(dataset_id,error)

 end subroutine read_ip
   
 subroutine read_rp(h5,group_id,dsetname,var)
    type(h5_file),intent(in) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*), intent(in) :: dsetname
    real(kind=rp), intent(inout) :: var

    integer(kind=HSIZE_T),dimension(1) :: dims
    integer :: error
    integer(HID_T) :: dataset_id

    call h5dopen_f(group_id,dsetname,dataset_id,error) 
 
    call h5dread_f(dataset_id,h5%pref_dtypef,var,dims,error)

    call h5dclose_f(dataset_id,error)

 end subroutine read_rp

 subroutine read_array(h5,group_id,dsetname,mgrid,lx1,ux1,lx2,ux2,lx3,ux3,ghost,vec)
    type(h5_file),intent(in) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*), intent(in) :: dsetname
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: lx1,ux1,lx2,ux2,lx3,ux3,ghost
    real(kind=rp), dimension( &
    lx1-ghost:ux1+ghost, &
    lx2-ghost:ux2+ghost, &
#if sdims_make==2
    lx3:ux3), intent(inout) :: vec
#endif
#if sdims_make==3
    lx3-ghost:ux3+ghost), intent(inout) :: vec
#endif

    integer :: error
    integer(HID_T) :: dataset_id,dataspace_id,memspace_id
    
    integer(HID_T) :: start(3),cnt(3),dims(3)

    call h5dopen_f(group_id,dsetname,dataset_id,error) 

    call h5dget_space_f(dataset_id,dataspace_id,error)

    dims(1) = ux1-lx1+1
    dims(2) = ux2-lx2+1
    dims(3) = ux3-lx3+1

    cnt(1) = ux1-lx1+1
    cnt(2) = ux2-lx2+1
    cnt(3) = ux3-lx3+1

    start(1) = cnt(1)*mgrid%coords_dd(1)
    start(2) = cnt(2)*mgrid%coords_dd(2)
    start(3) = cnt(3)*mgrid%coords_dd(3)

    call h5sselect_hyperslab_f(dataspace_id,H5S_SELECT_SET_F,start,cnt,error)

    call h5screate_simple_f(3,dims,memspace_id,error)

    call h5dread_f(dataset_id,h5%pref_dtypef, &
    vec( &
    lx1:ux1, &
    lx2:ux2, &
    lx3:ux3), &
    dims,error,memspace_id,dataspace_id)

    call h5dclose_f(dataset_id, error)

 end subroutine read_array

 subroutine read_ndarray(h5,group_id,dsetname,mgrid,nv,lx1,ux1,lx2,ux2,lx3,ux3,ghost,vec)
    type(h5_file),intent(in) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*), intent(in) :: dsetname
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: nv,lx1,ux1,lx2,ux2,lx3,ux3,ghost
    real(kind=rp), dimension(1:nv, &
    lx1-ghost:ux1+ghost, &
    lx2-ghost:ux2+ghost, &
#if sdims_make==2
    lx3:ux3), intent(inout) :: vec
#endif
#if sdims_make==3
    lx3-ghost:ux3+ghost), intent(inout) :: vec
#endif

    integer :: error
    integer(HID_T) :: dataset_id,dataspace_id,memspace_id
    
    integer(HID_T) :: start(4),cnt(4),dims(4)

    call h5dopen_f(group_id,dsetname,dataset_id,error) 

    call h5dget_space_f(dataset_id,dataspace_id,error)

    dims(1) = nv
    dims(2) = ux1-lx1+1
    dims(3) = ux2-lx2+1
    dims(4) = ux3-lx3+1

    cnt(1) = nv
    cnt(2) = ux1-lx1+1
    cnt(3) = ux2-lx2+1
    cnt(4) = ux3-lx3+1

    start(1) = 0
    start(2) = cnt(2)*mgrid%coords_dd(1)
    start(3) = cnt(3)*mgrid%coords_dd(2)
    start(4) = cnt(4)*mgrid%coords_dd(3)

    call h5sselect_hyperslab_f(dataspace_id,H5S_SELECT_SET_F,start,cnt,error)

    call h5screate_simple_f(4,dims,memspace_id,error)

    call h5dread_f(dataset_id,h5%pref_dtypef, &
    vec(1:nv, &
    lx1:ux1, &
    lx2:ux2, &
    lx3:ux3), &
    dims,error,memspace_id,dataspace_id)

    call h5dclose_f(dataset_id,error)

 end subroutine read_ndarray

 subroutine read_restart(mgrid,lgrid)
    type(mpigrid), intent(in) :: mgrid
    type(locgrid), intent(inout) :: lgrid

    type(h5_file) :: h5

    integer :: error
    integer(HID_T) :: file_id,group_id
    
    write(h5%filename, "('restart_n',I0.5,'.h5')") lgrid%step

#ifdef USE_SINGLE_PRECISION 
#ifdef LITTLE_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F32LE
#endif
#ifdef BIG_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F32BE
#endif
#endif

#ifdef USE_DOUBLE_PRECISION
#ifdef LITTLE_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F64LE
#endif
#ifdef BIG_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F64BE
#endif
#endif

#ifdef LITTLE_ENDIAN
    h5%pref_dtypei = H5T_STD_I32LE
#endif
#ifdef BIG_ENDIAN
    h5%pref_dtypei = H5T_STD_I32BE
#endif

    call h5fopen_f(h5%filename,H5F_ACC_RDONLY_F,file_id,error)

    call h5gopen_f(file_id,"grid",group_id,error)

    call  read_ndarray(h5,group_id,'prim',mgrid,nvars,&
    mgrid%i1(1),mgrid%i2(1),&
    mgrid%i1(2),mgrid%i2(2),&
    mgrid%i1(3),mgrid%i2(3),&
    ngc,lgrid%prim)

#ifdef USE_MHD

    call  read_array(h5,group_id,"b_x1",mgrid,&
    mgrid%i1(1),mgrid%i2(1)+1,&
    mgrid%i1(2),mgrid%i2(2),&
    mgrid%i1(3),mgrid%i2(3),&
    1,lgrid%b_x1)

    call  read_array(h5,group_id,"b_x2",mgrid,&
    mgrid%i1(1),mgrid%i2(1),&
    mgrid%i1(2),mgrid%i2(2)+1,&
    mgrid%i1(3),mgrid%i2(3),&
    1,lgrid%b_x2)

#if sdims_make==3
    call  read_array(h5,group_id,"b_x3",mgrid,&
    mgrid%i1(1),mgrid%i2(1),&
    mgrid%i1(2),mgrid%i2(2),&
    mgrid%i1(3),mgrid%i2(3)+1,&
    1,lgrid%b_x3)
#endif

#endif

#ifdef USE_GRAVITY
#ifdef USE_GRAVITY_SOLVER

    call  read_array(h5,group_id,"phi_cc",mgrid,&
    mgrid%i1(1),mgrid%i2(1),&
    mgrid%i1(2),mgrid%i2(2),&
    mgrid%i1(3),mgrid%i2(3),&
    ngc,lgrid%phi_cc)

    call  read_ndarray(h5,group_id,"grav",mgrid,nvars,&
    mgrid%i1(1),mgrid%i2(1),&
    mgrid%i1(2),mgrid%i2(2),&
    mgrid%i1(3),mgrid%i2(3),&
    ngc,lgrid%grav)

#endif
#ifdef USE_MONOPOLE_GRAVITY

    call  read_ndarray(h5,group_id,"grav",mgrid,nvars,&
    mgrid%i1(1),mgrid%i2(1),&
    mgrid%i1(2),mgrid%i2(2),&
    mgrid%i1(3),mgrid%i2(3),&
    ngc,lgrid%grav)

#endif
#endif

    call  read_array(h5,group_id,"temp",mgrid,&
    mgrid%i1(1),mgrid%i2(1),&
    mgrid%i1(2),mgrid%i2(2),&
    mgrid%i1(3),mgrid%i2(3),&
    ngc,lgrid%temp)

    call read_rp(h5,group_id,"time",lgrid%time)

    call read_rp(h5,group_id,"dt",lgrid%dt)

    call read_rp(h5,group_id,"smax",lgrid%smax)

#ifdef THERMAL_DIFFUSION_STS
    call read_rp(h5,group_id,"dt_par",lgrid%dt_par)
#endif

#ifdef OUTPUT_DT
    call read_rp(h5,group_id,"tnextoutput",lgrid%tnextoutput)
#endif

#ifdef SAVE_PLANES
    call read_ip(h5,group_id,"planes_dstep_dump",lgrid%planes_dstep_dump)
    call read_ip(h5,group_id,"planes_inextoutput",lgrid%planes_inextoutput)
#endif

#ifdef SAVE_SPHERICAL_PROJECTIONS
    call read_ip(h5,group_id,"spj_dstep_dump",lgrid%spj_dstep_dump)
    call read_ip(h5,group_id,"spj_inextoutput",lgrid%spj_inextoutput)
#endif

    call h5gclose_f(group_id,error)

    call h5fclose_f(file_id,error)

 end subroutine read_restart 
 
 subroutine write_output(mgrid,lgrid)
    type(mpigrid), intent(in) :: mgrid
    type(locgrid), intent(inout) :: lgrid

    type(h5_file) :: h5

    integer :: error,i,j,k
    integer(HID_T) :: id,plist_id

    logical :: resize

    real(kind=rp), allocatable, dimension(:,:,:) :: vol

#ifdef GEOMETRY_2D_POLAR
    real(kind=rp) :: r,rm,rpl,dr
    r = rp0
    rm = rp0
    rpl = rp0
    dr = rp0
#endif

#ifdef GEOMETRY_2D_SPHERICAL
    real(kind=rp) :: r,sin_theta,rm,rpl,dr
    r = rp0
    sin_theta = rp0
    rm = rp0
    rpl = rp0
    dr = rp0
#endif

#ifdef GEOMETRY_3D_SPHERICAL
    real(kind=rp) :: r,sin_theta,rm,rpl,dr
    r = rp0
    sin_theta = rp0
    rm = rp0
    rpl = rp0
    dr = rp0
#endif

#ifdef RESIZE_OUTPUT
    resize = .true.
#else
    resize = .false.
#endif

    write(h5%filename, "('grid_n',I0.5,'.h5')") lgrid%step

    call h5pcreate_f(H5P_FILE_ACCESS_F,plist_id,error)

    call h5pset_fapl_mpio_f(plist_id,mgrid%comm_cart,MPI_INFO_NULL,error)

    call h5fcreate_f(h5%filename,H5F_ACC_TRUNC_F,h5%file_id,error,H5P_DEFAULT_F,plist_id)
  
    call h5pclose_f(plist_id,error)

#ifdef USE_SINGLE_PRECISION 
#ifdef LITTLE_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F32LE
#endif
#ifdef BIG_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F32BE
#endif
#endif

#ifdef USE_DOUBLE_PRECISION
#ifdef LITTLE_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F64LE
#endif
#ifdef BIG_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F64BE
#endif
#endif

#ifdef LITTLE_ENDIAN
    h5%pref_dtypei = H5T_STD_I32LE
#endif
#ifdef BIG_ENDIAN
    h5%pref_dtypei = H5T_STD_I32BE
#endif

    call h5gcreate_f(h5%file_id,"grid", id, error)
    call hdf5_annotate_rp(h5,id,"time",lgrid%time)
    call hdf5_annotate_rp(h5,id,"dt",lgrid%dt)
    call hdf5_annotate_ip(h5,id,"step",lgrid%step)

    if(lgrid%step==0) then
 
      allocate(vol(mgrid%i1(1):mgrid%i2(1),mgrid%i1(2):mgrid%i2(2),mgrid%i1(3):mgrid%i2(3)))

      do k=mgrid%i1(3),mgrid%i2(3)
       do j=mgrid%i1(2),mgrid%i2(2)
        do i=mgrid%i1(1),mgrid%i2(1)
         vol(i,j,k) = rp1/lgrid%ivol(i,j,k)
        end do
       end do
      end do

      call hdf5_annotate_rp(h5,id,"gamma_ad",lgrid%gm)
      call hdf5_annotate_rp(h5,id,"mu",lgrid%mu)
      call hdf5_annotate_rp(h5,id,"x1l",lgrid%x1l)
      call hdf5_annotate_rp(h5,id,"x1u",lgrid%x1u)
      call hdf5_annotate_rp(h5,id,"x2l",lgrid%x2l)
      call hdf5_annotate_rp(h5,id,"x2u",lgrid%x2u)
      call hdf5_annotate_rp(h5,id,"x3l",lgrid%x3l)
      call hdf5_annotate_rp(h5,id,"x3u",lgrid%x3u)
      call hdf5_annotate_ip(h5,id,"sdims",sdims)
      call hdf5_annotate_ip(h5,id,"nx1",nx1)
      call hdf5_annotate_ip(h5,id,"nx2",nx2)
      call hdf5_annotate_ip(h5,id,"nx3",nx3)

#ifdef ADVECT_YE_IABAR
      call hdf5_annotate_string(id,"advect_yeiabar","true")
#else
      call hdf5_annotate_string(id,"advect_yeiabar","false")
#endif

#ifdef ADVECT_SPECIES
      call hdf5_annotate_string(id,"advect_species","true")
#else
      call hdf5_annotate_string(id,"advect_species","false")
#endif

#ifdef USE_PRAD
      call hdf5_annotate_string(id,"use_prad","true")
#else
      call hdf5_annotate_string(id,"use_prad","false")
#endif

#ifdef HELMHOLTZ_EOS
      call hdf5_annotate_string(id,"use_helmholtz","true")
#ifdef USE_COULOMB_CORRECTIONS
      call hdf5_annotate_string(id,"use_coulomb_corrections","true")
#else
      call hdf5_annotate_string(id,"use_coulomb_corrections","false")
#endif
#else
      call hdf5_annotate_string(id,"use_helmholtz","false")
#endif

#ifdef PIG_EOS
      call hdf5_annotate_string(id,"use_pig","true")
#else
      call hdf5_annotate_string(id,"use_pig","false")
#endif

#ifdef USE_GRAVITY_SOLVER
      call hdf5_annotate_string(id,"use_gravity_solver","true")
#else
      call hdf5_annotate_string(id,"use_gravity_solver","false")
#endif

#ifdef USE_MONOPOLE_GRAVITY
      call hdf5_annotate_string(id,"use_monopole_solver","true")
#else
      call hdf5_annotate_string(id,"use_monopole_solver","false")
#endif

#if defined(GEOMETRY_CARTESIAN_UNIFORM) || defined(GEOMETRY_CARTESIAN_NONUNIFORM)
      call hdf5_annotate_string(id,"geometry-type","cartesian")
#endif

#ifdef GEOMETRY_2D_POLAR
      call hdf5_annotate_string(id,"geometry-type","2d-polar")
#endif

#ifdef GEOMETRY_2D_SPHERICAL
      call hdf5_annotate_string(id,"geometry-type","2d-spherical")
#endif

#ifdef GEOMETRY_3D_SPHERICAL
      call hdf5_annotate_string(id,"geometry-type","3d-spherical")
#endif

#ifdef GEOMETRY_CUBED_SPHERE
      call hdf5_annotate_string(id,"geometry-type","cartesian")
#endif

#ifdef USE_INTERNAL_BOUNDARIES
      call hdf5_annotate_string(id,"use_internal_boundaries","true")
#else
#ifdef GEOMETRY_CUBED_SPHERE
      call hdf5_annotate_string(id,"use_internal_boundaries","true")
#else
      call hdf5_annotate_string(id,"use_internal_boundaries","false")
#endif
#endif 

#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL) || defined(USE_INTERNAL_BOUNDARIES) || defined(GEOMETRY_CUBED_SPHERE)
      call hdf5_write_array(h5,id,"r",mgrid, &
      mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,resize,.false.,lgrid%ivol,lgrid%r)
#endif

      call hdf5_write_ndarray(h5,id,"coords",mgrid,sdims, &
      mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,resize,.false.,lgrid%ivol,lgrid%coords)

#ifdef USE_TIMMES_KAPPA
      call hdf5_annotate_string(id,"update_kappa","true")
#else
      call hdf5_annotate_string(id,"update_kappa","false")
#endif

#if defined(THERMAL_DIFFUSION_STS) || defined(THERMAL_DIFFUSION_EXPLICIT)
#ifndef USE_TIMMES_KAPPA
      call hdf5_write_array(h5,id,"kappa",mgrid, &
      mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,resize,.true.,lgrid%ivol,lgrid%kappa)
#endif
#endif

#ifdef ADVECT_SPECIES
      call hdf5_annotate_array_rp(h5,id,"A",lgrid%A) 
      call hdf5_annotate_array_rp(h5,id,"Z",lgrid%Z) 
#endif

#ifdef USE_NUCLEAR_NETWORK
      call hdf5_annotate_array_string(id,"name_species",lgrid%name_species,nspecies)
      call hdf5_annotate_array_string(id,"name_reacs",lgrid%name_reacs,nreacs)
#endif 

#ifndef USE_GRAVITY_SOLVER
#ifndef USE_MONOPOLE_GRAVITY
#ifdef USE_GRAVITY
      call hdf5_write_ndarray(h5,id,"grav",mgrid,sdims, &
      mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,resize,.true.,lgrid%ivol,lgrid%grav)
#ifdef EVOLVE_ETOT
      call hdf5_write_array(h5,id,"phi_cc",mgrid, &
      mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,resize,.true.,lgrid%ivol,lgrid%phi_cc)
#endif
#endif
#endif
#endif

#ifdef USE_EDOT
      call hdf5_write_array(h5,id,"edot",mgrid, &
      mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,resize,.true.,lgrid%ivol,lgrid%edot)
#endif

#ifdef COROTATING_FRAME
      call hdf5_annotate_array_rp(h5,id,"omega_rot",lgrid%omega_rot) 
#endif

      call hdf5_write_array(h5,id,"vol",mgrid, &
      mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),0,resize,.false.,lgrid%ivol,vol)
     
      deallocate(vol)

    endif

    call hdf5_write_ndarray(h5,id,"prim",mgrid,nvars, &
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,resize,.true.,lgrid%ivol,lgrid%prim)

    call hdf5_write_array(h5,id,"temp",mgrid, &
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,resize,.true.,lgrid%ivol,lgrid%temp)

#ifdef USE_MHD
    call hdf5_write_ndarray(h5,id,"bfield",mgrid,sdims, &
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,resize,.true.,lgrid%ivol,lgrid%b_cc)
#endif

#ifdef USE_GRAVITY_SOLVER
    call hdf5_write_array(h5,id,"phi_cc",mgrid, &
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,resize,.true.,lgrid%ivol,lgrid%phi_cc)

    call hdf5_write_ndarray(h5,id,"grav",mgrid,sdims, &
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,resize,.true.,lgrid%ivol,lgrid%grav)
#endif

#ifdef USE_MONOPOLE_GRAVITY
    call hdf5_write_ndarray(h5,id,"grav",mgrid,sdims, &
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,resize,.true.,lgrid%ivol,lgrid%grav)
#endif

#ifdef USE_TIMMES_KAPPA
    call hdf5_write_array(h5,id,"kappa",mgrid, &
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),ngc,resize,.true.,lgrid%ivol,lgrid%kappa)
#endif

#ifdef USE_NUCLEAR_NETWORK
#ifdef USE_NEULOSS
    call hdf5_write_ndarray(h5,id,"edot_nuc",mgrid,nreacs+1, &
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),0,resize,.true.,lgrid%ivol,lgrid%edot_nuc)
#else
    call hdf5_write_ndarray(h5,id,"edot_nuc",mgrid,nreacs, &
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),0,resize,.true.,lgrid%ivol,lgrid%edot_nuc)
#endif
    call hdf5_write_ndarray(h5,id,"X_species_dot",mgrid,nspecies, &
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),0,resize,.true.,lgrid%ivol,lgrid%X_species_dot)
#ifdef SAVE_SPECIES_FLUXES
    call hdf5_write_nd2array(h5,id,"X_species_dot_reacs",mgrid,nspecies,nreacs, &
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),0,resize,lgrid%X_species_dot_reacs)
#endif
#endif

    call h5gclose_f(id,error)
    call h5fclose_f(h5%file_id,error)

 end subroutine write_output

#ifdef SAVE_SPHERICAL_PROJECTIONS
 
 subroutine write_spherical_projections(mgrid,lgrid)

    type(mpigrid), intent(in) :: mgrid
    type(locgrid), intent(inout) :: lgrid

    integer :: ir,it,ip,iv,ierr,total_size,nv
    integer :: id_x1,id_x2,id_x3,ic

    real(kind=rp) :: x1,x2,x3,theta,phi,r,sin_theta,x1_ref,x2_ref,x3_ref
    real(kind=rp) :: x1min,x1max,x2min,x2max,x3min,x3max,u,v,w
    real(kind=rp) :: q000,q001,q010,q100,q101,q011,q110,q111
    real(kind=rp) :: c000,c001,c010,c100,c101,c011,c110,c111

    real(kind=rp), allocatable :: local_flat(:)
    real(kind=rp), allocatable :: global_flat(:)
    real(kind=rp), allocatable :: global_data(:,:,:)
    real(kind=rp), allocatable :: phi_arr(:),theta_arr(:)

    real(kind=rp) :: dphi,dtheta
    integer :: nspj_nodes_phi,nspj_nodes_theta

    character(len=filename_size) :: filename

    type(h5_file) :: h5

    integer :: error
    integer(HID_T) :: group_id,plist_id,dset_id
    integer(kind=HSIZE_T), dimension(3) :: gnc

    if(mgrid%rankl==master_rank) then

#ifdef USE_SINGLE_PRECISION 
#ifdef LITTLE_ENDIAN
     h5%pref_dtypef = H5T_IEEE_F32LE
#endif
#ifdef BIG_ENDIAN
     h5%pref_dtypef = H5T_IEEE_F32BE
#endif
#endif

#ifdef USE_DOUBLE_PRECISION
#ifdef LITTLE_ENDIAN
     h5%pref_dtypef = H5T_IEEE_F64LE
#endif
#ifdef BIG_ENDIAN
     h5%pref_dtypef = H5T_IEEE_F64BE
#endif
#endif

#ifdef LITTLE_ENDIAN
     h5%pref_dtypei = H5T_STD_I32LE
#endif
#ifdef BIG_ENDIAN
     h5%pref_dtypei = H5T_STD_I32BE
#endif

     write(h5%filename, "('spj_n',I0.5,'.h5')") lgrid%step
     call h5fcreate_f(h5%filename,H5F_ACC_TRUNC_F,h5%file_id,error)

     call h5gcreate_f(h5%file_id,"grid",group_id,error)
     call hdf5_annotate_rp(h5,group_id,"time",lgrid%time)
     call hdf5_annotate_rp(h5,group_id,"dt",lgrid%dt)
     call hdf5_annotate_ip(h5,group_id,"step",lgrid%step) 
     call hdf5_annotate_ip(h5,group_id,"nhydro",nvars) 
     call hdf5_annotate_array_rp(h5,group_id,"r",lgrid%spj_r)
     call h5gclose_f(group_id,error)

    end if

    nv = nvars+1
#ifdef USE_MHD
    nv = nv + 3
#endif

    x1min = lgrid%coords_x1(1,mgrid%i1(1),mgrid%i1(2),mgrid%i1(3))
    x1max = lgrid%coords_x1(1,mgrid%i2(1)+1,mgrid%i2(2),mgrid%i2(3))
    x2min = lgrid%coords_x2(2,mgrid%i1(1),mgrid%i1(2),mgrid%i1(3))
    x2max = lgrid%coords_x2(2,mgrid%i2(1),mgrid%i2(2)+1,mgrid%i2(3))
    x3min = lgrid%coords_x3(3,mgrid%i1(1),mgrid%i1(2),mgrid%i1(3))
    x3max = lgrid%coords_x3(3,mgrid%i2(1),mgrid%i2(2),mgrid%i2(3)+1)

    do ir=1,nspj

     ic = 1

     r = lgrid%spj_r(ir)

     dphi = lgrid%dx1/r
     dtheta = dphi
 
     nspj_nodes_phi = nint(rp2*CONST_PI/dphi)
     nspj_nodes_theta = nint(CONST_PI/dtheta) 

     total_size = nv*nspj_nodes_phi*nspj_nodes_theta

     allocate(local_flat(1:total_size))

     do it=1,total_size
      local_flat(it) = -HUGE(rp0)
     end do

     allocate(phi_arr(1:nspj_nodes_phi))
     allocate(theta_arr(1:nspj_nodes_theta))

     do it=1,nspj_nodes_theta

      theta = real(it-0.5,kind=rp)*CONST_PI/real(nspj_nodes_theta,kind=rp)
      theta_arr(it) = theta

      do ip=1,nspj_nodes_phi

        phi = real(ip-0.5,kind=rp)*rp2*CONST_PI/real(nspj_nodes_phi,kind=rp)
        phi_arr(ip) = phi

        sin_theta = sin(theta)
        x1 = r*sin_theta*cos(phi)
        x2 = r*sin_theta*sin(phi)
        x3 = r*cos(theta)

        if((x1>=x1min) .and. (x1<=x1max) .and. &
        (x2>=x2min) .and. (x2<=x2max) .and.  &
        (x3>=x3min) .and. (x3<=x3max)) then

            id_x1 = nint((x1-lgrid%x1l)/lgrid%dx1)
            id_x2 = nint((x2-lgrid%x2l)/lgrid%dx2)
            id_x3 = nint((x3-lgrid%x3l)/lgrid%dx3)

            x1_ref = lgrid%coords(1,id_x1,id_x2,id_x3)
            x2_ref = lgrid%coords(2,id_x1,id_x2,id_x3)
            x3_ref = lgrid%coords(3,id_x1,id_x2,id_x3)

            u = (x1-x1_ref)/(lgrid%coords(1,id_x1+1,id_x2,id_x3)-x1_ref)
            v = (x2-x2_ref)/(lgrid%coords(2,id_x1,id_x2+1,id_x3)-x2_ref)
            w = (x3-x3_ref)/(lgrid%coords(3,id_x1,id_x2,id_x3+1)-x3_ref)

            c000 = (rp1-u)*(rp1-v)*(rp1-w)  
            c100 = u*(rp1-v)*(rp1-w) 
            c010 = (rp1-u)*v*(rp1-w) 
            c110 = u*v*(rp1-w) 
            c001 = (rp1-u)*(rp1-v)*w 
            c101 = u*(rp1-v)*w 
            c011 = (rp1-u)*v*w 
            c111 = u*v*w 
     
            do iv=1,nvars

             q000 = lgrid%prim(iv,id_x1,id_x2,id_x3)
             q100 = lgrid%prim(iv,id_x1+1,id_x2,id_x3)
             q010 = lgrid%prim(iv,id_x1,id_x2+1,id_x3)
             q001 = lgrid%prim(iv,id_x1,id_x2,id_x3+1)
             q110 = lgrid%prim(iv,id_x1+1,id_x2+1,id_x3)
             q101 = lgrid%prim(iv,id_x1+1,id_x2,id_x3+1)
             q011 = lgrid%prim(iv,id_x1,id_x2+1,id_x3+1)
             q111 = lgrid%prim(iv,id_x1+1,id_x2+1,id_x3+1)

             local_flat(ic) = &
             q000*c000 + &
             q100*c100 + &
             q010*c010 + &
             q110*c110 + &
             q001*c001 + &
             q101*c101 + &
             q011*c011 + &
             q111*c111
     
             ic = ic + 1     

            end do

            q000 = lgrid%temp(id_x1,id_x2,id_x3)
            q100 = lgrid%temp(id_x1+1,id_x2,id_x3)
            q010 = lgrid%temp(id_x1,id_x2+1,id_x3)
            q001 = lgrid%temp(id_x1,id_x2,id_x3+1)
            q110 = lgrid%temp(id_x1+1,id_x2+1,id_x3)
            q101 = lgrid%temp(id_x1+1,id_x2,id_x3+1)
            q011 = lgrid%temp(id_x1,id_x2+1,id_x3+1)
            q111 = lgrid%temp(id_x1+1,id_x2+1,id_x3+1)

            local_flat(ic) = &
            q000*c000 + &
            q100*c100 + &
            q010*c010 + &
            q110*c110 + &
            q001*c001 + &
            q101*c101 + &
            q011*c011 + &
            q111*c111
     
            ic = ic + 1     

#ifdef USE_MHD

            do iv=1,3

             q000 = lgrid%b_cc(iv,id_x1,id_x2,id_x3)
             q100 = lgrid%b_cc(iv,id_x1+1,id_x2,id_x3)
             q010 = lgrid%b_cc(iv,id_x1,id_x2+1,id_x3)
             q001 = lgrid%b_cc(iv,id_x1,id_x2,id_x3+1)
             q110 = lgrid%b_cc(iv,id_x1+1,id_x2+1,id_x3)
             q101 = lgrid%b_cc(iv,id_x1+1,id_x2,id_x3+1)
             q011 = lgrid%b_cc(iv,id_x1,id_x2+1,id_x3+1)
             q111 = lgrid%b_cc(iv,id_x1+1,id_x2+1,id_x3+1)

             local_flat(ic) = &
             q000*c000 + &
             q100*c100 + &
             q010*c010 + &
             q110*c110 + &
             q001*c001 + &
             q101*c101 + &
             q011*c011 + &
             q111*c111

             ic = ic + 1

            end do

#endif

        else
 
          do iv=1,nv
           ic = ic +1
          end do

        endif

       end do
     end do

     call mpi_barrier(mgrid%comm_cart,ip)

     allocate(global_flat(1:total_size))

     call mpi_reduce(local_flat,global_flat,total_size, &
     MPI_RP,MPI_MAX,master_rank,mgrid%comm_cart,ierr)

     deallocate(local_flat)

     if(mgrid%rankl==master_rank) then
      
      allocate(global_data(1:nv,1:nspj_nodes_phi,1:nspj_nodes_theta))

      ic = 1
      do it=1,nspj_nodes_theta
       do ip=1,nspj_nodes_phi
        do iv=1,nv

         global_data(iv,ip,it) = global_flat(ic)
         ic = ic +1

        end do
       end do
      end do

      gnc(1) = nv
      gnc(2) = nspj_nodes_phi
      gnc(3) = nspj_nodes_theta
      call h5screate_simple_f(3,gnc,plist_id,error)

      write(filename, "('plane_',I0.5)") ir
      call h5gcreate_f(h5%file_id,filename,group_id,error)

      call hdf5_annotate_array_rp(h5,group_id,"phi",phi_arr)
      call hdf5_annotate_array_rp(h5,group_id,"theta",theta_arr)
      call h5dcreate_f(group_id,"vars",h5%pref_dtypef,plist_id,dset_id,error)
      call h5dwrite_f(dset_id,h5%pref_dtypef,global_data,gnc,error)

      deallocate(global_data)

      call h5dclose_f(dset_id,error)
      call h5sclose_f(plist_id,error)
      call h5gclose_f(group_id,error)

     end if

     deallocate(phi_arr)
     deallocate(theta_arr)
     deallocate(global_flat)

    end do

    if(mgrid%rankl==master_rank) call h5fclose_f(h5%file_id,error)

 end subroutine write_spherical_projections

#endif

#ifdef SAVE_PLANES
 
 subroutine write_planes(mgrid,lgrid)
    type(mpigrid), intent(in) :: mgrid
    type(locgrid), intent(inout) :: lgrid

    type(h5_file) :: h5

    integer :: error,ip
    integer(HID_T) :: id,plist_id
    character(len=filename_size) :: filename

    write(h5%filename, "('planes_n',I0.5,'.h5')") lgrid%step

    call h5pcreate_f(H5P_FILE_ACCESS_F,plist_id,error)

    call h5pset_fapl_mpio_f(plist_id,mgrid%comm_cart,MPI_INFO_NULL,error)

    call h5fcreate_f(h5%filename,H5F_ACC_TRUNC_F,h5%file_id,error,H5P_DEFAULT_F,plist_id)
  
    call h5pclose_f(plist_id,error)

#ifdef USE_SINGLE_PRECISION 
#ifdef LITTLE_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F32LE
#endif
#ifdef BIG_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F32BE
#endif
#endif

#ifdef USE_DOUBLE_PRECISION
#ifdef LITTLE_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F64LE
#endif
#ifdef BIG_ENDIAN
    h5%pref_dtypef = H5T_IEEE_F64BE
#endif
#endif

#ifdef LITTLE_ENDIAN
    h5%pref_dtypei = H5T_STD_I32LE
#endif
#ifdef BIG_ENDIAN
    h5%pref_dtypei = H5T_STD_I32BE
#endif

    call h5gcreate_f(h5%file_id,"grid", id, error)
    call hdf5_annotate_rp(h5,id,"time",lgrid%time)
    call hdf5_annotate_rp(h5,id,"dt",lgrid%dt)
    call hdf5_annotate_ip(h5,id,"step",lgrid%step)
    call hdf5_annotate_ip(h5,id,"nplanes_x1",nplanes_x1)
    call hdf5_annotate_ip(h5,id,"nplanes_x2",nplanes_x2)
    call hdf5_annotate_ip(h5,id,"nplanes_x3",nplanes_x3)

#if nplanes_x1_make>0

    write(filename, "('planes_x1_index')")
    call hdf5_annotate_array_ip(h5,id,filename,lgrid%planes_x1_index)

    do ip=1,nplanes_x1

     write(filename, "('prim_x1_n',I0.5)") ip
     call hdf5_write_ndarray_x1(h5,id,filename,mgrid,nvars, &
     mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),lgrid%planes_x1_index(ip),& 
     ngc,lgrid%prim,lgrid%planes_x1_inside_domain(ip))

     write(filename, "('temp_x1_n',I0.5)") ip
     call hdf5_write_array_x1(h5,id,filename,mgrid, &
     mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),lgrid%planes_x1_index(ip),& 
     ngc,lgrid%temp,lgrid%planes_x1_inside_domain(ip))

#ifdef USE_MHD
     write(filename, "('bfield_x1_n',I0.5)") ip
     call hdf5_write_ndarray_x1(h5,id,filename,mgrid,3, &
     mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),lgrid%planes_x1_index(ip),& 
     ngc,lgrid%b_cc,lgrid%planes_x1_inside_domain(ip))
#endif

    end do

#endif

#if nplanes_x2_make>0

    write(filename, "('planes_x2_index')")
    call hdf5_annotate_array_ip(h5,id,filename,lgrid%planes_x2_index)

    do ip=1,nplanes_x2

     write(filename, "('prim_x2_n',I0.5)") ip
     call hdf5_write_ndarray_x2(h5,id,filename,mgrid,nvars, &
     mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),lgrid%planes_x2_index(ip),& 
     ngc,lgrid%prim,lgrid%planes_x2_inside_domain(ip))

     write(filename, "('temp_x2_n',I0.5)") ip
     call hdf5_write_array_x2(h5,id,filename,mgrid, &
     mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),lgrid%planes_x2_index(ip),& 
     ngc,lgrid%temp,lgrid%planes_x2_inside_domain(ip))

#ifdef USE_MHD
     write(filename, "('bfield_x2_n',I0.5)") ip
     call hdf5_write_ndarray_x2(h5,id,filename,mgrid,3, &
     mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),lgrid%planes_x2_index(ip),& 
     ngc,lgrid%b_cc,lgrid%planes_x2_inside_domain(ip))
#endif

    end do

#endif

#if nplanes_x3_make>0

    write(filename, "('planes_x3_index')")
    call hdf5_annotate_array_ip(h5,id,filename,lgrid%planes_x3_index)

    do ip=1,nplanes_x3

     write(filename, "('prim_x3_n',I0.5)") ip
     call hdf5_write_ndarray_x3(h5,id,filename,mgrid,nvars, &
     mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),lgrid%planes_x3_index(ip),& 
     ngc,lgrid%prim,lgrid%planes_x3_inside_domain(ip))

     write(filename, "('temp_x3_n',I0.5)") ip
     call hdf5_write_array_x3(h5,id,filename,mgrid, &
     mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),lgrid%planes_x3_index(ip),& 
     ngc,lgrid%temp,lgrid%planes_x3_inside_domain(ip))

#ifdef USE_MHD
     write(filename, "('bfield_x3_n',I0.5)") ip
     call hdf5_write_ndarray_x3(h5,id,filename,mgrid,3, &
     mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),mgrid%i1(3),mgrid%i2(3),lgrid%planes_x3_index(ip),& 
     ngc,lgrid%b_cc,lgrid%planes_x3_inside_domain(ip))
#endif

    end do

#endif

    call h5gclose_f(id,error)
    call h5fclose_f(h5%file_id,error)

 end subroutine write_planes

 subroutine hdf5_write_ndarray_x1(h5,group_id,dsetname,mgrid,nv,lx1,ux1,lx2,ux2,lx3,ux3,ix1,ghost,vec,inside_domain)
    type(h5_file) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*) :: dsetname
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: nv
    integer, intent(in) :: lx1,ux1,lx2,ux2,lx3,ux3,ix1,ghost
    real(kind=rp), dimension(1:nv, &
    lx1-ghost:ux1+ghost, &
    lx2-ghost:ux2+ghost, &
    lx3-ghost:ux3+ghost), intent(in) :: vec
    logical, intent(in) :: inside_domain
    
    integer(kind=HID_T) :: dset_id,filespace,memspace,plist_id
    integer(kind=HSIZE_T), dimension(3) :: gnc,cnt,off
    integer(kind=HSIZE_T), dimension(3) :: memcnt,memcnt2,memoff
    integer :: err

    integer :: nx1l,nx2l,nx3l
    integer :: iv,j,k

    real(kind=rp), allocatable :: slice(:,:,:)

    nx1l = ux1-lx1+1
    nx2l = ux2-lx2+1
    nx3l = ux3-lx3+1

    gnc(1) = nv
    gnc(2) = nx2l*mgrid%bricks(2)
    gnc(3) = nx3l*mgrid%bricks(3)

    call h5screate_simple_f(3,gnc,filespace,err)

    call h5dcreate_f(group_id,dsetname,h5%pref_dtypef,filespace,dset_id,err)

    call h5sclose_f(filespace,err)

    memcnt(1) = nv
    memcnt(2) = nx2l + 2*ghost
    memcnt(3) = nx3l + 2*ghost

    call h5screate_simple_f(3,memcnt,memspace,err)

    memcnt2(1) = nv
    memcnt2(2) = nx2l
    memcnt2(3) = nx3l

    memoff(1) = 0
    memoff(2) = ghost
    memoff(3) = ghost

    call h5sselect_hyperslab_f(memspace,H5S_SELECT_SET_F,memoff,memcnt2,err)
    
    cnt(1) = nv
    cnt(2) = nx2l 
    cnt(3) = nx3l

    off(1) = 0
    off(2) = nx2l*mgrid%coords_dd(2)
    off(3) = nx3l*mgrid%coords_dd(3)

    call h5dget_space_f(dset_id,filespace,err)

    call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,off,cnt,err)

    call h5pcreate_f(H5P_DATASET_XFER_F,plist_id,err)
    call h5pset_dxpl_mpio_f(plist_id,H5FD_MPIO_COLLECTIVE_F,err)

    allocate(slice(1:nv,lx2-ngc:ux2+ngc,lx3-ngc:ux3+ngc))
 
    if(inside_domain .eqv. .true.) then
    
     do k=lx3,ux3
      do j=lx2,ux2
       do iv=1,nv
        slice(iv,j,k) = vec(iv,ix1,j,k)
       end do
      end do
     end do

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     slice(1, &
     lbound(slice,2), &
     lbound(slice,3) ), &
     gnc,err,memspace,filespace,plist_id)
 
    else
    
     do k=lx3,ux3
      do j=lx2,ux2
       do iv=1,nv
        slice(iv,j,k) = rp1
       end do
      end do
     end do

     call h5sselect_none_f(filespace, err)
     call h5sselect_none_f(memspace, err)

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     slice(1, &
     lbound(slice,2), &
     lbound(slice,3) ), &
     gnc,err,memspace,filespace,plist_id)
 
    endif

    deallocate(slice)

    call h5sclose_f(filespace,err)
    call h5sclose_f(memspace,err)
    call h5dclose_f(dset_id,err)
    call h5pclose_f(plist_id,err)

 end subroutine hdf5_write_ndarray_x1

 subroutine hdf5_write_array_x1(h5,group_id,dsetname,mgrid,lx1,ux1,lx2,ux2,lx3,ux3,ix1,ghost,vec,inside_domain)
    type(h5_file) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*) :: dsetname
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: lx1,ux1,lx2,ux2,lx3,ux3,ix1,ghost
    real(kind=rp), dimension( &
    lx1-ghost:ux1+ghost, &
    lx2-ghost:ux2+ghost, &
    lx3-ghost:ux3+ghost), intent(in) :: vec
    logical, intent(in) :: inside_domain
    
    integer(kind=HID_T) :: dset_id,filespace,memspace,plist_id
    integer(kind=HSIZE_T), dimension(2) :: gnc,cnt,off
    integer(kind=HSIZE_T), dimension(2) :: memcnt,memcnt2,memoff
    integer :: err

    integer :: nx1l,nx2l,nx3l
    integer :: j,k

    real(kind=rp), allocatable :: slice(:,:)

    nx1l = ux1-lx1+1
    nx2l = ux2-lx2+1
    nx3l = ux3-lx3+1

    gnc(1) = nx2l*mgrid%bricks(2)
    gnc(2) = nx3l*mgrid%bricks(3)

    call h5screate_simple_f(2,gnc,filespace,err)

    call h5dcreate_f(group_id,dsetname,h5%pref_dtypef,filespace,dset_id,err)

    call h5sclose_f(filespace,err)

    memcnt(1) = nx2l + 2*ghost
    memcnt(2) = nx3l + 2*ghost

    call h5screate_simple_f(2,memcnt,memspace,err)

    memcnt2(1) = nx2l
    memcnt2(2) = nx3l

    memoff(1) = ghost
    memoff(2) = ghost

    call h5sselect_hyperslab_f(memspace,H5S_SELECT_SET_F,memoff,memcnt2,err)
    
    cnt(1) = nx2l 
    cnt(2) = nx3l

    off(1) = nx2l*mgrid%coords_dd(2)
    off(2) = nx3l*mgrid%coords_dd(3)

    call h5dget_space_f(dset_id,filespace,err)

    call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,off,cnt,err)

    call h5pcreate_f(H5P_DATASET_XFER_F,plist_id,err)
    call h5pset_dxpl_mpio_f(plist_id,H5FD_MPIO_COLLECTIVE_F,err)

    allocate(slice(lx2-ngc:ux2+ngc,lx3-ngc:ux3+ngc))
 
    if(inside_domain .eqv. .true.) then
    
     do k=lx3,ux3
      do j=lx2,ux2
       slice(j,k) = vec(ix1,j,k)
      end do
     end do

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     slice( &
     lbound(slice,1), &
     lbound(slice,2) ), &
     gnc,err,memspace,filespace,plist_id)
 
    else
    
     do k=lx3,ux3
      do j=lx2,ux2
       slice(j,k) = rp1
      end do
     end do

     call h5sselect_none_f(filespace, err)
     call h5sselect_none_f(memspace, err)

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     slice( &
     lbound(slice,1), &
     lbound(slice,2) ), &
     gnc,err,memspace,filespace,plist_id)
 
    endif

    deallocate(slice)

    call h5sclose_f(filespace,err)
    call h5sclose_f(memspace,err)
    call h5dclose_f(dset_id,err)
    call h5pclose_f(plist_id,err)

 end subroutine hdf5_write_array_x1

 subroutine hdf5_write_ndarray_x2(h5,group_id,dsetname,mgrid,nv,lx1,ux1,lx2,ux2,lx3,ux3,ix2,ghost,vec,inside_domain)
    type(h5_file) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*) :: dsetname
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: nv
    integer, intent(in) :: lx1,ux1,lx2,ux2,lx3,ux3,ix2,ghost
    real(kind=rp), dimension(1:nv, &
    lx1-ghost:ux1+ghost, &
    lx2-ghost:ux2+ghost, &
    lx3-ghost:ux3+ghost), intent(in) :: vec
    logical, intent(in) :: inside_domain
    
    integer(kind=HID_T) :: dset_id,filespace,memspace,plist_id
    integer(kind=HSIZE_T), dimension(3) :: gnc,cnt,off
    integer(kind=HSIZE_T), dimension(3) :: memcnt,memcnt2,memoff
    integer :: err

    integer :: nx1l,nx2l,nx3l
    integer :: iv,j,k

    real(kind=rp), allocatable :: slice(:,:,:)

    nx1l = ux1-lx1+1
    nx2l = ux2-lx2+1
    nx3l = ux3-lx3+1

    gnc(1) = nv
    gnc(2) = nx1l*mgrid%bricks(1)
    gnc(3) = nx3l*mgrid%bricks(3)

    call h5screate_simple_f(3,gnc,filespace,err)

    call h5dcreate_f(group_id,dsetname,h5%pref_dtypef,filespace,dset_id,err)

    call h5sclose_f(filespace,err)

    memcnt(1) = nv
    memcnt(2) = nx1l + 2*ghost
    memcnt(3) = nx3l + 2*ghost

    call h5screate_simple_f(3,memcnt,memspace,err)

    memcnt2(1) = nv
    memcnt2(2) = nx1l
    memcnt2(3) = nx3l

    memoff(1) = 0
    memoff(2) = ghost
    memoff(3) = ghost

    call h5sselect_hyperslab_f(memspace,H5S_SELECT_SET_F,memoff,memcnt2,err)
    
    cnt(1) = nv
    cnt(2) = nx1l 
    cnt(3) = nx3l

    off(1) = 0
    off(2) = nx1l*mgrid%coords_dd(1)
    off(3) = nx3l*mgrid%coords_dd(3)

    call h5dget_space_f(dset_id,filespace,err)

    call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,off,cnt,err)

    call h5pcreate_f(H5P_DATASET_XFER_F,plist_id,err)
    call h5pset_dxpl_mpio_f(plist_id,H5FD_MPIO_COLLECTIVE_F,err)

    allocate(slice(1:nv,lx1-ngc:ux1+ngc,lx3-ngc:ux3+ngc))
 
    if(inside_domain .eqv. .true.) then
    
     do k=lx3,ux3
      do j=lx1,ux1
       do iv=1,nv
        slice(iv,j,k) = vec(iv,j,ix2,k)
       end do
      end do
     end do

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     slice(1, &
     lbound(slice,2), &
     lbound(slice,3) ), &
     gnc,err,memspace,filespace,plist_id)
 
    else
    
     do k=lx3,ux3
      do j=lx1,ux1
       do iv=1,nv
        slice(iv,j,k) = rp1
       end do
      end do
     end do

     call h5sselect_none_f(filespace, err)
     call h5sselect_none_f(memspace, err)

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     slice(1, &
     lbound(slice,2), &
     lbound(slice,3) ), &
     gnc,err,memspace,filespace,plist_id)
 
    endif

    deallocate(slice)

    call h5sclose_f(filespace,err)
    call h5sclose_f(memspace,err)
    call h5dclose_f(dset_id,err)
    call h5pclose_f(plist_id,err)

 end subroutine hdf5_write_ndarray_x2

 subroutine hdf5_write_array_x2(h5,group_id,dsetname,mgrid,lx1,ux1,lx2,ux2,lx3,ux3,ix2,ghost,vec,inside_domain)
    type(h5_file) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*) :: dsetname
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: lx1,ux1,lx2,ux2,lx3,ux3,ix2,ghost
    real(kind=rp), dimension( &
    lx1-ghost:ux1+ghost, &
    lx2-ghost:ux2+ghost, &
    lx3-ghost:ux3+ghost), intent(in) :: vec
    logical, intent(in) :: inside_domain
    
    integer(kind=HID_T) :: dset_id,filespace,memspace,plist_id
    integer(kind=HSIZE_T), dimension(2) :: gnc,cnt,off
    integer(kind=HSIZE_T), dimension(2) :: memcnt,memcnt2,memoff
    integer :: err

    integer :: nx1l,nx2l,nx3l
    integer :: j,k

    real(kind=rp), allocatable :: slice(:,:)

    nx1l = ux1-lx1+1
    nx2l = ux2-lx2+1
    nx3l = ux3-lx3+1

    gnc(1) = nx1l*mgrid%bricks(1)
    gnc(2) = nx3l*mgrid%bricks(3)

    call h5screate_simple_f(2,gnc,filespace,err)

    call h5dcreate_f(group_id,dsetname,h5%pref_dtypef,filespace,dset_id,err)

    call h5sclose_f(filespace,err)

    memcnt(1) = nx1l + 2*ghost
    memcnt(2) = nx3l + 2*ghost

    call h5screate_simple_f(2,memcnt,memspace,err)

    memcnt2(1) = nx1l
    memcnt2(2) = nx3l

    memoff(1) = ghost
    memoff(2) = ghost

    call h5sselect_hyperslab_f(memspace,H5S_SELECT_SET_F,memoff,memcnt2,err)
    
    cnt(1) = nx1l 
    cnt(2) = nx3l

    off(1) = nx1l*mgrid%coords_dd(1)
    off(2) = nx3l*mgrid%coords_dd(3)

    call h5dget_space_f(dset_id,filespace,err)

    call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,off,cnt,err)

    call h5pcreate_f(H5P_DATASET_XFER_F,plist_id,err)
    call h5pset_dxpl_mpio_f(plist_id,H5FD_MPIO_COLLECTIVE_F,err)

    allocate(slice(lx1-ngc:ux1+ngc,lx3-ngc:ux3+ngc))
 
    if(inside_domain .eqv. .true.) then
    
     do k=lx3,ux3
      do j=lx1,ux1
       slice(j,k) = vec(j,ix2,k)
      end do
     end do

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     slice( &
     lbound(slice,1), &
     lbound(slice,2) ), &
     gnc,err,memspace,filespace,plist_id)
 
    else
    
     do k=lx3,ux3
      do j=lx1,ux1
       slice(j,k) = rp1
      end do
     end do

     call h5sselect_none_f(filespace, err)
     call h5sselect_none_f(memspace, err)

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     slice( &
     lbound(slice,1), &
     lbound(slice,2) ), &
     gnc,err,memspace,filespace,plist_id)
 
    endif

    deallocate(slice)

    call h5sclose_f(filespace,err)
    call h5sclose_f(memspace,err)
    call h5dclose_f(dset_id,err)
    call h5pclose_f(plist_id,err)

 end subroutine hdf5_write_array_x2

 subroutine hdf5_write_ndarray_x3(h5,group_id,dsetname,mgrid,nv,lx1,ux1,lx2,ux2,lx3,ux3,ix3,ghost,vec,inside_domain)
    type(h5_file) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*) :: dsetname
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: nv
    integer, intent(in) :: lx1,ux1,lx2,ux2,lx3,ux3,ix3,ghost
    real(kind=rp), dimension(1:nv, &
    lx1-ghost:ux1+ghost, &
    lx2-ghost:ux2+ghost, &
    lx3-ghost:ux3+ghost), intent(in) :: vec
    logical, intent(in) :: inside_domain
    
    integer(kind=HID_T) :: dset_id,filespace,memspace,plist_id
    integer(kind=HSIZE_T), dimension(3) :: gnc,cnt,off
    integer(kind=HSIZE_T), dimension(3) :: memcnt,memcnt2,memoff
    integer :: err

    integer :: nx1l,nx2l,nx3l
    integer :: iv,j,k

    real(kind=rp), allocatable :: slice(:,:,:)

    nx1l = ux1-lx1+1
    nx2l = ux2-lx2+1
    nx3l = ux3-lx3+1

    gnc(1) = nv
    gnc(2) = nx1l*mgrid%bricks(1)
    gnc(3) = nx2l*mgrid%bricks(2)

    call h5screate_simple_f(3,gnc,filespace,err)

    call h5dcreate_f(group_id,dsetname,h5%pref_dtypef,filespace,dset_id,err)

    call h5sclose_f(filespace,err)

    memcnt(1) = nv
    memcnt(2) = nx1l + 2*ghost
    memcnt(3) = nx2l + 2*ghost

    call h5screate_simple_f(3,memcnt,memspace,err)

    memcnt2(1) = nv
    memcnt2(2) = nx1l
    memcnt2(3) = nx2l

    memoff(1) = 0
    memoff(2) = ghost
    memoff(3) = ghost

    call h5sselect_hyperslab_f(memspace,H5S_SELECT_SET_F,memoff,memcnt2,err)
    
    cnt(1) = nv
    cnt(2) = nx1l 
    cnt(3) = nx2l

    off(1) = 0
    off(2) = nx1l*mgrid%coords_dd(1)
    off(3) = nx2l*mgrid%coords_dd(2)

    call h5dget_space_f(dset_id,filespace,err)

    call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,off,cnt,err)

    call h5pcreate_f(H5P_DATASET_XFER_F,plist_id,err)
    call h5pset_dxpl_mpio_f(plist_id,H5FD_MPIO_COLLECTIVE_F,err)

    allocate(slice(1:nv,lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc))
 
    if(inside_domain .eqv. .true.) then
    
     do k=lx2,ux2
      do j=lx1,ux1
       do iv=1,nv
        slice(iv,j,k) = vec(iv,j,k,ix3)
       end do
      end do
     end do

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     slice(1, &
     lbound(slice,2), &
     lbound(slice,3) ), &
     gnc,err,memspace,filespace,plist_id)
 
    else
    
     do k=lx2,ux2
      do j=lx1,ux1
       do iv=1,nv
        slice(iv,j,k) = rp1
       end do
      end do
     end do

     call h5sselect_none_f(filespace, err)
     call h5sselect_none_f(memspace, err)

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     slice(1, &
     lbound(slice,2), &
     lbound(slice,3) ), &
     gnc,err,memspace,filespace,plist_id)
 
    endif

    deallocate(slice)

    call h5sclose_f(filespace,err)
    call h5sclose_f(memspace,err)
    call h5dclose_f(dset_id,err)
    call h5pclose_f(plist_id,err)

 end subroutine hdf5_write_ndarray_x3

 subroutine hdf5_write_array_x3(h5,group_id,dsetname,mgrid,lx1,ux1,lx2,ux2,lx3,ux3,ix3,ghost,vec,inside_domain)
    type(h5_file) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*) :: dsetname
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: lx1,ux1,lx2,ux2,lx3,ux3,ix3,ghost
    real(kind=rp), dimension( &
    lx1-ghost:ux1+ghost, &
    lx2-ghost:ux2+ghost, &
    lx3-ghost:ux3+ghost), intent(in) :: vec
    logical, intent(in) :: inside_domain
    
    integer(kind=HID_T) :: dset_id,filespace,memspace,plist_id
    integer(kind=HSIZE_T), dimension(2) :: gnc,cnt,off
    integer(kind=HSIZE_T), dimension(2) :: memcnt,memcnt2,memoff
    integer :: err

    integer :: nx1l,nx2l,nx3l
    integer :: j,k

    real(kind=rp), allocatable :: slice(:,:)

    nx1l = ux1-lx1+1
    nx2l = ux2-lx2+1
    nx3l = ux3-lx3+1

    gnc(1) = nx1l*mgrid%bricks(1)
    gnc(2) = nx2l*mgrid%bricks(2)

    call h5screate_simple_f(2,gnc,filespace,err)

    call h5dcreate_f(group_id,dsetname,h5%pref_dtypef,filespace,dset_id,err)

    call h5sclose_f(filespace,err)

    memcnt(1) = nx1l + 2*ghost
    memcnt(2) = nx2l + 2*ghost

    call h5screate_simple_f(2,memcnt,memspace,err)

    memcnt2(1) = nx1l
    memcnt2(2) = nx2l

    memoff(1) = ghost
    memoff(2) = ghost

    call h5sselect_hyperslab_f(memspace,H5S_SELECT_SET_F,memoff,memcnt2,err)
    
    cnt(1) = nx1l 
    cnt(2) = nx2l

    off(1) = nx1l*mgrid%coords_dd(1)
    off(2) = nx2l*mgrid%coords_dd(2)

    call h5dget_space_f(dset_id,filespace,err)

    call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,off,cnt,err)

    call h5pcreate_f(H5P_DATASET_XFER_F,plist_id,err)
    call h5pset_dxpl_mpio_f(plist_id,H5FD_MPIO_COLLECTIVE_F,err)

    allocate(slice(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc))
 
    if(inside_domain .eqv. .true.) then
    
     do k=lx2,ux2
      do j=lx1,ux1
       slice(j,k) = vec(j,k,ix3)
      end do
     end do

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     slice( &
     lbound(slice,1), &
     lbound(slice,2) ), &
     gnc,err,memspace,filespace,plist_id)
 
    else
    
     do k=lx2,ux2
      do j=lx1,ux1
       slice(j,k) = rp1
      end do
     end do

     call h5sselect_none_f(filespace, err)
     call h5sselect_none_f(memspace, err)

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     slice( &
     lbound(slice,1), &
     lbound(slice,2) ), &
     gnc,err,memspace,filespace,plist_id)
 
    endif

    deallocate(slice)

    call h5sclose_f(filespace,err)
    call h5sclose_f(memspace,err)
    call h5dclose_f(dset_id,err)
    call h5pclose_f(plist_id,err)

 end subroutine hdf5_write_array_x3

#endif

 subroutine hdf5_write_array(h5,group_id,dsetname,mgrid,lx1,ux1,lx2,ux2,lx3,ux3,ghost,resize,apply_weights,ivol,vec)
    type(h5_file) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*) :: dsetname
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: lx1,ux1,lx2,ux2,lx3,ux3,ghost
    logical, intent(in) :: resize,apply_weights
    real(kind=rp), intent(in), dimension(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3) :: ivol
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc) :: ivol
#endif
    real(kind=rp), dimension( &
    lx1-ghost:ux1+ghost, &
    lx2-ghost:ux2+ghost, &
#if sdims_make==2
    lx3:ux3), intent(in) :: vec
#endif
#if sdims_make==3
    lx3-ghost:ux3+ghost), intent(in) :: vec
#endif

    integer(kind=HID_T) :: dset_id,filespace,memspace,plist_id
    integer(kind=HSIZE_T), dimension(3) :: gnc,cnt,off
    integer(kind=HSIZE_T), dimension(3) :: memcnt,memcnt2,memoff
    integer :: err
    real(kind=rp) :: tmp

    integer :: nx1l,nx2l,nx3l

    integer, dimension(3) :: i1r,i2r
    integer :: i,j,k,ia,ja,ka
    real(kind=rp), allocatable :: vec_aux(:,:,:)

#if defined(GEOMETRY_CARTESIAN_NONUNIFORM) || defined(GEOMETRY_3D_SPHERICAL) || defined(GEOMETRY_CUBED_SPHERE)
    real(kind=rp) :: v1=rp1,v2=rp1,v3=rp1,v4=rp1,v5=rp1,v6=rp1,v7=rp1,v8=rp1,ivol_sum=rp1
#endif

    tmp = ivol(lx1,lx1,ux1)

    if(apply_weights) then
     nx1l = 1
    end if

    nx1l = ux1-lx1+1
    nx2l = ux2-lx2+1
    nx3l = ux3-lx3+1
 
    if(resize .eqv. .true.) then
     nx1l = int(nx1l/2)
     nx2l = int(nx2l/2)
     nx3l = int(nx3l/2)
    endif

    gnc(1) = nx1l*mgrid%bricks(1)
    gnc(2) = nx2l*mgrid%bricks(2)
    gnc(3) = nx3l*mgrid%bricks(3)

    call h5screate_simple_f(3,gnc,filespace,err)

    call h5dcreate_f(group_id,dsetname,h5%pref_dtypef,filespace,dset_id,err)

    call h5sclose_f(filespace,err)

    memcnt(1) = nx1l + 2*ghost
    memcnt(2) = nx2l + 2*ghost
    memcnt(3) = nx3l
#if sdims_make==3
    memcnt(3) = nx3l + 2*ghost
#endif

    call h5screate_simple_f(3,memcnt,memspace,err)

    memcnt2(1) = nx1l
    memcnt2(2) = nx2l
    memcnt2(3) = nx3l

    memoff(1) = ghost
    memoff(2) = ghost
#if sdims_make==2
    memoff(3) = 0
#endif
#if sdims_make==3
    memoff(3) = ghost
#endif

    call h5sselect_hyperslab_f(memspace,H5S_SELECT_SET_F,memoff,memcnt2,err)
    
    cnt(1) = nx1l 
    cnt(2) = nx2l
    cnt(3) = nx3l

    off(1) = nx1l*mgrid%coords_dd(1)
    off(2) = nx2l*mgrid%coords_dd(2)
    off(3) = nx3l*mgrid%coords_dd(3)
 
    if(resize .eqv. .true.) then

     i1r(1) = int(mgrid%coords_dd(1)*nx1l+1)
     i2r(1) = int((mgrid%coords_dd(1)+1)*nx1l)

     i1r(2) = int(mgrid%coords_dd(2)*nx2l+1)
     i2r(2) = int((mgrid%coords_dd(2)+1)*nx2l)

     i1r(3) = int(mgrid%coords_dd(3)*nx3l+1)
     i2r(3) = int((mgrid%coords_dd(3)+1)*nx3l)

     allocate(vec_aux(i1r(1)-ghost:i2r(1)+ghost,i1r(2)-ghost:i2r(2)+ghost,i1r(3)-ghost:i2r(3)+ghost))

     do k=i1r(3),i2r(3)
      do j=i1r(2),i2r(2)
       do i=i1r(1),i2r(1)
   
        ia = 2*i-1
        ja = 2*j-1
        ka = 2*k-1

#if defined(GEOMETRY_CARTESIAN_NONUNIFORM) || defined(GEOMETRY_3D_SPHERICAL) || defined(GEOMETRY_CUBED_SPHERE)

        if(apply_weights .eqv. .true.) then

         v1 = rp1/ivol(ia,ja,ka)
         v2 = rp1/ivol(ia+1,ja,ka)
         v3 = rp1/ivol(ia,ja+1,ka)
         v4 = rp1/ivol(ia,ja,ka+1)
         v5 = rp1/ivol(ia+1,ja+1,ka)
         v6 = rp1/ivol(ia,ja+1,ka+1)
         v7 = rp1/ivol(ia+1,ja,ka+1)
         v8 = rp1/ivol(ia+1,ja+1,ka+1)

         ivol_sum = rp1/(v1+v2+v3+v4+v5+v6+v7+v8)

        end if

        vec_aux(i,j,k) = ivol_sum*( &
        v1*vec(ia,ja,ka) + &
        v2*vec(ia+1,ja,ka) + &
        v3*vec(ia,ja+1,ka) + &
        v4*vec(ia,ja,ka+1) + &
        v5*vec(ia+1,ja+1,ka) + &
        v6*vec(ia,ja+1,ka+1) + &
        v7*vec(ia+1,ja,ka+1) + &
        v8*vec(ia+1,ja+1,ka+1) &
        )

#else

        vec_aux(i,j,k) = 0.125_rp*( &
        vec(ia,ja,ka) + &
        vec(ia+1,ja,ka) + &
        vec(ia,ja+1,ka) + &
        vec(ia,ja,ka+1) + &
        vec(ia+1,ja+1,ka) + &
        vec(ia,ja+1,ka+1) + &
        vec(ia+1,ja,ka+1) + &
        vec(ia+1,ja+1,ka+1) &
        )

#endif

       end do
      end do 
     end do
 
    endif

    call h5dget_space_f(dset_id, filespace, err)
    call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,off,cnt,err)

    call h5pcreate_f(H5P_DATASET_XFER_F,plist_id,err)
    call h5pset_dxpl_mpio_f(plist_id,H5FD_MPIO_COLLECTIVE_F,err)

    if(resize .eqv. .true.) then

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     vec_aux( &
     lbound(vec_aux,1), &
     lbound(vec_aux,2), &
     lbound(vec_aux,3) ), &
     gnc,err,memspace,filespace,plist_id)

     deallocate(vec_aux)
  
    else

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     vec( &
     lbound(vec,1), &
     lbound(vec,2), &
     lbound(vec,3) ), &
     gnc,err,memspace,filespace,plist_id)

    endif

    call h5sclose_f(filespace,err)
    call h5sclose_f(memspace,err)
    call h5dclose_f(dset_id,err)
    call h5pclose_f(plist_id,err)

 end subroutine hdf5_write_array

 subroutine hdf5_write_ndarray(h5,group_id,dsetname,mgrid,nv,lx1,ux1,lx2,ux2,lx3,ux3,ghost,resize,apply_weights,ivol,vec)
    type(h5_file) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*) :: dsetname
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: nv
    integer, intent(in) :: lx1,ux1,lx2,ux2,lx3,ux3,ghost
    logical, intent(in) :: resize,apply_weights
    real(kind=rp), intent(in), dimension(lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc, &
#if sdims_make==2
    lx3:ux3) :: ivol
#endif
#if sdims_make==3
    lx3-ngc:ux3+ngc) :: ivol
#endif
    real(kind=rp), dimension(1:nv, &
    lx1-ghost:ux1+ghost, &
    lx2-ghost:ux2+ghost, &
#if sdims_make==2
    lx3:ux3), intent(in) :: vec
#endif
#if sdims_make==3
    lx3-ghost:ux3+ghost), intent(in) :: vec
#endif

    integer(kind=HID_T) :: dset_id,filespace,memspace,plist_id
    integer(kind=HSIZE_T), dimension(4) :: gnc,cnt,off
    integer(kind=HSIZE_T), dimension(4) :: memcnt,memcnt2,memoff
    integer :: err
    real(kind=rp) :: tmp

    integer :: nx1l,nx2l,nx3l

    integer, dimension(3) :: i1r,i2r
    integer :: iv,i,j,k,ia,ja,ka
    real(kind=rp), allocatable :: vec_aux(:,:,:,:)

#if defined(GEOMETRY_CARTESIAN_NONUNIFORM) || defined(GEOMETRY_3D_SPHERICAL) || defined(GEOMETRY_CUBED_SPHERE)
    real(kind=rp) :: v1=rp1,v2=rp1,v3=rp1,v4=rp1,v5=rp1,v6=rp1,v7=rp1,v8=rp1,ivol_sum=rp1
#endif

    tmp = ivol(lx1,lx1,ux1)

    if(apply_weights) then
     nx1l = 1
    end if

    nx1l = ux1-lx1+1
    nx2l = ux2-lx2+1
    nx3l = ux3-lx3+1
 
    if(resize .eqv. .true.) then
     nx1l = int(nx1l/2)
     nx2l = int(nx2l/2)
     nx3l = int(nx3l/2)
    endif
 
    gnc(1) = nv
    gnc(2) = nx1l*mgrid%bricks(1)
    gnc(3) = nx2l*mgrid%bricks(2)
    gnc(4) = nx3l*mgrid%bricks(3)

    call h5screate_simple_f(4,gnc,filespace,err)

    call h5dcreate_f(group_id,dsetname,h5%pref_dtypef,filespace,dset_id,err)

    call h5sclose_f(filespace,err)

    memcnt(1) = nv
    memcnt(2) = nx1l + 2*ghost
    memcnt(3) = nx2l + 2*ghost
    memcnt(4) = nx3l
#if sdims_make==3
    memcnt(4) = nx3l + 2*ghost
#endif

    call h5screate_simple_f(4,memcnt,memspace,err)

    memcnt2(1) = nv
    memcnt2(2) = nx1l
    memcnt2(3) = nx2l
    memcnt2(4) = nx3l

    memoff(1) = 0
    memoff(2) = ghost
    memoff(3) = ghost
#if sdims_make==2
    memoff(4) = 0
#endif
#if sdims_make==3
    memoff(4) = ghost
#endif

    call h5sselect_hyperslab_f(memspace,H5S_SELECT_SET_F,memoff,memcnt2,err)
    
    cnt(1) = nv
    cnt(2) = nx1l 
    cnt(3) = nx2l
    cnt(4) = nx3l

    off(1) = 0
    off(2) = nx1l*mgrid%coords_dd(1)
    off(3) = nx2l*mgrid%coords_dd(2)
    off(4) = nx3l*mgrid%coords_dd(3)

    if(resize .eqv. .true.) then

     i1r(1) = int(mgrid%coords_dd(1)*nx1l+1)
     i2r(1) = int((mgrid%coords_dd(1)+1)*nx1l)

     i1r(2) = int(mgrid%coords_dd(2)*nx2l+1)
     i2r(2) = int((mgrid%coords_dd(2)+1)*nx2l)

     i1r(3) = int(mgrid%coords_dd(3)*nx3l+1)
     i2r(3) = int((mgrid%coords_dd(3)+1)*nx3l)

     allocate(vec_aux(1:nv,i1r(1)-ghost:i2r(1)+ghost,i1r(2)-ghost:i2r(2)+ghost,i1r(3)-ghost:i2r(3)+ghost))

     do k=i1r(3),i2r(3)
      do j=i1r(2),i2r(2)
       do i=i1r(1),i2r(1)

        ia = 2*i-1
        ja = 2*j-1
        ka = 2*k-1

#if defined(GEOMETRY_CARTESIAN_NONUNIFORM) || defined(GEOMETRY_3D_SPHERICAL) || defined(GEOMETRY_CUBED_SPHERE)

        if(apply_weights .eqv. .true.) then 
         v1 = rp1/ivol(ia,ja,ka)
         v2 = rp1/ivol(ia+1,ja,ka)
         v3 = rp1/ivol(ia,ja+1,ka)
         v4 = rp1/ivol(ia,ja,ka+1)
         v5 = rp1/ivol(ia+1,ja+1,ka)
         v6 = rp1/ivol(ia,ja+1,ka+1)
         v7 = rp1/ivol(ia+1,ja,ka+1)
         v8 = rp1/ivol(ia+1,ja+1,ka+1)
         ivol_sum = rp1/(v1+v2+v3+v4+v5+v6+v7+v8)
        endif

        do iv=1,nv

         vec_aux(iv,i,j,k) = ivol_sum*( &
         v1*vec(iv,ia,ja,ka) + &
         v2*vec(iv,ia+1,ja,ka) + &
         v3*vec(iv,ia,ja+1,ka) + &
         v4*vec(iv,ia,ja,ka+1) + &
         v5*vec(iv,ia+1,ja+1,ka) + &
         v6*vec(iv,ia,ja+1,ka+1) + &
         v7*vec(iv,ia+1,ja,ka+1) + &
         v8*vec(iv,ia+1,ja+1,ka+1) &
         )

        end do

#else

        do iv=1,nv

         vec_aux(iv,i,j,k) = 0.125_rp*( &
         vec(iv,ia,ja,ka) + &
         vec(iv,ia+1,ja,ka) + &
         vec(iv,ia,ja+1,ka) + &
         vec(iv,ia,ja,ka+1) + &
         vec(iv,ia+1,ja+1,ka) + &
         vec(iv,ia,ja+1,ka+1) + &
         vec(iv,ia+1,ja,ka+1) + &
         vec(iv,ia+1,ja+1,ka+1) &
         )

        end do

#endif

       end do
      end do 
     end do
 
    end if

    call h5dget_space_f(dset_id,filespace,err)
    call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,off,cnt,err)

    call h5pcreate_f(H5P_DATASET_XFER_F,plist_id,err)
    call h5pset_dxpl_mpio_f(plist_id,H5FD_MPIO_COLLECTIVE_F,err)

    if(resize .eqv. .true.) then

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     vec_aux(1, &
     lbound(vec_aux,2), &
     lbound(vec_aux,3), &
     lbound(vec_aux,4) ), &
     gnc,err,memspace,filespace,plist_id)

     deallocate(vec_aux)

    else

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     vec(1, &
     lbound(vec,2), &
     lbound(vec,3), &
     lbound(vec,4) ), &
     gnc,err,memspace,filespace,plist_id)
 
    end if

    call h5sclose_f(filespace,err)
    call h5sclose_f(memspace,err)
    call h5dclose_f(dset_id,err)
    call h5pclose_f(plist_id,err)

 end subroutine hdf5_write_ndarray

#ifdef SAVE_SPECIES_FLUXES

 subroutine hdf5_write_nd2array(h5,group_id,dsetname,mgrid,nv,nr,lx1,ux1,lx2,ux2,lx3,ux3,ghost,resize,vec)
    type(h5_file) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*) :: dsetname
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: nv,nr
    integer, intent(in) :: lx1,ux1,lx2,ux2,lx3,ux3,ghost
    logical, intent(in) :: resize
    real(kind=rp), dimension(1:nv,1:nr, &
    lx1-ghost:ux1+ghost, &
    lx2-ghost:ux2+ghost, &
#if sdims_make==2
    lx3:ux3), intent(in) :: vec
#endif
#if sdims_make==3
    lx3-ghost:ux3+ghost), intent(in) :: vec
#endif
    integer(kind=HID_T) :: dset_id,filespace,memspace,plist_id
    integer(kind=HSIZE_T), dimension(5) :: gnc,cnt,off
    integer(kind=HSIZE_T), dimension(5) :: memcnt,memcnt2,memoff
    integer :: err

    integer :: nx1l,nx2l,nx3l

    integer, dimension(3) :: i1r,i2r
    integer :: iv,ir,i,j,k,ia,ja,ka
    real(kind=rp), allocatable :: vec_aux(:,:,:,:,:)

    nx1l = ux1-lx1+1
    nx2l = ux2-lx2+1
    nx3l = ux3-lx3+1
 
    if(resize .eqv. .true.) then
     nx1l = int(nx1l/2)
     nx2l = int(nx2l/2)
     nx3l = int(nx3l/2)
    endif
 
    gnc(1) = nv
    gnc(2) = nr
    gnc(3) = nx1l*mgrid%bricks(1)
    gnc(4) = nx2l*mgrid%bricks(2)
    gnc(5) = nx3l*mgrid%bricks(3)

    call h5screate_simple_f(5,gnc,filespace,err)

    call h5dcreate_f(group_id,dsetname,h5%pref_dtypef,filespace,dset_id,err)

    call h5sclose_f(filespace,err)

    memcnt(1) = nv
    memcnt(2) = nr
    memcnt(3) = nx1l + 2*ghost
    memcnt(4) = nx2l + 2*ghost
    memcnt(5) = nx3l
#if sdims_make==3
    memcnt(5) = nx3l + 2*ghost
#endif

    call h5screate_simple_f(5,memcnt,memspace,err)

    memcnt2(1) = nv
    memcnt2(2) = nr
    memcnt2(3) = nx1l
    memcnt2(4) = nx2l
    memcnt2(5) = nx3l

    memoff(1) = 0
    memoff(2) = 0
    memoff(3) = ghost
    memoff(4) = ghost
#if sdims_make==2
    memoff(5) = 0
#endif
#if sdims_make==3
    memoff(5) = ghost
#endif

    call h5sselect_hyperslab_f(memspace,H5S_SELECT_SET_F,memoff,memcnt2,err)
    
    cnt(1) = nv
    cnt(2) = nr
    cnt(3) = nx1l 
    cnt(4) = nx2l
    cnt(5) = nx3l

    off(1) = 0
    off(2) = 0
    off(3) = nx1l*mgrid%coords_dd(1)
    off(4) = nx2l*mgrid%coords_dd(2)
    off(5) = nx3l*mgrid%coords_dd(3)

    if(resize .eqv. .true.) then

     i1r(1) = int(mgrid%coords_dd(1)*nx1l+1)
     i2r(1) = int((mgrid%coords_dd(1)+1)*nx1l)

     i1r(2) = int(mgrid%coords_dd(2)*nx2l+1)
     i2r(2) = int((mgrid%coords_dd(2)+1)*nx2l)

     i1r(3) = int(mgrid%coords_dd(3)*nx3l+1)
     i2r(3) = int((mgrid%coords_dd(3)+1)*nx3l)

     allocate(vec_aux(1:nv,1:nr,i1r(1)-ghost:i2r(1)+ghost,i1r(2)-ghost:i2r(2)+ghost,i1r(3)-ghost:i2r(3)+ghost))

     do k=i1r(3),i2r(3)
      do j=i1r(2),i2r(2)
       do i=i1r(1),i2r(1)
        do ir=1,nr
         do iv=1,nv

          ia = 2*i-1
          ja = 2*j-1
          ka = 2*k-1

          vec_aux(iv,ir,i,j,k) = 0.125_rp*( &
          vec(iv,ir,ia,ja,ka) + &
          vec(iv,ir,ia+1,ja,ka) + &
          vec(iv,ir,ia,ja+1,ka) + &
          vec(iv,ir,ia,ja,ka+1) + &
          vec(iv,ir,ia+1,ja+1,ka) + &
          vec(iv,ir,ia,ja+1,ka+1) + &
          vec(iv,ir,ia+1,ja,ka+1) + &
          vec(iv,ir,ia+1,ja+1,ka+1) &
          )

         end do
        end do
       end do
      end do 
     end do
 
    end if

    call h5dget_space_f(dset_id,filespace,err)
    call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,off,cnt,err)

    call h5pcreate_f(H5P_DATASET_XFER_F,plist_id,err)
    call h5pset_dxpl_mpio_f(plist_id,H5FD_MPIO_COLLECTIVE_F,err)

    if(resize .eqv. .true.) then

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     vec_aux(1, &
     1, &
     lbound(vec_aux,3), &
     lbound(vec_aux,4), &
     lbound(vec_aux,5) ), &
     gnc,err,memspace,filespace,plist_id)

     deallocate(vec_aux)

    else

     call h5dwrite_f(dset_id,h5%pref_dtypef, &
     vec(1, &
     1, &
     lbound(vec,3), &
     lbound(vec,4), &
     lbound(vec,5) ), &
     gnc,err,memspace,filespace,plist_id)
 
    end if

    call h5sclose_f(filespace,err)
    call h5sclose_f(memspace,err)
    call h5dclose_f(dset_id,err)
    call h5pclose_f(plist_id,err)

 end subroutine hdf5_write_nd2array

#endif

 subroutine hdf5_annotate_rp(h5,id,key,val)
    type(h5_file) :: h5
    integer(kind=HID_T), intent(in) :: id
    character(len=*), intent(in) :: key
    real(kind=rp), intent(in) :: val

    integer(kind=HSIZE_T),dimension(1) :: dims
    integer :: err
    integer(kind=HID_T) :: sid,aid

    call h5screate_f(H5S_SCALAR_F,sid,err)
    call h5dcreate_f(id,key,h5%pref_dtypef,sid,aid,err)
    call h5dwrite_f(aid,h5%pref_dtypef,val,dims,err)
    call h5dclose_f(aid,err)
    call h5sclose_f(sid,err)

 end subroutine hdf5_annotate_rp

 subroutine hdf5_annotate_array_rp(h5,id,key,val)
      type(h5_file) :: h5
      integer(kind=HID_T), intent(in) :: id
      character(len=*), intent(in) :: key
      real(kind=rp), dimension(:), intent(in) :: val

      integer(kind=HSIZE_T),dimension(1) :: dims
      integer :: err
      integer(kind=HID_T) :: sid,aid

      dims(1) = size(val)
      call h5screate_simple_f(1,dims,sid,err)
      call h5dcreate_f(id,key,h5%pref_dtypef,sid,aid,err)
      call h5dwrite_f(aid,h5%pref_dtypef,val,dims,err)
      call h5dclose_f(aid,err)
      call h5sclose_f(sid,err)

 end subroutine hdf5_annotate_array_rp

 subroutine hdf5_annotate_array_ip(h5,id,key,val)
   type(h5_file) :: h5
   integer(kind=HID_T), intent(in) :: id
   character(len=*), intent(in) :: key
   integer, dimension(:), intent(in) :: val

   integer(kind=HSIZE_T), dimension(1) :: dims
   integer :: err
   integer(kind=HID_T) :: sid, aid

   dims(1) = size(val)
   call h5screate_simple_f(1,dims,sid,err)
   call h5dcreate_f(id,key,h5%pref_dtypei,sid,aid,err)
   call h5dwrite_f(aid,h5%pref_dtypei,val,dims,err)
   call h5dclose_f(aid,err)
   call h5sclose_f(sid,err)

 end subroutine hdf5_annotate_array_ip

 subroutine hdf5_annotate_string(id,key,val)
    integer(kind=HID_T), intent(in) :: id
    character(len=*), intent(in) :: key,val

    integer(kind=HSIZE_T),dimension(1) :: dims
    integer :: err
    integer(kind=HID_T) :: sid,aid,tid

    call h5tcopy_f (H5T_NATIVE_CHARACTER,tid,err)
    call h5tset_size_f(tid,int(len(trim(val)),kind=SIZE_T),err)
    call h5screate_f(H5S_SCALAR_F,sid,err)
    call h5acreate_f(id,key,tid,sid,aid,err)
    dims(1)=1
    call h5awrite_f(aid,tid,trim(val),dims,err)
    call h5aclose_f(aid,err)
    call h5sclose_f(sid,err)
    call h5tclose_f(tid,err)

 end subroutine hdf5_annotate_string

 subroutine hdf5_annotate_array_string(id,key,val,n)
    integer(HID_T), intent(in) :: id
    character(len=*), intent(in) :: key
    character(len=filename_size), dimension(*), intent(in) :: val
    integer, intent(in) :: n 

    integer :: err
    integer(HID_T) :: sid, aid, tid
    integer(HSIZE_T), dimension(1) :: dims
    integer(SIZE_T) :: strlen

    strlen = filename_size 
    dims(1) = n

    call h5tcopy_f(H5T_NATIVE_CHARACTER,tid,err)
    call h5tset_size_f(tid,strlen,err)
    call h5screate_simple_f(1,dims,sid,err)
    call h5acreate_f(id,key,tid,sid,aid,err)
    call h5awrite_f(aid,tid,val,dims,err)
    call h5aclose_f(aid,err)
    call h5sclose_f(sid,err)
    call h5tclose_f(tid,err)

 end subroutine hdf5_annotate_array_string

 subroutine hdf5_annotate_ip(h5,id,key,val)
    type(h5_file) :: h5 
    integer(kind=HID_T), intent(in) :: id
    character(len=*), intent(in) :: key
    integer, intent(in) :: val
        
    integer(kind=HSIZE_T),dimension(1) :: dims
    integer :: err
    integer(kind=HID_T) :: sid,aid
   
    call h5screate_f(H5S_SCALAR_F,sid,err)
    call h5dcreate_f(id, key, h5%pref_dtypei, sid, aid, err)
    call h5dwrite_f(aid,h5%pref_dtypei,val,dims,err)
    call h5dclose_f(aid,err)
    call h5sclose_f(sid,err)

 end subroutine hdf5_annotate_ip

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! MAIN LOOP
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 subroutine time_loop(mgrid,lgrid)
    type(mpigrid), intent(inout) :: mgrid
    type(locgrid), intent(inout) :: lgrid

    real(kind=rp) :: wct_hydro,wcti_hydro,wctf_hydro, &
    wctoi,wctof,wctg,step0,temp_max,temp_max_comm
#ifdef RESTART_LAST
    integer :: step_tmp(1)
#endif
    integer :: ierr,iv,res_nr,iflush,max_T_met
    integer :: i,j,k,ipr,iter
    integer :: lx1,ux1,lx2,ux2,lx3,ux3
    real(kind=rp) :: abar,eint,gm,gmm1,igmm1,p,rho,sound,sound2,T,ye,zbar,dp_drho,dp_deps
    real(kind=rp) :: mu,inv_mu,inv_abar,T2,T3,T4,dRes_dT,tmp,Res0,Res_prad,cv,tmp1,tmp2

#ifdef GEOMETRY_2D_POLAR
    real(kind=rp) :: r,rm,rpl,dr
    r = rp0
    rm = rp0
    rpl = rp0
    dr = rp0
#endif

#ifdef GEOMETRY_2D_SPHERICAL
    real(kind=rp) :: r,sin_theta,rm,rpl,dr
    r = rp0
    sin_theta = rp0
    rm = rp0
    rpl = rp0
    dr = rp0
#endif

#ifdef GEOMETRY_3D_SPHERICAL
    real(kind=rp) :: r,sin_theta,rm,rpl,dr
    r = rp0
    sin_theta = rp0
    rm = rp0
    rpl = rp0
    dr = rp0
#endif

    temp_max = rp0
    temp_max_comm = rp0
    
    ierr = idummy
    iv = idummy
    res_nr = idummy
    iflush = idummy

    ipr = idummy
    iter = idummy

    abar = rp0
    eint = rp0
    gm = lgrid%gm
    gmm1 = gm-rp1
    igmm1 = rp1/gmm1
    p = rp0
    rho = rp0
    sound = rp0
    sound2 = rp0
    T = rp0
    ye = rp0
    zbar = rp0
    dp_drho = rp0
    dp_deps = rp0

    mu = lgrid%mu
    inv_mu = rp1/mu
    inv_abar = rp0
    T2 = rp0
    T3 = rp0
    T4 = rp0
    dRes_dT = rp0
    tmp = rp0
    Res0 = rp0
    Res_prad = rp0
    cv = rp0
    tmp1 = rp0
    tmp2 = rp0

    lx1 = mgrid%i1(1)
    ux1 = mgrid%i2(1)
    lx2 = mgrid%i1(2)
    ux2 = mgrid%i2(2)
    lx3 = mgrid%i1(3)
    ux3 = mgrid%i2(3)

    do k=mgrid%i1(3),mgrid%i2(3)
     do j=mgrid%i1(2),mgrid%i2(2)
      do i=mgrid%i1(1),mgrid%i2(1)

#ifdef GEOMETRY_CARTESIAN_UNIFORM
#if sdims_make==2
         tmp = lgrid%dx1*lgrid%dx2
#endif
#if sdims_make==3
         tmp = lgrid%dx1*lgrid%dx2*lgrid%dx3
#endif
#endif

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
#if sdims_make==2
         tmp = &
         (lgrid%coords_x1(1,i+1,j,k)-lgrid%coords_x1(1,i,j,k))* &
         (lgrid%coords_x2(2,i,j+1,k)-lgrid%coords_x2(2,i,j,k))
#endif
#if sdims_make==3
         tmp = &
         (lgrid%coords_x1(1,i+1,j,k)-lgrid%coords_x1(1,i,j,k))* &
         (lgrid%coords_x2(2,i,j+1,k)-lgrid%coords_x2(2,i,j,k))* &
         (lgrid%coords_x3(3,i,j,k+1)-lgrid%coords_x3(3,i,j,k))
#endif
#endif

#ifdef GEOMETRY_2D_POLAR
         r = lgrid%r(i,j,k)
         rm = lgrid%r_x1(i,j,k)
         rpl = lgrid%r_x1(i+1,j,k)
         dr = rpl-rm
         tmp = r*dr*lgrid%dx2
#endif

#ifdef GEOMETRY_2D_SPHERICAL
         r = lgrid%r(i,j,k)
         sin_theta = lgrid%sin_theta(i,j,k)
         rm = lgrid%r_x1(i,j,k)
         rpl = lgrid%r_x1(i+1,j,k)
         dr = rpl-rm
         tmp = r*r*sin_theta*dr*lgrid%dx2*rp2*CONST_PI
#endif

#ifdef GEOMETRY_3D_SPHERICAL
         r = lgrid%r(i,j,k)
         sin_theta = lgrid%sin_theta(i,j,k)
         rm = lgrid%r_x1(i,j,k)
         rpl = lgrid%r_x1(i+1,j,k)
         dr = rpl-rm
         tmp = r*r*sin_theta*dr*lgrid%dx2*lgrid%dx3
#endif

#ifndef GEOMETRY_CUBED_SPHERE
         lgrid%ivol(i,j,k) = rp1/tmp
#endif

      end do
     end do
    end do

#ifdef FIX_BFIELD_AT_X1
    do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
     do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
      do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)
       do iv=1,nvars
        lgrid%res(iv,i,j,k) = rp0
       end do
      end do
     end do
    end do
#endif

#ifdef USE_POINT_PROBES
    
    do ipr=1,nprobes
     lgrid%pp_inside_domain(ipr) = .false.
    end do

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        do ipr=1,nprobes
         
         if( &
         (lgrid%pp_index(ipr,1)==i) .and. &
         (lgrid%pp_index(ipr,2)==j) .and. &
         (lgrid%pp_index(ipr,3)==k) ) then
          
           lgrid%pp_inside_domain(ipr) = .true.

         endif

        end do

      end do
     end do
    end do

#endif

#ifdef SAVE_PLANES

#if nplanes_x1_make>0
    do ipr=1,nplanes_x1
     lgrid%planes_x1_inside_domain(ipr) = .false.
    end do
#endif

#if nplanes_x2_make>0
    do ipr=1,nplanes_x2
     lgrid%planes_x2_inside_domain(ipr) = .false.
    end do
#endif

#if nplanes_x3_make>0
    do ipr=1,nplanes_x3
     lgrid%planes_x3_inside_domain(ipr) = .false.
    end do
#endif

#if nplanes_x1_make>0
    do i=lx1,ux1
     do ipr=1,nplanes_x1
      if(lgrid%planes_x1_index(ipr)==i) lgrid%planes_x1_inside_domain(ipr) = .true.
     end do
    end do
#endif

#if nplanes_x2_make>0
    do j=lx2,ux2
     do ipr=1,nplanes_x2
      if(lgrid%planes_x2_index(ipr)==j) lgrid%planes_x2_inside_domain(ipr) = .true.
     end do
    end do
#endif

#if nplanes_x3_make>0
    do k=lx3,ux3
     do ipr=1,nplanes_x3
      if(lgrid%planes_x3_index(ipr)==k) lgrid%planes_x3_inside_domain(ipr) = .true.
     end do
    end do
#endif

#endif

#ifdef RESTART_LAST

    if(mgrid%rankl==master_rank) then

     open(iunit,file='restart_info.txt',status='unknown',action='read')

     do 

       read(iunit,'(I10.10)',iostat=ierr) res_nr
       if(ierr/=0) exit

     end do

     close(iunit)

     if(res_nr>0) lgrid%step = int(res_nr)

    endif

    step_tmp(1) = lgrid%step
    call mpi_bcast(step_tmp,1,MPI_INTEGER,master_rank,mgrid%comm_cart,ierr)
    lgrid%step = step_tmp(1)
    
    if(lgrid%step>0) then
      call mpi_barrier(mgrid%comm_cart,ierr)
      call read_restart(mgrid,lgrid)
    endif

#endif
 
    step0 = lgrid%step

#ifdef USE_MHD

#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       tmp = lgrid%cm(i,j,k)
       tmp1 = rp1-tmp
       lgrid%b_cc(1,i,j,k) = tmp1*lgrid%b_x1(i+1,j,k)+tmp*lgrid%b_x1(i,j,k)
      end do
     end do
    end do
#else
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       lgrid%b_cc(1,i,j,k) = rph*(lgrid%b_x1(i+1,j,k)+lgrid%b_x1(i,j,k))
      end do
     end do
    end do
#endif

#if defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       tmp = lgrid%dm(i,j,k)
       tmp1 = rp1-tmp
       lgrid%b_cc(2,i,j,k) = tmp1*lgrid%b_x2(i,j+1,k)+tmp*lgrid%b_x2(i,j,k)
      end do
     end do
    end do
#else
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       lgrid%b_cc(2,i,j,k) = rph*(lgrid%b_x2(i,j+1,k)+lgrid%b_x2(i,j,k))
      end do
     end do
    end do
#endif

#if sdims_make==3
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       lgrid%b_cc(3,i,j,k) = rph*(lgrid%b_x3(i,j,k+1)+lgrid%b_x3(i,j,k))
      end do
     end do
    end do
#endif

#ifdef USE_INTERNAL_BOUNDARIES

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1+1
        
        ipr = lgrid%is_solid(i-1,j,k)+lgrid%is_solid(i,j,k)
        if(ipr>0) then
         if(ipr==1) then
          lgrid%fac_x1(i,j,k) = rp1
         else
          lgrid%fac_x1(i,j,k) = rp0
         endif
        else
         lgrid%fac_x1(i,j,k) = rp1
        endif

      end do
     end do
    end do   

    do k=lx3,ux3
     do j=lx2,ux2+1
      do i=lx1,ux1
        
        ipr = lgrid%is_solid(i,j-1,k)+lgrid%is_solid(i,j,k)
        if(ipr>0) then
         if(ipr==1) then
          lgrid%fac_x2(i,j,k) = rp1
         else
          lgrid%fac_x2(i,j,k) = rp0
         endif
        else
         lgrid%fac_x2(i,j,k) = rp1
        endif

      end do
     end do
    end do   

#if sdims_make==3

    do k=lx3,ux3+1
     do j=lx2,ux2
      do i=lx1,ux1
        
        ipr = lgrid%is_solid(i,j,k-1)+lgrid%is_solid(i,j,k)
        if(ipr>0) then
         if(ipr==1) then
          lgrid%fac_x3(i,j,k) = rp1
         else
          lgrid%fac_x3(i,j,k) = rp0
         endif
        else
         lgrid%fac_x3(i,j,k) = rp1
        endif

      end do
     end do
    end do   

#endif
        
    do k=lx3,ux3
     do j=lx2-1,ux2+2
      do i=lx1-1,ux1+2
        
        ipr = lgrid%is_solid(i-1,j,k)+lgrid%is_solid(i,j,k)+lgrid%is_solid(i,j-1,k)+lgrid%is_solid(i-1,j-1,k)
        if(ipr>0) then
         if(ipr==4) then
          lgrid%is_solid_cor_x3(i,j,k) = 1
         else
          lgrid%is_solid_cor_x3(i,j,k) = 2
         endif
        else
         lgrid%is_solid_cor_x3(i,j,k) = 0
        endif

      end do
     end do
    end do   

    do k=lx3,ux3
     do j=lx2,ux2+1
      do i=lx1,ux1+1
        
        if(lgrid%is_solid_cor_x3(i,j,k)>0) then
         lgrid%fac_cor_x3(i,j,k) = rp0
        else
         lgrid%fac_cor_x3(i,j,k) = oquart
        endif

      end do
     end do
    end do   

#if sdims_make==3

    do k=lx3-1,ux3+2
     do j=lx2-1,ux2+2
      do i=lx1,ux1
        
        ipr = lgrid%is_solid(i,j-1,k)+lgrid%is_solid(i,j,k)+lgrid%is_solid(i,j,k-1)+lgrid%is_solid(i,j-1,k-1)
        if(ipr>0) then
         if(ipr==4) then
          lgrid%is_solid_cor_x1(i,j,k) = 1
         else
          lgrid%is_solid_cor_x1(i,j,k) = 2
         endif
        else
         lgrid%is_solid_cor_x1(i,j,k) = 0
        endif

      end do
     end do
    end do   

    do k=lx3-1,ux3+2
     do j=lx2,ux2
      do i=lx1-1,ux1+2
        
        ipr = lgrid%is_solid(i-1,j,k)+lgrid%is_solid(i,j,k)+lgrid%is_solid(i,j,k-1)+lgrid%is_solid(i-1,j,k-1)
        if(ipr>0) then
         if(ipr==4) then
          lgrid%is_solid_cor_x2(i,j,k) = 1
         else
          lgrid%is_solid_cor_x2(i,j,k) = 2
         endif
        else
         lgrid%is_solid_cor_x2(i,j,k) = 0
        endif

      end do
     end do
    end do   

    do k=lx3,ux3+1
     do j=lx2,ux2+1
      do i=lx1,ux1
        
        if(lgrid%is_solid_cor_x1(i,j,k)>0) then
         lgrid%fac_cor_x1(i,j,k) = rp0
        else
         lgrid%fac_cor_x1(i,j,k) = oquart
        endif

      end do
     end do
    end do   

    do k=lx3,ux3+1
     do j=lx2,ux2
      do i=lx1,ux1+1
         
        if(lgrid%is_solid_cor_x2(i,j,k)>0) then
         lgrid%fac_cor_x2(i,j,k) = rp0
        else
         lgrid%fac_cor_x2(i,j,k) = oquart
        endif

      end do
     end do
    end do   

#endif

#endif

#endif
    
#ifdef USE_RESISTIVITY

    do k=lx3,ux3
     do j=lx2,ux2+1
      do i=lx1,ux1+1
         lgrid%eta_cor_x3(i,j,k) = oquart*( &
         lgrid%eta(i-1,j-1,k)+lgrid%eta(i,j,k)+lgrid%eta(i-1,j,k)+lgrid%eta(i,j-1,k) )
      end do
     end do
    end do   

#if sdims_make==3

    do k=lx3,ux3+1
     do j=lx2,ux2+1
      do i=lx1,ux1
         lgrid%eta_cor_x1(i,j,k) = oquart*( &
         lgrid%eta(i,j-1,k-1)+lgrid%eta(i,j,k)+lgrid%eta(i,j-1,k)+lgrid%eta(i,j,k-1) )
      end do
     end do
    end do   

    do k=lx3,ux3+1
     do j=lx2,ux2
      do i=lx1,ux1+1
         lgrid%eta_cor_x2(i,j,k) = oquart*( &
         lgrid%eta(i-1,j,k-1)+lgrid%eta(i,j,k)+lgrid%eta(i-1,j,k)+lgrid%eta(i,j,k-1) )
      end do
     end do
    end do   

#endif

    deallocate(lgrid%eta)

#endif

    if(lgrid%step==0) then 

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        rho = lgrid%prim(i_rho,i,j,k)

#ifdef HELMHOLTZ_EOS
#ifdef ADVECT_YE_IABAR
        abar = rp1/lgrid%prim(i_iabar,i,j,k)
        ye = lgrid%prim(i_ye,i,j,k)
#endif
#ifdef ADVECT_SPECIES
        inv_abar = rp0
        ye = rp0
        do iv=1,nspecies
         tmp = lgrid%prim(i_as1+iv-1,i,j,k)/lgrid%A(iv)
         inv_abar = inv_abar + tmp
         ye = ye + tmp*lgrid%Z(iv)
        end do
        abar = rp1/inv_abar
#endif
        zbar = abar*ye
#else
#ifdef ADVECT_YE_IABAR
        ye = lgrid%prim(i_ye,i,j,k)
        abar = rp1/lgrid%prim(i_iabar,i,j,k)
        inv_mu =  (ye*abar+rp1)/abar
#endif
#ifdef ADVECT_SPECIES
        inv_mu = rp0
        do iv=1,nspecies
         inv_mu = inv_mu + lgrid%prim(i_as1+iv-1,i,j,k)*(lgrid%Z(iv)+rp1)/lgrid%A(iv)
        end do
#endif
#endif

        p = lgrid%prim(i_p,i,j,k)

#ifdef USE_PRAD
        tmp = rho*CONST_RGAS*inv_mu
        T = lgrid%temp(i,j,k)
        Res_prad = -rp1
        do iter=1,250
         Res0 = Res_prad
         T2 = T*T
         T3 = T2*T
         T4 = T3*T
         Res_prad = CONST_RAD*othird*T4 + tmp*T - p
         if (abs(Res_prad/p) < em14) exit
         if ((abs(Res0 - Res_prad)/abs(Res0) < em15) .and. iter>1) then
           write(*,*)'temp->eint, EoS gas+radiation, RN stalled, ','cell=(',i,j,k,')'
           exit
         end if
         dRes_dT = fthirds*CONST_RAD*T3 + tmp
         T = T - Res_prad/dRes_dT
        end do
        T2 = T*T
        T3 = T2*T
        T4 = T3*T
        eint = tmp*T*igmm1 + CONST_RAD*T4
#ifdef USE_FASTEOS
        mu = rp1/inv_mu

        tmp1 = CONST_RAD*mu*T3
        tmp2 = CONST_RGAS*rho

        dp_drho = fthirds * &
        CONST_RAD*CONST_RGAS*T4*(rp3*gm-rp4) / &
        (rp4*tmp1*gmm1+tmp2)

        dp_deps = gmm1 * &
        (rp4*tmp1+rp3*tmp2) / &
        (rp12*tmp1*gmm1+rp3*tmp2)

        sound2 = dp_drho+dp_deps*(p+eint)/rho
        lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
        lgrid%gammaf(i_gammac,i,j,k) = sound2*rho/p
#endif
#elif defined(HELMHOLTZ_EOS)
        T = lgrid%temp(i,j,k)
#ifdef USE_FASTEOS       
        call helm_rhoP_given(rho,p,abar,zbar,T,eint,sound,.true.)
        eint = rho*eint
        lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
        lgrid%gammaf(i_gammac,i,j,k) = sound*sound*rho/p
#else
        call helm_rhoP_given(rho,p,abar,zbar,T,eint,sound,.false.)
        eint = rho*eint
#endif
#elif defined(PIG_EOS)
        T = lgrid%temp(i,j,k)
#ifdef USE_FASTEOS       
        call pig_rhoP_given(rho,p,T,eint,sound,.true.)
        eint = rho*eint
        lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
        lgrid%gammaf(i_gammac,i,j,k) = sound*sound*rho/p
#else
        call pig_rhoP_given(rho,p,T,eint,sound,.false.)
        eint = rho*eint
#endif
#else
        T =  p/(CONST_RGAS*rho*inv_mu)
        eint = p*igmm1
#endif

        lgrid%eint(i,j,k) = eint
        lgrid%temp(i,j,k) = T

       end do
      end do
     end do 

     call mpi_barrier(mgrid%comm_cart,ierr)
     call compute_hyperbolic_dt(mgrid,lgrid) 

#ifdef SAVE_PLANES
     lgrid%planes_dstep_dump = nint(planes_dt_dump/lgrid%dt)
#endif

#ifdef SAVE_SPHERICAL_PROJECTIONS
     lgrid%spj_dstep_dump = nint(spj_dt_dump/lgrid%dt)
#endif

#ifdef USE_GRAVITY
#ifdef USE_GRAVITY_SOLVER
     call gravity_solver(mgrid,lgrid)
#endif
#ifdef USE_MONOPOLE_GRAVITY
     call monopole_gravity(mgrid,lgrid,int(nx1/2))
#endif
#endif 

    else

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        rho = lgrid%prim(i_rho,i,j,k)

#ifdef HELMHOLTZ_EOS
#ifdef ADVECT_YE_IABAR
        abar = rp1/lgrid%prim(i_iabar,i,j,k)
        ye = lgrid%prim(i_ye,i,j,k)
#endif
#ifdef ADVECT_SPECIES
        inv_abar = rp0
        ye = rp0
        do iv=1,nspecies
         tmp = lgrid%prim(i_as1+iv-1,i,j,k)/lgrid%A(iv)
         inv_abar = inv_abar + tmp
         ye = ye + tmp*lgrid%Z(iv)
        end do
        abar = rp1/inv_abar
#endif
        zbar = abar*ye
#else
#ifdef ADVECT_YE_IABAR
        ye = lgrid%prim(i_ye,i,j,k)
        abar = rp1/lgrid%prim(i_iabar,i,j,k)
        inv_mu =  (ye*abar+rp1)/abar
#endif
#ifdef ADVECT_SPECIES
        inv_mu = rp0
        do iv=1,nspecies
         inv_mu = inv_mu + lgrid%prim(i_as1+iv-1,i,j,k)*(lgrid%Z(iv)+rp1)/lgrid%A(iv)
        end do
#endif
#endif

        p = lgrid%prim(i_p,i,j,k)

#ifdef USE_PRAD
        T = lgrid%temp(i,j,k)
        T2 = T*T
        T3 = T2*T
        T4 = T3*T
        eint = CONST_RGAS*rho*T*igmm1*inv_mu + CONST_RAD*T4
#ifdef USE_FASTEOS
        mu = rp1/inv_mu

        tmp1 = CONST_RAD*mu*T3
        tmp2 = CONST_RGAS*rho

        dp_drho = fthirds * &
        CONST_RAD*CONST_RGAS*T4*(rp3*gm-rp4) / &
        (rp4*tmp1*gmm1+tmp2)

        dp_deps = gmm1 * &
        (rp4*tmp1+rp3*tmp2) / &
        (rp12*tmp1*gmm1+rp3*tmp2)

        sound2 = dp_drho+dp_deps*(p+eint)/rho
        lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
        lgrid%gammaf(i_gammac,i,j,k) = sound2*rho/p
#endif
#elif defined(HELMHOLTZ_EOS)
        T = lgrid%temp(i,j,k)
        call helm_rhoT_given_full(rho,T,abar,zbar,p,eint,sound,cv)                                                   
        eint = rho*eint 
#ifdef USE_FASTEOS
        lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
        lgrid%gammaf(i_gammac,i,j,k) = sound*sound*rho/p
#endif
#elif defined(PIG_EOS)
        T = lgrid%temp(i,j,k)
        call pig_rhoT_given_full(rho,T,p,eint,sound,cv)                                                   
        eint = rho*eint 
#ifdef USE_FASTEOS
        lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
        lgrid%gammaf(i_gammac,i,j,k) = sound*sound*rho/p
#endif
#else
        eint = p*igmm1
#endif

        lgrid%eint(i,j,k) = eint
   
       end do
      end do
     end do 

    endif

#ifdef USE_TIMMES_KAPPA
    call compute_timmes_kappa(lgrid)
#endif

#ifdef THERMAL_DIFFUSION_STS
#ifndef EVALUATE_PARABOLIC_TIMESTEP
    if(lgrid%step==0) then
     call mpi_barrier(mgrid%comm_cart,ierr)
     call compute_parabolic_dt(mgrid,lgrid)
    endif
#endif
#endif

    wct_hydro = rp0
    call mpi_barrier(mgrid%comm_cart,ierr)
    wcti_hydro = get_wtime(mgrid)
    wctg = wcti_hydro-mgrid%wctgi

    max_T_met = 0

    do while((lgrid%time<tmax).and.(lgrid%step<stepmax).and.(wctg<wctmax).and.(max_T_met<1))

#ifdef USE_POINT_PROBES
 
       iflush = iflush + 1
          
       do ipr=1,nprobes

        if(lgrid%pp_inside_domain(ipr).eqv..true.) then
          
          do iv=1,i_p
           lgrid%pp_state(ipr,iflush,iv) = & 
           lgrid%prim(iv,lgrid%pp_index(ipr,1),lgrid%pp_index(ipr,2),lgrid%pp_index(ipr,3))
          end do
          
#ifdef USE_MHD
#if sdims_make==2
          lgrid%pp_state(ipr,iflush,i_p+1) = lgrid%b_cc(1,lgrid%pp_index(ipr,1),lgrid%pp_index(ipr,2),lgrid%pp_index(ipr,3))
          lgrid%pp_state(ipr,iflush,i_p+2) = lgrid%b_cc(2,lgrid%pp_index(ipr,1),lgrid%pp_index(ipr,2),lgrid%pp_index(ipr,3))
          lgrid%pp_state(ipr,iflush,i_p+3) = lgrid%temp(lgrid%pp_index(ipr,1),lgrid%pp_index(ipr,2),lgrid%pp_index(ipr,3))
          lgrid%pp_state(ipr,iflush,i_p+4) = lgrid%time
#endif
#if sdims_make==3
          lgrid%pp_state(ipr,iflush,i_p+1) = lgrid%b_cc(1,lgrid%pp_index(ipr,1),lgrid%pp_index(ipr,2),lgrid%pp_index(ipr,3))
          lgrid%pp_state(ipr,iflush,i_p+2) = lgrid%b_cc(2,lgrid%pp_index(ipr,1),lgrid%pp_index(ipr,2),lgrid%pp_index(ipr,3))
          lgrid%pp_state(ipr,iflush,i_p+3) = lgrid%b_cc(3,lgrid%pp_index(ipr,1),lgrid%pp_index(ipr,2),lgrid%pp_index(ipr,3))
          lgrid%pp_state(ipr,iflush,i_p+4) = lgrid%temp(lgrid%pp_index(ipr,1),lgrid%pp_index(ipr,2),lgrid%pp_index(ipr,3))
          lgrid%pp_state(ipr,iflush,i_p+5) = lgrid%time
#endif
#else
          lgrid%pp_state(ipr,iflush,i_p+1) = lgrid%temp(lgrid%pp_index(ipr,1),lgrid%pp_index(ipr,2),lgrid%pp_index(ipr,3)) 
          lgrid%pp_state(ipr,iflush,i_p+2) = lgrid%time
#endif

          if(iflush==10000) then
        
           open(newunit=iv,file='pp'//trim(str(ipr))//'_'//trim(str(lgrid%step))//'.dat', &
           status='replace',action='write',form='unformatted',access='stream')

           do i=1,10000
            write(iv) (lgrid%pp_state(ipr,i,j),j=i_rho,i_p+n_probe_vars)
           end do
 
           close(iv)

          endif

        end if

       end do

       if(iflush==10000) iflush=0

#endif

#ifdef OUTPUT_NSTEPS
       if(mod(lgrid%step,nsteps_dump)==0) then
        call mpi_barrier(mgrid%comm_cart,ierr)
        call write_output(mgrid,lgrid)
       endif
#endif

#ifdef OUTPUT_DT
       if(lgrid%time>=lgrid%tnextoutput) then
        call mpi_barrier(mgrid%comm_cart,ierr)
        call write_output(mgrid,lgrid)
        lgrid%tnextoutput = lgrid%tnextoutput + dt_dump
       end if
#endif

#ifdef SAVE_PLANES
       if(lgrid%step==lgrid%planes_inextoutput) then
        call mpi_barrier(mgrid%comm_cart,ierr)
        call write_planes(mgrid,lgrid)
        lgrid%planes_inextoutput = lgrid%planes_inextoutput + lgrid%planes_dstep_dump
       end if
#endif

#ifdef SAVE_SPHERICAL_PROJECTIONS
       if(lgrid%step==lgrid%spj_inextoutput) then
        call mpi_barrier(mgrid%comm_cart,ierr)
        call communicate_ndarray(mgrid,nvars,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%prim,.true.)
        call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%temp,.true.)
#ifdef USE_MHD
        call communicate_ndarray(mgrid,sdims,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%b_cc,.true.)
#endif
        call write_spherical_projections(mgrid,lgrid)
        lgrid%spj_inextoutput = lgrid%spj_inextoutput + lgrid%spj_dstep_dump
       end if
#endif

       if(wctg>=lgrid%tnextrestart) then

        call mpi_barrier(mgrid%comm_cart,ierr)
        call write_restart(mgrid,lgrid)
        lgrid%tnextrestart = lgrid%tnextrestart + dt_restart

        if(mgrid%rankl==master_rank) then

         open(iunit,file='restart_info.txt',status='unknown',action='write',form='formatted',position="append")
         write(iunit,'(I10.10)') lgrid%step
         close(iunit)

        end if

       end if

       if(mgrid%rankl==master_rank) then

         if(mod(lgrid%step,info_terminal_rate)==0) &
         write(*,'("| step=",I8.8," | time=",E9.3," | dt=",E9.3,"| t/tmax=",E9.3," |")') &
         lgrid%step,lgrid%time,lgrid%dt,lgrid%time/tmax

       endif

       call mpi_barrier(mgrid%comm_cart,ierr)
       wcti_hydro = get_wtime(mgrid)

       if((lgrid%time+lgrid%dt)>tmax) then
         lgrid%dt = tmax - lgrid%time
       endif

#ifdef USE_NUCLEAR_NETWORK
#ifdef NUCLEAR_NETWORK_STRANG
       call nuclear_network_step(mgrid,lgrid,rph*lgrid%dt)
#endif
#endif

#ifdef THERMAL_DIFFUSION_STS
#ifdef EVALUATE_PARABOLIC_TIMESTEP
       call mpi_barrier(mgrid%comm_cart,ierr)
       call compute_parabolic_dt(mgrid,lgrid) 
#endif 
       call thermal_diffusion_step(mgrid,lgrid,1)
#endif

#ifndef SKIP_HYDRO
       call hydro_step(mgrid,lgrid)
#endif

#ifdef THERMAL_DIFFUSION_STS
       call thermal_diffusion_step(mgrid,lgrid,2)
#endif

#ifdef USE_NUCLEAR_NETWORK
#ifdef NUCLEAR_NETWORK_STRANG
       call nuclear_network_step(mgrid,lgrid,rph*lgrid%dt)
#endif
#ifdef NUCLEAR_NETWORK_GODUNOV
       call nuclear_network_step(mgrid,lgrid,lgrid%dt) 
#endif
#endif

#ifdef USE_GRAVITY
#ifndef GRAVITY_SOLVER_RK
#ifdef USE_GRAVITY_SOLVER
       call gravity_solver(mgrid,lgrid)
#endif
#ifdef USE_MONOPOLE_GRAVITY
       call monopole_gravity(mgrid,lgrid,int(nx1/2))
#endif
#endif
#endif 

       lgrid%time = lgrid%time + lgrid%dt

#ifdef VARIABLE_TIMESTEP
       call mpi_barrier(mgrid%comm_cart,ierr)
       call compute_hyperbolic_dt(mgrid,lgrid)
#endif

       lgrid%step = lgrid%step + 1

       call mpi_barrier(mgrid%comm_cart,ierr)
       wctf_hydro = get_wtime(mgrid)
       wct_hydro = wct_hydro + wctf_hydro - wcti_hydro
       wctg = wctf_hydro-mgrid%wctgi

#ifdef CHECK_MAX_TEMP

       temp_max = 0.0_rp

       do k=lx3,ux3
        do j=lx2,ux2
         do i=lx1,ux1

          temp_max = max(temp_max,lgrid%temp(i,j,k))

         end do 
        end do
       end do

       call mpi_allreduce(temp_max,temp_max_comm,1,MPI_RP,MPI_MAX,mgrid%comm_cart,ierr)

       if(temp_max_comm>stop_at_temp_max) then
        max_T_met = 1
       end if

#endif

    end do 

    call mpi_barrier(mgrid%comm_cart,ierr)
    wctoi = get_wtime(mgrid)
    call write_output(mgrid,lgrid)
    wctof = get_wtime(mgrid)

#ifdef OUTPUT_DT
    if(lgrid%time>=lgrid%tnextoutput) lgrid%tnextoutput = lgrid%tnextoutput + dt_dump
#endif

#ifdef SAVE_PLANES
    if((lgrid%step==lgrid%planes_inextoutput) .or. (lgrid%time>=tmax) .or. (lgrid%step==stepmax)) then
      call write_planes(mgrid,lgrid) 
      lgrid%planes_inextoutput = lgrid%planes_inextoutput + lgrid%planes_dstep_dump
    end if
#endif

#ifdef SAVE_SPHERICAL_PROJECTIONS
    if((lgrid%step==lgrid%spj_inextoutput) .or. (lgrid%time>=tmax) .or. (lgrid%step==stepmax)) then
      call mpi_barrier(mgrid%comm_cart,ierr)
      call communicate_ndarray(mgrid,nvars,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%prim,.true.)
      call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%temp,.true.)
#ifdef USE_MHD
      call communicate_ndarray(mgrid,sdims,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%b_cc,.true.)
#endif
      call write_spherical_projections(mgrid,lgrid)
      lgrid%spj_inextoutput = lgrid%spj_inextoutput + lgrid%spj_dstep_dump
    end if
#endif

#ifdef USE_POINT_PROBES

    if(iflush>0) then    

     do ipr=1,nprobes

       if(lgrid%pp_inside_domain(ipr).eqv..true.) then
  
         open(newunit=iv,file='pp'//trim(str(ipr))//'_'//trim(str(lgrid%step-1))//'.dat', &
         status='replace',action='write',form='unformatted',access='stream')

         do i=1,iflush
          write(iv) (lgrid%pp_state(ipr,i,j),j=i_rho,i_p+n_probe_vars)
         end do
 
         close(iv)

       end if

     end do

    end if

#endif

    call mpi_barrier(mgrid%comm_cart,ierr)
    call write_restart(mgrid,lgrid)

    if(mgrid%rankl==master_rank) then

      open(iunit,file='restart_info.txt',status='unknown',action='write',form='formatted',position="append")
      write(iunit,'(I10.10)') lgrid%step
      close(iunit)

      write(*,'("| step=",I8.8," | time=",E9.3," | dt=",E9.3,"| t/tmax=",E9.3," |")') &
      lgrid%step,lgrid%time,lgrid%dt,lgrid%time/tmax
      write(*,'("wct/cell/cycle/core = ",E9.3," mus")') & 
      wct_hydro/(lgrid%step-step0)/(mgrid%nx1l*mgrid%nx2l*mgrid%nx3l)*1.0e6_rp
      write(*,'("updated cells/s = ",E9.3)') & 
      (lgrid%step-step0)*(real(nx1,kind=rp)*real(nx2,kind=rp)*real(nx3,kind=rp))/wct_hydro 
      write(*,'("total wct (no output) = ",E9.3," s")') wct_hydro
      write(*,'("wct single output = ",E9.3," s")') wctof-wctoi

    endif

 end subroutine time_loop 

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! HYPERBOLIC SOLVER
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 subroutine hydro_step(mgrid,lgrid)
    type(mpigrid), intent(inout) :: mgrid
    type(locgrid), intent(inout) :: lgrid

    integer :: iv,i,j,k,ierr,ir

    integer :: lx1,ux1,lx2,ux2,lx3,ux3,irk,rk_stages,iter

#ifdef RK2_STEPPER
    real(kind=rp), dimension(1:2,1:3) :: rk_coeff
#endif
#ifdef RK3_STEPPER
    real(kind=rp), dimension(1:3,1:3) :: rk_coeff
#endif

    real(kind=rp) :: a1rk,a2rk,a3rk

    real(kind=rp) :: rho,vx1,vx2,vx3,p,T,inv_rho,rhovx1,rhovx2,rhovx3,rhoe,eint,tmp,tmp1,tmp2

    real(kind=rp) :: qc,qm,qp,slope,slopef,slopeb,prod,am,ap,mn,mx,qmm,qpp,qmmm,qppp, &
    gx1,gx2,gx3,rho_eq,p_eq,ye,abar,inv_abar,Res0,Res_prad,dRes_dT,x,y,z,r,inv_r,dp_drho,dp_deps, &
    rmi,rpl,sin_theta_m,sin_theta_p,sin_theta,inv_r_sin_theta,r2,inv_r2,T2,T3,T4,zbar,sound,sound2,vn, &
    cos_theta,Tminus,Tplus,gradT,Krad,Kint,Kminus,Kplus

    real(kind=rp), dimension(1:nvars) :: qLbuf,qRbuf

    real(kind=rp) :: inv_dl
    real(kind=rp) :: gm,gmm1,igmm1,mu,inv_mu,snu
    real(kind=rp), dimension(1:nvars) :: bc_fac

#ifdef USE_VDAMPING
    real(kind=rp) :: const_damp, nu_damp_tmp
#endif

#ifdef USE_FASTEOS
    real(kind=rp) :: eosLbuf,eosRbuf
#endif

#ifdef GEOMETRY_CUBED_SPHERE
    real(kind=rp) :: nn1,nn2,nn3
#endif

#ifdef USE_MHD
    real(kind=rp), dimension(1:sdims) :: bLbuf, bRbuf
    real(kind=rp) :: emf_N,emf_S,emf_E,emf_W,emf_NW,emf_NE,&
    emf_SE,emf_SW,demf_N,demf_S,demf_W,demf_E,sgn,mach,bx1,bx2,bx3
    real(kind=rp), dimension(1:3) :: bc_facb
#endif

#ifdef COROTATING_FRAME
    real(kind=rp) :: om1,om2,om3
#ifdef GEOMETRY_3D_SPHERICAL
    real(kind=rp) :: ov1,ov2,ov3,or3,oor1,oor2
#endif
#if defined(GEOMETRY_CARTESIAN_UNIFORM) || defined(GEOMETRY_CARTESIAN_NONUNIFORM) || defined(GEOMETRY_CUBED_SPHERE)
    real(kind=rp) :: ov1,ov2,ov3,or1,or2,or3,oor1,oor2,oor3
#endif
#endif

    logical :: communicate_corners

    ierr = idummy
    ir = idummy

    iter = idummy

    p = rp0
    T = rp0
    tmp = rp0
    tmp1 = rp0
    tmp2 = rp0

    qc = rp0
    qm = rp0
    qp = rp0
    slope = rp0
    slopef = rp0
    slopeb = rp0
    prod = rp0
    am = rp0
    ap = rp0
    mn = rp0
    mx = rp0
    qmm = rp0
    qpp = rp0
    qppp = rp0
    qmmm = rp0
    gx1 = rp0
    gx2 = rp0
    gx3 = rp0
    rho_eq = rp0
    p_eq = rp0
    ye = rp0
    abar = rp0
    inv_abar = rp0
    Res0 = rp0
    Res_prad = rp0
    dRes_dT = rp0
    x = rp0
    y = rp0
    z = rp0
    r = rp0
    inv_r = rp0
    dp_drho = rp0
    dp_deps = rp0
    rmi = rp0
    rpl = rp0
    sin_theta_m = rp0
    sin_theta_p = rp0
    sin_theta = rp0
    cos_theta = rp0
    inv_r_sin_theta = rp0
    r2 = rp0
    inv_r2 = rp0
    T2 = rp0
    T3 = rp0
    T4 = rp0
    zbar = rp0 
    sound = rp0
    sound2 = rp0
    vn = rp0
    Tminus = rp0
    Tplus = rp0
    gradT = rp0
    Krad = fthirds*CONST_RAD*CONST_C
    Kint = rp0
    Kminus = rp0
    Kplus = rp0 

    gm = lgrid%gm
    gmm1 = gm-rp1
    igmm1 = rp1/gmm1
    mu = lgrid%mu
    inv_mu = rp1/mu
    snu = rp0

#ifdef GEOMETRY_CUBED_SPHERE
    nn1 = rp0
    nn2 = rp0
    nn3 = rp0
#endif

#ifdef COROTATING_FRAME
    om1 = lgrid%omega_rot(1)
    om2 = lgrid%omega_rot(2)
    om3 = lgrid%omega_rot(3)
#endif

#ifdef USE_VDAMPING
    const_damp = CONST_PI/(rmax_damp-rmin_damp)
#ifndef USE_VARIABLE_VDAMPING
    nu_damp_tmp = nu_damp
#endif
#endif 

    do ir=1,nvars
     bc_fac(ir) = rp0
    end do

#ifdef USE_MHD

    do ir=1,3
     bc_facb(ir) = rp0
    end do
    
    bx1 = rp0
    bx2 = rp0
    bx3 = rp0

#endif

#ifdef RK2_STEPPER

    rk_stages = 2

    rk_coeff(1,1) =  rp1
    rk_coeff(1,2) =  rp0
    rk_coeff(1,3) = -rp1

    rk_coeff(2,1) =  rph
    rk_coeff(2,2) =  rph
    rk_coeff(2,3) = -rph

#endif

#ifdef RK3_STEPPER

    rk_stages = 3

    rk_coeff(1,1) =  rp1
    rk_coeff(1,2) =  rp0
    rk_coeff(1,3) = -rp1

    rk_coeff(2,1) =  tquarts
    rk_coeff(2,2) =  oquart
    rk_coeff(2,3) = -oquart

    rk_coeff(3,1) =  othird
    rk_coeff(3,2) =  tthirds
    rk_coeff(3,3) = -tthirds

#endif

    lx1 = mgrid%i1(1)
    ux1 = mgrid%i2(1)
    lx2 = mgrid%i1(2)
    ux2 = mgrid%i2(2)
    lx3 = mgrid%i1(3)
    ux3 = mgrid%i2(3)

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1

       rho = lgrid%prim(i_rho,i,j,k)
       vx1 = lgrid%prim(i_vx1,i,j,k)
       vx2 = lgrid%prim(i_vx2,i,j,k)
#if sdims_make==3
       vx3 = lgrid%prim(i_vx3,i,j,k)
#else
       vx3 = rp0
#endif

       lgrid%state0(i_rho,i,j,k) = rho
       lgrid%state0(i_rhovx1,i,j,k) = rho*vx1
       lgrid%state0(i_rhovx2,i,j,k) = rho*vx2
#if sdims_make==3
       lgrid%state0(i_rhovx3,i,j,k) = rho*vx3
#endif

       eint = lgrid%eint(i,j,k)

       rhoe = eint + rph*rho*(vx1*vx1+vx2*vx2+vx3*vx3)

#ifdef USE_MHD
       bx1 = lgrid%b_cc(1,i,j,k)
       bx2 = lgrid%b_cc(2,i,j,k)
#if sdims_make==3
       bx3 = lgrid%b_cc(3,i,j,k)
#else
       bx3 = rp0
#endif
       rhoe = rhoe + rph*(bx1*bx1+bx2*bx2+bx3*bx3)
#endif
      
#ifdef EVOLVE_ETOT
       rhoe = rhoe + &
       rho*lgrid%phi_cc(i,j,k)
#endif
       
       lgrid%state0(i_rhoe,i,j,k) = rhoe

#if nas_make>0
       do iv=i_as1,i_asl
        lgrid%state0(iv,i,j,k) = rho*lgrid%prim(iv,i,j,k)
       end do
#endif

      end do
     end do
    end do

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       do iv=1,nvars
        lgrid%state(iv,i,j,k) = lgrid%state0(iv,i,j,k)
       end do
      end do
     end do
    end do

#ifdef USE_MHD
 
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1+1
        lgrid%b0_x1(i,j,k) = lgrid%b_x1(i,j,k)       
      end do
     end do
    end do
 
    do k=lx3,ux3
     do j=lx2,ux2+1
      do i=lx1,ux1
        lgrid%b0_x2(i,j,k) = lgrid%b_x2(i,j,k)       
      end do
     end do
    end do

#if sdims_make==3
    do k=lx3,ux3+1
     do j=lx2,ux2
      do i=lx1,ux1
        lgrid%b0_x3(i,j,k) = lgrid%b_x3(i,j,k)       
      end do
     end do
    end do
#endif

#endif

    do irk=1,rk_stages

#ifdef USE_WB

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        lgrid%prim(i_rho,i,j,k) = lgrid%prim(i_rho,i,j,k) - lgrid%eq_prim_cc(ieq_rho,i,j,k)
        lgrid%prim(i_p,i,j,k) = lgrid%prim(i_p,i,j,k) - lgrid%eq_prim_cc(ieq_p,i,j,k)
 
#ifdef USE_FASTEOS
        lgrid%gammaf(i_gammae,i,j,k) = lgrid%gammaf(i_gammae,i,j,k) - lgrid%eq_gammae_cc(i,j,k)
#endif

       end do
      end do
     end do

#endif

#ifdef USE_SHOCK_FLATTENING
     communicate_corners = .true.
#else
#ifdef USE_MHD
     communicate_corners = .true.
#else
     communicate_corners = .true. 
#endif
#endif

     call mpi_barrier(mgrid%comm_cart,ierr)
     call communicate_ndarray(mgrid,nvars,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%prim,communicate_corners)
#ifdef USE_MHD
     call communicate_ndarray(mgrid,sdims,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%b_cc,communicate_corners)
#endif

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
     call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%temp,communicate_corners)
#endif

#ifdef USE_FASTEOS
     call communicate_ndarray(mgrid,2,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%gammaf,communicate_corners)
#endif

#ifndef USE_INTERNAL_BOUNDARIES

#ifdef GEOMETRY_CUBED_SPHERE

#ifdef X1L_REFLECTIVE

     if(mgrid%coords_dd(1)==0) then

      do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
       do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)

        nn1 = lgrid%n_x1(1,lx1,j,k)
        nn2 = lgrid%n_x1(2,lx1,j,k)
#if sdims_make==3
        nn3 = lgrid%n_x1(3,lx1,j,k)
#endif

        do i=1-ngc,0

         ir = 1-i

         vx1 = lgrid%prim(i_vx1,ir,j,k)
         vx2 = lgrid%prim(i_vx2,ir,j,k)
#if sdims_make==3 
         vx3 = lgrid%prim(i_vx3,ir,j,k)
#endif

         vn = &
#if sdims_make==3
         vx3*nn3 + &
#endif
         vx1*nn1 + &
         vx2*nn2 

         do iv=1,nvars
          lgrid%prim(iv,i,j,k) = lgrid%prim(iv,ir,j,k)
         end do

         lgrid%prim(i_vx1,i,j,k) = vx1 - rp2*vn*nn1
         lgrid%prim(i_vx2,i,j,k) = vx2 - rp2*vn*nn2
#if sdims_make==3         
         lgrid%prim(i_vx3,i,j,k) = vx3 - rp2*vn*nn3
#endif

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
         lgrid%temp(i,j,k) = lgrid%temp(ir,j,k)
#endif
#ifdef USE_FASTEOS
         lgrid%gammaf(i_gammae,i,j,k) = lgrid%gammaf(i_gammae,ir,j,k)
         lgrid%gammaf(i_gammac,i,j,k) = lgrid%gammaf(i_gammac,ir,j,k)
#endif

        end do

       end do
      end do

     endif

#endif

#ifdef X1U_REFLECTIVE

     if(mgrid%coords_dd(1)==mgrid%bricks(1)-1) then

      do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
       do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)

        nn1 = lgrid%n_x1(1,ux1+1,j,k)
        nn2 = lgrid%n_x1(2,ux1+1,j,k)
#if sdims_make==3
        nn3 = lgrid%n_x1(3,ux1+1,j,k)
#endif

        do i=ux1+1,ux1+ngc

         ir = ux1 - (i-ux1-1)

         vx1 = lgrid%prim(i_vx1,ir,j,k)
         vx2 = lgrid%prim(i_vx2,ir,j,k)
#if sdims_make==3 
         vx3 = lgrid%prim(i_vx3,ir,j,k)
#endif

         vn = &
#if sdims_make==3
         vx3*nn3 + &
#endif
         vx1*nn1 + &
         vx2*nn2 

         do iv=1,nvars
          lgrid%prim(iv,i,j,k) = lgrid%prim(iv,ir,j,k)
         end do

         lgrid%prim(i_vx1,i,j,k) = vx1 - rp2*vn*nn1
         lgrid%prim(i_vx2,i,j,k) = vx2 - rp2*vn*nn2
#if sdims_make==3         
         lgrid%prim(i_vx3,i,j,k) = vx3 - rp2*vn*nn3
#endif

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
         lgrid%temp(i,j,k) = lgrid%temp(ir,j,k)
#endif
#ifdef USE_FASTEOS
         lgrid%gammaf(i_gammae,i,j,k) = lgrid%gammaf(i_gammae,ir,j,k)
         lgrid%gammaf(i_gammac,i,j,k) = lgrid%gammaf(i_gammac,ir,j,k)
#endif

        end do

       end do
      end do

     endif

#endif

#ifdef X2L_REFLECTIVE

     if(mgrid%coords_dd(2)==0) then

      do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
       do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

        nn1 = lgrid%n_x2(1,i,lx2,k)
        nn2 = lgrid%n_x2(2,i,lx2,k)
#if sdims_make==3
        nn3 = lgrid%n_x2(3,i,lx2,k)
#endif

        do j=1-ngc,0

         ir = 1-j

         vx1 = lgrid%prim(i_vx1,i,ir,k)
         vx2 = lgrid%prim(i_vx2,i,ir,k)
#if sdims_make==3 
         vx3 = lgrid%prim(i_vx3,i,ir,k)
#endif

         vn = &
#if sdims_make==3
         vx3*nn3 + &
#endif
         vx1*nn1 + &
         vx2*nn2 

         do iv=1,nvars
          lgrid%prim(iv,i,j,k) = lgrid%prim(iv,i,ir,k)
         end do

         lgrid%prim(i_vx1,i,j,k) = vx1 - rp2*vn*nn1
         lgrid%prim(i_vx2,i,j,k) = vx2 - rp2*vn*nn2
#if sdims_make==3         
         lgrid%prim(i_vx3,i,j,k) = vx3 - rp2*vn*nn3
#endif

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
         lgrid%temp(i,j,k) = lgrid%temp(i,ir,k)
#endif
#ifdef USE_FASTEOS
         lgrid%gammaf(i_gammae,i,j,k) = lgrid%gammaf(i_gammae,i,ir,k)
         lgrid%gammaf(i_gammac,i,j,k) = lgrid%gammaf(i_gammac,i,ir,k)
#endif

        end do

       end do
      end do

     endif

#endif

#ifdef X2U_REFLECTIVE

     if(mgrid%coords_dd(2)==mgrid%bricks(2)-1) then

      do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
       do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

        nn1 = lgrid%n_x2(1,i,ux2+1,k)
        nn2 = lgrid%n_x2(2,i,ux2+1,k)
#if sdims_make==3
        nn3 = lgrid%n_x2(3,i,ux2+1,k)
#endif

        do j=ux2+1,ux2+ngc

         ir = ux2 - (j-ux2-1)

         vx1 = lgrid%prim(i_vx1,i,ir,k)
         vx2 = lgrid%prim(i_vx2,i,ir,k)
#if sdims_make==3 
         vx3 = lgrid%prim(i_vx3,i,ir,k)
#endif

         vn = &
#if sdims_make==3
         vx3*nn3 + &
#endif
         vx1*nn1 + &
         vx2*nn2 

         do iv=1,nvars
          lgrid%prim(iv,i,j,k) = lgrid%prim(iv,i,ir,k)
         end do

         lgrid%prim(i_vx1,i,j,k) = vx1 - rp2*vn*nn1
         lgrid%prim(i_vx2,i,j,k) = vx2 - rp2*vn*nn2
#if sdims_make==3         
         lgrid%prim(i_vx3,i,j,k) = vx3 - rp2*vn*nn3
#endif

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
         lgrid%temp(i,j,k) = lgrid%temp(i,ir,k)
#endif
#ifdef USE_FASTEOS
         lgrid%gammaf(i_gammae,i,j,k) = lgrid%gammaf(i_gammae,i,ir,k)
         lgrid%gammaf(i_gammac,i,j,k) = lgrid%gammaf(i_gammac,i,ir,k)
#endif

        end do

       end do
      end do

     endif

#endif

#if sdims_make==3

#ifdef X3L_REFLECTIVE

     if(mgrid%coords_dd(3)==0) then

      do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
       do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

        nn1 = lgrid%n_x3(1,i,j,lx3)
        nn2 = lgrid%n_x3(2,i,j,lx3)
        nn3 = lgrid%n_x3(3,i,j,lx3)

        do k=1-ngc,0

         ir = 1-k

         vx1 = lgrid%prim(i_vx1,i,j,ir)
         vx2 = lgrid%prim(i_vx2,i,j,ir)
         vx3 = lgrid%prim(i_vx3,i,j,ir)

         vn = &
         vx3*nn3 + &
         vx1*nn1 + &
         vx2*nn2 

         do iv=1,nvars
          lgrid%prim(iv,i,j,k) = lgrid%prim(iv,i,j,ir)
         end do

         lgrid%prim(i_vx1,i,j,k) = vx1 - rp2*vn*nn1
         lgrid%prim(i_vx2,i,j,k) = vx2 - rp2*vn*nn2
         lgrid%prim(i_vx3,i,j,k) = vx3 - rp2*vn*nn3

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
         lgrid%temp(i,j,k) = lgrid%temp(i,j,ir)
#endif
#ifdef USE_FASTEOS
         lgrid%gammaf(i_gammae,i,j,k) = lgrid%gammaf(i_gammae,i,j,ir)
         lgrid%gammaf(i_gammac,i,j,k) = lgrid%gammaf(i_gammac,i,j,ir)
#endif

        end do

       end do
      end do

     endif

#endif

#ifdef X3U_REFLECTIVE

     if(mgrid%coords_dd(3)==mgrid%bricks(3)-1) then

      do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
       do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

        nn1 = lgrid%n_x3(1,i,j,ux3+1)
        nn2 = lgrid%n_x3(2,i,j,ux3+1)
        nn3 = lgrid%n_x3(3,i,j,ux3+1)

        do k=ux3+1,ux3+ngc

         ir = ux3 - (k-ux3-1)

         vx1 = lgrid%prim(i_vx1,i,j,ir)
         vx2 = lgrid%prim(i_vx2,i,j,ir)
         vx3 = lgrid%prim(i_vx3,i,j,ir)

         vn = &
         vx3*nn3 + &
         vx1*nn1 + &
         vx2*nn2 

         do iv=1,nvars
          lgrid%prim(iv,i,j,k) = lgrid%prim(iv,i,j,ir)
         end do

         lgrid%prim(i_vx1,i,j,k) = vx1 - rp2*vn*nn1
         lgrid%prim(i_vx2,i,j,k) = vx2 - rp2*vn*nn2
         lgrid%prim(i_vx3,i,j,k) = vx3 - rp2*vn*nn3

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
         lgrid%temp(i,j,k) = lgrid%temp(i,j,ir)
#endif
#ifdef USE_FASTEOS
         lgrid%gammaf(i_gammae,i,j,k) = lgrid%gammaf(i_gammae,i,j,ir)
         lgrid%gammaf(i_gammac,i,j,k) = lgrid%gammaf(i_gammac,i,j,ir)
#endif

        end do

       end do
      end do

     endif

#endif

#endif

#else

#if defined(X1L_REFLECTIVE) || defined(X1L_OUTFLOW) || defined(X1L_DIODE)

     if(mgrid%coords_dd(1)==0) then

      do iv=1,nvars
       bc_fac(iv) = rp1
      end do
#ifdef USE_MHD
      do iv=1,sdims
       bc_facb(iv) = rp1
      end do
#endif

#ifdef X1L_REFLECTIVE
      bc_fac(i_vx1) = -rp1
#ifdef USE_MHD
      bc_facb(1) = -rp1
#ifdef X1L_BFIELD_PMC
      bc_facb(1) = rp1
      bc_facb(2) = -rp1
      bc_facb(3) = -rp1
#endif
#endif
#endif

      do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
       do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)

#ifdef X1L_DIODE
        vn = -lgrid%prim(i_vx1,1,j,k)
        if (vn<rp0) then
         bc_fac(i_vx1) = -rp1
#ifdef USE_MHD
         bc_facb(1) = -rp1
#endif
        else
         bc_fac(i_vx1) = rp1
#ifdef USE_MHD
         bc_facb(1) = rp1
#endif
        endif
#endif

        do i=1-ngc,0

         ir = 1-i
         do iv=1,nvars
          lgrid%prim(iv,i,j,k) = bc_fac(iv)*lgrid%prim(iv,ir,j,k)
         end do
#ifdef USE_MHD
#ifndef FIX_BFIELD_AT_X1
         do iv=1,sdims
          lgrid%b_cc(iv,i,j,k) = bc_facb(iv)*lgrid%b_cc(iv,ir,j,k)
         end do
#endif
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
         lgrid%temp(i,j,k) = lgrid%temp(ir,j,k)
#endif
#ifdef USE_FASTEOS
         lgrid%gammaf(i_gammae,i,j,k) = lgrid%gammaf(i_gammae,ir,j,k)
         lgrid%gammaf(i_gammac,i,j,k) = lgrid%gammaf(i_gammac,ir,j,k)
#endif

        end do
       end do
      end do

     endif

#endif

#if defined(X1U_REFLECTIVE) || defined(X1U_OUTFLOW) || defined(X1U_DIODE)

     if(mgrid%coords_dd(1)==mgrid%bricks(1)-1) then

      do iv=1,nvars
       bc_fac(iv) = rp1
      end do
#ifdef USE_MHD
      do iv=1,sdims
       bc_facb(iv) = rp1
      end do
#endif

#ifdef X1U_REFLECTIVE
      bc_fac(i_vx1) = -rp1
#ifdef USE_MHD
      bc_facb(1) = -rp1
#ifdef X1U_BFIELD_PMC
      bc_facb(1) = rp1
      bc_facb(2) = -rp1
      bc_facb(3) = -rp1
#endif
#endif
#endif

      do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
       do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)

#ifdef X1U_DIODE
        vn = lgrid%prim(i_vx1,ux1,j,k)
        if (vn<rp0) then
         bc_fac(i_vx1) = -rp1
#ifdef USE_MHD
         bc_facb(1) = -rp1
#endif
        else
         bc_fac(i_vx1) = rp1
#ifdef USE_MHD
         bc_facb(1) = rp1
#endif        
        endif
#endif

        do i=ux1+1,ux1+ngc

         ir = ux1 - (i-ux1-1)
         do iv=1,nvars
           lgrid%prim(iv,i,j,k) = bc_fac(iv)*lgrid%prim(iv,ir,j,k)
         end do
#ifdef USE_MHD
#ifndef FIX_BFIELD_AT_X1
         do iv=1,sdims
           lgrid%b_cc(iv,i,j,k) = bc_facb(iv)*lgrid%b_cc(iv,ir,j,k)
         end do
#endif
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
         lgrid%temp(i,j,k) = lgrid%temp(ir,j,k)
#endif
#ifdef USE_FASTEOS
         lgrid%gammaf(i_gammae,i,j,k) = lgrid%gammaf(i_gammae,ir,j,k)
         lgrid%gammaf(i_gammac,i,j,k) = lgrid%gammaf(i_gammac,ir,j,k)
#endif

        end do
       end do
      end do

     endif

#endif

#if defined(X2L_REFLECTIVE) || defined(X2L_OUTFLOW) || defined(X2L_DIODE)

     if(mgrid%coords_dd(2)==0) then

      do iv=1,nvars
       bc_fac(iv) = rp1
      end do
#ifdef USE_MHD
      do iv=1,sdims
       bc_facb(iv) = rp1
      end do
#endif

#ifdef X2L_REFLECTIVE
      bc_fac(i_vx2) = -rp1
#ifdef USE_MHD
      bc_facb(2) = -rp1
#ifdef X2L_BFIELD_PMC
      bc_facb(1) = -rp1
      bc_facb(2) = rp1
      bc_facb(3) = -rp1
#endif
#endif
#endif

      do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4) 
       do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2) 

#ifdef X2L_DIODE
        vn = -lgrid%prim(i_vx2,i,1,k)
        if (vn<rp0) then
         bc_fac(i_vx2) = -rp1
#ifdef USE_MHD
         bc_facb(2) = -rp1
#endif
        else
         bc_fac(i_vx2) = rp1
#ifdef USE_MHD
         bc_facb(2) = rp1
#endif        
        endif
#endif

        do j=1-ngc,0 

         ir = 1-j
         do iv=1,nvars
          lgrid%prim(iv,i,j,k) = bc_fac(iv)*lgrid%prim(iv,i,ir,k)
         end do
#ifdef USE_MHD
         do iv=1,sdims
          lgrid%b_cc(iv,i,j,k) = bc_facb(iv)*lgrid%b_cc(iv,i,ir,k)
         end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
         lgrid%temp(i,j,k) = lgrid%temp(i,ir,k)
#endif
#ifdef USE_FASTEOS
         lgrid%gammaf(i_gammae,i,j,k) = lgrid%gammaf(i_gammae,i,ir,k)
         lgrid%gammaf(i_gammac,i,j,k) = lgrid%gammaf(i_gammac,i,ir,k)
#endif

        end do
       end do
      end do

     endif

#endif

#if defined(X2U_REFLECTIVE) || defined(X2U_OUTFLOW) || defined(X2U_DIODE)

     if(mgrid%coords_dd(2)==mgrid%bricks(2)-1) then

      do iv=1,nvars
       bc_fac(iv) = rp1
      end do
#ifdef USE_MHD
      do iv=1,sdims
       bc_facb(iv) = rp1
      end do
#endif

#ifdef X2U_REFLECTIVE
      bc_fac(i_vx2) = -rp1
#ifdef USE_MHD
      bc_facb(2) = -rp1
#ifdef X2U_BFIELD_PMC
      bc_facb(1) = -rp1
      bc_facb(2) = rp1
      bc_facb(3) = -rp1
#endif
#endif
#endif

      do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4) 
       do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2) 

#ifdef X2U_DIODE
        vn = lgrid%prim(i_vx2,i,ux2,k)
        if (vn<rp0) then
         bc_fac(i_vx2) = -rp1
#ifdef USE_MHD
         bc_facb(2) = -rp1
#endif
        else
         bc_fac(i_vx2) = rp1
#ifdef USE_MHD
         bc_facb(2) = rp1
#endif        
        endif
#endif

        do j=ux2+1,ux2+ngc 

         ir = ux2 - (j-ux2-1)
         do iv=1,nvars
           lgrid%prim(iv,i,j,k) = bc_fac(iv)*lgrid%prim(iv,i,ir,k)
         end do
#ifdef USE_MHD
         do iv=1,sdims
           lgrid%b_cc(iv,i,j,k) = bc_facb(iv)*lgrid%b_cc(iv,i,ir,k)
         end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
         lgrid%temp(i,j,k) = lgrid%temp(i,ir,k)
#endif
#ifdef USE_FASTEOS
         lgrid%gammaf(i_gammae,i,j,k) = lgrid%gammaf(i_gammae,i,ir,k)
         lgrid%gammaf(i_gammac,i,j,k) = lgrid%gammaf(i_gammac,i,ir,k)
#endif

        end do
       end do
      end do

     endif

#endif

#if sdims_make==3

#if defined(X3L_REFLECTIVE) || defined(X3L_OUTFLOW) || defined(X3L_DIODE)

     if(mgrid%coords_dd(3)==0) then

      do iv=1,nvars
       bc_fac(iv) = rp1
      end do
#ifdef USE_MHD
      do iv=1,sdims
       bc_facb(iv) = rp1
      end do
#endif

#ifdef X3L_REFLECTIVE
      bc_fac(i_vx3) = -rp1
#ifdef USE_MHD
      bc_facb(3) = -rp1
#ifdef X3L_BFIELD_PMC
      bc_facb(1) = -rp1
      bc_facb(2) = -rp1
      bc_facb(3) = rp1
#endif
#endif
#endif

      do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
       do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

#ifdef X3L_DIODE
        vn = -lgrid%prim(i_vx3,i,j,1)
        if (vn<rp0) then
         bc_fac(i_vx3) = -rp1
#ifdef USE_MHD
         bc_facb(3) = -rp1
#endif
        else
         bc_fac(i_vx3) = rp1
#ifdef USE_MHD
         bc_facb(3) = rp1
#endif        
        endif
#endif

        do k=1-ngc,0

         ir = 1-k
         do iv=1,nvars
          lgrid%prim(iv,i,j,k) = bc_fac(iv)*lgrid%prim(iv,i,j,ir)
         end do
#ifdef USE_MHD
         do iv=1,sdims
          lgrid%b_cc(iv,i,j,k) = bc_facb(iv)*lgrid%b_cc(iv,i,j,ir)
         end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
         lgrid%temp(i,j,k) = lgrid%temp(i,j,ir)
#endif
#ifdef USE_FASTEOS
         lgrid%gammaf(i_gammae,i,j,k) = lgrid%gammaf(i_gammae,i,j,ir)
         lgrid%gammaf(i_gammac,i,j,k) = lgrid%gammaf(i_gammac,i,j,ir)
#endif

        end do
       end do
      end do

     endif

#endif

#if defined(X3U_REFLECTIVE) || defined(X3U_OUTFLOW) || defined(X3U_DIODE)

     if(mgrid%coords_dd(3)==mgrid%bricks(3)-1) then

      do iv=1,nvars
       bc_fac(iv) = rp1
      end do
#ifdef USE_MHD
      do iv=1,sdims
       bc_facb(iv) = rp1
      end do
#endif

#ifdef X3U_REFLECTIVE
      bc_fac(i_vx3) = -rp1
#ifdef USE_MHD
      bc_facb(3) = -rp1
#ifdef X3U_BFIELD_PMC
      bc_facb(1) = -rp1
      bc_facb(2) = -rp1
      bc_facb(3) = rp1
#endif
#endif
#endif

      do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
       do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

#ifdef X3U_DIODE
        vn = lgrid%prim(i_vx3,i,j,ux3)
        if (vn<rp0) then
         bc_fac(i_vx3) = -rp1
#ifdef USE_MHD
         bc_facb(3) = -rp1
#endif
        else
         bc_fac(i_vx3) = rp1
#ifdef USE_MHD
         bc_facb(3) = rp1
#endif        
        endif
#endif

        do k=ux3+1,ux3+ngc

         ir = ux3 - (k-ux3-1)
         do iv=1,nvars
           lgrid%prim(iv,i,j,k) = bc_fac(iv)*lgrid%prim(iv,i,j,ir)
         end do
#ifdef USE_MHD
         do iv=1,sdims
           lgrid%b_cc(iv,i,j,k) = bc_facb(iv)*lgrid%b_cc(iv,i,j,ir)
         end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
         lgrid%temp(i,j,k) = lgrid%temp(i,j,ir)
#endif
#ifdef USE_FASTEOS
         lgrid%gammaf(i_gammae,i,j,k) = lgrid%gammaf(i_gammae,i,j,ir)
         lgrid%gammaf(i_gammac,i,j,k) = lgrid%gammaf(i_gammac,i,j,ir)
#endif

        end do
       end do
      end do

     endif

#endif

#endif

#endif

#endif

     inv_dl = lgrid%inv_dx1
     lgrid%ru%dir=1

#ifdef USE_INTERNAL_BOUNDARIES

     do iv=1,nvars
      bc_fac(iv) = rp1
     end do
#ifdef USE_MHD
     do iv=1,sdims
      bc_facb(iv) = rp1
     end do
#endif

     bc_fac(i_vx1) = -rp1
#ifdef USE_MHD
     bc_facb(1) = -rp1
#endif

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1-1,ux1+1

        if(lgrid%is_solid(i,j,k)==0) then

         if(lgrid%is_solid(i-1,j,k)==1) then

          do iv=1,nvars
           lgrid%prim(iv,i-1,j,k)=bc_fac(iv)*lgrid%prim(iv,i,j,k)
          end do
#ifdef USE_MHD
          do iv=1,sdims
           lgrid%b_cc(iv,i-1,j,k) = bc_facb(iv)*lgrid%b_cc(iv,i,j,k)
          end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
          lgrid%temp(i-1,j,k) = lgrid%temp(i,j,k)
#endif
#ifdef USE_FASTEOS
          lgrid%gammaf(i_gammae,i-1,j,k) = lgrid%gammaf(i_gammae,i,j,k)
          lgrid%gammaf(i_gammac,i-1,j,k) = lgrid%gammaf(i_gammac,i,j,k)
#endif

          if((lgrid%is_solid(i+1,j,k)==0) .and. (i>=lx1)) then

           do iv=1,nvars
            lgrid%prim(iv,i-2,j,k)=bc_fac(iv)*lgrid%prim(iv,i+1,j,k)
           end do
#ifdef USE_MHD
           do iv=1,sdims
            lgrid%b_cc(iv,i-2,j,k) = bc_facb(iv)*lgrid%b_cc(iv,i+1,j,k)
           end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
           lgrid%temp(i-2,j,k) = lgrid%temp(i+1,j,k)
#endif
#ifdef USE_FASTEOS
           lgrid%gammaf(i_gammae,i-2,j,k) = lgrid%gammaf(i_gammae,i+1,j,k)
           lgrid%gammaf(i_gammac,i-2,j,k) = lgrid%gammaf(i_gammac,i+1,j,k)
#endif

          endif

         endif

         if(lgrid%is_solid(i+1,j,k)==1) then

          do iv=1,nvars
           lgrid%prim(iv,i+1,j,k)=bc_fac(iv)*lgrid%prim(iv,i,j,k)
          end do
#ifdef USE_MHD
          do iv=1,sdims
           lgrid%b_cc(iv,i+1,j,k) = bc_facb(iv)*lgrid%b_cc(iv,i,j,k)
          end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
          lgrid%temp(i+1,j,k) = lgrid%temp(i,j,k)
#endif
#ifdef USE_FASTEOS
          lgrid%gammaf(i_gammae,i+1,j,k) = lgrid%gammaf(i_gammae,i,j,k)
          lgrid%gammaf(i_gammac,i+1,j,k) = lgrid%gammaf(i_gammac,i,j,k)
#endif

          if((lgrid%is_solid(i-1,j,k)==0) .and. (i<=ux1)) then

           do iv=1,nvars
            lgrid%prim(iv,i+2,j,k)=bc_fac(iv)*lgrid%prim(iv,i-1,j,k)
           end do
#ifdef USE_MHD
           do iv=1,sdims
            lgrid%b_cc(iv,i+2,j,k) = bc_facb(iv)*lgrid%b_cc(iv,i-1,j,k)
           end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
           lgrid%temp(i+2,j,k) = lgrid%temp(i-1,j,k)
#endif
#ifdef USE_FASTEOS
           lgrid%gammaf(i_gammae,i+2,j,k) = lgrid%gammaf(i_gammae,i-1,j,k)
           lgrid%gammaf(i_gammac,i+2,j,k) = lgrid%gammaf(i_gammac,i-1,j,k)
#endif

          endif

         endif

        endif

       end do
      end do
     end do

#endif

#ifdef USE_SHOCK_FLATTENING

#if sdims_make==3
     do k=lx3-1,ux3+1    
#else
     do k=lx3,ux3       
#endif
      do j=lx2-1,ux2+1
       do i=lx1-1,ux1+1

        lgrid%is_flattened(i,j,k) = 0

       end do
      end do
     end do

#if sdims_make==3
     do k=lx3-2,ux3+2       
#else
     do k=lx3,ux3       
#endif
      do j=lx2-2,ux2+2
       do i=lx1-2,ux1+2

#ifdef USE_WB
        tmp =  ( & 
#if sdims_make==3
        abs((lgrid%prim(i_p,i,j,k+1)+lgrid%eq_prim_cc(ieq_p,i,j,k+1))-(lgrid%prim(i_p,i,j,k-1)+lgrid%eq_prim_cc(ieq_p,i,j,k-1))) + &
#endif
        abs((lgrid%prim(i_p,i,j+1,k)+lgrid%eq_prim_cc(ieq_p,i,j+1,k))-(lgrid%prim(i_p,i,j-1,k)+lgrid%eq_prim_cc(ieq_p,i,j-1,k))) + &
        abs((lgrid%prim(i_p,i+1,j,k)+lgrid%eq_prim_cc(ieq_p,i+1,j,k))-(lgrid%prim(i_p,i-1,j,k)+lgrid%eq_prim_cc(ieq_p,i-1,j,k))) )/&
        (lgrid%prim(i_p,i,j,k)+lgrid%eq_prim_cc(ieq_p,i,j,k))
#else
        tmp =  ( & 
#if sdims_make==3
        abs(lgrid%prim(i_p,i,j,k+1)-lgrid%prim(i_p,i,j,k-1)) + &
#endif
        abs(lgrid%prim(i_p,i,j+1,k)-lgrid%prim(i_p,i,j-1,k)) + &
        abs(lgrid%prim(i_p,i+1,j,k)-lgrid%prim(i_p,i-1,j,k)) ) / lgrid%prim(i_p,i,j,k)
#endif

        if(tmp>eps_sf) then
#if sdims_make==3
         do iv=1,3
          do ir=1,3
           do ierr=1,3
            lgrid%is_flattened(i-2+ierr,j-2+ir,k-2+iv) = 1
           end do
          end do
         end do
#else
         do iv=1,3
          do ir=1,3
           lgrid%is_flattened(i-2+ir,j-2+iv,1) = 1
          end do
         end do
#endif
        endif

       end do
      end do
     end do

#endif

     do k=lx3,ux3
      do j=lx2,ux2

#ifdef LIM2ND_REC

       do i=lx1-1,ux1+1

        do iv=1,nvars

         qm = lgrid%prim(iv,i-1,j,k)
         qc = lgrid%prim(iv,i,j,k)
         qp = lgrid%prim(iv,i+1,j,k)

         slopef = qp-qc
         slopeb = qc-qm
         prod = slopef*slopeb
       
         slope = rp0

         if(prod>rp0) then
          slope=prod/(slopef+slopeb)
         endif
         
         tmp = rph*slope
         qLbuf(iv) = qc - tmp
         qRbuf(iv) = qc + tmp
         
        end do

        if(i>=lx1) then
         do iv=1,nvars
          lgrid%qRx1(iv,i) = qLbuf(iv)
         end do
        endif

        if(i<=ux1) then
         do iv=1,nvars
          lgrid%qLx1(iv,i+1) = qRbuf(iv)
         end do
        endif

       end do

#endif

#ifdef PPH_REC

       do i=lx1-1,ux1+1

        do iv=1,i_p

         qm = lgrid%prim(iv,i-1,j,k)
         qc = lgrid%prim(iv,i,j,k)
         qp = lgrid%prim(iv,i+1,j,k)
          
         tmp = fvsixth*qc
         qLbuf(iv) =  othird*qm + tmp - osixth*qp
         qRbuf(iv) = -osixth*qm + tmp + othird*qp

        end do

#if nas_make>0

        do iv=i_as1,i_asl
 
         qm = lgrid%prim(iv,i-1,j,k)
         qc = lgrid%prim(iv,i,j,k)
         qp = lgrid%prim(iv,i+1,j,k)

         tmp = fvsixth*qc
         am =  othird*qm + tmp - osixth*qp
         ap = -osixth*qm + tmp + othird*qp

         mn = min(qm,qc)
         mx = max(qm,qc)

         if (am<mn) am = mn
         if (am>mx) am = mx

         mn = min(qc,qp)
         mx = max(qc,qp)

         if (ap<mn) ap = mn
         if (ap>mx) ap = mx

         am = am - qc
         ap = ap - qc

         if (ap*am>=rp0) then
          ap = rp0
          am = rp0
         else
          if (abs(ap)>=rp2*abs(am)) then
           ap = -rp2*am
          end if
          if (abs(am)>=rp2*abs(ap)) then
           am = -rp2*ap
          end if
         end if

         qLbuf(iv) = am + qc
         qRbuf(iv) = ap + qc

        end do

#endif

        if(i>=lx1) then
         do iv=1,nvars
          lgrid%qRx1(iv,i) = qLbuf(iv)
         end do
        endif

        if(i<=ux1) then
         do iv=1,nvars
          lgrid%qLx1(iv,i+1) = qRbuf(iv)
         end do
        endif

       end do
 
#endif

#ifdef LIM5TH_REC

       do i=lx1-1,ux1+1

        do iv=1,nvars

         qmm = lgrid%prim(iv,i-2,j,k)
         qm = lgrid%prim(iv,i-1,j,k)
         qc = lgrid%prim(iv,i,j,k)
         qp = lgrid%prim(iv,i+1,j,k)
         qpp = lgrid%prim(iv,i+2,j,k)

         tmp = rp329*qc
         am = (-rp21*qmm + rp189*qm + tmp - rp91*qp + rp14*qpp)*o420
         ap = (rp14*qmm - rp91*qm + tmp + rp189*qp - rp21*qpp)*o420

         mn = min(qm,qc)
         mx = max(qm,qc)

         if (am<mn) am = mn
         if (am>mx) am = mx

         mn = min(qc,qp)
         mx = max(qc,qp)

         if (ap<mn) ap = mn
         if (ap>mx) ap = mx

         am = am - qc
         ap = ap - qc

         if (ap*am>=rp0) then
          ap = rp0
          am = rp0
         else
          if (abs(ap)>=rp2*abs(am)) then
           ap = -rp2*am
          end if
          if (abs(am)>=rp2*abs(ap)) then
           am = -rp2*ap
          end if
         end if

         qLbuf(iv) = am + qc
         qRbuf(iv) = ap + qc

        end do

        if(i>=lx1) then
         do iv=1,nvars
          lgrid%qRx1(iv,i) = qLbuf(iv)
         end do
        endif

        if(i<=ux1) then
         do iv=1,nvars
          lgrid%qLx1(iv,i+1) = qRbuf(iv)
         end do
        endif

       end do

#endif

#ifdef USE_MHD

#ifdef LIM2ND_REC
 
       do i=lx1-1,ux1+1

        do iv=2,sdims

         qm = lgrid%b_cc(iv,i-1,j,k)
         qc = lgrid%b_cc(iv,i,j,k)
         qp = lgrid%b_cc(iv,i+1,j,k)

         slopef = qp-qc
         slopeb = qc-qm
         prod = slopef*slopeb
       
         slope = rp0

         if(prod>rp0) then
          slope=prod/(slopef+slopeb)
         endif
         
         tmp = rph*slope
         bLbuf(iv) = qc - tmp
         bRbuf(iv) = qc + tmp
         
        end do

        if(i>=lx1) then
         do iv=2,sdims
          lgrid%bRx1(iv,i) = bLbuf(iv)
         end do
        endif

        if(i<=ux1) then
         do iv=2,sdims
          lgrid%bLx1(iv,i+1) = bRbuf(iv)
         end do
        endif

       end do

#endif

#ifdef PPH_REC
  
       do i=lx1-1,ux1+1

        do iv=2,sdims

         qm = lgrid%b_cc(iv,i-1,j,k)
         qc = lgrid%b_cc(iv,i,j,k)
         qp = lgrid%b_cc(iv,i+1,j,k)

         tmp = fvsixth*qc
         bLbuf(iv) =  othird*qm + tmp - osixth*qp
         bRbuf(iv) = -osixth*qm + tmp + othird*qp

        end do

        if(i>=lx1) then
         do iv=2,sdims
          lgrid%bRx1(iv,i) = bLbuf(iv)
         end do
        endif

        if(i<=ux1) then
         do iv=2,sdims
          lgrid%bLx1(iv,i+1) = bRbuf(iv)
         end do
        endif

       end do

#endif

#ifdef LIM5TH_REC
 
       do i=lx1-1,ux1+1

        do iv=2,sdims

         qmm = lgrid%b_cc(iv,i-2,j,k)
         qm = lgrid%b_cc(iv,i-1,j,k)
         qc = lgrid%b_cc(iv,i,j,k)
         qp = lgrid%b_cc(iv,i+1,j,k)
         qpp = lgrid%b_cc(iv,i+2,j,k)

         tmp = rp329*qc
         am = (-rp21*qmm + rp189*qm + tmp - rp91*qp + rp14*qpp)*o420
         ap = (rp14*qmm - rp91*qm + tmp + rp189*qp - rp21*qpp)*o420

         mn = min(qm,qc)
         mx = max(qm,qc)

         if (am<mn) am = mn
         if (am>mx) am = mx

         mn = min(qc,qp)
         mx = max(qc,qp)

         if (ap<mn) ap = mn
         if (ap>mx) ap = mx

         am = am - qc
         ap = ap - qc

         if (ap*am>=rp0) then
          ap = rp0
          am = rp0
         else
          if (abs(ap)>=rp2*abs(am)) then
           ap = -rp2*am
          end if
          if (abs(am)>=rp2*abs(ap)) then
           am = -rp2*ap
          end if
         end if

         bLbuf(iv) = am + qc
         bRbuf(iv) = ap + qc

        end do

        if(i>=lx1) then
         do iv=2,sdims
          lgrid%bRx1(iv,i) = bLbuf(iv)
         end do
        endif

        if(i<=ux1) then
         do iv=2,sdims
          lgrid%bLx1(iv,i+1) = bRbuf(iv)
         end do
        endif

       end do

#endif

       do i=lx1,ux1+1
        tmp = lgrid%b_x1(i,j,k)
        lgrid%bLx1(1,i) = tmp
        lgrid%bRx1(1,i) = tmp
       end do

#endif

#ifdef USE_WB
       do i=lx1,ux1+1
        
        rho_eq = lgrid%eq_prim_x1(ieq_rho,i,j,k)
        p_eq = lgrid%eq_prim_x1(ieq_p,i,j,k)

        lgrid%qLx1(i_rho,i) = lgrid%qLx1(i_rho,i) + rho_eq
        lgrid%qRx1(i_rho,i) = lgrid%qRx1(i_rho,i) + rho_eq

        lgrid%qLx1(i_p,i) = lgrid%qLx1(i_p,i) + p_eq
        lgrid%qRx1(i_p,i) = lgrid%qRx1(i_p,i) + p_eq

       end do
#endif

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
#ifndef USE_FASTEOS
       do i=lx1,ux1+1
        lgrid%ru%guess_temp(1)%val(i) = &
        rph*(lgrid%temp(i-1,j,k)+lgrid%temp(i,j,k))
       end do
#endif
#endif

#ifdef USE_FASTEOS

#ifdef LIM2ND_REC

       do i=lx1-1,ux1+1

        qm = lgrid%gammaf(i_gammae,i-1,j,k)
        qc = lgrid%gammaf(i_gammae,i,j,k)
        qp = lgrid%gammaf(i_gammae,i+1,j,k)

        slopef = qp-qc
        slopeb = qc-qm
        prod = slopef*slopeb
      
        slope = rp0

        if(prod>rp0) then
         slope=prod/(slopef+slopeb)
        endif
        
        tmp = rph*slope
        eosLbuf = qc - tmp
        eosRbuf = qc + tmp
 
        if(i>=lx1) then
          lgrid%ru%gammafR(1)%val(i_gammae,i) = eosLbuf
        endif

        if(i<=ux1) then
          lgrid%ru%gammafL(1)%val(i_gammae,i+1) = eosRbuf
        endif

       end do

       do i=lx1-1,ux1+1

        qm = lgrid%gammaf(i_gammac,i-1,j,k)
        qc = lgrid%gammaf(i_gammac,i,j,k)
        qp = lgrid%gammaf(i_gammac,i+1,j,k)

        slopef = qp-qc
        slopeb = qc-qm
        prod = slopef*slopeb
      
        slope = rp0

        if(prod>rp0) then
         slope=prod/(slopef+slopeb)
        endif
        
        tmp = rph*slope
        eosLbuf = qc - tmp
        eosRbuf = qc + tmp

        if(i>=lx1) then
          lgrid%ru%gammafR(1)%val(i_gammac,i) = eosLbuf
        endif

        if(i<=ux1) then
          lgrid%ru%gammafL(1)%val(i_gammac,i+1) = eosRbuf
        endif

       end do

#endif

#ifdef PPH_REC

       do i=lx1-1,ux1+1

        qm = lgrid%gammaf(i_gammae,i-1,j,k)
        qc = lgrid%gammaf(i_gammae,i,j,k)
        qp = lgrid%gammaf(i_gammae,i+1,j,k)

        tmp = fvsixth*qc
        eosLbuf =  othird*qm + tmp - osixth*qp
        eosRbuf = -osixth*qm + tmp + othird*qp

        if(i>=lx1) then
          lgrid%ru%gammafR(1)%val(i_gammae,i) = eosLbuf
        endif

        if(i<=ux1) then
          lgrid%ru%gammafL(1)%val(i_gammae,i+1) = eosRbuf
        endif

       end do

       do i=lx1-1,ux1+1

        qm = lgrid%gammaf(i_gammac,i-1,j,k)
        qc = lgrid%gammaf(i_gammac,i,j,k)
        qp = lgrid%gammaf(i_gammac,i+1,j,k)

        tmp = fvsixth*qc
        eosLbuf =  othird*qm + tmp - osixth*qp
        eosRbuf = -osixth*qm + tmp + othird*qp

        if(i>=lx1) then
          lgrid%ru%gammafR(1)%val(i_gammac,i) = eosLbuf
        endif

        if(i<=ux1) then
          lgrid%ru%gammafL(1)%val(i_gammac,i+1) = eosRbuf
        endif

       end do

#endif

#ifdef LIM5TH_REC

       do i=lx1-1,ux1+1

        qmm = lgrid%gammaf(i_gammae,i-2,j,k)
        qm  = lgrid%gammaf(i_gammae,i-1,j,k)
        qc  = lgrid%gammaf(i_gammae,i,j,k)
        qp  = lgrid%gammaf(i_gammae,i+1,j,k)
        qpp = lgrid%gammaf(i_gammae,i+2,j,k)

        tmp = rp329*qc
        am = (-rp21*qmm + rp189*qm + tmp - rp91*qp + rp14*qpp)*o420
        ap = (rp14*qmm - rp91*qm + tmp + rp189*qp - rp21*qpp)*o420

        mn = min(qm,qc)
        mx = max(qm,qc)

        if (am<mn) am = mn
        if (am>mx) am = mx

        mn = min(qc,qp)
        mx = max(qc,qp)

        if (ap<mn) ap = mn
        if (ap>mx) ap = mx

        am = am - qc
        ap = ap - qc

        if (ap*am>=rp0) then
         ap = rp0
         am = rp0
        else
         if (abs(ap)>=rp2*abs(am)) then
          ap = -rp2*am
         end if
         if (abs(am)>=rp2*abs(ap)) then
          am = -rp2*ap
         end if
        end if

        eosLbuf = am + qc
        eosRbuf = ap + qc

        if(i>=lx1) then
          lgrid%ru%gammafR(1)%val(i_gammae,i) = eosLbuf
        endif

        if(i<=ux1) then
          lgrid%ru%gammafL(1)%val(i_gammae,i+1) = eosRbuf
        endif

       end do

       do i=lx1-1,ux1+1

        qmm = lgrid%gammaf(i_gammac,i-2,j,k)
        qm  = lgrid%gammaf(i_gammac,i-1,j,k)
        qc  = lgrid%gammaf(i_gammac,i,j,k)
        qp  = lgrid%gammaf(i_gammac,i+1,j,k)
        qpp = lgrid%gammaf(i_gammac,i+2,j,k)

        tmp = rp329*qc
        am = (-rp21*qmm + rp189*qm + tmp - rp91*qp + rp14*qpp)*o420
        ap = (rp14*qmm - rp91*qm + tmp + rp189*qp - rp21*qpp)*o420

        mn = min(qm,qc)
        mx = max(qm,qc)

        if (am<mn) am = mn
        if (am>mx) am = mx

        mn = min(qc,qp)
        mx = max(qc,qp)

        if (ap<mn) ap = mn
        if (ap>mx) ap = mx

        am = am - qc
        ap = ap - qc

        if (ap*am>=rp0) then
         ap = rp0
         am = rp0
        else
         if (abs(ap)>=rp2*abs(am)) then
          ap = -rp2*am
         end if
         if (abs(am)>=rp2*abs(ap)) then
          am = -rp2*ap
         end if
        end if

        eosLbuf = am + qc
        eosRbuf = ap + qc

        if(i>=lx1) then
          lgrid%ru%gammafR(1)%val(i_gammac,i) = eosLbuf
        endif

        if(i<=ux1) then
          lgrid%ru%gammafL(1)%val(i_gammac,i+1) = eosRbuf
        endif

       end do

#endif

#ifdef USE_WB
       do i=lx1,ux1+1
        
        p_eq = lgrid%eq_gammae_x1(i,j,k)

        lgrid%ru%gammafL(1)%val(i_gammae,i) = &
        lgrid%ru%gammafL(1)%val(i_gammae,i) + p_eq
 
        lgrid%ru%gammafR(1)%val(i_gammae,i) = &
        lgrid%ru%gammafR(1)%val(i_gammae,i) + p_eq

       end do
#endif

#endif

#ifdef USE_SHOCK_FLATTENING

        do i=lx1,ux1+1
         if(lgrid%is_flattened(i-1,j,k)==1 .or. lgrid%is_flattened(i,j,k)==1) then         
           lgrid%ru%is_flattened(1)%val(i) = 1
         else
           lgrid%ru%is_flattened(1)%val(i) = 0
         endif
        end do

        do i=lx1-1,ux1+1

         if(lgrid%is_flattened(i,j,k)==1) then
         
          do iv=1,nvars

           qm = lgrid%prim(iv,i-1,j,k)
           qc = lgrid%prim(iv,i,j,k)
           qp = lgrid%prim(iv,i+1,j,k)

           slopef = qp-qc
           slopeb = qc-qm
           prod = slopef*slopeb

           slope = rp0

           if(prod>rp0) then
            slope=prod/(slopef+slopeb)
           endif

           tmp = rph*slope
           qLbuf(iv) = qc - tmp
           qRbuf(iv) = qc + tmp

          end do

          if(i>=lx1) then
           do iv=1,nvars
            lgrid%qRx1(iv,i) = qLbuf(iv)
           end do
#ifdef USE_WB
           rho_eq = lgrid%eq_prim_x1(ieq_rho,i,j,k)
           p_eq = lgrid%eq_prim_x1(ieq_p,i,j,k)
           lgrid%qRx1(i_rho,i) = lgrid%qRx1(i_rho,i) + rho_eq
           lgrid%qRx1(i_p,i) = lgrid%qRx1(i_p,i) + p_eq
#endif
          endif

          if(i<=ux1) then
           do iv=1,nvars
            lgrid%qLx1(iv,i+1) = qRbuf(iv)
           end do
#ifdef USE_WB
           rho_eq = lgrid%eq_prim_x1(ieq_rho,i+1,j,k)
           p_eq = lgrid%eq_prim_x1(ieq_p,i+1,j,k)
           lgrid%qLx1(i_rho,i+1) = lgrid%qLx1(i_rho,i+1) + rho_eq
           lgrid%qLx1(i_p,i+1) = lgrid%qLx1(i_p,i+1) + p_eq
#endif           
          endif

#ifdef USE_MHD

          do iv=2,sdims

           qm = lgrid%b_cc(iv,i-1,j,k)
           qc = lgrid%b_cc(iv,i,j,k)
           qp = lgrid%b_cc(iv,i+1,j,k)

           slopef = qp-qc
           slopeb = qc-qm
           prod = slopef*slopeb

           slope = rp0

           if(prod>rp0) then
            slope=prod/(slopef+slopeb)
           endif

           tmp = rph*slope
           bLbuf(iv) = qc - tmp
           bRbuf(iv) = qc + tmp

          end do

          if(i>=lx1) then
           do iv=2,sdims
            lgrid%bRx1(iv,i) = bLbuf(iv)
           end do
          endif

          if(i<=ux1) then
           do iv=2,sdims
            lgrid%bLx1(iv,i+1) = bRbuf(iv)
           end do
          endif

#endif

#ifdef USE_FASTEOS
          do iv=1,2

           qm = lgrid%gammaf(iv,i-1,j,k)
           qc = lgrid%gammaf(iv,i,j,k)
           qp = lgrid%gammaf(iv,i+1,j,k)

           slopef = qp-qc
           slopeb = qc-qm
           prod = slopef*slopeb

           slope = rp0

           if(prod>rp0) then
            slope=prod/(slopef+slopeb)
           endif

           tmp = rph*slope
           qLbuf(iv) = qc - tmp
           qRbuf(iv) = qc + tmp
          

          end do
 
          if(i>=lx1) then
           do iv=1,2
            lgrid%ru%gammafR(1)%val(iv,i)= qLbuf(iv)
           end do
#ifdef USE_WB
           p_eq = lgrid%eq_gammae_x1(i,j,k)
           lgrid%ru%gammafL(1)%val(1,i) = lgrid%ru%gammafL(1)%val(1,i) + p_eq
#endif
          endif

          if(i<=ux1) then
           do iv=1,2
            lgrid%ru%gammafL(1)%val(iv,i+1)= qRbuf(iv)
           end do
#ifdef USE_WB
           p_eq = lgrid%eq_gammae_x1(i+1,j,k)
           lgrid%ru%gammafR(1)%val(1,i+1) = lgrid%ru%gammafR(1)%val(1,i+1) + p_eq
#endif
          endif
#endif

         end if

        end do

#endif

#ifdef ADVECT_SPECIES

       do i=lx1,ux1+1

        tmp = rp0
        do iv=1,nspecies
         tmp = tmp + lgrid%qLx1(i_as1+iv-1,i)
        end do

        tmp = rp1/tmp

        do iv=1,nspecies
         lgrid%qLx1(i_as1+iv-1,i) = lgrid%qLx1(i_as1+iv-1,i)*tmp
        end do

        tmp = rp0
        do iv=1,nspecies
         tmp = tmp + lgrid%qRx1(i_as1+iv-1,i)
        end do

        tmp = rp1/tmp

        do iv=1,nspecies
         lgrid%qRx1(i_as1+iv-1,i) = lgrid%qRx1(i_as1+iv-1,i)*tmp
        end do

       end do

#endif
      
#ifdef GEOMETRY_CUBED_SPHERE
       do i=lx1,ux1+1
        lgrid%ru%nn(1)%val(1,i) = lgrid%n_x1(1,i,j,k)
        lgrid%ru%nn(1)%val(2,i) = lgrid%n_x1(2,i,j,k)
#if sdims_make==3        
        lgrid%ru%nn(1)%val(3,i) = lgrid%n_x1(3,i,j,k)
#endif
       end do
#endif

#ifdef USE_MHD
       call riemann(lx1,ux1+1,lgrid%qLx1,lgrid%qRx1,lgrid%bLx1,lgrid%bRx1,lgrid%fx1,lgrid%fbx1,lgrid%ru)
#else
       call riemann(lx1,ux1+1,lgrid%qLx1,lgrid%qRx1,lgrid%fx1,lgrid%ru)
#endif

#ifdef USE_MHD

       do i=lx1,ux1+1

#if sdims_make==3
         lgrid%emf_x1(1,i,j,k) = rp0
         lgrid%emf_x1(2,i,j,k) = lgrid%fbx1(3,i)
#endif
         lgrid%emf_x1(3,i,j,k) = -lgrid%fbx1(2,i)

         tmp = rph*(lgrid%qLx1(i_rho,i)+lgrid%qRx1(i_rho,i))*lgrid%smax
         mach = lgrid%fx1(i_rho,i) / tmp

         sgn = rp0
         if(mach>Mach_ct) then
          sgn = rp1        
         endif
         if(mach<-Mach_ct) then
          sgn = -rp1        
         endif

         lgrid%sign_frho_x1(i,j,k) = sgn

       end do

#endif

#if defined(GEOMETRY_CARTESIAN_UNIFORM) || defined(GEOMETRY_CARTESIAN_NONUNIFORM)
#ifdef USE_WB
       do i=lx1,ux1+1
        lgrid%fx1(i_rhovx1,i) = lgrid%fx1(i_rhovx1,i) - lgrid%eq_prim_x1(ieq_p,i,j,k) 
       end do
#endif
#endif

#ifdef EVOLVE_ETOT
       do i=lx1,ux1+1
        lgrid%fx1(i_rhoe,i) = lgrid%fx1(i_rhoe,i) + &
        lgrid%fx1(i_rho,i)*lgrid%phi_x1(i,j,k) 
       end do
#endif

#ifdef GEOMETRY_CUBED_SPHERE
#ifdef USE_WB
       do i=lx1,ux1+1
        tmp = lgrid%eq_prim_x1(ieq_p,i,j,k)
        lgrid%fx1(i_rhovx1,i) = lgrid%fx1(i_rhovx1,i) - tmp*lgrid%ru%nn(1)%val(1,i)
        lgrid%fx1(i_rhovx2,i) = lgrid%fx1(i_rhovx2,i) - tmp*lgrid%ru%nn(1)%val(2,i)
#if sdims_make==3
        lgrid%fx1(i_rhovx3,i) = lgrid%fx1(i_rhovx3,i) - tmp*lgrid%ru%nn(1)%val(3,i) 
#endif
       end do
#endif
#endif

#ifdef GEOMETRY_2D_POLAR

       do i=lx1,ux1+1
 
        r = lgrid%r_x1(i,j,k)

        do iv=1,nvars
         lgrid%fx1(iv,i) = r*lgrid%fx1(iv,i)
        end do

#ifdef USE_WB
        lgrid%ru%pn(1)%val(i) = lgrid%ru%pn(1)%val(i) - lgrid%eq_prim_x1(ieq_p,i,j,k) 
#endif

       end do

#endif

#if defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)

       do i=lx1,ux1+1
 
        r = lgrid%r_x1(i,j,k)
        r2 = r*r 

        do iv=1,nvars
         lgrid%fx1(iv,i) = r2*lgrid%fx1(iv,i)
        end do
 
#ifdef USE_WB
        lgrid%ru%pn(1)%val(i) = lgrid%ru%pn(1)%val(i) - lgrid%eq_prim_x1(ieq_p,i,j,k) 
#endif

       end do

#endif

       do i=lx1,ux1

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
        inv_dl = rp1/(lgrid%coords_x1(1,i+1,j,k)-lgrid%coords_x1(1,i,j,k))
#endif

#ifdef NONUNIFORM_RADIAL_NODES
        rmi = lgrid%r_x1(i,j,k)
        rpl = lgrid%r_x1(i+1,j,k)
        inv_dl = rp1/(rpl-rmi)
#endif

#ifdef GEOMETRY_CUBED_SPHERE
        am = lgrid%A_x1(i,j,k)
        ap = lgrid%A_x1(i+1,j,k)
        tmp = lgrid%ivol(i,j,k)
        do iv=1,nvars
         lgrid%res(iv,i,j,k) = & 
         (ap*lgrid%fx1(iv,i+1)-am*lgrid%fx1(iv,i))*tmp
        end do
#else
        do iv=1,nvars
         lgrid%res(iv,i,j,k) = (lgrid%fx1(iv,i+1)-lgrid%fx1(iv,i))*inv_dl
        end do
#endif

#ifdef GEOMETRY_2D_POLAR

        r = lgrid%r(i,j,k)
        inv_r = rp1/r
        do iv=1,nvars
         lgrid%res(iv,i,j,k) = lgrid%res(iv,i,j,k)*inv_r
        end do

        lgrid%res(i_rhovx1,i,j,k) = lgrid%res(i_rhovx1,i,j,k) + &
        (lgrid%ru%pn(1)%val(i+1)-lgrid%ru%pn(1)%val(i))*inv_dl
         
#endif

#if defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)

        r = lgrid%r(i,j,k)
        r2 = r*r 
        inv_r2 = rp1/r2
        do iv=1,nvars
         lgrid%res(iv,i,j,k) = lgrid%res(iv,i,j,k)*inv_r2
        end do

        lgrid%res(i_rhovx1,i,j,k) = lgrid%res(i_rhovx1,i,j,k) + &
        (lgrid%ru%pn(1)%val(i+1)-lgrid%ru%pn(1)%val(i))*inv_dl
         
#endif

       end do

      end do
     end do

     inv_dl = lgrid%inv_dx2
     lgrid%ru%dir=2

#ifdef USE_INTERNAL_BOUNDARIES

     do iv=1,nvars
      bc_fac(iv) = rp1
     end do
#ifdef USE_MHD
     do iv=1,sdims
      bc_facb(iv) = rp1
     end do
#endif

     bc_fac(i_vx2) = -rp1
#ifdef USE_MHD
     bc_facb(2) = -rp1
#endif

     do k=lx3,ux3
      do j=lx2-1,ux2+1
       do i=lx1,ux1

        if(lgrid%is_solid(i,j,k)==0) then

         if(lgrid%is_solid(i,j-1,k)==1) then

          do iv=1,nvars
           lgrid%prim(iv,i,j-1,k)=bc_fac(iv)*lgrid%prim(iv,i,j,k)
          end do
#ifdef USE_MHD
          do iv=1,sdims
           lgrid%b_cc(iv,i,j-1,k) = bc_facb(iv)*lgrid%b_cc(iv,i,j,k)
          end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
          lgrid%temp(i,j-1,k) = lgrid%temp(i,j,k)
#endif
#ifdef USE_FASTEOS
          lgrid%gammaf(i_gammae,i,j-1,k) = lgrid%gammaf(i_gammae,i,j,k)
          lgrid%gammaf(i_gammac,i,j-1,k) = lgrid%gammaf(i_gammac,i,j,k)
#endif

          if((lgrid%is_solid(i,j+1,k)==0) .and. (j>=lx2)) then

           do iv=1,nvars
            lgrid%prim(iv,i,j-2,k)=bc_fac(iv)*lgrid%prim(iv,i,j+1,k)
           end do
#ifdef USE_MHD
           do iv=1,sdims
            lgrid%b_cc(iv,i,j-2,k) = bc_facb(iv)*lgrid%b_cc(iv,i,j+1,k)
           end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
           lgrid%temp(i,j-2,k) = lgrid%temp(i,j+1,k)
#endif
#ifdef USE_FASTEOS
           lgrid%gammaf(i_gammae,i,j-2,k) = lgrid%gammaf(i_gammae,i,j+1,k)
           lgrid%gammaf(i_gammac,i,j-2,k) = lgrid%gammaf(i_gammac,i,j+1,k)
#endif

          endif

         endif

         if(lgrid%is_solid(i,j+1,k)==1) then

          do iv=1,nvars
           lgrid%prim(iv,i,j+1,k)=bc_fac(iv)*lgrid%prim(iv,i,j,k)
          end do
#ifdef USE_MHD
          do iv=1,sdims
           lgrid%b_cc(iv,i,j+1,k) = bc_facb(iv)*lgrid%b_cc(iv,i,j,k)
          end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
          lgrid%temp(i,j+1,k) = lgrid%temp(i,j,k)
#endif
#ifdef USE_FASTEOS
          lgrid%gammaf(i_gammae,i,j+1,k) = lgrid%gammaf(i_gammae,i,j,k)
          lgrid%gammaf(i_gammac,i,j+1,k) = lgrid%gammaf(i_gammac,i,j,k)
#endif

          if((lgrid%is_solid(i,j-1,k)==0) .and. (j<=ux2)) then

           do iv=1,nvars
            lgrid%prim(iv,i,j+2,k)=bc_fac(iv)*lgrid%prim(iv,i,j-1,k)
           end do
#ifdef USE_MHD
           do iv=1,sdims
            lgrid%b_cc(iv,i,j+2,k) = bc_facb(iv)*lgrid%b_cc(iv,i,j-1,k)
           end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
           lgrid%temp(i,j+2,k) = lgrid%temp(i,j-1,k)
#endif
#ifdef USE_FASTEOS
           lgrid%gammaf(i_gammae,i,j+2,k) = lgrid%gammaf(i_gammae,i,j-1,k)
           lgrid%gammaf(i_gammac,i,j+2,k) = lgrid%gammaf(i_gammac,i,j-1,k)
#endif

          endif

         endif

        endif

       end do
      end do
     end do

#endif

     do k=lx3,ux3
#ifdef FIX_BFIELD_AT_X1
      do i=lx1-1,ux1+1
#else
      do i=lx1,ux1
#endif

#ifdef LIM2ND_REC

       do j=lx2-1,ux2+1

        do iv=1,nvars

         qm = lgrid%prim(iv,i,j-1,k)
         qc = lgrid%prim(iv,i,j,k)
         qp = lgrid%prim(iv,i,j+1,k)

         slopef = qp-qc
         slopeb = qc-qm
         prod = slopef*slopeb
         
         slope = rp0

         if(prod>rp0) then
          slope=prod/(slopef+slopeb)
         endif
         
         tmp = rph*slope
         qLbuf(iv) = qc - tmp
         qRbuf(iv) = qc + tmp

        end do

        if(j>=lx2) then
         do iv=1,nvars
          lgrid%qRx2(iv,j) = qLbuf(iv)
         end do
        endif

        if(j<=ux2) then
         do iv=1,nvars
          lgrid%qLx2(iv,j+1) = qRbuf(iv)
         end do
        endif

       end do

#endif

#ifdef PPH_REC

       do j=lx2-1,ux2+1

        do iv=1,i_p

         qm = lgrid%prim(iv,i,j-1,k)
         qc = lgrid%prim(iv,i,j,k)
         qp = lgrid%prim(iv,i,j+1,k)

         tmp = fvsixth*qc
         qLbuf(iv) =  othird*qm + tmp - osixth*qp
         qRbuf(iv) = -osixth*qm + tmp + othird*qp

        end do

#if nas_make>0

        do iv=i_as1,i_asl
 
         qm = lgrid%prim(iv,i,j-1,k)
         qc = lgrid%prim(iv,i,j,k)
         qp = lgrid%prim(iv,i,j+1,k)

         tmp = fvsixth*qc
         am =  othird*qm + tmp - osixth*qp
         ap = -osixth*qm + tmp + othird*qp

         mn = min(qm,qc)
         mx = max(qm,qc)

         if (am<mn) am = mn
         if (am>mx) am = mx

         mn = min(qc,qp)
         mx = max(qc,qp)

         if (ap<mn) ap = mn
         if (ap>mx) ap = mx

         am = am - qc
         ap = ap - qc

         if (ap*am>=rp0) then
          ap = rp0
          am = rp0
         else
          if (abs(ap)>=rp2*abs(am)) then
           ap = -rp2*am
          end if
          if (abs(am)>=rp2*abs(ap)) then
           am = -rp2*ap
          end if
         end if

         qLbuf(iv) = am + qc
         qRbuf(iv) = ap + qc

        end do

#endif

        if(j>=lx2) then
         do iv=1,nvars
          lgrid%qRx2(iv,j) = qLbuf(iv)
         end do
        endif

        if(j<=ux2) then
         do iv=1,nvars
          lgrid%qLx2(iv,j+1) = qRbuf(iv)
         end do
        endif

       end do

#endif

#ifdef LIM5TH_REC

       do j=lx2-1,ux2+1

        do iv=1,nvars

         qmm = lgrid%prim(iv,i,j-2,k)
         qm = lgrid%prim(iv,i,j-1,k)
         qc = lgrid%prim(iv,i,j,k)
         qp = lgrid%prim(iv,i,j+1,k)
         qpp = lgrid%prim(iv,i,j+2,k)

         tmp = rp329*qc
         am = (-rp21*qmm + rp189*qm + tmp - rp91*qp + rp14*qpp)*o420
         ap = (rp14*qmm - rp91*qm + tmp + rp189*qp - rp21*qpp)*o420

         mn = min(qm,qc)
         mx = max(qm,qc)

         if (am<mn) am = mn
         if (am>mx) am = mx

         mn = min(qc,qp)
         mx = max(qc,qp)

         if (ap<mn) ap = mn
         if (ap>mx) ap = mx

         am = am - qc
         ap = ap - qc

         if (ap*am>=rp0) then
          ap = rp0
          am = rp0
         else
          if (abs(ap)>=rp2*abs(am)) then
           ap = -rp2*am
          end if
          if (abs(am)>=rp2*abs(ap)) then
           am = -rp2*ap
          end if
         end if

         qLbuf(iv) = am + qc
         qRbuf(iv) = ap + qc

        end do

        if(j>=lx2) then
         do iv=1,nvars
          lgrid%qRx2(iv,j) = qLbuf(iv)
         end do
        endif

        if(j<=ux2) then
         do iv=1,nvars
          lgrid%qLx2(iv,j+1) = qRbuf(iv)
         end do
        endif

       end do

#endif

#ifdef USE_MHD

#ifdef LIM2ND_REC

       do j=lx2-1,ux2+1

        qm = lgrid%b_cc(1,i,j-1,k)
        qc = lgrid%b_cc(1,i,j,k)
        qp = lgrid%b_cc(1,i,j+1,k)

        slopef = qp-qc
        slopeb = qc-qm
        prod = slopef*slopeb
         
        slope = rp0

        if(prod>rp0) then
         slope=prod/(slopef+slopeb)
        endif
         
        tmp = rph*slope
        bLbuf(1) = qc - tmp
        bRbuf(1) = qc + tmp

#if sdims_make==3
        qm = lgrid%b_cc(3,i,j-1,k)
        qc = lgrid%b_cc(3,i,j,k)
        qp = lgrid%b_cc(3,i,j+1,k)

        slopef = qp-qc
        slopeb = qc-qm
        prod = slopef*slopeb
         
        slope = rp0

        if(prod>rp0) then
         slope=prod/(slopef+slopeb)
        endif
         
        tmp = rph*slope
        bLbuf(3) = qc - tmp
        bRbuf(3) = qc + tmp
#endif

        if(j>=lx2) then
         lgrid%bRx2(1,j) = bLbuf(1)
#if sdims_make==3
         lgrid%bRx2(3,j) = bLbuf(3)
#endif
        endif

        if(j<=ux2) then             
         lgrid%bLx2(1,j+1) = bRbuf(1)
#if sdims_make==3
         lgrid%bLx2(3,j+1) = bRbuf(3)
#endif
        endif

       end do

#endif

#ifdef PPH_REC

       do j=lx2-1,ux2+1

        qm = lgrid%b_cc(1,i,j-1,k)
        qc = lgrid%b_cc(1,i,j,k)
        qp = lgrid%b_cc(1,i,j+1,k)

        tmp = fvsixth*qc
        bLbuf(1) =  othird*qm + tmp - osixth*qp
        bRbuf(1) = -osixth*qm + tmp + othird*qp

#if sdims_make==3
        qm = lgrid%b_cc(3,i,j-1,k)
        qc = lgrid%b_cc(3,i,j,k)
        qp = lgrid%b_cc(3,i,j+1,k)

        tmp = fvsixth*qc
        bLbuf(3) =  othird*qm + tmp - osixth*qp
        bRbuf(3) = -osixth*qm + tmp + othird*qp
#endif        

        if(j>=lx2) then
         lgrid%bRx2(1,j) = bLbuf(1)
#if sdims_make==3
         lgrid%bRx2(3,j) = bLbuf(3)
#endif
        endif

        if(j<=ux2) then                              
         lgrid%bLx2(1,j+1) = bRbuf(1)
#if sdims_make==3
         lgrid%bLx2(3,j+1) = bRbuf(3)
#endif
        endif

       end do

#endif

#ifdef LIM5TH_REC

       do j=lx2-1,ux2+1

        qmm = lgrid%b_cc(1,i,j-2,k)
        qm = lgrid%b_cc(1,i,j-1,k)
        qc = lgrid%b_cc(1,i,j,k)
        qp = lgrid%b_cc(1,i,j+1,k)
        qpp = lgrid%b_cc(1,i,j+2,k)

        tmp = rp329*qc
        am = (-rp21*qmm + rp189*qm + tmp - rp91*qp + rp14*qpp)*o420
        ap = (rp14*qmm - rp91*qm + tmp + rp189*qp - rp21*qpp)*o420

        mn = min(qm,qc)
        mx = max(qm,qc)

        if (am<mn) am = mn
        if (am>mx) am = mx

        mn = min(qc,qp)
        mx = max(qc,qp)

        if (ap<mn) ap = mn
        if (ap>mx) ap = mx

        am = am - qc
        ap = ap - qc

        if (ap*am>=rp0) then
         ap = rp0
         am = rp0
        else
         if (abs(ap)>=rp2*abs(am)) then
          ap = -rp2*am
         end if
         if (abs(am)>=rp2*abs(ap)) then
          am = -rp2*ap
         end if
        end if

        bLbuf(1) = am + qc
        bRbuf(1) = ap + qc

#if sdims_make==3

        qmm = lgrid%b_cc(3,i,j-2,k)
        qm = lgrid%b_cc(3,i,j-1,k)
        qc = lgrid%b_cc(3,i,j,k)
        qp = lgrid%b_cc(3,i,j+1,k)
        qpp = lgrid%b_cc(3,i,j+2,k)

        tmp = rp329*qc
        am = (-rp21*qmm + rp189*qm + tmp - rp91*qp + rp14*qpp)*o420
        ap = (rp14*qmm - rp91*qm + tmp + rp189*qp - rp21*qpp)*o420

        mn = min(qm,qc)
        mx = max(qm,qc)

        if (am<mn) am = mn
        if (am>mx) am = mx

        mn = min(qc,qp)
        mx = max(qc,qp)

        if (ap<mn) ap = mn
        if (ap>mx) ap = mx

        am = am - qc
        ap = ap - qc

        if (ap*am>=rp0) then
         ap = rp0
         am = rp0
        else
         if (abs(ap)>=rp2*abs(am)) then
          ap = -rp2*am
         end if
         if (abs(am)>=rp2*abs(ap)) then
          am = -rp2*ap
         end if
        end if

        bLbuf(3) = am + qc
        bRbuf(3) = ap + qc

#endif

        if(j>=lx2) then
         lgrid%bRx2(1,j) = bLbuf(1)
#if sdims_make==3
         lgrid%bRx2(3,j) = bLbuf(3)
#endif
        endif

        if(j<=ux2) then
         lgrid%bLx2(1,j+1) = bRbuf(1)
#if sdims_make==3
         lgrid%bLx2(3,j+1) = bRbuf(3)
#endif
        endif

       end do
 
#endif

       do j=lx2,ux2+1
        tmp = lgrid%b_x2(i,j,k)
        lgrid%bLx2(2,j) = tmp
        lgrid%bRx2(2,j) = tmp
       end do

#endif

#ifdef USE_SHOCK_FLATTENING

        do j=lx2,ux2+1
         if(lgrid%is_flattened(i,j-1,k)==1 .or. lgrid%is_flattened(i,j,k)==1) then         
           lgrid%ru%is_flattened(2)%val(j) = 1
         else
           lgrid%ru%is_flattened(2)%val(j) = 0
         endif
        end do

        do j=lx2-1,ux2+1

         if(lgrid%is_flattened(i,j,k)==1) then
         
          do iv=1,nvars

           qm = lgrid%prim(iv,i,j-1,k)
           qc = lgrid%prim(iv,i,j,k)
           qp = lgrid%prim(iv,i,j+1,k)

           slopef = qp-qc
           slopeb = qc-qm
           prod = slopef*slopeb

           slope = rp0

           if(prod>rp0) then
            slope=prod/(slopef+slopeb)
           endif

           tmp = rph*slope
           qLbuf(iv) = qc - tmp
           qRbuf(iv) = qc + tmp

          end do

          if(j>=lx2) then
           do iv=1,nvars
            lgrid%qRx2(iv,j) = qLbuf(iv)
           end do
          endif

          if(j<=ux2) then
           do iv=1,nvars
            lgrid%qLx2(iv,j+1) = qRbuf(iv)
           end do
          endif

#ifdef USE_MHD

          do iv=1,sdims,2

           qm = lgrid%b_cc(iv,i,j-1,k)
           qc = lgrid%b_cc(iv,i,j,k)
           qp = lgrid%b_cc(iv,i,j+1,k)

           slopef = qp-qc
           slopeb = qc-qm
           prod = slopef*slopeb

           slope = rp0

           if(prod>rp0) then
            slope=prod/(slopef+slopeb)
           endif

           tmp = rph*slope
           bLbuf(iv) = qc - tmp
           bRbuf(iv) = qc + tmp

          end do

          if(j>=lx2) then
           do iv=1,sdims,2
            lgrid%bRx2(iv,j) = bLbuf(iv)
           end do
          endif

          if(j<=ux2) then
           do iv=1,sdims,2
            lgrid%bLx2(iv,j+1) = bRbuf(iv)
           end do
          endif

#endif

         end if

        end do

#endif

#ifndef GEOMETRY_CUBED_SPHERE
       do j=lx2,ux2+1
        
         vx1 = lgrid%qLx2(i_vx1,j)
         vx2 = lgrid%qLx2(i_vx2,j)
         lgrid%qLx2(i_vx1,j) = vx2
         lgrid%qLx2(i_vx2,j) = -vx1
        
         vx1 = lgrid%qRx2(i_vx1,j)
         vx2 = lgrid%qRx2(i_vx2,j)
         lgrid%qRx2(i_vx1,j) = vx2
         lgrid%qRx2(i_vx2,j) = -vx1

       end do
#endif

#ifdef USE_MHD

       do j=lx2,ux2+1
 
         vx1 = lgrid%bLx2(1,j)
         vx2 = lgrid%bLx2(2,j)
         lgrid%bLx2(1,j) = vx2
         lgrid%bLx2(2,j) = -vx1
        
         vx1 = lgrid%bRx2(1,j)
         vx2 = lgrid%bRx2(2,j)
         lgrid%bRx2(1,j) = vx2
         lgrid%bRx2(2,j) = -vx1

       end do

#endif

#ifdef USE_WB

       do j=lx2,ux2+1
 
         rho_eq = lgrid%eq_prim_x2(ieq_rho,i,j,k)
         p_eq = lgrid%eq_prim_x2(ieq_p,i,j,k)

         lgrid%qLx2(i_rho,j) = lgrid%qLx2(i_rho,j) + rho_eq
         lgrid%qRx2(i_rho,j) = lgrid%qRx2(i_rho,j) + rho_eq

         lgrid%qLx2(i_p,j) = lgrid%qLx2(i_p,j) + p_eq
         lgrid%qRx2(i_p,j) = lgrid%qRx2(i_p,j) + p_eq

       end do 

#endif

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
#ifndef USE_FASTEOS
       do j=lx2,ux2+1
        lgrid%ru%guess_temp(2)%val(j) = &
        rph*(lgrid%temp(i,j-1,k)+lgrid%temp(i,j,k))
       end do
#endif
#endif

#ifdef USE_FASTEOS

#ifdef LIM2ND_REC

       do j=lx2-1,ux2+1

        qm = lgrid%gammaf(i_gammae,i,j-1,k)
        qc = lgrid%gammaf(i_gammae,i,j,k)
        qp = lgrid%gammaf(i_gammae,i,j+1,k)

        slopef = qp-qc
        slopeb = qc-qm
        prod = slopef*slopeb
      
        slope = rp0

        if(prod>rp0) then
         slope=prod/(slopef+slopeb)
        endif
        
        tmp = rph*slope
        eosLbuf = qc - tmp
        eosRbuf = qc + tmp

        if(j>=lx2) then
          lgrid%ru%gammafR(2)%val(i_gammae,j) = eosLbuf
        endif

        if(j<=ux2) then
          lgrid%ru%gammafL(2)%val(i_gammae,j+1) = eosRbuf
        endif

       end do

       do j=lx2-1,ux2+1

        qm = lgrid%gammaf(i_gammac,i,j-1,k)
        qc = lgrid%gammaf(i_gammac,i,j,k)
        qp = lgrid%gammaf(i_gammac,i,j+1,k)

        slopef = qp-qc
        slopeb = qc-qm
        prod = slopef*slopeb
      
        slope = rp0

        if(prod>rp0) then
         slope=prod/(slopef+slopeb)
        endif
        
        tmp = rph*slope
        eosLbuf = qc - tmp
        eosRbuf = qc + tmp

        if(j>=lx2) then
          lgrid%ru%gammafR(2)%val(i_gammac,j) = eosLbuf
        endif

        if(j<=ux2) then
          lgrid%ru%gammafL(2)%val(i_gammac,j+1) = eosRbuf
        endif

       end do

#endif

#ifdef PPH_REC

       do j=lx2-1,ux2+1

        qm = lgrid%gammaf(i_gammae,i,j-1,k)
        qc = lgrid%gammaf(i_gammae,i,j,k)
        qp = lgrid%gammaf(i_gammae,i,j+1,k)

        tmp = fvsixth*qc
        eosLbuf =  othird*qm + tmp - osixth*qp
        eosRbuf = -osixth*qm + tmp + othird*qp
 
        if(j>=lx2) then
          lgrid%ru%gammafR(2)%val(i_gammae,j) = eosLbuf
        endif

        if(j<=ux2) then
          lgrid%ru%gammafL(2)%val(i_gammae,j+1) = eosRbuf
        endif
 
       end do
 
       do j=lx2-1,ux2+1

        qm = lgrid%gammaf(i_gammac,i,j-1,k)
        qc = lgrid%gammaf(i_gammac,i,j,k)
        qp = lgrid%gammaf(i_gammac,i,j+1,k)

        tmp = fvsixth*qc
        eosLbuf =  othird*qm + tmp - osixth*qp
        eosRbuf = -osixth*qm + tmp + othird*qp

        if(j>=lx2) then
          lgrid%ru%gammafR(2)%val(i_gammac,j) = eosLbuf
        endif

        if(j<=ux2) then
          lgrid%ru%gammafL(2)%val(i_gammac,j+1) = eosRbuf
        endif

       end do

#endif

#ifdef LIM5TH_REC

       do j=lx2-1,ux2+1

        qmm = lgrid%gammaf(i_gammae,i,j-2,k)
        qm  = lgrid%gammaf(i_gammae,i,j-1,k)
        qc  = lgrid%gammaf(i_gammae,i,j,k)
        qp  = lgrid%gammaf(i_gammae,i,j+1,k)
        qpp = lgrid%gammaf(i_gammae,i,j+2,k)

        tmp = rp329*qc
        am = (-rp21*qmm + rp189*qm + tmp - rp91*qp + rp14*qpp)*o420
        ap = (rp14*qmm - rp91*qm + tmp + rp189*qp - rp21*qpp)*o420

        mn = min(qm,qc)
        mx = max(qm,qc)

        if (am<mn) am = mn
        if (am>mx) am = mx

        mn = min(qc,qp)
        mx = max(qc,qp)

        if (ap<mn) ap = mn
        if (ap>mx) ap = mx

        am = am - qc
        ap = ap - qc

        if (ap*am>=rp0) then
         ap = rp0
         am = rp0
        else
         if (abs(ap)>=rp2*abs(am)) then
          ap = -rp2*am
         end if
         if (abs(am)>=rp2*abs(ap)) then
          am = -rp2*ap
         end if
        end if

        eosLbuf = am + qc
        eosRbuf = ap + qc

        if(j>=lx2) then
          lgrid%ru%gammafR(2)%val(i_gammae,j) = eosLbuf
        endif

        if(j<=ux2) then
          lgrid%ru%gammafL(2)%val(i_gammae,j+1) = eosRbuf
        endif

       end do

       do j=lx2-1,ux2+1

        qmm = lgrid%gammaf(i_gammac,i,j-2,k)
        qm  = lgrid%gammaf(i_gammac,i,j-1,k)
        qc  = lgrid%gammaf(i_gammac,i,j,k)
        qp  = lgrid%gammaf(i_gammac,i,j+1,k)
        qpp = lgrid%gammaf(i_gammac,i,j+2,k)

        tmp = rp329*qc
        am = (-rp21*qmm + rp189*qm + tmp - rp91*qp + rp14*qpp)*o420
        ap = (rp14*qmm - rp91*qm + tmp + rp189*qp - rp21*qpp)*o420

        mn = min(qm,qc)
        mx = max(qm,qc)

        if (am<mn) am = mn
        if (am>mx) am = mx

        mn = min(qc,qp)
        mx = max(qc,qp)

        if (ap<mn) ap = mn
        if (ap>mx) ap = mx

        am = am - qc
        ap = ap - qc

        if (ap*am>=rp0) then
         ap = rp0
         am = rp0
        else
         if (abs(ap)>=rp2*abs(am)) then
          ap = -rp2*am
         end if
         if (abs(am)>=rp2*abs(ap)) then
          am = -rp2*ap
         end if
        end if

        eosLbuf = am + qc
        eosRbuf = ap + qc

        if(j>=lx2) then
          lgrid%ru%gammafR(2)%val(i_gammac,j) = eosLbuf
        endif

        if(j<=ux2) then
          lgrid%ru%gammafL(2)%val(i_gammac,j+1) = eosRbuf
        endif

       end do

#endif

#ifdef USE_SHOCK_FLATTENING
       do j=lx2-1,ux2+1
         if(lgrid%is_flattened(i,j,k)==1) then

          do iv=1,2

           qm = lgrid%gammaf(iv,i,j-1,k)
           qc = lgrid%gammaf(iv,i,j,k)
           qp = lgrid%gammaf(iv,i,j+1,k)

           slopef = qp-qc
           slopeb = qc-qm
           prod = slopef*slopeb

           slope = rp0

           if(prod>rp0) then
            slope=prod/(slopef+slopeb)
           endif

           tmp = rph*slope
           qLbuf(iv) = qc - tmp
           qRbuf(iv) = qc + tmp


          end do

          if(j>=lx2) then
           do iv=1,2
            lgrid%ru%gammafR(2)%val(iv,j)= qLbuf(iv)
           end do
          endif

          if(j<=ux2) then
           do iv=1,2
            lgrid%ru%gammafL(2)%val(iv,j+1)= qRbuf(iv)
           end do
          endif

       end if

      end do
#endif

#ifdef USE_WB

       do j=lx2,ux2+1
 
         p_eq = lgrid%eq_gammae_x2(i,j,k)

         lgrid%ru%gammafL(2)%val(i_gammae,j) = &
         lgrid%ru%gammafL(2)%val(i_gammae,j) + p_eq

         lgrid%ru%gammafR(2)%val(i_gammae,j) = &
         lgrid%ru%gammafR(2)%val(i_gammae,j) + p_eq

       end do 

#endif

#endif

#ifdef ADVECT_SPECIES

       do j=lx2,ux2+1

        tmp = rp0
        do iv=1,nspecies
         tmp = tmp + lgrid%qLx2(i_as1+iv-1,j)
        end do

        tmp = rp1/tmp

        do iv=1,nspecies
         lgrid%qLx2(i_as1+iv-1,j) = lgrid%qLx2(i_as1+iv-1,j)*tmp
        end do

        tmp = rp0
        do iv=1,nspecies
         tmp = tmp + lgrid%qRx2(i_as1+iv-1,j)
        end do

        tmp = rp1/tmp

        do iv=1,nspecies
         lgrid%qRx2(i_as1+iv-1,j) = lgrid%qRx2(i_as1+iv-1,j)*tmp
        end do

       end do

#endif
      
#ifdef GEOMETRY_CUBED_SPHERE
       do j=lx2,ux2+1
        lgrid%ru%nn(2)%val(1,j) = lgrid%n_x2(1,i,j,k)
        lgrid%ru%nn(2)%val(2,j) = lgrid%n_x2(2,i,j,k)
#if sdims_make==3        
        lgrid%ru%nn(2)%val(3,j) = lgrid%n_x2(3,i,j,k)
#endif
       end do
#endif

#ifdef USE_MHD
       call riemann(lx2,ux2+1,lgrid%qLx2,lgrid%qRx2,lgrid%bLx2,lgrid%bRx2,lgrid%fx2,lgrid%fbx2,lgrid%ru)
#else
       call riemann(lx2,ux2+1,lgrid%qLx2,lgrid%qRx2,lgrid%fx2,lgrid%ru)
#endif

#ifndef GEOMETRY_CUBED_SPHERE
       do j=lx2,ux2+1
        
         vx1 = lgrid%fx2(i_rhovx1,j)
         vx2 = lgrid%fx2(i_rhovx2,j)

         lgrid%fx2(i_rhovx1,j) = -vx2
         lgrid%fx2(i_rhovx2,j) = vx1

       end do
#endif

#ifdef USE_MHD
 
       do j=lx2,ux2+1
      
         vx1 = lgrid%fbx2(1,j)
         vx2 = lgrid%fbx2(2,j)

         lgrid%fbx2(1,j) = -vx2
         lgrid%fbx2(2,j) = vx1

#if sdims_make==3
         lgrid%emf_x2(1,i,j,k) = -lgrid%fbx2(3,j)
         lgrid%emf_x2(2,i,j,k) = rp0
#endif
         lgrid%emf_x2(3,i,j,k) = lgrid%fbx2(1,j)
          
         tmp = rph*(lgrid%qLx2(i_rho,j)+lgrid%qRx2(i_rho,j))*lgrid%smax
         mach = lgrid%fx2(i_rho,j) / tmp

         sgn = rp0
         if(mach>Mach_ct) then
          sgn = rp1        
         endif
         if(mach<-Mach_ct) then
          sgn = -rp1        
         endif

         lgrid%sign_frho_x2(i,j,k) = sgn
  
       end do

#endif

#if defined(GEOMETRY_CARTESIAN_UNIFORM) || defined(GEOMETRY_CARTESIAN_NONUNIFORM)
#ifdef USE_WB

       do j=lx2,ux2+1
         lgrid%fx2(i_rhovx2,j) = lgrid%fx2(i_rhovx2,j) - lgrid%eq_prim_x2(ieq_p,i,j,k)
       end do

#endif
#endif

#ifdef EVOLVE_ETOT

       do j=lx2,ux2+1 
         lgrid%fx2(i_rhoe,j) = lgrid%fx2(i_rhoe,j) + &
         lgrid%fx2(i_rho,j)*lgrid%phi_x2(i,j,k)
       end do

#endif

#ifdef GEOMETRY_CUBED_SPHERE
#ifdef USE_WB

       do j=lx2,ux2+1
         tmp = lgrid%eq_prim_x2(ieq_p,i,j,k)
         lgrid%fx2(i_rhovx1,j) = lgrid%fx2(i_rhovx1,j) - tmp*lgrid%ru%nn(2)%val(1,j)
         lgrid%fx2(i_rhovx2,j) = lgrid%fx2(i_rhovx2,j) - tmp*lgrid%ru%nn(2)%val(2,j)
#if sdims_make==3         
         lgrid%fx2(i_rhovx3,j) = lgrid%fx2(i_rhovx3,j) - tmp*lgrid%ru%nn(2)%val(3,j)
#endif         
       end do

#endif
#endif

#ifdef GEOMETRY_2D_POLAR
#ifdef USE_WB

       do j=lx2,ux2+1 
         lgrid%ru%pn(2)%val(j) = lgrid%ru%pn(2)%val(j) - lgrid%eq_prim_x2(ieq_p,i,j,k) 
       end do

#endif
#endif

#if defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
 
       do j=lx2,ux2+1
 
         sin_theta = lgrid%sin_theta_x2(i,j,k)

         do iv=1,nvars
          lgrid%fx2(iv,j) = sin_theta*lgrid%fx2(iv,j)
         end do

#ifdef USE_WB
         lgrid%ru%pn(2)%val(j) = lgrid%ru%pn(2)%val(j) - lgrid%eq_prim_x2(ieq_p,i,j,k) 
#endif

       end do
 
#endif

       do j=lx2,ux2

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
        inv_dl = rp1/(lgrid%coords_x2(2,i,j+1,k)-lgrid%coords_x2(2,i,j,k))
#endif

#ifdef GEOMETRY_2D_POLAR

        r = lgrid%r(i,j,k)
        inv_r = rp1/r
 
        do iv=1,nvars
         lgrid%res(iv,i,j,k) = lgrid%res(iv,i,j,k) + &
         (lgrid%fx2(iv,j+1)-lgrid%fx2(iv,j))*inv_dl*inv_r
        end do       
        
        lgrid%res(i_rhovx2,i,j,k) = lgrid%res(i_rhovx2,i,j,k) + &
        (lgrid%ru%pn(2)%val(j+1)-lgrid%ru%pn(2)%val(j))*inv_dl*inv_r

#elif defined(GEOMETRY_2D_SPHERICAL)

        inv_r_sin_theta = rp1/lgrid%coords(1,i,j,k)
        
        do iv=1,nvars
         lgrid%res(iv,i,j,k) = lgrid%res(iv,i,j,k) + &
         (lgrid%fx2(iv,j+1)-lgrid%fx2(iv,j))*inv_dl*inv_r_sin_theta
        end do       

        r = lgrid%r(i,j,k)

        lgrid%res(i_rhovx2,i,j,k) = lgrid%res(i_rhovx2,i,j,k) + &
        (lgrid%ru%pn(2)%val(j+1)-lgrid%ru%pn(2)%val(j))*inv_dl/r

#elif defined(GEOMETRY_3D_SPHERICAL)

        r = lgrid%r(i,j,k)
        inv_r_sin_theta = lgrid%inv_r_sin_theta(i,j,k)
        
        do iv=1,nvars
         lgrid%res(iv,i,j,k) = lgrid%res(iv,i,j,k) + &
         (lgrid%fx2(iv,j+1)-lgrid%fx2(iv,j))*inv_dl*inv_r_sin_theta
        end do       

        lgrid%res(i_rhovx2,i,j,k) = lgrid%res(i_rhovx2,i,j,k) + &
        (lgrid%ru%pn(2)%val(j+1)-lgrid%ru%pn(2)%val(j))*inv_dl/r

#elif defined(GEOMETRY_CUBED_SPHERE)

        am = lgrid%A_x2(i,j,k)
        ap = lgrid%A_x2(i,j+1,k)
        tmp = lgrid%ivol(i,j,k)

        do iv=1,nvars
         lgrid%res(iv,i,j,k) = lgrid%res(iv,i,j,k) + &
         (ap*lgrid%fx2(iv,j+1)-am*lgrid%fx2(iv,j))*tmp
        end do

#else

        do iv=1,nvars
         lgrid%res(iv,i,j,k) = lgrid%res(iv,i,j,k) + &
         (lgrid%fx2(iv,j+1)-lgrid%fx2(iv,j))*inv_dl
        end do

#endif

       end do

      end do
     end do
 
#if sdims_make==3

     inv_dl = lgrid%inv_dx3
     lgrid%ru%dir=3

#ifdef USE_INTERNAL_BOUNDARIES

     do iv=1,nvars
      bc_fac(iv) = rp1
     end do
#ifdef USE_MHD
     do iv=1,sdims
      bc_facb(iv) = rp1
     end do
#endif

     bc_fac(i_vx3) = -rp1
#ifdef USE_MHD
     bc_facb(3) = -rp1
#endif

     do k=lx3-1,ux3+1
      do j=lx2,ux2
       do i=lx1,ux1

        if(lgrid%is_solid(i,j,k)==0) then

         if(lgrid%is_solid(i,j,k-1)==1) then

          do iv=1,nvars
           lgrid%prim(iv,i,j,k-1)=bc_fac(iv)*lgrid%prim(iv,i,j,k)
          end do
#ifdef USE_MHD
          do iv=1,sdims
           lgrid%b_cc(iv,i,j,k-1) = bc_facb(iv)*lgrid%b_cc(iv,i,j,k)
          end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
          lgrid%temp(i,j,k-1) = lgrid%temp(i,j,k)
#endif
#ifdef USE_FASTEOS
          lgrid%gammaf(i_gammae,i,j,k-1) = lgrid%gammaf(i_gammae,i,j,k)
          lgrid%gammaf(i_gammac,i,j,k-1) = lgrid%gammaf(i_gammac,i,j,k)
#endif

          if((lgrid%is_solid(i,j,k+1)==0) .and. (k>=lx3)) then

           do iv=1,nvars
            lgrid%prim(iv,i,j,k-2)=bc_fac(iv)*lgrid%prim(iv,i,j,k+1)
           end do
#ifdef USE_MHD
           do iv=1,sdims
            lgrid%b_cc(iv,i,j,k-2) = bc_facb(iv)*lgrid%b_cc(iv,i,j,k+1)
           end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
           lgrid%temp(i,j,k-2) = lgrid%temp(i,j,k+1)
#endif
#ifdef USE_FASTEOS
           lgrid%gammaf(i_gammae,i,j,k-2) = lgrid%gammaf(i_gammae,i,j,k+1)
           lgrid%gammaf(i_gammac,i,j,k-2) = lgrid%gammaf(i_gammac,i,j,k+1)
#endif

          endif

         endif

         if(lgrid%is_solid(i,j,k+1)==1) then

          do iv=1,nvars
           lgrid%prim(iv,i,j,k+1)=bc_fac(iv)*lgrid%prim(iv,i,j,k)
          end do
#ifdef USE_MHD
          do iv=1,sdims
           lgrid%b_cc(iv,i,j,k+1) = bc_facb(iv)*lgrid%b_cc(iv,i,j,k)
          end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
          lgrid%temp(i,j,k+1) = lgrid%temp(i,j,k)
#endif
#ifdef USE_FASTEOS
          lgrid%gammaf(i_gammae,i,j,k+1) = lgrid%gammaf(i_gammae,i,j,k)
          lgrid%gammaf(i_gammac,i,j,k+1) = lgrid%gammaf(i_gammac,i,j,k)
#endif

          if((lgrid%is_solid(i,j,k-1)==0) .and. (k<=ux3)) then

           do iv=1,nvars
            lgrid%prim(iv,i,j,k+2)=bc_fac(iv)*lgrid%prim(iv,i,j,k-1)
           end do
#ifdef USE_MHD
           do iv=1,sdims
            lgrid%b_cc(iv,i,j,k+2) = bc_facb(iv)*lgrid%b_cc(iv,i,j,k-1)
           end do
#endif
#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
           lgrid%temp(i,j,k+2) = lgrid%temp(i,j,k-1)
#endif
#ifdef USE_FASTEOS
           lgrid%gammaf(i_gammae,i,j,k+2) = lgrid%gammaf(i_gammae,i,j,k-1)
           lgrid%gammaf(i_gammac,i,j,k+2) = lgrid%gammaf(i_gammac,i,j,k-1)
#endif

          endif

         endif

        endif

       end do
      end do
     end do

#endif

     do j=lx2,ux2
      do i=lx1,ux1

#ifdef LIM2ND_REC

       do k=lx3-1,ux3+1

        do iv=1,nvars

         qm = lgrid%prim(iv,i,j,k-1)
         qc = lgrid%prim(iv,i,j,k)
         qp = lgrid%prim(iv,i,j,k+1)

         slopef = qp-qc
         slopeb = qc-qm
         prod = slopef*slopeb

         slope = rp0
          
         if(prod>rp0) then
          slope=prod/(slopef+slopeb)
         endif
         
         tmp = rph*slope
         qLbuf(iv) = qc - tmp
         qRbuf(iv) = qc + tmp

        end do

        if(k>=lx3) then
         do iv=1,nvars
          lgrid%qRx3(iv,k) = qLbuf(iv)
         end do
        endif

        if(k<=ux3) then
         do iv=1,nvars
          lgrid%qLx3(iv,k+1) = qRbuf(iv)
         end do
        endif

       end do

#endif

#ifdef PPH_REC

       do k=lx3-1,ux3+1

        do iv=1,i_p

         qm = lgrid%prim(iv,i,j,k-1)
         qc = lgrid%prim(iv,i,j,k)
         qp = lgrid%prim(iv,i,j,k+1)

         tmp = fvsixth*qc
         qLbuf(iv) =  othird*qm + tmp - osixth*qp
         qRbuf(iv) = -osixth*qm + tmp + othird*qp

        end do

#if nas_make>0

        do iv=i_as1,i_asl
 
         qm = lgrid%prim(iv,i,j,k-1)
         qc = lgrid%prim(iv,i,j,k)
         qp = lgrid%prim(iv,i,j,k+1)

         tmp = fvsixth*qc
         am =  othird*qm + tmp - osixth*qp
         ap = -osixth*qm + tmp + othird*qp

         mn = min(qm,qc)
         mx = max(qm,qc)

         if (am<mn) am = mn
         if (am>mx) am = mx

         mn = min(qc,qp)
         mx = max(qc,qp)

         if (ap<mn) ap = mn
         if (ap>mx) ap = mx

         am = am - qc
         ap = ap - qc

         if (ap*am>=rp0) then
          ap = rp0
          am = rp0
         else
          if (abs(ap)>=rp2*abs(am)) then
           ap = -rp2*am
          end if
          if (abs(am)>=rp2*abs(ap)) then
           am = -rp2*ap
          end if
         end if

         qLbuf(iv) = am + qc
         qRbuf(iv) = ap + qc

        end do

#endif

        if(k>=lx3) then
         do iv=1,nvars
          lgrid%qRx3(iv,k) = qLbuf(iv)
         end do
        endif

        if(k<=ux3) then
         do iv=1,nvars
          lgrid%qLx3(iv,k+1) = qRbuf(iv)
         end do
        endif

       end do

#endif

#ifdef LIM5TH_REC

       do k=lx3-1,ux3+1

        do iv=1,nvars

         qmm = lgrid%prim(iv,i,j,k-2)
         qm = lgrid%prim(iv,i,j,k-1)
         qc = lgrid%prim(iv,i,j,k)
         qp = lgrid%prim(iv,i,j,k+1)
         qpp = lgrid%prim(iv,i,j,k+2)

         tmp = rp329*qc
         am = (-rp21*qmm + rp189*qm + tmp - rp91*qp + rp14*qpp)*o420
         ap = (rp14*qmm - rp91*qm + tmp + rp189*qp - rp21*qpp)*o420

         mn = min(qm,qc)
         mx = max(qm,qc)

         if (am<mn) am = mn
         if (am>mx) am = mx

         mn = min(qc,qp)
         mx = max(qc,qp)

         if (ap<mn) ap = mn
         if (ap>mx) ap = mx

         am = am - qc
         ap = ap - qc

         if (ap*am>=rp0) then
          ap = rp0
          am = rp0
         else
          if (abs(ap)>=rp2*abs(am)) then
           ap = -rp2*am
          end if
          if (abs(am)>=rp2*abs(ap)) then
           am = -rp2*ap
          end if
         end if

         qLbuf(iv) = am + qc
         qRbuf(iv) = ap + qc

        end do

        if(k>=lx3) then
         do iv=1,nvars
          lgrid%qRx3(iv,k) = qLbuf(iv)
         end do
        endif

        if(k<=ux3) then
         do iv=1,nvars
          lgrid%qLx3(iv,k+1) = qRbuf(iv)
         end do
        endif

       end do

#endif

#ifdef USE_MHD

#ifdef LIM2ND_REC

       do k=lx3-1,ux3+1

        do iv=1,2

         qm = lgrid%b_cc(iv,i,j,k-1)
         qc = lgrid%b_cc(iv,i,j,k)
         qp = lgrid%b_cc(iv,i,j,k+1)

         slopef = qp-qc
         slopeb = qc-qm
         prod = slopef*slopeb

         slope = rp0
          
         if(prod>rp0) then
          slope=prod/(slopef+slopeb)
         endif
         
         tmp = rph*slope
         bLbuf(iv) = qc - tmp
         bRbuf(iv) = qc + tmp

        end do

        if(k>=lx3) then
         do iv=1,2
          lgrid%bRx3(iv,k) = bLbuf(iv)
         end do
        endif

        if(k<=ux3) then
         do iv=1,2
          lgrid%bLx3(iv,k+1) = bRbuf(iv)
         end do
        endif

       end do

#endif

#ifdef PPH_REC

       do k=lx3-1,ux3+1

        do iv=1,2

         qm = lgrid%b_cc(iv,i,j,k-1)
         qc = lgrid%b_cc(iv,i,j,k)
         qp = lgrid%b_cc(iv,i,j,k+1)

         tmp = fvsixth*qc
         bLbuf(iv) =  othird*qm + tmp - osixth*qp
         bRbuf(iv) = -osixth*qm + tmp + othird*qp

        end do

        if(k>=lx3) then
         do iv=1,2
          lgrid%bRx3(iv,k) = bLbuf(iv)
         end do
        endif

        if(k<=ux3) then
         do iv=1,2
          lgrid%bLx3(iv,k+1) = bRbuf(iv)
         end do
        endif

       end do

#endif

#ifdef LIM5TH_REC

       do k=lx3-1,ux3+1

        do iv=1,2

         qmm = lgrid%b_cc(iv,i,j,k-2)
         qm = lgrid%b_cc(iv,i,j,k-1)
         qc = lgrid%b_cc(iv,i,j,k)
         qp = lgrid%b_cc(iv,i,j,k+1)
         qpp = lgrid%b_cc(iv,i,j,k+2)

         tmp = rp329*qc
         am = (-rp21*qmm + rp189*qm + tmp - rp91*qp + rp14*qpp)*o420
         ap = (rp14*qmm - rp91*qm + tmp + rp189*qp - rp21*qpp)*o420

         mn = min(qm,qc)
         mx = max(qm,qc)

         if (am<mn) am = mn
         if (am>mx) am = mx

         mn = min(qc,qp)
         mx = max(qc,qp)

         if (ap<mn) ap = mn
         if (ap>mx) ap = mx

         am = am - qc
         ap = ap - qc

         if (ap*am>=rp0) then
          ap = rp0
          am = rp0
         else
          if (abs(ap)>=rp2*abs(am)) then
           ap = -rp2*am
          end if
          if (abs(am)>=rp2*abs(ap)) then
           am = -rp2*ap
          end if
         end if

         bLbuf(iv) = am + qc
         bRbuf(iv) = ap + qc

        end do

        if(k>=lx3) then
         do iv=1,2
          lgrid%bRx3(iv,k) = bLbuf(iv)
         end do
        endif

        if(k<=ux3) then
         do iv=1,2
          lgrid%bLx3(iv,k+1) = bRbuf(iv)
         end do
        endif

       end do

#endif

       do k=lx3,ux3+1
        tmp = lgrid%b_x3(i,j,k)
        lgrid%bLx3(3,k) = tmp
        lgrid%bRx3(3,k) = tmp
       end do

#endif

#ifdef USE_SHOCK_FLATTENING

        do k=lx3,ux3+1
         if(lgrid%is_flattened(i,j,k-1)==1 .or. lgrid%is_flattened(i,j,k)==1) then         
           lgrid%ru%is_flattened(3)%val(k) = 1
         else
           lgrid%ru%is_flattened(3)%val(k) = 0
         endif
        end do

        do k=lx3-1,ux3+1

         if(lgrid%is_flattened(i,j,k)==1) then
         
          do iv=1,nvars

           qm = lgrid%prim(iv,i,j,k-1)
           qc = lgrid%prim(iv,i,j,k)
           qp = lgrid%prim(iv,i,j,k+1)

           slopef = qp-qc
           slopeb = qc-qm
           prod = slopef*slopeb

           slope = rp0

           if(prod>rp0) then
            slope=prod/(slopef+slopeb)
           endif

           tmp = rph*slope
           qLbuf(iv) = qc - tmp
           qRbuf(iv) = qc + tmp

          end do

          if(k>=lx3) then
           do iv=1,nvars
            lgrid%qRx3(iv,k) = qLbuf(iv)
           end do
          endif

          if(k<=ux3) then
           do iv=1,nvars
            lgrid%qLx3(iv,k+1) = qRbuf(iv)
           end do
          endif

#ifdef USE_MHD

          do iv=2,3

           qm = lgrid%b_cc(iv,i,j,k-1)
           qc = lgrid%b_cc(iv,i,j,k)
           qp = lgrid%b_cc(iv,i,j,k+1)

           slopef = qp-qc
           slopeb = qc-qm
           prod = slopef*slopeb

           slope = rp0

           if(prod>rp0) then
            slope=prod/(slopef+slopeb)
           endif

           tmp = rph*slope
           bLbuf(iv) = qc - tmp
           bRbuf(iv) = qc + tmp

          end do

          if(k>=lx3) then
           do iv=2,3
            lgrid%bRx3(iv,k) = bLbuf(iv)
           end do
          endif

          if(k<=ux3) then
           do iv=2,3
            lgrid%bLx3(iv,k+1) = bRbuf(iv)
           end do
          endif

#endif

         end if

        end do

#endif

#ifndef GEOMETRY_CUBED_SPHERE
       do k=lx3,ux3+1
        
         vx1 = lgrid%qLx3(i_vx1,k)
         vx2 = lgrid%qLx3(i_vx2,k)
         vx3 = lgrid%qLx3(i_vx3,k)

         lgrid%qLx3(i_vx1,k) = vx3
         lgrid%qLx3(i_vx2,k) = vx1
         lgrid%qLx3(i_vx3,k) = vx2
        
         vx1 = lgrid%qRx3(i_vx1,k)
         vx2 = lgrid%qRx3(i_vx2,k)
         vx3 = lgrid%qRx3(i_vx3,k)

         lgrid%qRx3(i_vx1,k) = vx3
         lgrid%qRx3(i_vx2,k) = vx1
         lgrid%qRx3(i_vx3,k) = vx2

       end do
#endif       

#ifdef USE_MHD
 
       do k=lx3,ux3+1
         
         vx1 = lgrid%bLx3(1,k)
         vx2 = lgrid%bLx3(2,k)
         vx3 = lgrid%bLx3(3,k)

         lgrid%bLx3(1,k) = vx3
         lgrid%bLx3(2,k) = vx1
         lgrid%bLx3(3,k) = vx2
        
         vx1 = lgrid%bRx3(1,k)
         vx2 = lgrid%bRx3(2,k)
         vx3 = lgrid%bRx3(3,k)

         lgrid%bRx3(1,k) = vx3
         lgrid%bRx3(2,k) = vx1
         lgrid%bRx3(3,k) = vx2

       end do
       
#endif

#ifdef USE_WB

       do k=lx3,ux3+1
       
         rho_eq = lgrid%eq_prim_x3(ieq_rho,i,j,k)
         p_eq = lgrid%eq_prim_x3(ieq_p,i,j,k)

         lgrid%qLx3(i_rho,k) = lgrid%qLx3(i_rho,k) + rho_eq
         lgrid%qRx3(i_rho,k) = lgrid%qRx3(i_rho,k) + rho_eq

         lgrid%qLx3(i_p,k) = lgrid%qLx3(i_p,k) + p_eq
         lgrid%qRx3(i_p,k) = lgrid%qRx3(i_p,k) + p_eq

       end do 
 
#endif

#if defined(HELMHOLTZ_EOS) || defined(USE_PRAD) || defined(PIG_EOS)
#ifndef USE_FASTEOS
       do k=lx3,ux3+1
        lgrid%ru%guess_temp(3)%val(k) = &
        rph*(lgrid%temp(i,j,k-1)+lgrid%temp(i,j,k))
       end do
#endif
#endif

#ifdef USE_FASTEOS

#ifdef LIM2ND_REC

       do k=lx3-1,ux3+1

        qm = lgrid%gammaf(i_gammae,i,j,k-1)
        qc = lgrid%gammaf(i_gammae,i,j,k)
        qp = lgrid%gammaf(i_gammae,i,j,k+1)

        slopef = qp-qc
        slopeb = qc-qm
        prod = slopef*slopeb
      
        slope = rp0

        if(prod>rp0) then
         slope=prod/(slopef+slopeb)
        endif
        
        tmp = rph*slope
        eosLbuf = qc - tmp
        eosRbuf = qc + tmp

        if(k>=lx3) then
          lgrid%ru%gammafR(3)%val(i_gammae,k) = eosLbuf
        endif

        if(k<=ux3) then
          lgrid%ru%gammafL(3)%val(i_gammae,k+1) = eosRbuf
        endif

       end do

       do k=lx3-1,ux3+1

        qm = lgrid%gammaf(i_gammac,i,j,k-1)
        qc = lgrid%gammaf(i_gammac,i,j,k)
        qp = lgrid%gammaf(i_gammac,i,j,k+1)

        slopef = qp-qc
        slopeb = qc-qm
        prod = slopef*slopeb
      
        slope = rp0

        if(prod>rp0) then
         slope=prod/(slopef+slopeb)
        endif
        
        tmp = rph*slope
        eosLbuf = qc - tmp
        eosRbuf = qc + tmp

        if(k>=lx3) then
          lgrid%ru%gammafR(3)%val(i_gammac,k) = eosLbuf
        endif

        if(k<=ux3) then
          lgrid%ru%gammafL(3)%val(i_gammac,k+1) = eosRbuf
        endif

       end do

#endif

#ifdef PPH_REC

       do k=lx3-1,ux3+1

        qm = lgrid%gammaf(i_gammae,i,j,k-1)
        qc = lgrid%gammaf(i_gammae,i,j,k)
        qp = lgrid%gammaf(i_gammae,i,j,k+1)

        tmp = fvsixth*qc
        eosLbuf =  othird*qm + tmp - osixth*qp
        eosRbuf = -osixth*qm + tmp + othird*qp
 
        if(k>=lx3) then
          lgrid%ru%gammafR(3)%val(i_gammae,k) = eosLbuf
        endif

        if(k<=ux3) then
          lgrid%ru%gammafL(3)%val(i_gammae,k+1) = eosRbuf
        endif

       end do

       do k=lx3-1,ux3+1

        qm = lgrid%gammaf(i_gammac,i,j,k-1)
        qc = lgrid%gammaf(i_gammac,i,j,k)
        qp = lgrid%gammaf(i_gammac,i,j,k+1)

        tmp = fvsixth*qc
        eosLbuf =  othird*qm + tmp - osixth*qp
        eosRbuf = -osixth*qm + tmp + othird*qp

        if(k>=lx3) then
          lgrid%ru%gammafR(3)%val(i_gammac,k) = eosLbuf
        endif

        if(k<=ux3) then
          lgrid%ru%gammafL(3)%val(i_gammac,k+1) = eosRbuf
        endif

       end do

#endif

#ifdef LIM5TH_REC

       do k=lx3-1,ux3+1

        qmm = lgrid%gammaf(i_gammae,i,j,k-2)
        qm  = lgrid%gammaf(i_gammae,i,j,k-1)
        qc  = lgrid%gammaf(i_gammae,i,j,k)
        qp  = lgrid%gammaf(i_gammae,i,j,k+1)
        qpp = lgrid%gammaf(i_gammae,i,j,k+2)

        tmp = rp329*qc
        am = (-rp21*qmm + rp189*qm + tmp - rp91*qp + rp14*qpp)*o420
        ap = (rp14*qmm - rp91*qm + tmp + rp189*qp - rp21*qpp)*o420

        mn = min(qm,qc)
        mx = max(qm,qc)

        if (am<mn) am = mn
        if (am>mx) am = mx

        mn = min(qc,qp)
        mx = max(qc,qp)

        if (ap<mn) ap = mn
        if (ap>mx) ap = mx

        am = am - qc
        ap = ap - qc

        if (ap*am>=rp0) then
         ap = rp0
         am = rp0
        else
         if (abs(ap)>=rp2*abs(am)) then
          ap = -rp2*am
         end if
         if (abs(am)>=rp2*abs(ap)) then
          am = -rp2*ap
         end if
        end if

        eosLbuf = am + qc
        eosRbuf = ap + qc

        if(k>=lx3) then
          lgrid%ru%gammafR(3)%val(i_gammae,k) = eosLbuf
        endif

        if(k<=ux3) then
          lgrid%ru%gammafL(3)%val(i_gammae,k+1) = eosRbuf
        endif

       end do

       do k=lx3-1,ux3+1

        qmm = lgrid%gammaf(i_gammac,i,j,k-2)
        qm  = lgrid%gammaf(i_gammac,i,j,k-1)
        qc  = lgrid%gammaf(i_gammac,i,j,k)
        qp  = lgrid%gammaf(i_gammac,i,j,k+1)
        qpp = lgrid%gammaf(i_gammac,i,j,k+2)

        tmp = rp329*qc
        am = (-rp21*qmm + rp189*qm + tmp - rp91*qp + rp14*qpp)*o420
        ap = (rp14*qmm - rp91*qm + tmp + rp189*qp - rp21*qpp)*o420

        mn = min(qm,qc)
        mx = max(qm,qc)

        if (am<mn) am = mn
        if (am>mx) am = mx

        mn = min(qc,qp)
        mx = max(qc,qp)

        if (ap<mn) ap = mn
        if (ap>mx) ap = mx

        am = am - qc
        ap = ap - qc

        if (ap*am>=rp0) then
         ap = rp0
         am = rp0
        else
         if (abs(ap)>=rp2*abs(am)) then
          ap = -rp2*am
         end if
         if (abs(am)>=rp2*abs(ap)) then
          am = -rp2*ap
         end if
        end if

        eosLbuf = am + qc
        eosRbuf = ap + qc

        if(k>=lx3) then
          lgrid%ru%gammafR(3)%val(i_gammac,k) = eosLbuf
        endif

        if(k<=ux3) then
          lgrid%ru%gammafL(3)%val(i_gammac,k+1) = eosRbuf
        endif

       end do

#endif

#ifdef USE_SHOCK_FLATTENING
       do k=lx3-1,ux3+1
         if(lgrid%is_flattened(i,j,k)==1) then

          do iv=1,2

           qm = lgrid%gammaf(iv,i,j,k-1)
           qc = lgrid%gammaf(iv,i,j,k)
           qp = lgrid%gammaf(iv,i,j,k+1)

           slopef = qp-qc
           slopeb = qc-qm
           prod = slopef*slopeb

           slope = rp0

           if(prod>rp0) then
            slope=prod/(slopef+slopeb)
           endif

           tmp = rph*slope
           qLbuf(iv) = qc - tmp
           qRbuf(iv) = qc + tmp


          end do

          if(k>=lx3) then
           do iv=1,2
            lgrid%ru%gammafR(3)%val(iv,k)= qLbuf(iv)
           end do
          endif

          if(k<=ux3) then
           do iv=1,2
            lgrid%ru%gammafL(3)%val(iv,k+1)= qRbuf(iv)
           end do
          endif

       end if

      end do
#endif

#ifdef USE_WB

       do k=lx3,ux3+1
 
         p_eq = lgrid%eq_gammae_x3(i,j,k)

         lgrid%ru%gammafL(3)%val(i_gammae,k) = &
         lgrid%ru%gammafL(3)%val(i_gammae,k) + p_eq

         lgrid%ru%gammafR(3)%val(i_gammae,k) = &
         lgrid%ru%gammafR(3)%val(i_gammae,k) + p_eq

       end do 

#endif

#endif

#ifdef ADVECT_SPECIES

       do k=lx3,ux3+1

        tmp = rp0
        do iv=1,nspecies
         tmp = tmp + lgrid%qLx3(i_as1+iv-1,k)
        end do

        tmp = rp1/tmp

        do iv=1,nspecies
         lgrid%qLx3(i_as1+iv-1,k) = lgrid%qLx3(i_as1+iv-1,k)*tmp
        end do

        tmp = rp0
        do iv=1,nspecies
         tmp = tmp + lgrid%qRx3(i_as1+iv-1,k)
        end do

        tmp = rp1/tmp

        do iv=1,nspecies
         lgrid%qRx3(i_as1+iv-1,k) = lgrid%qRx3(i_as1+iv-1,k)*tmp
        end do

       end do

#endif

#ifdef GEOMETRY_CUBED_SPHERE
       do k=lx3,ux3+1
        lgrid%ru%nn(3)%val(1,k) = lgrid%n_x3(1,i,j,k)
        lgrid%ru%nn(3)%val(2,k) = lgrid%n_x3(2,i,j,k)
        lgrid%ru%nn(3)%val(3,k) = lgrid%n_x3(3,i,j,k)
       end do
#endif

#ifdef USE_MHD
       call riemann(lx3,ux3+1,lgrid%qLx3,lgrid%qRx3,lgrid%bLx3,lgrid%bRx3,lgrid%fx3,lgrid%fbx3,lgrid%ru)
#else
       call riemann(lx3,ux3+1,lgrid%qLx3,lgrid%qRx3,lgrid%fx3,lgrid%ru)
#endif

#ifndef GEOMETRY_CUBED_SPHERE
       do k=lx3,ux3+1
        
         vx1 = lgrid%fx3(i_rhovx1,k)
         vx2 = lgrid%fx3(i_rhovx2,k)
         vx3 = lgrid%fx3(i_rhovx3,k)

         lgrid%fx3(i_rhovx1,k) = vx2
         lgrid%fx3(i_rhovx2,k) = vx3
         lgrid%fx3(i_rhovx3,k) = vx1

       end do
#endif

#ifdef USE_MHD

       do k=lx3,ux3+1
       
         vx1 = lgrid%fbx3(1,k)
         vx2 = lgrid%fbx3(2,k)
         vx3 = lgrid%fbx3(3,k)

         lgrid%fbx3(1,k) = vx2
         lgrid%fbx3(2,k) = vx3
         lgrid%fbx3(3,k) = vx1

         lgrid%emf_x3(1,i,j,k) = lgrid%fbx3(2,k)
         lgrid%emf_x3(2,i,j,k) = -lgrid%fbx3(1,k)
         lgrid%emf_x3(3,i,j,k) = rp0

         tmp = rph*(lgrid%qLx3(i_rho,k)+lgrid%qRx3(i_rho,k))*lgrid%smax
         mach = lgrid%fx3(i_rho,k) / tmp

         sgn = rp0
         if(mach>Mach_ct) then
          sgn = rp1        
         endif
         if(mach<-Mach_ct) then
          sgn = -rp1        
         endif

         lgrid%sign_frho_x3(i,j,k) = sgn

       end do

#endif

#if defined(GEOMETRY_CARTESIAN_UNIFORM) || defined(GEOMETRY_CARTESIAN_NONUNIFORM)
#ifdef USE_WB
       do k=lx3,ux3+1
         lgrid%fx3(i_rhovx3,k) = lgrid%fx3(i_rhovx3,k) - lgrid%eq_prim_x3(ieq_p,i,j,k)
       end do 
#endif
#endif

#ifdef EVOLVE_ETOT
       do k=lx3,ux3+1       
         lgrid%fx3(i_rhoe,k) = lgrid%fx3(i_rhoe,k) + &
         lgrid%fx3(i_rho,k)*lgrid%phi_x3(i,j,k)
       end do
#endif

#ifdef GEOMETRY_CUBED_SPHERE
#ifdef USE_WB
       do k=lx3,ux3+1
         tmp = lgrid%eq_prim_x3(ieq_p,i,j,k)
         lgrid%fx3(i_rhovx1,k) = lgrid%fx3(i_rhovx1,k) - tmp*lgrid%ru%nn(3)%val(1,k)
         lgrid%fx3(i_rhovx2,k) = lgrid%fx3(i_rhovx2,k) - tmp*lgrid%ru%nn(3)%val(2,k)
         lgrid%fx3(i_rhovx3,k) = lgrid%fx3(i_rhovx3,k) - tmp*lgrid%ru%nn(3)%val(3,k)
       end do 
#endif
#endif

#ifdef GEOMETRY_3D_SPHERICAL
#ifdef USE_WB
       do k=lx3,ux3+1       
         lgrid%ru%pn(3)%val(k) = lgrid%ru%pn(3)%val(k) - lgrid%eq_prim_x3(ieq_p,i,j,k) 
       end do
#endif
#endif

       do k=lx3,ux3
#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
        inv_dl = rp1/(lgrid%coords_x3(3,i,j,k+1)-lgrid%coords_x3(3,i,j,k))
#endif

#if defined(GEOMETRY_3D_SPHERICAL)

         inv_r_sin_theta = lgrid%inv_r_sin_theta(i,j,k)

         do iv=1,nvars
          lgrid%res(iv,i,j,k) = lgrid%res(iv,i,j,k) + &
          (lgrid%fx3(iv,k+1)-lgrid%fx3(iv,k))*inv_dl*inv_r_sin_theta
         end do

         lgrid%res(i_rhovx3,i,j,k) = lgrid%res(i_rhovx3,i,j,k) + &
         (lgrid%ru%pn(3)%val(k+1)-lgrid%ru%pn(3)%val(k))*inv_r_sin_theta*inv_dl
 
#elif defined(GEOMETRY_CUBED_SPHERE)

        am = lgrid%A_x3(i,j,k)
        ap = lgrid%A_x3(i,j,k+1)
        tmp = lgrid%ivol(i,j,k)

        do iv=1,nvars
         lgrid%res(iv,i,j,k) = lgrid%res(iv,i,j,k) + &
         (ap*lgrid%fx3(iv,k+1)-am*lgrid%fx3(iv,k))*tmp
        end do

#else

        do iv=1,nvars
         lgrid%res(iv,i,j,k) = lgrid%res(iv,i,j,k) + &
         (lgrid%fx3(iv,k+1)-lgrid%fx3(iv,k))*inv_dl
        end do

#endif

       end do

      end do
     end do

#endif

     a1rk = rk_coeff(irk,1)
     a2rk = rk_coeff(irk,2)
     a3rk = rk_coeff(irk,3)*lgrid%dt

#ifdef USE_MHD

     call mpi_barrier(mgrid%comm_cart,ierr)
     call communicate_ndarray(mgrid,3,lx1,ux1+1,lx2,ux2,lx3,ux3,1,lgrid%emf_x1,.false.)
     call communicate_ndarray(mgrid,3,lx1,ux1,lx2,ux2+1,lx3,ux3,1,lgrid%emf_x2,.false.)
#if sdims_make==3
     call communicate_ndarray(mgrid,3,lx1,ux1,lx2,ux2,lx3,ux3+1,1,lgrid%emf_x3,.false.)
#endif
     
     call communicate_array(mgrid,lx1,ux1+1,lx2,ux2,lx3,ux3,1,lgrid%sign_frho_x1,.false.)
     call communicate_array(mgrid,lx1,ux1,lx2,ux2+1,lx3,ux3,1,lgrid%sign_frho_x2,.false.)
#if sdims_make==3
     call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3+1,1,lgrid%sign_frho_x3,.false.)
#endif
 
#ifdef USE_RESISTIVITY

     call communicate_array(mgrid,lx1,ux1+1,lx2,ux2,lx3,ux3,1,lgrid%b_x1,.false.)
     call communicate_array(mgrid,lx1,ux1,lx2,ux2+1,lx3,ux3,1,lgrid%b_x2,.false.)
#if sdims_make==3
     call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3+1,1,lgrid%b_x3,.false.)
#endif
 
#endif
      
#ifndef USE_INTERNAL_BOUNDARIES
 
#if defined(X1L_REFLECTIVE) || defined(X1L_OUTFLOW) || defined(X1L_DIODE)

#ifndef FIX_BFIELD_AT_X1

     if(mgrid%coords_dd(1)==0) then

#ifdef X1L_REFLECTIVE
      bc_facb(1) =  rp1 
      bc_facb(2) = -rp1
      bc_facb(3) = -rp1
#ifdef X1L_BFIELD_PMC
      bc_facb(1) =  -rp1
      bc_facb(2) =   rp1
      bc_facb(3) =   rp1
#endif
#endif      
#ifdef X1L_OUTFLOW
      bc_facb(1) =  rp1 
      bc_facb(2) =  rp1
      bc_facb(3) =  rp1
#endif      

      do k=lx3,ux3
       do j=lx2,ux2+1
#if defined(X1L_REFLECTIVE) || defined(X1L_OUTFLOW)        
         do iv=1,3
          lgrid%emf_x2(iv,lx1-1,j,k) = bc_facb(iv)*lgrid%emf_x2(iv,lx1,j,k) 
         end do                   
#endif
         lgrid%sign_frho_x2(lx1-1,j,k) = lgrid%sign_frho_x2(lx1,j,k) 
       end do
      end do

#if sdims_make==3
      do k=lx3,ux3+1
       do j=lx2,ux2
#if defined(X1L_REFLECTIVE) || defined(X1L_OUTFLOW) 
         do iv=1,3
          lgrid%emf_x3(iv,lx1-1,j,k) = bc_facb(iv)*lgrid%emf_x3(iv,lx1,j,k) 
         end do                   
#endif
         lgrid%sign_frho_x3(lx1-1,j,k) = lgrid%sign_frho_x3(lx1,j,k) 
       end do
      end do
#endif

     end if

#endif
   
#if defined(X1U_REFLECTIVE) || defined(X1U_OUTFLOW) || defined(X1U_DIODE)
     
     if(mgrid%coords_dd(1)==mgrid%bricks(1)-1) then

#ifdef X1U_REFLECTIVE
      bc_facb(1) =  rp1 
      bc_facb(2) = -rp1
      bc_facb(3) = -rp1
#ifdef X1U_BFIELD_PMC
      bc_facb(1) = -rp1
      bc_facb(2) =  rp1
      bc_facb(3) =  rp1
#endif
#endif      
#ifdef X1U_OUTFLOW
      bc_facb(1) =  rp1
      bc_facb(2) =  rp1
      bc_facb(3) =  rp1
#endif      

      do k=lx3,ux3
       do j=lx2,ux2+1
#if defined(X1U_REFLECTIVE) || defined(X1U_OUTFLOW) 
         do iv=1,3
          lgrid%emf_x2(iv,ux1+1,j,k) = bc_facb(iv)*lgrid%emf_x2(iv,ux1,j,k) 
         end do                   
#endif
         lgrid%sign_frho_x2(ux1+1,j,k) = lgrid%sign_frho_x2(ux1,j,k) 
       end do
      end do

#if sdims_make==3
      do k=lx3,ux3+1
       do j=lx2,ux2
#if defined(X1U_REFLECTIVE) || defined(X1U_OUTFLOW)      
         do iv=1,3
          lgrid%emf_x3(iv,ux1+1,j,k) = bc_facb(iv)*lgrid%emf_x3(iv,ux1,j,k) 
         end do                   
#endif         
         lgrid%sign_frho_x3(ux1+1,j,k) = lgrid%sign_frho_x3(ux1,j,k) 
       end do
      end do
#endif

     end if

#endif

#endif
 
#if defined(X2L_REFLECTIVE) || defined(X2L_OUTFLOW) || defined(X2L_DIODE)
     
     if(mgrid%coords_dd(2)==0) then

#ifdef X2L_REFLECTIVE
      bc_facb(1) = -rp1 
      bc_facb(2) =  rp1
      bc_facb(3) = -rp1
#ifdef X2L_BFIELD_PMC
      bc_facb(1) =  rp1
      bc_facb(2) = -rp1
      bc_facb(3) =  rp1
#endif
#endif      
#ifdef X2L_OUTFLOW
      bc_facb(1) =  rp1 
      bc_facb(2) =  rp1
      bc_facb(3) =  rp1
#endif      

      do k=lx3,ux3
       do i=lx1,ux1+1
#if defined(X2L_REFLECTIVE) || defined(X2L_OUTFLOW) 
         do iv=1,3
          lgrid%emf_x1(iv,i,lx2-1,k) = bc_facb(iv)*lgrid%emf_x1(iv,i,lx2,k) 
         end do
#endif         
         lgrid%sign_frho_x1(i,lx2-1,k) = lgrid%sign_frho_x1(i,lx2,k) 
       end do
      end do

#if sdims_make==3
      do k=lx3,ux3+1
       do i=lx1,ux1
#if defined(X2L_REFLECTIVE) || defined(X2L_OUTFLOW) 
         do iv=1,3
          lgrid%emf_x3(iv,i,lx2-1,k) = bc_facb(iv)*lgrid%emf_x3(iv,i,lx2,k) 
         end do
#endif         
         lgrid%sign_frho_x3(i,lx2-1,k) = lgrid%sign_frho_x3(i,lx2,k) 
       end do
      end do
#endif

     end if

#endif
   
#if defined(X2U_REFLECTIVE) || defined(X2U_OUTFLOW) || defined(X2U_DIODE)
     
     if(mgrid%coords_dd(2)==mgrid%bricks(2)-1) then

#ifdef X2U_REFLECTIVE
      bc_facb(1) = -rp1 
      bc_facb(2) =  rp1
      bc_facb(3) = -rp1
#ifdef X2U_BFIELD_PMC
      bc_facb(1) =  rp1
      bc_facb(2) = -rp1
      bc_facb(3) =  rp1
#endif
#endif      
#ifdef X2U_OUTFLOW
      bc_facb(1) =  rp1
      bc_facb(2) =  rp1
      bc_facb(3) =  rp1
#endif      

      do k=lx3,ux3
       do i=lx1,ux1+1
#if defined(X2U_REFLECTIVE) || defined(X2U_OUTFLOW)       
         do iv=1,3
          lgrid%emf_x1(iv,i,ux2+1,k) = bc_facb(iv)*lgrid%emf_x1(iv,i,ux2,k) 
         end do                   
#endif         
         lgrid%sign_frho_x1(i,ux2+1,k) = lgrid%sign_frho_x1(i,ux2,k) 
       end do
      end do

#if sdims_make==3
      do k=lx3,ux3+1
       do i=lx1,ux1
#if defined(X2U_REFLECTIVE) || defined(X2U_OUTFLOW)       
         do iv=1,3
          lgrid%emf_x3(iv,i,ux2+1,k) = bc_facb(iv)*lgrid%emf_x3(iv,i,ux2,k) 
         end do                   
#endif         
         lgrid%sign_frho_x3(i,ux2+1,k) = lgrid%sign_frho_x3(i,ux2,k) 
       end do
      end do
#endif

     end if

#endif

#if sdims_make==3
       
#if defined(X3L_REFLECTIVE) || defined(X3L_OUTFLOW) || defined(X3L_DIODE)
     
     if(mgrid%coords_dd(3)==0) then

#ifdef X3L_REFLECTIVE
      bc_facb(1) = -rp1 
      bc_facb(2) = -rp1
      bc_facb(3) =  rp1
#ifdef X3L_BFIELD_PMC
      bc_facb(1) =  rp1
      bc_facb(2) =  rp1
      bc_facb(3) = -rp1
#endif
#endif      
#ifdef X3L_OUTFLOW
      bc_facb(1) =  rp1 
      bc_facb(2) =  rp1
      bc_facb(3) =  rp1
#endif      

      do j=lx2,ux2
       do i=lx1,ux1+1
#if defined(X3L_REFLECTIVE) || defined(X3L_OUTFLOW) 
         do iv=1,3
          lgrid%emf_x1(iv,i,j,lx3-1) = bc_facb(iv)*lgrid%emf_x1(iv,i,j,lx3) 
         end do
#endif         
         lgrid%sign_frho_x1(i,j,lx3-1) = lgrid%sign_frho_x1(i,j,lx3) 
       end do
      end do

      do j=lx2,ux2+1
       do i=lx1,ux1
#if defined(X3L_REFLECTIVE) || defined(X3L_OUTFLOW) 
         do iv=1,3
          lgrid%emf_x2(iv,i,j,lx3-1) = bc_facb(iv)*lgrid%emf_x2(iv,i,j,lx3) 
         end do
#endif         
         lgrid%sign_frho_x2(i,j,lx3-1) = lgrid%sign_frho_x2(i,j,lx3) 
       end do
      end do

     end if

#endif
   
#if defined(X3U_REFLECTIVE) || defined(X3U_OUTFLOW) || defined(X3U_DIODE)
     
     if(mgrid%coords_dd(3)==mgrid%bricks(3)-1) then

#ifdef X3U_REFLECTIVE
      bc_facb(1) = -rp1 
      bc_facb(2) = -rp1
      bc_facb(3) =  rp1
#ifdef X3U_BFIELD_PMC
      bc_facb(1) =  rp1
      bc_facb(2) =  rp1
      bc_facb(3) = -rp1
#endif
#endif      
#ifdef X3U_OUTFLOW
      bc_facb(1) =  rp1 
      bc_facb(2) =  rp1
      bc_facb(3) =  rp1
#endif      

      do j=lx2,ux2
       do i=lx1,ux1+1
#if defined(X3U_REFLECTIVE) || defined(X3U_OUTFLOW) 
         do iv=1,3
          lgrid%emf_x1(iv,i,j,ux3+1) = bc_facb(iv)*lgrid%emf_x1(iv,i,j,ux3) 
         end do                   
#endif         
         lgrid%sign_frho_x1(i,j,ux3+1) = lgrid%sign_frho_x1(i,j,ux3) 
       end do
      end do

      do j=lx2,ux2+1
       do i=lx1,ux1
#if defined(X3U_REFLECTIVE) || defined(X3U_OUTFLOW)        
         do iv=1,3
          lgrid%emf_x2(iv,i,j,ux3+1) = bc_facb(iv)*lgrid%emf_x2(iv,i,j,ux3) 
         end do                   
#endif         
         lgrid%sign_frho_x2(i,j,ux3+1) = lgrid%sign_frho_x2(i,j,ux3) 
       end do
      end do

     end if

#endif

#endif
       
#if defined(X1L_DIODE)
     
     if(mgrid%coords_dd(1)==0) then

      do k=lx3,ux3
       do j=lx2,ux2+1
         vn = -(lgrid%sign_frho_x1(1,j-1,k)+lgrid%sign_frho_x1(1,j,k))
         if(vn<0) then
          bc_facb(1) =  rp1 
          bc_facb(2) = -rp1
          bc_facb(3) = -rp1
         else
          bc_facb(1) =  rp1 
          bc_facb(2) =  rp1
          bc_facb(3) =  rp1
         endif
         do iv=1,3
          lgrid%emf_x2(iv,lx1-1,j,k) = bc_facb(iv)*lgrid%emf_x2(iv,lx1,j,k) 
         end do                   
       end do
      end do

#if sdims_make==3
      do k=lx3,ux3+1
       do j=lx2,ux2
         vn = -(lgrid%sign_frho_x1(1,j,k-1)+lgrid%sign_frho_x1(1,j,k))
         if(vn<0) then
          bc_facb(1) =  rp1 
          bc_facb(2) = -rp1
          bc_facb(3) = -rp1
         else
          bc_facb(1) =  rp1 
          bc_facb(2) =  rp1
          bc_facb(3) =  rp1
         endif
         do iv=1,3
          lgrid%emf_x3(iv,lx1-1,j,k) = bc_facb(iv)*lgrid%emf_x3(iv,lx1,j,k) 
         end do                   
       end do
      end do
#endif

     end if

#endif
   
#if defined(X1U_DIODE)
     
     if(mgrid%coords_dd(1)==mgrid%bricks(1)-1) then

      do k=lx3,ux3
       do j=lx2,ux2+1
         vn = lgrid%sign_frho_x1(ux1+1,j-1,k)+lgrid%sign_frho_x1(ux1+1,j,k)
         if(vn<0) then
          bc_facb(1) =  rp1 
          bc_facb(2) = -rp1
          bc_facb(3) = -rp1
         else
          bc_facb(1) =  rp1 
          bc_facb(2) =  rp1
          bc_facb(3) =  rp1
         endif
         do iv=1,3
          lgrid%emf_x2(iv,ux1+1,j,k) = bc_facb(iv)*lgrid%emf_x2(iv,ux1,j,k) 
         end do                   
       end do
      end do

#if sdims_make==3
      do k=lx3,ux3+1
       do j=lx2,ux2
         vn = lgrid%sign_frho_x1(ux1+1,j,k-1)+lgrid%sign_frho_x1(ux1+1,j,k)
         if(vn<0) then
          bc_facb(1) =  rp1 
          bc_facb(2) = -rp1
          bc_facb(3) = -rp1
         else
          bc_facb(1) =  rp1 
          bc_facb(2) =  rp1
          bc_facb(3) =  rp1
         endif
         do iv=1,3
          lgrid%emf_x3(iv,ux1+1,j,k) = bc_facb(iv)*lgrid%emf_x3(iv,ux1,j,k) 
         end do                   
       end do
      end do
#endif

     end if

#endif
       
#if defined(X2L_DIODE)
     
     if(mgrid%coords_dd(2)==0) then

      do k=lx3,ux3
       do i=lx1,ux1+1
         vn = -(lgrid%sign_frho_x2(i-1,1,k)+lgrid%sign_frho_x2(i,1,k))
         if(vn<0) then
          bc_facb(1) = -rp1 
          bc_facb(2) =  rp1
          bc_facb(3) = -rp1
         else
          bc_facb(1) =  rp1 
          bc_facb(2) =  rp1
          bc_facb(3) =  rp1
         endif
         do iv=1,3
          lgrid%emf_x1(iv,i,lx2-1,k) = bc_facb(iv)*lgrid%emf_x1(iv,i,lx2,k) 
         end do
       end do
      end do

#if sdims_make==3
      do k=lx3,ux3+1
       do i=lx1,ux1
         vn = -(lgrid%sign_frho_x2(i,1,k-1)+lgrid%sign_frho_x2(i,1,k))
         if(vn<0) then
          bc_facb(1) = -rp1
          bc_facb(2) =  rp1
          bc_facb(3) = -rp1
         else
          bc_facb(1) =  rp1
          bc_facb(2) =  rp1
          bc_facb(3) =  rp1
         endif
         do iv=1,3
          lgrid%emf_x3(iv,i,lx2-1,k) = bc_facb(iv)*lgrid%emf_x3(iv,i,lx2,k) 
         end do
       end do
      end do
#endif

     end if

#endif
   
#if defined(X2U_DIODE)
     
     if(mgrid%coords_dd(2)==mgrid%bricks(2)-1) then

      do k=lx3,ux3
       do i=lx1,ux1+1
         vn = lgrid%sign_frho_x2(i-1,ux2+1,k)+lgrid%sign_frho_x2(i,ux2+1,k)
         if(vn<0) then
          bc_facb(1) = -rp1
          bc_facb(2) =  rp1
          bc_facb(3) = -rp1
         else
          bc_facb(1) =  rp1
          bc_facb(2) =  rp1
          bc_facb(3) =  rp1
         endif
         do iv=1,3
          lgrid%emf_x1(iv,i,ux2+1,k) = bc_facb(iv)*lgrid%emf_x1(iv,i,ux2,k) 
         end do                   
       end do
      end do

#if sdims_make==3
      do k=lx3,ux3+1
       do i=lx1,ux1
         vn = lgrid%sign_frho_x2(i,ux2+1,k-1)+lgrid%sign_frho_x2(i,ux2+1,k)
         if(vn<0) then
          bc_facb(1) = -rp1
          bc_facb(2) =  rp1
          bc_facb(3) = -rp1
         else
          bc_facb(1) =  rp1
          bc_facb(2) =  rp1
          bc_facb(3) =  rp1
         endif
         do iv=1,3
          lgrid%emf_x3(iv,i,ux2+1,k) = bc_facb(iv)*lgrid%emf_x3(iv,i,ux2,k) 
         end do                   
       end do
      end do
#endif

     end if

#endif

#if sdims_make==3
       
#if defined(X3L_DIODE)
     
     if(mgrid%coords_dd(3)==0) then

      do j=lx2,ux2
       do i=lx1,ux1+1
         vn = -(lgrid%sign_frho_x3(i-1,j,1)+lgrid%sign_frho_x3(i,j,1))
         if(vn<0) then
          bc_facb(1) = -rp1 
          bc_facb(2) = -rp1
          bc_facb(3) =  rp1
         else
          bc_facb(1) =  rp1 
          bc_facb(2) =  rp1
          bc_facb(3) =  rp1
         endif
         do iv=1,3
          lgrid%emf_x1(iv,i,j,lx3-1) = bc_facb(iv)*lgrid%emf_x1(iv,i,j,lx3) 
         end do
       end do
      end do

      do j=lx2,ux2+1
       do i=lx1,ux1
         vn = -(lgrid%sign_frho_x3(i,j-1,1)+lgrid%sign_frho_x3(i,j,1))
         if(vn<0) then
          bc_facb(1) = -rp1
          bc_facb(2) = -rp1
          bc_facb(3) =  rp1
         else
          bc_facb(1) =  rp1
          bc_facb(2) =  rp1
          bc_facb(3) =  rp1
         endif
         do iv=1,3
          lgrid%emf_x2(iv,i,j,lx3-1) = bc_facb(iv)*lgrid%emf_x2(iv,i,j,lx3) 
         end do
       end do
      end do

     end if

#endif
   
#if defined(X3U_DIODE)
     
     if(mgrid%coords_dd(3)==mgrid%bricks(3)-1) then

      do j=lx2,ux2
       do i=lx1,ux1+1
         vn = lgrid%sign_frho_x3(i-1,j,ux3+1)+lgrid%sign_frho_x3(i,j,ux3+1)
         if(vn<0) then
          bc_facb(1) = -rp1
          bc_facb(2) = -rp1
          bc_facb(3) =  rp1
         else
          bc_facb(1) =  rp1
          bc_facb(2) =  rp1
          bc_facb(3) =  rp1
         endif
         do iv=1,3
          lgrid%emf_x1(iv,i,j,ux3+1) = bc_facb(iv)*lgrid%emf_x1(iv,i,j,ux3) 
         end do                   
       end do
      end do

      do j=lx2,ux2+1
       do i=lx1,ux1
         vn = lgrid%sign_frho_x3(i,j-1,ux3+1)+lgrid%sign_frho_x3(i,j,ux3+1)
         if(vn<0) then
          bc_facb(1) = -rp1
          bc_facb(2) = -rp1
          bc_facb(3) =  rp1
         else
          bc_facb(1) =  rp1
          bc_facb(2) =  rp1
          bc_facb(3) =  rp1
         endif
         do iv=1,3
          lgrid%emf_x2(iv,i,j,ux3+1) = bc_facb(iv)*lgrid%emf_x2(iv,i,j,ux3) 
         end do                   
       end do
      end do

     end if

#endif

#endif

#endif

     !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     ! CONSTRAINED TRANSPORT
     !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

     do k=lx3,ux3
      do j=lx2,ux2+1
       do i=lx1,ux1+1

        emf_N = lgrid%emf_x1(3,i,j,k)
        emf_E = lgrid%emf_x2(3,i,j,k)
        emf_S = lgrid%emf_x1(3,i,j-1,k)
        emf_W = lgrid%emf_x2(3,i-1,j,k)
       
        emf_SW = &
        -lgrid%prim(i_vx1,i-1,j-1,k)*lgrid%b_cc(2,i-1,j-1,k) + &
        lgrid%prim(i_vx2,i-1,j-1,k)*lgrid%b_cc(1,i-1,j-1,k) 

        emf_NW = &
        -lgrid%prim(i_vx1,i-1,j,k)*lgrid%b_cc(2,i-1,j,k) + &
        lgrid%prim(i_vx2,i-1,j,k)*lgrid%b_cc(1,i-1,j,k) 

        emf_NE = &
        -lgrid%prim(i_vx1,i,j,k)*lgrid%b_cc(2,i,j,k) + &
        lgrid%prim(i_vx2,i,j,k)*lgrid%b_cc(1,i,j,k) 

        emf_SE = &
        -lgrid%prim(i_vx1,i,j-1,k)*lgrid%b_cc(2,i,j-1,k) + &
        lgrid%prim(i_vx2,i,j-1,k)*lgrid%b_cc(1,i,j-1,k) 

        sgn = lgrid%sign_frho_x1(i,j-1,k)
        demf_S = &
        rph*(rp1+sgn)*(emf_W-emf_SW) + &
        rph*(rp1-sgn)*(emf_E-emf_SE) 

        sgn = lgrid%sign_frho_x1(i,j,k)
        demf_N = &
        rph*(rp1+sgn)*(emf_NW-emf_W) + &
        rph*(rp1-sgn)*(emf_NE-emf_E) 

        sgn = lgrid%sign_frho_x2(i-1,j,k)
        demf_W = &
        rph*(rp1+sgn)*(emf_S-emf_SW) + &
        rph*(rp1-sgn)*(emf_N-emf_NW) 

        sgn = lgrid%sign_frho_x2(i,j,k)
        demf_E = &
        rph*(rp1+sgn)*(emf_SE-emf_S) + &
        rph*(rp1-sgn)*(emf_NE-emf_N) 

#ifdef USE_INTERNAL_BOUNDARIES
        lgrid%emfx3_cor(i,j,k) = &
        lgrid%fac_cor_x3(i,j,k)*(emf_S+emf_W+emf_N+emf_E + &
        demf_S-demf_N+demf_W-demf_E)
#else
        lgrid%emfx3_cor(i,j,k) = &
        oquart*(emf_S+emf_W+emf_N+emf_E + &
        demf_S-demf_N+demf_W-demf_E)
#endif

       end do
      end do
     end do

#ifdef USE_RESISTIVITY

     do k=lx3,ux3
      do j=lx2,ux2+1
       do i=lx1,ux1+1

         tmp = &
         (lgrid%b_x2(i,j,k)-lgrid%b_x2(i-1,j,k))*lgrid%inv_dx1 - &
         (lgrid%b_x1(i,j,k)-lgrid%b_x1(i,j-1,k))*lgrid%inv_dx2

         lgrid%emfx3_cor(i,j,k) = lgrid%emfx3_cor(i,j,k) + & 
         tmp*lgrid%eta_cor_x3(i,j,k)

       end do
      end do
     end do

#endif

#if sdims_make==3

     do k=lx3,ux3+1
      do j=lx2,ux2+1
       do i=lx1,ux1

        emf_N = lgrid%emf_x2(1,i,j,k)
        emf_E = lgrid%emf_x3(1,i,j,k)
        emf_S = lgrid%emf_x2(1,i,j,k-1)
        emf_W = lgrid%emf_x3(1,i,j-1,k)

        emf_SW = &
        lgrid%prim(i_vx3,i,j-1,k-1)*lgrid%b_cc(2,i,j-1,k-1) - &
        lgrid%prim(i_vx2,i,j-1,k-1)*lgrid%b_cc(3,i,j-1,k-1) 

        emf_NW = &
        lgrid%prim(i_vx3,i,j-1,k)*lgrid%b_cc(2,i,j-1,k) - &
        lgrid%prim(i_vx2,i,j-1,k)*lgrid%b_cc(3,i,j-1,k) 

        emf_NE = &
        lgrid%prim(i_vx3,i,j,k)*lgrid%b_cc(2,i,j,k) - &
        lgrid%prim(i_vx2,i,j,k)*lgrid%b_cc(3,i,j,k) 

        emf_SE = &
        lgrid%prim(i_vx3,i,j,k-1)*lgrid%b_cc(2,i,j,k-1) - &
        lgrid%prim(i_vx2,i,j,k-1)*lgrid%b_cc(3,i,j,k-1) 

        sgn = lgrid%sign_frho_x2(i,j,k-1)
        demf_S = &
        rph*(rp1+sgn)*(emf_W-emf_SW) + &
        rph*(rp1-sgn)*(emf_E-emf_SE) 

        sgn = lgrid%sign_frho_x2(i,j,k)
        demf_N = &
        rph*(rp1+sgn)*(emf_NW-emf_W) + &
        rph*(rp1-sgn)*(emf_NE-emf_E) 

        sgn = lgrid%sign_frho_x3(i,j-1,k)
        demf_W = &
        rph*(rp1+sgn)*(emf_S-emf_SW) + &
        rph*(rp1-sgn)*(emf_N-emf_NW) 

        sgn = lgrid%sign_frho_x3(i,j,k)
        demf_E = &
        rph*(rp1+sgn)*(emf_SE-emf_S) + &
        rph*(rp1-sgn)*(emf_NE-emf_N) 

#ifdef USE_INTERNAL_BOUNDARIES
        lgrid%emfx1_cor(i,j,k) = &
        lgrid%fac_cor_x1(i,j,k)*(emf_S+emf_W+emf_N+emf_E + &
        demf_S-demf_N+demf_W-demf_E)
#else
        lgrid%emfx1_cor(i,j,k) = &
        oquart*(emf_S+emf_W+emf_N+emf_E + &
        demf_S-demf_N+demf_W-demf_E)
#endif

       end do
      end do
     end do

#ifdef USE_RESISTIVITY

     do k=lx3,ux3+1
      do j=lx2,ux2+1
       do i=lx1,ux1

         tmp = &
         (lgrid%b_x3(i,j,k)-lgrid%b_x3(i,j-1,k))*lgrid%inv_dx2 - &
         (lgrid%b_x2(i,j,k)-lgrid%b_x2(i,j,k-1))*lgrid%inv_dx3

         lgrid%emfx1_cor(i,j,k) = lgrid%emfx1_cor(i,j,k) + & 
         tmp*lgrid%eta_cor_x1(i,j,k)

       end do
      end do
     end do

#endif

     do k=lx3,ux3+1
      do j=lx2,ux2
       do i=lx1,ux1+1

        emf_N = lgrid%emf_x3(2,i,j,k)
        emf_E = lgrid%emf_x1(2,i,j,k)
        emf_S = lgrid%emf_x3(2,i-1,j,k)
        emf_W = lgrid%emf_x1(2,i,j,k-1)

        emf_SW = &
        lgrid%prim(i_vx1,i-1,j,k-1)*lgrid%b_cc(3,i-1,j,k-1) - &
        lgrid%prim(i_vx3,i-1,j,k-1)*lgrid%b_cc(1,i-1,j,k-1) 

        emf_NW = &
        lgrid%prim(i_vx1,i,j,k-1)*lgrid%b_cc(3,i,j,k-1) - &
        lgrid%prim(i_vx3,i,j,k-1)*lgrid%b_cc(1,i,j,k-1) 

        emf_NE = &
        lgrid%prim(i_vx1,i,j,k)*lgrid%b_cc(3,i,j,k) - &
        lgrid%prim(i_vx3,i,j,k)*lgrid%b_cc(1,i,j,k) 

        emf_SE = &
        lgrid%prim(i_vx1,i-1,j,k)*lgrid%b_cc(3,i-1,j,k) - &
        lgrid%prim(i_vx3,i-1,j,k)*lgrid%b_cc(1,i-1,j,k) 

        sgn = lgrid%sign_frho_x3(i-1,j,k)
        demf_S = &
        rph*(rp1+sgn)*(emf_W-emf_SW) + &
        rph*(rp1-sgn)*(emf_E-emf_SE) 

        sgn = lgrid%sign_frho_x3(i,j,k)
        demf_N = &
        rph*(rp1+sgn)*(emf_NW-emf_W) + &
        rph*(rp1-sgn)*(emf_NE-emf_E) 

        sgn = lgrid%sign_frho_x1(i,j,k-1)
        demf_W = &
        rph*(rp1+sgn)*(emf_S-emf_SW) + &
        rph*(rp1-sgn)*(emf_N-emf_NW) 

        sgn = lgrid%sign_frho_x1(i,j,k)
        demf_E = &
        rph*(rp1+sgn)*(emf_SE-emf_S) + &
        rph*(rp1-sgn)*(emf_NE-emf_N) 

#ifdef USE_INTERNAL_BOUNDARIES
        lgrid%emfx2_cor(i,j,k) = &
        lgrid%fac_cor_x2(i,j,k)*(emf_S+emf_W+emf_N+emf_E + &
        demf_S-demf_N+demf_W-demf_E)
#else
        lgrid%emfx2_cor(i,j,k) = &
        oquart*(emf_S+emf_W+emf_N+emf_E + &
        demf_S-demf_N+demf_W-demf_E)
#endif

       end do
      end do
     end do

#ifdef USE_RESISTIVITY

     do k=lx3,ux3+1
      do j=lx2,ux2
       do i=lx1,ux1+1

         tmp = &
         (lgrid%b_x1(i,j,k)-lgrid%b_x1(i,j,k-1))*lgrid%inv_dx3 - &
         (lgrid%b_x3(i,j,k)-lgrid%b_x3(i-1,j,k))*lgrid%inv_dx1

         lgrid%emfx2_cor(i,j,k) = lgrid%emfx2_cor(i,j,k) + & 
         tmp*lgrid%eta_cor_x2(i,j,k)

       end do
      end do
     end do

#endif
    
#endif
 
     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1+1

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM

        tmp = &
#if sdims_make==3
        -(lgrid%emfx2_cor(i,j,k+1)-lgrid%emfx2_cor(i,j,k))/(lgrid%nodes(3,i,j,k+1)-lgrid%nodes(3,i,j,k)) + &
#endif
        (lgrid%emfx3_cor(i,j+1,k)-lgrid%emfx3_cor(i,j,k))/(lgrid%nodes(2,i,j+1,k)-lgrid%nodes(2,i,j,k))

#elif defined(GEOMETRY_2D_POLAR)

        tmp = &
        (lgrid%emfx3_cor(i,j+1,k)-lgrid%emfx3_cor(i,j,k))*lgrid%inv_dx2

        r = lgrid%r_x1(i,j,k)
        tmp = tmp/r

#elif defined(GEOMETRY_2D_SPHERICAL) 

        sin_theta_m = lgrid%sin_theta_cor(i,j,k)
        sin_theta_p = lgrid%sin_theta_cor(i,j+1,k)

        x = lgrid%coords_x1(1,i,j,k)

        tmp = &
        (sin_theta_p*lgrid%emfx3_cor(i,j+1,k)-sin_theta_m*lgrid%emfx3_cor(i,j,k))*lgrid%inv_dx2/x

#elif defined(GEOMETRY_3D_SPHERICAL) 

        sin_theta_m = lgrid%sin_theta_cor(i,j,k)
        sin_theta_p = lgrid%sin_theta_cor(i,j+1,k)

        inv_r_sin_theta = lgrid%inv_r_sin_theta_x1(i,j,k)

        tmp = &
        -(lgrid%emfx2_cor(i,j,k+1)-lgrid%emfx2_cor(i,j,k))*lgrid%inv_dx3*inv_r_sin_theta + &               
        (sin_theta_p*lgrid%emfx3_cor(i,j+1,k)-sin_theta_m*lgrid%emfx3_cor(i,j,k))*lgrid%inv_dx2*inv_r_sin_theta

#else

        tmp = &
#if sdims_make==3
        -(lgrid%emfx2_cor(i,j,k+1)-lgrid%emfx2_cor(i,j,k))*lgrid%inv_dx3 + &
#endif
        (lgrid%emfx3_cor(i,j+1,k)-lgrid%emfx3_cor(i,j,k))*lgrid%inv_dx2

#endif

#ifdef FIX_BFIELD_AT_X1
        if(i==1 .or. i==nx1+1) then
         tmp = rp0
        endif
#endif
    
#ifdef USE_INTERNAL_BOUNDARIES
        lgrid%b_x1(i,j,k) = &
        a1rk*lgrid%b0_x1(i,j,k) + &
        a2rk*lgrid%b_x1(i,j,k) + &
        a3rk*tmp*lgrid%fac_x1(i,j,k)
#else
        lgrid%b_x1(i,j,k) = &
        a1rk*lgrid%b0_x1(i,j,k) + &
        a2rk*lgrid%b_x1(i,j,k) + &
        a3rk*tmp
#endif

       end do
      end do
     end do
     
     do k=lx3,ux3
      do j=lx2,ux2+1
       do i=lx1,ux1

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM

        tmp = &
#if sdims_make==3
        (lgrid%emfx1_cor(i,j,k+1)-lgrid%emfx1_cor(i,j,k))/(lgrid%nodes(3,i,j,k+1)-lgrid%nodes(3,i,j,k)) &
#endif
        -(lgrid%emfx3_cor(i+1,j,k)-lgrid%emfx3_cor(i,j,k))/(lgrid%nodes(1,i+1,j,k)-lgrid%nodes(1,i,j,k))

#elif defined(GEOMETRY_2D_POLAR)

#ifdef NONUNIFORM_RADIAL_NODES
        rmi = lgrid%r_cor(i,j,k)
        rpl = lgrid%r_cor(i+1,j,k)
        inv_dl = rp1/(rpl-rmi)
#else
        inv_dl = lgrid%inv_dx1
#endif

        tmp = &
        (lgrid%emfx3_cor(i,j,k)-lgrid%emfx3_cor(i+1,j,k))*inv_dl

#elif defined(GEOMETRY_2D_SPHERICAL)

        rmi = lgrid%r_cor(i,j,k)
        rpl = lgrid%r_cor(i+1,j,k)

        r = lgrid%r_x2(i,j,k)

#ifdef NONUNIFORM_RADIAL_NODES
        inv_dl = rp1/(rpl-rmi)
#else
        inv_dl = lgrid%inv_dx1
#endif

        tmp = &
        (rmi*lgrid%emfx3_cor(i,j,k)-rpl*lgrid%emfx3_cor(i+1,j,k))*inv_dl/r

#elif defined(GEOMETRY_3D_SPHERICAL)

        rmi = lgrid%r_cor(i,j,k)
        rpl = lgrid%r_cor(i+1,j,k)

        r = lgrid%r_x2(i,j,k)
        sin_theta = lgrid%sin_theta_x2(i,j,k)
        inv_r_sin_theta = rp1/(r*sin_theta)

#ifdef NONUNIFORM_RADIAL_NODES
        inv_dl = rp1/(rpl-rmi)
#else
        inv_dl = lgrid%inv_dx1
#endif

        tmp = &
        (lgrid%emfx1_cor(i,j,k+1)-lgrid%emfx1_cor(i,j,k))*lgrid%inv_dx3*inv_r_sin_theta + &
        (rmi*lgrid%emfx3_cor(i,j,k)-rpl*lgrid%emfx3_cor(i+1,j,k))*inv_dl/r

#else

        tmp = &
#if sdims_make==3
        (lgrid%emfx1_cor(i,j,k+1)-lgrid%emfx1_cor(i,j,k))*lgrid%inv_dx3 + &
#endif
        (lgrid%emfx3_cor(i,j,k)-lgrid%emfx3_cor(i+1,j,k))*lgrid%inv_dx1

#endif

#ifdef USE_INTERNAL_BOUNDARIES
        lgrid%b_x2(i,j,k) = &
        a1rk*lgrid%b0_x2(i,j,k) + &
        a2rk*lgrid%b_x2(i,j,k) + &
        a3rk*tmp*lgrid%fac_x2(i,j,k)
#else
        lgrid%b_x2(i,j,k) = &
        a1rk*lgrid%b0_x2(i,j,k) + &
        a2rk*lgrid%b_x2(i,j,k) + &
        a3rk*tmp
#endif

       end do
      end do
     end do

#if sdims_make==3
     
     do k=lx3,ux3+1
      do j=lx2,ux2
       do i=lx1,ux1

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM

        tmp = &
        (lgrid%emfx2_cor(i+1,j,k)-lgrid%emfx2_cor(i,j,k))/(lgrid%nodes(1,i+1,j,k)-lgrid%nodes(1,i,j,k)) - &
        (lgrid%emfx1_cor(i,j+1,k)-lgrid%emfx1_cor(i,j,k))/(lgrid%nodes(2,i,j+1,k)-lgrid%nodes(2,i,j,k))

#elif defined(GEOMETRY_3D_SPHERICAL)

        rmi = lgrid%r_cor(i,j,k)
        rpl = lgrid%r_cor(i+1,j,k)

        r = lgrid%r_x3(i,j,k)

#ifdef NONUNIFORM_RADIAL_NODES
        inv_dl = rp1/(rpl-rmi)
#else
        inv_dl = lgrid%inv_dx1
#endif
 
        tmp = &
        (rpl*lgrid%emfx2_cor(i+1,j,k)-rmi*lgrid%emfx2_cor(i,j,k))*inv_dl/r - &
        (lgrid%emfx1_cor(i,j+1,k)-lgrid%emfx1_cor(i,j,k))*lgrid%inv_dx2/r
       
#else

        tmp = &
        (lgrid%emfx2_cor(i+1,j,k)-lgrid%emfx2_cor(i,j,k))*lgrid%inv_dx1 - &
        (lgrid%emfx1_cor(i,j+1,k)-lgrid%emfx1_cor(i,j,k))*lgrid%inv_dx2

#endif

#ifdef USE_INTERNAL_BOUNDARIES
        lgrid%b_x3(i,j,k) = &
        a1rk*lgrid%b0_x3(i,j,k) + &
        a2rk*lgrid%b_x3(i,j,k) + &
        a3rk*tmp*lgrid%fac_x3(i,j,k)
#else
        lgrid%b_x3(i,j,k) = &
        a1rk*lgrid%b0_x3(i,j,k) + &
        a2rk*lgrid%b_x3(i,j,k) + &
        a3rk*tmp
#endif

       end do
      end do
     end do

#endif

#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       tmp = lgrid%cm(i,j,k)
       tmp1 = rp1-tmp
       lgrid%b_cc(1,i,j,k) = tmp1*lgrid%b_x1(i+1,j,k)+tmp*lgrid%b_x1(i,j,k)
      end do
     end do
    end do
#else
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       lgrid%b_cc(1,i,j,k) = rph*(lgrid%b_x1(i+1,j,k)+lgrid%b_x1(i,j,k))
      end do
     end do
    end do
#endif

#if defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       tmp = lgrid%dm(i,j,k)
       tmp1 = rp1-tmp
       lgrid%b_cc(2,i,j,k) = tmp1*lgrid%b_x2(i,j+1,k)+tmp*lgrid%b_x2(i,j,k)
      end do
     end do
    end do
#else
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       lgrid%b_cc(2,i,j,k) = rph*(lgrid%b_x2(i,j+1,k)+lgrid%b_x2(i,j,k))
      end do
     end do
    end do
#endif

#if sdims_make==3
     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1
        lgrid%b_cc(3,i,j,k) = rph*(lgrid%b_x3(i,j,k+1)+lgrid%b_x3(i,j,k))
       end do
      end do
     end do
#endif

#endif

#ifdef USE_NEULOSS
#ifndef USE_NUCLEAR_NETWORK

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

#ifdef ADVECT_YE_IABAR
         abar = rp1/lgrid%prim(i_iabar,i,j,k)
         ye = lgrid%prim(i_ye,i,j,k)
#endif
#ifdef ADVECT_SPECIES
         inv_abar = rp0
         ye = rp0
         do iv=1,nspecies
           tmp = lgrid%prim(i_as1+iv-1,i,j,k)/lgrid%A(iv)
           inv_abar = inv_abar + tmp
           ye = ye + tmp*lgrid%Z(iv)
         end do
         abar = rp1/inv_abar
#endif
         zbar = ye*abar

         snu = rp0
         T = lgrid%temp(i,j,k)
         rho = lgrid%state(i_rho,i,j,k)
         call sneut5(T,rho,abar,zbar,snu)
         lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) + rho*snu

       end do
      end do
     end do

#endif
#endif

#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL)

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        rho = lgrid%state(i_rho,i,j,k)
        vx1 = lgrid%prim(i_vx1,i,j,k)
        vx2 = lgrid%prim(i_vx2,i,j,k)

#ifdef USE_MHD
        bx1 = lgrid%b_cc(1,i,j,k) 
        bx2 = lgrid%b_cc(2,i,j,k)
#endif
        r = lgrid%r(i,j,k)
        inv_r = rp1/r
        
        lgrid%res(i_rhovx1,i,j,k) = lgrid%res(i_rhovx1,i,j,k) &
#ifdef USE_MHD
        + bx2*bx2*inv_r  &
#endif
        - rho*vx2*vx2*inv_r

        lgrid%res(i_rhovx2,i,j,k) = lgrid%res(i_rhovx2,i,j,k) &
#ifdef USE_MHD
        - bx1*bx2*inv_r  &
#endif
        + rho*vx1*vx2*inv_r

       end do
      end do
     end do

#endif

#ifdef GEOMETRY_3D_SPHERICAL

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        r = lgrid%r(i,j,k)
        tmp = lgrid%cot_theta(i,j,k)

        rho = lgrid%state(i_rho,i,j,k)
        vx1 = lgrid%prim(i_vx1,i,j,k)
        vx2 = lgrid%prim(i_vx2,i,j,k)
        vx3 = lgrid%prim(i_vx3,i,j,k)

#ifdef USE_MHD
        bx1 = lgrid%b_cc(1,i,j,k) 
        bx2 = lgrid%b_cc(2,i,j,k)
        bx3 = lgrid%b_cc(3,i,j,k)
#endif
        inv_r = rp1/r
        lgrid%res(i_rhovx1,i,j,k) = lgrid%res(i_rhovx1,i,j,k) &
#ifdef USE_MHD
        + (bx2*bx2+bx3*bx3)*inv_r &
#endif
        - rho*(vx2*vx2+vx3*vx3)*inv_r 

        lgrid%res(i_rhovx2,i,j,k) = lgrid%res(i_rhovx2,i,j,k) &
#ifdef USE_MHD
        - (bx1*bx2-tmp*bx3*bx3)*inv_r  &
#endif
        + rho*(vx1*vx2 - tmp*vx3*vx3)*inv_r

        lgrid%res(i_rhovx3,i,j,k) = lgrid%res(i_rhovx3,i,j,k) &
#ifdef USE_MHD
        - (bx1*bx3-tmp*bx3*bx2)*inv_r  &
#endif
        + rho*(vx1*vx3 + tmp*vx3*vx2)*inv_r

       end do
      end do
     end do

#endif

#ifdef USE_GRAVITY

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        rho = lgrid%prim(i_rho,i,j,k)

        gx1 = lgrid%grav(1,i,j,k)
        gx2 = lgrid%grav(2,i,j,k)
#if sdims_make==3
        gx3 = lgrid%grav(3,i,j,k)
#endif

        lgrid%res(i_rhovx1,i,j,k) = lgrid%res(i_rhovx1,i,j,k) - &
        rho*gx1

        lgrid%res(i_rhovx2,i,j,k) = lgrid%res(i_rhovx2,i,j,k) - &
        rho*gx2

#if sdims_make==3
        lgrid%res(i_rhovx3,i,j,k) = lgrid%res(i_rhovx3,i,j,k) - &
        rho*gx3
#endif

#ifndef EVOLVE_ETOT
        lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
#if sdims_make==3
        lgrid%state(i_rhovx3,i,j,k)*gx3 - &
#endif
        lgrid%state(i_rhovx1,i,j,k)*gx1 - &
        lgrid%state(i_rhovx2,i,j,k)*gx2 
#endif

       end do
      end do
     end do

#endif

#ifdef USE_EDOT
#ifndef VARIABLE_EDOT

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
        lgrid%edot(i,j,k)

       end do
      end do
     end do

#endif
#ifdef VARIABLE_EDOT
     if (lgrid%time>=t_start_edot) then
      do k=lx3,ux3
       do j=lx2,ux2
        do i=lx1,ux1

         lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
         lgrid%edot(i,j,k)

        end do
       end do
      end do
     end if

#endif
#endif

#ifdef COROTATING_FRAME
    
     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

         rho = lgrid%state(i_rho,i,j,k)
         rhovx1 = lgrid%state(i_rhovx1,i,j,k)
         rhovx2 = lgrid%state(i_rhovx2,i,j,k)
#if sdims_make==3
         rhovx3 = lgrid%state(i_rhovx3,i,j,k)
#else
         rhovx3 = rp0
#endif

#if defined(GEOMETRY_CARTESIAN_UNIFORM) || defined(GEOMETRY_CARTESIAN_NONUNIFORM) || defined(GEOMETRY_CUBED_SPHERE)

         x = lgrid%coords(1,i,j,k)
         y = lgrid%coords(2,i,j,k)
#if sdims_make==3
         z = lgrid%coords(3,i,j,k)
#else
         z = rp0
#endif

         ov1 = rhovx3*om2-rhovx2*om3

         ov2 = -rhovx3*om1+rhovx1*om3

         ov3 = rhovx2*om1-rhovx1*om2

         or1 = z*om2-y*om3

         or2 = -z*om1+x*om3

         or3 = y*om1-x*om2

         oor1 = or3*om2-or2*om3

         oor2 = -or3*om1+or1*om3

         oor3 = or2*om1-or1*om2

         lgrid%res(i_rhovx1,i,j,k) = lgrid%res(i_rhovx1,i,j,k) + &
         rp2*ov1+rho*oor1

         lgrid%res(i_rhovx2,i,j,k) = lgrid%res(i_rhovx2,i,j,k) + &
         rp2*ov2+rho*oor2

#if sdims_make==3
         lgrid%res(i_rhovx3,i,j,k) = lgrid%res(i_rhovx3,i,j,k) + &
         rp2*ov3+rho*oor3
#endif

         lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) + &
#if sdims_make==3
         rhovx3*oor3 + &
#endif
         rhovx2*oor2 + &
         rhovx1*oor1

#endif

#ifdef GEOMETRY_2D_POLAR

         r = lgrid%r(i,j,k)
         tmp = r*om3*om3
         
         lgrid%res(i_rhovx1,i,j,k) = lgrid%res(i_rhovx1,i,j,k) & 
         -rho*tmp-rp2*rhovx2*om3

         lgrid%res(i_rhovx2,i,j,k) = lgrid%res(i_rhovx2,i,j,k) & 
         +rp2*rhovx1*om3

         lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
         rhovx1*tmp

#endif

#ifdef GEOMETRY_3D_SPHERICAL
         
         r = lgrid%r(i,j,k)
         sin_theta = lgrid%sin_theta(i,j,k)
         cos_theta = lgrid%cos_theta(i,j,k)

         tmp = rhovx3*om3
         ov1 = -sin_theta*tmp
         ov2 = -cos_theta*tmp
         ov3 = (cos_theta*rhovx2+sin_theta*rhovx1)*om3
         or3 = r*sin_theta*om3
         tmp = or3*om3
         oor1 = -sin_theta*tmp
         oor2 = -cos_theta*tmp

         lgrid%res(i_rhovx1,i,j,k) = lgrid%res(i_rhovx1,i,j,k) + &
         rp2*ov1+rho*oor1

         lgrid%res(i_rhovx2,i,j,k) = lgrid%res(i_rhovx2,i,j,k) + &
         rp2*ov2+rho*oor2

         lgrid%res(i_rhovx3,i,j,k) = lgrid%res(i_rhovx3,i,j,k) + &
         rp2*ov3

         lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) + &
         rhovx1*oor1 + &
         rhovx2*oor2

#endif

       end do
      end do
     end do

#endif

#ifdef USE_CONSTANT_ACCELERATION

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        rho = lgrid%state(i_rho,i,j,k)

        lgrid%res(i_rhovx1,i,j,k) = lgrid%res(i_rhovx1,i,j,k) - &
        rho*lgrid%acc(1)

        lgrid%res(i_rhovx2,i,j,k) = lgrid%res(i_rhovx2,i,j,k) - &
        rho*lgrid%acc(2)

#if sdims_make==3
        lgrid%res(i_rhovx3,i,j,k) = lgrid%res(i_rhovx3,i,j,k) - &
        rho*lgrid%acc(3)
#endif

        lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
#if sdims_make==3
        lgrid%state(i_rhovx3,i,j,k)*lgrid%acc(3) - &
#endif
        lgrid%state(i_rhovx1,i,j,k)*lgrid%acc(1) - &
        lgrid%state(i_rhovx2,i,j,k)*lgrid%acc(2)

       end do
      end do
     end do

#endif

#ifdef USE_VDAMPING

#ifdef USE_VARIABLE_VDAMPING
     if (lgrid%time<tmax_damp) then
      nu_damp_tmp = nu_damp
     else if (lgrid%time<tend_damp) then
      nu_damp_tmp = nu_damp*cos((rph*CONST_PI)*(lgrid%time-tmax_damp)/(tend_damp-tmax_damp))
     else
      nu_damp_tmp = rp0
     endif
#endif

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

#if defined(USE_INTERNAL_BOUNDARIES) || defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL) || defined(GEOMETRY_CUBED_SPHERE)
        r = lgrid%r(i,j,k)
#else
        r = lgrid%coords(2,i,j,k)
#endif

        if(r<rmin_damp) then
         tmp = rp0
        else if(r<rmax_damp) then        
         tmp = nu_damp_tmp*rph*(rp1-cos(const_damp*(r-rmin_damp)))
        else
         tmp = nu_damp_tmp
        endif

        lgrid%res(i_rhovx1,i,j,k) = lgrid%res(i_rhovx1,i,j,k) + tmp*lgrid%state(i_rhovx1,i,j,k)
        lgrid%res(i_rhovx2,i,j,k) = lgrid%res(i_rhovx2,i,j,k) + tmp*lgrid%state(i_rhovx2,i,j,k)
#if sdims_make==3
        lgrid%res(i_rhovx3,i,j,k) = lgrid%res(i_rhovx3,i,j,k) + tmp*lgrid%state(i_rhovx3,i,j,k)
#endif

       end do
      end do
     end do

#endif

#ifdef THERMAL_DIFFUSION_EXPLICIT

     inv_dl = lgrid%inv_dx1

#ifdef USE_WB

     do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4) 
      do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3) 
       do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2) 
    
        lgrid%prim(i_rho,i,j,k) = lgrid%prim(i_rho,i,j,k) + lgrid%eq_prim_cc(ieq_rho,i,j,k)
  
       end do
      end do
     end do

#endif

#ifdef USE_TIMMES_KAPPA
     call compute_timmes_kappa(lgrid)
#endif

#ifndef USE_INTERNAL_BOUNDARIES

#if defined(X1L_REFLECTIVE) || defined(X1L_OUTFLOW) || defined(X1L_DIODE)

     if(mgrid%coords_dd(1)==0) then

      do k=lx3,ux3
       do j=lx2,ux2

         lgrid%prim(i_rho,lx1-1,j,k) = rp2*lgrid%prim(i_rho,lx1,j,k)-lgrid%prim(i_rho,lx1+1,j,k)

#ifdef FIX_TEMPERATURE_AT_X1L
#ifdef USE_WB
         lgrid%temp(lx1-1,j,k) = rp2*lgrid%eq_prim_x1(ieq_T,lx1,j,k)-lgrid%temp(lx1,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,lx1-1,j,k) = & 
         rp2*lgrid%eq_prim_x1(ieq_T,lx1,j,k)-lgrid%eq_prim_cc(ieq_T,lx1,j,k)
#endif
#else
         lgrid%temp(lx1-1,j,k) = rp2*lgrid%Tl(1)-lgrid%temp(lx1,j,k)
#endif
#else
         lgrid%temp(lx1-1,j,k) = lgrid%temp(lx1,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,lx1-1,j,k) = lgrid%eq_prim_cc(ieq_T,lx1,j,k)
#endif
#endif

       end do
      end do

     endif

#endif

#if defined(X1U_REFLECTIVE) || defined(X1U_OUTFLOW) || defined(X1U_DIODE)

     if(mgrid%coords_dd(1)==mgrid%bricks(1)-1) then

      do k=lx3,ux3
       do j=lx2,ux2

         lgrid%prim(i_rho,ux1+1,j,k) = rp2*lgrid%prim(i_rho,ux1,j,k)-lgrid%prim(i_rho,ux1-1,j,k)
      
#ifdef FIX_TEMPERATURE_AT_X1U
#ifdef USE_WB
         lgrid%temp(ux1+1,j,k) = rp2*lgrid%eq_prim_x1(ieq_T,ux1+1,j,k)-lgrid%temp(ux1,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,ux1+1,j,k) = & 
         rp2*lgrid%eq_prim_x1(ieq_T,ux1+1,j,k)-lgrid%eq_prim_cc(ieq_T,ux1,j,k)
#endif
#else
         lgrid%temp(ux1+1,j,k) = rp2*lgrid%Tu(1)-lgrid%temp(ux1,j,k)
#endif
#else
         lgrid%temp(ux1+1,j,k) = lgrid%temp(ux1,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,ux1+1,j,k) = lgrid%eq_prim_cc(ieq_T,ux1,j,k)
#endif
#endif

       end do
      end do

     endif

#endif

#if defined(X2L_REFLECTIVE) || defined(X2L_OUTFLOW) || defined(X2L_DIODE)

     if(mgrid%coords_dd(2)==0) then

      do k=lx3,ux3
       do i=lx1,ux1

         lgrid%prim(i_rho,i,lx2-1,k) = rp2*lgrid%prim(i_rho,i,lx2,k)-lgrid%prim(i_rho,i,lx2+1,k)
      
#ifdef FIX_TEMPERATURE_AT_X2L
#ifdef USE_WB
         lgrid%temp(i,lx2-1,k) = rp2*lgrid%eq_prim_x2(ieq_T,i,lx2,k)-lgrid%temp(i,lx2,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,lx2-1,k) = &
         rp2*lgrid%eq_prim_x2(ieq_T,i,lx2,k)-lgrid%eq_prim_cc(ieq_T,i,lx2,k)
#endif
#else
         lgrid%temp(i,lx2-1,k) = rp2*lgrid%Tl(2)-lgrid%temp(i,lx2,k)
#endif
#else
         lgrid%temp(i,lx2-1,k) = lgrid%temp(i,lx2,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,lx2-1,k) = lgrid%eq_prim_cc(ieq_T,i,lx2,k)
#endif
#endif

       end do
      end do

  endif

#endif

#if defined(X2U_REFLECTIVE) || defined(X2U_OUTFLOW) || defined(X2U_DIODE)

     if(mgrid%coords_dd(2)==mgrid%bricks(2)-1) then

      do k=lx3,ux3
       do i=lx1,ux1

         lgrid%prim(i_rho,i,ux2+1,k) = rp2*lgrid%prim(i_rho,i,ux2,k)-lgrid%prim(i_rho,i,ux2-1,k)
      
#ifdef FIX_TEMPERATURE_AT_X2U
#ifdef USE_WB
         lgrid%temp(i,ux2+1,k) = rp2*lgrid%eq_prim_x2(ieq_T,i,ux2+1,k)-lgrid%temp(i,ux2,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,ux2+1,k) = &
         rp2*lgrid%eq_prim_x2(ieq_T,i,ux2+1,k)-lgrid%eq_prim_cc(ieq_T,i,ux2,k)
#endif
#else
         lgrid%temp(i,ux2+1,k) = rp2*lgrid%Tu(2)-lgrid%temp(i,ux2,k)
#endif
#else
         lgrid%temp(i,ux2+1,k) = lgrid%temp(i,ux2,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,ux2+1,k) = lgrid%eq_prim_cc(ieq_T,i,ux2,k)
#endif
#endif

       end do
      end do

     endif

#endif

#if sdims_make==3

#if defined(X3L_REFLECTIVE) || defined(X3L_OUTFLOW) || defined(X3L_DIODE)

     if(mgrid%coords_dd(3)==0) then

      do j=lx2,ux2
       do i=lx1,ux1

         lgrid%prim(i_rho,i,j,lx3-1) = rp2*lgrid%prim(i_rho,i,j,lx3)-lgrid%prim(i_rho,i,j,lx3+1)
      
#ifdef FIX_TEMPERATURE_AT_X3L
#ifdef USE_WB
         lgrid%temp(i,j,lx3-1) = rp2*lgrid%eq_prim_x3(ieq_T,i,j,lx3)-lgrid%temp(i,j,lx3)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,j,lx3-1) = &
         rp2*lgrid%eq_prim_x3(ieq_T,i,j,lx3)-lgrid%eq_prim_cc(ieq_T,i,j,lx3)
#endif
#else
         lgrid%temp(i,j,lx3-1) = rp2*lgrid%Tl(3)-lgrid%temp(i,j,lx3)
#endif
#else
         lgrid%temp(i,j,lx3-1) = lgrid%temp(i,j,lx3)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,j,lx3-1) = lgrid%eq_prim_cc(ieq_T,i,j,lx3)
#endif
#endif

       end do
      end do

     endif

#endif

#if defined(X3U_REFLECTIVE) || defined(X3U_OUTFLOW) || defined(X3U_DIODE)

     if(mgrid%coords_dd(3)==mgrid%bricks(3)-1) then

      do j=lx2,ux2
       do i=lx1,ux1

         lgrid%prim(i_rho,i,j,ux3+1) = rp2*lgrid%prim(i_rho,i,j,ux3)-lgrid%prim(i_rho,i,j,ux3-1)
      
#ifdef FIX_TEMPERATURE_AT_X3U
#ifdef USE_WB
         lgrid%temp(i,j,ux3+1) = rp2*lgrid%eq_prim_x3(ieq_T,i,j,ux3+1)-lgrid%temp(i,j,ux3)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,j,ux3+1) = &
         rp2*lgrid%eq_prim_x3(ieq_T,i,j,ux3+1)-lgrid%eq_prim_cc(ieq_T,i,j,ux3)
#endif
#else
         lgrid%temp(i,j,ux3+1) = rp2*lgrid%Tu(3)-lgrid%temp(i,j,ux3)
#endif
#else
         lgrid%temp(i,j,ux3+1) = lgrid%temp(i,j,ux3)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,j,ux3+1) = lgrid%eq_prim_cc(ieq_T,i,j,ux3)
#endif
#endif

       end do
      end do

     endif

#endif

#endif

#endif

#ifdef USE_INTERNAL_BOUNDARIES

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        if(lgrid%is_solid(i,j,k)==0) then

         if(lgrid%is_solid(i-1,j,k)==1) then

          lgrid%prim(i_rho,i-1,j,k)=rp2*lgrid%prim(i_rho,i,j,k)-lgrid%prim(i_rho,i+1,j,k)
#ifdef FIX_TEMPERATURE_AT_X1L
#ifdef USE_WB
          lgrid%temp(i-1,j,k) = rp2*lgrid%eq_prim_x1(ieq_T,i,j,k)-lgrid%temp(i,j,k)
#endif
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i-1,j,k) = &
          rp2*lgrid%eq_prim_x1(ieq_T,i,j,k)-lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#else
          lgrid%temp(i-1,j,k) = lgrid%temp(i,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i-1,j,k) = &
          lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#endif    

         endif

         if(lgrid%is_solid(i+1,j,k)==1) then

          lgrid%prim(i_rho,i+1,j,k)=rp2*lgrid%prim(i_rho,i,j,k)-lgrid%prim(i_rho,i-1,j,k)
#ifdef FIX_TEMPERATURE_AT_X1U
#ifdef USE_WB
          lgrid%temp(i+1,j,k) = rp2*lgrid%eq_prim_x1(ieq_T,i+1,j,k)-lgrid%temp(i,j,k)
#endif          
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i+1,j,k) = &
          rp2*lgrid%eq_prim_x1(ieq_T,i+1,j,k)-lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#else
          lgrid%temp(i+1,j,k) = lgrid%temp(i,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i+1,j,k) = &
          lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#endif    

         endif

        endif

       end do
      end do
     end do

#endif

     inv_dl = lgrid%inv_dx1

     do k=lx3,ux3
      do j=lx2,ux2

       do i=lx1,ux1+1

        Tminus = lgrid%temp(i-1,j,k)
        Kminus = Tminus*Tminus*Tminus/(lgrid%prim(i_rho,i-1,j,k)*lgrid%kappa(i-1,j,k))

        Tplus = lgrid%temp(i,j,k)
        Kplus = Tplus*Tplus*Tplus/(lgrid%prim(i_rho,i,j,k)*lgrid%kappa(i,j,k))
 
        Kint = rp2*Kminus*Kplus/(Kminus+Kplus)
        
#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
        inv_dl = rp1/(lgrid%coords(1,i,j,k)-lgrid%coords(1,i-1,j,k))
#endif
#ifdef NONUNIFORM_RADIAL_NODES
        rmi = lgrid%r(i-1,j,k)
        rpl = lgrid%r(i,j,k)
        inv_dl = rp1/(rpl-rmi)
#endif

#ifdef BALANCE_THERMAL_DIFFUSION
        Tplus = Tplus-lgrid%eq_prim_cc(ieq_T,i,j,k)
        Tminus = Tminus-lgrid%eq_prim_cc(ieq_T,i-1,j,k)
#endif
        gradT = (Tplus-Tminus)*inv_dl

        lgrid%fe_x1(i) = Krad*Kint*gradT

#ifdef GEOMETRY_2D_POLAR
        r = lgrid%r_x1(i,j,k)
        lgrid%fe_x1(i) = lgrid%fe_x1(i)*r
#endif

#if defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
        r = lgrid%r_x1(i,j,k)
        lgrid%fe_x1(i) = lgrid%fe_x1(i)*r*r
#endif

       end do
    
       do i=lx1,ux1

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
        inv_dl = rp1/(lgrid%coords_x1(1,i+1,j,k)-lgrid%coords_x1(1,i,j,k))
#endif

#ifdef NONUNIFORM_RADIAL_NODES
        rmi = lgrid%r_x1(i,j,k)
        rpl = lgrid%r_x1(i+1,j,k)
        inv_dl = rp1/(rpl-rmi)
#endif

#ifdef GEOMETRY_2D_POLAR
        r = lgrid%r(i,j,k)
        lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
        (lgrid%fe_x1(i+1)-lgrid%fe_x1(i))*inv_dl/r
#elif defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
        r = lgrid%r(i,j,k)
        lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
        (lgrid%fe_x1(i+1)-lgrid%fe_x1(i))*inv_dl/(r*r)
#else
        lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
        (lgrid%fe_x1(i+1)-lgrid%fe_x1(i))*inv_dl
#endif

       end do

      end do
     end do

#ifdef USE_INTERNAL_BOUNDARIES

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        if(lgrid%is_solid(i,j,k)==0) then

         if(lgrid%is_solid(i,j-1,k)==1) then

          lgrid%prim(i_rho,i,j-1,k)=rp2*lgrid%prim(i_rho,i,j,k)-lgrid%prim(i_rho,i,j+1,k)
#ifdef FIX_TEMPERATURE_AT_X2L
#ifdef USE_WB
          lgrid%temp(i,j-1,k) = rp2*lgrid%eq_prim_x2(ieq_T,i,j,k)-lgrid%temp(i,j,k)
#endif          
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j-1,k) = &
          rp2*lgrid%eq_prim_x2(ieq_T,i,j,k)-lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#else
          lgrid%temp(i,j-1,k) = lgrid%temp(i,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j-1,k) = &
          lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#endif    

         endif

         if(lgrid%is_solid(i,j+1,k)==1) then

          lgrid%prim(i_rho,i,j+1,k)=rp2*lgrid%prim(i_rho,i,j,k)-lgrid%prim(i_rho,i,j-1,k)
#ifdef FIX_TEMPERATURE_AT_X2U
#ifdef USE_WB
          lgrid%temp(i,j+1,k) = rp2*lgrid%eq_prim_x2(ieq_T,i,j+1,k)-lgrid%temp(i,j,k)
#endif          
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j+1,k) = &
          rp2*lgrid%eq_prim_x2(ieq_T,i,j+1,k)-lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#else
          lgrid%temp(i,j+1,k) = lgrid%temp(i,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j+1,k) = &
          lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#endif    

         endif

        endif

       end do
      end do
     end do

#endif
 
     inv_dl = lgrid%inv_dx2

     do k=lx3,ux3
      do i=lx1,ux1

       do j=lx2,ux2+1
 
        Tminus = lgrid%temp(i,j-1,k)
        Kminus = Tminus*Tminus*Tminus/(lgrid%prim(i_rho,i,j-1,k)*lgrid%kappa(i,j-1,k))

        Tplus = lgrid%temp(i,j,k)
        Kplus = Tplus*Tplus*Tplus/(lgrid%prim(i_rho,i,j,k)*lgrid%kappa(i,j,k))
 
        Kint = rp2*Kminus*Kplus/(Kminus+Kplus)
     
#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
        inv_dl = rp1/(lgrid%coords(2,i,j,k)-lgrid%coords(2,i,j-1,k))
#endif
#ifdef BALANCE_THERMAL_DIFFUSION
        Tplus = Tplus-lgrid%eq_prim_cc(ieq_T,i,j,k)
        Tminus = Tminus-lgrid%eq_prim_cc(ieq_T,i,j-1,k)
#endif
        gradT = (Tplus-Tminus)*inv_dl

#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
        r = lgrid%r_x2(i,j,k)
        gradT = gradT/r
#endif

        lgrid%fe_x2(j) = Krad*Kint*gradT

#if defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
        sin_theta = lgrid%sin_theta_x2(i,j,k)
        lgrid%fe_x2(j) = sin_theta*lgrid%fe_x2(j)
#endif

       end do

       do j=lx2,ux2

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
        inv_dl = rp1/(lgrid%coords_x1(2,i,j+1,k)-lgrid%coords_x2(2,i,j,k))
#endif
#ifdef GEOMETRY_2D_POLAR
        r = lgrid%r(i,j,k)
        lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
        (lgrid%fe_x2(j+1)-lgrid%fe_x2(j))*inv_dl/r
#elif defined(GEOMETRY_2D_SPHERICAL)
        x = lgrid%coords(1,i,j,k)
        lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
        (lgrid%fe_x2(j+1)-lgrid%fe_x2(j))*inv_dl/x
#elif defined(GEOMETRY_3D_SPHERICAL)
        tmp = lgrid%inv_r_sin_theta(i,j,k)
        lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
        (lgrid%fe_x2(j+1)-lgrid%fe_x2(j))*inv_dl*tmp
#else
        lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
        (lgrid%fe_x2(j+1)-lgrid%fe_x2(j))*inv_dl
#endif 

       end do

      end do
     end do

#if sdims_make==3

#ifdef USE_INTERNAL_BOUNDARIES

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        if(lgrid%is_solid(i,j,k)==0) then

         if(lgrid%is_solid(i,j,k-1)==1) then

          lgrid%prim(i_rho,i,j,k-1)=rp2*lgrid%prim(i_rho,i,j,k)-lgrid%prim(i_rho,i,j,k+1)
#ifdef FIX_TEMPERATURE_AT_X3L
#ifdef USE_WB
          lgrid%temp(i,j,k-1) = rp2*lgrid%eq_prim_x3(ieq_T,i,j,k)-lgrid%temp(i,j,k)
#endif          
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j,k-1) = &
          rp2*lgrid%eq_prim_x3(ieq_T,i,j,k)-lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#else
          lgrid%temp(i,j,k-1) = lgrid%temp(i,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j,k-1) = &
          lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#endif    

         endif

         if(lgrid%is_solid(i,j,k+1)==1) then

          lgrid%prim(i_rho,i,j,k+1)=rp2*lgrid%prim(i_rho,i,j,k)-lgrid%prim(i_rho,i,j,k-1)
#ifdef FIX_TEMPERATURE_AT_X3U
#ifdef USE_WB
          lgrid%temp(i,j,k+1) = rp2*lgrid%eq_prim_x3(ieq_T,i,j,k+1)-lgrid%temp(i,j,k)
#endif          
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j,k+1) = &
          rp2*lgrid%eq_prim_x3(ieq_T,i,j,k+1)-lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#else
          lgrid%temp(i,j,k+1) = lgrid%temp(i,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j,k+1) = &
          lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#endif    

         endif

        endif

       end do
      end do
     end do

#endif
 
     inv_dl = lgrid%inv_dx3

     do j=lx2,ux2
      do i=lx1,ux1

       do k=lx3,ux3+1
  
        Tminus = lgrid%temp(i,j,k-1)
        Kminus = Tminus*Tminus*Tminus/(lgrid%prim(i_rho,i,j,k-1)*lgrid%kappa(i,j,k-1))

        Tplus = lgrid%temp(i,j,k)
        Kplus = Tplus*Tplus*Tplus/(lgrid%prim(i_rho,i,j,k)*lgrid%kappa(i,j,k))
 
        Kint = rp2*Kminus*Kplus/(Kminus+Kplus)
     
#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
        inv_dl = rp1/(lgrid%coords(3,i,j,k)-lgrid%coords(3,i,j,k-1))
#endif
#ifdef BALANCE_THERMAL_DIFFUSION
        Tplus = Tplus-lgrid%eq_prim_cc(ieq_T,i,j,k)
        Tminus = Tminus-lgrid%eq_prim_cc(ieq_T,i,j,k-1)
#endif
        gradT = (Tplus-Tminus)*inv_dl

#ifdef GEOMETRY_3D_SPHERICAL
        tmp = lgrid%inv_r_sin_theta_x3(i,j,k)
        gradT = gradT*tmp
#endif

        lgrid%fe_x3(k) = Krad*Kint*gradT

       end do

       do k=lx3,ux3
#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
        inv_dl = rp1/(lgrid%coords_x3(3,i,j,k+1)-lgrid%coords_x3(3,i,j,k))
#endif

#ifdef GEOMETRY_3D_SPHERICAL
        tmp = lgrid%inv_r_sin_theta(i,j,k)
        lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
        (lgrid%fe_x3(k+1)-lgrid%fe_x3(k))*inv_dl*tmp
#else
        lgrid%res(i_rhoe,i,j,k) = lgrid%res(i_rhoe,i,j,k) - &
        (lgrid%fe_x3(k+1)-lgrid%fe_x3(k))*inv_dl
#endif

       end do

      end do
    end do

#endif

#endif

#ifdef USE_INTERNAL_BOUNDARIES

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        if(lgrid%is_solid(i,j,k)==1) then
         do iv=1,nvars
          lgrid%res(iv,i,j,k) = rp0
         end do
        end if

       end do
      end do
     end do

#endif

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        do iv=1,nvars
         lgrid%state(iv,i,j,k) = &
         a1rk*lgrid%state0(iv,i,j,k) + &
         a2rk*lgrid%state(iv,i,j,k) + &
         a3rk*lgrid%res(iv,i,j,k)
        end do

       end do
      end do
     end do

     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        rho = lgrid%state(i_rho,i,j,k)
        rhovx1 = lgrid%state(i_rhovx1,i,j,k)
        rhovx2 = lgrid%state(i_rhovx2,i,j,k)
#if sdims_make==3       
        rhovx3 = lgrid%state(i_rhovx3,i,j,k)
#else
        rhovx3 = rp0
#endif       
        rhoe = lgrid%state(i_rhoe,i,j,k)

        inv_rho = rp1/rho

        eint = rhoe - rph*(rhovx1*rhovx1+rhovx2*rhovx2+rhovx3*rhovx3)*inv_rho

#ifdef USE_MHD
        bx1 = lgrid%b_cc(1,i,j,k)
        bx2 = lgrid%b_cc(2,i,j,k)
#if sdims_make==3
        bx3 = lgrid%b_cc(3,i,j,k)
#else
        bx3 = rp0
#endif
        eint = eint - rph*(bx1*bx1+bx2*bx2+bx3*bx3)
#endif

#ifdef EVOLVE_ETOT
        eint = eint - rho*lgrid%phi_cc(i,j,k)
#endif

        lgrid%prim(i_rho,i,j,k) = rho
        lgrid%prim(i_vx1,i,j,k) = rhovx1*inv_rho
        lgrid%prim(i_vx2,i,j,k) = rhovx2*inv_rho
#if sdims_make==3
        lgrid%prim(i_vx3,i,j,k) = rhovx3*inv_rho
#endif

#ifdef HELMHOLTZ_EOS
#ifdef ADVECT_YE_IABAR
        ye = lgrid%state(i_rhoye,i,j,k)*inv_rho
        abar = rho/lgrid%state(i_rhoiabar,i,j,k)
#endif
#ifdef ADVECT_SPECIES
       inv_abar = rp0
       ye = rp0
       do iv=1,nspecies
         tmp = lgrid%state(i_as1+iv-1,i,j,k)/lgrid%A(iv)
         inv_abar = inv_abar + tmp
         ye = ye + tmp*lgrid%Z(iv)
       end do
       abar = rp1/inv_abar*rho
       ye = ye*inv_rho
#endif
       zbar = ye*abar
#else
#ifdef ADVECT_YE_IABAR
        ye = lgrid%state(i_rhoye,i,j,k)*inv_rho
        abar = rho/lgrid%state(i_rhoiabar,i,j,k)
        inv_mu =  (ye*abar + rp1)/abar
#endif
#ifdef ADVECT_SPECIES
       inv_mu = rp0
       do iv=1,nspecies
         inv_mu = inv_mu + lgrid%state(i_as1+iv-1,i,j,k)*(lgrid%Z(iv)+rp1)/lgrid%A(iv)
       end do
       inv_mu = inv_mu*inv_rho
#endif
#endif

#ifdef USE_PRAD
        tmp = igmm1*rho*CONST_RGAS*inv_mu
        T = lgrid%temp(i,j,k)
        Res_prad = -rp1
        do iter=1,250
         Res0 = Res_prad
         T2 = T*T
         T3 = T2*T
         T4 = T3*T
         Res_prad = CONST_RAD*T4 + tmp*T - eint
         if (abs(Res_prad/eint) < em14) exit
         if ((abs(Res0 - Res_prad)/abs(Res0) < em15) .and. iter>1) then
           write(*,*) 'state->prim, EoS gas+radiation, RN stalled, ','cell=(',i,j,k,')'
           exit
         end if
         dRes_dT = rp4*CONST_RAD*T3 + tmp
         T = T - Res_prad/dRes_dT
        end do
        T2 = T*T
        T3 = T2*T
        T4 = T3*T
        lgrid%temp(i,j,k) = T
        p = rho*CONST_RGAS*T*inv_mu + CONST_RAD*T4*othird
        lgrid%prim(i_p,i,j,k) = p
#ifdef USE_FASTEOS
        mu = rp1/inv_mu 

        tmp1 = CONST_RAD*mu*T3
        tmp2 = CONST_RGAS*rho

        dp_drho = fthirds * &
        CONST_RAD*CONST_RGAS*T4*(rp3*gm-rp4) / &
        (rp4*tmp1*gmm1+tmp2)

        dp_deps = gmm1 * &
        (rp4*tmp1+rp3*tmp2) / &
        (rp12*tmp1*gmm1+rp3*tmp2)

        sound2 = dp_drho+dp_deps*(p+eint)/rho

        lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
        lgrid%gammaf(i_gammac,i,j,k) = sound2*rho/p
#endif
#elif defined(HELMHOLTZ_EOS)
        T = lgrid%temp(i,j,k)
#ifdef USE_FASTEOS       
        call helm_rhoe_given(rho,eint*inv_rho,abar,zbar,T,p,sound,.true.)
        lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
        lgrid%gammaf(i_gammac,i,j,k) = sound*sound*rho/p
#else
        call helm_rhoe_given(rho,eint*inv_rho,abar,zbar,T,p,sound,.false.)
#endif
        lgrid%prim(i_p,i,j,k) = p
        lgrid%temp(i,j,k) = T
#elif defined(PIG_EOS)
        T = lgrid%temp(i,j,k)
#ifdef USE_FASTEOS       
        call pig_rhoe_given(rho,eint*inv_rho,T,p,sound,.true.)
        lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
        lgrid%gammaf(i_gammac,i,j,k) = sound*sound*rho/p
#else
        call pig_rhoe_given(rho,eint*inv_rho,T,p,sound,.false.)
#endif
        lgrid%prim(i_p,i,j,k) = p
        lgrid%temp(i,j,k) = T
#else
        p = gmm1*eint
        lgrid%prim(i_p,i,j,k) = p
        lgrid%temp(i,j,k) = p/(rho*CONST_RGAS*inv_mu)
#endif
       
        lgrid%eint(i,j,k) = eint

#if nas_make>0
        do iv=i_as1,i_asl
         lgrid%prim(iv,i,j,k) = lgrid%state(iv,i,j,k)*inv_rho
        end do
#endif

       end do
      end do
     end do

#ifdef USE_GRAVITY
#ifdef GRAVITY_SOLVER_RK
#ifdef USE_GRAVITY_SOLVER
     call gravity_solver(mgrid,lgrid)
#endif
#ifdef USE_MONOPOLE_GRAVITY
     call monopole_gravity(mgrid,lgrid,int(nx1/2))
#endif
#endif
#endif 

    end do

 end subroutine hydro_step 

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! HYPERBOLIC TIME STEP (CFL CRITERION)
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 subroutine compute_hyperbolic_dt(mgrid,lgrid)
   type(mpigrid), intent(in) :: mgrid
   type(locgrid), intent(inout) :: lgrid

   integer :: i,j,k
   integer :: lx1,ux1,lx2,ux2,lx3,ux3
   integer :: ierr

   real(kind=rp) :: rho,vx1,vx2,vx3,p,c,sx1,sx2,sx3,smax(1),smax_comm(1),T,mu,inv_mu,inv_dl,T2,T3,T4

   real(kind=rp) :: gm,gmm1,igmm1
   real(kind=rp) :: ye,abar,inv_abar
   real(kind=rp) :: dp_drho,dp_deps,ei
   real(kind=rp) :: tmp,tmp1,tmp2,inv_r_sin_theta,zbar,rmi,rpl,cv,bx1,bx2,bx3
   integer :: iter
   real(kind=rp) :: ca2

   ierr = idummy

   sx3 = rp0
   T = rp0
   mu = lgrid%mu
   inv_mu = rp1/mu
   inv_dl = rp0
   T2 = rp0
   T3 = rp0
   T4 = rp0

   gm = lgrid%gm
   gmm1 = gm-rp1
   igmm1 = rp1/gmm1

   ye = rp0
   abar = rp0
   inv_abar = rp0

   dp_drho = rp0
   dp_deps = rp0
   ei = rp0

   tmp = rp0
   tmp1 = rp0
   tmp2 = rp0
   inv_r_sin_theta = rp0
   zbar = rp0
   rmi = rp0
   rpl = rp0
   cv = rp0

   bx1 = rp0
   bx2 = rp0
   bx3 = rp0

   iter = idummy
   
   ca2 = rp0
   smax(1) = rp0

   lx1 = mgrid%i1(1)
   ux1 = mgrid%i2(1)
   lx2 = mgrid%i1(2)
   ux2 = mgrid%i2(2)
   lx3 = mgrid%i1(3)
   ux3 = mgrid%i2(3)

   do k=lx3,ux3
    do j=lx2,ux2
     do i=lx1,ux1

#ifdef USE_INTERNAL_BOUNDARIES
      if(lgrid%is_solid(i,j,k)==0) then
#endif

       rho = lgrid%prim(i_rho,i,j,k)
       vx1 = lgrid%prim(i_vx1,i,j,k)
       vx2 = lgrid%prim(i_vx2,i,j,k)
#if sdims_make==3
       vx3 = lgrid%prim(i_vx3,i,j,k)
#else
       vx3 = rp0
#endif

#ifdef USE_PRAD
#ifdef ADVECT_YE_IABAR
       ye = lgrid%prim(i_ye,i,j,k)
       abar = rp1/lgrid%prim(i_iabar,i,j,k)
       inv_mu = (ye*abar + rp1)/abar
#endif
#ifdef ADVECT_SPECIES
       inv_mu = rp0
       do ierr=1,nspecies
         inv_mu = inv_mu + lgrid%prim(i_as1+ierr,i,j,k)*(lgrid%Z(ierr)+rp1)/lgrid%A(ierr)
       end do
#endif
#elif defined(HELMHOLTZ_EOS)
#ifdef ADVECT_YE_IABAR
       ye = lgrid%prim(i_ye,i,j,k)
       abar = rp1/lgrid%prim(i_iabar,i,j,k)
#endif
#ifdef ADVECT_SPECIES
       inv_abar = rp0
       ye = rp0
       do ierr=1,nspecies
         tmp = lgrid%prim(i_as1+ierr-1,i,j,k)/lgrid%A(ierr)
         inv_abar = inv_abar + tmp
         ye = ye + tmp*lgrid%Z(ierr)
       end do
       abar = rp1/inv_abar
#endif
       zbar = ye*abar
#endif

       p = lgrid%prim(i_p,i,j,k)

#ifdef USE_PRAD

       T = lgrid%temp(i,j,k)
       T2 = T*T
       T3 = T2*T
       T4 = T3*T
       ei = rho*CONST_RGAS*T*inv_mu*igmm1 + CONST_RAD*T4
       
       mu = rp1/inv_mu

       tmp1 = CONST_RAD*mu*T3 
       tmp2 = CONST_RGAS*rho

       dp_drho = fthirds * &
       CONST_RAD*CONST_RGAS*T4*(rp3*gm-rp4) / &
       (rp4*tmp1*gmm1+tmp2)

       dp_deps = gmm1 * &
       (rp4*tmp1+rp3*tmp2) / &
       (rp12*tmp1*gmm1+rp3*tmp2)
 
       c = sqrt(dp_drho+dp_deps*(p+ei)/rho)

#elif defined(HELMHOLTZ_EOS)

       T = lgrid%temp(i,j,k)
       call helm_rhoT_given_full(rho,T,abar,zbar,p,ei,c,cv)

#elif defined(PIG_EOS)

       T = lgrid%temp(i,j,k)
       call pig_rhoT_given_full(rho,T,p,ei,c,cv)

#else

       c = sqrt(gm*p/rho)

#endif

#ifdef USE_MHD
       bx1 = lgrid%b_cc(1,i,j,k)
       bx2 = lgrid%b_cc(2,i,j,k)
#if sdims_make==3
       bx3 = lgrid%b_cc(3,i,j,k)
#else
       bx3 = rp0
#endif 
       ca2 = bx1*bx1+bx2*bx2+bx3*bx3 
       c = sqrt(c*c+ca2/rho)
#endif

       inv_dl = lgrid%inv_dx1

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
       inv_dl = rp1/(lgrid%coords_x1(1,i+1,j,k)-lgrid%coords_x1(1,i,j,k))
#endif

#ifdef NONUNIFORM_RADIAL_NODES
       rmi = lgrid%r_x1(i,j,k)
       rpl = lgrid%r_x1(i+1,j,k)
       inv_dl = rp1/(rpl-rmi)
#endif

#ifdef GEOMETRY_CUBED_SPHERE
       tmp1 = lgrid%A_x1(i,j,k)
       tmp2 = lgrid%A_x1(i+1,j,k)
       tmp = lgrid%ivol(i,j,k)
       inv_dl = rph*(tmp1+tmp2)*tmp
#endif

       sx1 = (abs(vx1) + c)*inv_dl

       inv_dl = lgrid%inv_dx2

#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL) 
       inv_dl = inv_dl/lgrid%r(i,j,k)
#endif

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
       inv_dl = rp1/(lgrid%coords_x2(2,i,j+1,k)-lgrid%coords_x2(2,i,j,k))
#endif

#ifdef GEOMETRY_CUBED_SPHERE
       tmp1 = lgrid%A_x2(i,j,k)
       tmp2 = lgrid%A_x2(i,j+1,k)
       inv_dl = rph*(tmp2+tmp1)*tmp
#endif

       sx2 = (abs(vx2) + c)*inv_dl

#if sdims_make==3

       inv_dl = lgrid%inv_dx3

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
       inv_dl = rp1/(lgrid%coords_x3(3,i,j,k+1)-lgrid%coords_x3(3,i,j,k))
#endif

#ifdef GEOMETRY_3D_SPHERICAL
       inv_r_sin_theta = lgrid%inv_r_sin_theta(i,j,k)
       inv_dl = inv_dl*inv_r_sin_theta
#endif

#ifdef GEOMETRY_CUBED_SPHERE
       tmp1 = lgrid%A_x3(i,j,k)
       tmp2 = lgrid%A_x3(i,j,k+1)
       inv_dl = rph*(tmp2+tmp1)*tmp
#endif

       sx3 = (abs(vx3) + c)*inv_dl

#endif

       smax(1) = max(smax(1), &
#if sdims_make==3
       sx3+&
#endif
       sx1+sx2)

#ifdef USE_INTERNAL_BOUNDARIES
      end if
#endif

     end do
    end do 
   end do
   
   call mpi_allreduce(smax, smax_comm, 1, MPI_RP , MPI_MAX, mgrid%comm_cart, ierr)

   lgrid%smax = smax_comm(1) 

   lgrid%dt = cfl/smax_comm(1)

 end subroutine compute_hyperbolic_dt

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! RIEMANN SOLVERS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
#ifdef USE_MHD

#if defined(HLLD_FLUX) || defined(LHLLD_FLUX)  
 subroutine riemann(il,iu,qL,qR,bL,bR,flux,fluxb,ru)
   integer, intent(in) :: il,iu
   real(kind=rp), intent(in), dimension(1:nvars,il:iu) :: qL,qR
   real(kind=rp), intent(in), dimension(1:sdims,il:iu) :: bL,bR
   real(kind=rp), intent(inout), dimension(1:nvars,il:iu) :: flux
   real(kind=rp), intent(inout), dimension(1:sdims,il:iu) :: fluxb
   type(r_utils), intent(inout) :: ru

   integer :: idx, iv
   real(kind=rp) :: rhoL,vx1L,vx2L,vx3L,pL,rhoR,vx1R,vx2R,vx3R,pR,rhoeL,rhoeR,cL,cR
   real(kind=rp) :: max_c,sL,sR,dsuL,dsuR,ustar, &
   rhostarL,rhostarR,rhoestarL,rhoestarR,v2L,v2R,inv_rhoL,inv_rhoR, &
   T,eint,inv_mu,T2,T3,T4,inv_abar

   real(kind=rp) :: bx1L,bx2L,bx3L,bx1R,bx2R,bx3R,&
   bx1,bx1_2,pbL,pbR,a2L,a2R,an2L,an2R,c2L,c2R,ptL,ptR,&
   inv_temp1,dsumL,dsumR,a1_inv,vx2starL,bx2starL,&
   vx3starL,bx3starL,a2_inv,vx2starR,bx2starR,vx3starR,bx3starR,&
   vdotbL,vdotbR,vdotbstarL,vdotbstarR,pstar,&
   sqrt_rhostarL,sqrt_rhostarR,sstarL,sstarR,inv_sqr_bar,sgn,&
   vx22star,bx22star,vx32star,bx32star,vdotb2star,&
   rhoe2starL,rhoe2starR,&
   rho,vx1,vx2,vx3,rhoe,bx2,bx3,phi,pres,abs_bx1,dummy

   real(kind=rp) :: dp_drho,dp_deps

#ifdef HLLD_FLUX
   real(kind=rp), dimension(1:nvars) :: U,f,Us,Uss
   real(kind=rp), dimension(1:sdims) :: Ub,fb,Ubs,Ubss
#endif

#ifdef LHLLD_FLUX
   real(kind=rp) :: machL,machR,chi,cu2L,cu2R
#endif

#ifdef USE_SHOCK_FLATTENING
   real(kind=rp), dimension(1:nvars) :: UL,UR,fL,fR
   real(kind=rp), dimension(1:sdims) :: UbL,UbR,fbL,fbR
#endif

   real(kind=rp) :: ye,abar,zbar,sound

#ifdef USE_PRAD
#ifndef USE_FASTEOS
   real(kind=rp) :: tmp,tmp1,tmp2,Res0,Res_prad,dRes_dT
   integer :: iter
#endif
#endif

#ifdef LHLLD_FLUX
#if nas_make>0
   real(kind=rp) :: half_one_plus_sign,half_one_minus_sign
#endif
#endif

   real(kind=rp) :: gm,igmm1,gmm1,mu

   gm = ru%gm
   mu = ru%mu
   gmm1 = gm-rp1
   igmm1 = rp1/gmm1

   inv_mu = rp1/mu
   T = rp0
   T2 = rp0
   T3 = rp0
   T4 = rp0

   dummy = rp0
   pres = rp0

   iv = 0

   abar = rp0
   ye = rp0
   zbar = rp0
   sound = rp0
   dp_deps = rp0
   dp_drho = rp0
   inv_abar = rp0

   rho  = rp0
   vx1  = rp0
   vx2  = rp0
   vx3  = rp0
   rhoe = rp0
   bx2  = rp0
   bx3  = rp0

#ifdef HLLD_FLUX
   
   do iv=1,nvars
    U(iv) = rp0
    f(iv) = rp0
    Us(iv) = rp0
    Uss(iv) = rp0
  end do

   do iv=1,sdims
    Ub(iv) = rp0
    fb(iv) = rp0
    Ubs(iv) = rp0
    Ubss(iv) = rp0
   end do

#endif

   do idx=il,iu

      rhoL = qL(i_rho,idx)
      inv_rhoL = rp1/rhoL
      vx1L = qL(i_vx1,idx)
      vx2L = qL(i_vx2,idx)
#if sdims_make==3
      vx3L = qL(i_vx3,idx)
#else
      vx3L = rp0
#endif
      v2L = vx1L*vx1L+vx2L*vx2L+vx3L*vx3L

#ifdef USE_PRAD
#ifdef ADVECT_YE_IABAR
      ye = qL(i_ye,idx)
      abar = rp1/qL(i_iabar,idx)
      inv_mu = (ye*abar + rp1)/abar
#endif 
#ifdef ADVECT_SPECIES
      inv_mu = rp0
      do iv=1,nspecies
        inv_mu = inv_mu + qL(i_as1+iv-1,idx)*(ru%Z(iv)+rp1)/ru%A(iv)
      end do
#endif
#endif

#ifndef USE_FASTEOS
#ifdef HELMHOLTZ_EOS
#ifdef ADVECT_YE_IABAR
      ye = qL(i_ye,idx)
      abar = rp1/qL(i_iabar,idx)
#endif 
#ifdef ADVECT_SPECIES
      inv_abar = rp0
      ye = rp0
      do iv=1,nspecies
        dummy = qL(i_as1+iv-1,idx)/ru%A(iv)
        inv_abar = inv_abar + dummy
        ye = ye + dummy*ru%Z(iv)
      end do
      abar = rp1/inv_abar
#endif
      zbar = ye*abar
#endif
#endif

      pL = qL(i_p,idx)
      
#ifdef USE_PRAD
#ifdef USE_FASTEOS
      eint = pL/(ru%gammafL(ru%dir)%val(i_gammae,idx)-rp1)
      c2L = ru%gammafL(ru%dir)%val(i_gammac,idx)*pL*inv_rhoL
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      tmp = rhoL*CONST_RGAS*inv_mu
      Res_prad = -rp1
      do iter=1,250
        T2 = T*T
        T3 = T2*T
        T4 = T3*T
        Res0 = Res_prad
        Res_prad = CONST_RAD*othird*T4 + tmp*T - pL
        if (abs(Res_prad/pL) < em14) exit
        if ((abs(Res0 - Res_prad)/abs(Res0) < em15) .and. iter>1) then
          write(*,*) 'Riemann solver, EoS gas+radiation, RN stalled'
          exit
        end if
        dRes_dT = fthirds*CONST_RAD*T3 + tmp
        T = T - Res_prad/dRes_dT
      end do
      T2 = T*T
      T3 = T2*T
      T4 = T3*T
      eint = tmp*T*igmm1 + CONST_RAD*T4

      mu = rp1/inv_mu

      tmp1 = CONST_RAD*mu*T3
      tmp2 = CONST_RGAS*rhoL

      dp_drho = fthirds * &
      CONST_RAD*CONST_RGAS*T4*(rp3*gm-rp4) / &
      (rp4*tmp1*gmm1+tmp2)

      dp_deps = gmm1 * &
      (rp4*tmp1+rp3*tmp2) / &
      (rp12*tmp1*gmm1+rp3*tmp2)

      c2L = dp_drho+dp_deps*(pL+eint)*inv_rhoL
#endif
#elif defined(HELMHOLTZ_EOS)
#ifdef USE_FASTEOS
      eint = pL/(ru%gammafL(ru%dir)%val(i_gammae,idx)-rp1)
      c2L = ru%gammafL(ru%dir)%val(i_gammac,idx)*pL*inv_rhoL
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      call helm_rhoP_given(rhoL,pL,abar,zbar,T,eint,sound,.true.)
      eint = eint*rhoL
      c2L = sound*sound
#endif
#elif defined(PIG_EOS)
#ifdef USE_FASTEOS
      eint = pL/(ru%gammafL(ru%dir)%val(i_gammae,idx)-rp1)
      c2L = ru%gammafL(ru%dir)%val(i_gammac,idx)*pL*inv_rhoL
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      call pig_rhoP_given(rhoL,pL,T,eint,sound,.true.)
      eint = eint*rhoL
      c2L = sound*sound
#endif
#else   
      eint = pL*igmm1
      c2L = gm*pL*inv_rhoL
#endif

      rhoeL = eint + rph*rhoL*v2L

      bx1L = bL(1,idx)
      bx2L = bL(2,idx)
#if sdims_make==3
      bx3L = bL(3,idx)
#else
      bx3L = rp0
#endif

      rhoR = qR(i_rho,idx)
      inv_rhoR = rp1/rhoR
      vx1R = qR(i_vx1,idx)
      vx2R = qR(i_vx2,idx)
#if sdims_make==3
      vx3R = qR(i_vx3,idx)
#else
      vx3R = rp0
#endif
      v2R = vx1R*vx1R+vx2R*vx2R+vx3R*vx3R

#ifdef USE_PRAD
#ifdef ADVECT_YE_IABAR
      ye = qR(i_ye,idx)
      abar = rp1/qR(i_iabar,idx)
      inv_mu = (ye*abar + rp1)/abar
#endif 
#ifdef ADVECT_SPECIES
      inv_mu = rp0
      do iv=1,nspecies
        inv_mu = inv_mu + qR(i_as1+iv-1,idx)*(ru%Z(iv)+rp1)/ru%A(iv)
      end do
#endif
#endif

#ifndef USE_FASTEOS
#ifdef HELMHOLTZ_EOS
#ifdef ADVECT_YE_IABAR
      ye = qR(i_ye,idx)
      abar = rp1/qR(i_iabar,idx)
#endif
#ifdef ADVECT_SPECIES
      inv_abar = rp0
      ye = rp0
      do iv=1,nspecies
        dummy = qR(i_as1+iv-1,idx)/ru%A(iv)
        inv_abar = inv_abar + dummy
        ye = ye + dummy*ru%Z(iv)
      end do
      abar = rp1/inv_abar
#endif
      zbar = ye*abar
#endif
#endif

      pR = qR(i_p,idx)
      
#ifdef USE_PRAD
#ifdef USE_FASTEOS
      eint = pR/(ru%gammafR(ru%dir)%val(i_gammae,idx)-rp1)
      c2R = ru%gammafR(ru%dir)%val(i_gammac,idx)*pR*inv_rhoR
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      tmp = rhoR*CONST_RGAS*inv_mu
      Res_prad = -rp1
      do iter=1,250
        T2 = T*T
        T3 = T2*T
        T4 = T3*T
        Res0 = Res_prad
        Res_prad = CONST_RAD*othird*T4 + tmp*T - pR
        if (abs(Res_prad/pR) < em14) exit
        if ((abs(Res0 - Res_prad)/abs(Res0) < em15) .and. iter>1) then
          write(*,*) 'Riemann solver, EoS gas+radiation, RN stalled'
          exit
        end if
        dRes_dT = fthirds*CONST_RAD*T3 + tmp
        T = T - Res_prad/dRes_dT
      end do
      T2 = T*T
      T3 = T2*T
      T4 = T3*T
      eint = tmp*T*igmm1 + CONST_RAD*T4

      mu = rp1/inv_mu

      tmp1 = CONST_RAD*mu*T3
      tmp2 = CONST_RGAS*rhoR

      dp_drho = fthirds * &
      CONST_RAD*CONST_RGAS*T4*(rp3*gm-rp4) / &
      (rp4*tmp1*gmm1+tmp2)

      dp_deps = gmm1 * &
      (rp4*tmp1+rp3*tmp2) / &
      (rp12*tmp1*gmm1+rp3*tmp2)

      c2R = dp_drho+dp_deps*(pR+eint)*inv_rhoR
#endif
#elif defined(HELMHOLTZ_EOS)
#ifdef USE_FASTEOS
      eint = pR/(ru%gammafR(ru%dir)%val(i_gammae,idx)-rp1)
      c2R = ru%gammafR(ru%dir)%val(i_gammac,idx)*pR*inv_rhoR
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      call helm_rhoP_given(rhoR,pR,abar,zbar,T,eint,sound,.true.)
      eint = eint*rhoR
      c2R = sound*sound
#endif
#elif defined(PIG_EOS)
#ifdef USE_FASTEOS
      eint = pR/(ru%gammafR(ru%dir)%val(i_gammae,idx)-rp1)
      c2R = ru%gammafR(ru%dir)%val(i_gammac,idx)*pR*inv_rhoR
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      call pig_rhoP_given(rhoR,pR,T,eint,sound,.true.)
      eint = eint*rhoR
      c2R = sound*sound
#endif
#else   
      eint = pR*igmm1
      c2R = gm*pR*inv_rhoR
#endif

      rhoeR = eint + rph*rhoR*v2R

      bx1R = bR(1,idx)
      bx2R = bR(2,idx)
#if sdims_make==3
      bx3R = bR(3,idx)
#else
      bx3R = rp0
#endif
      
      bx1 = rph*(bx1L+bx1R)
      bx1_2 = bx1*bx1

      pbL = rph*(bx1_2+bx2L*bx2L+bx3L*bx3L)
      pbR = rph*(bx1_2+bx2R*bx2R+bx3R*bx3R)
      
      rhoeL = rhoeL + pbL
      rhoeR = rhoeR + pbR
     
      ptL = pL + pbL
      ptR = pR + pbR
      
      a2L = rp2*pbL*inv_rhoL
      a2R = rp2*pbR*inv_rhoR
  
      an2L = bx1_2*inv_rhoL
      an2R = bx1_2*inv_rhoR

      dummy = c2L+a2L
      cL = sqrt( rph*(c2L+a2L+sqrt( dummy*dummy-rp4*c2L*an2L )))
      dummy = c2R+a2R
      cR = sqrt( rph*(c2R+a2R+sqrt( dummy*dummy-rp4*c2R*an2R )))

      max_c = max(cL,cR)

      sL = min(vx1L,vx1R) - max_c
      sR = max(vx1L,vx1R) + max_c

      dsuL = sL-vx1L
      dsuR = sR-vx1R
      
      inv_temp1 = rp1 / (dsuR*rhoR-dsuL*rhoL)

      ustar = (dsuR*rhoR*vx1R - dsuL*rhoL*vx1L - ptR + ptL) * inv_temp1

      dsumL = sL - ustar
      dsumR = sR - ustar
 
#ifdef LHLLD_FLUX
      dummy = v2L+a2L
      cu2L = rph*(v2L+a2L+sqrt(dummy*dummy-rp4*v2L*an2L))
      dummy = v2R+a2R
      cu2R = rph*(v2R+a2R+sqrt(dummy*dummy-rp4*v2R*an2R))
           
      machL = sqrt(cu2L)/cL
      machR = sqrt(cu2R)/cR

      max_c = max(machL,machR)

      if(max_c<0.6_rp) then
       chi = min(rp1,max(machL,machR))
       chi = max(Mach_cutoff,chi)
       phi = chi*(rp2-chi)
      else
       phi = rp1
      endif
#else
      phi = rp1
#endif

#ifdef USE_SHOCK_FLATTENING
      if(ru%is_flattened(ru%dir)%val(idx)==1) then

        sL = min(rp0,sL)
        sR = max(rp0,sR)
     
        UL(i_rho) = rhoL
        UL(i_rhovx1) = rhoL*vx1L
        UL(i_rhovx2) = rhoL*vx2L
#if sdims_make==3
        UL(i_rhovx3) = rhoL*vx3L
#endif
        UL(i_rhoe) = rhoeL
         
#if nas_make>0
        do iv=i_as1,nvars
         UL(iv) = rhoL*qL(iv,idx)
        end do
#endif

        UbL(1) = bx1
        UbL(2) = bx2L
#if sdims_make==3
        UbL(3) = bx3L
#endif
     
        UR(i_rho) = rhoR
        UR(i_rhovx1) = rhoR*vx1R
        UR(i_rhovx2) = rhoR*vx2R
#if sdims_make==3
        UR(i_rhovx3) = rhoR*vx3R
#endif
        UR(i_rhoe) = rhoeR
         
#if nas_make>0
        do iv=i_as1,nvars
         UR(iv) = rhoR*qR(iv,idx)
        end do
#endif

        UbR(1) = bx1
        UbR(2) = bx2R
#if sdims_make==3
        UbR(3) = bx3R
#endif

        fL(i_rho) = rhoL*vx1L
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
        fL(i_rhovx1) = rhoL*vx1L*vx1L-bx1_2
#else
        fL(i_rhovx1) = rhoL*vx1L*vx1L+ptL-bx1_2
#endif
        fL(i_rhovx2) = rhoL*vx1L*vx2L-bx1*bx2L
#if sdims_make==3        
        fL(i_rhovx3) = rhoL*vx1L*vx3L-bx1*bx3L
#endif
        fL(i_rhoe) = (rhoeL+ptL)*vx1L-bx1*(bx1*vx1L+bx2L*vx2L+bx3L*vx3L)
#if nas_make>0
        do iv=i_as1,nvars
         fL(iv) = UL(iv)*vx1L
        end do
#endif
   
        fbL(1) = rp0
        fbL(2) = vx1L*bx2L-vx2L*bx1
#if sdims_make==3        
        fbL(3) = vx1L*bx3L-vx3L*bx1
#endif

        fR(i_rho) = rhoR*vx1R
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
        fR(i_rhovx1) = rhoR*vx1R*vx1R-bx1_2
#else
        fR(i_rhovx1) = rhoR*vx1R*vx1R+ptR-bx1_2
#endif
        fR(i_rhovx2) = rhoR*vx1R*vx2R-bx1*bx2R
#if sdims_make==3        
        fR(i_rhovx3) = rhoR*vx1R*vx3R-bx1*bx3R
#endif
        fR(i_rhoe) = (rhoeR+ptR)*vx1R-bx1*(bx1*vx1R+bx2R*vx2R+bx3R*vx3R)
#if nas_make>0
        do iv=i_as1,nvars
         fR(iv) = UR(iv)*vx1R
        end do
#endif
   
        fbR(1) = rp0
        fbR(2) = vx1R*bx2R-vx2R*bx1
#if sdims_make==3
        fbR(3) = vx1R*bx3R-vx3R*bx1
#endif

        dummy = rp1/(sR-sL)
        phi = sL*sR

        do iv=1,nvars
         flux(iv,idx) = dummy*(sR*fL(iv)-sL*fR(iv)+phi*(UR(iv)-UL(iv)))
        end do
 
        do iv=1,sdims
         fluxb(iv,idx) = dummy*(sR*fbL(iv)-sL*fbR(iv)+phi*(UbR(iv)-UbL(iv)))
        end do

#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
        ru%pn(ru%dir)%val(idx) = dummy*(sR*ptL-sL*ptR)
#endif

      else

#endif

      pstar = (dsuR * rhoR * ptL - dsuL * rhoL * ptR  &
      - phi * rhoL * rhoR * dsuR * dsuL * (vx1L-vx1R)) * inv_temp1
 
      rhostarL = rhoL*dsuL/dsumL
      rhostarR = rhoR*dsuR/dsumR

      a1_inv  = rp1 / (rhoL*dsuL*dsumL - bx1_2)
      vx2starL = vx2L - bx1 * bx2L * (ustar - vx1L) * a1_inv
      bx2starL = bx2L * (rhoL * dsuL*dsuL - bx1_2) * a1_inv

      vx3starL = vx3L - bx1 * bx3L * (ustar - vx1L) * a1_inv
      bx3starL = bx3L * (rhoL * dsuL*dsuL - bx1_2) * a1_inv

      a2_inv  = rp1 / (rhoR * dsuR * dsumR - bx1_2)

      vx2starR = vx2R - bx1 * bx2R * (ustar - vx1R) * a2_inv
      bx2starR = bx2R * (rhoR * dsuR*dsuR - bx1_2) * a2_inv

      vx3starR = vx3R - bx1 * bx3R * (ustar - vx1R) * a2_inv
      bx3starR = bx3R * (rhoR * dsuR*dsuR - bx1_2) * a2_inv

      vdotbL = vx1L*bx1+vx2L*bx2L+vx3L*bx3L
      vdotbR = vx1R*bx1+vx2R*bx2R+vx3R*bx3R

      vdotbstarL = ustar * bx1 + vx2starL * bx2starL + vx3starL * bx3starL
      vdotbstarR = ustar * bx1 + vx2starR * bx2starR + vx3starR * bx3starR

      rhoestarL = ( &
      dsuL * rhoeL &
      - ptL * vx1L &
      + pstar * ustar &
      + bx1 * (vdotbL - vdotbstarL) &
      ) / dsumL

      rhoestarR = ( &
      dsuR * rhoeR &
      - ptR * vx1R &
      + pstar * ustar &
      + bx1 * (vdotbR - vdotbstarR) &
      ) / dsumR

      sqrt_rhostarL = sqrt(rhostarL)
      sqrt_rhostarR = sqrt(rhostarR)

      abs_bx1 = abs(bx1)

      sstarL = ustar - abs_bx1 / sqrt_rhostarL
      sstarR = ustar + abs_bx1 / sqrt_rhostarR

      inv_sqr_bar = rp1 / (sqrt_rhostarL + sqrt_rhostarR)

      sgn = sign(rp1,bx1)

      vx22star = ( &
      sqrt_rhostarL * vx2starL + sqrt_rhostarR * vx2starR + (bx2starR - bx2starL) * sgn &
      ) * inv_sqr_bar

      bx22star = ( &
      sqrt_rhostarL * bx2starR &
      + sqrt_rhostarR * bx2starL &
      + sqrt_rhostarL * sqrt_rhostarR * (vx2starR - vx2starL) * sgn &
      ) * inv_sqr_bar

      vx32star = ( &
      sqrt_rhostarL * vx3starL + sqrt_rhostarR * vx3starR + (bx3starR - bx3starL) * sgn &
      ) * inv_sqr_bar

      bx32star = ( &
      sqrt_rhostarL * bx3starR &
      + sqrt_rhostarR * bx3starL &
      + sqrt_rhostarL * sqrt_rhostarR * (vx3starR - vx3starL) * sgn &
      ) * inv_sqr_bar

      vdotb2star = ustar * bx1 + vx22star * bx22star + vx32star * bx32star
      rhoe2starL = rhoestarL - sqrt_rhostarL * (vdotbstarL - vdotb2star) * sgn
      rhoe2starR = rhoestarR + sqrt_rhostarR * (vdotbstarR - vdotb2star) * sgn

#ifdef LHLLD_FLUX

#ifdef FLUX_IS_ALL_MACH

      if(sL>rp0) then
        rho  = rhoL
        vx1  = vx1L
        vx2  = vx2L
        vx3  = vx3L
        rhoe = rhoeL
        bx2  = bx2L
        bx3  = bx3L 
        pres = ptL
      else if(sstarL>rp0) then
        rho  = rhostarL
        vx1  = ustar
        vx2  = vx2starL
        vx3  = vx3starL
        rhoe = rhoestarL
        bx2  = bx2starL
        bx3  = bx3starL
        pres = pstar
      else if(ustar>rp0) then
        rho  = rhostarL
        vx1  = ustar
        vx2  = vx22star
        vx3  = vx32star
        rhoe = rhoe2starL
        bx2  = bx22star
        bx3  = bx32star
        pres = pstar
      else if(sstarR>rp0) then
        rho  = rhostarR
        vx1  = ustar
        vx2  = vx22star
        vx3  = vx32star
        rhoe = rhoe2starR
        bx2  = bx22star
        bx3  = bx32star
        pres = pstar
      else if(sR>rp0) then
        rho  = rhostarR
        vx1  = ustar
        vx2  = vx2starR
        vx3  = vx3starR
        rhoe = rhoestarR
        bx2  = bx2starR
        bx3  = bx3starR         
        pres = pstar
      else
        rho  = rhoR
        vx1  = vx1R
        vx2  = vx2R
        vx3  = vx3R
        rhoe = rhoeR
        bx2  = bx2R
        bx3  = bx3R 
        pres = ptR        
      end if

      flux(i_rho,idx) = rho*vx1
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
      flux(i_rhovx1,idx) = rho*vx1*vx1-bx1_2
      ru%pn(ru%dir)%val(idx) = pres
#else
      flux(i_rhovx1,idx) = rho*vx1*vx1+pres-bx1_2
#endif
      flux(i_rhovx2,idx) = rho*vx1*vx2-bx1*bx2
#if sdims_make==3
      flux(i_rhovx3,idx) = rho*vx1*vx3-bx1*bx3
#endif
      flux(i_rhoe,idx) = (rhoe+pres)*vx1-bx1*(bx1*vx1+vx2*bx2+vx3*bx3)

#if nas_make>0
      sgn = sign(rp1,vx1)
      half_one_plus_sign = rph*(rp1+sgn)
      half_one_minus_sign = rph*(rp1-sgn)
   
      do iv=i_as1,i_asl
        flux(iv,idx) = rho*vx1*(half_one_plus_sign*qL(iv,idx)+half_one_minus_sign*qR(iv,idx))
      end do
#endif
      
      fluxb(1,idx) = rp0
      fluxb(2,idx) = vx1*bx2-bx1*vx2
#if sdims_make==3
      fluxb(3,idx) = vx1*bx3-bx1*vx3
#endif

#else

      if(sstarL>rp0) then
        rho  = rhostarL
        vx1  = ustar
        vx2  = vx2starL
        vx3  = vx3starL
        rhoe = rhoestarL
        bx2  = bx2starL
        bx3  = bx3starL
        pres = pstar
      else if(ustar>rp0) then
        rho  = rhostarL
        vx1  = ustar
        vx2  = vx22star
        vx3  = vx32star
        rhoe = rhoe2starL
        bx2  = bx22star
        bx3  = bx32star
        pres = pstar
      else if(sstarR>rp0) then
        rho  = rhostarR
        vx1  = ustar
        vx2  = vx22star
        vx3  = vx32star
        rhoe = rhoe2starR
        bx2  = bx22star
        bx3  = bx32star
        pres = pstar
      else
        rho  = rhostarR
        vx1  = ustar
        vx2  = vx2starR
        vx3  = vx3starR
        rhoe = rhoestarR
        bx2  = bx2starR
        bx3  = bx3starR         
        pres = pstar
      end if

      flux(i_rho,idx) = rho*vx1
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
      flux(i_rhovx1,idx) = rho*vx1*vx1-bx1_2
      ru%pn(ru%dir)%val(idx) = pres
#else
      flux(i_rhovx1,idx) = rho*vx1*vx1+pres-bx1_2
#endif
      flux(i_rhovx2,idx) = rho*vx1*vx2-bx1*bx2
#if sdims_make==3
      flux(i_rhovx3,idx) = rho*vx1*vx3-bx1*bx3
#endif
      flux(i_rhoe,idx) = (rhoe+pres)*vx1-bx1*(bx1*vx1+vx2*bx2+vx3*bx3)

#if nas_make>0
      sgn = sign(rp1,vx1)
      half_one_plus_sign = rph*(rp1+sgn)
      half_one_minus_sign = rph*(rp1-sgn)
   
      do iv=i_as1,i_asl
        flux(iv,idx) = rho*vx1*(half_one_plus_sign*qL(iv,idx)+half_one_minus_sign*qR(iv,idx))
      end do
#endif
      
      fluxb(1,idx) = rp0
      fluxb(2,idx) = vx1*bx2-bx1*vx2
#if sdims_make==3
      fluxb(3,idx) = vx1*bx3-bx1*vx3
#endif

#endif

#endif

#ifdef HLLD_FLUX

      if(ustar>rp0) then

       U(i_rho) = rhoL
       U(i_rhovx1) = rhoL*vx1L
       U(i_rhovx2) = rhoL*vx2L
#if sdims_make==3
       U(i_rhovx3) = rhoL*vx3L
#endif
       U(i_rhoe) = rhoeL

#if nas_make>0
       do iv=i_as1,i_asl
         U(iv) = rhoL*qL(iv,idx)
       end do
#endif
      
       Ub(1) = bx1 
       Ub(2) = bx2L
#if sdims_make==3
       Ub(3) = bx3L
#endif

       f(i_rho) = rhoL*vx1L
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
       f(i_rhovx1) = rhoL*vx1L*vx1L-bx1_2
       ru%pn(ru%dir)%val(idx) = ptL
#else
       f(i_rhovx1) = rhoL*vx1L*vx1L+ptL-bx1_2
#endif
       f(i_rhovx2) = rhoL*vx1L*vx2L-bx1*bx2L
#if sdims_make==3
       f(i_rhovx3) = rhoL*vx1L*vx3L-bx1*bx3L
#endif
       f(i_rhoe) = (rhoeL+ptL)*vx1L-bx1*vdotbL

#if nas_make>0
       do iv=i_as1,i_asl
        f(iv) = rhoL*vx1L*qL(iv,idx)
       end do
#endif

       fb(1) = rp0
       fb(2) = vx1L*bx2L-bx1*vx2L
#if sdims_make==3
       fb(3) = vx1L*bx3L-bx1*vx3L
#endif
       
       if(sL>rp0) then

        do iv=1,nvars
         flux(iv,idx) = f(iv)
        end do 

        do iv=1,sdims
         fluxb(iv,idx) = fb(iv)
        end do 

       else if(sstarL>rp0) then

        Us(i_rho) = rhostarL
        Us(i_rhovx1) = rhostarL*ustar
        Us(i_rhovx2) = rhostarL*vx2starL
#if sdims_make==3        
        Us(i_rhovx3) = rhostarL*vx3starL
#endif
        Us(i_rhoe) = rhoestarL
#if nas_make>0
        do iv=i_as1,i_asl
          Us(iv) = rhostarL*qL(iv,idx)
        end do
#endif
        
        Ubs(1) = bx1
        Ubs(2) = bx2starL
#if sdims_make==3
        Ubs(3) = bx3starL
#endif

        do iv=1,nvars
         flux(iv,idx) = f(iv) + sL*(Us(iv)-U(iv))
        end do 

        do iv=1,sdims
         fluxb(iv,idx) = fb(iv) + sL*(Ubs(iv)-Ub(iv))
        end do

       else

        Us(i_rho) = rhostarL
        Us(i_rhovx1) = rhostarL*ustar
        Us(i_rhovx2) = rhostarL*vx2starL
#if sdims_make==3        
        Us(i_rhovx3) = rhostarL*vx3starL
#endif
        Us(i_rhoe) = rhoestarL
#if nas_make>0
        do iv=i_as1,i_asl
          Us(iv) = rhostarL*qL(iv,idx)
        end do
#endif
        
        Ubs(1) = bx1
        Ubs(2) = bx2starL
#if sdims_make==3
        Ubs(3) = bx3starL
#endif

        Uss(i_rho) = rhostarL
        Uss(i_rhovx1) = rhostarL*ustar
        Uss(i_rhovx2) = rhostarL*vx22star
#if sdims_make==3        
        Uss(i_rhovx3) = rhostarL*vx32star
#endif
        Uss(i_rhoe) = rhoe2starL
#if nas_make>0
        do iv=i_as1,i_asl
          Uss(iv) = rhostarL*qL(iv,idx)
        end do
#endif
        
        Ubss(1) = bx1
        Ubss(2) = bx22star
#if sdims_make==3
        Ubss(3) = bx32star
#endif

        do iv=1,nvars
         dummy = Us(iv)
         flux(iv,idx) = f(iv) + sL*(dummy-U(iv)) + sstarL*(Uss(iv)-dummy)
        end do 

        do iv=1,sdims
         dummy = Ubs(iv)
         fluxb(iv,idx) = fb(iv) + sL*(dummy-Ub(iv)) + sstarL*(Ubss(iv)-dummy)
        end do

       endif

      else

       U(i_rho) = rhoR
       U(i_rhovx1) = rhoR*vx1R
       U(i_rhovx2) = rhoR*vx2R
#if sdims_make==3
       U(i_rhovx3) = rhoR*vx3R
#endif
       U(i_rhoe) = rhoeR

#if nas_make>0
       do iv=i_as1,i_asl
         U(iv) = rhoR*qR(iv,idx)
       end do
#endif
      
       Ub(1) = bx1 
       Ub(2) = bx2R
#if sdims_make==3
       Ub(3) = bx3R
#endif

       f(i_rho) = rhoR*vx1R
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
       f(i_rhovx1) = rhoR*vx1R*vx1R-bx1_2
       ru%pn(ru%dir)%val(idx) = ptR
#else
       f(i_rhovx1) = rhoR*vx1R*vx1R+ptR-bx1_2
#endif
       f(i_rhovx2) = rhoR*vx1R*vx2R-bx1*bx2R
#if sdims_make==3
       f(i_rhovx3) = rhoR*vx1R*vx3R-bx1*bx3R
#endif
       f(i_rhoe) = (rhoeR+ptR)*vx1R-bx1*vdotbR

#if nas_make>0
       do iv=i_as1,i_asl
        f(iv) = rhoR*vx1R*qR(iv,idx)
       end do
#endif

       fb(1) = rp0
       fb(2) = vx1R*bx2R-bx1*vx2R
#if sdims_make==3
       fb(3) = vx1R*bx3R-bx1*vx3R
#endif
       
       if(sR<rp0) then

        do iv=1,nvars
         flux(iv,idx) = f(iv)
        end do 

        do iv=1,sdims
         fluxb(iv,idx) = fb(iv)
        end do 

       else if(sstarR<rp0) then

        Us(i_rho) = rhostarR
        Us(i_rhovx1) = rhostarR*ustar
        Us(i_rhovx2) = rhostarR*vx2starR
#if sdims_make==3        
        Us(i_rhovx3) = rhostarR*vx3starR
#endif
        Us(i_rhoe) = rhoestarR
#if nas_make>0
        do iv=i_as1,i_asl
          Us(iv) = rhostarR*qR(iv,idx)
        end do
#endif
        
        Ubs(1) = bx1
        Ubs(2) = bx2starR
#if sdims_make==3
        Ubs(3) = bx3starR
#endif

        do iv=1,nvars
         flux(iv,idx) = f(iv) + sR*(Us(iv)-U(iv))
        end do 

        do iv=1,sdims
         fluxb(iv,idx) = fb(iv) + sR*(Ubs(iv)-Ub(iv))
        end do

       else

        Us(i_rho) = rhostarR
        Us(i_rhovx1) = rhostarR*ustar
        Us(i_rhovx2) = rhostarR*vx2starR
#if sdims_make==3        
        Us(i_rhovx3) = rhostarR*vx3starR
#endif
        Us(i_rhoe) = rhoestarR
#if nas_make>0
        do iv=i_as1,i_asl
          Us(iv) = rhostarR*qR(iv,idx)
        end do
#endif
        
        Ubs(1) = bx1
        Ubs(2) = bx2starR
#if sdims_make==3
        Ubs(3) = bx3starR
#endif

        Uss(i_rho) = rhostarR
        Uss(i_rhovx1) = rhostarR*ustar
        Uss(i_rhovx2) = rhostarR*vx22star
#if sdims_make==3        
        Uss(i_rhovx3) = rhostarR*vx32star
#endif
        Uss(i_rhoe) = rhoe2starR
#if nas_make>0
        do iv=i_as1,i_asl
          Uss(iv) = rhostarR*qR(iv,idx)
        end do
#endif
        
        Ubss(1) = bx1
        Ubss(2) = bx22star
#if sdims_make==3
        Ubss(3) = bx32star
#endif

        do iv=1,nvars
         dummy = Us(iv)
         flux(iv,idx) = f(iv) + sR*(dummy-U(iv)) + sstarR*(Uss(iv)-dummy)
        end do 

        do iv=1,sdims
         dummy = Ubs(iv)
         fluxb(iv,idx) = fb(iv) + sR*(dummy-Ub(iv)) + sstarR*(Ubss(iv)-dummy)
        end do

       endif

      endif

#endif

#ifdef USE_SHOCK_FLATTENING
     end if
#endif

   end do

 end subroutine riemann

#endif

#else

#if defined(HLLC_FLUX) || defined(LHLLC_FLUX)

#ifdef GEOMETRY_CUBED_SPHERE

 subroutine riemann(il,iu,qL,qR,flux,ru)
   integer, intent(in) :: il,iu
   real(kind=rp), intent(in), dimension(1:nvars,il:iu) :: qL,qR
   real(kind=rp), intent(inout), dimension(1:nvars,il:iu) :: flux
   type(r_utils), intent(inout) :: ru

   integer :: idx, iv
   real(kind=rp) :: rhoL,vx1L,vx2L,vx3L,pL,rhoR,vx1R,vx2R,vx3R,pR,rhoeL,rhoeR,cL,cR
   real(kind=rp) :: max_c,sL,sR,dsuL,dsuR,ustar, &
   rhostarL,rhostarR,rhoestarL,rhoestarR,v2L,v2R,inv_rhoL,inv_rhoR, &
   T,eint,inv_mu,T2,T3,T4,inv_abar,dummy,vnL,vnR,nn1,nn2,nn3

   real(kind=rp) :: dp_drho,dp_deps,phi

#ifdef LHLLC_FLUX
   real(kind=rp) :: rhobar,cbar,pstar,sgn,rhostar, &
   half_one_plus_sign,half_one_minus_sign,machL,machR,chi
#endif

#ifdef HLLC_FLUX
   real(kind=rp), dimension(1:nvars) :: U,Us,f
#endif

   real(kind=rp) :: ye,abar,zbar

#ifdef USE_PRAD
#ifndef USE_FASTEOS
   real(kind=rp) :: tmp,tmp1,tmp2,Res0,Res_prad,dRes_dT
   integer :: iter
#endif
#endif

   real(kind=rp) :: gm,igmm1,mu,gmm1

#ifdef HLLC_FLUX
   do iv=1,nvars
    U(iv) = rp0
    Us(iv) = rp0
    f(iv) = rp0
   end do
#endif

   phi = rp0

   gm = ru%gm
   mu = ru%mu

   gmm1 = gm-rp1
   igmm1 = rp1/gmm1

   inv_mu = rp1/mu
   T = rp0
   T2 = rp0
   T3 = rp0
   T4 = rp0
   dp_deps = rp0
   dp_drho = rp0
   inv_abar = rp0

   iv = 0

   abar = rp0
   ye = rp0
   zbar = rp0
   dummy = rp0

   do idx=il,iu

      rhoL = qL(i_rho,idx)
      inv_rhoL = rp1/rhoL
      vx1L = qL(i_vx1,idx)
      vx2L = qL(i_vx2,idx)
#if sdims_make==3
      vx3L = qL(i_vx3,idx)
#else
      vx3L = rp0
#endif
      v2L = vx1L*vx1L+vx2L*vx2L+vx3L*vx3L

#ifdef USE_PRAD
#ifdef ADVECT_YE_IABAR
      ye = qL(i_ye,idx)
      abar = rp1/qL(i_iabar,idx)
      inv_mu = (ye*abar + rp1)/abar
#endif 
#ifdef ADVECT_SPECIES
      inv_mu = rp0
      do iv=1,nspecies
        inv_mu = inv_mu + qL(i_as1+iv-1,idx)*(ru%Z(iv)+rp1)/ru%A(iv)
      end do
#endif
#endif

#ifndef USE_FASTEOS
#ifdef HELMHOLTZ_EOS
#ifdef ADVECT_YE_IABAR
      ye = qL(i_ye,idx)
      abar = rp1/qL(i_iabar,idx)
#endif 
#ifdef ADVECT_SPECIES
      inv_abar = rp0
      ye = rp0
      do iv=1,nspecies
        dummy = qL(i_as1+iv-1,idx)/ru%A(iv)
        inv_abar = inv_abar + dummy
        ye = ye + dummy*ru%Z(iv)
      end do
      abar = rp1/inv_abar
#endif
      zbar = ye*abar
#endif
#endif

      pL = qL(i_p,idx)

#ifdef USE_PRAD
#ifdef USE_FASTEOS
      eint = pL/(ru%gammafL(ru%dir)%val(i_gammae,idx)-rp1)
      cL = sqrt(ru%gammafL(ru%dir)%val(i_gammac,idx)*pL*inv_rhoL)
#else
      tmp = rhoL*CONST_RGAS*inv_mu
      T = ru%guess_temp(ru%dir)%val(idx)
      Res_prad = -rp1
      do iter=1,250
        T2 = T*T
        T3 = T2*T
        T4 = T3*T
        Res0 = Res_prad
        Res_prad = CONST_RAD*othird*T4 + tmp*T - pL
        if (abs(Res_prad/pL) < em14) exit
        if ((abs(Res0 - Res_prad)/abs(Res0) < em15) .and. iter>1) then
          write(*,*) 'Riemann solver, EoS gas+radiation, RN stalled'
          exit
        end if
        dRes_dT = fthirds*CONST_RAD*T3 + tmp
        T = T - Res_prad/dRes_dT
      end do
      T2 = T*T
      T3 = T2*T
      T4 = T3*T

      mu = rp1/inv_mu

      eint = tmp*T*igmm1 + CONST_RAD*T4
      
      tmp1 = CONST_RAD*mu*T3
      tmp2 = CONST_RGAS*rhoL

      dp_drho = fthirds * &
      CONST_RAD*CONST_RGAS*T4*(rp3*gm-rp4) / &
      (rp4*tmp1*gmm1+tmp2)

      dp_deps = gmm1 * &
      (rp4*tmp1+rp3*tmp2) / &
      (rp12*tmp1*gmm1+rp3*tmp2)

      cL = sqrt(dp_drho+dp_deps*(pL+eint)*inv_rhoL)
#endif
#elif defined(HELMHOLTZ_EOS)
#ifdef USE_FASTEOS
      eint = pL/(ru%gammafL(ru%dir)%val(i_gammae,idx)-rp1)
      cL = sqrt(ru%gammafL(ru%dir)%val(i_gammac,idx)*pL*inv_rhoL)
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      call helm_rhoP_given(rhoL,pL,abar,zbar,T,eint,cL,.true.)
      eint = eint*rhoL
#endif
#elif defined(PIG_EOS)
#ifdef USE_FASTEOS
      eint = pL/(ru%gammafL(ru%dir)%val(i_gammae,idx)-rp1)
      cL = sqrt(ru%gammafL(ru%dir)%val(i_gammac,idx)*pL*inv_rhoL)
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      call pig_rhoP_given(rhoL,pL,T,eint,cL,.true.)
      eint = eint*rhoL
#endif
#else
      eint = igmm1*pL
      cL = sqrt(gm*pL*inv_rhoL)
#endif

      rhoeL = eint + rph*rhoL*v2L

      rhoR = qR(i_rho,idx)
      inv_rhoR = rp1/rhoR
      vx1R = qR(i_vx1,idx)
      vx2R = qR(i_vx2,idx)
#if sdims_make==3
      vx3R = qR(i_vx3,idx)
#else
      vx3R = rp0
#endif
      v2R = vx1R*vx1R+vx2R*vx2R+vx3R*vx3R

#ifdef USE_PRAD
#ifdef ADVECT_YE_IABAR
      ye = qR(i_ye,idx)
      abar = rp1/qR(i_iabar,idx)
      inv_mu = (ye*abar + rp1)/abar
#endif 
#ifdef ADVECT_SPECIES
      inv_mu = rp0
      do iv=1,nspecies
        inv_mu = inv_mu + qR(i_as1+iv-1,idx)*(ru%Z(iv)+rp1)/ru%A(iv)
      end do
#endif
#endif

#ifndef USE_FASTEOS
#ifdef HELMHOLTZ_EOS
#ifdef ADVECT_YE_IABAR
      ye = qR(i_ye,idx)
      abar = rp1/qR(i_iabar,idx)
#endif
#ifdef ADVECT_SPECIES
      inv_abar = rp0
      ye = rp0
      do iv=1,nspecies
        dummy = qR(i_as1+iv-1,idx)/ru%A(iv)
        inv_abar = inv_abar + dummy
        ye = ye + dummy*ru%Z(iv)
      end do
      abar = rp1/inv_abar
#endif
      zbar = ye*abar
#endif
#endif

      pR = qR(i_p,idx)

#ifdef USE_PRAD
#ifdef USE_FASTEOS
      eint = pR/(ru%gammafR(ru%dir)%val(i_gammae,idx)-rp1)
      cR = sqrt(ru%gammafR(ru%dir)%val(i_gammac,idx)*pR*inv_rhoR)
#else
      tmp = rhoR*CONST_RGAS*inv_mu
      T = ru%guess_temp(ru%dir)%val(idx)
      Res_prad = -rp1
      do iter=1,250
        T2 = T*T
        T3 = T2*T
        T4 = T3*T
        Res0 = Res_prad
        Res_prad = CONST_RAD*othird*T4 + tmp*T - pR
        if (abs(Res_prad/pR) < em14) exit
        if ((abs(Res0 - Res_prad)/abs(Res0) < em15) .and. iter>1) then
          write(*,*) 'Riemann solver, EoS gas+radiation, RN stalled'
          exit
        end if
        dRes_dT = fthirds*CONST_RAD*T3 + tmp
        T = T - Res_prad/dRes_dT
      end do
      T2 = T*T
      T3 = T2*T
      T4 = T3*T

      mu = rp1/inv_mu

      eint = tmp*T*igmm1 + CONST_RAD*T4

      tmp1 = CONST_RAD*mu*T3
      tmp2 = CONST_RGAS*rhoR

      dp_drho = fthirds * &
      CONST_RAD*CONST_RGAS*T4*(rp3*gm-rp4) / &
      (rp4*tmp1*gmm1+tmp2)

      dp_deps = gmm1 * &
      (rp4*tmp1+rp3*tmp2) / &
      (rp12*tmp1*gmm1+rp3*tmp2)

      cR = sqrt(dp_drho+dp_deps*(pR+eint)*inv_rhoR)
#endif
#elif defined(HELMHOLTZ_EOS)
#ifdef USE_FASTEOS
      eint = pR/(ru%gammafR(ru%dir)%val(i_gammae,idx)-rp1)
      cR = sqrt(ru%gammafR(ru%dir)%val(i_gammac,idx)*pR*inv_rhoR)
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      call helm_rhoP_given(rhoR,pR,abar,zbar,T,eint,cR,.true.)
      eint = eint*rhoR
#endif
#elif defined(PIG_EOS)
#ifdef USE_FASTEOS
      eint = pR/(ru%gammafR(ru%dir)%val(i_gammae,idx)-rp1)
      cR = sqrt(ru%gammafR(ru%dir)%val(i_gammac,idx)*pR*inv_rhoR)
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      call pig_rhoP_given(rhoR,pR,T,eint,cR,.true.)
      eint = eint*rhoR
#endif
#else
      eint = igmm1*pR
      cR = sqrt(gm*pR*inv_rhoR)
#endif

      rhoeR = eint + rph*rhoR*v2R

      max_c = max(cL,cR)

      nn1 = ru%nn(ru%dir)%val(1,idx)
      nn2 = ru%nn(ru%dir)%val(2,idx)

#if sdims_make==3
      nn3 = ru%nn(ru%dir)%val(3,idx)
#else
      nn3 = rp0
#endif

      vnL = vx1L*nn1+vx2L*nn2+vx3L*nn3
      vnR = vx1R*nn1+vx2R*nn2+vx3R*nn3

      sL = min(vnL,vnR) - max_c
      sR = max(vnL,vnR) + max_c

      dsuL = sL-vnL
      dsuR = sR-vnR

      ustar = (pR-pL+rhoL*vnL*dsuL-rhoR*vnR*dsuR) / (rhoL*dsuL-rhoR*dsuR)

      rhostarL = rhoL*(dsuL/(sL-ustar))
      rhoestarL = rhostarL*(rhoeL*inv_rhoL+(ustar-vnL)*(ustar+pL*inv_rhoL/dsuL)) 

      rhostarR = rhoR*(dsuR/(sR-ustar))
      rhoestarR = rhostarR*(rhoeR*inv_rhoR+(ustar-vnR)*(ustar+pR*inv_rhoR/dsuR)) 
 
#ifdef LHLLC_FLUX

      machL = sqrt(v2L)/cL
      machR = sqrt(v2R)/cR
     
      max_c = max(machL,machR)
 
      if(max_c<0.6_rp) then
       chi = min(rp1,max(machL,machR))
       chi = max(Mach_cutoff,chi)
       phi = chi*(rp2-chi)
      else
       phi = rp1
      endif

      rhobar = rph*(rhoL+rhoR)
      cbar = rph*(cL+cR)

      pstar = rph*(pL+pR)-rph*phi*rhobar*cbar*(vnR-vnL)

      sgn = sign(rp1,ustar)

      half_one_plus_sign = rph*(rp1+sgn)
      half_one_minus_sign = rph*(rp1-sgn)

      rhostar = half_one_plus_sign*rhostarL+half_one_minus_sign*rhostarR

#ifdef FLUX_IS_ALL_MACH

      if(sL>rp0) then
 
       flux(i_rho,idx) = rhoL*vnL
       flux(i_rhovx1,idx) = rhoL*vnL*vx1L + pL*nn1
       flux(i_rhovx2,idx) = rhoL*vnL*vx2L + pL*nn2
#if sdims_make==3
       flux(i_rhovx3,idx) = rhoL*vnL*vx3L + pL*nn3
#endif
       flux(i_rhoe,idx) = (rhoeL+pL)*vnL

#if nas_make>0
       do iv=i_as1,i_asl
         flux(iv,idx) = rhoL*qL(iv,idx)*vnL
       end do
#endif
      
      else if(sR<rp0) then

       flux(i_rho,idx) = rhoR*vnR
       flux(i_rhovx1,idx) = rhoR*vnR*vx1R + pR*nn1
       flux(i_rhovx2,idx) = rhoR*vnR*vx2R + pR*nn2
#if sdims_make==3 
       flux(i_rhovx3,idx) = rhoR*vnR*vx3R + pR*nn3
#endif
       flux(i_rhoe,idx) = (rhoeR+pR)*vnR

#if nas_make>0
       do iv=i_as1,i_asl
         flux(iv,idx) = rhoR*qR(iv,idx)*vnR
       end do
#endif

      else

       flux(i_rho,idx) = rhostar*ustar

       flux(i_rhovx1,idx) = rhostar*ustar*( nn1*ustar + &
       half_one_plus_sign*(vx1L-nn1*vnL) + &
       half_one_minus_sign*(vx1R-nn1*vnR) ) + &
       pstar*nn1

       flux(i_rhovx2,idx) = rhostar*ustar*( nn2*ustar + &
       half_one_plus_sign*(vx2L-nn2*vnL) + &
       half_one_minus_sign*(vx2R-nn2*vnR) ) + &
       pstar*nn2

#if sdims_make==3
       flux(i_rhovx3,idx) = rhostar*ustar*( nn3*ustar + &
       half_one_plus_sign*(vx3L-nn3*vnL) + &
       half_one_minus_sign*(vx3R-nn3*vnR) ) + &
       pstar*nn3
#endif

       flux(i_rhoe,idx) = (half_one_plus_sign*rhoestarL+half_one_minus_sign*rhoestarR+pstar)*ustar

#if nas_make>0
       do iv=i_as1,i_asl
         flux(iv,idx) = rhostar*ustar*(half_one_plus_sign*qL(iv,idx)+half_one_minus_sign*qR(iv,idx))
       end do
#endif

      end if

#else

      flux(i_rho,idx) = rhostar*ustar

      flux(i_rhovx1,idx) = rhostar*ustar*( nn1*ustar + &
      half_one_plus_sign*(vx1L-nn1*vnL) + &
      half_one_minus_sign*(vx1R-nn1*vnR) ) + &
      pstar*nn1

      flux(i_rhovx2,idx) = rhostar*ustar*( nn2*ustar + &
      half_one_plus_sign*(vx2L-nn2*vnL) + &
      half_one_minus_sign*(vx2R-nn2*vnR) ) + &
      pstar*nn2

#if sdims_make==3
      flux(i_rhovx3,idx) = rhostar*ustar*( nn3*ustar + &
      half_one_plus_sign*(vx3L-nn3*vnL) + &
      half_one_minus_sign*(vx3R-nn3*vnR) ) + &
      pstar*nn3
#endif

      flux(i_rhoe,idx) = (half_one_plus_sign*rhoestarL+half_one_minus_sign*rhoestarR+pstar)*ustar

#if nas_make>0
      do iv=i_as1,i_asl
        flux(iv,idx) = rhostar*ustar*(half_one_plus_sign*qL(iv,idx)+half_one_minus_sign*qR(iv,idx))
      end do
#endif

#endif

#endif

#ifdef HLLC_FLUX

      if(ustar>rp0) then

        U(i_rho) = rhoL
        U(i_rhovx1) = rhoL*vx1L
        U(i_rhovx2) = rhoL*vx2L
#if sdims_make==3
        U(i_rhovx3) = rhoL*vx3L
#endif
        U(i_rhoe) = rhoeL

#if nas_make>0
        do iv=i_as1,i_asl
          U(iv) = rhoL*qL(iv,idx)
        end do
#endif

        f(i_rho) = rhoL*vnL
        f(i_rhovx1) = rhoL*vnL*vx1L+pL*nn1
        f(i_rhovx2) = rhoL*vnL*vx2L+pL*nn2
#if sdims_make==3
        f(i_rhovx3) = rhoL*vnL*vx3L+pL*nn3
#endif
        f(i_rhoe) = (rhoeL+pL)*vnL

#if nas_make>0
        do iv=i_as1,i_asl
          f(iv) = rhoL*vnL*qL(iv,idx)
        end do
#endif

        if(sL>=rp0) then

         do iv=1,nvars
          flux(iv,idx) = f(iv)
         end do 

        else

         Us(i_rho) = rhostarL
         Us(i_rhovx1) = rhostarL*(nn1*ustar+(vx1L-nn1*vnL))
         Us(i_rhovx2) = rhostarL*(nn2*ustar+(vx2L-nn2*vnL))
#if sdims_make==3        
         Us(i_rhovx3) = rhostarL*(nn3*ustar+(vx3L-nn3*vnL))
#endif
         Us(i_rhoe) = rhoestarL
#if nas_make>0
         do iv=i_as1,i_asl
           Us(iv) = rhostarL*qL(iv,idx)
         end do
#endif
        
         do iv=1,nvars
          flux(iv,idx) = f(iv) + sL*(Us(iv)-U(iv))
         end do 

        end if

      else

        U(i_rho) = rhoR
        U(i_rhovx1) = rhoR*vx1R
        U(i_rhovx2) = rhoR*vx2R
#if sdims_make==3
        U(i_rhovx3) = rhoR*vx3R
#endif
        U(i_rhoe) = rhoeR

#if nas_make>0
        do iv=i_as1,i_asl
          U(iv) = rhoR*qR(iv,idx)
        end do
#endif

        f(i_rho) = rhoR*vnR
        f(i_rhovx1) = rhoR*vnR*vx1R+pR*nn1
        f(i_rhovx2) = rhoR*vnR*vx2R+pR*nn2
#if sdims_make==3
        f(i_rhovx3) = rhoR*vnR*vx3R+pR*nn3
#endif
        f(i_rhoe) = (rhoeR+pR)*vnR

#if nas_make>0
        do iv=i_as1,i_asl
          f(iv) = rhoR*vnR*qR(iv,idx)
        end do
#endif

        if(sR<rp0) then

         do iv=1,nvars
          flux(iv,idx) = f(iv)
         end do 

        else
       
         Us(i_rho) = rhostarR
         Us(i_rhovx1) = rhostarR*(nn1*ustar+(vx1R-nn1*vnR))
         Us(i_rhovx2) = rhostarR*(nn2*ustar+(vx2R-nn2*vnR))
#if sdims_make==3        
         Us(i_rhovx3) = rhostarR*(nn3*ustar+(vx3R-nn3*vnR))
#endif
         Us(i_rhoe) = rhoestarR
#if nas_make>0
         do iv=i_as1,i_asl
           Us(iv) = rhostarR*qR(iv,idx)
         end do
#endif
        
         do iv=1,nvars
           flux(iv,idx) = f(iv) + sR*(Us(iv)-U(iv))
         end do 

        endif

     endif

#endif

   end do

 end subroutine riemann

#else

 subroutine riemann(il,iu,qL,qR,flux,ru)
   integer, intent(in) :: il,iu
   real(kind=rp), intent(in), dimension(1:nvars,il:iu) :: qL,qR
   real(kind=rp), intent(inout), dimension(1:nvars,il:iu) :: flux
   type(r_utils), intent(inout) :: ru

   integer :: idx, iv
   real(kind=rp) :: rhoL,vx1L,vx2L,vx3L,pL,rhoR,vx1R,vx2R,vx3R,pR,rhoeL,rhoeR,cL,cR
   real(kind=rp) :: max_c,sL,sR,dsuL,dsuR,ustar, &
   rhostarL,rhostarR,rhoestarL,rhoestarR,v2L,v2R,inv_rhoL,inv_rhoR, &
   T,eint,inv_mu,T2,T3,T4,inv_abar,dummy

   real(kind=rp) :: dp_drho,dp_deps,phi

#ifdef LHLLC_FLUX
   real(kind=rp) :: rhobar,cbar,pstar,sgn,rhostar, &
   half_one_plus_sign,half_one_minus_sign,machL,machR,chi
#endif

#ifdef HLLC_FLUX
   real(kind=rp), dimension(1:nvars) :: U,Us,f
#endif

#ifdef USE_SHOCK_FLATTENING
   real(kind=rp), dimension(1:nvars) :: UL,UR,fL,fR
#endif

   real(kind=rp) :: ye,abar,zbar

#ifdef USE_PRAD
#ifndef USE_FASTEOS
   real(kind=rp) :: tmp,tmp1,tmp2,Res0,Res_prad,dRes_dT
   integer :: iter
#endif
#endif

   real(kind=rp) :: gm,igmm1,mu,gmm1

#ifdef HLLC_FLUX
   do iv=1,nvars
    U(iv) = rp0
    Us(iv) = rp0
    f(iv) = rp0
   end do
#endif

   phi = rp0

   gm = ru%gm
   mu = ru%mu

   gmm1 = gm-rp1
   igmm1 = rp1/gmm1

   inv_mu = rp1/mu
   T = rp0
   T2 = rp0
   T3 = rp0
   T4 = rp0
   dp_deps = rp0
   dp_drho = rp0
   inv_abar = rp0

   iv = 0

   abar = rp0
   ye = rp0
   zbar = rp0
   dummy = rp0

   do idx=il,iu

      rhoL = qL(i_rho,idx)
      inv_rhoL = rp1/rhoL
      vx1L = qL(i_vx1,idx)
      vx2L = qL(i_vx2,idx)
#if sdims_make==3
      vx3L = qL(i_vx3,idx)
#else
      vx3L = rp0
#endif
      v2L = vx1L*vx1L+vx2L*vx2L+vx3L*vx3L

#ifdef USE_PRAD
#ifdef ADVECT_YE_IABAR
      ye = qL(i_ye,idx)
      abar = rp1/qL(i_iabar,idx)
      inv_mu = (ye*abar + rp1)/abar
#endif 
#ifdef ADVECT_SPECIES
      inv_mu = rp0
      do iv=1,nspecies
        inv_mu = inv_mu + qL(i_as1+iv-1,idx)*(ru%Z(iv)+rp1)/ru%A(iv)
      end do
#endif
#endif

#ifndef USE_FASTEOS
#ifdef HELMHOLTZ_EOS
#ifdef ADVECT_YE_IABAR
      ye = qL(i_ye,idx)
      abar = rp1/qL(i_iabar,idx)
#endif 
#ifdef ADVECT_SPECIES
      inv_abar = rp0
      ye = rp0
      do iv=1,nspecies
        dummy = qL(i_as1+iv-1,idx)/ru%A(iv)
        inv_abar = inv_abar + dummy
        ye = ye + dummy*ru%Z(iv)
      end do
      abar = rp1/inv_abar
#endif
      zbar = ye*abar
#endif
#endif

      pL = qL(i_p,idx)

#ifdef USE_PRAD
#ifdef USE_FASTEOS
      eint = pL/(ru%gammafL(ru%dir)%val(i_gammae,idx)-rp1)
      cL = sqrt(ru%gammafL(ru%dir)%val(i_gammac,idx)*pL*inv_rhoL)
#else
      tmp = rhoL*CONST_RGAS*inv_mu
      T = ru%guess_temp(ru%dir)%val(idx)
      Res_prad = -rp1
      do iter=1,250
        T2 = T*T
        T3 = T2*T
        T4 = T3*T
        Res0 = Res_prad
        Res_prad = CONST_RAD*othird*T4 + tmp*T - pL
        if (abs(Res_prad/pL) < em14) exit
        if ((abs(Res0 - Res_prad)/abs(Res0) < em15) .and. iter>1) then
          write(*,*) 'Riemann solver, EoS gas+radiation, RN stalled'
          exit
        end if
        dRes_dT = fthirds*CONST_RAD*T3 + tmp
        T = T - Res_prad/dRes_dT
      end do
      T2 = T*T
      T3 = T2*T
      T4 = T3*T

      mu = rp1/inv_mu

      eint = tmp*T*igmm1 + CONST_RAD*T4
      
      tmp1 = CONST_RAD*mu*T3
      tmp2 = CONST_RGAS*rhoL

      dp_drho = fthirds * &
      CONST_RAD*CONST_RGAS*T4*(rp3*gm-rp4) / &
      (rp4*tmp1*gmm1+tmp2)

      dp_deps = gmm1 * &
      (rp4*tmp1+rp3*tmp2) / &
      (rp12*tmp1*gmm1+rp3*tmp2)

      cL = sqrt(dp_drho+dp_deps*(pL+eint)*inv_rhoL)
#endif
#elif defined(HELMHOLTZ_EOS)
#ifdef USE_FASTEOS
      eint = pL/(ru%gammafL(ru%dir)%val(i_gammae,idx)-rp1)
      cL = sqrt(ru%gammafL(ru%dir)%val(i_gammac,idx)*pL*inv_rhoL)
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      call helm_rhoP_given(rhoL,pL,abar,zbar,T,eint,cL,.true.)
      eint = eint*rhoL
#endif
#elif defined(PIG_EOS)
#ifdef USE_FASTEOS
      eint = pL/(ru%gammafL(ru%dir)%val(i_gammae,idx)-rp1)
      cL = sqrt(ru%gammafL(ru%dir)%val(i_gammac,idx)*pL*inv_rhoL)
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      call pig_rhoP_given(rhoL,pL,T,eint,cL,.true.)
      eint = eint*rhoL
#endif
#else
      eint = igmm1*pL
      cL = sqrt(gm*pL*inv_rhoL)
#endif

      rhoeL = eint + rph*rhoL*v2L

      rhoR = qR(i_rho,idx)
      inv_rhoR = rp1/rhoR
      vx1R = qR(i_vx1,idx)
      vx2R = qR(i_vx2,idx)
#if sdims_make==3
      vx3R = qR(i_vx3,idx)
#else
      vx3R = rp0
#endif
      v2R = vx1R*vx1R+vx2R*vx2R+vx3R*vx3R

#ifdef USE_PRAD
#ifdef ADVECT_YE_IABAR
      ye = qR(i_ye,idx)
      abar = rp1/qR(i_iabar,idx)
      inv_mu = (ye*abar + rp1)/abar
#endif 
#ifdef ADVECT_SPECIES
      inv_mu = rp0
      do iv=1,nspecies
        inv_mu = inv_mu + qR(i_as1+iv-1,idx)*(ru%Z(iv)+rp1)/ru%A(iv)
      end do
#endif
#endif

#ifndef USE_FASTEOS
#ifdef HELMHOLTZ_EOS
#ifdef ADVECT_YE_IABAR
      ye = qR(i_ye,idx)
      abar = rp1/qR(i_iabar,idx)
#endif
#ifdef ADVECT_SPECIES
      inv_abar = rp0
      ye = rp0
      do iv=1,nspecies
        dummy = qR(i_as1+iv-1,idx)/ru%A(iv)
        inv_abar = inv_abar + dummy
        ye = ye + dummy*ru%Z(iv)
      end do
      abar = rp1/inv_abar
#endif
      zbar = ye*abar
#endif
#endif

      pR = qR(i_p,idx)

#ifdef USE_PRAD
#ifdef USE_FASTEOS
      eint = pR/(ru%gammafR(ru%dir)%val(i_gammae,idx)-rp1)
      cR = sqrt(ru%gammafR(ru%dir)%val(i_gammac,idx)*pR*inv_rhoR)
#else
      tmp = rhoR*CONST_RGAS*inv_mu
      T = ru%guess_temp(ru%dir)%val(idx)
      Res_prad = -rp1
      do iter=1,250
        T2 = T*T
        T3 = T2*T
        T4 = T3*T
        Res0 = Res_prad
        Res_prad = CONST_RAD*othird*T4 + tmp*T - pR
        if (abs(Res_prad/pR) < em14) exit
        if ((abs(Res0 - Res_prad)/abs(Res0) < em15) .and. iter>1) then
          write(*,*) 'Riemann solver, EoS gas+radiation, RN stalled'
          exit
        end if
        dRes_dT = fthirds*CONST_RAD*T3 + tmp
        T = T - Res_prad/dRes_dT
      end do
      T2 = T*T
      T3 = T2*T
      T4 = T3*T

      mu = rp1/inv_mu

      eint = tmp*T*igmm1 + CONST_RAD*T4

      tmp1 = CONST_RAD*mu*T3
      tmp2 = CONST_RGAS*rhoR

      dp_drho = fthirds * &
      CONST_RAD*CONST_RGAS*T4*(rp3*gm-rp4) / &
      (rp4*tmp1*gmm1+tmp2)

      dp_deps = gmm1 * &
      (rp4*tmp1+rp3*tmp2) / &
      (rp12*tmp1*gmm1+rp3*tmp2)

      cR = sqrt(dp_drho+dp_deps*(pR+eint)*inv_rhoR)
#endif
#elif defined(HELMHOLTZ_EOS)
#ifdef USE_FASTEOS
      eint = pR/(ru%gammafR(ru%dir)%val(i_gammae,idx)-rp1)
      cR = sqrt(ru%gammafR(ru%dir)%val(i_gammac,idx)*pR*inv_rhoR)
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      call helm_rhoP_given(rhoR,pR,abar,zbar,T,eint,cR,.true.)
      eint = eint*rhoR
#endif
#elif defined(PIG_EOS)
#ifdef USE_FASTEOS
      eint = pR/(ru%gammafR(ru%dir)%val(i_gammae,idx)-rp1)
      cR = sqrt(ru%gammafR(ru%dir)%val(i_gammac,idx)*pR*inv_rhoR)
#else
      T = ru%guess_temp(ru%dir)%val(idx)
      call pig_rhoP_given(rhoR,pR,T,eint,cR,.true.)
      eint = eint*rhoR
#endif
#else
      eint = igmm1*pR
      cR = sqrt(gm*pR*inv_rhoR)
#endif

      rhoeR = eint + rph*rhoR*v2R

      max_c = max(cL,cR)

      sL = min(vx1L,vx1R) - max_c
      sR = max(vx1L,vx1R) + max_c

      dsuL = sL-vx1L
      dsuR = sR-vx1R

      ustar = (pR-pL+rhoL*vx1L*dsuL-rhoR*vx1R*dsuR) / (rhoL*dsuL-rhoR*dsuR)

      rhostarL = rhoL*(dsuL/(sL-ustar))
      rhoestarL = rhostarL*(rhoeL*inv_rhoL+(ustar-vx1L)*(ustar+pL*inv_rhoL/dsuL)) 

      rhostarR = rhoR*(dsuR/(sR-ustar))
      rhoestarR = rhostarR*(rhoeR*inv_rhoR+(ustar-vx1R)*(ustar+pR*inv_rhoR/dsuR)) 
 
#ifdef USE_SHOCK_FLATTENING
      if(ru%is_flattened(ru%dir)%val(idx)==1) then

        sL = min(rp0,sL)
        sR = max(rp0,sR)
     
        UL(i_rho) = rhoL
        UL(i_rhovx1) = rhoL*vx1L
        UL(i_rhovx2) = rhoL*vx2L
#if sdims_make==3
        UL(i_rhovx3) = rhoL*vx3L
#endif
        UL(i_rhoe) = rhoeL
         
#if nas_make>0
        do iv=i_as1,nvars
         UL(iv) = rhoL*qL(iv,idx)
        end do
#endif

        UR(i_rho) = rhoR
        UR(i_rhovx1) = rhoR*vx1R
        UR(i_rhovx2) = rhoR*vx2R
#if sdims_make==3
        UR(i_rhovx3) = rhoR*vx3R
#endif
        UR(i_rhoe) = rhoeR
         
#if nas_make>0
        do iv=i_as1,nvars
         UR(iv) = rhoR*qR(iv,idx)
        end do
#endif

        fL(i_rho) = rhoL*vx1L
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
        fL(i_rhovx1) = rhoL*vx1L*vx1L
#else
        fL(i_rhovx1) = rhoL*vx1L*vx1L+pL
#endif
        fL(i_rhovx2) = rhoL*vx1L*vx2L
#if sdims_make==3        
        fL(i_rhovx3) = rhoL*vx1L*vx3L
#endif
        fL(i_rhoe) = (rhoeL+pL)*vx1L
#if nas_make>0
        do iv=i_as1,nvars
         fL(iv) = UL(iv)*vx1L
        end do
#endif
   
        fR(i_rho) = rhoR*vx1R
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
        fR(i_rhovx1) = rhoR*vx1R*vx1R
#else
        fR(i_rhovx1) = rhoR*vx1R*vx1R+pR
#endif
        fR(i_rhovx2) = rhoR*vx1R*vx2R
#if sdims_make==3        
        fR(i_rhovx3) = rhoR*vx1R*vx3R
#endif
        fR(i_rhoe) = (rhoeR+pR)*vx1R
#if nas_make>0
        do iv=i_as1,nvars
         fR(iv) = UR(iv)*vx1R
        end do
#endif
   
        dummy = rp1/(sR-sL)
        phi = sL*sR

        do iv=1,nvars
         flux(iv,idx) = dummy*(sR*fL(iv)-sL*fR(iv)+phi*(UR(iv)-UL(iv)))
        end do

#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
        ru%pn(ru%dir)%val(idx) = dummy*(sR*pL-sL*pR)
#endif

      else

#endif

#ifdef LHLLC_FLUX

      machL = sqrt(v2L)/cL
      machR = sqrt(v2R)/cR
      chi = min(rp1,max(machL,machR))
      chi = max(Mach_cutoff,chi)
      phi = chi*(rp2-chi)

      rhobar = rph*(rhoL+rhoR)
      cbar = rph*(cL+cR)

      pstar = rph*(pL+pR)-rph*phi*rhobar*cbar*(vx1R-vx1L)

      sgn = sign(rp1,ustar)

      half_one_plus_sign = rph*(rp1+sgn)
      half_one_minus_sign = rph*(rp1-sgn)

      rhostar = half_one_plus_sign*rhostarL+half_one_minus_sign*rhostarR

#ifdef FLUX_IS_ALL_MACH

      if(sL>rp0) then
 
       flux(i_rho,idx) = rhoL*vx1L
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
       flux(i_rhovx1,idx) = rhoL*vx1L*vx1L
       ru%pn(ru%dir)%val(idx) = pL
#else
       flux(i_rhovx1,idx) = rhoL*vx1L*vx1L + pL
#endif
       flux(i_rhovx2,idx) = rhoL*vx1L*vx2L
#if sdims_make==3
       flux(i_rhovx3,idx) = rhoL*vx1L*vx3L
#endif
       flux(i_rhoe,idx) = (rhoeL+pL)*vx1L

#if nas_make>0
       do iv=i_as1,i_asl
         flux(iv,idx) = rhoL*qL(iv,idx)*vx1L
       end do
#endif
      
      else if(sR<rp0) then

       flux(i_rho,idx) = rhoR*vx1R
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
       flux(i_rhovx1,idx) = rhoR*vx1R*vx1R
       ru%pn(ru%dir)%val(idx) = pR
#else
       flux(i_rhovx1,idx) = rhoR*vx1R*vx1R + pR
#endif
       flux(i_rhovx2,idx) = rhoR*vx1R*vx2R
#if sdims_make==3
       flux(i_rhovx3,idx) = rhoR*vx1R*vx3R
#endif
       flux(i_rhoe,idx) = (rhoeR+pR)*vx1R

#if nas_make>0
       do iv=i_as1,i_asl
         flux(iv,idx) = rhoR*qR(iv,idx)*vx1R
       end do
#endif

      else

       flux(i_rho,idx) = rhostar*ustar
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
       flux(i_rhovx1,idx) = rhostar*ustar*ustar
       ru%pn(ru%dir)%val(idx) = pstar
#else
       flux(i_rhovx1,idx) = rhostar*ustar*ustar + pstar
#endif
       flux(i_rhovx2,idx) = rhostar*ustar*(half_one_plus_sign*vx2L+half_one_minus_sign*vx2R)
#if sdims_make==3
       flux(i_rhovx3,idx) = rhostar*ustar*(half_one_plus_sign*vx3L+half_one_minus_sign*vx3R)
#endif
       flux(i_rhoe,idx) = (half_one_plus_sign*rhoestarL+half_one_minus_sign*rhoestarR+pstar)*ustar

#if nas_make>0
       do iv=i_as1,i_asl
         flux(iv,idx) = rhostar*ustar*(half_one_plus_sign*qL(iv,idx)+half_one_minus_sign*qR(iv,idx))
       end do
#endif

      end if

#else

      flux(i_rho,idx) = rhostar*ustar
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
      flux(i_rhovx1,idx) = rhostar*ustar*ustar
      ru%pn(ru%dir)%val(idx) = pstar
#else
      flux(i_rhovx1,idx) = rhostar*ustar*ustar + pstar
#endif
      flux(i_rhovx2,idx) = rhostar*ustar*(half_one_plus_sign*vx2L+half_one_minus_sign*vx2R)
#if sdims_make==3
      flux(i_rhovx3,idx) = rhostar*ustar*(half_one_plus_sign*vx3L+half_one_minus_sign*vx3R)
#endif
      flux(i_rhoe,idx) = (half_one_plus_sign*rhoestarL+half_one_minus_sign*rhoestarR+pstar)*ustar

#if nas_make>0
      do iv=i_as1,i_asl
        flux(iv,idx) = rhostar*ustar*(half_one_plus_sign*qL(iv,idx)+half_one_minus_sign*qR(iv,idx))
      end do
#endif

#endif

#endif

#ifdef HLLC_FLUX

      if(ustar>rp0) then

        U(i_rho) = rhoL
        U(i_rhovx1) = rhoL*vx1L
        U(i_rhovx2) = rhoL*vx2L
#if sdims_make==3
        U(i_rhovx3) = rhoL*vx3L
#endif
        U(i_rhoe) = rhoeL

#if nas_make>0
        do iv=i_as1,i_asl
          U(iv) = rhoL*qL(iv,idx)
        end do
#endif

        f(i_rho) = rhoL*vx1L
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
        f(i_rhovx1) = rhoL*vx1L*vx1L
        ru%pn(ru%dir)%val(idx) = pL
#else
        f(i_rhovx1) = rhoL*vx1L*vx1L+pL
#endif
        f(i_rhovx2) = rhoL*vx1L*vx2L
#if sdims_make==3
        f(i_rhovx3) = rhoL*vx1L*vx3L
#endif
        f(i_rhoe) = (rhoeL+pL)*vx1L

#if nas_make>0
        do iv=i_as1,i_asl
          f(iv) = rhoL*vx1L*qL(iv,idx)
        end do
#endif

        if(sL>=rp0) then

         do iv=1,nvars
          flux(iv,idx) = f(iv)
         end do 

        else

         Us(i_rho) = rhostarL
         Us(i_rhovx1) = rhostarL*ustar
         Us(i_rhovx2) = rhostarL*vx2L
#if sdims_make==3        
         Us(i_rhovx3) = rhostarL*vx3L
#endif
         Us(i_rhoe) = rhoestarL
#if nas_make>0
         do iv=i_as1,i_asl
           Us(iv) = rhostarL*qL(iv,idx)
         end do
#endif
        
         do iv=1,nvars
          flux(iv,idx) = f(iv) + sL*(Us(iv)-U(iv))
         end do 

        end if

      else

        U(i_rho) = rhoR
        U(i_rhovx1) = rhoR*vx1R
        U(i_rhovx2) = rhoR*vx2R
#if sdims_make==3
        U(i_rhovx3) = rhoR*vx3R
#endif
        U(i_rhoe) = rhoeR

#if nas_make>0
        do iv=i_as1,i_asl
          U(iv) = rhoR*qR(iv,idx)
        end do
#endif

        f(i_rho) = rhoR*vx1R
#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
        f(i_rhovx1) = rhoR*vx1R*vx1R
        ru%pn(ru%dir)%val(idx) = pR
#else
        f(i_rhovx1) = rhoR*vx1R*vx1R+pR
#endif
        f(i_rhovx2) = rhoR*vx1R*vx2R
#if sdims_make==3
        f(i_rhovx3) = rhoR*vx1R*vx3R
#endif
        f(i_rhoe) = (rhoeR+pR)*vx1R

#if nas_make>0
        do iv=i_as1,i_asl
          f(iv) = rhoR*vx1R*qR(iv,idx)
        end do
#endif

        if(sR<rp0) then

         do iv=1,nvars
          flux(iv,idx) = f(iv)
         end do 

        else
       
         Us(i_rho) = rhostarR
         Us(i_rhovx1) = rhostarR*ustar
         Us(i_rhovx2) = rhostarR*vx2R
#if sdims_make==3        
         Us(i_rhovx3) = rhostarR*vx3R
#endif
         Us(i_rhoe) = rhoestarR
#if nas_make>0
         do iv=i_as1,i_asl
           Us(iv) = rhostarR*qR(iv,idx)
         end do
#endif
        
         do iv=1,nvars
           flux(iv,idx) = f(iv) + sR*(Us(iv)-U(iv))
         end do 

        endif

     endif

#endif

#ifdef USE_SHOCK_FLATTENING
    endif
#endif

   end do

 end subroutine riemann

#endif
#endif
#endif


 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! GRID GEOMETRIES
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
#ifdef GEOMETRY_CARTESIAN_UNIFORM
 subroutine create_geometry(lgrid,mgrid)
   type(locgrid), intent(inout) :: lgrid
   type(mpigrid), intent(inout) :: mgrid

   integer :: i,j,k

   do k=lbound(lgrid%nodes,4),ubound(lgrid%nodes,4)
    do j=lbound(lgrid%nodes,3),ubound(lgrid%nodes,3)
     do i=lbound(lgrid%nodes,2),ubound(lgrid%nodes,2)

       lgrid%nodes(1,i,j,k) = lgrid%x1l + (i-rp1)*lgrid%dx1
       lgrid%nodes(2,i,j,k) = lgrid%x2l + (j-rp1)*lgrid%dx2
#if sdims_make==3
       lgrid%nodes(3,i,j,k) = lgrid%x3l + (k-rp1)*lgrid%dx3
#endif

     end do
    end do
   end do

   do k=lbound(lgrid%coords,4),ubound(lgrid%coords,4)
    do j=lbound(lgrid%coords,3),ubound(lgrid%coords,3)
     do i=lbound(lgrid%coords,2),ubound(lgrid%coords,2)

        lgrid%coords(1,i,j,k) = lgrid%x1l + (i-rph)*lgrid%dx1
        lgrid%coords(2,i,j,k) = lgrid%x2l + (j-rph)*lgrid%dx2
#if sdims_make==3
        lgrid%coords(3,i,j,k) = lgrid%x3l + (k-rph)*lgrid%dx3
#endif

#ifdef USE_INTERNAL_BOUNDARIES
        lgrid%r(i,j,k) = sqrt( &
#if sdims_make==3
        lgrid%coords(3,i,j,k)**2 + & 
#endif                
        lgrid%coords(2,i,j,k)**2 + &
        lgrid%coords(1,i,j,k)**2 )
#endif

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x1,4),ubound(lgrid%coords_x1,4)
    do j=lbound(lgrid%coords_x1,3),ubound(lgrid%coords_x1,3)
     do i=lbound(lgrid%coords_x1,2),ubound(lgrid%coords_x1,2)

        lgrid%coords_x1(1,i,j,k) = lgrid%x1l + (i-rp1)*lgrid%dx1
        lgrid%coords_x1(2,i,j,k) = lgrid%x2l + (j-rph)*lgrid%dx2
#if sdims_make==3
        lgrid%coords_x1(3,i,j,k) = lgrid%x3l + (k-rph)*lgrid%dx3
#endif

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x2,4),ubound(lgrid%coords_x2,4)
    do j=lbound(lgrid%coords_x2,3),ubound(lgrid%coords_x2,3)
     do i=lbound(lgrid%coords_x2,2),ubound(lgrid%coords_x2,2)

        lgrid%coords_x2(1,i,j,k) = lgrid%x1l + (i-rph)*lgrid%dx1
        lgrid%coords_x2(2,i,j,k) = lgrid%x2l + (j-rp1)*lgrid%dx2
#if sdims_make==3
        lgrid%coords_x2(3,i,j,k) = lgrid%x3l + (k-rph)*lgrid%dx3
#endif

     end do
    end do
   end do

#if sdims_make==3
   do k=lbound(lgrid%coords_x3,4),ubound(lgrid%coords_x3,4)
    do j=lbound(lgrid%coords_x3,3),ubound(lgrid%coords_x3,3)
     do i=lbound(lgrid%coords_x3,2),ubound(lgrid%coords_x3,2)

        lgrid%coords_x3(1,i,j,k) = lgrid%x1l + (i-rph)*lgrid%dx1
        lgrid%coords_x3(2,i,j,k) = lgrid%x2l + (j-rph)*lgrid%dx2
        lgrid%coords_x3(3,i,j,k) = lgrid%x3l + (k-rp1)*lgrid%dx3

     end do
    end do
   end do
#endif
 
   mgrid%dummy = rp1

 end subroutine create_geometry
#endif

#ifndef NONUNIFORM_RADIAL_NODES
#ifdef GEOMETRY_2D_POLAR
 subroutine create_geometry(lgrid,mgrid)
   type(locgrid), intent(inout) :: lgrid
   type(mpigrid), intent(inout) :: mgrid

   real(kind=rp) :: r,phi
   integer :: i,j,k
#ifdef USE_MHD
   real(kind=rp) :: rpl,rm
#endif

   do k=lbound(lgrid%nodes,4),ubound(lgrid%nodes,4)
    do j=lbound(lgrid%nodes,3),ubound(lgrid%nodes,3)
     do i=lbound(lgrid%nodes,2),ubound(lgrid%nodes,2)

       r = lgrid%x1l + real(i-1,kind=rp)*lgrid%dx1
       phi = lgrid%x2l + real(j-1,kind=rp)*lgrid%dx2

       lgrid%nodes(1,i,j,k) = r*cos(phi)
       lgrid%nodes(2,i,j,k) = r*sin(phi)

     end do
    end do
   end do

   do k=lbound(lgrid%coords,4),ubound(lgrid%coords,4)
    do j=lbound(lgrid%coords,3),ubound(lgrid%coords,3)
     do i=lbound(lgrid%coords,2),ubound(lgrid%coords,2)

        r = lgrid%x1l + real(i-0.5,kind=rp)*lgrid%dx1
        phi = lgrid%x2l + real(j-0.5,kind=rp)*lgrid%dx2

        lgrid%coords(1,i,j,k) = r*cos(phi)
        lgrid%coords(2,i,j,k) = r*sin(phi)
        lgrid%r(i,j,k) = r

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x1,4),ubound(lgrid%coords_x1,4)
    do j=lbound(lgrid%coords_x1,3),ubound(lgrid%coords_x1,3)
     do i=lbound(lgrid%coords_x1,2),ubound(lgrid%coords_x1,2)

        r = lgrid%x1l + real(i-1.0,kind=rp)*lgrid%dx1
        phi = lgrid%x2l + real(j-0.5,kind=rp)*lgrid%dx2

        lgrid%coords_x1(1,i,j,k) = r*cos(phi)
        lgrid%coords_x1(2,i,j,k) = r*sin(phi)
        lgrid%r_x1(i,j,k) = r

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x2,4),ubound(lgrid%coords_x2,4)
    do j=lbound(lgrid%coords_x2,3),ubound(lgrid%coords_x2,3)
     do i=lbound(lgrid%coords_x2,2),ubound(lgrid%coords_x2,2)

        r = lgrid%x1l + real(i-0.5,kind=rp)*lgrid%dx1
        phi = lgrid%x2l + real(j-1.0,kind=rp)*lgrid%dx2

        lgrid%coords_x2(1,i,j,k) = r*cos(phi)
        lgrid%coords_x2(2,i,j,k) = r*sin(phi)
        lgrid%r_x2(i,j,k) = r

     end do
    end do
   end do

#ifdef USE_MHD 
   do k=mgrid%i1(3),mgrid%i2(3)
    do j=mgrid%i1(2),mgrid%i2(2)
     do i=mgrid%i1(1),mgrid%i2(1)
       rm = lgrid%r_x1(i,j,k)
       rpl = lgrid%r_x1(i+1,j,k)
       lgrid%cm(i,j,k) = (rpl+rp2*rm)/(rp3*(rpl+rm))
     end do 
    end do
   end do
#endif

   mgrid%dummy = rp1

 end subroutine create_geometry
#endif
 
#ifdef GEOMETRY_2D_SPHERICAL
 subroutine create_geometry(lgrid,mgrid)
   type(locgrid), intent(inout) :: lgrid
   type(mpigrid), intent(inout) :: mgrid

   real(kind=rp) :: r,theta,sin_theta
   integer :: i,j,k
#ifdef USE_MHD
   real(kind=rp) :: rmi,rpl,am,ap
#endif

   do k=lbound(lgrid%nodes,4),ubound(lgrid%nodes,4)
    do j=lbound(lgrid%nodes,3),ubound(lgrid%nodes,3)
     do i=lbound(lgrid%nodes,2),ubound(lgrid%nodes,2)

       r = lgrid%x1l + real(i-1,kind=rp)*lgrid%dx1
       theta = lgrid%x2l + real(j-1,kind=rp)*lgrid%dx2

       sin_theta = sin(theta)

       lgrid%nodes(1,i,j,k) = r*sin_theta
       lgrid%nodes(2,i,j,k) = r*cos(theta)

       lgrid%sin_theta_cor(i,j,k) = sin_theta
       lgrid%r_cor(i,j,k) = r

     end do
    end do
   end do

   do k=lbound(lgrid%coords,4),ubound(lgrid%coords,4)
    do j=lbound(lgrid%coords,3),ubound(lgrid%coords,3)
     do i=lbound(lgrid%coords,2),ubound(lgrid%coords,2)

        r = lgrid%x1l + real(i-0.5,kind=rp)*lgrid%dx1
        theta = lgrid%x2l + real(j-0.5,kind=rp)*lgrid%dx2

        sin_theta = sin(theta)

        lgrid%coords(1,i,j,k) = r*sin_theta
        lgrid%coords(2,i,j,k) = r*cos(theta)

        lgrid%sin_theta(i,j,k) = sin_theta

        lgrid%r(i,j,k) = r

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x1,4),ubound(lgrid%coords_x1,4)
    do j=lbound(lgrid%coords_x1,3),ubound(lgrid%coords_x1,3)
     do i=lbound(lgrid%coords_x1,2),ubound(lgrid%coords_x1,2)

        r = lgrid%x1l + real(i-1.0,kind=rp)*lgrid%dx1
        theta = lgrid%x2l + real(j-0.5,kind=rp)*lgrid%dx2

        lgrid%coords_x1(1,i,j,k) = r*sin(theta)
        lgrid%coords_x1(2,i,j,k) = r*cos(theta)

        lgrid%r_x1(i,j,k) = r

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x2,4),ubound(lgrid%coords_x2,4)
    do j=lbound(lgrid%coords_x2,3),ubound(lgrid%coords_x2,3)
     do i=lbound(lgrid%coords_x2,2),ubound(lgrid%coords_x2,2)

        r = lgrid%x1l + real(i-0.5,kind=rp)*lgrid%dx1
        theta = lgrid%x2l + real(j-1.0,kind=rp)*lgrid%dx2

        sin_theta = sin(theta)

        lgrid%coords_x2(1,i,j,k) = r*sin_theta
        lgrid%coords_x2(2,i,j,k) = r*cos(theta)

        lgrid%r_x2(i,j,k) = r
        lgrid%sin_theta_x2(i,j,k) = sin_theta

     end do
    end do
   end do

#ifdef USE_MHD
   do k=mgrid%i1(3),mgrid%i2(3)
    do j=mgrid%i1(2),mgrid%i2(2)
     do i=mgrid%i1(1),mgrid%i2(1)

      rmi = lgrid%r_x1(i,j,k)
      rpl = lgrid%r_x1(i+1,j,k)

      am = lgrid%x2l + real(j-1,kind=rp)*lgrid%dx2
      ap = lgrid%x2l + real(j,kind=rp)*lgrid%dx2

      lgrid%cm(i,j,k) = (rp3*rmi*rmi+rp2*rmi*rpl+rpl*rpl) / &
      (rp4*(rmi*rmi+rmi*rpl+rpl*rpl))

      lgrid%dm(i,j,k) = ((am-ap)*cos(am)-sin(am)+sin(ap)) / &
      ((am-ap)*(cos(am)-cos(ap)))        

     end do
    end do
   end do
#endif

   mgrid%dummy = rp1

 end subroutine create_geometry
#endif

#ifdef GEOMETRY_3D_SPHERICAL
 subroutine create_geometry(lgrid,mgrid)
   type(locgrid), intent(inout) :: lgrid
   type(mpigrid), intent(inout) :: mgrid

   real(kind=rp) :: r,theta,phi,sin_theta,cos_theta
   integer :: i,j,k
#ifdef USE_MHD
   real(kind=rp) :: rmi,rpl,am,ap
#endif

   do k=lbound(lgrid%nodes,4),ubound(lgrid%nodes,4)
    do j=lbound(lgrid%nodes,3),ubound(lgrid%nodes,3)
     do i=lbound(lgrid%nodes,2),ubound(lgrid%nodes,2)

       r = lgrid%x1l + real(i-1,kind=rp)*lgrid%dx1
       theta = lgrid%x2l + real(j-1,kind=rp)*lgrid%dx2
       phi = lgrid%x3l + real(k-1,kind=rp)*lgrid%dx3

       sin_theta = sin(theta)

       lgrid%nodes(1,i,j,k) = r*sin_theta*cos(phi)
       lgrid%nodes(2,i,j,k) = r*sin_theta*sin(phi)
       lgrid%nodes(3,i,j,k) = r*cos(theta)

       lgrid%sin_theta_cor(i,j,k) = sin_theta
       lgrid%r_cor(i,j,k) = r

     end do
    end do
   end do

   do k=lbound(lgrid%coords,4),ubound(lgrid%coords,4)
    do j=lbound(lgrid%coords,3),ubound(lgrid%coords,3)
     do i=lbound(lgrid%coords,2),ubound(lgrid%coords,2)

       r = lgrid%x1l + real(i-0.5,kind=rp)*lgrid%dx1
       theta = lgrid%x2l + real(j-0.5,kind=rp)*lgrid%dx2
       phi = lgrid%x3l + real(k-0.5,kind=rp)*lgrid%dx3

       sin_theta = sin(theta)
       cos_theta = cos(theta)

       lgrid%coords(1,i,j,k) = r*sin_theta*cos(phi)
       lgrid%coords(2,i,j,k) = r*sin_theta*sin(phi)
       lgrid%coords(3,i,j,k) = r*cos_theta

       lgrid%sin_theta(i,j,k) = sin_theta
       lgrid%cos_theta(i,j,k) = cos_theta
       lgrid%r(i,j,k) = r
       lgrid%cot_theta(i,j,k) = cos_theta/sin_theta
       lgrid%inv_r_sin_theta(i,j,k) = rp1/(r*sin_theta)

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x1,4),ubound(lgrid%coords_x1,4)
    do j=lbound(lgrid%coords_x1,3),ubound(lgrid%coords_x1,3)
     do i=lbound(lgrid%coords_x1,2),ubound(lgrid%coords_x1,2)

       r = lgrid%x1l + real(i-1.0,kind=rp)*lgrid%dx1
       theta = lgrid%x2l + real(j-0.5,kind=rp)*lgrid%dx2
       phi = lgrid%x3l + real(k-0.5,kind=rp)*lgrid%dx3

       sin_theta = sin(theta)

       lgrid%coords_x1(1,i,j,k) = r*sin_theta*cos(phi)
       lgrid%coords_x1(2,i,j,k) = r*sin_theta*sin(phi)
       lgrid%coords_x1(3,i,j,k) = r*cos(theta)

       lgrid%r_x1(i,j,k) = r
       lgrid%inv_r_sin_theta_x1(i,j,k) = rp1/(r*sin_theta)

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x2,4),ubound(lgrid%coords_x2,4)
    do j=lbound(lgrid%coords_x2,3),ubound(lgrid%coords_x2,3)
     do i=lbound(lgrid%coords_x2,2),ubound(lgrid%coords_x2,2)

       r = lgrid%x1l + real(i-0.5,kind=rp)*lgrid%dx1
       theta = lgrid%x2l + real(j-1,kind=rp)*lgrid%dx2
       phi = lgrid%x3l + real(k-0.5,kind=rp)*lgrid%dx3

       sin_theta = sin(theta)

       lgrid%coords_x2(1,i,j,k) = r*sin_theta*cos(phi)
       lgrid%coords_x2(2,i,j,k) = r*sin_theta*sin(phi)
       lgrid%coords_x2(3,i,j,k) = r*cos(theta)

       lgrid%r_x2(i,j,k) = r
       lgrid%sin_theta_x2(i,j,k) = sin_theta

     end do
    end do
   end do
 
   do k=lbound(lgrid%coords_x3,4),ubound(lgrid%coords_x3,4)
    do j=lbound(lgrid%coords_x3,3),ubound(lgrid%coords_x3,3)
     do i=lbound(lgrid%coords_x3,2),ubound(lgrid%coords_x3,2)

       r = lgrid%x1l + real(i-0.5,kind=rp)*lgrid%dx1
       theta = lgrid%x2l + real(j-0.5,kind=rp)*lgrid%dx2
       phi = lgrid%x3l + real(k-1,kind=rp)*lgrid%dx3

       sin_theta = sin(theta)

       lgrid%coords_x3(1,i,j,k) = r*sin_theta*cos(phi)
       lgrid%coords_x3(2,i,j,k) = r*sin_theta*sin(phi)
       lgrid%coords_x3(3,i,j,k) = r*cos(theta)

       lgrid%sin_theta_x3(i,j,k) = sin_theta
       lgrid%inv_r_sin_theta_x3(i,j,k) = rp1/(r*sin_theta)
       lgrid%r_x3(i,j,k) = r

     end do
    end do
   end do
 
#ifdef USE_MHD
   do k=mgrid%i1(3),mgrid%i2(3)
    do j=mgrid%i1(2),mgrid%i2(2)
     do i=mgrid%i1(1),mgrid%i2(1)

      rmi = lgrid%r_x1(i,j,k)
      rpl = lgrid%r_x1(i+1,j,k)

      am = lgrid%x2l + real(j-1,kind=rp)*lgrid%dx2
      ap = lgrid%x2l + real(j,kind=rp)*lgrid%dx2

      lgrid%cm(i,j,k) = (rp3*rmi*rmi+rp2*rmi*rpl+rpl*rpl) / &
      (rp4*(rmi*rmi+rmi*rpl+rpl*rpl))

      lgrid%dm(i,j,k) = ((am-ap)*cos(am)-sin(am)+sin(ap)) / &
      ((am-ap)*(cos(am)-cos(ap)))        

     end do
    end do
   end do
#endif

   mgrid%dummy = rp1

 end subroutine create_geometry
#endif
#endif

#ifdef GEOMETRY_CUBED_SPHERE
#if sdims_make==2
 subroutine create_geometry(lgrid,mgrid)
   type(locgrid), intent(inout) :: lgrid
   type(mpigrid), intent(inout) :: mgrid

   real(kind=rp) :: x_eta,y_eta
   real(kind=rp) :: w,d,r,x,y,dx,dy,rs,s0,s1
   real(kind=rp) :: a1,a2
   integer :: i,j,k

   s0 = 2.0_rp*cs_alpha/(1.0_rp+cs_alpha)
   s1 = s0/cs_alpha

   dx = 2.0_rp/real(nx1,kind=rp)
   dy = 2.0_rp/real(nx2,kind=rp)

   do k=lbound(lgrid%nodes,4),ubound(lgrid%nodes,4)
    do j=lbound(lgrid%nodes,3),ubound(lgrid%nodes,3)

     y = -1.0_rp + (real(j,kind=rp)-1.0_rp)*dy

     do i=lbound(lgrid%nodes,2),ubound(lgrid%nodes,2)
   
       x = -1.0_rp + (real(i,kind=rp)-1.0_rp)*dx
       d = max(abs(x),abs(y))
       r = max(1e-10_rp,sqrt(x**2+y**2))
       w = d**cs_gridexp

       lgrid%nodes(1,i,j,k) = &
       w*cs_r1*d*x/r+cs_r1*(1.0_rp-w)*x/sqrt(2.0_rp)
       lgrid%nodes(2,i,j,k) = &
       w*cs_r1*d*y/r+cs_r1*(1.0_rp-w)*y/sqrt(2.0_rp)

       r = max(1.0e-10_rp, &
       sqrt(lgrid%nodes(1,i,j,k)**2+lgrid%nodes(2,i,j,k)**2))
 
       rs = r/cs_r1
       rs = s0*rs + 0.5_rp*(s1-s0)*rs**2
       rs = rs*cs_r1

       lgrid%nodes(1,i,j,k) = lgrid%nodes(1,i,j,k)*rs/r
       lgrid%nodes(2,i,j,k) = lgrid%nodes(2,i,j,k)*rs/r

     end do
    end do
   end do

   do k=lbound(lgrid%coords,4),ubound(lgrid%coords,4)
    do j=lbound(lgrid%coords,3),ubound(lgrid%coords,3)
     do i=lbound(lgrid%coords,2),ubound(lgrid%coords,2)

        lgrid%coords(1,i,j,k) = 0.25_rp*( &
        lgrid%nodes(1,i,j,k) + &
        lgrid%nodes(1,i+1,j,k) + &
        lgrid%nodes(1,i,j+1,k) + &
        lgrid%nodes(1,i+1,j+1,k) )

        lgrid%coords(2,i,j,k) = 0.25_rp*( &
        lgrid%nodes(2,i,j,k) + &
        lgrid%nodes(2,i+1,j,k) + &
        lgrid%nodes(2,i,j+1,k) + &
        lgrid%nodes(2,i+1,j+1,k) )

        lgrid%r(i,j,k) = &
        sqrt(lgrid%coords(1,i,j,k)**2+lgrid%coords(2,i,j,k)**2)

        a1 = (lgrid%nodes(1,i,j+1,k)-lgrid%nodes(1,i+1,j,k))* &
             (lgrid%nodes(2,i,j,k)-lgrid%nodes(2,i+1,j+1,k))
 
        a2 = (lgrid%nodes(2,i,j+1,k)-lgrid%nodes(2,i+1,j,k))* &
             (lgrid%nodes(1,i,j,k)-lgrid%nodes(1,i+1,j+1,k))
     
        lgrid%ivol(i,j,k) = 2.0_rp/abs(a1-a2)

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x1,4),ubound(lgrid%coords_x1,4)
    do j=lbound(lgrid%coords_x1,3),ubound(lgrid%coords_x1,3)
     do i=lbound(lgrid%coords_x1,2),ubound(lgrid%coords_x1,2)

        x_eta = lgrid%nodes(1,i,j+1,k)-lgrid%nodes(1,i,j,k)
        y_eta = lgrid%nodes(2,i,j+1,k)-lgrid%nodes(2,i,j,k)

        lgrid%n_x1(1,i,j,k) = y_eta
        lgrid%n_x1(2,i,j,k) = -x_eta

        lgrid%A_x1(i,j,k) = & 
        sqrt(lgrid%n_x1(1,i,j,k)**2+lgrid%n_x1(2,i,j,k)**2)

        lgrid%n_x1(1,i,j,k) = lgrid%n_x1(1,i,j,k)/lgrid%A_x1(i,j,k)
        lgrid%n_x1(2,i,j,k) = lgrid%n_x1(2,i,j,k)/lgrid%A_x1(i,j,k)

        lgrid%coords_x1(1,i,j,k) = &
        0.5_rp*(lgrid%nodes(1,i,j+1,k)+lgrid%nodes(1,i,j,k))
        lgrid%coords_x1(2,i,j,k) = &
        0.5_rp*(lgrid%nodes(2,i,j+1,k)+lgrid%nodes(2,i,j,k))

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x2,4),ubound(lgrid%coords_x2,4)
    do j=lbound(lgrid%coords_x2,3),ubound(lgrid%coords_x2,3)
     do i=lbound(lgrid%coords_x2,2),ubound(lgrid%coords_x2,2)

        x_eta = lgrid%nodes(1,i+1,j,k)-lgrid%nodes(1,i,j,k)
        y_eta = lgrid%nodes(2,i+1,j,k)-lgrid%nodes(2,i,j,k)

        lgrid%n_x2(1,i,j,k) = -y_eta
        lgrid%n_x2(2,i,j,k) =  x_eta

        lgrid%A_x2(i,j,k) = & 
        sqrt(lgrid%n_x2(1,i,j,k)**2+lgrid%n_x2(2,i,j,k)**2)

        lgrid%n_x2(1,i,j,k) = lgrid%n_x2(1,i,j,k)/lgrid%A_x2(i,j,k)
        lgrid%n_x2(2,i,j,k) = lgrid%n_x2(2,i,j,k)/lgrid%A_x2(i,j,k)

        lgrid%coords_x2(1,i,j,k) = &
        0.5_rp*(lgrid%nodes(1,i+1,j,k)+lgrid%nodes(1,i,j,k))
        lgrid%coords_x2(2,i,j,k) = &
        0.5_rp*(lgrid%nodes(2,i+1,j,k)+lgrid%nodes(2,i,j,k))

     end do
    end do
   end do

   mgrid%dummy = rp1

 end subroutine create_geometry
#endif

#if sdims_make==3
 subroutine create_geometry(lgrid,mgrid)
   type(locgrid), intent(inout) :: lgrid
   type(mpigrid), intent(inout) :: mgrid

   real(kind=rp) :: w,d,r,x,y,z,dx,dy,dz,rs,s0,s1
   integer :: i,j,k,iv
   real(kind=rp) :: r24(3),r31(3),r45(3),r52(3),r61(3),r71(3),r81(3),&
   sh1485(3),sh1234(3),sh1562(3)
   real(kind=rp) :: x_xi,x_eta,x_zeta,y_xi,y_eta,y_zeta,z_eta,z_xi,z_zeta

   s0 = 2.0_rp*cs_alpha/(1.0_rp+cs_alpha)
   s1 = s0/cs_alpha

   dx = 2.0_rp/real(nx1,kind=rp)
   dy = 2.0_rp/real(nx2,kind=rp)
   dz = 2.0_rp/real(nx3,kind=rp)

   do k=lbound(lgrid%nodes,4),ubound(lgrid%nodes,4)

    z = -1.0_rp + (real(k,kind=rp)-1.0_rp)*dz

    do j=lbound(lgrid%nodes,3),ubound(lgrid%nodes,3)

     y = -1.0_rp + (real(j,kind=rp)-1.0_rp)*dy

     do i=lbound(lgrid%nodes,2),ubound(lgrid%nodes,2)
   
       x = -1.0_rp + (real(i,kind=rp)-1.0_rp)*dx

       d = max(abs(x),abs(y),abs(z))
       r = max(1e-10_rp,sqrt(x**2+y**2+z**2))
       w = d**cs_gridexp

       lgrid%nodes(1,i,j,k) = &
       w*cs_r1*d*x/r+cs_r1*(1.0_rp-w)*x/sqrt(2.0_rp)
       lgrid%nodes(2,i,j,k) = &
       w*cs_r1*d*y/r+cs_r1*(1.0_rp-w)*y/sqrt(2.0_rp)
       lgrid%nodes(3,i,j,k) = &
       w*cs_r1*d*z/r+cs_r1*(1.0_rp-w)*z/sqrt(2.0_rp)

       r = max(1.0e-10_rp, &
       sqrt(lgrid%nodes(1,i,j,k)**2+ &
       lgrid%nodes(2,i,j,k)**2+ &
       lgrid%nodes(3,i,j,k)**2))

       rs = r/cs_r1
       rs = s0*rs + 0.5_rp*(s1-s0)*rs**2
       rs = rs*cs_r1

       do iv=1,sdims
        lgrid%nodes(iv,i,j,k) = lgrid%nodes(iv,i,j,k)*rs/r
       end do

     end do
    end do
   end do

   do k=lbound(lgrid%coords,4),ubound(lgrid%coords,4)
    do j=lbound(lgrid%coords,3),ubound(lgrid%coords,3)
     do i=lbound(lgrid%coords,2),ubound(lgrid%coords,2)

        do iv=1,3

          lgrid%coords(iv,i,j,k) = 0.125_rp*( &
          lgrid%nodes(iv,i,j,k) + &
          lgrid%nodes(iv,i+1,j,k) + &
          lgrid%nodes(iv,i,j+1,k) + &
          lgrid%nodes(iv,i+1,j+1,k) + &
          lgrid%nodes(iv,i,j,k+1) + &
          lgrid%nodes(iv,i+1,j,k+1) + &
          lgrid%nodes(iv,i,j+1,k+1) + &
          lgrid%nodes(iv,i+1,j+1,k+1) )

        end do  

        lgrid%r(i,j,k) = &
        sqrt(lgrid%coords(1,i,j,k)**2 + &
        lgrid%coords(2,i,j,k)**2 + &
        lgrid%coords(3,i,j,k)**2 )

        do iv=1,3

          r71(iv) = lgrid%nodes(iv,i+1,j+1,k+1) - lgrid%nodes(iv,i,j,k)
          r31(iv) = lgrid%nodes(iv,i+1,j+1,k)   - lgrid%nodes(iv,i,j,k)
          r24(iv) = lgrid%nodes(iv,i,j+1,k)     - lgrid%nodes(iv,i+1,j,k)
          r61(iv) = lgrid%nodes(iv,i,j+1,k+1)   - lgrid%nodes(iv,i,j,k)
          r52(iv) = lgrid%nodes(iv,i,j,k+1)     - lgrid%nodes(iv,i,j+1,k)
          r81(iv) = lgrid%nodes(iv,i+1,j,k+1)   - lgrid%nodes(iv,i,j,k)
          r45(iv) = lgrid%nodes(iv,i+1,j,k)     - lgrid%nodes(iv,i,j,k+1)

        end do

        sh1485(1) = r31(2)*r24(3) - r31(3)*r24(2)
        sh1485(2) = r31(3)*r24(1) - r31(1)*r24(3)
        sh1485(3) = r31(1)*r24(2) - r31(2)*r24(1)

        sh1234(1) = r61(2)*r52(3) - r61(3)*r52(2)
        sh1234(2) = r61(3)*r52(1) - r61(1)*r52(3)
        sh1234(3) = r61(1)*r52(2) - r61(2)*r52(1)

        sh1562(1) = r81(2)*r45(3) - r81(3)*r45(2)
        sh1562(2) = r81(3)*r45(1) - r81(1)*r45(3)
        sh1562(3) = r81(1)*r45(2) - r81(2)*r45(1)

        lgrid%ivol(i,j,k) = 0.0_rp

        do iv=1,3

         lgrid%ivol(i,j,k) = lgrid%ivol(i,j,k) + &
          r71(iv)*(sh1485(iv)+sh1234(iv)+sh1562(iv))
 
        end do

        lgrid%ivol(i,j,k) = 6.0_rp/lgrid%ivol(i,j,k)

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x1,4),ubound(lgrid%coords_x1,4)
    do j=lbound(lgrid%coords_x1,3),ubound(lgrid%coords_x1,3)
     do i=lbound(lgrid%coords_x1,2),ubound(lgrid%coords_x1,2)

        x_eta  = 0.5_rp * ( &
        (lgrid%nodes(1,i,j+1,k  ) + lgrid%nodes(1,i,j+1,k+1)) - &
        (lgrid%nodes(1,i,j  ,k  ) + lgrid%nodes(1,i,j  ,k+1)) )

        x_zeta = 0.5_rp * ( &
        (lgrid%nodes(1,i,j  ,k+1) + lgrid%nodes(1,i,j+1,k+1)) - &
        (lgrid%nodes(1,i,j  ,k  ) + lgrid%nodes(1,i,j+1,k  )) )

        y_eta  = 0.5_rp * ( &
        (lgrid%nodes(2,i,j+1,k  ) + lgrid%nodes(2,i,j+1,k+1)) - &
        (lgrid%nodes(2,i,j  ,k  ) + lgrid%nodes(2,i,j  ,k+1)) )

        y_zeta = 0.5_rp * ( &
        (lgrid%nodes(2,i,j  ,k+1) + lgrid%nodes(2,i,j+1,k+1)) - &
        (lgrid%nodes(2,i,j  ,k  ) + lgrid%nodes(2,i,j+1,k  )) )

        z_eta  = 0.5_rp * ( &
        (lgrid%nodes(3,i,j+1,k  ) + lgrid%nodes(3,i,j+1,k+1)) - &
        (lgrid%nodes(3,i,j  ,k  ) + lgrid%nodes(3,i,j  ,k+1)) )

        z_zeta = 0.5_rp * ( &
        (lgrid%nodes(3,i,j  ,k+1) + lgrid%nodes(3,i,j+1,k+1)) - &
        (lgrid%nodes(3,i,j  ,k  ) + lgrid%nodes(3,i,j+1,k  )) )

        lgrid%n_x1(1,i,j,k) =  z_zeta*y_eta - y_zeta*z_eta
        lgrid%n_x1(2,i,j,k) = -z_zeta*x_eta + x_zeta*z_eta
        lgrid%n_x1(3,i,j,k) =  y_zeta*x_eta - x_zeta*y_eta

        lgrid%A_x1(i,j,k) = & 
        sqrt(lgrid%n_x1(1,i,j,k)**2+lgrid%n_x1(2,i,j,k)**2+lgrid%n_x1(3,i,j,k)**2)

        do iv=1,sdims
         lgrid%n_x1(iv,i,j,k) = lgrid%n_x1(iv,i,j,k)/lgrid%A_x1(i,j,k)
        end do 

        do iv=1,sdims
         lgrid%coords_x1(iv,i,j,k) = 0.25_rp*( &
         lgrid%nodes(iv,i,j,k) + &
         lgrid%nodes(iv,i,j+1,k) + &
         lgrid%nodes(iv,i,j,k+1) + &
         lgrid%nodes(iv,i,j+1,k+1) &
         )
        end do

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x2,4),ubound(lgrid%coords_x2,4)
    do j=lbound(lgrid%coords_x2,3),ubound(lgrid%coords_x2,3)
     do i=lbound(lgrid%coords_x2,2),ubound(lgrid%coords_x2,2)

        x_xi = 0.5_rp * ( &
        (lgrid%nodes(1,i+1,j,k  ) + lgrid%nodes(1,i+1,j,k+1)) - &
        (lgrid%nodes(1,i  ,j,k  ) + lgrid%nodes(1,i  ,j,k+1)) )
   
        x_zeta = 0.5_rp * ( &
        (lgrid%nodes(1,i  ,j,k+1) + lgrid%nodes(1,i+1,j,k+1)) - &
        (lgrid%nodes(1,i  ,j,k  ) + lgrid%nodes(1,i+1,j,k  )) )
   
        y_xi = 0.5_rp * ( &
        (lgrid%nodes(2,i+1,j,k  ) + lgrid%nodes(2,i+1,j,k+1)) - &
        (lgrid%nodes(2,i  ,j,k  ) + lgrid%nodes(2,i  ,j,k+1)) )
   
        y_zeta = 0.5_rp * ( &
        (lgrid%nodes(2,i  ,j,k+1) + lgrid%nodes(2,i+1,j,k+1)) - &
        (lgrid%nodes(2,i  ,j,k  ) + lgrid%nodes(2,i+1,j,k  )) )
   
        z_xi = 0.5_rp * ( &
        (lgrid%nodes(3,i+1,j,k  ) + lgrid%nodes(3,i+1,j,k+1)) - &
        (lgrid%nodes(3,i  ,j,k  ) + lgrid%nodes(3,i  ,j,k+1)) )
   
        z_zeta = 0.5_rp * ( &
        (lgrid%nodes(3,i  ,j,k+1) + lgrid%nodes(3,i+1,j,k+1)) - &
        (lgrid%nodes(3,i  ,j,k  ) + lgrid%nodes(3,i+1,j,k  )) )

        lgrid%n_x2(1,i,j,k) = -z_zeta*y_xi + y_zeta*z_xi
        lgrid%n_x2(2,i,j,k) =  z_zeta*x_xi - x_zeta*z_xi
        lgrid%n_x2(3,i,j,k) = -y_zeta*x_xi + x_zeta*y_xi

        lgrid%A_x2(i,j,k) = &
        sqrt(lgrid%n_x2(1,i,j,k)**2+lgrid%n_x2(2,i,j,k)**2+lgrid%n_x2(3,i,j,k)**2)

        do iv=1,sdims
         lgrid%n_x2(iv,i,j,k) = lgrid%n_x2(iv,i,j,k)/lgrid%A_x2(i,j,k)
        end do

        do iv=1,sdims
         lgrid%coords_x2(iv,i,j,k) = 0.25_rp*( &
         lgrid%nodes(iv,i,j,k) + &
         lgrid%nodes(iv,i+1,j,k) + &
         lgrid%nodes(iv,i,j,k+1) + &
         lgrid%nodes(iv,i+1,j,k+1) &
         )
        end do

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x3,4),ubound(lgrid%coords_x3,4)
    do j=lbound(lgrid%coords_x3,3),ubound(lgrid%coords_x3,3)
     do i=lbound(lgrid%coords_x3,2),ubound(lgrid%coords_x3,2)
  
        x_xi = 0.5_rp * ( &
        (lgrid%nodes(1,i+1,j  ,k) + lgrid%nodes(1,i+1,j+1,k)) - &
        (lgrid%nodes(1,i  ,j  ,k) + lgrid%nodes(1,i  ,j+1,k)) )
  
        x_eta = 0.5_rp * ( &
        (lgrid%nodes(1,i  ,j+1,k) + lgrid%nodes(1,i+1,j+1,k)) - &
        (lgrid%nodes(1,i  ,j  ,k) + lgrid%nodes(1,i+1,j  ,k)) )
  
        y_xi = 0.5_rp * ( &
        (lgrid%nodes(2,i+1,j  ,k) + lgrid%nodes(2,i+1,j+1,k)) - &
        (lgrid%nodes(2,i  ,j  ,k) + lgrid%nodes(2,i  ,j+1,k)) )
  
        y_eta = 0.5_rp * ( &
        (lgrid%nodes(2,i  ,j+1,k) + lgrid%nodes(2,i+1,j+1,k)) - &
        (lgrid%nodes(2,i  ,j  ,k) + lgrid%nodes(2,i+1,j  ,k)) )
  
        z_xi = 0.5_rp * ( &
        (lgrid%nodes(3,i+1,j  ,k) + lgrid%nodes(3,i+1,j+1,k)) - &
        (lgrid%nodes(3,i  ,j  ,k) + lgrid%nodes(3,i  ,j+1,k)) )
  
        z_eta = 0.5_rp * ( &
        (lgrid%nodes(3,i  ,j+1,k) + lgrid%nodes(3,i+1,j+1,k)) - &
        (lgrid%nodes(3,i  ,j  ,k) + lgrid%nodes(3,i+1,j  ,k)) )

        lgrid%n_x3(1,i,j,k) =  z_eta*y_xi - y_eta*z_xi
        lgrid%n_x3(2,i,j,k) = -z_eta*x_xi + x_eta*z_xi
        lgrid%n_x3(3,i,j,k) =  y_eta*x_xi - x_eta*y_xi

        lgrid%A_x3(i,j,k) = &
        sqrt(lgrid%n_x3(1,i,j,k)**2+lgrid%n_x3(2,i,j,k)**2+lgrid%n_x3(3,i,j,k)**2)

        do iv=1,sdims
         lgrid%n_x3(iv,i,j,k) = lgrid%n_x3(iv,i,j,k)/lgrid%A_x3(i,j,k)
        end do

         do iv=1,sdims
          lgrid%coords_x3(iv,i,j,k) = 0.25_rp*( &
          lgrid%nodes(iv,i,j,k) + &
          lgrid%nodes(iv,i+1,j,k) + &
          lgrid%nodes(iv,i,j+1,k) + &
          lgrid%nodes(iv,i+1,j+1,k) &
          )
         end do
 
     end do
    end do
   end do

   mgrid%dummy = rp1

 end subroutine create_geometry
#endif

#endif

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! GRAVITY SOLVER
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
#ifdef USE_GRAVITY

#ifdef USE_MONOPOLE_GRAVITY
 subroutine monopole_gravity(mgrid,lgrid,ni)
  type(mpigrid), intent(inout) :: mgrid
  type(locgrid), intent(inout) :: lgrid
  integer, intent(in) :: ni

  real(kind=rp) :: riv(ni+1)
  real(kind=rp) :: rhov(ni+2),rhorv(ni+2),rhov_glob(ni+2),rhorv_glob(ni+2)
  real(kind=rp) :: dr,r,rho,tmp,grl,theta,phi,x,y,z,rmax
  real(kind=rp) :: grv(ni+2),mrv(ni+2),rv(ni+2)
  integer :: cntv(ni+2),cntv_glob(ni+2)
  integer :: ir,i,j,k,ierr
  integer :: lx1,ux1,lx2,ux2,lx3,ux3

  lx1 = mgrid%i1(1)
  lx2 = mgrid%i1(2)
  lx3 = mgrid%i1(3)
  ux1 = mgrid%i2(1)
  ux2 = mgrid%i2(2)
  ux3 = mgrid%i2(3)

  rmax = (lgrid%x1u-lgrid%x1l)*rph

  dr = rmax/real(ni,kind=rp)

  do ir=1,ni+1
   riv(ir) = real(ir-1,kind=rp)*dr
  end do

  do ir=1,ni+2
   rhov(ir) = rp0
   rhorv(ir) = rp0
   cntv(ir) = 0
  end do

  z = rp0

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
  
     r = lgrid%r(i,j,k)

     ir = int(r/dr)+1

     if(ir<=ni) then
      rho = lgrid%prim(i_rho,i,j,k)
      rhov(ir+1) = rhov(ir+1) + rho
      rhorv(ir+1) = rhorv(ir+1) + rho*r
      cntv(ir+1) = cntv(ir+1) + 1
     endif
    
    end do
   end do
  end do

  call mpi_allreduce(rhov,rhov_glob,ni+2,MPI_RP,MPI_SUM,mgrid%comm_cart,ierr)
  call mpi_allreduce(rhorv,rhorv_glob,ni+2,MPI_RP,MPI_SUM,mgrid%comm_cart,ierr)
  call mpi_allreduce(cntv,cntv_glob,ni+2,MPI_INTEGER,MPI_SUM,mgrid%comm_cart,ierr)

  rv(1) = rp0

  do ir=2,ni+1
   tmp = rp1/real(cntv_glob(ir),kind=rp)
   rv(ir) = rhorv_glob(ir)/rhov_glob(ir)
   rhov(ir) = rhov_glob(ir)*tmp
  end do
  
  rv(ni+2) = rmax

  rhov(1) = rhov(2) - (rhov(3)-rhov(2))/(rv(3)-rv(2))*rv(2)
  rhov(ni+2) = rhov(ni+1) + (rhov(ni+1)-rhov(ni))/(rv(ni+1)-rv(ni))*(rv(ni+2)-rv(ni+1))

  tmp = -rp2*CONST_PI*CONST_GRAV
  
  mrv(1) = rp0
  do ir=2,ni+2
   mrv(ir) = mrv(ir-1) + &
   tmp*(rv(ir)-rv(ir-1))*(rhov(ir)*rv(ir)**2+rhov(ir-1)*rv(ir-1)**2)
  end do

  grv(1) = rp0
  do ir=2,ni+2
   grv(ir) = mrv(ir)/rv(ir)**2
  end do

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1

      lgrid%grav(1,i,j,k) = rp0
      lgrid%grav(2,i,j,k) = rp0
#if sdims_make==3
      lgrid%grav(3,i,j,k) = rp0
#endif

      r = lgrid%r(i,j,k)
      do ir=1,ni+1
       if((r>=rv(ir)) .and. (r<rv(ir+1))) then

        tmp = (r-rv(ir))/(rv(ir+1)-rv(ir))

        grl = grv(ir) + (grv(ir+1)-grv(ir))*tmp
 
        x = lgrid%coords(1,i,j,k)
        y = lgrid%coords(2,i,j,k)
#if sdims_make==3
        z = lgrid%coords(3,i,j,k)
#endif
        theta = acos(z/r)
        phi = atan2(y,x)

        lgrid%grav(1,i,j,k) = grl*sin(theta)*cos(phi)
        lgrid%grav(2,i,j,k) = grl*sin(theta)*sin(phi)
#if sdims_make==3
        lgrid%grav(3,i,j,k) = grl*cos(theta)
#endif

       endif
      end do
    
    end do
   end do
  end do

 end subroutine monopole_gravity
#endif

#ifdef USE_GRAVITY_SOLVER
#ifdef USE_INTERNAL_BOUNDARIES

 subroutine gravity_solver(mgrid,lgrid)
  type(mpigrid), intent(inout) :: mgrid
  type(locgrid), intent(inout) :: lgrid

  integer :: i,j,k
  integer :: lx1,ux1,lx2,ux2,lx3,ux3
  integer :: ierr

  real(kind=rp) ::  rho, x, y, z, r, dV, dm, mass(1), mass_comm(1), dx, dy, dz
  real(kind=rp), dimension(3) :: rcom, rcom_comm, dr

  real(kind=rp) :: res_L2(1),phicc,res_L2(1)_comm

  integer :: iter

  real(kind=rp) :: h1x,h2x,h1y,h2y,xc,yc,c1x,c2x,c3x, & 
  c1y,c2y,c3y,num(1),den,num_comm(1),den_comm,tmp,c2z
  
  real(kind=rp) :: rhoi, rhoim1, alpha, wi, beta

#if sdims_make==3
  real(kind=rp) :: h1z,h2z,zc,c1z,c3z
#endif

#ifdef GS_QUADRUPOLE_BCS
  real(kind=rp), dimension(9) :: Q, Q_comm
  real(kind=rp), dimension(3,3) :: Qij, deltak
  real(kind=rp) :: r2, qdp
  integer :: ic,ii,jj
#endif

#ifdef GS_OCTUPOLE_BCS
  real(kind=rp), dimension(27) :: Qo, Qo_comm
  real(kind=rp), dimension(3,3,3) :: Qijk
  real(kind=rp) :: oct
  integer :: kk
#endif

  lx1 = mgrid%i1(1)
  lx2 = mgrid%i1(2)
  lx3 = mgrid%i1(3)
  ux1 = mgrid%i2(1)
  ux2 = mgrid%i2(2)
  ux3 = mgrid%i2(3)
 
  rcom(1) = rp0
  rcom(2) = rp0
  rcom(3) = rp0

  dr(1) = rp0
  dr(2) = rp0
  dr(3) = rp0

  mass(1) = rp0

  z = rp0

  dx = lgrid%dx1
  dy = lgrid%dx2
#if sdims_make==3
  dz = lgrid%dx3
#else
  dz = rp1
#endif

  dV = dz*dy*dz

#ifdef GS_QUADRUPOLE_BCS

  do i=1,9
   Q(i) = rp0
  end do

  do j=1,3
   do i=1,3
    deltak(i,j) = rp0
   end do
  end do

  deltak(1,1) = rp1
  deltak(2,2) = rp1
  deltak(3,3) = rp1

#ifdef GS_OCTUPOLE_BCS

  do i=1,27
     Qo(i) = rp0
  end do

#endif

#endif

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1

     x = lgrid%coords(1,i,j,k)
     y = lgrid%coords(2,i,j,k)
#if sdims_make==3
     z = lgrid%coords(3,i,j,k)
#endif

     rho = lgrid%prim(i_rho,i,j,k)-lgrid%gs_rho_bg

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
     dx = lgrid%coords_x1(1,i+1,j,k)-lgrid%coords_x1(1,i,j,k)
     dy = lgrid%coords_x2(2,i,j+1,k)-lgrid%coords_x2(2,i,j,k)
#if sdims_make==3
     dz = lgrid%coords_x3(3,i,j,k+1)-lgrid%coords_x3(3,i,j,k)
#endif
     dV = dx*dy*dz
#endif
     dm = rho*dV*(rp1-real(lgrid%is_solid(i,j,k),kind=rp))
 
     rcom(1) = rcom(1) + x*dm
     rcom(2) = rcom(2) + y*dm
#if sdims_make==3
     rcom(3) = rcom(3) + z*dm
#endif
   
     mass(1) = mass(1) + dm

    end do
   end do
  end do
  
  call mpi_allreduce(rcom, rcom_comm, 3, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)
  call mpi_allreduce(mass, mass_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

  rcom(1) = rcom_comm(1)/mass_comm(1)
  rcom(2) = rcom_comm(2)/mass_comm(1)
  rcom(3) = rcom_comm(3)/mass_comm(1)

#ifdef GS_QUADRUPOLE_BCS
 
  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1

     x = lgrid%coords(1,i,j,k)
     y = lgrid%coords(2,i,j,k)
#if sdims_make==3
     z = lgrid%coords(3,i,j,k)
#endif

     rho = lgrid%prim(i_rho,i,j,k)-lgrid%gs_rho_bg

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
     dx = lgrid%coords_x1(1,i+1,j,k)-lgrid%coords_x1(1,i,j,k)
     dy = lgrid%coords_x2(2,i,j+1,k)-lgrid%coords_x2(2,i,j,k)
#if sdims_make==3
     dz = lgrid%coords_x3(3,i,j,k+1)-lgrid%coords_x3(3,i,j,k)
#endif
     dV = dx*dy*dz
#endif
     dm = rho*dV*(rp1-real(lgrid%is_solid(i,j,k),kind=rp)) 

     dr(1) = x - rcom(1)
     dr(2) = y - rcom(2)
#if sdims_make==3
     dr(3) = z - rcom(3)
#endif
     r2 = dr(1)*dr(1) + dr(2)*dr(2) + dr(3)*dr(3)

     ic = 1
     do jj=1,3
      do ii=1,3
        Q(ic) = Q(ic) + rph*dm*(rp3*dr(ii)*dr(jj)-r2*deltak(ii,jj))
        ic = ic + 1
      end do
     end do

#ifdef GS_OCTUPOLE_BCS

     ic = 1
     do kk=1,3
      do jj=1,3
       do ii=1,3
        Qo(ic) = Qo(ic) + dm*( &
        rpth*dr(ii)*dr(jj)*dr(kk) - &
        rph*r2*(dr(ii)*deltak(jj,kk) + &
        dr(jj)*deltak(ii,kk) + &
        dr(kk)*deltak(ii,jj) &
        ))
        ic = ic + 1
       end do
     end do
    end do

#endif

    end do
   end do
  end do
  
  call mpi_allreduce(Q, Q_comm, 9, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

  ic = 1
  do jj=1,3
   do ii=1,3
    Qij(ii,jj) = Q_comm(ic)
    ic = ic + 1
   end do
  end do

#ifdef GS_OCTUPOLE_BCS
  
  call mpi_allreduce(Qo, Qo_comm, 27, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

  ic = 1
  do kk=1,3
   do jj=1,3
    do ii=1,3
     Qijk(ii,jj,kk) = Qo_comm(ic)
     ic = ic + 1
    end do
   end do
  end do

#endif

#endif

   do k=lx3,ux3
    do j=lx2,ux2
     do i=lx1,ux1+1

      if((lgrid%is_solid(i-1,j,k)+lgrid%is_solid(i,j,k))==1) then

       dr(1) = lgrid%coords_x1(1,i,j,k)-rcom(1)
       dr(2) = lgrid%coords_x1(2,i,j,k)-rcom(2)
#if sdims_make==3
       dr(3) = lgrid%coords_x1(3,i,j,k)-rcom(3)
#endif
       r = sqrt(dr(1)*dr(1)+dr(2)*dr(2)+dr(3)*dr(3))

#ifdef GS_QUADRUPOLE_BCS
       qdp = rp0
       do jj=1,3
        do ii=1,3
         qdp = qdp + Qij(ii,jj)*dr(ii)*dr(jj)
        end do
       end do
#ifdef GS_OCTUPOLE_BCS
       oct = rp0
       do kk=1,3
        do jj=1,3
         do ii=1,3
          oct = oct + Qijk(ii,jj,kk)*dr(ii)*dr(jj)*dr(kk)
         end do
        end do
       end do
#endif
#endif

       lgrid%phi_x1(i,j,k) = &
#ifdef GS_QUADRUPOLE_BCS
       -qdp*CONST_GRAV/(r*r*r*r*r) &
#ifdef GS_OCTUPOLE_BCS
       -oct*CONST_GRAV/(r*r*r*r*r*r*r) &
#endif             
#endif
       -CONST_GRAV*mass_comm(1)/r

      endif

     end do
    end do
   end do

   do k=lx3,ux3
    do j=lx2,ux2+1
     do i=lx1,ux1

      if((lgrid%is_solid(i,j-1,k)+lgrid%is_solid(i,j,k))==1) then

       dr(1) = lgrid%coords_x2(1,i,j,k)-rcom(1)
       dr(2) = lgrid%coords_x2(2,i,j,k)-rcom(2)
#if sdims_make==3
       dr(3) = lgrid%coords_x2(3,i,j,k)-rcom(3)
#endif
       r = sqrt(dr(1)*dr(1)+dr(2)*dr(2)+dr(3)*dr(3))

#ifdef GS_QUADRUPOLE_BCS
       qdp = rp0
       do jj=1,3
        do ii=1,3
         qdp = qdp + Qij(ii,jj)*dr(ii)*dr(jj)
        end do
       end do
#ifdef GS_OCTUPOLE_BCS
       oct = rp0
       do kk=1,3
        do jj=1,3
         do ii=1,3
          oct = oct + Qijk(ii,jj,kk)*dr(ii)*dr(jj)*dr(kk)
         end do
        end do
       end do
#endif
#endif

       lgrid%phi_x2(i,j,k) = &
#ifdef GS_QUADRUPOLE_BCS
       -qdp*CONST_GRAV/(r*r*r*r*r) &
#ifdef GS_OCTUPOLE_BCS
       -oct*CONST_GRAV/(r*r*r*r*r*r*r) &
#endif             
#endif
       -CONST_GRAV*mass_comm(1)/r
 
      endif

     end do
    end do
   end do

#if sdims_make==3

   do k=lx3,ux3+1
    do j=lx2,ux2
     do i=lx1,ux1

      if((lgrid%is_solid(i,j,k-1)+lgrid%is_solid(i,j,k))==1) then

       dr(1) = lgrid%coords_x3(1,i,j,k)-rcom(1)
       dr(2) = lgrid%coords_x3(2,i,j,k)-rcom(2)
       dr(3) = lgrid%coords_x3(3,i,j,k)-rcom(3)
       r = sqrt(dr(1)*dr(1)+dr(2)*dr(2)+dr(3)*dr(3))

#ifdef GS_QUADRUPOLE_BCS
       qdp = rp0
       do jj=1,3
        do ii=1,3
         qdp = qdp + Qij(ii,jj)*dr(ii)*dr(jj)
        end do
       end do
#ifdef GS_OCTUPOLE_BCS
       oct = rp0
       do kk=1,3
        do jj=1,3
         do ii=1,3
          oct = oct + Qijk(ii,jj,kk)*dr(ii)*dr(jj)*dr(kk)
         end do
        end do
       end do
#endif
#endif

       lgrid%phi_x3(i,j,k) = &
#ifdef GS_QUADRUPOLE_BCS
       -qdp*CONST_GRAV/(r*r*r*r*r) &
#ifdef GS_OCTUPOLE_BCS
       -oct*CONST_GRAV/(r*r*r*r*r*r*r) &
#endif             
#endif
       -CONST_GRAV*mass_comm(1)/r
 
      endif

     end do
    end do
   end do

#endif

  call mpi_barrier(mgrid%comm_cart,ierr)
  call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%phi_cc,.false.)

  c2z = rp0
 
  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
 
     ierr = lgrid%is_solid(i,j,k)
     tmp = -lgrid%phi_cc(i,j,k) 

     if(ierr==0) then

       if(lgrid%is_solid(i-1,j,k)==1) then
        lgrid%phi_cc(i-1,j,k) = rp2*lgrid%phi_x1(i,j,k)+tmp
       end if

       if(lgrid%is_solid(i+1,j,k)==1) then
        lgrid%phi_cc(i+1,j,k) = rp2*lgrid%phi_x1(i+1,j,k)+tmp
       end if

       if(lgrid%is_solid(i,j-1,k)==1) then
        lgrid%phi_cc(i,j-1,k) = rp2*lgrid%phi_x2(i,j,k)+tmp
       end if

       if(lgrid%is_solid(i,j+1,k)==1) then
        lgrid%phi_cc(i,j+1,k) = rp2*lgrid%phi_x2(i,j+1,k)+tmp
       end if

#if sdims_make==3

       if(lgrid%is_solid(i,j,k-1)==1) then
        lgrid%phi_cc(i,j,k-1) = rp2*lgrid%phi_x3(i,j,k)+tmp
       end if

       if(lgrid%is_solid(i,j,k+1)==1) then
        lgrid%phi_cc(i,j,k+1) = rp2*lgrid%phi_x3(i,j,k+1)+tmp
       end if

#endif

      endif 
           
      xc = lgrid%coords(1,i,j,k)
      yc = lgrid%coords(2,i,j,k)
#if sdims_make==3
      zc = lgrid%coords(3,i,j,k)
#endif
      h1x = xc - lgrid%coords(1,i-1,j,k)
      h2x = lgrid%coords(1,i+1,j,k) - xc

      c1x = rp2/(h1x*(h1x+h2x))
      c2x = -rp2/(h1x*h2x)
      c3x = rp2/(h2x*(h1x+h2x))

      h1y = yc - lgrid%coords(2,i,j-1,k)
      h2y = lgrid%coords(2,i,j+1,k) - yc

      c1y = rp2/(h1y*(h1y+h2y))
      c2y = -rp2/(h1y*h2y)
      c3y = rp2/(h2y*(h1y+h2y))

#if sdims_make==3
      h1z = zc - lgrid%coords(3,i,j,k-1)
      h2z = lgrid%coords(3,i,j,k+1) - zc

      c1z = rp2/(h1z*(h1z+h2z))
      c2z = -rp2/(h1z*h2z)
      c3z = rp2/(h2z*(h1z+h2z))
#endif

      tmp = rp1/(c2x+c2y+c2z)*(rp1-real(lgrid%is_solid(i,j,k),kind=rp))

      phicc = lgrid%phi_cc(i,j,k)

      lgrid%rgs(i,j,k) = tmp*(rp4*CONST_PI*CONST_GRAV*(lgrid%prim(i_rho,i,j,k) - lgrid%gs_rho_bg) - ( &
#if sdims_make==3
      c3z*lgrid%phi_cc(i,j,k+1)+c2z*phicc+c1z*lgrid%phi_cc(i,j,k-1) + &
#endif
      c3x*lgrid%phi_cc(i+1,j,k)+c2x*phicc+c1x*lgrid%phi_cc(i-1,j,k) + &
      c3y*lgrid%phi_cc(i,j+1,k)+c2y*phicc+c1y*lgrid%phi_cc(i,j-1,k) ) )

    end do
   end do
  end do

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
            
      tmp = lgrid%rgs(i,j,k)
      lgrid%p(i,j,k) = tmp
      lgrid%v(i,j,k) = rp0
      lgrid%r0hat(i,j,k) = tmp

    end do
   end do
  end do

  res_L2(1) = rp0

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
       
      xc = lgrid%coords(1,i,j,k)
      yc = lgrid%coords(2,i,j,k)
#if sdims_make==3
      zc = lgrid%coords(3,i,j,k)
#endif
      h1x = xc - lgrid%coords(1,i-1,j,k)
      h2x = lgrid%coords(1,i+1,j,k) - xc
      c2x = -rp2/(h1x*h2x)

      h1y = yc - lgrid%coords(2,i,j-1,k)
      h2y = lgrid%coords(2,i,j+1,k) - yc
      c2y = -rp2/(h1y*h2y)

#if sdims_make==3
      h1z = zc - lgrid%coords(3,i,j,k-1)
      h2z = lgrid%coords(3,i,j,k+1) - zc
      c2z = -rp2/(h1z*h2z)
#endif

      tmp = rp1/(c2x+c2y+c2z)

      res_L2(1) = res_L2(1) + ( lgrid%r0hat(i,j,k) /  &
      (tmp*rp4*CONST_PI*CONST_GRAV*max(abs(lgrid%prim(i_rho,i,j,k)-lgrid%gs_rho_bg),lgrid%gs_rho_bg)))**2

    end do
   end do
  end do

  call mpi_allreduce(res_L2, res_L2_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

  res_L2_comm(1) = sqrt(res_L2_comm(1) / real(nx1*nx2*nx3,kind=rp))

  num(1) = rp0

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
  
      tmp = lgrid%r0hat(i,j,k)
      num(1) = num(1) + tmp*tmp

    end do
   end do
  end do

  call mpi_allreduce(num, num_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

  rhoi = num_comm(1)

  iter = 0

  do while(res_L2_comm(1) > gs_tol)

    call mpi_barrier(mgrid%comm_cart,ierr)
    call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3,1,lgrid%p,.false.)

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
  
       ierr = lgrid%is_solid(i,j,k)
       tmp = -lgrid%p(i,j,k) 
  
       if(ierr==0) then
  
         if(lgrid%is_solid(i-1,j,k)==1) then
          lgrid%p(i-1,j,k) = tmp
         end if
  
         if(lgrid%is_solid(i+1,j,k)==1) then
          lgrid%p(i+1,j,k) = tmp
         end if
  
         if(lgrid%is_solid(i,j-1,k)==1) then
          lgrid%p(i,j-1,k) = tmp
         end if
  
         if(lgrid%is_solid(i,j+1,k)==1) then
          lgrid%p(i,j+1,k) = tmp
         end if
  
#if sdims_make==3
  
         if(lgrid%is_solid(i,j,k-1)==1) then
          lgrid%p(i,j,k-1) = tmp
         end if
  
         if(lgrid%is_solid(i,j,k+1)==1) then
          lgrid%p(i,j,k+1) = tmp
         end if
  
#endif
  
       end if
 
       xc = lgrid%coords(1,i,j,k)
       yc = lgrid%coords(2,i,j,k)
#if sdims_make==3
       zc = lgrid%coords(3,i,j,k)
#endif
       h1x = xc - lgrid%coords(1,i-1,j,k)
       h2x = lgrid%coords(1,i+1,j,k) - xc

       c1x = rp2/(h1x*(h1x+h2x))
       c2x = -rp2/(h1x*h2x)
       c3x = rp2/(h2x*(h1x+h2x))

       h1y = yc - lgrid%coords(2,i,j-1,k)
       h2y = lgrid%coords(2,i,j+1,k) - yc

       c1y = rp2/(h1y*(h1y+h2y))
       c2y = -rp2/(h1y*h2y)
       c3y = rp2/(h2y*(h1y+h2y))

#if sdims_make==3
       h1z = zc - lgrid%coords(3,i,j,k-1)
       h2z = lgrid%coords(3,i,j,k+1) - zc

       c1z = rp2/(h1z*(h1z+h2z))
       c2z = -rp2/(h1z*h2z)
       c3z = rp2/(h2z*(h1z+h2z))
#endif

       tmp = rp1/(c2x+c2y+c2z)*(rp1-real(lgrid%is_solid(i,j,k),kind=rp))

       phicc = lgrid%p(i,j,k)

       lgrid%v(i,j,k) = tmp*( &
#if sdims_make==3
       c3z*lgrid%p(i,j,k+1)+c2z*phicc+c1z*lgrid%p(i,j,k-1) + &
#endif
       c3x*lgrid%p(i+1,j,k)+c2x*phicc+c1x*lgrid%p(i-1,j,k) + &
       c3y*lgrid%p(i,j+1,k)+c2y*phicc+c1y*lgrid%p(i,j-1,k) )

      end do
     end do
    end do

    num(1) = rp0

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
 
       num(1) = num(1) + lgrid%r0hat(i,j,k)*lgrid%v(i,j,k)

      end do
     end do
    end do

    call mpi_allreduce(num, num_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

    alpha = rhoi / num_comm(1)

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1

       lgrid%s(i,j,k) = lgrid%rgs(i,j,k) - alpha*lgrid%v(i,j,k)

      end do
     end do
    end do

    call mpi_barrier(mgrid%comm_cart,ierr)
    call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3,1,lgrid%s,.false.)
 
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
  
       ierr = lgrid%is_solid(i,j,k)
       tmp = -lgrid%s(i,j,k) 
  
       if(ierr==0) then
  
         if(lgrid%is_solid(i-1,j,k)==1) then
          lgrid%s(i-1,j,k) = tmp
         end if
  
         if(lgrid%is_solid(i+1,j,k)==1) then
          lgrid%s(i+1,j,k) = tmp
         end if
  
         if(lgrid%is_solid(i,j-1,k)==1) then
          lgrid%s(i,j-1,k) = tmp
         end if
  
         if(lgrid%is_solid(i,j+1,k)==1) then
          lgrid%s(i,j+1,k) = tmp
         end if
  
#if sdims_make==3
  
         if(lgrid%is_solid(i,j,k-1)==1) then
          lgrid%s(i,j,k-1) = tmp
         end if
  
         if(lgrid%is_solid(i,j,k+1)==1) then
          lgrid%s(i,j,k+1) = tmp
         end if
  
#endif
  
       end if
 
       xc = lgrid%coords(1,i,j,k)
       yc = lgrid%coords(2,i,j,k)
#if sdims_make==3
       zc = lgrid%coords(3,i,j,k)
#endif
       h1x = xc - lgrid%coords(1,i-1,j,k)
       h2x = lgrid%coords(1,i+1,j,k) - xc

       c1x = rp2/(h1x*(h1x+h2x))
       c2x = -rp2/(h1x*h2x)
       c3x = rp2/(h2x*(h1x+h2x))

       h1y = yc - lgrid%coords(2,i,j-1,k)
       h2y = lgrid%coords(2,i,j+1,k) - yc

       c1y = rp2/(h1y*(h1y+h2y))
       c2y = -rp2/(h1y*h2y)
       c3y = rp2/(h2y*(h1y+h2y))

#if sdims_make==3
       h1z = zc - lgrid%coords(3,i,j,k-1)
       h2z = lgrid%coords(3,i,j,k+1) - zc

       c1z = rp2/(h1z*(h1z+h2z))
       c2z = -rp2/(h1z*h2z)
       c3z = rp2/(h2z*(h1z+h2z))
#endif

       tmp = rp1/(c2x+c2y+c2z)*(rp1-real(lgrid%is_solid(i,j,k),kind=rp))

       phicc = lgrid%s(i,j,k)

       lgrid%t(i,j,k) = tmp*( &
#if sdims_make==3
       c3z*lgrid%s(i,j,k+1)+c2z*phicc+c1z*lgrid%s(i,j,k-1) + &
#endif
       c3x*lgrid%s(i+1,j,k)+c2x*phicc+c1x*lgrid%s(i-1,j,k) + &
       c3y*lgrid%s(i,j+1,k)+c2y*phicc+c1y*lgrid%s(i,j-1,k) )

      end do
     end do
    end do

    num(1) = rp0
    den = rp0

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       
       tmp = lgrid%t(i,j,k)
       num(1) = num(1) + tmp*lgrid%s(i,j,k)
       den = den + tmp*tmp

      end do
     end do
    end do

    call mpi_allreduce(num, num_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)
    call mpi_allreduce(den, den_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

    wi = num_comm(1) / den_comm

    num(1) = rp0
 
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       
       lgrid%phi_cc(i,j,k) = lgrid%phi_cc(i,j,k) + alpha*lgrid%p(i,j,k) + wi*lgrid%s(i,j,k)
       
       lgrid%rgs(i,j,k) = lgrid%s(i,j,k) -  wi*lgrid%t(i,j,k)

       num(1) = num(1) + lgrid%r0hat(i,j,k)*lgrid%rgs(i,j,k) 

      end do
     end do
    end do

    call mpi_allreduce(num, num_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

    rhoim1 = rhoi
    rhoi = num_comm(1)
    beta = (rhoi / rhoim1) * ( alpha / wi )
 
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       
       lgrid%p(i,j,k) = lgrid%rgs(i,j,k) + beta*( lgrid%p(i,j,k) - wi*lgrid%v(i,j,k) )
 
      end do
     end do
    end do

    res_L2(1) = rp0

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       
       xc = lgrid%coords(1,i,j,k)
       yc = lgrid%coords(2,i,j,k)
#if sdims_make==3
       zc = lgrid%coords(3,i,j,k)
#endif
       h1x = xc - lgrid%coords(1,i-1,j,k)
       h2x = lgrid%coords(1,i+1,j,k) - xc
       c2x = -rp2/(h1x*h2x)

       h1y = yc - lgrid%coords(2,i,j-1,k)
       h2y = lgrid%coords(2,i,j+1,k) - yc
       c2y = -rp2/(h1y*h2y)

#if sdims_make==3
       h1z = zc - lgrid%coords(3,i,j,k-1)
       h2z = lgrid%coords(3,i,j,k+1) - zc
       c2z = -rp2/(h1z*h2z)
#endif

       tmp = rp1/(c2x+c2y+c2z)

       res_L2(1) = res_L2(1) + ( lgrid%rgs(i,j,k) /  &
       (tmp*rp4*CONST_PI*CONST_GRAV*max(abs(lgrid%prim(i_rho,i,j,k)-lgrid%gs_rho_bg),lgrid%gs_rho_bg)))**2

      end do
     end do
    end do

  call mpi_allreduce(res_L2, res_L2_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

  res_L2_comm(1) = sqrt(res_L2_comm(1) / real(nx1*nx2*nx3,kind=rp))
  iter = iter + 1

  end do

  if(mgrid%rankl==master_rank) then
    if(mod(lgrid%step,info_terminal_rate)==0) write(*,'(" >> gs: niter=",I8.8," | L2=",E9.3)') &
    iter, res_L2_comm(1)
  endif

  call mpi_barrier(mgrid%comm_cart,ierr)
  call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%phi_cc,.false.)

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
 
      ierr = lgrid%is_solid(i,j,k)
      tmp = -lgrid%phi_cc(i,j,k) 
 
      if(ierr==0) then
 
        if(lgrid%is_solid(i-1,j,k)==1) then
         lgrid%phi_cc(i-1,j,k) = rp2*lgrid%phi_x1(i,j,k)+tmp
        end if
 
        if(lgrid%is_solid(i+1,j,k)==1) then
         lgrid%phi_cc(i+1,j,k) = rp2*lgrid%phi_x1(i+1,j,k)+tmp
        end if
 
        if(lgrid%is_solid(i,j-1,k)==1) then
         lgrid%phi_cc(i,j-1,k) = rp2*lgrid%phi_x2(i,j,k)+tmp
        end if
 
        if(lgrid%is_solid(i,j+1,k)==1) then
         lgrid%phi_cc(i,j+1,k) = rp2*lgrid%phi_x2(i,j+1,k)+tmp
        end if
 
#if sdims_make==3
 
        if(lgrid%is_solid(i,j,k-1)==1) then
         lgrid%phi_cc(i,j,k-1) = rp2*lgrid%phi_x3(i,j,k)+tmp
        end if
 
        if(lgrid%is_solid(i,j,k+1)==1) then
         lgrid%phi_cc(i,j,k+1) = rp2*lgrid%phi_x3(i,j,k+1)+tmp
        end if
 
#endif
 
        xc = lgrid%coords(1,i,j,k)
        yc = lgrid%coords(2,i,j,k)
#if sdims_make==3
        zc = lgrid%coords(3,i,j,k)
#endif

        h1x = xc - lgrid%coords(1,i-1,j,k)
        h2x = lgrid%coords(1,i+1,j,k) - xc

        tmp = h1x+h2x
        c1x = -h1x/(h2x*tmp)
        c2x = (h1x-h2x)/(h1x*h2x)
        c3x = h2x/(h1x*tmp)

        h1y = yc - lgrid%coords(2,i,j-1,k)
        h2y = lgrid%coords(2,i,j+1,k) - yc

        tmp = h1y+h2y
        c1y = -h1y/(h2y*tmp)
        c2y = (h1y-h2y)/(h1y*h2y)
        c3y = h2y/(h1y*tmp)

#if sdims_make==3
        h1z = zc - lgrid%coords(3,i,j,k-1)
        h2z = lgrid%coords(3,i,j,k+1) - zc

        tmp = h1z+h2z
        c1z = -h1z/(h2z*tmp)
        c2z = (h1z-h2z)/(h1z*h2z)
        c3z = h2z/(h1z*tmp)
#endif

        tmp = lgrid%phi_cc(i,j,k)

        lgrid%grav(1,i,j,k) = c1x*lgrid%phi_cc(i+1,j,k)+c2x*tmp+c3x*lgrid%phi_cc(i-1,j,k)
        lgrid%grav(2,i,j,k) = c1y*lgrid%phi_cc(i,j+1,k)+c2y*tmp+c3y*lgrid%phi_cc(i,j-1,k)
#if sdims_make==3
        lgrid%grav(3,i,j,k) = c1z*lgrid%phi_cc(i,j,k+1)+c2z*tmp+c3z*lgrid%phi_cc(i,j,k-1)
#endif

      else

       lgrid%grav(1,i,j,k) = rp0
       lgrid%grav(2,i,j,k) = rp0
#if sdims_make==3
       lgrid%grav(3,i,j,k) = rp0
#endif

      endif

    end do
   end do
  end do

 end subroutine gravity_solver
 
#else

 subroutine gravity_solver(mgrid,lgrid)
  type(mpigrid), intent(inout) :: mgrid
  type(locgrid), intent(inout) :: lgrid

  integer :: i,j,k
  integer :: lx1,ux1,lx2,ux2,lx3,ux3
  integer :: ierr

  real(kind=rp) ::  rho, x, y, z, r, dV, dm, mass(1), mass_comm(1), dx, dy, dz
  real(kind=rp), dimension(3) :: rcom, rcom_comm, dr

  real(kind=rp) :: res_L2(1),phicc,res_L2_comm(1)

  integer :: iter

  real(kind=rp) :: h1x,h2x,h1y,h2y,xc,yc,c1x,c2x,c3x, & 
  c1y,c2y,c3y,num(1),den(1),num_comm(1),den_comm(1),tmp,c2z
  
  real(kind=rp) :: rhoi, rhoim1, alpha, wi, beta

#if sdims_make==3
  real(kind=rp) :: h1z,h2z,zc,c1z,c3z
#endif

#ifdef GS_QUADRUPOLE_BCS
  real(kind=rp), dimension(9) :: Q, Q_comm
  real(kind=rp), dimension(3,3) :: Qij, deltak
  real(kind=rp) :: r2, qdp
  integer :: ic,ii,jj
#endif

#ifdef GS_OCTUPOLE_BCS
  real(kind=rp), dimension(27) :: Qo, Qo_comm
  real(kind=rp), dimension(3,3,3) :: Qijk
  real(kind=rp) :: oct
  integer :: kk
#endif

  lx1 = mgrid%i1(1)
  lx2 = mgrid%i1(2)
  lx3 = mgrid%i1(3)
  ux1 = mgrid%i2(1)
  ux2 = mgrid%i2(2)
  ux3 = mgrid%i2(3)
 
  rcom(1) = rp0
  rcom(2) = rp0
  rcom(3) = rp0

  dr(1) = rp0
  dr(2) = rp0
  dr(3) = rp0

  mass(1) = rp0

  z = rp0

  dx = lgrid%dx1
  dy = lgrid%dx2
#if sdims_make==3
  dz = lgrid%dx3
#else
  dz = rp1
#endif

  dV = dz*dy*dz

#ifdef GS_QUADRUPOLE_BCS

  do i=1,9
   Q(i) = rp0
  end do

  do j=1,3
   do i=1,3
    deltak(i,j) = rp0
   end do
  end do

  deltak(1,1) = rp1
  deltak(2,2) = rp1
  deltak(3,3) = rp1

#ifdef GS_OCTUPOLE_BCS

  do i=1,27
     Qo(i) = rp0
  end do

#endif

#endif

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1

     x = lgrid%coords(1,i,j,k)
     y = lgrid%coords(2,i,j,k)
#if sdims_make==3
     z = lgrid%coords(3,i,j,k)
#endif

     rho = lgrid%prim(i_rho,i,j,k)-lgrid%gs_rho_bg

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
     dx = lgrid%coords_x1(1,i+1,j,k)-lgrid%coords_x1(1,i,j,k)
     dy = lgrid%coords_x2(2,i,j+1,k)-lgrid%coords_x2(2,i,j,k)
#if sdims_make==3
     dz = lgrid%coords_x3(3,i,j,k+1)-lgrid%coords_x3(3,i,j,k)
#endif
     dV = dx*dy*dz
#endif
     dm = rho*dV    
 
     rcom(1) = rcom(1) + x*dm
     rcom(2) = rcom(2) + y*dm
#if sdims_make==3
     rcom(3) = rcom(3) + z*dm
#endif
   
     mass(1) = mass(1) + dm

    end do
   end do
  end do
  
  call mpi_allreduce(rcom, rcom_comm, 3, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)
  call mpi_allreduce(mass, mass_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

  rcom(1) = rcom_comm(1)/mass_comm(1)
  rcom(2) = rcom_comm(2)/mass_comm(1)
  rcom(3) = rcom_comm(3)/mass_comm(1)

#ifdef GS_QUADRUPOLE_BCS
 
  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1

     x = lgrid%coords(1,i,j,k)
     y = lgrid%coords(2,i,j,k)
#if sdims_make==3
     z = lgrid%coords(3,i,j,k)
#endif

     rho = lgrid%prim(i_rho,i,j,k)-lgrid%gs_rho_bg

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
     dx = lgrid%coords_x1(1,i+1,j,k)-lgrid%coords_x1(1,i,j,k)
     dy = lgrid%coords_x2(2,i,j+1,k)-lgrid%coords_x2(2,i,j,k)
#if sdims_make==3
     dz = lgrid%coords_x3(3,i,j,k+1)-lgrid%coords_x3(3,i,j,k)
#endif
     dV = dx*dy*dz
#endif
     dm = rho*dV    

     dr(1) = x - rcom(1)
     dr(2) = y - rcom(2)
#if sdims_make==3
     dr(3) = z - rcom(3)
#endif
     r2 = dr(1)*dr(1) + dr(2)*dr(2) + dr(3)*dr(3)

     ic = 1
     do jj=1,3
      do ii=1,3
        Q(ic) = Q(ic) + rph*dm*(rp3*dr(ii)*dr(jj)-r2*deltak(ii,jj))
        ic = ic + 1
      end do
     end do

#ifdef GS_OCTUPOLE_BCS

     ic = 1
     do kk=1,3
      do jj=1,3
       do ii=1,3
        Qo(ic) = Qo(ic) + dm*( &
        rpth*dr(ii)*dr(jj)*dr(kk) - &
        rph*r2*(dr(ii)*deltak(jj,kk) + &
        dr(jj)*deltak(ii,kk) + &
        dr(kk)*deltak(ii,jj) &
        ))
        ic = ic + 1
       end do
     end do
    end do

#endif

    end do
   end do
  end do
  
  call mpi_allreduce(Q, Q_comm, 9, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

  ic = 1
  do jj=1,3
   do ii=1,3
    Qij(ii,jj) = Q_comm(ic)
    ic = ic + 1
   end do
  end do

#ifdef GS_OCTUPOLE_BCS
  
  call mpi_allreduce(Qo, Qo_comm, 27, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

  ic = 1
  do kk=1,3
   do jj=1,3
    do ii=1,3
     Qijk(ii,jj,kk) = Qo_comm(ic)
     ic = ic + 1
    end do
   end do
  end do

#endif

#endif

  if(mgrid%coords_dd(1)==0) then

   do k=lx3,ux3
    do j=lx2,ux2

     dr(1) = lgrid%coords_x1(1,lx1,j,k)-rcom(1)
     dr(2) = lgrid%coords_x1(2,lx1,j,k)-rcom(2)
#if sdims_make==3
     dr(3) = lgrid%coords_x1(3,lx1,j,k)-rcom(3)
#endif
     r = sqrt(dr(1)*dr(1)+dr(2)*dr(2)+dr(3)*dr(3))

#ifdef GS_QUADRUPOLE_BCS
     qdp = rp0
     do jj=1,3
      do ii=1,3
       qdp = qdp + Qij(ii,jj)*dr(ii)*dr(jj)
      end do
     end do
#ifdef GS_OCTUPOLE_BCS
     oct = rp0
     do kk=1,3
      do jj=1,3
       do ii=1,3
        oct = oct + Qijk(ii,jj,kk)*dr(ii)*dr(jj)*dr(kk)
       end do
      end do
     end do
#endif
#endif

     lgrid%phi_x1(lx1,j,k) = &
#ifdef GS_QUADRUPOLE_BCS
     -qdp*CONST_GRAV/(r*r*r*r*r) &
#ifdef GS_OCTUPOLE_BCS
     -oct*CONST_GRAV/(r*r*r*r*r*r*r) &
#endif             
#endif
     -CONST_GRAV*mass_comm(1)/r

    end do
   end do

  endif
 
  if(mgrid%coords_dd(1)==mgrid%bricks(1)-1) then

   do k=lx3,ux3
    do j=lx2,ux2

     dr(1) = lgrid%coords_x1(1,ux1+1,j,k)-rcom(1)
     dr(2) = lgrid%coords_x1(2,ux1+1,j,k)-rcom(2)
#if sdims_make==3
     dr(3) = lgrid%coords_x1(3,ux1+1,j,k)-rcom(3)
#endif
     r = sqrt(dr(1)*dr(1)+dr(2)*dr(2)+dr(3)*dr(3))

#ifdef GS_QUADRUPOLE_BCS
     qdp = rp0
     do jj=1,3
      do ii=1,3
       qdp = qdp + Qij(ii,jj)*dr(ii)*dr(jj)
      end do
     end do
#ifdef GS_OCTUPOLE_BCS
     oct = rp0
     do kk=1,3
      do jj=1,3
       do ii=1,3
        oct = oct + Qijk(ii,jj,kk)*dr(ii)*dr(jj)*dr(kk)
       end do
      end do
     end do
#endif
#endif

     lgrid%phi_x1(ux1+1,j,k) = &
#ifdef GS_QUADRUPOLE_BCS
     -qdp*CONST_GRAV/(r*r*r*r*r) &      
#ifdef GS_OCTUPOLE_BCS
     -oct*CONST_GRAV/(r*r*r*r*r*r*r) &
#endif             
#endif
     -CONST_GRAV*mass_comm(1)/r

    end do
   end do

  endif
  
  if(mgrid%coords_dd(2)==0) then

   do k=lx3,ux3
    do i=lx1,ux1

     dr(1) = lgrid%coords_x2(1,i,lx2,k)-rcom(1)
     dr(2) = lgrid%coords_x2(2,i,lx2,k)-rcom(2)
#if sdims_make==3
     dr(3) = lgrid%coords_x2(3,i,lx2,k)-rcom(3)
#endif
     r = sqrt(dr(1)*dr(1)+dr(2)*dr(2)+dr(3)*dr(3))

#ifdef GS_QUADRUPOLE_BCS
     qdp = rp0
     do jj=1,3
      do ii=1,3
       qdp = qdp + Qij(ii,jj)*dr(ii)*dr(jj)
      end do
     end do
#ifdef GS_OCTUPOLE_BCS
     oct = rp0
     do kk=1,3
      do jj=1,3
       do ii=1,3
        oct = oct + Qijk(ii,jj,kk)*dr(ii)*dr(jj)*dr(kk)
       end do
      end do
     end do
#endif
#endif

     lgrid%phi_x2(i,lx2,k) = &
#ifdef GS_QUADRUPOLE_BCS
     -qdp*CONST_GRAV/(r*r*r*r*r) &      
#ifdef GS_OCTUPOLE_BCS
     -oct*CONST_GRAV/(r*r*r*r*r*r*r) &
#endif             
#endif          
     -CONST_GRAV*mass_comm(1)/r

    end do
   end do

  endif
 
  if(mgrid%coords_dd(2)==mgrid%bricks(2)-1) then

   do k=lx3,ux3
    do i=lx1,ux1

     dr(1) = lgrid%coords_x2(1,i,ux2+1,k)-rcom(1)
     dr(2) = lgrid%coords_x2(2,i,ux2+1,k)-rcom(2)
#if sdims_make==3
     dr(3) = lgrid%coords_x2(3,i,ux2+1,k)-rcom(3)
#endif
     r = sqrt(dr(1)*dr(1)+dr(2)*dr(2)+dr(3)*dr(3))

#ifdef GS_QUADRUPOLE_BCS
     qdp = rp0
     do jj=1,3
      do ii=1,3
       qdp = qdp + Qij(ii,jj)*dr(ii)*dr(jj)
      end do
     end do
#ifdef GS_OCTUPOLE_BCS
     oct = rp0
     do kk=1,3
      do jj=1,3
       do ii=1,3
        oct = oct + Qijk(ii,jj,kk)*dr(ii)*dr(jj)*dr(kk)
       end do
      end do
     end do
#endif
#endif

     lgrid%phi_x2(i,ux2+1,k) = &
#ifdef GS_QUADRUPOLE_BCS
     -qdp*CONST_GRAV/(r*r*r*r*r) &      
#ifdef GS_OCTUPOLE_BCS
     -oct*CONST_GRAV/(r*r*r*r*r*r*r) &
#endif             
#endif       
     -CONST_GRAV*mass_comm(1)/r

    end do
   end do

  endif

#if sdims_make==3

  if(mgrid%coords_dd(3)==0) then

   do j=lx2,ux2
    do i=lx1,ux1

     dr(1) = lgrid%coords_x3(1,i,j,lx3)-rcom(1)
     dr(2) = lgrid%coords_x3(2,i,j,lx3)-rcom(2)
     dr(3) = lgrid%coords_x3(3,i,j,lx3)-rcom(3)
     r = sqrt(dr(1)*dr(1)+dr(2)*dr(2)+dr(3)*dr(3))

#ifdef GS_QUADRUPOLE_BCS
     qdp = rp0
     do jj=1,3
      do ii=1,3
       qdp = qdp + Qij(ii,jj)*dr(ii)*dr(jj)
      end do
     end do
#ifdef GS_OCTUPOLE_BCS
     oct = rp0
     do kk=1,3
      do jj=1,3
       do ii=1,3
        oct = oct + Qijk(ii,jj,kk)*dr(ii)*dr(jj)*dr(kk)
       end do
      end do
     end do
#endif
#endif

     lgrid%phi_x3(i,j,lx3) = &
#ifdef GS_QUADRUPOLE_BCS
     -qdp*CONST_GRAV/(r*r*r*r*r) &      
#ifdef GS_OCTUPOLE_BCS
     -oct*CONST_GRAV/(r*r*r*r*r*r*r) &
#endif             
#endif           
     -CONST_GRAV*mass_comm(1)/r

    end do
   end do

  endif
 
  if(mgrid%coords_dd(3)==mgrid%bricks(3)-1) then

   do j=lx2,ux2
    do i=lx1,ux1

     dr(1) = lgrid%coords_x3(1,i,j,ux3+1)-rcom(1)
     dr(2) = lgrid%coords_x3(2,i,j,ux3+1)-rcom(2)
     dr(3) = lgrid%coords_x3(3,i,j,ux3+1)-rcom(3)
     r = sqrt(dr(1)*dr(1)+dr(2)*dr(2)+dr(3)*dr(3))

#ifdef GS_QUADRUPOLE_BCS
     qdp = rp0
     do jj=1,3
      do ii=1,3
       qdp = qdp + Qij(ii,jj)*dr(ii)*dr(jj)
      end do
     end do
#ifdef GS_OCTUPOLE_BCS
     oct = rp0
     do kk=1,3
      do jj=1,3
       do ii=1,3
        oct = oct + Qijk(ii,jj,kk)*dr(ii)*dr(jj)*dr(kk)
       end do
      end do
     end do
#endif
#endif

     lgrid%phi_x3(i,j,ux3+1) = &
#ifdef GS_QUADRUPOLE_BCS
     -qdp*CONST_GRAV/(r*r*r*r*r) &      
#ifdef GS_OCTUPOLE_BCS
     -oct*CONST_GRAV/(r*r*r*r*r*r*r) &
#endif             
#endif                   
     -CONST_GRAV*mass_comm(1)/r

    end do
   end do

  endif

#endif

  call mpi_barrier(mgrid%comm_cart,ierr)
  call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%phi_cc,.false.)
  call fill_ghost_potential(mgrid,lgrid)
 
  c2z = rp0
 
  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
            
      xc = lgrid%coords(1,i,j,k)
      yc = lgrid%coords(2,i,j,k)
#if sdims_make==3
      zc = lgrid%coords(3,i,j,k)
#endif
      h1x = xc - lgrid%coords(1,i-1,j,k)
      h2x = lgrid%coords(1,i+1,j,k) - xc

      c1x = rp2/(h1x*(h1x+h2x))
      c2x = -rp2/(h1x*h2x)
      c3x = rp2/(h2x*(h1x+h2x))

      h1y = yc - lgrid%coords(2,i,j-1,k)
      h2y = lgrid%coords(2,i,j+1,k) - yc

      c1y = rp2/(h1y*(h1y+h2y))
      c2y = -rp2/(h1y*h2y)
      c3y = rp2/(h2y*(h1y+h2y))

#if sdims_make==3
      h1z = zc - lgrid%coords(3,i,j,k-1)
      h2z = lgrid%coords(3,i,j,k+1) - zc

      c1z = rp2/(h1z*(h1z+h2z))
      c2z = -rp2/(h1z*h2z)
      c3z = rp2/(h2z*(h1z+h2z))
#endif

      tmp = rp1/(c2x+c2y+c2z)

      phicc = lgrid%phi_cc(i,j,k)

      lgrid%rgs(i,j,k) = tmp*(rp4*CONST_PI*CONST_GRAV*(lgrid%prim(i_rho,i,j,k) - lgrid%gs_rho_bg) - ( &
#if sdims_make==3
      c3z*lgrid%phi_cc(i,j,k+1)+c2z*phicc+c1z*lgrid%phi_cc(i,j,k-1) + &
#endif
      c3x*lgrid%phi_cc(i+1,j,k)+c2x*phicc+c1x*lgrid%phi_cc(i-1,j,k) + &
      c3y*lgrid%phi_cc(i,j+1,k)+c2y*phicc+c1y*lgrid%phi_cc(i,j-1,k) ) )

    end do
   end do
  end do

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
            
      tmp = lgrid%rgs(i,j,k)
      lgrid%p(i,j,k) = tmp
      lgrid%v(i,j,k) = rp0
      lgrid%r0hat(i,j,k) = tmp

    end do
   end do
  end do

  res_L2(1) = rp0

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
       
      xc = lgrid%coords(1,i,j,k)
      yc = lgrid%coords(2,i,j,k)
#if sdims_make==3
      zc = lgrid%coords(3,i,j,k)
#endif
      h1x = xc - lgrid%coords(1,i-1,j,k)
      h2x = lgrid%coords(1,i+1,j,k) - xc
      c2x = -rp2/(h1x*h2x)

      h1y = yc - lgrid%coords(2,i,j-1,k)
      h2y = lgrid%coords(2,i,j+1,k) - yc
      c2y = -rp2/(h1y*h2y)

#if sdims_make==3
      h1z = zc - lgrid%coords(3,i,j,k-1)
      h2z = lgrid%coords(3,i,j,k+1) - zc
      c2z = -rp2/(h1z*h2z)
#endif

      tmp = rp1/(c2x+c2y+c2z)

      res_L2(1) = res_L2(1) + ( lgrid%r0hat(i,j,k) /  &
      (tmp*rp4*CONST_PI*CONST_GRAV*max(abs(lgrid%prim(i_rho,i,j,k)-lgrid%gs_rho_bg),lgrid%gs_rho_bg)))**2

    end do
   end do
  end do

  call mpi_allreduce(res_L2, res_L2_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

  res_L2_comm(1) = sqrt(res_L2_comm(1) / real(nx1*nx2*nx3,kind=rp))

  num(1) = rp0

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
  
      tmp = lgrid%r0hat(i,j,k)
      num(1) = num(1) + tmp*tmp

    end do
   end do
  end do

  call mpi_allreduce(num, num_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

  rhoi = num_comm(1)

  iter = 0

  do while(res_L2_comm(1) > gs_tol)

    call mpi_barrier(mgrid%comm_cart,ierr)
    call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3,1,lgrid%p,.false.)
    
    if(mgrid%coords_dd(1)==0) then
      do k=lx3,ux3
       do j=lx2,ux2
         lgrid%p(lx1-1,j,k) = -lgrid%p(lx1,j,k)
       end do
      end do
    end if
    
    if(mgrid%coords_dd(1)==mgrid%bricks(1)-1) then
      do k=lx3,ux3
       do j=lx2,ux2
         lgrid%p(ux1+1,j,k) = -lgrid%p(ux1,j,k)
       end do
      end do
    end if
    
    if(mgrid%coords_dd(2)==0) then
      do k=lx3,ux3
       do i=lx1,ux1
         lgrid%p(i,lx2-1,k) = -lgrid%p(i,lx2,k)
       end do
      end do
    end if
    
    if(mgrid%coords_dd(2)==mgrid%bricks(2)-1) then
      do k=lx3,ux3
       do i=lx1,ux1
         lgrid%p(i,ux2+1,k) = -lgrid%p(i,ux2,k)
       end do
      end do
    end if

#if sdims_make==3
    
    if(mgrid%coords_dd(3)==0) then
      do j=lx2,ux2
       do i=lx1,ux1
         lgrid%p(i,j,lx3-1) = -lgrid%p(i,j,lx3)
       end do
      end do
    end if
    
    if(mgrid%coords_dd(3)==mgrid%bricks(3)-1) then
      do j=lx2,ux2
       do i=lx1,ux1
         lgrid%p(i,j,ux3+1) = -lgrid%p(i,j,ux3)
       end do
      end do
    end if

#endif

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1

       xc = lgrid%coords(1,i,j,k)
       yc = lgrid%coords(2,i,j,k)
#if sdims_make==3
       zc = lgrid%coords(3,i,j,k)
#endif
       h1x = xc - lgrid%coords(1,i-1,j,k)
       h2x = lgrid%coords(1,i+1,j,k) - xc

       c1x = rp2/(h1x*(h1x+h2x))
       c2x = -rp2/(h1x*h2x)
       c3x = rp2/(h2x*(h1x+h2x))

       h1y = yc - lgrid%coords(2,i,j-1,k)
       h2y = lgrid%coords(2,i,j+1,k) - yc

       c1y = rp2/(h1y*(h1y+h2y))
       c2y = -rp2/(h1y*h2y)
       c3y = rp2/(h2y*(h1y+h2y))

#if sdims_make==3
       h1z = zc - lgrid%coords(3,i,j,k-1)
       h2z = lgrid%coords(3,i,j,k+1) - zc

       c1z = rp2/(h1z*(h1z+h2z))
       c2z = -rp2/(h1z*h2z)
       c3z = rp2/(h2z*(h1z+h2z))
#endif

       tmp = rp1/(c2x+c2y+c2z)

       phicc = lgrid%p(i,j,k)

       lgrid%v(i,j,k) = tmp*( &
#if sdims_make==3
       c3z*lgrid%p(i,j,k+1)+c2z*phicc+c1z*lgrid%p(i,j,k-1) + &
#endif
       c3x*lgrid%p(i+1,j,k)+c2x*phicc+c1x*lgrid%p(i-1,j,k) + &
       c3y*lgrid%p(i,j+1,k)+c2y*phicc+c1y*lgrid%p(i,j-1,k) )

      end do
     end do
    end do

    num(1) = rp0

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
 
       num(1) = num(1) + lgrid%r0hat(i,j,k)*lgrid%v(i,j,k)

      end do
     end do
    end do

    call mpi_allreduce(num, num_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

    alpha = rhoi / num_comm(1)

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1

       lgrid%s(i,j,k) = lgrid%rgs(i,j,k) - alpha*lgrid%v(i,j,k)

      end do
     end do
    end do

    call mpi_barrier(mgrid%comm_cart,ierr)
    call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3,1,lgrid%s,.false.)
    
    if(mgrid%coords_dd(1)==0) then
      do k=lx3,ux3
       do j=lx2,ux2
         lgrid%s(lx1-1,j,k) = -lgrid%s(lx1,j,k)
       end do
      end do
    end if
    
    if(mgrid%coords_dd(1)==mgrid%bricks(1)-1) then
      do k=lx3,ux3
       do j=lx2,ux2
         lgrid%s(ux1+1,j,k) = -lgrid%s(ux1,j,k)
       end do
      end do
    end if
    
    if(mgrid%coords_dd(2)==0) then
      do k=lx3,ux3
       do i=lx1,ux1
         lgrid%s(i,lx2-1,k) = -lgrid%s(i,lx2,k)
       end do
      end do
    end if
    
    if(mgrid%coords_dd(2)==mgrid%bricks(2)-1) then
      do k=lx3,ux3
       do i=lx1,ux1
         lgrid%s(i,ux2+1,k) = -lgrid%s(i,ux2,k)
       end do
      end do
    end if

#if sdims_make==3
    
    if(mgrid%coords_dd(3)==0) then
      do j=lx2,ux2
       do i=lx1,ux1
         lgrid%s(i,j,lx3-1) = -lgrid%s(i,j,lx3)
       end do
      end do
    end if
    
    if(mgrid%coords_dd(3)==mgrid%bricks(3)-1) then
      do j=lx2,ux2
       do i=lx1,ux1
         lgrid%s(i,j,ux3+1) = -lgrid%s(i,j,ux3)
       end do
      end do
    end if

#endif

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1

       xc = lgrid%coords(1,i,j,k)
       yc = lgrid%coords(2,i,j,k)
#if sdims_make==3
       zc = lgrid%coords(3,i,j,k)
#endif
       h1x = xc - lgrid%coords(1,i-1,j,k)
       h2x = lgrid%coords(1,i+1,j,k) - xc

       c1x = rp2/(h1x*(h1x+h2x))
       c2x = -rp2/(h1x*h2x)
       c3x = rp2/(h2x*(h1x+h2x))

       h1y = yc - lgrid%coords(2,i,j-1,k)
       h2y = lgrid%coords(2,i,j+1,k) - yc

       c1y = rp2/(h1y*(h1y+h2y))
       c2y = -rp2/(h1y*h2y)
       c3y = rp2/(h2y*(h1y+h2y))

#if sdims_make==3
       h1z = zc - lgrid%coords(3,i,j,k-1)
       h2z = lgrid%coords(3,i,j,k+1) - zc

       c1z = rp2/(h1z*(h1z+h2z))
       c2z = -rp2/(h1z*h2z)
       c3z = rp2/(h2z*(h1z+h2z))
#endif

       tmp = rp1/(c2x+c2y+c2z)

       phicc = lgrid%s(i,j,k)

       lgrid%t(i,j,k) = tmp*( &
#if sdims_make==3
       c3z*lgrid%s(i,j,k+1)+c2z*phicc+c1z*lgrid%s(i,j,k-1) + &
#endif
       c3x*lgrid%s(i+1,j,k)+c2x*phicc+c1x*lgrid%s(i-1,j,k) + &
       c3y*lgrid%s(i,j+1,k)+c2y*phicc+c1y*lgrid%s(i,j-1,k) )

      end do
     end do
    end do

    num(1) = rp0
    den(1) = rp0

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       
       tmp = lgrid%t(i,j,k)
       num(1) = num(1) + tmp*lgrid%s(i,j,k)
       den(1) = den(1) + tmp*tmp

      end do
     end do
    end do

    call mpi_allreduce(num, num_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)
    call mpi_allreduce(den, den_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

    wi = num_comm(1) / den_comm(1)

    num(1) = rp0
 
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       
       lgrid%phi_cc(i,j,k) = lgrid%phi_cc(i,j,k) + alpha*lgrid%p(i,j,k) + wi*lgrid%s(i,j,k)
       
       lgrid%rgs(i,j,k) = lgrid%s(i,j,k) -  wi*lgrid%t(i,j,k)

       num(1) = num(1) + lgrid%r0hat(i,j,k)*lgrid%rgs(i,j,k) 

      end do
     end do
    end do

    call mpi_allreduce(num, num_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

    rhoim1 = rhoi
    rhoi = num_comm(1)
    beta = (rhoi / rhoim1) * ( alpha / wi )
 
    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       
       lgrid%p(i,j,k) = lgrid%rgs(i,j,k) + beta*( lgrid%p(i,j,k) - wi*lgrid%v(i,j,k) )
 
      end do
     end do
    end do

    res_L2(1) = rp0

    do k=lx3,ux3
     do j=lx2,ux2
      do i=lx1,ux1
       
       xc = lgrid%coords(1,i,j,k)
       yc = lgrid%coords(2,i,j,k)
#if sdims_make==3
       zc = lgrid%coords(3,i,j,k)
#endif
       h1x = xc - lgrid%coords(1,i-1,j,k)
       h2x = lgrid%coords(1,i+1,j,k) - xc
       c2x = -rp2/(h1x*h2x)

       h1y = yc - lgrid%coords(2,i,j-1,k)
       h2y = lgrid%coords(2,i,j+1,k) - yc
       c2y = -rp2/(h1y*h2y)

#if sdims_make==3
       h1z = zc - lgrid%coords(3,i,j,k-1)
       h2z = lgrid%coords(3,i,j,k+1) - zc
       c2z = -rp2/(h1z*h2z)
#endif

       tmp = rp1/(c2x+c2y+c2z)

       res_L2(1) = res_L2(1) + ( lgrid%rgs(i,j,k) /  &
       (tmp*rp4*CONST_PI*CONST_GRAV*max(abs(lgrid%prim(i_rho,i,j,k)-lgrid%gs_rho_bg),lgrid%gs_rho_bg)))**2

      end do
     end do
    end do

  call mpi_allreduce(res_L2, res_L2_comm, 1, MPI_RP, MPI_SUM, mgrid%comm_cart, ierr)

  res_L2_comm(1) = sqrt(res_L2_comm(1) / real(nx1*nx2*nx3,kind=rp))
  iter = iter + 1

  end do

  if(mgrid%rankl==master_rank) then
    if(mod(lgrid%step,info_terminal_rate)==0) write(*,'(" >> gs: niter=",I8.8," | L2=",E9.3)') &
    iter, res_L2_comm(1)
  endif

  call mpi_barrier(mgrid%comm_cart,ierr)
  call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%phi_cc,.false.)
  call fill_ghost_potential(mgrid,lgrid)

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
       
      xc = lgrid%coords(1,i,j,k)
      yc = lgrid%coords(2,i,j,k)
#if sdims_make==3
      zc = lgrid%coords(3,i,j,k)
#endif

      h1x = xc - lgrid%coords(1,i-1,j,k)
      h2x = lgrid%coords(1,i+1,j,k) - xc

      tmp = h1x+h2x
      c1x = -h1x/(h2x*tmp)
      c2x = (h1x-h2x)/(h1x*h2x)
      c3x = h2x/(h1x*tmp)

      h1y = yc - lgrid%coords(2,i,j-1,k)
      h2y = lgrid%coords(2,i,j+1,k) - yc

      tmp = h1y+h2y
      c1y = -h1y/(h2y*tmp)
      c2y = (h1y-h2y)/(h1y*h2y)
      c3y = h2y/(h1y*tmp)

#if sdims_make==3
      h1z = zc - lgrid%coords(3,i,j,k-1)
      h2z = lgrid%coords(3,i,j,k+1) - zc

      tmp = h1z+h2z
      c1z = -h1z/(h2z*tmp)
      c2z = (h1z-h2z)/(h1z*h2z)
      c3z = h2z/(h1z*tmp)
#endif

      tmp = lgrid%phi_cc(i,j,k)

      lgrid%grav(1,i,j,k) = c1x*lgrid%phi_cc(i+1,j,k)+c2x*tmp+c3x*lgrid%phi_cc(i-1,j,k)
      lgrid%grav(2,i,j,k) = c1y*lgrid%phi_cc(i,j+1,k)+c2y*tmp+c3y*lgrid%phi_cc(i,j-1,k)
#if sdims_make==3
      lgrid%grav(3,i,j,k) = c1z*lgrid%phi_cc(i,j,k+1)+c2z*tmp+c3z*lgrid%phi_cc(i,j,k-1)
#endif

    end do
   end do
  end do

 end subroutine gravity_solver

 subroutine fill_ghost_potential(mgrid,lgrid)
  type(mpigrid), intent(inout) :: mgrid
  type(locgrid), intent(inout) :: lgrid

  integer :: i,j,k
  integer :: lx1,ux1,lx2,ux2,lx3,ux3

  lx1 = mgrid%i1(1)
  lx2 = mgrid%i1(2)
  lx3 = mgrid%i1(3)
  ux1 = mgrid%i2(1)
  ux2 = mgrid%i2(2)
  ux3 = mgrid%i2(3)

  if(mgrid%coords_dd(1)==0) then
   do k=lx3,ux3
    do j=lx2,ux2
     lgrid%phi_cc(lx1-1,j,k) = rp2*lgrid%phi_x1(lx1,j,k) - lgrid%phi_cc(lx1,j,k)
    end do
   end do  
  endif

  if(mgrid%coords_dd(1)==mgrid%bricks(1)-1) then
   do k=lx3,ux3
    do j=lx2,ux2
     lgrid%phi_cc(ux1+1,j,k) = rp2*lgrid%phi_x1(ux1+1,j,k) - lgrid%phi_cc(ux1,j,k)
    end do
   end do  
  endif

  if(mgrid%coords_dd(2)==0) then
   do k=lx3,ux3
    do i=lx1,ux1
     lgrid%phi_cc(i,lx2-1,k) = rp2*lgrid%phi_x2(i,lx2,k) - lgrid%phi_cc(i,lx2,k)
    end do
   end do  
  endif

  if(mgrid%coords_dd(2)==mgrid%bricks(2)-1) then
   do k=lx3,ux3
    do i=lx1,ux1
     lgrid%phi_cc(i,ux2+1,k) = rp2*lgrid%phi_x2(i,ux2+1,k) - lgrid%phi_cc(i,ux2,k)
    end do
   end do  
  endif

#if sdims_make==3

  if(mgrid%coords_dd(3)==0) then
   do j=lx2,ux2
    do i=lx1,ux1
     lgrid%phi_cc(i,j,lx3-1) = rp2*lgrid%phi_x3(i,j,lx3) - lgrid%phi_cc(i,j,lx3)
    end do
   end do  
  endif

  if(mgrid%coords_dd(3)==mgrid%bricks(3)-1) then
   do j=lx2,ux2
    do i=lx1,ux1
     lgrid%phi_cc(i,j,ux3+1) = rp2*lgrid%phi_x3(i,j,ux3+1) - lgrid%phi_cc(i,j,ux3)
    end do
   end do  
  endif

#endif

 end subroutine fill_ghost_potential

#endif
#endif
#endif

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! RADIATIVE DIFFUSION (SUPER TIME STEPPER)
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#ifdef USE_TIMMES_KAPPA

 subroutine compute_timmes_kappa(lgrid)
   type(locgrid), intent(inout) :: lgrid

   real(kind=rp) :: rho,T,inv_abar,ye,tmp1,abar,zbar,&
   pep,eta,xf,opac

   integer :: i,j,k,iv

   do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
    do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
     do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

        rho = lgrid%prim(i_rho,i,j,k)
        T = lgrid%temp(i,j,k)

        inv_abar = rp0
        ye = rp0
        do iv=1,nspecies
         tmp1 = lgrid%prim(i_as1+iv-1,i,j,k)/lgrid%A(iv)
         inv_abar = inv_abar + tmp1
         ye = ye + tmp1*lgrid%Z(iv)
        end do
        abar = rp1/inv_abar
        zbar = abar*ye

#ifdef USE_WB
        if(rho*ye>rhol_eos) then
#endif 

        call  helm_rhoT_given_extra(rho,T,abar,zbar,pep,eta,xf)

        call sig99( &
        T, &
        rho, &
        lgrid%prim(i_as1:i_as1+nspecies-1,i,j,k), &
        lgrid%Z(:), &
        lgrid%A(:), &
        nspecies, &
        pep, &
        xf, &
        eta, &
        opac)

        lgrid%kappa(i,j,k) = opac

#ifdef USE_WB
        endif
#endif 


     end do
    end do
   end do

 end subroutine compute_timmes_kappa

 !This implementation is based on sig99.tar.xz available at https://cococubed.com/code_pages/kap.shtml (last accessed 10 April 2026).
 subroutine sig99(temp,den,xmass,zion,aion,ionmax,pep,xne,eta,opac)

! this routine approximates an opacity.

! input:
! temp   = temperature temp (in K)
! den    = density den (in g/cm**3)
! ionmax = number of isotopes in the composition
! xmass  = mass fractions of the composition
! zion   = number of protons in each isotope (charge of each isotope)
! aion   = number of protons + neutrons in each isotope (atomic weight)
! pep    = electron-positron pressure (in erg/cm**3)
! xne    = electron-positron number density (in 1/cm**3)
! eta    = electron degeneracy parameter (chemical potential / k T)

! output:
! opac   = total opacity in cm**2/gr

! -------------------------------------------------------------------

  real(kind=rp), intent(in) :: temp, den
  real(kind=rp), intent(in) :: xmass(1:nspecies), zion(1:nspecies)
  real(kind=rp), intent(in) :: aion(1:nspecies)
  real(kind=rp), intent(in) :: pep, xne, eta
  integer,       intent(in) :: ionmax

  real(kind=rp), intent(inout) :: opac

! -------------------------------------------------------------------
! local variables

  integer :: iz, i
  real(kind=rp) :: xmu,t6,orad,ocond,ytot1,ymass,abar,zbar,w(6),xh, &
                   xhe,xz,xkc,xkap,xkb,xka,dbar,oiben1,d0log,xka1, &
                   xkw,xkaz,dbar1log,dbar2log,oiben2,t4,t4r,t44, &
                   t45,t46,ck1,ck3,ck2,ck4,ck5,ck6,xkcx,xkcy, &
                   xkcz,ochrs,th,fact,facetax,faceta,ocompt,tcut, &
                   cutfac,xkf,dlog10,zdel,zdell10,eta0,eta02,thpl, &
                   thpla,cfac1,cfac2,oh,pefac,pefacl,pefacal,dnefac, &
                   wpar2,walf,walf10,thx,thy,thc,farg,ffac,xmas,ymas, &
                   wfac,cint,vie,cie,tpe,yg,xrel,beta2,jy,vee,cee, &
                   ov1,ov,xdum,ydum,zdum

! -------------------------------------------------------------------
! constants

  real(kind=rp), parameter :: &
    third   = 1.0_rp/3.0_rp, &
    twoth   = 2.0_rp*third, &
    pi      = 3.14159265358979323846_rp, &
    rt3     = 1.7320508075688772_rp, &
    avo     = 6.0221367e23_rp, &
    c       = 2.99792458e10_rp, &
    ssol    = 5.67050407222e-5_rp, &
    asol    = 4.0_rp*ssol/c, &
    zbound  = 0.1_rp, &
    t7peek  = 1.0e20_rp, &
    k2c     = (4.0_rp/3.0_rp)*asol*c, &
    meff    = 1.194648642401440e-10_rp, &
    weid    = 6.884326138694269e-5_rp, &
    iec     = 1.754582332329132e16_rp, &
    xec     = 4.309054377592449e-7_rp, &
    con2    = 1.07726359439811217e-7_rp

  real(kind=rp), parameter :: &
    t6_switch1 = 1.0_rp, &
    t6_switch2 = 1.5_rp

  real(kind=rp) :: drel, drel10, drelim

! -------------------------------------------------------------------
! initialize

  opac   = 0.0_rp
  orad   = 0.0_rp
  ocond  = 0.0_rp
  oiben1 = 0.0_rp
  oiben2 = 0.0_rp
  ochrs  = 0.0_rp
  oh     = 0.0_rp
  ov     = 0.0_rp
  zbar   = 0.0_rp
  ytot1  = 0.0_rp
  w      = 0.0_rp

! -------------------------------------------------------------------
! composition

  do i = 1, ionmax
    iz      = min(3, max(1, int(zion(i))))
    ymass   = xmass(i)/aion(i)
    w(iz)   = w(iz)   + xmass(i)
    w(iz+3) = w(iz+3) + zion(i)*zion(i)*ymass
    zbar    = zbar + zion(i)*ymass
    ytot1   = ytot1 + ymass
  end do

  abar = 1.0_rp/ytot1
  zbar = zbar*abar
  t6   = temp*1.0e-6_rp
  xh   = w(1)
  xhe  = w(2)
  xz   = w(3)

! -------------------------------------------------------------------
! radiative opacity (Iben 1975)

  if (xh < 1.0e-5_rp) then
    xmu    = max(1.0e-99_rp, w(4)+w(5)+w(6)-1.0_rp)
    xkc    = (2.019e-4_rp*den/t6**1.7_rp)**2.425_rp
    xkap   = 1.0_rp + xkc*(1.0_rp + xkc/24.55_rp)
    xkb    = 3.86_rp + 0.252_rp*sqrt(xmu) + 0.018_rp*xmu
    xka    = 3.437_rp*(1.25_rp + 0.488_rp*sqrt(xmu) + 0.092_rp*xmu)
    dbar   = exp(-xka + xkb*log(t6))
    oiben1 = xkap*(den/dbar)**0.67_rp
  end if

  if (.not.((xh >= 1.0e-5_rp) .and. (t6 < t6_switch1)) .and. &
      .not.((xh < 1.0e-5_rp) .and. (xz > zbound))) then

    if (t6 > t6_switch1) then
      d0log = -(3.868_rp + 0.806_rp*xh) + 1.8_rp*log(t6)
    else
      d0log = -(3.868_rp + 0.806_rp*xh) + (3.42_rp - 0.52_rp*xh)*log(t6)
    end if

    xka1 = 2.809_rp*exp(-(1.74_rp - 0.755_rp*xh) * &
           (log10(t6) - 0.22_rp + 0.1375_rp*xh)**2)

    xkw  = 4.05_rp*exp(-(0.306_rp - 0.04125_rp*xh) * &
           (log10(t6) - 0.18_rp + 0.1625_rp*xh)**2)

    xkaz = 50.0_rp*xz*xka1 * exp(-0.5206_rp*((log(den)-d0log)/xkw)**2)

    dbar2log = -(4.283_rp + 0.7196_rp*xh) + 3.86_rp*log(t6)
    dbar1log = -5.296_rp + 4.833_rp*log(t6)
    if (dbar2log < dbar1log) dbar1log = dbar2log

    oiben2 = (den/exp(dbar1log))**0.67_rp * exp(xkaz)
  end if

! -------------------------------------------------------------------
! Christy opacity (1966)

  if (t6 < t6_switch2 .and. xh >= 1.0e-5_rp) then
    t4    = temp*1.0e-4_rp
    t4r   = sqrt(t4)
    t44   = t4**4
    t45   = t44*t4
    t46   = t45*t4

    ck1   = 2.0e6_rp/t44 + 2.1_rp*t46
    ck3   = 4.0e-3_rp/t44 + 2.0e-4_rp/den**0.25_rp
    ck2   = 4.5_rp*t46 + 1.0_rp/(t4*ck3)
    ck4   = 1.4e3_rp*t4 + t46
    ck5   = 1.0e6_rp + 0.1_rp*t46
    ck6   = 20.0_rp*t4 + 5.0_rp*t44 + t45

    xkcx  = xh*(t4r/ck1 + 1.0_rp/ck2)
    xkcy  = xhe*(1.0_rp/ck4 + 1.5_rp/ck5)
    xkcz  = xz*(t4r/ck6)

    ochrs = pep*(xkcx + xkcy + xkcz)
  end if

! -------------------------------------------------------------------
! combine radiative opacities

  if (xh >= 1.0e-5_rp) then
    if (t6 < t6_switch1) then
      orad = ochrs
    else if (t6 <= t6_switch2) then
      zdum = 1.0_rp/(t6_switch1 - t6_switch2)
      xdum = (t6 - t6_switch2)*zdum
      ydum = (t6 - t6_switch1)*zdum
      orad = ochrs*xdum + oiben2*ydum
    else
      orad = oiben2
    end if
  else
    if (xz > zbound) then
      orad = oiben1
    else
      orad = oiben1*(xz/zbound) + oiben2*((zbound-xz)/zbound)
    end if
  end if

! -------------------------------------------------------------------
! Compton scattering

  th      = min(511.0_rp, temp*8.617e-8_rp)
  fact    = 1.0_rp + 2.75e-2_rp*th - 4.88e-5_rp*th*th
  facetax = 1.0e100_rp
  if (eta <= 500.0_rp) facetax = exp(0.522_rp*eta - 1.563_rp)
  faceta  = 1.0_rp + facetax
  ocompt  = 6.65205e-25_rp/(fact*faceta)*xne/den
  orad    = orad + ocompt

! -------------------------------------------------------------------
! low-temperature cutoff

  tcut = con2*sqrt(xne)
  if (temp < tcut) then
    if (tcut > 200.0_rp*temp) then
      orad = orad*2.658e86_rp
    else
      cutfac = exp(tcut/temp - 1.0_rp)
      orad   = orad*cutfac
    end if
  end if

! molecular opacity fudge

  xkf  = t7peek*den*(temp*1.0e-7_rp)**4
  orad = xkf*orad/(xkf + orad)

! -------------------------------------------------------------------
! conductivity: non-degenerate (Iben 1975)

  dlog10 = log10(den)
  drel   = 2.4e-7_rp*zbar/abar*temp*sqrt(temp)
  drel10 = log10(drel)
  drelim = drel10 + 1.0_rp

  if (dlog10 < drelim) then
    zdel    = xne/(avo*t6*sqrt(t6))
    zdell10 = log10(zdel)
    eta0    = exp(-1.20322_rp + twoth*log(zdel))
    eta02   = eta0*eta0

    if (zdell10 < 0.645_rp) then
      thpl = -7.5668_rp + log(zdel*(1.0_rp + 0.024417_rp*zdel))
    else if (zdell10 < 2.5_rp) then
      thpl = -7.58110_rp + log(zdel*(1.0_rp + 0.02804_rp*zdel))
      if (zdell10 >= 2.0_rp) then
        thpla = thpl
        thpl  = -11.0742_rp + log(zdel**2*(1.0_rp + 9.376_rp/eta02))
        thpl  = 2.0_rp*((2.5_rp-zdell10)*thpla + (zdell10-2.0_rp)*thpl)
      end if
    else
      thpl = -11.0742_rp + log(zdel**2*(1.0_rp + 9.376_rp/eta02))
    end if

    if (zdell10 < 2.0_rp) then
      pefac = 1.0_rp + 0.021876_rp*zdel
      if (zdell10 > 1.5_rp) then
        pefacal = log(pefac)
        pefacl  = log(0.4_rp*eta0 + 1.64496_rp/eta0)
        cfac1   = 2.0_rp - zdell10
        cfac2   = zdell10 - 1.5_rp
        pefac   = exp(2.0_rp*(cfac1*pefacal + cfac2*pefacl))
      end if
    else
      pefac = 0.4_rp*eta0 + 1.64496_rp/eta0
    end if

    if (zdel < 40.0_rp) then
      dnefac = 1.0_rp + zdel*(3.4838e-4_rp*zdel - 2.8966e-2_rp)
    else
      dnefac = 1.5_rp/eta0*(1.0_rp - 0.8225_rp/eta02)
    end if

    wpar2 = 9.24735e-3_rp*zdel * &
            (den*avo*(w(4)+w(5)+w(6))/xne + dnefac) / &
            (sqrt(t6)*pefac)

    walf   = log(wpar2)
    walf10 = log10(wpar2)

    if (walf10 <= -3.0_rp) then
      thx = exp(2.413_rp - 0.124_rp*walf)
    else if (walf10 <= -1.0_rp) then
      thx = exp(0.299_rp - walf*(0.745_rp + 0.0456_rp*walf))
    else
      thx = exp(0.426_rp - 0.558_rp*walf)
    end if

    if (walf10 <= -3.0_rp) then
      thy = exp(2.158_rp - 0.111_rp*walf)
    else if (walf10 <= 0.0_rp) then
      thy = exp(0.553_rp - walf*(0.55_rp + 0.0299_rp*walf))
    else
      thy = exp(0.553_rp - 0.6_rp*walf)
    end if

    if (walf10 <= -2.5_rp) then
      thc = exp(2.924_rp - 0.1_rp*walf)
    else if (walf10 <= 0.5_rp) then
      thc = exp(1.6740_rp - walf*(0.511_rp + 0.0338_rp*walf))
    else
      thc = exp(1.941_rp - 0.785_rp*walf)
    end if

    oh = (xh*thx + xhe*thy + w(6)*third*thc)/(t6*exp(thpl))
  end if

! -------------------------------------------------------------------
! degenerate conductivity

  if (dlog10 > drel10) then
    xmas   = meff*xne**third
    ymas   = sqrt(1.0_rp + xmas*xmas)
    wfac   = weid*temp/ymas*xne
    cint   = 1.0_rp

    vie = iec*zbar*ymas*cint
    cie = wfac/vie

    tpe   = xec*sqrt(xne/ymas)
    yg    = rt3*tpe/temp
    xrel  = 1.009_rp*(zbar/abar*den*1.0e-6_rp)**third
    beta2 = xrel**2/(1.0_rp + xrel**2)

    jy = (1.0_rp + 6.0_rp/(5.0_rp*xrel**2) + 2.0_rp/(5.0_rp*xrel**4)) * &
         (yg**3/(3.0_rp*(1.0_rp + 0.07414_rp*yg)**3) * &
          log((2.81_rp - 0.810_rp*beta2 + yg)/yg) + &
          pi**5/6.0_rp*yg**4/(13.91_rp + yg)**4)

    vee = 0.511_rp*temp**2*xmas/ymas**2*sqrt(xmas/ymas)*jy
    cee = wfac/vee

    ov1 = cie*cee/(cee + cie)
    ov  = k2c/(ov1*den)*temp**3
  end if

! -------------------------------------------------------------------
! blend conductivity

  if (dlog10 <= drel10) then
    ocond = oh
  else if (dlog10 < drelim) then
    farg  = pi*(dlog10 - drel10)/0.3_rp
    ffac  = 0.5_rp*(1.0_rp - cos(farg))
    ocond = exp((1.0_rp-ffac)*log(oh) + ffac*log(ov))
  else
    ocond = ov
  end if

! -------------------------------------------------------------------
! total opacity

  opac = orad*ocond/(ocond + orad)

 end subroutine sig99

#endif

#ifdef THERMAL_DIFFUSION_STS

 subroutine compute_parabolic_dt(mgrid,lgrid)
  type(mpigrid), intent(inout) :: mgrid
  type(locgrid), intent(inout) :: lgrid

  integer :: i,j,k
  integer :: lx1,ux1,lx2,ux2,lx3,ux3,ierr

  real(kind=rp) :: Drad,inv_dt_par(1),inv_dt_par_comm(1),inv_dx1,inv_dx2,&
  inv_dx3,inv_dl2,rmi,rpl

  real(kind=rp) :: x,y,z,r,tmp

#ifdef USE_TIMMES_KAPPA
  integer :: iv
  real(kind=rp) :: inv_abar,abar,zbar,ye,rho,T,cv,E,P,sound
#endif

  x = rp0
  y = rp0
  z = rp0
  r = rp0
  tmp = rp0
  rmi = rp0
  rpl = rp0

  inv_dt_par(1) = rp0

  lx1 = mgrid%i1(1)
  ux1 = mgrid%i2(1)
  lx2 = mgrid%i1(2)
  ux2 = mgrid%i2(2)
  lx3 = mgrid%i1(3)
  ux3 = mgrid%i2(3)

  inv_dx1 = lgrid%inv_dx1
  inv_dx2 = lgrid%inv_dx2
#if sdims_make==3
  inv_dx3 = lgrid%inv_dx3
#else
  inv_dx3 = rp0
#endif

  inv_dl2 = inv_dx1*inv_dx1+inv_dx2*inv_dx2+inv_dx3*inv_dx3

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1

#ifdef USE_INTERNAL_BOUNDARIES
     if(lgrid%is_solid(i,j,k)==0) then
#endif

#ifdef USE_TIMMES_KAPPA
      rho = lgrid%prim(i_rho,i,j,k)
      T = lgrid%temp(i,j,k)
      inv_abar = rp0
      ye = rp0
      do iv=1,nspecies
       tmp = lgrid%prim(i_as1+iv-1,i,j,k)/lgrid%A(iv)
       inv_abar = inv_abar + tmp
       ye = ye + tmp*lgrid%Z(iv)
      end do
      abar = rp1/inv_abar
      zbar = abar*ye
      call helm_rhoT_given_full(rho,T,abar,zbar,P,E,sound,cv)   
      Drad = fthirds*CONST_RAD*CONST_C*T*T*T/(rho*rho*lgrid%kappa(i,j,k)*cv)
#else
      Drad = othird*CONST_C/(lgrid%kappa(i,j,k)*lgrid%prim(i_rho,i,j,k))
#endif

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
      inv_dx1 = rp1/(lgrid%coords_x1(1,i+1,j,k)-lgrid%coords_x1(1,i,j,k))
      inv_dx2 = rp1/(lgrid%coords_x2(2,i,j+1,k)-lgrid%coords_x2(2,i,j,k))
#if sdims_make==3
      inv_dx3 = rp1/(lgrid%coords_x3(3,i,j,k+1)-lgrid%coords_x3(3,i,j,k))
#endif
      inv_dl2 = inv_dx1*inv_dx1+inv_dx2*inv_dx2+inv_dx3*inv_dx3
#endif

#ifdef NONUNIFORM_RADIAL_NODES
      rmi = lgrid%r_x1(i,j,k)
      rpl = lgrid%r_x1(i+1,j,k)
      inv_dx1 = rp1/(rpl-rmi)
#endif

#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL)
      r = lgrid%r(i,j,k)
      inv_dx2 = rp1/r*inv_dx2
      inv_dl2 = inv_dx1*inv_dx1+inv_dx2*inv_dx2
#endif

#ifdef GEOMETRY_3D_SPHERICAL
      r = lgrid%r(i,j,k)
      inv_dx2 = rp1/r*inv_dx2
      inv_dx3 = lgrid%inv_r_sin_theta(i,j,k)*inv_dx3
      inv_dl2 = inv_dx1*inv_dx1+inv_dx2*inv_dx2+inv_dx3*inv_dx3
#endif

      inv_dt_par(1) = max(inv_dt_par(1),rp2*Drad*inv_dl2)

#ifdef USE_INTERNAL_BOUNDARIES
     end if
#endif

    end do
   end do
  end do

  call mpi_allreduce(inv_dt_par, inv_dt_par_comm, 1, MPI_RP , MPI_MAX, mgrid%comm_cart, ierr)

  lgrid%dt_par = rp1/inv_dt_par_comm(1)

 end subroutine compute_parabolic_dt

 subroutine thermal_diffusion_step(mgrid,lgrid,strang)
  type(mpigrid), intent(inout) :: mgrid
  type(locgrid), intent(inout) :: lgrid
  integer, intent(in) :: strang

  integer :: i,j,k
  integer :: lx1,ux1,lx2,ux2,lx3,ux3
  integer :: i_sts,nstages 

  real(kind=rp) :: b0,b1,w1,mut1,bjm2,bjm1,bj,muj,mutj,nuj,ajm1,gammatj,fac,tmp1,tmp2
  real(kind=rp) :: igmm1,eint,p,rho,T,inv_mu,gm,mu,half_dt,pgas,beta,gmm1,sound,cv
  real(kind=rp) :: dp_drho,dp_deps,sound2
  real(kind=rp) :: ye,inv_abar,abar,zbar
  integer :: iv

  real(kind=rp) :: T2,T3,T4
  integer :: ierr

  gm = lgrid%gm
  gmm1 = gm-rp1
  mu = lgrid%mu
  inv_mu = rp1/mu
  T = rp0
  T2 = rp0
  T3 = rp0
  T4 = rp0
  p = rp0
  pgas = rp0
  beta = rp0
  sound = rp0
  abar = rp0
  cv = rp0
  zbar = rp0

  dp_drho = rp0
  dp_deps = rp0
  sound2 = rp0

  ye = rp0
  inv_abar = rp0
 
  iv = 0

  b0 = othird
  b1 = othird

  lx1 = mgrid%i1(1)
  ux1 = mgrid%i2(1)
  lx2 = mgrid%i1(2)
  ux2 = mgrid%i2(2)
  lx3 = mgrid%i1(3)
  ux3 = mgrid%i2(3)

  fac = lgrid%dt/lgrid%dt_par
  tmp1 = rp0
  tmp2 = rp0

  half_dt = rph*lgrid%dt

  nstages = 1 + floor(rph*(sqrt(rp9+rp16*fac)-rp1))

  if(nstages<3) then
    nstages = 3
  endif

  igmm1 = rp1/gmm1

  if((mgrid%rankl==master_rank).and.(strang==1)) then
   if(mod(lgrid%step,info_terminal_rate)==0) & 
    write(*,'(" >> sts thermal diffusion: dt_h/dt_p=",E9.3," | nstages=",I8.8)') fac,nstages
  end if

  w1 = rp4/(nstages*nstages+nstages-rp2)
  mut1 = b1*w1
 
  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1

#ifdef STS_EVOLVE_TEMP

#ifdef HELMHOLTZ_EOS
#ifdef ADVECT_YE_IABAR
        ye = lgrid%prim(i_ye,i,j,k)
        abar = rp1/lgrid%prim(i_iabar,i,j,k)
#endif
#ifdef ADVECT_SPECIES
        inv_abar = rp0
        ye = rp0
        do iv=1,nspecies
         tmp1 = lgrid%prim(i_as1+iv-1,i,j,k)/lgrid%A(iv)
         inv_abar = inv_abar + tmp1
         ye = ye + tmp1*lgrid%Z(iv)
        end do
        abar = rp1/inv_abar
#endif
        zbar = abar*ye
#else
#ifdef ADVECT_YE_IABAR
        ye = lgrid%prim(i_ye,i,j,k)
        abar = rp1/lgrid%prim(i_iabar,i,j,k)
        inv_mu =  (ye*abar+rp1)/abar
#endif
#ifdef ADVECT_SPECIES
        inv_mu = rp0
        do iv=1,nspecies
         inv_mu = inv_mu + lgrid%prim(i_as1+iv-1,i,j,k)*(lgrid%Z(iv)+rp1)/lgrid%A(iv)
        end do
#endif
#endif

      T = lgrid%temp(i,j,k)
      rho = lgrid%prim(i_rho,i,j,k)
      lgrid%e_0(i,j,k) = T
      lgrid%eint(i,j,k) = T

#ifdef USE_PRAD
      p = lgrid%prim(i_p,i,j,k)

      T2 = T*T
      T3 = T2*T
      T4 = T3*T
      pgas = rho*CONST_RGAS*T*inv_mu
      beta = pgas/p 

      lgrid%icv(i,j,k) = &
      gmm1/inv_mu/CONST_RGAS*(beta/(rp12*(rp1-beta)*gmm1+beta))/rho

#elif defined(HELMHOLTZ_EOS)
     
      call  helm_rhoT_given_full(rho,T,abar,zbar,p,eint,sound,cv)
 
      lgrid%icv(i,j,k) = rp1/(rho*cv)
 
#elif defined(PIG_EOS)
     
      call  pig_rhoT_given_full(rho,T,p,eint,sound,cv)
 
      lgrid%icv(i,j,k) = rp1/(rho*cv)
         
#else
     
      lgrid%icv(i,j,k) = gmm1/(rho*inv_mu*CONST_RGAS)
      
#endif

#else

      lgrid%e_0(i,j,k) = lgrid%eint(i,j,k)

#endif

    end do
   end do
  end do

  call mpi_barrier(mgrid%comm_cart,ierr) 
  call communicate_ndarray(mgrid,nvars,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%prim,.false.)
  call bcs_thermal_diffusion(mgrid,lgrid)
  call residuals_thermal_diffusion(mgrid,lgrid)

  bjm2 = b0
  bjm1 = b1

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1

      lgrid%Me_0(i,j,k) = lgrid%Me_jm1(i,j,k)

      lgrid%e_1(i,j,k) = lgrid%e_0(i,j,k) + half_dt*mut1*lgrid%Me_0(i,j,k)

      lgrid%e_jm2(i,j,k) = lgrid%e_0(i,j,k) 

      lgrid%eint(i,j,k) = lgrid%e_1(i,j,k)

    end do
   end do
  end do

  do i_sts=2,nstages
   
     bj = (i_sts*i_sts+i_sts-rp2)/(rp2*i_sts*(i_sts+rp1))
     muj  = ((rp2*i_sts-rp1)/i_sts)*bj/bjm1
     mutj = muj*w1
     nuj = -((i_sts-rp1)/i_sts)*bj/bjm2
     ajm1 = rp1-bjm1
     gammatj = -ajm1*mutj

#ifdef STS_EVOLVE_TEMP
     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1
        lgrid%temp(i,j,k) = lgrid%eint(i,j,k)
       end do
      end do
     end do
#else
     call eint_to_temp(mgrid,lgrid) 
#endif     
     call bcs_thermal_diffusion(mgrid,lgrid)
     call residuals_thermal_diffusion(mgrid,lgrid)
 
     do k=lx3,ux3
      do j=lx2,ux2
       do i=lx1,ux1

        lgrid%e_jm1(i,j,k) = lgrid%eint(i,j,k)

        lgrid%eint(i,j,k) = muj*lgrid%e_jm1(i,j,k) + nuj*lgrid%e_jm2(i,j,k) + (rp1-muj-nuj)*lgrid%e_0(i,j,k) + &
        half_dt*mutj*lgrid%Me_jm1(i,j,k) + half_dt*gammatj*lgrid%Me_0(i,j,k)
    
        lgrid%e_jm2(i,j,k) = lgrid%e_jm1(i,j,k)

       end do
      end do
     end do
       
     bjm2 = bjm1
     bjm1 = bj

  end do
 
#ifdef STS_EVOLVE_TEMP
  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
      lgrid%temp(i,j,k) = lgrid%eint(i,j,k)
    end do
   end do
  end do
#else
  call eint_to_temp(mgrid,lgrid) 
#endif      

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1

      rho = lgrid%prim(i_rho,i,j,k)
      T = lgrid%temp(i,j,k)

#ifdef HELMHOLTZ_EOS
#ifdef ADVECT_YE_IABAR
      ye = lgrid%prim(i_ye,i,j,k)
      abar = rp1/lgrid%prim(i_iabar,i,j,k)
#endif
#ifdef ADVECT_SPECIES
      inv_abar = rp0
      ye = rp0
      do iv=1,nspecies
       tmp1 = lgrid%prim(i_as1+iv-1,i,j,k)/lgrid%A(iv)
       inv_abar = inv_abar + tmp1
       ye = ye + tmp1*lgrid%Z(iv)
      end do
      abar = rp1/inv_abar
#endif
      zbar = abar*ye
#else
#ifdef ADVECT_YE_IABAR
      ye = lgrid%prim(i_ye,i,j,k)
      abar = rp1/lgrid%prim(i_iabar,i,j,k)
      inv_mu =  (ye*abar+rp1)/abar
#endif
#ifdef ADVECT_SPECIES
      inv_mu = rp0
      do iv=1,nspecies
       inv_mu = inv_mu + lgrid%prim(i_as1+iv-1,i,j,k)*(lgrid%Z(iv)+rp1)/lgrid%A(iv)
      end do
#endif
#endif

#ifdef USE_PRAD
      T2 = T*T
      T3 = T2*T
      T4 = T3*T
      p = CONST_RAD*T4*othird + &
      CONST_RGAS*rho*T*inv_mu
 
#ifdef STS_EVOLVE_TEMP
      eint = CONST_RAD*T4 + &
      CONST_RGAS*rho*T*inv_mu*igmm1
      lgrid%eint(i,j,k) = eint
#else
      eint = lgrid%eint(i,j,k)
#endif

      lgrid%prim(i_p,i,j,k) = p

#ifdef USE_FASTEOS
      mu = rp1/inv_mu

      tmp1 = CONST_RAD*mu*T3
      tmp2 = CONST_RGAS*rho

      dp_drho = fthirds * &
      CONST_RAD*CONST_RGAS*T4*(rp3*gm-rp4) / &
      (rp4*tmp1*gmm1+tmp2)
      dp_deps = gmm1 * &
      (rp4*tmp1+rp3*tmp2) / &
      (rp12*tmp1*gmm1+rp3*tmp2)

      sound2 = dp_drho+dp_deps*(p+eint)/rho

      lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
      lgrid%gammaf(i_gammac,i,j,k) = sound2*rho/p
#endif
#elif defined(HELMHOLTZ_EOS)
      call  helm_rhoT_given_full(rho,T,abar,zbar,p,eint,sound,cv)
      eint = rho*eint
      lgrid%prim(i_p,i,j,k) = p
      lgrid%eint(i,j,k) = eint
#ifdef USE_FASTEOS
      lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
      lgrid%gammaf(i_gammac,i,j,k) = sound*sound*rho/p
#endif
#elif defined(PIG_EOS)
      call  pig_rhoT_given_full(rho,T,p,eint,sound,cv)
      eint = rho*eint
      lgrid%prim(i_p,i,j,k) = p
      lgrid%eint(i,j,k) = eint
#ifdef USE_FASTEOS
      lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
      lgrid%gammaf(i_gammac,i,j,k) = sound*sound*rho/p
#endif
#else

      lgrid%prim(i_p,i,j,k) = &
      CONST_RGAS*rho*T*inv_mu

#ifdef STS_EVOLVE_TEMP
      lgrid%eint(i_p,i,j,k) = &
      CONST_RGAS*rho*T*inv_mu*igmm1
#endif

#endif

    end do
   end do
  end do

 end subroutine thermal_diffusion_step

 subroutine eint_to_temp(mgrid,lgrid) 
  type(mpigrid), intent(inout) :: mgrid
  type(locgrid), intent(inout) :: lgrid
 
  integer :: lx1,ux1,lx2,ux2,lx3,ux3
  integer :: i,j,k

  real(kind=rp) :: gmm1,igmm1,mu,inv_mu,rho,eint,T,p,sound

  real(kind=rp) :: ye,abar,inv_abar,zbar
  integer :: iv
  real(kind=rp) :: tmp,Res_prad,Res0,dRes_dT,T2,T3,T4
  integer :: iter

  lx1 = mgrid%i1(1)
  ux1 = mgrid%i2(1)
  lx2 = mgrid%i1(2)
  ux2 = mgrid%i2(2)
  lx3 = mgrid%i1(3)
  ux3 = mgrid%i2(3)

  T = rp0
  mu = lgrid%mu
  inv_mu = rp1/mu
  gmm1 = lgrid%gm-rp1
  igmm1 = rp1/gmm1

  ye = rp0
  abar = rp0
  tmp = rp0
  Res_prad = rp0
  Res0 = rp0
  dRes_dT = rp0

  inv_abar = rp0
  zbar = rp0
  p = rp0 
  sound = rp0

  T2 = rp0
  T3 = rp0
  T4 = rp0

  iter = 0
  iv = 0

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1

#ifdef HELMHOLTZ_EOS

#ifdef ADVECT_YE_IABAR
        ye = lgrid%prim(i_ye,i,j,k)
        abar = rp1/lgrid%prim(i_iabar,i,j,k)
#endif 
#ifdef ADVECT_SPECIES
       inv_abar = rp0
       ye = rp0
       do iv=1,nspecies
         tmp = lgrid%prim(i_as1+iv-1,i,j,k)/lgrid%A(iv)
         inv_abar = inv_abar + tmp
         ye = ye + tmp*lgrid%Z(iv)
       end do
       abar = rp1/inv_abar
#endif
       zbar = ye*abar

#else

#ifdef ADVECT_YE_IABAR
        ye = lgrid%prim(i_ye,i,j,k)
        abar = rp1/lgrid%prim(i_iabar,i,j,k)
        inv_mu = (ye*abar + rp1)/abar
#endif
#ifdef ADVECT_SPECIES
        inv_mu = rp0
        do iv=1,nspecies
          inv_mu = inv_mu + lgrid%prim(i_as1+iv-1,i,j,k)*(lgrid%Z(iv)+rp1)/lgrid%A(iv)
        end do
#endif

#endif

        rho = lgrid%prim(i_rho,i,j,k)
        eint = lgrid%eint(i,j,k)

#ifdef USE_PRAD
        tmp = rho*CONST_RGAS*inv_mu*igmm1
        T = lgrid%temp(i,j,k)
        Res_prad = -rp1
        do iter=1,250
         T2 = T*T
         T3 = T2*T
         T4 = T3*T
         Res0 = Res_prad
         Res_prad = CONST_RAD*T4 + tmp*T - eint
         if (abs(Res_prad/eint) < em14) exit
         if ((abs(Res0 - Res_prad)/abs(Res0) < em15) .and. iter>1) then
           write(*,*) 'eint->temp, EoS gas+radiation, RN stalled, ','cell:(',i,j,k,')'
           exit
         end if
         dRes_dT = rp4*CONST_RAD*T3 + tmp
         T = T - Res_prad/dRes_dT
        end do
#elif defined(HELMHOLTZ_EOS)
        T = lgrid%temp(i,j,k)
        call helm_rhoe_given(rho,eint/rho,abar,zbar,T,p,sound,.false.)
#elif defined(PIG_EOS)
        T = lgrid%temp(i,j,k)
        call pig_rhoe_given(rho,eint/rho,T,p,sound,.false.)
#else
        T = gmm1*eint/(inv_mu*rho*CONST_RGAS)
#endif

        lgrid%temp(i,j,k) = T

    end do
   end do
  end do

 end subroutine eint_to_temp

 subroutine residuals_thermal_diffusion(mgrid,lgrid)
  type(mpigrid), intent(inout) :: mgrid
  type(locgrid), intent(inout) :: lgrid
 
  real(kind=rp) :: gradT,inv_dl,Tminus,Tplus,x,y,z,r,&
  sin_theta,tmp,rmi,rpl,Kint,Krad,Kminus,Kplus
  integer :: lx1,ux1,lx2,ux2,lx3,ux3
  integer :: i,j,k
 
  lx1 = mgrid%i1(1)
  ux1 = mgrid%i2(1)
  lx2 = mgrid%i1(2)
  ux2 = mgrid%i2(2)
  lx3 = mgrid%i1(3)
  ux3 = mgrid%i2(3)

  x = rp0
  y = rp0
  z = rp0
  r = rp0
  sin_theta = rp0
  tmp = rp0
  rmi = rp0
  rpl = rp0

  Krad = fthirds*CONST_RAD*CONST_C

#ifdef USE_TIMMES_KAPPA
  call compute_timmes_kappa(lgrid)
#endif

  inv_dl = lgrid%inv_dx1

#ifdef USE_INTERNAL_BOUNDARIES

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1

        if(lgrid%is_solid(i,j,k)==0) then

         if(lgrid%is_solid(i-1,j,k)==1) then

          lgrid%prim(i_rho,i-1,j,k)=rp2*lgrid%prim(i_rho,i,j,k)-lgrid%prim(i_rho,i+1,j,k)
#ifdef FIX_TEMPERATURE_AT_X1L
#ifdef USE_WB
          lgrid%temp(i-1,j,k) = rp2*lgrid%eq_prim_x1(ieq_T,i,j,k)-lgrid%temp(i,j,k)
#endif
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i-1,j,k) = &
          rp2*lgrid%eq_prim_x1(ieq_T,i,j,k)-lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#else
          lgrid%temp(i-1,j,k) = lgrid%temp(i,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i-1,j,k) = &
          lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#endif    

         endif

         if(lgrid%is_solid(i+1,j,k)==1) then

          lgrid%prim(i_rho,i+1,j,k)=rp2*lgrid%prim(i_rho,i,j,k)-lgrid%prim(i_rho,i-1,j,k)
#ifdef FIX_TEMPERATURE_AT_X1U
#ifdef USE_WB
          lgrid%temp(i+1,j,k) = rp2*lgrid%eq_prim_x1(ieq_T,i+1,j,k)-lgrid%temp(i,j,k)
#endif          
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i+1,j,k) = &
          rp2*lgrid%eq_prim_x1(ieq_T,i+1,j,k)-lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#else
          lgrid%temp(i+1,j,k) = lgrid%temp(i,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i+1,j,k) = &
          lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#endif    

         endif

        endif

    end do
   end do
  end do

#endif

  do k=lx3,ux3
   do j=lx2,ux2

    do i=lx1,ux1+1
     
     Tminus = lgrid%temp(i-1,j,k)
     Kminus = Tminus*Tminus*Tminus/(lgrid%prim(i_rho,i-1,j,k)*lgrid%kappa(i-1,j,k))

     Tplus = lgrid%temp(i,j,k)
     Kplus = Tplus*Tplus*Tplus/(lgrid%prim(i_rho,i,j,k)*lgrid%kappa(i,j,k))

     Kint = rp2*(Kminus*Kplus)/(Kminus+Kplus)

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
     inv_dl = rp1/(lgrid%coords(1,i,j,k)-lgrid%coords(1,i-1,j,k))
#endif
#ifdef NONUNIFORM_RADIAL_NODES
     rmi = lgrid%r(i-1,j,k)
     rpl = lgrid%r(i,j,k)
     inv_dl = rp1/(rpl-rmi)
#endif

#ifdef BALANCE_THERMAL_DIFFUSION
     Tplus = Tplus-lgrid%eq_prim_cc(ieq_T,i,j,k)
     Tminus = Tminus-lgrid%eq_prim_cc(ieq_T,i-1,j,k)
#endif
     gradT = (Tplus-Tminus)*inv_dl


     lgrid%fe_x1(i) = Krad*Kint*gradT

#ifdef GEOMETRY_2D_POLAR
     r = lgrid%r_x1(i,j,k)
     lgrid%fe_x1(i) = lgrid%fe_x1(i)*r
#endif

#if defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
     r = lgrid%r_x1(i,j,k)
     lgrid%fe_x1(i) = lgrid%fe_x1(i)*r*r
#endif

    end do
    
    do i=lx1,ux1

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
     inv_dl = rp1/(lgrid%coords_x1(1,i+1,j,k)-lgrid%coords_x1(1,i,j,k))
#endif

#ifdef NONUNIFORM_RADIAL_NODES
     rmi = lgrid%r_x1(i,j,k)
     rpl = lgrid%r_x1(i+1,j,k)
     inv_dl = rp1/(rpl-rmi)
#endif

#ifdef GEOMETRY_2D_POLAR
     r = lgrid%r(i,j,k)
     lgrid%Me_jm1(i,j,k) = (lgrid%fe_x1(i+1)-lgrid%fe_x1(i))*inv_dl/r
#elif defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
     r = lgrid%r(i,j,k)
     lgrid%Me_jm1(i,j,k) = (lgrid%fe_x1(i+1)-lgrid%fe_x1(i))*inv_dl/(r*r)
#else
     lgrid%Me_jm1(i,j,k) = (lgrid%fe_x1(i+1)-lgrid%fe_x1(i))*inv_dl
#endif

    end do

   end do
  end do
 
  inv_dl = lgrid%inv_dx2

#ifdef USE_INTERNAL_BOUNDARIES

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1

        if(lgrid%is_solid(i,j,k)==0) then

         if(lgrid%is_solid(i,j-1,k)==1) then

          lgrid%prim(i_rho,i,j-1,k)=rp2*lgrid%prim(i_rho,i,j,k)-lgrid%prim(i_rho,i,j+1,k)
#ifdef FIX_TEMPERATURE_AT_X2L
#ifdef USE_WB
          lgrid%temp(i,j-1,k) = rp2*lgrid%eq_prim_x2(ieq_T,i,j,k)-lgrid%temp(i,j,k)
#endif          
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j-1,k) = &
          rp2*lgrid%eq_prim_x2(ieq_T,i,j,k)-lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#else
          lgrid%temp(i,j-1,k) = lgrid%temp(i,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j-1,k) = &
          lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#endif    

         endif

         if(lgrid%is_solid(i,j+1,k)==1) then

          lgrid%prim(i_rho,i,j+1,k)=rp2*lgrid%prim(i_rho,i,j,k)-lgrid%prim(i_rho,i,j-1,k)
#ifdef FIX_TEMPERATURE_AT_X2U
#ifdef USE_WB
          lgrid%temp(i,j+1,k) = rp2*lgrid%eq_prim_x2(ieq_T,i,j+1,k)-lgrid%temp(i,j,k)
#endif          
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j+1,k) = &
          rp2*lgrid%eq_prim_x2(ieq_T,i,j+1,k)-lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#else
          lgrid%temp(i,j+1,k) = lgrid%temp(i,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j+1,k) = &
          lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#endif    

         endif

        endif

    end do
   end do
  end do

#endif

  do k=lx3,ux3
   do i=lx1,ux1

    do j=lx2,ux2+1

     Tminus = lgrid%temp(i,j-1,k)
     Kminus = Tminus*Tminus*Tminus/(lgrid%prim(i_rho,i,j-1,k)*lgrid%kappa(i,j-1,k))

     Tplus = lgrid%temp(i,j,k)
     Kplus = Tplus*Tplus*Tplus/(lgrid%prim(i_rho,i,j,k)*lgrid%kappa(i,j,k))

     Kint = rp2*(Kminus*Kplus)/(Kminus+Kplus)
     
#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
     inv_dl = rp1/(lgrid%coords(2,i,j,k)-lgrid%coords(2,i,j-1,k))
#endif
#ifdef BALANCE_THERMAL_DIFFUSION
     Tplus = Tplus-lgrid%eq_prim_cc(ieq_T,i,j,k)
     Tminus = Tminus-lgrid%eq_prim_cc(ieq_T,i,j-1,k)
#endif
     gradT = (Tplus-Tminus)*inv_dl

#if defined(GEOMETRY_2D_POLAR) || defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
     r = lgrid%r_x2(i,j,k)
     gradT = gradT/r
#endif

     lgrid%fe_x2(j) = Krad*Kint*gradT

#if defined(GEOMETRY_2D_SPHERICAL) || defined(GEOMETRY_3D_SPHERICAL)
     sin_theta = lgrid%sin_theta_x2(i,j,k)
     lgrid%fe_x2(j) = sin_theta*lgrid%fe_x2(j)
#endif

    end do

    do j=lx2,ux2

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
     inv_dl = rp1/(lgrid%coords_x1(2,i,j+1,k)-lgrid%coords_x2(2,i,j,k))
#endif
#ifdef GEOMETRY_2D_POLAR
     r = lgrid%r(i,j,k)
     lgrid%Me_jm1(i,j,k) = lgrid%Me_jm1(i,j,k) + (lgrid%fe_x2(j+1)-lgrid%fe_x2(j))*inv_dl/r
#elif defined(GEOMETRY_2D_SPHERICAL)
     x = lgrid%coords(1,i,j,k)
     lgrid%Me_jm1(i,j,k) = lgrid%Me_jm1(i,j,k) + (lgrid%fe_x2(j+1)-lgrid%fe_x2(j))*inv_dl/x
#elif defined(GEOMETRY_3D_SPHERICAL)
     tmp = lgrid%inv_r_sin_theta(i,j,k)
     lgrid%Me_jm1(i,j,k) = lgrid%Me_jm1(i,j,k) + (lgrid%fe_x2(j+1)-lgrid%fe_x2(j))*inv_dl*tmp
#else
     lgrid%Me_jm1(i,j,k) = lgrid%Me_jm1(i,j,k) + (lgrid%fe_x2(j+1)-lgrid%fe_x2(j))*inv_dl
#endif

    end do

   end do
  end do

#if sdims_make==3
 
  inv_dl = lgrid%inv_dx3

#ifdef USE_INTERNAL_BOUNDARIES

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1

        if(lgrid%is_solid(i,j,k)==0) then

         if(lgrid%is_solid(i,j,k-1)==1) then

          lgrid%prim(i_rho,i,j,k-1)=rp2*lgrid%prim(i_rho,i,j,k)-lgrid%prim(i_rho,i,j,k+1)
#ifdef FIX_TEMPERATURE_AT_X3L
#ifdef USE_WB
          lgrid%temp(i,j,k-1) = rp2*lgrid%eq_prim_x3(ieq_T,i,j,k)-lgrid%temp(i,j,k)
#endif          
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j,k-1) = &
          rp2*lgrid%eq_prim_x3(ieq_T,i,j,k)-lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#else
          lgrid%temp(i,j,k-1) = lgrid%temp(i,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j,k-1) = &
          lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#endif    

         endif

         if(lgrid%is_solid(i,j,k+1)==1) then

          lgrid%prim(i_rho,i,j,k+1)=rp2*lgrid%prim(i_rho,i,j,k)-lgrid%prim(i_rho,i,j,k-1)
#ifdef FIX_TEMPERATURE_AT_X3U
#ifdef USE_WB
          lgrid%temp(i,j,k+1) = rp2*lgrid%eq_prim_x3(ieq_T,i,j,k+1)-lgrid%temp(i,j,k)
#endif          
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j,k+1) = &
          rp2*lgrid%eq_prim_x3(ieq_T,i,j,k+1)-lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#else
          lgrid%temp(i,j,k+1) = lgrid%temp(i,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
          lgrid%eq_prim_cc(ieq_T,i,j,k+1) = &
          lgrid%eq_prim_cc(ieq_T,i,j,k)
#endif
#endif    

         endif

        endif

    end do
   end do
  end do

#endif

  do j=lx2,ux2
   do i=lx1,ux1

    do k=lx3,ux3+1
 
     Tminus = lgrid%temp(i,j,k-1)
     Kminus = Tminus*Tminus*Tminus/(lgrid%prim(i_rho,i,j,k-1)*lgrid%kappa(i,j,k-1))

     Tplus = lgrid%temp(i,j,k)
     Kplus = Tplus*Tplus*Tplus/(lgrid%prim(i_rho,i,j,k)*lgrid%kappa(i,j,k))

     Kint = rp2*(Kminus*Kplus)/(Kminus+Kplus)

#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
     inv_dl = rp1/(lgrid%coords(3,i,j,k)-lgrid%coords(3,i,j,k-1))
#endif
#ifdef BALANCE_THERMAL_DIFFUSION
     Tplus = Tplus-lgrid%eq_prim_cc(ieq_T,i,j,k)
     Tminus = Tminus-lgrid%eq_prim_cc(ieq_T,i,j,k-1)
#endif
     gradT = (Tplus-Tminus)*inv_dl

#ifdef GEOMETRY_3D_SPHERICAL
     tmp = lgrid%inv_r_sin_theta_x3(i,j,k) 
     gradT = gradT*tmp
#endif

     lgrid%fe_x3(k) = Krad*Kint*gradT

    end do

    do k=lx3,ux3
#ifdef GEOMETRY_CARTESIAN_NONUNIFORM
     inv_dl = rp1/(lgrid%coords_x3(3,i,j,k+1)-lgrid%coords_x3(3,i,j,k))
#endif

#ifdef GEOMETRY_3D_SPHERICAL
     tmp = lgrid%inv_r_sin_theta(i,j,k)
     lgrid%Me_jm1(i,j,k) = lgrid%Me_jm1(i,j,k) + (lgrid%fe_x3(k+1)-lgrid%fe_x3(k))*inv_dl*tmp
#else
     lgrid%Me_jm1(i,j,k) = lgrid%Me_jm1(i,j,k) + (lgrid%fe_x3(k+1)-lgrid%fe_x3(k))*inv_dl
#endif

    end do

   end do
  end do

#endif

#ifdef STS_EVOLVE_TEMP

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
      lgrid%Me_jm1(i,j,k) = lgrid%Me_jm1(i,j,k)*lgrid%icv(i,j,k)
    end do
   end do
  end do 

#endif

#ifdef USE_INTERNAL_BOUNDARIES

  do k=lx3,ux3
   do j=lx2,ux2
    do i=lx1,ux1
     if(lgrid%is_solid(i,j,k)==1) then
      lgrid%Me_jm1(i,j,k) = rp0
     end if
    end do
   end do
  end do 

#endif

 end subroutine residuals_thermal_diffusion

 subroutine bcs_thermal_diffusion(mgrid,lgrid)
  type(mpigrid), intent(inout) :: mgrid
  type(locgrid), intent(inout) :: lgrid

  integer :: i,j,k
  integer :: lx1,ux1,lx2,ux2,lx3,ux3
  integer :: ierr
  
  i=0
  j=0
  k=0

  lx1 = mgrid%i1(1)
  ux1 = mgrid%i2(1)
  lx2 = mgrid%i1(2)
  ux2 = mgrid%i2(2)
  lx3 = mgrid%i1(3)
  ux3 = mgrid%i2(3)

  call mpi_barrier(mgrid%comm_cart,ierr)
  call communicate_array(mgrid,lx1,ux1,lx2,ux2,lx3,ux3,ngc,lgrid%temp,.false.)

#ifndef USE_INTERNAL_BOUNDARIES

#if defined(X1L_REFLECTIVE) || defined(X1L_OUTFLOW) || defined(X1L_DIODE)

  if(mgrid%coords_dd(1)==0) then

      do k=lx3,ux3
       do j=lx2,ux2

         lgrid%prim(i_rho,lx1-1,j,k) = rp2*lgrid%prim(i_rho,lx1,j,k)-lgrid%prim(i_rho,lx1+1,j,k)

#ifdef FIX_TEMPERATURE_AT_X1L
#ifdef USE_WB
         lgrid%temp(lx1-1,j,k) = rp2*lgrid%eq_prim_x1(ieq_T,lx1,j,k)-lgrid%temp(lx1,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,lx1-1,j,k) = & 
         rp2*lgrid%eq_prim_x1(ieq_T,lx1,j,k)-lgrid%eq_prim_cc(ieq_T,lx1,j,k)
#endif
#else
         lgrid%temp(lx1-1,j,k) = rp2*lgrid%Tl(1)-lgrid%temp(lx1,j,k)
#endif
#else
         lgrid%temp(lx1-1,j,k) = lgrid%temp(lx1,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,lx1-1,j,k) = lgrid%eq_prim_cc(ieq_T,lx1,j,k)
#endif
#endif

       end do
      end do

  endif

#endif

#if defined(X1U_REFLECTIVE) || defined(X1U_OUTFLOW) || defined(X1U_DIODE)

  if(mgrid%coords_dd(1)==mgrid%bricks(1)-1) then

      do k=lx3,ux3
       do j=lx2,ux2

         lgrid%prim(i_rho,ux1+1,j,k) = rp2*lgrid%prim(i_rho,ux1,j,k)-lgrid%prim(i_rho,ux1-1,j,k)
      
#ifdef FIX_TEMPERATURE_AT_X1U
#ifdef USE_WB
         lgrid%temp(ux1+1,j,k) = rp2*lgrid%eq_prim_x1(ieq_T,ux1+1,j,k)-lgrid%temp(ux1,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,ux1+1,j,k) = & 
         rp2*lgrid%eq_prim_x1(ieq_T,ux1+1,j,k)-lgrid%eq_prim_cc(ieq_T,ux1,j,k)
#endif
#else
         lgrid%temp(ux1+1,j,k) = rp2*lgrid%Tu(1)-lgrid%temp(ux1,j,k)
#endif
#else
         lgrid%temp(ux1+1,j,k) = lgrid%temp(ux1,j,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,ux1+1,j,k) = lgrid%eq_prim_cc(ieq_T,ux1,j,k)
#endif
#endif

       end do
      end do

  endif

#endif

#if defined(X2L_REFLECTIVE) || defined(X2L_OUTFLOW) || defined(X2L_DIODE)

  if(mgrid%coords_dd(2)==0) then

      do k=lx3,ux3
       do i=lx1,ux1

         lgrid%prim(i_rho,i,lx2-1,k) = rp2*lgrid%prim(i_rho,i,lx2,k)-lgrid%prim(i_rho,i,lx2+1,k)
      
#ifdef FIX_TEMPERATURE_AT_X2L
#ifdef USE_WB
         lgrid%temp(i,lx2-1,k) = rp2*lgrid%eq_prim_x2(ieq_T,i,lx2,k)-lgrid%temp(i,lx2,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,lx2-1,k) = &
         rp2*lgrid%eq_prim_x2(ieq_T,i,lx2,k)-lgrid%eq_prim_cc(ieq_T,i,lx2,k)
#endif
#else
         lgrid%temp(i,lx2-1,k) = rp2*lgrid%Tl(2)-lgrid%temp(i,lx2,k)
#endif
#else
         lgrid%temp(i,lx2-1,k) = lgrid%temp(i,lx2,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,lx2-1,k) = lgrid%eq_prim_cc(ieq_T,i,lx2,k)
#endif
#endif

       end do
      end do

  endif

#endif

#if defined(X2U_REFLECTIVE) || defined(X2U_OUTFLOW) || defined(X2U_DIODE)

  if(mgrid%coords_dd(2)==mgrid%bricks(2)-1) then

      do k=lx3,ux3
       do i=lx1,ux1

         lgrid%prim(i_rho,i,ux2+1,k) = rp2*lgrid%prim(i_rho,i,ux2,k)-lgrid%prim(i_rho,i,ux2-1,k)
      
#ifdef FIX_TEMPERATURE_AT_X2U
#ifdef USE_WB
         lgrid%temp(i,ux2+1,k) = rp2*lgrid%eq_prim_x2(ieq_T,i,ux2+1,k)-lgrid%temp(i,ux2,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,ux2+1,k) = &
         rp2*lgrid%eq_prim_x2(ieq_T,i,ux2+1,k)-lgrid%eq_prim_cc(ieq_T,i,ux2,k)
#endif
#else
         lgrid%temp(i,ux2+1,k) = rp2*lgrid%Tu(2)-lgrid%temp(i,ux2,k)
#endif
#else
         lgrid%temp(i,ux2+1,k) = lgrid%temp(i,ux2,k)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,ux2+1,k) = lgrid%eq_prim_cc(ieq_T,i,ux2,k)
#endif
#endif

       end do
      end do

  endif

#endif

#if sdims_make==3

#if defined(X3L_REFLECTIVE) || defined(X3L_OUTFLOW) || defined(X3L_DIODE)

  if(mgrid%coords_dd(3)==0) then

      do j=lx2,ux2
       do i=lx1,ux1

         lgrid%prim(i_rho,i,j,lx3-1) = rp2*lgrid%prim(i_rho,i,j,lx3)-lgrid%prim(i_rho,i,j,lx3+1)
      
#ifdef FIX_TEMPERATURE_AT_X3L
#ifdef USE_WB
         lgrid%temp(i,j,lx3-1) = rp2*lgrid%eq_prim_x3(ieq_T,i,j,lx3)-lgrid%temp(i,j,lx3)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,j,lx3-1) = &
         rp2*lgrid%eq_prim_x3(ieq_T,i,j,lx3)-lgrid%eq_prim_cc(ieq_T,i,j,lx3)
#endif
#else
         lgrid%temp(i,j,lx3-1) = rp2*lgrid%Tl(3)-lgrid%temp(i,j,lx3)
#endif
#else
         lgrid%temp(i,j,lx3-1) = lgrid%temp(i,j,lx3)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,j,lx3-1) = lgrid%eq_prim_cc(ieq_T,i,j,lx3)
#endif
#endif

       end do
      end do

  endif

#endif

#if defined(X3U_REFLECTIVE) || defined(X3U_OUTFLOW) || defined(X3U_DIODE)

  if(mgrid%coords_dd(3)==mgrid%bricks(3)-1) then

      do j=lx2,ux2
       do i=lx1,ux1

         lgrid%prim(i_rho,i,j,ux3+1) = rp2*lgrid%prim(i_rho,i,j,ux3)-lgrid%prim(i_rho,i,j,ux3-1)
      
#ifdef FIX_TEMPERATURE_AT_X3U
#ifdef USE_WB
         lgrid%temp(i,j,ux3+1) = rp2*lgrid%eq_prim_x3(ieq_T,i,j,ux3+1)-lgrid%temp(i,j,ux3)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,j,ux3+1) = &
         rp2*lgrid%eq_prim_x3(ieq_T,i,j,ux3+1)-lgrid%eq_prim_cc(ieq_T,i,j,ux3)
#endif
#else
         lgrid%temp(i,j,ux3+1) = rp2*lgrid%Tu(3)-lgrid%temp(i,j,ux3)
#endif
#else
         lgrid%temp(i,j,ux3+1) = lgrid%temp(i,j,ux3)
#ifdef BALANCE_THERMAL_DIFFUSION
         lgrid%eq_prim_cc(ieq_T,i,j,ux3+1) = lgrid%eq_prim_cc(ieq_T,i,j,ux3)
#endif
#endif

       end do
      end do

  endif

#endif

#endif

#endif

 end subroutine bcs_thermal_diffusion

#endif

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! NEUTRINO COOLING
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#ifdef USE_NEULOSS

 !This implementation is based on sneut5.tbz available at https://cococubed.com/code_pages/nuloss.shtml (last accessed 10 April 2026).
 subroutine sneut5(temp,den,abar,zbar,snu)
      implicit none

!..this routine computes neutrino losses from the analytic fits of
!..itoh et al. apjs 102, 411, 1996, and also returns their derivatives.

!..input:
!..temp = temperature
!..den  = density
!..abar = mean atomic weight
!..zbar = mean charge

!..output:
!..snu    = total neutrino loss rate in erg/g/sec
!..dsnudt = derivative of snu with temperature
!..dsnudd = derivative of snu with density
!..dsnuda = derivative of snu with abar
!..dsnudz = derivative of snu with zbar


!..declare the pass
      real(kind=rp), intent(in) :: temp,den,abar,zbar
      real(kind=rp), intent(out) :: snu

!..local variables
      real(kind=rp) :: spair,spairdt,spairdd,spairda,spairdz,           &
                       splas,splasdt,splasdd,splasda,splasdz,           &
                       sphot,sphotdt,sphotdd,sphotda,sphotdz,           &
                       sbrem,sbremdt,sbremdd,sbremda,sbremdz,           &
                       sreco,srecodt,srecodd,srecoda,srecodz

      real(kind=rp) :: t9,xl,xldt,xlp5,xl2,xl3,xl4,xl5,xl6,xl7,xl8,xl9, &
                       xlmp5,xlm1,xlm2,xlm3,xlm4,xlnt,cc,den6,tfermi,   &
                       a0,a1,a2,a3,b1,b2,c00,c01,c02,c03,c04,c05,c06,&
                       c10,c11,c12,c13,c14,c15,c16,c20,c21,c22,c23,c24, &
                       c25,c26,dd00,dd01,dd02,dd03,dd04,dd05,dd11,dd12, &
                       dd13,dd14,dd15,dd21,dd22,dd23,dd24,dd25,b,c,d,f0,&
                       f1,tempi,abari,zbari,f2,f3,z,deni,xmue,ye,       &
                       dum,             &
                       gum


!..pair production
      real(kind=rp) :: rm,rmi,gl,                   &
                       zeta,zeta2,zeta3,    &
                       xnum,                &
                       xden,                &
                       fpair,           &
                       qpair

!..plasma
      real(kind=rp) :: gl2,gl12,gl32,gl72,gl6,  &
                       ft,fl,   &
                       fxy

!..photo
      real(kind=rp) :: tau,taudt,cos1,cos2,cos3,cos4,cos5,sin1,sin2,    &
                       sin3,sin4,sin5,last,xast,                        &
                       fphot,           &
                       qphot

!..brem
      real(kind=rp) :: t8,t812,t832,t82,t83,t85,t86,t8m1,t8m2,t8m3,t8m5,&
                       t8m6,                                            &
                       eta,etam1,etam2,etam3,   &
                       fbrem,           &
                       gbrem,           &
                       u,gm1,gm2,gm13,gm23,gm43,gm53,v,w,fb,gt,gb,      &
                       fliq,                &
                       gliq

!..recomb
      real(kind=rp) :: nu,       &
                       nu2,nu3,bigj



!..numerical constants
      real(kind=rp) :: fac1,fac2,fac3,oneth,twoth,con1,sixth,iln10
      parameter        (fac1   = 5.0e0_rp * CONST_PI / 3.0e0_rp,                    &
                        fac2   = 10.0e0_rp * CONST_PI,                           &
                        fac3   = CONST_PI / 5.0e0_rp,                            &
                        oneth  = 1.0e0_rp/3.0e0_rp,                           &
                        twoth  = 2.0e0_rp/3.0e0_rp,                           &
                        con1   = 1.0e0_rp/5.9302e0_rp,                        &
                        sixth  = 1.0e0_rp/6.0e0_rp,                           &
                        iln10  = 4.342944819032518e-1_rp)


!..theta is sin**2(theta_weinberg) = 0.2319 plus/minus 0.00005 (1996)
!..xnufam is the number of neutrino flavors = 3.02 plus/minus 0.005 (199
!..change theta and xnufam if need be, and the changes will automaticall
!..propagate through the routine. cv and ca are the vector and axial cur

      real(kind=rp), parameter :: theta  = 0.2319e0_rp,                              &
                        xnufam = 3.0e0_rp,                                 &
                        cv     = 0.5e0_rp + 2.0e0_rp * theta,                 &
                        cvp    = 1.0e0_rp - cv,                            &
                        ca     = 0.5e0_rp,                                 &
                        cap    = 1.0e0_rp - ca,                            &
                        tfac1  = cv*cv + ca*ca +                        &
                                 (xnufam-1.0e0_rp) * (cvp*cvp+cap*cap),    &
                        tfac2  = cv*cv - ca*ca +                        &
                                 (xnufam-1.0e0_rp) * (cvp*cvp - cap*cap),  &
                        tfac3  = tfac2/tfac1,                           &
                        tfac4  = 0.5e0_rp * tfac1,                         &
                        tfac5  = 0.5e0_rp * tfac2,                         &
                        tfac6  = cv*cv + 1.5e0_rp*ca*ca + (xnufam - 1.0e0_rp)*&
                                 (cvp*cvp + 1.5e0_rp*cap*cap)



!..initialize
      spair   = 0.0e0_rp
      spairdt = 0.0e0_rp
      spairdd = 0.0e0_rp
      spairda = 0.0e0_rp
      spairdz = 0.0e0_rp

      splas   = 0.0e0_rp
      splasdt = 0.0e0_rp
      splasdd = 0.0e0_rp
      splasda = 0.0e0_rp
      splasdz = 0.0e0_rp

      sphot   = 0.0e0_rp
      sphotdt = 0.0e0_rp
      sphotdd = 0.0e0_rp
      sphotda = 0.0e0_rp
      sphotdz = 0.0e0_rp

      sbrem   = 0.0e0_rp
      sbremdt = 0.0e0_rp
      sbremdd = 0.0e0_rp
      sbremda = 0.0e0_rp
      sbremdz = 0.0e0_rp

      sreco   = 0.0e0_rp
      srecodt = 0.0e0_rp
      srecodd = 0.0e0_rp
      srecoda = 0.0e0_rp
      srecodz = 0.0e0_rp

      snu     = 0.0e0_rp

      c01 = 0.0_rp
      c02 = 0.0_rp
      c03 = 0.0_rp
      c04 = 0.0_rp
      c05 = 0.0_rp
      c11 = 0.0_rp
      c12 = 0.0_rp
      c13 = 0.0_rp
      c14 = 0.0_rp
      c15 = 0.0_rp
      c21 = 0.0_rp
      c22 = 0.0_rp
      c23 = 0.0_rp
      c24 = 0.0_rp
      c25 = 0.0_rp
      c06 = 0.0_rp
      c10 = 0.0_rp
      c16 = 0.0_rp
      c20 = 0.0_rp
      c26 = 0.0_rp

      dd01 = 0.0_rp
      dd02 = 0.0_rp
      dd03 = 0.0_rp
      dd04 = 0.0_rp
      dd05 = 0.0_rp
      dd11 = 0.0_rp
      dd12 = 0.0_rp
      dd13 = 0.0_rp
      dd14 = 0.0_rp
      dd15 = 0.0_rp
      dd21 = 0.0_rp
      dd22 = 0.0_rp
      dd23 = 0.0_rp
      dd24 = 0.0_rp
      dd25 = 0.0_rp

      tau = 0.0_rp

      if (temp .lt. 1.0e7_rp) return


!..to avoid lots of divisions
      deni  = 1.0e0_rp/den
      tempi = 1.0e0_rp/temp
      abari = 1.0e0_rp/abar
      zbari = 1.0e0_rp/zbar


!..some composition variables
      ye    = zbar*abari
      xmue  = abar*zbari




!..some frequent factors
      t9     = temp * 1.0e-9_rp
      xl     = t9 * con1
      xldt   = 1.0e-9_rp * con1
      xlp5   = sqrt(xl)
      xl2    = xl*xl
      xl3    = xl2*xl
      xl4    = xl3*xl
      xl5    = xl4*xl
      xl6    = xl5*xl
      xl7    = xl6*xl
      xl8    = xl7*xl
      xl9    = xl8*xl
      xlmp5  = 1.0e0_rp/xlp5
      xlm1   = 1.0e0_rp/xl
      xlm2   = xlm1*xlm1
      xlm3   = xlm1*xlm2
      xlm4   = xlm1*xlm3

      rm     = den*ye
!      rmdd   = ye
!      rmda   = -rm*abari
!      rmdz   = den*abari
      rmi    = 1.0e0_rp/rm

      a0     = rm * 1.0e-9_rp
      a1     = a0**oneth
      zeta   = a1 * xlm1
!      zetadt = -a1 * xlm2 * xldt
      a2     = oneth * a1*rmi * xlm1
!      zetadd = a2 * rmdd
!      zetada = a2 * rmda
!      zetadz = a2 * rmdz

      zeta2 = zeta * zeta
      zeta3 = zeta2 * zeta




!..pair neutrino section
!..for reactions like e+ + e- => nu_e + nubar_e

!..equation 2.8
      gl   = 1.0e0_rp - 13.04e0_rp*xl2 +133.5e0_rp*xl4 +1534.0e0_rp*xl6 +918.6e0_rp*xl8
!     gldt = xldt*(-26.08e0_rp*xl +534.0e0_rp*xl3 +9204.0e0_rp*xl5 +7348.8e0_rp*xl7)

!..equation 2.7

      a1     = 6.002e19_rp + 2.084e20_rp*zeta + 1.872e21_rp*zeta2
      a2     = 2.084e20_rp + 2.0e0_rp*1.872e21_rp*zeta

      if (t9 .lt. 10.0_rp) then
       b1     = exp(-5.5924e0_rp*zeta)
       b2     = -b1*5.5924e0_rp
      else
       b1     = exp(-4.9924e0_rp*zeta)
       b2     = -b1*4.9924e0_rp
      end if

      xnum   = a1 * b1
      c      = a2*b1 + a1*b2
!      xnumdt = c*zetadt
!      xnumdd = c*zetadd
!      xnumda = c*zetada
!      xnumdz = c*zetadz

      if (t9 .lt. 10.0_rp) then
       a1   = 9.383e-1_rp*xlm1 - 4.141e-1_rp*xlm2 + 5.829e-2_rp*xlm3
       a2   = -9.383e-1_rp*xlm2 + 2.0e0_rp*4.141e-1_rp*xlm3 - 3.0e0_rp*5.829e-2_rp*xlm4
      else
       a1   = 1.2383e0_rp*xlm1 - 8.141e-1_rp*xlm2
       a2   = -1.2383e0_rp*xlm2 + 2.0e0_rp*8.141e-1_rp*xlm3
      end if

      b1   = 3.0e0_rp*zeta2

      xden   = zeta3 + a1
!      xdendt = b1*zetadt + a2*xldt
!      xdendd = b1*zetadd
!      xdenda = b1*zetada
!      xdendz = b1*zetadz

      a1      = 1.0e0_rp/xden
      fpair   = xnum*a1
!      fpairdt = (xnumdt - fpair*xdendt)*a1
!      fpairdd = (xnumdd - fpair*xdendd)*a1
!      fpairda = (xnumda - fpair*xdenda)*a1
!      fpairdz = (xnumdz - fpair*xdendz)*a1


!..equation 2.6
      a1     = 10.7480e0_rp*xl2 + 0.3967e0_rp*xlp5 + 1.005e0_rp
      a2     = xldt*(2.0e0_rp*10.7480e0_rp*xl + 0.5e0_rp*0.3967e0_rp*xlmp5)
      xnum   = 1.0e0_rp/a1
!      xnumdt = -xnum*xnum*a2

      a1     = 7.692e7_rp*xl3 + 9.715e6_rp*xlp5
      a2     = xldt*(3.0e0_rp*7.692e7_rp*xl2 + 0.5e0_rp*9.715e6_rp*xlmp5)

      c      = 1.0e0_rp/a1
      b1     = 1.0e0_rp + rm*c

      xden   = b1**(-0.3e0_rp)

      d      = -0.3e0_rp*xden/b1
!      xdendt = -d*rm*c*c*a2
!      xdendd = d*rmdd*c
!      xdenda = d*rmda*c
!      xdendz = d*rmdz*c

      qpair   = xnum*xden
!      qpairdt = xnumdt*xden + xnum*xdendt
!      qpairdd = xnum*xdendd
!      qpairda = xnum*xdenda
!      qpairdz = xnum*xdendz



!..equation 2.5
      a1    = exp(-2.0e0_rp*xlm1)
      a2    = a1*2.0e0_rp*xlm2*xldt

      spair   = a1*fpair
!      spairdt = a2*fpair + a1*fpairdt
!      spairdd = a1*fpairdd
!      spairda = a1*fpairda
!      spairdz = a1*fpairdz

      a1      = spair
      spair   = gl*a1
!      spairdt = gl*spairdt + gldt*a1
!      spairdd = gl*spairdd
!      spairda = gl*spairda
!      spairdz = gl*spairdz

      a1      = tfac4*(1.0e0_rp + tfac3 * qpair)
      a2      = tfac4*tfac3

      a3      = spair
      spair   = a1*a3
!      spairdt = a1*spairdt + a2*qpairdt*a3
!      spairdd = a1*spairdd + a2*qpairdd*a3
!      spairda = a1*spairda + a2*qpairda*a3
!      spairdz = a1*spairdz + a2*qpairdz*a3




!..plasma neutrino section
!..for collective reactions like gamma_plasmon => nu_e + nubar_e
!..equation 4.6

      a1   = 1.019e-6_rp*rm
      a2   = a1**twoth
      a3   = twoth*a2/a1

      b1   =  sqrt(1.0e0_rp + a2)
      b2   = 1.0e0_rp/b1

      c00  = 1.0e0_rp/(temp*temp*b1)

      gl2   = 1.1095e11_rp * rm * c00

!      gl2dt = -2.0e0_rp*gl2*tempi
      d     = rm*c00*b2*0.5e0_rp*b2*a3*1.019e-6_rp
!      gl2dd = 1.1095e11_rp * (rmdd*c00  - d*rmdd)
!      gl2da = 1.1095e11_rp * (rmda*c00  - d*rmda)
!      gl2dz = 1.1095e11_rp * (rmdz*c00  - d*rmdz)


      gl    = sqrt(gl2)
      gl12  = sqrt(gl)
      gl32  = gl * gl12
      gl72  = gl2 * gl32
      gl6   = gl2 * gl2 * gl2


!..equation 4.7
      ft   = 2.4e0_rp + 0.6e0_rp*gl12 + 0.51e0_rp*gl + 1.25e0_rp*gl32
      gum  = 1.0e0_rp/gl2
      a1   =(0.25e0_rp*0.6e0_rp*gl12 +0.5e0_rp*0.51e0_rp*gl +0.75e0_rp*1.25e0_rp*gl32)*gum
!      ftdt = a1*gl2dt
!      ftdd = a1*gl2dd
!      ftda = a1*gl2da
!      ftdz = a1*gl2dz


!..equation 4.8
      a1   = 8.6e0_rp*gl2 + 1.35e0_rp*gl72
      a2   = 8.6e0_rp + 1.75e0_rp*1.35e0_rp*gl72*gum

      b1   = 225.0e0_rp - 17.0e0_rp*gl + gl2
      b2   = -0.5e0_rp*17.0e0_rp*gl*gum + 1.0e0_rp

      c    = 1.0e0_rp/b1
      fl   = a1*c

      d    = (a2 - fl*b2)*c
!      fldt = d*gl2dt
!      fldd = d*gl2dd
!      flda = d*gl2da
!      fldz = d*gl2dz


!..equation 4.9 and 4.10
      cc   = log10(2.0e0_rp*rm)
      xlnt = log10(temp)

      xnum   = sixth * (17.5e0_rp + cc - 3.0e0_rp*xlnt)
!      xnumdt = -iln10*0.5e0_rp*tempi
      a2     = iln10*sixth*rmi
!      xnumdd = a2*rmdd
!      xnumda = a2*rmda
!      xnumdz = a2*rmdz

      xden   = sixth * (-24.5e0_rp + cc + 3.0e0_rp*xlnt)
!      xdendt = iln10*0.5e0_rp*tempi
!      xdendd = a2*rmdd
!      xdenda = a2*rmda
!      xdendz = a2*rmdz


!..equation 4.11
      if (abs(xnum) .gt. 0.7e0_rp  .or.  xden .lt. 0.0e0_rp) then
       fxy   = 1.0e0_rp
!       fxydt = 0.0e0_rp
!       fxydd = 0.0e0_rp
!       fxydz = 0.0e0_rp
!       fxyda = 0.0e0_rp

      else

       a1  = 0.39e0_rp - 1.25e0_rp*xnum - 0.35e0_rp*sin(4.5e0_rp*xnum)
       a2  = -1.25e0_rp - 4.5e0_rp*0.35e0_rp*cos(4.5e0_rp*xnum)

       b1  = 0.3e0_rp * exp(-1.0e0_rp*(4.5e0_rp*xnum + 0.9e0_rp)**2)
       b2  = -b1*2.0e0_rp*(4.5e0_rp*xnum + 0.9e0_rp)*4.5e0_rp

       c   = min(0.0e0_rp, xden - 1.6e0_rp + 1.25e0_rp*xnum)
!       if (abs(c) < em14) then
!        dumdt = 0.0e0_rp
!        dumdd = 0.0e0_rp
!        dumda = 0.0e0_rp
!        dumdz = 0.0e0_rp
!       else
!        dumdt = xdendt + 1.25e0_rp*xnumdt
!        dumdd = xdendd + 1.25e0_rp*xnumdd
!        dumda = xdenda + 1.25e0_rp*xnumda
!        dumdz = xdendz + 1.25e0_rp*xnumdz
!       end if

       d   = 0.57e0_rp - 0.25e0_rp*xnum
       a3  = c/d
       c00 = exp(-1.0e0_rp*a3**2)

       f1  = -c00*2.0e0_rp*a3/d
!       c01 = f1*(dumdt + a3*0.25e0_rp*xnumdt)
!       c02 = f1*(dumdd + a3*0.25e0_rp*xnumdd)
!       c03 = f1*(dumda + a3*0.25e0_rp*xnumda)
!       c04 = f1*(dumdz + a3*0.25e0_rp*xnumdz)

       fxy   = 1.05e0_rp + (a1 - b1)*c00
!       fxydt = (a2*xnumdt -  b2*xnumdt)*c00 + (a1-b1)*c01
!       fxydd = (a2*xnumdd -  b2*xnumdd)*c00 + (a1-b1)*c02
!       fxyda = (a2*xnumda -  b2*xnumda)*c00 + (a1-b1)*c03
!       fxydz = (a2*xnumdz -  b2*xnumdz)*c00 + (a1-b1)*c04

      end if



!..equation 4.1 and 4.5
      splas   = (ft + fl) * fxy
!      splasdt = (ftdt + fldt)*fxy + (ft+fl)*fxydt
!      splasdd = (ftdd + fldd)*fxy + (ft+fl)*fxydd
!      splasda = (ftda + flda)*fxy + (ft+fl)*fxyda
!      splasdz = (ftdz + fldz)*fxy + (ft+fl)*fxydz

      a2      = exp(-gl)
      a3      = -0.5e0_rp*a2*gl*gum

      a1      = splas
      splas   = a2*a1
!      splasdt = a2*splasdt + a3*gl2dt*a1
!      splasdd = a2*splasdd + a3*gl2dd*a1
!      splasda = a2*splasda + a3*gl2da*a1
!      splasdz = a2*splasdz + a3*gl2dz*a1

      a2      = gl6
      a3      = 3.0e0_rp*gl6*gum

      a1      = splas
      splas   = a2*a1
!      splasdt = a2*splasdt + a3*gl2dt*a1
!      splasdd = a2*splasdd + a3*gl2dd*a1
!      splasda = a2*splasda + a3*gl2da*a1
!      splasdz = a2*splasdz + a3*gl2dz*a1


      a2      = 0.93153e0_rp * 3.0e21_rp * xl9
      a3      = 0.93153e0_rp * 3.0e21_rp * 9.0e0_rp*xl8*xldt

      a1      = splas
      splas   = a2*a1
!      splasdt = a2*splasdt + a3*a1
!      splasdd = a2*splasdd
!      splasda = a2*splasda
!      splasdz = a2*splasdz




!..photoneutrino process section
!..for reactions like e- + gamma => e- + nu_e + nubar_e
!..                   e+ + gamma => e+ + nu_e + nubar_e
!..equation 3.8 for tau, equation 3.6 for cc,
!..and table 2 written out for speed
      if (temp .ge. 1.0e7_rp  .and. temp .lt. 1.0e8_rp) then
       tau  =  log10(temp * 1.0e-7_rp)
       cc   =  0.5654e0_rp + tau
       c00  =  1.008e11_rp
       c01  =  0.0e0_rp
       c02  =  0.0e0_rp
       c03  =  0.0e0_rp
       c04  =  0.0e0_rp
       c05  =  0.0e0_rp
       c06  =  0.0e0_rp
       c10  =  8.156e10_rp
       c11  =  9.728e8_rp
       c12  = -3.806e9_rp
       c13  = -4.384e9_rp
       c14  = -5.774e9_rp
       c15  = -5.249e9_rp
       c16  = -5.153e9_rp
       c20  =  1.067e11_rp
       c21  = -9.782e9_rp
       c22  = -7.193e9_rp
       c23  = -6.936e9_rp
       c24  = -6.893e9_rp
       c25  = -7.041e9_rp
       c26  = -7.193e9_rp
       dd01 =  0.0e0_rp
       dd02 =  0.0e0_rp
       dd03 =  0.0e0_rp
       dd04 =  0.0e0_rp
       dd05 =  0.0e0_rp
       dd11 = -1.879e10_rp
       dd12 = -9.667e9_rp
       dd13 = -5.602e9_rp
       dd14 = -3.370e9_rp
       dd15 = -1.825e9_rp
       dd21 = -2.919e10_rp
       dd22 = -1.185e10_rp
       dd23 = -7.270e9_rp
       dd24 = -4.222e9_rp
       dd25 = -1.560e9_rp

      else if (temp .ge. 1.0e8_rp  .and. temp .lt. 1.0e9_rp) then
       tau   =  log10(temp * 1.0e-8_rp)
       cc   =  1.5654e0_rp
       c00  =  9.889e10_rp
       c01  = -4.524e8_rp
       c02  = -6.088e6_rp
       c03  =  4.269e7_rp
       c04  =  5.172e7_rp
       c05  =  4.910e7_rp
       c06  =  4.388e7_rp
       c10  =  1.813e11_rp
       c11  = -7.556e9_rp
       c12  = -3.304e9_rp
       c13  = -1.031e9_rp
       c14  = -1.764e9_rp
       c15  = -1.851e9_rp
       c16  = -1.928e9_rp
       c20  =  9.750e10_rp
       c21  =  3.484e10_rp
       c22  =  5.199e9_rp
       c23  = -1.695e9_rp
       c24  = -2.865e9_rp
       c25  = -3.395e9_rp
       c26  = -3.418e9_rp
       dd01 = -1.135e8_rp
       dd02 =  1.256e8_rp
       dd03 =  5.149e7_rp
       dd04 =  3.436e7_rp
       dd05 =  1.005e7_rp
       dd11 =  1.652e9_rp
       dd12 = -3.119e9_rp
       dd13 = -1.839e9_rp
       dd14 = -1.458e9_rp
       dd15 = -8.956e8_rp
       dd21 = -1.549e10_rp
       dd22 = -9.338e9_rp
       dd23 = -5.899e9_rp
       dd24 = -3.035e9_rp
       dd25 = -1.598e9_rp

      else if (temp .ge. 1.0e9_rp) then
       tau  =  log10(t9)
       cc   =  1.5654e0_rp
       c00  =  9.581e10_rp
       c01  =  4.107e8_rp
       c02  =  2.305e8_rp
       c03  =  2.236e8_rp
       c04  =  1.580e8_rp
       c05  =  2.165e8_rp
       c06  =  1.721e8_rp
       c10  =  1.459e12_rp
       c11  =  1.314e11_rp
       c12  = -1.169e11_rp
       c13  = -1.765e11_rp
       c14  = -1.867e11_rp
       c15  = -1.983e11_rp
       c16  = -1.896e11_rp
       c20  =  2.424e11_rp
       c21  = -3.669e9_rp
       c22  = -8.691e9_rp
       c23  = -7.967e9_rp
       c24  = -7.932e9_rp
       c25  = -7.987e9_rp
       c26  = -8.333e9_rp
       dd01 =  4.724e8_rp
       dd02 =  2.976e8_rp
       dd03 =  2.242e8_rp
       dd04 =  7.937e7_rp
       dd05 =  4.859e7_rp
       dd11 = -7.094e11_rp
       dd12 = -3.697e11_rp
       dd13 = -2.189e11_rp
       dd14 = -1.273e11_rp
       dd15 = -5.705e10_rp
       dd21 = -2.254e10_rp
       dd22 = -1.551e10_rp
       dd23 = -7.793e9_rp
       dd24 = -4.489e9_rp
       dd25 = -2.185e9_rp
      end if

      taudt = iln10*tempi


!..equation 3.7, compute the expensive trig functions only one time
      cos1 = cos(fac1*tau)
      cos2 = cos(fac1*2.0e0_rp*tau)
      cos3 = cos(fac1*3.0e0_rp*tau)
      cos4 = cos(fac1*4.0e0_rp*tau)
      cos5 = cos(fac1*5.0e0_rp*tau)
      last = cos(fac2*tau)

      sin1 = sin(fac1*tau)
      sin2 = sin(fac1*2.0e0_rp*tau)
      sin3 = sin(fac1*3.0e0_rp*tau)
      sin4 = sin(fac1*4.0e0_rp*tau)
      sin5 = sin(fac1*5.0e0_rp*tau)
      xast = sin(fac2*tau)

      a0 = 0.5e0_rp*c00                                                    &
           + c01*cos1 + dd01*sin1 + c02*cos2 + dd02*sin2                &
           + c03*cos3 + dd03*sin3 + c04*cos4 + dd04*sin4                &
           + c05*cos5 + dd05*sin5 + 0.5e0_rp*c06*last

      f0 =  taudt*fac1*(-c01*sin1 + dd01*cos1 - c02*sin2*2.0e0_rp          &
           + dd02*cos2*2.0e0_rp - c03*sin3*3.0e0_rp + dd03*cos3*3.0e0_rp         &
           - c04*sin4*4.0e0_rp + dd04*cos4*4.0e0_rp                           &
           - c05*sin5*5.0e0_rp + dd05*cos5*5.0e0_rp)                          &
           - 0.5e0_rp*c06*xast*fac2*taudt

      a1 = 0.5e0_rp*c10                                                    &
           + c11*cos1 + dd11*sin1 + c12*cos2 + dd12*sin2                &
           + c13*cos3 + dd13*sin3 + c14*cos4 + dd14*sin4                &
           + c15*cos5 + dd15*sin5 + 0.5e0_rp*c16*last

      f1 = taudt*fac1*(-c11*sin1 + dd11*cos1 - c12*sin2*2.0e0_rp           &
           + dd12*cos2*2.0e0_rp - c13*sin3*3.0e0_rp + dd13*cos3*3.0e0_rp         &
           - c14*sin4*4.0e0_rp + dd14*cos4*4.0e0_rp - c15*sin5*5.0e0_rp          &
           + dd15*cos5*5.0e0_rp) - 0.5e0_rp*c16*xast*fac2*taudt

      a2 = 0.5e0_rp*c20                                                    &
           + c21*cos1 + dd21*sin1 + c22*cos2 + dd22*sin2                &
           + c23*cos3 + dd23*sin3 + c24*cos4 + dd24*sin4                &
           + c25*cos5 + dd25*sin5 + 0.5e0_rp*c26*last

      f2 = taudt*fac1*(-c21*sin1 + dd21*cos1 - c22*sin2*2.0e0_rp           &
           + dd22*cos2*2.0e0_rp - c23*sin3*3.0e0_rp + dd23*cos3*3.0e0_rp         &
           - c24*sin4*4.0e0_rp + dd24*cos4*4.0e0_rp - c25*sin5*5.0e0_rp          &
           + dd25*cos5*5.0e0_rp) - 0.5e0_rp*c26*xast*fac2*taudt

!..equation 3.4
      dum   = a0 + a1*zeta + a2*zeta2
!      dumdt = f0 + f1*zeta + a1*zetadt + f2*zeta2 + 2.0e0_rp*a2*zeta*zetadt
!      dumdd = a1*zetadd + 2.0e0_rp*a2*zeta*zetadd
!      dumda = a1*zetada + 2.0e0_rp*a2*zeta*zetada
!      dumdz = a1*zetadz + 2.0e0_rp*a2*zeta*zetadz

      z      = exp(-cc*zeta)

      xnum   = dum*z
!      xnumdt = dumdt*z - dum*z*cc*zetadt
!      xnumdd = dumdd*z - dum*z*cc*zetadd
!      xnumda = dumda*z - dum*z*cc*zetada
!      xnumdz = dumdz*z - dum*z*cc*zetadz

      xden   = zeta3 + 6.290e-3_rp*xlm1 + 7.483e-3_rp*xlm2 + 3.061e-4_rp*xlm3

      dum    = 3.0e0_rp*zeta2
!      xdendt = dum*zetadt - xldt*(6.290e-3_rp*xlm2                         &
!               + 2.0e0_rp*7.483e-3_rp*xlm3 + 3.0e0_rp*3.061e-4_rp*xlm4)
!      xdendd = dum*zetadd
!      xdenda = dum*zetada
!      xdendz = dum*zetadz

      dum      = 1.0e0_rp/xden
      fphot   = xnum*dum
!      fphotdt = (xnumdt - fphot*xdendt)*dum
!      fphotdd = (xnumdd - fphot*xdendd)*dum
!      fphotda = (xnumda - fphot*xdenda)*dum
!      fphotdz = (xnumdz - fphot*xdendz)*dum


!..equation 3.3
      a0     = 1.0e0_rp + 2.045e0_rp * xl
      xnum   = 0.666e0_rp*a0**(-2.066e0_rp)
!      xnumdt = -2.066e0_rp*xnum/a0 * 2.045e0_rp*xldt

      dum    = 1.875e8_rp*xl + 1.653e8_rp*xl2 + 8.449e8_rp*xl3 - 1.604e8_rp*xl4
!      dumdt  = xldt*(1.875e8_rp + 2.0e0_rp*1.653e8_rp*xl + 3.0e0_rp*8.449e8_rp*xl2     &
!               - 4.0e0_rp*1.604e8_rp*xl3)

      z      = 1.0e0_rp/dum
      xden   = 1.0e0_rp + rm*z
!      xdendt =  -rm*z*z*dumdt
!      xdendd =  rmdd*z
!      xdenda =  rmda*z
!      xdendz =  rmdz*z

      z      = 1.0e0_rp/xden
      qphot = xnum*z
!      qphotdt = (xnumdt - qphot*xdendt)*z
      dum      = -qphot*z
!      qphotdd = dum*xdendd
!      qphotda = dum*xdenda
!      qphotdz = dum*xdendz

!..equation 3.2
      sphot   = xl5 * fphot
!      sphotdt = 5.0e0_rp*xl4*xldt*fphot + xl5*fphotdt
!      sphotdd = xl5*fphotdd
!      sphotda = xl5*fphotda
!      sphotdz = xl5*fphotdz

      a1      = sphot
      sphot   = rm*a1
!      sphotdt = rm*sphotdt
!      sphotdd = rm*sphotdd + rmdd*a1
!      sphotda = rm*sphotda + rmda*a1
!      sphotdz = rm*sphotdz + rmdz*a1

      a1      = tfac4*(1.0e0_rp - tfac3 * qphot)
      a2      = -tfac4*tfac3

      a3      = sphot
      sphot   = a1*a3
!      sphotdt = a1*sphotdt + a2*qphotdt*a3
!      sphotdd = a1*sphotdd + a2*qphotdd*a3
!      sphotda = a1*sphotda + a2*qphotda*a3
!      sphotdz = a1*sphotdz + a2*qphotdz*a3

      if (sphot .le. 0.0_rp) then
       sphot   = 0.0e0_rp
!       sphotdt = 0.0e0_rp
!       sphotdd = 0.0e0_rp
!       sphotda = 0.0e0_rp
!       sphotdz = 0.0e0_rp
      end if





!..bremsstrahlung neutrino section
!..for reactions like e- + (z,a) => e- + (z,a) + nu + nubar
!..                   n  + n     => n + n + nu + nubar
!..                   n  + p     => n + p + nu + nubar
!..equation 4.3

      den6   = den * 1.0e-6_rp
      t8     = temp * 1.0e-8_rp
      t812   = sqrt(t8)
      t832   = t8 * t812
      t82    = t8*t8
      t83    = t82*t8
      t85    = t82*t83
      t86    = t85*t8
      t8m1   = 1.0e0_rp/t8
      t8m2   = t8m1*t8m1
      t8m3   = t8m2*t8m1
      t8m5   = t8m3*t8m2
      t8m6   = t8m5*t8m1


      tfermi = 5.9302e9_rp*(sqrt(1.0e0_rp+1.018e0_rp*(den6*ye)**twoth)-1.0e0_rp)

!.."weak" degenerate electrons only
      if (temp .gt. 0.3e0_rp * tfermi) then

!..equation 5.3
       dum   = 7.05e6_rp * t832 + 5.12e4_rp * t83
!       dumdt = (1.5e0_rp*7.05e6_rp*t812 + 3.0e0_rp*5.12e4_rp*t82)*1.0e-8_rp

       z     = 1.0e0_rp/dum
       eta   = rm*z
!       etadt = -rm*z*z*dumdt
!       etadd = rmdd*z
!       etada = rmda*z
!       etadz = rmdz*z

       etam1 = 1.0e0_rp/eta
       etam2 = etam1 * etam1
       etam3 = etam2 * etam1


!..equation 5.2
       a0    = 23.5e0_rp + 6.83e4_rp*t8m2 + 7.81e8_rp*t8m5
       f0    = (-2.0e0_rp*6.83e4_rp*t8m3 - 5.0e0_rp*7.81e8_rp*t8m6)*1.0e-8_rp
       xnum  = 1.0e0_rp/a0

       dum   = 1.0e0_rp + 1.47e0_rp*etam1 + 3.29e-2_rp*etam2
       z     = -1.47e0_rp*etam2 - 2.0e0_rp*3.29e-2_rp*etam3
!       dumdt = z*etadt
!       dumdd = z*etadd
!       dumda = z*etada
!       dumdz = z*etadz

       c00   = 1.26e0_rp * (1.0e0_rp+etam1)
       z     = -1.26e0_rp*etam2
!       c01   = z*etadt
!       c02   = z*etadd
!       c03   = z*etada
!       c04   = z*etadz

       z      = 1.0e0_rp/dum
!       xden   = c00*z
!       xdendt = (c01 - xden*dumdt)*z
!       xdendd = (c02 - xden*dumdd)*z
!       xdenda = (c03 - xden*dumda)*z
!       xdendz = (c04 - xden*dumdz)*z

       fbrem   = xnum + xden
!       fbremdt = -xnum*xnum*f0 + xdendt
!       fbremdd = xdendd
!       fbremda = xdenda
!       fbremdz = xdendz


!..equation 5.9
       a0    = 230.0e0_rp + 6.7e5_rp*t8m2 + 7.66e9_rp*t8m5
       f0    = (-2.0e0_rp*6.7e5_rp*t8m3 - 5.0e0_rp*7.66e9_rp*t8m6)*1.0e-8_rp

       z     = 1.0e0_rp + rm*1.0e-9_rp
       dum   = a0*z
!       dumdt = f0*z
       z     = a0*1.0e-9_rp
!       dumdd = z*rmdd
!       dumda = z*rmda
!       dumdz = z*rmdz

       xnum   = 1.0e0_rp/dum
       z      = -xnum*xnum
!       xnumdt = z*dumdt
!       xnumdd = z*dumdd
!       xnumda = z*dumda
!       xnumdz = z*dumdz

       c00   = 7.75e5_rp*t832 + 247.0e0_rp*t8**(3.85e0_rp)
       dd00  = (1.5e0_rp*7.75e5_rp*t812 + 3.85e0_rp*247.0e0_rp*t8**(2.85e0_rp))*1.0e-8_rp

       c01   = 4.07e0_rp + 0.0240e0_rp * t8**(1.4e0_rp)
       dd01  = 1.4e0_rp*0.0240e0_rp*t8**(0.4e0_rp)*1.0e-8_rp

       c02   = 4.59e-5_rp * t8**(-0.110e0_rp)
       dd02  = -0.11e0_rp*4.59e-5_rp * t8**(-1.11e0_rp)*1.0e-8_rp

       z     = den**(0.656e0_rp)
       dum   = c00*rmi  + c01  + c02*z
!       dumdt = dd00*rmi + dd01 + dd02*z
       z     = -c00*rmi*rmi
!       dumdd = z*rmdd + 0.656e0_rp*c02*den**(-0.454e0_rp)
!       dumda = z*rmda
!       dumdz = z*rmdz

       xden  = 1.0e0_rp/dum
       z      = -xden*xden
!       xdendt = z*dumdt
!       xdendd = z*dumdd
!       xdenda = z*dumda
!       xdendz = z*dumdz

       gbrem   = xnum + xden
!       gbremdt = xnumdt + xdendt
!       gbremdd = xnumdd + xdendd
!       gbremda = xnumda + xdenda
!       gbremdz = xnumdz + xdendz


!..equation 5.1
       dum    = 0.5738e0_rp*zbar*ye*t86*den
!       dumdt  = 0.5738e0_rp*zbar*ye*6.0e0_rp*t85*den*1.0e-8_rp
!       dumdd  = 0.5738e0_rp*zbar*ye*t86
!       dumda  = -dum*abari
!       dumdz  = 0.5738e0_rp*2.0e0_rp*ye*t86*den

       z       = tfac4*fbrem - tfac5*gbrem
       sbrem   = dum * z
!       sbremdt = dumdt*z + dum*(tfac4*fbremdt - tfac5*gbremdt)
!       sbremdd = dumdd*z + dum*(tfac4*fbremdd - tfac5*gbremdd)
!       sbremda = dumda*z + dum*(tfac4*fbremda - tfac5*gbremda)
!       sbremdz = dumdz*z + dum*(tfac4*fbremdz - tfac5*gbremdz)




!..liquid metal with c12 parameters (not too different for other element
!..equation 5.18 and 5.16

      else
       u     = fac3 * (log10(den) - 3.0e0_rp)
       a0    = iln10*fac3*deni

!..compute the expensive trig functions of equation 5.21 only once
       cos1 = cos(u)
       cos2 = cos(2.0e0_rp*u)
       cos3 = cos(3.0e0_rp*u)
       cos4 = cos(4.0e0_rp*u)
       cos5 = cos(5.0e0_rp*u)

       sin1 = sin(u)
       sin2 = sin(2.0e0_rp*u)
       sin3 = sin(3.0e0_rp*u)
       sin4 = sin(4.0e0_rp*u)
       sin5 = sin(5.0e0_rp*u)

!..equation 5.21
       fb =  0.5e0_rp * 0.17946e0_rp  + 0.00945e0_rp*u + 0.34529e0_rp               &
             - 0.05821e0_rp*cos1 - 0.04969e0_rp*sin1                          &
             - 0.01089e0_rp*cos2 - 0.01584e0_rp*sin2                          &
             - 0.01147e0_rp*cos3 - 0.00504e0_rp*sin3                          &
             - 0.00656e0_rp*cos4 - 0.00281e0_rp*sin4                          &
             - 0.00519e0_rp*cos5

       c00 =  a0*(0.00945e0_rp                                             &
             + 0.05821e0_rp*sin1       - 0.04969e0_rp*cos1                    &
             + 0.01089e0_rp*sin2*2.0e0_rp - 0.01584e0_rp*cos2*2.0e0_rp              &
             + 0.01147e0_rp*sin3*3.0e0_rp - 0.00504e0_rp*cos3*3.0e0_rp              &
             + 0.00656e0_rp*sin4*4.0e0_rp - 0.00281e0_rp*cos4*4.0e0_rp              &
             + 0.00519e0_rp*sin5*5.0e0_rp)


!..equation 5.22
       ft =  0.5e0_rp * 0.06781e0_rp - 0.02342e0_rp*u + 0.24819e0_rp                &
             - 0.00944e0_rp*cos1 - 0.02213e0_rp*sin1                          &
             - 0.01289e0_rp*cos2 - 0.01136e0_rp*sin2                          &
             - 0.00589e0_rp*cos3 - 0.00467e0_rp*sin3                          &
             - 0.00404e0_rp*cos4 - 0.00131e0_rp*sin4                          &
             - 0.00330e0_rp*cos5

       c01 = a0*(-0.02342e0_rp                                             &
             + 0.00944e0_rp*sin1       - 0.02213e0_rp*cos1                    &
             + 0.01289e0_rp*sin2*2.0e0_rp - 0.01136e0_rp*cos2*2.0e0_rp              &
             + 0.00589e0_rp*sin3*3.0e0_rp - 0.00467e0_rp*cos3*3.0e0_rp              &
             + 0.00404e0_rp*sin4*4.0e0_rp - 0.00131e0_rp*cos4*4.0e0_rp              &
             + 0.00330e0_rp*sin5*5.0e0_rp)


!..equation 5.23
       gb =  0.5e0_rp * 0.00766e0_rp - 0.01259e0_rp*u + 0.07917e0_rp                &
             - 0.00710e0_rp*cos1 + 0.02300e0_rp*sin1                          &
             - 0.00028e0_rp*cos2 - 0.01078e0_rp*sin2                          &
             + 0.00232e0_rp*cos3 + 0.00118e0_rp*sin3                          &
             + 0.00044e0_rp*cos4 - 0.00089e0_rp*sin4                          &
             + 0.00158e0_rp*cos5

       c02 = a0*(-0.01259e0_rp                                             &
             + 0.00710e0_rp*sin1       + 0.02300e0_rp*cos1                    &
             + 0.00028e0_rp*sin2*2.0e0_rp - 0.01078e0_rp*cos2*2.0e0_rp              &
             - 0.00232e0_rp*sin3*3.0e0_rp + 0.00118e0_rp*cos3*3.0e0_rp              &
             - 0.00044e0_rp*sin4*4.0e0_rp - 0.00089e0_rp*cos4*4.0e0_rp              &
             - 0.00158e0_rp*sin5*5.0e0_rp)


!..equation 5.24
       gt =  -0.5e0_rp * 0.00769e0_rp  - 0.00829e0_rp*u + 0.05211e0_rp              &
             + 0.00356e0_rp*cos1 + 0.01052e0_rp*sin1                          &
             - 0.00184e0_rp*cos2 - 0.00354e0_rp*sin2                          &
             + 0.00146e0_rp*cos3 - 0.00014e0_rp*sin3                          &
             + 0.00031e0_rp*cos4 - 0.00018e0_rp*sin4                          &
             + 0.00069e0_rp*cos5

       c03 = a0*(-0.00829e0_rp                                             &
             - 0.00356e0_rp*sin1       + 0.01052e0_rp*cos1                    &
             + 0.00184e0_rp*sin2*2.0e0_rp - 0.00354e0_rp*cos2*2.0e0_rp              &
             - 0.00146e0_rp*sin3*3.0e0_rp - 0.00014e0_rp*cos3*3.0e0_rp              &
             - 0.00031e0_rp*sin4*4.0e0_rp - 0.00018e0_rp*cos4*4.0e0_rp              &
             - 0.00069e0_rp*sin5*5.0e0_rp)


       dum   = 2.275e-1_rp * zbar * zbar*t8m1 * (den6*abari)**oneth
!       dumdt = -dum*tempi
!       dumdd = oneth*dum*deni
!       dumda = -oneth*dum*abari
!       dumdz = 2.0e0_rp*dum*zbari

       gm1   = 1.0e0_rp/dum
       gm2   = gm1*gm1
       gm13  = gm1**oneth
       gm23  = gm13 * gm13
       gm43  = gm13*gm1
       gm53  = gm23*gm1


!..equation 5.25 and 5.26
       v  = -0.05483e0_rp - 0.01946e0_rp*gm13 + 1.86310e0_rp*gm23 - 0.78873e0_rp*gm1
       a0 = oneth*0.01946e0_rp*gm43 - twoth*1.86310e0_rp*gm53 + 0.78873e0_rp*gm2

       w  = -0.06711e0_rp + 0.06859e0_rp*gm13 + 1.74360e0_rp*gm23 - 0.74498e0_rp*gm1
       a1 = -oneth*0.06859e0_rp*gm43 - twoth*1.74360e0_rp*gm53 + 0.74498e0_rp*gm2


!..equation 5.19 and 5.20
       fliq   = v*fb + (1.0e0_rp - v)*ft
!       fliqdt = a0*dumdt*(fb - ft)
!       fliqdd = a0*dumdd*(fb - ft) + v*c00 + (1.0e0_rp - v)*c01
!       fliqda = a0*dumda*(fb - ft)
!       fliqdz = a0*dumdz*(fb - ft)

       gliq   = w*gb + (1.0e0_rp - w)*gt
!       gliqdt = a1*dumdt*(gb - gt)
!       gliqdd = a1*dumdd*(gb - gt) + w*c02 + (1.0e0_rp - w)*c03
!       gliqda = a1*dumda*(gb - gt)
!       gliqdz = a1*dumdz*(gb - gt)


!..equation 5.17
       dum    = 0.5738e0_rp*zbar*ye*t86*den
!       dumdt  = 0.5738e0_rp*zbar*ye*6.0e0_rp*t85*den*1.0e-8_rp
!       dumdd  = 0.5738e0_rp*zbar*ye*t86
!       dumda  = -dum*abari
!       dumdz  = 0.5738e0_rp*2.0e0_rp*ye*t86*den

       z       = tfac4*fliq - tfac5*gliq
       sbrem   = dum * z
!       sbremdt = dumdt*z + dum*(tfac4*fliqdt - tfac5*gliqdt)
!       sbremdd = dumdd*z + dum*(tfac4*fliqdd - tfac5*gliqdd)
!       sbremda = dumda*z + dum*(tfac4*fliqda - tfac5*gliqda)
!       sbremdz = dumdz*z + dum*(tfac4*fliqdz - tfac5*gliqdz)

      end if




!..recombination neutrino section
!..for reactions like e- (continuum) => e- (bound) + nu_e + nubar_e
!..equation 6.11 solved for nu
      xnum   = 1.10520e8_rp * den * ye /(temp*sqrt(temp))
!      xnumdt = -1.50e0_rp*xnum*tempi
!      xnumdd = xnum*deni
!      xnumda = -xnum*abari
!      xnumdz = xnum*zbari

!..the chemical potential
      nu   = ifermi12(xnum)

!..a0 is d(nu)/d(xnum)
      a0 = 1.0e0_rp/(0.5e0_rp*zfermim12(nu))
!      nudt = a0*xnumdt
!      nudd = a0*xnumdd
!      nuda = a0*xnumda
!      nudz = a0*xnumdz

      nu2  = nu * nu
      nu3  = nu2 * nu

!..table 12
      if (nu .ge. -20.0_rp  .and. nu .lt. 0.0_rp) then
       a1 = 1.51e-2_rp
       a2 = 2.42e-1_rp
       a3 = 1.21e0_rp
       b  = 3.71e-2_rp
       c  = 9.06e-1_rp
       d  = 9.28e-1_rp
       f1 = 0.0e0_rp
       f2 = 0.0e0_rp
       f3 = 0.0e0_rp
      else if (nu .ge. 0.0_rp  .and. nu .le. 10.0_rp) then
       a1 = 1.23e-2_rp
       a2 = 2.66e-1_rp
       a3 = 1.30e0_rp
       b  = 1.17e-1_rp
       c  = 8.97e-1_rp
       d  = 1.77e-1_rp
       f1 = -1.20e-2_rp
       f2 = 2.29e-2_rp
       f3 = -1.04e-3_rp
      end if


!..equation 6.7, 6.13 and 6.14
      if (nu .ge. -20.0_rp  .and.  nu .le. 10.0_rp) then

       zeta   = 1.579e5_rp*zbar*zbar*tempi
!       zetadt = -zeta*tempi
!       zetadd = 0.0e0_rp
!       zetada = 0.0e0_rp
!       zetadz = 2.0e0_rp*zeta*zbari

       c00    = 1.0e0_rp/(1.0e0_rp + f1*nu + f2*nu2 + f3*nu3)
       c01    = f1 + f2*2.0e0_rp*nu + f3*3.0e0_rp*nu2
       dum    = zeta*c00
!       dumdt  = zetadt*c00 + zeta*c01*nudt
!       dumdd  = zeta*c01*nudd
!       dumda  = zeta*c01*nuda
!       dumdz  = zetadz*c00 + zeta*c01*nudz


       z      = 1.0e0_rp/dum
       dd00   = dum**(-2.25_rp)
       dd01   = dum**(-4.55_rp)
       c00    = a1*z + a2*dd00 + a3*dd01
       c01    = -(a1*z + 2.25_rp*a2*dd00 + 4.55_rp*a3*dd01)*z


       z      = exp(c*nu)
       dd00   = b*z*(1.0e0_rp + d*dum)
       gum    = 1.0e0_rp + dd00
!       gumdt  = dd00*c*nudt + b*z*d*dumdt
!       gumdd  = dd00*c*nudd + b*z*d*dumdd
!       gumda  = dd00*c*nuda + b*z*d*dumda
!       gumdz  = dd00*c*nudz + b*z*d*dumdz


       z   = exp(nu)
       a1  = 1.0e0_rp/gum

       bigj   = c00 * z * a1
!       bigjdt = c01*dumdt*z*a1 + c00*z*nudt*a1 - c00*z*a1*a1 * gumdt
!       bigjdd = c01*dumdd*z*a1 + c00*z*nudd*a1 - c00*z*a1*a1 * gumdd
!       bigjda = c01*dumda*z*a1 + c00*z*nuda*a1 - c00*z*a1*a1 * gumda
!       bigjdz = c01*dumdz*z*a1 + c00*z*nudz*a1 - c00*z*a1*a1 * gumdz


!..equation 6.5
       z     = exp(zeta + nu)
       dum   = 1.0e0_rp + z
       a1    = 1.0e0_rp/dum
       a2    = 1.0e0_rp/bigj

       sreco   = tfac6 * 2.649e-18_rp * ye * zbar**13 * den * bigj*a1
!       srecodt = sreco*(bigjdt*a2 - z*(zetadt + nudt)*a1)
!       srecodd = sreco*(1.0e0_rp*deni + bigjdd*a2 - z*(zetadd + nudd)*a1)
!       srecoda = sreco*(-1.0e0_rp*abari + bigjda*a2 - z*(zetada+nuda)*a1)
!       srecodz = sreco*(14.0e0_rp*zbari + bigjdz*a2 - z*(zetadz+nudz)*a1)

      end if


!..convert from erg/cm^3/s to erg/g/s
!..comment these out to duplicate the itoh et al plots

      spair   = spair*deni
!      spairdt = spairdt*deni
!      spairdd = spairdd*deni - spair*deni
!      spairda = spairda*deni
!      spairdz = spairdz*deni

      splas   = splas*deni
!      splasdt = splasdt*deni
!      splasdd = splasdd*deni - splas*deni
!      splasda = splasda*deni
!      splasdz = splasdz*deni

      sphot   = sphot*deni
!      sphotdt = sphotdt*deni
!      sphotdd = sphotdd*deni - sphot*deni
!      sphotda = sphotda*deni
!      sphotdz = sphotdz*deni

      sbrem   = sbrem*deni
!      sbremdt = sbremdt*deni
!      sbremdd = sbremdd*deni - sbrem*deni
!      sbremda = sbremda*deni
!      sbremdz = sbremdz*deni

      sreco   = sreco*deni
!      srecodt = srecodt*deni
!      srecodd = srecodd*deni - sreco*deni
!      srecoda = srecoda*deni
!      srecodz = srecodz*deni

!..the total neutrino loss rate
      snu    =  splas + spair + sphot + sbrem + sreco
!      dsnudt =  splasdt + spairdt + sphotdt + sbremdt + srecodt
!      dsnudd =  splasdd + spairdd + sphotdd + sbremdd + srecodd
!      dsnuda =  splasda + spairda + sphotda + sbremda + srecoda
!      dsnudz =  splasdz + spairdz + sphotdz + sbremdz + srecodz

!xx
!      snu    = sreco
!      dsnudt = srecodt
!      dsnudd = srecodd
!      dsnuda = srecoda
!      dsnudz = srecodz

#ifdef BOOST_NEULOSS
      snu = snu*boost_neuloss
#endif

 end subroutine sneut5

 function ifermi12(f)
!..this routine applies a rational function expansion to get the inverse
!..fermi-dirac integral of order 1/2 when it is equal to f.
!..maximum error is 4.19e-9_rp.   reference: antia apjs 84,101 1993

!..declare
      real(kind=rp), intent(in) :: f
      real(kind=rp) ifermi12, den, ff, rn
      integer :: i

!..load the coefficients of the expansion

      real(kind=rp), parameter ::  an=0.5_rp
      integer, parameter ::  m1=4, k1=3, m2=6, k2=5
      real(kind=rp), parameter ::  a1(5) = (/ 1.999266880833e4_rp,   5.702479099336e3_rp,        &
           6.610132843877e2_rp,   3.818838129486e1_rp,                        &
           1.0e0_rp/), &
      b1(4) = (/ 1.771804140488e4_rp,  -2.014785161019e3_rp,        &
           9.130355392717e1_rp,  -1.670718177489e0_rp/), &
      a2(7) = (/-1.277060388085e-2_rp,  7.187946804945e-2_rp,       &
                          -4.262314235106e-1_rp,  4.997559426872e-1_rp,       &
                          -1.285579118012e0_rp,  -3.930805454272e-1_rp,       &
           1.0e0_rp/), &
      b2(6) = (/-9.745794806288e-3_rp,  5.485432756838e-2_rp,       &
                          -3.299466243260e-1_rp,  4.077841975923e-1_rp,       &
                          -1.145531476975e0_rp,  -6.067091689181e-2_rp/)


      if (f .lt. 4.0e0_rp) then
       rn  = f + a1(m1)
       do i=m1-1,1,-1
        rn  = rn*f + a1(i)
       enddo
       den = b1(k1+1)
       do i=k1,1,-1
        den = den*f + b1(i)
       enddo
       ifermi12 = log(f * rn/den)

      else
       ff = 1.0e0_rp/f**(1.0e0_rp/(1.0e0_rp + an))
       rn = ff + a2(m2)
       do i=m2-1,1,-1
        rn = rn*ff + a2(i)
       enddo
       den = b2(k2+1)
       do i=k2,1,-1
        den = den*ff + b2(i)
       enddo
       ifermi12 = rn/(den*ff)
      end if
 end function ifermi12

 function zfermim12(x)
!..this routine applies a rational function expansion to get the fermi-d
!..integral of order -1/2 evaluated at x. maximum error is 1.23e-12_rp.
!..reference: antia apjs 84,101 1993

!..declare
      real(kind=rp), intent(in) :: x
      real(kind=rp) :: zfermim12, den, rn, xx
      integer ::       i

!..load the coefficients of the expansion
      integer, parameter ::  m1=7, k1=7, m2=11, k2=11
      real(kind=rp), parameter :: a1(8) = (/ 1.71446374704454e7_rp,    3.88148302324068e7_rp,   &
                           3.16743385304962e7_rp,    1.14587609192151e7_rp,   &
                           1.83696370756153e6_rp,    1.14980998186874e5_rp,   &
                           1.98276889924768e3_rp,    1.0e0_rp/), &
      b1(8) = (/ 9.67282587452899e6_rp,    2.87386436731785e7_rp,   &
                           3.26070130734158e7_rp,    1.77657027846367e7_rp,   &
                           4.81648022267831e6_rp,    6.13709569333207e5_rp,   &
                           3.13595854332114e4_rp,    4.35061725080755e2_rp/), &
      a2(12) = (/-4.46620341924942e-15_rp, -1.58654991146236e-12_rp, &
                          -4.44467627042232e-10_rp, -6.84738791621745e-8_rp,  &
                          -6.64932238528105e-6_rp,  -3.69976170193942e-4_rp,  &
                          -1.12295393687006e-2_rp,  -1.60926102124442e-1_rp,  &
                          -8.52408612877447e-1_rp,  -7.45519953763928e-1_rp,  &
                           2.98435207466372e0_rp,    1.0e0_rp/), &
      b2(12) = (/-2.23310170962369e-15_rp, -7.94193282071464e-13_rp, &
                          -2.22564376956228e-10_rp, -3.43299431079845e-8_rp,  &
                          -3.33919612678907e-6_rp,  -1.86432212187088e-4_rp,  &
                          -5.69764436880529e-3_rp,  -8.34904593067194e-2_rp,  &
                          -4.78770844009440e-1_rp,  -4.99759250374148e-1_rp,  &
                           1.86795964993052e0_rp,    4.16485970495288e-1_rp/)


      if (x .lt. 2.0e0_rp) then
       xx = exp(x)
       rn = xx + a1(m1)
       do i=m1-1,1,-1
        rn = rn*xx + a1(i)
       enddo
       den = b1(k1+1)
       do i=k1,1,-1
        den = den*xx + b1(i)
       enddo
       zfermim12 = xx * rn/den
!..
      else
       xx = 1.0e0_rp/(x*x)
       rn = xx + a2(m2)
       do i=m2-1,1,-1
        rn = rn*xx + a2(i)
       enddo
       den = b2(k2+1)
       do i=k2,1,-1
        den = den*xx + b2(i)
       enddo
       zfermim12 = sqrt(x)*rn/den
      end if

 end function zfermim12

#endif

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! NUCLEAR NETWORK
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#ifdef USE_NUCLEAR_NETWORK

 subroutine nuclear_network_step(mgrid,lgrid,dt)
  type(mpigrid), intent(inout) :: mgrid
  type(locgrid), intent(inout) :: lgrid
  real(kind=rp), intent(in) :: dt
 
  real(kind=rp), dimension(1:nspecies) :: Y,Y0,res,dY
  integer :: iv,i,j,k
  real(kind=rp) :: rho,T
  real(kind=rp), dimension(1:nreacs) :: rates
  real(kind=rp), dimension(1:nspecies,1:nspecies) :: jac
  real(kind=rp) :: T9,L2_def
#ifdef NUCLEAR_NETWORK_TRBDF2
  real(kind=rp), dimension(1:3,1:3) :: akl
  real(kind=rp), dimension(1:nspecies) :: res_esdirk1,res_esdirk2
  real(kind=rp), dimension(1:nreacs) :: res_ene2,res_ene3
#endif
  real(kind=rp), dimension(1:nreacs) :: res_ene1
  real(kind=rp) :: theta,eint,deltae,tmp,tmp1,tmp2,tmp3,abar,zbar,ye

  real(kind=rp) :: gm,gmm1,igmm1,inv_mu,inv_abar,mu
  real(kind=rp) :: Res0,Res_prad,dRes_dT,T2,T3,T4,dp_drho,dp_deps,sound2,sound
  integer :: iter
  real(kind=rp) :: p,snu,res_snu1,res_snu2,res_snu3,idt,Xsum,iXsum

  eint = rp0

  gm = lgrid%gm
  gmm1 = gm-rp1
  igmm1 = rp1/gmm1

  tmp1 = rp0
  tmp2 = rp0
  tmp3 = rp0

  Res0 = rp0
  Res_prad = rp0
  dRes_dT = rp0

  dp_drho = rp0
  dp_deps = rp0
  sound2 = rp0
  sound = rp0

  abar = rp0
  inv_abar = rp0
  zbar = rp0
  ye = rp0
  p = rp0

  T2 = rp0
  T3 = rp0
  T4 = rp0

  inv_mu = rp0
  mu = rp0

  snu = rp0
  res_snu1 = rp0
  res_snu2 = rp0
  res_snu3 = rp0
  theta = rp0

  idt = rp1/dt

  Xsum = rp1
  iXsum = rp1

  iter = 0

#ifdef NUCLEAR_NETWORK_TRBDF2

  do j=1,3
   do i=1,3
    akl(i,j) = rp0
   end do
  end do

  theta = rp2-sqrt(rp2)
 
  akl(2,1) = rph*theta
  akl(2,2) = rph*theta
  akl(3,1) = rph*(rp3*theta-theta*theta-rp1)/theta
  akl(3,2) = rph*(rp1-theta)/theta
  akl(3,3) = rph*theta

#endif

  do j=1,nspecies
   do i=1,nspecies
    jac(i,j) = rp0
   end do
  end do

  do k=mgrid%i1(3),mgrid%i2(3)
   do j=mgrid%i1(2),mgrid%i2(2)
    do i=mgrid%i1(1),mgrid%i2(1)

     deltae = rp0
     rho = lgrid%prim(i_rho,i,j,k)
     T = lgrid%temp(i,j,k)

     do iv=1,nreacs
      lgrid%edot_nuc(iv,i,j,k) = rp0
      res_ene1(iv) = rp0
#ifdef NUCLEAR_NETWORK_TRBDF2
      res_ene2(iv) = rp0
      res_ene3(iv) = rp0
#endif
     end do

     do iv=1,nspecies
      Y(iv) = lgrid%prim(i_as1+iv-1,i,j,k)
      lgrid%X_species_dot(iv,i,j,k) = rp0
     end do

     Xsum = rp0
     do iv=1,nspecies
      Xsum = Xsum + Y(iv)
     end do
     iXsum = rp1/Xsum

     do iv=1,nspecies
      Y(iv) = Y(iv)*iXsum/lgrid%A(iv)
     end do

#ifdef USE_INTERNAL_BOUNDARIES
     if((T>nn_Tmin) .and. (lgrid%is_solid(i,j,k)==0)) then
#else
     if(T>nn_Tmin) then
#endif

      T9 = T*em9

      do iv=1,nspecies
       Y0(iv) = Y(iv)
      end do

      call compute_jina_rates(T9,rates)

#ifdef USE_LMP_WEAK_RATES
      ye = rp0
      do iv=1,nspecies
       ye = ye + Y0(iv)*lgrid%Z(iv)
      end do    
      call compute_weak_rates(rho*ye,T9,dt,lgrid%weak_table,lgrid%weak_neu,lgrid%neu_rates,rates)
#endif

#ifdef PARTITION_FUNCTIONS_FOR_REVERSE_RATES
      call use_partition_functions(T9,lgrid%temp_part,lgrid%part,rates)
#endif

#ifdef USE_ELECTRON_SCREENING
      call screen_rates(rho,T,Y0,rates)
#endif

#ifdef BOOST_NUCLEAR_REACTIONS
      do iv=1,nreacs
       rates(iv) = rates(iv)*boost_reacs 
      end do
#endif

#ifdef SAVE_SPECIES_FLUXES
      call species_residuals_per_reac(Y,rho,rates,lgrid%X_species_dot_reacs(:,:,i,j,k))
#endif

      do iv=1,nreacs
       rates(iv) = rates(iv)*dt
      end do

#ifdef NUCLEAR_NETWORK_TRBDF2

#ifdef USE_NEULOSS
      
      ye = rp0
      inv_abar = rp0
      do iv=1,nspecies
       tmp = Y0(iv)
       inv_abar = inv_abar + tmp
       ye = ye + tmp*lgrid%Z(iv)
      end do
      abar = rp1/inv_abar
      zbar = ye*abar

      snu = rp0
      call sneut5(T,rho,abar,zbar,snu)
      res_snu1 = -rho*snu

#endif

      call compute_network_residuals(Y,rho,rates,res,jac,res_ene1,.true.,.true.)
 
#ifdef USE_LMP_WEAK_RATES
      call compute_weak_neuloss(rho,Y,lgrid%neu_rates,res_ene1)
#endif

      do iv=1,nspecies
       res_esdirk1(iv) = res(iv)
      end do
  
      tmp = rp1/akl(2,2)
      tmp1 = akl(2,1)*tmp
      tmp2 = tmp
      do iv=1,nspecies
       res(iv) = res(iv) + &
       res_esdirk1(iv)*tmp1 + (Y(iv)-Y0(iv))*tmp2
      end do
       
      do iv=1,nspecies
       jac(iv,iv) = jac(iv,iv) + tmp2
      end do
     
      L2_def = rp0
      do iv=1,nspecies
       L2_def = L2_def + res(iv)*res(iv)
      end do 
      L2_def = sqrt(L2_def/real(nspecies,kind=rp))

      do while(L2_def > nn_nltol)

       call nuclear_network_bicgstab(res,jac,dY)
  
       do iv=1,nspecies
        Y(iv) = Y(iv) + dY(iv)
       end do 

       call compute_network_residuals(Y,rho,rates,res,jac,res_ene2,.true.,.false.)

       do iv=1,nspecies
        res(iv) = res(iv) + &
        res_esdirk1(iv)*tmp1 + (Y(iv)-Y0(iv))*tmp2
       end do
 
       do iv=1,nspecies
        jac(iv,iv) = jac(iv,iv) + tmp2
       end do

       L2_def = rp0
       do iv=1,nspecies
        L2_def = L2_def + res(iv)*res(iv)
       end do
       L2_def = sqrt(L2_def/real(nspecies,kind=rp))
     
      end do

#ifdef USE_NEULOSS
      
      ye = rp0
      inv_abar = rp0
      do iv=1,nspecies
       tmp1 = Y(iv)
       inv_abar = inv_abar + tmp1
       ye = ye + tmp1*lgrid%Z(iv)
      end do
      abar = rp1/inv_abar
      zbar = ye*abar

      snu = rp0
      call sneut5(T,rho,abar,zbar,snu)
      res_snu2 = -rho*snu

#endif

      call compute_network_residuals(Y,rho,rates,res,jac,res_ene2,.true.,.true.)
 
#ifdef USE_LMP_WEAK_RATES
      call compute_weak_neuloss(rho,Y,lgrid%neu_rates,res_ene2)
#endif

      do iv=1,nspecies
       res_esdirk2(iv) = res(iv)
      end do

      tmp = rp1/akl(3,3)
      tmp1 = akl(3,1)*tmp
      tmp2 = akl(3,2)*tmp
      tmp3 = tmp

      do iv=1,nspecies
       res(iv) = res(iv) + &
       res_esdirk1(iv)*tmp1 + & 
       res_esdirk2(iv)*tmp2 + & 
       (Y(iv)-Y0(iv))*tmp3
      end do

      do iv=1,nspecies
       jac(iv,iv) = jac(iv,iv) + tmp3
      end do
     
      L2_def = rp0
      do iv=1,nspecies
       L2_def = L2_def + res(iv)*res(iv)
      end do
      L2_def = sqrt(L2_def/real(nspecies,kind=rp))

      do while(L2_def > nn_nltol)
 
       call nuclear_network_bicgstab(res,jac,dY)
 
       do iv=1,nspecies
        Y(iv) = Y(iv) + dY(iv)
       end do 
     
       call compute_network_residuals(Y,rho,rates,res,jac,res_ene3,.true.,.false.)

       do iv=1,nspecies
        res(iv) = res(iv) + &
        res_esdirk1(iv)*tmp1 + & 
        res_esdirk2(iv)*tmp2 + & 
        (Y(iv)-Y0(iv))*tmp3
       end do

       do iv=1,nspecies
        jac(iv,iv) = jac(iv,iv) + tmp3
       end do

       L2_def = rp0
       do iv=1,nspecies
        L2_def = L2_def + res(iv)*res(iv)
       end do
       L2_def = sqrt(L2_def/real(nspecies,kind=rp))

      end do
 
#ifdef USE_NEULOSS
      
      ye = rp0
      inv_abar = rp0
      do iv=1,nspecies
       tmp1 = Y(iv)
       inv_abar = inv_abar + tmp1
       ye = ye + tmp1*lgrid%Z(iv)
      end do
      abar = rp1/inv_abar
      zbar = ye*abar

      snu = rp0
      call sneut5(T,rho,abar,zbar,snu)
      res_snu3 = -rho*snu

#endif

      call compute_network_residuals(Y,rho,rates,res,jac,res_ene3,.false.,.true.)
 
#ifdef USE_LMP_WEAK_RATES
      call compute_weak_neuloss(rho,Y,lgrid%neu_rates,res_ene3)
#endif

      tmp1 = akl(3,1)
      tmp2 = akl(3,2)
      tmp3 = akl(3,3)

      deltae = rp0
      do iv=1,nreacs
       tmp =  & 
       tmp1*res_ene1(iv) + &
       tmp2*res_ene2(iv) + &
       tmp3*res_ene3(iv) 
       lgrid%edot_nuc(iv,i,j,k) = tmp*idt
       deltae = deltae + tmp
      end do

#ifdef USE_NEULOSS
      tmp =  & 
      tmp1*res_snu1 + &
      tmp2*res_snu2 + &
      tmp3*res_snu3 
      deltae = deltae + tmp*dt
      lgrid%edot_nuc(nreacs+1,i,j,k) = tmp
#endif

#endif

#ifdef NUCLEAR_NETWORK_BE

      call compute_network_residuals(Y,rho,rates,res,jac,res,.true.,.false.)

      do iv=1,nspecies
       res(iv) = res(iv) + &
       (Y(iv)-Y0(iv))
      end do
       
      do iv=1,nspecies
       jac(iv,iv) = jac(iv,iv) + rp1
      end do
     
      L2_def = rp0
      do iv=1,nspecies
       L2_def = L2_def + res(iv)**2
      end do 
      L2_def = sqrt(L2_def/real(nspecies,kind=rp))

      do while(L2_def > nn_nltol)

       call nuclear_network_bicgstab(res,jac,dY)
  
       do iv=1,nspecies
        Y(iv) = Y(iv) + dY(iv)
       end do 

       call compute_network_residuals(Y,rho,rates,res,jac,res_ene1,.true.,.false.)

       do iv=1,nspecies
        res(iv) = res(iv) + &
        (Y(iv)-Y0(iv))
       end do
 
       do iv=1,nspecies
        jac(iv,iv) = jac(iv,iv) + rp1
       end do

       L2_def = rp0
       do iv=1,nspecies
        L2_def = L2_def + res(iv)*res(iv)
       end do
       L2_def = sqrt(L2_def/real(nspecies,kind=rp))

      end do

#ifdef USE_NEULOSS
      
      ye = rp0
      inv_abar = rp0
      do iv=1,nspecies
       tmp1 = Y(iv)
       inv_abar = inv_abar + tmp1
       ye = ye + tmp1*lgrid%Z(iv)
      end do
      abar = rp1/inv_abar
      zbar = ye*abar

      snu = rp0
      call sneut5(T,rho,abar,zbar,snu)
      res_snu1 = -rho*snu

#endif

      call compute_network_residuals(Y,rho,rates,res,jac,res_ene1,.false.,.true.)
 
#ifdef USE_LMP_WEAK_RATES
      call compute_weak_neuloss(rho,Y,lgrid%neu_rates,res_ene1)
#endif

      deltae = rp0
      do iv=1,nreacs
       tmp = res_ene1(iv)
       lgrid%edot_nuc(iv,i,j,k) = tmp*idt
       deltae = deltae + tmp
      end do

#ifdef USE_NEULOSS
      deltae = deltae + res_snu1*dt
      lgrid%edot_nuc(nreacs+1,i,j,k) = res_snu1
#endif

#endif

      do iv=1,nspecies
       lgrid%X_species_dot(iv,i,j,k) = (Y(iv)-Y0(iv))*lgrid%A(iv)*idt
      end do

      Xsum = rp0
      do iv=1,nspecies
       Xsum = Xsum + Y(iv)*lgrid%A(iv)
      end do
      iXsum = rp1/Xsum

      do iv=1,nspecies
       lgrid%prim(i_as1+iv-1,i,j,k) = Y(iv)*lgrid%A(iv)*iXsum
      end do

#ifndef SKIP_HYDRO
      lgrid%eint(i,j,k) = lgrid%eint(i,j,k) + &
      deltae

      eint = lgrid%eint(i,j,k)

      ye = rp0
      inv_abar = rp0
      do iv=1,nspecies
       tmp1 = Y(iv)*iXsum 
       inv_abar = inv_abar + tmp1
       ye = ye + lgrid%Z(iv)*tmp1
      end do
      abar = rp1/inv_abar
      zbar = ye*abar
      inv_mu = (zbar+rp1)/abar

#ifdef USE_PRAD
      tmp = igmm1*rho*CONST_RGAS*inv_mu
      T = lgrid%temp(i,j,k)
      Res_prad = -rp1
      do iter=1,250
       Res0 = Res_prad
       T2 = T*T
       T3 = T2*T
       T4 = T3*T
       Res_prad = CONST_RAD*T4 + tmp*T - eint
       if (abs(Res_prad/eint) < em14) exit
       if ((abs(Res0 - Res_prad)/abs(Res0) < em15) .and. iter>1) then
         write(*,*) 'NN: eint->temp, EoS gas+radiation, RN stalled, ','cell=(',i,j,k,')'
         exit
       end if
       dRes_dT = rp4*CONST_RAD*T3 + tmp
       T = T - Res_prad/dRes_dT
      end do
      T2 = T*T
      T3 = T2*T
      T4 = T3*T
      lgrid%temp(i,j,k) = T
      p = rho*CONST_RGAS*T*inv_mu + CONST_RAD*T4*othird
      lgrid%prim(i_p,i,j,k) = p
#ifdef USE_FASTEOS
      mu = rp1/inv_mu 

      tmp1 = CONST_RAD*mu*T3
      tmp2 = CONST_RGAS*rho

      dp_drho = fthirds * &
      CONST_RAD*CONST_RGAS*T4*(rp3*gm-rp4) / &
      (rp4*tmp1*gmm1+tmp2)

      dp_deps = gmm1 * &
      (rp4*tmp1+rp3*tmp2) / &
      (rp12*tmp1*gmm1+rp3*tmp2)

      sound2 = dp_drho+dp_deps*(p+eint)/rho

      lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
      lgrid%gammaf(i_gammac,i,j,k) = sound2*rho/p
#endif
#elif defined(HELMHOLTZ_EOS)
      T = lgrid%temp(i,j,k)
#ifdef USE_FASTEOS       
      call helm_rhoe_given(rho,eint/rho,abar,zbar,T,p,sound,.true.)
      lgrid%gammaf(i_gammae,i,j,k) = p/eint+rp1
      lgrid%gammaf(i_gammac,i,j,k) = sound*sound*rho/p
#else
      call helm_rhoe_given(rho,eint/rho,abar,zbar,T,p,sound,.false.)
#endif
      lgrid%prim(i_p,i,j,k) = p
      lgrid%temp(i,j,k) = T
#else
      p = gmm1*eint
      lgrid%prim(i_p,i,j,k) = p
      lgrid%temp(i,j,k) = p/(rho*CONST_RGAS*inv_mu)
#endif

#endif

     end if
 
    end do
   end do
  end do

 end subroutine nuclear_network_step

 subroutine nuclear_network_bicgstab(res,jac,dY)
   real(kind=rp), dimension(1:nspecies), intent(in) :: res
   real(kind=rp), dimension(1:nspecies,1:nspecies), intent(in) :: jac
   real(kind=rp), dimension(1:nspecies), intent(inout) :: dY

   real(kind=rp), dimension(1:nspecies) :: r,r0hat,p,v,s,t
   integer :: iv1, iv2, iv
   real(kind=rp) :: tmp,L2_lin,rhoi,rhoim1,wi,alpha,beta,num,den

   do iv1=1,nspecies
    dY(iv1) = rp0
    r(iv1) = -res(iv1)  
    tmp = r(iv1)
    p(iv1) = tmp
    v(iv1) = rp0
    r0hat(iv1) = tmp    
   end do

   rhoi = rp0
   do iv=1,nspecies
    tmp = r0hat(iv)
    rhoi = rhoi + tmp*tmp
   end do

   L2_lin = rp1
   do while(L2_lin > nn_ltol)

     do iv1=1,nspecies
      tmp = rp0
      do iv2=1,nspecies
       tmp = tmp + jac(iv1,iv2)*p(iv2)
      end do
      v(iv1) = tmp  
     end do

     den = rp0
     do iv=1,nspecies
      den = den + r0hat(iv)*v(iv)
     end do

     alpha = rhoi/den

     do iv=1,nspecies
      s(iv) = r(iv) - alpha*v(iv)
     end do

     do iv1=1,nspecies
      tmp = rp0
      do iv2=1,nspecies
       tmp = tmp + jac(iv1,iv2)*s(iv2)
      end do
      t(iv1) = tmp  
     end do

     num = rp0
     den = rp0

     do iv=1,nspecies
      tmp = t(iv)
      num = num + tmp*s(iv)
      den = den + tmp*tmp
     end do

     wi = num/den
     num = rp0

     do iv=1,nspecies
      dY(iv) = dY(iv) + alpha*p(iv) + wi*s(iv)
      r(iv) = s(iv) - wi*t(iv)
      num = num + r0hat(iv)*r(iv)
     end do

     rhoim1 = rhoi
     rhoi = num
     beta = (rhoi/rhoim1)*(alpha/wi)

     do iv=1,nspecies
      p(iv) = r(iv) + beta*(p(iv)-wi*v(iv))
     end do

     L2_lin = rp0
     do iv=1,nspecies
      L2_lin = L2_lin + r(iv)*r(iv)
     end do
     L2_lin = sqrt(L2_lin/real(nspecies,kind=rp))

   end do

 end subroutine nuclear_network_bicgstab

#endif

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! HELMHOLTZ EOS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#ifdef HELMHOLTZ_EOS

#ifdef USE_TIMMES_KAPPA
 subroutine load_helm_table(helm_table_var, dpdrho_table_var, eta_table, xf_table, helm_rho, helm_T, helm_drho, helm_dT)
#else
 subroutine load_helm_table(helm_table_var, dpdrho_table_var, helm_rho, helm_T, helm_drho, helm_dT)
#endif
  real(kind=rp), dimension(1:helm_nvars,1:helm_nrho,1:helm_nT), intent(out) :: helm_table_var
  real(kind=rp), dimension(1:4,1:helm_nrho,1:helm_nT), intent(out) :: dpdrho_table_var 
#ifdef USE_TIMMES_KAPPA
  real(kind=rp), dimension(1:4,1:helm_nrho,1:helm_nT), intent(out) :: eta_table
  real(kind=rp), dimension(1:4,1:helm_nrho,1:helm_nT), intent(out) :: xf_table
#endif
  real(kind=rp), dimension(1:helm_nrho), intent(out) :: helm_rho
  real(kind=rp), dimension(1:helm_nT), intent(out) :: helm_T
  real(kind=rp), intent(out) :: helm_drho, helm_dT

  integer :: i,j

  open(unit=iunit,file=path_to_helm_table,status='old')

  helm_dT = ((helm_lthi)-(helm_ltlo))/real(helm_nT-1,kind=rp)
  helm_drho = ((helm_ldhi)-(helm_ldlo))/real(helm_nrho-1,kind=rp)

  do j=1,helm_nT

   helm_T(j) = 10**((helm_ltlo)+real(j-1,kind=rp)*helm_dT)

   do i=1,helm_nrho

     helm_rho(i) = 10**((helm_ldlo)+real(i-1,kind=rp)*helm_drho)

     read(iunit,*) & 
     helm_table_var(id_f,i,j), &
     helm_table_var(id_dfdrho,i,j), &
     helm_table_var(id_dfdT,i,j), &
     helm_table_var(id_d2fdrho2,i,j), &
     helm_table_var(id_d2fdT2,i,j), &
     helm_table_var(id_d2fdrhodT,i,j), &
     helm_table_var(id_d3fdrho2dT,i,j), &
     helm_table_var(id_d3fdrhodT2,i,j), &
     helm_table_var(id_d4fdrho2dT2,i,j)

   end do
  end do

  do j=1,helm_nT
   do i=1,helm_nrho
     read(iunit,*) &
     dpdrho_table_var(id_c,i,j), &
     dpdrho_table_var(id_dcdrho,i,j), &
     dpdrho_table_var(id_dcdT,i,j), &
     dpdrho_table_var(id_d2cdrhodT,i,j)
   end do
  end do

#ifdef USE_TIMMES_KAPPA

  do j=1,helm_nT
   do i=1,helm_nrho
     read(iunit,*) & 
     eta_table(id_eta,i,j), &
     eta_table(id_detadrho,i,j), &
     eta_table(id_detadT,i,j), &
     eta_table(id_d2etadrhodT,i,j)
   end do
  end do

  do j=1,helm_nT
   do i=1,helm_nrho
     read(iunit,*) & 
     xf_table(id_xf,i,j), &
     xf_table(id_dxfdrho,i,j), &
     xf_table(id_dxfdT,i,j), &
     xf_table(id_d2xfdrhodT,i,j)
   end do
  end do

#endif

  close(iunit)

 end subroutine load_helm_table

#ifdef USE_TIMMES_KAPPA

 subroutine helm_rhoT_given_extra(rho,T,abar,zbar,P,eta,xf)
 real(kind=rp), intent(in) :: rho,T,abar,zbar
 real(kind=rp), intent(inout) :: P,eta,xf

 real(kind=rp) :: &
 loc_eos1, &
 loc_eos2, &
 loc_eos3, &
 loc_eos4, &
 loc_eos5, &
 loc_eos6, &
 loc_eos7, &
 loc_eos8, &
 loc_eos9, &
 loc_eos10, &
 loc_eos11, &
 loc_eos12, &
 loc_eos13, &
 loc_eos14, &
 loc_eos15, &
 loc_eos16, &
 loc_eos17, &
 loc_eos18, &
 loc_eos19, &
 loc_eos20, &
 loc_eos21, &
 loc_eos22, &
 loc_eos23, &
 loc_eos24, &
 loc_eos25, &
 loc_eos26, &
 loc_eos27, &
 loc_eos28, &
 loc_eos29, &
 loc_eos30, &
 loc_eos31, &
 loc_eos32, &
 loc_eos33, &
 loc_eos34, &
 loc_eos35, &
 loc_eos36
 
 integer :: ih,jh

 real(kind=rp) :: df_drho
 real(kind=rp) :: Ye,rhos

 real(kind=rp) :: x,y,drho,drho2,dT,dT2,tmp
 real(kind=rp) :: p0r,p0t,p0mr,p0mt,p1r,p1t,p1mr,p1mt,p2r,p2t,p2mr,p2mt,idrho,idrho2,idT,idT2
 real(kind=rp) :: dp0r,dp1r,dp2r,dp0mr,dp1mr,dp2mr
 real(kind=rp) :: omx,omy
 real(kind=rp) :: x2,x3,x4,x5,y2,y3,y4,y5,omx2,omx3,omx4,omx5,omy2,omy3,omy4,omy5
 
 Ye = zbar/abar

 rhos = rho*Ye

 ih = int((log10(rhos)-log10(helm_rho(1)))/helm_drho) + 1
 jh = int((log10(T)-log10(helm_T(1)))/helm_dT) + 1

 tmp = helm_rho(ih)
 drho = helm_rho(ih+1)-tmp
 x = (rhos-tmp)/drho
 omx = rp1-x

 tmp = helm_T(jh)
 dT = helm_T(jh+1)-tmp
 y = (T-tmp)/dT
 omy = rp1-y

 drho2 = drho*drho
 dT2 = dT*dT

 idrho = rp1/drho
 idrho2 = idrho*idrho

 idT = rp1/dT
 idT2 = idT*idT

 loc_eos1 = helm_table_var(1,ih,jh)
 loc_eos2 = helm_table_var(1,ih+1,jh)
 loc_eos3 = helm_table_var(1,ih,jh+1)
 loc_eos4 = helm_table_var(1,ih+1,jh+1)
 loc_eos5 = helm_table_var(2,ih,jh)
 loc_eos6 = helm_table_var(2,ih+1,jh)
 loc_eos7 = helm_table_var(2,ih,jh+1)
 loc_eos8 = helm_table_var(2,ih+1,jh+1)
 loc_eos9 = helm_table_var(3,ih,jh)
 loc_eos10 = helm_table_var(3,ih+1,jh)
 loc_eos11 = helm_table_var(3,ih,jh+1)
 loc_eos12 = helm_table_var(3,ih+1,jh+1)
 loc_eos13 = helm_table_var(4,ih,jh)
 loc_eos14 = helm_table_var(4,ih+1,jh)
 loc_eos15 = helm_table_var(4,ih,jh+1)
 loc_eos16 = helm_table_var(4,ih+1,jh+1)
 loc_eos17 = helm_table_var(5,ih,jh)
 loc_eos18 = helm_table_var(5,ih+1,jh)
 loc_eos19 = helm_table_var(5,ih,jh+1)
 loc_eos20 = helm_table_var(5,ih+1,jh+1)
 loc_eos21 = helm_table_var(6,ih,jh)
 loc_eos22 = helm_table_var(6,ih+1,jh)
 loc_eos23 = helm_table_var(6,ih,jh+1)
 loc_eos24 = helm_table_var(6,ih+1,jh+1)
 loc_eos25 = helm_table_var(7,ih,jh)
 loc_eos26 = helm_table_var(7,ih+1,jh)
 loc_eos27 = helm_table_var(7,ih,jh+1)
 loc_eos28 = helm_table_var(7,ih+1,jh+1)
 loc_eos29 = helm_table_var(8,ih,jh)
 loc_eos30 = helm_table_var(8,ih+1,jh)
 loc_eos31 = helm_table_var(8,ih,jh+1)
 loc_eos32 = helm_table_var(8,ih+1,jh+1)
 loc_eos33 = helm_table_var(9,ih,jh)
 loc_eos34 = helm_table_var(9,ih+1,jh)
 loc_eos35 = helm_table_var(9,ih,jh+1)
 loc_eos36 = helm_table_var(9,ih+1,jh+1)

 x2 = x*x
 x3 = x2*x
 x4 = x3*x
 x5 = x4*x
 p0r = -rp6*x5 + rp15*x4 - rp10*x3 + rp1
 p1r = (-rp3*x5 + rp8*x4 - rp6*x3 + x)*drho
 p2r = (rph*(-x5 + rp3*x4 - rp3*x3 + x2))*drho2

 omx2 = omx*omx
 omx3 = omx2*omx
 omx4 = omx3*omx
 omx5 = omx4*omx
 p0mr = -rp6*omx5 + rp15*omx4 - rp10*omx3 + rp1
 p1mr =  (rp3*omx5 - rp8*omx4 + rp6*omx3 - omx)*drho
 p2mr =  (rph*(-omx5 + rp3*omx4 - rp3*omx3 + omx2))*drho2

 y2 = y*y
 y3 = y2*y
 y4 = y3*y
 y5 = y4*y
 p0t = -rp6*y5 + rp15*y4 - rp10*y3 + rp1
 p1t = (-rp3*y5 + rp8*y4 - rp6*y3 + y)*dT
 p2t = (rph*(-y5 + rp3*y4 - rp3*y3 + y2))*dT2

 omy2 = omy*omy
 omy3 = omy2*omy
 omy4 = omy3*omy
 omy5 = omy4*omy
 p0mt = -rp6*omy5 + rp15*omy4 - rp10*omy3 + rp1
 p1mt =  (rp3*omy5 - rp8*omy4 + rp6*omy3 - omy)*dT
 p2mt =  (rph*(-omy5 + rp3*omy4 - rp3*omy3 + omy2))*dT2

 dp0r =  (-rp30*x4 + rp60*x3 - rp30*x2)*idrho
 dp1r =  (-rp15*x4 + rp32*x3 - rp18*x2 + rp1)
 dp2r =  (rph*(-rp5*x4 + rp12*x3 - rp9*x2 + rp2*x))*drho

 dp0mr = -(-rp30*omx4 + rp60*omx3 - rp30*omx2)*idrho
 dp1mr =  (-rp15*omx4 + rp32*omx3 - rp18*omx2 + rp1)
 dp2mr = -(rph*(-rp5*omx4 + rp12*omx3 - rp9*omx2 + rp2*omx))*drho

 df_drho = &
 loc_eos1*dp0r*p0t + &
 loc_eos2*dp0mr*p0t + &
 loc_eos3*dp0r*p0mt + &
 loc_eos4*dp0mr*p0mt + &
 loc_eos5*dp0r*p1t + &
 loc_eos6*dp0mr*p1t + &
 loc_eos7*dp0r*p1mt + &
 loc_eos8*dp0mr*p1mt + &
 loc_eos9*dp0r*p2t + &
 loc_eos10*dp0mr*p2t + &
 loc_eos11*dp0r*p2mt + &
 loc_eos12*dp0mr*p2mt + &
 loc_eos13*dp1r*p0t + &
 loc_eos14*dp1mr*p0t + &
 loc_eos15*dp1r*p0mt + &
 loc_eos16*dp1mr*p0mt + &
 loc_eos17*dp2r*p0t + &
 loc_eos18*dp2mr*p0t + &
 loc_eos19*dp2r*p0mt + &
 loc_eos20*dp2mr*p0mt + &
 loc_eos21*dp1r*p1t + &
 loc_eos22*dp1mr*p1t + &
 loc_eos23*dp1r*p1mt + &
 loc_eos24*dp1mr*p1mt + &
 loc_eos25*dp2r*p1t + &
 loc_eos26*dp2mr*p1t + &
 loc_eos27*dp2r*p1mt + &
 loc_eos28*dp2mr*p1mt + &
 loc_eos29*dp1r*p2t + &
 loc_eos30*dp1mr*p2t + &
 loc_eos31*dp1r*p2mt + &
 loc_eos32*dp1mr*p2mt + &
 loc_eos33*dp2r*p2t + &
 loc_eos34*dp2mr*p2t + &
 loc_eos35*dp2r*p2mt + &
 loc_eos36*dp2mr*p2mt

 tmp = rhos*rhos
 P = tmp*df_drho

 p0r = rp2*x3-rp3*x2+rp1 
 p1r = (x3-rp2*x2+x)*drho
 
 p0mr = rp2*omx3-rp3*omx2+rp1 
 p1mr = -(omx3-rp2*omx2+omx)*drho

 p0t = rp2*y3-rp3*y2+rp1 
 p1t = (y3-rp2*y2+y)*dT 
 
 p0mt = rp2*omy3-rp3*omy2+rp1 
 p1mt = -(omy3-rp2*omy2+omy)*dT 

 loc_eos1 = eta_table(1,ih,jh)
 loc_eos2 = eta_table(1,ih+1,jh)
 loc_eos3 = eta_table(1,ih,jh+1)
 loc_eos4 = eta_table(1,ih+1,jh+1)
 loc_eos5 = eta_table(2,ih,jh)
 loc_eos6 = eta_table(2,ih+1,jh)
 loc_eos7 = eta_table(2,ih,jh+1)
 loc_eos8 = eta_table(2,ih+1,jh+1)
 loc_eos9 = eta_table(3,ih,jh)
 loc_eos10 = eta_table(3,ih+1,jh)
 loc_eos11 = eta_table(3,ih,jh+1)
 loc_eos12 = eta_table(3,ih+1,jh+1)
 loc_eos13 = eta_table(4,ih,jh)
 loc_eos14 = eta_table(4,ih+1,jh)
 loc_eos15 = eta_table(4,ih,jh+1)
 loc_eos16 = eta_table(4,ih+1,jh+1)

 eta = &
 loc_eos1*p0r*p0t + &
 loc_eos2*p0mr*p0t + &
 loc_eos3*p0r*p0mt + &
 loc_eos4*p0mr*p0mt + &
 loc_eos5*p0r*p1t + &
 loc_eos6*p0mr*p1t + &
 loc_eos7*p0r*p1mt + &
 loc_eos8*p0mr*p1mt + &
 loc_eos9*p1r*p0t + &
 loc_eos10*p1mr*p0t + &
 loc_eos11*p1r*p0mt + &
 loc_eos12*p1mr*p0mt + &
 loc_eos13*p1r*p1t + &
 loc_eos14*p1mr*p1t + &
 loc_eos15*p1r*p1mt + &
 loc_eos16*p1mr*p1mt 

 loc_eos1 = xf_table(1,ih,jh)
 loc_eos2 = xf_table(1,ih+1,jh)
 loc_eos3 = xf_table(1,ih,jh+1)
 loc_eos4 = xf_table(1,ih+1,jh+1)
 loc_eos5 = xf_table(2,ih,jh)
 loc_eos6 = xf_table(2,ih+1,jh)
 loc_eos7 = xf_table(2,ih,jh+1)
 loc_eos8 = xf_table(2,ih+1,jh+1)
 loc_eos9 = xf_table(3,ih,jh)
 loc_eos10 = xf_table(3,ih+1,jh)
 loc_eos11 = xf_table(3,ih,jh+1)
 loc_eos12 = xf_table(3,ih+1,jh+1)
 loc_eos13 = xf_table(4,ih,jh)
 loc_eos14 = xf_table(4,ih+1,jh)
 loc_eos15 = xf_table(4,ih,jh+1)
 loc_eos16 = xf_table(4,ih+1,jh+1)

 xf = &
 loc_eos1*p0r*p0t + &
 loc_eos2*p0mr*p0t + &
 loc_eos3*p0r*p0mt + &
 loc_eos4*p0mr*p0mt + &
 loc_eos5*p0r*p1t + &
 loc_eos6*p0mr*p1t + &
 loc_eos7*p0r*p1mt + &
 loc_eos8*p0mr*p1mt + &
 loc_eos9*p1r*p0t + &
 loc_eos10*p1mr*p0t + &
 loc_eos11*p1r*p0mt + &
 loc_eos12*p1mr*p0mt + &
 loc_eos13*p1r*p1t + &
 loc_eos14*p1mr*p1t + &
 loc_eos15*p1r*p1mt + &
 loc_eos16*p1mr*p1mt 

 end subroutine helm_rhoT_given_extra

#endif

 subroutine helm_rhoT_given_full(rho,T,abar,zbar,P,E,sound,cv)
 real(kind=rp), intent(in) :: rho,T,abar,zbar
 real(kind=rp), intent(inout) :: P,E,sound,cv

 real(kind=rp) :: &
 loc_eos1, &
 loc_eos2, &
 loc_eos3, &
 loc_eos4, &
 loc_eos5, &
 loc_eos6, &
 loc_eos7, &
 loc_eos8, &
 loc_eos9, &
 loc_eos10, &
 loc_eos11, &
 loc_eos12, &
 loc_eos13, &
 loc_eos14, &
 loc_eos15, &
 loc_eos16, &
 loc_eos17, &
 loc_eos18, &
 loc_eos19, &
 loc_eos20, &
 loc_eos21, &
 loc_eos22, &
 loc_eos23, &
 loc_eos24, &
 loc_eos25, &
 loc_eos26, &
 loc_eos27, &
 loc_eos28, &
 loc_eos29, &
 loc_eos30, &
 loc_eos31, &
 loc_eos32, &
 loc_eos33, &
 loc_eos34, &
 loc_eos35, &
 loc_eos36
        
 integer :: ih,jh

 real(kind=rp) :: df_drho,df_dT,df_drhodT,df_dT2
 real(kind=rp) :: f,s,ds_dT,ds_drho,T2,T3,T4,Ye,rhos
 real(kind=rp) :: zz,chiT,chirho,gam1,z,dP_drho,dP_dT,dE_drho,dE_dT

 real(kind=rp) :: x,y,drho,drho2,dT,dT2,tmp
 real(kind=rp) :: p0r,p0t,p0mr,p0mt,p1r,p1t,p1mr,p1mt,p2r,p2t,p2mr,p2mt,idrho,idrho2,idT,idT2
 real(kind=rp) :: dp0r,dp1r,dp2r,dp0mr,dp1mr,dp2mr
 real(kind=rp) :: dp0t,dp1t,dp2t,dp0mt,dp1mt,dp2mt
 real(kind=rp) :: ddp0t,ddp1t,ddp2t,ddp0mt,ddp1mt,ddp2mt
 real(kind=rp) :: omx,omy
 real(kind=rp) :: x2,x3,x4,x5,y2,y3,y4,y5,omx2,omx3,omx4,omx5,omy2,omy3,omy4,omy5

 real(kind=rp) :: &
 pion, dpiondt, dpiondd

#ifdef USE_COULOMB_CORRECTIONS

 real(kind=rp) :: &
 xni, &
 dxnidd, &
 dxnida, &
 ktinv, &
 dsdd, &
 dsda, &
 lami, &
 inv_lami, &
 lamidd, &
 lamida, &
 plasg, &
 plasgdd, &
 plasgdt, &
 ecoul, &
 pcoul, &
 dpcouldd, &
 dpcouldt, &
 decouldd, &
 decouldt

#endif
             
 Ye = zbar/abar
 rhos = rho*Ye

 ih = int((log10(rhos)-log10(helm_rho(1)))/helm_drho) + 1
 jh = int((log10(T)-log10(helm_T(1)))/helm_dT) + 1

 tmp = helm_rho(ih)
 drho = helm_rho(ih+1)-tmp
 x = (rhos-tmp)/drho
 omx = rp1-x

 tmp = helm_T(jh)
 dT = helm_T(jh+1)-tmp
 y = (T-tmp)/dT
 omy = rp1-y

 drho2 = drho*drho
 dT2 = dT*dT

 idrho = rp1/drho
 idrho2 = idrho*idrho

 idT = rp1/dT
 idT2 = idT*idT

 loc_eos1 = helm_table_var(1,ih,jh)
 loc_eos2 = helm_table_var(1,ih+1,jh)
 loc_eos3 = helm_table_var(1,ih,jh+1)
 loc_eos4 = helm_table_var(1,ih+1,jh+1)
 loc_eos5 = helm_table_var(2,ih,jh)
 loc_eos6 = helm_table_var(2,ih+1,jh)
 loc_eos7 = helm_table_var(2,ih,jh+1)
 loc_eos8 = helm_table_var(2,ih+1,jh+1)
 loc_eos9 = helm_table_var(3,ih,jh)
 loc_eos10 = helm_table_var(3,ih+1,jh)
 loc_eos11 = helm_table_var(3,ih,jh+1)
 loc_eos12 = helm_table_var(3,ih+1,jh+1)
 loc_eos13 = helm_table_var(4,ih,jh)
 loc_eos14 = helm_table_var(4,ih+1,jh)
 loc_eos15 = helm_table_var(4,ih,jh+1)
 loc_eos16 = helm_table_var(4,ih+1,jh+1)
 loc_eos17 = helm_table_var(5,ih,jh)
 loc_eos18 = helm_table_var(5,ih+1,jh)
 loc_eos19 = helm_table_var(5,ih,jh+1)
 loc_eos20 = helm_table_var(5,ih+1,jh+1)
 loc_eos21 = helm_table_var(6,ih,jh)
 loc_eos22 = helm_table_var(6,ih+1,jh)
 loc_eos23 = helm_table_var(6,ih,jh+1)
 loc_eos24 = helm_table_var(6,ih+1,jh+1)
 loc_eos25 = helm_table_var(7,ih,jh)
 loc_eos26 = helm_table_var(7,ih+1,jh)
 loc_eos27 = helm_table_var(7,ih,jh+1)
 loc_eos28 = helm_table_var(7,ih+1,jh+1)
 loc_eos29 = helm_table_var(8,ih,jh)
 loc_eos30 = helm_table_var(8,ih+1,jh)
 loc_eos31 = helm_table_var(8,ih,jh+1)
 loc_eos32 = helm_table_var(8,ih+1,jh+1)
 loc_eos33 = helm_table_var(9,ih,jh)
 loc_eos34 = helm_table_var(9,ih+1,jh)
 loc_eos35 = helm_table_var(9,ih,jh+1)
 loc_eos36 = helm_table_var(9,ih+1,jh+1)

 x2 = x*x
 x3 = x2*x
 x4 = x3*x
 x5 = x4*x
 p0r = -rp6*x5 + rp15*x4 - rp10*x3 + rp1
 p1r = (-rp3*x5 + rp8*x4 - rp6*x3 + x)*drho
 p2r = (rph*(-x5 + rp3*x4 - rp3*x3 + x2))*drho2

 omx2 = omx*omx
 omx3 = omx2*omx
 omx4 = omx3*omx
 omx5 = omx4*omx
 p0mr = -rp6*omx5 + rp15*omx4 - rp10*omx3 + rp1
 p1mr =  (rp3*omx5 - rp8*omx4 + rp6*omx3 - omx)*drho
 p2mr =  (rph*(-omx5 + rp3*omx4 - rp3*omx3 + omx2))*drho2

 y2 = y*y
 y3 = y2*y
 y4 = y3*y
 y5 = y4*y
 p0t = -rp6*y5 + rp15*y4 - rp10*y3 + rp1
 p1t = (-rp3*y5 + rp8*y4 - rp6*y3 + y)*dT
 p2t = (rph*(-y5 + rp3*y4 - rp3*y3 + y2))*dT2

 omy2 = omy*omy
 omy3 = omy2*omy
 omy4 = omy3*omy
 omy5 = omy4*omy
 p0mt = -rp6*omy5 + rp15*omy4 - rp10*omy3 + rp1
 p1mt =  (rp3*omy5 - rp8*omy4 + rp6*omy3 - omy)*dT
 p2mt =  (rph*(-omy5 + rp3*omy4 - rp3*omy3 + omy2))*dT2

 f = &
 loc_eos1*p0r*p0t + &
 loc_eos2*p0mr*p0t + &
 loc_eos3*p0r*p0mt + &
 loc_eos4*p0mr*p0mt + &
 loc_eos5*p0r*p1t + &
 loc_eos6*p0mr*p1t + &
 loc_eos7*p0r*p1mt + &
 loc_eos8*p0mr*p1mt + &
 loc_eos9*p0r*p2t + &
 loc_eos10*p0mr*p2t + &
 loc_eos11*p0r*p2mt + &
 loc_eos12*p0mr*p2mt + &
 loc_eos13*p1r*p0t + &
 loc_eos14*p1mr*p0t + &
 loc_eos15*p1r*p0mt + &
 loc_eos16*p1mr*p0mt + &
 loc_eos17*p2r*p0t + &
 loc_eos18*p2mr*p0t + &
 loc_eos19*p2r*p0mt + &
 loc_eos20*p2mr*p0mt + &
 loc_eos21*p1r*p1t + &
 loc_eos22*p1mr*p1t + &
 loc_eos23*p1r*p1mt + &
 loc_eos24*p1mr*p1mt + &
 loc_eos25*p2r*p1t + &
 loc_eos26*p2mr*p1t + &
 loc_eos27*p2r*p1mt + &
 loc_eos28*p2mr*p1mt + &
 loc_eos29*p1r*p2t + &
 loc_eos30*p1mr*p2t + &
 loc_eos31*p1r*p2mt + &
 loc_eos32*p1mr*p2mt + &
 loc_eos33*p2r*p2t + &
 loc_eos34*p2mr*p2t + &
 loc_eos35*p2r*p2mt + &
 loc_eos36*p2mr*p2mt

 dp0r =  (-rp30*x4 + rp60*x3 - rp30*x2)*idrho
 dp1r =  (-rp15*x4 + rp32*x3 - rp18*x2 + rp1)
 dp2r =  (rph*(-rp5*x4 + rp12*x3 - rp9*x2 + rp2*x))*drho

 dp0mr = -(-rp30*omx4 + rp60*omx3 - rp30*omx2)*idrho
 dp1mr =  (-rp15*omx4 + rp32*omx3 - rp18*omx2 + rp1)
 dp2mr = -(rph*(-rp5*omx4 + rp12*omx3 - rp9*omx2 + rp2*omx))*drho

 df_drho = &
 loc_eos1*dp0r*p0t + &
 loc_eos2*dp0mr*p0t + &
 loc_eos3*dp0r*p0mt + &
 loc_eos4*dp0mr*p0mt + &
 loc_eos5*dp0r*p1t + &
 loc_eos6*dp0mr*p1t + &
 loc_eos7*dp0r*p1mt + &
 loc_eos8*dp0mr*p1mt + &
 loc_eos9*dp0r*p2t + &
 loc_eos10*dp0mr*p2t + &
 loc_eos11*dp0r*p2mt + &
 loc_eos12*dp0mr*p2mt + &
 loc_eos13*dp1r*p0t + &
 loc_eos14*dp1mr*p0t + &
 loc_eos15*dp1r*p0mt + &
 loc_eos16*dp1mr*p0mt + &
 loc_eos17*dp2r*p0t + &
 loc_eos18*dp2mr*p0t + &
 loc_eos19*dp2r*p0mt + &
 loc_eos20*dp2mr*p0mt + &
 loc_eos21*dp1r*p1t + &
 loc_eos22*dp1mr*p1t + &
 loc_eos23*dp1r*p1mt + &
 loc_eos24*dp1mr*p1mt + &
 loc_eos25*dp2r*p1t + &
 loc_eos26*dp2mr*p1t + &
 loc_eos27*dp2r*p1mt + &
 loc_eos28*dp2mr*p1mt + &
 loc_eos29*dp1r*p2t + &
 loc_eos30*dp1mr*p2t + &
 loc_eos31*dp1r*p2mt + &
 loc_eos32*dp1mr*p2mt + &
 loc_eos33*dp2r*p2t + &
 loc_eos34*dp2mr*p2t + &
 loc_eos35*dp2r*p2mt + &
 loc_eos36*dp2mr*p2mt

 dp0t =  (-rp30*y4 + rp60*y3 - rp30*y2)*idT
 dp1t =  (-rp15*y4 + rp32*y3 - rp18*y2 + rp1)
 dp2t =  (rph*(-rp5*y4 + rp12*y3 - rp9*y2 + rp2*y))*dT

 dp0mt = -(-rp30*omy4 + rp60*omy3 - rp30*omy2)*idT
 dp1mt =  (-rp15*omy4 + rp32*omy3 - rp18*omy2 + rp1)
 dp2mt = -(rph*(-rp5*omy4 + rp12*omy3 - rp9*omy2 + rp2*omy))*dT

 df_dT = &
 loc_eos1*p0r*dp0t + &
 loc_eos2*p0mr*dp0t + &
 loc_eos3*p0r*dp0mt + &
 loc_eos4*p0mr*dp0mt + &
 loc_eos5*p0r*dp1t + &
 loc_eos6*p0mr*dp1t + &
 loc_eos7*p0r*dp1mt + &
 loc_eos8*p0mr*dp1mt + &
 loc_eos9*p0r*dp2t + &
 loc_eos10*p0mr*dp2t + &
 loc_eos11*p0r*dp2mt + &
 loc_eos12*p0mr*dp2mt + &
 loc_eos13*p1r*dp0t + &
 loc_eos14*p1mr*dp0t + &
 loc_eos15*p1r*dp0mt + &
 loc_eos16*p1mr*dp0mt + &
 loc_eos17*p2r*dp0t + &
 loc_eos18*p2mr*dp0t + &
 loc_eos19*p2r*dp0mt + &
 loc_eos20*p2mr*dp0mt + &
 loc_eos21*p1r*dp1t + &
 loc_eos22*p1mr*dp1t + &
 loc_eos23*p1r*dp1mt + &
 loc_eos24*p1mr*dp1mt + &
 loc_eos25*p2r*dp1t + &
 loc_eos26*p2mr*dp1t + &
 loc_eos27*p2r*dp1mt + &
 loc_eos28*p2mr*dp1mt + &
 loc_eos29*p1r*dp2t + &
 loc_eos30*p1mr*dp2t + &
 loc_eos31*p1r*dp2mt + &
 loc_eos32*p1mr*dp2mt + &
 loc_eos33*p2r*dp2t + &
 loc_eos34*p2mr*dp2t + &
 loc_eos35*p2r*dp2mt + &
 loc_eos36*p2mr*dp2mt

 df_drhodT = &
 loc_eos1*dp0r*dp0t + &
 loc_eos2*dp0mr*dp0t + &
 loc_eos3*dp0r*dp0mt + &
 loc_eos4*dp0mr*dp0mt + &
 loc_eos5*dp0r*dp1t + &
 loc_eos6*dp0mr*dp1t + &
 loc_eos7*dp0r*dp1mt + &
 loc_eos8*dp0mr*dp1mt + &
 loc_eos9*dp0r*dp2t + &
 loc_eos10*dp0mr*dp2t + &
 loc_eos11*dp0r*dp2mt + &
 loc_eos12*dp0mr*dp2mt + &
 loc_eos13*dp1r*dp0t + &
 loc_eos14*dp1mr*dp0t + &
 loc_eos15*dp1r*dp0mt + &
 loc_eos16*dp1mr*dp0mt + &
 loc_eos17*dp2r*dp0t + &
 loc_eos18*dp2mr*dp0t + &
 loc_eos19*dp2r*dp0mt + &
 loc_eos20*dp2mr*dp0mt + &
 loc_eos21*dp1r*dp1t + &
 loc_eos22*dp1mr*dp1t + &
 loc_eos23*dp1r*dp1mt + &
 loc_eos24*dp1mr*dp1mt + &
 loc_eos25*dp2r*dp1t + &
 loc_eos26*dp2mr*dp1t + &
 loc_eos27*dp2r*dp1mt + &
 loc_eos28*dp2mr*dp1mt + &
 loc_eos29*dp1r*dp2t + &
 loc_eos30*dp1mr*dp2t + &
 loc_eos31*dp1r*dp2mt + &
 loc_eos32*dp1mr*dp2mt + &
 loc_eos33*dp2r*dp2t + &
 loc_eos34*dp2mr*dp2t + &
 loc_eos35*dp2r*dp2mt + &
 loc_eos36*dp2mr*dp2mt

 ddp0t =  (-rp120*y3 + rp180*y2 - rp60*y)*idT2
 ddp1t =  (-rp60*y3 + rp96*y2 - rp36*y)*idT
 ddp2t =  (rph*(-rp20*y3 + rp36*y2 - rp18*y + rp2))

 ddp0mt =  (-rp120*omy3 + rp180*omy2 - rp60*omy)*idT2
 ddp1mt = -(-rp60*omy3 + rp96*omy2 - rp36*omy)*idT
 ddp2mt =  (rph*(-rp20*omy3 + rp36*omy2 - rp18*omy + rp2))

 df_dT2 = &
 loc_eos1*p0r*ddp0t + &
 loc_eos2*p0mr*ddp0t + &
 loc_eos3*p0r*ddp0mt + &
 loc_eos4*p0mr*ddp0mt + &
 loc_eos5*p0r*ddp1t + &
 loc_eos6*p0mr*ddp1t + &
 loc_eos7*p0r*ddp1mt + &
 loc_eos8*p0mr*ddp1mt + &
 loc_eos9*p0r*ddp2t + &
 loc_eos10*p0mr*ddp2t + &
 loc_eos11*p0r*ddp2mt + &
 loc_eos12*p0mr*ddp2mt + &
 loc_eos13*p1r*ddp0t + &
 loc_eos14*p1mr*ddp0t + &
 loc_eos15*p1r*ddp0mt + &
 loc_eos16*p1mr*ddp0mt + &
 loc_eos17*p2r*ddp0t + &
 loc_eos18*p2mr*ddp0t + &
 loc_eos19*p2r*ddp0mt + &
 loc_eos20*p2mr*ddp0mt + &
 loc_eos21*p1r*ddp1t + &
 loc_eos22*p1mr*ddp1t + &
 loc_eos23*p1r*ddp1mt + &
 loc_eos24*p1mr*ddp1mt + &
 loc_eos25*p2r*ddp1t + &
 loc_eos26*p2mr*ddp1t + &
 loc_eos27*p2r*ddp1mt + &
 loc_eos28*p2mr*ddp1mt + &
 loc_eos29*p1r*ddp2t + &
 loc_eos30*p1mr*ddp2t + &
 loc_eos31*p1r*ddp2mt + &
 loc_eos32*p1mr*ddp2mt + &
 loc_eos33*p2r*ddp2t + &
 loc_eos34*p2mr*ddp2t + &
 loc_eos35*p2r*ddp2mt + &
 loc_eos36*p2mr*ddp2mt

 p0r = rp2*x3-rp3*x2+rp1
 p1r = (x3-rp2*x2+x)*drho

 p0mr = rp2*omx3-rp3*omx2+rp1
 p1mr = -(omx3-rp2*omx2+omx)*drho

 p0t = rp2*y3-rp3*y2+rp1
 p1t = (y3-rp2*y2+y)*dT

 p0mt = rp2*omy3-rp3*omy2+rp1
 p1mt = -(omy3-rp2*omy2+omy)*dT

 loc_eos1 = dpdrho_table_var(1,ih,jh)
 loc_eos2 = dpdrho_table_var(1,ih+1,jh)
 loc_eos3 = dpdrho_table_var(1,ih,jh+1)
 loc_eos4 = dpdrho_table_var(1,ih+1,jh+1)
 loc_eos5 = dpdrho_table_var(2,ih,jh)
 loc_eos6 = dpdrho_table_var(2,ih+1,jh)
 loc_eos7 = dpdrho_table_var(2,ih,jh+1)
 loc_eos8 = dpdrho_table_var(2,ih+1,jh+1)
 loc_eos9 = dpdrho_table_var(3,ih,jh)
 loc_eos10 = dpdrho_table_var(3,ih+1,jh)
 loc_eos11 = dpdrho_table_var(3,ih,jh+1)
 loc_eos12 = dpdrho_table_var(3,ih+1,jh+1)
 loc_eos13 = dpdrho_table_var(4,ih,jh)
 loc_eos14 = dpdrho_table_var(4,ih+1,jh)
 loc_eos15 = dpdrho_table_var(4,ih,jh+1)
 loc_eos16 = dpdrho_table_var(4,ih+1,jh+1)

 dP_drho = &
 loc_eos1*p0r*p0t + &
 loc_eos2*p0mr*p0t + &
 loc_eos3*p0r*p0mt + &
 loc_eos4*p0mr*p0mt + &
 loc_eos5*p0r*p1t + &
 loc_eos6*p0mr*p1t + &
 loc_eos7*p0r*p1mt + &
 loc_eos8*p0mr*p1mt + &
 loc_eos9*p1r*p0t + &
 loc_eos10*p1mr*p0t + &
 loc_eos11*p1r*p0mt + &
 loc_eos12*p1mr*p0mt + &
 loc_eos13*p1r*p1t + &
 loc_eos14*p1mr*p1t + &
 loc_eos15*p1r*p1mt + &
 loc_eos16*p1mr*p1mt

 dP_drho = Ye*dP_drho  

 tmp = rhos*rhos
 P = tmp*df_drho
 dP_dT = tmp*df_drhodT
 s = -Ye*df_dT
 ds_dT = -Ye*df_dT2
 tmp = Ye*Ye
 ds_drho = -df_drhodT*tmp
 E = Ye*f + T*s
 dE_dT = T*ds_dT
 dE_drho = df_drho*tmp + T*ds_drho

 tmp = rp1/abar
 T2 = T*T
 T3 = T2*T
 T4 = T3*T

 pion = CONST_RGAS*rho*T*tmp
 dpiondt = CONST_RGAS*rho*tmp
 dpiondd = CONST_RGAS*T*tmp

 P = P + pion + CONST_RAD*T4*othird
 dP_dT = dP_dT + dpiondt + fthirds*CONST_RAD*T3
 dP_drho = dP_drho + dpiondd

 E = E + rpoh*CONST_RGAS*T*tmp + CONST_RAD*T4/rho
 dE_dT = dE_dT + rpoh*CONST_RGAS*tmp + rp4*CONST_RAD*T3/rho
 dE_drho = dE_drho - CONST_RAD*T4/(rho*rho)

#ifdef USE_COULOMB_CORRECTIONS

 xni = CONST_AV*tmp*rho

 dxnidd = CONST_AV*tmp
 dxnida = -xni*tmp

 ktinv = rp1/(CONST_KB*T)

 z = fthirds*CONST_PI
 s = z*xni
 dsdd = z*dxnidd
 dsda = z*dxnida

 lami = rp1/s**othird
 inv_lami = rp1/lami
 z = -othird*lami
 lamidd = z*dsdd/s
 lamida = z*dsda/s

 plasg = zbar*zbar*CONST_QE*CONST_QE*ktinv*inv_lami
 z = -plasg*inv_lami
 plasgdd = z*lamidd
 plasgdt = -plasg*ktinv*CONST_KB

 if (plasg>=rp1) then

   x        = plasg**oquart
   y        = CONST_AV*tmp*CONST_KB
   ecoul    = y*T*(cc_a1*plasg+cc_b1*x+cc_c1/x+cc_d1)
   pcoul    = othird*rho*ecoul

   y        = CONST_AV*tmp*CONST_KB*T*(cc_a1+oquart/plasg*(cc_b1*x-cc_c1/x))
   decouldd = y*plasgdd
   decouldt = y*plasgdt+ecoul/T

   y        = othird*rho
   dpcouldd = othird*ecoul+y*decouldd
   dpcouldt = y*decouldt
 
 else 

   x        = plasg*sqrt(plasg)
   y        = plasg**cc_b2
   z        = cc_c2*x-othird*cc_a2*y
   pcoul    = -pion*z
   ecoul    = rp3*pcoul/rho

   s        = rpoh*cc_c2*x/plasg-othird*cc_a2*cc_b2*y/plasg
   dpcouldd = -dpiondd*z-pion*s*plasgdd
   dpcouldt = -dpiondt*z-pion*s*plasgdt

   s        = rp3/rho
   decouldd = s*dpcouldd-ecoul/rho
   decouldt = s*dpcouldt

 end if

 dE_drho = dE_drho + decouldd
 dE_dT = dE_dT + decouldt
 dP_drho = dP_drho + dpcouldd
 dP_dT = dP_dT + dpcouldt

 P = P + pcoul
 E = E + ecoul

#endif

 zz = P/rho
 cv = dE_dT
 chiT = T/P*dP_dT
 chirho = dP_drho/zz
 x = zz*chiT/(T*cv)
 gam1 = chiT*x+chirho
 z = rp1 + (E+CONST_C2)/zz
 sound = CONST_C*sqrt(gam1/z)

 end subroutine helm_rhoT_given_full

 subroutine helm_rhoT_given1(rho,T,abar,zbar,P,dP_dT,return_dP_dT)
 real(kind=rp), intent(in) :: rho,T,abar,zbar
 real(kind=rp), intent(inout) :: P,dP_dT
 logical, intent(in) :: return_dP_dT

 real(kind=rp) :: &
 loc_eos1, &
 loc_eos2, &
 loc_eos3, &
 loc_eos4, &
 loc_eos5, &
 loc_eos6, &
 loc_eos7, &
 loc_eos8, &
 loc_eos9, &
 loc_eos10, &
 loc_eos11, &
 loc_eos12, &
 loc_eos13, &
 loc_eos14, &
 loc_eos15, &
 loc_eos16, &
 loc_eos17, &
 loc_eos18, &
 loc_eos19, &
 loc_eos20, &
 loc_eos21, &
 loc_eos22, &
 loc_eos23, &
 loc_eos24, &
 loc_eos25, &
 loc_eos26, &
 loc_eos27, &
 loc_eos28, &
 loc_eos29, &
 loc_eos30, &
 loc_eos31, &
 loc_eos32, &
 loc_eos33, &
 loc_eos34, &
 loc_eos35, &
 loc_eos36
 
 integer :: ih,jh

 real(kind=rp) :: df_drho,df_drhodT
 real(kind=rp) :: T2,T3,T4,Ye,rhos

 real(kind=rp) :: x,y,drho,drho2,dT,dT2,tmp
 real(kind=rp) :: p0r,p0t,p0mr,p0mt,p1r,p1t,p1mr,p1mt,p2r,p2t,p2mr,p2mt,idrho,idrho2,idT,idT2
 real(kind=rp) :: dp0r,dp1r,dp2r,dp0mr,dp1mr,dp2mr
 real(kind=rp) :: dp0t,dp1t,dp2t,dp0mt,dp1mt,dp2mt
 real(kind=rp) :: omx,omy
 real(kind=rp) :: x2,x3,x4,x5,y2,y3,y4,y5,omx2,omx3,omx4,omx5,omy2,omy3,omy4,omy5
 
 real(kind=rp) :: &
 pion, dpiondt

#ifdef USE_COULOMB_CORRECTIONS

 real(kind=rp) :: &
 xni, &
 dxnidd, &
 dxnida, &
 ktinv, &
 lami, &
 inv_lami, &
 plasg, &
 plasgdt, &
 ecoul, &
 pcoul, &
 dpcouldt, &
 decouldt, &
 s, &
 z

#endif

 Ye = zbar/abar

 rhos = rho*Ye

 ih = int((log10(rhos)-log10(helm_rho(1)))/helm_drho) + 1
 jh = int((log10(T)-log10(helm_T(1)))/helm_dT) + 1

 tmp = helm_rho(ih)
 drho = helm_rho(ih+1)-tmp
 x = (rhos-tmp)/drho
 omx = rp1-x

 tmp = helm_T(jh)
 dT = helm_T(jh+1)-tmp
 y = (T-tmp)/dT
 omy = rp1-y

 drho2 = drho*drho
 dT2 = dT*dT

 idrho = rp1/drho
 idrho2 = idrho*idrho

 idT = rp1/dT
 idT2 = idT*idT

 loc_eos1 = helm_table_var(1,ih,jh)
 loc_eos2 = helm_table_var(1,ih+1,jh)
 loc_eos3 = helm_table_var(1,ih,jh+1)
 loc_eos4 = helm_table_var(1,ih+1,jh+1)
 loc_eos5 = helm_table_var(2,ih,jh)
 loc_eos6 = helm_table_var(2,ih+1,jh)
 loc_eos7 = helm_table_var(2,ih,jh+1)
 loc_eos8 = helm_table_var(2,ih+1,jh+1)
 loc_eos9 = helm_table_var(3,ih,jh)
 loc_eos10 = helm_table_var(3,ih+1,jh)
 loc_eos11 = helm_table_var(3,ih,jh+1)
 loc_eos12 = helm_table_var(3,ih+1,jh+1)
 loc_eos13 = helm_table_var(4,ih,jh)
 loc_eos14 = helm_table_var(4,ih+1,jh)
 loc_eos15 = helm_table_var(4,ih,jh+1)
 loc_eos16 = helm_table_var(4,ih+1,jh+1)
 loc_eos17 = helm_table_var(5,ih,jh)
 loc_eos18 = helm_table_var(5,ih+1,jh)
 loc_eos19 = helm_table_var(5,ih,jh+1)
 loc_eos20 = helm_table_var(5,ih+1,jh+1)
 loc_eos21 = helm_table_var(6,ih,jh)
 loc_eos22 = helm_table_var(6,ih+1,jh)
 loc_eos23 = helm_table_var(6,ih,jh+1)
 loc_eos24 = helm_table_var(6,ih+1,jh+1)
 loc_eos25 = helm_table_var(7,ih,jh)
 loc_eos26 = helm_table_var(7,ih+1,jh)
 loc_eos27 = helm_table_var(7,ih,jh+1)
 loc_eos28 = helm_table_var(7,ih+1,jh+1)
 loc_eos29 = helm_table_var(8,ih,jh)
 loc_eos30 = helm_table_var(8,ih+1,jh)
 loc_eos31 = helm_table_var(8,ih,jh+1)
 loc_eos32 = helm_table_var(8,ih+1,jh+1)
 loc_eos33 = helm_table_var(9,ih,jh)
 loc_eos34 = helm_table_var(9,ih+1,jh)
 loc_eos35 = helm_table_var(9,ih,jh+1)
 loc_eos36 = helm_table_var(9,ih+1,jh+1)

 x2 = x*x
 x3 = x2*x
 x4 = x3*x
 x5 = x4*x
 p0r = -rp6*x5 + rp15*x4 - rp10*x3 + rp1
 p1r = (-rp3*x5 + rp8*x4 - rp6*x3 + x)*drho
 p2r = (rph*(-x5 + rp3*x4 - rp3*x3 + x2))*drho2

 omx2 = omx*omx
 omx3 = omx2*omx
 omx4 = omx3*omx
 omx5 = omx4*omx
 p0mr = -rp6*omx5 + rp15*omx4 - rp10*omx3 + rp1
 p1mr =  (rp3*omx5 - rp8*omx4 + rp6*omx3 - omx)*drho
 p2mr =  (rph*(-omx5 + rp3*omx4 - rp3*omx3 + omx2))*drho2

 y2 = y*y
 y3 = y2*y
 y4 = y3*y
 y5 = y4*y
 p0t = -rp6*y5 + rp15*y4 - rp10*y3 + rp1
 p1t = (-rp3*y5 + rp8*y4 - rp6*y3 + y)*dT
 p2t = (rph*(-y5 + rp3*y4 - rp3*y3 + y2))*dT2

 omy2 = omy*omy
 omy3 = omy2*omy
 omy4 = omy3*omy
 omy5 = omy4*omy
 p0mt = -rp6*omy5 + rp15*omy4 - rp10*omy3 + rp1
 p1mt =  (rp3*omy5 - rp8*omy4 + rp6*omy3 - omy)*dT
 p2mt =  (rph*(-omy5 + rp3*omy4 - rp3*omy3 + omy2))*dT2

 dp0r =  (-rp30*x4 + rp60*x3 - rp30*x2)*idrho
 dp1r =  (-rp15*x4 + rp32*x3 - rp18*x2 + rp1)
 dp2r =  (rph*(-rp5*x4 + rp12*x3 - rp9*x2 + rp2*x))*drho

 dp0mr = -(-rp30*omx4 + rp60*omx3 - rp30*omx2)*idrho
 dp1mr =  (-rp15*omx4 + rp32*omx3 - rp18*omx2 + rp1)
 dp2mr = -(rph*(-rp5*omx4 + rp12*omx3 - rp9*omx2 + rp2*omx))*drho

 df_drho = &
 loc_eos1*dp0r*p0t + &
 loc_eos2*dp0mr*p0t + &
 loc_eos3*dp0r*p0mt + &
 loc_eos4*dp0mr*p0mt + &
 loc_eos5*dp0r*p1t + &
 loc_eos6*dp0mr*p1t + &
 loc_eos7*dp0r*p1mt + &
 loc_eos8*dp0mr*p1mt + &
 loc_eos9*dp0r*p2t + &
 loc_eos10*dp0mr*p2t + &
 loc_eos11*dp0r*p2mt + &
 loc_eos12*dp0mr*p2mt + &
 loc_eos13*dp1r*p0t + &
 loc_eos14*dp1mr*p0t + &
 loc_eos15*dp1r*p0mt + &
 loc_eos16*dp1mr*p0mt + &
 loc_eos17*dp2r*p0t + &
 loc_eos18*dp2mr*p0t + &
 loc_eos19*dp2r*p0mt + &
 loc_eos20*dp2mr*p0mt + &
 loc_eos21*dp1r*p1t + &
 loc_eos22*dp1mr*p1t + &
 loc_eos23*dp1r*p1mt + &
 loc_eos24*dp1mr*p1mt + &
 loc_eos25*dp2r*p1t + &
 loc_eos26*dp2mr*p1t + &
 loc_eos27*dp2r*p1mt + &
 loc_eos28*dp2mr*p1mt + &
 loc_eos29*dp1r*p2t + &
 loc_eos30*dp1mr*p2t + &
 loc_eos31*dp1r*p2mt + &
 loc_eos32*dp1mr*p2mt + &
 loc_eos33*dp2r*p2t + &
 loc_eos34*dp2mr*p2t + &
 loc_eos35*dp2r*p2mt + &
 loc_eos36*dp2mr*p2mt

 dp0t =  (-rp30*y4 + rp60*y3 - rp30*y2)*idT
 dp1t =  (-rp15*y4 + rp32*y3 - rp18*y2 + rp1)
 dp2t =  (rph*(-rp5*y4 + rp12*y3 - rp9*y2 + rp2*y))*dT

 dp0mt = -(-rp30*omy4 + rp60*omy3 - rp30*omy2)*idT
 dp1mt =  (-rp15*omy4 + rp32*omy3 - rp18*omy2 + rp1)
 dp2mt = -(rph*(-rp5*omy4 + rp12*omy3 - rp9*omy2 + rp2*omy))*dT

 df_drhodT = rp0

 if(return_dP_dT) then

 df_drhodT = &
 loc_eos1*dp0r*dp0t + &
 loc_eos2*dp0mr*dp0t + &
 loc_eos3*dp0r*dp0mt + &
 loc_eos4*dp0mr*dp0mt + &
 loc_eos5*dp0r*dp1t + &
 loc_eos6*dp0mr*dp1t + &
 loc_eos7*dp0r*dp1mt + &
 loc_eos8*dp0mr*dp1mt + &
 loc_eos9*dp0r*dp2t + &
 loc_eos10*dp0mr*dp2t + &
 loc_eos11*dp0r*dp2mt + &
 loc_eos12*dp0mr*dp2mt + &
 loc_eos13*dp1r*dp0t + &
 loc_eos14*dp1mr*dp0t + &
 loc_eos15*dp1r*dp0mt + &
 loc_eos16*dp1mr*dp0mt + &
 loc_eos17*dp2r*dp0t + &
 loc_eos18*dp2mr*dp0t + &
 loc_eos19*dp2r*dp0mt + &
 loc_eos20*dp2mr*dp0mt + &
 loc_eos21*dp1r*dp1t + &
 loc_eos22*dp1mr*dp1t + &
 loc_eos23*dp1r*dp1mt + &
 loc_eos24*dp1mr*dp1mt + &
 loc_eos25*dp2r*dp1t + &
 loc_eos26*dp2mr*dp1t + &
 loc_eos27*dp2r*dp1mt + &
 loc_eos28*dp2mr*dp1mt + &
 loc_eos29*dp1r*dp2t + &
 loc_eos30*dp1mr*dp2t + &
 loc_eos31*dp1r*dp2mt + &
 loc_eos32*dp1mr*dp2mt + &
 loc_eos33*dp2r*dp2t + &
 loc_eos34*dp2mr*dp2t + &
 loc_eos35*dp2r*dp2mt + &
 loc_eos36*dp2mr*dp2mt

 endif

 tmp = rhos*rhos
 P = tmp*df_drho
 dP_dT = tmp*df_drhodT

 T2 = T*T
 T3 = T2*T
 T4 = T3*T
 
 tmp = rp1/abar

 pion = CONST_RGAS*rho*T*tmp
 dpiondt = CONST_RGAS*rho*tmp

 P = P + pion + CONST_RAD*T4*othird
 dP_dT = dP_dT + dpiondt + fthirds*CONST_RAD*T3

#ifdef USE_COULOMB_CORRECTIONS

 xni = CONST_AV*tmp*rho

 dxnidd = CONST_AV*tmp
 dxnida = -xni*tmp

 ktinv = rp1/(CONST_KB*T)

 z = fthirds*CONST_PI
 s = z*xni

 lami = rp1/s**othird
 inv_lami = rp1/lami

 plasg = zbar*zbar*CONST_QE*CONST_QE*ktinv*inv_lami
 plasgdt = -plasg*ktinv*CONST_KB

 if (plasg>=rp1) then

   x        = plasg**oquart
   y        = CONST_AV*tmp*CONST_KB
   ecoul    = y*T*(cc_a1*plasg+cc_b1*x+cc_c1/x+cc_d1)
   pcoul    = othird*rho*ecoul

   y        = CONST_AV*tmp*CONST_KB*T*(cc_a1+oquart/plasg*(cc_b1*x-cc_c1/x))
   decouldt = y*plasgdt+ecoul/T

   y        = othird*rho
   dpcouldt = y*decouldt
 
 else 

   x        = plasg*sqrt(plasg)
   y        = plasg**cc_b2
   z        = cc_c2*x-othird*cc_a2*y
   pcoul    = -pion*z

   s        = rpoh*cc_c2*x/plasg-othird*cc_a2*cc_b2*y/plasg
   dpcouldt = -dpiondt*z-pion*s*plasgdt

 end if

 dP_dT = dP_dT + dpcouldt
 P = P + pcoul

#endif

 end subroutine helm_rhoT_given1

 subroutine helm_rhoT_given2(rho,T,abar,zbar,E,dE_dT,return_dE_dT)
 real(kind=rp), intent(in) :: rho,T,abar,zbar
 real(kind=rp), intent(inout) :: E,dE_dT
 logical, intent(in) :: return_dE_dT

 real(kind=rp) :: &
 loc_eos1, &
 loc_eos2, &
 loc_eos3, &
 loc_eos4, &
 loc_eos5, &
 loc_eos6, &
 loc_eos7, &
 loc_eos8, &
 loc_eos9, &
 loc_eos10, &
 loc_eos11, &
 loc_eos12, &
 loc_eos13, &
 loc_eos14, &
 loc_eos15, &
 loc_eos16, &
 loc_eos17, &
 loc_eos18, &
 loc_eos19, &
 loc_eos20, &
 loc_eos21, &
 loc_eos22, &
 loc_eos23, &
 loc_eos24, &
 loc_eos25, &
 loc_eos26, &
 loc_eos27, &
 loc_eos28, &
 loc_eos29, &
 loc_eos30, &
 loc_eos31, &
 loc_eos32, &
 loc_eos33, &
 loc_eos34, &
 loc_eos35, &
 loc_eos36

 integer :: ih,jh

 real(kind=rp) :: df_dT,df_dT2
 real(kind=rp) :: f,s,ds_dT
 real(kind=rp) :: Ye,T2,T3,T4,rhos

 real(kind=rp) :: x,y,drho,drho2,dT,dT2,tmp
 real(kind=rp) :: p0r,p0t,p0mr,p0mt,p1r,p1t,p1mr,p1mt,p2r,p2t,p2mr,p2mt,idrho,idrho2,idT,idT2
 real(kind=rp) :: dp0t,dp1t,dp2t,dp0mt,dp1mt,dp2mt
 real(kind=rp) :: ddp0t,ddp1t,ddp2t,ddp0mt,ddp1mt,ddp2mt
 real(kind=rp) :: omx,omy
 real(kind=rp) :: x2,x3,x4,x5,y2,y3,y4,y5,omx2,omx3,omx4,omx5,omy2,omy3,omy4,omy5

#ifdef USE_COULOMB_CORRECTIONS

 real(kind=rp) :: &
 xni, &
 ktinv, &
 lami, &
 inv_lami, &
 plasg, &
 plasgdt, &
 ecoul, &
 pcoul, &
 dpcouldt, &
 decouldt, &
 z, &
 pion, &
 dpiondt

#endif

 Ye = zbar/abar
 rhos = rho*Ye

 ih = int((log10(rhos)-log10(helm_rho(1)))/helm_drho) + 1
 jh = int((log10(T)-log10(helm_T(1)))/helm_dT) + 1

 tmp = helm_rho(ih)
 drho = helm_rho(ih+1)-tmp
 x = (rhos-tmp)/drho
 omx = rp1-x

 tmp = helm_T(jh)
 dT = helm_T(jh+1)-tmp
 y = (T-tmp)/dT
 omy = rp1-y

 drho2 = drho*drho
 dT2 = dT*dT

 idrho = rp1/drho
 idrho2 = idrho*idrho

 idT = rp1/dT
 idT2 = idT*idT

 loc_eos1 = helm_table_var(1,ih,jh)
 loc_eos2 = helm_table_var(1,ih+1,jh)
 loc_eos3 = helm_table_var(1,ih,jh+1)
 loc_eos4 = helm_table_var(1,ih+1,jh+1)
 loc_eos5 = helm_table_var(2,ih,jh)
 loc_eos6 = helm_table_var(2,ih+1,jh)
 loc_eos7 = helm_table_var(2,ih,jh+1)
 loc_eos8 = helm_table_var(2,ih+1,jh+1)
 loc_eos9 = helm_table_var(3,ih,jh)
 loc_eos10 = helm_table_var(3,ih+1,jh)
 loc_eos11 = helm_table_var(3,ih,jh+1)
 loc_eos12 = helm_table_var(3,ih+1,jh+1)
 loc_eos13 = helm_table_var(4,ih,jh)
 loc_eos14 = helm_table_var(4,ih+1,jh)
 loc_eos15 = helm_table_var(4,ih,jh+1)
 loc_eos16 = helm_table_var(4,ih+1,jh+1)
 loc_eos17 = helm_table_var(5,ih,jh)
 loc_eos18 = helm_table_var(5,ih+1,jh)
 loc_eos19 = helm_table_var(5,ih,jh+1)
 loc_eos20 = helm_table_var(5,ih+1,jh+1)
 loc_eos21 = helm_table_var(6,ih,jh)
 loc_eos22 = helm_table_var(6,ih+1,jh)
 loc_eos23 = helm_table_var(6,ih,jh+1)
 loc_eos24 = helm_table_var(6,ih+1,jh+1)
 loc_eos25 = helm_table_var(7,ih,jh)
 loc_eos26 = helm_table_var(7,ih+1,jh)
 loc_eos27 = helm_table_var(7,ih,jh+1)
 loc_eos28 = helm_table_var(7,ih+1,jh+1)
 loc_eos29 = helm_table_var(8,ih,jh)
 loc_eos30 = helm_table_var(8,ih+1,jh)
 loc_eos31 = helm_table_var(8,ih,jh+1)
 loc_eos32 = helm_table_var(8,ih+1,jh+1)
 loc_eos33 = helm_table_var(9,ih,jh)
 loc_eos34 = helm_table_var(9,ih+1,jh)
 loc_eos35 = helm_table_var(9,ih,jh+1)
 loc_eos36 = helm_table_var(9,ih+1,jh+1)

 x2 = x*x
 x3 = x2*x
 x4 = x3*x
 x5 = x4*x
 p0r = -rp6*x5 + rp15*x4 - rp10*x3 + rp1
 p1r = (-rp3*x5 + rp8*x4 - rp6*x3 + x)*drho
 p2r = ( rph*(-x5 + rp3*x4 - rp3*x3 + x2))*drho2

 omx2 = omx*omx
 omx3 = omx2*omx
 omx4 = omx3*omx
 omx5 = omx4*omx
 p0mr = -rp6*omx5 + rp15*omx4 - rp10*omx3 + rp1
 p1mr =  (rp3*omx5 - rp8*omx4 + rp6*omx3 - omx)*drho
 p2mr =  (rph*(-omx5 + rp3*omx4 - rp3*omx3 + omx2))*drho2

 y2 = y*y
 y3 = y2*y
 y4 = y3*y
 y5 = y4*y
 p0t = -rp6*y5 + rp15*y4 - rp10*y3 + rp1
 p1t = (-rp3*y5 + rp8*y4 - rp6*y3 + y)*dT
 p2t = ( rph*(-y5 + rp3*y4 - rp3*y3 + y2))*dT2

 omy2 = omy*omy
 omy3 = omy2*omy
 omy4 = omy3*omy
 omy5 = omy4*omy
 p0mt = -rp6*omy5 + rp15*omy4 - rp10*omy3 + rp1
 p1mt =  (rp3*omy5 - rp8*omy4 + rp6*omy3 - omy)*dT
 p2mt =  (rph*(-omy5 + rp3*omy4 - rp3*omy3 + omy2))*dT2

 f = &
 loc_eos1*p0r*p0t + &
 loc_eos2*p0mr*p0t + &
 loc_eos3*p0r*p0mt + &
 loc_eos4*p0mr*p0mt + &
 loc_eos5*p0r*p1t + &
 loc_eos6*p0mr*p1t + &
 loc_eos7*p0r*p1mt + &
 loc_eos8*p0mr*p1mt + &
 loc_eos9*p0r*p2t + &
 loc_eos10*p0mr*p2t + &
 loc_eos11*p0r*p2mt + &
 loc_eos12*p0mr*p2mt + &
 loc_eos13*p1r*p0t + &
 loc_eos14*p1mr*p0t + &
 loc_eos15*p1r*p0mt + &
 loc_eos16*p1mr*p0mt + &
 loc_eos17*p2r*p0t + &
 loc_eos18*p2mr*p0t + &
 loc_eos19*p2r*p0mt + &
 loc_eos20*p2mr*p0mt + &
 loc_eos21*p1r*p1t + &
 loc_eos22*p1mr*p1t + &
 loc_eos23*p1r*p1mt + &
 loc_eos24*p1mr*p1mt + &
 loc_eos25*p2r*p1t + &
 loc_eos26*p2mr*p1t + &
 loc_eos27*p2r*p1mt + &
 loc_eos28*p2mr*p1mt + &
 loc_eos29*p1r*p2t + &
 loc_eos30*p1mr*p2t + &
 loc_eos31*p1r*p2mt + &
 loc_eos32*p1mr*p2mt + &
 loc_eos33*p2r*p2t + &
 loc_eos34*p2mr*p2t + &
 loc_eos35*p2r*p2mt + &
 loc_eos36*p2mr*p2mt

 dp0t =  (-rp30*y4 + rp60*y3 - rp30*y2)*idT
 dp1t =  (-rp15*y4 + rp32*y3 - rp18*y2 + rp1)
 dp2t =  (rph*(-rp5*y4 + rp12*y3 - rp9*y2 + rp2*y))*dT

 dp0mt = -(-rp30*omy4 + rp60*omy3 - rp30*omy2)*idT
 dp1mt =  (-rp15*omy4 + rp32*omy3 - rp18*omy2 + rp1)
 dp2mt = -(rph*(-rp5*omy4 + rp12*omy3 - rp9*omy2 + rp2*omy))*dT

 df_dT = &
 loc_eos1*p0r*dp0t + &
 loc_eos2*p0mr*dp0t + &
 loc_eos3*p0r*dp0mt + &
 loc_eos4*p0mr*dp0mt + &
 loc_eos5*p0r*dp1t + &
 loc_eos6*p0mr*dp1t + &
 loc_eos7*p0r*dp1mt + &
 loc_eos8*p0mr*dp1mt + &
 loc_eos9*p0r*dp2t + &
 loc_eos10*p0mr*dp2t + &
 loc_eos11*p0r*dp2mt + &
 loc_eos12*p0mr*dp2mt + &
 loc_eos13*p1r*dp0t + &
 loc_eos14*p1mr*dp0t + &
 loc_eos15*p1r*dp0mt + &
 loc_eos16*p1mr*dp0mt + &
 loc_eos17*p2r*dp0t + &
 loc_eos18*p2mr*dp0t + &
 loc_eos19*p2r*dp0mt + &
 loc_eos20*p2mr*dp0mt + &
 loc_eos21*p1r*dp1t + &
 loc_eos22*p1mr*dp1t + &
 loc_eos23*p1r*dp1mt + &
 loc_eos24*p1mr*dp1mt + &
 loc_eos25*p2r*dp1t + &
 loc_eos26*p2mr*dp1t + &
 loc_eos27*p2r*dp1mt + &
 loc_eos28*p2mr*dp1mt + &
 loc_eos29*p1r*dp2t + &
 loc_eos30*p1mr*dp2t + &
 loc_eos31*p1r*dp2mt + &
 loc_eos32*p1mr*dp2mt + &
 loc_eos33*p2r*dp2t + &
 loc_eos34*p2mr*dp2t + &
 loc_eos35*p2r*dp2mt + &
 loc_eos36*p2mr*dp2mt

 df_dT2 = rp0

 if(return_dE_dT) then

 ddp0t =  (-rp120*y3 + rp180*y2 - rp60*y)*idT2
 ddp1t =  (-rp60*y3 + rp96*y2 - rp36*y)*idT
 ddp2t =  (rph*(-rp20*y3 + rp36*y2 - rp18*y + rp2))

 ddp0mt =  (-rp120*omy3 + rp180*omy2 - rp60*omy)*idT2
 ddp1mt = -(-rp60*omy3 + rp96*omy2 - rp36*omy)*idT
 ddp2mt =  (rph*(-rp20*omy3 + rp36*omy2 - rp18*omy + rp2))

 df_dT2 = &
 loc_eos1*p0r*ddp0t + &
 loc_eos2*p0mr*ddp0t + &
 loc_eos3*p0r*ddp0mt + &
 loc_eos4*p0mr*ddp0mt + &
 loc_eos5*p0r*ddp1t + &
 loc_eos6*p0mr*ddp1t + &
 loc_eos7*p0r*ddp1mt + &
 loc_eos8*p0mr*ddp1mt + &
 loc_eos9*p0r*ddp2t + &
 loc_eos10*p0mr*ddp2t + &
 loc_eos11*p0r*ddp2mt + &
 loc_eos12*p0mr*ddp2mt + &
 loc_eos13*p1r*ddp0t + &
 loc_eos14*p1mr*ddp0t + &
 loc_eos15*p1r*ddp0mt + &
 loc_eos16*p1mr*ddp0mt + &
 loc_eos17*p2r*ddp0t + &
 loc_eos18*p2mr*ddp0t + &
 loc_eos19*p2r*ddp0mt + &
 loc_eos20*p2mr*ddp0mt + &
 loc_eos21*p1r*ddp1t + &
 loc_eos22*p1mr*ddp1t + &
 loc_eos23*p1r*ddp1mt + &
 loc_eos24*p1mr*ddp1mt + &
 loc_eos25*p2r*ddp1t + &
 loc_eos26*p2mr*ddp1t + &
 loc_eos27*p2r*ddp1mt + &
 loc_eos28*p2mr*ddp1mt + &
 loc_eos29*p1r*ddp2t + &
 loc_eos30*p1mr*ddp2t + &
 loc_eos31*p1r*ddp2mt + &
 loc_eos32*p1mr*ddp2mt + &
 loc_eos33*p2r*ddp2t + &
 loc_eos34*p2mr*ddp2t + &
 loc_eos35*p2r*ddp2mt + &
 loc_eos36*p2mr*ddp2mt

 endif

 s = -Ye*df_dT
 ds_dT = -Ye*df_dT2
 E = Ye*f + T*s
 dE_dT = T*ds_dT

 T2 = T*T
 T3 = T2*T
 T4 = T3*T

 tmp = rp1/abar

 E = E + rpoh*CONST_RGAS*T*tmp + CONST_RAD*T4/rho
 dE_dT = dE_dT + rpoh*CONST_RGAS*tmp + rp4*CONST_RAD*T3/rho

#ifdef USE_COULOMB_CORRECTIONS

 pion = CONST_RGAS*rho*T*tmp
 dpiondt = CONST_RGAS*rho*tmp

 xni = CONST_AV*tmp*rho

 ktinv = rp1/(CONST_KB*T)

 z = fthirds*CONST_PI
 s = z*xni

 lami = rp1/s**othird
 inv_lami = rp1/lami

 plasg = zbar*zbar*CONST_QE*CONST_QE*ktinv*inv_lami
 plasgdt = -plasg*ktinv*CONST_KB

 if (plasg>=rp1) then

   x        = plasg**oquart
   y        = CONST_AV*tmp*CONST_KB
   ecoul    = y*T*(cc_a1*plasg+cc_b1*x+cc_c1/x+cc_d1)

   y        = CONST_AV*tmp*CONST_KB*T*(cc_a1+oquart/plasg*(cc_b1*x-cc_c1/x))
   decouldt = y*plasgdt+ecoul/T

   y        = othird*rho
   dpcouldt = y*decouldt
 
 else 

   x        = plasg*sqrt(plasg)
   y        = plasg**cc_b2
   z        = cc_c2*x-othird*cc_a2*y
   pcoul    = -pion*z
   ecoul    = rp3*pcoul/rho

   s        = rpoh*cc_c2*x/plasg-othird*cc_a2*cc_b2*y/plasg
   dpcouldt = -dpiondt*z-pion*s*plasgdt

   s        = rp3/rho
   decouldt = s*dpcouldt

 end if

 dE_dT = dE_dT + decouldt
 E = E + ecoul

#endif

 end subroutine helm_rhoT_given2

 subroutine helm_rhoP_given(rho,P0,abar,zbar,T,E,sound,return_sound)
  real(kind=rp), intent(in) :: rho,P0,abar,zbar
  real(kind=rp), intent(inout) :: T,E,sound
  logical, intent(in) :: return_sound

  real(kind=rp) :: error,P,dP_dT,res,dE_dT,cv,Told
  integer :: iter

  sound = rp0
  cv = rp0
  error = rp1

  Told = T

  do iter=1,100

   call helm_rhoT_given1(rho,T,abar,zbar,P,dP_dT,.true.)
   res = P-P0
   T = T - res/dP_dT

   error = abs(res/P0)

   if( (T<Tl_eos) .or. (T>Th_eos) ) then
    T = Told
    error = em15
   endif

   if(error<helm_tol) exit

  end do

  if(return_sound) then 
   call helm_rhoT_given_full(rho,T,abar,zbar,P,E,sound,cv)
  else    
   call helm_rhoT_given2(rho,T,abar,zbar,E,dE_dT,.false.)         
  endif

 end subroutine helm_rhoP_given

 subroutine helm_rhoe_given(rho,E0,abar,zbar,T,P,sound,return_sound)
  real(kind=rp), intent(in) :: rho,E0,abar,zbar
  real(kind=rp), intent(inout) :: T,P,sound
  logical, intent(in) :: return_sound

  real(kind=rp) :: error,E,dE_dT,res,dP_dT,cv,Told
  integer :: iter

  error = rp1
  cv = rp0
  sound = rp0

  Told = T

  do iter=1,100

   call helm_rhoT_given2(rho,T,abar,zbar,E,dE_dT,.true.)
   res = E-E0
   T = T - res/dE_dT

   error = abs(res/E0)

   if( (T<Tl_eos) .or. (T>Th_eos) ) then
    T = Told
    error=em15
   endif

   if(error<helm_tol) exit

  end do

  if(return_sound) then 
   call helm_rhoT_given_full(rho,T,abar,zbar,P,E,sound,cv)
  else    
   call helm_rhoT_given1(rho,T,abar,zbar,P,dP_dT,.false.)
  endif

 end subroutine helm_rhoe_given

 subroutine helm_PT_given(T,P0,abar,zbar,rho,E,sound,return_sound)
  real(kind=rp), intent(in) :: T,P0,abar,zbar
  real(kind=rp), intent(inout) :: rho,E,sound
  logical, intent(in) :: return_sound

  real(kind=rp) :: error,P,dP_drho,res,dE_dT,cv,rhoold
  integer :: iter

  sound = rp0
  cv = rp0
  error = rp1

  rhoold = rho

  do iter=1,100

   call helm_rhoT_given3(rho,T,abar,zbar,P,dP_drho)
   res = P-P0
   rho = rho - res/dP_drho

   error = abs(res/P0)

   if( (rho<rhol_eos) .or. (rho>rhoh_eos) ) then
    rho = rhoold
    error = em15
   endif

   if(error<helm_tol) exit

  end do

  if(return_sound) then 
   call helm_rhoT_given_full(rho,T,abar,zbar,P,E,sound,cv)
  else    
   call helm_rhoT_given2(rho,T,abar,zbar,E,dE_dT,.false.)         
  endif

 end subroutine helm_PT_given

 subroutine helm_rhoT_given3(rho,T,abar,zbar,P,dP_drho)
 real(kind=rp), intent(in) :: rho,T,abar,zbar
 real(kind=rp), intent(inout) :: P,dP_drho

 real(kind=rp) :: &
 loc_eos1, &
 loc_eos2, &
 loc_eos3, &
 loc_eos4, &
 loc_eos5, &
 loc_eos6, &
 loc_eos7, &
 loc_eos8, &
 loc_eos9, &
 loc_eos10, &
 loc_eos11, &
 loc_eos12, &
 loc_eos13, &
 loc_eos14, &
 loc_eos15, &
 loc_eos16, &
 loc_eos17, &
 loc_eos18, &
 loc_eos19, &
 loc_eos20, &
 loc_eos21, &
 loc_eos22, &
 loc_eos23, &
 loc_eos24, &
 loc_eos25, &
 loc_eos26, &
 loc_eos27, &
 loc_eos28, &
 loc_eos29, &
 loc_eos30, &
 loc_eos31, &
 loc_eos32, &
 loc_eos33, &
 loc_eos34, &
 loc_eos35, &
 loc_eos36
        
 integer :: ih,jh

 real(kind=rp) :: df_drho
 real(kind=rp) :: T2,T3,T4,Ye,rhos

 real(kind=rp) :: x,y,drho,drho2,dT,dT2,tmp
 real(kind=rp) :: p0r,p0t,p0mr,p0mt,p1r,p1t,p1mr,p1mt,p2r,p2t,p2mr,p2mt,idrho,idrho2,idT,idT2
 real(kind=rp) :: dp0r,dp1r,dp2r,dp0mr,dp1mr,dp2mr
 real(kind=rp) :: omx,omy
 real(kind=rp) :: x2,x3,x4,x5,y2,y3,y4,y5,omx2,omx3,omx4,omx5,omy2,omy3,omy4,omy5

 real(kind=rp) :: &
 pion,dpiondd

#ifdef USE_COULOMB_CORRECTIONS

 real(kind=rp) :: &
 xni, &
 dxnidd, &
 dxnida, &
 ktinv, &
 dsdd, &
 dsda, &
 lami, &
 inv_lami, &
 lamidd, &
 lamida, &
 plasg, &
 plasgdd, &
 ecoul, &
 pcoul, &
 dpcouldd, &
 decouldd, &
 s, &
 z

#endif
             
 Ye = zbar/abar
 rhos = rho*Ye

 ih = int((log10(rhos)-log10(helm_rho(1)))/helm_drho) + 1
 jh = int((log10(T)-log10(helm_T(1)))/helm_dT) + 1

 tmp = helm_rho(ih)
 drho = helm_rho(ih+1)-tmp
 x = (rhos-tmp)/drho
 omx = rp1-x

 tmp = helm_T(jh)
 dT = helm_T(jh+1)-tmp
 y = (T-tmp)/dT
 omy = rp1-y

 drho2 = drho*drho
 dT2 = dT*dT

 idrho = rp1/drho
 idrho2 = idrho*idrho

 idT = rp1/dT
 idT2 = idT*idT

 loc_eos1 = helm_table_var(1,ih,jh)
 loc_eos2 = helm_table_var(1,ih+1,jh)
 loc_eos3 = helm_table_var(1,ih,jh+1)
 loc_eos4 = helm_table_var(1,ih+1,jh+1)
 loc_eos5 = helm_table_var(2,ih,jh)
 loc_eos6 = helm_table_var(2,ih+1,jh)
 loc_eos7 = helm_table_var(2,ih,jh+1)
 loc_eos8 = helm_table_var(2,ih+1,jh+1)
 loc_eos9 = helm_table_var(3,ih,jh)
 loc_eos10 = helm_table_var(3,ih+1,jh)
 loc_eos11 = helm_table_var(3,ih,jh+1)
 loc_eos12 = helm_table_var(3,ih+1,jh+1)
 loc_eos13 = helm_table_var(4,ih,jh)
 loc_eos14 = helm_table_var(4,ih+1,jh)
 loc_eos15 = helm_table_var(4,ih,jh+1)
 loc_eos16 = helm_table_var(4,ih+1,jh+1)
 loc_eos17 = helm_table_var(5,ih,jh)
 loc_eos18 = helm_table_var(5,ih+1,jh)
 loc_eos19 = helm_table_var(5,ih,jh+1)
 loc_eos20 = helm_table_var(5,ih+1,jh+1)
 loc_eos21 = helm_table_var(6,ih,jh)
 loc_eos22 = helm_table_var(6,ih+1,jh)
 loc_eos23 = helm_table_var(6,ih,jh+1)
 loc_eos24 = helm_table_var(6,ih+1,jh+1)
 loc_eos25 = helm_table_var(7,ih,jh)
 loc_eos26 = helm_table_var(7,ih+1,jh)
 loc_eos27 = helm_table_var(7,ih,jh+1)
 loc_eos28 = helm_table_var(7,ih+1,jh+1)
 loc_eos29 = helm_table_var(8,ih,jh)
 loc_eos30 = helm_table_var(8,ih+1,jh)
 loc_eos31 = helm_table_var(8,ih,jh+1)
 loc_eos32 = helm_table_var(8,ih+1,jh+1)
 loc_eos33 = helm_table_var(9,ih,jh)
 loc_eos34 = helm_table_var(9,ih+1,jh)
 loc_eos35 = helm_table_var(9,ih,jh+1)
 loc_eos36 = helm_table_var(9,ih+1,jh+1)

 x2 = x*x
 x3 = x2*x
 x4 = x3*x
 x5 = x4*x
 p0r = -rp6*x5 + rp15*x4 - rp10*x3 + rp1
 p1r = (-rp3*x5 + rp8*x4 - rp6*x3 + x)*drho
 p2r = (rph*(-x5 + rp3*x4 - rp3*x3 + x2))*drho2

 omx2 = omx*omx
 omx3 = omx2*omx
 omx4 = omx3*omx
 omx5 = omx4*omx
 p0mr = -rp6*omx5 + rp15*omx4 - rp10*omx3 + rp1
 p1mr =  (rp3*omx5 - rp8*omx4 + rp6*omx3 - omx)*drho
 p2mr =  (rph*(-omx5 + rp3*omx4 - rp3*omx3 + omx2))*drho2

 y2 = y*y
 y3 = y2*y
 y4 = y3*y
 y5 = y4*y
 p0t = -rp6*y5 + rp15*y4 - rp10*y3 + rp1
 p1t = (-rp3*y5 + rp8*y4 - rp6*y3 + y)*dT
 p2t = (rph*(-y5 + rp3*y4 - rp3*y3 + y2))*dT2

 omy2 = omy*omy
 omy3 = omy2*omy
 omy4 = omy3*omy
 omy5 = omy4*omy
 p0mt = -rp6*omy5 + rp15*omy4 - rp10*omy3 + rp1
 p1mt =  (rp3*omy5 - rp8*omy4 + rp6*omy3 - omy)*dT
 p2mt =  (rph*(-omy5 + rp3*omy4 - rp3*omy3 + omy2))*dT2

 dp0r =  (-rp30*x4 + rp60*x3 - rp30*x2)*idrho
 dp1r =  (-rp15*x4 + rp32*x3 - rp18*x2 + rp1)
 dp2r =  (rph*(-rp5*x4 + rp12*x3 - rp9*x2 + rp2*x))*drho

 dp0mr = -(-rp30*omx4 + rp60*omx3 - rp30*omx2)*idrho
 dp1mr =  (-rp15*omx4 + rp32*omx3 - rp18*omx2 + rp1)
 dp2mr = -(rph*(-rp5*omx4 + rp12*omx3 - rp9*omx2 + rp2*omx))*drho

 df_drho = &
 loc_eos1*dp0r*p0t + &
 loc_eos2*dp0mr*p0t + &
 loc_eos3*dp0r*p0mt + &
 loc_eos4*dp0mr*p0mt + &
 loc_eos5*dp0r*p1t + &
 loc_eos6*dp0mr*p1t + &
 loc_eos7*dp0r*p1mt + &
 loc_eos8*dp0mr*p1mt + &
 loc_eos9*dp0r*p2t + &
 loc_eos10*dp0mr*p2t + &
 loc_eos11*dp0r*p2mt + &
 loc_eos12*dp0mr*p2mt + &
 loc_eos13*dp1r*p0t + &
 loc_eos14*dp1mr*p0t + &
 loc_eos15*dp1r*p0mt + &
 loc_eos16*dp1mr*p0mt + &
 loc_eos17*dp2r*p0t + &
 loc_eos18*dp2mr*p0t + &
 loc_eos19*dp2r*p0mt + &
 loc_eos20*dp2mr*p0mt + &
 loc_eos21*dp1r*p1t + &
 loc_eos22*dp1mr*p1t + &
 loc_eos23*dp1r*p1mt + &
 loc_eos24*dp1mr*p1mt + &
 loc_eos25*dp2r*p1t + &
 loc_eos26*dp2mr*p1t + &
 loc_eos27*dp2r*p1mt + &
 loc_eos28*dp2mr*p1mt + &
 loc_eos29*dp1r*p2t + &
 loc_eos30*dp1mr*p2t + &
 loc_eos31*dp1r*p2mt + &
 loc_eos32*dp1mr*p2mt + &
 loc_eos33*dp2r*p2t + &
 loc_eos34*dp2mr*p2t + &
 loc_eos35*dp2r*p2mt + &
 loc_eos36*dp2mr*p2mt

 p0r = rp2*x3-rp3*x2+rp1
 p1r = (x3-rp2*x2+x)*drho

 p0mr = rp2*omx3-rp3*omx2+rp1
 p1mr = -(omx3-rp2*omx2+omx)*drho

 p0t = rp2*y3-rp3*y2+rp1
 p1t = (y3-rp2*y2+y)*dT

 p0mt = rp2*omy3-rp3*omy2+rp1
 p1mt = -(omy3-rp2*omy2+omy)*dT

 loc_eos1 = dpdrho_table_var(1,ih,jh)
 loc_eos2 = dpdrho_table_var(1,ih+1,jh)
 loc_eos3 = dpdrho_table_var(1,ih,jh+1)
 loc_eos4 = dpdrho_table_var(1,ih+1,jh+1)
 loc_eos5 = dpdrho_table_var(2,ih,jh)
 loc_eos6 = dpdrho_table_var(2,ih+1,jh)
 loc_eos7 = dpdrho_table_var(2,ih,jh+1)
 loc_eos8 = dpdrho_table_var(2,ih+1,jh+1)
 loc_eos9 = dpdrho_table_var(3,ih,jh)
 loc_eos10 = dpdrho_table_var(3,ih+1,jh)
 loc_eos11 = dpdrho_table_var(3,ih,jh+1)
 loc_eos12 = dpdrho_table_var(3,ih+1,jh+1)
 loc_eos13 = dpdrho_table_var(4,ih,jh)
 loc_eos14 = dpdrho_table_var(4,ih+1,jh)
 loc_eos15 = dpdrho_table_var(4,ih,jh+1)
 loc_eos16 = dpdrho_table_var(4,ih+1,jh+1)

 dP_drho = &
 loc_eos1*p0r*p0t + &
 loc_eos2*p0mr*p0t + &
 loc_eos3*p0r*p0mt + &
 loc_eos4*p0mr*p0mt + &
 loc_eos5*p0r*p1t + &
 loc_eos6*p0mr*p1t + &
 loc_eos7*p0r*p1mt + &
 loc_eos8*p0mr*p1mt + &
 loc_eos9*p1r*p0t + &
 loc_eos10*p1mr*p0t + &
 loc_eos11*p1r*p0mt + &
 loc_eos12*p1mr*p0mt + &
 loc_eos13*p1r*p1t + &
 loc_eos14*p1mr*p1t + &
 loc_eos15*p1r*p1mt + &
 loc_eos16*p1mr*p1mt

 dP_drho = Ye*dP_drho

 tmp = rhos*rhos
 P = tmp*df_drho

 tmp = rp1/abar
 T2 = T*T
 T3 = T2*T
 T4 = T3*T

 pion = CONST_RGAS*rho*T*tmp
 dpiondd = CONST_RGAS*T*tmp

 P = P + pion + CONST_RAD*T4*othird
 dP_drho = dP_drho + dpiondd

#ifdef USE_COULOMB_CORRECTIONS

 xni = CONST_AV*tmp*rho

 dxnidd = CONST_AV*tmp
 dxnida = -xni*tmp

 ktinv = rp1/(CONST_KB*T)

 z = fthirds*CONST_PI
 s = z*xni
 dsdd = z*dxnidd
 dsda = z*dxnida

 lami = rp1/s**othird
 inv_lami = rp1/lami
 z = -othird*lami
 lamidd = z*dsdd/s
 lamida = z*dsda/s

 plasg = zbar*zbar*CONST_QE*CONST_QE*ktinv*inv_lami
 z = -plasg*inv_lami
 plasgdd = z*lamidd

 if (plasg>=rp1) then

   x        = plasg**oquart
   y        = CONST_AV*tmp*CONST_KB
   ecoul    = y*T*(cc_a1*plasg+cc_b1*x+cc_c1/x+cc_d1)
   pcoul    = othird*rho*ecoul

   y        = CONST_AV*tmp*CONST_KB*T*(cc_a1+oquart/plasg*(cc_b1*x-cc_c1/x))
   decouldd = y*plasgdd

   y        = othird*rho
   dpcouldd = othird*ecoul+y*decouldd
 
 else 

   x        = plasg*sqrt(plasg)
   y        = plasg**cc_b2
   z        = cc_c2*x-othird*cc_a2*y
   pcoul    = -pion*z

   s        = rpoh*cc_c2*x/plasg-othird*cc_a2*cc_b2*y/plasg
   dpcouldd = -dpiondd*z-pion*s*plasgdd

 end if

 P = P + pcoul
 dP_drho = dP_drho + dpcouldd

#endif

 end subroutine helm_rhoT_given3

#endif

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! PIG EOS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#ifdef PIG_EOS

 subroutine load_pig_table(pig_table_var, dpdrho_table_var, pig_rho, pig_T, pig_drho, pig_dT)
  real(kind=rp), dimension(1:pig_nvars,1:pig_nrho,1:pig_nT), intent(out) :: pig_table_var
  real(kind=rp), dimension(1:4,1:pig_nrho,1:pig_nT), intent(out) :: dpdrho_table_var 
  real(kind=rp), dimension(1:pig_nrho), intent(out) :: pig_rho
  real(kind=rp), dimension(1:pig_nT), intent(out) :: pig_T
  real(kind=rp), intent(out) :: pig_drho, pig_dT

  integer :: i,j

  open(unit=iunit,file=path_to_pig_table,status='old')

  pig_dT = ((pig_lthi)-(pig_ltlo))/real(pig_nT-1,kind=rp)
  pig_drho = ((pig_ldhi)-(pig_ldlo))/real(pig_nrho-1,kind=rp)

  do j=1,pig_nT

   pig_T(j) = 10**((pig_ltlo)+real(j-1,kind=rp)*pig_dT)

   do i=1,pig_nrho

     pig_rho(i) = 10**((pig_ldlo)+real(i-1,kind=rp)*pig_drho)

     read(iunit,*) & 
     pig_table_var(id_f,i,j), &
     pig_table_var(id_dfdrho,i,j), &
     pig_table_var(id_dfdT,i,j), &
     pig_table_var(id_d2fdrho2,i,j), &
     pig_table_var(id_d2fdT2,i,j), &
     pig_table_var(id_d2fdrhodT,i,j), &
     pig_table_var(id_d3fdrho2dT,i,j), &
     pig_table_var(id_d3fdrhodT2,i,j), &
     pig_table_var(id_d4fdrho2dT2,i,j)

   end do
  end do

  do j=1,pig_nT
   do i=1,pig_nrho
     read(iunit,*) &
     dpdrho_table_var(id_c,i,j), &
     dpdrho_table_var(id_dcdrho,i,j), &
     dpdrho_table_var(id_dcdT,i,j), &
     dpdrho_table_var(id_d2cdrhodT,i,j)
   end do
  end do

  close(iunit)

 end subroutine load_pig_table

 subroutine pig_rhoT_given_full(rho,T,P,E,sound,cv)
 real(kind=rp), intent(in) :: rho,T
 real(kind=rp), intent(inout) :: P,E,sound,cv

 real(kind=rp) :: &
 loc_eos1, &
 loc_eos2, &
 loc_eos3, &
 loc_eos4, &
 loc_eos5, &
 loc_eos6, &
 loc_eos7, &
 loc_eos8, &
 loc_eos9, &
 loc_eos10, &
 loc_eos11, &
 loc_eos12, &
 loc_eos13, &
 loc_eos14, &
 loc_eos15, &
 loc_eos16, &
 loc_eos17, &
 loc_eos18, &
 loc_eos19, &
 loc_eos20, &
 loc_eos21, &
 loc_eos22, &
 loc_eos23, &
 loc_eos24, &
 loc_eos25, &
 loc_eos26, &
 loc_eos27, &
 loc_eos28, &
 loc_eos29, &
 loc_eos30, &
 loc_eos31, &
 loc_eos32, &
 loc_eos33, &
 loc_eos34, &
 loc_eos35, &
 loc_eos36
        
 integer :: ih,jh

 real(kind=rp) :: df_drho,df_dT,df_drhodT,df_dT2
 real(kind=rp) :: f,s,ds_dT,ds_drho,T2,T3,T4,rhos,Ye
 real(kind=rp) :: zz,chiT,chirho,gam1,z,dP_drho,dP_dT,dE_drho,dE_dT

 real(kind=rp) :: x,y,drho,drho2,dT,dT2,tmp
 real(kind=rp) :: p0r,p0t,p0mr,p0mt,p1r,p1t,p1mr,p1mt,p2r,p2t,p2mr,p2mt,idrho,idrho2,idT,idT2
 real(kind=rp) :: dp0r,dp1r,dp2r,dp0mr,dp1mr,dp2mr
 real(kind=rp) :: dp0t,dp1t,dp2t,dp0mt,dp1mt,dp2mt
 real(kind=rp) :: ddp0t,ddp1t,ddp2t,ddp0mt,ddp1mt,ddp2mt
 real(kind=rp) :: omx,omy
 real(kind=rp) :: x2,x3,x4,x5,y2,y3,y4,y5,omx2,omx3,omx4,omx5,omy2,omy3,omy4,omy5
 
 Ye = rp1 

 rhos = rho*Ye

 ih = int((log10(rhos)-log10(pig_rho(1)))/pig_drho) + 1
 jh = int((log10(T)-log10(pig_T(1)))/pig_dT) + 1

 tmp = pig_rho(ih)
 drho = pig_rho(ih+1)-tmp
 x = (rhos-tmp)/drho
 omx = rp1-x

 tmp = pig_T(jh)
 dT = pig_T(jh+1)-tmp
 y = (T-tmp)/dT
 omy = rp1-y

 drho2 = drho*drho
 dT2 = dT*dT

 idrho = rp1/drho
 idrho2 = idrho*idrho

 idT = rp1/dT
 idT2 = idT*idT

 loc_eos1 = pig_table_var(1,ih,jh)
 loc_eos2 = pig_table_var(1,ih+1,jh)
 loc_eos3 = pig_table_var(1,ih,jh+1)
 loc_eos4 = pig_table_var(1,ih+1,jh+1)
 loc_eos5 = pig_table_var(2,ih,jh)
 loc_eos6 = pig_table_var(2,ih+1,jh)
 loc_eos7 = pig_table_var(2,ih,jh+1)
 loc_eos8 = pig_table_var(2,ih+1,jh+1)
 loc_eos9 = pig_table_var(3,ih,jh)
 loc_eos10 = pig_table_var(3,ih+1,jh)
 loc_eos11 = pig_table_var(3,ih,jh+1)
 loc_eos12 = pig_table_var(3,ih+1,jh+1)
 loc_eos13 = pig_table_var(4,ih,jh)
 loc_eos14 = pig_table_var(4,ih+1,jh)
 loc_eos15 = pig_table_var(4,ih,jh+1)
 loc_eos16 = pig_table_var(4,ih+1,jh+1)
 loc_eos17 = pig_table_var(5,ih,jh)
 loc_eos18 = pig_table_var(5,ih+1,jh)
 loc_eos19 = pig_table_var(5,ih,jh+1)
 loc_eos20 = pig_table_var(5,ih+1,jh+1)
 loc_eos21 = pig_table_var(6,ih,jh)
 loc_eos22 = pig_table_var(6,ih+1,jh)
 loc_eos23 = pig_table_var(6,ih,jh+1)
 loc_eos24 = pig_table_var(6,ih+1,jh+1)
 loc_eos25 = pig_table_var(7,ih,jh)
 loc_eos26 = pig_table_var(7,ih+1,jh)
 loc_eos27 = pig_table_var(7,ih,jh+1)
 loc_eos28 = pig_table_var(7,ih+1,jh+1)
 loc_eos29 = pig_table_var(8,ih,jh)
 loc_eos30 = pig_table_var(8,ih+1,jh)
 loc_eos31 = pig_table_var(8,ih,jh+1)
 loc_eos32 = pig_table_var(8,ih+1,jh+1)
 loc_eos33 = pig_table_var(9,ih,jh)
 loc_eos34 = pig_table_var(9,ih+1,jh)
 loc_eos35 = pig_table_var(9,ih,jh+1)
 loc_eos36 = pig_table_var(9,ih+1,jh+1)

 x2 = x*x
 x3 = x2*x
 x4 = x3*x
 x5 = x4*x
 p0r = -rp6*x5 + rp15*x4 - rp10*x3 + rp1
 p1r = (-rp3*x5 + rp8*x4 - rp6*x3 + x)*drho
 p2r = (rph*(-x5 + rp3*x4 - rp3*x3 + x2))*drho2

 omx2 = omx*omx
 omx3 = omx2*omx
 omx4 = omx3*omx
 omx5 = omx4*omx
 p0mr = -rp6*omx5 + rp15*omx4 - rp10*omx3 + rp1
 p1mr =  (rp3*omx5 - rp8*omx4 + rp6*omx3 - omx)*drho
 p2mr =  (rph*(-omx5 + rp3*omx4 - rp3*omx3 + omx2))*drho2

 y2 = y*y
 y3 = y2*y
 y4 = y3*y
 y5 = y4*y
 p0t = -rp6*y5 + rp15*y4 - rp10*y3 + rp1
 p1t = (-rp3*y5 + rp8*y4 - rp6*y3 + y)*dT
 p2t = (rph*(-y5 + rp3*y4 - rp3*y3 + y2))*dT2

 omy2 = omy*omy
 omy3 = omy2*omy
 omy4 = omy3*omy
 omy5 = omy4*omy
 p0mt = -rp6*omy5 + rp15*omy4 - rp10*omy3 + rp1
 p1mt =  (rp3*omy5 - rp8*omy4 + rp6*omy3 - omy)*dT
 p2mt =  (rph*(-omy5 + rp3*omy4 - rp3*omy3 + omy2))*dT2

 f = &
 loc_eos1*p0r*p0t + &
 loc_eos2*p0mr*p0t + &
 loc_eos3*p0r*p0mt + &
 loc_eos4*p0mr*p0mt + &
 loc_eos5*p0r*p1t + &
 loc_eos6*p0mr*p1t + &
 loc_eos7*p0r*p1mt + &
 loc_eos8*p0mr*p1mt + &
 loc_eos9*p0r*p2t + &
 loc_eos10*p0mr*p2t + &
 loc_eos11*p0r*p2mt + &
 loc_eos12*p0mr*p2mt + &
 loc_eos13*p1r*p0t + &
 loc_eos14*p1mr*p0t + &
 loc_eos15*p1r*p0mt + &
 loc_eos16*p1mr*p0mt + &
 loc_eos17*p2r*p0t + &
 loc_eos18*p2mr*p0t + &
 loc_eos19*p2r*p0mt + &
 loc_eos20*p2mr*p0mt + &
 loc_eos21*p1r*p1t + &
 loc_eos22*p1mr*p1t + &
 loc_eos23*p1r*p1mt + &
 loc_eos24*p1mr*p1mt + &
 loc_eos25*p2r*p1t + &
 loc_eos26*p2mr*p1t + &
 loc_eos27*p2r*p1mt + &
 loc_eos28*p2mr*p1mt + &
 loc_eos29*p1r*p2t + &
 loc_eos30*p1mr*p2t + &
 loc_eos31*p1r*p2mt + &
 loc_eos32*p1mr*p2mt + &
 loc_eos33*p2r*p2t + &
 loc_eos34*p2mr*p2t + &
 loc_eos35*p2r*p2mt + &
 loc_eos36*p2mr*p2mt

 dp0r =  (-rp30*x4 + rp60*x3 - rp30*x2)*idrho
 dp1r =  (-rp15*x4 + rp32*x3 - rp18*x2 + rp1)
 dp2r =  (rph*(-rp5*x4 + rp12*x3 - rp9*x2 + rp2*x))*drho

 dp0mr = -(-rp30*omx4 + rp60*omx3 - rp30*omx2)*idrho
 dp1mr =  (-rp15*omx4 + rp32*omx3 - rp18*omx2 + rp1)
 dp2mr = -(rph*(-rp5*omx4 + rp12*omx3 - rp9*omx2 + rp2*omx))*drho

 df_drho = &
 loc_eos1*dp0r*p0t + &
 loc_eos2*dp0mr*p0t + &
 loc_eos3*dp0r*p0mt + &
 loc_eos4*dp0mr*p0mt + &
 loc_eos5*dp0r*p1t + &
 loc_eos6*dp0mr*p1t + &
 loc_eos7*dp0r*p1mt + &
 loc_eos8*dp0mr*p1mt + &
 loc_eos9*dp0r*p2t + &
 loc_eos10*dp0mr*p2t + &
 loc_eos11*dp0r*p2mt + &
 loc_eos12*dp0mr*p2mt + &
 loc_eos13*dp1r*p0t + &
 loc_eos14*dp1mr*p0t + &
 loc_eos15*dp1r*p0mt + &
 loc_eos16*dp1mr*p0mt + &
 loc_eos17*dp2r*p0t + &
 loc_eos18*dp2mr*p0t + &
 loc_eos19*dp2r*p0mt + &
 loc_eos20*dp2mr*p0mt + &
 loc_eos21*dp1r*p1t + &
 loc_eos22*dp1mr*p1t + &
 loc_eos23*dp1r*p1mt + &
 loc_eos24*dp1mr*p1mt + &
 loc_eos25*dp2r*p1t + &
 loc_eos26*dp2mr*p1t + &
 loc_eos27*dp2r*p1mt + &
 loc_eos28*dp2mr*p1mt + &
 loc_eos29*dp1r*p2t + &
 loc_eos30*dp1mr*p2t + &
 loc_eos31*dp1r*p2mt + &
 loc_eos32*dp1mr*p2mt + &
 loc_eos33*dp2r*p2t + &
 loc_eos34*dp2mr*p2t + &
 loc_eos35*dp2r*p2mt + &
 loc_eos36*dp2mr*p2mt

 dp0t =  (-rp30*y4 + rp60*y3 - rp30*y2)*idT
 dp1t =  (-rp15*y4 + rp32*y3 - rp18*y2 + rp1)
 dp2t =  (rph*(-rp5*y4 + rp12*y3 - rp9*y2 + rp2*y))*dT

 dp0mt = -(-rp30*omy4 + rp60*omy3 - rp30*omy2)*idT
 dp1mt =  (-rp15*omy4 + rp32*omy3 - rp18*omy2 + rp1)
 dp2mt = -(rph*(-rp5*omy4 + rp12*omy3 - rp9*omy2 + rp2*omy))*dT

 df_dT = &
 loc_eos1*p0r*dp0t + &
 loc_eos2*p0mr*dp0t + &
 loc_eos3*p0r*dp0mt + &
 loc_eos4*p0mr*dp0mt + &
 loc_eos5*p0r*dp1t + &
 loc_eos6*p0mr*dp1t + &
 loc_eos7*p0r*dp1mt + &
 loc_eos8*p0mr*dp1mt + &
 loc_eos9*p0r*dp2t + &
 loc_eos10*p0mr*dp2t + &
 loc_eos11*p0r*dp2mt + &
 loc_eos12*p0mr*dp2mt + &
 loc_eos13*p1r*dp0t + &
 loc_eos14*p1mr*dp0t + &
 loc_eos15*p1r*dp0mt + &
 loc_eos16*p1mr*dp0mt + &
 loc_eos17*p2r*dp0t + &
 loc_eos18*p2mr*dp0t + &
 loc_eos19*p2r*dp0mt + &
 loc_eos20*p2mr*dp0mt + &
 loc_eos21*p1r*dp1t + &
 loc_eos22*p1mr*dp1t + &
 loc_eos23*p1r*dp1mt + &
 loc_eos24*p1mr*dp1mt + &
 loc_eos25*p2r*dp1t + &
 loc_eos26*p2mr*dp1t + &
 loc_eos27*p2r*dp1mt + &
 loc_eos28*p2mr*dp1mt + &
 loc_eos29*p1r*dp2t + &
 loc_eos30*p1mr*dp2t + &
 loc_eos31*p1r*dp2mt + &
 loc_eos32*p1mr*dp2mt + &
 loc_eos33*p2r*dp2t + &
 loc_eos34*p2mr*dp2t + &
 loc_eos35*p2r*dp2mt + &
 loc_eos36*p2mr*dp2mt

 df_drhodT = &
 loc_eos1*dp0r*dp0t + &
 loc_eos2*dp0mr*dp0t + &
 loc_eos3*dp0r*dp0mt + &
 loc_eos4*dp0mr*dp0mt + &
 loc_eos5*dp0r*dp1t + &
 loc_eos6*dp0mr*dp1t + &
 loc_eos7*dp0r*dp1mt + &
 loc_eos8*dp0mr*dp1mt + &
 loc_eos9*dp0r*dp2t + &
 loc_eos10*dp0mr*dp2t + &
 loc_eos11*dp0r*dp2mt + &
 loc_eos12*dp0mr*dp2mt + &
 loc_eos13*dp1r*dp0t + &
 loc_eos14*dp1mr*dp0t + &
 loc_eos15*dp1r*dp0mt + &
 loc_eos16*dp1mr*dp0mt + &
 loc_eos17*dp2r*dp0t + &
 loc_eos18*dp2mr*dp0t + &
 loc_eos19*dp2r*dp0mt + &
 loc_eos20*dp2mr*dp0mt + &
 loc_eos21*dp1r*dp1t + &
 loc_eos22*dp1mr*dp1t + &
 loc_eos23*dp1r*dp1mt + &
 loc_eos24*dp1mr*dp1mt + &
 loc_eos25*dp2r*dp1t + &
 loc_eos26*dp2mr*dp1t + &
 loc_eos27*dp2r*dp1mt + &
 loc_eos28*dp2mr*dp1mt + &
 loc_eos29*dp1r*dp2t + &
 loc_eos30*dp1mr*dp2t + &
 loc_eos31*dp1r*dp2mt + &
 loc_eos32*dp1mr*dp2mt + &
 loc_eos33*dp2r*dp2t + &
 loc_eos34*dp2mr*dp2t + &
 loc_eos35*dp2r*dp2mt + &
 loc_eos36*dp2mr*dp2mt

 ddp0t =  (-rp120*y3 + rp180*y2 - rp60*y)*idT2
 ddp1t =  (-rp60*y3 + rp96*y2 - rp36*y)*idT
 ddp2t =  (rph*(-rp20*y3 + rp36*y2 - rp18*y + rp2))

 ddp0mt =  (-rp120*omy3 + rp180*omy2 - rp60*omy)*idT2
 ddp1mt = -(-rp60*omy3 + rp96*omy2 - rp36*omy)*idT
 ddp2mt =  (rph*(-rp20*omy3 + rp36*omy2 - rp18*omy + rp2))

 df_dT2 = &
 loc_eos1*p0r*ddp0t + &
 loc_eos2*p0mr*ddp0t + &
 loc_eos3*p0r*ddp0mt + &
 loc_eos4*p0mr*ddp0mt + &
 loc_eos5*p0r*ddp1t + &
 loc_eos6*p0mr*ddp1t + &
 loc_eos7*p0r*ddp1mt + &
 loc_eos8*p0mr*ddp1mt + &
 loc_eos9*p0r*ddp2t + &
 loc_eos10*p0mr*ddp2t + &
 loc_eos11*p0r*ddp2mt + &
 loc_eos12*p0mr*ddp2mt + &
 loc_eos13*p1r*ddp0t + &
 loc_eos14*p1mr*ddp0t + &
 loc_eos15*p1r*ddp0mt + &
 loc_eos16*p1mr*ddp0mt + &
 loc_eos17*p2r*ddp0t + &
 loc_eos18*p2mr*ddp0t + &
 loc_eos19*p2r*ddp0mt + &
 loc_eos20*p2mr*ddp0mt + &
 loc_eos21*p1r*ddp1t + &
 loc_eos22*p1mr*ddp1t + &
 loc_eos23*p1r*ddp1mt + &
 loc_eos24*p1mr*ddp1mt + &
 loc_eos25*p2r*ddp1t + &
 loc_eos26*p2mr*ddp1t + &
 loc_eos27*p2r*ddp1mt + &
 loc_eos28*p2mr*ddp1mt + &
 loc_eos29*p1r*ddp2t + &
 loc_eos30*p1mr*ddp2t + &
 loc_eos31*p1r*ddp2mt + &
 loc_eos32*p1mr*ddp2mt + &
 loc_eos33*p2r*ddp2t + &
 loc_eos34*p2mr*ddp2t + &
 loc_eos35*p2r*ddp2mt + &
 loc_eos36*p2mr*ddp2mt

 p0r = rp2*x3-rp3*x2+rp1
 p1r = (x3-rp2*x2+x)*drho

 p0mr = rp2*omx3-rp3*omx2+rp1
 p1mr = -(omx3-rp2*omx2+omx)*drho

 p0t = rp2*y3-rp3*y2+rp1
 p1t = (y3-rp2*y2+y)*dT

 p0mt = rp2*omy3-rp3*omy2+rp1
 p1mt = -(omy3-rp2*omy2+omy)*dT

 loc_eos1 = dpdrho_table_var(1,ih,jh)
 loc_eos2 = dpdrho_table_var(1,ih+1,jh)
 loc_eos3 = dpdrho_table_var(1,ih,jh+1)
 loc_eos4 = dpdrho_table_var(1,ih+1,jh+1)
 loc_eos5 = dpdrho_table_var(2,ih,jh)
 loc_eos6 = dpdrho_table_var(2,ih+1,jh)
 loc_eos7 = dpdrho_table_var(2,ih,jh+1)
 loc_eos8 = dpdrho_table_var(2,ih+1,jh+1)
 loc_eos9 = dpdrho_table_var(3,ih,jh)
 loc_eos10 = dpdrho_table_var(3,ih+1,jh)
 loc_eos11 = dpdrho_table_var(3,ih,jh+1)
 loc_eos12 = dpdrho_table_var(3,ih+1,jh+1)
 loc_eos13 = dpdrho_table_var(4,ih,jh)
 loc_eos14 = dpdrho_table_var(4,ih+1,jh)
 loc_eos15 = dpdrho_table_var(4,ih,jh+1)
 loc_eos16 = dpdrho_table_var(4,ih+1,jh+1)

 dP_drho = &
 loc_eos1*p0r*p0t + &
 loc_eos2*p0mr*p0t + &
 loc_eos3*p0r*p0mt + &
 loc_eos4*p0mr*p0mt + &
 loc_eos5*p0r*p1t + &
 loc_eos6*p0mr*p1t + &
 loc_eos7*p0r*p1mt + &
 loc_eos8*p0mr*p1mt + &
 loc_eos9*p1r*p0t + &
 loc_eos10*p1mr*p0t + &
 loc_eos11*p1r*p0mt + &
 loc_eos12*p1mr*p0mt + &
 loc_eos13*p1r*p1t + &
 loc_eos14*p1mr*p1t + &
 loc_eos15*p1r*p1mt + &
 loc_eos16*p1mr*p1mt

 tmp = rhos*rhos
 P = tmp*df_drho
 dP_dT = tmp*df_drhodT
 s = -Ye*df_dT
 ds_dT = -Ye*df_dT2
 tmp = Ye*Ye
 ds_drho = -df_drhodT*tmp
 E = Ye*f + T*s 
 dE_dT = T*ds_dT
 dE_drho = df_drho*tmp + T*ds_drho

 T2 = T*T
 T3 = T2*T
 T4 = T3*T

 P = P + CONST_RAD*T4*othird
 dP_dT = dP_dT + fthirds*CONST_RAD*T3

 E = E + CONST_RAD*T4/rho 
 dE_dT = dE_dT + rp4*CONST_RAD*T3/rho
 dE_drho = dE_drho - CONST_RAD*T4/(rho*rho)

 zz = P/rho
 cv = dE_dT
 chiT = T/P*dP_dT
 chirho = dP_drho/zz
 x = zz*chiT/(T*cv)
 gam1 = chiT*x+chirho
 z = rp1 + (E+CONST_C2)/zz
 sound = CONST_C*sqrt(gam1/z)

 end subroutine pig_rhoT_given_full

 subroutine pig_rhoT_given1(rho,T,P,dP_dT,return_dP_dT)
 real(kind=rp), intent(in) :: rho,T
 real(kind=rp), intent(inout) :: P,dP_dT
 logical, intent(in) :: return_dP_dT

 real(kind=rp) :: &
 loc_eos1, &
 loc_eos2, &
 loc_eos3, &
 loc_eos4, &
 loc_eos5, &
 loc_eos6, &
 loc_eos7, &
 loc_eos8, &
 loc_eos9, &
 loc_eos10, &
 loc_eos11, &
 loc_eos12, &
 loc_eos13, &
 loc_eos14, &
 loc_eos15, &
 loc_eos16, &
 loc_eos17, &
 loc_eos18, &
 loc_eos19, &
 loc_eos20, &
 loc_eos21, &
 loc_eos22, &
 loc_eos23, &
 loc_eos24, &
 loc_eos25, &
 loc_eos26, &
 loc_eos27, &
 loc_eos28, &
 loc_eos29, &
 loc_eos30, &
 loc_eos31, &
 loc_eos32, &
 loc_eos33, &
 loc_eos34, &
 loc_eos35, &
 loc_eos36
 
 integer :: ih,jh

 real(kind=rp) :: df_drho,df_drhodT
 real(kind=rp) :: T2,T3,T4,Ye,rhos

 real(kind=rp) :: x,y,drho,drho2,dT,dT2,tmp
 real(kind=rp) :: p0r,p0t,p0mr,p0mt,p1r,p1t,p1mr,p1mt,p2r,p2t,p2mr,p2mt,idrho,idrho2,idT,idT2
 real(kind=rp) :: dp0r,dp1r,dp2r,dp0mr,dp1mr,dp2mr
 real(kind=rp) :: dp0t,dp1t,dp2t,dp0mt,dp1mt,dp2mt
 real(kind=rp) :: omx,omy
 real(kind=rp) :: x2,x3,x4,x5,y2,y3,y4,y5,omx2,omx3,omx4,omx5,omy2,omy3,omy4,omy5

 Ye = rp1

 rhos = rho*Ye

 ih = int((log10(rhos)-log10(pig_rho(1)))/pig_drho) + 1
 jh = int((log10(T)-log10(pig_T(1)))/pig_dT) + 1

 tmp = pig_rho(ih)
 drho = pig_rho(ih+1)-tmp
 x = (rhos-tmp)/drho
 omx = rp1-x

 tmp = pig_T(jh)
 dT = pig_T(jh+1)-tmp
 y = (T-tmp)/dT
 omy = rp1-y

 drho2 = drho*drho
 dT2 = dT*dT

 idrho = rp1/drho
 idrho2 = idrho*idrho

 idT = rp1/dT
 idT2 = idT*idT

 loc_eos1 = pig_table_var(1,ih,jh)
 loc_eos2 = pig_table_var(1,ih+1,jh)
 loc_eos3 = pig_table_var(1,ih,jh+1)
 loc_eos4 = pig_table_var(1,ih+1,jh+1)
 loc_eos5 = pig_table_var(2,ih,jh)
 loc_eos6 = pig_table_var(2,ih+1,jh)
 loc_eos7 = pig_table_var(2,ih,jh+1)
 loc_eos8 = pig_table_var(2,ih+1,jh+1)
 loc_eos9 = pig_table_var(3,ih,jh)
 loc_eos10 = pig_table_var(3,ih+1,jh)
 loc_eos11 = pig_table_var(3,ih,jh+1)
 loc_eos12 = pig_table_var(3,ih+1,jh+1)
 loc_eos13 = pig_table_var(4,ih,jh)
 loc_eos14 = pig_table_var(4,ih+1,jh)
 loc_eos15 = pig_table_var(4,ih,jh+1)
 loc_eos16 = pig_table_var(4,ih+1,jh+1)
 loc_eos17 = pig_table_var(5,ih,jh)
 loc_eos18 = pig_table_var(5,ih+1,jh)
 loc_eos19 = pig_table_var(5,ih,jh+1)
 loc_eos20 = pig_table_var(5,ih+1,jh+1)
 loc_eos21 = pig_table_var(6,ih,jh)
 loc_eos22 = pig_table_var(6,ih+1,jh)
 loc_eos23 = pig_table_var(6,ih,jh+1)
 loc_eos24 = pig_table_var(6,ih+1,jh+1)
 loc_eos25 = pig_table_var(7,ih,jh)
 loc_eos26 = pig_table_var(7,ih+1,jh)
 loc_eos27 = pig_table_var(7,ih,jh+1)
 loc_eos28 = pig_table_var(7,ih+1,jh+1)
 loc_eos29 = pig_table_var(8,ih,jh)
 loc_eos30 = pig_table_var(8,ih+1,jh)
 loc_eos31 = pig_table_var(8,ih,jh+1)
 loc_eos32 = pig_table_var(8,ih+1,jh+1)
 loc_eos33 = pig_table_var(9,ih,jh)
 loc_eos34 = pig_table_var(9,ih+1,jh)
 loc_eos35 = pig_table_var(9,ih,jh+1)
 loc_eos36 = pig_table_var(9,ih+1,jh+1)

 x2 = x*x
 x3 = x2*x
 x4 = x3*x
 x5 = x4*x
 p0r = -rp6*x5 + rp15*x4 - rp10*x3 + rp1
 p1r = (-rp3*x5 + rp8*x4 - rp6*x3 + x)*drho
 p2r = (rph*(-x5 + rp3*x4 - rp3*x3 + x2))*drho2

 omx2 = omx*omx
 omx3 = omx2*omx
 omx4 = omx3*omx
 omx5 = omx4*omx
 p0mr = -rp6*omx5 + rp15*omx4 - rp10*omx3 + rp1
 p1mr =  (rp3*omx5 - rp8*omx4 + rp6*omx3 - omx)*drho
 p2mr =  (rph*(-omx5 + rp3*omx4 - rp3*omx3 + omx2))*drho2

 y2 = y*y
 y3 = y2*y
 y4 = y3*y
 y5 = y4*y
 p0t = -rp6*y5 + rp15*y4 - rp10*y3 + rp1
 p1t = (-rp3*y5 + rp8*y4 - rp6*y3 + y)*dT
 p2t = (rph*(-y5 + rp3*y4 - rp3*y3 + y2))*dT2

 omy2 = omy*omy
 omy3 = omy2*omy
 omy4 = omy3*omy
 omy5 = omy4*omy
 p0mt = -rp6*omy5 + rp15*omy4 - rp10*omy3 + rp1
 p1mt =  (rp3*omy5 - rp8*omy4 + rp6*omy3 - omy)*dT
 p2mt =  (rph*(-omy5 + rp3*omy4 - rp3*omy3 + omy2))*dT2

 dp0r =  (-rp30*x4 + rp60*x3 - rp30*x2)*idrho
 dp1r =  (-rp15*x4 + rp32*x3 - rp18*x2 + rp1)
 dp2r =  (rph*(-rp5*x4 + rp12*x3 - rp9*x2 + rp2*x))*drho

 dp0mr = -(-rp30*omx4 + rp60*omx3 - rp30*omx2)*idrho
 dp1mr =  (-rp15*omx4 + rp32*omx3 - rp18*omx2 + rp1)
 dp2mr = -(rph*(-rp5*omx4 + rp12*omx3 - rp9*omx2 + rp2*omx))*drho

 df_drho = &
 loc_eos1*dp0r*p0t + &
 loc_eos2*dp0mr*p0t + &
 loc_eos3*dp0r*p0mt + &
 loc_eos4*dp0mr*p0mt + &
 loc_eos5*dp0r*p1t + &
 loc_eos6*dp0mr*p1t + &
 loc_eos7*dp0r*p1mt + &
 loc_eos8*dp0mr*p1mt + &
 loc_eos9*dp0r*p2t + &
 loc_eos10*dp0mr*p2t + &
 loc_eos11*dp0r*p2mt + &
 loc_eos12*dp0mr*p2mt + &
 loc_eos13*dp1r*p0t + &
 loc_eos14*dp1mr*p0t + &
 loc_eos15*dp1r*p0mt + &
 loc_eos16*dp1mr*p0mt + &
 loc_eos17*dp2r*p0t + &
 loc_eos18*dp2mr*p0t + &
 loc_eos19*dp2r*p0mt + &
 loc_eos20*dp2mr*p0mt + &
 loc_eos21*dp1r*p1t + &
 loc_eos22*dp1mr*p1t + &
 loc_eos23*dp1r*p1mt + &
 loc_eos24*dp1mr*p1mt + &
 loc_eos25*dp2r*p1t + &
 loc_eos26*dp2mr*p1t + &
 loc_eos27*dp2r*p1mt + &
 loc_eos28*dp2mr*p1mt + &
 loc_eos29*dp1r*p2t + &
 loc_eos30*dp1mr*p2t + &
 loc_eos31*dp1r*p2mt + &
 loc_eos32*dp1mr*p2mt + &
 loc_eos33*dp2r*p2t + &
 loc_eos34*dp2mr*p2t + &
 loc_eos35*dp2r*p2mt + &
 loc_eos36*dp2mr*p2mt

 dp0t =  (-rp30*y4 + rp60*y3 - rp30*y2)*idT
 dp1t =  (-rp15*y4 + rp32*y3 - rp18*y2 + rp1)
 dp2t =  (rph*(-rp5*y4 + rp12*y3 - rp9*y2 + rp2*y))*dT

 dp0mt = -(-rp30*omy4 + rp60*omy3 - rp30*omy2)*idT
 dp1mt =  (-rp15*omy4 + rp32*omy3 - rp18*omy2 + rp1)
 dp2mt = -(rph*(-rp5*omy4 + rp12*omy3 - rp9*omy2 + rp2*omy))*dT

 df_drhodT = rp0

 if(return_dP_dT) then

 df_drhodT = &
 loc_eos1*dp0r*dp0t + &
 loc_eos2*dp0mr*dp0t + &
 loc_eos3*dp0r*dp0mt + &
 loc_eos4*dp0mr*dp0mt + &
 loc_eos5*dp0r*dp1t + &
 loc_eos6*dp0mr*dp1t + &
 loc_eos7*dp0r*dp1mt + &
 loc_eos8*dp0mr*dp1mt + &
 loc_eos9*dp0r*dp2t + &
 loc_eos10*dp0mr*dp2t + &
 loc_eos11*dp0r*dp2mt + &
 loc_eos12*dp0mr*dp2mt + &
 loc_eos13*dp1r*dp0t + &
 loc_eos14*dp1mr*dp0t + &
 loc_eos15*dp1r*dp0mt + &
 loc_eos16*dp1mr*dp0mt + &
 loc_eos17*dp2r*dp0t + &
 loc_eos18*dp2mr*dp0t + &
 loc_eos19*dp2r*dp0mt + &
 loc_eos20*dp2mr*dp0mt + &
 loc_eos21*dp1r*dp1t + &
 loc_eos22*dp1mr*dp1t + &
 loc_eos23*dp1r*dp1mt + &
 loc_eos24*dp1mr*dp1mt + &
 loc_eos25*dp2r*dp1t + &
 loc_eos26*dp2mr*dp1t + &
 loc_eos27*dp2r*dp1mt + &
 loc_eos28*dp2mr*dp1mt + &
 loc_eos29*dp1r*dp2t + &
 loc_eos30*dp1mr*dp2t + &
 loc_eos31*dp1r*dp2mt + &
 loc_eos32*dp1mr*dp2mt + &
 loc_eos33*dp2r*dp2t + &
 loc_eos34*dp2mr*dp2t + &
 loc_eos35*dp2r*dp2mt + &
 loc_eos36*dp2mr*dp2mt

 endif

 tmp = rhos*rhos
 P = tmp*df_drho
 dP_dT = tmp*df_drhodT

 T2 = T*T
 T3 = T2*T
 T4 = T3*T

 P = P + CONST_RAD*T4*othird
 dP_dT = dP_dT + fthirds*CONST_RAD*T3

 end subroutine pig_rhoT_given1

 subroutine pig_rhoT_given2(rho,T,E,dE_dT,return_dE_dT)
 real(kind=rp), intent(in) :: rho,T
 real(kind=rp), intent(inout) :: E,dE_dT
 logical, intent(in) :: return_dE_dT

 real(kind=rp) :: &
 loc_eos1, &
 loc_eos2, &
 loc_eos3, &
 loc_eos4, &
 loc_eos5, &
 loc_eos6, &
 loc_eos7, &
 loc_eos8, &
 loc_eos9, &
 loc_eos10, &
 loc_eos11, &
 loc_eos12, &
 loc_eos13, &
 loc_eos14, &
 loc_eos15, &
 loc_eos16, &
 loc_eos17, &
 loc_eos18, &
 loc_eos19, &
 loc_eos20, &
 loc_eos21, &
 loc_eos22, &
 loc_eos23, &
 loc_eos24, &
 loc_eos25, &
 loc_eos26, &
 loc_eos27, &
 loc_eos28, &
 loc_eos29, &
 loc_eos30, &
 loc_eos31, &
 loc_eos32, &
 loc_eos33, &
 loc_eos34, &
 loc_eos35, &
 loc_eos36

 integer :: ih,jh

 real(kind=rp) :: df_dT,df_dT2
 real(kind=rp) :: f,s,ds_dT
 real(kind=rp) :: Ye,T2,T3,T4,rhos

 real(kind=rp) :: x,y,drho,drho2,dT,dT2,tmp
 real(kind=rp) :: p0r,p0t,p0mr,p0mt,p1r,p1t,p1mr,p1mt,p2r,p2t,p2mr,p2mt,idrho,idrho2,idT,idT2
 real(kind=rp) :: dp0t,dp1t,dp2t,dp0mt,dp1mt,dp2mt
 real(kind=rp) :: ddp0t,ddp1t,ddp2t,ddp0mt,ddp1mt,ddp2mt
 real(kind=rp) :: omx,omy
 real(kind=rp) :: x2,x3,x4,x5,y2,y3,y4,y5,omx2,omx3,omx4,omx5,omy2,omy3,omy4,omy5

 Ye = rp1
 rhos = rho*Ye

 ih = int((log10(rhos)-log10(pig_rho(1)))/pig_drho) + 1
 jh = int((log10(T)-log10(pig_T(1)))/pig_dT) + 1

 tmp = pig_rho(ih)
 drho = pig_rho(ih+1)-tmp
 x = (rhos-tmp)/drho
 omx = rp1-x

 tmp = pig_T(jh)
 dT = pig_T(jh+1)-tmp
 y = (T-tmp)/dT
 omy = rp1-y

 drho2 = drho*drho
 dT2 = dT*dT

 idrho = rp1/drho
 idrho2 = idrho*idrho

 idT = rp1/dT
 idT2 = idT*idT

 loc_eos1 = pig_table_var(1,ih,jh)
 loc_eos2 = pig_table_var(1,ih+1,jh)
 loc_eos3 = pig_table_var(1,ih,jh+1)
 loc_eos4 = pig_table_var(1,ih+1,jh+1)
 loc_eos5 = pig_table_var(2,ih,jh)
 loc_eos6 = pig_table_var(2,ih+1,jh)
 loc_eos7 = pig_table_var(2,ih,jh+1)
 loc_eos8 = pig_table_var(2,ih+1,jh+1)
 loc_eos9 = pig_table_var(3,ih,jh)
 loc_eos10 = pig_table_var(3,ih+1,jh)
 loc_eos11 = pig_table_var(3,ih,jh+1)
 loc_eos12 = pig_table_var(3,ih+1,jh+1)
 loc_eos13 = pig_table_var(4,ih,jh)
 loc_eos14 = pig_table_var(4,ih+1,jh)
 loc_eos15 = pig_table_var(4,ih,jh+1)
 loc_eos16 = pig_table_var(4,ih+1,jh+1)
 loc_eos17 = pig_table_var(5,ih,jh)
 loc_eos18 = pig_table_var(5,ih+1,jh)
 loc_eos19 = pig_table_var(5,ih,jh+1)
 loc_eos20 = pig_table_var(5,ih+1,jh+1)
 loc_eos21 = pig_table_var(6,ih,jh)
 loc_eos22 = pig_table_var(6,ih+1,jh)
 loc_eos23 = pig_table_var(6,ih,jh+1)
 loc_eos24 = pig_table_var(6,ih+1,jh+1)
 loc_eos25 = pig_table_var(7,ih,jh)
 loc_eos26 = pig_table_var(7,ih+1,jh)
 loc_eos27 = pig_table_var(7,ih,jh+1)
 loc_eos28 = pig_table_var(7,ih+1,jh+1)
 loc_eos29 = pig_table_var(8,ih,jh)
 loc_eos30 = pig_table_var(8,ih+1,jh)
 loc_eos31 = pig_table_var(8,ih,jh+1)
 loc_eos32 = pig_table_var(8,ih+1,jh+1)
 loc_eos33 = pig_table_var(9,ih,jh)
 loc_eos34 = pig_table_var(9,ih+1,jh)
 loc_eos35 = pig_table_var(9,ih,jh+1)
 loc_eos36 = pig_table_var(9,ih+1,jh+1)

 x2 = x*x
 x3 = x2*x
 x4 = x3*x
 x5 = x4*x
 p0r = -rp6*x5 + rp15*x4 - rp10*x3 + rp1
 p1r = (-rp3*x5 + rp8*x4 - rp6*x3 + x)*drho
 p2r = ( rph*(-x5 + rp3*x4 - rp3*x3 + x2))*drho2

 omx2 = omx*omx
 omx3 = omx2*omx
 omx4 = omx3*omx
 omx5 = omx4*omx
 p0mr = -rp6*omx5 + rp15*omx4 - rp10*omx3 + rp1
 p1mr =  (rp3*omx5 - rp8*omx4 + rp6*omx3 - omx)*drho
 p2mr =  (rph*(-omx5 + rp3*omx4 - rp3*omx3 + omx2))*drho2

 y2 = y*y
 y3 = y2*y
 y4 = y3*y
 y5 = y4*y
 p0t = -rp6*y5 + rp15*y4 - rp10*y3 + rp1
 p1t = (-rp3*y5 + rp8*y4 - rp6*y3 + y)*dT
 p2t = ( rph*(-y5 + rp3*y4 - rp3*y3 + y2))*dT2

 omy2 = omy*omy
 omy3 = omy2*omy
 omy4 = omy3*omy
 omy5 = omy4*omy
 p0mt = -rp6*omy5 + rp15*omy4 - rp10*omy3 + rp1
 p1mt =  (rp3*omy5 - rp8*omy4 + rp6*omy3 - omy)*dT
 p2mt =  (rph*(-omy5 + rp3*omy4 - rp3*omy3 + omy2))*dT2

 f = &
 loc_eos1*p0r*p0t + &
 loc_eos2*p0mr*p0t + &
 loc_eos3*p0r*p0mt + &
 loc_eos4*p0mr*p0mt + &
 loc_eos5*p0r*p1t + &
 loc_eos6*p0mr*p1t + &
 loc_eos7*p0r*p1mt + &
 loc_eos8*p0mr*p1mt + &
 loc_eos9*p0r*p2t + &
 loc_eos10*p0mr*p2t + &
 loc_eos11*p0r*p2mt + &
 loc_eos12*p0mr*p2mt + &
 loc_eos13*p1r*p0t + &
 loc_eos14*p1mr*p0t + &
 loc_eos15*p1r*p0mt + &
 loc_eos16*p1mr*p0mt + &
 loc_eos17*p2r*p0t + &
 loc_eos18*p2mr*p0t + &
 loc_eos19*p2r*p0mt + &
 loc_eos20*p2mr*p0mt + &
 loc_eos21*p1r*p1t + &
 loc_eos22*p1mr*p1t + &
 loc_eos23*p1r*p1mt + &
 loc_eos24*p1mr*p1mt + &
 loc_eos25*p2r*p1t + &
 loc_eos26*p2mr*p1t + &
 loc_eos27*p2r*p1mt + &
 loc_eos28*p2mr*p1mt + &
 loc_eos29*p1r*p2t + &
 loc_eos30*p1mr*p2t + &
 loc_eos31*p1r*p2mt + &
 loc_eos32*p1mr*p2mt + &
 loc_eos33*p2r*p2t + &
 loc_eos34*p2mr*p2t + &
 loc_eos35*p2r*p2mt + &
 loc_eos36*p2mr*p2mt

 dp0t =  (-rp30*y4 + rp60*y3 - rp30*y2)*idT
 dp1t =  (-rp15*y4 + rp32*y3 - rp18*y2 + rp1)
 dp2t =  (rph*(-rp5*y4 + rp12*y3 - rp9*y2 + rp2*y))*dT

 dp0mt = -(-rp30*omy4 + rp60*omy3 - rp30*omy2)*idT
 dp1mt =  (-rp15*omy4 + rp32*omy3 - rp18*omy2 + rp1)
 dp2mt = -(rph*(-rp5*omy4 + rp12*omy3 - rp9*omy2 + rp2*omy))*dT

 df_dT = &
 loc_eos1*p0r*dp0t + &
 loc_eos2*p0mr*dp0t + &
 loc_eos3*p0r*dp0mt + &
 loc_eos4*p0mr*dp0mt + &
 loc_eos5*p0r*dp1t + &
 loc_eos6*p0mr*dp1t + &
 loc_eos7*p0r*dp1mt + &
 loc_eos8*p0mr*dp1mt + &
 loc_eos9*p0r*dp2t + &
 loc_eos10*p0mr*dp2t + &
 loc_eos11*p0r*dp2mt + &
 loc_eos12*p0mr*dp2mt + &
 loc_eos13*p1r*dp0t + &
 loc_eos14*p1mr*dp0t + &
 loc_eos15*p1r*dp0mt + &
 loc_eos16*p1mr*dp0mt + &
 loc_eos17*p2r*dp0t + &
 loc_eos18*p2mr*dp0t + &
 loc_eos19*p2r*dp0mt + &
 loc_eos20*p2mr*dp0mt + &
 loc_eos21*p1r*dp1t + &
 loc_eos22*p1mr*dp1t + &
 loc_eos23*p1r*dp1mt + &
 loc_eos24*p1mr*dp1mt + &
 loc_eos25*p2r*dp1t + &
 loc_eos26*p2mr*dp1t + &
 loc_eos27*p2r*dp1mt + &
 loc_eos28*p2mr*dp1mt + &
 loc_eos29*p1r*dp2t + &
 loc_eos30*p1mr*dp2t + &
 loc_eos31*p1r*dp2mt + &
 loc_eos32*p1mr*dp2mt + &
 loc_eos33*p2r*dp2t + &
 loc_eos34*p2mr*dp2t + &
 loc_eos35*p2r*dp2mt + &
 loc_eos36*p2mr*dp2mt

 df_dT2 = rp0

 if(return_dE_dT) then

 ddp0t =  (-rp120*y3 + rp180*y2 - rp60*y)*idT2
 ddp1t =  (-rp60*y3 + rp96*y2 - rp36*y)*idT
 ddp2t =  (rph*(-rp20*y3 + rp36*y2 - rp18*y + rp2))

 ddp0mt =  (-rp120*omy3 + rp180*omy2 - rp60*omy)*idT2
 ddp1mt = -(-rp60*omy3 + rp96*omy2 - rp36*omy)*idT
 ddp2mt =  (rph*(-rp20*omy3 + rp36*omy2 - rp18*omy + rp2))

 df_dT2 = &
 loc_eos1*p0r*ddp0t + &
 loc_eos2*p0mr*ddp0t + &
 loc_eos3*p0r*ddp0mt + &
 loc_eos4*p0mr*ddp0mt + &
 loc_eos5*p0r*ddp1t + &
 loc_eos6*p0mr*ddp1t + &
 loc_eos7*p0r*ddp1mt + &
 loc_eos8*p0mr*ddp1mt + &
 loc_eos9*p0r*ddp2t + &
 loc_eos10*p0mr*ddp2t + &
 loc_eos11*p0r*ddp2mt + &
 loc_eos12*p0mr*ddp2mt + &
 loc_eos13*p1r*ddp0t + &
 loc_eos14*p1mr*ddp0t + &
 loc_eos15*p1r*ddp0mt + &
 loc_eos16*p1mr*ddp0mt + &
 loc_eos17*p2r*ddp0t + &
 loc_eos18*p2mr*ddp0t + &
 loc_eos19*p2r*ddp0mt + &
 loc_eos20*p2mr*ddp0mt + &
 loc_eos21*p1r*ddp1t + &
 loc_eos22*p1mr*ddp1t + &
 loc_eos23*p1r*ddp1mt + &
 loc_eos24*p1mr*ddp1mt + &
 loc_eos25*p2r*ddp1t + &
 loc_eos26*p2mr*ddp1t + &
 loc_eos27*p2r*ddp1mt + &
 loc_eos28*p2mr*ddp1mt + &
 loc_eos29*p1r*ddp2t + &
 loc_eos30*p1mr*ddp2t + &
 loc_eos31*p1r*ddp2mt + &
 loc_eos32*p1mr*ddp2mt + &
 loc_eos33*p2r*ddp2t + &
 loc_eos34*p2mr*ddp2t + &
 loc_eos35*p2r*ddp2mt + &
 loc_eos36*p2mr*ddp2mt

 endif

 s = -Ye*df_dT
 ds_dT = -Ye*df_dT2
 E = Ye*f + T*s 
 dE_dT = T*ds_dT

 T2 = T*T
 T3 = T2*T
 T4 = T3*T

 E = E + CONST_RAD*T4/rho
 dE_dT = dE_dT + rp4*CONST_RAD*T3/rho

 end subroutine pig_rhoT_given2

 subroutine pig_rhoP_given(rho,P0,T,E,sound,return_sound)
  real(kind=rp), intent(in) :: rho,P0
  real(kind=rp), intent(inout) :: T,E,sound
  logical, intent(in) :: return_sound

  real(kind=rp) :: error,P,dP_dT,res,dE_dT,cv,Told
  integer :: iter

  sound = rp0
  cv = rp0
  error = rp1

  Told = T

  do iter=1,100

   call pig_rhoT_given1(rho,T,P,dP_dT,.true.)
   res = P-P0
   T = T - res/dP_dT

   error = abs(res/P0)

   if( (T<Tl_eos) .or. (T>Th_eos) ) then
    T = Told
    error = em15
   endif

   if(error<pig_tol) exit

  end do

  if(return_sound) then 
   call pig_rhoT_given_full(rho,T,P,E,sound,cv)
  else    
   call pig_rhoT_given2(rho,T,E,dE_dT,.false.)         
  endif

 end subroutine pig_rhoP_given

 subroutine pig_rhoe_given(rho,E0,T,P,sound,return_sound)
  real(kind=rp), intent(in) :: rho,E0
  real(kind=rp), intent(inout) :: T,P,sound
  logical, intent(in) :: return_sound

  real(kind=rp) :: error,E,dE_dT,res,dP_dT,cv,Told
  integer :: iter

  error = rp1
  cv = rp0
  sound = rp0

  Told = T

  do iter=1,100

   call pig_rhoT_given2(rho,T,E,dE_dT,.true.)
   res = E-E0
   T = T - res/dE_dT

   error = abs(res/E0)

   if( (T<Tl_eos) .or. (T>Th_eos) ) then
    T = Told
    error=em15
   endif

   if(error<pig_tol) exit

  end do

  if(return_sound) then 
   call pig_rhoT_given_full(rho,T,P,E,sound,cv)
  else    
   call pig_rhoT_given1(rho,T,P,dP_dT,.false.)
  endif

 end subroutine pig_rhoe_given

#endif

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! MPI WALL CLOCK TIME
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 function get_wtime(mgrid) result(wct)
   type(mpigrid),intent(inout) :: mgrid
   real(kind=rp) :: wct, tmp(1)
   integer :: ierr

   tmp(1) = real(mpi_wtime(),kind=rp)
   call mpi_bcast(tmp,1,MPI_RP,master_rank,mgrid%comm_cart,ierr)
   wct = tmp(1)

 end function get_wtime

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! USEFUL FUNCTIONS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 character(len=20) function str(k)
   integer, intent(in) :: k
   write (str, *) k
   str = adjustl(str)
 end function str

end module source
