module Bio3DView

# Add precompile

export view3D

using PyCall
using BioStructures

@pyimport py3Dmol

# Check IJulia with
# isdefined(Main, :IJulia) && Main.IJulia.inited

defaultstyle = Dict("cartoon"=> Dict("color"=> "spectrum"))

# Name chosen to avoid collision with Base.view
function view3D(s::AbstractString; style::Dict=defaultstyle)
    v = py3Dmol.view()
    v[:addModel](s, "pdb")
    v[:setStyle](style)
    v[:zoomTo]()
    return v
end

function view3D(e::StructuralElementOrList, atom_selectors::Function...; kwargs...)
    io = IOBuffer()
    writepdb(io, e, atom_selectors...)
    s = String(io)
    return view3D(s; kwargs...)
end

end
