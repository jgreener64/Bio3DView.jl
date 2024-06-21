module Bio3DViewBlinkExt

using Bio3DView
using Blink

# Create a Blink window
function Bio3DView.viewblink(html::AbstractString,
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
        req_path = replace(Bio3DView.path_jquery, "\\" => "\\\\")
    else
        req_path = Bio3DView.path_jquery
    end
    loadhtml(w, html)
    return w
end

end
