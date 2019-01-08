module Bio3DView

export
    Style,
    Surface,
    IsoSurface,
    Box,
    Axes,
    CameraAngle,
    viewfile,
    viewstring,
    viewstruc,
    viewpdb

using Requires

# Counter for viewers so they can be named individually
element_count = 0

function __init__()
    @require BioStructures="de9282ab-8554-53be-b2d6-f6c222edabfc" include("biostructures.jl")
    @require Blink="ad839575-38b3-5650-b840-f874b8c74a25" include("blink.jl")
end

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
    Axes(length, radius)
    Axes()

Styling for visualisation of the coordinate axes.
Arguments are numbers for the length and the radius of the arrows.
The optional keyword argument `colors` is a list of 3 colors as `String`s for
the 3 axes.
"""
struct Axes
    len::Float64
    radius::Float64
    colors::Vector{String}
end

function Axes(len::Real=1.0,
                radius::Real=0.1;
                colors::Vector{String}=["red", "green", "blue"])
    return Axes(len, radius, colors)
end

"""
    CameraAngle(posx, posy, posz, zoom, qx, qy, qz, qw)

A custom perspective to view the molecule from.
Arguments are x/y/z translation, zoom, and x/y/z/w rotation quaternion.
Default is `CameraAngle(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0)`.
"""
struct CameraAngle
    posx::Float64
    posy::Float64
    posz::Float64
    zoom::Float64
    qx::Float64
    qy::Float64
    qz::Float64
    qw::Float64
end

"""
    viewfile(file)
    viewfile(file, format)

View a molecular structure from a file.
Displays in a popup window, or in the output cell for an IJulia notebook.
Arguments are the filepath and the format ("pdb", "sdf", "xyz" or "mol2").
If not provided, the format is guessed from the file extension, e.g.
"myfile.xyz" is treated as being in the xyz format.
Optional keyword arguments are `style`, `surface`, `isosurface`, `box`,
`vtkcell`, `axes`, `cameraangle`, `height`, `width`, `html` and `debug`.
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
`vtkcell`, `axes`, `cameraangle`, `height`, `width`, `html` and `debug`.
"""
function viewstring(s::AbstractString,
                format::AbstractString;
                style::Style=defaultstyle(format),
                kwargs...)
    return view("data-type='$format'", s; style=style, kwargs...)
end

"""
    viewpdb(pdbid)

View a structure from the Protein Data Bank (PDB).
Displays in a popup window, or in the output cell for an IJulia notebook.
Argument is the four letter PDB ID, e.g. "1AKE".
Requires an internet connection to work.
Optional keyword arguments are `style`, `surface`, `isosurface`, `box`,
`vtkcell`, `axes`, `cameraangle`, `height`, `width`, `html` and `debug`.
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

# Get the script to add a unit cell from a vtk format file
function vtkcellstring(f::AbstractString)
    coords = []
    lines = []
    mode = "none"
    open(f) do file
        for l in eachline(file)
            if startswith(l, "POINTS")
                mode = "points"
            elseif startswith(l, "LINES")
                mode = "lines"
            elseif mode == "points"
                push!(coords, parse.(Float64, split(l)))
            elseif mode == "lines"
                # Account for zero-based indexing
                push!(lines, parse.(Int, split(l))[2:end] .+ 1)
            end
        end
    end
    o = ""
    for (i, j) in lines
        o *= "viewer.addLine({\n" *
        "start:{x:$(coords[i][1]), y:$(coords[i][2]), z:$(coords[i][3])},\n" *
        "end:{x:$(coords[j][1]), y:$(coords[j][2]), z:$(coords[j][3])}\n});\n"
    end
    return o
end

# Get the script to add arrows showing the coordinate axes
function axesstring(a::Axes)
    o = ""
    for (x, y, z, col) in ((a.len, 0, 0, a.colors[1]), (0, a.len, 0, a.colors[2]),
                (0, 0, a.len, a.colors[3]))
        o *= "viewer.addArrow({\nstart:{x:0, y:0, z:0},\n" *
                "end:{x:$x, y:$y, z:$z},\ncolor:'$col',\nradius:$(a.radius)\n});\n"
    end
    return o
end

# Get the script to change the view to a custom angle
function cameraanglestring(a::CameraAngle)
    return "viewer.setView([$(a.posx), $(a.posy), $(a.posz), $(a.zoom), " *
            "$(a.qx), $(a.qy), $(a.qz), $(a.qw)]);\n"
end

# Generate HTML to view a molecule
function view(tag_str::AbstractString,
                data_str::AbstractString="";
                style::Style,
                surface::Union{Surface, Nothing}=nothing,
                isosurface::Union{IsoSurface, Nothing}=nothing,
                box::Union{Box, Nothing}=nothing,
                vtkcell::Union{AbstractString, Nothing}=nothing,
                axes::Union{Axes, Nothing}=nothing,
                cameraangle::Union{CameraAngle, Nothing}=nothing,
                height::Integer=540,
                width::Integer=540,
                html::Bool=false,
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
    if vtkcell != nothing
        script_str *= vtkcellstring(vtkcell)
    end
    if axes != nothing
        script_str *= axesstring(axes)
    end
    if cameraangle != nothing
        script_str *= cameraanglestring(cameraangle)
    end
    script_str *= "viewer.render();\n});\n</script>"
    ijulia_html = "<script type='text/javascript'>$js_jquery</script>\n" *
            "<script type='text/javascript'>$js_3dmol</script>\n$data_div\n$div_str\n$script_str\n"
    # Return stand-alone HTML only
    if html
        return "<html>\n<meta charset=\"UTF-8\">\n<head></head>\n<body>" *
                "$ijulia_html</body></html>\n"
    end
    if isijulia()
        return HTML(ijulia_html)
    else
        if !isdefined(Main, :Blink)
            throw("Cannot run the command as you do not appear to be in an IJulia " *
                    "notebook, Blink is not loaded and html is not set to true")
        end
        if Sys.iswindows()
            req_path = replace(path_jquery, "\\" => "\\\\")
        else
            req_path = path_jquery
        end
        # The first part gets jQuery to work with Electron
        blink_html = "<script>window.\$ = window.jQuery = require('$req_path');</script>\n" *
            "<script src='$path_jquery'></script>\n" *
            "<script src='$path_3dmol'></script>\n$data_div\n$div_str\n$script_str\n"
        viewblink(blink_html, height, width, debug)
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
