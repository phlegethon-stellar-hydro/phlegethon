# Phlegethon Documentation

```{image} _static/logo.svg
:alt: Phlegethon logo
:width: 320px
```

**PHLEGETHON** is a fully compressible, Eulerian magnetohydrodynamic (MHD) code designed for multidimensional simulations in stellar astrophysics. The code uses a time-explicit, second-order, finite-volume method optimized to model a wide range of dynamical regimes, from very low-Mach-number turbulent convection in the deep interior of stars to supersonic flows in subsurface convection zones. **PHLEGETHON** runs on CPUs and uses MPI-based parallelization via domain decomposition.

## Contents

```{toctree}
:maxdepth: 2

getting_started
modules/docker_workflow.md
modules/build_and_run.md
modules/options_reference.md
modules/generate_pig_table.md
modules/overview.md
../../miscellaneous/create_input_library/create_input.md
../../miscellaneous/get_rprofs/get_rprofs.md
../../miscellaneous/get_spectra_plane_parallel/get_spectra_plane_parallel.md
../../miscellaneous/create_network/create_network.md
```

