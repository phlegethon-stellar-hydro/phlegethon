program test
 use source
 
 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j,k
 real(kind=rp) :: x,y,r
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu
 real(kind=rp) :: p0,p,phi,uphi,x0,y0,mach
  
 mach = real(mach_make,kind=rp)

 x1l = 0.0_rp
 x1u = 1.0_rp
 x2l = 0.0_rp
 x2u = 1.0_rp
 x3l = 0.0_rp
 x3u = 1.0_rp
 gamma_ad = 5.0_rp/3.0_rp
 mu = 1.0_rp

 x0 = 0.5_rp
 y0 = 0.5_rp
 p0 = 1.0_rp/gamma_ad/mach**2-0.5_rp
 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)

 do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
  do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
   do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

     x = lgrid%coords(1,i,j,k)
     y = lgrid%coords(2,i,j,k)

     r   = sqrt((x-x0)**2+(y-y0)**2)
     phi = atan2(y-y0,x-x0)
     if(r < 0.2_rp) then
      uphi = 5.0_rp*r
      p    = p0 + 12.5_rp*r**2
     else if (r < 0.4_rp) then
      uphi = 2.0_rp - 5.0_rp*r
      p    = p0 + 12.5_rp*r**2 + 4.0_rp * (1.0_rp-5.0_rp*r-log(0.2_rp)+log(r))
     else
      uphi = 0.0_rp
      p    = p0 - 2.0_rp + 4.0_rp*log(2.0_rp)
     end if

     lgrid%prim(i_vx1,i,j,k) = -sin(phi)*uphi
     lgrid%prim(i_vx2,i,j,k) =  cos(phi)*uphi

     lgrid%prim(i_rho,i,j,k) = 1.0_rp
     lgrid%prim(i_p,i,j,k) = p

   end do
  end do
 end do

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)
 
end program test
