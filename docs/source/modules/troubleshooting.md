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
3. Update the `INCLUDE`, `LIBS`, and `RPATH` environment variables based on the output of `h5pcc -show`, e.g.,
   
   ```bash
   INCLUDE = -I/usr/lib/x86_64-linux-gnu/hdf5/openmpi/include
   LIBS = -L/usr/lib/x86_64-linux-gnu/hdf5/openmpi/lib
   RPATH = -Wl,-rpath=/usr/lib/x86_64-linux-gnu/hdf5/openmpi/lib
   ```
5. Point `Makefile.config` to the selected file via the `include` line.
6. Run `make clean` and rebuild.

See {ref}`getting_started` for setup details and `Make.local/README.md` for machine-specific examples.

### Q: macOS process is killed immediately

A: If Phlegethon is started from an application that is not enabled in macOS developer settings, macOS may terminate it immediately (signal 9) without a stack trace.

Typical symptoms include:

Serial run:

```bash
[1]    23301 killed     ./run.app
```

Parallel run:

```text
--------------------------------------------------------------------------
prterun noticed that process rank 1 with PID 23314 on node your-machine exited on
signal 9 (Killed: 9).
--------------------------------------------------------------------------
```

Fix:

1. Open `System Settings` -> `Privacy & Security` -> `Developer Tools`.
2. Enable the application you use to launch Phlegethon (for example `Terminal`, `iTerm`, or `VS Code`).
3. Fully quit and reopen that application.
4. Re-run `./run.app` or `mpirun -n <N> ./run.app`.

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
