# Phlegethon Build Configuration Directory

This directory contains machine-specific build configurations for the Phlegethon test problems.

## Quick Start

### Default Setup (pkg-config)
The default `../Makefile.config` uses automatic HDF5 detection via pkg-config. No setup needed:
```bash
cd ../tests/hotbubble-2.0
make
```

### Switch to a Different Machine

Edit `../Makefile.config` and change the include line to the machine you want
(no copying needed):
```makefile
# Example: use Giovanni Leidi's system
include ../../Make.local/Make.leidi

# Example: use HITS Genoa cluster
include ../../Make.local/Make.hits_genoa
```

Then build normally:
```bash
make
```

## Available Configurations

### Make.pkgconfig (Default)
Automatically detects HDF5 using:
1. `pkg-config` (recommended)
2. Homebrew on macOS: `brew --prefix hdf5`
3. System defaults as fallback

### Hardcoded paths for Giovanni Leidi's system:
- HDF5: `/home/giovanni-leidi/HDF5/built-fortran`
- Compiler flags: Optimized for x86-64 systems

### Make.hits_genoa
Hardcoded paths for HITS Genoa cluster:
- HDF5: `/hits/sw/shared/genoa/a89/apps/HDF5/1.14.3-gompi-2023b`
- Compiler flags: Optimized for native Genoa processors

## Creating a Custom Configuration

### For Your Local Machine

1. Identify HDF5 installation path:
   ```bash
   # If using pkg-config:
   pkg-config --cflags --libs hdf5-fortran
   
   # Or find it manually:
   find /usr/local -name "hdf5*" -type d
   find /opt -name "hdf5*" -type d
   ```

2. Create a new file, e.g., `Make.myhost`:
   ```makefile
   FC = mpifort
   FFLAGS = -O3 -mtune=native -march=native -ftree-vectorize -ftree-vectorizer-verbose=0 -funroll-loops -fforce-addr -Wall -Wextra
   INCLUDE = -I/path/to/hdf5/include
   LIBS = -L/path/to/hdf5/lib
   HDF5_LIB = -lhdf5 -lhdf5_fortran -lz
   RPATH = -Wl,-rpath=/path/to/hdf5/lib

   BUILD_DIR ?= obj
   FC_ADD_DEF ?= -D

   FC_OPTS += $(foreach opt,$(OPTS),$(FC_ADD_DEF) $(opt))
   EXE = run.$(APPNAME)

   $(info ----------------------------------------)
   $(info Phlegethon Build Configuration)
   $(info Configuration: myhost)
   $(info FC: $(FC))
   $(info FFLAGS: $(FFLAGS))
   $(info INCLUDE: $(INCLUDE))
   $(info LIBS: $(LIBS))
   $(info HDF5_LIB: $(HDF5_LIB))
   $(info ----------------------------------------)
   ```

3. Use it:
   ```bash
   cp Make.myhost ../Makefile.config
   ```

### For a Cluster or HPC System

1. Load necessary modules:
   ```bash
   module load hdf5  # or appropriate module name
   ```

2. Determine HDF5 paths:
   ```bash
   echo $HDF5_HOME  # Often set by module system
   pkg-config --cflags --libs hdf5-fortran
   ```

3. Create configuration file with paths from step 2

4. Copy to `../Makefile.config` before building

## Environment Variables

Some configurations may benefit from environment variables:

```bash
# For pkg-config configurations
export PKG_CONFIG_PATH=/custom/path/lib/pkgconfig:$PKG_CONFIG_PATH

# For runtime library loading
export LD_LIBRARY_PATH=/path/to/hdf5/lib:$LD_LIBRARY_PATH

# For MPI with Homebrew
export MPI_HOME=$(brew --prefix open-mpi)
```
