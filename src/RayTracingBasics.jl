# RayTracingBasics.jl
# Dan Bartley, June 2026
# Vector types to represent position and direction

module RayTracingBasics

using StaticArrays

# ----------------------------------------------------------------------------------------------------------
# VECTOR TYPES
# ----------------------------------------------------------------------------------------------------------

"""
    PositionVector{FT<:AbstractFloat} <: FieldVector{3,FT}
    PositionVector(xc::FT, yc::FT, zc::FT) where {FT<:AbstractFloat}

Vector representing position in 3D space.

# Constructor arguments
- `xc`, `yc`, `zc`: position components [metres]

# Fields
- Same as constructor arguments
"""
struct PositionVector{FT<:AbstractFloat} <: FieldVector{3,FT}
    xc::FT
    yc::FT
    zc::FT
end

"""
    DirectionVector{FT<:AbstractFloat} <: FieldVector{3,FT}
    DirectionVector(x::FT, y::FT, z::FT) where {FT<:AbstractFloat}

Unit-length vector representing direction in 3D space.

# Constructor arguments
- `x`, `y`, `z`: direction components [-]

# Fields
- `xd`, `yd`, `zd`: normalised direction components [-]
"""
struct DirectionVector{FT<:AbstractFloat} <: FieldVector{3,FT}
    xd::FT
    yd::FT
    zd::FT
    function DirectionVector(x::FT, y::FT, z::FT) where {FT<:AbstractFloat}
        L = hypot(x, y, z)
        check_positive(L)
        return new{FT}(x / L, y / L, z / L)
    end
end

"""
    DirectionVector(alpha::FT, beta::FT) where {FT<:AbstractFloat}

Constructor for `DirectionVector` using spherical coordinates.

# Arguments
- `alpha`: elevation angle [radians]
- `beta`: azimuth angle [radians]

# Returns
- `DirectionVector{FT}` constructed from spherical coordinates
"""
function DirectionVector(alpha::FT, beta::FT) where {FT<:AbstractFloat}
    sin_alpha, cos_alpha = sincos(alpha)
    sin_beta, cos_beta = sincos(beta)
    return DirectionVector(cos_alpha * sin_beta, cos_alpha * cos_beta, sin_alpha)
end

"""
    StaticArrays.similar_type(::Type{<:DirectionVector}, ::Type{T}, s::Size{S}) where {T,S}

Extend `StaticArrays.similar_type` to return a standard `SVector` when doing maths on a `DirectionVector`. This is because the result of arithmetic on a `DirectionVector` is not generally a unit vector.
"""
function StaticArrays.similar_type(
    ::Type{<:DirectionVector}, ::Type{T}, ::Size{S}
) where {T,S}
    return SVector{prod(S),T}
end

# ----------------------------------------------------------------------------------------------------------
# RAYS
# ----------------------------------------------------------------------------------------------------------

"""
    t_at_plane(ray_origin::PositionVector{FT}, ray_direction::DirectionVector{FT}, axis::Int, c::FT) where {FT<:AbstractFloat}

Compute the ray parameter `t` at which a ray intersects an axis-aligned plane.

# Arguments
- `ray_origin`, `ray_direction`: ray origin [metres] and direction [-]
- `axis`: axis normal to the plane (1=x, 2=y, 3=z)
- `c`: coordinate of the plane along `axis` [metres]

# Returns
- `FT`: ray parameter `t` at the intersection point [metres]
"""
function t_at_plane(
    ray_origin::PositionVector{FT}, ray_direction::DirectionVector{FT}, axis::Int, c::FT
) where {FT<:AbstractFloat}
    check_positive(abs(ray_direction[axis]))
    return (c - ray_origin[axis]) / ray_direction[axis]
end

# ----------------------------------------------------------------------------------------------------------
# HOMOGENEOUS COORDINATES
# ----------------------------------------------------------------------------------------------------------

"""
    to_homogeneous(v::PositionVector{FT}) where {FT<:AbstractFloat}

Convert a `PositionVector` to homogeneous coordinates by appending a unit weight.

# Arguments
- `v`: position vector in 3D space

# Returns
- `SVector{4, FT}`: homogeneous coordinate vector `[xc, yc, zc, 1]`
"""
function to_homogeneous(v::PositionVector{FT}) where {FT<:AbstractFloat}
    return SVector(v[1], v[2], v[3], one(FT))
end

"""
    to_homogeneous(v::DirectionVector{FT}) where {FT<:AbstractFloat}

Convert a `DirectionVector` to homogeneous coordinates by appending a zero weight.

# Arguments
- `v`: direction vector in 3D space

# Returns
- `SVector{4, FT}`: homogeneous coordinate vector `[xd, yd, zd, 0]`
"""
function to_homogeneous(v::DirectionVector{FT}) where {FT<:AbstractFloat}
    return SVector(v[1], v[2], v[3], zero(FT))
end

# ----------------------------------------------------------------------------------------------------------
# HELPER FUNCTION
# ----------------------------------------------------------------------------------------------------------

function check_positive(val::Real)
    val <= eps(typeof(val)) && throw(ArgumentError("value must be greater than zero"))
    return nothing
end

end # module
