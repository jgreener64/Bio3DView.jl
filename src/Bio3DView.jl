module Bio3DView

export
    Style,
    Surface,
    Box,
    viewfile,
    viewstring,
    viewstruc,
    viewpdb

using Blink
using BioStructures

# Counter for data elements so they can be named individually
element_count = 0

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

# Default style for molecular visualisation, depends on file format
function defaultstyle(format::AbstractString)
    if format == "pdb"
        return Style("cartoon", Dict("color"=> "spectrum"))
    elseif format in ("sdf", "xyz", "mol2", "cube")
        return Style("sphere")
    else
        throw(ArgumentError("Not a valid file format: \"$fmt\""))
    end
end

struct Box
    center::Vector{Float64}
    dims::Vector{Float64}
    color::String
    wireframe::Bool
end

Box(center, dims; color::AbstractString="black", wireframe::Bool=false) = Box(
        center, dims, color, wireframe)

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
                style::Style=defaultstyle(format),
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
                style::Style=defaultstyle(format),
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
                style::Style=defaultstyle("pdb"),
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
function viewpdb(p::AbstractString;
                style::Style=defaultstyle("pdb"),
                kwargs...)
    if !occursin(r"^[a-zA-Z0-9]{4}$", p)
        throw(ArgumentError("Not a valid PDB ID: \"$p\""))
    end
    return view("data-pdb='$p'"; kwargs...)
end

# Get the script to add a box from a Box object
function boxstring(box::Box)
    return "{center:{x:$(box.center[1]),y:$(box.center[2]),z:$(box.center[3])}, " *
        "dimensions:{w:$(box.dims[1]),h:$(box.dims[2]),d:$(box.dims[3])}, " *
        "color:'$(box.color)', " *
        "wireframe:$(box.wireframe)}"
end

# Generate HTML to view a molecule
function view(tag_str::AbstractString,
                data_str::AbstractString="";
                style::Style,
                surface::Union{Surface, Nothing}=nothing,
                box::Union{Box, Nothing}=nothing,
                height::Int64=540,
                width::Int64=540,
                debug::Bool=false)
    global element_count
    element_count += 1
    if length(data_str) > 0
        data_id = "3dmol_data_$element_count"
        data_div = "<textarea style='display:none;' id='$data_id'>$data_str</textarea>"
        tag_str *= " data-element='$data_id'"
    else
        data_div = ""
    end
    if surface != nothing
        surface_tag = "data-surface='$(tagstring(surface))'"
    else
        surface_tag = ""
    end
    viewer_id = "3dmol_viewer_$element_count"
    div_str = "<div style='height: $(height)px; width: $(width)px;' id='$viewer_id' " *
        "class='viewer_3Dmoljs' $tag_str " *
        "data-backgroundcolor='0xffffff' " *
        "data-style='$(tagstring(style))' " *
        "$surface_tag></div>"
    if box != nothing
        script_str = "<script type='text/javascript'>" *
            "\$(function() {
                var viewer = \$3Dmol.viewers['$viewer_id'];
                viewer.addBox($(boxstring(box)));
                viewer.render();
            });" *
            "</script>"
    else
        script_str = ""
    end
    if isijulia()
        return HTML("<script type='text/javascript'>$js_jquery</script>" *
            "<script type='text/javascript'>$js_3dmol</script>$data_div$div_str$script_str")
    else
        w = Window()
        if debug
            opentools(w)
        end
        title(w, "Bio3DView")
        size(w, width, height)
        if Sys.iswindows()
            req_path = replace(path_jquery, "\\" => "\\\\")
        else
            req_path = path_jquery
        end
        # The first part gets jQuery to work with Electron
        loadhtml(w, "<script>window.\$ = window.jQuery = require('$req_path');</script>" *
            "<script src='$path_jquery'></script><script src='$path_3dmol'>" *
            "</script>$data_div$div_str$script_str")
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
