struct Field{T, TE}
    # units:
    Eu :: T
    Iu :: T
    # frequency and wavelength:
    w0 :: T
    lam0 :: T
    # field:
    E :: TE
end

@adapt_structure Field


function Field(E; Eu=nothing, Iu=nothing, n0=nothing, w0=nothing, lam0=nothing)
    if isnothing(n0)
        @warn "Since n0 is not defined, assume n0=1."
        n0 = 1
    end

    if isnothing(Eu) && isnothing(Iu)
        error("You have to define either Eu or Iu.")
    elseif !isnothing(Eu) && !isnothing(Iu)
        if !isapprox(Eu, sqrt(Iu / (real(n0) * EPS0 * C0 / 2)))
            error("Eu does not match Iu.")
        end
    elseif isnothing(Eu)
        Eu = sqrt(Iu / (real(n0) * EPS0 * C0 / 2))
    elseif isnothing(Iu)
        Iu = real(n0) * EPS0 * C0 / 2 * Eu^2
    end

    if isnothing(w0) && isnothing(lam0)
        error("Either w0, either lam0 have to be defined.")
    elseif !isnothing(w0) && !isnothing(lam0)
        if !isapprox(w0, 2 * pi * C0 / lam0 )
            error("w0 does not match lam0.")
        end
    elseif isnothing(w0)
        w0 = 2 * pi * C0 / lam0
    elseif isnothing(lam0)
        lam0 = 2 * pi * C0 / w0
    end

    # convert to complex:
    E = Array{Complex{real(eltype(E))}}(E)

    return Field(Eu, Iu, w0, lam0, E)
end
