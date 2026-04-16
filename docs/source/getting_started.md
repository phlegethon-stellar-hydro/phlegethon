(getting_started)=
# Getting Started

## 1. Clone the git repository

```bash
git clone https://github.com/phlegethon-stellar-hydro/phlegethon.git
cd phlegethon
```

## 2.1 System dependencies (Debian-based systems)

Run the following command to install curl, an MPI-Fortran compiler, and [hdf5](https://www.hdfgroup.org/solutions/hdf5/) with parallel I/O capabilities

```bash
sudo apt install -y curl build-essential gfortran libopenmpi-dev openmpi-bin openmpi-common libhdf5-openmpi-dev hdf5-tools
```

## 2.2 System dependencies (MacOS/ Homebrew)

On MacOS, use homebrew to install the system dependencies

```bash
brew install open-mpi gcc hdf5-mpi
```

You will also need to enable developer mode in your OS settings.

If runs are killed immediately without a stack trace (for example `killed ./run.app` or `signal 9 (Killed: 9)` in MPI runs), see [Troubleshooting FAQ: macOS process is killed immediately](modules/troubleshooting.md#q-macos-process-is-killed-immediately).

## 2.3 Containerized setup (Docker, optional)

For all container workflows (Docker installation, image build, Compose, Jupyter, output access, and interactive sessions), see {ref}`docker-workflow`.

## 3. Python environment

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

## 5. Download Helmholtz EoS table and JINA REACLIB rates

In the root directory of **phlegethon**, run

```bash
bash data/get_data.sh
```

This bash script will download a 541x271 Helmholtz EoS table from Frank Timmes' [cococubed](https://cococubed.com/code_pages/eos.shtml) and the latest default [JINA REACLIB](https://reaclib.jinaweb.org/) rate library (version 21-06-2021).

## 6. Compile the Fortran EoS modules

The Python post-processing stack requires the compiled module `eos_fort`.
If `f2py` uses the meson backend, `ninja` must be available (installed above).

```bash
cd miscellaneous/eos/
f2py -c eos.f90 -m eos_fort --opt='-O3'
```

Verify import from the active Python environment:

```bash
python -c 'import eos_fort; print(eos_fort.__file__)'
```

## 7. Set environment variables

- Add the following variables to your `.bashrc`:

```bash
export PYTHONPATH=$PYTHONPATH:<path-to-phlegethon>/python/
export PYTHONPATH=$PYTHONPATH:<path-to-phlegethon>/miscellaneous/eos/
export PHLEGETHONDATA=<path-to-phlegethon>/data/
```

- Reload the `.bashrc`:

```bash
source .bashrc
```

## 8. Choose a build configuration

Phlegethon uses `pkg-config` to auto-detect the MPI-Fortran compiler and the hdf5 library. In case you need to specify machine-dependent settings (see also `Make.local/README.md`):

- Create a new build-configuration file in `Make.local/`, specifiying the path to the MPI-Fortran compiler and the hdf5 library
- Edit the `include` path in `Makefile.config` to link the costum configuration, e.g.,

```make
include ../../Make.local/Make.leidi
```

## 9. Verify setup

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

## Reading HDF5 output in Python

In a Python session (e.g., `ipython`), you can load and imshow any quantity from the ith-snapshot (here sixth) like

```python
from phloutput import *
g = h5grid(6)
g.gridshow(g.mach())
```

Check `python/phloutput.py` for a list of variables that can be accessed from the `h5grid` class. For 3D simulations, individual planes can be accessed with the `ix`, `iy`, and `iz` indices (by default, `h5grid` will load the full array).
