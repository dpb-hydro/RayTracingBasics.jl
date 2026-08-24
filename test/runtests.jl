using RayTracingBasics
using Test
using Aqua
using JET

@testset "RayTracingBasics.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(RayTracingBasics)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(RayTracingBasics; target_defined_modules = true)
    end
    # Write your tests here.
end
