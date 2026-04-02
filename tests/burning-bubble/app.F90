program test
 use source
 implicit none

 type model_t
  real(kind=rp), allocatable :: r(:),grav(:),gpot(:),rho(:),p(:),T(:)
 end type model_t

 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 call setup(mgrid,lgrid)

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)

contains 

subroutine setup(mgrid,lgrid)
 type(mpigrid),intent(inout) :: mgrid
 type(locgrid),intent(inout) :: lgrid


 type(model_t) :: model
 integer :: i,j,k,iv
 real(kind=rp) :: x,y,x0,y0,z0,r
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu

 real(kind=rp) :: L,inv_abar,abar,abar0,zbar,Ye,X_he4,X_c12,fac
 real(kind=rp) :: rho_hse,p_hse,T_hse,T,gpot,grav,rb,e_hse,sound,cv,amp,dummy
 real(kind=rp) :: Xs(2)

 dummy = rp0
 cv = rp0
 sound = rp0
 e_hse = rp0

 call load_model('hotbubble_helm.in',model)

 amp = 1.0e-1_rp

 abar0 = 12.0_rp

 L = 382160789.9505216_rp

 mu = 1.77777777777_rp
 gamma_ad = 5.0_rp/3.0_rp

#ifdef GEOMETRY_CARTESIAN_UNIFORM
 x1l = -L/4.0_rp
 x1u = +L/4.0_rp
 x2l = 0.0_rp
 x2u = L*0.75_rp
 x3l = -L/2.0_rp
 x3u = +L/2.0_rp
#endif

#ifdef GEOMETRY_2D_SPHERICAL
 x1l = 0.1_rp*L
 x1u = L/2.0_rp
 x2l = CONST_PI/4.0_rp
 x2u = 3.0_rp*CONST_PI/4.0_rp
 x3l = -L/2.0_rp
 x3u = +L/2.0_rp
#endif

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)

#ifdef GEOMETRY_CARTESIAN_UNIFORM
 y0 = L/4.0_rp
 x0 = 0.0_rp
#else
 y0 = 0.0_rp
 x0 = L/5.0_rp
#endif
 z0 = 0.0_rp
 rb = L/10.0_rp

#if defined(EVOLVE_ETOT) || defined(USE_WB) 

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)
   do i=mgrid%i1(1),mgrid%i2(1)+1

#ifdef GEOMETRY_CARTESIAN_UNIFORM
     r = lgrid%coords_x1(2,i,j,k)
#else
     r = lgrid%r_x1(i,j,k)
#endif

     call interpolate_model(model,r,grav,gpot,rho_hse,p_hse,T_hse)

     call helm_rhoT_given_full(rho_hse,T_hse,abar0,0.5_rp*abar0,p_hse,e_hse,sound,cv)

#ifdef EVOLVE_ETOT
     lgrid%phi_x1(i,j,k) = gpot
#endif
#ifdef USE_WB
     lgrid%eq_prim_x1(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_x1(ieq_p,i,j,k) = p_hse
#ifdef USE_FASTEOS
     e_hse = rho_hse*e_hse
     lgrid%eq_gammae_x1(i,j,k) = p_hse/e_hse+rp1
#endif
#endif

   end do
  end do
 end do

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)+1
   do i=mgrid%i1(1),mgrid%i2(1)

#ifdef GEOMETRY_CARTESIAN_UNIFORM
     r = lgrid%coords_x2(2,i,j,k)
#else
     r = lgrid%r_x2(i,j,k)
#endif

     call interpolate_model(model,r,grav,gpot,rho_hse,p_hse,T_hse)

     call helm_rhoT_given_full(rho_hse,T_hse,abar0,0.5_rp*abar0,p_hse,e_hse,sound,cv)

#ifdef EVOLVE_ETOT
     lgrid%phi_x2(i,j,k) = gpot
#endif
#ifdef USE_WB
     lgrid%eq_prim_x2(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_x2(ieq_p,i,j,k) = p_hse
#ifdef USE_FASTEOS
     e_hse = rho_hse*e_hse
     lgrid%eq_gammae_x2(i,j,k) = p_hse/e_hse+rp1
#endif
#endif

   end do
  end do
 end do

#endif

 do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
  do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
   do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

     x = lgrid%coords(1,i,j,k)
     y = lgrid%coords(2,i,j,k)

#ifdef GEOMETRY_CARTESIAN_UNIFORM
     r = y
#else
     r = lgrid%r(i,j,k)
#endif

     call interpolate_model(model,r,grav,gpot,rho_hse,p_hse,T_hse)

     call helm_rhoT_given_full(rho_hse,T_hse,abar0,0.5_rp*abar0,p_hse,e_hse,sound,cv)

     r = sqrt((x-x0)**2+(y-y0)**2)/rb

     X_he4 = 0.0_rp
     X_c12 = 1.0_rp
     if(r<=1.0_rp) then
      fac = cos(CONST_PI*r/2.0_rp)**2
      X_he4 = amp*fac
      X_c12 = X_c12 - X_he4
     endif

     Xs(1) = X_he4
     Xs(2) = X_c12

     ye = 0.0_rp
     inv_abar = 0.0_rp
     do iv=1,nspecies
      inv_abar = inv_abar + Xs(iv)/lgrid%A(iv)
      ye = ye + Xs(iv)*lgrid%Z(iv)/lgrid%A(iv)
     end do
     abar = 1.0_rp/inv_abar
     zbar = ye*abar

     lgrid%prim(i_as1,i,j,k) = X_he4
     lgrid%prim(i_as1+1,i,j,k) = X_c12

     T = T_hse

     call helm_rhoP_given(rho_hse,p_hse,abar,zbar,T,dummy,sound,.false.)

     lgrid%temp(i,j,k) = T

     lgrid%prim(i_rho,i,j,k) = rho_hse
     lgrid%prim(i_p,i,j,k) = p_hse
     lgrid%prim(i_vx1,i,j,k) = 0.0_rp
     lgrid%prim(i_vx2,i,j,k) = 0.0_rp

#ifdef GEOMETRY_CARTESIAN_UNIFORM
     lgrid%grav(1,i,j,k) = 0.0_rp
     lgrid%grav(2,i,j,k) = grav
#else
     lgrid%grav(1,i,j,k) = grav
     lgrid%grav(2,i,j,k) = 0.0_rp
#endif

#ifdef EVOLVE_ETOT
     lgrid%phi_cc(i,j,k) = gpot
#endif
#ifdef USE_WB
     lgrid%eq_prim_cc(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_cc(ieq_p,i,j,k) = p_hse
#ifdef USE_FASTEOS
     e_hse = rho_hse*e_hse
     lgrid%eq_gammae_cc(i,j,k) = p_hse/e_hse+rp1
#endif
#endif

   end do
  end do
 end do
 
 call deallocate_model(model)

end subroutine setup

subroutine load_model(filename, m)
  character(len=*), intent(in) :: filename
  type(model_t), intent(inout) :: m
  integer, parameter :: fp=23
  integer :: i, len

  open(unit=fp, file=filename)
  read(fp,*) len
  allocate(m%r(len), m%grav(len), m%gpot(len), m%rho(len), m%p(len), m%T(len))

  do i=1, len
    read(fp, *) m%r(i), m%grav(i), m%gpot(i), m%rho(i), m%p(i), m%T(i)
  end do

  close(fp)

end subroutine load_model

subroutine interpolate_model(m, r, grav, gpot, rho, pres, T)
  type(model_t), intent(in) :: m
  real(kind=rp), intent(in) :: r
  real(kind=rp), intent(out) :: grav, gpot, rho, pres, T

  real(kind=rp) :: fac, rr
  integer :: i

  rr = r

  if (rr < m%r(lbound(m%r,1))) then
    rr = m%r(lbound(m%r,1))
  end if

  if (rr > m%r(ubound(m%r,1))) then
    rr = m%r(ubound(m%r,1))
  end if

  i = minloc(abs(m%r(:) - rr),1)
  if (m%r(i) > rr) i = i - 1
  i = min(max(lbound(m%r,1),i),ubound(m%r,1)-1)

  fac = (rr - m%r(i)) / (m%r(i+1) - m%r(i))
  grav = fac * (m%grav(i+1) - m%grav(i)) + m%grav(i)
  gpot = fac * (m%gpot(i+1) - m%gpot(i)) + m%gpot(i)
  pres = fac * (m%p(i+1) - m%p(i)) + m%p(i)
  rho = fac * (m%rho(i+1) - m%rho(i)) + m%rho(i)
  T = fac * (m%T(i+1) - m%T(i)) + m%T(i)

end subroutine interpolate_model

subroutine deallocate_model(m)
  type(model_t), intent(inout) :: m
  deallocate(m%r, m%grav, m%gpot, m%rho, m%p, m%T)
end subroutine deallocate_model

end program test

#ifdef USE_NUCLEAR_NETWORK 
subroutine extract_network_information(lgrid) 
  use source 
  type(locgrid), intent(inout) :: lgrid 

  lgrid%A(1)=4.0_rp 
  lgrid%A(2)=12.0_rp 

  lgrid%Z(1)=2.0_rp 
  lgrid%Z(2)=6.0_rp 

  lgrid%name_species(1)='he4' 
  lgrid%name_species(2)='c12' 

  lgrid%name_reacs(1)='he4+he4+he4-->c12' 

#ifdef USE_LMP_WEAK_RATES 
 
  allocate(lgrid%weak_table(1:0,1:13,1:11)) 
  allocate(lgrid%weak_neu(1:0,1:13,1:11)) 
  allocate(lgrid%neu_rates(1:0)) 

#endif 

#ifdef PARTITION_FUNCTIONS_FOR_REVERSE_RATES 
 
  lgrid%temp_part(1)=0.1000_rp 
  lgrid%temp_part(2)=0.1500_rp 
  lgrid%temp_part(3)=0.2000_rp 
  lgrid%temp_part(4)=0.3000_rp 
  lgrid%temp_part(5)=0.4000_rp 
  lgrid%temp_part(6)=0.5000_rp 
  lgrid%temp_part(7)=0.6000_rp 
  lgrid%temp_part(8)=0.7000_rp 
  lgrid%temp_part(9)=0.8000_rp 
  lgrid%temp_part(10)=0.9000_rp 
  lgrid%temp_part(11)=1.0000_rp 
  lgrid%temp_part(12)=1.5000_rp 
  lgrid%temp_part(13)=2.0000_rp 
  lgrid%temp_part(14)=2.5000_rp 
  lgrid%temp_part(15)=3.0000_rp 
  lgrid%temp_part(16)=3.5000_rp 
  lgrid%temp_part(17)=4.0000_rp 
  lgrid%temp_part(18)=4.5000_rp 
  lgrid%temp_part(19)=5.0000_rp 
  lgrid%temp_part(20)=6.0000_rp 
  lgrid%temp_part(21)=7.0000_rp 
  lgrid%temp_part(22)=8.0000_rp 
  lgrid%temp_part(23)=9.0000_rp 
  lgrid%temp_part(24)=10.0000_rp 

  allocate(lgrid%part(1:nspecies,1:24)) 

  lgrid%part(1,1)=0.000e+00_rp 
  lgrid%part(1,2)=0.000e+00_rp 
  lgrid%part(1,3)=0.000e+00_rp 
  lgrid%part(1,4)=0.000e+00_rp 
  lgrid%part(1,5)=0.000e+00_rp 
  lgrid%part(1,6)=0.000e+00_rp 
  lgrid%part(1,7)=0.000e+00_rp 
  lgrid%part(1,8)=0.000e+00_rp 
  lgrid%part(1,9)=0.000e+00_rp 
  lgrid%part(1,10)=0.000e+00_rp 
  lgrid%part(1,11)=0.000e+00_rp 
  lgrid%part(1,12)=0.000e+00_rp 
  lgrid%part(1,13)=0.000e+00_rp 
  lgrid%part(1,14)=0.000e+00_rp 
  lgrid%part(1,15)=0.000e+00_rp 
  lgrid%part(1,16)=0.000e+00_rp 
  lgrid%part(1,17)=0.000e+00_rp 
  lgrid%part(1,18)=0.000e+00_rp 
  lgrid%part(1,19)=0.000e+00_rp 
  lgrid%part(1,20)=0.000e+00_rp 
  lgrid%part(1,21)=0.000e+00_rp 
  lgrid%part(1,22)=0.000e+00_rp 
  lgrid%part(1,23)=0.000e+00_rp 
  lgrid%part(1,24)=0.000e+00_rp 

  lgrid%part(2,1)=0.000e+00_rp 
  lgrid%part(2,2)=0.000e+00_rp 
  lgrid%part(2,3)=0.000e+00_rp 
  lgrid%part(2,4)=0.000e+00_rp 
  lgrid%part(2,5)=0.000e+00_rp 
  lgrid%part(2,6)=0.000e+00_rp 
  lgrid%part(2,7)=0.000e+00_rp 
  lgrid%part(2,8)=0.000e+00_rp 
  lgrid%part(2,9)=0.000e+00_rp 
  lgrid%part(2,10)=0.000e+00_rp 
  lgrid%part(2,11)=0.000e+00_rp 
  lgrid%part(2,12)=0.000e+00_rp 
  lgrid%part(2,13)=0.000e+00_rp 
  lgrid%part(2,14)=0.000e+00_rp 
  lgrid%part(2,15)=0.000e+00_rp 
  lgrid%part(2,16)=0.000e+00_rp 
  lgrid%part(2,17)=0.000e+00_rp 
  lgrid%part(2,18)=0.000e+00_rp 
  lgrid%part(2,19)=0.000e+00_rp 
  lgrid%part(2,20)=0.000e+00_rp 
  lgrid%part(2,21)=0.000e+00_rp 
  lgrid%part(2,22)=0.000e+00_rp 
  lgrid%part(2,23)=0.000e+00_rp 
  lgrid%part(2,24)=0.000e+00_rp 

#endif 
 
end subroutine extract_network_information 

subroutine compute_jina_rates(T9,R) 
  use source 
  real(kind=rp), intent(in) :: T9 
  real(kind=rp), dimension(1:nreacs), intent(inout) :: R 

  real(kind=rp) :: logT9,cf,e1,e2,e3,e4,e5,tmp,tmpp 

  logT9 = log(T9) 
  cf = rp1/T9**fvthirds 
  e1 = T9**tthirds 
  e2 = e1*e1 
  e3 = e2*e1
  e4 = e3*e1 
  e5 = e4*e1 
  e1 = e1*cf 
  e2 = e2*cf 
  e3 = e3*cf
  e4 = e4*cf 
  e5 = e5*cf 
  tmp = rp0 
  tmpp = rp0 

  tmp=-2.435050e+01_rp & 
  -4.126560e+00_rp*e1 & 
  -1.349000e+01_rp*e2 & 
  +2.142590e+01_rp*e3 & 
  -1.347690e+00_rp*e4 & 
  +8.798160e-02_rp*e5 & 
  -1.316530e+01_rp*logT9
  R(1)=exp(tmp) 

end subroutine compute_jina_rates 

#ifdef USE_LMP_WEAK_RATES 
subroutine compute_weak_rates(rhoye,T9,dt,weak_table,weak_neu,neu_rates,R) 
  use source 
  real(kind=rp), intent(in) :: rhoye, T9, dt 
  real(kind=rp), dimension(1:0,1:13,1:11), intent(in) :: weak_table 
  real(kind=rp), dimension(1:0,1:13,1:11), intent(in) :: weak_neu 
  real(kind=rp), dimension(1:0), intent(inout) :: neu_rates 
  real(kind=rp), dimension(1:nreacs), intent(inout) :: R 


  real(kind=rp) :: logrhoye,tmp,u,v,omu,omv,omu_omv,u_omv,v_omu,u_v 
  real(kind=rp) :: lam_neu,E_neu_avg 
  integer :: i,idx_logrhoye,idx_T9
 
  logrhoye = log10(rhoye) 
  u = rp0 
  v = rp0 
  idx_T9 = 0 
  idx_logrhoye = 0 

  do i=1,12 
   if((T9>=weak_T9(i)) .and. (T9<weak_T9(i+1))) then 
    idx_T9 = i 
    tmp = weak_T9(i) 
    u = (T9-tmp)/(weak_T9(i+1)-tmp) 
    exit 
   end if 
  end do 

  do i=1,10 
   if((logrhoye>=weak_logrhoye(i)) .and. (logrhoye<weak_logrhoye(i+1))) then 
    idx_logrhoye = i 
    tmp = weak_logrhoye(i) 
    v = (logrhoye-tmp)/(weak_logrhoye(i+1)-tmp) 
    exit 
   end if 
  end do 

  omu=rp1-u 
  omv=rp1-v 
  omu_omv=omu*omv 
  u_omv=u*omv 
  v_omu=v*omu 
  u_v=u*v 

end subroutine compute_weak_rates 

subroutine compute_weak_neuloss(rho,Y,neu_rates,dedt) 
  use source 
  real(kind=rp), intent(in) :: rho 
  real(kind=rp), dimension(1:nspecies), intent(in) :: Y 
  real(kind=rp), dimension(1:0), intent(in) :: neu_rates 
  real(kind=rp), dimension(1:nreacs), intent(inout) :: dedt 

  real(kind=rp) :: fac 

  fac = rho*CONST_NAV_MEV_TO_ERG 

end subroutine compute_weak_neuloss 
#endif 

#ifdef PARTITION_FUNCTIONS_FOR_REVERSE_RATES 
subroutine use_partition_functions(T9,temp_part,part,R) 
  use source 
  real(kind=rp), intent(in) :: T9 
  real(kind=rp), intent(in) :: temp_part(1:24) 
  real(kind=rp), intent(in) :: part(1:nspecies,1:24) 
  real(kind=rp), dimension(1:nreacs), intent(inout) :: R 

  real(kind=rp) :: fac,tmp,tmpp 
  integer :: idx_temp,i 
  real(kind=rp) :: & 
  part1, & 
  part2 
  idx_temp = 1 
  fac = rp1 
  tmp = rp1 
  tmpp = rp1 

  do i=1,23 
   if((T9>=temp_part(i)) .and. (T9<temp_part(i+1))) then 
    idx_temp = i 
    tmp = temp_part(i) 
    fac = (T9-tmp)/(temp_part(i+1)-tmp) 
    exit 
   end if 
  end do 

  part1=rp1 
  part2=rp1 

end subroutine use_partition_functions 
#endif 

#ifdef USE_ELECTRON_SCREENING 
subroutine screen_rates(rho,T,Y,rates) 
  use source 
  real(kind=rp), intent(in) :: T 
  real(kind=rp), intent(in) :: rho 
  real(kind=rp), intent(in) :: Y(1:nspecies) 
  real(kind=rp), intent(inout) :: rates(1:nreacs) 

  real(kind=rp) :: ye,iabar,abar,zbar,Zk,Yk,fw 
  real(kind=rp) :: rhoye,gammap,gammapo4,lngammap,iT,iT3 
  real(kind=rp) :: gammaeff,Z1,Z2,A1,A2,Ahat,Zprod,Zsum 
  real(kind=rp) :: C,zt,jt,tau,b,b3,b4,b5,b6,Hs,Hw,H 
  real(kind=rp) :: Zsum_5_12,Z1_5_12,Z2_5_12 
  real(kind=rp) :: Zsum_5_3,Z1_5_3,Z2_5_3 

  Hw = rp0 
  A1 = rp0 
  A2 = rp0 
  A1 = rp0 
  Ahat = rp0 
  Z1_5_12 = rp0 
  Z2_5_12 = rp0 
  Zsum_5_12 = rp0 
  Z1_5_3 = rp0 
  Z2_5_3 = rp0 
  Zsum_5_3 = rp0 
  zt = rp0 
  jt = rp0 
  C = rp0 
  tau = rp0 
  b = rp0 
  b3 = rp0 
  b4 = rp0 
  b5 = rp0 
  b6 = rp0 
  Hs = rp0 

  ye = rp0 
  iabar = rp0 
  fw = rp0 
  Yk = Y(1) 
  Zk = 2.0_rp 
  ye = ye + Yk*Zk 
  iabar = iabar + Yk 
  fw = fw + Zk*Zk*Yk 
  Yk = Y(2) 
  Zk = 6.0_rp 
  ye = ye + Yk*Zk 
  iabar = iabar + Yk 
  fw = fw + Zk*Zk*Yk 

  abar = rp1/iabar 
  zbar = ye*abar 
  fw = fw + ye 

  iT = rp1/T 
  rhoye = rho*ye 
  gammap = CONST_S1*rhoye**othird*iT 
  gammapo4 = gammap**oquart 
  lngammap = log(gammap) 
  iT3 = iT*iT*iT 
  fw = CONST_S2*sqrt(fw*rho*iT3) 

  Z1 = 2.0_rp 
  Z2 = 2.0_rp 
  Zsum = Z1+Z2 
  Zprod = Z1*Z2 
  gammaeff = (rp2/Zsum)**othird*Zprod*gammap 
  if(gammaeff<0.3_rp) then 
   H = Zprod*fw 
  else if(gammaeff>0.8_rp) then 
   A1 = 4.0_rp 
   A2 = 4.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   H = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
  else 
   Hw = Zprod*fw 
   A1 = 4.0_rp 
   A2 = 4.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   Hs = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
   H = rp2*(0.8_rp-gammaeff)*Hw + rp2*(gammaeff-0.3_rp)*Hs 
  end if 
  rates(1) = rates(1)*exp(H) 

  Z1 = 4.0_rp 
  Z2 = 2.0_rp 
  Zsum = Z1+Z2 
  Zprod = Z1*Z2 
  gammaeff = (rp2/Zsum)**othird*Zprod*gammap 
  if(gammaeff<0.3_rp) then 
   H = Zprod*fw 
  else if(gammaeff>0.8_rp) then 
   A1 = 8.0_rp 
   A2 = 4.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   H = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
  else 
   Hw = Zprod*fw 
   A1 = 8.0_rp 
   A2 = 4.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   Hs = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
   H = rp2*(0.8_rp-gammaeff)*Hw + rp2*(gammaeff-0.3_rp)*Hs 
  end if 
  rates(1) = rates(1)*exp(H) 

end subroutine screen_rates 
#endif 

subroutine compute_network_residuals(Y,rho,R,res,jac,dedt,return_jac,return_dedt) 
  use source 
  real(kind=rp), dimension(1:nspecies), intent(in) :: Y 
  real(kind=rp), intent(in) :: rho 
  real(kind=rp), dimension(1:nreacs), intent(in) :: R 
  real(kind=rp), dimension(1:nspecies), intent(inout) :: res 
  real(kind=rp), dimension(1:nspecies,1:nspecies), intent(inout) :: jac 
  real(kind=rp), dimension(1:nreacs), intent(inout) :: dedt 
  logical, intent(in) :: return_jac 
  logical, intent(in) :: return_dedt 

  real(kind=rp) :: & 
  ye, & 
  lam1, & 
  R1, & 
  Y1, & 
  Y2, & 
  dlam_dY_1_1, & 
  rho2 

  rho2 = rho*rho 
  ye=rp1 

  R1=R(1) 

  Y1=Y(1) 
  Y2=Y(2) 

  lam1=osixth*rho2*Y1*Y1*Y1*R1

  res(1)= & 
  +rp3*lam1

  res(2)= & 
  -lam1

  if(return_jac) then 

   dlam_dY_1_1=rph*rho2*Y1*Y1*R1 

   jac(1,1)= & 
   +rp3*dlam_dY_1_1

   jac(2,1)= & 
   -dlam_dY_1_1

   jac(2,2)=rp0 

  end if 

  if(return_dedt) then 

   dedt(1)=7.019308e+18_rp*lam1*rho 

  end if 

end subroutine compute_network_residuals 
#endif 

#ifdef SAVE_SPECIES_FLUXES 
subroutine species_residuals_per_reac(Y,rho,R,Xds) 
  use source 
  real(kind=rp), dimension(1:nspecies), intent(in) :: Y 
  real(kind=rp), intent(in) :: rho 
  real(kind=rp), dimension(1:nreacs), intent(in) :: R 
  real(kind=rp), dimension(1:nspecies,1:nreacs), intent(inout) :: Xds 

  real(kind=rp) :: & 
  ye, & 
  lam1, & 
  R1, & 
  Y1, & 
  Y2, & 
  rho2 

  rho2 = rho*rho 
  ye=rp1 

  R1=R(1) 

  Y1=Y(1) 
  Y2=Y(2) 

  lam1=osixth*rho2*Y1*Y1*Y1*R1

  Xds(1,1) = -rp3*lam1 
  Xds(2,1) = lam1 

end subroutine species_residuals_per_reac 
#endif 

