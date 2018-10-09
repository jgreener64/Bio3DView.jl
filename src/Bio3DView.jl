module Bio3DView

export
    Style,
    Surface,
    defaultstyle,
    viewfile,
    viewstring,
    viewstruc,
    viewpdb

using Blink
using BioStructures

isijulia() = isdefined(Main, :IJulia) && Main.IJulia.inited

path_lib = normpath(@__DIR__, "..", "js")
path_3dmol = joinpath(path_lib, "3Dmol-nojquery-min.js")
path_jquery = joinpath(path_lib, "jquery-3.3.1.min.js")
js_3dmol = read(path_3dmol, String)
js_jquery = read(path_jquery, String)

"""
    Style(style_type)
    Style(style_type, options)

A style for a molecular visualisation, with an optional `Dict` of options.
Examples are `Style("cartoon")` and
`Style("cartoon", Dict("color"=> "spectrum", "ribbon"=> true, "thickness"=> 1.0))`.
"""
struct Style
    name::String
    options::Dict{String, Any}
end

Style(s::AbstractString) = Style(s, Dict())

struct Surface
    options::Dict{String, Any}
end

Surface() = Surface(Dict())

"Default `Style` for molecular visualisation."
const defaultstyle = Style("cartoon", Dict("color"=> "spectrum"))

# Counter for data elements so they can be named individually
element_count = 0

"""
    viewfile(file, format)
    viewfile(url, format)

View a molecular structure from a file or URL.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are the filepath/URL and the format ("pdb", "sdf", "xyz", "mol2", or
"cube").
The optional keyword argument `style` is a `Style`.
"""
function viewfile(f::AbstractString,
                format::AbstractString;
                kwargs...)
    if !(startswith(f, "http") || isfile(f))
        throw(ArgumentError("Cannot find file or URL \"$f\""))
    end
    return view("data-type='$format'", read(f, String); kwargs...)
end

"""
    viewstring(str, format)

View a molecular structure contained in a string.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are the molecule string and the format ("pdb", "sdf", "xyz", "mol2",
or "cube").
The optional keyword argument `style` is a `Style`.
"""
function viewstring(s::AbstractString,
                format::AbstractString;
                kwargs...)
    return view("data-type='$format'", s; kwargs...)
end

"""
    viewstruc(struc)
    viewstruc(struc, atom_selectors...)

View a structural element from BioStructures.jl.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are a `StructuralElementOrList` and zero or more functions to act as
atom selectors - see BioStructures.jl documentation for more.
The optional keyword argument `style` is a `Style`.
"""
function viewstruc(e::StructuralElementOrList,
                atom_selectors::Function...;
                kwargs...)
    io = IOBuffer()
    writepdb(io, e, atom_selectors...)
    return view("data-type='pdb'", String(take!(io)); kwargs...)
end

"""
    viewpdb(pdbid)

View a structure from the Protein Data Bank (PDB).
Displays in a popup window, or in the output cell for an IJulia notebook.
Argument is the four letter PDB ID, e.g. "1AKE".
The optional keyword argument `style` is a `Style`.
"""
function viewpdb(p::AbstractString; kwargs...)
    if !occursin(r"^[a-zA-Z0-9]{4}$", p)
        throw(ArgumentError("Not a valid PDB ID: \"$p\""))
    end
    return view("data-pdb='$p'"; kwargs...)
end

# Generate HTML to view a molecule
function view(tag_str::AbstractString,
                data_str::AbstractString="";
                style::Style=defaultstyle,
                surface::Union{Surface, Nothing}=nothing)
    if length(data_str) > 0
        global element_count
        element_count += 1
        data_element = "3dmol_data_$element_count"
        data_div = "<textarea style='display:none;' id='$data_element'>$data_str</textarea>"
        tag_str *= " data-element='$data_element'"
    else
        data_div = ""
    end
    if surface != nothing
        surface_tag = " data-surface='$(tagstring(surface))'"
    else
        surface_tag = ""
    end
    div_str = "<div style='height: 540px; width: 540px;' " *
        "class='viewer_3Dmoljs' $tag_str " *
        "data-backgroundcolor='0xffffff' " *
        "data-style='$(tagstring(style))'" *
        "$surface_tag></div>"
    if isijulia()
        return HTML("<script type='text/javascript'>$js_jquery</script>" *
            "<script type='text/javascript'>$js_3dmol</script>$data_div$div_str")
    else
        w = Window()
        title(w, "Bio3DView")
        size(w, 580, 580)
        if Sys.iswindows()
            req_path = replace(path_jquery, "\\" => "\\\\")
        else
            req_path = path_jquery
        end
        # The first part gets jQuery to work with Electron
        loadhtml(w, "<script>window.\$ = window.jQuery = require('$req_path');</script>" *
            "<script src='$path_jquery'></script><script src='$path_3dmol'>" *
            "</script>$data_div$div_str")
        return w
    end
end

# Convert Style or surface instance to a tag string
# Style format is "cartoon:color=red,ribbon=true"
function tagstring(s::Style)
    o = s.name
    if length(s.options) > 0
        o *= ":"
        for k in keys(s.options)
            o *= "$k=$(string(s.options[k])),"
        end
        # Strip trailing comma
        o = o[1:end - 1]
    end
    return o
end

# Style format is "opacity:0.7;color:white"
function tagstring(s::Surface)
    o = ""
    if length(s.options) > 0
        for k in keys(s.options)
            o *= "$k:$(string(s.options[k]));"
        end
        # Strip trailing comma
        o = o[1:end - 1]
    end
    return o
end

end
