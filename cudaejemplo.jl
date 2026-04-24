# ============================================================
#  Julia + CUDA.jl
#  Requiere: ] add CUDA
# ============================================================

using CUDA        # GPU computing
using BenchmarkTools  # para medir tiempos

# ────────────────────────────────────────────
# 1. VERIFICAR GPU DISPONIBLE
# ────────────────────────────────────────────
println("¿CUDA disponible? ", CUDA.functional())
CUDA.versioninfo()   # muestra driver, toolkit, GPU detectada


# ────────────────────────────────────────────
# 2. TRANSFERENCIA CPU → GPU
# ────────────────────────────────────────────
N = 1_000_000

# Array normal en RAM
a_cpu = rand(Float32, N)
b_cpu = rand(Float32, N)

# Mover a VRAM de la GPU con cu()
a_gpu = cu(a_cpu)   # → CuArray{Float32, 1}
b_gpu = cu(b_cpu)

println("Tipo CPU: ", typeof(a_cpu))  # Array{Float32,1}
println("Tipo GPU: ", typeof(a_gpu))  # CuArray{Float32,1, CUDA.Mem.DeviceBuffer}


# ────────────────────────────────────────────
# 3. OPERACIONES AUTOMÁTICAS EN GPU
#    (Julia despacha al kernel correcto solo)
# ────────────────────────────────────────────
c_gpu = a_gpu .+ b_gpu        # suma element-wise en GPU
d_gpu = sqrt.(a_gpu) .* 2f0   # sqrt y multiplicación en GPU

# Traer resultado de vuelta a CPU
c_cpu = Array(c_gpu)
println("Primeros 5 valores: ", c_cpu[1:5])


# ────────────────────────────────────────────
# 4. KERNEL PROPIO CON @cuda
#    El corazón de CUDA: función que corre en GPU
# ────────────────────────────────────────────
function mi_kernel!(resultado, a, b)
    # Cada hilo calcula su propio índice
    i = threadIdx().x + (blockIdx().x - 1) * blockDim().x

    if i <= length(resultado)
        resultado[i] = a[i]^2 + b[i]^2   # operación custom
    end
    return nothing   # los kernels siempre retornan nothing
end

resultado_gpu = CUDA.zeros(Float32, N)

# Lanzar el kernel:
#   threads = hilos por bloque (máx 1024)
#   blocks  = cuántos bloques necesitamos para cubrir N
threads = 256
blocks  = ceil(Int, N / threads)

@cuda threads=threads blocks=blocks mi_kernel!(resultado_gpu, a_gpu, b_gpu)

# Sincronizar antes de leer (esperar que la GPU termine)
CUDA.synchronize()

println("Kernel OK. Resultado[1] = ", Array(resultado_gpu)[1])
println("Verificación CPU: ", a_cpu[1]^2 + b_cpu[1]^2)


# ────────────────────────────────────────────
# 5. BENCHMARK: CPU vs GPU
# ────────────────────────────────────────────
println("\n--- Benchmark suma de vectores ---")

# CPU
t_cpu = @belapsed $a_cpu .+ $b_cpu
println("CPU: ", round(t_cpu * 1000, digits=2), " ms")

# GPU (incluye sincronización para medir tiempo real)
t_gpu = @belapsed begin
    CUDA.@sync $a_gpu .+ $b_gpu
end
println("GPU: ", round(t_gpu * 1000, digits=3), " ms")
println("Aceleración: ", round(t_cpu / t_gpu, digits=1), "×")


# ────────────────────────────────────────────
# 6. MEMORIA: ver uso de VRAM
# ────────────────────────────────────────────
free_mem, total_mem = CUDA.memory_info()
println("\nVRAM libre:  ", round(free_mem  / 1024^3, digits=2), " GB")
println("VRAM total:  ", round(total_mem / 1024^3, digits=2), " GB")

# Liberar memoria GPU manualmente (opcional, el GC lo hace solo)
CUDA.unsafe_free!(a_gpu)
CUDA.unsafe_free!(b_gpu)