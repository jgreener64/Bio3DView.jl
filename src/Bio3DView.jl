module Bio3DView

export
    Style,
    defaultstyle,
    viewfile,
    viewstring,
    viewstruc,
    viewpdb

using Blink
using BioStructures

isijulia() = isdefined(Main, :IJulia) && Main.IJulia.inited

libpath = normpath(@__DIR__, "..", "js")
path_3dmol = joinpath(libpath, "3Dmol-nojquery-min.js")
path_jquery = joinpath(libpath, "jquery-3.3.1.min.js")
js_3dmol = read(path_3dmol, String)
js_jquery = read(path_jquery, String)

"""
A style for a molecular visualisation.
Examples are `Style("cartoon")` and
`Style("cartoon", Dict("color"=> "spectrum", "ribbon"=> true, "thickness"=> 1.0))`.
"""
struct Style
    styletype::String
    options::Dict{String, Any}
end

Style(s::AbstractString) = Style(s, Dict())

"Default `Style` for molecular visualisation."
const defaultstyle = Style("cartoon", Dict("color"=> "spectrum"))

# Counter for data elements so they can be named individually
elementcount = 0

"""
View a molecular structure from a file or URL.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are the filepath/URL and the format ("pdb", "sdf", "xyz", "mol2", or
"cube").
The optional keyword argument `style` is a `Style`.
"""
function viewfile(f::AbstractString,
                format::AbstractString;
                style::Style=defaultstyle)
    if isijulia()
        return view("data-type='$format'", read(f, String); style=style)
    else
        return view("data-type='$format' data-href='$f'"; style=style)
    end
end

"""
View a molecular structure contained in a string.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are the molecule string and the format ("pdb", "sdf", "xyz", "mol2",
or "cube").
The optional keyword argument `style` is a `Style`.
"""
function viewstring(s::AbstractString,
                format::AbstractString;
                style::Style=defaultstyle)
    return view("data-type='$format'", s; style=style)
end

"""
View a structural element from BioStructures.jl.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are a `StructuralElementOrList` and zero or more functions to act as
atom selectors - see BioStructures.jl documentation for more.
The optional keyword argument `style` is a `Style`.
"""
function viewstruc(e::StructuralElementOrList,
                atom_selectors::Function...;
                style::Style=defaultstyle)
    io = IOBuffer()
    writepdb(io, e, atom_selectors...)
    return view("data-type='pdb'", String(io); style=style)
end

"""
View a structure from the Protein Data Bank (PDB).
Displays in a popup window, or in the output cell for an IJulia notebook.
Argument is the four letter PDB ID, e.g. "1AKE".
The optional keyword argument `style` is a `Style`.
"""
function viewpdb(p::AbstractString; style::Style=defaultstyle)
    if !occursin(r"^[a-zA-Z0-9]{4}$", p)
        throw(ArgumentError("Not a valid PDB ID: \"$p\""))
    end
    return view("data-pdb='$p'"; style=style)
end

# Generate HTML to view a molecule
function view(tagstr::AbstractString,
                datastr::AbstractString="";
                style::Style=defaultstyle)
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
        return HTML("<script type='text/javascript'>$js_jquery</script>" *
            "<script type='text/javascript'>$js_3dmol</script>$datadiv$divstr")
    else
        w = Window()
        title(w, "Bio3DView")
        size(w, 580, 580)
        loadhtml(w, "<script>window.\$ = window.jQuery = require" *
            "('$(replace(path_jquery, "\\" => "\\\\"))');</script>" *
            "<script src='$path_jquery'></script><script src='$path_3dmol'>" *
            "</script>$datadiv$divstr")
        return w
    end
end

# Convert Style instance to a style string
# String format is "cartoon:color=red,ribbon=true"
function stylestring(style::Style)
    s = style.styletype
    if length(style.options) > 0
        s *= ":"
        for k in keys(style.options)
            s *= "$k=$(string(style.options[k])),"
        end
        s = s[1:end - 1]
    end
    return s
end

end
