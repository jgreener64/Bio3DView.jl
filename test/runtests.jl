using Bio3DView
using BioStructures
using Base.Test

testpath(p::AbstractString) = joinpath(dirname(@__FILE__), p)

view3D()

s = """
ATOM     72  N   ALA A  11      16.899  42.259  22.187  1.00 16.83           N
ATOM     73  CA  ALA A  11      15.960  42.201  23.284  1.00 18.31           C
ATOM     74  C   ALA A  11      15.625  43.630  23.738  1.00 17.96           C
ATOM     75  O   ALA A  11      14.821  43.804  24.675  1.00 22.53           O
ATOM     76  CB  ALA A  11      16.528  41.416  24.561  1.00 15.72           C
"""
view3D(s, "pdb")

struc = read(testpath("1AKE.pdb"), PDB)
view3D(struc)
view3D(struc, calphaselector)
view3D(struc, calphaselector, disorderselector)

v = view3D(struc['A']; style=Dict("cartoon"=> Dict("color"=> "green")))
addmodel!(v, struc['B'])
setstyle!(v, Dict("cartoon"=> Dict("color"=> "red")))

viewfile(testpath("1AKE.pdb"), "pdb")

viewpdb("3PXF")
@test_throws ArgumentError viewpdb("123")

png(v)
