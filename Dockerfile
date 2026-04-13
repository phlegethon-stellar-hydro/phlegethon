# syntax=docker/dockerfile:1

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG INSTALL_CMD=
ARG TEST_CASE=tests/hotbubble
ARG MPI_RANKS=4

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
            libopenmpi-dev openmpi-bin openmpi-common \
            libhdf5-openmpi-dev hdf5-tools; \
        rm -rf /var/lib/apt/lists/*; \
    else \
        echo "Unsupported base image: no apt-get found." >&2; \
        echo "Use --build-arg INSTALL_CMD='...' to install dependencies." >&2; \
        exit 1; \
    fi

COPY . .

ENV PHLEGETHONDATA=/opt/phlegethon/data
ENV PYTHONPATH=/opt/phlegethon/python:/opt/phlegethon/miscellaneous/eos:${PYTHONPATH}
ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
ENV TEST_CASE=${TEST_CASE}
ENV MPI_RANKS=${MPI_RANKS}

# Default command: build and run one test case.
CMD ["bash", "-lc", "cd \"$TEST_CASE\" && make clean && make && mpirun -n \"$MPI_RANKS\" ./run.app"]
