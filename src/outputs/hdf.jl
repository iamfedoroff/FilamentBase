mutable struct OutputHDF{S, T, TE, F, Z}
    fname :: S
    ihdf :: Int
    zhdf :: T
    dzhdf :: T
    E :: TE
    func :: F
    zdata :: Z
end


function OutputHDF(
    fname, grid::GridR, field; zu, z, dzhdf, func=identity, zvars=nothing,
)
    (; ru, rmax, Nr, r) = grid
    (; Eu, Iu, E) = field

    if !isdir(dirname(fname))
        mkpath(dirname(fname))
    end

    HDF5.h5open(fname, "w") do fp
        fp["units/ru"] = ru
        fp["units/zu"] = zu
        fp["units/Eu"] = Eu
        fp["units/Iu"] = Iu
        fp["grid/rmax"] = rmax
        fp["grid/Nr"] = Nr
        fp["grid/r"] = collect(r)
        HDF5.create_group(fp, "field")
    end

    ihdf = 1
    zhdf = z
    zhdf, dzhdf = promote(zhdf, dzhdf)

    if !isnothing(zvars)
        zdata = ZData(fname, field, z, zvars)
    else
        zdata = nothing
    end

    return OutputHDF(fname, ihdf, zhdf, dzhdf, E, func, zdata)
end


function OutputHDF(
    fname, grid::GridT, field; zu, z, dzhdf, func=identity, zvars=nothing,
)
    (; tu, tmin, tmax, Nt, t) = grid
    (; Eu, Iu, E) = field

    if !isdir(dirname(fname))
        mkpath(dirname(fname))
    end

    HDF5.h5open(fname, "w") do fp
        fp["units/tu"] = tu
        fp["units/zu"] = zu
        fp["units/Eu"] = Eu
        fp["units/Iu"] = Iu
        fp["grid/tmin"] = tmin
        fp["grid/tmax"] = tmax
        fp["grid/Nt"] = Nt
        fp["grid/t"] = collect(t)
        HDF5.create_group(fp, "field")
    end

    ihdf = 1
    zhdf = z
    zhdf, dzhdf = promote(zhdf, dzhdf)

    if !isnothing(zvars)
        zdata = ZData(fname, field, z, zvars)
    else
        zdata = nothing
    end

    return OutputHDF(fname, ihdf, zhdf, dzhdf, E, func, zdata)
end


function OutputHDF(
    fname, grid::GridRT, field; zu, z, dzhdf, func=identity, zvars=nothing,
)
    (; ru, tu, rmax, Nr, tmin, tmax, Nt, r, t) = grid
    (; Eu, Iu, E) = field

    if !isdir(dirname(fname))
        mkpath(dirname(fname))
    end

    HDF5.h5open(fname, "w") do fp
        fp["units/ru"] = ru
        fp["units/tu"] = tu
        fp["units/zu"] = zu
        fp["units/Eu"] = Eu
        fp["units/Iu"] = Iu
        fp["grid/rmax"] = rmax
        fp["grid/Nr"] = Nr
        fp["grid/tmin"] = tmin
        fp["grid/tmax"] = tmax
        fp["grid/Nt"] = Nt
        fp["grid/r"] = collect(r)
        fp["grid/t"] = collect(t)
        HDF5.create_group(fp, "field")
    end

    ihdf = 1
    zhdf = z
    zhdf, dzhdf = promote(zhdf, dzhdf)

    if !isnothing(zvars)
        zdata = ZData(fname, field, z, zvars)
    else
        zdata = nothing
    end

    return OutputHDF(fname, ihdf, zhdf, dzhdf, E, func, zdata)
end


function OutputHDF(
    fname, grid::GridXY, field; zu, z, dzhdf, func=identity, zvars=nothing,
)
    (; xu, yu, xmin, xmax, Nx, ymin, ymax, Ny, x, y) = grid
    (; Eu, Iu, E) = field

    if !isdir(dirname(fname))
        mkpath(dirname(fname))
    end

    HDF5.h5open(fname, "w") do fp
        fp["units/xu"] = xu
        fp["units/yu"] = yu
        fp["units/zu"] = zu
        fp["units/Eu"] = Eu
        fp["units/Iu"] = Iu
        fp["grid/xmin"] = xmin
        fp["grid/xmax"] = xmax
        fp["grid/Nx"] = Nx
        fp["grid/ymin"] = ymin
        fp["grid/ymax"] = ymax
        fp["grid/Ny"] = Ny
        fp["grid/x"] = collect(x)
        fp["grid/y"] = collect(y)
        HDF5.create_group(fp, "field")
    end

    ihdf = 1
    zhdf = z
    zhdf, dzhdf = promote(zhdf, dzhdf)

    if !isnothing(zvars)
        zdata = ZData(fname, field, z, zvars)
    else
        zdata = nothing
    end

    return OutputHDF(fname, ihdf, zhdf, dzhdf, E, func, zdata)
end


function OutputHDF(
    fname, grid::GridXYT, field; zu, z, dzhdf, func=identity, zvars=nothing,
)
    (; xu, yu, tu, xmin, xmax, Nx, ymin, ymax, Ny, tmin, tmax, Nt,
       x, y, t) = grid
    (; Eu, Iu) = field

    if !isdir(dirname(fname))
        mkpath(dirname(fname))
    end

    HDF5.h5open(fname, "w") do fp
        fp["units/xu"] = xu
        fp["units/yu"] = yu
        fp["units/tu"] = tu
        fp["units/zu"] = zu
        fp["units/Eu"] = Eu
        fp["units/Iu"] = Iu
        fp["grid/xmin"] = xmin
        fp["grid/xmax"] = xmax
        fp["grid/Nx"] = Nx
        fp["grid/ymin"] = ymin
        fp["grid/ymax"] = ymax
        fp["grid/Ny"] = Ny
        fp["grid/tmin"] = tmin
        fp["grid/tmax"] = tmax
        fp["grid/Nt"] = Nt
        fp["grid/x"] = collect(x)
        fp["grid/y"] = collect(y)
        fp["grid/t"] = collect(t)
        HDF5.create_group(fp, "field")
    end

    ihdf = 1
    zhdf = z
    zhdf, dzhdf = promote(zhdf, dzhdf)

    if !isnothing(zvars)
        zdata = ZData(fname, field, z, zvars)
    else
        zdata = nothing
    end

    return OutputHDF(fname, ihdf, zhdf, dzhdf, E, func, zdata)
end


function writehdf(out::OutputHDF, z)
    (; fname, ihdf, zhdf, dzhdf, E, func, zdata) = out
    if z >= zhdf
        dset = @sprintf("%03d", ihdf)
        @printf("Writing field dataset %s...\n", dset)

        HDF5.h5open(fname, "r+") do fp
            group = fp["field"]
            # group[dset, shuffle=true, deflate=9] = func.(collect(E))
            group[dset] = func.(collect(E))
            HDF5.attributes(group[dset])["z"] = z
        end

        out.ihdf += 1
        out.zhdf += dzhdf
    end

    if !isnothing(zdata)
        write_zdata(zdata, z)
    end
    return nothing
end
