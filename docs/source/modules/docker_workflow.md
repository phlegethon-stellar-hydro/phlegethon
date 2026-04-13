(docker-workflow)=
# Docker Workflow

This section collects all container-based workflows for Phlegethon.

## Install Docker

### macOS

Install Docker Desktop:

- https://docs.docker.com/desktop/setup/install/mac-install/

Or via Homebrew:

```bash
brew install --cask docker
```

After installation, start Docker Desktop and confirm:

```bash
docker --version
docker compose version
```

### Ubuntu or Debian

Use Docker Engine and Docker Compose plugin:

- https://docs.docker.com/engine/install/ubuntu/
- https://docs.docker.com/compose/install/linux/

Quick install (distribution packages):

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker "$USER"
```

Log out and back in, then verify:

```bash
docker --version
docker compose version
```

### Fedora

Use Docker Engine and Compose plugin:

- https://docs.docker.com/engine/install/fedora/

Quick install:

```bash
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

Log out and back in, then verify:

```bash
docker --version
docker compose version
```

## Build and Run (Dockerfile)

Build an Ubuntu-based image (default):

```bash
docker buildx build --load -t phlegethon:ubuntu .
```

If `buildx` is not available yet, use:

```bash
docker build -t phlegethon:ubuntu .
```

Compile a test case in the container:

```bash
docker run --rm -it -v "$PWD":/opt/phlegethon -w /opt/phlegethon phlegethon:ubuntu bash -lc 'cd tests/hotbubble && make clean && make'
```

Run with default container command:

```bash
docker run --rm -it -v "$PWD":/opt/phlegethon -w /opt/phlegethon -e TEST_CASE=tests/hotbubble -e MPI_RANKS=4 phlegethon:ubuntu
```

## Build and Run (Docker Compose)

Build image with compose:

```bash
docker compose build
```

Compile a test case:

```bash
docker compose run --rm phlegethon bash -lc 'cd tests/hotbubble && make clean && make'
```

Run with compose defaults (`TEST_CASE=tests/hotbubble`, `MPI_RANKS=4`):

```bash
docker compose run --rm phlegethon
```

Override runtime options:

```bash
TEST_CASE=tests/hotbubble-helmholtz MPI_RANKS=2 docker compose run --rm phlegethon
```

Use a different base image (example Fedora):

```bash
BASE_IMAGE=fedora:41 \
INSTALL_CMD='dnf install -y gcc gcc-c++ gcc-gfortran make pkgconf-pkg-config openmpi openmpi-devel hdf5-openmpi hdf5-openmpi-devel python3 python3-pip python3-devel ninja-build && dnf clean all' \
docker compose build --no-cache
```

## Python Post-Processing in Containers

The image includes a dedicated Python virtual environment at `/opt/phl_env` with:

- `numpy`
- `matplotlib`
- `scipy`
- `h5py`
- `ipython`
- `jupyterlab`
- `meson`
- `ninja`

The Fortran module `eos_fort` is compiled during image build from `miscellaneous/eos/eos.f90` and installed into this environment.

Validate post-processing environment:

```bash
docker compose run --rm phlegethon python -c 'import h5py, numpy, matplotlib; print("post-processing env OK")'
docker compose run --rm phlegethon python -c 'import eos_fort; print(eos_fort.__file__)'
```

Interactive Python:

```bash
docker compose run --rm phlegethon ipython
```

Customize Python packages at build time:

```bash
PYTHON_PACKAGES='numpy matplotlib scipy h5py ipython jupyterlab meson ninja pandas' docker compose build --no-cache
```

## JupyterLab

Start JupyterLab:

```bash
docker compose up phlegethon-jupyter
```

Open:

- http://localhost:8888

Jupyter runs without a token for local development in this setup.

Stop Jupyter service:

```bash
docker compose stop phlegethon-jupyter
```

Matplotlib in notebooks:

```python
%matplotlib inline
import matplotlib.pyplot as plt
```

## Access Output Files

- With `docker run`, include `-v "$PWD":/opt/phlegethon -w /opt/phlegethon` so outputs are written to host files.
- With compose, outputs are persisted via the `./:/opt/phlegethon` bind mount.

Inspect outputs from host:

```bash
ls -lh tests/hotbubble-helmholtz
tail -n 100 tests/hotbubble-helmholtz/restart_info.txt
```

## Interactive Container Access and Logs

Open an interactive shell (docker run):

```bash
docker run --rm -it -v "$PWD":/opt/phlegethon -w /opt/phlegethon --entrypoint bash phlegethon:ubuntu
```

Open an interactive shell (compose):

```bash
docker compose run --rm phlegethon bash
```

Typical interactive session:

```bash
cd tests/hotbubble-helmholtz
make clean
make
mpirun -n 4 ./run.app
tail -n 100 restart_info.txt
```

Detached run with log monitoring:

```bash
docker compose run -d --name phl-run phlegethon
docker logs -f phl-run
docker exec -it phl-run bash
docker rm -f phl-run
```

## Troubleshooting

- `docker build requires 1 argument`: you missed the build context. Keep trailing `.`.
- `legacy builder is deprecated`: install or enable `buildx`, then use `docker buildx build --load ...`.
