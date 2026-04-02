program test
 use source
 implicit none

 type model_t
  real(kind=rp), allocatable :: r(:),grav(:),gpot(:),rho(:),p(:),T(:)
 end type model_t

 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 call setup(mgrid,lgrid)

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)

contains 

subroutine setup(mgrid,lgrid)
 type(mpigrid),intent(inout) :: mgrid
 type(locgrid),intent(inout) :: lgrid


 type(model_t) :: model
 integer :: i,j,k
 real(kind=rp) :: x,y,x0,y0,z0,r,rt
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu

 real(kind=rp) :: L,abar,abar0
 real(kind=rp) :: rho_hse,p_hse,T_hse,gpot,grav,rho,rb

 abar0 = 16.0_rp

 call load_model('hotbubble.in',model)

#ifdef USE_PRAD
 L = 139324245.55182254_rp
#else
 L = 78967016.28920652_rp
#endif

 mu = 1.77777777777_rp
 gamma_ad = 5.0_rp/3.0_rp

#ifdef GEOMETRY_2D_SPHERICAL
 x1l = 0.1_rp*L
 x1u = L
 x2l = CONST_PI/4.0_rp
 x2u = 3.0_rp*CONST_PI/4.0_rp
#elif defined(GEOMETRY_2D_POLAR)
 x1l = 0.1_rp*L
 x1u = L
 x2l = 0.0_rp
 x2u = CONST_PI/4.0_rp
#else
 x1l = -L/2.0_rp
 x1u = L/2.0_rp
 x2l = 0.0_rp
 x2u = L
#endif
 x3l = -L/2.0_rp
 x3u = +L/2.0_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)

#ifdef GEOMETRY_2D_SPHERICAL
 x0 = L/3.0_rp
 y0 = 0.0_rp
#elif defined(GEOMETRY_2D_POLAR)
 x0 = L/3.0_rp*cos(x2u/2.0_rp)
 y0 = L/3.0_rp*sin(x2u/2.0_rp)
#else
 x0 = 0.0_rp
 y0 = L/3.0_rp
#endif
 z0 = 0.0_rp
 rb = L/10.0_rp

#if defined(EVOLVE_ETOT) || defined(USE_WB) 

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)
   do i=mgrid%i1(1),mgrid%i2(1)+1

     x = lgrid%coords_x1(1,i,j,k)
     y = lgrid%coords_x1(2,i,j,k)
#ifdef GEOMETRY_CARTESIAN_UNIFORM
     r = y
#else
     r = sqrt(x**2+y**2)
#endif

     call interpolate_model(model,r,grav,gpot,rho_hse,p_hse,T_hse)

#ifdef EVOLVE_ETOT
     lgrid%phi_x1(i,j,k) = gpot
#endif
#ifdef USE_WB
     lgrid%eq_prim_x1(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_x1(ieq_p,i,j,k) = p_hse
     lgrid%eq_prim_x1(ieq_T,i,j,k) = T_hse
#endif

   end do
  end do
 end do

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)+1
   do i=mgrid%i1(1),mgrid%i2(1)

     x = lgrid%coords_x2(1,i,j,k)
     y = lgrid%coords_x2(2,i,j,k)
#ifdef GEOMETRY_CARTESIAN_UNIFORM
     r = y
#else
     r = sqrt(x**2+y**2)
#endif

     call interpolate_model(model,r,grav,gpot,rho_hse,p_hse,T_hse)

#ifdef EVOLVE_ETOT
     lgrid%phi_x2(i,j,k) = gpot
#endif
#ifdef USE_WB
     lgrid%eq_prim_x2(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_x2(ieq_p,i,j,k) = p_hse
     lgrid%eq_prim_x2(ieq_T,i,j,k) = T_hse
#endif

   end do
  end do
 end do

#endif

 do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
  do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
   do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

     x = lgrid%coords(1,i,j,k)
     y = lgrid%coords(2,i,j,k)
#ifdef GEOMETRY_CARTESIAN_UNIFORM
     r = y
#else
     r = sqrt(x**2+y**2)
#endif

     call interpolate_model(model,r,grav,gpot,rho_hse,p_hse,T_hse)

     rt = sqrt((x-x0)**2+(y-y0)**2)/rb

     rho = rho_hse
     abar = abar0
     if(rt<=1.0_rp) then
      rho = rho_hse*(1.0_rp-0.3_rp*cos(CONST_PI*rt/2.0_rp)**2)
     endif
 
     lgrid%temp(i,j,k) = T_hse

#ifdef ADVECT_YE_IABAR
     lgrid%prim(i_ye,i,j,k) = 0.5_rp
     lgrid%prim(i_iabar,i,j,k) = 1.0_rp/abar
#endif

     lgrid%prim(i_rho,i,j,k) = rho
     lgrid%prim(i_p,i,j,k) = p_hse
     lgrid%prim(i_vx1,i,j,k) = 0.0_rp
     lgrid%prim(i_vx2,i,j,k) = 0.0_rp

     lgrid%grav(1,i,j,k) = grav
     lgrid%grav(2,i,j,k) = 0.0_rp

#ifdef EVOLVE_ETOT
     lgrid%phi_cc(i,j,k) = gpot
#endif
#ifdef USE_WB
     lgrid%eq_prim_cc(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_cc(ieq_p,i,j,k) = p_hse
     lgrid%eq_prim_cc(ieq_T,i,j,k) = T_hse
#endif

#ifdef THERMAL_DIFFUSION_STS
     lgrid%kappa(i,j,k) = 1.e-5_rp
#endif

   end do
  end do
 end do
 
 call deallocate_model(model)

end subroutine setup

subroutine load_model(filename, m)
  character(len=*), intent(in) :: filename
  type(model_t), intent(inout) :: m
  integer, parameter :: fp=23
  integer :: i, len

  open(unit=fp, file=filename)
  read(fp,*) len
  allocate(m%r(len), m%grav(len), m%gpot(len), m%rho(len), m%p(len), m%T(len))

  do i=1, len
    read(fp, *) m%r(i), m%grav(i), m%gpot(i), m%rho(i), m%p(i), m%T(i)
  end do

  close(fp)

end subroutine load_model

subroutine interpolate_model(m, r, grav, gpot, rho, pres, T)
  type(model_t), intent(in) :: m
  real(kind=rp), intent(in) :: r
  real(kind=rp), intent(out) :: grav, gpot, rho, pres, T

  real(kind=rp) :: fac, rr
  integer :: i

  rr = r

  if (rr < m%r(lbound(m%r,1))) then
    rr = m%r(lbound(m%r,1))
  end if

  if (rr > m%r(ubound(m%r,1))) then
    rr = m%r(ubound(m%r,1))
  end if

  i = minloc(abs(m%r(:) - rr),1)
  if (m%r(i) > rr) i = i - 1
  i = min(max(lbound(m%r,1),i),ubound(m%r,1)-1)

  fac = (rr - m%r(i)) / (m%r(i+1) - m%r(i))
  grav = fac * (m%grav(i+1) - m%grav(i)) + m%grav(i)
  gpot = fac * (m%gpot(i+1) - m%gpot(i)) + m%gpot(i)
  pres = fac * (m%p(i+1) - m%p(i)) + m%p(i)
  rho = fac * (m%rho(i+1) - m%rho(i)) + m%rho(i)
  T = fac * (m%T(i+1) - m%T(i)) + m%T(i)

end subroutine interpolate_model

subroutine deallocate_model(m)
  type(model_t), intent(inout) :: m
  deallocate(m%r, m%grav, m%gpot, m%rho, m%p, m%T)
end subroutine deallocate_model

end program test

#if defined(NONUNIFORM_RADIAL_NODES) || defined(GEOMETRY_2D_SPHERICAL)

 subroutine create_geometry(lgrid,mgrid)
   use source
   type(locgrid), intent(inout) :: lgrid
   type(mpigrid), intent(inout) :: mgrid

   real(kind=rp) :: r,theta,logr,logr1,logr2,dlogr,rmi,rpl
   real(kind=rp) :: sin_theta
   integer :: i,j,k

   logr1 = log(lgrid%x1l)
   logr2 = log(lgrid%x1u)

   dlogr = (logr2-logr1)/real(nx1,kind=rp)

   do k=lbound(lgrid%nodes,4),ubound(lgrid%nodes,4)
    do j=lbound(lgrid%nodes,3),ubound(lgrid%nodes,3)
     do i=lbound(lgrid%nodes,2),ubound(lgrid%nodes,2)

       logr = logr1 + real(i-1,kind=rp)*dlogr
       r = exp(logr)
       theta = lgrid%x2l + real(j-1,kind=rp)*lgrid%dx2

       sin_theta = sin(theta)

       lgrid%nodes(1,i,j,k) = r*sin_theta
       lgrid%nodes(2,i,j,k) = r*cos(theta)

       lgrid%sin_theta_cor(i,j,k) = sin_theta
       lgrid%r_cor(i,j,k) = r

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x1,4),ubound(lgrid%coords_x1,4)
    do j=lbound(lgrid%coords_x1,3),ubound(lgrid%coords_x1,3)
     do i=lbound(lgrid%coords_x1,2),ubound(lgrid%coords_x1,2)

        logr = logr1 + real(i-1,kind=rp)*dlogr
        r = exp(logr)
        theta = lgrid%x2l + real(j-0.5,kind=rp)*lgrid%dx2

        lgrid%coords_x1(1,i,j,k) = r*sin(theta)
        lgrid%coords_x1(2,i,j,k) = r*cos(theta)

        lgrid%r_x1(i,j,k) = r

     end do
    end do
   end do

   do k=lbound(lgrid%coords_x2,4),ubound(lgrid%coords_x2,4)
    do j=lbound(lgrid%coords_x2,3),ubound(lgrid%coords_x2,3)
     do i=lbound(lgrid%coords_x2,2),ubound(lgrid%coords_x2,2)

        logr = logr1 + real(i-1,kind=rp)*dlogr
        rmi = exp(logr)
        
        logr = logr1 + real(i,kind=rp)*dlogr
        rpl = exp(logr)
        
        r = 0.5_rp*(rmi+rpl)       

        theta = lgrid%x2l + real(j-1.0,kind=rp)*lgrid%dx2

        sin_theta = sin(theta)

        lgrid%coords_x2(1,i,j,k) = r*sin_theta
        lgrid%coords_x2(2,i,j,k) = r*cos(theta)

        lgrid%r_x2(i,j,k) = r
        lgrid%sin_theta_x2(i,j,k) = sin_theta

     end do
    end do
   end do

   do k=lbound(lgrid%coords,4),ubound(lgrid%coords,4)
    do j=lbound(lgrid%coords,3),ubound(lgrid%coords,3)
     do i=lbound(lgrid%coords,2),ubound(lgrid%coords,2)

        logr = logr1 + real(i-1,kind=rp)*dlogr
        rmi = exp(logr)
        
        logr = logr1 + real(i,kind=rp)*dlogr
        rpl = exp(logr)
        
        r = 0.5_rp*(rmi+rpl)       

        theta = lgrid%x2l + real(j-0.5,kind=rp)*lgrid%dx2

        sin_theta = sin(theta)

        lgrid%coords(1,i,j,k) = r*sin_theta
        lgrid%coords(2,i,j,k) = r*cos(theta)

        lgrid%sin_theta(i,j,k) = sin_theta
        lgrid%r(i,j,k) = r

     end do
    end do
   end do

   mgrid%dummy = 1.0_rp

 end subroutine create_geometry

#endif





