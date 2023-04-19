struct Medium{T, FE, FM}
    permittivity :: FE
    permeability :: FM
    n2 :: T
    N0 :: T
end


function Medium(permittivity, permeability; n2=0, N0=1)
    n2, N0 = promote(n2, N0)
    return Medium(permittivity, permeability, n2, N0)
end


function refractive_index(medium, w)
    eps = medium.permittivity(abs(w))
    mu = medium.permeability(abs(w))
    n = sqrt(eps * mu + 0im)
    return n
end


function k_func(medium, w)
    n = refractive_index(medium, w)
    return n * abs(w) / C0
end


function k1_func(medium, w)
    func(w) = k_func(medium, w)
    return derivative1(func, w)
end


function k2_func(medium, w)
    func(w) = k_func(medium, w)
    return derivative2(func, w)
end


function phase_velocity(medium, w)
    n = refractive_index(medium, w)
    return C0 / real(n)
end


function group_velocity(medium, w)
    k1 = real(k1_func(medium, w))
    return 1 / k1
end


function diffraction_length(medium, w, a0)
    k = real(k_func(medium, w))
    return k * a0^2
end


function dispersion_length(medium, w, t0)
    k2 = real(k2_func(medium, w))
    if k2 == 0
        zdisp = Inf
    else
        zdisp = t0^2 / abs(k2)
    end
    return zdisp
end


function absorption_length(medium, w)
    ga = imag(k_func(medium, w))
    if ga == 0
        za = Inf
    else
        za = ga / 2
    end
    return za
end


function chi1_func(medium, w)
    eps = medium.permittivity(abs(w))
    return eps - 1
end

function chi3_func(medium, w)
    (; n2) = medium
    n = refractive_index(medium, w)
    return 4/3 * real(n)^2 * EPS0 * C0 * n2
end


function critical_power(medium, w; Rcr=3.79)
    (; n2) = medium
    lam = 2 * pi * C0 / abs(w)
    n = refractive_index(medium, w)
    return Rcr * lam^2 / (8*pi * abs(real(n)) * abs(real(n2)))
end


function nonlinearity_length(medium, w, I0)
    (; n2) = medium
    if real(n2) == 0
        znl = Inf
    else
        znl = 1 / (abs(real(n2)) * I0 * w / C0)
    end
    return znl
end


"""Self-focusing distance by the Marburger formula (P in watts)."""
function selffocusing_length(medium, w, a0, P)
    zd = diffraction_length(medium, w, a0)
    PPcr = P / critical_power(medium, w)
    if PPcr > 1
        zf = 0.367 * zd / sqrt((sqrt(PPcr) - 0.852)^2 - 0.0219)
    else
        zf = Inf
    end
    return zf
end


"""
N-th derivative of a function f at a point x.

The derivative is found using five-point stencil:
    http://en.wikipedia.org/wiki/Five-point_stencil
Additional info:
    http://en.wikipedia.org/wiki/Finite_difference_coefficients
"""
function derivative1(f, x)
    x == 0 ? h = 0.01 : h = 0.001 * x
    return (f(x-2*h) - 8*f(x-h) + 8*f(x+h) - f(x+2*h)) / (12*h)
end
function derivative2(f, x)
    x == 0 ? h = 0.01 : h = 0.001 * x
    return (-f(x-2*h) + 16*f(x-h) - 30*f(x) + 16*f(x+h) - f(x+2*h)) / (12*h^2)
end
