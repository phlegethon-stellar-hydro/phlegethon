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

## 2.3 Containerized setup (Docker, optional)

You can build and run Phlegethon in a container using the repository `Dockerfile`.

- Build an Ubuntu-based image (default):

```bash
docker buildx build --load -t phlegethon:ubuntu .
```

If `buildx` is not available yet, use:

```bash
docker build -t phlegethon:ubuntu .
```

- Run and compile a test problem (`make clean && make`) in the container:

```bash
docker run --rm -it -v "$PWD":/opt/phlegethon -w /opt/phlegethon phlegethon:ubuntu bash -lc 'cd tests/hotbubble && make clean && make'
```

- Build and run a test problem directly via container defaults:

```bash
docker run --rm -it -v "$PWD":/opt/phlegethon -w /opt/phlegethon -e TEST_CASE=tests/hotbubble -e MPI_RANKS=4 phlegethon:ubuntu
```

The Dockerfile is configurable for other Linux base images.
If your base image is not Debian/Ubuntu, provide your own dependency installation command via `INSTALL_CMD`.

Example (Fedora):

```bash
docker build \
	--build-arg BASE_IMAGE=fedora:41 \
	--build-arg INSTALL_CMD='dnf install -y gcc gcc-c++ gcc-gfortran make pkgconf-pkg-config openmpi openmpi-devel hdf5-openmpi hdf5-openmpi-devel && dnf clean all' \
	-t phlegethon:fedora .
```

Troubleshooting:

- `docker build requires 1 argument` means the build context is missing. Keep the trailing `.` (or provide another path/URL).
- `legacy builder is deprecated` indicates Docker suggests BuildKit via buildx. Install/enable buildx and run `docker buildx build --load ...`.

### Docker Compose workflow

Use the repository `docker-compose.yml` for repeated build/run/test cycles.

- Build image with compose:

```bash
docker compose build
```

- Compile a test case:

```bash
docker compose run --rm phlegethon bash -lc 'cd tests/hotbubble && make clean && make'
```

- Build and run with compose defaults (`TEST_CASE=tests/hotbubble`, `MPI_RANKS=4`):

```bash
docker compose run --rm phlegethon
```

- Override runtime options for one command:

```bash
TEST_CASE=tests/hotbubble-helmholtz MPI_RANKS=2 docker compose run --rm phlegethon
```

- Use a different base image (example Fedora):

```bash
BASE_IMAGE=fedora:41 \
INSTALL_CMD='dnf install -y gcc gcc-c++ gcc-gfortran make pkgconf-pkg-config openmpi openmpi-devel hdf5-openmpi hdf5-openmpi-devel && dnf clean all' \
docker compose build --no-cache
```

### Access output files from container runs

- With `docker run`, use `-v "$PWD":/opt/phlegethon -w /opt/phlegethon` so generated outputs are written to your local repository.
- With `docker compose`, outputs are already persisted to the host because `./` is mounted into `/opt/phlegethon`.
- Typical output inspection from host:

```bash
ls -lh tests/hotbubble-helmholtz
tail -n 100 tests/hotbubble-helmholtz/restart_info.txt
```

### Interactive container access

- Open an interactive shell with `docker run`:

```bash
docker run --rm -it -v "$PWD":/opt/phlegethon -w /opt/phlegethon --entrypoint bash phlegethon:ubuntu
```

- Open an interactive shell with compose:

```bash
docker compose run --rm phlegethon bash
```

- Example commands inside the container:

```bash
cd tests/hotbubble
make clean
make
mpirun -n 2 ./run.app
tail -n 100 restart_info.txt
```

- Run in background and inspect logs:

```bash
docker compose run -d --name phl-run phlegethon
docker logs -f phl-run
docker exec -it phl-run bash
docker rm -f phl-run
```

## 3. Python environment

- We recommend installing [mamba](https://mamba.readthedocs.io/en/latest/installation/mamba-installation.html).

- After the installation, create and activate a new environment:

```bash
mamba create -n phl_env
mamba activate phl_env
```

- Install required Python packages:

```bash
mamba install python numpy matplotlib scipy h5py ipython meson
```

## 5. Download Helmholtz EoS table and JINA REACLIB rates

In the root directory of **phlegethon**, run

```bash
bash data/get_data.sh
```

This bash script will download a 541x271 Helmholtz EoS table from Frank Timmes' [cococubed](https://cococubed.com/code_pages/eos.shtml) and the latest default [JINA REACLIB](https://reaclib.jinaweb.org/) rate library (version 21-06-2021).

## 6. Compile the Fortran EoS modules

```bash
cd miscellaneous/eos/
f2py -c eos.f90 -m eos_fort --opt='-O3'
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
