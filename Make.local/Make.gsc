# Phlegethon Build Configuration - GSC Cluster
# =====================================================

FC = mpifort

FFLAGS = -O3 -mtune=native -march=native -ftree-vectorize -ftree-vectorizer-verbose=0 -funroll-loops -fforce-addr -Wall -Wextra

# HDF5 paths from active Mamba environment
CONDA_PREFIX ?= $(shell echo $$CONDA_PREFIX)

INCLUDE = -I$(CONDA_PREFIX)/include
LIBS = -L$(CONDA_PREFIX)/lib

HDF5_LIB = -lhdf5_fortran -lhdf5 -lz
RPATH = -Wl,-rpath,$(CONDA_PREFIX)/lib

# Common settings
BUILD_DIR ?= obj
FC_ADD_DEF ?= -D

# Construct FC_OPTS from OPTS and define EXE
FC_OPTS += $(foreach opt,$(OPTS),$(FC_ADD_DEF) $(opt))
EXE = run.$(APPNAME)

# Display configuration being used
$(info ----------------------------------------)
$(info Phlegethon Build Configuration)
$(info Configuration: Mamba)
$(info FC: $(FC))
$(info FFLAGS: $(FFLAGS))
$(info INCLUDE: $(INCLUDE))
$(info LIBS: $(LIBS))
$(info HDF5_LIB: $(HDF5_LIB))
$(info RPATH: $(RPATH))
$(info ----------------------------------------)

