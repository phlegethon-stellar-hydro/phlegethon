To generate a customized table for a partially-ionized-gas (PIG) EoS, you must first specify the following options in the provided Makefile

OPTS = Nrho=240 | number of intervals (i.e., nodes-1) in the temperature axis of the table
OPTS += NT=160 | number of intervals (i.e., nodes-1) in the density axis of the table
OPTS += log10_T_min=6.5_rp | minumum log10 of the tabulated temperature / K
OPTS += log10_T_max=8.5_rp | maximum log10 of the tabulated temperature / K
OPTS += log10_rho_min=3.0_rp | minumum log10 of the tabulated density / (g cm^-3)
OPTS += log10_rho_max=6.0_rp | maximum log10 of the tabulated density / (g cm^-3)
OPTS += thr_ne=1.0e-15_rp | tolerance threshold of the Secant solver that finds the root of sum_j(rijxnij(ne))-ne
OPTS += eps_eta=1.0e-3_rp | relative perturbation in a quantity "q" needed to compute its first or second derivative using a 4th-order accurate discretization method on a 5-point stencil
OPTS += ddx1=12 | number of briquettes in the density axis used for MPI parallelization
OPTS += ddx2=8 | number of briquettes in the temperature axis used for MPI parallelization
OPTS += USE_QUAD_PRECISION | to enable 128-bit precision (recommended), otherwise use "USE_DOUBLE_PRECISION"
OPTS += USE_H2 | if enabled, adds h2 to the mixture.
 
The provided Makefile will use mpifort to compile the source code, but you can explicitly set the fortran compiler at

FC = mpifort

The mass fractional abundances of a finite list of elements must be provided in generate_pig_table.F90 as

mgrid%X(i_h1) = 0.72_rp
mgrid%X(i_he4) = 0.25_rp
mgrid%X(i_c12) = 0.01_rp
mgrid%X(i_n14) = 0.01_rp
mgrid%X(i_o16) = 0.01_rp

You can then build the executable as

make clean
make

The program is then ready to be run, using, e.g.,

mpirun -n 96 ./run.generate_pig_table

or by submitting a job script (see ./pig_table.job)

Note: the number of MPI tasks used to run the executable must match the product of ddx1 and ddx2.)

The resulting table has resolution (Nrho+1)x(NT+1) and can be found in ./pig_table.dat

In a Phlegethon application, the table path, resolution, and range must be specified in the Makefile of the application by defining the following parameters (here the generated table has been moved to $(DATA))

OPTS += path_to_pig_table=\"$(DATA)/pig_table.dat\"
OPTS += pig_nT=161
OPTS += pig_nrho=241
OPTS += pig_ltlo=6.5_rp
OPTS += pig_lthi=8.5_rp
OPTS += pig_ldlo=3.0_rp
OPTS += pig_ldhi=6.0_rp

The new table can also be used in Python for postprocessing. To this end the customized table must be copied to $(DATA). 

At this point, when loading a grid snapshot using the functionalities of phloutput, you must specify the name of the new table, e.g., 

sl = h5grid(-1,pig_table='pig_table.dat',NRHO=<NRHO>,NT=<NT>,LOGRHOMIN=<LOGRHOMIN>,LOGRHOMAX=<LOGRHOMAX>,LOGTMIN=<LOGTMIN>,LOGTMAX=<LOGTMAX>)

Note: the call to h5grid will automatically set eos_mode = ['radiation','pig'], so that the ultimate EoS will include the selected mixture of partially ionized species and thermal radiation







