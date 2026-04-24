include("funcionesutiles.jl")

# Parámetros de ejemplo: A=1, B=1, a=3, b=2, desfase δ=π/2
A, B = 1.0, 1.0
a, b = 3, 2
δ = π/2

# Generar la curva
x, y = lissajous(A, B, a, b, δ)


#graficar
graficar(x,y,"Curva de Lissajous (a=3, b=2, δ=π/2)", "x", "y")