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
 real(kind=rp) :: x,y,x0,y0,z0,r
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu

 real(kind=rp) :: L,abar,abar0
 real(kind=rp) :: rho_hse,p_hse,T_hse,gpot,grav,rho,rb,e_hse,sound,cv

 abar0 = 16.0_rp

 call load_model('hotbubble.in',model)

 L = 117702683.54861562_rp

 mu = 1.77777777777_rp
 gamma_ad = 5.0_rp/3.0_rp

 x1l = -L/4.0_rp
 x1u = +L/4.0_rp
 x2l = 0.0_rp
 x2u = L
 x3l = -L/2.0_rp
 x3u = +L/2.0_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)

 x0 = 0.0_rp
 y0 = L/5.0_rp
 z0 = 0.0_rp
 rb = L/10.0_rp

#if defined(EVOLVE_ETOT) || defined(USE_WB) 

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)
   do i=mgrid%i1(1),mgrid%i2(1)+1

     y = lgrid%coords_x1(2,i,j,k)

     call interpolate_model(model,y,grav,gpot,rho_hse,p_hse,T_hse)

     call helm_rhoT_given_full(rho_hse,T_hse,abar0,0.5_rp*abar0,p_hse,e_hse,sound,cv)

#ifdef EVOLVE_ETOT
     lgrid%phi_x1(i,j,k) = gpot
#endif
#ifdef USE_WB
     lgrid%eq_prim_x1(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_x1(ieq_p,i,j,k) = p_hse
#ifdef USE_FASTEOS
     e_hse = rho_hse*e_hse
     lgrid%eq_gammae_x1(i,j,k) = p_hse/e_hse+rp1
#endif
#endif

   end do
  end do
 end do

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)+1
   do i=mgrid%i1(1),mgrid%i2(1)

     y = lgrid%coords_x2(2,i,j,k)

     call interpolate_model(model,y,grav,gpot,rho_hse,p_hse,T_hse)

     call helm_rhoT_given_full(rho_hse,T_hse,abar0,0.5_rp*abar0,p_hse,e_hse,sound,cv)

#ifdef EVOLVE_ETOT
     lgrid%phi_x2(i,j,k) = gpot
#endif
#ifdef USE_WB
     lgrid%eq_prim_x2(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_x2(ieq_p,i,j,k) = p_hse
#ifdef USE_FASTEOS
     e_hse = rho_hse*e_hse
     lgrid%eq_gammae_x2(i,j,k) = p_hse/e_hse+rp1
#endif
#endif

   end do
  end do
 end do

#if sdims_make==3

 do k=mgrid%i1(3),mgrid%i2(3)+1
  do j=mgrid%i1(2),mgrid%i2(2)
   do i=mgrid%i1(1),mgrid%i2(1)
   
     y = lgrid%coords_x3(2,i,j,k)

     call interpolate_model(model,y,grav,gpot,rho_hse,p_hse,T_hse)

     call helm_rhoT_given_full(rho_hse,T_hse,abar0,0.5_rp*abar0,p_hse,e_hse,sound,cv)

#ifdef EVOLVE_ETOT
     lgrid%phi_x3(i,j,k) = gpot
#endif
#ifdef USE_WB
     lgrid%eq_prim_x3(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_x3(ieq_p,i,j,k) = p_hse
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

     call interpolate_model(model,y,grav,gpot,rho_hse,p_hse,T_hse)

     call helm_rhoT_given_full(rho_hse,T_hse,abar0,0.5_rp*abar0,p_hse,e_hse,sound,cv)

     r = sqrt((x-x0)**2+(y-y0)**2)/rb

     rho = rho_hse
     abar = abar0
     if(r<=1.0_rp) then
      rho = rho_hse*(1.0_rp-3.0e-3_rp*cos(CONST_PI*r/2.0_rp)**2)
      abar = abar0
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
#if sdims_make==3
     lgrid%prim(i_vx3,i,j,k) = 0.0_rp
#endif
     lgrid%grav(1,i,j,k) = 0.0_rp
     lgrid%grav(2,i,j,k) = grav
#if sdims_make==3
     lgrid%grav(3,i,j,k) = 0.0_rp
#endif
#ifdef EVOLVE_ETOT
     lgrid%phi_cc(i,j,k) = gpot
#endif
#ifdef USE_WB
     lgrid%eq_prim_cc(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_cc(ieq_p,i,j,k) = p_hse
#ifdef USE_FASTEOS
     e_hse = rho_hse*e_hse
     lgrid%eq_gammae_cc(i,j,k) = p_hse/e_hse+rp1
#endif
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
