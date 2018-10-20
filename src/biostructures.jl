# Included when BioStructures.jl is loaded

using .BioStructures

"""
    viewstruc(struc)
    viewstruc(struc, atom_selectors...)

View a structural element from BioStructures.jl.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are a `StructuralElementOrList` and zero or more functions to act as
atom selectors - see BioStructures.jl documentation for more.
Optional keyword arguments are `style`, `surface`, `isosurface`, `box`,
`vtkcell`, `axes`, `height`, `width`, `html` and `debug`.
"""
function viewstruc(e::StructuralElementOrList,
                atom_selectors::Function...;
                style::Style=defaultstyle("pdb"),
                kwargs...)
    io = IOBuffer()
    writepdb(io, e, atom_selectors...)
    return view("data-type='pdb'", String(take!(io)); style=style, kwargs...)
end
