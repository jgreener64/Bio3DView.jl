# Included when Blink.jl is loaded

using .Blink

# Create a Blink window
function viewblink(html::AbstractString,
                height::Integer,
                width::Integer,
                debug::Bool)
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
    loadhtml(w, html)
    return w
end
