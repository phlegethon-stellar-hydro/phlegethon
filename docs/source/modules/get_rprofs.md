# get_rprofs

Utilities in this directory extract Reynolds-averaged radial profiles from PHLEGETHON snapshot files (`grid_nXXXXX.h5`).

Files:

- `extract_rprofs.py`: reads snapshot dumps and writes one radial-profile archive per dump. This module cotains the backend.
- `submit_rprofs.py`: helper for Slurm batch submission in chunks. The configuration of the extraction is set here.
- `get_rprofs.job`: Slurm job template rewritten by `submit_rprofs.py` before each submission.

## Requirements



1. PHLEGETHON Python paths available (example):

```bash
export PYTHONPATH=$PYTHONPATH:/path/to/phlegethon/python/
export PYTHONPATH=$PYTHONPATH:/path/to/phlegethon/miscellaneous/eos/
```

2. EOS data path available through `PHLEGETHONDATA` (or use default `../../data/`):

```bash
export PHLEGETHONDATA=/path/to/phlegethon/data/
```

## Input Expectations

- Snapshots must be named `grid_nXXXXX.h5`.
- `grid_n00000.h5` must exist (used to read metadata and static geometry fields).
- The snapshot path argument is to be passed with a trailing slash, for example `/path/to/snaps/`.

## Run Directly

From this directory:

```bash
python3 extract_rprofs.py <dump1> <dump2> <delta_dump> <make_coarse> <snapshots_path/> <output_dir>
```

Arguments:

- `dump1`: first dump index (inclusive).
- `dump2`: last dump index (exclusive).
- `delta_dump`: stride between processed dumps.
- `make_coarse`: `0` for no rebinning, `1` for x2 coarsening in each active dimension.
- `snapshots_path/`: path to `grid_nXXXXX.h5` files (include trailing `/`).
- `output_dir`: directory where `RPROFS_<time>.npz` files are written.

Example:

```bash
python3 extract_rprofs.py 0 200 1 0 /scratch/run01/ /scratch/run01/rprofs
```

## Slurm Workflow (`submit_rprofs.py`)

`submit_rprofs.py` splits the available snapshots into chunks and submits one Slurm job per chunk.

1. Edit the variables at the top of `submit_rprofs.py`:
   - `path_to_sim`: snapshot directory containing `grid_nXXXXX.h5` files.
   - `path_to_output`: output directory for `RPROFS_*.npz` files.
   - `pycmd`: path to `extract_rprofs.py` used in submitted jobs.
   - `ntasks`: number of chunks/jobs used to split the dump range.
   - `ncores_per_task`: core count requested per submitted job.
   - `delta`: dump stride passed to the extractor.
   - `rebin`: rebin toggle (`0` off, `1` on for x2 coarsening).
   - `partition`: Slurm partition name (`#SBATCH -p`).
2. Check `get_rprofs.job` for any site-specific directives (time limit, account, etc.).
3. Run:

```bash
python3 submit_rprofs.py
```

Notes:

- `submit_rprofs.py` rewrites `#SBATCH -p`, `#SBATCH -n`, and the `python3 ...` line in `get_rprofs.job` for each submitted chunk.

## Output

For each processed dump, the script writes:

- `RPROFS_<rounded_time>.npz`

Stored fields include:

- `time`: simulation time for the snapshot.
- `geometry`: geometry string from the grid metadata.
- `use_internal_boundaries`: boundary mode flag.
- `sdims`: number of spatial dimensions.
- `dd`: dictionary of radial mean profiles and correlations (thermodynamic, velocity, gravity, diffusion, reaction/source terms, optional MHD and network terms when present).

Computed profiles (`dd` keys, physical names + formulas):

Here, $\langle \cdot \rangle$ is the radial Reynolds average, $i$ indexes species/reactions, and $h = e_{\mathrm{int}} + P/\rho$.
All formulas below use inline `$...$` math syntax supported by GitHub Markdown.

- `r`: radial coordinate, $r$.
- `area`: shell/annulus area, $A(r)$.
- `gr_bar`: radial gravitational acceleration, $\langle g_r \rangle$.
- `epot_bar`: gravitational potential, $\langle \Phi \rangle$.
- `kappa_bar`: opacity, $\langle \kappa \rangle$.
- `edot_bar`: external/source heating-cooling rate density, $\langle \dot{e} \rangle$.
- `rho_bar`: mass density, $\langle \rho \rangle$.
- `P_bar`: pressure, $\langle P \rangle$.
- `T_bar`: temperature, $\langle T \rangle$.
- `s_bar`: specific entropy, $\langle s \rangle$.
- `abar_bar`: mean mass number (Abar), $\langle \bar{A} \rangle$.
- `Ye_bar`: electron fraction, $\langle Y_e \rangle$.
- `zbar_bar`: mean charge number (Zbar), $\langle \bar{Z} \rangle = \langle Y_e\bar{A} \rangle$.
- `rho_rho_bar`: density second moment, $\langle \rho^2 \rangle$.
- `T_T_bar`: temperature second moment, $\langle T^2 \rangle$.
- `P_P_bar`: pressure second moment, $\langle P^2 \rangle$.
- `s_s_bar`: entropy second moment, $\langle s^2 \rangle$.
- `abs_vel_bar`: speed magnitude, $\langle |\mathbf{v}| \rangle$.
- `abs_vh_bar`: tangential speed magnitude, $\langle |\mathbf{v}_h| \rangle$.
- `rho_vr_bar`: radial mass flux, $\langle \rho v_r \rangle$.
- `rho_eint_bar`: internal energy density, $\langle \rho e_{\mathrm{int}} \rangle$.
- `rho_ekin_bar`: kinetic energy density, $\langle \rho e_{\mathrm{kin}} \rangle$.
- `rho_etot_bar`: total energy density, $\langle \rho e_{\mathrm{tot}} \rangle$.
- `rho_h_bar`: enthalpy density, $\langle \rho h \rangle$.
- `rho_s_bar`: entropy density proxy, $\langle \rho s \rangle$.
- `rho_eint_vr_bar`: radial internal-energy flux, $\langle \rho e_{\mathrm{int}} v_r \rangle$.
- `rho_ekin_vr_bar`: radial kinetic-energy flux, $\langle \rho e_{\mathrm{kin}} v_r \rangle$.
- `rho_etot_vr_bar`: radial total-energy flux, $\langle \rho e_{\mathrm{tot}} v_r \rangle$.
- `rho_h_vr_bar`: radial enthalpy flux, $\langle \rho h v_r \rangle$.
- `rho_s_vr_bar`: radial entropy flux proxy, $\langle \rho s v_r \rangle$.
- `div_vel_bar`: velocity divergence, $\langle \nabla \cdot \mathbf{v} \rangle$.
- `P_div_vel_bar`: compressional work term, $\langle P\,\nabla \cdot \mathbf{v} \rangle$.
- `iT_bar`: inverse temperature, $\langle T^{-1} \rangle$.
- `vr_bar`: radial velocity, $\langle v_r \rangle$.
- `abar_vr_bar`: radial transport of Abar, $\langle \bar{A} v_r \rangle$.
- `zbar_vr_bar`: radial transport of Zbar, $\langle \bar{Z} v_r \rangle$.
- `P_vr_bar`: pressure-velocity correlation, $\langle P v_r \rangle$.
- `T_vr_bar`: temperature-velocity correlation, $\langle T v_r \rangle$.
- `rhovel_g_bar`: gravitational power density, $\langle \rho\,(\mathbf{g}\cdot\mathbf{v}) \rangle$.
- `vel_g_bar`: specific gravitational power, $\langle \mathbf{g}\cdot\mathbf{v} \rangle$.
- `dTdr_bar`: radial temperature gradient, $\langle \partial_r T \rangle$.
- `Krad_bar`: radiative conductivity, $\langle K_{\mathrm{rad}} \rangle$.
- `Krad_dTdr_bar`: conductive transport term, $\langle K_{\mathrm{rad}}\,\partial_r T \rangle$.
- `div_frad_iT_bar`: radiative heating/cooling over temperature, $\langle \frac{\nabla\cdot\mathbf{F}_{\mathrm{rad}}}{T} \rangle$.
- `edot_nuc_bar`: nuclear heating rate density, $\langle \dot{e}_{\mathrm{nuc}} \rangle$.
- `edot_reacs_bar`: per-reaction heating rate density (array), $\langle \dot{e}_{\mathrm{reac},i} \rangle$.
- `edot_neu_bar`: neutrino cooling/heating rate density, $\langle \dot{e}_{\nu} \rangle$.
- `edot_nuc_iT_bar`: nuclear heating over temperature, $\langle \frac{\dot{e}_{\mathrm{nuc}}}{T} \rangle$.
- `edot_neu_iT_bar`: neutrino term over temperature, $\langle \frac{\dot{e}_{\nu}}{T} \rangle$.
- `edot_tot_iT_bar`: total source term over temperature, $\langle \frac{\dot{e}_{\mathrm{nuc}}+\dot{e}_{\nu}}{T} \rangle$.
- `eps_nuc_bar`: specific nuclear heating rate, $\langle \epsilon_{\mathrm{nuc}} \rangle$.
- `eps_reacs_bar`: per-reaction specific heating rate (array), $\langle \epsilon_{\mathrm{reac},i} \rangle$.
- `eps_neu_bar`: specific neutrino cooling/heating rate, $\langle \epsilon_{\nu} \rangle$.
- `eps_nuc_iT_bar`: specific nuclear term over temperature, $\langle \frac{\epsilon_{\mathrm{nuc}}}{T} \rangle$.
- `eps_neu_iT_bar`: specific neutrino term over temperature, $\langle \frac{\epsilon_{\nu}}{T} \rangle$.
- `eps_tot_iT_bar`: total specific source term over temperature, $\langle \frac{\epsilon_{\mathrm{nuc}}+\epsilon_{\nu}}{T} \rangle$.
- `rho_X_bar`: species mass density (array over species), $\langle \rho X_i \rangle$.
- `rho_X_X_bar`: species density second moment (array over species), $\langle \rho X_i^2 \rangle$.
- `rho_X_X_vr_bar`: radial transport of species second moment (array over species), $\langle \rho X_i^2 v_r \rangle$.
- `rho_X_vr_bar`: radial species mass flux (array over species), $\langle \rho X_i v_r \rangle$.
- `rho_dXdt_bar`: species source term density (array over species), $\langle \rho\,\dot{X}_i \rangle$.
- `rho_X_dXdt_bar`: species production/destruction correlation (array over species), $\langle \rho X_i\dot{X}_i \rangle$.
- `rho_vr_vr_bar`: radial Reynolds stress component, $\langle \rho v_r^2 \rangle$.
- `rho_vt1_bar`: tangential momentum density (component 1), $\langle \rho v_{t1} \rangle$.
- `rho_vt1_vt1_bar`: tangential Reynolds stress (component 1), $\langle \rho v_{t1}^2 \rangle$.
- `rho_vt2_bar`: tangential momentum density (component 2, 3D), $\langle \rho v_{t2} \rangle$.
- `rho_vt2_vt2_bar`: tangential Reynolds stress (component 2, 3D), $\langle \rho v_{t2}^2 \rangle$.
- `emag_bar`: magnetic energy density, $\langle e_{\mathrm{mag}} \rangle = \langle \frac{|\mathbf{B}|^2}{2} \rangle$.
- `abs_br_bar`: radial magnetic-field strength, $\langle |B_r| \rangle$.
- `abs_bh_bar`: tangential magnetic-field strength, $\langle |\mathbf{B}_h| \rangle$.

Quick check:

```python
import numpy as np

f = np.load("RPROFS_100.npz", allow_pickle=True)
print(f["time"], f["geometry"], f["sdims"])
dd = f["dd"].item()
print(dd.keys())
```
