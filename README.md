# Bio3DView.jl

[![Build Status](https://travis-ci.org/jgreener64/Bio3DView.jl.svg?branch=master)](https://travis-ci.org/jgreener64/Bio3DView.jl)

[![Coverage Status](https://coveralls.io/repos/jgreener64/Bio3DView.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/jgreener64/Bio3DView.jl?branch=master)

[![codecov.io](http://codecov.io/github/jgreener64/Bio3DView.jl/coverage.svg?branch=master)](http://codecov.io/github/jgreener64/Bio3DView.jl?branch=master)

Bio3DView provides an interface to explore macromolecular 3D structures in [Jupyter](http://jupyter.org) notebooks.
It uses PyCall to call py3Dmol, a Python package that uses 3Dmol.js to render structures in the notebook.

This project is work in progress.
Contributions and bug reports are welcome.

## Installation

Julia v0.6 is required. Install Bio3DView from the Julia REPL:

```julia
julia> Pkg.add("Bio3DView")
```

py3Dmol also needs to be available on the Python path which PyCall sees.
By default this will be the `python` available on the path for Linux systems and a Python installation local to Julia for Windows/Mac - see the discussion at [PyCall](https://github.com/JuliaPy/PyCall.jl#installation).
For example, to install py3Dmol at the `python` available on the path run:

```bash
pip install py3Dmol
```

## Usage

See `examples/tutorial.ipynb` for a tutorial notebook.
