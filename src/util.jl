macro krun(ex...)
    N = ex[1]
    call = ex[2]
    args = call.args[2:end]
    @gensym kernel config threads blocks
    code = quote
        local $kernel = @cuda launch=false $call
        local $config = launch_configuration($kernel.fun)
        local $threads = min($config.threads, $N)
        local $blocks = min($config.blocks, cld($N, $threads))
        $kernel($(args...); threads=$threads, blocks=$blocks)
    end
    return esc(code)
end


function mulvec!(A::AbstractArray, b; dim::Int=1)
    @. A *= b
    return nothing
end


function mulvec!(A::AbstractArray, b::Vector; dim::Int=1)
    ci = CartesianIndices(A)
    for ici in eachindex(ci)
        idim = ci[ici][dim]
        A[ici] *= b[idim]
    end
    return nothing
end


function mulvec!(A::CuArray, b::CuVector; dim::Int=1)
    N = length(A)
    @krun N mulvec_kernel!(A, b, dim)
    return nothing
end
function mulvec_kernel!(A, b, dim)
    id = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    stride = blockDim().x * gridDim().x
    ci = CartesianIndices(A)
    for ici=id:stride:length(ci)
        idim = ci[ici][dim]
        A[ici] *= b[idim]
    end
    return nothing
end


function radius(func::Function, t, u; level=exp(-1))
    ulevel = maximum(func, u) * level
    i1 = findfirst(x -> func(x) >= ulevel, u)
    i2 = findlast(x -> func(x) >= ulevel, u)
    return (abs(t[i1]) + abs(t[i2])) / 2
end


radius(t, u; level=exp(-1)) = radius(identity, t, u; level)


function linterp(xi, x, y)
    if xi <= x[1]
        i = 1
    elseif xi >= x[end]
        i = length(x) - 1
    else
        i = searchsortedfirst(x, xi) - 1
    end
    dydx = (y[i+1] - y[i]) / (x[i+1] - x[i])
    return y[i] + dydx * (xi - x[i])
end
