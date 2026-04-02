program generate_pig_table
  use source
  implicit none
 
  type(mpigrid) :: mgrid
  type(teos), dimension(1:int(Nrho/ddx1+1),1:int(NT/ddx2+1)) :: table 
  type(teos), dimension(1:Nrho+1,1:NT+1) :: table_glob
  integer :: ierr

  call init_mpi(mgrid)
  
  mgrid%X(:) = 0.0_rp
  mgrid%X(i_h1) = 0.67348334_rp
  mgrid%X(i_he4) = 0.3063957_rp
  mgrid%X(i_c12) = 0.00214939_rp
  mgrid%X(i_n14) = 0.0033643_rp
  mgrid%X(i_o16) = 0.00839068_rp
  mgrid%X(i_ne20) = 0.00621659_rp

  call mpi_barrier(mgrid%comm_cart,ierr)

  call create_table_briquette(mgrid,table)

  call create_global_table(mgrid,table_glob)

  call mpi_barrier(mgrid%comm_cart,ierr)

  call mpi_finalize(ierr)

end program generate_pig_table
