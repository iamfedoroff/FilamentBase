struct OutVar{S, T}
    name :: S
    siunit :: S
    unit :: T
end


struct OutputTXT{S}
    fname :: S
    nvars :: Int
end


function OutputTXT(fname, ovars)
    if !isdir(dirname(fname))
        mkpath(dirname(fname))
    end

    open(fname, "w") do fp
        # names:
        write(fp, "#")
        for ovar in ovars
            @printf(fp, " %-18s", ovar.name)
        end
        write(fp, "\n")

        # SI units:
        write(fp, "#")
        for ovar in ovars
            @printf(fp, " %-18s", ovar.siunit)
        end
        write(fp, "\n")

        # dimensionless units:
        write(fp, "#")
        for ovar in ovars
            @printf(fp, " %-18s", ovar.unit)
        end
        write(fp, "\n")
    end

    return OutputTXT(fname, length(ovars))
end


function OutputTXT(fname, grid::GridR, field; zu)
    (; ru) = grid
    (; Iu) = field
    ovars = (
        OutVar("z", "m", zu),
        OutVar("Imax", "W/m^2", Iu),
        OutVar("rad", "m", ru),
        OutVar("P", "W", ru^2 * Iu),
    )
    return OutputTXT(fname, ovars)
end


function OutputTXT(fname, grid::GridT, field; zu, neu=1)
    (; tu) = grid
    (; Iu) = field
    ovars = (
        OutVar("z", "m", zu),
        OutVar("Imax", "W/m^2", Iu),
        OutVar("nemax", "1/m^3", neu),
        OutVar("tau", "s", tu),
        OutVar("F", "J/m^2", tu * Iu),
    )
    return OutputTXT(fname, ovars)
end


function OutputTXT(fname, grid::GridRT, field; zu, neu=1)
    (; ru, tu) = grid
    (; Iu) = field
    ovars = (
        OutVar("z", "m", zu),
        OutVar("Imax", "W/m^2", Iu),
        OutVar("Fmax", "J/m^2", tu * Iu),
        OutVar("nemax", "1/m^3", neu),
        OutVar("rad", "m", ru),
        OutVar("tau", "s", tu),
        OutVar("W", "J", tu * ru^2 * Iu),
    )
    return OutputTXT(fname, ovars)
end


function OutputTXT(fname, grid::GridXY, field; zu)
    (; xu, yu) = grid
    (; Iu) = field
    ovars = (
        OutVar("z", "m", zu),
        OutVar("Imax", "W/m^2", Iu),
        OutVar("radx", "m", xu),
        OutVar("rady", "m", yu),
        OutVar("P", "W", xu * yu * Iu),
    )
    return OutputTXT(fname, ovars)
end


function OutputTXT(fname, grid::GridXYT, field; zu, neu=1)
    (; xu, yu, tu) = grid
    (; Iu) = field
    ovars = (
        OutVar("z", "m", zu),
        OutVar("Imax", "W/m^2", Iu),
        OutVar("Fmax", "J/m^2", tu * Iu),
        OutVar("nemax", "1/m^3", neu),
        OutVar("radx", "m", xu),
        OutVar("rady", "m", yu),
        OutVar("tau", "s", tu),
        OutVar("W", "J", xu * yu * tu * Iu),
    )
    return OutputTXT(fname, ovars)
end


function writetxt(out::OutputTXT, pvals)
    if length(pvals) != out.nvars
        error("Wrong number of plot values.")
    end
    open(out.fname, "a") do fp
        write(fp, "  ")
        for pval in pvals
            @printf(fp, "%18.12e ", pval)
        end
        write(fp, "\n")
    end
    return nothing
end
