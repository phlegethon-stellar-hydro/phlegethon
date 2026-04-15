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

This section focuses on the most commonly used workflow: initialize a snapshot, inspect basic fields, plot a 2D slice with `gridshow`, and make a radial profile with `radialshow`.

### 1. Initialize one snapshot (`h5grid`)

```python
import numpy as np
from matplotlib.colors import LogNorm
from phloutput import h5grid

# Path containing grid_nXXXXX.h5 files
path = "./"

# mode='i' means: index into the sorted file list (0 = first snapshot)
grid = h5grid(0, path=path, mode='i')

print("time [s] =", grid.time)
print("step     =", grid.step)
print("geometry =", grid.geometry)
print("dims     =", grid.nx1, grid.nx2, grid.nx3)
```

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
rho_xy = grid.rho(iz=0)

fig, ax = grid.gridshow(
    rho_xy,
    cmap='magma',
    norm=LogNorm(),
    cb_lbl=r'$\rho\ [\mathrm{g\ cm^{-3}}]$',
    coords_in_Rsun=True,
)

fig.savefig("rho_xy.png", dpi=300)
```

### 4. Radial profile with `radialshow`

```python
fig, ax = grid.radialshow(
    grid.rho(),
    y_lbl=r'$\rho\ [\mathrm{g\ cm^{-3}}]$',
    coords_in_Rsun=True,
)

fig.savefig("rho_radial.png", dpi=300)
```

If you want the profile values directly:

```python
r_axis = grid.r2raxis()
rho_profile = grid.radial_profile(grid.rho())
```

### 5. Quick time profile over many snapshots

Use `timeprof` to evaluate one expression for multiple outputs.

```python
from phloutput import timeprof

# Expression is evaluated in h5grid context (use self.<method>())
t, max_mach = timeprof(
    "np.max(self.mach())",
    i1=0,
    i2=50,
    delta=1,
    path=path,
)
```

## Core concepts

### Slice selection convention

Many methods accept `ix`, `iy`, `iz`:

- `ix>=0`: plane at constant `x1` index,
- `iy>=0`: plane at constant `x2` index,
- `iz>=0`: plane at constant `x3` index,
- all negative (default): return full volume.

For 2D simulations (`sdims==2`), the internal logic forces a single plane.

### EOS-aware derived quantities

Methods like `sound`, `cp`, `cv`, `nabla_ad`, `gamma1`, `s`, `delta`, `phi` call the EOS through `phleos`.
So thermodynamic outputs are consistent with the run setup (ideal/radiation/Helmholtz/PIG depending on metadata).

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

Constructor (main options):

```python
grid = h5grid(
    0,
    path="./",
    mode='i',
    data_path="../../data/",
    helm_table='helm_table_timmes_x2.dat',
    pig_table='401x401_pig_table_h2_offset.dat',
)
```

### Metadata and geometry

- Scalar metadata: `time`, `dt`, `step`, `nx1`, `nx2`, `nx3`, `sdims`, `geometry`.
- Geometry arrays:
  - `coords(ix, iy, iz)`
  - `r(ix, iy, iz)`
  - `vol(ix, iy, iz)`

### Primitive and composition fields

- Hydrodynamics/MHD primitives:
  - `rho`, `vel`, `P`, `T`, `asc`, `X_species`, `bfield`
- Composition and mixture quantities:
  - `ye`, `abar`, `zbar`, `mu`

### Derived flow and magnetic diagnostics

- Flow kinematics:
  - `mom`, `abs_vel`, `vr`, `vh`, `ekin`
- Magnetic diagnostics:
  - `emag`, `abs_bfield`, `br`, `bh`

### Thermodynamics and stability (EOS-based)

- Thermodynamics:
  - `eint`, `enthalpy`, `etot`, `sound`, `mach`, `mach_vec`
  - `cp`, `cv`, `s`, `nabla_ad`, `delta`, `phi`
  - `gamma1`, `gamma2`, `gamma3`
- Gradients/stability:
  - `grad_r`, `nabla`, `nabla_mu`, `ledoux_stability`, `bvf2`, `bvf`

### Gravity and nuclear-network quantities

- Gravity:
  - `grav`, `phipot`, `epot`
- Nuclear diagnostics:
  - `edot_reacs`, `dXdt_reacs`, `dXdt`, `edot_nuc`, `neuloss`

### Profiles and utility methods

- Profiles/axes:
  - `radial_profile`, `r2raxis`, `r2maxis`
- Data layout helpers:
  - `vec3d`, `vec4d`, `vec5d`
- Expression helper:
  - `evaluate_expression(expr)`

### Plotting methods in `h5grid`

- `gridshow(...)`: 2D field map for a selected slice.
- `radialshow(...)`: radial profile plot.

### 3. `h5plane`: reader for pre-extracted planes

`h5plane` reads `planes_nXXXXX.h5`, which store selected slices already written by the simulation.

Typical use:

```python
from phloutput import h5plane

pl = h5plane(0, path="./", path_to_grids="./", mode='i')

rho_plane = pl.rho(iz=0)
fig, ax = pl.planeshow(rho_plane, cb_lbl=r'$\rho$')
fig.savefig("rho_plane.png", dpi=300)
```

Notes:

- `path_to_grids` should point to the directory containing `grid_n00000.h5` metadata/EOS context.
- Plane indices are mapped through `planes_x1_index`, `planes_x2_index`, `planes_x3_index`.

Main method families mirror `h5grid` for plane data:

- field access: `prim`, `T`, `rho`, `vel`, `P`, `X_species`, `bfield`
- derived quantities: `vr`, `vh`, `br`, `bh`, `mach`, thermodynamic EOS methods (`cp`, `cv`, `gamma1`, ...)
- plotting: `planeshow(...)`

### 4. `h5spj`: reader for spherical projection outputs

`h5spj` reads `spj_nXXXXX.h5` files with values on spherical shells.

Typical use:

```python
import numpy as np
from phloutput import h5spj

spj = h5spj(0, path="./", path_to_grids="./", mode='i')

rho_shell = spj.rho(ir=0)
spj.mollweide(
    np.log10(rho_shell),
    cb_lbl=r'$\log_{10}(\rho)$',
    cmap='viridis',
    showfig=False,
    figname='rho_mollweide.png',
)
```

Main capabilities:

- shell coordinates: `coords(ir)`
- shell fields: `prim`, `rho`, `T`, `vel`, `P`, `bfield`, species/composition
- derived flow/magnetic/EOS diagnostics (same naming pattern as in `h5grid`)
- global map plotting: `mollweide(...)`

### 5. `Probe`: point-probe time series and spectra

`Probe` reads `pp<id>_<chunk>.dat` probe chunks and concatenates them in time.

Typical use:

```python
from phloutput import Probe

probe = Probe(0, 0, 0, nprobe=1, dire="./")
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

## Practical recommendations

- Start from `h5grid` unless your workflow specifically uses plane (`h5plane`) or spherical-projection (`h5spj`) files.
- For 3D plotting with `gridshow`, explicitly choose one slice (`ix`, `iy`, or `iz`) before plotting.
- For comparative studies over many snapshots, use `timeprof` first, then move to per-snapshot deep dives.
- For reproducible figures, save returned matplotlib figures with explicit `dpi` and colormap normalization.

## Minimal quick reference

```python
from phloutput import h5grid

g = h5grid(0, path="./", mode='i')

# data
rho = g.rho(iz=0)
T = g.T(iz=0)
M = g.mach(iz=0)

# plots
fig1, ax1 = g.gridshow(rho, cmap='magma', cb_lbl=r'$\rho$')
fig2, ax2 = g.radialshow(g.rho(), y_lbl=r'$\rho$')

fig1.savefig("rho_map.png", dpi=300)
fig2.savefig("rho_radial.png", dpi=300)
```
