# Bio3DView.jl

[![Build Status](https://travis-ci.org/jgreener64/Bio3DView.jl.svg?branch=master)](https://travis-ci.org/jgreener64/Bio3DView.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/l2gep9mdvcnhsc4p/branch/master?svg=true)](https://ci.appveyor.com/project/jgreener64/bio3dview-jl/branch/master)
[![codecov.io](http://codecov.io/github/jgreener64/Bio3DView.jl/coverage.svg?branch=master)](http://codecov.io/github/jgreener64/Bio3DView.jl?branch=master)

Bio3DView.jl provides a viewer for molecular structures in [Julia](https://julialang.org).
It is a wrapper round the excellent [3Dmol.js](http://3dmol.csb.pitt.edu) package [1].
When used from the REPL or a file, the viewer shows in a popup using [Blink.jl](https://github.com/JunoLab/Blink.jl).
When used from [IJulia](https://github.com/JuliaLang/IJulia.jl) running in a [Jupyter](http://jupyter.org) notebook or JupyterLab, the viewer shows in the output cell.

[1] Nicholas Rego and David Koes,
3Dmol.js: molecular visualization with WebGL,
Bioinformatics (2015) 31(8): 1322-1324 - [link](http://doi.org/10.1093/bioinformatics/btu829)

Contributions and bug reports are welcome.

## Installation

Julia v0.7 or later is required.
Install Bio3DView from the package mode of the Julia REPL (press `]`):

```julia
add https://github.com/jgreener64/Bio3DView.jl#master
```

You may need to run `using Blink; Blink.AtomShell.install()` if you have not set up Blink.jl before.
If you want to use Bio3DView.jl with Jupyter (optional), [IJulia](https://github.com/JuliaLang/IJulia.jl) also needs to be installed.

## Usage

See the [tutorial notebook](http://nbviewer.jupyter.org/github/jgreener64/Bio3DView.jl/blob/master/examples/tutorial.ipynb).
