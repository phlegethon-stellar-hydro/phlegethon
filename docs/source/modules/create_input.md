(create-input)=
# create_input_library Documentation

The create_input_library serves as a tool for preparing initial conditions for Phlegethon simulations. In Phlegethon a 1D profile of the stars structure is mapped onto a multidimentional grid. Commonly the 1D hydrostatic profiles are taken from the stellar evolution code MESA, yet there is mismatch between the EOS used in MESA and in Phlegethnon. Hence, the set of scripts in this library is used for loading the MESA data, providing quick relevant diagnostics, reintegrating the hydrostatic equalibrium with an EOS consistent with Phlegethon and creating an input file in the correct format for Phlegethon.

This document describes the intended workflow and key controls for the create_input_library environment:

- Notebook template: `create_input.ipynb`
- Reintegration backend: `hse_reintegration.py`
- MESA reader and composition tools: `mesa_minireader.py`

## 1. Intended Workflow

The create_input_library only uses standard python libraries and phleos (see phleos section). That is, if you have the phleos set-up correctly the rest should work "out of the the box".


For each project:

1. Copy create_input.ipynb to a new working notebook for that project.
2. Keep notebook pointers aimed at this library (or custom location):
	 - `hse_reintegration.py`
	 - `mesa_minireader.py`
3. Load a MESA profile and experiment with preparation controls (smoothing, composition handling, anchor placement, optional abundance/enuc tweaks).
4. Run reintegration and inspect diagnostics/plots.
5. When satisfied, enable `output_file` and write:
	 - .in file: initial conditions consumed by Phlegethon.
	 - .npz file: provenance + diagnostics + source/final profiles used to generate the .in file.



## 2. Notebook Structure

The template notebook is organized as:

1. Imports and library loading
	- No plots.
2. Physical constants
	- No plots.
3. Toggles and input values (ALL USER CONTROLES ARE HERE!)
	- No plots (configuration only).
4. Setup and profile loading
	- No plots; this section prepares data for later diagnostics.
5. MESA profile extraction and derived diagnostics
	- Early diagnostics of the MESA model:
		- convective velocity + Mach number panels (linear/log views),
		- radiative/total/convective flux comparison panels,
		- flux definitions used in the comparison:

$$
F_{\rm rad}(r)=\frac{4ac\,T(r)^4\,\nabla(r)}{3\,\kappa(r)\,\rho(r)\,H_P(r)},
\qquad
H_P(r)= -\frac{P(r)}{\rho(r)g(r)},
$$

$$
F_{\rm tot}(r)=\frac{L(r)}{4\pi r^2},
\qquad
F_{\rm conv}(r)=F_{\rm tot}(r)-F_{\rm rad}(r).
$$

6. Abundance transition
	- Optional composition-transition comparison ($\bar{A}/\bar{Z}/Y_e$) and species presence/missing summary prints.
7. Optional $\epsilon_{\rm nuc}(r)$ tweaking
	- Optional original-vs-modified $\epsilon_{\rm nuc}(r)$ comparison plot.
8. Reintegration input preparation
	- Prepared (initilization of the reintegration)-vs-original profile comparison plots (e.g., $P$, $T$, $g$, composition, and $\nabla-\nabla_{\rm ad}$ when applicable).
9. Reintegration
	- No dedicated new plot in this section; produces profiles consumed by summary/visual-check stages.
10. Run summary
	- No plots (text diagnostics and residual statistics).
11. Output writing
	- No plots (file export stage).
12. Visual diagnostics
	- Main post-run visual-check figures (split linear/log variants), with panel set controlled by primary_keys and mode-dependent availability.


## 3. Minimal Example (profile10 test case)

If you want a fast sanity check, use the profile10 setup that is already configured in the template notebook. This MESA model is of a 15 $M_{\odot}$ starjust before depletion of hydrogen in the core. The set-up was taken identical to the standart tutorial for MESA  (https://docs.mesastar.org/en/25.12.1/using_mesa/running.html).

Template defaults in `create_input.ipynb` already include:

- `mesa_path = '../mesa_profile_for_tests/profile10.data'`
- `run_reintegration = True`
- `output_file = True`
- `name_of_in_file = 'TESTCASE.in'`

It also enebles `enable_abundance_transition` in order to recompute $\bar{A}$ with a reduced number of species.

Quick-start:

1. Open `miscellaneous/create_input_library/create_input.ipynb`.
2. Keep default paths/toggles for the first run.
3. Run all notebook cells from top to bottom.
4. Check diagnostic plots and generated files in this directory:
	- `TESTCASE.in`
	- `TESTCASE.npz`

This gives a minimal end-to-end example: load MESA profile10, prepare/reintegrate with the selected EOS mode, write Phlegethon-ready input.


## 4. Toggle and Switch Reference (Section: Toggles and Input Values)

### Runtime and plotting mode

These controls are meant to make notebook plotting behavior reproducible across different execution environments.


- `configure_plot_backend` (bool)
	- True: tries to configure Matplotlib backend in IPython/Jupyter.
	- False: keeps current backend unchanged.
	- Use True in most interactive notebook sessions to reduce backend-related surprises.
	- Use False if your environment or project startup already configures Matplotlib (for example via site/user startup hooks, lab config, or a larger workflow that enforces a backend).
- `plot_backend_mode` (str)
	- auto: tries ipympl -> notebook -> inline; recommended default for general use because it prefers richer interactivity first, then falls back safely.
	- interactive: same fallback chain as auto in current implementation; kept as an explicit intent label for "prefer interactive behavior".
	- inline: forces inline backend; best for static outputs, CI-like runs, and export-focused sessions where widget backends are unavailable or undesired.

### EOS and source data

- `eos_mode` (list[str] or str passed to PHLEOS wrappers)
	- Typical component sets include combinations of `ideal`, `ions`, `radiation`, `elepos`, `coulomb`, and `pig` (depending on your EOS/table setup).
- `mesa_path` (str)
	- Path to source MESA profile file.
- `helm_table_path` (str)
	- Path to Helmholtz EOS table.
- `mesa_reader_pointer` (str)
	- Path to local mesa_minireader.py.

### Requested MESA fields

- `profile_names` (list[str])
	- Profiles requested from MESA reader.
	- Missing fields are governed by `missing_profile_policy`.
	- Naming summary: use exact (case-sensitive) names; resolution tries `profile_name_aliases`, then built-in aliases, then the raw name.
	- Transform/fallback summary: canonical requests may apply unit/log/sign transforms, and some fields can be derived if missing (currently $\bar{Z}$ from $\bar{A}Y_e$, grav from mass+rmid).
- `profile_name_aliases` (dict)
	- Optional per-field source-name overrides.
	- Useful for custom MESA column names.
	- e.g. `'gradT_sub_grada': ['gradT_sub_grada', 'superad'],`
- `missing_profile_policy` (str)
	- Missing fields means requested names that cannot be found in the loaded MESA columns after alias resolution.
	- ignore: skip silently.
	- warn: emit warning and continue.
	- error: raise and stop.

### MESA pre-reintegration modifications

#### Smoothing
- `smoothing_width` (int)
	- $\>$ 0: smooth selected profiles before integration.
	- $<=$ 0: no smoothing.
	- Number of MESA points in the smoothing window (dimensionless), not a physical length unit.
- `smoothing_kernel` (str)
	- box, gaussian, bump.


- Effective smoothing width in preparation is scaled as $n_{\rm eff} = \texttt{smoothing width} \times \texttt{resize factor}$
  
  
- Profiles smoothed during preparation (when `smoothing_width > 0`):
	- Always: pressure ($P$), temperature ($T$), gravity ($g$), $\bar{A}$, $\bar{Z}$.
	- Conditionally: density ($\rho$) only if $\texttt{use eos p0}=\mathrm{True}$.
	- Conditionally: $\nabla-\nabla_{\rm ad}$ only in `integration_mode = nabladif_given`.
- If abundance-transition species columns are emitted (`X_species`), each species profile is outputed with the same smoothong applied as is to the other profiles.

For a sampled profile $f_i = f(r_i)$, let $n =$ `smoothing_width` and $p = \lfloor n/2 \rfloor$.
The implementation pads by $p$ points on each side and applies a length-$n$ normalized convolution:

$$
\widetilde{f}_i = \sum_{k=0}^{n-1} \hat K_k\, f_{i + k - p},
\qquad
\hat K_k = \frac{K_k}{\sum_{m=0}^{n-1} K_m}.
$$

Kernel definitions used by `smoothing_kernel` (before normalization):

- `box`: Uniform moving average

$$
K_k = 1, \qquad k = 0,\dots,n-1.
$$

- `gaussian`: Truncated Gaussian

$$
K_k = \exp\left(-\tfrac12 x_k^2\right),
\qquad
x_k \in \text{linspace}(-1,1,n).
$$

- `bump`: Compact-support smooth bump

$$
K_k = \exp\left(-\dfrac{1}{1-u_k^2}\right),
\qquad
u_k \in \text{linspace}(-1,1,n+2).
$$

#### Extrapolation to lower radii

- `enable_mesa_inner_extrapolation` (bool)
	- True: if `rmin` is below the minimum radius available in the loaded MESA profile, prepend extrapolated MESA points down to `rmin` before any preparation/reintegration step.
	- False: the notebook raises an explicit error when `rmin < min(r_MESA)`.
	- Extrapolation is applied consistently to all loaded profile fields that are inputed into the reintegration and loaded abundance species, so abundance-transition and reintegration operate on one consistent extended radial domain.

- `mesa_inner_extrapolation_mode` (str)
	- `constant`: each extrapolated point is equal to the innermost MESA value of that field.
	- `polynomial`: fit a polynomial to innermost MESA points and evaluate it inward.
- `mesa_inner_extrapolation_points` (int)
	- Number of prepended radial points between `rmin` and the original MESA innermost radius.
- `mesa_inner_extrapolation_poly_degree` (int)
	- Polynomial degree used in `polynomial` mode.
- `mesa_inner_extrapolation_fit_window` (int)
	- Number of innermost original MESA points used for the polynomial fit.


#### $\nabla_{\rm diff}$ clamping

- `nabladif_zero_tol` (float or None)
	- Applies only in `nabladif_given` mode.
	- Values with $|\nabla_{\rm diff}| <$ `nabladif_zero_tol` are set exactly to 0.
	- `None` disables the clamp.

### Abundance transition

Intent: build composition variables from a selected species subset (or even initialize species not included in the MESA model) instead of relying on the full-network composition.

Use this when you want a controlled reduced-species composition basis for reintegration/output.

- `enable_abundance_transition` (bool)
	- True: use selected species to reconstruct $\bar{A}/\bar{Z}/Y_e$.
	- False: skip this reconstruction step completely.
- `abundance_target_species` (list[str])
	- Species list used to build composition variables.
	- Must be non-empty.
	- List only species you want to carry into the reduced basis.
	- Practical default style: isotope tokens like `h1`, `he4`, `c12`, `o16`, `ne20`.
	- Names should match your MESA abundance columns (or be mapped via aliases if needed).
	- You can list species not present in the MESA profile; those species are initialized with `abundance_missing_fill`.
- `abundance_closure_species` (str)
	- Species adjusted so $\sum X_{\rm i}=1$ after selection/filling.
	- Must be included in `abundance_target_species`.
	- A good choice might be a species that is heavy and abundently present.
- `abundance_missing_fill` (float)
	- Value used if a requested species is absent in the loaded MESA profile.
	- Typical choice is 0.0.

Derived composition in code (per radius point $r$):

1. Build selected mass fractions $X_i(r)$ for all $i\in\texttt{abundance target species}$.
   Missing species are initialized as

$$
X_i(r)=\texttt{abundance missing fill}.
$$

2. Compute the pre-closure sum and enforce closure on `abundance_closure_species` (call it $c$):

$$
X_{\Sigma}^{\rm before}(r)=\sum_i X_i(r),
\qquad
\Delta X_c(r)=1-X_{\Sigma}^{\rm before}(r),
$$

$$
X_c^{\rm new}(r)=X_c(r)+\Delta X_c(r),
\qquad
\sum_i X_i^{\rm new}(r)=1.
$$

3. From species $(A_i,Z_i)$, derive

$$
\frac{1}{\bar{A}(r)}=\sum_i \frac{X_i^{\rm new}(r)}{A_i},
\qquad
Y_e(r)=\sum_i X_i^{\rm new}(r)\frac{Z_i}{A_i},
$$

$$
\bar{A}(r)=\left[\sum_i \frac{X_i^{\rm new}(r)}{A_i}\right]^{-1},
\qquad
\bar{Z}(r)=\bar{A}(r)\,Y_e(r).
$$

### Optional $\epsilon_{\rm nuc}(r)$ tweaking

Intent: apply a controlled shift and renormalization to the MESA heating profile before reintegration.

- `enable_enuc_tweaking` (bool)
	- Enables pre-reintegration heating-profile transformation.
- `enuc_shift_dr` (float, cm)
	- Radius shift for $\epsilon_{\rm nuc}$ MESA profile sampling.
- `enuc_renorm_factor` (float)
	- Multiplicative rescaling factor for $\epsilon_{\rm nuc}$ MESA profile.
- `enuc_plot_compare` (bool)
	- Enables diagnostic comparison plot of original MESA profile vs modified profile.

Applied profile modification (with interpolation on the radius grid):

$$
\epsilon_{\rm nuc}^{\rm mod}(r) = f_{\rm renorm} \epsilon_{\rm nuc}^{\rm orig}(r-\Delta r),
\qquad
\Delta r = \texttt{enuc shift dr},
\quad
f_{\rm renorm}=\texttt{enuc renorm factor}.
$$

The notebook also reports a luminosity comparison before/after tweaking over $[r_{\min}, r_{\max}]$:

$$
L_{\rm enuc}=4\pi\int_{r_{\min}}^{r_{\max}} r^2 \dot e_{\rm nuc}(r)\,dr,
$$

where $\dot e_{\rm nuc}(r)$ is the volumetric heating profile used for output/diagnostics.

### Reintegration grid and domain

- `Nr` (int)
	- Number of reintegration points = number of points in the output.
- `rmin`, `rmax` (float, cm)
	- Reintegration radial bounds.
- `RESIZE_FACTOR` (int)
	- Multiplies the base reintegration resolution to create a temporary preparation grid:

$$
N_{\rm prep} = N_r \times \texttt{RESIZE FACTOR}.
$$
- This finer intermediate grid is used for profile preprocessing/interpolation before the final integration/output sampling.


### Integration selection

- `integration_mode` (str)
	- `nabladif_given`: integrate enforcing prescribed $\nabla-\nabla_{\rm ad}$.
	- `t_given`: integrate enforcing prescribed $T(r)$.
	- see integrated equations in lower sections.
	- RK4 is always used.
- `run_reintegration` (bool)
	- True: execute integrator.
	- False: skip integrator, only run pre-integration steps and visulize only MESA profiles.
- `use_eos_p0` (bool)
	- True: compute initial pressure $P_0$ from EOS using prepared profiles at the snapped anchor radius $r_{\rm anchor}$:
		- non-uniform composition: local $\rho(r_{\rm anchor}), T(r_{\rm anchor}), \bar A(r_{\rm anchor}), \bar Z(r_{\rm anchor})$,
		- uniform composition: local $\rho(r_{\rm anchor}), T(r_{\rm anchor})$ with scalar $(\bar A,\bar Z)$ from the selected uniform strategy.
	- False: use prepared/interpolated pressure at $r_{\rm anchor}$.
- `use_non_uniform_composition` (bool)
	- True: use $\bar{A}(r)$ and $\bar{Z}(r)$ interpolants.
	- False: collapse composition to global scalar values according to `uniform_composition_strategy`.
- `uniform_composition_strategy` (str, used only when non-uniform is off)
	- `mean` or `median` (used to build scalar composition proxies for $\bar{A}$ and $\bar{Z}$).

### Anchor placement controls

- `anchor_radius_mode` (str)
	- `fraction`: derive $r_{\rm start}$ from  $r_{\rm start}=r_{\min}+f(r_{\max}-r_{\min}), \qquad f=\texttt{r start frac}.$
	- `absolute`: use $r_{\rm start}=\texttt{r start abs}$ directly.
	- `none`: no user anchor request; defaults to $r_{\min}$ behavior.
- `r_start_frac` (float in [0,1] recommended)
	- Fraction used when `anchor_radius_mode`=`fraction`.
- `r_start_abs` (float or None)
	- Absolute anchor radius when `anchor_radius_mode`=`absolute`.

- Anchor mapping behavior
	- Requested anchor radius $r_{\rm req}$ is always snapped to the nearest grid point $r_{\rm anchor}$.
	- If $r_{\rm req}$ is outside the grid domain, this naturally selects the nearest boundary grid point.
- `eos_output_dtype` (str or None)
	- Optional dtype cast for EOS diagnostic arrays returned by `compute_eos_profiles(...)` (used in visual diagnostics).
	- `None`: keep default (usually `float64`).
	- Common choices: `"float64"` (best precision), `"float32"` (less memory), `"float16"` (smallest, least precise).

### Output controls

- `output_file` (bool)
	- Enables writing .in and .npz products.
	- Useful to keep `False` during tuning (faster iterations, no file clutter) and switch to `True` only for finalized runs you want to keep.
- `name_of_in_file` (str)
	- Output .in filename.

- `enuc_at_output` (bool)
	- Includes enuc_erg_cm3_s output column from prepared enuc profile.
- `output_column_names_requested` (list[str])
	- Ordered columns to write into `.in` table (validated against available columns).
	- Name matching is exact and case-sensitive (`build_output_table`):
		- unknown names raise an error,
		- duplicate names raise an error,
		- all entries must be strings.
	- Order is preserved exactly as provided and used as the final `.in` column order.
	- Common valid names in current notebook workflow include:
		- `r_cm`, `g_cms2`, `phi_ergg`, `P_cgs`, `rho_cgs`, `T_K`, `kappa_cgs`
		- composition columns depend on composition mode:
			- non-uniform composition path: `Ye`, `inv_Abar`
			- uniform composition path: `Abar`, `Zbar`
		- optional heating column (when `enuc_at_output=True`): `enuc_erg_cm3_s`
	- Abundance profile columns:
		- if abundance-transition species are available at output, species columns are auto-registered as `X_<species>` (for example `X_h1`, `X_he4`, `X_c12`, `X_o16`),
		- auto-registered means these names are added automatically to the internal valid-column dictionary for the current run; you do not have to add them manually in code,
		- these `X_<species>` names can be included in `output_column_names_requested` like any other output column,
		- if you include abundance columns in a custom order, that exact order is used in `.in` output (the request order always wins),
		- if you do not include any `X_<species>` names in `output_column_names_requested`, no abundance columns are written to `.in`,
		- species columns are interpolated onto the final output radius grid before writing.
	- If `output_column_names_requested` is missing or empty, writing fails with a validation error (this list is required).
	- Example:
		- Requested order `['r_cm', 'T_K', 'X_o16', 'X_h1']` writes `.in` columns in exactly that order.
		- If `X_o16` is not available in the current run, validation fails with an unknown-column error.
	

### Plot and figure controls

- `plot_title_fontsize` (int)
	- Global fontsize used for plot titles.
- `plot_legend_fontsize` (int)
	- Global fontsize used for legends.
- `plot_label_fontsize` (int)
	- Global fontsize used for axis labels ($x$/$y$ labels).
- `plot_axis_values_fontsize` (int)
	- Global fontsize used for axis tick values.
- `plot_xaxis_unit` (str)
	- Sets the radius unit used on plot x-axes.
	- `rsol`: plot radius as $r/R_{\odot}$ 
	- `cm`: plot radius directly in cm.

- `rphl_min`, `rphl_max` (float, cm)
	- Suggested Phlegethon simulation bounds; shown as blue guide lines in plots.
- `plot_every` (int)
	- MESA Marker decimation for visual overlays.
- `entropy_alignment_mode` (str)
	- none: compare entropy directly.
	- anchor: shift MESA entropy to match RK4 at first RK4 point.
- `primary_keys` (list[str])
	- Variables selected for Figure 1 in split visual-check output.
- `figure1_scale_mode` (str)
	- Controls how Figure 1 is rendered for variables in `primary_keys`.
	- `split`: show linear and log/symlog variants side by side.
	- `linear`: show only linear variants.
	- `log`: show only log/symlog variants.
- `figure2_show_legends` (bool)
	- Controls whether legends are shown in the secondary visual-check figure (Figure 2).

## 5. Reintegration Methods and Equations

### 5.1 Hydrostatic balance.

The integration is based on

$$
\frac{dP}{dr} = \rho g
$$

with EOS closures.

### 5.2 Mode: nabladif_given

Unknowns advanced by RK4 are pressure and temperature.

Temperature equation implemented in the code uses

$$
\frac{dT}{dr} = -\frac{T}{H_P}\left(\nabla_{ad} + \nabla_{diff}\right), \qquad H_P = -\frac{P}{dP/dr}
$$

where $\nabla_{diff}$ corresponds to imported MESA $\nabla-\nabla_{ad}$.

Supported in both:

- Uniform composition (single $\bar{A}$, $\bar{Z}$)
- Non-uniform composition ($\bar{A}(r)$ , $\bar{Z}(r)$)

### 5.3 Mode: t_given

Temperature profile $T(r)$ is prescribed from prepared/interpolated MESA profile.
The integrator advances only pressure with RK4:

$$
\frac{dP}{dr} = \rho(P, T(r), \bar{A}(r), \bar{Z}(r)) g(r)
$$

Supported in both:

- Uniform composition (single $\bar{A}$, $\bar{Z}$)
- Non-uniform composition (profiles $\bar{A}(r)$, $\bar{Z}$(r))

### 5.4 Anchor and bidirectional marching

If an anchor radius is used, the solver starts at anchor index and marches:

- outward to $r_{\rm max}$
- inward to $r_{\rm min}$

so the entire domain is filled from a physically selected starting point.

## 6. Output Files

### 6.1 .in file

This is the file that can be then directly use as initial conditions for Phlegethon simulations.

Written as:

1. First line: Nr
2. Following lines: numeric table in requested column order.

Column order is controlled by `output_column_names_requested` and validated by `build_output_table`.

Typical available columns include:

- Always: r_cm, g_cms2, phi_ergg, P_cgs, rho_cgs, T_K, kappa_cgs
- With non-uniform composition path: $Y_e$, $1/\bar{A}$
- If `enuc_at_output=True`: enuc_erg_cm3_s
- If abundance transition exports species: X_<species_name> for each selected species

### 6.2 .npz file

The `.npz` companion stores all data needed to reproduce and audit the run later.

Top-level keys written to the file are:

- `metadata_json`
- `run_summary_json`
- `integration_diagnostics_json`
- `anchor_diagnostics_json`
- `output_columns`
- `output_table`
- `r_hse_rk4`
- `p_hse_rk4`
- `T_hse_rk4`
- `rho_hse_rk4`
- `g_hse_rk4`
- `phi_rk4`
- `kappa_hse_rk4`
- `abar_hse_rk4`
- `zbar_hse_rk4`
- `ye_hse_rk4`
- `inv_abar_hse_rk4`
- `enuc_hse_rk4`
- `hse_residual`
- `r_mesa`
- `p_mesa`
- `T_mesa`
- `rho_mesa`
- `g_mesa`
- `abar_mesa`
- `zbar_mesa`
- `ye_mesa`
- `kappa_mesa`
- `nabladif_mesa`
- `r_prepared`
- `p_prepared`
- `T_prepared`
- `rho_prepared`
- `g_prepared`
- `abar_prepared`
- `zbar_prepared`
- `nabladif_prepared`
- `X_<species_name>` for each abundance-transition species exported (optional)

Notes on key contents:

- `metadata_json` includes path/provenance/config snapshot: notebook path, MESA path, HELM table path, library pointers, output paths, UTC timestamp, and toggle settings (`integration_mode`, `run_reintegration`, `use_eos_p0`, `use_non_uniform_composition`, `uniform_composition_strategy`, `enuc_at_output`, `output_column_names_requested`, `eos_mode`, `missing_profile_policy`, `nabladif_zero_tol`).
- `metadata_json` also includes `uniform_abar`, `uniform_zbar`, `uniform_ye` when `use_non_uniform_composition=False`.
- `run_summary_json` stores high-level run diagnostics/summary.
- `integration_diagnostics_json` stores integrator diagnostics (`integration_info`).
- `anchor_diagnostics_json` stores anchor-selection diagnostics (`anchor_info`).
- `output_columns` and `output_table` are exactly what is written to the `.in` file.
- `*_hse_rk4` arrays are the final reintegrated/output-grid profiles.
- `*_mesa` arrays are original source profiles from MESA.
- `*_prepared` arrays are intermediary prepared profiles on the prepared grid.

## 7. What if the template notebook is not what you are looking for? 

If `create_input.ipynb` does not match your workflow, you can import the Python libraries directly and build a custom script or pipeline around only the steps you need.

### 7.1 Suggested importable tools from hse_reintegration.py

- `configure_plot_backend`
	- Optional backend setup helper for notebook-style plotting environments.
- `derive_runtime_settings`
	- Converts user toggles into validated runtime settings (anchor radius, abundance mode, composition mode).
- `tweak_enuc_profile`
	- Applies radius shift + renormalization to the heating profile.
- `build_output_table`
	- Validates requested output columns and assembles the final table in explicit order.
- `build_run_summary`
	- Produces standardized post-run diagnostics and metadata summary.
- `HSEIntegrator`
	- Core preparation and reintegration engine (EOS calls, RK4 integration, potential handling).
- `HSEPlotter`
	- Plotting utilities used by diagnostics, reusable in custom scripts.
- `compute_eos_profiles`, `make_eos_profile_ufunc`
	- Helpers for bulk EOS-derived thermodynamic profile extraction.
	- Supported named fields currently include: `P`, `e`, `dpdrho`, `dpdt`, `dEdrho`, `dEdT`, `cv`, `chiT`, `chirho`, `gamma_1`, `gamma_2`, `gamma_3`, `cp`, `nabla_ad`, `s`, `dsdrho`, `dsdt`, `delta`, `eta`, `nep`, `phi`, `sound`, `dPdA`.

### 7.2 Suggested importable tools from mesa_minireader.py

- `load_mesa_profile`
	- Loads and normalizes MESA profile data with alias resolution and canonical transforms.
- `prepare_abundance_transition`
	- Builds selected-species composition basis with closure enforcement and derived $\bar{A}/\bar{Z}/Y_e$.
- `MesaProfileData`
	- Structured container with metadata, raw data, resolved fields, transformed profiles, and abundance views.

