# This script builds the documentation for RayTracingBasics.jl
#
# To build the docs locally, run `include("docs/make.jl")` then open `docs/build/index.html` in your browser.

using Documenter
using RayTracingBasics

DocMeta.setdocmeta!(RayTracingBasics, :DocTestSetup, :(using RayTracingBasics); recursive=true)

makedocs(;
    modules=[RayTracingBasics],
    authors="Dan Bartley",
    repo="https://github.com/dpb-hydro/RayTracingBasics.jl/blob/{commit}{path}#{line}",
    sitename="RayTracingBasics.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://dpb-hydro.github.io/RayTracingBasics.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Guide" => "guide.md",
        "API Reference" => "api.md",
    ],
    doctest=true,
    checkdocs=:exports,
)

deploydocs(;
    repo="github.com/dpb-hydro/RayTracingBasics.jl",
    devbranch="main",
    push_preview=true,
)