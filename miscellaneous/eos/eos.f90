module eos_fort_mod
  implicit none

  public :: &
  rhoT_given_3d, &
  rhoP_given_3d, &
  PT_given_3d, &
  Ps_given_3d, &
  load_table

  double precision, parameter :: &
  CONST_RAD = 7.565767381646406d-15, &
  CONST_RGAS = 8.31446261815324d7, &
  CONST_C = 2.99792458d10, &
  CONST_C2 = 8.987551787368177d20, &
  CONST_PI = 3.141592653589793238d0, &
  CONST_AV = 6.02214076d23, &
  CONST_QE = 4.8032042712d-10, &
  CONST_KB = 1.380650424d-16, &
  CONST_MU = 1.660538782d-24, &
  CONST_H = 6.62606896d-27, &
  cc_a1 = -0.898004d0, &
  cc_b1 =  0.96786d0, &
  cc_c1 =  0.220703d0, &
  cc_d1 = -0.86097d0, &
  cc_e1 =  2.5269d0, &
  cc_a2 =  0.29561d0, &
  cc_b2 =  1.9885d0, &
  cc_c2 =  0.288675d0

  integer, parameter :: &
  id_f = 1, &
  id_dfdT = 2, &
  id_d2fdT2 = 3, &
  id_dfdrho = 4, &
  id_d2fdrho2 = 5, &
  id_d2fdrhodT = 6, &
  id_d3fdrho2dT = 7, &
  id_d3fdrhodT2 = 8, &
  id_d4fdrho2dT2 = 9, &
  id_c = 10, &
  id_dcdT = 11, &
  id_dcdrho = 12, &
  id_d2cdrhodT = 13, &
  id_eta = 14, &
  id_detadT = 15, &
  id_detadrho = 16, &
  id_d2etadrhodT = 17, &
  id_nep = 18, &
  id_dnepdT = 19, &
  id_dnepdrho = 20, &
  id_d2nepdrhodT = 21

  integer, parameter :: &
  eos_nvars = 23

  integer, parameter :: &
  id_P = 1, &
  id_E = 2, &
  id_dPdrho = 3, &
  id_dPdT = 4, &
  id_dEdrho = 5, &
  id_dEdT = 6, &
  id_cv = 7, &
  id_chiT = 8, &
  id_chirho = 9, &
  id_gam1 = 10, &
  id_sound = 11, &
  id_cp = 12, &
  id_gam2 = 13, &
  id_gam3 = 14, &
  id_nabla_ad = 15, &
  id_s = 16, &
  id_dsdrho = 17, &
  id_dsdT = 18, &
  id_delta = 19, &
  idt_eta = 20, &
  idt_nep = 21, &
  id_phi = 22, &
  id_dPdA = 23

contains

subroutine load_table(path_to_table, &
                      NRHO,NT, &
                      LOGRHOMIN,LOGRHOMAX,LOGTMIN,LOGTMAX, &
                      table_var,table_rho,table_T,table_drho,table_dT)
  implicit none

  character(len=*) :: path_to_table 
  integer, intent(in) :: NRHO,NT
  double precision, intent(in) :: LOGRHOMIN,LOGRHOMAX,LOGTMIN,LOGTMAX
  double precision, dimension(1:21,1:NRHO,1:NT), intent(out) :: table_var
  double precision, dimension(1:NRHO), intent(out) :: table_rho
  double precision, dimension(1:NT), intent(out) :: table_T
  double precision, intent(out) :: table_drho, table_dT

  integer :: i,j

  open(unit=21,file=path_to_table,status='old')

  table_drho = (LOGRHOMAX-LOGRHOMIN)/real(NRHO-1)
  table_dT = (LOGTMAX-LOGTMIN)/real(NT-1)

  do j=1,NT

   table_T(j) = 10**(LOGTMIN+real(j-1)*table_dT)

   do i=1,NRHO

     table_rho(i) = 10**(LOGRHOMIN+real(i-1)*table_drho)

     read(21,*) &
     table_var(id_f,i,j), &
     table_var(id_dfdrho,i,j), &
     table_var(id_dfdT,i,j), &
     table_var(id_d2fdrho2,i,j), &
     table_var(id_d2fdT2,i,j), &
     table_var(id_d2fdrhodT,i,j), &
     table_var(id_d3fdrho2dT,i,j), &
     table_var(id_d3fdrhodT2,i,j), &
     table_var(id_d4fdrho2dT2,i,j)

   end do
  end do

  do j=1,NT
   do i=1,NRHO

     read(21,*) &
     table_var(id_c,i,j), &
     table_var(id_dcdrho,i,j), &
     table_var(id_dcdT,i,j), &
     table_var(id_d2cdrhodT,i,j)

   end do
  end do

  do j=1,NT
   do i=1,NRHO

     read(21,*) &
     table_var(id_eta,i,j), &
     table_var(id_detadrho,i,j), &
     table_var(id_detadT,i,j), &
     table_var(id_d2etadrhodT,i,j)

   end do
  end do

  do j=1,NT
   do i=1,NRHO

     read(21,*) &
     table_var(id_nep,i,j), &
     table_var(id_dnepdrho,i,j), &
     table_var(id_dnepdT,i,j), &
     table_var(id_d2nepdrhodT,i,j)

   end do
  end do

  close(21)
  
end subroutine load_table

subroutine rhoT_given_3d(rho_arr,T_arr,abar_arr,zbar_arr, &
                         ideal,ions,radiation,elepos,coulomb,pig, & 
                         gamma_ideal, &
                         table, &
                         table_rho, table_T, &
                         table_drho, table_dT, &
                         eos_arr)

  implicit none

  double precision, intent(in)  :: rho_arr(:,:,:)
  double precision, intent(in)  :: T_arr(:,:,:)
  double precision, intent(in)  :: abar_arr(:,:,:)
  double precision, intent(in)  :: zbar_arr(:,:,:)
 
  logical, intent(in) :: ideal,ions,radiation,elepos,coulomb,pig

  double precision, intent(in) :: gamma_ideal

  double precision, intent(in) :: table(:,:,:)

  double precision, intent(in) :: table_rho(:),table_T(:)

  double precision, intent(in) :: table_drho,table_dT

  double precision, intent(out) :: eos_arr(1:23,size(rho_arr,1),size(rho_arr,2),size(rho_arr,3))

  integer :: i,j,k,iv

  double precision :: rho,T,abar,zbar
  double precision :: T2,T3,T4
  double precision :: tmp

  double precision :: Pid, dPid_drho, dPid_dT, Eid, dEid_dT, sid, dsid_drho, dsid_dT
  double precision :: Pio, dPio_drho, dPio_dT, Eio, dEio_dT, sio, dsio_drho, dsio_dT
  double precision :: Prad, dPrad_dT, Erad, dErad_drho, dErad_dT, srad, dsrad_drho, dsrad_dT
  double precision :: Pep, dPep_drho, dPep_dT, Eep, dEep_drho, dEep_dT, sep, dsep_drho, dsep_dT
  double precision :: Pc, dPc_drho, dPc_dT, Ec, dEc_drho, dEc_dT
  double precision :: P,dPdrho,dPdT,dpionda,lswot15,plasgda,ywot

  integer :: dummy

  integer :: n1,n2,n3 

  double precision :: &
  loc_eos1, &
  loc_eos2, &
  loc_eos3, &
  loc_eos4, &
  loc_eos5, &
  loc_eos6, &
  loc_eos7, &
  loc_eos8, &
  loc_eos9, &
  loc_eos10, &
  loc_eos11, &
  loc_eos12, &
  loc_eos13, &
  loc_eos14, &
  loc_eos15, &
  loc_eos16, &
  loc_eos17, &
  loc_eos18, &
  loc_eos19, &
  loc_eos20, &
  loc_eos21, &
  loc_eos22, &
  loc_eos23, &
  loc_eos24, &
  loc_eos25, &
  loc_eos26, &
  loc_eos27, &
  loc_eos28, &
  loc_eos29, &
  loc_eos30, &
  loc_eos31, &
  loc_eos32, &
  loc_eos33, &
  loc_eos34, &
  loc_eos35, &
  loc_eos36
 
  integer :: ih,jh
 
  double precision:: df_drho,df_dT,df_drhodT,df_dT2
  double precision :: f,Ye,rhos
  double precision :: zz,chiT,chirho,gam1,z,cv,sound,eta,nep
 
  double precision :: x,y,drho,drho2,dT,dT2
  double precision :: p0r,p0t,p0mr,p0mt,p1r,p1t,p1mr,p1mt,p2r,p2t,p2mr,p2mt,idrho,idrho2,idT,idT2
  double precision :: dp0r,dp1r,dp2r,dp0mr,dp1mr,dp2mr
  double precision :: dp0t,dp1t,dp2t,dp0mt,dp1mt,dp2mt
  double precision :: ddp0t,ddp1t,ddp2t,ddp0mt,ddp1mt,ddp2mt
  double precision :: omx,omy
  double precision :: x2,x3,x4,x5,y2,y3,y4,y5,omx2,omx3,omx4,omx5,omy2,omy3,omy4,omy5
 
  double precision :: &
  xni, &
  dxnidd, &
  dxnida, &
  ktinv, &
  dsdd, &
  dsda, &
  lami, &
  inv_lami, &
  lamidd, &
  lamida, &
  plasg, &
  plasgdd, &
  plasgdt, &
  ecoul, &
  pcoul, &
  dpcouldd, &
  dpcouldt, &
  decouldd, &
  decouldt

  double precision :: pion,dpiondt,dpiondd,s

  n1 = size(rho_arr,1)
  n2 = size(rho_arr,2)
  n3 = size(rho_arr,3)

  do k=1,n3
   do j=1,n2
    do i=1,n1

      do iv=1,eos_nvars
       eos_arr(iv,i,j,k) = 0.0d0
      end do

    end do
   end do
  end do

  if(ideal) then

   do k=1,n3
    do j=1,n2
     do i=1,n1

      rho = rho_arr(i,j,k)
      T = T_arr(i,j,k)

      abar = abar_arr(i,j,k)
      zbar = zbar_arr(i,j,k) 

      abar = abar/(zbar+1.0d0)

      tmp = 1.0d0/abar
      Pid = CONST_RGAS*rho*T*tmp
      dPid_dT = CONST_RGAS*rho*tmp
      dPid_drho = CONST_RGAS*T*tmp
      Eid = CONST_RGAS*T*tmp/(gamma_ideal-1.0d0)
      dEid_dT = CONST_RGAS*tmp/(gamma_ideal-1.0d0)

      eos_arr(id_P,i,j,k) = eos_arr(id_P,i,j,k) + Pid
      eos_arr(id_E,i,j,k) = eos_arr(id_E,i,j,k) + Eid
      eos_arr(id_dPdrho,i,j,k) = eos_arr(id_dPdrho,i,j,k) + dPid_drho
      eos_arr(id_dPdT,i,j,k) = eos_arr(id_dPdT,i,j,k) + dPid_dT
      eos_arr(id_dEdT,i,j,k) = eos_arr(id_dEdT,i,j,k) + dEid_dT
      eos_arr(id_dPdA,i,j,k) = eos_arr(id_dPdA,i,j,k)-rho*CONST_RGAS*T/abar**2

      lswot15 = 1.5d0*log((2.0d0*CONST_PI*CONST_MU*CONST_KB)/(CONST_H*CONST_H))
      ywot = log(abar*abar*sqrt(abar)/(rho*CONST_AV))
      y = ywot+lswot15+1.5d0*log(T)
      sid = (Pid/rho+Eid)/T + CONST_KB*CONST_AV*tmp*y
      dsid_drho = (dPid_drho/rho-Pid/(rho*rho))/T - CONST_KB*CONST_AV*tmp/rho
      dsid_dT = (dPid_dT/rho+dEid_dT)/T-(Pid/rho+Eid) / (T*T)+1.5d0*CONST_KB*CONST_AV*tmp/T
      eos_arr(id_s,i,j,k) = eos_arr(id_s,i,j,k) + sid
      eos_arr(id_dsdrho,i,j,k) = eos_arr(id_dsdrho,i,j,k) + dsid_drho
      eos_arr(id_dsdT,i,j,k) = eos_arr(id_dsdT,i,j,k) + dsid_dT

     end do
    end do
   end do

  else

   dummy = 0

  endif

  if(ions) then

   do k=1,n3
    do j=1,n2
     do i=1,n1

      rho = rho_arr(i,j,k)
      T = T_arr(i,j,k)
      abar = abar_arr(i,j,k)
      zbar = zbar_arr(i,j,k) 

      tmp = 1.0/abar
      Pio = CONST_RGAS*rho*T*tmp
      dPio_dT = CONST_RGAS*rho*tmp
      dPio_drho = CONST_RGAS*T*tmp
      Eio = CONST_RGAS*T*tmp/(gamma_ideal-1.0)
      dEio_dT = CONST_RGAS*tmp/(gamma_ideal-1.0)

      eos_arr(id_P,i,j,k) = eos_arr(id_P,i,j,k) + Pio
      eos_arr(id_E,i,j,k) = eos_arr(id_E,i,j,k) + Eio
      eos_arr(id_dPdrho,i,j,k) = eos_arr(id_dPdrho,i,j,k) + dPio_drho
      eos_arr(id_dPdT,i,j,k) = eos_arr(id_dPdT,i,j,k) + dPio_dT
      eos_arr(id_dEdT,i,j,k) = eos_arr(id_dEdT,i,j,k) + dEio_dT
      eos_arr(id_dPdA,i,j,k) = eos_arr(id_dPdA,i,j,k)-rho*CONST_RGAS*T/abar**2

      lswot15 = 1.5d0*log((2.0d0*CONST_PI*CONST_MU*CONST_KB)/(CONST_H*CONST_H))
      ywot = log(abar*abar*sqrt(abar)/(rho*CONST_AV))
      y = ywot+lswot15+1.5d0*log(T)
      sio = (Pio/rho+Eio)/T + CONST_KB*CONST_AV*tmp*y
      dsio_drho = (dPio_drho/rho-Pio/(rho*rho))/T - CONST_KB*CONST_AV*tmp/rho
      dsio_dT = (dPio_dT/rho+dEio_dT)/T-(Pio/rho+Eio) / (T*T)+1.5d0*CONST_KB*CONST_AV*tmp/T 
      eos_arr(id_s,i,j,k) = eos_arr(id_s,i,j,k) + sio
      eos_arr(id_dsdrho,i,j,k) = eos_arr(id_dsdrho,i,j,k) + dsio_drho
      eos_arr(id_dsdT,i,j,k) = eos_arr(id_dsdT,i,j,k) + dsio_dT

     end do
    end do
   end do

  else

   dummy = 0

  endif

  if(radiation) then
 
   do k=1,n3
    do j=1,n2
     do i=1,n1

      rho = rho_arr(i,j,k)
      T = T_arr(i,j,k)
  
      T2 = T*T
      T3 = T2*T
      T4 = T3*T
  
      Prad = CONST_RAD*T4/3.0d0
      dPrad_dT = 4.0d0/3.0d0*CONST_RAD*T3
      Erad = CONST_RAD*T4/rho
      dErad_dT = 4.0d0*CONST_RAD*T3/rho
      dErad_drho = -CONST_RAD*T4/(rho*rho)

      eos_arr(id_P,i,j,k) = eos_arr(id_P,i,j,k) + Prad
      eos_arr(id_E,i,j,k) = eos_arr(id_E,i,j,k) + Erad
      eos_arr(id_dPdT,i,j,k) = eos_arr(id_dPdT,i,j,k) + dPrad_dT
      eos_arr(id_dEdrho,i,j,k) = eos_arr(id_dEdrho,i,j,k) + dErad_drho
      eos_arr(id_dEdT,i,j,k) = eos_arr(id_dEdT,i,j,k) + dErad_dT

      srad = (Prad/rho+Erad)/T
      dsrad_drho = ((-Prad/rho)/rho+dErad_drho)/T
      dsrad_dT = (dPrad_dT/rho+dErad_dT-srad)/T

      eos_arr(id_s,i,j,k) = eos_arr(id_s,i,j,k) + srad
      eos_arr(id_dsdrho,i,j,k) = eos_arr(id_dsdrho,i,j,k) + dsrad_drho
      eos_arr(id_dsdT,i,j,k) = eos_arr(id_dsdT,i,j,k) + dsrad_dT

     end do
    end do
   end do

  else

    dummy = 0 

  end if

  if(elepos .or. pig) then

   do k=1,n3
    do j=1,n2
     do i=1,n1

      rho = rho_arr(i,j,k)
      T = T_arr(i,j,k)

      if(pig) then
       abar = 1.0d0
       zbar = 1.0d0
       Ye = 1.0d0
      else
       abar = abar_arr(i,j,k)
       zbar = zbar_arr(i,j,k) 
       Ye = zbar/abar
      endif

      rhos = rho*Ye
  
      ih = int((log10(rhos)-log10(table_rho(1)))/table_drho) + 1
      jh = int((log10(T)-log10(table_T(1)))/table_dT) + 1

      tmp = table_rho(ih)
      drho = table_rho(ih+1)-tmp
      x = (rhos-tmp)/drho
      omx = 1.0d0-x
  
      tmp = table_T(jh)
      dT = table_T(jh+1)-tmp
      y = (T-tmp)/dT
      omy = 1.0d0-y
  
      drho2 = drho*drho
      dT2 = dT*dT
  
      idrho = 1.0d0/drho
      idrho2 = idrho*idrho
  
      idT = 1.0d0/dT
      idT2 = idT*idT
     
      loc_eos1 = table(1,ih,jh)
      loc_eos2 = table(1,ih+1,jh)
      loc_eos3 = table(1,ih,jh+1)
      loc_eos4 = table(1,ih+1,jh+1)
      loc_eos5 = table(2,ih,jh)
      loc_eos6 = table(2,ih+1,jh)
      loc_eos7 = table(2,ih,jh+1)
      loc_eos8 = table(2,ih+1,jh+1)
      loc_eos9 = table(3,ih,jh)
      loc_eos10 = table(3,ih+1,jh)
      loc_eos11 = table(3,ih,jh+1)
      loc_eos12 = table(3,ih+1,jh+1)
      loc_eos13 = table(4,ih,jh)
      loc_eos14 = table(4,ih+1,jh)
      loc_eos15 = table(4,ih,jh+1)
      loc_eos16 = table(4,ih+1,jh+1)
      loc_eos17 = table(5,ih,jh)
      loc_eos18 = table(5,ih+1,jh)
      loc_eos19 = table(5,ih,jh+1)
      loc_eos20 = table(5,ih+1,jh+1)
      loc_eos21 = table(6,ih,jh)
      loc_eos22 = table(6,ih+1,jh)
      loc_eos23 = table(6,ih,jh+1)
      loc_eos24 = table(6,ih+1,jh+1)
      loc_eos25 = table(7,ih,jh)
      loc_eos26 = table(7,ih+1,jh)
      loc_eos27 = table(7,ih,jh+1)
      loc_eos28 = table(7,ih+1,jh+1)
      loc_eos29 = table(8,ih,jh)
      loc_eos30 = table(8,ih+1,jh)
      loc_eos31 = table(8,ih,jh+1)
      loc_eos32 = table(8,ih+1,jh+1)
      loc_eos33 = table(9,ih,jh)
      loc_eos34 = table(9,ih+1,jh)
      loc_eos35 = table(9,ih,jh+1)
      loc_eos36 = table(9,ih+1,jh+1)
         
      !f
     
      x2 = x*x
      x3 = x2*x
      x4 = x3*x
      x5 = x4*x
      p0r = -6.0d0*x5 + 15.0d0*x4 - 10.0d0*x3 + 1.0d0
      p1r = (-3.0d0*x5 + 8.0d0*x4 - 6.0d0*x3 + x)*drho
      p2r = (0.5d0*(-x5 + 3.0d0*x4 - 3.0d0*x3 + x2))*drho2
     
      omx2 = omx*omx
      omx3 = omx2*omx
      omx4 = omx3*omx
      omx5 = omx4*omx
      p0mr = -6.0d0*omx5 + 15.0d0*omx4 - 10.0d0*omx3 + 1.0d0
      p1mr =  (3.0d0*omx5 - 8.0d0*omx4 + 6.0d0*omx3 - omx)*drho
      p2mr =  (0.5d0*(-omx5 + 3.0d0*omx4 - 3.0d0*omx3 + omx2))*drho2
     
      y2 = y*y
      y3 = y2*y
      y4 = y3*y
      y5 = y4*y
      p0t = -6.0d0*y5 + 15.0d0*y4 - 10.0d0*y3 + 1.0d0
      p1t = (-3.0d0*y5 + 8.0d0*y4 - 6.0d0*y3 + y)*dT
      p2t = (0.5d0*(-y5 + 3.0d0*y4 - 3.0d0*y3 + y2))*dT2
     
      omy2 = omy*omy
      omy3 = omy2*omy
      omy4 = omy3*omy
      omy5 = omy4*omy
      p0mt = -6.0d0*omy5 + 15.0d0*omy4 - 10.0d0*omy3 + 1.0d0
      p1mt =  (3.0d0*omy5 - 8.0d0*omy4 + 6.0d0*omy3 - omy)*dT
      p2mt =  (0.5d0*(-omy5 + 3.0d0*omy4 - 3.0d0*omy3 + omy2))*dT2
     
      f = &
      loc_eos1*p0r*p0t + &
      loc_eos2*p0mr*p0t + &
      loc_eos3*p0r*p0mt + &
      loc_eos4*p0mr*p0mt + &
      loc_eos5*p0r*p1t + &
      loc_eos6*p0mr*p1t + &
      loc_eos7*p0r*p1mt + &
      loc_eos8*p0mr*p1mt + &
      loc_eos9*p0r*p2t + &
      loc_eos10*p0mr*p2t + &
      loc_eos11*p0r*p2mt + &
      loc_eos12*p0mr*p2mt + &
      loc_eos13*p1r*p0t + &
      loc_eos14*p1mr*p0t + &
      loc_eos15*p1r*p0mt + &
      loc_eos16*p1mr*p0mt + &
      loc_eos17*p2r*p0t + &
      loc_eos18*p2mr*p0t + &
      loc_eos19*p2r*p0mt + &
      loc_eos20*p2mr*p0mt + &
      loc_eos21*p1r*p1t + &
      loc_eos22*p1mr*p1t + &
      loc_eos23*p1r*p1mt + &
      loc_eos24*p1mr*p1mt + &
      loc_eos25*p2r*p1t + &
      loc_eos26*p2mr*p1t + &
      loc_eos27*p2r*p1mt + &
      loc_eos28*p2mr*p1mt + &
      loc_eos29*p1r*p2t + &
      loc_eos30*p1mr*p2t + &
      loc_eos31*p1r*p2mt + &
      loc_eos32*p1mr*p2mt + &
      loc_eos33*p2r*p2t + &
      loc_eos34*p2mr*p2t + &
      loc_eos35*p2r*p2mt + &
      loc_eos36*p2mr*p2mt
     
      !df_drho
     
      dp0r =  (-30.0d0*x4 + 60.0d0*x3 - 30.0d0*x2)*idrho
      dp1r =  (-15.0d0*x4 + 32.0d0*x3 - 18.0d0*x2 + 1.0d0)
      dp2r =  (0.5d0*(-5.0d0*x4 + 12.0d0*x3 - 9.0d0*x2 + 2.0d0*x))*drho
     
      dp0mr = -(-30.0d0*omx4 + 60.0d0*omx3 - 30.0d0*omx2)*idrho
      dp1mr =  (-15.0d0*omx4 + 32.0d0*omx3 - 18.0d0*omx2 + 1.0d0)
      dp2mr = -(0.5d0*(-5.0d0*omx4 + 12.0d0*omx3 - 9.0d0*omx2 + 2.0d0*omx))*drho
     
      df_drho = &
      loc_eos1*dp0r*p0t + &
      loc_eos2*dp0mr*p0t + &
      loc_eos3*dp0r*p0mt + &
      loc_eos4*dp0mr*p0mt + &
      loc_eos5*dp0r*p1t + &
      loc_eos6*dp0mr*p1t + &
      loc_eos7*dp0r*p1mt + &
      loc_eos8*dp0mr*p1mt + &
      loc_eos9*dp0r*p2t + &
      loc_eos10*dp0mr*p2t + &
      loc_eos11*dp0r*p2mt + &
      loc_eos12*dp0mr*p2mt + &
      loc_eos13*dp1r*p0t + &
      loc_eos14*dp1mr*p0t + &
      loc_eos15*dp1r*p0mt + &
      loc_eos16*dp1mr*p0mt + &
      loc_eos17*dp2r*p0t + &
      loc_eos18*dp2mr*p0t + &
      loc_eos19*dp2r*p0mt + &
      loc_eos20*dp2mr*p0mt + &
      loc_eos21*dp1r*p1t + &
      loc_eos22*dp1mr*p1t + &
      loc_eos23*dp1r*p1mt + &
      loc_eos24*dp1mr*p1mt + &
      loc_eos25*dp2r*p1t + &
      loc_eos26*dp2mr*p1t + &
      loc_eos27*dp2r*p1mt + &
      loc_eos28*dp2mr*p1mt + &
      loc_eos29*dp1r*p2t + &
      loc_eos30*dp1mr*p2t + &
      loc_eos31*dp1r*p2mt + &
      loc_eos32*dp1mr*p2mt + &
      loc_eos33*dp2r*p2t + &
      loc_eos34*dp2mr*p2t + &
      loc_eos35*dp2r*p2mt + &
      loc_eos36*dp2mr*p2mt
     
      !df_dT
     
      dp0t =  (-30.0d0*y4 + 60.0d0*y3 - 30.0d0*y2)*idT
      dp1t =  (-15.0d0*y4 + 32.0d0*y3 - 18.0d0*y2 + 1.0d0)
      dp2t =  (0.5d0*(-5.0d0*y4 + 12.0d0*y3 - 9.0d0*y2 + 2.0d0*y))*dT
     
      dp0mt = -(-30.0d0*omy4 + 60.0d0*omy3 - 30.0d0*omy2)*idT
      dp1mt =  (-15.0d0*omy4 + 32.0d0*omy3 - 18.0d0*omy2 + 1.0d0)
      dp2mt = -(0.5d0*(-5.0d0*omy4 + 12.0d0*omy3 - 9.0d0*omy2 + 2.0d0*omy))*dT
     
      df_dT = &
      loc_eos1*p0r*dp0t + &
      loc_eos2*p0mr*dp0t + &
      loc_eos3*p0r*dp0mt + &
      loc_eos4*p0mr*dp0mt + &
      loc_eos5*p0r*dp1t + &
      loc_eos6*p0mr*dp1t + &
      loc_eos7*p0r*dp1mt + &
      loc_eos8*p0mr*dp1mt + &
      loc_eos9*p0r*dp2t + &
      loc_eos10*p0mr*dp2t + &
      loc_eos11*p0r*dp2mt + &
      loc_eos12*p0mr*dp2mt + &
      loc_eos13*p1r*dp0t + &
      loc_eos14*p1mr*dp0t + &
      loc_eos15*p1r*dp0mt + &
      loc_eos16*p1mr*dp0mt + &
      loc_eos17*p2r*dp0t + &
      loc_eos18*p2mr*dp0t + &
      loc_eos19*p2r*dp0mt + &
      loc_eos20*p2mr*dp0mt + &
      loc_eos21*p1r*dp1t + &
      loc_eos22*p1mr*dp1t + &
      loc_eos23*p1r*dp1mt + &
      loc_eos24*p1mr*dp1mt + &
      loc_eos25*p2r*dp1t + &
      loc_eos26*p2mr*dp1t + &
      loc_eos27*p2r*dp1mt + &
      loc_eos28*p2mr*dp1mt + &
      loc_eos29*p1r*dp2t + &
      loc_eos30*p1mr*dp2t + &
      loc_eos31*p1r*dp2mt + &
      loc_eos32*p1mr*dp2mt + &
      loc_eos33*p2r*dp2t + &
      loc_eos34*p2mr*dp2t + &
      loc_eos35*p2r*dp2mt + &
      loc_eos36*p2mr*dp2mt
        
      !df_drhodT
     
      df_drhodT = &
      loc_eos1*dp0r*dp0t + &
      loc_eos2*dp0mr*dp0t + &
      loc_eos3*dp0r*dp0mt + &
      loc_eos4*dp0mr*dp0mt + &
      loc_eos5*dp0r*dp1t + &
      loc_eos6*dp0mr*dp1t + &
      loc_eos7*dp0r*dp1mt + &
      loc_eos8*dp0mr*dp1mt + &
      loc_eos9*dp0r*dp2t + &
      loc_eos10*dp0mr*dp2t + &
      loc_eos11*dp0r*dp2mt + &
      loc_eos12*dp0mr*dp2mt + &
      loc_eos13*dp1r*dp0t + &
      loc_eos14*dp1mr*dp0t + &
      loc_eos15*dp1r*dp0mt + &
      loc_eos16*dp1mr*dp0mt + &
      loc_eos17*dp2r*dp0t + &
      loc_eos18*dp2mr*dp0t + &
      loc_eos19*dp2r*dp0mt + &
      loc_eos20*dp2mr*dp0mt + &
      loc_eos21*dp1r*dp1t + &
      loc_eos22*dp1mr*dp1t + &
      loc_eos23*dp1r*dp1mt + &
      loc_eos24*dp1mr*dp1mt + &
      loc_eos25*dp2r*dp1t + &
      loc_eos26*dp2mr*dp1t + &
      loc_eos27*dp2r*dp1mt + &
      loc_eos28*dp2mr*dp1mt + &
      loc_eos29*dp1r*dp2t + &
      loc_eos30*dp1mr*dp2t + &
      loc_eos31*dp1r*dp2mt + &
      loc_eos32*dp1mr*dp2mt + &
      loc_eos33*dp2r*dp2t + &
      loc_eos34*dp2mr*dp2t + &
      loc_eos35*dp2r*dp2mt + &
      loc_eos36*dp2mr*dp2mt
        
      !df_dT2
     
      ddp0t =  (-120.0d0*y3 + 180.0d0*y2 - 60.0d0*y)*idT2
      ddp1t =  (-60.0d0*y3 + 96.0d0*y2 - 36.0d0*y)*idT
      ddp2t =  (0.5d0*(-20.0d0*y3 + 36.0d0*y2 - 18.0d0*y + 2.0d0))
     
      ddp0mt =  (-120.0d0*omy3 + 180.0d0*omy2 - 60.0d0*omy)*idT2
      ddp1mt = -(-60.0d0*omy3 + 96.0d0*omy2 - 36.0d0*omy)*idT
      ddp2mt =  (0.5d0*(-20.0d0*omy3 + 36.0d0*omy2 - 18.0d0*omy + 2.0d0))
     
      df_dT2 = &
      loc_eos1*p0r*ddp0t + &
      loc_eos2*p0mr*ddp0t + &
      loc_eos3*p0r*ddp0mt + &
      loc_eos4*p0mr*ddp0mt + &
      loc_eos5*p0r*ddp1t + &
      loc_eos6*p0mr*ddp1t + &
      loc_eos7*p0r*ddp1mt + &
      loc_eos8*p0mr*ddp1mt + &
      loc_eos9*p0r*ddp2t + &
      loc_eos10*p0mr*ddp2t + &
      loc_eos11*p0r*ddp2mt + &
      loc_eos12*p0mr*ddp2mt + &
      loc_eos13*p1r*ddp0t + &
      loc_eos14*p1mr*ddp0t + &
      loc_eos15*p1r*ddp0mt + &
      loc_eos16*p1mr*ddp0mt + &
      loc_eos17*p2r*ddp0t + &
      loc_eos18*p2mr*ddp0t + &
      loc_eos19*p2r*ddp0mt + &
      loc_eos20*p2mr*ddp0mt + &
      loc_eos21*p1r*ddp1t + &
      loc_eos22*p1mr*ddp1t + &
      loc_eos23*p1r*ddp1mt + &
      loc_eos24*p1mr*ddp1mt + &
      loc_eos25*p2r*ddp1t + &
      loc_eos26*p2mr*ddp1t + &
      loc_eos27*p2r*ddp1mt + &
      loc_eos28*p2mr*ddp1mt + &
      loc_eos29*p1r*ddp2t + &
      loc_eos30*p1mr*ddp2t + &
      loc_eos31*p1r*ddp2mt + &
      loc_eos32*p1mr*ddp2mt + &
      loc_eos33*p2r*ddp2t + &
      loc_eos34*p2mr*ddp2t + &
      loc_eos35*p2r*ddp2mt + &
      loc_eos36*p2mr*ddp2mt

      !dpdrho

      p0r = 2.0d0*x3-3.0d0*x2+1.0d0
      p1r = (x3-2.0d0*x2+x)*drho
     
      p0mr = 2.0d0*omx3-3.0d0*omx2+1.0d0
      p1mr = -(omx3-2.0d0*omx2+omx)*drho
     
      p0t = 2.0d0*y3-3.0d0*y2+1.0d0
      p1t = (y3-2.0d0*y2+y)*dT
     
      p0mt = 2.0d0*omy3-3.0d0*omy2+1.0d0
      p1mt = -(omy3-2.0d0*omy2+omy)*dT
     
      loc_eos1 = table(10,ih,jh)
      loc_eos2 = table(10,ih+1,jh)
      loc_eos3 = table(10,ih,jh+1)
      loc_eos4 = table(10,ih+1,jh+1)
      loc_eos5 = table(11,ih,jh)
      loc_eos6 = table(11,ih+1,jh)
      loc_eos7 = table(11,ih,jh+1)
      loc_eos8 = table(11,ih+1,jh+1)
      loc_eos9 = table(12,ih,jh)
      loc_eos10 = table(12,ih+1,jh)
      loc_eos11 = table(12,ih,jh+1)
      loc_eos12 = table(12,ih+1,jh+1)
      loc_eos13 = table(13,ih,jh)
      loc_eos14 = table(13,ih+1,jh)
      loc_eos15 = table(13,ih,jh+1)
      loc_eos16 = table(13,ih+1,jh+1)
     
      dPep_drho = &
      loc_eos1*p0r*p0t + &
      loc_eos2*p0mr*p0t + &
      loc_eos3*p0r*p0mt + &
      loc_eos4*p0mr*p0mt + &
      loc_eos5*p0r*p1t + &
      loc_eos6*p0mr*p1t + &
      loc_eos7*p0r*p1mt + &
      loc_eos8*p0mr*p1mt + &
      loc_eos9*p1r*p0t + &
      loc_eos10*p1mr*p0t + &
      loc_eos11*p1r*p0mt + &
      loc_eos12*p1mr*p0mt + &
      loc_eos13*p1r*p1t + &
      loc_eos14*p1mr*p1t + &
      loc_eos15*p1r*p1mt + &
      loc_eos16*p1mr*p1mt

      dPep_drho = Ye*dPep_drho

      !eta

      loc_eos1 = table(14,ih,jh)
      loc_eos2 = table(14,ih+1,jh)
      loc_eos3 = table(14,ih,jh+1)
      loc_eos4 = table(14,ih+1,jh+1)
      loc_eos5 = table(15,ih,jh)
      loc_eos6 = table(15,ih+1,jh)
      loc_eos7 = table(15,ih,jh+1)
      loc_eos8 = table(15,ih+1,jh+1)
      loc_eos9 = table(16,ih,jh)
      loc_eos10 = table(16,ih+1,jh)
      loc_eos11 = table(16,ih,jh+1)
      loc_eos12 = table(16,ih+1,jh+1)
      loc_eos13 = table(17,ih,jh)
      loc_eos14 = table(17,ih+1,jh)
      loc_eos15 = table(17,ih,jh+1)
      loc_eos16 = table(17,ih+1,jh+1)
     
      eta = &
      loc_eos1*p0r*p0t + &
      loc_eos2*p0mr*p0t + &
      loc_eos3*p0r*p0mt + &
      loc_eos4*p0mr*p0mt + &
      loc_eos5*p0r*p1t + &
      loc_eos6*p0mr*p1t + &
      loc_eos7*p0r*p1mt + &
      loc_eos8*p0mr*p1mt + &
      loc_eos9*p1r*p0t + &
      loc_eos10*p1mr*p0t + &
      loc_eos11*p1r*p0mt + &
      loc_eos12*p1mr*p0mt + &
      loc_eos13*p1r*p1t + &
      loc_eos14*p1mr*p1t + &
      loc_eos15*p1r*p1mt + &
      loc_eos16*p1mr*p1mt
       
      !nep

      loc_eos1 = table(18,ih,jh)
      loc_eos2 = table(18,ih+1,jh)
      loc_eos3 = table(18,ih,jh+1)
      loc_eos4 = table(18,ih+1,jh+1)
      loc_eos5 = table(19,ih,jh)
      loc_eos6 = table(19,ih+1,jh)
      loc_eos7 = table(19,ih,jh+1)
      loc_eos8 = table(19,ih+1,jh+1)
      loc_eos9 = table(20,ih,jh)
      loc_eos10 = table(20,ih+1,jh)
      loc_eos11 = table(20,ih,jh+1)
      loc_eos12 = table(20,ih+1,jh+1)
      loc_eos13 = table(21,ih,jh)
      loc_eos14 = table(21,ih+1,jh)
      loc_eos15 = table(21,ih,jh+1)
      loc_eos16 = table(21,ih+1,jh+1)
     
      nep = &
      loc_eos1*p0r*p0t + &
      loc_eos2*p0mr*p0t + &
      loc_eos3*p0r*p0mt + &
      loc_eos4*p0mr*p0mt + &
      loc_eos5*p0r*p1t + &
      loc_eos6*p0mr*p1t + &
      loc_eos7*p0r*p1mt + &
      loc_eos8*p0mr*p1mt + &
      loc_eos9*p1r*p0t + &
      loc_eos10*p1mr*p0t + &
      loc_eos11*p1r*p0mt + &
      loc_eos12*p1mr*p0mt + &
      loc_eos13*p1r*p1t + &
      loc_eos14*p1mr*p1t + &
      loc_eos15*p1r*p1mt + &
      loc_eos16*p1mr*p1mt
 
      tmp = rhos*rhos
      Pep = tmp*df_drho
      dPep_dT = tmp*df_drhodT
      sep = -Ye*df_dT
      dsep_dT = -Ye*df_dT2
      tmp = Ye*Ye
      dsep_drho = -df_drhodT*tmp
      Eep = Ye*f + T*sep
      dEep_dT = T*dsep_dT
      dEep_drho = df_drho*tmp + T*dsep_drho
    
      eos_arr(id_P,i,j,k) = eos_arr(id_P,i,j,k) + Pep
      eos_arr(id_E,i,j,k) = eos_arr(id_E,i,j,k) + Eep
      eos_arr(id_dPdrho,i,j,k) = eos_arr(id_dPdrho,i,j,k) + dPep_drho
      eos_arr(id_dPdT,i,j,k) = eos_arr(id_dPdT,i,j,k) + dPep_dT
      eos_arr(id_dEdrho,i,j,k) = eos_arr(id_dEdrho,i,j,k) + dEep_drho
      eos_arr(id_dEdT,i,j,k) = eos_arr(id_dEdT,i,j,k) + dEep_dT

      eos_arr(id_s,i,j,k) = eos_arr(id_s,i,j,k) + sep
      eos_arr(id_dsdrho,i,j,k) = eos_arr(id_dsdrho,i,j,k) + dsep_drho
      eos_arr(id_dsdT,i,j,k) = eos_arr(id_dsdT,i,j,k) + dsep_dT

      eos_arr(idt_eta,i,j,k) = eta
      eos_arr(idt_nep,i,j,k) = nep

      s = dPep_drho/Ye - 2.0d0*rhos*df_drho
      eos_arr(id_dPdA,i,j,k)  = eos_arr(id_dPdA,i,j,k) - (2.0d0*Pep+s*rhos)/abar

     end do
    end do
   end do
  
  else
 
    dummy = 0
  
  endif
  
  if(coulomb) then

   do k=1,n3
    do j=1,n2
     do i=1,n1

       rho = rho_arr(i,j,k)
       T = T_arr(i,j,k)
       abar = abar_arr(i,j,k)
       zbar = zbar_arr(i,j,k)
       tmp = 1d0/abar
       xni = CONST_AV*tmp*rho

       pion = CONST_RGAS*rho*T*tmp
       dpiondt = CONST_RGAS*rho*tmp
       dpiondd = CONST_RGAS*T*tmp
       dpionda = -rho*CONST_RGAS*T/abar**2

       dxnidd = CONST_AV*tmp
       dxnida = -xni*tmp

       ktinv = 1.0d0/(CONST_KB*T)

       z = 4.0d0/3.0d0*CONST_PI
       s = z*xni
       dsdd = z*dxnidd
       dsda = z*dxnida

       lami = 1.0d0/s**(1.0d0/3.0d0)
       inv_lami = 1.0d0/lami
       z = -1.0d0/3.0d0*lami
       lamidd = z*dsdd/s
       lamida = z*dsda/s

       plasg = zbar*zbar*CONST_QE*CONST_QE*ktinv*inv_lami
       z = -plasg*inv_lami
       plasgdd = z*lamidd
       plasgdt = -plasg*ktinv*CONST_KB
       plasgda = -plasg*inv_lami*lamida

       if (plasg>=1.0d0) then

        x        = plasg**0.25d0
        y        = CONST_AV*tmp*CONST_KB
        ecoul    = y*T*(cc_a1*plasg+cc_b1*x+cc_c1/x+cc_d1)
        pcoul    = 1.0d0/3.0d0*rho*ecoul

        eos_arr(id_s,i,j,k) = eos_arr(id_s,i,j,k)  &
        -y * (3.0d0*cc_b1*x-5.0d0*cc_c1/x+cc_d1*(log(plasg)-1.0d0)-cc_e1)

        y        = CONST_AV*tmp*CONST_KB*T*(cc_a1+0.25d0/plasg*(cc_b1*x-cc_c1/x))
        decouldd = y*plasgdd
        decouldt = y*plasgdt+ecoul/T
        eos_arr(id_dPdA,i,j,k) = eos_arr(id_dPdA,i,j,k) + rho*(y*plasgda-ecoul/abar)/3.0d0

        y        = 1.0d0/3.0d0*rho
        dpcouldd = 1.0d0/3.0d0*ecoul+y*decouldd
        dpcouldt = y*decouldt


        y = -CONST_AV*CONST_KB/(abar/plasg)*(0.75d0*cc_b1*x+1.25d0*cc_c1/x+cc_d1)
        eos_arr(id_dsdrho,i,j,k) = eos_arr(id_dsdrho,i,j,k) + y*plasgdd
        eos_arr(id_dsdT,i,j,k) = eos_arr(id_dsdT,i,j,k) + y*plasgdt

       else

        x        = plasg*sqrt(plasg)
        y        = plasg**cc_b2
        z        = cc_c2*x-1.0d0/3.0d0*cc_a2*y
        pcoul    = -pion*z
        ecoul    = 3.0d0*pcoul/rho

        eos_arr(id_s,i,j,k) = eos_arr(id_s,i,j,k) &
        -CONST_AV*CONST_KB/abar*(cc_c2*x-cc_a2*(cc_b2-1.0d0)/cc_b2*y)

        s        = 1.5d0*cc_c2*x/plasg-1.0d0/3.0d0*cc_a2*cc_b2*y/plasg
        dpcouldd = -dpiondd*z-pion*s*plasgdd
        dpcouldt = -dpiondt*z-pion*s*plasgdt
        eos_arr(id_dPdA,i,j,k) = eos_arr(id_dPdA,i,j,k)-dpionda*z-pion*s*plasgda

        s        = 3.0d0/rho
        decouldd = s*dpcouldd-ecoul/rho
        decouldt = s*dpcouldt

        s = -CONST_AV*CONST_KB/(abar*plasg)*(1.5d0*cc_c2*x-cc_a2*(cc_b2-1.0d0)*y)
        eos_arr(id_dsdrho,i,j,k) = eos_arr(id_dsdrho,i,j,k) + s*plasgdd
        eos_arr(id_dsdT,i,j,k) = eos_arr(id_dsdT,i,j,k) + s*plasgdt

       end if

       Pc = pcoul
       Ec = ecoul

       dPc_drho = dpcouldd
       dPc_dT = dpcouldt

       dEc_drho = decouldd
       dEc_dT = decouldt

       eos_arr(id_P,i,j,k) = eos_arr(id_P,i,j,k) + Pc
       eos_arr(id_E,i,j,k) = eos_arr(id_E,i,j,k) + Ec
       eos_arr(id_dPdrho,i,j,k) = eos_arr(id_dPdrho,i,j,k) + dPc_drho
       eos_arr(id_dPdT,i,j,k) = eos_arr(id_dPdT,i,j,k) + dPc_dT
       eos_arr(id_dEdrho,i,j,k) = eos_arr(id_dEdrho,i,j,k) + dEc_drho
       eos_arr(id_dEdT,i,j,k) = eos_arr(id_dEdT,i,j,k) + dEc_dT

     end do
    end do
   end do

  else

   dummy = 0

  endif

  do k=1,n3
   do j=1,n2
    do i=1,n1

     rho = rho_arr(i,j,k)
     T = T_arr(i,j,k)
     P = eos_arr(id_P,i,j,k)
     dPdrho = eos_arr(id_dPdrho,i,j,k)
     dPdT = eos_arr(id_dPdT,i,j,k)

     zz = P/rho
     cv = eos_arr(id_dEdT,i,j,k)
     chiT = T/P*dPdT
     chirho = dPdrho/zz
     x = zz*chiT/(T*cv)
     gam1 = chiT*x+chirho
     z = 1.0d0 + (eos_arr(id_E,i,j,k)+CONST_C2)/zz
     sound = CONST_C*sqrt(gam1/z)

     eos_arr(id_cv,i,j,k) = cv
     eos_arr(id_chiT,i,j,k) = chiT
     eos_arr(id_chirho,i,j,k) = chirho
     eos_arr(id_gam1,i,j,k) = gam1
     eos_arr(id_sound,i,j,k) = sound
     eos_arr(id_nabla_ad,i,j,k) = x/gam1
     eos_arr(id_delta,i,j,k) = T/rho*dPdT/dPdrho
     eos_arr(id_gam2,i,j,k) = 1.0d0 / (1.0d0 - eos_arr(id_nabla_ad,i,j,k))
     eos_arr(id_gam3,i,j,k) = x+1.0d0
     eos_arr(id_cp,i,j,k) = cv*gam1/chirho
     eos_arr(id_phi,i,j,k) = -abar_arr(i,j,k)/rho*eos_arr(id_dPdA,i,j,k)/dPdrho

    end do
   end do
  end do

end subroutine rhoT_given_3d

subroutine rhoP_given_3d(rho_arr,P_arr,Tg_arr,abar_arr,zbar_arr, &
                         ideal,ions,radiation,elepos,coulomb,pig, &
                         gamma_ideal, &
                         table, &
                         table_rho, table_T, &
                         table_drho, table_dT, &
                         eos_arr, &
                         T_arr)

  implicit none

  double precision, intent(in)  :: rho_arr(:,:,:)
  double precision, intent(in)  :: P_arr(:,:,:)
  double precision, intent(in)  :: Tg_arr(:,:,:)
  double precision, intent(in)  :: abar_arr(:,:,:)
  double precision, intent(in)  :: zbar_arr(:,:,:)

  logical, intent(in) :: ideal,ions,radiation,elepos,coulomb,pig
  double precision, intent(in) :: gamma_ideal
  double precision, intent(in) :: table(:,:,:)
  double precision, intent(in) :: table_rho(:),table_T(:)
  double precision, intent(in) :: table_drho,table_dT
  double precision, intent(out) :: eos_arr(1:23,size(rho_arr,1),size(rho_arr,2),size(rho_arr,3))
  double precision, intent(out) :: T_arr(size(rho_arr,1),size(rho_arr,2),size(rho_arr,3))

  integer :: i,j,k,iv,iter
  integer :: n1,n2,n3

  double precision :: T_sc(1,1,1),rho_sc(1,1,1),abar_sc(1,1,1),zbar_sc(1,1,1), &
  eos_sc(1:23,1,1,1)

  double precision :: error,P,res,Tmin,Tmax

  n1 = size(rho_arr,1)
  n2 = size(rho_arr,2)
  n3 = size(rho_arr,3)

  Tmin = minval(table_T)
  Tmax = maxval(table_T)

  do k=1,n3
   do j=1,n2
    do i=1,n1

        rho_sc(1,1,1) = rho_arr(i,j,k) 
        abar_sc(1,1,1) = abar_arr(i,j,k)
        zbar_sc(1,1,1) = zbar_arr(i,j,k)
        P = P_arr(i,j,k)

        T_sc(1,1,1) = Tg_arr(i,j,k)

        if(T_sc(1,1,1)<0.0d0) then
         T_sc(1,1,1) = abar_sc(1,1,1)/(zbar_sc(1,1,1)+1.0d0)*P/(rho_sc(1,1,1)*CONST_RGAS)
        endif

        do iter=1,1000

         call rhoT_given_3d(rho_sc,T_sc,abar_sc,zbar_sc, &
         ideal,ions,radiation,elepos,coulomb,pig, &
         gamma_ideal, &
         table, &
         table_rho, table_T, &
         table_drho, table_dT, &
         eos_sc)

         res = eos_sc(id_P,1,1,1)-P

         T_sc(1,1,1) = T_sc(1,1,1) - res/eos_sc(id_dPdT,1,1,1)

         if(T_sc(1,1,1)<Tmin) then 
           T_sc(1,1,1) = 1.1d0*Tmin
         endif
         if(T_sc(1,1,1)>Tmax) then 
           T_sc(1,1,1) = 0.9d0*Tmax
         endif
        
         error = abs(res/P)

         if(error<1.0d-11) exit

        end do

        if(iter>1000) write(*,*) 'NR not converged', error

        do iv=1,23
         eos_arr(iv,i,j,k) = eos_sc(iv,1,1,1)
        end do

        T_arr(i,j,k) = T_sc(1,1,1)

    end do
   end do
  end do

end subroutine rhoP_given_3d

subroutine PT_given_3d(P_arr,T_arr,rhog_arr,abar_arr,zbar_arr, &
                         ideal,ions,radiation,elepos,coulomb,pig, &
                         gamma_ideal, &
                         table, &
                         table_rho, table_T, &
                         table_drho, table_dT, &
                         eos_arr, &
                         rho_arr)

  implicit none

  double precision, intent(in)  :: P_arr(:,:,:)
  double precision, intent(in)  :: T_arr(:,:,:)
  double precision, intent(in)  :: rhog_arr(:,:,:)
  double precision, intent(in)  :: abar_arr(:,:,:)
  double precision, intent(in)  :: zbar_arr(:,:,:)

  logical, intent(in) :: ideal,ions,radiation,elepos,coulomb,pig
  double precision, intent(in) :: gamma_ideal
  double precision, intent(in) :: table(:,:,:)
  double precision, intent(in) :: table_rho(:),table_T(:)
  double precision, intent(in) :: table_drho,table_dT
  double precision, intent(out) :: eos_arr(1:23,size(P_arr,1),size(P_arr,2),size(P_arr,3))
  double precision, intent(out) :: rho_arr(size(P_arr,1),size(P_arr,2),size(P_arr,3))

  integer :: i,j,k,iv,iter
  integer :: n1,n2,n3

  double precision :: T_sc(1,1,1),rho_sc(1,1,1),abar_sc(1,1,1),zbar_sc(1,1,1), &
  eos_sc(1:23,1,1,1)

  double precision :: error,P,res,rhomin,rhomax,Ye

  n1 = size(P_arr,1)
  n2 = size(P_arr,2)
  n3 = size(P_arr,3)

  rhomin = minval(table_rho)
  rhomax = maxval(table_rho)

  do k=1,n3
   do j=1,n2
    do i=1,n1

        T_sc(1,1,1) = T_arr(i,j,k) 
        abar_sc(1,1,1) = abar_arr(i,j,k)
        zbar_sc(1,1,1) = zbar_arr(i,j,k)

        Ye = zbar_sc(1,1,1)/abar_sc(1,1,1)

        P = P_arr(i,j,k)

        rho_sc(1,1,1) = rhog_arr(i,j,k)

        if(rho_sc(1,1,1)<0.0d0) then
         rho_sc(1,1,1) = abar_sc(1,1,1)/(zbar_sc(1,1,1)+1.0d0)*P/(T_sc(1,1,1)*CONST_RGAS)
        endif

        do iter=1,1000

         call rhoT_given_3d(rho_sc,T_sc,abar_sc,zbar_sc, &
         ideal,ions,radiation,elepos,coulomb,pig, &
         gamma_ideal, &
         table, &
         table_rho, table_T, &
         table_drho, table_dT, &
         eos_sc)

         res = eos_sc(id_P,1,1,1)-P

         rho_sc(1,1,1) = rho_sc(1,1,1) - res/eos_sc(id_dPdrho,1,1,1)

         if(rho_sc(1,1,1)*Ye<rhomin) then 
           rho_sc(1,1,1) = 1.1d0*rhomin
         endif
         if(rho_sc(1,1,1)*Ye>rhomax) then 
           rho_sc(1,1,1) = 0.9d0*rhomax
         endif
        
         error = abs(res/P)

         if(error<1.0d-11) exit

        end do

        if(iter>1000) write(*,*) 'NR not converged', error

        do iv=1,23
         eos_arr(iv,i,j,k) = eos_sc(iv,1,1,1)
        end do

        rho_arr(i,j,k) = rho_sc(1,1,1)

    end do
   end do
  end do

end subroutine PT_given_3d

subroutine Ps_given_3d(P_arr,s_arr,rhog_arr,Tg_arr,abar_arr,zbar_arr, &
                         ideal,ions,radiation,elepos,coulomb,pig, &
                         gamma_ideal, &
                         table, &
                         table_rho, table_T, &
                         table_drho, table_dT, &
                         eos_arr, &
                         rho_arr,T_arr)

  implicit none

  double precision, intent(in)  :: P_arr(:,:,:)
  double precision, intent(in)  :: s_arr(:,:,:)
  double precision, intent(in)  :: rhog_arr(:,:,:)
  double precision, intent(in)  :: Tg_arr(:,:,:)
  double precision, intent(in)  :: abar_arr(:,:,:)
  double precision, intent(in)  :: zbar_arr(:,:,:)

  logical, intent(in) :: ideal,ions,radiation,elepos,coulomb,pig
  double precision, intent(in) :: gamma_ideal
  double precision, intent(in) :: table(:,:,:)
  double precision, intent(in) :: table_rho(:),table_T(:)
  double precision, intent(in) :: table_drho,table_dT
  double precision, intent(out) :: eos_arr(1:23,size(P_arr,1),size(P_arr,2),size(P_arr,3))
  double precision, intent(out) :: rho_arr(size(P_arr,1),size(P_arr,2),size(P_arr,3))
  double precision, intent(out) :: T_arr(size(P_arr,1),size(P_arr,2),size(P_arr,3))

  integer :: i,j,k,iv,iter
  integer :: n1,n2,n3

  double precision :: rho_sc(1,1,1),T_sc(1,1,1),abar_sc(1,1,1),zbar_sc(1,1,1), &
  eos_sc(1:23,1,1,1)

  double precision :: error,P,s,res(1:2),jac(2,2),ijac(2,2),rhomin,rhomax,Ye,Tmin,Tmax,det

  n1 = size(P_arr,1)
  n2 = size(P_arr,2)
  n3 = size(P_arr,3)

  rhomin = minval(table_rho)
  rhomax = maxval(table_rho)

  Tmin = minval(table_T)
  Tmax = maxval(table_T)

  do k=1,n3
   do j=1,n2
    do i=1,n1

        rho_sc(1,1,1) = rhog_arr(i,j,k)
        T_sc(1,1,1) = Tg_arr(i,j,k) 
        abar_sc(1,1,1) = abar_arr(i,j,k)
        zbar_sc(1,1,1) = zbar_arr(i,j,k)

        if(pig) then
         Ye = 1.0d0
        else
         Ye = zbar_sc(1,1,1)/abar_sc(1,1,1)
        endif

        P = P_arr(i,j,k)
        s = s_arr(i,j,k)

        do iter=1,1000

         call rhoT_given_3d(rho_sc,T_sc,abar_sc,zbar_sc, &
         ideal,ions,radiation,elepos,coulomb,pig, &
         gamma_ideal, &
         table, &
         table_rho, table_T, &
         table_drho, table_dT, &
         eos_sc)

         res(1) = eos_sc(id_P,1,1,1)-P
         res(2) = eos_sc(id_s,1,1,1)-s

         jac(1,1) = eos_sc(id_dPdrho,1,1,1)
         jac(1,2) = eos_sc(id_dPdT,1,1,1)
         jac(2,1) = eos_sc(id_dsdrho,1,1,1)
         jac(2,2) = eos_sc(id_dsdT,1,1,1)
          
         det = jac(1,1)*jac(2,2)-jac(1,2)*jac(2,1)
         det = 1.0d0/det

         ijac(1,1) = jac(2,2)*det
         ijac(1,2) = -jac(1,2)*det
         ijac(2,1) = -jac(2,1)*det
         ijac(2,2) = jac(1,1)*det

         rho_sc(1,1,1) = rho_sc(1,1,1) - ijac(1,1)*res(1) - ijac(1,2)*res(2)
         T_sc(1,1,1) = T_sc(1,1,1) - ijac(2,1)*res(1) - ijac(2,2)*res(2)
         
         if(rho_sc(1,1,1)*Ye<rhomin) then 
           rho_sc(1,1,1) = 1.1d0*rhomin
         endif
         if(rho_sc(1,1,1)*Ye>rhomax) then 
           rho_sc(1,1,1) = 0.9d0*rhomax
         endif
 
         if(T_sc(1,1,1)<Tmin) then 
           T_sc(1,1,1) = 1.1d0*Tmin
         endif
         if(T_sc(1,1,1)>Tmax) then 
           T_sc(1,1,1) = 0.9d0*Tmax
         endif
        
         error = abs(res(1)/P) + abs(res(2)/s)

         if(error<1.0d-11) exit

        end do

        if(iter>1000) write(*,*) 'NR not converged', error

        do iv=1,23
         eos_arr(iv,i,j,k) = eos_sc(iv,1,1,1)
        end do

        rho_arr(i,j,k) = rho_sc(1,1,1)
        T_arr(i,j,k) = T_sc(1,1,1)

    end do
   end do
  end do

end subroutine Ps_given_3d

end module eos_fort_mod
