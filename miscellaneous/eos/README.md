# PHLEOS (Fortran + Python)

The `misclellaneous/eos` directory contains the Equation of State (EOS) routines used by PHLEGETHON for preparation of initial condition,post-processing and analysis in Python.

Core files:

- `eos.f90`: Fortran implementation with table loading and EOS solvers.
- `phleos.py`: Python wrappers around the compiled Fortran module.
- `test.py`: End-to-end usage example on a MESA profile.

## Minimal Setup

From the repository root:

1. If you have not yet done so download required data (Helmholtz table + JINA reaclib):

```bash
bash data/get_data.sh
```

2. Compile the Fortran EOS module for Python:

```bash
cd miscellaneous/eos
f2py -c eos.f90 -m eos_fort --opt='-O3'
```
This will create a `.so` image that allows the python module to use the Fortran code.

3. Export environment variables (for example in `~/.bashrc`):

```bash
export PYTHONPATH=$PYTHONPATH:/home/<user>/phlegethon/python/
export PYTHONPATH=$PYTHONPATH:/home/<user>/phlegethon/miscellaneous/eos/
export PHLEGETHONDATA=/home/<user>/phlegethon/data/
```

## Minimal Validation

Run a test that exercises Helmholtz EOS usage in the main code:

```bash
cd tests/hotbubble-helmholtz
make clean
make
mpirun -n 4 ./run.app
```

For post-processing output checks, use the helper utilities in `python/phloutput.py`.
 
Or for an EOS-only example you can use the following:

```bash
cd miscellaneous/eos
python test.py
```
The test calls the EOS fuctions and finally reproduces the MESA sound speed profile and saves the plot in `sound.png`.

Note: `miscellaneous/eos/test.py` uses `miscellaneous/create_input_library/mesa_minireader.py` and `miscellaneous/mesa_profile_for_tests/profile10.data`.
Don't forget to define the `mesa_reader_pointer` although the default should work.


## General `eos_table` Initialization

The following snippet shows a reusable, general way to initialize the Helmholtz table in Python (same setup used in `test.py`):

```python

NRHO = 541
NT = 201
LOGRHOMIN = -12.0
LOGRHOMAX = 15.0
LOGTMIN = 3.0
LOGTMAX = 13.0

eos_table = eos_fort.eos_fort_mod.load_table(
 '%shelm_table_timmes_x2.dat'%(data),
    NRHO, NT,
    LOGRHOMIN, LOGRHOMAX,
    LOGTMIN, LOGTMAX,
)
```

Parameter definitions:

- `NRHO`: number of nodes on the density table axis.
- `NT`: number of nodes on the temperature table axis.
- `LOGRHOMIN`: minimum of $\log_{10}(\rho Y_e)$ used to build the table axis.
- `LOGRHOMAX`: maximum of $\log_{10}(\rho Y_e)$ used to build the table axis.
- `LOGTMIN`: minimum of $\log_{10}(T)$ used to build the table axis.
- `LOGTMAX`: maximum of $\log_{10}(T)$ used to build the table axis.

Derived logarithmic spacings are:

- $\Delta\log_{10}(\rho Y_e) = (\texttt{LOGRHOMAX} - \texttt{LOGRHOMIN})/(\texttt{NRHO}-1)$
- $\Delta\log_{10}(T) = (\texttt{LOGTMAX} - \texttt{LOGTMIN})/(\texttt{NT}-1)$


Notes:

- In Helmholtz mode, interpolation uses $\rho Y_e$.
- In PIG mode, the implementation sets $Y_e=1$, so this axis reduces to $\rho$.
- For consistency, these values must match the selected table file resolution/range (for example `helm_table_timmes_x2.dat` uses 201x541).

You can use this `eos_table` object in all EOS wrapper calls (`rhoT_given`, `rhoP_given`, `PT_given`, `Ps_given`).

## EOS Modes

`eos_mode` is a list of strings. Available contributions are:

- `ideal`: ideal gas term`.
- `ions`: ion ideal-gas term.
- `radiation`: thermal radiation term.
- `elepos`: electron-positron contribution from the Helmholtz table.
- `coulomb`: Coulomb correction term.
- `pig`: partially-ionized-gas mode (uses PIG table, see documentation).

## EOS Functions (Python)

All wrappers in `phleos.py` accept scalar, 1D, 2D, or 3D inputs (internally promoted to 3D) and return NumPy arrays with consistent dimensionality.
In all wrappers, `full` is the first return value and contains 23 EOS quantities (see **Returned Quantities (`full` array)** below).

1. `rhoT_given(eos_table, rho, T, abar=1.0, zbar=1.0, gamma_ideal=5.0/3.0, eos_mode=['ideal'])`

- Required parameters:
    - `eos_table`: preloaded EOS table from `eos_fort.eos_fort_mod.load_table`.
    - `rho`: density.
    - `T`: temperature.
- Optional parameters:
    - `abar` (default `1.0`): mean atomic mass.
    - `zbar` (default `1.0`): mean charge.
    - `gamma_ideal` (default `5.0/3.0`): ideal-gas adiabatic index used by `ideal` mode.
    - `eos_mode` (default `['ideal']`): active EOS contributions.
- Returns: `full`.

2. `rhoP_given(eos_table, rho, P, abar=1.0, zbar=1.0, Tguess=-1.0, gamma_ideal=5.0/3.0, eos_mode=['ideal'])`

- Required parameters:
    - `eos_table`: preloaded EOS table.
    - `rho`: density.
    - `P`: pressure.
- Optional parameters:
    - `abar` (default `1.0`): mean atomic mass.
    - `zbar` (default `1.0`): mean charge.
    - `Tguess` (default `-1.0`): initial temperature guess; if `< 0`, an ideal-gas estimate is used.
    - `gamma_ideal` (default `5.0/3.0`): ideal-gas adiabatic index used by `ideal` mode.
    - `eos_mode` (default `['ideal']`): active EOS contributions.
- Returns: `full, T`.

3. `PT_given(eos_table, P, T, abar=1.0, zbar=1.0, rhoguess=-1.0, gamma_ideal=5.0/3.0, eos_mode=['ideal'])`

- Required parameters:
    - `eos_table`: preloaded EOS table.
    - `P`: pressure.
    - `T`: temperature.
- Optional parameters:
    - `abar` (default `1.0`): mean atomic mass.
    - `zbar` (default `1.0`): mean charge.
    - `rhoguess` (default `-1.0`): initial density guess; if `< 0`, an ideal-gas estimate is used.
    - `gamma_ideal` (default `5.0/3.0`): ideal-gas adiabatic index used by `ideal` mode.
    - `eos_mode` (default `['ideal']`): active EOS contributions.
- Returns: `full, rho` where `full` contains 23 EOS quantities evaluated at `(rho, T)`.

4. `Ps_given(eos_table, P, s, rhoguess, Tguess, abar=1.0, zbar=1.0, gamma_ideal=5.0/3.0, eos_mode=['ideal'])`

- Required parameters:
    - `eos_table`: preloaded EOS table.
    - `P`: pressure.
    - `s`: specific entropy.
    - `rhoguess`: initial density guess.
    - `Tguess`: initial temperature guess.
- Optional parameters:
    - `abar` (default `1.0`): mean atomic mass.
    - `zbar` (default `1.0`): mean charge.
    - `gamma_ideal` (default `5.0/3.0`): ideal-gas adiabatic index used by `ideal` mode.
    - `eos_mode` (default `['ideal']`): active EOS contributions.
- Returns: `full, rho, T`.



## Returned Quantities (`full` array)

Indices are zero-based in Python (`phleos.py`):
`full` has shape `(23, ...)`, where trailing dimensions follow your input shape (scalar, 1D, 2D, or 3D).

- `id_P = 0`: pressure, $P$
- `id_E = 1`: specific internal energy, $E$
- `id_dPdrho = 2`: density derivative of pressure at fixed temperature, $(\partial P / \partial \rho)_T$
- `id_dPdT = 3`: temperature derivative of pressure at fixed density, $(\partial P / \partial T)_\rho$
- `id_dEdrho = 4`: density derivative of specific internal energy at fixed temperature, $(\partial E / \partial \rho)_T$
- `id_dEdT = 5`: temperature derivative of specific internal energy at fixed density, $(\partial E / \partial T)_\rho$
- `id_cv = 6`: specific heat at constant volume, $c_v$
- `id_chiT = 7`: logarithmic temperature derivative of pressure, $\chi_T$
- `id_chirho = 8`: logarithmic density derivative of pressure, $\chi_\rho$
- `id_gam1 = 9`: first adiabatic exponent, $\Gamma_1$
- `id_sound = 10`: adiabatic sound speed, $c_s$
- `id_cp = 11`: specific heat at constant pressure, $c_p$
- `id_gam2 = 12`: second adiabatic exponent, $\Gamma_2$
- `id_gam3 = 13`: third adiabatic exponent, $\Gamma_3$
- `id_nabla_ad = 14`: adiabatic temperature gradient, $\nabla_{\mathrm{ad}}$
- `id_s = 15`: specific entropy, $s$
- `id_dsdrho = 16`: density derivative of entropy at fixed temperature, $(\partial s / \partial \rho)_T$
- `id_dsdT = 17`: temperature derivative of entropy at fixed density, $(\partial s / \partial T)_\rho$
- `id_delta = 18`: thermodynamic delta, $\delta$
- `id_eta = 19`: degeneracy parameter, $\eta$
- `id_nep = 20`: electron-positron number quantity, $n_{e^{\pm}}$
- `id_phi = 21`: auxiliary EOS quantity, $\phi$
- `id_dPdA = 22`: derivative of pressure with respect to mean atomic mass, $\partial P / \partial \bar{A}$

Typical field extraction:

```python
from phleos import id_P, id_E, id_sound, id_s

P = full[id_P]
E = full[id_E]
cs = full[id_sound]
s = full[id_s]
```

## Minimal Method Notes

Quick numerical overview (from `eos.f90`):

- The Helmholtz/PIG EOS is evaluated from pre-tabulated data defined on uniform $\log_{10}(\rho Y_e)$ and $\log_{10}(T)$ grids.
- At runtime, thermodynamic quantities are reconstructed with a high-order 2D interpolation that uses both tabulated values and tabulated derivatives.
- Final EOS outputs are built by summing the active contributions selected in `eos_mode` (`ideal`, `ions`, `radiation`, `elepos`, `coulomb`, `pig`).
- `rhoP_given_3d` solves for $T$ with a 1D Newton-Raphson iteration using $(\partial P/\partial T)_\rho$.
- `PT_given_3d` solves for $\rho$ with a 1D Newton-Raphson iteration using $(\partial P/\partial \rho)_T$.
- `Ps_given_3d` performs a coupled 2D Newton-Raphson solve in $(\rho, T)$ using a $2\times2$ Jacobian built from pressure/entropy derivatives.
- Inverse solves are bounded to table limits for stability and stop at relative residual $<10^{-11}$ (up to 1000 iterations).
