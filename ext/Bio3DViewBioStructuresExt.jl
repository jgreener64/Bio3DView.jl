module Bio3DViewBioStructuresExt

using Bio3DView
using BioStructures

function Bio3DView.viewstruc(e::StructuralElementOrList,
                            atom_selectors::Function...;
                            style::Style=Bio3DView.defaultstyle("pdb"),
                            kwargs...)
    io = IOBuffer()
    writepdb(io, e, atom_selectors...)
    return Bio3DView.view("data-type='pdb'", String(take!(io)); style=style, kwargs...)
end

end
