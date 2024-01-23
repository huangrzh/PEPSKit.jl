"""
    struct InfinitePEPS{T<:PEPSTensor}

Represents an infinite projected entangled pairs state on a 2D square lattice.
"""
struct InfinitePEPS{T<:PEPSTensor} <: AbstractPEPS
    A::Array{T,2}

    function InfinitePEPS(A::Array{T,2}) where {T<:PEPSTensor}
        return new{T}(A)
    end
end


## Constructors
"""
    InfinitePEPS(A::AbstractArray{T, 2})

Allow users to pass in an array of tensors.
"""
function InfinitePEPS(A::AbstractArray{T,2}) where {T<:PEPSTensor}
    return InfinitePEPS(Array(deepcopy(A)))
end

"""
    InfinitePEPS(Pspaces, Nspaces, Espaces)

Allow users to pass in arrays of spaces.
"""
function InfinitePEPS(
    Pspaces::AbstractArray{S,2},
    Nspaces::AbstractArray{S,2},
    Espaces::AbstractArray{S,2}=Nspaces
) where {S<:ElementarySpace}
    size(Pspaces) == size(Nspaces) == size(Espaces) ||
        throw(ArgumentError("Input spaces should have equal sizes."))

    Sspaces = adjoint.(circshift(Nspaces, (1, 0)))
    Wspaces = adjoint.(circshift(Espaces, (0, -1)))

    A = map(Pspaces, Nspaces, Espaces, Sspaces, Wspaces) do P, N, E, S, W
        return TensorMap(rand, ComplexF64, P ← N * E * S * W)
    end

    return InfinitePEPS(A)
end

"""
    InfinitePEPS(Pspace, Nspace, Espace)

Allow users to pass in single space.
"""
function InfinitePEPS(Pspace::S, Nspace::S, Espace::S=Nspace) where {S<:ElementarySpace}
    Pspaces = Array{S,2}(undef, (1, 1))
    Pspaces[1, 1] = Pspace
    Nspaces = Array{S,2}(undef, (1, 1))
    Nspaces[1, 1] = Nspace
    Espaces = Array{S,2}(undef, (1, 1))
    Espaces[1, 1] = Espace
    return InfinitePEPS(Pspaces, Nspaces, Espaces)
end

"""
    InfinitePEPS(d, D)

Allow users to pass in integers.
"""
function InfinitePEPS(d::Integer, D::Integer)
    T = [TensorMap(rand, ComplexF64, ℂ^d ← ℂ^D ⊗ ℂ^D ⊗ (ℂ^D)' ⊗ (ℂ^D)')]
    return InfinitePEPS(Array(reshape(T, (1, 1))))
end

function InfinitePEPS(d::Integer, D::Integer, L::Integer)
    T = [TensorMap(rand, ComplexF64, ℂ^d ← ℂ^D ⊗ ℂ^D ⊗ (ℂ^D)' ⊗ (ℂ^D)')]
    return InfinitePEPS(Array(repeat(T, L,L)))
end

function InfinitePEPS(d::Integer, D::Integer, Ls::Tuple{Integer,Integer})
    T = [TensorMap(rand, ComplexF64, ℂ^d ← ℂ^D ⊗ ℂ^D ⊗ (ℂ^D)' ⊗ (ℂ^D)')]
    return InfinitePEPS(Array(repeat(T, Ls...)))
end


## Shape and size
Base.size(T::InfinitePEPS) = size(T.A)
Base.size(T::InfinitePEPS, i) = size(T.A, i)
Base.length(T::InfinitePEPS) = length(T.A)
Base.eltype(T::InfinitePEPS) = eltype(eltype(T.A))

## Copy
Base.copy(T::InfinitePEPS) = InfinitePEPS(copy(T.A))
Base.similar(T::InfinitePEPS) = InfinitePEPS(similar(T.A))
Base.repeat(T::InfinitePEPS, counts...) = InfinitePEPS(repeat(T.A, counts...))

Base.getindex(T::InfinitePEPS, args...) = getindex(T.A, args...);
TensorKit.space(t::InfinitePEPS, i, j) = space(t[i, j], 1)


Base.rotl90(t::InfinitePEPS) = InfinitePEPS(rotl90(rotl90.(t.A)));
