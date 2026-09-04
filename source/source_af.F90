module source
 use mpi
 use hdf5

 implicit none

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! TYPES
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 integer, parameter :: &
 rp=8

 integer, parameter :: &
 MPI_RP=MPI_REAL8

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! MAKEFILE OPTS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  integer, parameter :: nx1 = &
#ifdef nx1_make
  nx1_make
#else
  1
#endif

 integer, parameter :: nx2 = &
#ifdef nx2_make
  nx2_make
#else
  1
#endif

 integer, parameter :: ddx1 = &
#ifdef ddx1_make
  ddx1_make
#else
  1
#endif

 integer, parameter :: ddx2 = &
#ifdef ddx2_make
  ddx2_make
#else
  1
#endif

 integer, parameter :: ngc = &
#ifdef ngc_make
  ngc_make
#else
  2
#endif

 real(kind=rp), parameter :: cfl = &
#ifdef cfl_make
  cfl_make
#else
  0.8_rp
#endif

 real(kind=rp), parameter :: tmax = &
#ifdef tmax_make
  tmax_make
#else
  30.0_rp
#endif

 integer, parameter :: nvars = &
#ifdef nvars_make
  nvars_make
#else
  4
#endif

#ifdef OUTPUT_DT
 real(kind=rp), parameter :: dt_dump = &
#ifdef dt_dump_make
  dt_dump_make
#else
  1.5_rp
#endif
#endif
  
 integer, parameter :: info_terminal_rate = &
#ifdef info_terminal_rate_make
  info_terminal_rate_make
#else
  100000
#endif

 integer, parameter :: master_rank=0
 integer, parameter :: filename_size=256
 integer, parameter :: iunit=21
 integer, parameter :: idummy=0

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! INDEXES
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 integer, parameter :: &
 i_rho = 1, &
 i_vx1 = 2, &
 i_vx2 = 3, &
 i_p = i_vx2+1, &
 i_rhovx1 = i_vx1, &
 i_rhovx2 = i_vx2, &
 i_rhoe = i_p

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! NUMBERS 
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 real(kind=rp), parameter :: &
 rph = 0.5_rp, &
 rpoh = 1.5_rp, &
 rpth = 2.5_rp, &
 rp0 = 0.0_rp, &
 rp1 = 1.0_rp, &
 rp2 = 2.0_rp, &
 rp3 = 3.0_rp, &
 rp4 = 4.0_rp, &
 rp5 = 5.0_rp, &
 rp6 = 6.0_rp, &
 rp7 = 7.0_rp, &
 rp8 = 8.0_rp, &
 rp9 = 9.0_rp, &
 rp10 = 10.0_rp, &
 rp11 = 11.0_rp, &
 rp12 = 12.0_rp, &
 rp13 = 13.0_rp, &
 rp14 = 14.0_rp, &
 rp15 = 15.0_rp, &
 rp16 = 16.0_rp, &
 rp17 = 17.0_rp, &
 rp18 = 18.0_rp, &
 rp19 = 19.0_rp, &
 rp20 = 20.0_rp, &
 rp21 = 21.0_rp, &
 rp25 = 25.0_rp, &
 rp30 = 30.0_rp, &
 rp32 = 32.0_rp, &
 rp36 = 36.0_rp, &
 rp38 = 38.0_rp, &
 rp60 = 60.0_rp, &
 rp91 = 91.0_rp, &
 rp96 = 96.0_rp, &
 rp120 = 120.0_rp, &
 rp180 = 180.0_rp, &
 rp189 = 189.0_rp, &
 rp329 = 329.0_rp, &
 othird = 1.0_rp/3.0_rp, &
 tthirds = 2.0_rp/3.0_rp, &
 fthirds = 4.0_rp/3.0_rp, &
 fvthirds = 5.0_rp/3.0_rp, &
 oquart = 0.25_rp, &
 tquarts = 0.75_rp, &
 osixth = 1.0_rp/6.0_rp, &
 fvsixth = 5.0_rp/6.0_rp, &
 fvtwelfth = 5.0_rp/12.0_rp, &
 o420 = 1.0_rp/420.0_rp, &
 ep3 = 1.0e3_rp, &
 ep13 = 1.0e13_rp, &
 em9 = 1.0e-9_rp, &
 em11 = 1.0e-11_rp, &
 em14 = 1.0e-14_rp, &
 em15 = 1.0e-15_rp

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! PHYSICAL CONSTANTS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 real(kind=rp), parameter :: &
 CONST_PI = 3.141592653589793238_rp

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! MPI UTILS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 type mpigrid

    integer, dimension(2) :: i1,i2,coords_dd,bricks
    logical, dimension(2) :: periodic
    integer :: comm_cart,wsize,rankl,nx1l,nx2l,nx3l
    real(kind=rp) :: wctgi
    real(kind=rp) :: dummy

 end type mpigrid

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! LOCAL GRID
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 type locgrid

    real(kind=rp) :: x1l,x1u,x2l,x2u

    real(kind=rp) :: dx1,dx2,inv_dx1,inv_dx2
    
    real(kind=rp) :: dt,time,tnextoutput
    
    real(kind=rp) :: gm,mu

    integer :: step

    real(kind=rp), allocatable, dimension(:,:,:) :: &
    coords_cc,coords_x1,coords_x2,coords_cor
    
    real(kind=rp), allocatable, dimension(:,:,:) :: &
    q_cc,qbar_cc,q_x1,q_x2,q_cor   

    real(kind=rp), allocatable, dimension(:,:,:) :: &
    flux_x1,flux_x2,flux_cor   

    real(kind=rp), allocatable, dimension(:,:,:) :: &
    res_cc,res_x1,res_x2,res_cor   

    real(kind=rp), allocatable, dimension(:,:,:) :: &
    qbar0_cc,q0_x1,q0_x2,q0_cor
    
    real(kind=rp), allocatable, dimension(:,:,:) :: &
    grav_cc,grav_x1,grav_x2,grav_cor

 end type locgrid
 
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! HDF5 SPECS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 type h5_file

  character(len=filename_size) :: filename

  integer(kind=HID_T) :: file_id,pref_dtypef,pref_dtypei

 end type h5_file

contains

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! INITIALIZE MPI AND ALLOCATION OF GRID QUANTITIES
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 subroutine initialize_simulation(mgrid,lgrid,x1l,x1u,x2l,x2u,gamma_ad,mu)
    type(mpigrid), intent(inout) :: mgrid
    type(locgrid), intent(inout) :: lgrid
    real(kind=rp), intent(in) :: x1l,x1u,x2l,x2u
    real(kind=rp), intent(in) :: gamma_ad,mu

    integer :: ierr
    logical :: isinitialized,reorder
    integer :: lx1,ux1,lx2,ux2

    mgrid%bricks(1) = ddx1
    mgrid%bricks(2) = ddx2

    mgrid%nx1l = int(nx1/ddx1)
    mgrid%nx2l = int(nx2/ddx2)

#ifdef X1_PERIODIC
    mgrid%periodic(1) = .true.
#else
    mgrid%periodic(1) = .false.
#endif

#ifdef X2_PERIODIC
    mgrid%periodic(2) = .true.
#else
    mgrid%periodic(2) = .false.
#endif



    call mpi_initialized(isinitialized, ierr)
    call mpi_init(ierr)

    reorder = .true.

    call mpi_cart_create(MPI_COMM_WORLD, 2, mgrid%bricks, mgrid%periodic, reorder, mgrid%comm_cart, ierr)

    call mpi_comm_rank(mgrid%comm_cart,mgrid%rankl,ierr)

    call mpi_comm_size(mgrid%comm_cart,mgrid%wsize,ierr)

    mgrid%coords_dd(:) = 0

    call mpi_cart_coords(mgrid%comm_cart,mgrid%rankl,2,mgrid%coords_dd,ierr)
    call mpi_barrier(mgrid%comm_cart,ierr)
    mgrid%wctgi = get_wtime(mgrid)

    mgrid%i1(1) = int(mgrid%coords_dd(1)*mgrid%nx1l+1)
    mgrid%i2(1) = int((mgrid%coords_dd(1)+1)*mgrid%nx1l)

    mgrid%i1(2) = int(mgrid%coords_dd(2)*mgrid%nx2l+1)
    mgrid%i2(2) = int((mgrid%coords_dd(2)+1)*mgrid%nx2l)

    lx1 = mgrid%i1(1)
    ux1 = mgrid%i2(1)
    lx2 = mgrid%i1(2)
    ux2 = mgrid%i2(2)

    lgrid%x1l = x1l
    lgrid%x1u = x1u

    lgrid%x2l = x2l
    lgrid%x2u = x2u

    lgrid%dx1 = (lgrid%x1u - lgrid%x1l) / real(nx1,kind=rp)
    lgrid%dx2 = (lgrid%x2u - lgrid%x2l) / real(nx2,kind=rp)

    lgrid%inv_dx1 = rp1/lgrid%dx1
    lgrid%inv_dx2 = rp1/lgrid%dx2

    allocate(lgrid%coords_cc(1:2,lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc))
    allocate(lgrid%coords_x1(1:2,lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+ngc))
    allocate(lgrid%coords_x2(1:2,lx1-ngc:ux1+ngc,lx2-ngc:ux2+1+ngc))
    allocate(lgrid%coords_cor(1:2,lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+1+ngc))
 
    allocate(lgrid%q_cc(1:nvars,lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc))   
    allocate(lgrid%qbar_cc(1:nvars,lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc))
    allocate(lgrid%q_x1(1:nvars,lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+ngc))
    allocate(lgrid%q_x2(1:nvars,lx1-ngc:ux1+ngc,lx2-ngc:ux2+1+ngc))
    allocate(lgrid%q_cor(1:nvars,lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+1+ngc))

    allocate(lgrid%flux_x1(1:nvars,lx1:ux1+1,lx2:ux2))
    allocate(lgrid%flux_x2(1:nvars,lx1:ux1,lx2:ux2+1))
    allocate(lgrid%flux_cor(1:nvars,lx1:ux1+1,lx2:ux2+1))

    allocate(lgrid%res_cc(1:nvars,lx1:ux1,lx2:ux2))  
    allocate(lgrid%res_x1(1:nvars,lx1:ux1+1,lx2:ux2))
    allocate(lgrid%res_x2(1:nvars,lx1:ux1,lx2:ux2+1))
    allocate(lgrid%res_cor(1:nvars,lx1:ux1+1,lx2:ux2+1))

    allocate(lgrid%grav_cc(1:2,lx1-ngc:ux1+ngc,lx2-ngc:ux2+ngc))
    allocate(lgrid%grav_x1(1:2,lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+ngc))
    allocate(lgrid%grav_x2(1:2,lx1-ngc:ux1+ngc,lx2-ngc:ux2+1+ngc))
    allocate(lgrid%grav_cor(1:2,lx1-ngc:ux1+1+ngc,lx2-ngc:ux2+1+ngc))

    allocate(lgrid%qbar0_cc(1:nvars,lx1:ux1,lx2:ux2))  
    allocate(lgrid%q0_x1(1:nvars,lx1:ux1+1,lx2:ux2))
    allocate(lgrid%q0_x2(1:nvars,lx1:ux1,lx2:ux2+1))
    allocate(lgrid%q0_cor(1:nvars,lx1:ux1+1,lx2:ux2+1))

    call create_geometry(lgrid,mgrid)

    lgrid%time = rp0
    lgrid%step = 0
    lgrid%tnextoutput = rp0
    
    lgrid%gm = gamma_ad
    lgrid%mu = mu

    call h5open_f(ierr)

 end subroutine initialize_simulation

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! GRID DESTRUCTION
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 subroutine finalize_simulation(lgrid)
    type(locgrid), intent(inout) :: lgrid

    integer :: ierr

    call h5close_f(ierr)

    call mpi_finalize(ierr)
    
    deallocate(lgrid%coords_cc)
    deallocate(lgrid%coords_x1)
    deallocate(lgrid%coords_x2)
    deallocate(lgrid%coords_cor)
 
    deallocate(lgrid%q_cc)  
    deallocate(lgrid%qbar_cc)
    deallocate(lgrid%q_x1)
    deallocate(lgrid%q_x2)
    deallocate(lgrid%q_cor)

    deallocate(lgrid%flux_x1)
    deallocate(lgrid%flux_x2)
    deallocate(lgrid%flux_cor)

    deallocate(lgrid%res_cc)
    deallocate(lgrid%res_x1)
    deallocate(lgrid%res_x2)
    deallocate(lgrid%res_cor)

    deallocate(lgrid%grav_cc)
    deallocate(lgrid%grav_x1)
    deallocate(lgrid%grav_x2)
    deallocate(lgrid%grav_cor)

    deallocate(lgrid%qbar0_cc)  
    deallocate(lgrid%q0_x1)
    deallocate(lgrid%q0_x2)
    deallocate(lgrid%q0_cor)

 end subroutine finalize_simulation
 
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! GRID GEOMETRIES
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 subroutine create_geometry(lgrid,mgrid)
   type(locgrid), intent(inout) :: lgrid
   type(mpigrid), intent(inout) :: mgrid

   integer :: i,j

   do j=lbound(lgrid%coords_cor,3),ubound(lgrid%coords_cor,3)
    do i=lbound(lgrid%coords_cor,2),ubound(lgrid%coords_cor,2)

       lgrid%coords_cor(1,i,j) = lgrid%x1l + (i-rp1)*lgrid%dx1
       lgrid%coords_cor(2,i,j) = lgrid%x2l + (j-rp1)*lgrid%dx2

    end do
   end do

   do j=lbound(lgrid%coords_cc,3),ubound(lgrid%coords_cc,3)
    do i=lbound(lgrid%coords_cc,2),ubound(lgrid%coords_cc,2)

        lgrid%coords_cc(1,i,j) = lgrid%x1l + (i-rph)*lgrid%dx1
        lgrid%coords_cc(2,i,j) = lgrid%x2l + (j-rph)*lgrid%dx2

    end do
   end do

   do j=lbound(lgrid%coords_x1,3),ubound(lgrid%coords_x1,3)
    do i=lbound(lgrid%coords_x1,2),ubound(lgrid%coords_x1,2)

        lgrid%coords_x1(1,i,j) = lgrid%x1l + (i-rp1)*lgrid%dx1
        lgrid%coords_x1(2,i,j) = lgrid%x2l + (j-rph)*lgrid%dx2

    end do
   end do

   do j=lbound(lgrid%coords_x2,3),ubound(lgrid%coords_x2,3)
    do i=lbound(lgrid%coords_x2,2),ubound(lgrid%coords_x2,2)

        lgrid%coords_x2(1,i,j) = lgrid%x1l + (i-rph)*lgrid%dx1
        lgrid%coords_x2(2,i,j) = lgrid%x2l + (j-rp1)*lgrid%dx2

    end do
   end do

   mgrid%dummy = rp1

 end subroutine create_geometry
 
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! MAIN LOOP
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
 subroutine time_loop(mgrid,lgrid)
    type(mpigrid), intent(inout) :: mgrid
    type(locgrid), intent(inout) :: lgrid

    integer :: iv,i,j,ierr,step0

    real(kind=rp) :: wct_hydro,wctf_hydro,wcti_hydro
    
    step0 = lgrid%step

    do j=lbound(lgrid%qbar_cc,3),ubound(lgrid%qbar_cc,3)
     do i=lbound(lgrid%qbar_cc,2),ubound(lgrid%qbar_cc,2)

       do iv=1,nvars
        lgrid%qbar_cc(iv,i,j) = ( rp16*lgrid%q_cc(iv,i,j) + &
        rp4*(lgrid%q_x1(iv,i,j)+lgrid%q_x1(iv,i+1,j)+lgrid%q_x2(iv,i,j)+lgrid%q_x2(iv,i,j+1)) + &
        (lgrid%q_cor(iv,i,j)+lgrid%q_cor(iv,i+1,j)+lgrid%q_cor(iv,i,j+1)+lgrid%q_cor(iv,i+1,j+1)) &
        ) / rp36
       end do

     end do
    end do
   
    call compute_hyperbolic_dt(mgrid,lgrid)

    wct_hydro = rp0
    call mpi_barrier(mgrid%comm_cart,ierr)
    wcti_hydro = get_wtime(mgrid)

    do while(lgrid%time<tmax)

#ifdef OUTPUT_DT
      if(lgrid%time>=lgrid%tnextoutput) then
       call mpi_barrier(mgrid%comm_cart,ierr)
       call write_output(mgrid,lgrid)
       lgrid%tnextoutput = lgrid%tnextoutput + dt_dump
      end if
#endif

      if(mgrid%rankl==master_rank) then
       if(mod(lgrid%step,info_terminal_rate)==0) &
       write(*,'("| step=",I8.8," | time=",E9.3," | dt=",E9.3,"| t/tmax=",E9.3," |")') &
       lgrid%step,lgrid%time,lgrid%dt,lgrid%time/tmax

      endif

      if((lgrid%time+lgrid%dt)>tmax) then
       lgrid%dt = tmax - lgrid%time
      endif

      call mpi_barrier(mgrid%comm_cart,ierr)
      wcti_hydro = get_wtime(mgrid)
 
      call active_flux_step(mgrid,lgrid)

      lgrid%step = lgrid%step + 1
      lgrid%time = lgrid%time + lgrid%dt

      call compute_hyperbolic_dt(mgrid,lgrid)

      call mpi_barrier(mgrid%comm_cart,ierr)
      wctf_hydro = get_wtime(mgrid)
      wct_hydro = wct_hydro + wctf_hydro - wcti_hydro

    end do 

    call mpi_barrier(mgrid%comm_cart,ierr)
    call write_output(mgrid,lgrid)

#ifdef OUTPUT_DT
    if(lgrid%time>=lgrid%tnextoutput) lgrid%tnextoutput = lgrid%tnextoutput + dt_dump
#endif

    if(mgrid%rankl==master_rank) then

      write(*,'("| step=",I8.8," | time=",E9.3," | dt=",E9.3,"| t/tmax=",E9.3," |")') &
      lgrid%step,lgrid%time,lgrid%dt,lgrid%time/tmax
      write(*,'("wct/cell/cycle/core = ",E9.3," mus")') &
      wct_hydro/(lgrid%step-step0)/(mgrid%nx1l*mgrid%nx2l)*1.0e6_rp
      write(*,'("updated cells/s = ",E9.3)') &
      (lgrid%step-step0)*(real(nx1,kind=rp)*real(nx2,kind=rp))/wct_hydro

    endif

 end subroutine time_loop
  
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! HYDRO STEP
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 subroutine active_flux_step(mgrid,lgrid)
    type(mpigrid), intent(inout) :: mgrid
    type(locgrid), intent(inout) :: lgrid

    integer :: iv,i,j,ik,it

    integer :: lx1,ux1,lx2,ux2,irk,rk_stages

    real(kind=rp), dimension(1:3,1:3) :: rk_coeff
    real(kind=rp) :: a1rk,a2rk,a3rk
    real(kind=rp) :: gm,gmm1,rho,inv_rho,p,rhoe,rhoeint,vx1,vx2

    integer :: offset(2)

    real(kind=rp), dimension(nvars,nvars) :: Rmat,Rimat,lammat,Amat,Jm,Jp
    real(kind=rp), dimension(nvars) :: Dmq,Dpq,Dq
    real(kind=rp), dimension(nvars,nvars) :: Jmat

    real(kind=rp) :: beta,c,H,k,phi,tmp,v2,l1,l2,l3,l4

    real(kind=rp) :: n1_x1, n2_x1, n1_x2, n2_x2
    real(kind=rp) :: vn_cc, v1_cc, v2_cc
    real(kind=rp) :: vn_cor, v1_cor, v2_cor
    real(kind=rp) :: vn_x1, v1_x1, v2_x1
    real(kind=rp) :: vn_x2, v1_x2, v2_x2
    real(rp) :: rho_cc, rhovx1_cc, rhovx2_cc

    rk_stages = 3

    rk_coeff(1,1) =  rp1
    rk_coeff(1,2) =  rp0
    rk_coeff(1,3) = -rp1

    rk_coeff(2,1) =  tquarts
    rk_coeff(2,2) =  oquart
    rk_coeff(2,3) = -oquart

    rk_coeff(3,1) =  othird
    rk_coeff(3,2) =  tthirds
    rk_coeff(3,3) = -tthirds

    lx1 = mgrid%i1(1)
    ux1 = mgrid%i2(1)
    lx2 = mgrid%i1(2)
    ux2 = mgrid%i2(2)

    gm = lgrid%gm
    gmm1 = gm-rp1

    !---------------------------------------------------------------------------------------!

    ! fill 0th-state

    do j=lx2,ux2
     do i=lx1,ux1
      do iv=1,nvars
        lgrid%qbar0_cc(iv,i,j) = lgrid%qbar_cc(iv,i,j)
      end do
     end do
    end do

    do j=lx2,ux2
     do i=lx1,ux1+1
      do iv=1,nvars
        lgrid%q0_x1(iv,i,j) = lgrid%q_x1(iv,i,j)
      end do
     end do
    end do

    do j=lx2,ux2+1
     do i=lx1,ux1
      do iv=1,nvars
        lgrid%q0_x2(iv,i,j) = lgrid%q_x2(iv,i,j)
      end do
     end do
    end do

    do j=lx2,ux2+1
     do i=lx1,ux1+1
      do iv=1,nvars
        lgrid%q0_cor(iv,i,j) = lgrid%q_cor(iv,i,j)
      end do
     end do
    end do


    do iv=1,nvars
     do it=1,nvars
      Jmat(iv,it) = rp0
     end do
    end do

    !---------------------------------------------------------------------------------------!
 
    ! SSP Runge--Kutta 3rd-order
 
    do irk=1,rk_stages

     !---------------------------------------------------------------------------------------!

     ! communicate arrays

     offset(1) = 0
     offset(2) = 0
     call communicate_array(mgrid,nvars,lx1,ux1,lx2,ux2,ngc,lgrid%qbar_cc,offset,.false.)

     offset(1) = 1
     offset(2) = 0
     call communicate_array(mgrid,nvars,lx1,ux1+1,lx2,ux2,ngc,lgrid%q_x1,offset,.false.)

     offset(1) = 0
     offset(2) = 1
     call communicate_array(mgrid,nvars,lx1,ux1,lx2,ux2+1,ngc,lgrid%q_x2,offset,.false.)

     offset(1) = 1
     offset(2) = 1
     call communicate_array(mgrid,nvars,lx1,ux1+1,lx2,ux2+1,ngc,lgrid%q_cor,offset,.false.)
 
     !---------------------------------------------------------------------------------------!
     ! apply boundary conditions
     
     
     !! define normals in x1
     n1_x1 = 1.0d0
     n2_x1 = 0.0d0

     !! define normals in x2
     n1_x2 = 0.0d0
     n2_x2 = 1.0d0

     !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
     ! Reflective Boundary conditions
     !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#ifdef X1L_REFLECTIVE

     if (mgrid%coords_dd(1) == 0) then
        !!lower cc
        do j=lx2,ux2
           do i=lx1-ngc,lx1-1
              ik = 1 - i

              do iv = 1, nvars
                 lgrid%qbar_cc(iv,i,j) = lgrid%qbar_cc(iv,ik,j)
              end do

              ! normal component of vec
              v1_cc = lgrid%qbar_cc(i_vx1, ik, j)
              v2_cc = lgrid%qbar_cc(i_vx2, ik, j)
              vn_cc = v1_cc*n1_x1 + v2_cc*n2_x1

              lgrid%qbar_cc(i_vx1,i,j) = v1_cc - 2.0 * vn_cc * n1_x1
              lgrid%qbar_cc(i_vx2,i,j) = v2_cc - 2.0 * vn_cc * n2_x1
           end do
        end do
        !!lower corners
        do j=lx2,ux2+1
           do i=lx1-ngc,lx1-1
              ik = 2 - i

              do iv = 1, nvars
                 lgrid%q_cor(iv,i,j) = lgrid%q_cor(iv,ik,j)
              end do

              ! normal component of vec
              v1_cor = lgrid%q_cor(i_vx1, ik, j)
              v2_cor = lgrid%q_cor(i_vx2, ik, j)
              vn_cor = v1_cor*n1_x1 + v2_cor*n2_x1

              lgrid%q_cor(i_vx1,i,j) = v1_cor - 2.0 * vn_cor * n1_x1
              lgrid%q_cor(i_vx2,i,j) = v2_cor - 2.0 * vn_cor * n2_x1
           end do
        end do

        !!lower faces x1
        do j=lx2,ux2
           do i=lx1-ngc,lx1-1
              ik = 2 - i

              do iv = 1, nvars
                 lgrid%q_x1(iv,i,j) = lgrid%q_x1(iv,ik,j)
              end do

              ! normal component of vec
              v1_x1 = lgrid%q_x1(i_vx1, ik, j)
              v2_x1 = lgrid%q_x1(i_vx2, ik, j)
              vn_x1 = v1_x1*n1_x1 + v2_x1*n2_x1

              lgrid%q_x1(i_vx1,i,j) = v1_x1 - 2.0 * vn_x1 * n1_x1
              lgrid%q_x1(i_vx2,i,j) = v2_x1 - 2.0 * vn_x1 * n2_x1
           end do
        end do

        !!lower faces x2
        do j=lx2,ux2+1
           do i=lx1-ngc,lx1-1
              ik = 1 - i

              do iv = 1, nvars
                 lgrid%q_x1(iv,i,j) = lgrid%q_x1(iv,ik,j)
              end do

              ! normal component of vec
              v1_x2 = lgrid%q_x2(i_vx1, ik, j)
              v2_x2 = lgrid%q_x2(i_vx2, ik, j)
              vn_x2 = v1_x2*n1_x1 + v2_x2*n2_x1

              lgrid%q_x2(i_vx1,i,j) = v1_x2 - 2.0 * vn_x2 * n1_x1
              lgrid%q_x2(i_vx2,i,j) = v2_x2 - 2.0 * vn_x2 * n2_x1
           end do
        end do

        
     end if

#endif
#ifdef X1U_REFLECTIVE

     if (mgrid%coords_dd(1) == mgrid%bricks(1)-1) then
        !!upper cc
        do j=lx2,ux2
           do i=ux1+1,ux1+ngc
              ik= ux1 - (i-ux1-1)

              do iv = 1, nvars
                 lgrid%qbar_cc(iv,i,j) = lgrid%qbar_cc(iv,ik,j)
              end do

              ! normal component of vec
              v1_cc = lgrid%qbar_cc(i_vx1, ik, j)
              v2_cc = lgrid%qbar_cc(i_vx2, ik, j)
              vn_cc = v1_cc * n1_x1 + v2_cc * n2_x1
              lgrid%qbar_cc(i_vx1,i,j) = v1_cc - 2.0 * vn_cc * n1_x1
              lgrid%qbar_cc(i_vx2,i,j) = v2_cc - 2.0 * vn_cc * n2_x1

           end do
        end do

        !!upper corners
        do j=lx2,ux2+1
           do i=ux1+2,ux1+1+ngc
              ik= ux1 - (i-ux1-2)

              do iv = 1, nvars
                 lgrid%q_cor(iv,i,j) = lgrid%q_cor(iv,ik,j)
              end do

              ! normal component of vec
              v1_cor = lgrid%q_cor(i_vx1, ik, j)
              v2_cor =lgrid%q_cor(i_vx2, ik, j)
              vn_cor = v1_cor * n1_x1 + v2_cor * n2_x1
              lgrid%q_cor(i_vx1,i,j) = v1_cor - 2.0 * vn_cor * n1_x1
              lgrid%q_cor(i_vx2,i,j) = v2_cor - 2.0 * vn_cor * n2_x1
           end do
        end do

        !!upper faces x1
        do j=lx2,ux2
           do i=ux1+2,ux1+1+ngc
              ik= ux1 - (i-ux1-2)

              do iv = 1, nvars
                 lgrid%q_x1(iv,i,j) = lgrid%q_x1(iv,ik,j)
              end do

              ! normal component of vec
              v1_x1 = lgrid%q_x1(i_vx1, ik, j)
              v2_x1 = lgrid%q_x1(i_vx2, ik, j)
              vn_x1 = v1_x1 * n1_x1 + v2_x1 * n2_x1
              lgrid%q_x1(i_vx1,i,j) = v1_x1 - 2.0 * vn_x1 * n1_x1
              lgrid%q_x1(i_vx2,i,j) = v2_x1 - 2.0 * vn_x1 * n2_x1
           end do
        end do

        !!upper faces x2
        do j=lx2,ux2+1
           do i=ux1+1,ux1+ngc
              ik= ux1 - (i-ux1-1)

              do iv = 1, nvars
                 lgrid%q_x2(iv,i,j) = lgrid%q_x2(iv,ik,j)
              end do

              ! normal component of vec
              v1_x2 = lgrid%q_x2(i_vx1, ik, j)
              v2_x2 = lgrid%q_x2(i_vx2, ik, j)
              vn_x2 = v1_x2 * n1_x1 + v2_x2 * n2_x1
              lgrid%q_x2(i_vx1,i,j) = v1_x2 - 2.0 * vn_x2 * n1_x1
              lgrid%q_x2(i_vx2,i,j) = v2_x2 - 2.0 * vn_x2 * n2_x1
           end do
        end do
     end if
#endif
#ifdef X2L_REFLECTIVE

     if (mgrid%coords_dd(2) == 0) then
        !!lower cc
        do j=lx2-ngc,lx2-1
           do i=lx1,ux1
              ik =  1-j

              do iv = 1, nvars
                 lgrid%qbar_cc(iv,i,j) = lgrid%qbar_cc(iv,i,ik)
              end do


              v1_cc = lgrid%qbar_cc(i_vx1, i, ik)
              v2_cc = lgrid%qbar_cc(i_vx2, i, ik)

              vn_cc = v1_cc * n1_x2 + v2_cc * n2_x2


              lgrid%qbar_cc(i_vx1,i,j) = v1_cc - 2.0d0 * vn_cc * n1_x2
              lgrid%qbar_cc(i_vx2,i,j) = v2_cc - 2.0d0 * vn_cc * n2_x2
           end do
        end do

        !!lower corners
        do j=lx2-ngc,lx2-1
           do i=lx1,ux1+1
              ik =  2-j

              do iv = 1, nvars
                 lgrid%q_cor(iv,i,j) = lgrid%q_cor(iv,i,ik)
              end do


              v1_cor = lgrid%q_cor(i_vx1, i, ik)
              v2_cor = lgrid%q_cor(i_vx2, i, ik)

              vn_cor = v1_cor * n1_x2 + v2_cor * n2_x2


              lgrid%q_cor(i_vx1,i,j) = v1_cor - 2.0d0 * vn_cor * n1_x2
              lgrid%q_cor(i_vx2,i,j) = v2_cor - 2.0d0 * vn_cor * n2_x2
           end do
        end do

        !!lower faces x1
        do j=lx2-ngc,lx2-1
           do i=lx1,ux1+1
              ik =  1-j

              do iv = 1, nvars
                 lgrid%q_x1(iv,i,j) = lgrid%q_x1(iv,i,ik)
              end do
              v1_x1 = lgrid%q_x1(i_vx1, i, ik)
              v2_x1 = lgrid%q_x1(i_vx2, i, ik)

              vn_x1 = v1_x1 * n1_x2 + v2_x1 * n2_x2


              lgrid%q_x1(i_vx1,i,j) = v1_x1 - 2.0d0 * vn_x1 * n1_x2
              lgrid%q_x1(i_vx2,i,j) = v2_x1 - 2.0d0 * vn_x1 * n2_x2
           end do
        end do

        !!lower faces x2
        do j=lx2-ngc,lx2-1
           do i=lx1,ux1
              ik =  2-j

              do iv = 1, nvars
                 lgrid%q_x2(iv,i,j) = lgrid%q_x2(iv,i,ik)
              end do


              v1_x2 = lgrid%q_x2(i_vx1, i, ik)
              v2_x2 = lgrid%q_x2(i_vx2, i, ik)

              vn_x2 = v1_x2 * n1_x2 + v2_x2 * n2_x2


              lgrid%q_x2(i_vx1,i,j) = v1_x2 - 2.0d0 * vn_x2 * n1_x2
              lgrid%q_x2(i_vx2,i,j) = v2_x2 - 2.0d0 * vn_x2 * n2_x2
           end do
        end do

     end if

#endif
#ifdef X2U_REFLECTIVE

     if (mgrid%coords_dd(2) == mgrid%bricks(2)-1) then
        !!upper cc
        do j=ux2+1,ux2+ngc
           do i=lx1,ux1

              ik= ux2 - (j-ux2-1)

              do iv = 1, nvars
                 lgrid%qbar_cc(iv,i,j) = lgrid%qbar_cc(iv,i,ik)
              end do

              ! normal component of vec
              v1_cc = lgrid%qbar_cc(i_vx1, i, ik)
              v2_cc = lgrid%qbar_cc(i_vx2, i, ik)
              vn_cc = v1_cc * n1_x2 + v2_cc * n2_x2
              lgrid%qbar_cc(i_vx1,i,j) = v1_cc - 2.0 * vn_cc * n1_x2
              lgrid%qbar_cc(i_vx2,i,j) = v2_cc - 2.0 * vn_cc * n2_x2
           end do
        end do

        !!upper corners
        do j=ux2+2,ux2+1+ngc
           do i=lx1,ux1+1

              ik= ux2 - (j-ux2-2)

              do iv = 1, nvars
                 lgrid%q_cor(iv,i,j) = lgrid%q_cor(iv,i,ik)
              end do

              ! normal component of vec
              v1_cor =  lgrid%q_cor(i_vx1, i, ik)
              v2_cor =  lgrid%q_cor(i_vx2, i, ik)
              vn_cor = v1_cor * n1_x2 + v2_cor * n2_x2
              lgrid%q_cor(i_vx1,i,j) = v1_cor - 2.0 * vn_cor * n1_x2
              lgrid%q_cor(i_vx2,i,j) = v2_cor - 2.0 * vn_cor * n2_x2
           end do
        end do

        !!upper faces x1
        do j=ux2+1,ux2+ngc
           do i=lx1,ux1+1

              ik= ux2 - (j-ux2-1)

              do iv = 1, nvars
                 lgrid%q_x1(iv,i,j) =  lgrid%q_x1(iv,i,ik)
              end do

              ! normal component of vec
              v1_x1 =  lgrid%q_x1(i_vx1, i, ik)
              v2_x1 =  lgrid%q_x1(i_vx2, i, ik)
              vn_x1 = v1_x1 * n1_x2 + v2_x1 * n2_x2
              lgrid%q_x1(i_vx1,i,j) = v1_x1 - 2.0 * vn_x1 * n1_x2
              lgrid%q_x1(i_vx2,i,j) = v2_x1 - 2.0 * vn_x1 * n2_x2
           end do
        end do


        !!upper faces x2
        do j=ux2+2,ux2+1+ngc
           do i=lx1,ux1

              ik= ux2 - (j-ux2-2)

              do iv = 1, nvars
                 lgrid%q_x2(iv,i,j) =  lgrid%q_x2(iv,i,ik)
              end do

              ! normal component of vec
              v1_x2 =  lgrid%q_x2(i_vx1, i, ik)
              v2_x2 =  lgrid%q_x2(i_vx2, i, ik)
              vn_x2 = v1_x2 * n1_x2 + v2_x2 * n2_x2
              lgrid%q_x2(i_vx1,i,j) = v1_x2 - 2.0 * vn_x2 * n1_x2
              lgrid%q_x2(i_vx2,i,j) = v2_x2 - 2.0 * vn_x2 * n2_x2
           end do
        end do
     end if
#endif

#ifdef USE_INTERNAL_BOUNDARIES
     ! TODO: here we impose internal solid boundary conditions
     ! same implementation as reflective BC, but the boundary here is the
     ! interface between solid and fluid cells (requires lgrid%is_solid(i,j) as it is done in app.F90?)
#endif

     !---------------------------------------------------------------------------------------!

     ! compute cell-centered point values

     do j=lbound(lgrid%q_cc,3),ubound(lgrid%q_cc,3)
      do i=lbound(lgrid%q_cc,2),ubound(lgrid%q_cc,2)

       do iv=1,nvars
        lgrid%q_cc(iv,i,j) = ( rp36*lgrid%qbar_cc(iv,i,j) - &
        rp4*(lgrid%q_x1(iv,i,j)+lgrid%q_x1(iv,i+1,j)+lgrid%q_x2(iv,i,j)+lgrid%q_x2(iv,i,j+1)) - &
        (lgrid%q_cor(iv,i,j)+lgrid%q_cor(iv,i+1,j)+lgrid%q_cor(iv,i,j+1)+lgrid%q_cor(iv,i+1,j+1)) &
        ) / rp16
       end do

      end do
     end do
 
     !---------------------------------------------------------------------------------------!

     ! cell-centered residuals

     ! x1-fluxes

     do j=lx2,ux2
      do i=lx1,ux1+1

       rho = lgrid%q_x1(i_rho,i,j)
       inv_rho = rp1/rho
       vx1 = lgrid%q_x1(i_rhovx1,i,j)*inv_rho
       vx2 = lgrid%q_x1(i_rhovx2,i,j)*inv_rho
       rhoe = lgrid%q_x1(i_rhoe,i,j)
       rhoeint = rhoe-rph*rho*(vx1*vx1+vx2*vx2)
       p = gmm1*rhoeint

       lgrid%flux_x1(i_rho,i,j) = rho*vx1
       lgrid%flux_x1(i_rhovx1,i,j) = rho*vx1*vx1+p
       lgrid%flux_x1(i_rhovx2,i,j) = rho*vx1*vx2
       lgrid%flux_x1(i_rhoe,i,j) = (rhoe+p)*vx1

      end do
     end do
 
     do j=lx2,ux2+1
      do i=lx1,ux1+1

       rho = lgrid%q_cor(i_rho,i,j)
       inv_rho = rp1/rho
       vx1 = lgrid%q_cor(i_rhovx1,i,j)*inv_rho
       vx2 = lgrid%q_cor(i_rhovx2,i,j)*inv_rho
       rhoe = lgrid%q_cor(i_rhoe,i,j)
       rhoeint = rhoe-rph*rho*(vx1*vx1+vx2*vx2)
       p = gmm1*rhoeint

       lgrid%flux_cor(i_rho,i,j) = rho*vx1
       lgrid%flux_cor(i_rhovx1,i,j) = rho*vx1*vx1+p
       lgrid%flux_cor(i_rhovx2,i,j) = rho*vx1*vx2
       lgrid%flux_cor(i_rhoe,i,j) = (rhoe+p)*vx1
   
      end do
     end do
     
     do j=lx2,ux2
      do i=lx1,ux1+1
       do iv=1,nvars
        lgrid%flux_x1(iv,i,j) = osixth*( &
        lgrid%flux_cor(iv,i,j+1)+rp4*lgrid%flux_x1(iv,i,j)+lgrid%flux_cor(iv,i,j) &
        ) 
       end do
      end do
     end do
     
     ! x2-fluxes

     do j=lx2,ux2+1
      do i=lx1,ux1

       rho = lgrid%q_x2(i_rho,i,j)
       inv_rho = rp1/rho
       vx1 = lgrid%q_x2(i_rhovx1,i,j)*inv_rho
       vx2 = lgrid%q_x2(i_rhovx2,i,j)*inv_rho
       rhoe = lgrid%q_x2(i_rhoe,i,j)
       rhoeint = rhoe-rph*rho*(vx1*vx1+vx2*vx2)
       p = gmm1*rhoeint

       lgrid%flux_x2(i_rho,i,j) = rho*vx2
       lgrid%flux_x2(i_rhovx1,i,j) = rho*vx1*vx2
       lgrid%flux_x2(i_rhovx2,i,j) = rho*vx2*vx2+p
       lgrid%flux_x2(i_rhoe,i,j) = (rhoe+p)*vx2
   
      end do
     end do
 
     do j=lx2,ux2+1
      do i=lx1,ux1+1

       rho = lgrid%q_cor(i_rho,i,j)
       inv_rho = rp1/rho
       vx1 = lgrid%q_cor(i_rhovx1,i,j)*inv_rho
       vx2 = lgrid%q_cor(i_rhovx2,i,j)*inv_rho
       rhoe = lgrid%q_cor(i_rhoe,i,j)
       rhoeint = rhoe-rph*rho*(vx1*vx1+vx2*vx2)
       p = gmm1*rhoeint

       lgrid%flux_cor(i_rho,i,j) = rho*vx2
       lgrid%flux_cor(i_rhovx1,i,j) = rho*vx1*vx2
       lgrid%flux_cor(i_rhovx2,i,j) = rho*vx2*vx2+p
       lgrid%flux_cor(i_rhoe,i,j) = (rhoe+p)*vx2
       
      end do
     end do
     
     do j=lx2,ux2+1
      do i=lx1,ux1
       do iv=1,nvars
        lgrid%flux_x2(iv,i,j) = osixth*( &
        lgrid%flux_cor(iv,i+1,j)+rp4*lgrid%flux_x2(iv,i,j)+lgrid%flux_cor(iv,i,j) &
        ) 
       end do
      end do
     end do

     do j=lx2,ux2
      do i=lx1,ux1
       do iv=1,nvars
         lgrid%res_cc(iv,i,j) = &
         (lgrid%flux_x1(iv,i+1,j)-lgrid%flux_x1(iv,i,j))*lgrid%inv_dx1 + &
         (lgrid%flux_x2(iv,i,j+1)-lgrid%flux_x2(iv,i,j))*lgrid%inv_dx2
       end do

#ifdef USE_GRAVITY      
      !Point values of density and momentum at cell center 
      rho_cc = (1.0_rp/16.0_rp)*(36.0_rp*lgrid%qbar_cc(i_rho,i,j) - 4.0_rp*(lgrid%q_x1(i_rho,i,j)+ lgrid%q_x1(i_rho,i+1,j)+ lgrid%q_x2(i_rho,i,j)+ lgrid%q_x2(i_rho,i,j+1)) - (lgrid%q_cor(i_rho,i,j)+ lgrid%q_cor(i_rho,i+1,j)+ lgrid%q_cor(i_rho,i,j+1)+ lgrid%q_cor(i_rho,i+1,j+1)) )

      rhovx1_cc = (1.0_rp/16.0_rp)*(36.0_rp*lgrid%qbar_cc(i_rhovx1,i,j) - 4.0_rp*(lgrid%q_x1(i_rhovx1,i,j)+ lgrid%q_x1(i_rhovx1,i+1,j)+ lgrid%q_x2(i_rhovx1,i,j)+ lgrid%q_x2(i_rhovx1,i,j+1)) - (lgrid%q_cor(i_rhovx1,i,j)+ lgrid%q_cor(i_rhovx1,i+1,j)+ lgrid%q_cor(i_rhovx1,i,j+1)+ lgrid%q_cor(i_rhovx1,i+1,j+1)) )
      
      rhovx2_cc = (1.0_rp/16.0_rp)*(36.0_rp*lgrid%qbar_cc(i_rhovx2,i,j) - 4.0_rp*(lgrid%q_x1(i_rhovx2,i,j)+ lgrid%q_x1(i_rhovx2,i+1,j)+ lgrid%q_x2(i_rhovx2,i,j)+ lgrid%q_x2(i_rhovx2,i,j+1)) - (lgrid%q_cor(i_rhovx2,i,j)+ lgrid%q_cor(i_rhovx2,i+1,j)+ lgrid%q_cor(i_rhovx2,i,j+1)+ lgrid%q_cor(i_rhovx2,i+1,j+1)) )

       !SECOND-ORDER DISCRETIZATION OF GRAVITY SOURCE
      !  lgrid%res_cc(i_rhovx1,i,j) = lgrid%res_cc(i_rhovx1,i,j) - &
      !                               lgrid%qbar_cc(i_rho,i,j) * lgrid%grav_cc(1,i,j) 
      !  lgrid%res_cc(i_rhovx2,i,j) = lgrid%res_cc(i_rhovx2,i,j) - &
      !                               lgrid%qbar_cc(i_rho,i,j) * lgrid%grav_cc(2,i,j)
      !  lgrid%res_cc(i_rhoe,i,j)   = lgrid%res_cc(i_rhoe,i,j) - &
      !                               lgrid%qbar_cc(i_rhovx1,i,j) * lgrid%grav_cc(1,i,j) - &
      !                               lgrid%qbar_cc(i_rhovx2,i,j) * lgrid%grav_cc(2,i,j)

      ! THIRD-ORDER DISCRETIZATION OF GRAVITY SOURCE
       lgrid%res_cc(i_rhovx1,i,j) = lgrid%res_cc(i_rhovx1,i,j) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x1(i_rho,i,j) * lgrid%grav_x1(1,i,j)) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x1(i_rho,i+1,j) * lgrid%grav_x1(1,i+1,j)) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x2(i_rho,i,j) * lgrid%grav_x2(1,i,j)) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x2(i_rho,i,j+1) * lgrid%grav_x2(1,i,j+1)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rho,i,j) * lgrid%grav_cor(1,i,j)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rho,i+1,j) * lgrid%grav_cor(1,i+1,j)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rho,i,j+1) * lgrid%grav_cor(1,i,j+1)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rho,i+1,j+1) * lgrid%grav_cor(1,i+1,j+1)) - &
                                     (16.0_rp/36.0_rp)*(rho_cc * lgrid%grav_cc(1,i,j))

       lgrid%res_cc(i_rhovx2,i,j) = lgrid%res_cc(i_rhovx2,i,j) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x1(i_rho,i,j) * lgrid%grav_x1(2,i,j)) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x1(i_rho,i+1,j) * lgrid%grav_x1(2,i+1,j)) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x2(i_rho,i,j) * lgrid%grav_x2(2,i,j)) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x2(i_rho,i,j+1) * lgrid%grav_x2(2,i,j+1)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rho,i,j) * lgrid%grav_cor(2,i,j)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rho,i+1,j) * lgrid%grav_cor(2,i+1,j)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rho,i,j+1) * lgrid%grav_cor(2,i,j+1)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rho,i+1,j+1) * lgrid%grav_cor(2,i+1,j+1)) - &
                                     (16.0_rp/36.0_rp)*(rho_cc * lgrid%grav_cc(2,i,j))           

       lgrid%res_cc(i_rhoe,i,j)   = lgrid%res_cc(i_rhoe,i,j) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x1(i_rhovx1,i,j) * lgrid%grav_x1(1,i,j)) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x1(i_rhovx1,i+1,j) * lgrid%grav_x1(1,i+1,j)) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x2(i_rhovx1,i,j) * lgrid%grav_x2(1,i,j)) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x2(i_rhovx1,i,j+1) * lgrid%grav_x2(1,i,j+1)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rhovx1,i,j) * lgrid%grav_cor(1,i,j)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rhovx1,i+1,j) * lgrid%grav_cor(1,i+1,j)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rhovx1,i,j+1) * lgrid%grav_cor(1,i,j+1)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rhovx1,i+1,j+1) * lgrid%grav_cor(1,i+1,j+1)) - &
                                     (16.0_rp/36.0_rp)*(rhovx1_cc * lgrid%grav_cc(1,i,j)) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x1(i_rhovx2,i,j) * lgrid%grav_x1(2,i,j)) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x1(i_rhovx2,i+1,j) * lgrid%grav_x1(2,i+1,j)) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x2(i_rhovx2,i,j) * lgrid%grav_x2(2,i,j)) - &
                                     (4.0_rp/36.0_rp)*(lgrid%q_x2(i_rhovx2,i,j+1) * lgrid%grav_x2(2,i,j+1)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rhovx2,i,j) * lgrid%grav_cor(2,i,j)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rhovx2,i+1,j) * lgrid%grav_cor(2,i+1,j)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rhovx2,i,j+1) * lgrid%grav_cor(2,i,j+1)) - &
                                     (1.0_rp/36.0_rp)*(lgrid%q_cor(i_rhovx2,i+1,j+1) * lgrid%grav_cor(2,i+1,j+1)) - &
                                     (16.0_rp/36.0_rp)*(rhovx2_cc * lgrid%grav_cc(2,i,j))   

#endif
#ifdef ADD_EINT_RHS
       ! we apply a simpson 1/3 rule on rho*e: corner + face + cell-center contributions
       lgrid%res_cc(i_rhoe,i,j)   = lgrid%res_cc(i_rhoe,i,j) + &
                            (1.0_rp/36.0_rp) * (lgrid%q_cor(i_rhoe,i,j) + lgrid%q_cor(i_rhoe,i+1,j) + &
                                                lgrid%q_cor(i_rhoe,i,j+1) + lgrid%q_cor(i_rhoe,i+1,j+1)) + &
                            (4.0_rp/36.0_rp) * (lgrid%q_x1(i_rhoe,i,j) + lgrid%q_x1(i_rhoe,i+1,j) ) + &
                            (4.0_rp/36.0_rp) * (lgrid%q_x2(i_rhoe,i,j) + lgrid%q_x2(i_rhoe,i,j+1) ) + &
                            (16.0_rp/36.0_rp)*(lgrid%q_cc(i_rhoe,i,j))
#endif
                                                                                             
      end do
     end do

     !---------------------------------------------------------------------------------------!

     ! x1 face-centered residuals

     do j=lx2,ux2
      do i=lx1,ux1+1

       !-----------------------------------------------!

       ! compute useful quantities

       rho = lgrid%q_x1(i_rho,i,j)
       inv_rho = rp1/rho
       vx1 = lgrid%q_x1(i_rhovx1,i,j)*inv_rho
       vx2 = lgrid%q_x1(i_rhovx2,i,j)*inv_rho
       rhoe = lgrid%q_x1(i_rhoe,i,j)
       v2 = vx1*vx1+vx2*vx2
       rhoeint = rhoe - rph*rho*v2
       p = gmm1*rhoeint
       H = (rhoe+p)*inv_rho
       c = sqrt(gm*p*inv_rho)
       k = rph*v2
       phi = gmm1*k
       beta = gmm1/(c*c)

       l1 = vx1-c
       l2 = vx1
       l3 = vx1
       l4 = vx1+c

       !-----------------------------------------------!

       ! Jy

       Jmat(i_rho,i_rho) = rp0
       Jmat(i_rhovx1,i_rho) = -vx1*vx2
       Jmat(i_rhovx2,i_rho) = phi-vx2*vx2
       Jmat(i_rhoe,i_rho) = vx2*(phi-H)

       Jmat(i_rho,i_rhovx1) = rp0
       Jmat(i_rhovx1,i_rhovx1) = vx2
       Jmat(i_rhovx2,i_rhovx1) = -gmm1*vx1
       Jmat(i_rhoe,i_rhovx1) = -gmm1*vx1*vx2

       Jmat(i_rho,i_rhovx2) = rp1
       Jmat(i_rhovx1,i_rhovx2) = vx1
       Jmat(i_rhovx2,i_rhovx2) = (rp3-gm)*vx2
       Jmat(i_rhoe,i_rhovx2) = H-gmm1*vx2*vx2

       Jmat(i_rho,i_rhoe) = rp0
       Jmat(i_rhovx1,i_rhoe) = rp0
       Jmat(i_rhovx2,i_rhoe) = gmm1
       Jmat(i_rhoe,i_rhoe) = gm*vx2
   
       !-----------------------------------------------!

       ! Dyq 

       do iv=1,nvars
        Dq(iv) = (lgrid%q_cor(iv,i,j+1)-lgrid%q_cor(iv,i,j))*lgrid%inv_dx2
       end do

       !-----------------------------------------------!

       ! Jy-Dyq

       do iv=1,nvars
        tmp = rp0
        do ik=1,nvars
         tmp = tmp + Jmat(iv,ik)*Dq(ik)
        end do
        lgrid%res_x1(iv,i,j) = tmp
       end do

       !-----------------------------------------------!

       ! R

       Rmat(i_rho,i_rho) = rp1
       Rmat(i_rhovx1,i_rho) = vx1-c
       Rmat(i_rhovx2,i_rho) = vx2
       Rmat(i_rhoe,i_rho) = H-c*vx1
 
       Rmat(i_rho,i_rhovx1) = rp0
       Rmat(i_rhovx1,i_rhovx1) = rp0
       Rmat(i_rhovx2,i_rhovx1) = rp1
       Rmat(i_rhoe,i_rhovx1) = vx2

       Rmat(i_rho,i_rhovx2) = rp1
       Rmat(i_rhovx1,i_rhovx2) = vx1
       Rmat(i_rhovx2,i_rhovx2) = vx2
       Rmat(i_rhoe,i_rhovx2) = k
  
       Rmat(i_rho,i_rhoe) = rp1
       Rmat(i_rhovx1,i_rhoe) = vx1+c
       Rmat(i_rhovx2,i_rhoe) = vx2
       Rmat(i_rhoe,i_rhoe) = H+c*vx1

       !-----------------------------------------------!

       ! R^-1

       Rimat(i_rho,i_rho) = rph*beta*(k+c*vx1/gmm1)
       Rimat(i_rhovx1,i_rho) = -vx2
       Rimat(i_rhovx2,i_rho) = rp1-beta*k
       Rimat(i_rhoe,i_rho) = rph*beta*(k-c*vx1/gmm1)
 
       Rimat(i_rho,i_rhovx1) = -rph*beta*(vx1+c/gmm1)
       Rimat(i_rhovx1,i_rhovx1) = rp0
       Rimat(i_rhovx2,i_rhovx1) = beta*vx1
       Rimat(i_rhoe,i_rhovx1) = -rph*beta*(vx1-c/gmm1)
 
       Rimat(i_rho,i_rhovx2) = -rph*beta*vx2
       Rimat(i_rhovx1,i_rhovx2) = rp1
       Rimat(i_rhovx2,i_rhovx2) = beta*vx2
       Rimat(i_rhoe,i_rhovx2) = -rph*beta*vx2
 
       Rimat(i_rho,i_rhoe) = rph*beta
       Rimat(i_rhovx1,i_rhoe) = rp0
       Rimat(i_rhovx2,i_rhoe) = -beta
       Rimat(i_rhoe,i_rhoe) = rph*beta

       !-----------------------------------------------!

       ! lam+

       do iv=1,nvars
        do ik=1,nvars
         lammat(ik,iv) = rp0
        end do
       end do

       lammat(i_rho,i_rho) = max(rp0,l1)
       lammat(i_rhovx1,i_rhovx1) = max(rp0,l2)
       lammat(i_rhovx2,i_rhovx2) = max(rp0,l3)
       lammat(i_rhoe,i_rhoe) = max(rp0,l4)

       !-----------------------------------------------!

       ! R-lam+

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Rmat(iv,ik)*lammat(ik,it)
         end do
         Amat(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Jxp = (R-lam+)-R^-1

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Amat(iv,ik)*Rimat(ik,it)
         end do
         Jp(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Dpq

       do iv=1,nvars

        Dpq(iv) = lgrid%inv_dx1*(rp3*lgrid%q_x1(iv,i,j)-rp4*lgrid%q_cc(iv,i-1,j)+lgrid%q_x1(iv,i-1,j))

       end do

       !-----------------------------------------------!

       ! Jxp-Dpq

       do iv=1,nvars
        tmp = rp0
        do ik=1,nvars
         tmp = tmp + Jp(iv,ik)*Dpq(ik)
        end do
        lgrid%res_x1(iv,i,j) = lgrid%res_x1(iv,i,j) + tmp
       end do
       
       !-----------------------------------------------!

       ! lam-

       do iv=1,nvars
        do ik=1,nvars
         lammat(ik,iv) = rp0
        end do
       end do
 
       lammat(i_rho,i_rho) = min(rp0,l1)
       lammat(i_rhovx1,i_rhovx1) = min(rp0,l2)
       lammat(i_rhovx2,i_rhovx2) = min(rp0,l3)
       lammat(i_rhoe,i_rhoe) = min(rp0,l4)

       !-----------------------------------------------!

       ! R-lam-

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Rmat(iv,ik)*lammat(ik,it)
         end do
         Amat(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Jxm = (R-lam-)-R^-1

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Amat(iv,ik)*Rimat(ik,it)
         end do
         Jm(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Dmq

       do iv=1,nvars

        Dmq(iv) = lgrid%inv_dx1*(-rp3*lgrid%q_x1(iv,i,j)+rp4*lgrid%q_cc(iv,i,j)-lgrid%q_x1(iv,i+1,j))

       end do

       !-----------------------------------------------!

       ! Jxm-Dmq

       do iv=1,nvars
        tmp = rp0
        do ik=1,nvars
         tmp = tmp + Jm(iv,ik)*Dmq(ik)
        end do
        lgrid%res_x1(iv,i,j) = lgrid%res_x1(iv,i,j) + tmp
       end do

       !-----------------------------------------------!
#ifdef USE_GRAVITY       
       lgrid%res_x1(i_rhovx1,i,j) = lgrid%res_x1(i_rhovx1,i,j) - &
                                     lgrid%q_x1(i_rho,i,j) * lgrid%grav_x1(1,i,j)
       lgrid%res_x1(i_rhovx2,i,j) = lgrid%res_x1(i_rhovx2,i,j) - &
                                     lgrid%q_x1(i_rho,i,j) * lgrid%grav_x1(2,i,j)
       lgrid%res_x1(i_rhoe,i,j)   = lgrid%res_x1(i_rhoe,i,j) - &
                                     lgrid%q_x1(i_rhovx1,i,j) * lgrid%grav_x1(1,i,j) - &
                                     lgrid%q_x1(i_rhovx2,i,j) * lgrid%grav_x1(2,i,j)
#endif
#ifdef ADD_EINT_RHS
       lgrid%res_x1(i_rhoe,i,j)   =  lgrid%res_x1(i_rhoe,i,j) + lgrid%q_x1(i_rhoe,i,j)
#endif       
      end do
     end do

     !---------------------------------------------------------------------------------------!

     ! x2 face-centered residuals

     do j=lx2,ux2+1
      do i=lx1,ux1

       !-----------------------------------------------!

       !compute useful quantities

       rho = lgrid%q_x2(i_rho,i,j)
       inv_rho = rp1/rho
       vx1 = lgrid%q_x2(i_rhovx1,i,j)*inv_rho
       vx2 = lgrid%q_x2(i_rhovx2,i,j)*inv_rho
       rhoe = lgrid%q_x2(i_rhoe,i,j)
       v2 = vx1*vx1+vx2*vx2
       rhoeint = rhoe - rph*rho*v2
       p = gmm1*rhoeint
       H = (rhoe+p)*inv_rho
       c = sqrt(gm*p*inv_rho)
       k = rph*v2
       phi = gmm1*k
       beta = gmm1/(c*c)

       l1 = vx2-c
       l2 = vx2
       l3 = vx2
       l4 = vx2+c

       !-----------------------------------------------!

       !Jx

       Jmat(i_rho,i_rho) = rp0
       Jmat(i_rhovx1,i_rho) = phi-vx1*vx1
       Jmat(i_rhovx2,i_rho) = -vx1*vx2
       Jmat(i_rhoe,i_rho) = vx1*(phi-H)

       Jmat(i_rho,i_rhovx1) = rp1
       Jmat(i_rhovx1,i_rhovx1) = (rp3-gm)*vx1
       Jmat(i_rhovx2,i_rhovx1) = vx2
       Jmat(i_rhoe,i_rhovx1) = H-gmm1*vx1*vx1

       Jmat(i_rho,i_rhovx2) = rp0
       Jmat(i_rhovx1,i_rhovx2) = -gmm1*vx2
       Jmat(i_rhovx2,i_rhovx2) = vx1
       Jmat(i_rhoe,i_rhovx2) = -gmm1*vx1*vx2

       Jmat(i_rho,i_rhoe) = rp0
       Jmat(i_rhovx1,i_rhoe) = gmm1
       Jmat(i_rhovx2,i_rhoe) = rp0
       Jmat(i_rhoe,i_rhoe) = gm*vx1

       !-----------------------------------------------!

       !Dxq 

       do iv=1,nvars
        Dq(iv) = (lgrid%q_cor(iv,i+1,j)-lgrid%q_cor(iv,i,j))*lgrid%inv_dx1
       end do

       !-----------------------------------------------!

       ! Jx-Dxq

       do iv=1,nvars
        tmp = rp0
        do ik=1,nvars
         tmp = tmp + Jmat(iv,ik)*Dq(ik)
        end do
        lgrid%res_x2(iv,i,j) = tmp
       end do

       !-----------------------------------------------!

       ! R

       Rmat(i_rho,i_rho) = rp1
       Rmat(i_rhovx1,i_rho) = vx1
       Rmat(i_rhovx2,i_rho) = vx2-c
       Rmat(i_rhoe,i_rho) = H-c*vx2
 
       Rmat(i_rho,i_rhovx1) = rp0
       Rmat(i_rhovx1,i_rhovx1) = -rp1
       Rmat(i_rhovx2,i_rhovx1) = rp0
       Rmat(i_rhoe,i_rhovx1) = -vx1

       Rmat(i_rho,i_rhovx2) = rp1
       Rmat(i_rhovx1,i_rhovx2) = vx1
       Rmat(i_rhovx2,i_rhovx2) = vx2
       Rmat(i_rhoe,i_rhovx2) = k
  
       Rmat(i_rho,i_rhoe) = rp1
       Rmat(i_rhovx1,i_rhoe) = vx1
       Rmat(i_rhovx2,i_rhoe) = vx2+c
       Rmat(i_rhoe,i_rhoe) = H+c*vx2
 
       !-----------------------------------------------!

       ! R^-1

       Rimat(i_rho,i_rho) = rph*beta*(k+c*vx2/gmm1)
       Rimat(i_rhovx1,i_rho) = vx1
       Rimat(i_rhovx2,i_rho) = rp1-beta*k
       Rimat(i_rhoe,i_rho) = rph*beta*(k-c*vx2/gmm1)
 
       Rimat(i_rho,i_rhovx1) = -rph*beta*vx1
       Rimat(i_rhovx1,i_rhovx1) = -rp1
       Rimat(i_rhovx2,i_rhovx1) = beta*vx1
       Rimat(i_rhoe,i_rhovx1) = -rph*beta*vx1
 
       Rimat(i_rho,i_rhovx2) = -rph*beta*(vx2+c/gmm1)
       Rimat(i_rhovx1,i_rhovx2) = rp0
       Rimat(i_rhovx2,i_rhovx2) = beta*vx2
       Rimat(i_rhoe,i_rhovx2) = -rph*beta*(vx2-c/gmm1)
 
       Rimat(i_rho,i_rhoe) = rph*beta
       Rimat(i_rhovx1,i_rhoe) = rp0
       Rimat(i_rhovx2,i_rhoe) = -beta
       Rimat(i_rhoe,i_rhoe) = rph*beta

       !-----------------------------------------------!

       ! lam+

       do iv=1,nvars
        do ik=1,nvars
         lammat(ik,iv) = rp0
        end do
       end do

       lammat(i_rho,i_rho) = max(rp0,l1)
       lammat(i_rhovx1,i_rhovx1) = max(rp0,l2)
       lammat(i_rhovx2,i_rhovx2) = max(rp0,l3)
       lammat(i_rhoe,i_rhoe) = max(rp0,l4)

       !-----------------------------------------------!

       ! R-lam+

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Rmat(iv,ik)*lammat(ik,it)
         end do
         Amat(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Jyp = (R-lam+)-R^-1

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Amat(iv,ik)*Rimat(ik,it)
         end do
         Jp(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Dpq

       do iv=1,nvars

        Dpq(iv) = lgrid%inv_dx2*(rp3*lgrid%q_x2(iv,i,j)-rp4*lgrid%q_cc(iv,i,j-1)+lgrid%q_x2(iv,i,j-1))

       end do

       !-----------------------------------------------!

       ! Jyp-Dpq

       do iv=1,nvars
        tmp = rp0
        do ik=1,nvars
         tmp = tmp + Jp(iv,ik)*Dpq(ik)
        end do
        lgrid%res_x2(iv,i,j) = lgrid%res_x2(iv,i,j) + tmp
       end do

       !-----------------------------------------------!

       ! lam-

       do iv=1,nvars
        do ik=1,nvars
         lammat(ik,iv) = rp0
        end do
       end do

       lammat(i_rho,i_rho) = min(rp0,l1)
       lammat(i_rhovx1,i_rhovx1) = min(rp0,l2)
       lammat(i_rhovx2,i_rhovx2) = min(rp0,l3)
       lammat(i_rhoe,i_rhoe) = min(rp0,l4)
 
       !-----------------------------------------------!

       ! R-lam-

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Rmat(iv,ik)*lammat(ik,it)
         end do
         Amat(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Jym = (R-lam-)-R^-1

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Amat(iv,ik)*Rimat(ik,it)
         end do
         Jm(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Dmq

       do iv=1,nvars

        Dmq(iv) = lgrid%inv_dx2*(-rp3*lgrid%q_x2(iv,i,j)+rp4*lgrid%q_cc(iv,i,j)-lgrid%q_x2(iv,i,j+1))

       end do

       !-----------------------------------------------!

       ! Jym-Dmq

       do iv=1,nvars
        tmp = rp0
        do ik=1,nvars
         tmp = tmp + Jm(iv,ik)*Dmq(ik)
        end do
        lgrid%res_x2(iv,i,j) = lgrid%res_x2(iv,i,j) + tmp
       end do

#ifdef USE_GRAVITY
       !-----------------------------------------------!
       lgrid%res_x2(i_rhovx1,i,j) = lgrid%res_x2(i_rhovx1,i,j) - &
                                     lgrid%q_x2(i_rho,i,j) * lgrid%grav_x2(1,i,j)
       lgrid%res_x2(i_rhovx2,i,j) = lgrid%res_x2(i_rhovx2,i,j) - &
                                     lgrid%q_x2(i_rho,i,j) * lgrid%grav_x2(2,i,j)
       lgrid%res_x2(i_rhoe,i,j)   = lgrid%res_x2(i_rhoe,i,j) - &
                                     lgrid%q_x2(i_rhovx1,i,j) * lgrid%grav_x2(1,i,j) - &
                                     lgrid%q_x2(i_rhovx2,i,j) * lgrid%grav_x2(2,i,j)   

#endif                                                                 

#ifdef ADD_EINT_RHS
       lgrid%res_x2(i_rhoe,i,j)   =  lgrid%res_x2(i_rhoe,i,j) + lgrid%q_x2(i_rhoe,i,j)
#endif  
      end do
     end do

     !---------------------------------------------------------------------------------------!

     ! corner-centered residuals

     do j=lx2,ux2+1
      do i=lx1,ux1+1

       !-----------------------------------------------!

       ! compute useful quantities

       rho = lgrid%q_cor(i_rho,i,j)
       inv_rho = rp1/rho
       vx1 = lgrid%q_cor(i_rhovx1,i,j)*inv_rho
       vx2 = lgrid%q_cor(i_rhovx2,i,j)*inv_rho
       rhoe = lgrid%q_cor(i_rhoe,i,j)
       v2 = vx1*vx1+vx2*vx2
       rhoeint = rhoe - rph*rho*v2
       p = gmm1*rhoeint
       H = (rhoe+p)*inv_rho
       c = sqrt(gm*p*inv_rho)
       k = rph*v2
       phi = gmm1*k
       beta = gmm1/(c*c)

       !-----------------------------------------------!

       ! x1-fluxes

       !-----------------------------------------------!

       l1 = vx1-c
       l2 = vx1
       l3 = vx1
       l4 = vx1+c

       ! R

       Rmat(i_rho,i_rho) = rp1
       Rmat(i_rhovx1,i_rho) = vx1-c
       Rmat(i_rhovx2,i_rho) = vx2
       Rmat(i_rhoe,i_rho) = H-c*vx1
 
       Rmat(i_rho,i_rhovx1) = rp0
       Rmat(i_rhovx1,i_rhovx1) = rp0
       Rmat(i_rhovx2,i_rhovx1) = rp1
       Rmat(i_rhoe,i_rhovx1) = vx2

       Rmat(i_rho,i_rhovx2) = rp1
       Rmat(i_rhovx1,i_rhovx2) = vx1
       Rmat(i_rhovx2,i_rhovx2) = vx2
       Rmat(i_rhoe,i_rhovx2) = k
  
       Rmat(i_rho,i_rhoe) = rp1
       Rmat(i_rhovx1,i_rhoe) = vx1+c
       Rmat(i_rhovx2,i_rhoe) = vx2
       Rmat(i_rhoe,i_rhoe) = H+c*vx1
 
       !-----------------------------------------------!

       ! R^-1

       Rimat(i_rho,i_rho) = rph*beta*(k+c*vx1/gmm1)
       Rimat(i_rhovx1,i_rho) = -vx2
       Rimat(i_rhovx2,i_rho) = rp1-beta*k
       Rimat(i_rhoe,i_rho) = rph*beta*(k-c*vx1/gmm1)
 
       Rimat(i_rho,i_rhovx1) = -rph*beta*(vx1+c/gmm1)
       Rimat(i_rhovx1,i_rhovx1) = rp0
       Rimat(i_rhovx2,i_rhovx1) = beta*vx1
       Rimat(i_rhoe,i_rhovx1) = -rph*beta*(vx1-c/gmm1)
 
       Rimat(i_rho,i_rhovx2) = -rph*beta*vx2
       Rimat(i_rhovx1,i_rhovx2) = rp1
       Rimat(i_rhovx2,i_rhovx2) = beta*vx2
       Rimat(i_rhoe,i_rhovx2) = -rph*beta*vx2
 
       Rimat(i_rho,i_rhoe) = rph*beta
       Rimat(i_rhovx1,i_rhoe) = rp0
       Rimat(i_rhovx2,i_rhoe) = -beta
       Rimat(i_rhoe,i_rhoe) = rph*beta
 
       !-----------------------------------------------!

       ! lam+

       do iv=1,nvars
        do ik=1,nvars
         lammat(ik,iv) = rp0
        end do
       end do

       lammat(i_rho,i_rho) = max(rp0,l1)
       lammat(i_rhovx1,i_rhovx1) = max(rp0,l2)
       lammat(i_rhovx2,i_rhovx2) = max(rp0,l3)
       lammat(i_rhoe,i_rhoe) = max(rp0,l4)

       !-----------------------------------------------!

       ! R-lam+

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Rmat(iv,ik)*lammat(ik,it)
         end do
         Amat(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Jxp = (R-lam+)-R^-1

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Amat(iv,ik)*Rimat(ik,it)
         end do
         Jp(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Dpq

       do iv=1,nvars
        Dpq(iv) = lgrid%inv_dx1*( &
        lgrid%q_cor(iv,i-1,j)-rp4*lgrid%q_x2(iv,i-1,j)+rp3*lgrid%q_cor(iv,i,j) &
        )
       end do

       !-----------------------------------------------!

       ! Jxp-Dpq

       do iv=1,nvars
        tmp = rp0
        do ik=1,nvars
         tmp = tmp + Jp(iv,ik)*Dpq(ik)
        end do
        lgrid%res_cor(iv,i,j) = tmp
       end do
 
       !-----------------------------------------------!

       ! lam-

       do iv=1,nvars
        do ik=1,nvars
         lammat(ik,iv) = rp0
        end do
       end do

       lammat(i_rho,i_rho) = min(rp0,l1)
       lammat(i_rhovx1,i_rhovx1) = min(rp0,l2)
       lammat(i_rhovx2,i_rhovx2) = min(rp0,l3)
       lammat(i_rhoe,i_rhoe) = min(rp0,l4)

       !-----------------------------------------------!

       ! R-lam-

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Rmat(iv,ik)*lammat(ik,it)
         end do
         Amat(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Jxm = (R-lam-)-R^-1

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Amat(iv,ik)*Rimat(ik,it)
         end do
         Jm(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Dmq

       do iv=1,nvars
        Dmq(iv) = lgrid%inv_dx1*( &
        rp4*lgrid%q_x2(iv,i,j)-rp3*lgrid%q_cor(iv,i,j)-lgrid%q_cor(iv,i+1,j) &
        )
       end do

       !-----------------------------------------------!

       ! Jxm-Dmq

       do iv=1,nvars
        tmp = rp0
        do ik=1,nvars
         tmp = tmp + Jm(iv,ik)*Dmq(ik)
        end do
        lgrid%res_cor(iv,i,j) = lgrid%res_cor(iv,i,j) + tmp
       end do

       !-----------------------------------------------!

       ! x2-fluxes

       !-----------------------------------------------!

       l1 = vx2-c
       l2 = vx2
       l3 = vx2
       l4 = vx2+c

       ! R

       Rmat(i_rho,i_rho) = rp1
       Rmat(i_rhovx1,i_rho) = vx1
       Rmat(i_rhovx2,i_rho) = vx2-c
       Rmat(i_rhoe,i_rho) = H-c*vx2
 
       Rmat(i_rho,i_rhovx1) = rp0
       Rmat(i_rhovx1,i_rhovx1) = -rp1
       Rmat(i_rhovx2,i_rhovx1) = rp0
       Rmat(i_rhoe,i_rhovx1) = -vx1

       Rmat(i_rho,i_rhovx2) = rp1
       Rmat(i_rhovx1,i_rhovx2) = vx1
       Rmat(i_rhovx2,i_rhovx2) = vx2
       Rmat(i_rhoe,i_rhovx2) = k
  
       Rmat(i_rho,i_rhoe) = rp1
       Rmat(i_rhovx1,i_rhoe) = vx1
       Rmat(i_rhovx2,i_rhoe) = vx2+c
       Rmat(i_rhoe,i_rhoe) = H+c*vx2
 
       !-----------------------------------------------!

       ! R^-1

       Rimat(i_rho,i_rho) = rph*beta*(k+c*vx2/gmm1)
       Rimat(i_rhovx1,i_rho) = vx1
       Rimat(i_rhovx2,i_rho) = rp1-beta*k
       Rimat(i_rhoe,i_rho) = rph*beta*(k-c*vx2/gmm1)
 
       Rimat(i_rho,i_rhovx1) = -rph*beta*vx1
       Rimat(i_rhovx1,i_rhovx1) = -rp1
       Rimat(i_rhovx2,i_rhovx1) = beta*vx1
       Rimat(i_rhoe,i_rhovx1) = -rph*beta*vx1
 
       Rimat(i_rho,i_rhovx2) = -rph*beta*(vx2+c/gmm1)
       Rimat(i_rhovx1,i_rhovx2) = rp0
       Rimat(i_rhovx2,i_rhovx2) = beta*vx2
       Rimat(i_rhoe,i_rhovx2) = -rph*beta*(vx2-c/gmm1)
 
       Rimat(i_rho,i_rhoe) = rph*beta
       Rimat(i_rhovx1,i_rhoe) = rp0
       Rimat(i_rhovx2,i_rhoe) = -beta
       Rimat(i_rhoe,i_rhoe) = rph*beta
 
       !-----------------------------------------------!

       ! lam+

       do iv=1,nvars
        do ik=1,nvars
         lammat(ik,iv) = rp0
        end do
       end do
       
       lammat(i_rho,i_rho) = max(rp0,l1)
       lammat(i_rhovx1,i_rhovx1) = max(rp0,l2)
       lammat(i_rhovx2,i_rhovx2) = max(rp0,l3)
       lammat(i_rhoe,i_rhoe) = max(rp0,l4)

       !-----------------------------------------------!

       ! R-lam+

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Rmat(iv,ik)*lammat(ik,it)
         end do
         Amat(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Jyp = (R-lam+)-R^-1

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Amat(iv,ik)*Rimat(ik,it)
         end do
         Jp(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Dpq

       do iv=1,nvars
        Dpq(iv) = lgrid%inv_dx2*( &
        lgrid%q_cor(iv,i,j-1)-rp4*lgrid%q_x1(iv,i,j-1)+rp3*lgrid%q_cor(iv,i,j) &
        )
       end do

       !-----------------------------------------------!

       ! Jyp-Dpq

       do iv=1,nvars
        tmp = rp0
        do ik=1,nvars
         tmp = tmp + Jp(iv,ik)*Dpq(ik)
        end do
        lgrid%res_cor(iv,i,j) = lgrid%res_cor(iv,i,j) + tmp
       end do
 
       !-----------------------------------------------!

       ! lam-

       do iv=1,nvars
        do ik=1,nvars
         lammat(ik,iv) = rp0
        end do
       end do

       lammat(i_rho,i_rho) = min(rp0,l1)
       lammat(i_rhovx1,i_rhovx1) = min(rp0,l2)
       lammat(i_rhovx2,i_rhovx2) = min(rp0,l3)
       lammat(i_rhoe,i_rhoe) = min(rp0,l4)
 
       !-----------------------------------------------!

       ! R-lam-

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Rmat(iv,ik)*lammat(ik,it)
         end do
         Amat(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Jym = (R-lam-)-R^-1

       do it=1,nvars

        do iv=1,nvars
         tmp = rp0
         do ik=1,nvars
          tmp = tmp + Amat(iv,ik)*Rimat(ik,it)
         end do
         Jm(iv,it) = tmp
        end do

       end do

       !-----------------------------------------------!

       ! Dmq

       do iv=1,nvars
        Dmq(iv) = lgrid%inv_dx2*( &
        rp4*lgrid%q_x1(iv,i,j)-rp3*lgrid%q_cor(iv,i,j)-lgrid%q_cor(iv,i,j+1) &              
        )
       end do

       !-----------------------------------------------!

       ! Jym-Dmq

       do iv=1,nvars
        tmp = rp0
        do ik=1,nvars
         tmp = tmp + Jm(iv,ik)*Dmq(ik)
        end do
        lgrid%res_cor(iv,i,j) = lgrid%res_cor(iv,i,j) + tmp
       end do

#ifdef USE_GRAVITY
       !-----------------------------------------------!

       lgrid%res_cor(i_rhovx1,i,j) = lgrid%res_cor(i_rhovx1,i,j) - &
                                      lgrid%q_cor(i_rho,i,j) * lgrid%grav_cor(1,i,j)
       lgrid%res_cor(i_rhovx2,i,j) = lgrid%res_cor(i_rhovx2,i,j) - &
                                      lgrid%q_cor(i_rho,i,j) * lgrid%grav_cor(2,i,j)
       lgrid%res_cor(i_rhoe,i,j)   = lgrid%res_cor(i_rhoe,i,j) - &
                                      lgrid%q_cor(i_rhovx1,i,j) * lgrid%grav_cor(1,i,j) - &
                                      lgrid%q_cor(i_rhovx2,i,j) * lgrid%grav_cor(2,i,j)      
#endif
#ifdef ADD_EINT_RHS
       lgrid%res_cor(i_rhoe,i,j)   = lgrid%res_cor(i_rhoe,i,j) + lgrid%q_cor(i_rhoe,i,j)
#endif  
      end do
     end do
 
     !---------------------------------------------------------------------------------------!

     ! update
    
     a1rk = rk_coeff(irk,1)
     a2rk = rk_coeff(irk,2)
     a3rk = rk_coeff(irk,3)*lgrid%dt

     do j=lx2,ux2
      do i=lx1,ux1
       do iv=1,nvars
         lgrid%qbar_cc(iv,i,j) = &
         a1rk*lgrid%qbar0_cc(iv,i,j) + &
         a2rk*lgrid%qbar_cc(iv,i,j) + &
         a3rk*lgrid%res_cc(iv,i,j) 
       end do
      end do
     end do

     do j=lx2,ux2
      do i=lx1,ux1+1
       do iv=1,nvars
         lgrid%q_x1(iv,i,j) = &
         a1rk*lgrid%q0_x1(iv,i,j) + &
         a2rk*lgrid%q_x1(iv,i,j) + &
         a3rk*lgrid%res_x1(iv,i,j) 
       end do
      end do
     end do

     do j=lx2,ux2+1
      do i=lx1,ux1
       do iv=1,nvars
         lgrid%q_x2(iv,i,j) = &
         a1rk*lgrid%q0_x2(iv,i,j) + &
         a2rk*lgrid%q_x2(iv,i,j) + &
         a3rk*lgrid%res_x2(iv,i,j) 
       end do
      end do
     end do

     do j=lx2,ux2+1
      do i=lx1,ux1+1
       do iv=1,nvars
         lgrid%q_cor(iv,i,j) = &
         a1rk*lgrid%q0_cor(iv,i,j) + &
         a2rk*lgrid%q_cor(iv,i,j) + &
         a3rk*lgrid%res_cor(iv,i,j) 
       end do
      end do
     end do

    end do

 end subroutine active_flux_step

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! HYPERBOLIC TIME STEP
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 subroutine compute_hyperbolic_dt(mgrid,lgrid)
   type(mpigrid), intent(in) :: mgrid
   type(locgrid), intent(inout) :: lgrid

   integer :: i,j,ierr

   real(kind=rp) :: rho,rhovx1,rhovx2,rhoe,inv_rho,&
   rhoeint,p,cs,sx1,sx2,smax(1),smax_comm(1)

   smax(1) = rp0

   do j=mgrid%i1(2),mgrid%i2(2)
    do i=mgrid%i1(1),mgrid%i2(1)

     rho = lgrid%qbar_cc(i_rho,i,j)
     rhovx1 = lgrid%qbar_cc(i_rhovx1,i,j)
     rhovx2 = lgrid%qbar_cc(i_rhovx2,i,j)
     rhoe = lgrid%qbar_cc(i_rhoe,i,j)

     inv_rho = rp1/rho

     rhoeint = rhoe - rph*(rhovx1*rhovx1+rhovx2*rhovx2)*inv_rho

     p = (lgrid%gm-rp1)*rhoeint

     cs = sqrt(lgrid%gm*p*inv_rho)

     sx1 = (abs(rhovx1)*inv_rho + cs)*lgrid%inv_dx1
     sx2 = (abs(rhovx2)*inv_rho + cs)*lgrid%inv_dx2

     smax(1) = max(smax(1),sx1+sx2)

    end do
   end do

   call mpi_allreduce(smax,smax_comm,1,MPI_RP,MPI_MAX,mgrid%comm_cart,ierr)

   lgrid%dt = cfl/smax_comm(1)

 end subroutine compute_hyperbolic_dt

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! MPI SUBROUTINES
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 subroutine communicate_array(mgrid,nv,lx1,ux1,lx2,ux2,gst,vec,offset,communicate_corners)
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: nv,lx1,ux1,lx2,ux2,gst
    real(kind=rp), intent(inout) :: vec(1:nv, &
    lx1-gst:ux1+gst, &
    lx2-gst:ux2+gst)
    integer, intent(in) :: offset(2)
    logical, intent(in) :: communicate_corners

    integer, dimension(3) :: sizes,subsizes,rstarts,sstarts
    integer :: ghost,is,prev_mpi,next_mpi,prev,next,ierror,itmp
    integer :: edge,iv,i,j
    integer, dimension(2) :: i1,i2,ri1,ri2,si1,si2
    integer :: sendtype,recvtype

    if(communicate_corners) then
      ghost = gst
    else
      ghost = 0
    endif

    do is=1,2

     if ((.not.mgrid%periodic(is)).and.(mgrid%bricks(is)==1)) cycle

     call mpi_cart_shift(mgrid%comm_cart,int(is-1),1,prev_mpi,next_mpi,ierror)
     prev = prev_mpi
     next = next_mpi

     if ((.not.mgrid%periodic(is)).and.(mgrid%coords_dd(is)==mgrid%bricks(is)-1)) &
       next = MPI_PROC_NULL
     if ((.not.mgrid%periodic(is)).and.(mgrid%coords_dd(is)==0)) &
       prev = MPI_PROC_NULL

     i1(1) = lx1
     i1(2) = lx2

     i2(1) = ux1
     i2(2) = ux2

     do iv=1,2
      si1(iv) = i1(iv)
      si2(iv) = i2(iv)
     end do

     do i=1,2
      si1(i) = si1(i) - ghost
      si2(i) = si2(i) + ghost
     end do

     do iv=1,2
      ri1(iv) = si1(iv)
      ri2(iv) = si2(iv)
     end do

     si1(is) = i2(is)-gst+1-offset(is)
     si2(is) = i2(is)-offset(is)

     ri1(is) = i1(is)-gst
     ri2(is) = i1(is)-1

     do edge=1,2

      if ((mgrid%periodic(is)).and.(mgrid%bricks(is)==1)) then

        do j=si1(2),si2(2)
         do i=si1(1),si2(1)

          do iv=1,nv
           vec(iv, &
           i-si1(1)+ri1(1), &
           j-si1(2)+ri1(2) &
           ) = vec(iv,i,j)
          end do

         end do
        end do

      else

       sizes(:) = ubound(vec)-lbound(vec)+1

       do iv=1,3
        subsizes(iv) = sizes(iv)
       end do

       subsizes(2:2+1) = subsizes(2:2+1)-2*(gst-ghost)
       subsizes(is+1) = gst

       sstarts(1) = 0
       sstarts(2) = si1(1)-lbound(vec,2)
       sstarts(3) = si1(2)-lbound(vec,3)

       rstarts(1) = 0
       rstarts(2) = ri1(1)-lbound(vec,2)
       rstarts(3) = ri1(2)-lbound(vec,3)

       call mpi_type_create_subarray(3,sizes,subsizes,sstarts,&
       MPI_ORDER_FORTRAN,MPI_RP,sendtype,ierror)
       call mpi_type_create_subarray(3,sizes,subsizes,rstarts,&
       MPI_ORDER_FORTRAN,MPI_RP,recvtype,ierror)

       call mpi_type_commit(sendtype,ierror)
       call mpi_type_commit(recvtype,ierror)

       call mpi_sendrecv( &
       vec,1,sendtype,next,0, &
       vec,1,recvtype,prev,0, &
       mgrid%comm_cart,MPI_STATUS_IGNORE,ierror)

       call mpi_type_free(sendtype,ierror)
       call mpi_type_free(recvtype,ierror)

      endif

      si1(is) = i1(is) + offset(is)
      si2(is) = i1(is)+gst-1 + offset(is)

      ri1(is) = i2(is)+1 
      ri2(is) = i2(is)+gst 

      itmp = next
      next = prev
      prev = itmp

     end do


    end do

 end subroutine communicate_array
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! I/O
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 subroutine write_output(mgrid,lgrid)
    type(mpigrid), intent(in) :: mgrid
    type(locgrid), intent(inout) :: lgrid

    type(h5_file) :: h5

    integer :: error
    integer(HID_T) :: id,plist_id

    write(h5%filename, "('./grids/grid_n',I0.5,'.h5')") lgrid%step

    call h5pcreate_f(H5P_FILE_ACCESS_F,plist_id,error)

    call h5pset_fapl_mpio_f(plist_id,mgrid%comm_cart,MPI_INFO_NULL,error)

    call h5fcreate_f(h5%filename,H5F_ACC_TRUNC_F,h5%file_id,error,H5P_DEFAULT_F,plist_id)

    call h5pclose_f(plist_id,error)

    h5%pref_dtypef = H5T_IEEE_F64LE
    h5%pref_dtypei = H5T_STD_I32LE

    call h5gcreate_f(h5%file_id,"grid", id, error)
    call hdf5_annotate_rp(h5,id,"time",lgrid%time)
    call hdf5_annotate_rp(h5,id,"dt",lgrid%dt)
    call hdf5_annotate_ip(h5,id,"step",lgrid%step)

    if(lgrid%step==0) then

      call hdf5_annotate_rp(h5,id,"gamma_ad",lgrid%gm)
      call hdf5_annotate_rp(h5,id,"mu",lgrid%mu)
      call hdf5_annotate_rp(h5,id,"x1l",lgrid%x1l)
      call hdf5_annotate_rp(h5,id,"x1u",lgrid%x1u)
      call hdf5_annotate_rp(h5,id,"x2l",lgrid%x2l)
      call hdf5_annotate_rp(h5,id,"x2u",lgrid%x2u)
      call hdf5_annotate_ip(h5,id,"nx1",nx1)
      call hdf5_annotate_ip(h5,id,"nx2",nx2)

      call hdf5_write_ndarray(h5,id,"coords",mgrid,2, &
      mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),ngc,lgrid%coords_cc)

    end if

    call hdf5_write_ndarray(h5,id,"qbar_cc",mgrid,nvars, &
    mgrid%i1(1),mgrid%i2(1),mgrid%i1(2),mgrid%i2(2),ngc,lgrid%qbar_cc)

    call h5gclose_f(id,error)
    call h5fclose_f(h5%file_id,error)

 end subroutine write_output

 subroutine hdf5_write_ndarray(h5,group_id,dsetname,mgrid,nv,lx1,ux1,lx2,ux2,ghost,vec)
    type(h5_file) :: h5
    integer(kind=HID_T), intent(in) :: group_id
    character(len=*) :: dsetname
    type(mpigrid), intent(in) :: mgrid
    integer, intent(in) :: nv
    integer, intent(in) :: lx1,ux1,lx2,ux2,ghost
    real(kind=rp), dimension(1:nv, &
    lx1-ghost:ux1+ghost, &
    lx2-ghost:ux2+ghost), intent(in) :: vec

    integer(kind=HID_T) :: dset_id,filespace,memspace,plist_id
    integer(kind=HSIZE_T), dimension(3) :: gnc,cnt,off
    integer(kind=HSIZE_T), dimension(3) :: memcnt,memcnt2,memoff
    integer :: err

    integer :: nx1l,nx2l

    nx1l = ux1-lx1+1
    nx2l = ux2-lx2+1

    gnc(1) = nv
    gnc(2) = nx1l*mgrid%bricks(1)
    gnc(3) = nx2l*mgrid%bricks(2)

    call h5screate_simple_f(3,gnc,filespace,err)

    call h5dcreate_f(group_id,dsetname,h5%pref_dtypef,filespace,dset_id,err)

    call h5sclose_f(filespace,err)

    memcnt(1) = nv
    memcnt(2) = nx1l + 2*ghost
    memcnt(3) = nx2l + 2*ghost

    call h5screate_simple_f(3,memcnt,memspace,err)

    memcnt2(1) = nv
    memcnt2(2) = nx1l
    memcnt2(3) = nx2l

    memoff(1) = 0
    memoff(2) = ghost
    memoff(3) = ghost

    call h5sselect_hyperslab_f(memspace,H5S_SELECT_SET_F,memoff,memcnt2,err)

    cnt(1) = nv
    cnt(2) = nx1l
    cnt(3) = nx2l

    off(1) = 0
    off(2) = nx1l*mgrid%coords_dd(1)
    off(3) = nx2l*mgrid%coords_dd(2)

    call h5dget_space_f(dset_id,filespace,err)
    call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,off,cnt,err)

    call h5pcreate_f(H5P_DATASET_XFER_F,plist_id,err)
    call h5pset_dxpl_mpio_f(plist_id,H5FD_MPIO_COLLECTIVE_F,err)

    call h5dwrite_f(dset_id,h5%pref_dtypef, &
    vec(1, &
    lbound(vec,2), &
    lbound(vec,3) ), &
    gnc,err,memspace,filespace,plist_id)

    call h5sclose_f(filespace,err)
    call h5sclose_f(memspace,err)
    call h5dclose_f(dset_id,err)
    call h5pclose_f(plist_id,err)

 end subroutine hdf5_write_ndarray

 subroutine hdf5_annotate_rp(h5,id,key,val)
    type(h5_file) :: h5
    integer(kind=HID_T), intent(in) :: id
    character(len=*), intent(in) :: key
    real(kind=rp), intent(in) :: val

    integer(kind=HSIZE_T),dimension(1) :: dims
    integer :: err
    integer(kind=HID_T) :: sid,aid

    call h5screate_f(H5S_SCALAR_F,sid,err)
    call h5dcreate_f(id,key,h5%pref_dtypef,sid,aid,err)
    call h5dwrite_f(aid,h5%pref_dtypef,val,dims,err)
    call h5dclose_f(aid,err)
    call h5sclose_f(sid,err)

 end subroutine hdf5_annotate_rp

 subroutine hdf5_annotate_array_rp(h5,id,key,val)
      type(h5_file) :: h5
      integer(kind=HID_T), intent(in) :: id
      character(len=*), intent(in) :: key
      real(kind=rp), dimension(:), intent(in) :: val

      integer(kind=HSIZE_T),dimension(1) :: dims
      integer :: err
      integer(kind=HID_T) :: sid,aid

      dims(1) = size(val)
      call h5screate_simple_f(1,dims,sid,err)
      call h5dcreate_f(id,key,h5%pref_dtypef,sid,aid,err)
      call h5dwrite_f(aid,h5%pref_dtypef,val,dims,err)
      call h5dclose_f(aid,err)
      call h5sclose_f(sid,err)

 end subroutine hdf5_annotate_array_rp

 subroutine hdf5_annotate_array_ip(h5,id,key,val)
   type(h5_file) :: h5
   integer(kind=HID_T), intent(in) :: id
   character(len=*), intent(in) :: key
   integer, dimension(:), intent(in) :: val

   integer(kind=HSIZE_T), dimension(1) :: dims
   integer :: err
   integer(kind=HID_T) :: sid, aid

   dims(1) = size(val)
   call h5screate_simple_f(1,dims,sid,err)
   call h5dcreate_f(id,key,h5%pref_dtypei,sid,aid,err)
   call h5dwrite_f(aid,h5%pref_dtypei,val,dims,err)
   call h5dclose_f(aid,err)
   call h5sclose_f(sid,err)

 end subroutine hdf5_annotate_array_ip

 subroutine hdf5_annotate_string(id,key,val)
    integer(kind=HID_T), intent(in) :: id
    character(len=*), intent(in) :: key,val

    integer(kind=HSIZE_T),dimension(1) :: dims
    integer :: err
    integer(kind=HID_T) :: sid,aid,tid

    call h5tcopy_f (H5T_NATIVE_CHARACTER,tid,err)
    call h5tset_size_f(tid,int(len(trim(val)),kind=SIZE_T),err)
    call h5screate_f(H5S_SCALAR_F,sid,err)
    call h5acreate_f(id,key,tid,sid,aid,err)
    dims(1)=1
    call h5awrite_f(aid,tid,trim(val),dims,err)
    call h5aclose_f(aid,err)
    call h5sclose_f(sid,err)
    call h5tclose_f(tid,err)

 end subroutine hdf5_annotate_string

 subroutine hdf5_annotate_array_string(id,key,val,n)
    integer(HID_T), intent(in) :: id
    character(len=*), intent(in) :: key
    character(len=filename_size), dimension(*), intent(in) :: val
    integer, intent(in) :: n

    integer :: err
    integer(HID_T) :: sid, aid, tid
    integer(HSIZE_T), dimension(1) :: dims
    integer(SIZE_T) :: strlen

    strlen = filename_size
    dims(1) = n

    call h5tcopy_f(H5T_NATIVE_CHARACTER,tid,err)
    call h5tset_size_f(tid,strlen,err)
    call h5screate_simple_f(1,dims,sid,err)
    call h5acreate_f(id,key,tid,sid,aid,err)
    call h5awrite_f(aid,tid,val,dims,err)
    call h5aclose_f(aid,err)
    call h5sclose_f(sid,err)
    call h5tclose_f(tid,err)

 end subroutine hdf5_annotate_array_string

 subroutine hdf5_annotate_ip(h5,id,key,val)
    type(h5_file) :: h5
    integer(kind=HID_T), intent(in) :: id
    character(len=*), intent(in) :: key
    integer, intent(in) :: val

    integer(kind=HSIZE_T),dimension(1) :: dims
    integer :: err
    integer(kind=HID_T) :: sid,aid

    call h5screate_f(H5S_SCALAR_F,sid,err)
    call h5dcreate_f(id, key, h5%pref_dtypei, sid, aid, err)
    call h5dwrite_f(aid,h5%pref_dtypei,val,dims,err)
    call h5dclose_f(aid,err)
    call h5sclose_f(sid,err)

 end subroutine hdf5_annotate_ip

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! MPI WALL CLOCK TIME
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 function get_wtime(mgrid) result(wct)
   type(mpigrid),intent(inout) :: mgrid
   real(kind=rp) :: wct, tmp(1)
   integer :: ierr

   tmp(1) = real(mpi_wtime(),kind=rp)
   call mpi_bcast(tmp,1,MPI_RP,master_rank,mgrid%comm_cart,ierr)
   wct = tmp(1)

 end function get_wtime

 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ! USEFUL FUNCTIONS
 !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 character(len=20) function str(k)
   integer, intent(in) :: k
   write (str, *) k
   str = adjustl(str)
 end function str

end module source
                         


