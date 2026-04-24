using Plots

function esnumeropar(x)
    resultado=""
    if x % 2 == 0
        resultado="es un numero par"
    else
        resultado="es un numero impar"
    end
    return resultado
end

function esnumeroprimo(x)
    resultado="es numero primo"
    limite = 0 
    if (x < 2) || (x % 2 == 0) && (x != 2)
       resultado="no es numero primo"
    elseif x == 2
        resultado
    end
  
    if isinteger(x) && x > 0
        limite= floor(Int, sqrt(x)) 
    end

    for i = 3:2:limite + 1   
        if x % i == 0
            resultado="no es un numero primo"
        end           
    end  

    return resultado
end   

function lissajous(A, B, a, b, δ; t_range = 0:0.01:2π)
    t=collect(t_range)
    x=A * sin.(a * t .+ δ)
    y=B * sin.(b * t)
    return x, y
end 

function graficar(x, y, titulo, xEtiqueta, yEtiqueta)
    resultado=plot(x, y, 
                   title = titulo, 
                   xlabel = xEtiqueta, ylabel = yEtiqueta, 
                   aspect_ratio =:equal, 
                   linewidth = 2, 
                   legend = false )
    return resultado
end