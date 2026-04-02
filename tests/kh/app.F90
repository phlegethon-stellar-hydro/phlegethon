program test
 use source
 
 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j,k
 real(kind=rp) :: x,y,eta,mach0
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu
 real(kind=rp) :: ye,abar,abar0,dabar

 mach0 = 1e-1_rp
 ye = 0.5_rp
 abar = 0.0_rp
 abar0 = 16.0_rp
 dabar = 0.5_rp

 x1l = 0.0_rp
 x1u = 2.0_rp
 x2l = -0.5_rp
 x2u = 0.5_rp
 x3l = 0.0_rp
 x3u = 1.0_rp
 gamma_ad = 5.0_rp/3.0_rp
 mu = 1.0_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)

#ifdef USE_MHD

 do k=lbound(lgrid%b_x1,3),ubound(lgrid%b_x1,3)
  do j=lbound(lgrid%b_x1,2),ubound(lgrid%b_x1,2)
   do i=lbound(lgrid%b_x1,1),ubound(lgrid%b_x1,1)
    lgrid%b_x1(i,j,k) = 0.1_rp*mach0
   end do
  end do
 end do

 do k=lbound(lgrid%b_x2,3),ubound(lgrid%b_x2,3)
  do j=lbound(lgrid%b_x2,2),ubound(lgrid%b_x2,2)
   do i=lbound(lgrid%b_x2,1),ubound(lgrid%b_x2,1)
    lgrid%b_x2(i,j,k) = 0.0_rp
   end do
  end do
 end do

#if sdims_make==3

 do k=lbound(lgrid%b_x3,3),ubound(lgrid%b_x3,3)
  do j=lbound(lgrid%b_x3,2),ubound(lgrid%b_x3,2)
   do i=lbound(lgrid%b_x3,1),ubound(lgrid%b_x3,1)
    lgrid%b_x3(i,j,k) = 0.0_rp
   end do
  end do
 end do

#endif

#endif

 do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
  do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
   do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

     x = lgrid%coords(1,i,j,k)
     y = lgrid%coords(2,i,j,k)

     if ((y.gt.(-0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(-0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(16.0_rp*CONST_PI*(y+0.25_rp)))
     else if ((y.ge.(-0.25_rp+1.0_rp/32.0_rp)).and.(y.le.(0.25_rp-1.0_rp/32.0_rp))) then
       eta = 1.0_rp
     else if ((y.gt.(0.25_rp-1.0_rp/32.0_rp)).and.(y.lt.(0.25_rp+1.0_rp/32.0_rp))) then
       eta = 0.5_rp*(1.0_rp+sin(-16.0_rp*CONST_PI*(y-0.25_rp)))
     else
       eta = 0.0
     end if

     lgrid%prim(i_rho,i,j,k) = gamma_ad
     lgrid%prim(i_p,i,j,k) = 1.0_rp

#if nas_make>0
#ifdef ADVECT_YE_IABAR
     abar = abar0*(1.0_rp+dabar*eta)
     lgrid%prim(i_ye,i,j,k) = ye
     lgrid%prim(i_iabar,i,j,k) = 1.0_rp/abar
     mu = abar/(ye*abar+1.0_rp)
#if nas_make>2
     lgrid%prim(i_iabar+1:i_asl,i,j,k) = eta
#endif
#else
     lgrid%prim(i_as1:i_asl,i,j,k) = eta
#endif
#endif

     lgrid%temp(i,j,k) = 1.0_rp/(CONST_RGAS*gamma_ad)*mu

     lgrid%prim(i_vx1,i,j,k) = mach0*(1.0_rp-2.0_rp*eta)
     lgrid%prim(i_vx2,i,j,k) = 0.1_rp*mach0*sin(2.0_rp*CONST_PI*x)
#if sdims_make==3
     lgrid%prim(i_vx3,i,j,k) = 0.0_rp
#endif

   end do
  end do
 end do

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)
 
end program test
