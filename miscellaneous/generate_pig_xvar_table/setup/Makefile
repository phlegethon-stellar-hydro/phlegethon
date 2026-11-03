SRC = ../../generate_pig_table/source
APPNAME = generate_pig_table

OPTS = Nrho=200
OPTS += NT=200
OPTS += log10_T_min=1.0_rp
OPTS += log10_T_max=8.0_rp
OPTS += log10_rho_min=-20.0_rp
OPTS += log10_rho_max=0.0_rp
OPTS += thr_ne=1.0e-20_rp
OPTS += eps_eta=1.0e-3_rp
OPTS += ddx1=1
OPTS += ddx2=1
OPTS += USE_QUAD_PRECISION
OPTS += USE_H2
OPTS += X_nint=1
OPTS += sim_index=1
OPTS += USE_OPR_EQM
OPTS += ndigits=15
 
#--------------------------------#

BUILD_DIR = obj

FC_ADD_DEF = -D

FC_OPTS += $(foreach opt,$(OPTS),$(FC_ADD_DEF) $(opt))

FC = mpifort 

FFLAGS = -std=f2008 -Wall -Wextra

EXE = run.$(APPNAME)

all: $(EXE)

$(BUILD_DIR)/source.o: $(SRC)/source.F90
	 $(FC) $(FFLAGS) -J $(BUILD_DIR) $(FC_OPTS) -o $@ -c $< 

$(BUILD_DIR)/$(APPNAME).o: $(APPNAME).F90
	$(FC) $(FFLAGS)  -J $(BUILD_DIR) $(FC_OPTS) -o $@ -c $< 

$(EXE): $(BUILD_DIR)/source.o $(BUILD_DIR)/$(APPNAME).o
	$(FC) $(FFLAGS) $(FC_OPTS) -o $@ $^ 

clean: 
	rm -f run.$(APPNAME)
	rm -rf $(BUILD_DIR)

$(shell mkdir -p $(BUILD_DIR))



