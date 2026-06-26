program test
 use source

 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j
 real(kind=rp) :: x1l,x1u,x2l,x2u,gamma_ad,mu
 real(kind=rp) :: p0,x0,y0
 real(kind=rp) :: x,y
 real(kind=rp) :: radius,T_b,dT

 real(kind=rp) :: mach

 mach = 0.1_rp

 x1l = -5.0_rp * CONST_RSUN
 x1u = 5.0_rp * CONST_RSUN
 x2l = -5.0_rp * CONST_RSUN
 x2u = 5.0_rp * CONST_RSUN
 gamma_ad = 5.0_rp/3.0_rp
 mu = 1.0_rp

 x0 = 0.0_rp
 y0 = 0.0_rp
 p0 = 1.0_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,gamma_ad,mu)

 T_b = 1.0e7_rp
 dT = T_b /10.0_rp

 do j=lbound(lgrid%t_cc,2),ubound(lgrid%t_cc,2)
  do i=lbound(lgrid%t_cc,1),ubound(lgrid%t_cc,1)
      x = lgrid%coords_cc(1,i,j)
      y = lgrid%coords_cc(2,i,j)
      radius = sqrt(x * x + y * y)
      if (radius <= CONST_RSUN) then
          lgrid%t_cc(i,j) = T_b + dT &
          * cos(CONST_PI * radius / (2.0_rp * CONST_RSUN)) * cos(CONST_PI * radius / (2.0_rp * CONST_RSUN))
      else
          lgrid%t_cc(i,j) = T_b
      end if
  end do
 end do

 do j=lbound(lgrid%t_x1,2),ubound(lgrid%t_x1,2)
  do i=lbound(lgrid%t_x1,1),ubound(lgrid%t_x1,1)
      x = lgrid%coords_x1(1,i,j)
      y = lgrid%coords_x1(2,i,j)
      radius = sqrt(x * x + y * y)
      if (radius <= CONST_RSUN) then
          lgrid%t_x1(i,j) = T_b + dT &
          * cos(CONST_PI * radius / (2.0_rp * CONST_RSUN)) * cos(CONST_PI * radius / (2.0_rp * CONST_RSUN))
      else
          lgrid%t_x1(i,j) = T_b
      end if
  end do
 end do

 do j=lbound(lgrid%t_x2,2),ubound(lgrid%t_x2,2)
  do i=lbound(lgrid%t_x2,1),ubound(lgrid%t_x2,1)
      x = lgrid%coords_x2(1,i,j)
      y = lgrid%coords_x2(2,i,j)
      radius = sqrt(x * x + y * y)
      if (radius <= CONST_RSUN) then
          lgrid%t_x2(i,j) = T_b + dT &
          * cos(CONST_PI * radius / (2.0_rp * CONST_RSUN)) * cos(CONST_PI * radius / (2.0_rp * CONST_RSUN))
      else
          lgrid%t_x2(i,j) = T_b
      end if
  end do
 end do

 do j=lbound(lgrid%t_cor,2),ubound(lgrid%t_cor,2)
  do i=lbound(lgrid%t_cor,1),ubound(lgrid%t_cor,1)
      x = lgrid%coords_cor(1,i,j)
      y = lgrid%coords_cor(2,i,j)
      radius = sqrt(x * x + y * y)
      if (radius <= CONST_RSUN) then
          lgrid%t_cor(i,j) = T_b + dT &
          * cos(CONST_PI * radius / (2.0_rp * CONST_RSUN)) * cos(CONST_PI * radius / (2.0_rp * CONST_RSUN))
      else
          lgrid%t_cor(i,j) = T_b
      end if
  end do
 end do

 do j=lbound(lgrid%q_cor,3),ubound(lgrid%q_cor,3)
  do i=lbound(lgrid%q_cor,2),ubound(lgrid%q_cor,2)

     lgrid%q_cor(i_rhovx1,i,j) = 0
     lgrid%q_cor(i_rhovx2,i,j) = 0

     lgrid%q_cor(i_rho,i,j) = 1.0_rp
     lgrid%q_cor(i_rhoe,i,j) = 1.0_rp * CONST_R * lgrid%t_cor(i,j) /(mu * (gamma_ad -1))

  end do
 end do

 do j=lbound(lgrid%q_x1,3),ubound(lgrid%q_x1,3)
  do i=lbound(lgrid%q_x1,2),ubound(lgrid%q_x1,2)

     lgrid%q_x1(i_rhovx1,i,j) = 0
     lgrid%q_x1(i_rhovx2,i,j) = 0

     lgrid%q_x1(i_rho,i,j) = 1.0_rp
     lgrid%q_x1(i_rhoe,i,j) = 1.0_rp * CONST_R * lgrid%t_x1(i,j) /(mu * (gamma_ad -1))

  end do
 end do

 do j=lbound(lgrid%q_x2,3),ubound(lgrid%q_x2,3)
  do i=lbound(lgrid%q_x2,2),ubound(lgrid%q_x2,2)


     lgrid%q_x2(i_rhovx1,i,j) = 0
     lgrid%q_x2(i_rhovx2,i,j) = 0

     lgrid%q_x2(i_rho,i,j) = 1.0_rp
     lgrid%q_x2(i_rhoe,i,j) = 1.0_rp * CONST_R * lgrid%t_x2(i,j) /(mu * (gamma_ad -1))

  end do
 end do

!Define the opacity (currently assumed to be constant)

 do j=lbound(lgrid%kap_cc,2),ubound(lgrid%kap_cc,2)
  do i=lbound(lgrid%kap_cc,1),ubound(lgrid%kap_cc,1)
      lgrid%kap_cc(i,j) = 1.0e-8_rp
  end do
 end do

 do j=lbound(lgrid%kap_x1,2),ubound(lgrid%kap_x1,2)
  do i=lbound(lgrid%kap_x1,1),ubound(lgrid%kap_x1,1)
      lgrid%kap_x1(i,j) = 1.0e-8_rp
  end do
 end do

 do j=lbound(lgrid%kap_x2,2),ubound(lgrid%kap_x2,2)
  do i=lbound(lgrid%kap_x2,1),ubound(lgrid%kap_x2,1)
      lgrid%kap_x2(i,j) = 1.0e-8_rp
  end do
 end do

 do j=lbound(lgrid%kap_cor,2),ubound(lgrid%kap_cor,2)
  do i=lbound(lgrid%kap_cor,1),ubound(lgrid%kap_cor,1)
      lgrid%kap_cor(i,j) = 1.0e-8_rp
  end do
 end do

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)

end program test
