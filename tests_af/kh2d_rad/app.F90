program test
 use source
 
 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu
 real(kind=rp) :: x,y,eta,mach0,rho0,vx1,vx2,rhoe0,cs0,T0

#ifdef ADVECT_YE_IABAR
 real(kind=rp) :: Ye0, inv_abar0, Ye_loc, inv_abar_loc
#endif

 gamma_ad = 1.4_rp
#ifdef ADVECT_YE_IABAR
 !Ye0 = 0.45_rp
 Ye0 = 0.5_rp
 !inv_abar0 = 1.0_rp
 inv_abar0 = 0.95_rp
 mu = 1.0_rp/(Ye0 + inv_abar0)
#else
 mu = 1.0_rp
#endif

 mach0 = 0.1_rp
 rho0 = 1.0_rp
 T0 = 1.0e8_rp
 rhoe0 = (rho0*CONST_RGAS*T0)/(mu*(gamma_ad-1.0_rp)) + CONST_RAD*(T0**4)  
 call get_sound_speed(rho0, rhoe0, 0.0_rp, 0.0_rp, gamma_ad, mu, T0, cs0)

 x1l =  0.0_rp*cs0
 x1u =  2.0_rp*cs0
 x2l = -0.5_rp*cs0
 x2u =  0.5_rp*cs0
 x3l =  0.0_rp*cs0
 x3u =  1.0_rp*cs0
 
 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,gamma_ad,mu)

 do j=lbound(lgrid%q_cor,3),ubound(lgrid%q_cor,3)
  do i=lbound(lgrid%q_cor,2),ubound(lgrid%q_cor,2)

     x = lgrid%coords_cor(1,i,j)/cs0
     y = lgrid%coords_cor(2,i,j)/cs0

     if ((y.gt.(-0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(-0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(16.0_rp*CONST_PI*(y+0.25_rp)))
     else if ((y.ge.(-0.25_rp+1.0_rp/32.0_rp)).and.(y.le.(0.25_rp-1.0_rp/32.0_rp))) then
       eta = 1.0_rp
     else if ((y.gt.(0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(-16.0_rp*CONST_PI*(y-0.25_rp)))
     else
       eta = 0.0
     end if

     vx1 = mach0*cs0*(1.0_rp-2.0_rp*eta)
     vx2 = 0.1_rp*mach0*cs0*sin(2.0_rp*CONST_PI*x)

     lgrid%q_cor(i_rhovx1,i,j) = rho0*vx1
     lgrid%q_cor(i_rhovx2,i,j) = rho0*vx2
     lgrid%q_cor(i_rho,i,j) = rho0
     lgrid%q_cor(i_rhoe,i,j) = (rho0*CONST_RGAS*T0)/(mu*(lgrid%gm-1.0_rp)) + CONST_RAD*(T0**4) + 0.5_rp*rho0*(vx1**2+vx2**2)
#ifdef ADVECT_YE_IABAR
     !Ye_loc = Ye0 + 0.05_rp * eta
     inv_abar_loc = inv_abar0 + 0.05_rp * eta 
     lgrid%q_cor(i_rhoye,i,j) = rho0*Ye0
     !lgrid%q_cor(i_rhoiabar,i,j) = rho0*inv_abar0
     !lgrid%q_cor(i_rhoye,i,j) = rho0*Ye_loc
     lgrid%q_cor(i_rhoiabar,i,j) = rho0*inv_abar_loc
#endif

  end do
 end do

 do j=lbound(lgrid%q_x1,3),ubound(lgrid%q_x1,3)
  do i=lbound(lgrid%q_x1,2),ubound(lgrid%q_x1,2)

     x = lgrid%coords_x1(1,i,j)/cs0
     y = lgrid%coords_x1(2,i,j)/cs0

     if ((y.gt.(-0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(-0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(16.0_rp*CONST_PI*(y+0.25_rp)))
     else if ((y.ge.(-0.25_rp+1.0_rp/32.0_rp)).and.(y.le.(0.25_rp-1.0_rp/32.0_rp))) then
       eta = 1.0_rp
     else if ((y.gt.(0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(-16.0_rp*CONST_PI*(y-0.25_rp)))
     else
       eta = 0.0
     end if

     vx1 = mach0*cs0*(1.0_rp-2.0_rp*eta)
     vx2 = 0.1_rp*mach0*cs0*sin(2.0_rp*CONST_PI*x)

     lgrid%q_x1(i_rhovx1,i,j) = rho0*vx1
     lgrid%q_x1(i_rhovx2,i,j) = rho0*vx2
     lgrid%q_x1(i_rho,i,j) = rho0
     lgrid%q_x1(i_rhoe,i,j) = (rho0*CONST_RGAS*T0)/(mu*(lgrid%gm-1.0_rp)) + CONST_RAD*(T0**4) + 0.5_rp*rho0*(vx1**2+vx2**2)

#ifdef ADVECT_YE_IABAR
     !Ye_loc = Ye0 + 0.05_rp * eta
     inv_abar_loc = inv_abar0 + 0.05_rp * eta 
     lgrid%q_x1(i_rhoye,i,j) = rho0*Ye0
     !lgrid%q_x1(i_rhoye,i,j) = rho0*Ye_loc
     !lgrid%q_x1(i_rhoiabar,i,j) = rho0*inv_abar0
     lgrid%q_x1(i_rhoiabar,i,j) = rho0*inv_abar_loc
#endif

  end do
 end do

 do j=lbound(lgrid%q_x2,3),ubound(lgrid%q_x2,3)
  do i=lbound(lgrid%q_x2,2),ubound(lgrid%q_x2,2)

     x = lgrid%coords_x2(1,i,j)/cs0
     y = lgrid%coords_x2(2,i,j)/cs0

     if ((y.gt.(-0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(-0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(16.0_rp*CONST_PI*(y+0.25_rp)))
     else if ((y.ge.(-0.25_rp+1.0_rp/32.0_rp)).and.(y.le.(0.25_rp-1.0_rp/32.0_rp))) then
       eta = 1.0_rp
     else if ((y.gt.(0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(-16.0_rp*CONST_PI*(y-0.25_rp)))
     else
       eta = 0.0
     end if

     vx1 = mach0*cs0*(1.0_rp-2.0_rp*eta)
     vx2 = 0.1_rp*mach0*cs0*sin(2.0_rp*CONST_PI*x)

     lgrid%q_x2(i_rhovx1,i,j) = rho0*vx1
     lgrid%q_x2(i_rhovx2,i,j) = rho0*vx2
     lgrid%q_x2(i_rho,i,j) = rho0
     lgrid%q_x2(i_rhoe,i,j) = (rho0*CONST_RGAS*T0)/(mu*(lgrid%gm-1.0_rp)) + CONST_RAD*(T0**4) + 0.5_rp*rho0*(vx1**2+vx2**2)

#ifdef ADVECT_YE_IABAR
     !Ye_loc = Ye0 + 0.05_rp * eta
     inv_abar_loc = inv_abar0 + 0.05_rp * eta 
     lgrid%q_x2(i_rhoye,i,j) = rho0*Ye0
     !lgrid%q_x2(i_rhoye,i,j) = rho0*Ye_loc
     !lgrid%q_x2(i_rhoiabar,i,j) = rho0*inv_abar0
     lgrid%q_x2(i_rhoiabar,i,j) = rho0*inv_abar_loc
#endif

  end do
 end do

 do j=lbound(lgrid%q_cc,3),ubound(lgrid%q_cc,3)
  do i=lbound(lgrid%q_cc,2),ubound(lgrid%q_cc,2)

     x = lgrid%coords_cc(1,i,j)/cs0
     y = lgrid%coords_cc(2,i,j)/cs0

     if ((y.gt.(-0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(-0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(16.0_rp*CONST_PI*(y+0.25_rp)))
     else if ((y.ge.(-0.25_rp+1.0_rp/32.0_rp)).and.(y.le.(0.25_rp-1.0_rp/32.0_rp))) then
       eta = 1.0_rp
     else if ((y.gt.(0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(-16.0_rp*CONST_PI*(y-0.25_rp)))
     else
       eta = 0.0
     end if

     vx1 = mach0*cs0*(1.0_rp-2.0_rp*eta)
     vx2 = 0.1_rp*mach0*cs0*sin(2.0_rp*CONST_PI*x)

     lgrid%q_cc(i_rhovx1,i,j) = rho0*vx1
     lgrid%q_cc(i_rhovx2,i,j) = rho0*vx2
     lgrid%q_cc(i_rho,i,j) = rho0
     lgrid%q_cc(i_rhoe,i,j) = (rho0*CONST_RGAS*T0)/(mu*(lgrid%gm-1.0_rp)) + CONST_RAD*(T0**4) + 0.5_rp*rho0*(vx1**2+vx2**2)

  end do
 end do

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)

 contains

 subroutine get_sound_speed(rho, rhoe, vx1, vx2, gm, mu, T, cs)
    implicit none

    real(kind=rp), intent(in) :: rho, rhoe, vx1, vx2, gm, mu, T
    real(kind=rp), intent(out) :: cs   
    real(kind=rp) :: T3, T4, gmm1, inv_rho, rhoeint, p
    real(kind=rp) :: P_rho, P_T, Eps_T 

    gmm1 = (gm - 1.0_rp)
    inv_rho = 1.0_rp/rho
    rhoeint = rhoe-0.5_rp*rho*(vx1*vx1+vx2*vx2)

    select case (eos_type) ! eos_type: 0 = ideal gas law, 1 = thermal correction
    
      case (0)

          p = gmm1 * rhoeint
          cs = sqrt(gm*p*inv_rho)

      case (1)

          T3 = T*T*T
          T4 = T3*T
          p = (rho*CONST_RGAS*T/mu) + CONST_RAD*1.0_rp/3.0_rp*T4  
          
          P_rho = CONST_RGAS*T/mu
          P_T = (rho*CONST_RGAS/mu) + CONST_RAD*T3*4.0_rp/3.0_rp
          Eps_T = (CONST_RGAS*rho)/(mu*gmm1) + 4.0_rp*CONST_RAD*T3
          cs = sqrt( P_rho + (P_T**2)*T*(inv_rho)*(1.0_rp/Eps_T) )

      case default
          continue
          
    end select

  end subroutine get_sound_speed

 
end program test
