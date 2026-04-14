(troubleshooting)=
# Troubleshooting FAQ

This page collects common setup, build, and runtime issues together with practical fixes.

If your issue is not listed yet, please open an issue or submit a documentation update so this FAQ can grow over time.

## How to use this page

- Search for your error message text first.
- Follow steps in order.
- Re-run the failing command after each change.
- Add new solved issues here in the same FAQ format.

## FAQ

### Q: `f2py` fails while compiling `miscellaneous/eos/eos.f90`.

A: Ensure required Python build tools are installed and available in the active environment.

1. Install required tools in the active environment:

```bash
mamba install numpy meson ninja
```

2. Re-run compilation:

```bash
cd miscellaneous/eos/
f2py -c eos.f90 -m eos_fort --opt='-O3'
```

3. Verify the module import:

```bash
python -c 'import eos_fort; print(eos_fort.__file__)'
```

### Q: Build fails because MPI or HDF5 cannot be found.

A: Check system dependencies and local build configuration.

1. Install required system packages (MPI and parallel HDF5).
2. If auto-detection fails, create/update a machine file in `Make.local/`.
3. Point `Makefile.config` to the selected file via the `include` line.
4. Run `make clean` and rebuild.

See {ref}`getting_started` for setup details and `Make.local/README.md` for machine-specific examples.

### Q: Python post-processing cannot import project modules.

A: Verify environment variables and active environment.

1. Ensure your environment is activated.
2. Confirm `PYTHONPATH` includes:
   - `<path-to-phlegethon>/python/`
   - `<path-to-phlegethon>/miscellaneous/eos/`
3. Confirm `PHLEGETHONDATA` points to `<path-to-phlegethon>/data/` (the trailing '/' is important).
4. Re-open the shell or re-source your shell rc file.

## Add a new FAQ entry

Use this template when adding new entries:

```md
### Q: <short issue description>

A: <short diagnosis>

1. <step one>
2. <step two>
3. <step three>
```
