# Bio3DView.jl

[![Build Status](https://travis-ci.org/jgreener64/Bio3DView.jl.svg?branch=master)](https://travis-ci.org/jgreener64/Bio3DView.jl)
[![codecov.io](http://codecov.io/github/jgreener64/Bio3DView.jl/coverage.svg?branch=master)](http://codecov.io/github/jgreener64/Bio3DView.jl?branch=master)

Bio3DView provides an interface to explore macromolecular 3D structures using [Julia](https://julialang.org) in [Jupyter](http://jupyter.org) notebooks.
It uses [PyCall](https://github.com/JuliaPy/PyCall.jl) to call [py3Dmol](https://pypi.python.org/pypi/py3Dmol), a Python package that uses [3Dmol.js](http://3dmol.csb.pitt.edu) [1] to render structures in the notebook.

[1] Nicholas Rego and David Koes,
3Dmol.js: molecular visualization with WebGL,
Bioinformatics (2015) 31(8): 1322-1324 - [link](http://doi.org/10.1093/bioinformatics/btu829)

This project is work in progress.
Contributions and bug reports are welcome.

## Installation

Julia v0.6 is required.
To use Julia in the Jupyter notebook, [IJulia](https://github.com/JuliaLang/IJulia.jl) also needs to be installed.
Install Bio3DView from the Julia REPL:

```julia
julia> Pkg.add("Bio3DView")
```

`py3Dmol` also needs to be available on the Python path which PyCall sees.
By default this will be the `python` available on the path for Linux systems and a Python installation local to Julia for Windows/Mac - see the [discussion](https://github.com/JuliaPy/PyCall.jl#installation) at PyCall.
For example, to install `py3Dmol` at the `python` available on the path run:

```bash
pip install py3Dmol
```

## Usage

See the [tutorial notebook](http://nbviewer.jupyter.org/github/jgreener64/Bio3DView.jl/blob/master/examples/tutorial.ipynb).
