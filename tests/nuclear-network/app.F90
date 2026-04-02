program test
 use source
 
 type(mpigrid) :: mgrid
 type(locgrid) :: lgrid

 integer :: i,j,k,iv
 real(kind=rp) :: x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu
 real(kind=rp) :: rho,T,ye,abar,zbar,e,cv,c,p,inv_abar
 real(kind=rp), dimension(1:nspecies) :: Xs

 x1l = 0.0_rp
 x1u = 25.0e6_rp
 x2l = 0.0_rp
 x2u = 25.0e6_rp
 x3l = 0.0_rp
 x3u = 25.0e6_rp
 gamma_ad = 5.0_rp/3.0_rp

 rho = 1.0e4_rp 
 T = 2.0e8_rp 

 Xs(:) = 0.0_rp
 Xs(1)   = 0.5_rp
 Xs(2)   = 0.25_rp
 Xs(3)   = 0.25_rp

 mu = rp1

 call initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,x3l,x3u,gamma_ad,mu)

 inv_mu = 0.0_rp
 ye = 0.0_rp
 inv_abar = 0.0_rp
 do iv=1,nspecies
  inv_abar = inv_abar + Xs(iv)/lgrid%A(iv)
  ye = ye + Xs(iv)*lgrid%Z(iv)/lgrid%A(iv)
 end do 
 abar = 1.0_rp/inv_abar
 zbar = ye*abar

 do k=lbound(lgrid%prim,4),ubound(lgrid%prim,4)
  do j=lbound(lgrid%prim,3),ubound(lgrid%prim,3)
   do i=lbound(lgrid%prim,2),ubound(lgrid%prim,2)

     lgrid%prim(i_rho,i,j,k) = rho

     call helm_rhoT_given_full(rho,T,abar,zbar,p,e,c,cv)
     lgrid%prim(i_p,i,j,k) = p

     lgrid%temp(i,j,k) = T

     lgrid%prim(i_vx1,i,j,k) = 0.0_rp
     lgrid%prim(i_vx2,i,j,k) = 0.0_rp

     do iv=1,nspecies
      lgrid%prim(i_as1+iv-1,i,j,k) = Xs(iv)
     end do

   end do
  end do
 end do

 call time_loop(mgrid,lgrid)

 call finalize_simulation(lgrid)

end program test

#ifdef USE_NUCLEAR_NETWORK 
subroutine extract_network_information(lgrid) 
  use source 
  type(locgrid), intent(inout) :: lgrid 

  lgrid%A(1)=1.0_rp 
  lgrid%A(2)=4.0_rp 
  lgrid%A(3)=12.0_rp 
  lgrid%A(4)=13.0_rp 
  lgrid%A(5)=13.0_rp 
  lgrid%A(6)=14.0_rp 
  lgrid%A(7)=15.0_rp 
  lgrid%A(8)=14.0_rp 
  lgrid%A(9)=15.0_rp 

  lgrid%Z(1)=1.0_rp 
  lgrid%Z(2)=2.0_rp 
  lgrid%Z(3)=6.0_rp 
  lgrid%Z(4)=6.0_rp 
  lgrid%Z(5)=7.0_rp 
  lgrid%Z(6)=7.0_rp 
  lgrid%Z(7)=7.0_rp 
  lgrid%Z(8)=8.0_rp 
  lgrid%Z(9)=8.0_rp 

  lgrid%name_species(1)='p' 
  lgrid%name_species(2)='he4' 
  lgrid%name_species(3)='c12' 
  lgrid%name_species(4)='c13' 
  lgrid%name_species(5)='n13' 
  lgrid%name_species(6)='n14' 
  lgrid%name_species(7)='n15' 
  lgrid%name_species(8)='o14' 
  lgrid%name_species(9)='o15' 

  lgrid%name_reacs(1)='n13-->c13' 
  lgrid%name_reacs(2)='o14-->n14' 
  lgrid%name_reacs(3)='o15-->n15' 
  lgrid%name_reacs(4)='p+c12-->n13' 
  lgrid%name_reacs(5)='p+c13-->n14' 
  lgrid%name_reacs(6)='p+n13-->o14' 
  lgrid%name_reacs(7)='p+n14-->o15' 
  lgrid%name_reacs(8)='p+n15-->he4+c12' 

#ifdef USE_LMP_WEAK_RATES 
 
  allocate(lgrid%weak_table(1:0,1:13,1:11)) 
  allocate(lgrid%weak_neu(1:0,1:13,1:11)) 
  allocate(lgrid%neu_rates(1:0)) 

#endif 

#ifdef PARTITION_FUNCTIONS_FOR_REVERSE_RATES 
 
  lgrid%temp_part(1)=0.1000_rp 
  lgrid%temp_part(2)=0.1500_rp 
  lgrid%temp_part(3)=0.2000_rp 
  lgrid%temp_part(4)=0.3000_rp 
  lgrid%temp_part(5)=0.4000_rp 
  lgrid%temp_part(6)=0.5000_rp 
  lgrid%temp_part(7)=0.6000_rp 
  lgrid%temp_part(8)=0.7000_rp 
  lgrid%temp_part(9)=0.8000_rp 
  lgrid%temp_part(10)=0.9000_rp 
  lgrid%temp_part(11)=1.0000_rp 
  lgrid%temp_part(12)=1.5000_rp 
  lgrid%temp_part(13)=2.0000_rp 
  lgrid%temp_part(14)=2.5000_rp 
  lgrid%temp_part(15)=3.0000_rp 
  lgrid%temp_part(16)=3.5000_rp 
  lgrid%temp_part(17)=4.0000_rp 
  lgrid%temp_part(18)=4.5000_rp 
  lgrid%temp_part(19)=5.0000_rp 
  lgrid%temp_part(20)=6.0000_rp 
  lgrid%temp_part(21)=7.0000_rp 
  lgrid%temp_part(22)=8.0000_rp 
  lgrid%temp_part(23)=9.0000_rp 
  lgrid%temp_part(24)=10.0000_rp 

  allocate(lgrid%part(1:nspecies,1:24)) 

  lgrid%part(1,1)=0.000e+00_rp 
  lgrid%part(1,2)=0.000e+00_rp 
  lgrid%part(1,3)=0.000e+00_rp 
  lgrid%part(1,4)=0.000e+00_rp 
  lgrid%part(1,5)=0.000e+00_rp 
  lgrid%part(1,6)=0.000e+00_rp 
  lgrid%part(1,7)=0.000e+00_rp 
  lgrid%part(1,8)=0.000e+00_rp 
  lgrid%part(1,9)=0.000e+00_rp 
  lgrid%part(1,10)=0.000e+00_rp 
  lgrid%part(1,11)=0.000e+00_rp 
  lgrid%part(1,12)=0.000e+00_rp 
  lgrid%part(1,13)=0.000e+00_rp 
  lgrid%part(1,14)=0.000e+00_rp 
  lgrid%part(1,15)=0.000e+00_rp 
  lgrid%part(1,16)=0.000e+00_rp 
  lgrid%part(1,17)=0.000e+00_rp 
  lgrid%part(1,18)=0.000e+00_rp 
  lgrid%part(1,19)=0.000e+00_rp 
  lgrid%part(1,20)=0.000e+00_rp 
  lgrid%part(1,21)=0.000e+00_rp 
  lgrid%part(1,22)=0.000e+00_rp 
  lgrid%part(1,23)=0.000e+00_rp 
  lgrid%part(1,24)=0.000e+00_rp 

  lgrid%part(2,1)=0.000e+00_rp 
  lgrid%part(2,2)=0.000e+00_rp 
  lgrid%part(2,3)=0.000e+00_rp 
  lgrid%part(2,4)=0.000e+00_rp 
  lgrid%part(2,5)=0.000e+00_rp 
  lgrid%part(2,6)=0.000e+00_rp 
  lgrid%part(2,7)=0.000e+00_rp 
  lgrid%part(2,8)=0.000e+00_rp 
  lgrid%part(2,9)=0.000e+00_rp 
  lgrid%part(2,10)=0.000e+00_rp 
  lgrid%part(2,11)=0.000e+00_rp 
  lgrid%part(2,12)=0.000e+00_rp 
  lgrid%part(2,13)=0.000e+00_rp 
  lgrid%part(2,14)=0.000e+00_rp 
  lgrid%part(2,15)=0.000e+00_rp 
  lgrid%part(2,16)=0.000e+00_rp 
  lgrid%part(2,17)=0.000e+00_rp 
  lgrid%part(2,18)=0.000e+00_rp 
  lgrid%part(2,19)=0.000e+00_rp 
  lgrid%part(2,20)=0.000e+00_rp 
  lgrid%part(2,21)=0.000e+00_rp 
  lgrid%part(2,22)=0.000e+00_rp 
  lgrid%part(2,23)=0.000e+00_rp 
  lgrid%part(2,24)=0.000e+00_rp 

  lgrid%part(3,1)=0.000e+00_rp 
  lgrid%part(3,2)=0.000e+00_rp 
  lgrid%part(3,3)=0.000e+00_rp 
  lgrid%part(3,4)=0.000e+00_rp 
  lgrid%part(3,5)=0.000e+00_rp 
  lgrid%part(3,6)=0.000e+00_rp 
  lgrid%part(3,7)=0.000e+00_rp 
  lgrid%part(3,8)=0.000e+00_rp 
  lgrid%part(3,9)=0.000e+00_rp 
  lgrid%part(3,10)=0.000e+00_rp 
  lgrid%part(3,11)=0.000e+00_rp 
  lgrid%part(3,12)=0.000e+00_rp 
  lgrid%part(3,13)=0.000e+00_rp 
  lgrid%part(3,14)=0.000e+00_rp 
  lgrid%part(3,15)=0.000e+00_rp 
  lgrid%part(3,16)=0.000e+00_rp 
  lgrid%part(3,17)=0.000e+00_rp 
  lgrid%part(3,18)=0.000e+00_rp 
  lgrid%part(3,19)=0.000e+00_rp 
  lgrid%part(3,20)=0.000e+00_rp 
  lgrid%part(3,21)=0.000e+00_rp 
  lgrid%part(3,22)=0.000e+00_rp 
  lgrid%part(3,23)=0.000e+00_rp 
  lgrid%part(3,24)=0.000e+00_rp 

  lgrid%part(4,1)=0.000e+00_rp 
  lgrid%part(4,2)=0.000e+00_rp 
  lgrid%part(4,3)=0.000e+00_rp 
  lgrid%part(4,4)=0.000e+00_rp 
  lgrid%part(4,5)=0.000e+00_rp 
  lgrid%part(4,6)=0.000e+00_rp 
  lgrid%part(4,7)=0.000e+00_rp 
  lgrid%part(4,8)=0.000e+00_rp 
  lgrid%part(4,9)=0.000e+00_rp 
  lgrid%part(4,10)=0.000e+00_rp 
  lgrid%part(4,11)=0.000e+00_rp 
  lgrid%part(4,12)=0.000e+00_rp 
  lgrid%part(4,13)=0.000e+00_rp 
  lgrid%part(4,14)=0.000e+00_rp 
  lgrid%part(4,15)=0.000e+00_rp 
  lgrid%part(4,16)=0.000e+00_rp 
  lgrid%part(4,17)=0.000e+00_rp 
  lgrid%part(4,18)=0.000e+00_rp 
  lgrid%part(4,19)=0.000e+00_rp 
  lgrid%part(4,20)=0.000e+00_rp 
  lgrid%part(4,21)=0.000e+00_rp 
  lgrid%part(4,22)=0.000e+00_rp 
  lgrid%part(4,23)=0.000e+00_rp 
  lgrid%part(4,24)=0.000e+00_rp 

  lgrid%part(5,1)=0.000e+00_rp 
  lgrid%part(5,2)=0.000e+00_rp 
  lgrid%part(5,3)=0.000e+00_rp 
  lgrid%part(5,4)=0.000e+00_rp 
  lgrid%part(5,5)=0.000e+00_rp 
  lgrid%part(5,6)=0.000e+00_rp 
  lgrid%part(5,7)=0.000e+00_rp 
  lgrid%part(5,8)=0.000e+00_rp 
  lgrid%part(5,9)=0.000e+00_rp 
  lgrid%part(5,10)=0.000e+00_rp 
  lgrid%part(5,11)=0.000e+00_rp 
  lgrid%part(5,12)=0.000e+00_rp 
  lgrid%part(5,13)=0.000e+00_rp 
  lgrid%part(5,14)=0.000e+00_rp 
  lgrid%part(5,15)=0.000e+00_rp 
  lgrid%part(5,16)=0.000e+00_rp 
  lgrid%part(5,17)=0.000e+00_rp 
  lgrid%part(5,18)=0.000e+00_rp 
  lgrid%part(5,19)=0.000e+00_rp 
  lgrid%part(5,20)=0.000e+00_rp 
  lgrid%part(5,21)=0.000e+00_rp 
  lgrid%part(5,22)=0.000e+00_rp 
  lgrid%part(5,23)=0.000e+00_rp 
  lgrid%part(5,24)=0.000e+00_rp 

  lgrid%part(6,1)=0.000e+00_rp 
  lgrid%part(6,2)=0.000e+00_rp 
  lgrid%part(6,3)=0.000e+00_rp 
  lgrid%part(6,4)=0.000e+00_rp 
  lgrid%part(6,5)=0.000e+00_rp 
  lgrid%part(6,6)=0.000e+00_rp 
  lgrid%part(6,7)=0.000e+00_rp 
  lgrid%part(6,8)=0.000e+00_rp 
  lgrid%part(6,9)=0.000e+00_rp 
  lgrid%part(6,10)=0.000e+00_rp 
  lgrid%part(6,11)=0.000e+00_rp 
  lgrid%part(6,12)=0.000e+00_rp 
  lgrid%part(6,13)=0.000e+00_rp 
  lgrid%part(6,14)=0.000e+00_rp 
  lgrid%part(6,15)=0.000e+00_rp 
  lgrid%part(6,16)=0.000e+00_rp 
  lgrid%part(6,17)=0.000e+00_rp 
  lgrid%part(6,18)=0.000e+00_rp 
  lgrid%part(6,19)=0.000e+00_rp 
  lgrid%part(6,20)=0.000e+00_rp 
  lgrid%part(6,21)=0.000e+00_rp 
  lgrid%part(6,22)=0.000e+00_rp 
  lgrid%part(6,23)=0.000e+00_rp 
  lgrid%part(6,24)=0.000e+00_rp 

  lgrid%part(7,1)=0.000e+00_rp 
  lgrid%part(7,2)=0.000e+00_rp 
  lgrid%part(7,3)=0.000e+00_rp 
  lgrid%part(7,4)=0.000e+00_rp 
  lgrid%part(7,5)=0.000e+00_rp 
  lgrid%part(7,6)=0.000e+00_rp 
  lgrid%part(7,7)=0.000e+00_rp 
  lgrid%part(7,8)=0.000e+00_rp 
  lgrid%part(7,9)=0.000e+00_rp 
  lgrid%part(7,10)=0.000e+00_rp 
  lgrid%part(7,11)=0.000e+00_rp 
  lgrid%part(7,12)=0.000e+00_rp 
  lgrid%part(7,13)=0.000e+00_rp 
  lgrid%part(7,14)=0.000e+00_rp 
  lgrid%part(7,15)=0.000e+00_rp 
  lgrid%part(7,16)=0.000e+00_rp 
  lgrid%part(7,17)=0.000e+00_rp 
  lgrid%part(7,18)=0.000e+00_rp 
  lgrid%part(7,19)=0.000e+00_rp 
  lgrid%part(7,20)=0.000e+00_rp 
  lgrid%part(7,21)=0.000e+00_rp 
  lgrid%part(7,22)=0.000e+00_rp 
  lgrid%part(7,23)=0.000e+00_rp 
  lgrid%part(7,24)=0.000e+00_rp 

  lgrid%part(8,1)=0.000e+00_rp 
  lgrid%part(8,2)=0.000e+00_rp 
  lgrid%part(8,3)=0.000e+00_rp 
  lgrid%part(8,4)=0.000e+00_rp 
  lgrid%part(8,5)=0.000e+00_rp 
  lgrid%part(8,6)=0.000e+00_rp 
  lgrid%part(8,7)=0.000e+00_rp 
  lgrid%part(8,8)=0.000e+00_rp 
  lgrid%part(8,9)=0.000e+00_rp 
  lgrid%part(8,10)=0.000e+00_rp 
  lgrid%part(8,11)=0.000e+00_rp 
  lgrid%part(8,12)=0.000e+00_rp 
  lgrid%part(8,13)=0.000e+00_rp 
  lgrid%part(8,14)=0.000e+00_rp 
  lgrid%part(8,15)=0.000e+00_rp 
  lgrid%part(8,16)=0.000e+00_rp 
  lgrid%part(8,17)=0.000e+00_rp 
  lgrid%part(8,18)=0.000e+00_rp 
  lgrid%part(8,19)=0.000e+00_rp 
  lgrid%part(8,20)=0.000e+00_rp 
  lgrid%part(8,21)=0.000e+00_rp 
  lgrid%part(8,22)=0.000e+00_rp 
  lgrid%part(8,23)=0.000e+00_rp 
  lgrid%part(8,24)=0.000e+00_rp 

  lgrid%part(9,1)=0.000e+00_rp 
  lgrid%part(9,2)=0.000e+00_rp 
  lgrid%part(9,3)=0.000e+00_rp 
  lgrid%part(9,4)=0.000e+00_rp 
  lgrid%part(9,5)=0.000e+00_rp 
  lgrid%part(9,6)=0.000e+00_rp 
  lgrid%part(9,7)=0.000e+00_rp 
  lgrid%part(9,8)=0.000e+00_rp 
  lgrid%part(9,9)=0.000e+00_rp 
  lgrid%part(9,10)=0.000e+00_rp 
  lgrid%part(9,11)=0.000e+00_rp 
  lgrid%part(9,12)=0.000e+00_rp 
  lgrid%part(9,13)=0.000e+00_rp 
  lgrid%part(9,14)=0.000e+00_rp 
  lgrid%part(9,15)=0.000e+00_rp 
  lgrid%part(9,16)=0.000e+00_rp 
  lgrid%part(9,17)=0.000e+00_rp 
  lgrid%part(9,18)=0.000e+00_rp 
  lgrid%part(9,19)=0.000e+00_rp 
  lgrid%part(9,20)=0.000e+00_rp 
  lgrid%part(9,21)=0.000e+00_rp 
  lgrid%part(9,22)=0.000e+00_rp 
  lgrid%part(9,23)=0.000e+00_rp 
  lgrid%part(9,24)=0.000e+00_rp 

#endif 
 
end subroutine extract_network_information 

subroutine compute_jina_rates(T9,R) 
  use source 
  real(kind=rp), intent(in) :: T9 
  real(kind=rp), dimension(1:nreacs), intent(inout) :: R 

  real(kind=rp) :: logT9,cf,e1,e2,e3,e4,e5,tmp,tmpp 

  logT9 = log(T9) 
  cf = rp1/T9**fvthirds 
  e1 = T9**tthirds 
  e2 = e1*e1 
  e3 = e2*e1
  e4 = e3*e1 
  e5 = e4*e1 
  e1 = e1*cf 
  e2 = e2*cf 
  e3 = e3*cf
  e4 = e4*cf 
  e5 = e5*cf 
  tmp = rp0 
  tmpp = rp0 

  tmp=-6.760100e+00_rp
  R(1)=exp(tmp) 

  tmp=-4.623540e+00_rp
  R(2)=exp(tmp) 

  tmp=-5.170530e+00_rp
  R(3)=exp(tmp) 

  tmp=rp0 
  tmpp =1.754280e+01_rp & 
  -3.778490e+00_rp*e1 & 
  -5.107350e+00_rp*e2 & 
  -2.241110e+00_rp*e3 & 
  +1.488830e-01_rp*e4 & 
  -1.500000e+00_rp*logT9
  tmp=tmp+exp(tmpp) 
  tmpp =1.714820e+01_rp & 
  -1.369200e+01_rp*e2 & 
  -2.308810e-01_rp*e3 & 
  +4.443620e+00_rp*e4 & 
  -3.158980e+00_rp*e5 & 
  -6.666670e-01_rp*logT9
  tmp=tmp+exp(tmpp) 
  R(4)=tmp 
 
  tmp=rp0 
  tmpp =1.396370e+01_rp & 
  -5.781470e+00_rp*e1 & 
  -1.967030e-01_rp*e3 & 
  +1.421260e-01_rp*e4 & 
  -2.389120e-02_rp*e5 & 
  -1.500000e+00_rp*logT9
  tmp=tmp+exp(tmpp) 
  tmpp =1.851550e+01_rp & 
  -1.372000e+01_rp*e2 & 
  -4.500180e-01_rp*e3 & 
  +3.708230e+00_rp*e4 & 
  -1.705450e+00_rp*e5 & 
  -6.666670e-01_rp*logT9
  tmp=tmp+exp(tmpp) 
  R(5)=tmp 
 
  tmp=rp0 
  tmpp =1.099710e+01_rp & 
  -6.126020e+00_rp*e1 & 
  +1.571220e+00_rp*e2 & 
  -1.500000e+00_rp*logT9
  tmp=tmp+exp(tmpp) 
  tmpp =1.813560e+01_rp & 
  -1.516760e+01_rp*e2 & 
  +9.551660e-02_rp*e3 & 
  +3.065900e+00_rp*e4 & 
  -5.073390e-01_rp*e5 & 
  -6.666670e-01_rp*logT9
  tmp=tmp+exp(tmpp) 
  R(6)=tmp 
 
  tmp=rp0 
  tmpp =7.654440e+00_rp & 
  -2.998000e+00_rp*e1 & 
  -1.500000e+00_rp*logT9
  tmp=tmp+exp(tmpp) 
  tmpp =2.011690e+01_rp & 
  -1.519300e+01_rp*e2 & 
  -4.639750e+00_rp*e3 & 
  +9.734580e+00_rp*e4 & 
  -9.550510e+00_rp*e5 & 
  +3.333330e-01_rp*logT9
  tmp=tmp+exp(tmpp) 
  tmpp =1.701000e+01_rp & 
  -1.519300e+01_rp*e2 & 
  -1.619540e-01_rp*e3 & 
  -7.521230e+00_rp*e4 & 
  -9.875650e-01_rp*e5 & 
  -6.666670e-01_rp*logT9
  tmp=tmp+exp(tmpp) 
  tmpp =6.735780e+00_rp & 
  -4.891000e+00_rp*e1 & 
  +6.820000e-02_rp*logT9
  tmp=tmp+exp(tmpp) 
  R(7)=tmp 
 
  tmp=rp0 
  tmpp =2.089720e+01_rp & 
  -7.406000e+00_rp*e1 & 
  -1.500000e+00_rp*logT9
  tmp=tmp+exp(tmpp) 
  tmpp =-4.873470e+00_rp & 
  -2.021170e+00_rp*e1 & 
  +3.084970e+01_rp*e3 & 
  -8.504330e+00_rp*e4 & 
  -1.544260e+00_rp*e5 & 
  -1.500000e+00_rp*logT9
  tmp=tmp+exp(tmpp) 
  tmpp =2.747640e+01_rp & 
  -1.525300e+01_rp*e2 & 
  +1.593180e+00_rp*e3 & 
  +2.447900e+00_rp*e4 & 
  -2.197080e+00_rp*e5 & 
  -6.666670e-01_rp*logT9
  tmp=tmp+exp(tmpp) 
  tmpp =-6.575220e+00_rp & 
  -1.163800e+00_rp*e1 & 
  +2.271050e+01_rp*e3 & 
  -2.907070e+00_rp*e4 & 
  +2.057540e-01_rp*e5 & 
  -1.500000e+00_rp*logT9
  tmp=tmp+exp(tmpp) 
  R(8)=tmp 
 
end subroutine compute_jina_rates 

#ifdef USE_LMP_WEAK_RATES 
subroutine compute_weak_rates(rhoye,T9,dt,weak_table,weak_neu,neu_rates,R) 
  use source 
  real(kind=rp), intent(in) :: rhoye, T9, dt 
  real(kind=rp), dimension(1:0,1:13,1:11), intent(in) :: weak_table 
  real(kind=rp), dimension(1:0,1:13,1:11), intent(in) :: weak_neu 
  real(kind=rp), dimension(1:0), intent(inout) :: neu_rates 
  real(kind=rp), dimension(1:nreacs), intent(inout) :: R 


  real(kind=rp) :: logrhoye,tmp,u,v,omu,omv,omu_omv,u_omv,v_omu,u_v 
  real(kind=rp) :: lam_neu,E_neu_avg 
  integer :: i,idx_logrhoye,idx_T9
 
  logrhoye = log10(rhoye) 
  u = rp0 
  v = rp0 
  idx_T9 = 0 
  idx_logrhoye = 0 

  do i=1,12 
   if((T9>=weak_T9(i)) .and. (T9<weak_T9(i+1))) then 
    idx_T9 = i 
    tmp = weak_T9(i) 
    u = (T9-tmp)/(weak_T9(i+1)-tmp) 
    exit 
   end if 
  end do 

  do i=1,10 
   if((logrhoye>=weak_logrhoye(i)) .and. (logrhoye<weak_logrhoye(i+1))) then 
    idx_logrhoye = i 
    tmp = weak_logrhoye(i) 
    v = (logrhoye-tmp)/(weak_logrhoye(i+1)-tmp) 
    exit 
   end if 
  end do 

  omu=rp1-u 
  omv=rp1-v 
  omu_omv=omu*omv 
  u_omv=u*omv 
  v_omu=v*omu 
  u_v=u*v 

end subroutine compute_weak_rates 

subroutine compute_weak_neuloss(rho,Y,neu_rates,dedt) 
  use source 
  real(kind=rp), intent(in) :: rho 
  real(kind=rp), dimension(1:nspecies), intent(in) :: Y 
  real(kind=rp), dimension(1:0), intent(in) :: neu_rates 
  real(kind=rp), dimension(1:nreacs), intent(inout) :: dedt 

  real(kind=rp) :: fac 

  fac = rho*CONST_NAV_MEV_TO_ERG 

end subroutine compute_weak_neuloss 
#endif 

#ifdef PARTITION_FUNCTIONS_FOR_REVERSE_RATES 
subroutine use_partition_functions(T9,temp_part,part,R) 
  use source 
  real(kind=rp), intent(in) :: T9 
  real(kind=rp), intent(in) :: temp_part(1:24) 
  real(kind=rp), intent(in) :: part(1:nspecies,1:24) 
  real(kind=rp), dimension(1:nreacs), intent(inout) :: R 

  real(kind=rp) :: fac,tmp,tmpp 
  integer :: idx_temp,i 
  real(kind=rp) :: & 
  part1, & 
  part2, & 
  part3, & 
  part4, & 
  part5, & 
  part6, & 
  part7, & 
  part8, & 
  part9 
  idx_temp = 1 
  fac = rp1 
  tmp = rp1 
  tmpp = rp1 

  do i=1,23 
   if((T9>=temp_part(i)) .and. (T9<temp_part(i+1))) then 
    idx_temp = i 
    tmp = temp_part(i) 
    fac = (T9-tmp)/(temp_part(i+1)-tmp) 
    exit 
   end if 
  end do 

  part1=rp1 
  part2=rp1 
  part3=rp1 
  part4=rp1 
  part5=rp1 
  part6=rp1 
  part7=rp1 
  part8=rp1 
  part9=rp1 

end subroutine use_partition_functions 
#endif 

#ifdef USE_ELECTRON_SCREENING 
subroutine screen_rates(rho,T,Y,rates) 
  use source 
  real(kind=rp), intent(in) :: T 
  real(kind=rp), intent(in) :: rho 
  real(kind=rp), intent(in) :: Y(1:nspecies) 
  real(kind=rp), intent(inout) :: rates(1:nreacs) 

  real(kind=rp) :: ye,iabar,abar,zbar,Zk,Yk,fw 
  real(kind=rp) :: rhoye,gammap,gammapo4,lngammap,iT,iT3 
  real(kind=rp) :: gammaeff,Z1,Z2,A1,A2,Ahat,Zprod,Zsum 
  real(kind=rp) :: C,zt,jt,tau,b,b3,b4,b5,b6,Hs,Hw,H 
  real(kind=rp) :: Zsum_5_12,Z1_5_12,Z2_5_12 
  real(kind=rp) :: Zsum_5_3,Z1_5_3,Z2_5_3 

  Hw = rp0 
  A1 = rp0 
  A2 = rp0 
  A1 = rp0 
  Ahat = rp0 
  Z1_5_12 = rp0 
  Z2_5_12 = rp0 
  Zsum_5_12 = rp0 
  Z1_5_3 = rp0 
  Z2_5_3 = rp0 
  Zsum_5_3 = rp0 
  zt = rp0 
  jt = rp0 
  C = rp0 
  tau = rp0 
  b = rp0 
  b3 = rp0 
  b4 = rp0 
  b5 = rp0 
  b6 = rp0 
  Hs = rp0 

  ye = rp0 
  iabar = rp0 
  fw = rp0 
  Yk = Y(1) 
  Zk = 1.0_rp 
  ye = ye + Yk*Zk 
  iabar = iabar + Yk 
  fw = fw + Zk*Zk*Yk 
  Yk = Y(2) 
  Zk = 2.0_rp 
  ye = ye + Yk*Zk 
  iabar = iabar + Yk 
  fw = fw + Zk*Zk*Yk 
  Yk = Y(3) 
  Zk = 6.0_rp 
  ye = ye + Yk*Zk 
  iabar = iabar + Yk 
  fw = fw + Zk*Zk*Yk 
  Yk = Y(4) 
  Zk = 6.0_rp 
  ye = ye + Yk*Zk 
  iabar = iabar + Yk 
  fw = fw + Zk*Zk*Yk 
  Yk = Y(5) 
  Zk = 7.0_rp 
  ye = ye + Yk*Zk 
  iabar = iabar + Yk 
  fw = fw + Zk*Zk*Yk 
  Yk = Y(6) 
  Zk = 7.0_rp 
  ye = ye + Yk*Zk 
  iabar = iabar + Yk 
  fw = fw + Zk*Zk*Yk 
  Yk = Y(7) 
  Zk = 7.0_rp 
  ye = ye + Yk*Zk 
  iabar = iabar + Yk 
  fw = fw + Zk*Zk*Yk 
  Yk = Y(8) 
  Zk = 8.0_rp 
  ye = ye + Yk*Zk 
  iabar = iabar + Yk 
  fw = fw + Zk*Zk*Yk 
  Yk = Y(9) 
  Zk = 8.0_rp 
  ye = ye + Yk*Zk 
  iabar = iabar + Yk 
  fw = fw + Zk*Zk*Yk 

  abar = rp1/iabar 
  zbar = ye*abar 
  fw = fw + ye 

  iT = rp1/T 
  rhoye = rho*ye 
  gammap = CONST_S1*rhoye**othird*iT 
  gammapo4 = gammap**oquart 
  lngammap = log(gammap) 
  iT3 = iT*iT*iT 
  fw = CONST_S2*sqrt(fw*rho*iT3) 

  Z1 = 1.0_rp 
  Z2 = 6.0_rp 
  Zsum = Z1+Z2 
  Zprod = Z1*Z2 
  gammaeff = (rp2/Zsum)**othird*Zprod*gammap 
  if(gammaeff<0.3_rp) then 
   H = Zprod*fw 
  else if(gammaeff>0.8_rp) then 
   A1 = 1.0_rp 
   A2 = 12.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   H = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
  else 
   Hw = Zprod*fw 
   A1 = 1.0_rp 
   A2 = 12.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   Hs = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
   H = rp2*(0.8_rp-gammaeff)*Hw + rp2*(gammaeff-0.3_rp)*Hs 
  end if 
  rates(4) = rates(4)*exp(H) 

  Z1 = 1.0_rp 
  Z2 = 6.0_rp 
  Zsum = Z1+Z2 
  Zprod = Z1*Z2 
  gammaeff = (rp2/Zsum)**othird*Zprod*gammap 
  if(gammaeff<0.3_rp) then 
   H = Zprod*fw 
  else if(gammaeff>0.8_rp) then 
   A1 = 1.0_rp 
   A2 = 13.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   H = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
  else 
   Hw = Zprod*fw 
   A1 = 1.0_rp 
   A2 = 13.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   Hs = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
   H = rp2*(0.8_rp-gammaeff)*Hw + rp2*(gammaeff-0.3_rp)*Hs 
  end if 
  rates(5) = rates(5)*exp(H) 

  Z1 = 1.0_rp 
  Z2 = 7.0_rp 
  Zsum = Z1+Z2 
  Zprod = Z1*Z2 
  gammaeff = (rp2/Zsum)**othird*Zprod*gammap 
  if(gammaeff<0.3_rp) then 
   H = Zprod*fw 
  else if(gammaeff>0.8_rp) then 
   A1 = 1.0_rp 
   A2 = 13.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   H = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
  else 
   Hw = Zprod*fw 
   A1 = 1.0_rp 
   A2 = 13.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   Hs = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
   H = rp2*(0.8_rp-gammaeff)*Hw + rp2*(gammaeff-0.3_rp)*Hs 
  end if 
  rates(6) = rates(6)*exp(H) 

  Z1 = 1.0_rp 
  Z2 = 7.0_rp 
  Zsum = Z1+Z2 
  Zprod = Z1*Z2 
  gammaeff = (rp2/Zsum)**othird*Zprod*gammap 
  if(gammaeff<0.3_rp) then 
   H = Zprod*fw 
  else if(gammaeff>0.8_rp) then 
   A1 = 1.0_rp 
   A2 = 14.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   H = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
  else 
   Hw = Zprod*fw 
   A1 = 1.0_rp 
   A2 = 14.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   Hs = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
   H = rp2*(0.8_rp-gammaeff)*Hw + rp2*(gammaeff-0.3_rp)*Hs 
  end if 
  rates(7) = rates(7)*exp(H) 

  Z1 = 1.0_rp 
  Z2 = 7.0_rp 
  Zsum = Z1+Z2 
  Zprod = Z1*Z2 
  gammaeff = (rp2/Zsum)**othird*Zprod*gammap 
  if(gammaeff<0.3_rp) then 
   H = Zprod*fw 
  else if(gammaeff>0.8_rp) then 
   A1 = 1.0_rp 
   A2 = 15.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   H = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
  else 
   Hw = Zprod*fw 
   A1 = 1.0_rp 
   A2 = 15.0_rp 
   Ahat = A1*A2/(A1+A2) 
   Z1_5_12 = Z1**fvtwelfth 
   Z2_5_12 = Z2**fvtwelfth 
   Zsum_5_12 = Zsum**fvtwelfth 
   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 
   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 
   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 
   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 
   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 
   C = & 
   0.896434_rp*gammap*zt - & 
   3.44740_rp*gammapo4*jt - & 
   2.996_rp - & 
   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) 
   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird 
   b = rp3*gammaeff/tau 
   b3 = b*b*b 
   b4 = b3*b 
   b5 = b4*b 
   b6 = b5*b 
   Hs = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & 
   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) 
   H = rp2*(0.8_rp-gammaeff)*Hw + rp2*(gammaeff-0.3_rp)*Hs 
  end if 
  rates(8) = rates(8)*exp(H) 

end subroutine screen_rates 
#endif 

subroutine compute_network_residuals(Y,rho,R,res,jac,dedt,return_jac,return_dedt) 
  use source 
  real(kind=rp), dimension(1:nspecies), intent(in) :: Y 
  real(kind=rp), intent(in) :: rho 
  real(kind=rp), dimension(1:nreacs), intent(in) :: R 
  real(kind=rp), dimension(1:nspecies), intent(inout) :: res 
  real(kind=rp), dimension(1:nspecies,1:nspecies), intent(inout) :: jac 
  real(kind=rp), dimension(1:nreacs), intent(inout) :: dedt 
  logical, intent(in) :: return_jac 
  logical, intent(in) :: return_dedt 

  real(kind=rp) :: & 
  ye, & 
  lam1, & 
  lam2, & 
  lam3, & 
  lam4, & 
  lam5, & 
  lam6, & 
  lam7, & 
  lam8, & 
  R1, & 
  R2, & 
  R3, & 
  R4, & 
  R5, & 
  R6, & 
  R7, & 
  R8, & 
  Y1, & 
  Y2, & 
  Y3, & 
  Y4, & 
  Y5, & 
  Y6, & 
  Y7, & 
  Y8, & 
  Y9, & 
  dlam_dY_1_5, & 
  dlam_dY_2_8, & 
  dlam_dY_3_9, & 
  dlam_dY_4_1, & 
  dlam_dY_4_3, & 
  dlam_dY_5_1, & 
  dlam_dY_5_4, & 
  dlam_dY_6_1, & 
  dlam_dY_6_5, & 
  dlam_dY_7_1, & 
  dlam_dY_7_6, & 
  dlam_dY_8_1, & 
  dlam_dY_8_7, & 
  rho2 

  rho2 = rho*rho 
  ye=rp1 

  R1=R(1) 
  R2=R(2) 
  R3=R(3) 
  R4=R(4) 
  R5=R(5) 
  R6=R(6) 
  R7=R(7) 
  R8=R(8) 

  Y1=Y(1) 
  Y2=Y(2) 
  Y3=Y(3) 
  Y4=Y(4) 
  Y5=Y(5) 
  Y6=Y(6) 
  Y7=Y(7) 
  Y8=Y(8) 
  Y9=Y(9) 

  lam1=Y5*R1
  lam2=Y8*R2
  lam3=Y9*R3
  lam4=rho*Y1*Y3*R4
  lam5=rho*Y1*Y4*R5
  lam6=rho*Y1*Y5*R6
  lam7=rho*Y1*Y6*R7
  lam8=rho*Y1*Y7*R8

  res(1)= & 
  +lam4 & 
  +lam5 & 
  +lam6 & 
  +lam7 & 
  +lam8

  res(2)= & 
  -lam8

  res(3)= & 
  +lam4 & 
  -lam8

  res(4)= & 
  -lam1 & 
  +lam5

  res(5)= & 
  +lam1 & 
  -lam4 & 
  +lam6

  res(6)= & 
  -lam2 & 
  -lam5 & 
  +lam7

  res(7)= & 
  -lam3 & 
  +lam8

  res(8)= & 
  +lam2 & 
  -lam6

  res(9)= & 
  +lam3 & 
  -lam7

  if(return_jac) then 

   dlam_dY_1_5=R1 
   dlam_dY_2_8=R2 
   dlam_dY_3_9=R3 
   dlam_dY_4_1=rho*Y3*R4 
   dlam_dY_4_3=rho*Y1*R4 
   dlam_dY_5_1=rho*Y4*R5 
   dlam_dY_5_4=rho*Y1*R5 
   dlam_dY_6_1=rho*Y5*R6 
   dlam_dY_6_5=rho*Y1*R6 
   dlam_dY_7_1=rho*Y6*R7 
   dlam_dY_7_6=rho*Y1*R7 
   dlam_dY_8_1=rho*Y7*R8 
   dlam_dY_8_7=rho*Y1*R8 

   jac(1,1)= & 
   +dlam_dY_4_1 & 
   +dlam_dY_5_1 & 
   +dlam_dY_6_1 & 
   +dlam_dY_7_1 & 
   +dlam_dY_8_1

   jac(1,3)= & 
   +dlam_dY_4_3

   jac(1,4)= & 
   +dlam_dY_5_4

   jac(1,5)= & 
   +dlam_dY_6_5

   jac(1,6)= & 
   +dlam_dY_7_6

   jac(1,7)= & 
   +dlam_dY_8_7

   jac(2,1)= & 
   -dlam_dY_8_1

   jac(2,7)= & 
   -dlam_dY_8_7

   jac(3,1)= & 
   +dlam_dY_4_1 & 
   -dlam_dY_8_1

   jac(3,3)= & 
   +dlam_dY_4_3

   jac(3,7)= & 
   -dlam_dY_8_7

   jac(4,1)= & 
   +dlam_dY_5_1

   jac(4,4)= & 
   +dlam_dY_5_4

   jac(4,5)= & 
   -dlam_dY_1_5

   jac(5,1)= & 
   -dlam_dY_4_1 & 
   +dlam_dY_6_1

   jac(5,3)= & 
   -dlam_dY_4_3

   jac(5,5)= & 
   +dlam_dY_1_5 & 
   +dlam_dY_6_5

   jac(6,1)= & 
   -dlam_dY_5_1 & 
   +dlam_dY_7_1

   jac(6,4)= & 
   -dlam_dY_5_4

   jac(6,6)= & 
   +dlam_dY_7_6

   jac(6,8)= & 
   -dlam_dY_2_8

   jac(7,1)= & 
   +dlam_dY_8_1

   jac(7,7)= & 
   +dlam_dY_8_7

   jac(7,9)= & 
   -dlam_dY_3_9

   jac(8,1)= & 
   -dlam_dY_6_1

   jac(8,5)= & 
   -dlam_dY_6_5

   jac(8,8)= & 
   +dlam_dY_2_8

   jac(9,1)= & 
   -dlam_dY_7_1

   jac(9,6)= & 
   -dlam_dY_7_6

   jac(9,9)= & 
   +dlam_dY_3_9

   jac(2,2)=rp0 

  end if 

  if(return_dedt) then 

   dedt(1)=2.141974e+18_rp*lam1*rho 
   dedt(2)=4.962819e+18_rp*lam2*rho 
   dedt(3)=2.656820e+18_rp*lam3*rho 
   dedt(4)=1.874710e+18_rp*lam4*rho 
   dedt(5)=7.285607e+18_rp*lam5*rho 
   dedt(6)=4.465312e+18_rp*lam6*rho 
   dedt(7)=7.040342e+18_rp*lam7*rho 
   dedt(8)=4.791461e+18_rp*lam8*rho 

  end if 

end subroutine compute_network_residuals 
#endif 

#ifdef SAVE_SPECIES_FLUXES 
subroutine species_residuals_per_reac(Y,rho,R,Xds) 
  use source 
  real(kind=rp), dimension(1:nspecies), intent(in) :: Y 
  real(kind=rp), intent(in) :: rho 
  real(kind=rp), dimension(1:nreacs), intent(in) :: R 
  real(kind=rp), dimension(1:nspecies,1:nreacs), intent(inout) :: Xds 

  real(kind=rp) :: & 
  ye, & 
  lam1, & 
  lam2, & 
  lam3, & 
  lam4, & 
  lam5, & 
  lam6, & 
  lam7, & 
  lam8, & 
  R1, & 
  R2, & 
  R3, & 
  R4, & 
  R5, & 
  R6, & 
  R7, & 
  R8, & 
  Y1, & 
  Y2, & 
  Y3, & 
  Y4, & 
  Y5, & 
  Y6, & 
  Y7, & 
  Y8, & 
  Y9, & 
  rho2 

  rho2 = rho*rho 
  ye=rp1 

  R1=R(1) 
  R2=R(2) 
  R3=R(3) 
  R4=R(4) 
  R5=R(5) 
  R6=R(6) 
  R7=R(7) 
  R8=R(8) 

  Y1=Y(1) 
  Y2=Y(2) 
  Y3=Y(3) 
  Y4=Y(4) 
  Y5=Y(5) 
  Y6=Y(6) 
  Y7=Y(7) 
  Y8=Y(8) 
  Y9=Y(9) 

  lam1=Y5*R1
  lam2=Y8*R2
  lam3=Y9*R3
  lam4=rho*Y1*Y3*R4
  lam5=rho*Y1*Y4*R5
  lam6=rho*Y1*Y5*R6
  lam7=rho*Y1*Y6*R7
  lam8=rho*Y1*Y7*R8

  Xds(1,1) = rp0 
  Xds(1,2) = rp0 
  Xds(1,3) = rp0 
  Xds(1,4) = -lam4 
  Xds(1,5) = -lam5 
  Xds(1,6) = -lam6 
  Xds(1,7) = -lam7 
  Xds(1,8) = -lam8 
  Xds(2,1) = rp0 
  Xds(2,2) = rp0 
  Xds(2,3) = rp0 
  Xds(2,4) = rp0 
  Xds(2,5) = rp0 
  Xds(2,6) = rp0 
  Xds(2,7) = rp0 
  Xds(2,8) = lam8 
  Xds(3,1) = rp0 
  Xds(3,2) = rp0 
  Xds(3,3) = rp0 
  Xds(3,4) = -lam4 
  Xds(3,5) = rp0 
  Xds(3,6) = rp0 
  Xds(3,7) = rp0 
  Xds(3,8) = lam8 
  Xds(4,1) = lam1 
  Xds(4,2) = rp0 
  Xds(4,3) = rp0 
  Xds(4,4) = rp0 
  Xds(4,5) = -lam5 
  Xds(4,6) = rp0 
  Xds(4,7) = rp0 
  Xds(4,8) = rp0 
  Xds(5,1) = -lam1 
  Xds(5,2) = rp0 
  Xds(5,3) = rp0 
  Xds(5,4) = lam4 
  Xds(5,5) = rp0 
  Xds(5,6) = -lam6 
  Xds(5,7) = rp0 
  Xds(5,8) = rp0 
  Xds(6,1) = rp0 
  Xds(6,2) = lam2 
  Xds(6,3) = rp0 
  Xds(6,4) = rp0 
  Xds(6,5) = lam5 
  Xds(6,6) = rp0 
  Xds(6,7) = -lam7 
  Xds(6,8) = rp0 
  Xds(7,1) = rp0 
  Xds(7,2) = rp0 
  Xds(7,3) = lam3 
  Xds(7,4) = rp0 
  Xds(7,5) = rp0 
  Xds(7,6) = rp0 
  Xds(7,7) = rp0 
  Xds(7,8) = -lam8 
  Xds(8,1) = rp0 
  Xds(8,2) = -lam2 
  Xds(8,3) = rp0 
  Xds(8,4) = rp0 
  Xds(8,5) = rp0 
  Xds(8,6) = lam6 
  Xds(8,7) = rp0 
  Xds(8,8) = rp0 
  Xds(9,1) = rp0 
  Xds(9,2) = rp0 
  Xds(9,3) = -lam3 
  Xds(9,4) = rp0 
  Xds(9,5) = rp0 
  Xds(9,6) = rp0 
  Xds(9,7) = lam7 
  Xds(9,8) = rp0 

end subroutine species_residuals_per_reac 
#endif 

