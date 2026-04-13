# syntax=docker/dockerfile:1

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG INSTALL_CMD=
ARG TEST_CASE=tests/hotbubble
ARG MPI_RANKS=4
ARG PYTHON_PACKAGES="numpy matplotlib scipy h5py ipython jupyterlab meson ninja"
ARG JUPYTER_PORT=8888

WORKDIR /opt/phlegethon

# Default dependency installation targets Debian/Ubuntu.
# For other base images, pass INSTALL_CMD at build time.
RUN set -eux; \
    if [[ -n "${INSTALL_CMD}" ]]; then \
        eval "${INSTALL_CMD}"; \
    elif command -v apt-get >/dev/null 2>&1; then \
        export DEBIAN_FRONTEND=noninteractive; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            ca-certificates curl build-essential gfortran make pkg-config \
            python3 python3-venv python3-pip python3-dev ninja-build \
            libopenmpi-dev openmpi-bin openmpi-common \
            libhdf5-openmpi-dev hdf5-tools; \
        rm -rf /var/lib/apt/lists/*; \
    else \
        echo "Unsupported base image: no apt-get found." >&2; \
        echo "Use --build-arg INSTALL_CMD='...' to install dependencies." >&2; \
        exit 1; \
    fi

COPY . .

# Python post-processing environment (isolated from system packages)
RUN set -eux; \
    command -v python3 >/dev/null 2>&1 || (echo "python3 is required for post-processing environment setup. If using INSTALL_CMD, ensure it installs python3/python3-venv/python3-pip." >&2; exit 1); \
    command -v ninja >/dev/null 2>&1 || (echo "ninja is required for f2py meson builds. If using INSTALL_CMD, ensure it installs ninja/ninja-build." >&2; exit 1); \
    python3 -m venv /opt/phl_env; \
    export PATH="/opt/phl_env/bin:${PATH}"; \
    /opt/phl_env/bin/pip install --no-cache-dir --upgrade pip; \
    # Keep meson/ninja guaranteed even if PYTHON_PACKAGES is overridden.
    /opt/phl_env/bin/pip install --no-cache-dir meson ninja; \
    /opt/phl_env/bin/pip install --no-cache-dir ${PYTHON_PACKAGES}; \
    command -v meson >/dev/null 2>&1 || (echo "meson executable not found in venv PATH" >&2; exit 1); \
    command -v ninja >/dev/null 2>&1 || (echo "ninja executable not found in venv PATH" >&2; exit 1); \
    cd /tmp; \
    /opt/phl_env/bin/f2py -c /opt/phlegethon/miscellaneous/eos/eos.f90 -m eos_fort --opt='-O3'; \
    cp /tmp/eos_fort*.so /opt/phl_env/lib/python*/site-packages/

ENV PHLEGETHONDATA=/opt/phlegethon/data/
ENV PYTHONPATH=/opt/phlegethon/python:/opt/phlegethon/miscellaneous/eos:${PYTHONPATH}
ENV VIRTUAL_ENV=/opt/phl_env
ENV PATH=/opt/phl_env/bin:${PATH}
ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
ENV TEST_CASE=${TEST_CASE}
ENV MPI_RANKS=${MPI_RANKS}
ENV JUPYTER_PORT=${JUPYTER_PORT}

EXPOSE 8888

# Default command: build and run one test case.
CMD ["bash", "-lc", "cd \"$TEST_CASE\" && make clean && make && mpirun -n \"$MPI_RANKS\" ./run.app"]
