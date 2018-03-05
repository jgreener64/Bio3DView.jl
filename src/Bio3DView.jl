module Bio3DView

export
    defaultstyle,
    viewfile,
    viewstring,
    viewstruc,
    viewpdb

using Blink
using BioStructures

isijulia() = isdefined(Main, :IJulia) && Main.IJulia.inited

libpath = normpath(@__DIR__, "..", "js", "3Dmol-min.js")
js3dmol = readstring(libpath)

"`Dict` of default styles for molecular visualisation."
const defaultstyle = Dict("cartoon"=> Dict("color"=> "spectrum"))

# Counter for data elements so they can be named individually
elementcount = 0

"""
View a molecular structure from a file or URL.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are the filepath/URL and the format ("pdb", "sdf", "xyz", "mol2", or
"cube").
The optional keyword argument `style` is a `Dict` of style options.
"""
function viewfile(f::AbstractString,
                format::AbstractString;
                style::Dict=defaultstyle)
    if isijulia()
        return view("data-type='$format'", readstring(f); style=style)
    else
        return view("data-type='$format' data-href='$f'"; style=style)
    end
end

"""
View a molecular structure contained in a string.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are the molecule string and the format ("pdb", "sdf", "xyz", "mol2",
or "cube").
The optional keyword argument `style` is a `Dict` of style options.
"""
function viewstring(s::AbstractString,
                format::AbstractString;
                style::Dict=defaultstyle)
    return view("data-type='$format'", s; style=style)
end

"""
View a structural element from BioStructures.jl.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are a `StructuralElementOrList` and zero or more functions to act as
atom selectors - see BioStructures.jl documentation for more.
The optional keyword argument `style` is a `Dict` of style options.
"""
function viewstruc(e::StructuralElementOrList,
                atom_selectors::Function...;
                style::Dict=defaultstyle)
    io = IOBuffer()
    writepdb(io, e, atom_selectors...)
    return view("data-type='pdb'", String(io); style=style)
end

"""
View a structure from the Protein Data Bank (PDB).
Displays in a popup window, or in the output cell for an IJulia notebook.
Argument is the four letter PDB ID, e.g. "1AKE".
The optional keyword argument `style` is a `Dict` of style options.
"""
function viewpdb(p::AbstractString; style::Dict=defaultstyle)
    if !ismatch(r"^[a-zA-Z0-9]{4}$", p)
        throw(ArgumentError("Not a valid PDB ID: \"$p\""))
    end
    return view("data-pdb='$p'"; style=style)
end

# Generate HTML to view a molecule
function view(tagstr::AbstractString,
                datastr::AbstractString="";
                style::Dict=defaultstyle)
    if length(datastr) > 0
        global elementcount
        elementcount += 1
        dataelement = "3dmol_data_$elementcount"
        datadiv = "<textarea style='display:none;' id='$dataelement'>$datastr</textarea>"
        tagstr *= " data-element='$dataelement'"
    else
        datadiv = ""
    end
    divstr = "<div style='height: 540px; width: 540px;' " *
        "class='viewer_3Dmoljs' $tagstr " *
        "data-backgroundcolor='0xffffff' " *
        "data-style='$(stylestring(style))'></div>"
    if isijulia()
        return HTML("<script type='text/javascript'>$js3dmol</script>$datadiv$divstr")
    else
        w = Window()
        title(w, "Bio3DView")
        size(w, 580, 580)
        loadhtml(w, "<script src='$libpath'></script>$datadiv$divstr")
        return w
    end
end

# Convert dictionary to a style string
function stylestring(style::Dict)
    return ""
end

end
