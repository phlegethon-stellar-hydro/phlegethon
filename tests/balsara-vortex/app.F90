program test
 use source
 
 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j,k
 real(kind=rp) :: x,y,r,fac,coeff
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu
 real(kind=rp), allocatable :: Az(:,:,:)

 real(kind=rp) :: kp=0.01_rp,mp=0.01_rp

 fac = 1.0_rp/sqrt(2.0_rp)

 x1l = -5.0_rp
 x1u =  5.0_rp
 x2l = -5.0_rp
 x2u =  5.0_rp
 x3l = 0.0_rp
 x3u = 1.0_rp
 gamma_ad = 5.0_rp/3.0_rp
 mu = 1.0_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)

#ifdef USE_MHD

 allocate(Az( & 
 lbound(lgrid%nodes,2):ubound(lgrid%nodes,2), &
 lbound(lgrid%nodes,3):ubound(lgrid%nodes,3), &
 lbound(lgrid%nodes,4):ubound(lgrid%nodes,4) &
 ) )

 do k=lbound(lgrid%nodes,4),ubound(lgrid%nodes,4)
  do j=lbound(lgrid%nodes,3),ubound(lgrid%nodes,3)
   do i=lbound(lgrid%nodes,2),ubound(lgrid%nodes,2)
     x = lgrid%nodes(1,i,j,k)
     y = lgrid%nodes(2,i,j,k)
     r = sqrt(x*x+y*y)
     Az(i,j,k) = mp*exp(0.5_rp*(1.0_rp-r*r))
   end do
  end do 
 end do 

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)
   do i=mgrid%i1(1),mgrid%i2(1)+1
    lgrid%b_x1(i,j,k) = lgrid%inv_dx2*(Az(i,j+1,k)-Az(i,j,k))
   end do
  end do
 end do

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)+1
   do i=mgrid%i1(1),mgrid%i2(1)
    lgrid%b_x2(i,j,k) = -lgrid%inv_dx1*(Az(i+1,j,k)-Az(i,j,k))
   end do
  end do
 end do

 deallocate(Az)

#endif

 do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
  do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
   do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

     x = lgrid%coords(1,i,j,k)
     y = lgrid%coords(2,i,j,k)
     r = sqrt(x**2+y**2)
     coeff = exp(0.5_rp*(1.0_rp-r**2))

     lgrid%prim(i_rho,i,j,k) = 1.0_rp
     lgrid%prim(i_p,i,j,k) = 1.0_rp+(0.5_rp*mp**2*(1.0_rp-r**2)-0.5_rp*kp**2)*exp(1-r**2)

     lgrid%temp(i,j,k) = lgrid%prim(i_p,i,j,k)/(CONST_RGAS*lgrid%prim(i_rho,i,j,k))*mu

     lgrid%prim(i_vx1,i,j,k) = -kp*coeff*y + kp*fac
     lgrid%prim(i_vx2,i,j,k) = kp*coeff*x + kp*fac

   end do
  end do
 end do

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)
 
end program test
