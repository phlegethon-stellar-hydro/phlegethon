import numpy as np
import matplotlib.pyplot as plt
import json
from pathlib import Path
from scipy.interpolate import interp1d
from scipy.integrate import cumulative_trapezoid
import phleos as phleos

# -----------------------------------------------------------------------------
# Module Organization
# -----------------------------------------------------------------------------
# 1) Configuration and table helpers
# 2) HSE integration core (`HSEIntegrator`)
# 3) Plotting/reporting helpers (`HSEPlotter`)
# 4) Module-level convenience wrappers
# 5) EOS profile accessor helpers
#
# Includes:
# - backend setup helpers for notebook plotting,
# - data table assembly/validation,
# - integration and EOS calculation classes,
# - plotting and visual diagnostics,
# - top-level wrappers for notebook-friendly calls.
#
# This file intentionally exposes both class APIs and thin module wrappers to
# support notebook-style workflows and script imports with minimal friction.

# -----------------------------------------------------------------------------
# Physical Constants
# -----------------------------------------------------------------------------
# Includes:
# - solar radius and common thermodynamic/radiative constants used by notebooks.
R_SOL = 6.957e10
C_LIGHT = 2.99792458e10
A_RAD = 7.5657e-15
R_GAS = 83144621.0


# -----------------------------------------------------------------------------
# Configuration / Output Assembly Helpers
# -----------------------------------------------------------------------------
# Includes:
# - `configure_plot_backend`: selects/activates Matplotlib backend in IPython,
# - `build_output_table`: validates requested output columns and stacks arrays.
def configure_plot_backend(mode="auto", enabled=True, ip=None, verbose=True):
    """Configure a Matplotlib backend in IPython/Jupyter with graceful fallback.

    Parameters
    ----------
    mode : {'auto', 'interactive', 'inline'}
        Backend selection strategy.
    enabled : bool
        If False, no backend magic is executed.
    ip : IPython shell, optional
        Existing shell instance; auto-detected when omitted.
    verbose : bool
        Print selected mode/backend details.

    Returns
    -------
    dict
        Runtime details including selected backend and whether magics ran.
    """
    import matplotlib as mpl

    if mode not in ("auto", "interactive", "inline"):
        raise ValueError(f"Unknown backend mode: {mode}")

    if not enabled:
        info = {
            "enabled": False,
            "mode": mode,
            "magic_used": None,
            "ipython_available": ip is not None,
            "backend": mpl.get_backend(),
        }
        if verbose:
            print("Plot backend configuration is disabled")
            print("Matplotlib backend:", info["backend"])
        return info

    if ip is None:
        try:
            from IPython import get_ipython
            ip = get_ipython()
        except Exception:
            ip = None

    def _run_with_fallback(candidates):
        for candidate in candidates:
            try:
                ip.run_line_magic("matplotlib", candidate)
                return candidate
            except Exception:
                continue
        return None

    magic_used = None

    if ip is not None:
        if mode == "inline":
            ip.run_line_magic("matplotlib", "inline")
            magic_used = "inline"
        else:
            # interactive and auto share the same fallback sequence.
            magic_used = _run_with_fallback(("ipympl", "notebook", "inline"))

    info = {
        "enabled": True,
        "mode": mode,
        "magic_used": magic_used,
        "ipython_available": ip is not None,
        "backend": mpl.get_backend(),
    }
    if verbose:
        print("Plot backend mode:", mode)
        print("Matplotlib backend:", info["backend"])
        if magic_used is not None:
            print("Matplotlib magic used:", magic_used)
    return info


def build_output_table(output_column_names, available_columns):
    """Build output table using an explicit, user-defined column order.

    Parameters
    ----------
    output_column_names : sequence of str
        Ordered column names requested by the user.
    available_columns : dict[str, array-like]
        Mapping from valid column names to 1D arrays of equal length.

    Returns
    -------
    tuple[np.ndarray, list[str]]
        Stacked table and the validated ordered names.
    """
    if output_column_names is None:
        raise ValueError("output_column_names must be provided as a non-empty list of strings.")

    ordered = list(output_column_names)
    if len(ordered) == 0:
        raise ValueError("output_column_names is empty. Provide at least one column name.")

    if any((not isinstance(name, str)) for name in ordered):
        raise ValueError("All entries in output_column_names must be strings.")

    seen = set()
    duplicates = []
    for name in ordered:
        if name in seen and name not in duplicates:
            duplicates.append(name)
        seen.add(name)
    if duplicates:
        raise ValueError(f"Duplicate column names are not allowed: {duplicates}")

    unknown = [name for name in ordered if name not in available_columns]
    if unknown:
        valid = sorted(list(available_columns.keys()))
        raise ValueError(
            "Unknown output column(s): "
            f"{unknown}. Valid choices for the current toggles are: {valid}"
        )

    lengths = {name: np.asarray(available_columns[name]).shape[0] for name in available_columns}
    if len(set(lengths.values())) != 1:
        raise ValueError("available_columns arrays must all have the same length.")

    stacked = np.column_stack([np.asarray(available_columns[name], dtype=float) for name in ordered])
    return stacked, ordered


def derive_runtime_settings(
    *,
    enable_abundance_transition,
    abundance_target_species,
    abundance_closure_species,
    anchor_radius_mode,
    rmin,
    rmax,
    r_start_frac,
    r_start_abs,
    use_non_uniform_composition,
    uniform_composition_strategy,
):
    """Derive execution settings from notebook toggles.

    Returns a dictionary with:
    - `abundance_mode`, `abundance_names`
    - `r_start`
    - `unif_comp_mode`
    """
    if enable_abundance_transition:
        abundance_mode = "list"
        abundance_names = sorted(set(list(abundance_target_species) + [abundance_closure_species]))
    else:
        abundance_mode = "none"
        abundance_names = []

    if anchor_radius_mode == "fraction":
        r_start = float(rmin + np.clip(r_start_frac, 0.0, 1.0) * (rmax - rmin))
    elif anchor_radius_mode == "absolute":
        r_start = r_start_abs
    elif anchor_radius_mode == "none":
        r_start = None
    else:
        raise ValueError(f"Unknown anchor_radius_mode: {anchor_radius_mode}")

    if use_non_uniform_composition:
        unif_comp_mode = None
    else:
        unif_comp_mode = uniform_composition_strategy

    return {
        "abundance_mode": abundance_mode,
        "abundance_names": abundance_names,
        "r_start": r_start,
        "unif_comp_mode": unif_comp_mode,
    }


def tweak_enuc_profile(r, enuc, shift_dr=0.0, renorm_factor=1.0, clip_non_negative=True):
    """Apply shift+renormalization to an enuc profile on radius grid `r`."""
    r = np.asarray(r, dtype=float)
    enuc = np.asarray(enuc, dtype=float)

    enuc_shifted = np.interp(
        r - float(shift_dr),
        r,
        enuc,
        left=enuc[0],
        right=enuc[-1],
    )
    enuc_modified = float(renorm_factor) * enuc_shifted
    if clip_non_negative:
        enuc_modified = np.maximum(enuc_modified, 0.0)

    return enuc_modified


def build_run_summary(
    *,
    rmin,
    rmax,
    Nr,
    p_hse,
    rho_hse,
    r_hse,
    gravity_fn,
    integration_mode,
    r_start,
    anchor_info,
    nabladif_zero_tol,
):
    """Compute HSE residual stats and assemble a compact run-summary dictionary."""
    delta_r = (float(rmax) - float(rmin)) / (int(Nr) - 1)
    gradp_hse = (p_hse[2:] - p_hse[:-2]) / (2.0 * delta_r)
    rho_mid = rho_hse[1:-1]
    g_mid = gravity_fn(r_hse[1:-1])
    hse_residual = np.abs((gradp_hse - rho_mid * g_mid) / (rho_mid * g_mid))

    finite_res = np.isfinite(hse_residual)
    if np.any(finite_res):
        hse_stats = {
            "min": float(np.min(hse_residual[finite_res])),
            "median": float(np.median(hse_residual[finite_res])),
            "max": float(np.max(hse_residual[finite_res])),
        }
    else:
        hse_stats = {"min": np.nan, "median": np.nan, "max": np.nan}

    run_summary = {
        "integration_mode": integration_mode,
        "r_start_requested": r_start,
        "r_anchor_used": anchor_info["r_anchor"],
        "nabladif_zero_tol": nabladif_zero_tol if integration_mode == "nabladif_given" else None,
        "hse_residual_stats": hse_stats,
    }
    return run_summary, hse_residual


def write_output_bundle(
    *,
    output_file,
    name_of_in_file,
    r_hse_rk4,
    gravity_p,
    phi_rk4,
    p_hse_rk4,
    rho_hse_rk4,
    T_hse_rk4,
    r_mm,
    kappa_mm,
    use_non_uniform_composition,
    abar_p,
    zbar_p,
    enuc_inter,
    enuc_at_output,
    abundance_profiles_mm,
    output_column_names_requested,
    build_output_table_fn,
    rmin,
    rmax,
    integration_mode,
    r_start,
    anchor_info,
    nabladif_zero_tol,
    build_run_summary_fn,
    integration_info,
    mesa_path,
    helm_table_path,
    hse_library_pointer,
    mesa_reader_pointer,
    run_reintegration,
    use_eos_p0,
    uniform_composition_strategy,
    eos_mode,
    missing_profile_policy,
    press_mm,
    temp_mm,
    rho_mm,
    gr_mm,
    abar_mm,
    zbar_mm,
    ye_mm,
    nabladif_mm,
    r_mme,
    press_mme,
    temp_mme,
    rho_mme,
    gr_mme,
    abar_mme,
    zbar_mme,
    nabladif_mme,
    smoothing_width=0,
    smoothing_kernel="gaussian",
    resize_factor=1,
    notebook_path="create_input_library/create_input.ipynb",
):
    """Write `.in` and `.npz` outputs for prepared or reintegrated profiles.

    Returns a dictionary containing paths, selected columns, and assembled arrays
    for downstream plotting/diagnostics.
    """
    if not output_file:
        print("output_file=False -> skipping output writing stage.")
        return {
            "written": False,
            "in_path": None,
            "npz_path": None,
            "output_columns": [],
            "output_table": None,
            "available_columns": {},
            "abundance_profiles_out": {},
            "run_summary": None,
            "hse_residual": None,
        }

    # Build common output-grid arrays.
    r_out = np.asarray(r_hse_rk4, dtype=float)
    g_out = np.asarray(gravity_p(r_out), dtype=float)
    phi_out = np.asarray(phi_rk4, dtype=float)
    p_out = np.asarray(p_hse_rk4, dtype=float)
    rho_out = np.asarray(rho_hse_rk4, dtype=float)
    t_out = np.asarray(T_hse_rk4, dtype=float)
    kappa_out = np.interp(r_out, r_mm, kappa_mm)

    if use_non_uniform_composition:
        abar_out = np.asarray(abar_p(r_out), dtype=float)
        zbar_out = np.asarray(zbar_p(r_out), dtype=float)
    else:
        abar_scalar = float(abar_p)
        zbar_scalar = float(zbar_p)
        ye_scalar = zbar_scalar / max(abar_scalar, 1e-99)
        print(f"Collapsed uniform composition: Abar={abar_scalar:.6e}, Zbar={zbar_scalar:.6e}, Ye={ye_scalar:.6e}")
        abar_out = np.full_like(r_out, abar_scalar, dtype=float)
        zbar_out = np.full_like(r_out, zbar_scalar, dtype=float)

    ye_out = zbar_out / np.maximum(abar_out, 1e-99)
    inv_abar_out = 1.0 / np.maximum(abar_out, 1e-99)
    enuc_out = np.asarray(enuc_inter(r_out), dtype=float) if enuc_at_output else np.zeros_like(r_out)

    # Available columns are validated against the user-requested explicit order.
    available_columns = {
        "r_cm": r_out,
        "g_cms2": g_out,
        "phi_ergg": phi_out,
        "P_cgs": p_out,
        "rho_cgs": rho_out,
        "T_K": t_out,
        "kappa_cgs": kappa_out,
        "Ye": ye_out,
        "inv_Abar": inv_abar_out,
        "Abar": abar_out,
        "Zbar": zbar_out,
    }
    if enuc_at_output:
        available_columns["enuc_erg_cm3_s"] = enuc_out

    # Optional abundance-transition species columns (X_species).
    abundance_profiles_out = {}
    if len(abundance_profiles_mm) > 0:
        smoothing_width_eff = int(float(smoothing_width) * float(resize_factor))
        for sp_name, sp_prof in abundance_profiles_mm.items():
            col_name = f"X_{sp_name}"
            sp_arr = np.asarray(sp_prof, dtype=float)
            if smoothing_width_eff > 0:
                # Match preparation behavior: remap to prepared grid, smooth,
                # then sample on output grid.
                sp_prepared = np.interp(r_mme, r_mm, sp_arr)
                sp_prepared = HSEIntegrator.smooth_profile(sp_prepared,smoothing_width_eff,kernel=smoothing_kernel)
                sp_out = np.interp(r_out, r_mme, sp_prepared)
            else:
                sp_out = np.interp(r_out, r_mm, sp_arr)
            available_columns[col_name] = sp_out
            abundance_profiles_out[col_name] = sp_out

    output_table, output_columns = build_output_table_fn(
        output_column_names_requested,
        available_columns,
    )

    in_path = Path(name_of_in_file)
    npz_path = in_path.with_suffix(".npz")

    with open(in_path, "w", encoding="utf-8") as f_out:
        f_out.write(f"{len(r_out)}\n")
        np.savetxt(f_out, output_table, fmt="%.16e")

    run_summary, hse_residual = build_run_summary_fn(
        rmin=rmin,
        rmax=rmax,
        Nr=len(r_out),
        p_hse=p_out,
        rho_hse=rho_out,
        r_hse=r_out,
        gravity_fn=gravity_p,
        integration_mode=integration_mode,
        r_start=r_start,
        anchor_info=anchor_info,
        nabladif_zero_tol=nabladif_zero_tol,
    )

    metadata = {
        "notebook": notebook_path,
        "mesa_path": mesa_path,
        "helm_table_path": helm_table_path,
        "hse_library_pointer": hse_library_pointer,
        "mesa_reader_pointer": mesa_reader_pointer,
        "output_in_file": str(in_path),
        "output_npz_file": str(npz_path),
        "timestamp_utc": np.datetime_as_string(np.datetime64("now"), timezone="UTC"),
        "toggles": {
            "integration_mode": integration_mode,
            "run_reintegration": bool(run_reintegration),
            "use_eos_p0": bool(use_eos_p0),
            "use_non_uniform_composition": bool(use_non_uniform_composition),
            "uniform_composition_strategy": uniform_composition_strategy,
            "enuc_at_output": bool(enuc_at_output),
            "output_column_names_requested": list(output_column_names_requested),
            "eos_mode": eos_mode,
            "missing_profile_policy": missing_profile_policy,
            "nabladif_zero_tol": nabladif_zero_tol,
        },
    }
    if not use_non_uniform_composition:
        metadata["uniform_abar"] = float(abar_out[0])
        metadata["uniform_zbar"] = float(zbar_out[0])
        metadata["uniform_ye"] = float(ye_out[0])

    np.savez_compressed(
        npz_path,
        metadata_json=json.dumps(metadata, indent=2),
        run_summary_json=json.dumps(run_summary, indent=2),
        integration_diagnostics_json=json.dumps(integration_info, indent=2),
        anchor_diagnostics_json=json.dumps(anchor_info, indent=2),
        output_columns=np.asarray(output_columns, dtype=object),
        output_table=output_table,
        r_hse_rk4=r_out,
        p_hse_rk4=p_out,
        T_hse_rk4=t_out,
        rho_hse_rk4=rho_out,
        g_hse_rk4=g_out,
        phi_rk4=phi_out,
        kappa_hse_rk4=kappa_out,
        abar_hse_rk4=abar_out,
        zbar_hse_rk4=zbar_out,
        ye_hse_rk4=ye_out,
        inv_abar_hse_rk4=inv_abar_out,
        enuc_hse_rk4=enuc_out,
        hse_residual=hse_residual,
        r_mesa=r_mm,
        p_mesa=press_mm,
        T_mesa=temp_mm,
        rho_mesa=rho_mm,
        g_mesa=gr_mm,
        abar_mesa=abar_mm,
        zbar_mesa=zbar_mm,
        ye_mesa=ye_mm,
        kappa_mesa=kappa_mm,
        nabladif_mesa=nabladif_mm,
        r_prepared=r_mme,
        p_prepared=press_mme,
        T_prepared=temp_mme,
        rho_prepared=rho_mme,
        g_prepared=gr_mme,
        abar_prepared=abar_mme,
        zbar_prepared=zbar_mme,
        nabladif_prepared=nabladif_mme,
        **abundance_profiles_out,
    )

    print(f"Wrote .in file: {in_path}")
    print(f"Wrote .npz file: {npz_path}")
    print(f"Columns written ({len(output_columns)}): {output_columns}")

    return {
        "written": True,
        "in_path": in_path,
        "npz_path": npz_path,
        "output_columns": output_columns,
        "output_table": output_table,
        "available_columns": available_columns,
        "abundance_profiles_out": abundance_profiles_out,
        "run_summary": run_summary,
        "hse_residual": hse_residual,
    }


# -----------------------------------------------------------------------------
# Hydrostatic Structure Integration Core
# -----------------------------------------------------------------------------
# Includes:
# - RK4 marching kernels for uniform and composition-gradient integration,
# - profile smoothing and input preparation,
# - dispatch routine that selects integration path,
# - potential post-processing utility.
class HSEIntegrator:
    # Construction and shared EOS state ---------------------------------------
    def __init__(self, eos_backend=phleos,eos_table=None, eos_mode=None):
        """Initialize integrator with an EOS backend and optional default EOS mode."""
        self.eos = eos_backend
        self.eos_table = eos_table
        self.eos_mode = eos_mode

    def _mode(self, eos_mode):
        """Resolve EOS mode, preferring call-time override over instance default."""
        return self.eos_mode if eos_mode is None else eos_mode

    # Low-level numeric helpers ------------------------------------------------
    @staticmethod
    def grid2grid(r_array, q_array, rmin, rmax, Nr):
        """Interpolate profile values from an input grid onto an evenly spaced grid."""
        q_interpolated = interp1d(r_array, q_array)
        r_equal = np.linspace(rmin, rmax, Nr)
        q_equal = q_interpolated(r_equal)
        return q_equal

    @staticmethod
    def pressure_scale_height(p, gradp):
        """Compute pressure scale height from pressure and pressure gradient."""
        return -p / gradp

    # March-domain index helpers ----------------------------------------------
    @staticmethod
    def _resolve_anchor_index(r_arr, r_start=None):
        """Return anchor index by snapping requested radius to nearest grid point."""
        if r_start is None:
            return 0

        r_target = float(r_start)
        idx = int(np.argmin(np.abs(r_arr - r_target)))
        return idx

    @staticmethod
    def _walk_indices(start_idx, end_idx):
        """Yield index pairs `(i, j)` for marching from start to end (inclusive)."""
        if start_idx == end_idx:
            return
        step = 1 if end_idx > start_idx else -1
        for i in range(start_idx, end_idx, step):
            yield i, i + step

    # RK4 stepping kernel and diagnostics -------------------------------------
    def _rk4_march_nabladif(self, r_arr, p_hse, T_hse, rho_hse, start_idx, end_idx, p_init, T_init, grav_fn, comp_fn, nabladif_fn, mode):
        """March one RK4 branch in radius for dP/dr and dT/dr with nabladif forcing."""
        p = p_init
        T = T_init
        abar0, zbar0 = comp_fn(r_arr[start_idx])
        p_hse[start_idx] = p
        T_hse[start_idx] = T
        _, rho_hse[start_idx] = self.eos.PT_given(self.eos_table, p, T, abar0, zbar0, eos_mode=mode)

        for i, j in self._walk_indices(start_idx, end_idx):
            r = r_arr[i]
            delta_r = r_arr[j] - r
            abar_i, zbar_i = comp_fn(r)
            _, rho = self.eos.PT_given(self.eos_table, p, T, abar_i, zbar_i, eos_mode=mode)
            k1_p = rho * grav_fn(r)
            Hpk1 = self.pressure_scale_height(p, k1_p)

            nabla_ad = self.eos.rhoT_given(self.eos_table, rho, T, abar_i, zbar_i, eos_mode=mode)[phleos.id_nabla_ad]
            k1_T = -T * (nabla_ad + nabladif_fn(r)) / Hpk1

            r_2 = r + delta_r / 2
            abar_2, zbar_2 = comp_fn(r_2)
            p_2 = p + delta_r / 2 * k1_p
            T_2 = T + delta_r / 2 * k1_T
            _, rho = self.eos.PT_given(self.eos_table, p_2, T_2, abar_2, zbar_2, eos_mode=mode)
            k2_p = rho * grav_fn(r_2)
            Hpk2 = self.pressure_scale_height(p_2, k2_p)
            nabla_ad = self.eos.rhoT_given(self.eos_table, rho, T_2, abar_2, zbar_2, eos_mode=mode)[phleos.id_nabla_ad]
            k2_T = -T_2 * (nabla_ad + nabladif_fn(r_2)) / Hpk2

            r_3 = r + delta_r / 2
            abar_3, zbar_3 = comp_fn(r_3)
            p_3 = p + delta_r / 2 * k2_p
            T_3 = T + delta_r / 2 * k2_T
            _, rho = self.eos.PT_given(self.eos_table, p_3, T_3, abar_3, zbar_3, eos_mode=mode)
            k3_p = rho * grav_fn(r_3)
            Hpk3 = self.pressure_scale_height(p_3, k3_p)
            nabla_ad = self.eos.rhoT_given(self.eos_table, rho, T_3, abar_3, zbar_3, eos_mode=mode)[phleos.id_nabla_ad]
            k3_T = -T_3 * (nabla_ad + nabladif_fn(r_3)) / Hpk3

            r_4 = r + delta_r
            abar_4, zbar_4 = comp_fn(r_4)
            p_4 = p + delta_r * k3_p
            T_4 = T + delta_r * k3_T
            _, rho = self.eos.PT_given(self.eos_table, p_4, T_4, abar_4, zbar_4, eos_mode=mode)
            k4_p = rho * grav_fn(r_4)
            Hpk4 = self.pressure_scale_height(p_4, k4_p)
            nabla_ad = self.eos.rhoT_given(self.eos_table, rho, T_4, abar_4, zbar_4, eos_mode=mode)[phleos.id_nabla_ad]
            k4_T = -T_4 * (nabla_ad + nabladif_fn(r_4)) / Hpk4

            p = p + delta_r / 6 * (k1_p + 2 * k2_p + 2 * k3_p + k4_p)
            T = T + delta_r / 6 * (k1_T + 2 * k2_T + 2 * k3_T + k4_T)
            abar_j, zbar_j = comp_fn(r_arr[j])
            p_hse[j] = p
            T_hse[j] = T
            _, rho_hse[j] = self.eos.PT_given(self.eos_table, p, T, abar_j, zbar_j, eos_mode=mode)

    def _integration_diag(self, r_arr, anchor_idx, r_request):
        """Build integration diagnostics payload."""
        return {
            "anchor_idx": int(anchor_idx),
            "anchor_r": float(r_arr[anchor_idx]),
            "requested_r_start": None if r_request is None else float(r_request),
            "domain": (float(r_arr[0]), float(r_arr[-1])),
        }

    # Public integration entry points -----------------------------------------
    def integration_rk4(
        self,
        p0,
        T0,
        rmin,
        rmax,
        Nr,
        grav_inter,
        abar,
        zbar,
        nabladif_inter,
        eos_mode=None,
        r_start=None,
        verbose=True,
        return_diagnostics=False,
    ):
        """Integrate hydrostatic structure with RK4 for uniform composition.

        If `r_start` is provided, integration starts there and marches both outward
        and inward to fill the whole [rmin, rmax] domain.
        """
        mode = self._mode(eos_mode)
        p_hse = np.full((Nr), np.nan)
        T_hse = np.full((Nr), np.nan)
        rho_hse = np.full((Nr), np.nan)
        r_arr = np.linspace(rmin, rmax, Nr)
        anchor_idx = self._resolve_anchor_index(r_arr, r_start=r_start)

        self._rk4_march_nabladif(
            r_arr,
            p_hse,
            T_hse,
            rho_hse,
            anchor_idx,
            Nr - 1,
            p0,
            T0,
            grav_inter,
            lambda _r: (abar, zbar),
            nabladif_inter,
            mode,
        )
        if anchor_idx > 0:
            self._rk4_march_nabladif(
                r_arr,
                p_hse,
                T_hse,
                rho_hse,
                anchor_idx,
                0,
                p0,
                T0,
                grav_inter,
                lambda _r: (abar, zbar),
                nabladif_inter,
                mode,
            )

        r_hse = r_arr
        if np.any(np.isnan(p_hse)) or np.any(np.isnan(T_hse)) or np.any(np.isnan(rho_hse)):
            raise RuntimeError("Bidirectional RK4 integration did not populate all grid points.")

        diag = self._integration_diag(r_hse, anchor_idx, r_start)
        if verbose:
            print(f"integration done with RK4 from anchor r={diag['anchor_r']} (idx={diag['anchor_idx']})")
        if return_diagnostics:
            return p_hse, T_hse, rho_hse, r_hse, diag
        return p_hse, T_hse, rho_hse, r_hse

    # Public integration entry points (composition gradients) -----------------
    def integration_rk4_compgrad(
        self,
        p0,
        T0,
        rmin,
        rmax,
        Nr,
        grav_inter,
        abar_inter,
        zbar_inter,
        nabladif_inter,
        eos_mode=None,
        r_start=None,
        verbose=True,
        return_diagnostics=False,
    ):
        """Integrate hydrostatic structure with RK4 using composition gradients.

        If `r_start` is provided, integration starts there and marches both outward
        and inward to fill the whole [rmin, rmax] domain.
        """
        mode = self._mode(eos_mode)
        p_hse = np.full((Nr), np.nan)
        T_hse = np.full((Nr), np.nan)
        rho_hse = np.full((Nr), np.nan)
        r_arr = np.linspace(rmin, rmax, Nr)
        anchor_idx = self._resolve_anchor_index(r_arr, r_start=r_start)

        self._rk4_march_nabladif(
            r_arr,
            p_hse,
            T_hse,
            rho_hse,
            anchor_idx,
            Nr - 1,
            p0,
            T0,
            grav_inter,
            lambda rr: (float(abar_inter(rr)), float(zbar_inter(rr))),
            nabladif_inter,
            mode,
        )
        if anchor_idx > 0:
            self._rk4_march_nabladif(
                r_arr,
                p_hse,
                T_hse,
                rho_hse,
                anchor_idx,
                0,
                p0,
                T0,
                grav_inter,
                lambda rr: (float(abar_inter(rr)), float(zbar_inter(rr))),
                nabladif_inter,
                mode,
            )

        r_hse = r_arr
        if np.any(np.isnan(p_hse)) or np.any(np.isnan(T_hse)) or np.any(np.isnan(rho_hse)):
            raise RuntimeError("Bidirectional RK4 integration (composition gradient) did not populate all grid points.")

        diag = self._integration_diag(r_hse, anchor_idx, r_start)
        if verbose:
            print(f"integration done with RK4 + composition gradients from anchor r={diag['anchor_r']} (idx={diag['anchor_idx']})")
        if return_diagnostics:
            return p_hse, T_hse, rho_hse, r_hse, diag
        return p_hse, T_hse, rho_hse, r_hse

    # Integration path with prescribed temperature ----------------------------
    def integration_tgiven(
        self,
        P0,
        Tm,
        rmin,
        rmax,
        Nr,
        gm,
        abarm,
        zbarm,
        eos_mode=None,
        r_start=None,
        verbose=True,
        return_diagnostics=False,
    ):
        """Integrate hydrostatic pressure when temperature profile is prescribed.

        If `r_start` is provided, integration starts there and marches both outward
        and inward to fill the whole [rmin, rmax] domain.
        """
        mode = self._mode(eos_mode)
        rs = np.linspace(rmin, rmax, Nr)

        Ps = np.full((Nr), np.nan)
        rhos = np.full((Nr), np.nan)
        abars = abarm(rs)
        zbars = zbarm(rs)
        Ts = Tm(rs)
        anchor_idx = self._resolve_anchor_index(rs, r_start=r_start)

        def _march(start_idx, end_idx, p_init):
            Ps[start_idx] = p_init
            rhos[start_idx] = self.eos.PT_given(self.eos_table, Ps[start_idx], Ts[start_idx], abars[start_idx], zbars[start_idx], eos_mode=mode)[1]

            for i, j in self._walk_indices(start_idx, end_idx):
                rn = rs[i]
                dr = rs[j] - rn
                pn = Ps[i]
                _, rhon = self.eos.PT_given(self.eos_table, pn, Ts[i], abars[i], zbars[i], eos_mode=mode)
                k1 = rhon * gm(rn)

                r2 = rn + dr / 2.0
                p2 = pn + k1 * dr / 2.0
                _, rho2 = self.eos.PT_given(self.eos_table, p2, Tm(r2), abarm(r2), zbarm(r2), eos_mode=mode)
                k2 = rho2 * gm(r2)

                r3 = rn + dr / 2.0
                p3 = pn + k2 * dr / 2.0
                _, rho3 = self.eos.PT_given(self.eos_table, p3, Tm(r3), abarm(r3), zbarm(r3), eos_mode=mode)
                k3 = rho3 * gm(r3)

                r4 = rn + dr
                p4 = pn + k3 * dr
                _, rho4 = self.eos.PT_given(self.eos_table, p4, Tm(r4), abarm(r4), zbarm(r4), eos_mode=mode)
                k4 = rho4 * gm(r4)

                p_next = pn + dr / 6.0 * (k1 + 2.0 * k2 + 2.0 * k3 + k4)
                Ps[j] = p_next
                _, rhos[j] = self.eos.PT_given(self.eos_table, p_next, Ts[j], abars[j], zbars[j], eos_mode=mode)

        _march(anchor_idx, Nr - 1, P0)
        if anchor_idx > 0:
            _march(anchor_idx, 0, P0)

        if np.any(np.isnan(Ps)) or np.any(np.isnan(rhos)):
            raise RuntimeError("Bidirectional t_given integration did not populate all grid points.")

        diag = self._integration_diag(rs, anchor_idx, r_start)
        if verbose:
            print(f"integration done with t_given from anchor r={diag['anchor_r']} (idx={diag['anchor_idx']})")
        if return_diagnostics:
            return Ps, Ts, rhos, rs, diag
        return Ps, Ts, rhos, rs

    # Input preparation and dispatch ------------------------------------------
    @staticmethod
    def smooth_profile(q, width, kernel="gaussian"):
        """Smooth a 1D profile with box, gaussian, or bump kernel."""
        prolonged_profile = np.pad(q, (int(width / 2), int(width / 2)), mode="edge")
        if kernel == "box":
            smoothed_q_prolonged = np.convolve(prolonged_profile, np.ones((width)), mode="same") / width
        elif kernel == "gaussian":
            gauss_kern = np.exp(-0.5 * (np.linspace(-1, 1, width) ** 2))
            gauss_kern /= gauss_kern.sum()
            smoothed_q_prolonged = np.convolve(prolonged_profile, gauss_kern, mode="same")
        elif kernel == "bump":
            bump_kern = np.exp(-1 / (1 - (np.linspace(-1, 1, width + 2)[1:-1] ** 2)))
            bump_kern /= bump_kern.sum()
            smoothed_q_prolonged = np.convolve(prolonged_profile, bump_kern, mode="same")
        else:
            raise ValueError(f"Unknown kernel: {kernel}")
        smoothed_q = smoothed_q_prolonged[int(width / 2):-int(width / 2)]
        return smoothed_q

    def prepare_for_integration(
        self,
        integration_mode: str,
        use_non_uniform_composition: bool,
        smoothing_width: int,
        smoothing_kernel: str,
        rmin: float,
        r_mme: np.ndarray,
        grav_mme: np.ndarray,
        unif_comp_mode: str,
        use_eos_p0: bool,
        rho_mme: np.ndarray,
        press_mme: np.ndarray,
        temp_mme: np.ndarray,
        abar_mme: np.ndarray,
        zbar_mme: np.ndarray,
        nabladif_mme: np.ndarray,
        eos_mode=None,
        resize_factor: int = 1,
        r_start: float = None,
        nabladif_zero_tol: float = None,
        verbose: bool = True,
        return_anchor_info: bool = False,
    ) -> tuple:
        """Prepare interpolators/scalars and initial pressure for selected integration mode."""
        mode = self._mode(eos_mode)

        if smoothing_width > 0:
            smoothing_width = smoothing_width * resize_factor
            press_mme = self.smooth_profile(press_mme, smoothing_width, kernel=smoothing_kernel)
            temp_mme = self.smooth_profile(temp_mme, smoothing_width, kernel=smoothing_kernel)
            grav_mme = self.smooth_profile(grav_mme, smoothing_width, kernel=smoothing_kernel)
            if use_eos_p0:
                rho_mme = self.smooth_profile(rho_mme, smoothing_width, kernel=smoothing_kernel)
            # Smooth composition inputs for both composition modes so uniform
            # mode statistics (mean/median) reflect the prepared profiles too.
            abar_mme = self.smooth_profile(abar_mme, smoothing_width, kernel=smoothing_kernel)
            zbar_mme = self.smooth_profile(zbar_mme, smoothing_width, kernel=smoothing_kernel)
            if integration_mode == "nabladif_given":
                nabladif_mme = self.smooth_profile(nabladif_mme, smoothing_width, kernel=smoothing_kernel)
        else:
            print("No smoothing applied to input profiles")

        # In nabladif_given mode, optionally clamp near-zero imported nabladif values to hard zero.
        if integration_mode == "nabladif_given" and nabladif_zero_tol is not None:
            tol = float(nabladif_zero_tol)
            if tol < 0.0:
                raise ValueError(f"nabladif_zero_tol must be non-negative, got {nabladif_zero_tol}")
            near_zero = np.abs(nabladif_mme) < tol
            if np.any(near_zero):
                nabladif_mme = nabladif_mme.copy()
                nabladif_mme[near_zero] = 0.0
                if verbose:
                    print(f"Applied nabladif zero clamp with tol={tol}: zeroed {int(np.count_nonzero(near_zero))} points")

        nabladif_inter = interp1d(r_mme, nabladif_mme, fill_value="extrapolate")
        grav_inter = interp1d(r_mme, grav_mme, fill_value="extrapolate")
        temp_inter = interp1d(r_mme, temp_mme, fill_value="extrapolate")
        rho_inter = interp1d(r_mme, rho_mme, fill_value="extrapolate")
        press_inter = interp1d(r_mme, press_mme, fill_value="extrapolate")

        if r_start is None:
            r_request = rmin
        else:
            r_request = r_start

        anchor_idx = self._resolve_anchor_index(r_mme, r_start=r_request)
        r_start_eff = float(r_mme[anchor_idx])
        anchor_info = {
            "anchor_idx": int(anchor_idx),
            "requested_r_start": float(r_request),
            "r_anchor": r_start_eff,
            "domain": (float(np.min(r_mme)), float(np.max(r_mme))),
        }

        if use_non_uniform_composition:
            abar_inter = interp1d(r_mme, abar_mme, fill_value="extrapolate")
            zbar_inter = interp1d(r_mme, zbar_mme, fill_value="extrapolate")
            abar_start = float(abar_inter(r_start_eff))
            zbar_start = float(zbar_inter(r_start_eff))
        else:
            if unif_comp_mode == "mean":
                abar_mean = np.mean(abar_mme)
                zbar_mean = np.mean(zbar_mme)
            elif unif_comp_mode == "median":
                abar_mean = np.median(abar_mme)
                zbar_mean = np.median(zbar_mme)
            else:
                raise ValueError(f"Unknown unif_comp_mode: {unif_comp_mode}")

        temp_start = float(temp_inter(r_start_eff))
        rho_start = float(rho_inter(r_start_eff))

        if use_eos_p0:
            if use_non_uniform_composition:
                press_0 = self.eos.rhoT_given(self.eos_table, rho_start, temp_start, abar_start, zbar_start, eos_mode=mode)[phleos.id_P]
            else:
                press_0 = self.eos.rhoT_given(self.eos_table, rho_start, temp_start, abar_mean, zbar_mean, eos_mode=mode)[phleos.id_P]
            if verbose:
                print(f"Initial pressure P0 computed using Helmholtz EOS at r_start={r_start_eff}: {press_0}")
        else:
            press_0 = float(press_inter(r_start_eff))
            if verbose:
                print(f"Initial pressure P0 taken from MESA profile at r_start={r_start_eff}: {press_0}")

        if use_non_uniform_composition:
            if integration_mode == "t_given":
                out = (press_0, temp_inter, grav_inter, abar_inter, zbar_inter, None)
                if return_anchor_info:
                    return out + (anchor_info,)
                return out
            if integration_mode == "nabladif_given":
                out = (press_0, temp_start, grav_inter, abar_inter, zbar_inter, nabladif_inter)
                if return_anchor_info:
                    return out + (anchor_info,)
                return out
            raise ValueError(f"Unknown integration_mode for non-uniform composition: {integration_mode}")

        if integration_mode == "t_given":
            out = (press_0, temp_inter, grav_inter, abar_mean, zbar_mean, None)
            if return_anchor_info:
                return out + (anchor_info,)
            return out

        if integration_mode == "nabladif_given":
            out = (press_0, temp_start, grav_inter, abar_mean, zbar_mean, nabladif_inter)
            if return_anchor_info:
                return out + (anchor_info,)
            return out

        raise ValueError(f"Unknown integration_mode for uniform composition: {integration_mode}")

    def hse_integrate(self, integration_mode: str, use_non_uniform_composition: bool, *args, **kwargs) -> tuple:
        """Dispatch to the correct integration routine based on mode and composition option."""
        if integration_mode == "t_given":
            # `prepare_for_integration` appends a placeholder (`None`) for
            # nabladif in t_given mode to keep tuple arity uniform across modes.
            # Drop that sentinel before dispatching to integration_tgiven.
            args = args[:-1]
            if not use_non_uniform_composition:
                p0, temp_fn, rmin, rmax, Nr, grav_fn, abar_scalar, zbar_scalar = args
                args = (
                    p0,
                    temp_fn,
                    rmin,
                    rmax,
                    Nr,
                    grav_fn,
                    (lambda r, a=float(abar_scalar): np.full_like(np.asarray(r, dtype=float), a, dtype=float) if np.ndim(r) > 0 else a),
                    (lambda r, z=float(zbar_scalar): np.full_like(np.asarray(r, dtype=float), z, dtype=float) if np.ndim(r) > 0 else z),
                )
            result = self.integration_tgiven(*args, **kwargs)
        elif use_non_uniform_composition:
            if integration_mode == "nabladif_given":
                result = self.integration_rk4_compgrad(*args, **kwargs)
            else:
                raise ValueError(f"Unknown integration mode for non-uniform composition: {integration_mode}")
        else:
            if integration_mode == "nabladif_given":
                result = self.integration_rk4(*args, **kwargs)
            else:
                raise ValueError(f"Unknown integration mode for uniform composition: {integration_mode}")

        if len(result) == 5:
            return result

        Ps, Ts, rhos, rs = result
        return Ps, Ts, rhos, rs

    # Post-processing ----------------------------------------------------------
    @staticmethod
    def g_potential(gravity_inter, r: np.ndarray) -> np.ndarray:
        """Compute gravitational potential from gravity profile by radial integration."""
        phi_rk4 = cumulative_trapezoid(gravity_inter(r), r, initial=0)
        phi_rk4 = -phi_rk4 + phi_rk4[-1]
        return phi_rk4


# -----------------------------------------------------------------------------
# Plotting and Visual Diagnostics
# -----------------------------------------------------------------------------
# Includes:
# - one-to-one profile comparison plots,
# - diagnostic multiplots (fluxes, convection, residuals),
# - prepared-profile and composition-transition checks,
# - generic visual-check dashboard builders and split-scale figure helpers.
class HSEPlotter:
    # Plot context / boundaries ------------------------------------------------
    def __init__(
        self,
        r_sol: float,
        rmin=None,
        rmax=None,
        rphl_min=None,
        rphl_max=None,
        r_integration_start=None,
        title_fontsize=10,
        legend_fontsize=8,
        label_fontsize=9,
        axis_value_fontsize=8,
    ):
        """Initialize plotting helper with radius normalization and optional boundaries."""
        self.r_sol = r_sol
        self.rmin = rmin
        self.rmax = rmax
        self.rphl_min = rphl_min
        self.rphl_max = rphl_max
        self.r_integration_start = r_integration_start
        self.title_fontsize = title_fontsize
        self.legend_fontsize = legend_fontsize
        self.label_fontsize = label_fontsize
        self.axis_value_fontsize = axis_value_fontsize
        # Color-blind-friendly blue/red palette (Okabe-Ito inspired).
        self.palette = {
            "blue": "#0933C0",
            "blue_light": "#56B4E9",
            "red": "#F01818",
            "red_dark": "#9B2226",
            "reference": "#9B2226",
        }

    def _style_axis(self, ax, title=None, ylabel=None, xlabel=r"$r/R_{\odot}$"):
        """Apply consistent title/label/tick font sizes to one axis."""
        if title is not None:
            ax.set_title(title, fontsize=self.title_fontsize)
        if xlabel is not None:
            ax.set_xlabel(xlabel, fontsize=self.label_fontsize)
        if ylabel is not None:
            ax.set_ylabel(ylabel, fontsize=self.label_fontsize)
        ax.tick_params(axis="both", labelsize=self.axis_value_fontsize)

    def _add_legend(self, ax):
        """Attach legend with configured font size."""
        ax.legend(fontsize=self.legend_fontsize)

    def _default_xlim(self):
        """Return default x-axis limits in units of r/R_sol."""
        if self.rmin is None or self.rmax is None:
            return None
        rmin_n = self.rmin / self.r_sol
        rmax_n = self.rmax / self.r_sol
        span = max(rmax_n - rmin_n, 1e-12)
        left_margin = 0.10 * span
        right_margin = 0.05 * span
        return (rmin_n - left_margin, rmax_n + right_margin)

    def _draw_boundaries(self, ax):
        """Draw configured radial boundary markers on a Matplotlib axis."""
        if self.rmin is not None:
            ax.axvline(x=self.rmin / self.r_sol, color=self.palette["red"], linestyle="--", label="Reintegration rmin")
        if self.rmax is not None:
            ax.axvline(x=self.rmax / self.r_sol, color=self.palette["red"], linestyle="--", label="Reintegration rmax")
        if self.rphl_min is not None:
            ax.axvline(x=self.rphl_min / self.r_sol, color=self.palette["blue"], linestyle="--", label="Simulation rmin")
        if self.rphl_max is not None:
            ax.axvline(x=self.rphl_max / self.r_sol, color=self.palette["blue"], linestyle="--", label="Simulation rmax")
        if self.r_integration_start is not None:
            ax.axvline(
                x=self.r_integration_start / self.r_sol,
                color=self.palette["red_dark"],
                linestyle=":",
                label="Integration start",
            )

    @staticmethod
    def _has_finite_values(y):
        """Return True if an array-like contains at least one finite value."""
        try:
            arr = np.asarray(y, dtype=float)
            return np.any(np.isfinite(arr))
        except (TypeError, ValueError):
            # Fall back for object arrays (e.g., mixed types) by checking
            # element-wise convertibility to float.
            try:
                arr_obj = np.asarray(y, dtype=object).ravel()
            except Exception:
                return False

            finite_found = False
            for val in arr_obj:
                try:
                    if np.isfinite(float(val)):
                        finite_found = True
                        break
                except (TypeError, ValueError):
                    continue
            return finite_found

    # Core profile comparison plots -------------------------------------------
    def compare_profile(
        self,
        r_mesa,
        y_mesa,
        r_phl,
        y_phl,
        title,
        ylabel,
        plot_every=None,
        yscale=None,
        ylim=None,
        xlim=None,
        mesa_label="MESA",
        phl_label="Phlegethon from RK4",
    ):
        """Plot one MESA profile against one reintegrated profile.

        Parameters use physical radii (cm) on input and are displayed as r/R_sol.
        Optional limits/scales are forwarded directly to Matplotlib axes.
        """
        fig, ax = plt.subplots()
        ax.plot(r_mesa / self.r_sol, y_mesa, label=mesa_label, linewidth=3.5, color=self.palette["blue"])
        if plot_every is not None:
            ax.plot(
                r_mesa[::plot_every] / self.r_sol,
                y_mesa[::plot_every],
                linestyle="None",
                marker="|",
                markersize=5,
                markerfacecolor=self.palette["blue"],
                markeredgecolor=self.palette["blue"],
            )

        ax.plot(r_phl / self.r_sol, y_phl, label=phl_label, linewidth=1.5, color=self.palette["red"])
        if plot_every is not None:
            ax.plot(
                r_phl[::plot_every] / self.r_sol,
                y_phl[::plot_every],
                linestyle="None",
                marker="|",
                markersize=5,
                markerfacecolor=self.palette["red"],
                markeredgecolor=self.palette["red"],
            )

        self._style_axis(ax, title=title, ylabel=ylabel)

        if xlim is None:
            xlim = self._default_xlim()
        if xlim is not None:
            ax.set_xlim(*xlim)

        if ylim is not None:
            ax.set_ylim(*ylim)

        if yscale is not None:
            ax.set_yscale(yscale)

        self._draw_boundaries(ax)
        self._add_legend(ax)
        return fig, ax

    # Single-profile plotting --------------------------------------------------
    def plot_single_profile(
        self,
        r,
        y,
        title,
        ylabel,
        label,
        plot_every=None,
        yscale=None,
        ylim=None,
        xlim=None,
        color=None,
    ):
        """Plot a single radial profile with optional sparse markers and scales."""
        if color is None:
            color = self.palette["red"]
        fig, ax = plt.subplots()
        ax.plot(r / self.r_sol, y, label=label, linewidth=1.5, color=color)
        if plot_every is not None:
            ax.plot(
                r[::plot_every] / self.r_sol,
                y[::plot_every],
                linestyle="None",
                marker="|",
                markersize=5,
                markerfacecolor=color,
                markeredgecolor=color,
            )

        self._style_axis(ax, title=title, ylabel=ylabel)

        if xlim is None:
            xlim = self._default_xlim()
        if xlim is not None:
            ax.set_xlim(*xlim)

        if ylim is not None:
            ax.set_ylim(*ylim)

        if yscale is not None:
            ax.set_yscale(yscale)

        self._draw_boundaries(ax)
        self._add_legend(ax)
        return fig, ax

    # Multi-panel diagnostic suites -------------------------------------------
    def compare_flux_components(self, r, f_rad, f_tot, f_conv, xlim=None):
        """Plot radiative/total/convective flux components in a 2x2 overview."""
        fig, axs = plt.subplots(2, 2, figsize=(12, 8))
        plt.subplots_adjust(wspace=0.3, hspace=0.4)

        flux_labels = {
            "f_rad": r"$f_{\rm rad}$",
            "f_tot": r"$f_{\rm tot}$",
            "f_conv": r"$f_{\rm conv}$",
        }

        panels = [
            (axs[0, 0], f_rad, "f_rad", self.palette["blue"]),
            (axs[0, 1], f_tot, "f_tot", self.palette["red_dark"]),
            (axs[1, 0], f_conv, "f_conv", self.palette["red"]),
        ]

        for ax, y, name, color in panels:
            ax.plot(r / self.r_sol, y, label="MESA", color=color)
            pretty_name = flux_labels.get(name, name)
            self._style_axis(ax, title=pretty_name, ylabel=pretty_name)
            if xlim is None:
                xlim_local = self._default_xlim()
            else:
                xlim_local = xlim
            if xlim_local is not None:
                ax.set_xlim(*xlim_local)
            ax.set_ylim(0, 1.1 * np.max(y))
            self._draw_boundaries(ax)
            self._add_legend(ax)

        axs[1, 1].plot(r / self.r_sol, f_conv, label=r"MESA $f_{\rm conv}$", color=self.palette["red"])
        axs[1, 1].plot(r / self.r_sol, f_rad, label=r"MESA $f_{\rm rad}$", color=self.palette["blue"])
        axs[1, 1].plot(
            r / self.r_sol,
            f_tot,
            label=r"MESA $f_{\rm tot}$",
            color=self.palette["red_dark"],
            linestyle="--",
        )
        self._style_axis(axs[1, 1], title=r"$f_{\rm conv},\ f_{\rm rad},\ f_{\rm tot}$", ylabel=r"$f$")
        if xlim is None:
            xlim_local = self._default_xlim()
        else:
            xlim_local = xlim
        if xlim_local is not None:
            axs[1, 1].set_xlim(*xlim_local)
        self._draw_boundaries(axs[1, 1])
        self._add_legend(axs[1, 1])

        return fig, axs

    def plot_conv_vel_mach(self, r, conv_vel, mach, xlim=None):
        """Plot convective velocity and Mach number in linear and log views."""
        fig, axs = plt.subplots(2, 2, figsize=(12, 8))
        plt.subplots_adjust(wspace=0.3, hspace=0.4)

        panels = [
            (axs[0, 0], conv_vel, r"$v_{\rm conv}$", r"$v_{\rm conv}$", False),
            (axs[0, 1], mach, r"$\mathcal{M}$", r"$\mathcal{M}$", False),
            (axs[1, 0], conv_vel, r"$v_{\rm conv}$ (log)", r"$v_{\rm conv}$", True),
            (axs[1, 1], mach, r"$\mathcal{M}$ (log)", r"$\mathcal{M}$", True),
        ]

        for ax, y, title, ylabel, is_log in panels:
            y_plot = np.asarray(y, dtype=float)
            if is_log:
                y_plot = np.where(np.isfinite(y_plot) & (y_plot > 0.0), y_plot, np.nan)
            else:
                y_plot = np.where(np.isfinite(y_plot), y_plot, np.nan)

            color = self.palette["blue"] if "v_{\\rm conv}" in title else self.palette["red"]
            ax.plot(r / self.r_sol, y_plot, label="MESA", color=color)
            self._style_axis(ax, title=title, ylabel=ylabel)

            if xlim is None:
                xlim_local = self._default_xlim()
            else:
                xlim_local = xlim
            if xlim_local is not None:
                ax.set_xlim(*xlim_local)

            if not is_log:
                if np.any(np.isfinite(y_plot)):
                    ymax = np.nanmax(y_plot)
                    ax.set_ylim(0, 1.1 * ymax if ymax > 0.0 else 1.0)
                else:
                    ax.set_ylim(0, 1.0)
            else:
                ax.set_yscale("log")

            self._draw_boundaries(ax)
            self._add_legend(ax)

        return fig, axs

    # Input-preparation comparison plots --------------------------------------
    def compare_prepared_profiles(
        self,
        r_mesa,
        r_prepared,
        press_mesa,
        press_prepared,
        temp_mesa,
        temp_prepared,
        grav_mesa,
        grav_prepared,
        abar_mesa,
        abar_prepared,
        zbar_mesa,
        zbar_prepared,
        integration_mode,
        use_non_uniform_composition,
        nabladif_mesa=None,
        nabladif_prepared=None,
    ):
        """Compare original MESA profiles against profiles prepared for integration."""
        fig, axs = plt.subplots(2, 3, figsize=(12, 8))
        plt.subplots_adjust(wspace=0.3, hspace=0.4)

        def _axis_common(ax, title, ylabel):
            self._style_axis(ax, title=title, ylabel=ylabel)
            xlim = self._default_xlim()
            if xlim is not None:
                ax.set_xlim(*xlim)
            self._draw_boundaries(ax)
            self._add_legend(ax)

        axs[0, 0].plot(r_mesa / self.r_sol, press_mesa, label="MESA", color=self.palette["blue"])
        axs[0, 0].plot(r_prepared / self.r_sol, press_prepared * np.ones_like(r_prepared),label="Prepared",color=self.palette["red"])
        _axis_common(axs[0, 0], r"$P$ prepared for integration", r"$P$")

        axs[0, 1].plot(r_mesa / self.r_sol, temp_mesa, label="MESA", color=self.palette["blue"])
        if integration_mode == "t_given":
            axs[0, 1].plot(r_prepared / self.r_sol,temp_prepared(r_prepared),label="Prepared",color=self.palette["red"])
        else:
            axs[0, 1].plot(r_prepared / self.r_sol,temp_prepared * np.ones_like(r_prepared),label="Prepared",color=self.palette["red"])
        _axis_common(axs[0, 1], r"$T$ prepared for integration", r"$T$")

        axs[0, 2].plot(r_mesa / self.r_sol, grav_mesa, label="MESA", color=self.palette["blue"])
        axs[0, 2].plot(r_prepared / self.r_sol, grav_prepared(r_prepared), label="Prepared", color=self.palette["red"])
        _axis_common(axs[0, 2], r"$g$ prepared for integration", r"$g$")

        axs[1, 0].plot(r_mesa / self.r_sol, abar_mesa, label="MESA", color=self.palette["blue"])
        if use_non_uniform_composition:
            axs[1, 0].plot(r_prepared / self.r_sol, abar_prepared(r_prepared), label="Prepared", color=self.palette["red"])
        else:
            axs[1, 0].plot(r_prepared / self.r_sol,abar_prepared * np.ones_like(r_prepared),label="Prepared",color=self.palette["red"])
        _axis_common(axs[1, 0], r"$\bar{A}$ prepared for integration", r"$\bar{A}$")

        axs[1, 1].plot(r_mesa / self.r_sol, zbar_mesa, label="MESA", color=self.palette["blue"])
        if use_non_uniform_composition:
            axs[1, 1].plot(r_prepared / self.r_sol, zbar_prepared(r_prepared), label="Prepared", color=self.palette["red"])
        else:
            axs[1, 1].plot(r_prepared / self.r_sol, zbar_prepared * np.ones_like(r_prepared),label="Prepared", color=self.palette["red"])
        _axis_common(axs[1, 1], r"$\bar{Z}$ prepared for integration", r"$\bar{Z}$")

        if integration_mode == "nabladif_given" and nabladif_mesa is not None and nabladif_prepared is not None:
            axs[1, 2].plot(r_mesa / self.r_sol, nabladif_mesa, label="MESA", color=self.palette["blue"])
            axs[1, 2].plot(r_prepared / self.r_sol,nabladif_prepared(r_prepared),label="Prepared",color=self.palette["red"])
            _axis_common(axs[1, 2], r"$\nabla-\nabla_{\rm ad}$ prepared for integration", r"$\nabla-\nabla_{\rm ad}$")
        else:
            axs[1, 2].text(
                0.5,
                0.5,
                r"$\nabla-\nabla_{\rm ad}$ not used in t_given mode",
                horizontalalignment="center",
                verticalalignment="center",
                transform=axs[1, 2].transAxes,
            )
            axs[1, 2].axis("off")

        return fig, axs

    # Composition-transition diagnostics --------------------------------------
    def compare_composition_transition(
        self,
        r,
        abar_old,
        zbar_old,
        ye_old,
        abar_new,
        zbar_new,
        ye_new,
        species_label="selected species",
    ):
        """Compare old/new composition moments using a two-column panel layout."""
        fig, axs = plt.subplots(3, 2, figsize=(12, 10))
        plt.subplots_adjust(wspace=0.30, hspace=0.40)

        rr = r / self.r_sol
        moments = [
            (abar_old, abar_new, r"$\bar{A}$"),
            (zbar_old, zbar_new, r"$\bar{Z}$"),
            (ye_old, ye_new, r"$Y_e$"),
        ]

        for i, (old_arr, new_arr, label) in enumerate(moments):
            old_arr = np.asarray(old_arr, dtype=float)
            new_arr = np.asarray(new_arr, dtype=float)

            ax_abs = axs[i, 0]
            ax_abs.plot(rr, old_arr, label="MESA original", linewidth=2.0, color=self.palette["blue"])
            ax_abs.plot(rr,new_arr,label=f"Transitioned ({species_label})",linewidth=1.6,color=self.palette["red"])
            self._style_axis(ax_abs, title=f"{label} (absolute)", ylabel=label)
            xlim = self._default_xlim()
            if xlim is not None:
                ax_abs.set_xlim(*xlim)
            self._draw_boundaries(ax_abs)
            self._add_legend(ax_abs)

            ax_rel = axs[i, 1]
            denom = np.where(np.abs(old_arr) > 1e-99, old_arr, np.nan)
            rel = (new_arr - old_arr) / denom
            ax_rel.plot(rr, rel, label=r"$(new-old)/old$", linewidth=1.6, color=self.palette["red_dark"])
            ax_rel.axhline(0.0, color=self.palette["reference"], linewidth=0.8, linestyle="--")
            self._style_axis(ax_rel, title=f"{label} (relative)", ylabel=r"$\Delta/old$")
            if xlim is not None:
                ax_rel.set_xlim(*xlim)
            self._draw_boundaries(ax_rel)
            self._add_legend(ax_rel)

        return fig, axs

    # HSE residual diagnostics -------------------------------------------------
    def plot_hse_residual(self, r_hse, delta_hse, plot_every=None):
        """Plot logarithmic hydrostatic-equilibrium residual versus radius."""
        fig, ax = plt.subplots()
        ax.plot(r_hse / self.r_sol, delta_hse, label="delta from RK4", linewidth=3.5, color=self.palette["red"])
        if plot_every is not None:
            ax.plot(
                r_hse[::plot_every] / self.r_sol,
                delta_hse[::plot_every],
                linestyle="None",
                marker="|",
                markersize=5,
                markerfacecolor=self.palette["red"],
                markeredgecolor=self.palette["red"],
            )
        self._style_axis(ax, ylabel="delta HSE")
        xlim = self._default_xlim()
        if xlim is not None:
            ax.set_xlim(*xlim)
        ax.set_yscale("log")
        self._draw_boundaries(ax)
        self._add_legend(ax)
        return fig, ax

    # Visual-check dashboard builders -----------------------------------------
    def plot_visual_check_multiplot(self, panels, ncols=3, figsize=(18, 28), xlim=None, show_legends=True):
        """Render a grid of comparison panels for the Visual Check section.

        Each item in ``panels`` is a dict with required keys:
        ``x_mesa``, ``y_mesa``, ``title``, ``ylabel``.
        Optional keys:
        ``x_phl``, ``y_phl``, ``mesa_label``, ``phl_label``, ``plot_every``,
        ``ylim``, ``yscale``.

        """
        # Skip panels whose inputs are entirely non-finite (common when optional
        # diagnostics were not loaded and are represented as NaN arrays).
        filtered_panels = []
        for panel in panels:
            y_mesa = panel["y_mesa"]
            y_phl = panel.get("y_phl", None)
            has_mesa = self._has_finite_values(y_mesa)
            has_phl = y_phl is not None and self._has_finite_values(y_phl)
            if has_mesa or has_phl:
                filtered_panels.append(panel)

        n_panels = len(filtered_panels)
        if n_panels == 0:
            fig, ax = plt.subplots(1, 1, figsize=(8, 3))
            ax.text(0.5, 0.5, "No finite panels to plot", ha="center", va="center")
            ax.axis("off")
            return fig, np.array([ax])

        nrows = int(np.ceil(n_panels / ncols))
        fig, axs = plt.subplots(nrows, ncols, figsize=figsize)
        axs = np.atleast_1d(axs).ravel()

        for i, panel in enumerate(filtered_panels):
            ax = axs[i]
            x_mesa = panel["x_mesa"]
            y_mesa = panel["y_mesa"]
            x_phl = panel.get("x_phl", None)
            y_phl = panel.get("y_phl", None)
            title = panel["title"]
            ylabel = panel["ylabel"]
            mesa_label = panel.get("mesa_label", "MESA")
            phl_label = panel.get("phl_label", "Phlegethon from RK4")
            plot_every = panel.get("plot_every", None)
            ylim = panel.get("ylim", None)
            yscale = panel.get("yscale", None)

            if self._has_finite_values(y_mesa):
                ax.plot(x_mesa / self.r_sol, y_mesa, label=mesa_label, linewidth=2.5, color=self.palette["blue"])
            if plot_every is not None and self._has_finite_values(y_mesa):
                ax.plot(
                    x_mesa[::plot_every] / self.r_sol,
                    y_mesa[::plot_every],
                    linestyle="None",
                    marker="|",
                    markersize=4,
                    markerfacecolor=self.palette["blue"],
                    markeredgecolor=self.palette["blue"],
                )

            if x_phl is not None and y_phl is not None and self._has_finite_values(y_phl):
                ax.plot(x_phl / self.r_sol, y_phl, label=phl_label, linewidth=1.5, color=self.palette["red"])
                if plot_every is not None:
                    ax.plot(
                        x_phl[::plot_every] / self.r_sol,
                        y_phl[::plot_every],
                        linestyle="None",
                        marker="|",
                        markersize=4,
                        markerfacecolor=self.palette["red"],
                        markeredgecolor=self.palette["red"],
                    )

            self._style_axis(ax, title=title, ylabel=ylabel)

            if xlim is None:
                xlim_local = self._default_xlim()
            else:
                xlim_local = xlim
            if xlim_local is not None:
                ax.set_xlim(*xlim_local)

            if yscale is not None:
                ax.set_yscale(yscale)
            if ylim is not None:
                ax.set_ylim(*ylim)

            self._draw_boundaries(ax)
            if show_legends:
                self._add_legend(ax)

        for j in range(n_panels, len(axs)):
            axs[j].axis("off")

        plt.tight_layout()
        return fig, axs

    # Split linear/log panel generation ---------------------------------------
    @staticmethod
    def _panel_pair(base_panel):
        """Create linear and log/symlog variants of one panel definition."""
        p_lin = dict(base_panel)
        p_log = dict(base_panel)

        p_lin["title"] = f"{base_panel['title']} (linear)"
        p_lin["yscale"] = None

        y_for_scale = [np.asarray(base_panel["y_mesa"], dtype=float)]
        if "y_phl" in base_panel and base_panel["y_phl"] is not None:
            y_for_scale.append(np.asarray(base_panel["y_phl"], dtype=float))

        finite_parts = [y[np.isfinite(y)] for y in y_for_scale if y.size > 0]
        y_all = np.concatenate(finite_parts) if finite_parts else np.array([])

        if y_all.size > 0 and np.any(y_all <= 0.0):
            p_log["yscale"] = "symlog"
            p_log["title"] = f"{base_panel['title']} (symlog)"
        else:
            p_log["yscale"] = "log"
            p_log["title"] = f"{base_panel['title']} (log)"

        # Drop linear y-limits for scaled panel.
        p_log.pop("ylim", None)
        return [p_lin, p_log]

    # Split-figure orchestration ----------------------------------------------
    def build_split_scale_panels(self, base_panels, primary_keys, figure1_scale_mode="split"):
        """Split base panel definitions into Figure 1 and Figure 2 panel sets.

        Figure 1 panels are selected by ``primary_keys`` and rendered according to
        ``figure1_scale_mode``:
        - ``split``: include both linear and log/symlog variants.
        - ``linear``: include only linear variants.
        - ``log``: include only log/symlog variants.

        Figure 2 panels always include both linear and log/symlog variants.
        """
        primary_panels = []
        secondary_panels = []
        primary_set = set(primary_keys)
        mode = str(figure1_scale_mode).strip().lower()
        valid_modes = {"split", "linear", "log"}
        if mode not in valid_modes:
            raise ValueError(
                f"Invalid figure1_scale_mode={figure1_scale_mode!r}. "
                "Expected one of: 'split', 'linear', 'log'."
            )

        for bp in base_panels:
            pair = self._panel_pair(bp)
            if bp.get("key") in primary_set:
                if mode == "split":
                    primary_panels.extend(pair)
                elif mode == "linear":
                    primary_panels.append(pair[0])
                else:  # mode == "log"
                    primary_panels.append(pair[1])
            else:
                secondary_panels.extend(pair)

        return primary_panels, secondary_panels

    def plot_visual_check_split_figures(
        self,
        base_panels,
        primary_keys,
        figure1_scale_mode="split",
        ncols=2,
        primary_figsize=(10, 21),
        secondary_figsize=(10, 36),
        show_primary_legends=True,
        show_secondary_legends=True,
    ):
        """Render two visual-check figures from base panel definitions.

        Figure 1 uses variables listed in ``primary_keys`` and follows
        ``figure1_scale_mode``:
        - ``split``: linear + log/symlog variants,
        - ``linear``: linear only,
        - ``log``: log/symlog only.

        Figure 2 contains all remaining variables and always uses split
        linear + log/symlog variants.
        """
        primary_panels, secondary_panels = self.build_split_scale_panels(
            base_panels,
            primary_keys,
            figure1_scale_mode=figure1_scale_mode,
        )

        fig_primary, axs_primary = self.plot_visual_check_multiplot(
            primary_panels,
            ncols=ncols,
            figsize=primary_figsize,
            show_legends=show_primary_legends,
        )

        fig_secondary, axs_secondary = self.plot_visual_check_multiplot(
            secondary_panels,
            ncols=ncols,
            figsize=secondary_figsize,
            show_legends=show_secondary_legends,
        )

        return (fig_primary, axs_primary), (fig_secondary, axs_secondary)


# -----------------------------------------------------------------------------
# Module-Level Convenience API
# -----------------------------------------------------------------------------
# Includes:
# - a shared default `HSEIntegrator` instance,
# - thin module-level wrappers around integration/EOS utilities,
# - static-helper aliases for direct notebook usage without class plumbing.
_default_integrator = HSEIntegrator()


# Basic aliases to static helpers ---------------------------------------------
def grid2grid(r_array, q_array, rmin, rmax, Nr):
    """Module-level alias for `HSEIntegrator.grid2grid`."""
    return HSEIntegrator.grid2grid(r_array, q_array, rmin, rmax, Nr)


def Hp(p, gradp):
    """Module-level alias for pressure scale height calculation."""
    return HSEIntegrator.pressure_scale_height(p, gradp)


# Integration and EOS wrappers ------------------------------------------------
def integration_rk4(*args, **kwargs):
    """Module-level convenience wrapper for RK4 integration (uniform composition)."""
    return _default_integrator.integration_rk4(*args, **kwargs)


def integration_rk4_compgrad(*args, **kwargs):
    """Module-level convenience wrapper for RK4 integration with composition gradients."""
    return _default_integrator.integration_rk4_compgrad(*args, **kwargs)


def integration_tgiven(*args, **kwargs):
    """Module-level wrapper for integration with prescribed temperature profile."""
    return _default_integrator.integration_tgiven(*args, **kwargs)


def smooth_profile(*args, **kwargs):
    """Module-level wrapper for profile smoothing utility."""
    return HSEIntegrator.smooth_profile(*args, **kwargs)


def prepare_for_integration(*args, **kwargs):
    """Module-level wrapper to prepare profiles and initial conditions for integration."""
    return _default_integrator.prepare_for_integration(*args, **kwargs)


def hse_integrate(*args, **kwargs):
    """Module-level wrapper that dispatches to the selected integration routine."""
    return _default_integrator.hse_integrate(*args, **kwargs)


def g_potential(*args, **kwargs):
    """Module-level wrapper for gravitational potential calculation."""
    return HSEIntegrator.g_potential(*args, **kwargs)


# -----------------------------------------------------------------------------
# EOS Profile Accessor Utilities
# -----------------------------------------------------------------------------
# Includes:
# - `make_eos_profile_ufunc`: field accessor generator from Helmholtz EOS output,
# - `compute_eos_profiles`: bulk dictionary builder for multiple EOS fields.
def make_eos_profile_ufunc(field: str, eos_mode=None, dtype=None, eos_table=None):
    """Return a vectorized Helmholtz-EOS accessor for a thermodynamic field.

    The returned callable expects ``(rho, temp, abar, zbar)`` and returns
    ``full[field]`` from ``phleos.eos_rhoTgiven``.

    Parameters
    ----------
    dtype : optional
        If provided, cast outputs to this dtype.
    """

    if eos_table is None:
        eos_table = _default_integrator.eos_table
    if eos_table is None:
        raise ValueError("eos_table is required for compute_eos_profiles/make_eos_profile_ufunc")

    field_map = {
        "P": phleos.id_P,
        "e": phleos.id_E,
        "dpdrho": phleos.id_dPdrho,
        "dpdt": phleos.id_dPdT,
        "dEdrho": phleos.id_dEdrho,
        "dEdT": phleos.id_dEdT,
        "cv": phleos.id_cv,
        "chiT": phleos.id_chiT,
        "chirho": phleos.id_chirho,
        "gamma_1": phleos.id_gam1,
        "sound": phleos.id_sound,
        "cp": phleos.id_cp,
        "gamma_2": phleos.id_gam2,
        "gamma_3": phleos.id_gam3,
        "nabla_ad": phleos.id_nabla_ad,
        "s": phleos.id_s,
        "dsdrho": phleos.id_dsdrho,
        "dsdt": phleos.id_dsdT,
        "delta": phleos.id_delta,
        "eta": phleos.id_eta,
        "nep": phleos.id_nep,
        "phi": phleos.id_phi,
        "dPdA": phleos.id_dPdA,
    }
    field_idx = field_map[field] if isinstance(field, str) else int(field)

    raw = np.frompyfunc(
        lambda rho_, temp_, abar_, zbar_: phleos.rhoT_given(
            eos_table, rho_, temp_, abar_, zbar_, eos_mode=eos_mode
        )[field_idx],
        4,
        1,
    )

    if dtype is None:
        return raw

    def typed(rho_, temp_, abar_, zbar_):
        return np.asarray(raw(rho_, temp_, abar_, zbar_), dtype=dtype)

    return typed


def compute_eos_profiles(rho, temp, abar, zbar, fields, eos_mode=None, dtype=None, eos_table=None):
    """Compute a dictionary of EOS fields for given profile inputs.

    Parameters
    ----------
    rho, temp, abar, zbar
        Scalars or arrays broadcastable under ``numpy.frompyfunc`` usage.
    fields : iterable[str]
        Keys available in the Helmholtz EOS ``full`` dictionary.
    eos_mode : optional
        EOS mode forwarded to ``phleos.eos_rhoTgiven``.
    dtype : optional
        If provided, cast all field arrays to this dtype.
    """

    return {
        field: make_eos_profile_ufunc(field, eos_mode=eos_mode, dtype=dtype, eos_table=eos_table)(rho, temp, abar, zbar)
        for field in fields
    }
