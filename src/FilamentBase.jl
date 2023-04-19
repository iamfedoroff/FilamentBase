module FilamentBase


import Adapt: adapt_storage, @adapt_structure
import CUDA: CUDA, @cuda, launch_configuration, threadIdx, blockIdx, blockDim,
             gridDim, CuArray, CuVector
import FFTW: fft!, plan_fft!, cFFTWPlan
import HankelTransforms: DHTPlan, CuDHTPlan, dhtcoord
import HDF5
import Printf: @printf, @sprintf
import StaticArrays: SVector


using PhysicalConstants.CODATA2018
const C0 = SpeedOfLightInVacuum.val
const EPS0 = VacuumElectricPermittivity.val


export @krun, mulvec!, CPU, GPU,
       GridR, GridT, GridRT, GridXY, GridXYT, Field, Medium,
       guard, refractive_index, k_func, k1_func, k2_func, phase_velocity,
       group_velocity, diffraction_length, dispersion_length, absorption_length,
       chi1_func, chi3_func, critical_power, nonlinearity_length,
       selffocusing_length,
       OutputTXT, OutputHDF, writetxt, writehdf

CUDA.allowscalar(false)

include("util.jl")
include("adapters.jl")
include("grids.jl")
include("fields.jl")
include("media.jl")
include("guards.jl")
include("outputs/zdata.jl")
include("outputs/hdf.jl")
include("outputs/txt.jl")


end
