program test
 use source

 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j
 real(kind=rp) :: x1l,x1u,x2l,x2u,gamma_ad,mu
 real(kind=rp) :: p0,p,phi,uphi,x0,y0
 real(kind=rp) :: x,y,r,vx1,vx2

 real(kind=rp) :: mach

 mach = 0.1_rp

 x1l = 0.0_rp
 x1u = 1.0_rp
 x2l = 0.0_rp
 x2u = 1.0_rp
 gamma_ad = 5.0_rp/3.0_rp
 mu = 1.0_rp

 x0 = 0.5_rp
 y0 = 0.5_rp
 p0 = 1.0_rp/gamma_ad/mach**2-0.5_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,gamma_ad,mu)

 do j=lbound(lgrid%q_cor,3),ubound(lgrid%q_cor,3)
  do i=lbound(lgrid%q_cor,2),ubound(lgrid%q_cor,2)

     x = lgrid%coords_cor(1,i,j)
     y = lgrid%coords_cor(2,i,j)

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

     vx1 = -sin(phi)*uphi
     vx2 = cos(phi)*uphi

     lgrid%q_cor(i_rhovx1,i,j) = vx1
     lgrid%q_cor(i_rhovx2,i,j) = vx2

     lgrid%q_cor(i_rho,i,j) = 1.0_rp
     lgrid%q_cor(i_rhoe,i,j) = p/(lgrid%gm-1.0_rp)+rph*(vx1**2+vx2**2)

  end do
 end do

 do j=lbound(lgrid%q_x1,3),ubound(lgrid%q_x1,3)
  do i=lbound(lgrid%q_x1,2),ubound(lgrid%q_x1,2)

     x = lgrid%coords_x1(1,i,j)
     y = lgrid%coords_x1(2,i,j)

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

     vx1 = -sin(phi)*uphi
     vx2 = cos(phi)*uphi

     lgrid%q_x1(i_rhovx1,i,j) = vx1
     lgrid%q_x1(i_rhovx2,i,j) = vx2

     lgrid%q_x1(i_rho,i,j) = 1.0_rp
     lgrid%q_x1(i_rhoe,i,j) = p/(lgrid%gm-1.0_rp)+rph*(vx1**2+vx2**2)

  end do
 end do

 do j=lbound(lgrid%q_x2,3),ubound(lgrid%q_x2,3)
  do i=lbound(lgrid%q_x2,2),ubound(lgrid%q_x2,2)

     x = lgrid%coords_x2(1,i,j)
     y = lgrid%coords_x2(2,i,j)

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

     vx1 = -sin(phi)*uphi
     vx2 = cos(phi)*uphi

     lgrid%q_x2(i_rhovx1,i,j) = vx1
     lgrid%q_x2(i_rhovx2,i,j) = vx2

     lgrid%q_x2(i_rho,i,j) = 1.0_rp
     lgrid%q_x2(i_rhoe,i,j) = p/(lgrid%gm-1.0_rp)+rph*(vx1**2+vx2**2)

  end do
 end do

!Define the opacity (currently assumed to be constant)

 do j=lbound(lgrid%kap_cc,2),ubound(lgrid%kap_cc,2)
  do i=lbound(lgrid%kap_cc,1),ubound(lgrid%kap_cc,1)
      lgrid%kap_cc(i,j) = 1.0_rp
  end do
 end do

 do j=lbound(lgrid%kap_x1,2),ubound(lgrid%kap_x1,2)
  do i=lbound(lgrid%kap_x1,1),ubound(lgrid%kap_x1,1)
      lgrid%kap_x1(i,j) = 1.0_rp
  end do
 end do

 do j=lbound(lgrid%kap_x2,2),ubound(lgrid%kap_x2,2)
  do i=lbound(lgrid%kap_x2,1),ubound(lgrid%kap_x2,1)
      lgrid%kap_x2(i,j) = 1.0_rp
  end do
 end do

 do j=lbound(lgrid%kap_cor,2),ubound(lgrid%kap_cor,2)
  do i=lbound(lgrid%kap_cor,1),ubound(lgrid%kap_cor,1)
      lgrid%kap_cor(i,j) = 1.0_rp
  end do
 end do

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)

end program test
