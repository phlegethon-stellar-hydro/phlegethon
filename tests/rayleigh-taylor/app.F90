program test
 use source
 
 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j,k
 real(kind=rp) :: x,y
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu

 real(kind=rp) :: rho,v,g

 g = -0.1_rp
 p0 = 2.5_rp

 x1l = -0.25_rp
 x1u = +0.25_rp
 x2l = -0.75_rp
 x2u = +0.75_rp
 x3l = 0.0_rp
 x3u = 1.0_rp
 gamma_ad = 1.4_rp
 mu = 1.0_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)

 do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
  do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
   do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

     x = lgrid%coords(1,i,j,k)
     y = lgrid%coords(2,i,j,k)
 
     v = 0.01_rp*(1.0_rp+cos(4.0_rp*CONST_PI*x)*(1.0_rp+cos(3.0_rp*CONST_PI*y)))
     
     rho = 1.0_rp
     if(y>0) rho = 2.0_rp
    
     lgrid%prim(i_rho,i,j,k) = rho
     lgrid%prim(i_p,i,j,k) = p0  - 0.1_rp*y
     lgrid%prim(i_vx1,i,j,k) = 0.0_rp
     lgrid%prim(i_vx2,i,j,k) = v

     lgrid%grav(1,i,j,k) = 0.0_rp
     lgrid%grav(2,i,j,k) = g

   end do
  end do
 end do

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)
 
end program test
