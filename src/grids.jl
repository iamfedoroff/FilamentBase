abstract type Grid end


# ******************************************************************************
# R
# ******************************************************************************
struct GridR{T, GR} <: Grid
    # number of grid points:
    Nr :: Int
    # units:
    ru :: T
    # domain size:
    rmax :: T
    # Grid points:
    r :: GR
    # Grid spacing:
    dr :: GR
end

@adapt_structure GridR


function GridR(; rmax, Nr, ru=1)
    r = dhtcoord(rmax, Nr)

    dr = zeros(Nr)
    dr[1] = r[2] - r[1]
    for i=2:Nr-1
        dr[i] = (r[i+1] - r[i-1]) / 2
    end
    dr[Nr] = r[Nr] - r[Nr-1]

    ru, rmax = promote(ru, rmax)
    return GridR(Nr, ru, rmax, r, dr)
end


# ******************************************************************************
# T
# ******************************************************************************
struct GridT{T, G} <: Grid
    # number of grid points:
    Nt :: Int
    # units:
    tu :: T
    # domain size:
    tmin :: T
    tmax :: T
    # grid points:
    t :: G
    # grid spacing:
    dt :: T
end

@adapt_structure GridT


function GridT(; tmin, tmax, Nt, tu=1)
    t = range(tmin, tmax, Nt+1)[1:Nt]
    dt = t[2] - t[1]
    tu, tmin, tmax, dt = promote(tu, tmin, tmax, dt)
    return GridT(Nt, tu, tmin, tmax, t, dt)
end


# ******************************************************************************
# RT
# ******************************************************************************
struct GridRT{T, GR, GT} <: Grid
    # number of grid points:
    Nr :: Int
    Nt :: Int
    # units:
    ru :: T
    tu :: T
    # domain size:
    rmax :: T
    tmin :: T
    tmax :: T
    # Grid points:
    r :: GR
    t :: GT
    # Grid spacing:
    dr :: GR
    dt :: T
end

@adapt_structure GridRT


function GridRT(; rmax, Nr, tmin, tmax, Nt, ru=1, tu=1)
    r = dhtcoord(rmax, Nr)

    dr = zeros(Nr)
    dr[1] = r[2] - r[1]
    for i=2:Nr-1
        dr[i] = (r[i+1] - r[i-1]) / 2
    end
    dr[Nr] = r[Nr] - r[Nr-1]

    t = range(tmin, tmax, Nt+1)[1:Nt]
    dt = t[2] - t[1]

    ru, tu, rmax, tmin, tmax, dt = promote(ru, tu, rmax, tmin, tmax, dt)
    return GridRT(Nr, Nt, ru, tu, rmax, tmin, tmax, r, t, dr, dt)
end


# ******************************************************************************
# XY
# ******************************************************************************
struct GridXY{T, G} <: Grid
    # number of grid points:
    Nx :: Int
    Ny :: Int
    # units:
    xu :: T
    yu :: T
    # domain size:
    xmin :: T
    xmax :: T
    ymin :: T
    ymax :: T
    # Grid points:
    x :: G
    y :: G
    # Grid spacing:
    dx :: T
    dy :: T
end

@adapt_structure GridXY


function GridXY(; xmin, xmax, Nx, ymin, ymax, Ny, xu=1, yu=1)
    x = range(xmin, xmax, Nx+1)[1:Nx]
    y = range(ymin, ymax, Ny+1)[1:Ny]
    dx = x[2] - x[1]
    dy = y[2] - y[1]
    xu, yu, xmin, xmax, ymin, ymax, dx, dy =
        promote(xu, yu, xmin, xmax, ymin, ymax, dx, dy)
    return GridXY(Nx, Ny, xu, yu, xmin, xmax, ymin, ymax, x, y, dx, dy)
end


# ******************************************************************************
# XYT
# ******************************************************************************
struct GridXYT{T, G} <: Grid
    # number of grid points:
    Nx :: Int
    Ny :: Int
    Nt :: Int
    # units:
    xu :: T
    yu :: T
    tu :: T
    # domain size:
    xmin :: T
    xmax :: T
    ymin :: T
    ymax :: T
    tmin :: T
    tmax :: T
    # Grid points:
    x :: G
    y :: G
    t :: G
    # Grid spacing:
    dx :: T
    dy :: T
    dt :: T
end

@adapt_structure GridXYT


function GridXYT(
    ; xmin, xmax, Nx, ymin, ymax, Ny, tmin, tmax, Nt, xu=1, yu=1, tu=1,
)
    x = range(xmin, xmax, Nx+1)[1:Nx]
    y = range(ymin, ymax, Ny+1)[1:Ny]
    t = range(tmin, tmax, Nt+1)[1:Nt]
    dx = x[2] - x[1]
    dy = y[2] - y[1]
    dt = t[2] - t[1]
    xu, yu, tu, xmin, xmax, ymin, ymax, tmin, tmax, dx, dy, dt =
        promote(xu, yu, tu, xmin, xmax, ymin, ymax, tmin, tmax, dx, dy, dt)
    return GridXYT(
        Nx, Ny, Nt, xu, yu, tu, xmin, xmax, ymin, ymax, tmin, tmax, x, y, t,
        dx, dy, dt,
    )
end
