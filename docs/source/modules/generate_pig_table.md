(generate-pig-table)=
# Generate PIG EoS table

To generate a customized table for a partially-ionized-gas (PIG) EoS, you must first specify the following options through `OPTS += ...` entries in the `Makefile` in `miscellaneous/generate_pig_table`:

| Option | Meaning |
| --- | --- |
| `Nrho=240` | Number of intervals (i.e., nodes-1) in the temperature axis of the table |
| `NT=160` | Number of intervals (i.e., nodes-1) in the density axis of the table |
| `log10_T_min=1.0_rp` | Minumum log10 of the tabulated temperature / K |
| `log10_T_max=8.0_rp` | Maximum log10 of the tabulated temperature / K | 
| `log10_rho_min=-20.0_rp` | Minumum log10 of the tabulated density / (g cm^-3) |
| `log10_rho_max=0.0_rp` | Maximum log10 of the tabulated density / (g cm^-3) | 
| `thr_ne=1.0e-15_rp` | Tolerance threshold of the Secant solver that finds the root of $\sum_j(Z_{ij} n_{ij}(n_e))-n_e = 0$ |
| `eps_eta=1.0e-3_rp` | Relative perturbation in a quantity "q" needed to compute its first or second derivative using a 4th-order accurate discretization method on a 5-point stencil |
| `ddx1=12` | Number of briquettes in the density axis used for MPI parallelization |
| `ddx2=8` | Number of briquettes in the temperature axis used for MPI parallelization |
| `USE_QUAD_PRECISION` | To enable 128-bit precision (recommended), otherwise use `USE_DOUBLE_PRECISION` |
| `USE_H2` | If enabled, adds h2 to the mixture |
 
The provided Makefile will use `mpifort` to compile the source code, but you can explicitly set the fortran compiler at `FC = mpifort`.

The mass fractional abundances of a finite list of elements must be provided in `generate_pig_table.F90` as
```fortran
mgrid%X(i_h1) = 0.72_rp
mgrid%X(i_he4) = 0.25_rp
mgrid%X(i_c12) = 0.01_rp
mgrid%X(i_n14) = 0.01_rp
mgrid%X(i_o16) = 0.01_rp
```

You can then build the executable as

```bash
make clean
make
```

The executable is then ready to be run, using, e.g.,
```bash
mpirun -n 96 ./run.generate_pig_table
```
or by submitting a job script (see `miscellaneous/generate_pig_table/pig_table.job`).

Note: the number of MPI tasks used to run the executable must match the product of `ddx1` and `ddx2`.

The resulting table has resolution `(Nrho+1)x(NT+1)` and can be found in `miscellaneous/generate_pig_table/pig_table.dat`.

In a Phlegethon application, the table path, resolution, and range must be specified in the `Makefile` of the application by defining the following parameters (here the generated table has been moved to `$(DATA)`)

```bash
OPTS += path_to_pig_table=\"$(DATA)/pig_table.dat\"
OPTS += pig_nT_make=161
OPTS += pig_nrho_make=241
OPTS += pig_ltlo_make=3.0_rp
OPTS += pig_lthi_make=8.0_rp
OPTS += pig_ldlo_make=-20.0_rp
OPTS += pig_ldhi_make=0.0_rp
```

The new table can also be used in Python for postprocessing. To this end, the customized table must be copied to `$(DATA)`. 

At this point, when loading a grid snapshot using the functionalities of phloutput, you must specify the name of the new table, e.g., 
```python
sl = h5grid(-1,pig_table='pig_table.dat',NRHO=<NRHO>,NT=<NT>,LOGRHOMIN=<LOGRHOMIN>,LOGRHOMAX=<LOGRHOMAX>,LOGTMIN=<LOGTMIN>,LOGTMAX=<LOGTMAX>)
```
Note: the call to h5grid will automatically `set eos_mode = ['radiation','pig']`, so that the ultimate EoS will include the selected mixture of partially ionized species and thermal radiation.
