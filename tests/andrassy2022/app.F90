program test
 use source
 implicit none

 type model_t
   integer :: len
   real(kind=rp), allocatable :: y(:),grav(:),gpot(:),fv(:),rho(:),pres(:)
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
 real(kind=rp) :: x,y,z,dy
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu

 real(kind=rp) :: rnd,rho_pert,fheat,Xcld
 real(kind=rp) :: grav,gpot,rho,pres,fv,rho_hse
 real(kind=rp) :: airmu,cldmu,avg_fact,drhoE0
 real(kind=rp) :: bx1=1.4673421507927957e-07_rp

 airmu=1.848_rp
 cldmu=1.802_rp
 call load_model('setup-two-layers.in',model)
 
 mu = 1.0_rp
 gamma_ad = 5.0_rp/3.0_rp

 x1l =  -1.0_rp
 x1u =  +1.0_rp
 x2l =  +1.0_rp
 x2u =  +3.0_rp
 x3l =  -1.0_rp
 x3u =  +1.0_rp

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)

 dy = lgrid%dx2
 avg_fact = sin(4.0_rp*CONST_PI*dy)/(4.0_rp*CONST_PI*dy)
 drhoE0 = 3.795720e-4_rp*avg_fact

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)
   do i=mgrid%i1(1),mgrid%i2(1)+1
 
     y = lgrid%coords_x1(2,i,j,k)
     call interpolate_model(model,y,grav,gpot,fv,rho,pres)

     lgrid%phi_x1(i,j,k) = gpot
     lgrid%eq_prim_x1(ieq_rho,i,j,k) = rho
     lgrid%eq_prim_x1(ieq_p,i,j,k) = pres
     lgrid%eq_prim_x1(ieq_T,i,j,k) = pres/(CONST_RGAS*rho)

#ifdef USE_MHD
     lgrid%b_x1(i,j,k) = bx1 
#endif

   end do
  end do
 end do

 do k=mgrid%i1(3),mgrid%i2(3)
  do j=mgrid%i1(2),mgrid%i2(2)+1
   do i=mgrid%i1(1),mgrid%i2(1)

     y = lgrid%coords_x2(2,i,j,k)
     call interpolate_model(model,y,grav,gpot,fv,rho,pres)

     lgrid%phi_x2(i,j,k) = gpot
     lgrid%eq_prim_x2(ieq_rho,i,j,k) = rho
     lgrid%eq_prim_x2(ieq_p,i,j,k) = pres
     lgrid%eq_prim_x2(ieq_T,i,j,k) = pres/(CONST_RGAS*rho)

#ifdef USE_MHD
     lgrid%b_x2(i,j,k) = 0.0_rp
#endif

   end do
  end do
 end do

#if sdims_make==3
 do k=mgrid%i1(3),mgrid%i2(3)+1
  do j=mgrid%i1(2),mgrid%i2(2)
   do i=mgrid%i1(1),mgrid%i2(1)

     y = lgrid%coords_x3(2,i,j,k)
     call interpolate_model(model,y,grav,gpot,fv,rho,pres)

     lgrid%phi_x3(i,j,k) = gpot
     lgrid%eq_prim_x3(ieq_rho,i,j,k) = rho
     lgrid%eq_prim_x3(ieq_p,i,j,k) = pres
     lgrid%eq_prim_x3(ieq_T,i,j,k) = pres/(CONST_RGAS*rho)

#ifdef USE_MHD
     lgrid%b_x3(i,j,k) = 0.0_rp 
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
#if sdims_make==3
     z = lgrid%coords(3,i,j,k)
#else
     z = rp0
#endif

     call interpolate_model(model,y,grav,gpot,fv,rho_hse,pres)
 
     Xcld = fv/((1.0_rp-fv)*(airmu/cldmu)+fv)

     fheat = sin(8.0_rp*CONST_PI*(y-1.0_rp))
     if (y<1.0_rp .or. y>1.125_rp) then
      fheat = 0.0_rp
     endif

     rho_pert = 5.0e-5_rp*fheat* &
     (sin(3.0_rp*CONST_PI*x)+cos(CONST_PI*x))*&
     (sin(3.0_rp*CONST_PI*z)-cos(CONST_PI*z))

     call random_number(rnd)

     rho_pert = rho_pert+5e-7_rp*(2.0_rp*rnd-1.0_rp)
     rho = rho_hse + rho_pert

     lgrid%prim(i_rho,i,j,k) = rho
     lgrid%prim(i_vx1,i,j,k) = 0.0_rp
     lgrid%prim(i_vx2,i,j,k) = 0.0_rp
#if sdims_make==3
     lgrid%prim(i_vx3,i,j,k) = 0.0_rp
#endif
     lgrid%prim(i_p,i,j,k) = pres
     lgrid%prim(i_as1,i,j,k) = Xcld 

     lgrid%grav(1,i,j,k) = 0.0_rp
     lgrid%grav(2,i,j,k) = grav
#if sdims_make==3
     lgrid%grav(3,i,j,k) = 0.0_rp
#endif

     lgrid%phi_cc(i,j,k) = gpot

     lgrid%eq_prim_cc(ieq_rho,i,j,k) = rho_hse
     lgrid%eq_prim_cc(ieq_p,i,j,k) = pres
     lgrid%eq_prim_cc(ieq_T,i,j,k) = pres/(CONST_RGAS*rho_hse)
     
     lgrid%edot(i,j,k) = fheat*drhoE0

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
  allocate(m%y(len),m%grav(len),m%gpot(len),m%fv(len),m%rho(len),m%pres(len))

  do i=1,len
    read(fp, *) m%y(i),m%grav(i),m%gpot(i),m%fv(i),m%rho(i),m%pres(i)
  end do

  close(fp)

end subroutine load_model

subroutine interpolate_model(m,y,grav,gpot,fv,rho,pres)
  type(model_t), intent(in) :: m
  real(kind=rp), intent(in) :: y
  real(kind=rp), intent(out) :: grav,gpot,fv,rho,pres

  real(kind=rp) :: fac, yy
  integer :: i

  yy = y

  if (yy < m%y(lbound(m%y,1))) then
    yy = m%y(lbound(m%y,1))
  end if

  if (yy > m%y(ubound(m%y,1))) then
    yy = m%y(ubound(m%y,1))
  end if

  i = minloc(abs(m%y(:) - yy),1)
  if (m%y(i) > yy) i = i - 1
  i = min(max(lbound(m%y,1),i),ubound(m%y,1)-1)

  fac = (yy - m%y(i)) / (m%y(i+1) - m%y(i))
  grav = fac * (m%grav(i+1) - m%grav(i)) + m%grav(i)
  gpot = fac * (m%gpot(i+1) - m%gpot(i)) + m%gpot(i)
  rho = fac * (m%rho(i+1) - m%rho(i)) + m%rho(i)
  pres = fac * (m%pres(i+1) - m%pres(i)) + m%pres(i)
  fv = fac * (m%fv(i+1) - m%fv(i)) + m%fv(i)

end subroutine interpolate_model

subroutine deallocate_model(m)
  type(model_t), intent(inout) :: m
  deallocate(m%y,m%grav,m%gpot,m%fv,m%rho,m%pres)
end subroutine deallocate_model

end program test
