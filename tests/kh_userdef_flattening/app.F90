program test
 use source
 
 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j,k
 real(kind=rp) :: x,y,eta,mach0
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu


 mach0 = 1e-1_rp

 x1l = 0.0_rp
 x1u = 2.0_rp
 x2l = -0.5_rp
 x2u = 0.5_rp
 x3l = 0.0_rp
 x3u = 1.0_rp
 gamma_ad = 5.0_rp/3.0_rp
 mu = 1.0_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)



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
     lgrid%prim(i_as1:i_asl,i,j,k) = eta
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

#ifdef USE_USERDEF_SHOCK_FLATTENING

 subroutine userdef_shock_flattening(mgrid,lgrid)
 use source
 type(locgrid), intent(inout) :: lgrid
 type(mpigrid), intent(inout) :: mgrid

 integer :: i,j,k
 real(kind=rp) :: y
 do k=mgrid%i1(3)-1,mgrid%i2(3)+1
  do j=mgrid%i1(2)-1,mgrid%i2(2)+1
     do i=mgrid%i1(1)-1,mgrid%i2(1)+1
          y = lgrid%coords(2,i,j,k)
          if(y > 0.0_rp) lgrid%is_flattened(i,j,k) = 1
   end do
  end do
 end do

 end subroutine userdef_shock_flattening

#endif


