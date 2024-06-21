using Bio3DView
using Test
using BioStructures

testfile(path::AbstractString...) = normpath(
                    dirname(pathof(Bio3DView)), "..", "examples", path...)

style = Style("sphere", Dict("colorscheme"=> "greenCarbon"))
surface = Surface(Dict("colorscheme"=> "greenCarbon"))
isosurface = IsoSurface(testfile("benzene.cube"), 0.01)
box = Box([0.0, 0.0, 0.0], [6.0, 6.0, 6.0])
lines = [Line([0.0, 1.0, 2.0], [6.0, 7.0, 7.0]), Line([-3.0, -2.0, -1.0], [3.0, 4.0, 5.0])]
cylinders = [
    Cylinder([0.0, 1.0, 2.0], [6.0, 7.0, 7.0]),
    Cylinder([-3.0, -2.0, -1.0], [3.0, 4.0, 5.0]; startcap=RoundCap, stopcap=FlatCap),
]
axes = Axes(5, 0.3)
cameraangle = CameraAngle(0, 0, 0, 0, 0, 0, 0, 1)

viewfile(testfile("benzene.sdf"), "sdf", html=true)
viewpdb("1CRN", html=true)
viewfile(testfile("benzene.sdf"), style=style, html=true)

s = """
ATOM     72  N   ALA A  11      16.899  42.259  22.187  1.00 16.83           N
ATOM     73  CA  ALA A  11      15.960  42.201  23.284  1.00 18.31           C
ATOM     74  C   ALA A  11      15.625  43.630  23.738  1.00 17.96           C
ATOM     75  O   ALA A  11      14.821  43.804  24.675  1.00 22.53           O
ATOM     76  CB  ALA A  11      16.528  41.416  24.561  1.00 15.72           C
"""
viewstring(s, "pdb", style=Style("sphere"), html=true)

struc = read(testfile("1AKE.pdb"), PDBFormat)
viewstruc(struc['A'], html=true)
viewstruc(struc, disorderselector, style=Style("sphere"), html=true)
viewstruc(struc['A'], surface=surface, html=true)

viewfile(testfile("benzene.sdf"), "sdf", isosurface=isosurface, html=true)
viewfile(testfile("benzene.sdf"), "sdf", box=box, html=true)
viewfile(testfile("benzene.sdf"), "sdf", lines=lines, html=true)
viewfile(testfile("benzene.sdf"), "sdf", lines=lines[1], html=true)
viewfile(testfile("benzene.sdf"), "sdf", cylinders=cylinders, html=true)
viewfile(testfile("benzene.sdf"), "sdf", cylinders=cylinders[1], html=true)

viewfile(testfile("IRMOF-1.xyz"), "xyz"; style=Style("stick"), html=true)
isosurface = IsoSurface(testfile("IRMOF-1.cube"), -5.0)
viewfile(testfile("IRMOF-1.xyz"), "xyz", isosurface=isosurface,
            vtkcell=testfile("IRMOF-1.vtk"), html=true)

isosurface = IsoSurface(testfile("SBMOF-1.cube"), 100.0, wireframe=true,
                color="green")
viewfile(testfile("SBMOF-1.xyz"), "xyz"; isosurface=isosurface,
            vtkcell=testfile("SBMOF-1.vtk"), axes=axes, cameraangle=cameraangle, html=true)
