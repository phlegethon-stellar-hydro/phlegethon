# create_network

This directory provides a Python utility that generates nuclear-network Fortran routines and appends them to a target setup file (for example `app.F90` in one of the test problems).

Files:

- `create_network.py`: selects reaction rates from JINA REACLIB (and optionally Langanke-Martinez-Pinedo weak tables) for user-defined thermodynamic conditions and writes Fortran code blocks to the target setup file.

## What the Script Does

`create_network.py` performs the following steps:

1. Reads isotope metadata (`A`, `Z`) from `sunet.dat`.
2. Optionally reads tabulated weak rates from `lmp_weak_rates.txt`.
3. Reads JINA REACLIB rates and keeps only reactions composed of the selected isotopes.
4. Filters reactions by a timescale criterion at the specified `T9` and `rho`.
5. Removes duplicate reactions and computes effective rates.
6. Reads partition functions from `part.txt`.
7. Prints selected network content to stdout (`#species`, reaction list, `#reactions`).
8. Rewrites/extends the target Fortran file with generated network routines.

## Typical Workflow

1. Choose isotopes in `sps` and thermodynamic filter values (`T9`, `rho`, `tau`).
2. Set `path_to_target`, `target`, and `end_target` for the Fortran setup to update.
3. Set `path_to_data` and verify required files exist there.
4. Run `python3 create_network.py`.
5. Check stdout summary (`#species`, reaction list, `#reactions`).
6. Ensure build settings are consistent with the generated network:
   - `nspecies_make` should match `len(sps)`.
   - `nreacs_make` should match generated reaction count.
7. Rebuild and run your test/setup.

## Configuration (Edit in Script)

`create_network.py` is enabled by editing variables near the top of the file (no CLI arguments are parsed).

- `sps` (`list[str]`): isotope names used in the network (must match naming in input tables).
- `T9` (`float`): temperature in units of $10^9$ K.
- `rho` (`float`): density in g cm $^{-3}$.
- `tau` (`float`): maximum allowed reaction timescale in seconds for reaction selection.
- `path_to_target` (`str`): directory containing the target Fortran setup file.
- `target` (`str`): target Fortran setup file path, typically `path_to_target + 'app.F90'`.
- `end_target` (`str`): marker line used to truncate existing generated content (example: `end program test`).
- `path_to_data` (`str`): directory containing nuclear data tables.
- `full_output` (`bool`): if `True`, prints extra reaction diagnostics (Q-value, reverse flag, timescale).
- `use_weak_rates` (`bool`): enables LMP weak-rate ingestion.
- `jina_reaclib_file` (`str`): REACLIB filename inside `path_to_data`.



## Run

From this directory:

```bash
python3 create_network.py
```

There are no command-line parameters. Adjust the top-of-file configuration and rerun.

## Generated Fortran Routines & Makefile options

The script appends generated code to `target`. Before appending, it scans the file and truncates at the first line matching `end_target`, so regenerating the network replaces the previous generated block instead of duplicating it.

Core generated subroutines (always written):

- `extract_network_information(lgrid)`: fills network metadata in `lgrid`, including species (`A`, `Z`, names), reaction names, and tables needed by optional features.
- `compute_jina_rates(T9, R)`: evaluates REACLIB fit coefficients at the current temperature and fills the base reaction-rate array `R(1:nreacs)`.
- `compute_network_residuals(Y, rho, R, res, jac, dedt, return_jac, return_dedt)`: computes the species ODE residual vector (`res`), and optionally computes the Jacobian (`jac`) and per-reaction energy terms (`dedt`) for implicit solves.

Optional generated subroutines (guarded by compile-time macros):

- `USE_LMP_WEAK_RATES`:
  - `compute_weak_rates(rhoye, T9, dt, weak_table, weak_neu, neu_rates, R)`: interpolates LMP weak tables, updates the relevant entries in `R`, and updates weak neutrino-rate bookkeeping.
  - `compute_weak_neuloss(rho, Y, neu_rates, dedt)`: converts weak neutrino losses into energy-source corrections in `dedt`.
- `PARTITION_FUNCTIONS_FOR_REVERSE_RATES`:
  - `use_partition_functions(T9, temp_part, part, R)`: rescales reverse reaction rates using partition-function ratios.
- `USE_ELECTRON_SCREENING`:
  - `screen_rates(rho, T, Y, rates)`: applies electron-screening enhancement factors to charged-particle rates.
- `SAVE_SPECIES_FLUXES`:
  - `species_residuals_per_reac(Y, rho, R, Xds)`: stores per-species, per-reaction flux contributions for diagnostics/output.

Example (simulation `Makefile`) to enable these options:

```makefile
# nuclear network (required)
OPTS += USE_NUCLEAR_NETWORK

# optional generated network features
OPTS += USE_LMP_WEAK_RATES
OPTS += PARTITION_FUNCTIONS_FOR_REVERSE_RATES
OPTS += USE_ELECTRON_SCREENING
OPTS += SAVE_SPECIES_FLUXES

# optional reaction-rate boosting
OPTS += BOOST_NUCLEAR_REACTIONS
OPTS += boost_reacs_make=100.0_rp
```

`BOOST_NUCLEAR_REACTIONS` represents the option to multiply nuclear energy generation rates by a boosting factors:
- Enable it in the simulation `Makefile` with `OPTS += BOOST_NUCLEAR_REACTIONS`.
- Control the boost factor with `OPTS += boost_reacs_make=<value>` (for example `100.0_rp`).
In practice, the boosting is applied consistently to all network rates and to weak neutrino-rate bookkeeping, so source-term scaling remains synchronized. The same boosting factor is also applied for neutrino-rate scaling.

Notes:

- Remember to keep `use_weak_rates` in `create_network.py` if `USE_LMP_WEAK_RATES` is enabled in the `Makefile`.
- `nspecies_make` and `nreacs_make` in the `Makefile` should also match what used in the `create_network.py` file.

For concrete generated examples, see `tests/nuclear-network/app.F90` and `tests/burning-bubble/app.F90`.


## Example: `tests/nuclear-network`

This is a compact network-focused validation case that already contains generated routines in `app.F90`.
It is useful as a template because it isolates the burning routine from the hydrodynamics.

What this example is configured to do:

- Use a minimal setup with one active cell (`nx1_make=1`, `nx2_make=1`, `nx3_make=1`).
- Evolve species with the Helmholtz EOS and a nuclear network (`ADVECT_SPECIES`, `HELMHOLTZ_EOS`, `USE_NUCLEAR_NETWORK`).
- Solve the network implicitly with Backward Euler (`NUCLEAR_NETWORK_BE`) and Godunov splitting (`NUCLEAR_NETWORK_GODUNOV`).
- Enable electron screening (`USE_ELECTRON_SCREENING`).
- Skip the hydro update (`SKIP_HYDRO`) so the run mainly exercises the network integration path.
- Use `nspecies_make=9` and `nreacs_make=8`, matching the generated block in `app.F90`.

Initial thermodynamic/composition setup in `tests/nuclear-network/app.F90`:

- `rho = 1.0e4` g cm $^{-3}$
- `T = 2.0e8` K
- `X(p)=0.5`, `X(he4)=0.25`, `X(c12)=0.25`

The generated reaction names in this example correspond to a small hot-CNO-like network (for example `p+c12->n13`, `p+n15->he4+c12`) and demonstrate how the selected reactions are embedded in the setup file.

How to build and run this example:

```bash
cd tests/nuclear-network
make clean
make
mpirun -n 1 ./run.app
```

If you regenerate this case with `create_network.py`, point `path_to_target` to `../../tests/nuclear-network/` and re-check that `nspecies_make` and `nreacs_make` in the test `Makefile` still match the regenerated network.


The following shows the three pieces together: Python configuration, generated Fortran, and compile-time `OPTS`.

1. Configure `create_network.py` for this test:

```python
sps = ['p','he4','c12','c13','n13','n14','n15','o14','o15']
T9 = 0.2
rho = 1e4
tau = 1.0e5

path_to_target = '../../tests/nuclear-network/'
target = path_to_target + 'app.F90'
end_target = 'end program test'

path_to_data = '../../data/'

full_output = True
use_weak_rates = True
jina_reaclib_file = 'jina_reaclib_default'
```

2. Running the script writes Fortran blocks like this into `tests/nuclear-network/app.F90`:

```fortran
#ifdef USE_NUCLEAR_NETWORK
subroutine extract_network_information(lgrid)
  use source
  type(locgrid), intent(inout) :: lgrid

  lgrid%A(1)=1.0_rp
  lgrid%A(2)=4.0_rp
  ...
  lgrid%A(9)=15.0_rp

  lgrid%name_species(1)='p'
  ...
  lgrid%name_species(9)='o15'

  lgrid%name_reacs(1)='n13-->c13'
  ...
  lgrid%name_reacs(8)='p+n15-->he4+c12'
end subroutine extract_network_information

subroutine compute_jina_rates(T9,R)
  ...
end subroutine compute_jina_rates

subroutine compute_network_residuals(Y,rho,R,res,jac,dedt,return_jac,return_dedt)
  ...
end subroutine compute_network_residuals
#endif
```

3. The matching compile-time options in `tests/nuclear-network/Makefile` are:

```makefile
OPTS += nas_make=9
OPTS += nspecies_make=9
OPTS += nreacs_make=8

OPTS += ADVECT_SPECIES
OPTS += HELMHOLTZ_EOS

OPTS += USE_NUCLEAR_NETWORK
OPTS += USE_ELECTRON_SCREENING
OPTS += NUCLEAR_NETWORK_GODUNOV
OPTS += NUCLEAR_NETWORK_BE
OPTS += nn_Tmin_make=1e6_rp
OPTS += nn_nltol_make=1.0e-15_rp
OPTS += nn_ltol_make=1.0e-15_rp

OPTS += SKIP_HYDRO
```

If you also want weak-rate tables, partition-function correction, reaction-rate boosting, or per-reaction species flux output active at compile time, add:

```makefile
OPTS += USE_LMP_WEAK_RATES
OPTS += PARTITION_FUNCTIONS_FOR_REVERSE_RATES
OPTS += SAVE_SPECIES_FLUXES
OPTS += BOOST_NUCLEAR_REACTIONS
OPTS += boost_reacs_make=100.0_rp
```



