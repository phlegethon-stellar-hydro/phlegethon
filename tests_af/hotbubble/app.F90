program test
 use source
 
 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j
 real(kind=rp) :: x,y
 real(kind=rp) :: x1l,x1u,x2l,x2u,gamma_ad,mu

 real(kind=rp) :: p0,temp0,grav0,x0,y0,z0,inv_gamma, &
 A0,ky,intc,intf,p,grav,A,r,r0,rho,rho0,T, phi
        
 real(kind=rp), parameter :: dAbyA = 0.001_rp
 !real(kind=rp), parameter :: CONST_RGAS = 8.31446261815324e7_rp

 x1l = 0.0_rp
 x1u = 1e6_rp
 x2l = 0.0_rp
 x2u = 1.5e6_rp
 gamma_ad = 5.0_rp/3.0_rp
 mu = 1.0_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,gamma_ad,mu)

 p0 = 1e6_rp
 temp0 = 300_rp
 grav0 = -109904.373_rp

 x0 = 5e5_rp
 !x0 = 503906.25_rp
 !x0 = 531250.0_rp


 y0 = 1.875e5_rp
 z0 = 5e5_rp  !check if this is needed
             
 
 rho0 = p0/(CONST_RGAS*temp0) 
 inv_gamma = 1.0_rp/lgrid%gm
 A0 = p0/rho0**lgrid%gm
 ky = 2.0_rp*CONST_PI/x2u
 intc = p0**(1.0_rp-inv_gamma)
 intf = -(1.0_rp-inv_gamma)/A0**inv_gamma*grav0/ky
 r0 = 1.25e5_rp
 T = 0.0_rp


 !---------------------------------------------------------------------------------------------------------------------------------

  ! 1. Cell Centers
  do j=lbound(lgrid%q_cc,3),ubound(lgrid%q_cc,3)
   do i=lbound(lgrid%q_cc,2),ubound(lgrid%q_cc,2)
     x = lgrid%coords_cc(1,i,j)
     y = lgrid%coords_cc(2,i,j)

     grav = grav0*sin(ky*y)

     ! Hydrostatic background pressure
     p = (intc+intf*(cos(ky*y)-1.0_rp))**(1.0_rp/(1.0_rp-inv_gamma))
     
     ! Entropy perturbation
     r = sqrt(((x-x0)**2+(y-y0)**2)/r0**2)
     A = A0
     if(r < 1.0_rp) then
      A = A0*(1.0_rp+dAbyA*cos(0.5_rp*CONST_PI*r)**2)
     endif
     
     ! Resulting density
     rho = (p/A)**inv_gamma

     ! Conserved variables
     lgrid%q_cc(i_rho,i,j)    = rho
     lgrid%q_cc(i_rhovx1,i,j) = 0.0_rp
     lgrid%q_cc(i_rhovx2,i,j) = 0.0_rp

#ifdef EVOLVE_ETOT
     phi = (grav0 / ky) * cos(ky * y)
     lgrid%phi_cc(i,j) = phi 
     lgrid%q_cc(i_rhoe,i,j) = (p / (lgrid%gm - 1.0_rp)) + (rho * phi)
#else
     lgrid%q_cc(i_rhoe,i,j) = p / (lgrid%gm - 1.0_rp)
#endif
     
     lgrid%grav_cc(1,i,j) = 0.0_rp
     lgrid%grav_cc(2,i,j) = grav

   end do
  end do

  ! 2. x1 Faces
  do j=lbound(lgrid%q_x1,3),ubound(lgrid%q_x1,3)
   do i=lbound(lgrid%q_x1,2),ubound(lgrid%q_x1,2)
     x = lgrid%coords_x1(1,i,j)
     y = lgrid%coords_x1(2,i,j)
     grav = grav0*sin(ky*y)

     p = (intc+intf*(cos(ky*y)-1.0_rp))**(1.0_rp/(1.0_rp-inv_gamma))
     
     r = sqrt(((x-x0)**2+(y-y0)**2)/r0**2)
     A = A0
     if(r < 1.0_rp) then
      A = A0*(1.0_rp+dAbyA*cos(0.5_rp*CONST_PI*r)**2)
     endif
     
     rho = (p/A)**inv_gamma

     lgrid%q_x1(i_rho,i,j)    = rho
     lgrid%q_x1(i_rhovx1,i,j) = 0.0_rp
     lgrid%q_x1(i_rhovx2,i,j) = 0.0_rp
     
#ifdef EVOLVE_ETOT
     phi = (grav0 / ky) * cos(ky * y)
     lgrid%phi_x1(i,j) = phi 
     lgrid%q_x1(i_rhoe,i,j) = (p / (lgrid%gm - 1.0_rp)) + (rho * phi)
#else
     lgrid%q_x1(i_rhoe,i,j) = p / (lgrid%gm - 1.0_rp)
#endif

     lgrid%grav_x1(1,i,j) = 0.0_rp
     lgrid%grav_x1(2,i,j) = grav
   end do
  end do

  ! 3. x2 Faces
  do j=lbound(lgrid%q_x2,3),ubound(lgrid%q_x2,3)
   do i=lbound(lgrid%q_x2,2),ubound(lgrid%q_x2,2)
     x = lgrid%coords_x2(1,i,j)
     y = lgrid%coords_x2(2,i,j)
     grav = grav0*sin(ky*y)

     p = (intc+intf*(cos(ky*y)-1.0_rp))**(1.0_rp/(1.0_rp-inv_gamma))
     
     r = sqrt(((x-x0)**2+(y-y0)**2)/r0**2)
     A = A0
     if(r < 1.0_rp) then
      A = A0*(1.0_rp+dAbyA*cos(0.5_rp*CONST_PI*r)**2)
     endif
     
     rho = (p/A)**inv_gamma

     lgrid%q_x2(i_rho,i,j)    = rho
     lgrid%q_x2(i_rhovx1,i,j) = 0.0_rp
     lgrid%q_x2(i_rhovx2,i,j) = 0.0_rp
     
#ifdef EVOLVE_ETOT
     phi = (grav0 / ky) * cos(ky * y)
     lgrid%phi_x2(i,j) = phi 
     lgrid%q_x2(i_rhoe,i,j) = (p / (lgrid%gm - 1.0_rp)) + (rho * phi)
#else
     lgrid%q_x2(i_rhoe,i,j) = p / (lgrid%gm - 1.0_rp)
#endif

     lgrid%grav_x2(1,i,j) = 0.0_rp
     lgrid%grav_x2(2,i,j) = grav
   end do
  end do

  ! 4. Corners
  do j=lbound(lgrid%q_cor,3),ubound(lgrid%q_cor,3)
   do i=lbound(lgrid%q_cor,2),ubound(lgrid%q_cor,2)
     x = lgrid%coords_cor(1,i,j)
     y = lgrid%coords_cor(2,i,j)
     grav = grav0*sin(ky*y)

     p = (intc+intf*(cos(ky*y)-1.0_rp))**(1.0_rp/(1.0_rp-inv_gamma))
     
     r = sqrt(((x-x0)**2+(y-y0)**2)/r0**2)
     A = A0
     if(r < 1.0_rp) then
      A = A0*(1.0_rp+dAbyA*cos(0.5_rp*CONST_PI*r)**2)
     endif
     
     rho = (p/A)**inv_gamma

     lgrid%q_cor(i_rho,i,j)    = rho
     lgrid%q_cor(i_rhovx1,i,j) = 0.0_rp
     lgrid%q_cor(i_rhovx2,i,j) = 0.0_rp
   
#ifdef EVOLVE_ETOT
     phi = (grav0 / ky) * cos(ky * y)
     lgrid%phi_cor(i,j) = phi 
     lgrid%q_cor(i_rhoe,i,j) = (p / (lgrid%gm - 1.0_rp)) + (rho * phi)
#else
     lgrid%q_cor(i_rhoe,i,j) = p / (lgrid%gm - 1.0_rp)
#endif

     lgrid%grav_cor(1,i,j) = 0.0_rp
     lgrid%grav_cor(2,i,j) = grav
   end do
  end do


#ifdef USE_GRAVITY
  ! 1. Cell Centers (Point Values)
  do j=lbound(lgrid%q_cc_bg,3),ubound(lgrid%q_cc_bg,3)
   do i=lbound(lgrid%q_cc_bg,2),ubound(lgrid%q_cc_bg,2)
     x = lgrid%coords_cc(1,i,j)
     y = lgrid%coords_cc(2,i,j)

     grav = grav0*sin(ky*y)
     ! Hydrostatic background pressure
     p = (intc+intf*(cos(ky*y)-1.0_rp))**(1.0_rp/(1.0_rp-inv_gamma))
     
     ! Resulting density
     rho = (p/A0)**inv_gamma

     ! Conserved variables
     lgrid%q_cc_bg(i_rho,i,j)    = rho
     lgrid%q_cc_bg(i_rhovx1,i,j) = 0.0_rp
     lgrid%q_cc_bg(i_rhovx2,i,j) = 0.0_rp
     
#ifdef EVOLVE_ETOT
     phi = (grav0 / ky) * cos(ky * y)
     lgrid%phi_cc_bg(i,j) = phi 
     lgrid%q_cc_bg(i_rhoe,i,j) = (p / (lgrid%gm - 1.0_rp)) + (rho * phi)
#else
     lgrid%q_cc_bg(i_rhoe,i,j) = p / (lgrid%gm - 1.0_rp)
#endif

     lgrid%grav_cc(1,i,j) = 0.0_rp
     lgrid%grav_cc(2,i,j) = grav

   end do
  end do

  ! 2. x1 Faces
  do j=lbound(lgrid%q_x1_bg,3),ubound(lgrid%q_x1_bg,3)
   do i=lbound(lgrid%q_x1_bg,2),ubound(lgrid%q_x1_bg,2)
     x = lgrid%coords_x1(1,i,j)
     y = lgrid%coords_x1(2,i,j)
     grav = grav0*sin(ky*y)

     p = (intc+intf*(cos(ky*y)-1.0_rp))**(1.0_rp/(1.0_rp-inv_gamma))
     
     rho = (p/A0)**inv_gamma

     lgrid%q_x1_bg(i_rho,i,j)    = rho
     lgrid%q_x1_bg(i_rhovx1,i,j) = 0.0_rp
     lgrid%q_x1_bg(i_rhovx2,i,j) = 0.0_rp
     
#ifdef EVOLVE_ETOT
     phi = (grav0 / ky) * cos(ky * y)
     lgrid%phi_x1_bg(i,j) = phi 
     lgrid%q_x1_bg(i_rhoe,i,j) = (p / (lgrid%gm - 1.0_rp)) + (rho * phi)
#else
     lgrid%q_x1_bg(i_rhoe,i,j) = p / (lgrid%gm - 1.0_rp)
#endif

     lgrid%grav_x1(1,i,j) = 0.0_rp
     lgrid%grav_x1(2,i,j) = grav
   end do
  end do

  ! 3. x2 Faces
  do j=lbound(lgrid%q_x2_bg,3),ubound(lgrid%q_x2_bg,3)
   do i=lbound(lgrid%q_x2_bg,2),ubound(lgrid%q_x2_bg,2)
     x = lgrid%coords_x2(1,i,j)
     y = lgrid%coords_x2(2,i,j)
     grav = grav0*sin(ky*y)

     p = (intc+intf*(cos(ky*y)-1.0_rp))**(1.0_rp/(1.0_rp-inv_gamma))
     
     rho = (p/A0)**inv_gamma

     lgrid%q_x2_bg(i_rho,i,j)    = rho
     lgrid%q_x2_bg(i_rhovx1,i,j) = 0.0_rp
     lgrid%q_x2_bg(i_rhovx2,i,j) = 0.0_rp
     
#ifdef EVOLVE_ETOT
     phi = (grav0 / ky) * cos(ky * y)
     lgrid%phi_x2_bg(i,j) = phi 
     lgrid%q_x2_bg(i_rhoe,i,j) = (p / (lgrid%gm - 1.0_rp)) + (rho * phi)
#else
     lgrid%q_x2_bg(i_rhoe,i,j) = p / (lgrid%gm - 1.0_rp)
#endif

     lgrid%grav_x2(1,i,j) = 0.0_rp
     lgrid%grav_x2(2,i,j) = grav
   end do
  end do

  ! 4. Corners
  do j=lbound(lgrid%q_cor_bg,3),ubound(lgrid%q_cor_bg,3)
   do i=lbound(lgrid%q_cor_bg,2),ubound(lgrid%q_cor_bg,2)
     x = lgrid%coords_cor(1,i,j)
     y = lgrid%coords_cor(2,i,j)
     grav = grav0*sin(ky*y)

     p = (intc+intf*(cos(ky*y)-1.0_rp))**(1.0_rp/(1.0_rp-inv_gamma))
     
     rho = (p/A0)**inv_gamma

     lgrid%q_cor_bg(i_rho,i,j)    = rho
     lgrid%q_cor_bg(i_rhovx1,i,j) = 0.0_rp
     lgrid%q_cor_bg(i_rhovx2,i,j) = 0.0_rp
     
#ifdef EVOLVE_ETOT
     phi = (grav0 / ky) * cos(ky * y)
     lgrid%phi_cor_bg(i,j) = phi 
     lgrid%q_cor_bg(i_rhoe,i,j) = (p / (lgrid%gm - 1.0_rp)) + (rho * phi)
#else
     lgrid%q_cor_bg(i_rhoe,i,j) = p / (lgrid%gm - 1.0_rp)
#endif

     lgrid%grav_cor(1,i,j) = 0.0_rp
     lgrid%grav_cor(2,i,j) = grav
   end do
  end do

  ! 5. Calculate accurate cell averages for the background
  do j=lbound(lgrid%qbar_cc_bg,3),ubound(lgrid%qbar_cc_bg,3)
   do i=lbound(lgrid%qbar_cc_bg,2),ubound(lgrid%qbar_cc_bg,2)
     do iv=1,nvars
      lgrid%qbar_cc_bg(iv,i,j) = ( rp16*lgrid%q_cc_bg(iv,i,j) + &
      rp4*(lgrid%q_x1_bg(iv,i,j)+lgrid%q_x1_bg(iv,i+1,j)+lgrid%q_x2_bg(iv,i,j)+lgrid%q_x2_bg(iv,i,j+1)) + &
      (lgrid%q_cor_bg(iv,i,j)+lgrid%q_cor_bg(iv,i+1,j)+lgrid%q_cor_bg(iv,i,j+1)+lgrid%q_cor_bg(iv,i+1,j+1)) &
      ) / rp36
     end do
   end do
  end do
  
  call compute_background_residuals(mgrid, lgrid)


#endif  



  ! -------------------------------------

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)
 
end program test