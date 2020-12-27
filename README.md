# Bio3DView.jl

[![Build status](https://github.com/jgreener64/Bio3DView.jl/workflows/CI/badge.svg)](https://github.com/jgreener64/Bio3DView.jl/actions)
[![codecov](https://codecov.io/gh/jgreener64/Bio3DView.jl/branch/master/graph/badge.svg?token=SDiIEXLZQV)](https://codecov.io/gh/jgreener64/Bio3DView.jl)

Bio3DView.jl provides a viewer for molecular structures in [Julia](https://julialang.org).
It is a wrapper round the excellent [3Dmol.js](http://3dmol.csb.pitt.edu) package [1].
When used from the REPL or a file, the viewer shows in a popup using [Blink.jl](https://github.com/JunoLab/Blink.jl).
When used from [IJulia](https://github.com/JuliaLang/IJulia.jl) running in a [Jupyter](http://jupyter.org) notebook or JupyterLab, or from [Pluto.jl](https://github.com/fonsp/Pluto.jl), the viewer shows in the output cell.
You can also use Bio3DView.jl to generate standalone HTML, e.g. for use in a web page.

[1] Nicholas Rego and David Koes,
3Dmol.js: molecular visualization with WebGL,
Bioinformatics (2015) 31(8): 1322-1324 - [link](http://doi.org/10.1093/bioinformatics/btu829)

Contributions and bug reports are welcome.

## Installation

Julia v1.0 or later is required.
Install Bio3DView from the package mode of the Julia REPL (press `]`):

```
add Bio3DView
```

Bio3DView uses [Requires.jl](https://github.com/MikeInnes/Requires.jl) to minimise dependencies so you will also need to install either Blink, IJulia or Pluto to make this package useful, though you can generate HTML without them.
If you are using Blink, you will need to run `using Blink` before the Bio3DView functions work.
To view structural objects from [BioStructures.jl](https://github.com/BioJulia/BioStructures.jl) you will need to have BioStructures.jl installed.

## Usage

See the [tutorial notebook](http://nbviewer.jupyter.org/github/jgreener64/Bio3DView.jl/blob/master/examples/tutorial.ipynb).

## Citation

If you use Bio3DView, please cite the BioStructures paper where it is mentioned:

Greener JG, Selvaraj J and Ward BJ. BioStructures.jl: read, write and manipulate macromolecular structures in Julia, *Bioinformatics* 36(14):4206-4207 (2020) - [link](https://academic.oup.com/bioinformatics/advance-article/doi/10.1093/bioinformatics/btaa502/5837108?guestAccessKey=aec90643-1d43-4521-9883-4a4a669187da) - [PDF](https://github.com/BioJulia/BioStructures.jl/blob/master/paper.pdf)
