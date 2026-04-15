# get_spectra_plane_parallel

Scripts in this directory compute 2D kinetic and magnetic power spectra on horizontal slices of PHLEGETHON snapshots (`grid_nXXXXX.h5`), then optionally compute a time-averaged spectrum over a selected time window.

Files:

- `extract_spectra.py`: backend that reads snapshots and writes one spectrum archive per dump and per selected slice.
- `submit_spectra.py`: helper for Slurm submission in chunks. Main extraction configuration is set here.
- `get_spectra.job`: Slurm job template rewritten by `submit_spectra.py` before each submission.
- `average_spectra.py`: post-processing utility for time averaging previously generated spectra.


## Input Expectations

- Snapshots in a directory as `grid_nXXXXX.h5`.
- `grid_n00000.h5` must exist in the same snapshot directory (used to read static geometry and coordinate information).
- Snapshot names are expected as `grid_nXXXXX.h5`.
- The snapshot path passed to `extract_spectra.py` must include a trailing slash, for example `/scratch/run01/`.
- The selected slice index `iY` must be a valid x2 index for your grid.

## Run Directly (Single Process)

From this directory:

```bash
python3 extract_spectra.py <dump1> <dump2> <delta_dump> <iY> <snapshots_path/> <output_dir>
```

Arguments:

- `dump1`: first dump index (inclusive).
- `dump2`: last dump index (exclusive).
- `delta_dump`: stride between processed dumps.
- `iY`: x2 index of the horizontal slice used for 2D spectra.
- `snapshots_path/`: directory containing `grid_nXXXXX.h5` (include trailing `/`).
- `output_dir`: directory where `SPECTRA_iY_<iY>_<dump>.npz` files are written.

Example:

```bash
python3 extract_spectra.py 0 500 1 64 /scratch/run01/ /scratch/run01/spectra
```

## What `extract_spectra.py` Computes

For each selected dump and slice:

1. Reads `rho`, `vx1`, `vx2`, `vx3` on the $x$-$y$ plane at fixed `iY`.
2. Computes 2D FFTs of velocity components.
3. Builds kinetic spectral energy density:

$$
\hat{E}_k = \frac{1}{2}\langle\rho\rangle\left(|\hat{v}_{x1}|^2 + |\hat{v}_{x2}|^2 + |\hat{v}_{x3}|^2\right)
$$

Here, $\hat{v}_{x1}$, $\hat{v}_{x2}$, and $\hat{v}_{x3}$ are the 2D Fourier coefficients of the slice velocity components $v_{x1}$, $v_{x2}$, and $v_{x3}$, computed with a 2D FFT and normalized by $N_{x1}N_{x3}$.

4. Radially bins this field in horizontal wavenumber $k_h = \sqrt{k_x^2 + k_z^2}$.
5. If magnetic fields are present, computes and bins:

$$
\hat{E}_b = \frac{1}{2}\left(|\hat{B}_{x1}|^2 + |\hat{B}_{x2}|^2 + |\hat{B}_{x3}|^2\right)
$$

Here, $\hat{B}_{x1}$, $\hat{B}_{x2}$, and $\hat{B}_{x3}$ are the 2D Fourier coefficients of the slice magnetic-field components $B_{x1}$, $B_{x2}$, and $B_{x3}$, computed with a 2D FFT and normalized by $N_{x1}N_{x3}$.

## Slurm Workflow (`submit_spectra.py`)

`submit_spectra.py` splits the available snapshots into chunks and submits one Slurm job per chunk and per requested `iY` slice.

1. Edit variables at the top of `submit_spectra.py`:
   - `path_to_sim`: snapshot directory containing `grid_nXXXXX.h5`.
   - `path_to_output`: output directory for `SPECTRA_iY_*.npz` files.
   - `pycmd`: path to `extract_spectra.py` used in submitted jobs.
   - `ntasks`: number of chunks/jobs used to split the dump range.
   - `ncores_per_task`: core count requested per submitted job.
   - `delta`: dump stride passed to the extractor.
   - `iYs`: list of x2 slice indices.
   - `partition`: Slurm partition name (`#SBATCH -p`).
2. Check `get_spectra.job` for site-specific directives (time, account, etc.).
3. Run:

```bash
python3 submit_spectra.py
```

Notes:

- `submit_spectra.py` rewrites `#SBATCH -p`, `#SBATCH -n`, and the `python3 ...` line in `get_spectra.job` before each submission.
- Chunk boundaries are computed from the number of `grid_*.h5` files found in `path_to_sim`.

## Output

For each processed dump, `extract_spectra.py` writes:

- `SPECTRA_iY_<iY>_<dump>.npz`

Stored fields:

- `time`: simulation time of the dump.
- `yref`: geometric coordinate of the selected slice.
- `dd`: dictionary with:
  - `kh`: horizontal wavenumber bins.
  - `ek_hat`: binned kinetic spectrum.
  - `eb_hat`: binned magnetic spectrum (or `0.0` when no magnetic field is present).

Quick check:

```python
import numpy as np

f = np.load("SPECTRA_iY_64_100.npz", allow_pickle=True)
print(f["time"], f["yref"])
dd = f["dd"].item()
print(dd["kh"].shape, dd["ek_hat"].shape)
```

## Time-Averaged Spectra (`average_spectra.py`)

`average_spectra.py` averages spectra between two times for each selected slice.

1. Edit variables at the top of the script:
   - `path_to_spectra`: directory containing `SPECTRA_iY_<iY>_<dump>.npz` files.
   - `path_to_output`: directory for averaged files.
   - `iYs`: list of slices to average.
   - `t1`, `t2`: averaging window in simulation time units.
2. Run:

```bash
python3 average_spectra.py
```

Output per slice:

- `SPECTRA_AVG_iY_<iY>.npz`

Stored fields:

- `kh`: binned horizontal wavenumber centers.
- `ek_hat`: time-averaged kinetic spectrum.
- `eb_hat`: time-averaged magnetic spectrum.
- `yref`: geometric coordinate of the selected slice.
- `t1`, `t2`: averaging limits used.

