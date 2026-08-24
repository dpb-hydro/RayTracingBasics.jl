import RayTracingBasics as RT
using Test
using Aqua
using JET
using LinearAlgebra: norm, cross, dot
using StaticArrays

include("vector_tests.jl")

@testset "RayTracingBasics.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(RT; persistent_tasks=false)
    end

    @testset "Code linting (JET.jl)" begin
        JET.test_package(RT; target_modules=(RT,))
    end

    test_vectors()
end
