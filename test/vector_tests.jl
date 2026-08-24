function test_vectors()
    @testset "PositionVector" begin
        @testset "3-argument constructor" begin
            P = RT.PositionVector(1.0, 2.0, 3.0)
            @test P.xc == 1.0
            @test P.yc == 2.0
            @test P.zc == 3.0
            @test P[1] == 1.0
            @test P[2] == 2.0
            @test P[3] == 3.0
        end

        @testset "Float32" begin
            P = RT.PositionVector(1.0f0, 2.0f0, 3.0f0)
            @test P.xc isa Float32
            @test P.yc isa Float32
            @test P.zc isa Float32
        end

        @testset "Arithmetic" begin
            P1 = RT.PositionVector(1.0, 2.0, 3.0)
            P2 = RT.PositionVector(4.0, 5.0, 6.0)
            @test (P1 + P2)[1] ≈ 5.0
            @test (P1 + P2)[2] ≈ 7.0
            @test (P1 + P2)[3] ≈ 9.0
            @test (P2 - P1)[1] ≈ 3.0
            @test (P2 - P1)[2] ≈ 3.0
            @test (P2 - P1)[3] ≈ 3.0
        end

        @testset "Indexing" begin
            P = RT.PositionVector(1.0, 2.0, 3.0)
            @test length(P) == 3
            @test size(P) == (3,)
            @test_throws BoundsError P[0]
            @test_throws BoundsError P[4]
        end

        @testset "Scalar multiplication" begin
            P = RT.PositionVector(1.0, 2.0, 3.0)
            @test (2.0 * P)[1] ≈ 2.0
            @test (2.0 * P)[2] ≈ 4.0
            @test (2.0 * P)[3] ≈ 6.0
            @test (-1.0 * P)[1] ≈ -1.0
        end

        @testset "Equality and approximate equality" begin
            P1 = RT.PositionVector(1.0, 2.0, 3.0)
            P2 = RT.PositionVector(1.0, 2.0, 3.0)
            P3 = RT.PositionVector(1.0, 2.0, 3.0 + eps(Float64))
            @test P1 == P2
            @test P1 ≈ P3
        end

        @testset "Zero vector" begin
            P = RT.PositionVector(0.0, 0.0, 0.0)
            @test iszero(P)
        end
    end

    @testset "DirectionVector" begin
        @testset "Normalisation" begin
            D = RT.DirectionVector(1.0, 0.0, 0.0)
            @test norm(D) ≈ one(Float64)
            @test D.xd ≈ 1.0
            @test D.yd ≈ 0.0
            @test D.zd ≈ 0.0

            D = RT.DirectionVector(3.0, 4.0, 0.0)
            @test norm(D) ≈ one(Float64)
            @test D.xd ≈ 0.6
            @test D.yd ≈ 0.8
            @test D.zd ≈ 0.0

            D = RT.DirectionVector(10.0, 20.0, 30.0)
            @test norm(D) ≈ one(Float64)
        end

        @testset "Zero-length throws" begin
            @test_throws ArgumentError RT.DirectionVector(0.0, 0.0, 0.0)
            @test_throws ArgumentError RT.DirectionVector(0.0f0, 0.0f0, 0.0f0)
        end

        @testset "Polar constructor" begin
            # alpha=pi/4, beta=0: (0, sqrt(0.5), sqrt(0.5))
            D = RT.DirectionVector(pi / 4, 0.0)
            @test norm(D) ≈ one(Float64)
            @test D[1] ≈ 0.0 atol = 1e-15
            @test D[2] ≈ sqrt(0.5)
            @test D[3] ≈ sqrt(0.5)

            # alpha=pi/2 (straight up): (0, 0, 1) regardless of beta
            D = RT.DirectionVector(pi / 2, 0.0)
            @test norm(D) ≈ one(Float64)
            @test D[1] ≈ 0.0 atol = 1e-15
            @test D[2] ≈ 0.0 atol = 1e-15
            @test D[3] ≈ 1.0

            # alpha=0, beta=0: points in y-direction (0, 1, 0)
            D = RT.DirectionVector(0.0, 0.0)
            @test norm(D) ≈ one(Float64)
            @test D[1] ≈ 0.0 atol = 1e-15
            @test D[2] ≈ 1.0
            @test D[3] ≈ 0.0 atol = 1e-15

            # alpha=0, beta=pi/2: points in x-direction (1, 0, 0)
            D = RT.DirectionVector(0.0, pi / 2)
            @test norm(D) ≈ one(Float64)
            @test D[1] ≈ 1.0
            @test D[2] ≈ 0.0 atol = 1e-15
            @test D[3] ≈ 0.0 atol = 1e-15
        end

        @testset "Float32" begin
            D = RT.DirectionVector(1.0f0, 0.0f0, 0.0f0)
            @test norm(D) ≈ one(Float32)
            @test D.xd isa Float32

            D = RT.DirectionVector(Float32(pi / 4), Float32(0.0))
            @test norm(D) ≈ one(Float32)
        end

        @testset "Arithmetic returns SVector not DirectionVector" begin
            D = RT.DirectionVector(1.0, 0.0, 0.0)
            @test (D + D) isa SVector
            @test !((D + D) isa RT.DirectionVector)
            @test (2.0 * D) isa SVector
            @test !((2.0 * D) isa RT.DirectionVector)
        end

        @testset "Normalisation — negative components" begin
            D = RT.DirectionVector(-1.0, -1.0, -1.0)
            @test norm(D) ≈ one(Float64)
            @test D.xd < 0.0
            @test D.yd < 0.0
            @test D.zd < 0.0
        end

        @testset "Normalisation — very large and very small inputs" begin
            D = RT.DirectionVector(1e300, 1e300, 1e300)
            @test norm(D) ≈ one(Float64)
            @test_throws ArgumentError RT.DirectionVector(1e-300, 1e-300, 1e-300)
        end

        @testset "Polar constructor — Float32" begin
            D = RT.DirectionVector(Float32(pi / 2), Float32(pi / 2))
            @test norm(D) ≈ one(Float32)
            @test D.xd isa Float32
        end

        @testset "Polar constructor — negative angles" begin
            D = RT.DirectionVector(-pi / 4, -pi / 4)
            @test norm(D) ≈ one(Float64)
        end

        @testset "Polar constructor — round trip" begin
            alpha = pi / 6
            beta = pi / 3
            D1 = RT.DirectionVector(alpha, beta)
            D2 = RT.DirectionVector(D1.xd, D1.yd, D1.zd)
            @test D1 ≈ D2
        end

        @testset "Arithmetic — subtraction returns SVector" begin
            D1 = RT.DirectionVector(1.0, 0.0, 0.0)
            D2 = RT.DirectionVector(0.0, 1.0, 0.0)
            @test (D1 - D2) isa SVector
            @test !((D1 - D2) isa RT.DirectionVector)
        end

        @testset "Arithmetic — dot and cross products" begin
            Dx = RT.DirectionVector(1.0, 0.0, 0.0)
            Dy = RT.DirectionVector(0.0, 1.0, 0.0)
            Dz = RT.DirectionVector(0.0, 0.0, 1.0)
            @test dot(Dx, Dy) ≈ 0.0 atol = 1e-15
            @test dot(Dx, Dx) ≈ 1.0
            @test cross(Dx, Dy) ≈ [0.0, 0.0, 1.0]
            @test cross(Dy, Dz) ≈ [1.0, 0.0, 0.0]
        end
    end

    @testset "to_homogeneous" begin
        @testset "PositionVector" begin
            P = RT.PositionVector(1.0, 2.0, 3.0)
            h = RT.to_homogeneous(P)
            @test h isa SVector{4,Float64}
            @test h[1] ≈ 1.0
            @test h[2] ≈ 2.0
            @test h[3] ≈ 3.0
            @test h[4] ≈ 1.0

            P32 = RT.PositionVector(1.0f0, 2.0f0, 3.0f0)
            h32 = RT.to_homogeneous(P32)
            @test h32 isa SVector{4,Float32}
            @test h32[4] isa Float32
            @test h32[4] == one(Float32)
        end

        @testset "DirectionVector" begin
            D = RT.DirectionVector(1.0, 0.0, 0.0)
            h = RT.to_homogeneous(D)
            @test h isa SVector{4,Float64}
            @test h[1] ≈ 1.0
            @test h[2] ≈ 0.0
            @test h[3] ≈ 0.0
            @test h[4] ≈ 0.0

            D2 = RT.DirectionVector(3.0, 4.0, 0.0)
            h2 = RT.to_homogeneous(D2)
            @test h2[4] ≈ 0.0

            D32 = RT.DirectionVector(0.0f0, 1.0f0, 0.0f0)
            h32 = RT.to_homogeneous(D32)
            @test h32 isa SVector{4,Float32}
            @test h32[4] == zero(Float32)
        end

        @testset "Homogeneous w distinguishes point from direction" begin
            P = RT.PositionVector(5.0, -3.0, 2.0)
            D = RT.DirectionVector(5.0, -3.0, 2.0)
            @test RT.to_homogeneous(P)[4] == 1.0
            @test RT.to_homogeneous(D)[4] == 0.0
        end
    end

    @testset "t_at_plane" begin
        @testset "Basic intersection" begin
            origin = RT.PositionVector(0.0, 0.0, 0.0)
            direction = RT.DirectionVector(0.0, 0.0, 1.0)
            t = RT.t_at_plane(origin, direction, 3, 1.0)
            @test t ≈ 1.0

            origin2 = RT.PositionVector(0.0, 0.0, 2.0)
            t2 = RT.t_at_plane(origin2, direction, 3, 5.0)
            @test t2 ≈ 3.0
        end

        @testset "Oblique ray" begin
            origin = RT.PositionVector(0.0, 0.0, 0.0)
            direction = RT.DirectionVector(0.0, 1.0, 1.0)
            t = RT.t_at_plane(origin, direction, 3, 1.0)
            @test t ≈ sqrt(2.0)
        end

        @testset "Target z equals origin z" begin
            origin = RT.PositionVector(1.0, 2.0, 5.0)
            direction = RT.DirectionVector(0.0, 0.0, 1.0)
            t = RT.t_at_plane(origin, direction, 3, 5.0)
            @test t ≈ 0.0 atol = 1e-15
        end

        @testset "Target z below origin" begin
            origin = RT.PositionVector(0.0, 0.0, 10.0)
            direction = RT.DirectionVector(0.0, 0.0, 1.0)
            t = RT.t_at_plane(origin, direction, 3, 5.0)
            @test t ≈ -5.0
        end

        @testset "Zero z-component throws" begin
            origin = RT.PositionVector(0.0, 0.0, 0.0)
            direction = RT.DirectionVector(1.0, 0.0, 0.0)
            @test_throws ArgumentError RT.t_at_plane(origin, direction, 3, 1.0)
        end

        @testset "Near-zero z-component throws" begin
            # zd positive but below eps(Float64) should still throw
            origin = RT.PositionVector(0.0, 0.0, 0.0)
            direction = RT.DirectionVector(1.0, 0.0, 1e-320)
            @test_throws ArgumentError RT.t_at_plane(origin, direction, 3, 1.0)
        end

        @testset "Float32" begin
            origin = RT.PositionVector(0.0f0, 0.0f0, 0.0f0)
            direction = RT.DirectionVector(0.0f0, 0.0f0, 1.0f0)
            t = RT.t_at_plane(origin, direction, 3, 1.0f0)
            @test t isa Float32
            @test t ≈ 1.0f0
        end

        @testset "Consistency: point on ray at t matches target z" begin
            origin = RT.PositionVector(1.0, 2.0, 3.0)
            direction = RT.DirectionVector(1.0, 1.0, 1.0)
            z_target = 7.0
            t = RT.t_at_plane(origin, direction, 3, z_target)
            z_reconstructed = origin.zc + t * direction.zd
            @test z_reconstructed ≈ z_target
        end

        @testset "x-axis plane" begin
            origin = RT.PositionVector(0.0, 0.0, 0.0)
            direction = RT.DirectionVector(1.0, 0.0, 0.0)
            t = RT.t_at_plane(origin, direction, 1, 3.0)
            @test t ≈ 3.0

            origin2 = RT.PositionVector(1.0, 0.0, 0.0)
            t2 = RT.t_at_plane(origin2, direction, 1, 4.0)
            @test t2 ≈ 3.0
        end

        @testset "y-axis plane" begin
            origin = RT.PositionVector(0.0, 0.0, 0.0)
            direction = RT.DirectionVector(0.0, 1.0, 0.0)
            t = RT.t_at_plane(origin, direction, 2, 5.0)
            @test t ≈ 5.0

            origin2 = RT.PositionVector(0.0, 2.0, 0.0)
            t2 = RT.t_at_plane(origin2, direction, 2, 5.0)
            @test t2 ≈ 3.0
        end

        @testset "Zero x-component throws" begin
            origin = RT.PositionVector(0.0, 0.0, 0.0)
            direction = RT.DirectionVector(0.0, 1.0, 0.0)
            @test_throws ArgumentError RT.t_at_plane(origin, direction, 1, 1.0)
        end

        @testset "Zero y-component throws" begin
            origin = RT.PositionVector(0.0, 0.0, 0.0)
            direction = RT.DirectionVector(1.0, 0.0, 0.0)
            @test_throws ArgumentError RT.t_at_plane(origin, direction, 2, 1.0)
        end

        @testset "Consistency: point on ray at t matches plane — x axis" begin
            origin = RT.PositionVector(1.0, 2.0, 3.0)
            direction = RT.DirectionVector(1.0, 1.0, 1.0)
            x_target = 4.0
            t = RT.t_at_plane(origin, direction, 1, x_target)
            x_reconstructed = origin.xc + t * direction.xd
            @test x_reconstructed ≈ x_target
        end

        @testset "Consistency: point on ray at t matches plane — y axis" begin
            origin = RT.PositionVector(1.0, 2.0, 3.0)
            direction = RT.DirectionVector(1.0, 1.0, 1.0)
            y_target = 6.0
            t = RT.t_at_plane(origin, direction, 2, y_target)
            y_reconstructed = origin.yc + t * direction.yd
            @test y_reconstructed ≈ y_target
        end

        @testset "Float32 — x and y axes" begin
            origin = RT.PositionVector(0.0f0, 0.0f0, 0.0f0)
            direction = RT.DirectionVector(1.0f0, 0.0f0, 0.0f0)
            t = RT.t_at_plane(origin, direction, 1, 2.0f0)
            @test t isa Float32
            @test t ≈ 2.0f0

            direction2 = RT.DirectionVector(0.0f0, 1.0f0, 0.0f0)
            t2 = RT.t_at_plane(origin, direction2, 2, 3.0f0)
            @test t2 isa Float32
            @test t2 ≈ 3.0f0
        end
    end

    @testset "Polar constructor — straight down" begin
        D = RT.DirectionVector(-pi / 2, 0.0)
        @test norm(D) ≈ one(Float64)
        @test D[1] ≈ 0.0 atol = 1e-15
        @test D[2] ≈ 0.0 atol = 1e-15
        @test D[3] ≈ -1.0
    end

    @testset "PositionVector to DirectionVector workflow" begin
        P1 = RT.PositionVector(0.0, 0.0, 0.0)
        P2 = RT.PositionVector(3.0, 4.0, 0.0)
        disp = P2 - P1
        D = RT.DirectionVector(disp[1], disp[2], disp[3])
        @test norm(D) ≈ one(Float64)
        @test D.xd ≈ 0.6
        @test D.yd ≈ 0.8
        @test D.zd ≈ 0.0
    end
end
