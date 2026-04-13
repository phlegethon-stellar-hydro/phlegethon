(build-and-run)=
# Build and Run

## Setting up a test problem

To set up a test problem, you need:
- A `Makefile` with a definition of the numerical options used.
- An application file (e.g., `app.F90`) where the initial conditions for the primitive variables `lgrid%prim(:,i,j,k)` are set at every cell center and the main time integration loop is performed.
- Optional: a job script for running simulations on HPC clusters.

## Build workflow

### 1. Choose a build configuration

Phlegethon uses `pkg-config` to auto-detect the MPI-Fortran compiler and the hdf5 library. In case you need to specify machine-dependent settings (see also `Make.local/README.md`):

- Create a new build-configuration file in `Make.local/`, specifiying the path to the MPI-Fortran compiler and the hdf5 library.
- Edit the `include` path in `Makefile.config` to link the costum configuration, e.g.,

```make
include ../../Make.local/Make.leidi
```

### 2. Build a test problem

```bash
cd tests/hotbubble-helmholtz
make clean
make
```

### 3. Run a test problem

```bash
mpirun -n 4 ./run.app
```

### 4. Read output in Python

```python
from phloutput import *
g = h5grid(-1)
g.gridshow(g.mach())
```

In a Python session (e.g., `ipython`), you can load and imshow any quantity from the ith-snapshot (here sixth) like

```python
from phloutput import *
g = h5grid(6)
g.gridshow(g.mach())
```

Check `python/phloutput.py` for a list of variables that can be accessed from the `h5grid` class. For 3D simulations, individual planes can be accessed with the `ix`, `iy`, and `iz` indices (by default, `h5grid` will load the full array).

## Docker workflow (optional)

The repository provides a configurable `Dockerfile` to build and run Phlegethon in a container.

### Build image (Ubuntu default)

```bash
docker buildx build --load -t phlegethon:ubuntu .
```

If `buildx` is not available yet, use:

```bash
docker build -t phlegethon:ubuntu .
```

### Compile a test case in the container

```bash
docker run --rm -it phlegethon:ubuntu bash -lc 'cd tests/hotbubble && make clean && make'
```

### Build and run with container defaults

The default container command executes:

```bash
cd "$TEST_CASE" && make clean && make && mpirun -n "$MPI_RANKS" ./run.app
```

Set these environment variables at runtime:

- `TEST_CASE` (default: `tests/hotbubble`)
- `MPI_RANKS` (default: `4`)

Example:

```bash
docker run --rm -it -e TEST_CASE=tests/hotbubble -e MPI_RANKS=2 phlegethon:ubuntu
```

### Use another base image

Pass `BASE_IMAGE` and a custom `INSTALL_CMD` at build time to support non-Debian base images.

```bash
docker build \
	--build-arg BASE_IMAGE=fedora:41 \
	--build-arg INSTALL_CMD='dnf install -y gcc gcc-c++ gcc-gfortran make pkgconf-pkg-config openmpi openmpi-devel hdf5-openmpi hdf5-openmpi-devel && dnf clean all' \
	-t phlegethon:fedora .
```

Troubleshooting:

- `docker build requires 1 argument` means the build context is missing. Keep the trailing `.` (or provide another path/URL).
- `legacy builder is deprecated` indicates Docker suggests BuildKit via buildx. Install/enable buildx and run `docker buildx build --load ...`.

## Compile-time configuration

Most Phlegethon configuration is done at compile time through `OPTS += ...` entries in each test `Makefile`.

`Makefile` options are passed as:

```make
OPTS += USE_DOUBLE_PRECISION
OPTS += nx1_make=64
OPTS += cfl_make=0.8_rp
```

These are forwarded as preprocessor definitions when compiling `source/source.F90`.

See {ref}`options-reference` for the full option list.