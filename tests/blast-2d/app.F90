program test
 use source
 
 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j,k
 real(kind=rp) :: x,y
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu
 real(kind=rp) :: rho0,T0,p,e,sound,cv,T,L,abar,ye,zbar

 L = 1.0e9_rp
 abar = 16.0_rp
 ye = 1.0_rp
 zbar = ye*abar

 x1l = -L
 x1u = +L
 x2l = -L
 x2u = +L
 x3l = 0.0_rp
 x3u = 1.0_rp
 gamma_ad = 5.0_rp/3.0_rp
 mu = 1.0_rp

 rho0 = 1.0e4_rp
 T0 = 1.0e7_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)

 do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
  do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
   do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

     x = lgrid%coords(1,i,j,k)
     y = lgrid%coords(2,i,j,k)

     T = T0

     if(sqrt(x**2+y**2)<=0.1_rp*L) then
      T = 100.0_rp*T0
     endif

     call helm_rhoT_given_full(rho0,T,abar,zbar,p,e,sound,cv)

     lgrid%prim(i_rho,i,j,k) = rho0
     lgrid%prim(i_p,i,j,k) = p

     lgrid%prim(i_vx1,i,j,k) = 0.0_rp
     lgrid%prim(i_vx2,i,j,k) = 0.0_rp

     lgrid%prim(i_iabar,i,j,k) = 1.0_rp/abar
     lgrid%prim(i_ye,i,j,k) = ye
   
     lgrid%temp(i,j,k) = T

   end do
  end do
 end do

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)
 
end program test
