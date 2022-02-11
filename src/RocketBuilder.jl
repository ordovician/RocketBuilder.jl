module RocketBuilder

const datadir = joinpath(@__DIR__, "..", "data")

include("db.jl")
include("tank-editor.jl")
include("engine-editor.jl")

end
