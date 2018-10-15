module Bio3DView

export
    Style,
    Surface,
    IsoSurface,
    Box,
    viewfile,
    viewstring,
    viewstruc,
    viewpdb

using Blink
using BioStructures

# Counter for viewers so they can be named individually
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

# Default style for molecular visualisation, depends on file format
function defaultstyle(format::AbstractString)
    if format == "pdb"
        return Style("cartoon", Dict("color"=> "spectrum"))
    elseif format in ("sdf", "xyz", "mol2")
        return Style("stick")
    else
        throw(ArgumentError("Not a valid file format: \"$fmt\""))
    end
end

"""
    Surface()
    Surface(options)

A style for a molecular VDW surface visualisation, with an optional `Dict` of
options.
An example is `Surface(Dict("opacity"=> 0.8, "colorscheme"=> "whiteCarbon"))`.
"""
struct Surface
    options::Dict{String, Any}
end

Surface() = Surface(Dict())

"""
    IsoSurface(voldata, isoval)

Data and styling for an isosurface visualisation.
Arguments are the filepath with the volume data in "cube" format and the value
to view the isosurface at.
Optional keyword arguments are `color`, `opacity`, `wireframe` and `smoothness`.
"""
struct IsoSurface
    voldata::String
    isoval::Float64
    color::String
    opacity::Float64
    wireframe::Bool
    smoothness::Float64
end

function IsoSurface(voldata::AbstractString,
                isoval::Real;
                color::AbstractString="blue",
                opacity::Real=0.8,
                wireframe::Bool=false,
                smoothness::Real=5)
    return IsoSurface(voldata, isoval, color, opacity, wireframe, smoothness)
end

"""
    Box(center, dimensions)

Data and styling for a box visualisation.
Arguments are a `Vector{Float64}` of the center coordinates and a
`Vector{Float64}` of the box size in each dimension.
Optional keyword arguments are `color` and `wireframe`.
"""
struct Box
    center::Vector{Float64}
    dims::Vector{Float64}
    color::String
    wireframe::Bool
end

Box(center, dims; color::AbstractString="black", wireframe::Bool=true) = Box(
        center, dims, color, wireframe)

"""
    viewfile(file)
    viewfile(file, format)

View a molecular structure from a file.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are the filepath and the format ("pdb", "sdf", "xyz" or "mol2").
If not provided, the format is guessed from the file extension, e.g.
"myfile.xyz" is treated as being in the xyz format.
Optional keyword arguments are `style`, `surface`, `isosurface`, `box`,
`height`, `width` and `debug`.
"""
function viewfile(f::AbstractString,
                format::AbstractString=lowercase(split(f, ".")[end]);
                style::Style=defaultstyle(format),
                kwargs...)
    if !isfile(f)
        throw(ArgumentError("Cannot find file \"$f\""))
    end
    return view("data-type='$format'", read(f, String); style=style, kwargs...)
end

"""
    viewstring(str, format)

View a molecular structure contained in a string.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are the molecule string and the format ("pdb", "sdf", "xyz" or
"mol2").
Optional keyword arguments are `style`, `surface`, `isosurface`, `box`,
`height`, `width` and `debug`.
"""
function viewstring(s::AbstractString,
                format::AbstractString;
                style::Style=defaultstyle(format),
                kwargs...)
    return view("data-type='$format'", s; style=style, kwargs...)
end

"""
    viewstruc(struc)
    viewstruc(struc, atom_selectors...)

View a structural element from BioStructures.jl.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are a `StructuralElementOrList` and zero or more functions to act as
atom selectors - see BioStructures.jl documentation for more.
Optional keyword arguments are `style`, `surface`, `isosurface`, `box`,
`height`, `width` and `debug`.
"""
function viewstruc(e::StructuralElementOrList,
                atom_selectors::Function...;
                style::Style=defaultstyle("pdb"),
                kwargs...)
    io = IOBuffer()
    writepdb(io, e, atom_selectors...)
    return view("data-type='pdb'", String(take!(io)); style=style, kwargs...)
end

"""
    viewpdb(pdbid)

View a structure from the Protein Data Bank (PDB).
Displays in a popup window, or in the output cell for an IJulia notebook.
Argument is the four letter PDB ID, e.g. "1AKE".
Optional keyword arguments are `style`, `surface`, `isosurface`, `box`,
`height`, `width` and `debug`.
"""
function viewpdb(p::AbstractString;
                style::Style=defaultstyle("pdb"),
                kwargs...)
    if !occursin(r"^[a-zA-Z0-9]{4}$", p)
        throw(ArgumentError("Not a valid PDB ID: \"$p\""))
    end
    return view("data-pdb='$p'"; style=style, kwargs...)
end

# Get the script to add an isosurface from an IsoSurface object
function isosurfacestring(iso::IsoSurface)
    return "data = `$(read(iso.voldata, String))`\n" *
        "var voldata = new \$3Dmol.VolumeData(data, \"cube\");\n" *
        "viewer.addIsosurface(voldata, {isoval: $(iso.isoval), " *
        "color: \"$(iso.color)\", alpha: $(iso.opacity), " *
        "wireframe: $(iso.wireframe), smoothness: $(iso.smoothness)});\n"
end

# Get the script to add a box from a Box object
function boxstring(box::Box)
    return "viewer.addBox({" *
        "center:{x:$(box.center[1]),y:$(box.center[2]),z:$(box.center[3])}, " *
        "dimensions:{w:$(box.dims[1]),h:$(box.dims[2]),d:$(box.dims[3])}, " *
        "color:'$(box.color)', " *
        "wireframe:$(box.wireframe)});\n"
end

# Generate HTML to view a molecule
function view(tag_str::AbstractString,
                data_str::AbstractString="";
                style::Style,
                surface::Union{Surface, Nothing}=nothing,
                isosurface::Union{IsoSurface, Nothing}=nothing,
                box::Union{Box, Nothing}=nothing,
                height::Integer=540,
                width::Integer=540,
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
    script_str = "<script type='text/javascript'>\n\$(function() {\n" *
        "var viewer = \$3Dmol.viewers['$viewer_id'];\n"
    if isosurface != nothing
        script_str *= isosurfacestring(isosurface)
    end
    if box != nothing
        script_str *= boxstring(box)
    end
    script_str *= "viewer.render();\n});\n</script>"
    if isijulia()
        return HTML("<script type='text/javascript'>$js_jquery</script>\n" *
            "<script type='text/javascript'>$js_3dmol</script>\n$data_div\n$div_str\n$script_str\n")
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
        loadhtml(w, "<script>window.\$ = window.jQuery = require('$req_path');</script>\n" *
            "<script src='$path_jquery'></script>\n" *
            "<script src='$path_3dmol'></script>\n$data_div\n$div_str\n$script_str\n")
        return w
    end
end

# Convert Style instance to a tag string
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

# Convert Surface instance to a tag string
# Surface format is "opacity:0.7;color:white"
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
