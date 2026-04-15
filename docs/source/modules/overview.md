(phlegethon-overview)=
# Phlegethon Overview

## Key numerical methods:

- Second-order, time-explicit finite-volume scheme
- Low-dissipation Riemann solvers and well-balanced methods
- Shock-capturing schemes for supersonic flows
- Constrained transport for divergence-free magnetic field evolution
- Time-implicit nuclear reaction networks
- Super-time-stepping for stiff thermal diffusion
- BiCGSTAB full gravity solver
- Realistic equations of state for stellar plasma (including partial ionization, electron degeneracy, and pair production)
- Multiple grid geometries: Cartesian, polar, spherical, cubed-sphere

## Documentation

Documentation can be consulted [here](https://phlegethon-stellar-hydro.github.io/phlegethon/)

## Authors

**PHLEGETHON** was originally written by Giovanni Leidi and is continuously under active development. Current support is provided by:

- Giovanni Leidi
- Alexander Holas
- Kristian Vitovsky
- Federico Rizzuti
- Jonas Reichert
- Korinna Bayer

## Citation

If you use **PHLEGETHON** in your work, please cite it using the following BibTeX entry for its [associated method paper](https://arxiv.org/abs/2604.12672):
```bibtex
@misc{leidi2026phlegethon,
      title={Phlegethon: a fully compressible magnetohydrodynamic code for simulations in stellar astrophysics}, 
      author={G. Leidi and A. Holas and K. Vitovsky and F. Rizzuti and A. Roy and J. Reichert and K. Bayer and D. Gagnier and R. Andrassy and P. Christians and P. V. F. Edelmann and V. Varma and R. Hirschi and F. K. Röpke},
      year={2026},
      eprint={2604.12672},
      archivePrefix={arXiv},
      primaryClass={astro-ph.SR},
      url={https://arxiv.org/abs/2604.12672}, 
}
```

For reproducibility, please also cite the exact code version used, available on Zenodo. The latest version is:

```bibtex
@software{leidi_2026_19554676,
  author       = {Leidi, Giovanni and
                  Holas, Alexander and
                  Vitovsky, Kristian and
                  Rizzuti, Federico and
                  Roy, Arkaprabha and
                  Reichert, Jonas and
                  Bayer, Korinna and
                  Gagnier, Damien and
                  Andrassy, Robert and
                  Christians, Paul and
                  Edelmann, Philipp and
                  Varma, Vishnu and
                  Hirschi, Raphael and
                  Röpke, Friedrich},
  title        = {Phlegethon},
  month        = apr,
  year         = 2026,
  publisher    = {Zenodo},
  version      = {v2026.4.1},
  doi          = {10.5281/zenodo.19554676},
  url          = {https://doi.org/10.5281/zenodo.19554676},
}
```

## License

**PHLEGETHON** is released under the [AGPL-3.0 license](https://www.gnu.org/licenses/agpl-3.0.html)
