# Phlegethon
<p align="left">
  <img src="logo.svg" width="300"/>
</p>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.19554676.svg)](https://doi.org/10.5281/zenodo.19554676)
[![License](https://img.shields.io/github/license/phlegethon-stellar-hydro/phlegethon)](https://github.com/phlegethon-stellar-hydro/phlegethon/blob/main/LICENSE)

**PHLEGETHON** is a fully compressible, Eulerian magnetohydrodynamic (MHD) code designed for multidimensional simulations in stellar astrophysics. The code uses a time-explicit, second-order, finite-volume method optimized to model a wide range of dynamical regimes, from very low-Mach-number turbulent convection in the deep interior of stars to supersonic flows in subsurface convection zones. **PHLEGETHON** runs on CPUs and uses MPI-based parallelization via domain decomposition.

### Key numerical methods:

- Second-order, time-explicit finite-volume scheme  
- Low-dissipation Riemann solvers and well-balanced methods
- Shock-capturing schemes for supersonic flows
- Constrained transport for divergence-free magnetic field evolution
- Time-implicit nuclear reaction networks
- Super-time-stepping for stiff thermal diffusion
- BiCGSTAB full gravity solver
- Realistic equations of state for stellar plasma (including partial ionization, electron degeneracy, and pair production)  
- Multiple grid geometries: Cartesian, polar, spherical, cubed-sphere
  
---

## Getting Started

### 1. Clone the git repository

```bash
git clone https://github.com/phlegethon-stellar-hydro/phlegethon.git
cd phlegethon
```

### 2.1 System dependencies (Debian-based systems)

Run the following command to install curl, an MPI-Fortran compiler, and [hdf5](https://www.hdfgroup.org/solutions/hdf5/) with parallel I/O capabilities

```bash
sudo apt install -y curl build-essential gfortran libopenmpi-dev openmpi-bin openmpi-common libhdf5-openmpi-dev hdf5-tools
```

### 2.2 System dependencies (MacOS/ Homebrew)

On MacOS, use homebrew to install the system dependencies

```bash
brew install open-mpi gcc hdf5-mpi
```

You will also need to enable developer mode in your OS settings.

### 3. Python environment 

- We recommend installing [mamba](https://mamba.readthedocs.io/en/latest/installation/mamba-installation.html). 

- After the installation, create and activate a new environment:
```bash
mamba create -n phl_env
mamba activate phl_env
```

- Install required Python packages:

```bash
mamba install python numpy matplotlib scipy h5py ipython meson ninja
```

### 5. Download Helmholtz EoS table and JINA REACLIB rates

In the root directory of **phlegethon**, run

```bash
bash data/get_data.sh
```
This bash script will download a 541x271 Helmholtz EoS table from Frank Timmes' [cococubed](https://cococubed.com/code_pages/eos.shtml) and the latest default [JINA REACLIB](https://reaclib.jinaweb.org/) rate library (version 21-06-2021).

### 6. Compile the Fortran EoS modules

```bash
cd miscellaneous/eos/
f2py -c eos.f90 -m eos_fort --opt='-O3'
```

### 7. Set environment variables

- Add the following variables to your `.bashrc`:

```bash
export PYTHONPATH=$PYTHONPATH:<path-to-phlegethon>/python/
export PYTHONPATH=$PYTHONPATH:<path-to-phlegethon>/miscellaneous/eos/
export PHLEGETHONDATA=<path-to-phlegethon>/data/
```

- Reload the `.bashrc`:

```bashrc
source .bashrc
```

### 8. Choose a build configuration

Phlegethon uses `pkg-config` to auto-detect the MPI-Fortran compiler and the hdf5 library. In case you need to specify machine-dependent settings (see also `Make.local/README.md`):

- Create a new build-configuration file in `Make.local/`, specifiying the path to the MPI-Fortran compiler and the hdf5 library
- Edit the `include` path in `Makefile.config` to link the costum configuration, e.g.,
```bash
include ../../Make.local/Make.leidi
```

### 9. Verify setup

- Compile and run the `hotbubble-helmholtz` test problem in `tests`:

```bash
cd tests/hotbubble-helmholtz
make clean
make
mpirun -n 4 ./run.app
```

- Visualize the output in `python`:

```python
from phloutput import *
g = h5grid(-1)
g.gridshow(g.mach())
```

## Documentation

Documentation can be consulted [here](https://phlegethon-stellar-hydro.github.io/phlegethon/).

## Authors

**PHLEGETHON** was originally written by Giovanni Leidi and is continuously under active development. Current support is provided by:
- Giovanni Leidi
- Alexander Holas
- Kristian Vitovsky
- Federico Rizzuti
- Jonas Reichert
- Korinna Bayer

## Citation

If you use **PHLEGETHON** in your work, please cite it using the following BibTeX entry for its associated method paper:
- TOFILL

For reproducibility, please also cite the exact code version used, available on Zenodo. The latest version is:

```bibtex
@software{leidi_2026_19554676,
  author       = {Leidi, Giovanni and
                  Holas, Alexander and
                  Vitovsky, Kristian and
                  Rizzuti, Federico and
                  Roy, Arkaprabha and
                  Reichert, Jonas and
                  Bayer, Korinna and
                  Gagnier, Damien and
                  Andrassy, Robert and
                  Christians, Paul and
                  Edelmann, Philipp and
                  Varma, Vishnu and
                  Hirschi, Raphael and
                  Röpke, Friedrich},
  title        = {Phlegethon},
  month        = apr,
  year         = 2026,
  publisher    = {Zenodo},
  version      = {v2026.4.1},
  doi          = {10.5281/zenodo.19554676},
  url          = {https://doi.org/10.5281/zenodo.19554676},
}
```

## License 

**PHLEGETHON** is released under the [AGPL-3.0 license](https://www.gnu.org/licenses/agpl-3.0.html)



