# Bio3DView.jl

[![Build Status](https://travis-ci.org/jgreener64/Bio3DView.jl.svg?branch=master)](https://travis-ci.org/jgreener64/Bio3DView.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/l2gep9mdvcnhsc4p/branch/master?svg=true)](https://ci.appveyor.com/project/jgreener64/bio3dview-jl/branch/master)
[![codecov.io](http://codecov.io/github/jgreener64/Bio3DView.jl/coverage.svg?branch=master)](http://codecov.io/github/jgreener64/Bio3DView.jl?branch=master)

Bio3DView.jl provides a viewer for macromolecular 3D structures in [Julia](https://julialang.org).
It is a wrapper round the excellent [3Dmol.js](http://3dmol.csb.pitt.edu) package [1].
When used from the REPL or a file, the viewer shows in a popup using [Blink.jl](https://github.com/JunoLab/Blink.jl).
When used from [IJulia](https://github.com/JuliaLang/IJulia.jl) running in a [Jupyter](http://jupyter.org) notebook, the viewer shows in the output cell.

[1] Nicholas Rego and David Koes,
3Dmol.js: molecular visualization with WebGL,
Bioinformatics (2015) 31(8): 1322-1324 - [link](http://doi.org/10.1093/bioinformatics/btu829)

This project is in development.
Current status: partly working.
Contributions and bug reports are welcome.

## Installation

Julia v0.6 is required.
Install Bio3DView from the Julia REPL:

```julia
julia> Pkg.clone("https://github.com/jgreener64/Bio3DView.jl.git")
```

You may need to run `using Blink; Blink.AtomShell.install()` if you have not set up Blink.jl before.
If you want to use Bio3DView.jl in a notebook (optional), [IJulia](https://github.com/JuliaLang/IJulia.jl) also needs to be installed.

## Usage

See the [tutorial notebook](http://nbviewer.jupyter.org/github/jgreener64/Bio3DView.jl/blob/master/examples/tutorial.ipynb).
This is out of date and will be updated.
