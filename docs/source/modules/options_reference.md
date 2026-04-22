(options-reference)=
# Compile-Time Flags and Options

Most Phlegethon configuration is done at compile time through `OPTS += ...` entries in each test `Makefile`.

`Makefile` options are passed as:

```make
OPTS += USE_MHD
OPTS += nx1_make=64
OPTS += cfl_make=0.8_rp
```

These are forwarded as preprocessor definitions when compiling `source/source.F90`.

## List of options in Phlegethon

Some of the options refer to sections, equations, or tables of the [instrument paper](https://arxiv.org/abs/2604.12672).

### 1. Paths
| Option | Meaning |
| --- | --- |
| `SRC = ../../source`  | Path to source directory. |
| `DATA = ../../data`   | Path to `data` directory (containing the EoS tables and nuclear data). |

### 2. Grid variables
| Option | Meaning |
| --- | --- |
| `sdims_make=3` | Number of spatial dimensions (allowed values are `2` or `3`). |
| `nx1_make=64`  | Global number of grid cells in the `x1` direction. |
| `nx2_make=64`  | Global number of grid cells in the `x2` direction. |
| `nx3_make=64`  | Global number of grid cells in the `x3` direction. |
| `ddx1_make=64`  | Number of local domains in the `x1` direction. |
| `ddx2_make=64`  | Number of local domains in the `x2` direction. |
| `ddx3_make=64`  | Number of local domains in the `x3` direction. |
| `ngc_make=2`  | Number of ghost cells (see Sect. 2.1). |
| `nas_make=15`  | Number of active/passive scalars. |
| `nspecies_make=12`  | Number of species participating in a nuclear reaction network (`nspecies_make<=nas_make`). |
| `nreacs_make=38`  | Number of reactions in the nuclear network. |

### 2. Grid geometry
To set a grid geometry, you need to define one of the following options:

| Option | Meaning |
| --- | --- |
| `GEOMETRY_CARTESIAN_UNIFORM` | Cartesian geometry (uniform). |
| `GEOMETRY_CARTESIAN_NONUNIFORM` | Cartesian geometry (nonuniform). |
| `GEOMETRY_2D_POLAR` | 2D polar geometry (requires `sdims_make=2`). |
| `GEOMETRY_2D_SPHERICAL` | 2D spherical geometry (requires `sdims_make=2`). |
| `GEOMETRY_3D_SPHERICAL` | 3D spherical geometry (requires `sdims_make=3`). |
| `GEOMETRY_CUBED_SPHERE` | 2D/3D cubed-sphere geometry of [Calhoun+08](https://ui.adsabs.harvard.edu/abs/2008SIAMR..50..723C/abstract). |

For polar or spherical grids, the user can enable arbitrarily nonuniform radial grid spacing with `NONUNIFORM_RADIAL_NODES`.
In this case, the subroutine `create_geometry` must be defined by the user in `app.F90` (see, e.g., `tests/logarithmic-grid/app.F90`)
The same applies when non-uniform Cartesian grids are enabled with `GEOMETRY_CARTESIAN_NONUNIFORM`.

For `GEOMETRY_CUBED_SPHERE`, the following parameters must be defined at compile time:

| Option | Meaning |
| --- | --- |
|`cs_r1_make=1.0_rp` | Maximum radius of the grid. |
|`cs_gridexp_make=0.0_rp` | Regulates the sphericity of the grid. |
|`cs_alpha_make=1.0_rp` | Regulates the radial stretching of the grid. |

### 3. Physics modules
| Option | Meaning |
| --- | --- |
| `COROTATING_FRAME `| Solves the governing equations in the co-rotating frame defined by the angular frequency vector `lgrid%omega_rot(1:3)` specified in the user in `app.F90`. |
| `USE_CONSTANT_ACCELERATION` | Applies a constant-acceleration body force to the system. In `app.F90`, the grid components of the acceleration vector must be defined in `lgrid%acc(1:sdims_make)`. |
| `USE_MHD` | Enables ideal magnetohydrodynamics (solved with the CT-contact algorithm of [Gardiner+05](https://ui.adsabs.harvard.edu/abs/2005JCoPh.205..509G/abstract)). In `app.F90`, the face-centered magnetic field components must be filled, e.g., `lgrid%b_x1(i,j,k)` etc. |
| `Mach_ct_make=1e-6_rp` | Minimum local Mach number to enable the (upwind) contact version of constrained transport. |
| `USE_RESISTIVITY` | Adds magnetic resistivity to the induction equation (note: not to the energy equation and only for Cartesian grids). For this option, the cell-centered value of the magnetic diffusion coefficient `lgrid%eta(i,j,k)` must be provided in `app.F90`. |
| `ADVECT_YE_IABAR` | Advects `ye` and the inverse of `abar` as active scalars. In the code, the mean molecular weight is then computed from these two quantities assuming a fully ionized medium. If this option is chosen , `nas` must be at least `2` to accomodate the two additional variables in `lgrid%prim`. In `app.F90`, they can be accessed with the indixes `i_ye` and `i_iabar`. Other active scalars can be defined starting from the index `i_iabar+1`. |
|`ADVECT_SPECIES` | If declared, advects `nspecies` chemical species as active scalars. In the code, the mean molecular weight is then computed from the mass fractional abundances of the species assuming a fully ionized mixture. If this option is chosen , `nas_make` must be at least `nspecies_make` to accomodate the species in `lgrid%prim`. The species index goes from `i_as1` to `i_as1+nspecies`. In `app.F90`, before calling the `initialize_simulation` subroutine, `lgrid%A(:)` and `lgrid%Z(1:nspecies_make)` must be filled for each element (starting from index `1` to index `nspecies_make`) by providing the mass number and the charge number of the element, respectively. Make sure that the sum of the mass fractional abundances of the species is 1, otherwise the mean molecular weight of the gas will be wrong. Do not use this option in combination with `ADVECT_YE_IABAR`. |
| `USE_GRAVITY` | Enables space dependent gravity (Newtonian gravity only). The cell-centered components of gravity must be filled in `app.F90` in `lgrid%grav(:,i,j,k)`. |
| `CONST_GRAV_UNITY` | Sets `G=1` in the code |
| `EVOLVE_ETOT` | Evolves the total energy per unit volume, i.e., $e \rightarrow e +  \phi$. In `app.F90`, the cell-centered and face-centered gravitational potential must be filled as, e.g., `lgrid%phi_cc(i,j,k)`, `lgrid%phi_x1(i,j,k)`, etc.  |
| `USE_NUCLEAR_NETWORK` | Couples a time-dependent nuclear network to the system of conservation laws, in Godunov-split fashion by default (see Sect. 2.13). The network solver is time-implicit. The network has to be used in combination with the option `ADVECT_SPECIES`. The number of reactions (`nreacs_make`) must be defined in the Makefile. Furthermore, the network solver needs the functions `compute_network_rates`, `compute_network_residuals`, `compute_network_jacobian`, and `compute_network_dedt`, all of which must be defined in `app.F90` (see `tests/nuclear-network` for an example of the usage of the nuclear network solver). A python script (`./miscellaneous/create_network/create_network.py`) is provided to automatically generate the Fortran code based on the array of input isotopes, density and temperature conditions, and the timescale of interest. |
| `THERMAL_DIFFUSION_EXPLICIT` | Enables thermal diffusion solved explicitly in time-unsplit fashion (unstable if the time step is longer than the parabolic CFL criterion, see Sect. 2.10). The cell-centered opacity must be filled in `app.F90` as `lgrid%kappa(i,j,k)`. |
| `THERMAL_DIFFUSION_STS` | Enables radiative diffusion solved with the RKL2 super time stepper of [Meyer+14](https://ui.adsabs.harvard.edu/abs/2014JCoPh.257..594M/abstract) (see, Sect. 2.10). The cell-centered opacity must be filled in `app.F90` as `lgrid%kappa(i,j,k)`. |
| `USE_EDOT` | Enables time independent heating. The heating rate per unit volume (`lgrid%edot(i,j,k)`) must be provided in `app.F90` at every cell center. |
| `USE_VARIABLE_EDOT` | Switches on a fixed heating source after `t=t_start_edot_make` |
| `t_start_edot_make=1.0_rp` | Time after which the heating source is activated. |
| `USE_NEULOSS` | Enables nonnuclear neutrino cooling, computed according to [Itoh+1996](https://ui.adsabs.harvard.edu/abs/1996ApJS..102..411I/abstract) (adapted from Frank Timmes' [cococubed](https://cococubed.com/code_pages/nuloss.shtml)). |

### 4. Boundary conditions (see Table 1)

| Option | Meaning |
| --- | --- |
| `X1_PERIODIC` | Periodic boundary conditions on the x1 axis. |
| `X2_PERIODIC` | Periodic boundary conditions on the x2 axis. |
| `X3_PERIODIC` | Periodic boundary conditions on the x3 axis. |
| `X1L_REFLECTIVE` | Reflecting boundary conditions at the lower x1 boundary. |
| `X1U_REFLECTIVE` | Reflecting boundary conditions at the upper x1 boundary. |
| `X2L_REFLECTIVE` | Reflecting boundary conditions at the lower x2 boundary. |
| `X2U_REFLECTIVE` | Reflecting boundary conditions at the upper x2 boundary. |
| `X3L_REFLECTIVE` | Reflecting boundary conditions at the lower x3 boundary. |
| `X3U_REFLECTIVE` | Reflecting boundary conditions at the upper x3 boundary. |
| `X1L_OUTFLOW` | Outflow boundary conditions at the lower x1 boundary. |
| `X1U_OUTFLOW` | Outflow boundary conditions at the upper x1 boundary. |
| `X2L_OUTFLOW` | Outflow boundary conditions at the lower x2 boundary. |
| `X2U_OUTFLOW` | Outflow boundary conditions at the upper x2 boundary. |
| `X3L_OUTFLOW` | Outflow boundary conditions at the lower x3 boundary. |
| `X3U_OUTFLOW` | Outflow boundary conditions at the upper x3 boundary. |
| `X1L_DIODE` | Diode boundary conditions at the lower x1 boundary. |
| `X1U_DIODE` | Diode boundary conditions at the upper x1 boundary. |
| `X2L_DIODE` | Diode boundary conditions at the lower x2 boundary. |
| `X2U_DIODE` | Diode boundary conditions at the upper x2 boundary. |
| `X3L_DIODE` | Diode boundary conditions at the lower x3 boundary. |
| `X3U_DIODE` | Diode boundary conditions at the upper x3 boundary. |
| `FIX_TEMPERATURE_AT_X1L` | Fixes the temperature (in this example) at the lower x1 boundary only for the thermal diffusion step. If `USE_WB` is enabled, the temperature at the boundaries is fixed using the equilibrium state, otherwise the temperature must be provided at each lower and upper domain boundary by filling the 3-element arrays (1 element per spatial dimension) `lgrid%Tl(:)` and `grid%Tu(:)`, respectively. |
|`USE_INTERNAL_BOUNDARIES` | Imposes reflecting boundary conditions at solid interfaces embedded in the numerical domain. This option only works for Cartesian grids and requires `lgrid%is_solid(i,j,k)` to be filled at every cell center in `app.F90`, including the ghost cells (`is_solid=1` for solid cells, `is_solid=0` otherwise). |

With reflecting boundary conditions, the option, e.g., `X1L_BFIELD_PMC` imposes zero gradient for the normal component and zero for the transverse component of the field.

### 6. Equation of state (see Sect. 2.2)

- `OPTION A`:

By default, Phlegethon uses the EoS of a classical ideal gas with fixed mean molecular weight and adiabatic index, which need to be specified in `app.F90`.

The option `USE_PRAD`, adds thermal radiation to the mixture. In `app.F90`, `lgrid%temp(i,j,k)` must be filled at every cell center to provide an initial estimate of the temperature for the `rhoP->T` and `rhoe->T` transformations appearing in the source code which are based on a Newton--Raphson root finding algorithm.

If `ADVECT_SPECIES` is enabled, the mean molecular weight is computed from the mass fractions of the species assuming full ionization.

- `OPTION B`:

Alternatively, one can use the `Helmholtz` EoS (see [Timmes+2000](https://ui.adsabs.harvard.edu/abs/2000ApJS..126..501T/abstract)):

| Option | Meaning |
| --- | --- |
| `HELMHOLTZ_EOS` | Uses biquintic interpolation of the free energy to compute the electron-positron EoS contribution (tabulated). In this EoS, electrons/positrons are modeled as a non interacting mixture in an arbitrarily degenerate and relativistic Fermi gas. Additional, ions are assumed to behave like as a classical ideal gas and radiation is in thermal equilibrium. As in the mode `USE_PRAD`, `lgrid%temp(i,j,k)` must be filled in `app.F90`. The EoS also needs the `ADVECT_YE_IABAR` option or the `ADVECT_SPECIES` option. |
| `path_to_helm_table=\"$(DATA)/helm_table_timmes_x1.dat\"` | This variable contains the path to the Helmholtz table and needs to be defined every time `HELMHOLTZ_EOS` is used. Note: in `$(DATA)` you find the nominal-resolution table (`helm_table_timmes_x1.dat`, `helm_nTxhelm_nrho=101x271`) and a double-resolution table (`helm_table_timmes_x2.dat`, `helm_nTxhelm_nrho=201x541`) downloaded from Frank Timmes' [cococubed](https://cococubed.com/code_pages/eos.shtml). |
| `helm_nT_make=101` | Number of nodes in the temperature axis in the Helmholtz table. |
| `helm_nrho_make=271` | Number of nodes in the density axis in the Helmholtz table. |
| `helm_ltlo_make=3.0_rp` | Minimum of $\mathrm{log}_{10}(T)$ in the Helmholtz table. |
| `helm_lthi_make=13.0_rp` | Maximum of $\mathrm{log}_{10}(T)$ in the Helmholtz table. |
| `helm_ldlo_make=-12.0_rp` | Minimum of $\mathrm{log}_{10}(\rho Y_e)$ in the Helmholtz table. |
| `helm_ldhi_make=15.0_rp` | Maximum of $\mathrm{log}_{10}(\rho Y_e)$ in the Helmholtz table. |
| `USE_COULOMB_CORRECTIONS` | Switches on coulomb corrections in the Helmholtz EoS according to [Yakovlev+89](https://ui.adsabs.harvard.edu/abs/1990SvAL...16...86Y/abstract)'s prescription. |

- `OPTION C`:

Alternatively, one can use the `PIG` Eos of Vetter et al. 2026, in prep.

| Option | Meaning |
| --- | --- |
| `PIG_EOS` | Computes a partially-ionized-gas EoS using biquintic interpolation of the free energy (PIG, tabulated) + thermal radiation. All ionization states of a bunch of elements and the electron number density are computed using Maxwell--Boltzmann statistics, and radiation is in thermal equilibrium with the gas. As in the mode `USE_PRAD`, `lgrid%temp(i,j,k)` must be filled in `app.F90`. |
| `path_to_pig_table=\"$(DATA)/pig_table.dat\"` | This variable contains the path to the PIG EoS table and needs to be defined every time `PIG_EOS` is used. |
|`pig_nT_make=401` | Number of nodes in the temperature axis in the PIG table. |
|`pig_nrho_make=401` | Number of nodes in the density axis in the PIG table. |
|`pig_ltlo_make=1.0_rp` | Minimum of $\mathrm{log}_{10}(T)$ in the PIG table. |
|`pig_lthi_make=8.0_rp` | Maximum of $\mathrm{log}_{10}(T)$ in the PIG table. |
|`pig_ldlo_make=-20.0_rp` | Minimum of $\mathrm{log}_{10}(\rho)$ in the PIG table. |
|`pig_ldhi_make=0.0_rp` | Maximum of $\mathrm{log}_{10}(\rho)$ in the PIG table. |

With `USE_PRAD`, `HELMHOLTZ_EOS`, or `PIG_EOS`, the option `USE_FASTEOS` reconstructs a pair of states for sound speed and internal energy at every grid cell interface to avoid calling the Helmholtz EoS within the Riemann solver subroutine (see Sect. 2.6). If this option is used in combination with `USE_WB`, the equilibrium state for the thermodynamic variable `gammae` must be provided at cell centers and cell faces (i.e., `lgrid%eq_gammae_cc(i,j,k)`, `lgrid%eq_gammae_x1(i,j,k)`, etc., see `./tests/hotbubble-2.0-helmholtz`).

### 7. Time Integration (see Sect. 2.9)

| Option | Meaning |
| --- | --- |
| `VARIABLE_TIMESTEP` | CFL-based adaptive timestep (Eq. 64). If not used, the code will estimate the time step from `t=0` and hold it fixed throughout the simulation. |

Choose one of the following time-marching schemes for solving the hyperbolic equations:

| Option | Meaning |
| --- | --- |
| `RK2_STEPPER` | Second-order RK time stepper of [Shu+88](https://ui.adsabs.harvard.edu/abs/1988JCoPh..77..439S/abstract). |
| `RK3_STEPPER` | Third-order RK time stepper of [Shu+88](https://ui.adsabs.harvard.edu/abs/1988JCoPh..77..439S/abstract). |

| Option | Meaning |
| --- | --- |
| `cfl_make=0.8_rp` | CFL factor |

The option `SKIP_HYDRO` will skip the hyperbolic update during the simulation.

### 8. Godunov algorithm

Choose one of the following spatial reconstruction methods (see Sect. 2.5)

| Option | Meaning |
| --- | --- |
| `LIM2ND_REC`| Second-order linear reconstruction with [van Leer](https://ui.adsabs.harvard.edu/abs/1997JCoPh.135..229V/abstract) slope limiting. |
| `PPH_REC`| Unlimited parabolic reconstruction for all variables except active scalars, for which limited parabolic reconstruction is used, based on [Leidi+24](https://ui.adsabs.harvard.edu/abs/2024A%26A...686A..34L/abstract). |
| `LIM5TH_REC`| Limited fifth-order reconstruction, based on [Leidi+24](https://ui.adsabs.harvard.edu/abs/2024A%26A...686A..34L/abstract). |

The option `USE_SHOCK_FLATTENING` will enable the shock-flattening procedure described in Sect. 2.7 (i.e., switch to a two-wave HLL Riemann solver and van Leer reconstruction in the presence of a shock). For this option to be used, the shock-flattening parameter needs to be defined by the user, e.g., `eps_sf_make=0.2`). This is such that the shock flattener will be activated if the relative jump in pressure at a certain cell location is larger than `eps_sf_make`.

Riemann solvers (see Sect. 2.6). For hydrodynamic simulations, choose one of the following options:

| Option | Meaning |
| --- | --- |
| `HLLC_FLUX`| Three-wave HLLC solver of [Toro+94](https://ui.adsabs.harvard.edu/abs/1994ShWav...4...25T/abstract). |
| `LHLLC_FLUX`| Three-wave low-Mach HLLC solver of [Minoshima+21](https://ui.adsabs.harvard.edu/abs/2021JCoPh.44610639M/abstract). |

For MHD simulations, choose one of the following

| Option | Meaning |
| --- | --- |
| `HLLD_FLUX`| Five-wave HLLD solver of [Miyoshi+05](https://ui.adsabs.harvard.edu/abs/2005JCoPh.208..315M/abstract). |
| `LHLLD_FLUX`| Five-wave low-Mach HLLD solver of [Minoshima+21](https://ui.adsabs.harvard.edu/abs/2021JCoPh.44610639M/abstract). |

For `LHLL-type` solvers, a cut-off Mach number must be specified to avoid introducing too-little dissipation in quasi-static flows, e.g., `Mach_cutoff_make=1e-4_rp`.

For `LHLL-type` solvers, if both low-Mach and supersonic flows need to be captured on the same grid, the option `FLUX_IS_ALL_MACH` will switch to a `HLL-type` solver when `Mach>0.6`.

### 9. Gravity options

| Option | Meaning |
| --- | --- |
| `USE_WB` | uses the Deviation method of [Berberich+19](https://ui.adsabs.harvard.edu/abs/2019arXiv190305154B/abstract). In `app.F90`, the cell-centered and face-centered components of $\rho$ and $P$ must be filled as, e.g., `lgrid%eq_prim_cc(i_rho:i_p:i_T,i,j,k)` and `lgrid%eq_prim_x1(i_rho:i_p:i_T,,i,j,k)` etc. |
| `USE_GRAVITY_SOLVER` | Enables time-dependent gravity by solving Poisson's equation (see Sect. 2.12), in Godunov-splitting fashion unless `GRAVITY_SOLVER_RK` is enabled. Boundary conditions are imposed on the gravitational potential by computing the monopole expansion of the mass distribution on the grid. |
| `GRAVITY_SOLVER_RK` | Solves Poisson's equation for the gravitational potential in every substage of the Runge--Kutta time stepper. |
| `GS_QUADRUPOLE_BCS` | Adds the quadrupole expansion term of the mass distribution to compute boundary conditions for the gravitational potential. |
| `GS_OCTUPOLE_BCS` | Adds the octupole expansion term of the mass distribution to compute boundary conditions for the gravitational potential (must be used in combination with `GS_QUADRUPOLE_BCS`). |
| `gs_tol_make=1e-4_rp` | Minimum tolerance for the iterative gravity solver, measured in L2 mean error norm (see Eq. 104). |
| `USE_MONOPOLE_GRAVITY` | Employs a monopole gravity solver. This option only works for internal boundaries (both 2D and 3D). |

### 10. Thermal diffusion options

| Option | Meaning |
| --- | --- |
| `STS_EVOLVE_TEMP` | Solves the temperature equation rather than the internal energy equation during the radiative diffusion step (see Sect. 2.10). To increase performance, the heat capacity $c_v$ is held fixed during the time step, so that the EoS does not have to be evaluated in every substep of the super time stepper. |
| `EVALUATE_PARABOLIC_TIMESTEP` | Adaptively changes the number of substeps in the super time stepper. |
| `BALANCE_THERMAL_DIFFUSION` | Balances the thermal diffusion operator using the equilibrium states from the well-balancing method (needs `USE_WB`). |
| `USE_TIMMES_KAPPA` | Enables the computation of radiative+conductive opacities as a function of density, composition and temperature according to [Timmes+2000](https://ui.adsabs.harvard.edu/abs/2000ApJ...528..913T/abstract) (implementation basde on [coccubed](https://cococubed.com/code_pages/kap.shtml)) |

### 11. Nuclear network options

| Option | Meaning |
| --- | --- |
| `PARTITION_FUNCTIONS_FOR_REVERSE_RATES` | Corrects the reverse rates from reaclib by including the temperature-dependent part of the partition functions of the products and reactants following [Rauscher+2000](https://ui.adsabs.harvard.edu/abs/2000ADNDT..75....1R/abstract). |
| `USE_LMP_WEAK_RATES` | Uses the Oda-Langarke-Martinez-Pinedo tabulated weak rates for the nuclear reaction network. |
| `NUCLEAR_NETWORK_GODUNOV` | Uses Godunov splitting (1st-order) to couple hydrodynamics to the nuclear network. |
| `NUCLEAR_NETWORK_STRANG` | Uses Strang splitting (2nd-order) to couple hydrodynamics to the nuclear network. |
| `NUCLEAR_NETWORK_BE` | Uses the backward Euler method (1st-order) to solve the nuclear network. |
| `NUCLEAR_NETWORK_TRBDF2` | Uses the esdirk23 method (3 stages, 2nd-order) to solve the nuclear network. |
| `nn_nltol_make=1e-13_rp` | Tolerance of the nonlinear solver used in the nuclear network calculation. |
| `nn_ltol_make=1e-13_rp` | Tolerance of the iterative linear solver (bicgstab) used in the nuclear network calculation. |
| `nn_Tmin_make=1e6_rp` | Minimum temperature to activate the network. |
| `USE_ELECTRON_SCREENING` | Uses electron screening corrections for reaction rates (2-body reactions only for now), based on [Wallace+1982](https://ui.adsabs.harvard.edu/abs/1982ApJ...258..696W/abstract). |
| `BOOST_NUCLEAR_REACTIONS` | Activates boosting of nuclear reactions rates (note: both the rate of change of the abundances and the nuclear energy generation will be boosted). |
| `boost_reacs_make=100.0_rp` | Boost factor for the nuclear reactions rates. |
| `BOOST_NEULOSS` | Activates boosting of non-nuclear neutrino losses. |
| `boost_neuloss_make=10.0_rp` | Boost factor for non-nuclear neutrino losses. |
| `SAVE_SPECIES_FLUXES` | Saves rate of change of each species due to each reaction. |

### 12. Velocity damping

| Option | Meaning |
| --- | --- |
| `USE_VDAMPING` | Enables velocity damping. All momentum components are damped thanks to a rhs source term of the form $-\nu f(r_\mathrm{min},r_\mathrm{max}) \rho \mathbf{u}$, where $\nu$ (`nu_damp`) is the maximum damping frequency, $r_\mathrm{min}$ (`rmin_damp_make`) is the radius at which damping starts, $r_\mathrm{max}$ (`rmax_damp_make`) is the radius beyond which the damping is set to the maximum, $f(r_\mathrm{min},r_\mathrm{max})$ is a smooth function of the form $0.5(1-\mathrm{cos}(\pi(r-r_\mathrm{min})/(r_\mathrm{max}-r_\mathrm{min})))$. For all grids, the cell-centered radius is taked from `lgrid%r(i,j,k)`, except for Cartesian grids that do not use internal boundarues, for which the radius is assumed to be the vertical spatial coordinate `y`. |
| `nu_damp_make=0.01_rp` | Maximum damping frequency in $\mathrm{s}^-1$ |
| `rmin_damp_make=1.0e10_rp` | Radius at which damping starts. |
| `rmax_damp_make=1.5e10_rp` | Radius beyond which the damping is set to its maximum value. |
| `USE_VARIABLE_VDAMPING` | Enables a time-dependent velocity damping. Only works with `USE_VDAMPING`. Until `tmax_damp_make` the maximum damping `nu_damp_make` frequency is used. For the time between `tmax_damp_make` and `t_end_damp_make`, the maximum damping frequency is modulated by a function of the form $\cos(\pi*(t-t_\mathrm{max})/(t_\mathrm{end}-t_\mathrm{max}))$. After tend_damp, the maximum damping frequency `nu_damp_make` is set to `0`. |
| `tmax_damp_make=1000.0_rp` | Time in $\mathrm{s}$ of simulation time for which to apply the full maximum damping frequency. |
| `tend_damp_make=1500.0_rp` | Time in $\mathrm{s}$ of simulation time when velocity damping is set to `0`. |

### 13. Simulation stopping criteria

| Option | Meaning |
| --- | --- |
|`tmax_make=30.0_rp` | The maximum simulation time. |
|`stepmax_make=100000` | The maximum number of integration steps. |
|`wctmax_make=85000.0_rp` | Maximum wall clock time of the job (in seconds). |
|`CHECK_MAX_TEMP` | If enabled, the simulation will be interrupted if the maximum temperature on the grid exceeds the value provided in the `stop_at_temp_max_make` flag |
| `stop_at_temp_max_make=1.0e10_rp` | Maximum temperature beyond which the simulation will be interrupted. |

### 14. Output options

| Option | Meaning |
| --- | --- |
|`OUTPUT_NSTEPS` | Enables output dumping every `nsteps_dump` integration steps. |
|`nsteps_dump_make=10` | Dumping frequency (only if `OUTPUT_NSTEPS` is declared). |
| `OUTPUT_DT` | Enables output dumping every (approximately) `dt_dump` of simulation time (in seconds). |
| `dt_dump_make=1.5_rp` | Dumping frequency (only if `OUTPUT_DT` is declared). |
| `info_terminal_rate_make=100000` | Frequency at which the simulation time, cycle, and time step are written to terminal. Further information on the gravity solver or the thermal diffusion step (if used) is also shown. |
| `dt_restart_make=100.0_rp` | Dumps a restart file every `dt_restart_make` of wall clock time (in seconds). |
| `RESTART_LAST` | Restarts the simulation from the restart file indicated in the last line of `restart_info.txt` (by default, the last restart). |
| `SAVE_PLANES` | Dumps 2D slices (planes) to a separate hdf5 output channel (only if `sdims_make=3`). In `app.F90`, the indices of the slices must be provided as `lgrid%planes_x1_index(<plane index>) = <x1 index>` and analogously for slices in the other directions. |
| `nplanes_x1_make=2` | Number of `(x2,x3)` planes to be saved to output. |
| `nplanes_x2_make=4` | Number of `(x1,x3)` planes to be saved to output. |
| `nplanes_x3_make=1` | Number of `(x1,x2)` planes to be saved to output. |
| `planes_dt_dump_make=1.0_rp` | Output cadence of the planes in units of simulation time. |
| `SAVE_SPHERICAL_PROJECTIONS` | Dumps spherical projections onto given radii (only if `sdims_make=3` and if `USE_INTERNAL_BOUNDARIES` is declared). |
| `nspj_make=5` | number of spherical projections |
| `spj_dt_dump_make=1.5_rp` | Output cadence of the spherical projections in units of simulation time. In `app.F90`, the radii of the projections must be provided as `lgrid%spj_r(<projection index>) = <radius of projection>`. |
| `USE_POINT_PROBES` | This option allows the value of state variables in certain cells to be saved to file at very timestep. The number of probes (`nprobes_make`) alongside their coordinates must be provided by the user. The coordinates are the indexes of the probe on the computational grid and must be specified in `app.F90` as `lgrid%pp_index(<probe index>,1)=<index along the x1 axis>` etc. |
| `nprobes_make=2` | The number of point probes used in the run. |
|`RESIZE_OUTPUT` | Performs rebinning to save a grid snapshot to the output at half the original resolution, without modifying the restart files. |

### 13. Precision and endianity

| Option| Meaning |
| --- | --- |
| `USE_SINGLE_PRECISION` / `USE_DOUBLE_PRECISION` | floating-point precision mode |
| `LITTLE_ENDIAN`  / `BIG_ENDIAN`|  endianness setting for binary I/O paths |
