# Phlegethon
<p align="left">
  <img src="logo.svg" width="300"/>
</p>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.19554676.svg)](https://doi.org/10.5281/zenodo.19554676)
[![License](https://img.shields.io/github/license/phlegethon-stellar-hydro/phlegethon)](https://github.com/phlegethon-stellar-hydro/phlegethon/blob/main/LICENSE)

**[PHLEGETHON](https://arxiv.org/abs/2604.12672)** is a fully compressible, Eulerian magnetohydrodynamic (MHD) code designed for multidimensional simulations in stellar astrophysics. The code uses a time-explicit, second-order, finite-volume method optimized to model a wide range of dynamical regimes, from very low-Mach-number turbulent convection in the deep interior of stars to supersonic flows in subsurface convection zones. **PHLEGETHON** runs on CPUs and uses MPI-based parallelization via domain decomposition.

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

If runs are killed immediately without a stack trace (for example `killed ./run.app` or `signal 9 (Killed: 9)` in MPI runs), see [Troubleshooting FAQ: macOS process is killed immediately](https://phlegethon-stellar-hydro.github.io/phlegethon/modules/troubleshooting.html#q-macos-process-is-killed-immediately).

### 3. Python environment 

#### Option 1: Using mamba (recommended)

- Install [mamba](https://mamba.readthedocs.io/en/latest/installation/mamba-installation.html).

- Create and activate a new environment:
```bash
mamba create -n phl_env
mamba activate phl_env
```

- Install required Python packages:

```bash
mamba install python numpy matplotlib scipy h5py ipython meson ninja
```

(Also works with conda, just replace all ``mamba`` commands with ``conda``)

#### Option 2: Using venv (standard library)

Alternatively, you can use Python's built-in `venv` module:

- Create a new virtual environment:

```bash
python3 -m venv phl_env
```

- Activate the environment:

```bash
# On macOS/Linux
source phl_env/bin/activate

# On Windows
phl_env\Scripts\activate
```

- Install required Python packages:

```bash
pip install --upgrade pip
pip install numpy matplotlib scipy h5py ipython meson ninja
```

### 5. Download Helmholtz EoS table and JINA REACLIB rates

In the root directory of **phlegethon**, run

```bash
bash data/get_data.sh
```
This bash script will download a 541x271 Helmholtz EoS table from Frank Timmes' [cococubed](https://cococubed.com/code_pages/eos.shtml) and the latest default [JINA REACLIB](https://reaclib.jinaweb.org/) rate library (version 24-06-2021).

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

If the build fails despite having installed both the MPI-Fortran compiler and HDF5 library correctly, have a look at [Troubleshooting FAQ: Build fails because MPI or HDF5 cannot be found](https://phlegethon-stellar-hydro.github.io/phlegethon/modules/troubleshooting.html#q-build-fails-because-mpi-or-hdf5-cannot-be-found).

- Visualize the output in `python`:

```python
from phloutput import *
g = h5grid(-1)
g.gridshow(g.mach())
```

## Documentation

Documentation can be consulted [here](https://phlegethon-stellar-hydro.github.io/phlegethon/).

For common setup/build/runtime issues, see the [Troubleshooting FAQ](https://phlegethon-stellar-hydro.github.io/phlegethon/modules/troubleshooting.html).

Contributor guidelines are available in [Contributing](docs/source/modules/contributing.md).

## Maintainers

| Name | GitHub | Affiliation |
| --- | --- | --- |
| Giovanni Leidi | [@GioLeidi](https://github.com/GioLeidi) | Heidelberg Institute for Theoretical Studies |
| Alexander Holas | [@AlexHls](https://github.com/AlexHls) | Heidelberg Institute for Theoretical Studies |
| Kristián Vitovský | [@KristianVitovsky](https://github.com/KristianVitovsky) | Heidelberg Institute for Theoretical Studies |

## Authors

**PHLEGETHON** was originally written by Giovanni Leidi and is continuously under active development. Current support is provided by:
- Giovanni Leidi
- Alexander Holas
- Kristian Vitovsky
- Federico Rizzuti
- Jonas Reichert
- Korinna Bayer

## Citation

If you use **PHLEGETHON** in your work, please cite it using the following BibTeX entry for its [associated method paper](https://arxiv.org/abs/2604.12672):
```bibtex
@misc{leidi2026phlegethon,
      title={Phlegethon: a fully compressible magnetohydrodynamic code for simulations in stellar astrophysics}, 
      author={G. Leidi and A. Holas and K. Vitovsky and F. Rizzuti and A. Roy and J. Reichert and K. Bayer and D. Gagnier and R. Andrassy and P. Christians and P. V. F. Edelmann and V. Varma and R. Hirschi and F. K. Röpke},
      year={2026},
      eprint={2604.12672},
      archivePrefix={arXiv},
      primaryClass={astro-ph.SR},
      url={https://arxiv.org/abs/2604.12672}, 
}
```

For reproducibility, please also cite the exact code version used, available on [Zenodo](https://zenodo.org/records/19554676). The latest version is:

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

## Support Policy

Maintainers prioritize support, bug-fix effort, and collaboration for users who contribute back to the project or properly cite Phlegethon.

See the detailed policy in [Contributing](docs/source/modules/contributing.md).

## License 

**PHLEGETHON** is released under the [AGPL-3.0 license](https://www.gnu.org/licenses/agpl-3.0.html)



