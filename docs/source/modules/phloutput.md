(phloutput)=
# phloutput (Python post-processing utilities)

The module `python/phloutput.py` provides tools to read Phlegethon HDF5 outputs and quickly produce diagnostics and figures.
It is designed for:

- loading full grid snapshots (`grid_nXXXXX.h5`),
- loading pre-extracted 2D planes (`planes_nXXXXX.h5`),
- loading spherical projection outputs (`spj_nXXXXX.h5`),
- extracting radial/time diagnostics,
- making publication-ready plots directly from Python.

## Minimal requirements

`phloutput.py` depends on:

- `numpy`, `scipy`, `matplotlib`, `h5py`,
- the EOS Python wrapper (`phleos.py`) and its Fortran module.

Typical environment setup (adapt paths to your machine):

```bash
export PYTHONPATH=$PYTHONPATH:/home/<user>/phlegethon/python/
export PYTHONPATH=$PYTHONPATH:/home/<user>/phlegethon/miscellaneous/eos/
export PHLEGETHONDATA=/home/<user>/phlegethon/data/
```

If `PHLEGETHONDATA` is not set, `phloutput.py` falls back to `../../data/`.

## Quick start

This section focuses on the most commonly used workflow: initialize a snapshot, inspect basic fields, plot a 2D slice with `gridshow`, make a radial profile with `radialshow`, and quickly inspect plane/spherical-projection outputs.
Unless noted otherwise, the examples below assume an interactive Python environment (IPython/Jupyter).

### 1. Initialize one snapshot (`h5grid`)

```python
import numpy as np
from matplotlib.colors import LogNorm
from phloutput import h5grid

# Path containing grid_nXXXXX.h5 files
path = "./"

# mode='i' means: index into the sorted file list (0 = first snapshot)
grid = h5grid(25, path=path, mode='i')

print("time [s] =", grid.time)
print("step     =", grid.step)
print("geometry =", grid.geometry)
print("dims     =", grid.nx1, grid.nx2, grid.nx3)
```
If you are already in the directory where the snapshots are located, you can use defaults and run just: `grid = h5grid(25)`.
Note that snapshot `0` must always be present, because it contains static data that is not saved in later snapshots.

### 2. Get basic physical fields

```python
rho = grid.rho()      # density
T = grid.T()          # temperature
P = grid.P()          # pressure
vel = grid.vel()      # velocity components
mach = grid.mach()    # |v| / cs
```

### 3. Plot a slice with `gridshow`

For 3D runs, select a plane with one fixed index (`ix`, `iy`, or `iz`).

```python
grid.gridshow(
    grid.rho(iz=0),
    cmap='magma',
    norm=LogNorm(),
    cb_lbl=r'$\rho\ [\mathrm{g\ cm^{-3}}]$',
    coords_in_Rsun=True)
```
Dependent on your set-up, you might then have to `show()`. For a minimal call with defaults you can use simply: `grid.gridshow(grid.rho(iz=0))`

### 4. Radial profile with `radialshow`

```python
grid.radialshow(
    grid.rho(),
    y_lbl=r'$\rho\ [\mathrm{g\ cm^{-3}}]$',
    coords_in_Rsun=True,
)
```
Again, you might then have to `show()`. For a minimal call with defaults you can use simply: `grid.radialshow(grid.rho(iz=0))`
If you want the profile values directly:

```python
r_axis = grid.r2raxis()
rho_profile = grid.radial_profile(grid.rho())
```

### 5. Quick time profile over many snapshots

Use `timeprof` to evaluate one expression for multiple outputs.

```python
# Expression is evaluated in h5grid context
t, max_mach = timeprof(
    "np.max(self.mach())",
    i1=0,
    i2=50,
    delta=1,
    path=path,
)
```

### 6. Quick look at planes and spherical projections

If your run writes `planes_nXXXXX.h5`, use `h5plane`:

```python
pl = h5plane(0, path=path, path_to_grids=path, mode='i')
pl.planeshow(pl.rho(iz=0))
```

If your run writes `spj_nXXXXX.h5`, use `h5spj`:

```python
spj = h5spj(0, path=path, path_to_grids=path, mode='i')
spj.mollweide(spj.rho(ir=0), cmap='viridis', cb_lbl=r'$\rho$')
```

For both classes, `path_to_grids` should point to a directory containing  also `grid_n00000.h5`.

## Core concepts

### Slice selection convention

Many methods accept `ix`, `iy`, `iz`:

- `ix>=0`: plane at constant `x1` index,
- `iy>=0`: plane at constant `x2` index,
- `iz>=0`: plane at constant `x3` index,
- all negative (default): return full volume.

For 2D simulations (`sdims==2`), the internal logic forces a single plane. The meaning of each index depends on the geometry.

### EOS derived quantities

Methods like `sound`, `cp`, `cv`, `nabla_ad`, `gamma1`, `s`, `delta`, `phi` call the EOS through `phleos`.
So thermodynamic outputs are consistent with the run setup (ideal/radiation/Helmholtz/PIG depending on metadata saved in the 0th snapshot).

## Comprehensive overview

### 1. Snapshot and file helpers

- `file_list(path="")`: list and sort `grid_nXXXXX.h5`.
- `plane_list(path="")`: list and sort `planes_nXXXXX.h5`.
- `spj_list(path="")`: list and sort `spj_nXXXXX.h5`.
- `read_data(file, n1)`: read binary point-probe chunk data.
- `timeprof(expr, i1=0, i2=-1, delta=1, path="")`: evaluate an expression over multiple `h5grid` snapshots.
- `generate_grid_free(...)`: helper to build custom matplotlib subplot grids.

### 2. `h5grid`: full-grid reader and diagnostics

`h5grid` is the main class for regular Phlegethon outputs (`grid_nXXXXX.h5`).

Initialize:

```python
grid = h5grid(
    12,
    path="./",
    mode='i',
    data_path="../../data/",
    helm_table='helm_table_timmes_x2.dat',
    pig_table='401x401_pig_table_h2_offset.dat',
)
```

### Metadata and geometry

- Attributes (no function call): `time`, `dt`, `step`, `nx1`, `nx2`, `nx3`, `sdims`, `geometry`.
- Geometry methods (call with parentheses):
  - `coords(ix=-1, iy=-1, iz=-1)`
  - `r()`
  - `vol()`

### Methods

 In grouped method lists below, the first method shows the full signature; methods shown as `method()` use the same `ix/iy/iz` defaults unless noted otherwise.

### Primitive and composition fields

- Hydrodynamics/MHD primitives:
  - `rho(ix=-1, iy=-1, iz=-1)`, `vel()`, `P()`, `T()`, `asc()`, `X_species()`, `bfield()`
- Composition and mixture quantities:
  - `ye(ix=-1, iy=-1, iz=-1)`, `abar()`, `zbar()`, `mu()`

### Derived flow and magnetic diagnostics

- Flow kinematics:
  - `mom(ix=-1, iy=-1, iz=-1)`, `abs_vel()`, `vr()`, `vh()`, `ekin()`
- Magnetic diagnostics:
  - `emag(ix=-1, iy=-1, iz=-1)`, `abs_bfield()`, `br()`, `bh()`

### Thermodynamics and stability (EOS-based)

- Thermodynamics:
  - `eint(ix=-1, iy=-1, iz=-1)`, `enthalpy()`, `etot()`, `sound()`, `mach()`, `mach_vec()`
  - `cp(ix=-1, iy=-1, iz=-1)`, `cv()`, `s()`, `nabla_ad()`, `delta()`, `phi()`
  - `gamma1(ix=-1, iy=-1, iz=-1)`, `gamma2()`, `gamma3()`
- Gradients/stability:
  - `grad_r(data, ix=-1, iy=-1, iz=-1)`: radial derivative of an input field, evaluated consistently with the active geometry.
  - `nabla(ix=-1, iy=-1, iz=-1)`, `nabla_mu()`, `ledoux_stability(relative=True, ix=-1, iy=-1, iz=-1)`, `bvf2()`, `bvf()`

### Gravity and nuclear-network quantities

- Gravity:
  - `grav(ix=-1, iy=-1, iz=-1)`, `phipot()`, `epot()`
- Nuclear diagnostics:
  - `edot_reacs(ix=-1, iy=-1, iz=-1)`, `dXdt_reacs()`, `dXdt()`, `edot_nuc()`, `neuloss()`

### Profiles and utility methods

- Profiles/axes:
  - `radial_profile(quant, ib_bins=None, slices=False, s1=-1, s2=-1, s3=-1)`: angle-averaged (or shell-binned) radial profile of a field.
  - `r2raxis()`: radius axis corresponding to radial-profile outputs.
  - `r2maxis()`: cumulative mass axis inferred from radius and radial density profile.


### Plotting methods in `h5grid`

- `gridshow(out, ichx=ichx_g, ichy=ichy_g, figdpi=500, figname=None, show_cb=True, x_lbl=None, y_lbl=None, cb_lbl='', cb_pad=0.05, cb_size=cb_size_g, cb_pos='right', time_in_days=True, coords_in_Rsun=True, showfig=True, Rstar=-1, use_latex=False, fontsize=fontsize, **kwargs)`: plot a 2D map of the input slice field `out`.
- `radialshow(quant, ib_bins=None, slices=False, s1=-1, s2=-1, s3=-1, figdpi=500, figname=None, x_lbl=r'$r$', y_lbl='$q$', time_in_days=True, coords_in_Rsun=True, showfig=True, use_latex=False, fontsize=fontsize, ichx=ichx_g, ichy=ichy_g, **kwargs)`: compute and plot a radial profile from `quant`.

### 3. `h5plane`: reader for pre-extracted planes

`h5plane` reads `planes_nXXXXX.h5`, which store selected slices already written by the simulation.

Initialize:

```python
pl = h5plane(
    0,
    path="./",
    path_to_grids="./",
    mode='i',
    data_path="../../data/",
    helm_table='helm_table_timmes_x2.dat',
    pig_table='401x401_pig_table_h2_offset.dat',
)
```

### Metadata and plane selection

- Attributes (no function call): `time`, `dt`, `step`, `nplanes_x1`, `nplanes_x2`, `nplanes_x3`.
- Plane-index maps: `planes_x1_index`, `planes_x2_index`, `planes_x3_index` map simulation grid indices to stored slices.
- `path_to_grids` should point to a directory containing `grid_n00000.h5` metadata/EOS context.

### Methods

 In grouped method lists below, the first method shows the full signature; methods shown as `method()` use the same `ix/iy/iz` defaults unless noted otherwise.

### Primitive and composition fields

- Hydrodynamics/MHD primitives:
  - `prim(ix=-1, iy=-1, iz=-1)`, `T()`, `rho()`, `vel()`, `P()`, `asc()`, `X_species()`, `bfield()`
- Composition and mixture quantities:
  - `ye(ix=-1, iy=-1, iz=-1)`, `abar()`, `zbar()`, `mu()`

### Derived flow and magnetic diagnostics

- Flow kinematics:
  - `mom(ix=-1, iy=-1, iz=-1)`, `abs_vel()`, `vr()`, `vh()`, `ekin()`
- Magnetic diagnostics:
  - `emag(ix=-1, iy=-1, iz=-1)`, `abs_bfield()`, `br()`, `bh()`

### Thermodynamics (EOS-based)

- Thermodynamics:
  - `eint(ix=-1, iy=-1, iz=-1)`, `enthalpy()`, `sound()`, `mach()`, `mach_vec()`
  - `cp(ix=-1, iy=-1, iz=-1)`, `cv()`, `nabla_ad()`, `s()`, `delta()`, `phi()`
  - `gamma1(ix=-1, iy=-1, iz=-1)`, `gamma2()`, `gamma3()`

### Plotting methods in `h5plane`

- `planeshow(out, ichx=ichx_g, ichy=ichy_g, figdpi=500, figname=None, x_lbl=None, y_lbl=None, cb_lbl='', cb_pad=0.05, cb_size=cb_size_g, cb_pos='right', time_in_days=True, coords_in_Rsun=True, Rstar=-1, showfig=True, use_latex=False, fontsize=fontsize, **kwargs)`: plot a 2D map of the selected plane field `out`.

Typical use with defaults:

```python
pl = h5plane(42)

rho_plane = pl.rho(iz=50)
pl.planeshow(rho_plane)
```

### 4. `h5spj`: reader for spherical projection outputs

`h5spj` reads `spj_nXXXXX.h5` files with values on selected spherical shells.

Initialization:

```python

spj = h5spj(
    0,
    path="./",
    path_to_grids="./",
    mode='i',
    data_path="../../data/",
    helm_table='helm_table_timmes_x2.dat',
    pig_table='401x401_pig_table_h2_offset.dat',
)
```

### Metadata and shell geometry

- Attributes (no function call): `time`, `dt`, `step`, `r`, `nhydro`.
- For each radial shell, the corresponding angular arrays (`phi`, `theta`) are loaded and used internally by both `coords(ir=0)` and `mollweide(...)`.
- `path_to_grids` should point to a directory containing `grid_n00000.h5` metadata/EOS context.

### Methods

 In grouped method lists below, the first method shows the full signature; methods shown as `method()` use the same `ir` default unless noted otherwise.

### Primitive and composition fields

- Hydrodynamics/MHD primitives:
  - `prim(ir=0)`, `T()`, `rho()`, `vel()`, `P()`, `asc()`, `X_species()`, `bfield()`
- Geometry and composition quantities:
  - `coords(ir=0)`, `ye()`, `abar()`, `zbar()`, `mu()`

### Derived flow and magnetic diagnostics

- Flow kinematics:
  - `mom(ir=0)`, `abs_vel()`, `vr()`, `vh()`, `ekin()`
- Magnetic diagnostics:
  - `emag(ir=0)`, `abs_bfield()`, `br()`, `bh()`

### Thermodynamics (EOS-based)

- Thermodynamics:
  - `eint(ir=0)`, `enthalpy()`, `sound()`, `mach()`, `mach_vec()`
  - `cp(ir=0)`, `cv()`, `nabla_ad()`, `s()`, `delta()`, `phi()`
  - `gamma1(ir=0)`, `gamma2()`, `gamma3()`

### Plotting methods in `h5spj`

- `mollweide(out, ichx=ichx_g, ichy=ichy_g, figdpi=500, figname=None, cb_lbl='', cb_pad=0.05, cb_pos='horizontal', time_in_days=True, coords_in_Rsun=True, showfig=True, showgrid=False, use_latex=False, fontsize=fontsize, **kwargs)`: render a Mollweide projection of a shell field.

Typical use with defaults:

```python
spj = h5spj(42)

rho_shell = spj.rho(ir=50)
spj.mollweide(np.log10(rho_shell))

```

### 5. `Probe`: point-probe time series and spectra

A point probe is at one fixed grid location that records selected simulation variables as the run evolves. `Probe` reads all `pp<id>_<chunk>.dat` files for one probe ID and stitches the chunked records into one continuous time series.

Initialize:

```python
probe = Probe(nprobe=1, dire="./")
```

- `nprobe`: probe ID to load. Files are matched as `pp<nprobe>_<chunk>.dat`.
- `dire`: directory containing the probe files.
- Location is selected implicitly by `nprobe`.



### Methods

- `time_series(idx_var=0)`: load/concatenate one variable from all chunks and populate `t`, `dt`, and `signal`.
- `power_spectrum(tini, tfin, Nw=11, subtract_base=True)`: compute a windowed FFT spectrum on a selected interval and populate `t_cut`, `signal_cut`, `dt_cut`, `freq`, and `pow`.

Method input parameters:

- `idx_var`: zero-based column index of the signal to extract from probe files (see table below).

| Build configuration | `idx_var` meanings (signal columns) |
| --- | --- |
| Hydro, 2D (no MHD) | `0: rho`, `1: vx1`, `2: vx2`, `3: p`, `4: T` |
| Hydro, 3D (no MHD) | `0: rho`, `1: vx1`, `2: vx2`, `3: vx3`, `4: p`, `5: T` |
| MHD, 2D | `0: rho`, `1: vx1`, `2: vx2`, `3: p`, `4: Bx`, `5: By`, `6: T` |
| MHD, 3D | `0: rho`, `1: vx1`, `2: vx2`, `3: vx3`, `4: p`, `5: Bx`, `6: By`, `7: Bz`, `8: T` |

- `tini`: start time of the interval used for the spectrum (`probe.t >= tini`).
- `tfin`: end time of the interval used for the spectrum (`probe.t <= tfin`).
- `Nw`: smoothing window size (number of bins) applied to the power spectrum via a moving average.
- `subtract_base`: if `True`, remove a quadratic baseline trend from the selected signal segment before FFT.

Call `time_series(...)` before `power_spectrum(...)`, because the latter uses `probe.t` and `probe.signal` created by `time_series`.




Time is always is loaded automatically into `probe.t`.

Typical use:

```python
probe = Probe(nprobe=1)

probe.time_series(idx_var=0)

probe.power_spectrum(
    tini=probe.t[0],
    tfin=probe.t[-1],
    Nw=11,
    subtract_base=True,
)

# Results:
# probe.t, probe.signal, probe.freq, probe.pow
```


