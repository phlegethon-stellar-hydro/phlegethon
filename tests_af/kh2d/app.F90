program test
 use source

 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j
 real(kind=rp) :: x1l,x1u,x2l,x2u,gamma_ad,mu
 real(kind=rp) :: x,y,eta,mach0,rho0,p0,vx1,vx2


 x1l = 0.0_rp
 x1u = 2.0_rp
 x2l = -0.5_rp
 x2u = 0.5_rp
 x3l = 0.0_rp
 x3u = 1.0_rp
 gamma_ad = 1.4_rp
 mu = 1.0_rp

 rho0 = gamma_ad
 mach0 = 0.1_rp
 p0 = 1.0_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,gamma_ad,mu)

 do j=lbound(lgrid%q_cor,3),ubound(lgrid%q_cor,3)
  do i=lbound(lgrid%q_cor,2),ubound(lgrid%q_cor,2)

     x = lgrid%coords_cor(1,i,j)
     y = lgrid%coords_cor(2,i,j)

     if ((y.gt.(-0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(-0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(16.0_rp*CONST_PI*(y+0.25_rp)))
     else if ((y.ge.(-0.25_rp+1.0_rp/32.0_rp)).and.(y.le.(0.25_rp-1.0_rp/32.0_rp))) then
       eta = 1.0_rp
     else if ((y.gt.(0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(-16.0_rp*CONST_PI*(y-0.25_rp)))
     else
       eta = 0.0
     end if

     vx1 = mach0*(1.0_rp-2.0_rp*eta)
     vx2 = 0.1_rp*mach0*sin(2.0_rp*CONST_PI*x)

     lgrid%q_cor(i_rhovx1,i,j) = rho0*vx1
     lgrid%q_cor(i_rhovx2,i,j) = rho0*vx2
     lgrid%q_cor(i_rho,i,j) = rho0
     lgrid%q_cor(i_rhoe,i,j) = p0/(lgrid%gm-1.0_rp)+rph*rho0*(vx1**2+vx2**2)

  end do
 end do

 do j=lbound(lgrid%q_x1,3),ubound(lgrid%q_x1,3)
  do i=lbound(lgrid%q_x1,2),ubound(lgrid%q_x1,2)

     x = lgrid%coords_x1(1,i,j)
     y = lgrid%coords_x1(2,i,j)

     if ((y.gt.(-0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(-0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(16.0_rp*CONST_PI*(y+0.25_rp)))
     else if ((y.ge.(-0.25_rp+1.0_rp/32.0_rp)).and.(y.le.(0.25_rp-1.0_rp/32.0_rp))) then
       eta = 1.0_rp
     else if ((y.gt.(0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(-16.0_rp*CONST_PI*(y-0.25_rp)))
     else
       eta = 0.0
     end if

     vx1 = mach0*(1.0_rp-2.0_rp*eta)
     vx2 = 0.1_rp*mach0*sin(2.0_rp*CONST_PI*x)

     lgrid%q_x1(i_rhovx1,i,j) = rho0*vx1
     lgrid%q_x1(i_rhovx2,i,j) = rho0*vx2
     lgrid%q_x1(i_rho,i,j) = rho0
     lgrid%q_x1(i_rhoe,i,j) = p0/(lgrid%gm-1.0_rp)+rph*rho0*(vx1**2+vx2**2)

  end do
 end do

 do j=lbound(lgrid%q_x2,3),ubound(lgrid%q_x2,3)
  do i=lbound(lgrid%q_x2,2),ubound(lgrid%q_x2,2)

     x = lgrid%coords_x2(1,i,j)
     y = lgrid%coords_x2(2,i,j)

     if ((y.gt.(-0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(-0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(16.0_rp*CONST_PI*(y+0.25_rp)))
     else if ((y.ge.(-0.25_rp+1.0_rp/32.0_rp)).and.(y.le.(0.25_rp-1.0_rp/32.0_rp))) then
       eta = 1.0_rp
     else if ((y.gt.(0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(-16.0_rp*CONST_PI*(y-0.25_rp)))
     else
       eta = 0.0
     end if

     vx1 = mach0*(1.0_rp-2.0_rp*eta)
     vx2 = 0.1_rp*mach0*sin(2.0_rp*CONST_PI*x)

     lgrid%q_x2(i_rhovx1,i,j) = rho0*vx1
     lgrid%q_x2(i_rhovx2,i,j) = rho0*vx2
     lgrid%q_x2(i_rho,i,j) = rho0
     lgrid%q_x2(i_rhoe,i,j) = p0/(lgrid%gm-1.0_rp)+rph*rho0*(vx1**2+vx2**2)

  end do
 end do


  !initialize temperature
  call compute_temp(mgrid,lgrid)

  !Define the opacity (currently assumed to be constant)
   do j=lbound(lgrid%kap_cc,2),ubound(lgrid%kap_cc,2)
    do i=lbound(lgrid%kap_cc,1),ubound(lgrid%kap_cc,1)

        lgrid%kap_cc(i,j) = 1.0e-34_rp
    end do
   end do

   do j=lbound(lgrid%kap_x1,2),ubound(lgrid%kap_x1,2)
    do i=lbound(lgrid%kap_x1,1),ubound(lgrid%kap_x1,1)
        lgrid%kap_x1(i,j) =  1.0e-34_rp
    end do
   end do

   do j=lbound(lgrid%kap_x2,2),ubound(lgrid%kap_x2,2)
    do i=lbound(lgrid%kap_x2,1),ubound(lgrid%kap_x2,1)
        lgrid%kap_x2(i,j) =  1.0e-34_rp
    end do
   end do

   do j=lbound(lgrid%kap_cor,2),ubound(lgrid%kap_cor,2)
    do i=lbound(lgrid%kap_cor,1),ubound(lgrid%kap_cor,1)
        lgrid%kap_cor(i,j) = 1.0e-34_rp
    end do
   end do

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)

end program test
