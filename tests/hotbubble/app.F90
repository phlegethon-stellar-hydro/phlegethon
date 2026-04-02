program test
 use source
 
 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j,k
 real(kind=rp) :: x,y
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu

 real(kind=rp) :: p0,temp0,grav0,x0,y0,z0,inv_gamma, &
 A0,ky,intc,intf,p,rho_hse,grav,A,r,r0,rho,rho0,T
        
 real(kind=rp), parameter :: dAbyA = dAbyA_make

 x1l = 0.0_rp
 x1u = 1e6_rp
 x2l = 0.0_rp
 x2u = 1.5e6_rp
 x3l = 0.0_rp
 x3u = 1e6_rp
 gamma_ad = 5.0_rp/3.0_rp
 mu = 1.0_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)

 p0 = 1e6_rp
 temp0 = 300_rp
 grav0 = -109904.73_rp

 x0 = 5e5_rp
 y0 = 1.875e5_rp
 z0 = 5e5_rp
 rho0 = p0/(CONST_RGAS*temp0) 
 inv_gamma = 1.0_rp/lgrid%gm
 A0 = p0/rho0**lgrid%gm
 ky = 2.0_rp*CONST_PI/x2u
 intc = p0**(1.0_rp-inv_gamma)
 intf = -(1.0_rp-inv_gamma)/A0**inv_gamma*grav0/ky
 r0 = 1.25e5_rp
 T = 0.0_rp

#ifdef USE_MHD

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)
   do i=mgrid%i1(1),mgrid%i2(1)+1
    lgrid%b_x1(i,j,k) = 1e-5_rp*sqrt(p0/rho0)
   end do
  end do
 end do

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)+1
   do i=mgrid%i1(1),mgrid%i2(1)
    lgrid%b_x2(i,j,k) = 0.0_rp
   end do
  end do
 end do

#if sdims_make==3
 do k=mgrid%i1(3),mgrid%i2(3)+1
  do j=mgrid%i1(2),mgrid%i2(2)
   do i=mgrid%i1(1),mgrid%i2(1)
    lgrid%b_x3(i,j,k) = 0.0_rp
   end do
  end do
 end do
#endif

#endif

#if defined(EVOLVE_ETOT) || defined(USE_WB) 

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)
   do i=mgrid%i1(1),mgrid%i2(1)+1

     y = lgrid%coords_x1(2,i,j,k)
     p = (intc+intf*(cos(ky*y)-1.0_rp))**(1.0_rp/(1.0_rp-inv_gamma))
     rho_hse = (p/A0)**inv_gamma
#ifdef EVOLVE_ETOT
     lgrid%phi_x1(i,j,k) = (grav0/ky)*cos(ky*y)
#endif
#ifdef USE_WB
     lgrid%eq_prim_x1(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_x1(ieq_p,i,j,k) = p
#endif

   end do
  end do
 end do

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)+1
   do i=mgrid%i1(1),mgrid%i2(1)

     y = lgrid%coords_x2(2,i,j,k)
     p = (intc+intf*(cos(ky*y)-1.0_rp))**(1.0_rp/(1.0_rp-inv_gamma))
     rho_hse = (p/A0)**inv_gamma
#ifdef EVOLVE_ETOT
     lgrid%phi_x2(i,j,k) = (grav0/ky)*cos(ky*y)
#endif
#ifdef USE_WB
     lgrid%eq_prim_x2(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_x2(ieq_p,i,j,k) = p
#endif

   end do
  end do
 end do

#if sdims_make==3

 do k=mgrid%i1(3),mgrid%i2(3)+1
  do j=mgrid%i1(2),mgrid%i2(2)
   do i=mgrid%i1(1),mgrid%i2(1)
   
     y = lgrid%coords_x3(2,i,j,k)
     p = (intc+intf*(cos(ky*y)-1.0_rp))**(1.0_rp/(1.0_rp-inv_gamma))
     rho_hse = (p/A0)**inv_gamma
#ifdef EVOLVE_ETOT
     lgrid%phi_x3(i,j,k) = (grav0/ky)*cos(ky*y)
#endif
#ifdef USE_WB
     lgrid%eq_prim_x3(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_x3(ieq_p,i,j,k) = p
#endif

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
     grav = grav0*sin(ky*y)
     p = (intc+intf*(cos(ky*y)-1.0_rp))**(1.0_rp/(1.0_rp-inv_gamma))
     rho_hse = (p/A0)**inv_gamma
     r = sqrt(((x-x0)**2+(y-y0)**2)/r0**2)
     A = A0
     if(r<1.0_rp) then
      A = A0*(1.0_rp+dAbyA*cos(0.5_rp*CONST_PI*r)**2)
     endif
     rho = (p/A)**inv_gamma
     lgrid%prim(i_rho,i,j,k) = rho
     lgrid%prim(i_p,i,j,k) = p
     lgrid%prim(i_vx1,i,j,k) = 0.0_rp
     lgrid%prim(i_vx2,i,j,k) = 0.0_rp
#if sdims_make==3
     lgrid%prim(i_vx3,i,j,k) = 0.0_rp
#endif
     lgrid%grav(1,i,j,k) = 0.0_rp
     lgrid%grav(2,i,j,k) = grav
#if sdims_make==3
     lgrid%grav(3,i,j,k) = 0.0_rp
#endif
#ifdef EVOLVE_ETOT
     lgrid%phi_cc(i,j,k) = (grav0/ky)*cos(ky*y)   
#endif
#ifdef USE_WB
     lgrid%eq_prim_cc(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_cc(ieq_p,i,j,k) = p
#endif

#if nas>0
     lgrid%prim(i_as1:i_asl,i,j,k) = 1.0_rp
#endif

   end do
  end do
 end do

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)
 
end program test
