abstract type ARCH{T} end
struct CPU{T} <: ARCH{T} end
struct GPU{T} <: ARCH{T} end
CPU() = CPU{Float64}()
GPU() = GPU{Float32}()


adapt_storage(::ARCH{T}, x::AbstractFloat) where T = T(x)
adapt_storage(::ARCH{T}, x::Complex) where T = Complex{T}(x)
adapt_storage(::ARCH{T}, x::StepRangeLen) where T = range(T(first(x)), T(last(x)), x.len)
adapt_storage(::CPU{T}, x::Array) where T = Array{T}(x)
adapt_storage(::GPU{T}, x::Array) where T = CuArray{T}(x)
adapt_storage(::CPU{T}, x::Array{TA}) where {T, TA<:Complex} = Array{Complex{T}}(x)
adapt_storage(::GPU{T}, x::Array{TA}) where {T, TA<:Complex} = CuArray{Complex{T}}(x)
adapt_storage(::ARCH{T}, x::SVector{N}) where {N,T} = SVector{N,T}(x)


function adapt_storage(::CPU{T}, p::cFFTWPlan) where T
    tmp = zeros(Complex{T}, p.sz)
    return plan_fft!(tmp, p.region)
end

function adapt_storage(::GPU{T}, p::cFFTWPlan) where T
    tmp = CUDA.zeros(Complex{T}, p.sz)
    return plan_fft!(tmp, p.region)
end


function adapt_storage(to::CPU, p::Union{DHTPlan, CuDHTPlan})
    (; N, R, V, J, TT, Atmp, Ipre, Ipos, Itot) = p
    R = adapt_storage(to, R)
    V = adapt_storage(to, V)
    J = adapt_storage(to, J)
    TT = adapt_storage(to, TT)
    Atmp = adapt_storage(to, Atmp)
    return DHTPlan(N, R, V, J, TT, Atmp, Ipre, Ipos, Itot)
end

function adapt_storage(to::GPU, p::Union{DHTPlan, CuDHTPlan})
    (; N, R, V, J, TT, Atmp, Ipre, Ipos, Itot) = p
    R = adapt_storage(to, R)
    V = adapt_storage(to, V)
    J = adapt_storage(to, J)
    TT = adapt_storage(to, TT)
    Atmp = adapt_storage(to, Atmp)
    return CuDHTPlan(N, R, V, J, TT, Atmp, Ipre, Ipos, Itot)
end
