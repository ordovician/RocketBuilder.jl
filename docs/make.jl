using RocketBuilder
using Documenter

DocMeta.setdocmeta!(RocketBuilder, :DocTestSetup, :(using RocketBuilder); recursive=true)

makedocs(;
    modules=[RocketBuilder],
    authors="Erik Engheim <erik.engheim@mac.com> and contributors",
    repo="https://github.com/ordovician/RocketBuilder.jl/blob/{commit}{path}#{line}",
    sitename="RocketBuilder.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
