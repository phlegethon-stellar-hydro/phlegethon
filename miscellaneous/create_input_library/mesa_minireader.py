import warnings
from dataclasses import dataclass
import re
import numpy as np

# -----------------------------------------------------------------------------
# Module Overview
# -----------------------------------------------------------------------------
# This module provides:
# - lightweight MESA profile parsing,
# - alias-based field resolution,
# - canonical unit/log/sign transforms,
# - optional isotope abundance extraction,
# - abundance-transition helpers for custom composition workflows.

# -----------------------------------------------------------------------------
# Constants (CGS)
# -----------------------------------------------------------------------------
R_SOL = 6.957e10
M_SOL = 1.9891e33
L_SOL = 3.846e33
G_CGS = 6.67428e-8

# -----------------------------------------------------------------------------
# Isotope Token Parsing
# -----------------------------------------------------------------------------
ISOTOPE_RE = re.compile(r"^[A-Za-z]+[0-9]+$")
ISOTOPE_TOKEN_RE = re.compile(r"^([A-Za-z]+)([0-9]+)$")

ELEMENT_Z = {
    "h": 1,
    "he": 2,
    "li": 3,
    "be": 4,
    "b": 5,
    "c": 6,
    "n": 7,
    "o": 8,
    "f": 9,
    "ne": 10,
    "na": 11,
    "mg": 12,
    "al": 13,
    "si": 14,
    "p": 15,
    "s": 16,
    "cl": 17,
    "ar": 18,
    "k": 19,
    "ca": 20,
    "sc": 21,
    "ti": 22,
    "v": 23,
    "cr": 24,
    "mn": 25,
    "fe": 26,
    "co": 27,
    "ni": 28,
}

# -----------------------------------------------------------------------------
# Canonical Field Aliases
# -----------------------------------------------------------------------------
DEFAULT_ALIASES = {
    "r": ["rmid", "r", "radius"],
    "rho": ["logRho", "rho"],
    "grav": ["grav", "gravity"],
    "Abar": ["abar", "Abar"],
    "Ye": ["ye", "Ye"],
    "Zbar": ["zbar", "Zbar"],
    "P": ["logP", "P", "pressure"],
    "T": ["logT", "T", "temperature"],
    "kappa": ["log_opacity", "kappa", "opacity"],
    "gradT_sub_grada": ["gradT_sub_grada", "superad", "nabla_diff"],
    "s": ["entropy", "s"],
    "gamma1": ["gamma1", "Gamma1"],
    "gamma3": ["gamma3", "Gamma3"],
    "cp": ["cp"],
    "cv": ["cv"],
    "energy": ["energy", "e"],
    "chiRho": ["chiRho", "chi_rho"],
    "nabla_ad": ["nabla_ad"],
    "conv_vel": ["conv_vel", "v_conv"],
    "Mach": ["Mach", "mach"],
    "sound": ["csound", "sound"],
    "luminosity": ["luminosity", "L", "log_L"],
    "eps_nuc": ["eps_nuc", "enuc"],
}

# -----------------------------------------------------------------------------
# Structured Return Object
# -----------------------------------------------------------------------------
@dataclass
class MesaProfileData:
    """Container returned by `load_mesa_profile`."""

    meta: dict
    columns: list
    raw: dict
    data: dict
    resolved: dict
    abundances: dict

    def __getitem__(self, key):
        return self.data[key]

    def get(self, key, default=None):
        return self.data.get(key, default)


# -----------------------------------------------------------------------------
# File Parsing Helpers
# -----------------------------------------------------------------------------
def _parse_profile_file(filename, reverse_radius_order=True):
    """Parse one MESA profile file into metadata, columns, and raw arrays."""
    with open(filename, "r", encoding="utf-8") as f:
        f.readline()  # column numbers
        labels = f.readline().split()
        values = f.readline().split()

        meta = {}
        for k, v in zip(labels, values):
            if v.startswith('"'):
                meta[k] = v.strip('"')
            else:
                try:
                    meta[k] = int(v)
                except ValueError:
                    meta[k] = float(v)

        f.readline()
        f.readline()
        columns = f.readline().split()
        table = np.loadtxt(f)

    if table.ndim == 1:
        table = table[None, :]

    raw = {}
    for i, name in enumerate(columns):
        col = table[:, i]
        if reverse_radius_order:
            col = col[::-1]
        raw[name] = col

    return meta, columns, raw


# -----------------------------------------------------------------------------
# Field Resolution and Transformation
# -----------------------------------------------------------------------------
def _candidate_names(name, aliases):
    """Build de-duplicated candidate source names for one requested field."""
    candidates = []
    if name in aliases:
        candidates.extend(aliases[name])
    if name in DEFAULT_ALIASES:
        candidates.extend(DEFAULT_ALIASES[name])
    candidates.append(name)

    unique = []
    seen = set()
    for cand in candidates:
        if cand not in seen:
            unique.append(cand)
            seen.add(cand)
    return unique


def _resolve_source_name(name, raw, aliases):
    """Return first matching source name in `raw`, else `None`."""
    for cand in _candidate_names(name, aliases):
        if cand in raw:
            return cand
    return None


def _transform_value(requested_name, source_name, arr, raw):
    """Apply canonical transforms (units/sign/log) for one resolved source."""
    val = np.asarray(arr, dtype=float)

    if requested_name == "r" and source_name == "rmid":
        return val * R_SOL

    if requested_name == "P" and source_name == "logP":
        return 10.0 ** val

    if requested_name == "rho" and source_name == "logRho":
        return 10.0 ** val

    if requested_name == "T" and source_name == "logT":
        return 10.0 ** val

    if requested_name == "kappa" and source_name == "log_opacity":
        return 10.0 ** val

    if requested_name == "luminosity":
        if source_name == "log_L":
            return (10.0 ** val) * L_SOL
        return val * L_SOL

    if requested_name == "Abar" and source_name == "abar":
        return val

    if requested_name == "Ye" and source_name == "ye":
        return val

    if requested_name == "Zbar":
        if source_name in ("Zbar", "zbar"):
            return val
        if "abar" in raw and "ye" in raw:
            return np.asarray(raw["abar"], dtype=float) * np.asarray(raw["ye"], dtype=float)

    if requested_name == "grav":
        if source_name == "grav":
            return -val
        if source_name == "gravity":
            return val
        # Fallback if mass + radius are available.
        m_src = "mass" if "mass" in raw else ("m" if "m" in raw else None)
        r_src = "rmid" if "rmid" in raw else ("r" if "r" in raw else None)
        if m_src is not None and r_src is not None:
            m = np.asarray(raw[m_src], dtype=float) * M_SOL
            r = np.asarray(raw[r_src], dtype=float)
            if r_src == "rmid":
                r = r * R_SOL
            r = np.maximum(r, 1e-99)
            return -G_CGS * m / (r ** 2)

    return val


def _handle_missing(name, missing_policy):
    """Apply missing-field policy (`ignore`, `warn`, or `error`)."""
    msg = f"Requested MESA profile not found: {name}"
    if missing_policy == "error":
        raise KeyError(msg)
    if missing_policy == "warn":
        warnings.warn(msg)


# -----------------------------------------------------------------------------
# Abundance Extraction Helpers
# -----------------------------------------------------------------------------
def _collect_abundances(raw, abundance_mode, abundance_names, aliases, missing_policy):
    """Collect isotope abundances according to `abundance_mode`."""
    abundances = {}

    if abundance_mode == "none":
        return abundances

    if abundance_mode == "auto":
        for key, val in raw.items():
            if ISOTOPE_RE.match(key):
                abundances[key] = np.asarray(val, dtype=float)
        return abundances

    if abundance_mode == "list":
        abundance_names = [] if abundance_names is None else list(abundance_names)
        for name in abundance_names:
            src = _resolve_source_name(name, raw, aliases)
            if src is None:
                _handle_missing(name, missing_policy)
                continue
            abundances[name] = np.asarray(raw[src], dtype=float)
        return abundances

    raise ValueError(f"Unknown abundance_mode: {abundance_mode}")


def _species_az(species_name):
    """Parse isotope token and return mass number A and atomic number Z."""
    name = str(species_name).strip().lower()

    if name in ("prot", "p"):
        return 1.0, 1.0
    if name in ("neut", "n"):
        return 1.0, 0.0

    m = ISOTOPE_TOKEN_RE.match(name)
    if m is None:
        raise ValueError(f"Cannot parse isotope name '{species_name}'")

    elem, mass_s = m.group(1).lower(), m.group(2)
    if elem not in ELEMENT_Z:
        raise ValueError(f"Unknown element symbol in isotope name '{species_name}'")

    a = float(int(mass_s))
    z = float(ELEMENT_Z[elem])
    return a, z


# -----------------------------------------------------------------------------
# Abundance Transition Utility
# -----------------------------------------------------------------------------
# Includes:
# - selected-species abundance assembly,
# - closure-species rebalance to enforce sum(X)=1,
# - derived composition moments (`Abar`, `Zbar`, `Ye`).
def prepare_abundance_transition(
    profile,
    species_names,
    closure_species,
    missing_fill=0.0,
):
    """Build selected abundance set and derive consistent Abar/Zbar/Ye profiles.

    Parameters
    ----------
    profile : MesaProfileData
        Output of ``load_mesa_profile``.
    species_names : sequence[str]
        Species requested for final model composition.
    closure_species : str
        Species to adjust so total abundance sum is restored to unity.
    missing_fill : float
        Value for species absent from the MESA profile.
    """
    if not isinstance(profile, MesaProfileData):
        raise TypeError("profile must be MesaProfileData")

    species = [str(s).strip() for s in species_names]
    if len(species) == 0:
        raise ValueError("species_names cannot be empty")

    if closure_species not in species:
        raise ValueError("closure_species must be present in species_names")

    radius = profile.data.get("r", None)
    if radius is None:
        if len(profile.raw) == 0:
            raise ValueError("profile has no raw columns")
        any_key = next(iter(profile.raw))
        size = np.asarray(profile.raw[any_key], dtype=float).size
    else:
        size = np.asarray(radius, dtype=float).size

    abund = {}
    present = []
    missing = []
    for sp in species:
        if sp in profile.abundances:
            arr = np.asarray(profile.abundances[sp], dtype=float)
            present.append(sp)
        else:
            arr = np.full(size, float(missing_fill), dtype=float)
            missing.append(sp)
        abund[sp] = arr

    xsum_before = np.zeros(size, dtype=float)
    for sp in species:
        xsum_before = xsum_before + abund[sp]

    closure_delta = 1.0 - xsum_before
    abund[closure_species] = abund[closure_species] + closure_delta

    xsum_after = np.zeros(size, dtype=float)
    for sp in species:
        xsum_after = xsum_after + abund[sp]

    inv_abar = np.zeros(size, dtype=float)
    ye = np.zeros(size, dtype=float)
    species_az = {}
    for sp in species:
        a, z = _species_az(sp)
        species_az[sp] = (a, z)
        inv_abar = inv_abar + abund[sp] / a
        ye = ye + abund[sp] * (z / a)

    inv_abar = np.maximum(inv_abar, 1e-99)
    abar = 1.0 / inv_abar
    zbar = abar * ye

    return {
        "species": list(species),
        "abundances": abund,
        "present_species": present,
        "missing_species": missing,
        "closure_species": closure_species,
        "closure_delta": closure_delta,
        "sum_before": xsum_before,
        "sum_after": xsum_after,
        "Abar": abar,
        "Zbar": zbar,
        "Ye": ye,
        "species_az": species_az,
    }


# -----------------------------------------------------------------------------
# Public API
# -----------------------------------------------------------------------------
def load_mesa_profile(
    filename,
    profile_names,
    aliases=None,
    missing_policy="warn",
    reverse_radius_order=True,
    abundance_mode="none",
    abundance_names=None,
):
    """Load selected MESA profile fields with transforms and optional abundances."""
    aliases = {} if aliases is None else dict(aliases)

    if missing_policy not in ("ignore", "warn", "error"):
        raise ValueError(f"Unknown missing_policy: {missing_policy}")

    meta, columns, raw = _parse_profile_file(filename, reverse_radius_order=reverse_radius_order)

    data = {}
    resolved = {}

    for requested_name in profile_names:
        src = _resolve_source_name(requested_name, raw, aliases)
        if src is None:
            _handle_missing(requested_name, missing_policy)
            continue

        transformed = _transform_value(requested_name, src, raw[src], raw)
        data[requested_name] = transformed
        resolved[requested_name] = src

    # Derived quantities if requested but unresolved.
    if "Zbar" in profile_names and "Zbar" not in data and "Abar" in data and "Ye" in data:
        data["Zbar"] = np.asarray(data["Abar"], dtype=float) * np.asarray(data["Ye"], dtype=float)
        resolved["Zbar"] = "Abar*Ye"

    if "grav" in profile_names and "grav" not in data:
        if "mass" in raw and "rmid" in raw:
            m = np.asarray(raw["mass"], dtype=float) * M_SOL
            r = np.maximum(np.asarray(raw["rmid"], dtype=float) * R_SOL, 1e-99)
            data["grav"] = -G_CGS * m / (r ** 2)
            resolved["grav"] = "derived(mass,rmid)"

    abundances = _collect_abundances(
        raw,
        abundance_mode=abundance_mode,
        abundance_names=abundance_names,
        aliases=aliases,
        missing_policy=missing_policy,
    )

    return MesaProfileData(
        meta=meta,
        columns=list(columns),
        raw=raw,
        data=data,
        resolved=resolved,
        abundances=abundances,
    )
