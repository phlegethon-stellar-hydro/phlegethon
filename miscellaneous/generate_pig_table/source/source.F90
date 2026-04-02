module source
 use mpi

 implicit none

 !===========================
 ! REAL TYPE
 !===========================

#ifdef USE_QUAD_PRECISION
 integer, parameter :: rp = SELECTED_REAL_KIND(p=33, r=4931)  
#endif
#ifdef USE_DOUBLE_PRECISION
 integer, parameter :: rp=8
#endif

 real(kind=rp), parameter :: &
 dlogrho = ((log10_rho_max)-(log10_rho_min))/max(1.0_rp,real(Nrho,kind=rp)), &
 dlogT = ((log10_T_max)-(log10_T_min))/max(1.0_rp,real(NT,kind=rp))

 !===========================
 ! INDEXES
 !===========================

 integer, parameter :: &
 niso = 14, &
 nlev_max = 30, &
 i_h1 = 1, &
 i_he4 = 2, &
 i_c12 = 3, &
 i_n14 = 4, &
 i_o16 = 5, &
 i_ne20 = 6, &
 i_na22 = 7, &
 i_mg24 = 8, &
 i_al27 = 9, &
 i_si28 = 10, &
 i_s32 = 11, &
 i_k39 = 12, &
 i_ca40 = 13, &
 i_fe56 = 14

 integer, parameter :: nvars = 25
 integer, parameter :: fp=23

 integer, parameter :: &
 id_rho = 1, & 
 id_T = 2, &
 id_P = 3, &
 id_E = 4, &
 id_s = 5, &
 id_f = 6, &
 id_dPdrho = 7, &
 id_dEdrho = 8, &
 id_dsdrho = 9, &
 id_dPdT = 10, &
 id_dEdT = 11, &
 id_dsdT = 12, &
 id_dfdrho = 13, &
 id_dfdT = 14, &
 id_d2fdrhodT = 15, &
 id_d2fdrho2 = 16, &
 id_d2fdT2 = 17, &
 id_d3fdrhodT2 = 18, &
 id_d3fdrho2dT = 19, &
 id_d4fdrho2dT2 = 20, &
 id_ne = 21, &
 id_ni = 22, &
 id_dcdrho = 23, &
 id_dcdT = 24, &
 id_d2cdrhodT = 25

 real(kind=rp), save :: Al(niso),Zl(niso),glj(niso,nlev_max),Iplj(niso,nlev_max)
 integer, save :: ns(niso) 
 
 !===========================
 ! CONSTANTS
 !===========================

 real(kind=rp), parameter :: &
 pi = 3.1415926535897932384_rp, &
 Nav = 6.02214199e23, & 
 me = 9.10938188e-28_rp, & 
 mh = 1.6605e-24_rp, &
 h = 6.62606896e-27_rp, & 
 clight = 2.99792458e10_rp, &
 kb = 1.3806504e-16, & 
 sboltz = 5.67040047374e-5, & 
 arad = 4.0*sboltz/clight, &
 ev_to_erg = 1.60218e-12_rp, &
 chi_h1 = 13.59844_rp*ev_to_erg, & 
 chi_h2 = 7.17e-12_rp, &
 theta_rot = 170.64_rp, &
 theta_vib = 5984.48_rp

 !===========================
 ! EOS STRUCTURE
 !===========================

 type teos
  
   real(kind=rp), dimension(nvars) :: var
   real(kind=rp) :: X(niso)

 end type teos

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! MPI UTILS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 type mpigrid

    integer, dimension(3) :: i1,i2,coords_dd,bricks
    logical, dimension(3) :: periodic
    integer :: comm_cart,wsize,rankl,nx1l,nx2l,nx3l
    real(kind=rp) :: wctgi
    real(kind=rp) :: dummy
    real(kind=rp) :: X(niso)

 end type mpigrid

contains

 subroutine get_atomic_data(Al,Zl,glj,Iplj,ns)
 
   real(kind=rp), intent(out) :: Al(niso),Zl(niso),glj(niso,nlev_max),Iplj(niso,nlev_max)
   integer, intent(out) :: ns(niso) 

   !number of ionization stages 
   ns(i_h1) = 1
   ns(i_he4) = 2
   ns(i_c12) = 6
   ns(i_n14) = 7
   ns(i_o16) = 8
   ns(i_ne20) = 10
   ns(i_na22) = 11
   ns(i_mg24) = 12
   ns(i_al27) = 13
   ns(i_si28) = 14
   ns(i_s32) = 16
   ns(i_k39) = 19
   ns(i_ca40) = 20
   ns(i_fe56) = 26

   !mass number
   Al(i_h1) = 1.0_rp
   Al(i_he4) = 4.0_rp
   Al(i_c12) = 12.0_rp
   Al(i_n14) = 14.0_rp
   Al(i_o16) = 16.0_rp
   Al(i_ne20) = 20.0_rp
   Al(i_na22) = 22.0_rp
   Al(i_mg24) = 24.0_rp
   Al(i_al27) = 27.0_rp
   Al(i_si28) = 28.0_rp
   Al(i_s32) = 32.0_rp
   Al(i_k39) = 39.0_rp
   Al(i_ca40) = 40.0_rp
   Al(i_fe56) = 56.0_rp

   !charge number
   Zl(i_h1) = 1.0_rp
   Zl(i_he4) = 2.0_rp
   Zl(i_c12) = 6.0_rp
   Zl(i_n14) = 7.0_rp
   Zl(i_o16) = 8.0_rp
   Zl(i_ne20) = 10.0_rp
   Zl(i_na22) = 11.0_rp
   Zl(i_mg24) = 12.0_rp
   Zl(i_al27) = 13.0_rp
   Zl(i_si28) = 14.0_rp
   Zl(i_s32) = 16.0_rp
   Zl(i_k39) = 19.0_rp
   Zl(i_ca40) = 20.0_rp
   Zl(i_fe56) = 26.0_rp

   !multiplicity of the ground state of every ionized stage (from https://cococubed.com/code_pages/eos_ionize.shtml)
   glj(i_h1,1) = 2.0_rp
   glj(i_h1,2) = 1.0_rp
   
   glj(i_he4,1) = 1.0_rp
   glj(i_he4,2) = 2.0_rp
   glj(i_he4,3) = 1.0_rp

   glj(i_c12,1) = 9.0_rp
   glj(i_c12,2) = 6.0_rp
   glj(i_c12,3) = 1.0_rp
   glj(i_c12,4) = 2.0_rp
   glj(i_c12,5) = 1.0_rp
   glj(i_c12,6) = 2.0_rp
   glj(i_c12,7) = 1.0_rp

   glj(i_n14,1) = 4.0_rp
   glj(i_n14,2) = 9.0_rp
   glj(i_n14,3) = 6.0_rp
   glj(i_n14,4) = 1.0_rp
   glj(i_n14,5) = 2.0_rp
   glj(i_n14,6) = 1.0_rp
   glj(i_n14,7) = 2.0_rp
   glj(i_n14,8) = 1.0_rp

   glj(i_o16,1) = 9.0_rp
   glj(i_o16,2) = 4.0_rp
   glj(i_o16,3) = 9.0_rp
   glj(i_o16,4) = 6.0_rp
   glj(i_o16,5) = 1.0_rp
   glj(i_o16,6) = 2.0_rp
   glj(i_o16,7) = 1.0_rp
   glj(i_o16,8) = 2.0_rp
   glj(i_o16,9) = 1.0_rp

   glj(i_ne20,1) = 1.0_rp
   glj(i_ne20,2) = 6.0_rp
   glj(i_ne20,3) = 9.0_rp
   glj(i_ne20,4) = 4.0_rp
   glj(i_ne20,5) = 9.0_rp
   glj(i_ne20,6) = 6.0_rp
   glj(i_ne20,7) = 1.0_rp
   glj(i_ne20,8) = 2.0_rp
   glj(i_ne20,9) = 1.0_rp
   glj(i_ne20,10) = 2.0_rp
   glj(i_ne20,11) = 1.0_rp

   glj(i_na22,1) = 2.0_rp
   glj(i_na22,2) = 1.0_rp
   glj(i_na22,3) = 6.0_rp
   glj(i_na22,4) = 9.0_rp
   glj(i_na22,5) = 4.0_rp
   glj(i_na22,6) = 9.0_rp
   glj(i_na22,7) = 6.0_rp
   glj(i_na22,8) = 1.0_rp
   glj(i_na22,9) = 2.0_rp
   glj(i_na22,10) = 1.0_rp
   glj(i_na22,11) = 2.0_rp
   glj(i_na22,12) = 1.0_rp

   glj(i_mg24,1) = 1.0_rp
   glj(i_mg24,2) = 2.0_rp
   glj(i_mg24,3) = 1.0_rp
   glj(i_mg24,4) = 6.0_rp
   glj(i_mg24,5) = 9.0_rp
   glj(i_mg24,6) = 4.0_rp
   glj(i_mg24,7) = 9.0_rp
   glj(i_mg24,8) = 6.0_rp
   glj(i_mg24,9) = 1.0_rp
   glj(i_mg24,10) = 2.0_rp
   glj(i_mg24,11) = 1.0_rp
   glj(i_mg24,12) = 2.0_rp
   glj(i_mg24,13) = 1.0_rp

   glj(i_al27,1) = 6.0_rp
   glj(i_al27,2) = 1.0_rp
   glj(i_al27,3) = 2.0_rp
   glj(i_al27,4) = 1.0_rp
   glj(i_al27,5) = 6.0_rp
   glj(i_al27,6) = 9.0_rp
   glj(i_al27,7) = 4.0_rp
   glj(i_al27,8) = 9.0_rp
   glj(i_al27,9) = 6.0_rp
   glj(i_al27,10) = 1.0_rp
   glj(i_al27,11) = 2.0_rp
   glj(i_al27,12) = 1.0_rp
   glj(i_al27,13) = 2.0_rp
   glj(i_al27,14) = 1.0_rp

   glj(i_si28,1) = 9.0_rp
   glj(i_si28,2) = 6.0_rp
   glj(i_si28,3) = 1.0_rp
   glj(i_si28,4) = 2.0_rp
   glj(i_si28,5) = 1.0_rp
   glj(i_si28,6) = 6.0_rp
   glj(i_si28,7) = 9.0_rp
   glj(i_si28,8) = 4.0_rp
   glj(i_si28,9) = 9.0_rp
   glj(i_si28,10) = 6.0_rp
   glj(i_si28,11) = 1.0_rp
   glj(i_si28,12) = 2.0_rp
   glj(i_si28,13) = 1.0_rp
   glj(i_si28,14) = 2.0_rp
   glj(i_si28,15) = 1.0_rp

   glj(i_s32,1) = 9.0_rp
   glj(i_s32,2) = 4.0_rp
   glj(i_s32,3) = 9.0_rp
   glj(i_s32,4) = 6.0_rp
   glj(i_s32,5) = 1.0_rp
   glj(i_s32,6) = 2.0_rp
   glj(i_s32,7) = 1.0_rp
   glj(i_s32,8) = 6.0_rp
   glj(i_s32,9) = 9.0_rp
   glj(i_s32,10) = 4.0_rp
   glj(i_s32,11) = 9.0_rp
   glj(i_s32,12) = 6.0_rp
   glj(i_s32,13) = 1.0_rp
   glj(i_s32,14) = 2.0_rp
   glj(i_s32,15) = 1.0_rp
   glj(i_s32,16) = 2.0_rp
   glj(i_s32,17) = 1.0_rp

   glj(i_k39,1) = 2.0_rp
   glj(i_k39,2) = 1.0_rp
   glj(i_k39,3) = 6.0_rp 
   glj(i_k39,4) = 9.0_rp
   glj(i_k39,5) = 4.0_rp
   glj(i_k39,6) = 9.0_rp
   glj(i_k39,7) = 6.0_rp
   glj(i_k39,8) = 1.0_rp
   glj(i_k39,9) = 2.0_rp
   glj(i_k39,10) = 1.0_rp
   glj(i_k39,11) = 6.0_rp
   glj(i_k39,12) = 9.0_rp
   glj(i_k39,13) = 4.0_rp
   glj(i_k39,14) = 9.0_rp
   glj(i_k39,15) = 6.0_rp
   glj(i_k39,16) = 1.0_rp
   glj(i_k39,17) = 2.0_rp
   glj(i_k39,18) = 1.0_rp
   glj(i_k39,19) = 2.0_rp
   glj(i_k39,20) = 1.0_rp

   glj(i_ca40,1) = 1.0_rp
   glj(i_ca40,2) = 2.0_rp
   glj(i_ca40,3) = 1.0_rp
   glj(i_ca40,4) = 6.0_rp 
   glj(i_ca40,5) = 9.0_rp
   glj(i_ca40,6) = 4.0_rp
   glj(i_ca40,7) = 9.0_rp
   glj(i_ca40,8) = 6.0_rp
   glj(i_ca40,9) = 1.0_rp
   glj(i_ca40,10) = 2.0_rp
   glj(i_ca40,11) = 1.0_rp
   glj(i_ca40,12) = 6.0_rp
   glj(i_ca40,13) = 9.0_rp
   glj(i_ca40,14) = 4.0_rp
   glj(i_ca40,15) = 9.0_rp
   glj(i_ca40,16) = 6.0_rp
   glj(i_ca40,17) = 1.0_rp
   glj(i_ca40,18) = 2.0_rp
   glj(i_ca40,19) = 1.0_rp
   glj(i_ca40,20) = 2.0_rp
   glj(i_ca40,21) = 1.0_rp

   glj(i_fe56,1) = 25.0_rp
   glj(i_fe56,2) = 30.0_rp
   glj(i_fe56,3) = 25.0_rp
   glj(i_fe56,4) = 6.0_rp 
   glj(i_fe56,5) = 25.0_rp
   glj(i_fe56,6) = 28.0_rp
   glj(i_fe56,7) = 21.0_rp
   glj(i_fe56,8) = 10.0_rp
   glj(i_fe56,9) = 1.0_rp
   glj(i_fe56,10) = 6.0_rp
   glj(i_fe56,11) = 9.0_rp
   glj(i_fe56,12) = 2.0_rp
   glj(i_fe56,13) = 9.0_rp
   glj(i_fe56,14) = 2.0_rp
   glj(i_fe56,15) = 1.0_rp
   glj(i_fe56,16) = 2.0_rp
   glj(i_fe56,17) = 1.0_rp
   glj(i_fe56,18) = 2.0_rp
   glj(i_fe56,19) = 1.0_rp
   glj(i_fe56,20) = 2.0_rp
   glj(i_fe56,21) = 1.0_rp
   glj(i_fe56,22) = 2.0_rp
   glj(i_fe56,23) = 1.0_rp
   glj(i_fe56,24) = 2.0_rp
   glj(i_fe56,25) = 1.0_rp
   glj(i_fe56,26) = 2.0_rp
   glj(i_fe56,27) = 1.0_rp

   !ionization potential of every ion (from https://cococubed.com/code_pages/eos_ionize.shtml)
   Iplj(:,:) = 0.0_rp

   Iplj(i_h1,1) = 13.59844_rp*ev_to_erg

   Iplj(i_he4,1) = 24.58741_rp*ev_to_erg   
   Iplj(i_he4,2) = 54.41778_rp*ev_to_erg

   Iplj(i_c12,1) = 11.26030_rp*ev_to_erg
   Iplj(i_c12,2) = 24.38332_rp*ev_to_erg
   Iplj(i_c12,3) = 47.8878_rp*ev_to_erg
   Iplj(i_c12,4) = 64.4939_rp*ev_to_erg
   Iplj(i_c12,5) = 392.087_rp*ev_to_erg
   Iplj(i_c12,6) = 489.99334_rp*ev_to_erg

   Iplj(i_n14,1) = 14.53414_rp*ev_to_erg
   Iplj(i_n14,2) = 29.6013_rp*ev_to_erg
   Iplj(i_n14,3) = 47.44924_rp*ev_to_erg
   Iplj(i_n14,4) = 77.4735_rp*ev_to_erg
   Iplj(i_n14,5) = 97.8902_rp*ev_to_erg
   Iplj(i_n14,6) = 552.0718_rp*ev_to_erg
   Iplj(i_n14,7) = 667.046_rp*ev_to_erg
 
   Iplj(i_o16,1) = 13.61806_rp*ev_to_erg
   Iplj(i_o16,2) = 35.11730_rp*ev_to_erg
   Iplj(i_o16,3) = 54.9355_rp*ev_to_erg
   Iplj(i_o16,4) = 77.41353_rp*ev_to_erg
   Iplj(i_o16,5) = 113.8990_rp*ev_to_erg
   Iplj(i_o16,6) = 138.1197_rp*ev_to_erg
   Iplj(i_o16,7) = 739.29_rp*ev_to_erg
   Iplj(i_o16,8) = 871.4101_rp*ev_to_erg

   Iplj(i_ne20,1)  = 21.5646_rp*ev_to_erg
   Iplj(i_ne20,2)  = 40.96328_rp*ev_to_erg
   Iplj(i_ne20,3)  = 63.45_rp*ev_to_erg
   Iplj(i_ne20,4)  = 97.12_rp*ev_to_erg
   Iplj(i_ne20,5)  = 126.21_rp*ev_to_erg
   Iplj(i_ne20,6)  = 157.93_rp*ev_to_erg
   Iplj(i_ne20,7)  = 207.2759_rp*ev_to_erg
   Iplj(i_ne20,8)  = 239.0989_rp*ev_to_erg
   Iplj(i_ne20,9)  = 1195.8286_rp*ev_to_erg
   Iplj(i_ne20,10) = 1362.1995_rp*ev_to_erg

   Iplj(i_na22,1)  = 5.13908_rp*ev_to_erg
   Iplj(i_na22,2)  = 47.2864_rp*ev_to_erg
   Iplj(i_na22,3)  = 71.62_rp*ev_to_erg
   Iplj(i_na22,4)  = 98.91_rp*ev_to_erg
   Iplj(i_na22,5)  = 138.40_rp*ev_to_erg
   Iplj(i_na22,6)  = 172.18_rp*ev_to_erg
   Iplj(i_na22,7)  = 208.50_rp*ev_to_erg
   Iplj(i_na22,8)  = 264.25_rp*ev_to_erg
   Iplj(i_na22,9)  = 299.864_rp*ev_to_erg
   Iplj(i_na22,10) = 1465.121_rp*ev_to_erg
   Iplj(i_na22,11) = 1648.702_rp*ev_to_erg

   Iplj(i_mg24,1)  = 7.64624_rp*ev_to_erg
   Iplj(i_mg24,2)  = 15.03528_rp*ev_to_erg
   Iplj(i_mg24,3)  = 80.1437_rp*ev_to_erg
   Iplj(i_mg24,4)  = 109.2655_rp*ev_to_erg
   Iplj(i_mg24,5)  = 141.27_rp*ev_to_erg
   Iplj(i_mg24,6)  = 186.76_rp*ev_to_erg
   Iplj(i_mg24,7)  = 225.02_rp*ev_to_erg
   Iplj(i_mg24,8)  = 265.96_rp*ev_to_erg
   Iplj(i_mg24,9)  = 328.06_rp*ev_to_erg
   Iplj(i_mg24,10) = 367.5_rp*ev_to_erg
   Iplj(i_mg24,11) = 1761.805_rp*ev_to_erg
   Iplj(i_mg24,12) = 1962.665_rp*ev_to_erg

   Iplj(i_al27,1)  = 5.98577_rp *ev_to_erg
   Iplj(i_al27,2)  = 18.82856_rp*ev_to_erg
   Iplj(i_al27,3)  = 28.44765_rp*ev_to_erg
   Iplj(i_al27,4)  = 119.992_rp*ev_to_erg
   Iplj(i_al27,5)  = 153.825_rp*ev_to_erg
   Iplj(i_al27,6)  = 190.49_rp*ev_to_erg
   Iplj(i_al27,7)  = 241.76_rp*ev_to_erg
   Iplj(i_al27,8)  = 284.66_rp*ev_to_erg
   Iplj(i_al27,9)  = 330.13_rp*ev_to_erg
   Iplj(i_al27,10) = 398.75_rp*ev_to_erg
   Iplj(i_al27,11) = 442.0_rp*ev_to_erg
   Iplj(i_al27,12) = 2085.98_rp*ev_to_erg
   Iplj(i_al27,13) = 2304.141_rp*ev_to_erg

   Iplj(i_si28,1)  = 8.15169_rp *ev_to_erg
   Iplj(i_si28,2)  = 16.34585_rp*ev_to_erg
   Iplj(i_si28,3)  = 33.49302_rp*ev_to_erg
   Iplj(i_si28,4)  = 45.14181_rp*ev_to_erg
   Iplj(i_si28,5)  = 166.767_rp*ev_to_erg
   Iplj(i_si28,6)  = 205.27_rp*ev_to_erg
   Iplj(i_si28,7)  = 246.5_rp*ev_to_erg
   Iplj(i_si28,8)  = 303.54_rp*ev_to_erg
   Iplj(i_si28,9)  = 351.12_rp*ev_to_erg
   Iplj(i_si28,10) = 401.37_rp*ev_to_erg
   Iplj(i_si28,11) = 476.36_rp*ev_to_erg
   Iplj(i_si28,12) = 523.42_rp*ev_to_erg
   Iplj(i_si28,13) = 2437.63_rp*ev_to_erg
   Iplj(i_si28,14) = 2673.182_rp*ev_to_erg

   Iplj(i_s32,1)   = 10.36001_rp*ev_to_erg
   Iplj(i_s32,2)   = 23.3379_rp*ev_to_erg
   Iplj(i_s32,3)   = 34.79_rp*ev_to_erg
   Iplj(i_s32,4)   = 47.222_rp*ev_to_erg
   Iplj(i_s32,5)   = 72.5945_rp*ev_to_erg
   Iplj(i_s32,6)   = 88.053_rp*ev_to_erg
   Iplj(i_s32,7)   = 280.948_rp*ev_to_erg
   Iplj(i_s32,8)   = 328.75_rp*ev_to_erg
   Iplj(i_s32,9)   = 379.55_rp*ev_to_erg
   Iplj(i_s32,10)  = 447.5_rp*ev_to_erg
   Iplj(i_s32,11)  = 504.8_rp*ev_to_erg
   Iplj(i_s32,12)  = 564.44_rp*ev_to_erg
   Iplj(i_s32,13)  = 652.2_rp*ev_to_erg
   Iplj(i_s32,14)  = 707.01_rp*ev_to_erg
   Iplj(i_s32,15)  = 3223.78_rp*ev_to_erg
   Iplj(i_s32,16)  = 3494.1892_rp*ev_to_erg

   Iplj(i_k39,1)   = 4.34066_rp*ev_to_erg
   Iplj(i_k39,2)   = 31.63_rp*ev_to_erg
   Iplj(i_k39,3)   = 45.806_rp*ev_to_erg
   Iplj(i_k39,4)   = 60.91_rp*ev_to_erg
   Iplj(i_k39,5)   = 82.66_rp*ev_to_erg
   Iplj(i_k39,6)   = 99.4_rp*ev_to_erg
   Iplj(i_k39,7)   = 117.56_rp*ev_to_erg
   Iplj(i_k39,8)   = 154.88_rp*ev_to_erg
   Iplj(i_k39,9)   = 175.8174_rp*ev_to_erg
   Iplj(i_k39,10)  = 503.8_rp*ev_to_erg
   Iplj(i_k39,11)  = 564.7_rp*ev_to_erg
   Iplj(i_k39,12)  = 629.4_rp*ev_to_erg
   Iplj(i_k39,13)  = 714.6_rp*ev_to_erg
   Iplj(i_k39,14)  = 786.6_rp*ev_to_erg
   Iplj(i_k39,15)  = 861.1_rp*ev_to_erg
   Iplj(i_k39,16)  = 968.0_rp*ev_to_erg
   Iplj(i_k39,17)  = 1033.4_rp*ev_to_erg
   Iplj(i_k39,18)  = 4610.8_rp*ev_to_erg
   Iplj(i_k39,19)  = 4934.046_rp*ev_to_erg

   Iplj(i_ca40,1)  = 6.11316_rp*ev_to_erg
   Iplj(i_ca40,2)  = 11.87172_rp*ev_to_erg
   Iplj(i_ca40,3)  = 50.9131_rp*ev_to_erg
   Iplj(i_ca40,4)  = 67.27_rp*ev_to_erg
   Iplj(i_ca40,5)  = 84.5_rp*ev_to_erg
   Iplj(i_ca40,6)  = 108.78_rp*ev_to_erg
   Iplj(i_ca40,7)  = 127.2_rp*ev_to_erg
   Iplj(i_ca40,8)  = 147.24_rp*ev_to_erg
   Iplj(i_ca40,9)  = 188.54_rp*ev_to_erg
   Iplj(i_ca40,10) = 211.275_rp*ev_to_erg
   Iplj(i_ca40,11) = 591.9_rp*ev_to_erg
   Iplj(i_ca40,12) = 657.2_rp*ev_to_erg
   Iplj(i_ca40,13) = 726.6_rp*ev_to_erg
   Iplj(i_ca40,14) = 817.6_rp*ev_to_erg
   Iplj(i_ca40,15) = 894.5_rp*ev_to_erg
   Iplj(i_ca40,16) = 974.0_rp*ev_to_erg
   Iplj(i_ca40,17) = 1087.0_rp*ev_to_erg
   Iplj(i_ca40,18) = 1157.8_rp*ev_to_erg
   Iplj(i_ca40,19) = 5128.8_rp*ev_to_erg
   Iplj(i_ca40,20) = 5469.864_rp*ev_to_erg

   Iplj(i_fe56,1)  = 7.9024_rp*ev_to_erg
   Iplj(i_fe56,2)  = 16.1878_rp*ev_to_erg
   Iplj(i_fe56,3)  = 30.652_rp*ev_to_erg
   Iplj(i_fe56,4)  = 54.8_rp*ev_to_erg
   Iplj(i_fe56,5)  = 75.0_rp*ev_to_erg
   Iplj(i_fe56,6)  = 99.1_rp*ev_to_erg
   Iplj(i_fe56,7)  = 124.98_rp*ev_to_erg
   Iplj(i_fe56,8)  = 151.06_rp*ev_to_erg
   Iplj(i_fe56,9)  = 233.6_rp*ev_to_erg
   Iplj(i_fe56,10) = 262.1_rp*ev_to_erg
   Iplj(i_fe56,11) = 290.2_rp*ev_to_erg
   Iplj(i_fe56,12) = 330.8_rp*ev_to_erg
   Iplj(i_fe56,13) = 361.0_rp*ev_to_erg
   Iplj(i_fe56,14) = 392.2_rp*ev_to_erg
   Iplj(i_fe56,15) = 457.0_rp*ev_to_erg
   Iplj(i_fe56,16) = 489.256_rp*ev_to_erg
   Iplj(i_fe56,17) = 1266.0_rp*ev_to_erg
   Iplj(i_fe56,18) = 1358.0_rp*ev_to_erg
   Iplj(i_fe56,19) = 1456.0_rp*ev_to_erg
   Iplj(i_fe56,20) = 1582.0_rp*ev_to_erg
   Iplj(i_fe56,21) = 1689.0_rp*ev_to_erg
   Iplj(i_fe56,22) = 1799.0_rp*ev_to_erg
   Iplj(i_fe56,23) = 1950.0_rp*ev_to_erg
   Iplj(i_fe56,24) = 2023.0_rp*ev_to_erg
   Iplj(i_fe56,25) = 8828.0_rp*ev_to_erg
   Iplj(i_fe56,26) = 9277.69_rp*ev_to_erg

 end subroutine get_atomic_data 

 subroutine init_mpi(mgrid)
    type(mpigrid), intent(inout) :: mgrid

    integer :: ierr
    logical :: isinitialized,reorder

    mgrid%bricks(1) = ddx1
    mgrid%bricks(2) = ddx2
    mgrid%bricks(3) = 1

    mgrid%nx1l = int(Nrho/ddx1)
    mgrid%nx2l = int(NT/ddx2)
    mgrid%nx3l = 1

    mgrid%periodic(1) = .true.
    mgrid%periodic(2) = .true.
    mgrid%periodic(3) = .true. 

    call mpi_initialized(isinitialized, ierr)
    call mpi_init(ierr)

    reorder = .true.

    call mpi_cart_create(MPI_COMM_WORLD, 2, mgrid%bricks, mgrid%periodic, reorder, mgrid%comm_cart, ierr)
    
    call mpi_comm_rank(mgrid%comm_cart,mgrid%rankl,ierr)
 
    call mpi_comm_size(mgrid%comm_cart,mgrid%wsize,ierr)
    
    mgrid%coords_dd(:) = 0

    call mpi_cart_coords(mgrid%comm_cart,mgrid%rankl,2,mgrid%coords_dd,ierr)
 
    call mpi_barrier(mgrid%comm_cart,ierr)

    mgrid%i1(1) = int(mgrid%coords_dd(1)*mgrid%nx1l+1)
    mgrid%i2(1) = int((mgrid%coords_dd(1)+1)*mgrid%nx1l+1)

    mgrid%i1(2) = int(mgrid%coords_dd(2)*mgrid%nx2l+1)
    mgrid%i2(2) = int((mgrid%coords_dd(2)+1)*mgrid%nx2l+1)

    mgrid%i1(3) = int(mgrid%coords_dd(3)*mgrid%nx3l+1)
    mgrid%i2(3) = int((mgrid%coords_dd(3)+1)*mgrid%nx3l+1)

    call get_atomic_data(Al,Zl,glj,Iplj,ns)

  end subroutine init_mpi

  subroutine create_table_briquette(mgrid,table)
    type(mpigrid), intent(in) :: mgrid
    type(teos), dimension(1:int(Nrho/ddx1+1),1:int(NT/ddx2+1)), intent(inout) :: table 

    integer :: i,j,ic,il,jl,iv
    type(teos), dimension(5,5) :: eos_loc
    real(kind=rp) :: rhoc,Tc,drho,dT,ne
   
    ic = 1
    do j=mgrid%i1(2),mgrid%i2(2)
     do i=mgrid%i1(1),mgrid%i2(1)
      
      rhoc = 10**(log10_rho_min + (i-1.0_rp)*dlogrho)
      Tc = 10**(log10_T_min + (j-1.0_rp)*dlogT)

      ne = -1.0_rp 

      do jl=1,5
       do il=1,5
        eos_loc(il,jl)%var(id_ne) = ne
        eos_loc(il,jl)%var(id_rho) = rhoc*(1.0_rp+(il-3.0_rp)*eps_eta)
        eos_loc(il,jl)%var(id_T) = Tc*(1.0_rp+(jl-3.0_rp)*eps_eta)
        do iv=1,niso
         eos_loc(il,jl)%X(iv) = mgrid%X(iv)
        end do
        call solve(eos_loc(il,jl))
        if((il==1) .and. (jl==1)) then
         ne = eos_loc(il,jl)%var(id_ne)
        end if
       end do
      end do
   
      drho = eps_eta*rhoc
      dT = eps_eta*Tc
      
      !dPdrho
      do jl=1,5
       call Dpx(eos_loc,jl,id_P,id_dPdrho,drho)          
      end do
   
      !dEdrho
      call Dpx(eos_loc,3,id_E,id_dEdrho,drho)          
   
      !dsdrho
      call Dpx(eos_loc,3,id_s,id_dsdrho,drho)          
   
      !dPdT
      call Dpy(eos_loc,3,id_P,id_dPdT,dT)          
   
      !dEdT
      call Dpy(eos_loc,3,id_E,id_dEdT,dT)          
   
      !dsdT
      do il=1,5
       call Dpy(eos_loc,il,id_s,id_dsdT,dT)          
      end do
   
      !dfdrho
      do jl=1,5
       eos_loc(3,jl)%var(id_dfdrho) = eos_loc(3,jl)%var(id_P)/eos_loc(3,jl)%var(id_rho)**2
      end do
   
      !dfdT
      eos_loc(3,3)%var(id_dfdT) = -eos_loc(3,3)%var(id_s)
   
      !d2fdrhodT
      eos_loc(3,3)%var(id_d2fdrhodT) = -eos_loc(3,3)%var(id_dsdrho)
   
      !d2fdrho2
      do jl=1,5
       eos_loc(3,jl)%var(id_d2fdrho2) = eos_loc(3,jl)%var(id_dPdrho)/eos_loc(3,jl)%var(id_rho)**2 - &
       2.0_rp*eos_loc(3,jl)%var(id_P)/eos_loc(3,jl)%var(id_rho)**3
      end do
   
      !d2fdT2
      do il=1,5
       eos_loc(il,3)%var(id_d2fdT2) = -eos_loc(il,3)%var(id_dsdT)
      end do
   
      !d3fdrho2dT=d_dT(d2fdrho2)
      call Dpy(eos_loc,3,id_d2fdrho2,id_d3fdrho2dT,dT)
 
      !d3fdrhodT2=d_drho(d2fdT2)  
      call Dpx(eos_loc,3,id_d2fdT2,id_d3fdrhodT2,drho)
   
      !d4fdrho2dT2=d2_dT(d3fdrho2dT)
      !call Dppx(eos_loc,3,id_d2fdT2,id_d4fdrho2dT2,drho)
    
      !d4fdrho2dT2=d2_dT(d3fdrho2dT)
      call Dppy(eos_loc,3,id_d2fdrho2,id_d4fdrho2dT2,dT)

      !dcdrho=d2Pdrho2
      do jl=1,5
       call Dppx(eos_loc,jl,id_P,id_dcdrho,drho)
      end do

      !dcdT=d2Pdrho2dT 
      call Dpy(eos_loc,3,id_dPdrho,id_dcdT,dT)

      !d2cdrhodT=d3Pdrho2dT 
      call Dpy(eos_loc,3,id_dcdrho,id_d2cdrhodT,dT)


      table(i-mgrid%i1(1)+1,j-mgrid%i1(2)+1) = eos_loc(3,3)

      if(mgrid%rankl==0) then
       write(*,'("advance: ",E9.3," rho=",E9.3," T=",E9.3)') &
       real(ic,kind=rp)/real((Nrho/ddx1+1)*(NT/ddx2+1),kind=rp), rhoc, Tc
      end if

      ic = ic + 1
   
     end do
    end do
   
    call dump_table(table,mgrid)
   
  end subroutine create_table_briquette

  subroutine Dpx(eos_loc,jl,id_in,id_out,hx)
   type(teos), dimension(5,5), intent(inout) :: eos_loc
   integer, intent(in) :: jl,id_in,id_out
   real(kind=rp), intent(in) :: hx

   real(kind=rp) :: fm2,fm1,fp1,fp2

   fm2 = eos_loc(1,jl)%var(id_in)
   fm1 = eos_loc(2,jl)%var(id_in)
   fp1 = eos_loc(4,jl)%var(id_in)
   fp2 = eos_loc(5,jl)%var(id_in)

   eos_loc(3,jl)%var(id_out) = (fm2-8.0_rp*fm1+8.0_rp*fp1-fp2)/(12.0_rp*hx)

  end subroutine Dpx

  subroutine Dppx(eos_loc,jl,id_in,id_out,hx)
   type(teos), dimension(5,5), intent(inout) :: eos_loc
   integer, intent(in) :: jl,id_in,id_out
   real(kind=rp), intent(in) :: hx

   real(kind=rp) :: fm2,fm1,f,fp1,fp2

   fm2 = eos_loc(1,jl)%var(id_in)
   fm1 = eos_loc(2,jl)%var(id_in)
   f   = eos_loc(3,jl)%var(id_in)
   fp1 = eos_loc(4,jl)%var(id_in)
   fp2 = eos_loc(5,jl)%var(id_in)

   eos_loc(3,jl)%var(id_out) = (-fm2+16.0_rp*fm1-30.0_rp*f+16.0_rp*fp1-fp2)/(12.0_rp*hx*hx)

  end subroutine Dppx

  subroutine Dpy(eos_loc,il,id_in,id_out,hy)
   type(teos), dimension(5,5), intent(inout) :: eos_loc
   integer, intent(in) :: il,id_in,id_out
   real(kind=rp), intent(in) :: hy

   real(kind=rp) :: fm2,fm1,fp1,fp2

   fm2 = eos_loc(il,1)%var(id_in)
   fm1 = eos_loc(il,2)%var(id_in)
   fp1 = eos_loc(il,4)%var(id_in)
   fp2 = eos_loc(il,5)%var(id_in)

   eos_loc(il,3)%var(id_out) = (fm2-8.0_rp*fm1+8.0_rp*fp1-fp2)/(12.0_rp*hy)

  end subroutine Dpy

  subroutine Dppy(eos_loc,il,id_in,id_out,hy)
   type(teos), dimension(5,5), intent(inout) :: eos_loc
   integer, intent(in) :: il,id_in,id_out
   real(kind=rp), intent(in) :: hy

   real(kind=rp) :: fm2,fm1,f,fp1,fp2

   fm2 = eos_loc(il,1)%var(id_in)
   fm1 = eos_loc(il,2)%var(id_in)
   f   = eos_loc(il,3)%var(id_in)
   fp1 = eos_loc(il,4)%var(id_in)
   fp2 = eos_loc(il,5)%var(id_in)

   eos_loc(il,3)%var(id_out) = (-fm2+16.0_rp*fm1-30.0_rp*f+16.0_rp*fp1-fp2)/(12.0_rp*hy*hy)

  end subroutine Dppy

  subroutine create_global_table(mgrid,table_glob)
   type(mpigrid), intent(in) :: mgrid
   type(teos), dimension(1:int(Nrho+1),1:int(NT+1)) :: table_glob

   integer :: ierr,i,j,it,jt,iit,jjt,u=13

   character(len=256) :: filename

   call mpi_barrier(mgrid%comm_cart,ierr)

   if(mgrid%rankl==0) then
   
    do j=0,ddx2-1
     do i=0,ddx1-1
 
       write(filename, "('briquette_',I0.3,'x',I0.3,'.dat')") i,j

       open(unit=fp, file=filename)

       do jjt=1,int(NT/ddx2+1)
        do iit=1,int(Nrho/ddx1+1)
 
          it = iit + int(Nrho/ddx1)*i
          jt = jjt + int(NT/ddx2)*j

          read(fp,'(E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14)') &
          table_glob(it,jt)%var(id_f), &
          table_glob(it,jt)%var(id_dfdrho), &
          table_glob(it,jt)%var(id_dfdT), &
          table_glob(it,jt)%var(id_d2fdrho2), &
          table_glob(it,jt)%var(id_d2fdT2), &
          table_glob(it,jt)%var(id_d2fdrhodT), &
          table_glob(it,jt)%var(id_d3fdrho2dT), &
          table_glob(it,jt)%var(id_d3fdrhodT2), &
          table_glob(it,jt)%var(id_d4fdrho2dT2)
 
        end do
       end do
      
       do jjt=1,int(NT/ddx2+1)
        do iit=1,int(Nrho/ddx1+1)

          it = iit + int(Nrho/ddx1)*i
          jt = jjt + int(NT/ddx2)*j

          read(fp,'(E21.14,1X,E21.14,1X,E21.14,1X,E21.14)') &
          table_glob(it,jt)%var(id_dPdrho), &
          table_glob(it,jt)%var(id_dcdrho), &
          table_glob(it,jt)%var(id_dcdT), &
          table_glob(it,jt)%var(id_d2cdrhodT)

        end do
       end do
    
       close(fp)
 
     end do
    end do
   
    write(filename, "('pig_table.dat')")

    open(newunit=u, file=filename, &
    status='replace',action = 'write')

    do j=1,NT+1
     do i=1,Nrho+1
      write(u,'(E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14)') & 
      table_glob(i,j)%var(id_f), &
      table_glob(i,j)%var(id_dfdrho), &
      table_glob(i,j)%var(id_dfdT), &
      table_glob(i,j)%var(id_d2fdrho2), &
      table_glob(i,j)%var(id_d2fdT2), &
      table_glob(i,j)%var(id_d2fdrhodT), &
      table_glob(i,j)%var(id_d3fdrho2dT), &
      table_glob(i,j)%var(id_d3fdrhodT2), &
      table_glob(i,j)%var(id_d4fdrho2dT2)
     end do
    end do

    do j=1,NT+1
     do i=1,Nrho+1
      write(u,'(E21.14,1X,E21.14,1X,E21.14,1X,E21.14)') &
      table_glob(i,j)%var(id_dPdrho), &
      table_glob(i,j)%var(id_dcdrho), &
      table_glob(i,j)%var(id_dcdT), &
      table_glob(i,j)%var(id_d2cdrhodT)
     end do
    end do

    do j=1,NT+1
     do i=1,Nrho+1
      write(u,'(E21.14,1X,E21.14,1X,E21.14,1X,E21.14)') &
      0.0_rp, &
      0.0_rp, &
      0.0_rp, &
      0.0_rp
     end do
    end do

    do j=1,NT+1
     do i=1,Nrho+1
      write(u,'(E21.14,1X,E21.14,1X,E21.14,1X,E21.14)') &
      0.0_rp, &
      0.0_rp, &
      0.0_rp, &
      0.0_rp
     end do
    end do

    close(u)

   end if

  end subroutine create_global_table

  subroutine dump_table(table,mgrid)
   type(teos), dimension(1:int(Nrho/ddx1+1),1:int(NT/ddx2+1)), intent(inout) :: table
   type(mpigrid), intent(in) :: mgrid

   integer :: u=12,i,j
   character(len=256) :: filename

   write(filename, "('briquette_',I0.3,'x',I0.3,'.dat')") mgrid%coords_dd(1),mgrid%coords_dd(2) 

   open(newunit=u,file=filename, &
   status='replace',action = 'write')

   do j=1,int(NT/ddx2+1)
    do i=1,int(Nrho/ddx1+1)
      write(u,'(E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14,1X,E21.14)') & 
      table(i,j)%var(id_f), &
      table(i,j)%var(id_dfdrho), &
      table(i,j)%var(id_dfdT), &
      table(i,j)%var(id_d2fdrho2), &
      table(i,j)%var(id_d2fdT2), &
      table(i,j)%var(id_d2fdrhodT), &
      table(i,j)%var(id_d3fdrho2dT), &
      table(i,j)%var(id_d3fdrhodT2), &
      table(i,j)%var(id_d4fdrho2dT2)
    end do
   end do

   do j=1,int(NT/ddx2+1)
    do i=1,int(Nrho/ddx1+1)
      write(u,'(E21.14,1X,E21.14,1X,E21.14,1X,E21.14)') &
      table(i,j)%var(id_dPdrho), &
      table(i,j)%var(id_dcdrho), &
      table(i,j)%var(id_dcdT), &
      table(i,j)%var(id_d2cdrhodT)
    end do
   end do

   close(u)

  end subroutine dump_table

  subroutine solve(eos)

   type(teos), intent(inout) :: eos

   integer :: iv,ir,jr,cnt

   real(kind=rp) :: nl(niso),nlj(niso,nlev_max)
   integer :: nstages 
   real(kind=rp) :: err1,V0,T,ni,ne,ne0,rho,nkT_logZ,ldb3,res,res0,tmp,log_ne,log_ne0,E0
   real(kind=rp) :: Eb,nh2,Eh2,Zh2

   rho = eos%var(id_rho)
   T = eos%var(id_T)

   Eb = 0.0_rp
   nh2 = 0.0_rp
   Eh2 = 0.0_rp
   Zh2 = 0.0_rp

   !compute ion number density and assume that all matter is ionized at first

   ne0 = 0.0_rp
   ni = 0.0_rp
   do iv=1,niso
    nl(iv) = eos%X(iv)/Al(iv)*rho*Nav
    ni = ni + nl(iv)
    ne0 = ne0 + Zl(iv)*nl(iv)
    nlj(iv,:) = 0.0_rp
    nlj(iv,1) = nl(iv)
   end do 
   eos%var(id_ni) = ni

   if(eos%var(id_ne)>0.0_rp) then
    ne0 = eos%var(id_ne)
   endif
 
   call compute_inz_frac(eos,ne0,nlj,Eb,Eh2,nh2,Zh2)
   res0 = 0.0_rp
   do iv=1,niso
    nstages = ns(iv)+1
    do ir=1,nstages-1 
      res0 = res0 + real(ir,kind=rp)*nlj(iv,ir+1)
    end do
   end do     
   res0 = res0-ne0
 
   ne = 0.9_rp*ne0
 
   call compute_inz_frac(eos,ne,nlj,Eb,Eh2,nh2,Zh2)

   res = 0.0_rp
   do iv=1,niso
    nstages = ns(iv)+1
    do ir=1,nstages-1
      res = res + real(ir,kind=rp)*nlj(iv,ir+1)
    end do
   end do     
   res = res-ne

   !secant method
   log_ne0 = log(ne0)
   log_ne = log(ne)
 
   err1 = 1.0_rp
   
   cnt = 0
   
   do while(err1>thr_ne)
 
     ne = exp(log_ne)
  
     call compute_inz_frac(eos,ne,nlj,Eb,Eh2,nh2,Zh2)
 
     res = 0.0_rp
     do iv=1,niso
      nstages = ns(iv)+1
      do ir=1,nstages-1
       res = res + real(ir,kind=rp)*nlj(iv,ir+1)
      end do
     end do

     res = res-ne
 
     tmp = ne
 
     log_ne = log_ne - res*(log_ne-log_ne0)/(res-res0)
     ne0 = tmp
     log_ne0 = log(ne0)
     res0 = res
 
     ne = exp(log_ne)
 
     cnt = cnt + 1

     if(cnt>1000) then
      err1 = 0.1_rp*thr_ne
      write(*,*) ne/nl(1),nlj(1,1:2)/nl(1),nh2/nl(1)
     else
      err1 = abs(res)/ne
     endif 

   end do

   call compute_inz_frac(eos,ne,nlj,Eb,Eh2,nh2,Zh2)
 
   !thermodynamics of the mixture

   eos%var(id_ne) = ne

   !number density of atoms
   ni = 0.0_rp
   do iv=1,niso
    nstages = ns(iv)+1
    do ir=1,nstages
     ni = ni + nlj(iv,ir)
    end do
   end do 
   eos%var(id_ni) = ni

   !compute pressure
   eos%var(id_P) = (ni+ne)*kb*T

   !compute (kinetic) internal energy
   eos%var(id_E) = 1.5_rp*(ni+ne)*kb*T
 
   nKT_logZ = 0.0_rp

   !compute thermodynamic probability for every ionization state of every isotope
   do iv=1,niso

    nstages = ns(iv)+1 

    !De-Broglie wavelength cubed
    ldb3 = (h*h/(2.0_rp*pi*mh*Al(iv)*kb*T))**(1.5_rp)
  
    do ir=1,nstages-1

     !compute energy of ground state with respect to the continuum
     V0 = 0.0_rp
     do jr=nstages,ir,-1
      V0 = V0 + Iplj(iv,jr)
     end do

     !update energies
     eos%var(id_E) = eos%var(id_E) - &
     nlj(iv,ir)*V0

     if(nlj(iv,ir)>0.0_rp) then 
      nkT_logZ = nkT_logZ + nlj(iv,ir)*(kb*T*log(nlj(iv,ir)*ldb3/glj(iv,ir))-V0)
     end if

    end do

    if(nlj(iv,nstages)>0.0_rp) then
     !include last ionization state     
     nkT_logZ = nkT_logZ + nlj(iv,nstages)*kb*T*log(nlj(iv,nstages)*ldb3/glj(iv,nstages))
    end if

   end do

#ifdef USE_H2
   !compute thermodynamic probability for H2 
   if(nh2>0.0_rp) then

    eos%var(id_E) = eos%var(id_E) + &
    nh2*Eh2
 
    eos%var(id_P) = eos%var(id_P) + nh2*kb*T
  
    !add binding energy separately because of min operation
    nkT_logZ = nkT_logZ + nh2*(kb*T*log(nh2/Zh2)+Eb)

   endif
#endif

   !compute thermodynamic probability for the electrons
   if(ne>0.0_rp) then
    ldb3 = (h*h/(2.0_rp*pi*me*kb*T))**(1.5_rp) 
    nkT_logZ = nkT_logZ + ne*kb*T*log(ne*ldb3/2.0_rp)
   endif

   !compute the 0 energy level
   E0 = 0.0_rp

#ifdef USE_H2
   V0 = 2.0_rp*Iplj(1,1)+7.17e-12_rp
   E0 = 0.5_rp*eos%X(1)*V0
   do iv=2,niso
#else
   do iv=1,niso
#endif
     nstages = ns(iv)
     V0 = 0.0_rp
     do jr=1,nstages
      V0 = V0 + Iplj(iv,jr)
     end do
     E0 = E0 + eos%X(iv)/Al(iv)*V0
   end do

   !compute internal energy, free energy, and entropy per unit mass
   eos%var(id_E) = eos%var(id_E)/rho+E0*Nav
   eos%var(id_f) = (-eos%var(id_P)+nkT_logZ)/rho+E0*Nav
   eos%var(id_s) = (eos%var(id_E)-eos%var(id_f))/T

  end subroutine solve

  subroutine compute_inz_frac(eos,ne,nlj,Eb,Eh2,nh2,Zh2)
   type(teos), intent(in) :: eos
   real(kind=rp), intent(in) :: ne
   real(kind=rp), intent(inout) :: nlj(niso,nlev_max)
   real(kind=rp), intent(inout) :: Eb,Eh2,nh2,Zh2
   
   integer :: iv,ir,jr

   real(kind=rp) :: phij(nlev_max),Pj(nlev_max)
   real(kind=rp) :: nl(niso)
   integer :: nstages 
   real(kind=rp) :: CI,Sl,T,ni,rho,tmp,a1,a2,a3,Zrot,Zh2ext,Zroto,Zrote,dZrotedT,dZrotodT

   a1 = 0.0_rp
   a2 = 0.0_rp
   a3 = 0.0_rp
   Eb = 0.0_rp
   Eh2 = 0.0_rp
   nh2 = 0.0_rp
   Zh2 = 0.0_rp
   Zh2ext = 0.0_rp
   Zrot = 0.0_rp
   Zrote = 0.0_rp
   Zroto = 0.0_rp
   dZrotedT = 0.0_rp
   dZrotodT = 0.0_rp
 
   rho = eos%var(id_rho)
   T = eos%var(id_T)

   CI = 0.5_rp*(h*h/(2.0_rp*pi*me*kb*T))**(1.5_rp)

   !compute ion number density and assume that all matter is ionized at first
   ni = 0.0_rp
   do iv=1,niso
    nl(iv) = eos%X(iv)/Al(iv)*rho*Nav
   enddo 

#ifdef USE_H2 

   if(nl(1)>0.0_rp) then

    !treat hydrogen separately
    Eb = -(2.0_rp*chi_h1+chi_h2)
    Eh2 = Eb + 1.5_rp*kb*T
    Zh2 = 4.0_rp*(2.0_rp*pi*2.0_rp*mh*kb*T/h**2)**1.5_rp

    !vibrational part
    Zh2ext = 1.0_rp/(1.0_rp-exp(-theta_vib/T))
    Eh2 = Eh2 + & 
    kb*theta_vib*exp(-theta_vib/T)/(1.0_rp-exp(-theta_vib/T))
 
    !rotational part
    Zroto = 0.0_rp
    Zrote = 0.0_rp

    dZrotedT = 0.0_rp
    dZrotodT = 0.0_rp

    do ir=0,100,2
     Zrote = Zrote + &
     (2.0_rp*ir+1.0_rp)*exp(-0.5_rp*ir*(ir+1)*theta_rot/T)
    end do

    do ir=0,100,2
     dZrotedT = dZrotedT + &
     (2.0_rp*ir+1.0_rp)*ir*(ir+1.0_rp)*exp(-0.5_rp*ir*(ir+1)*theta_rot/T)
    end do
    dZrotedT = 0.5_rp*dZrotedT*theta_rot

    do ir=1,101,2
     Zroto = Zroto + &
     (2.0_rp*ir+1.0_rp)*exp(-0.5_rp*ir*(ir+1)*theta_rot/T)
    end do

    do ir=1,101,2
     dZrotodT = dZrotodT + &
     (2.0_rp*ir+1.0_rp)*ir*(ir+1.0_rp)*exp(-0.5_rp*ir*(ir+1)*theta_rot/T)
    end do
    dZrotodT = 0.5_rp*dZrotodT*theta_rot

    Zrot = Zrote**(0.25_rp)*(3.0_rp*Zroto*exp(theta_rot/T))**(3.0_rp/4.0_rp)

    Zh2ext = Zh2ext*Zrot 

    Eh2 = Eh2 + kb*0.25_rp*dZrotedT/Zrote + kb*0.75_rp*dZrotodT/Zroto - 0.75_rp*kb*theta_rot
   
    Zh2 = Zh2*Zh2ext

    a1 = (2.0_rp*pi*me*kb*T/h**2)**1.5_rp * &
    exp(-min(chi_h1/(kb*T),250.0_rp))/ne
  
    a2 = (0.5_rp*2.0_rp*pi*mh*kb*T/h**2)**1.5_rp * &
    exp(-min(chi_h2/(kb*T),250.0_rp))/Zh2ext

    a2 = 1.0_rp/a2

    a3 = eos%X(1)*rho*Nav 

    nlj(1,1) = 2.0_rp*a3 / ( &
    sqrt((1.0_rp+a1)*(1.0_rp+a1)+8.0_rp*a3*a2) + &
    (1.0_rp+a1) &
    ) 

    nlj(1,2) = a1*nlj(1,1)

    nh2 =  nlj(1,1)*nlj(1,1)*a2

   else
     
    nlj(1,1) = 0.0_rp
    nlj(1,2) = 0.0_rp
    nh2 = 0.0_rp   

   endif

   !for every isotope in the list except hydrogen
   do iv=2,niso

#else

   !for every isotope in the list 
   do iv=1,niso

#endif

     !compute thermodynamics of the isotope if its abundance is not 0
     if(nl(iv)>0.0_rp) then

       !number of states (ground +  all ionization stages)
       nstages = ns(iv)+1
  
       !Hubeny & Mihalas (Eq. 4.34)

       do ir=1,nstages-1
        tmp = min(Iplj(iv,ir)/(kb*T),250.0_rp)
        phij(ir) = CI*(glj(iv,ir)/glj(iv,ir+1))*exp(tmp) 
       end do
       phij(nstages) = 1.0_rp/ne

       !Hubeny & Mihalas (Eq. 4.36c)
       Sl = 0.0_rp
       do ir=1,nstages
        tmp = 1.0_rp
        do jr=ir,nstages
         tmp = tmp*ne*phij(jr)
        end do
        Sl = Sl+tmp
       end do
       
       !Hubeny & Mihalas (Eq. 4.36c)
       do ir=1,nstages-1
        tmp = 1.0_rp
        do jr=ir,nstages-1
         tmp = tmp*ne*phij(jr)
        end do
        Pj(ir) = tmp
       end do
       Pj(nstages) = 1.0_rp

       !get number density of ionization state j of isotope v
       do ir=1,nstages
        nlj(iv,ir) = Pj(ir)/Sl*nl(iv)
       end do

     else

       nlj(iv,:) = 0.0_rp

     end if

    end do
    
  end subroutine compute_inz_frac

end module source



