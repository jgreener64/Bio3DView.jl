module Bio3DView

# Add precompile

export
    defaultstyle,
    setstyle!,
    addmodel!,
    view3D,
    viewfile,
    viewpdb

using PyCall
using BioStructures

@pyimport py3Dmol

const defaultstyle = Dict("cartoon"=> Dict("color"=> "spectrum"))

# Can this actually be a string?
function setstyle!(v::PyObject, style::Dict)
    v[:setStyle](style)
    return v
end

function addmodel!(v::PyObject,
                s::AbstractString,
                format::AbstractString;
                style::Dict=defaultstyle)
    v[:addModel](s, format)
    v[:zoomTo]()
    setstyle!(v, style)
    return v
end

function addmodel!(v::PyObject,
                e::StructuralElementOrList,
                atom_selectors::Function...;
                kwargs...)
    io = IOBuffer()
    writepdb(io, e, atom_selectors...)
    s = String(io)
    addmodel!(v, s, "pdb"; kwargs...)
end

view3D() = py3Dmol.view()

function view3D(s::AbstractString,
                format::AbstractString;
                style::Dict=defaultstyle)
    v = view3D()
    addmodel!(v, s, format; style=style)
    return v
end

function view3D(e::StructuralElementOrList,
                atom_selectors::Function...;
                kwargs...)
    io = IOBuffer()
    writepdb(io, e, atom_selectors...)
    s = String(io)
    return view3D(s, "pdb"; kwargs...)
end

function viewfile(f::AbstractString,
                format::AbstractString;
                kwargs...)
    in_file = open(f)
    s = readstring(in_file)
    close(in_file)
    return view3D(s, format; kwargs...)
end

function viewpdb(p::AbstractString; style::Dict=defaultstyle)
    if !ismatch(r"^[a-zA-Z0-9]{4}$", p)
        throw(ArgumentError("Not a valid PDB ID: \"$p\""))
    end
    v = py3Dmol.view(query="pdb:$(lowercase(p))")
    setstyle!(v, style)
    return v
end

end
