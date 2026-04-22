program test
 use source
 
 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j,k
 real(kind=rp) :: x,y
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu
 real(kind=rp) :: B0
 real(kind=rp), allocatable :: Az(:,:,:)

 B0 = 1.0_rp / sqrt(4.0_rp*CONST_PI)

 x1l = 0.0_rp
 x1u = 1.0_rp
 x2l = 0.0_rp
 x2u = 1.0_rp
 x3l = 0.0_rp
 x3u = 1.0_rp
 gamma_ad = 5.0_rp/3.0_rp
 mu = 1.0_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)

 allocate(Az(mgrid%i1(1):mgrid%i2(1)+1,mgrid%i1(2):mgrid%i2(2)+1,mgrid%i1(3):mgrid%i2(3)))

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)+1
   do i=mgrid%i1(1),mgrid%i2(1)+1

     x = lgrid%nodes(1,i,j,k)
     y = lgrid%nodes(2,i,j,k)

     Az(i,j,k) = B0/(2.0_rp*CONST_PI)*cos(2.0_rp*CONST_PI*y) + &
                 B0/(4.0_rp*CONST_PI)*cos(4.0_rp*CONST_PI*x)

   end do
  end do
 end do

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)
   do i=mgrid%i1(1),mgrid%i2(1)+1

    lgrid%b_x1(i,j,k) = (Az(i,j+1,k)-Az(i,j,k))*lgrid%inv_dx2 

   end do
  end do
 end do

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)+1
   do i=mgrid%i1(1),mgrid%i2(1)

    lgrid%b_x2(i,j,k) = -(Az(i+1,j,k)-Az(i,j,k))*lgrid%inv_dx1

   end do
  end do
 end do

 deallocate(Az)

 do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
  do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
   do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

     x = lgrid%coords(1,i,j,k)
     y = lgrid%coords(2,i,j,k)

     lgrid%prim(i_rho,i,j,k) = 25.0_rp/(36.0_rp*CONST_PI) 
     lgrid%prim(i_p,i,j,k) = 5.0_rp/(12.0_rp*CONST_PI)

     lgrid%prim(i_vx1,i,j,k) = -sin(2.0_rp*CONST_PI*y)
     lgrid%prim(i_vx2,i,j,k) =  sin(2.0_rp*CONST_PI*x)

   end do
  end do
 end do

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)
 
end program test
