# Bio3DView.jl release notes

## v0.1.5 - Jul 2023

- Fix issue with rendering in VS Code.

## v0.1.4 - Aug 2022

- Drop support for Julia versions below 1.6.

## v0.1.3 - Apr 2021

- Fix JavaScript issue when viewing in Pluto.jl.

## v0.1.2 - Mar 2021

- Add the ability to draw lines and cylinders.

## v0.1.1 - Jul 2020

- Add support for [Pluto.jl](https://github.com/fonsp/Pluto.jl).

## v0.1.0 - Jan 2019

First release of Bio3DView.jl, a viewer for molecular structures in Julia based on 3Dmol.js.

Features:
- View files and strings in multiple file formats ("pdb", "sdf", "xyz" and "mol2").
- View structures from the PDB and objects from BioStructures.jl.
- Add styles, surfaces, isosurfaces, boxes etc.
- View in an IJulia cell or a Blink.jl popup, or export to HTML.
