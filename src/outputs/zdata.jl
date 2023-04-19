mutable struct ZData{S, T, TZ}
    fname :: S
    ihdf :: Int
    zhdf :: T
    dzhdf :: T
    zvars :: TZ
end


function ZData(fname, field, z, zvars)
    (; w0) = field

    lam0 = 2*pi * C0 / w0

    HDF5.h5open(fname, "r+") do fp
        group = HDF5.create_group(fp, "zdata")
        HDF5.create_dataset(group, "z", Float64, ((1,), (-1,)), chunk=(100,))

        for (key, value) in zvars
            T = eltype(value)
            N = length(value)
            HDF5.create_dataset(group, key, T, ((1,N), (-1,N)), chunk=(100,N))
        end
    end

    ihdf = 1
    zhdf = z
    dzhdf = lam0 / 2
    zhdf, dzhdf = promote(zhdf, dzhdf)

    return ZData(fname, ihdf, zhdf, dzhdf, zvars)
end


function write_zdata(zdata::ZData, z)
    (; ihdf, zhdf, dzhdf, zvars) = zdata

    if z >= zhdf
        HDF5.h5open(zdata.fname, "r+") do fp
            group = fp["zdata"]

            data = group["z"]
            HDF5.set_extent_dims(data, (ihdf,))
            data[ihdf] = Float64(z)

            for (key, value) in zvars
                data = group[key]
                HDF5.set_extent_dims(data, (ihdf, length(value)))
                data[ihdf,:] = collect(value)
            end
        end

        zdata.ihdf += 1
        zdata.zhdf = z + dzhdf
    end
    return nothing
end
