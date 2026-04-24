# ============================================================
#  Julia + CUDA.jl - OPTIMIZADO para máxima velocidad GPU
#  Requiere: ] add CUDA,BenchmarkTools
# ============================================================

using CUDA
using BenchmarkTools

println("¿CUDA disponible? ", CUDA.functional())

# Benchmark OPTIMIZADO para N=1M (sin transferencias CPU→GPU)
N = 1_000_000
println("\n📏 N = ", N, " elementos")

# Generar DIRECTO en GPU (¡clave para velocidad!)
a_gpu = CUDA.rand(Float32, N)
b_gpu = CUDA.rand(Float32, N)

# CPU (con transferencias)
t_cpu = @belapsed begin
    a_cpu = Array(a_gpu)
    b_cpu = Array(b_gpu)
    _ = a_cpu .+ b_cpu
end

# GPU Puro (sin transferencias)
t_gpu = @belapsed CUDA.@sync($a_gpu .+ $b_gpu)

accel = t_cpu / t_gpu
println("CPU:  $(round(t_cpu*1000, digits=3)) ms")
println("GPU:  $(round(t_gpu*1000, digits=3)) ms")
println(" $(round(accel, digits=1))×")

# Liberar memoria
CUDA.unsafe_free!(a_gpu)
CUDA.unsafe_free!(b_gpu)

free_mem, total_mem = CUDA.memory_info()
println("\nVRAM libre:  $(round(free_mem/1024^3, digits=2)) GB")