"""
En este módulo se implementa el modelo mecánico del péndulo,
que está explicado en el README.md de este directorio.

Los campos de aceleración están definidos en el submódulo `Campos`.
"""
module Modelo

export Campos

using ..VectorAliases

include("../Coordenadas.jl")
using .Coordenadas

include("Campos.jl")
using .Campos

"""
Recibe un campo de aceleración y devuelve la función de evolución del sistema,
 f(u, p, t) -> du/dt.

La función devuelta asume que `parámetros` tiene el campo `longitud` (longitud
del péndulo, m), además de los campos que requiera el campo de aceleración dado.
"""
function función_de_evolución(aceleración)
    function estado_derivado(estado, parámetros, t)
        θ, φ, dθ, dφ = estado
        a_θ, a_φ = aceleración(estado, parámetros)

        ddθ = a_θ/parámetros.longitud + dφ^2 * sin(θ) * cos(θ)
        ddφ = (a_φ/parámetros.longitud - 2 * dθ * dφ * cos(θ)) / sin(θ)

        return Vector4D(dθ, dφ, ddθ, ddφ)
    end

    return estado_derivado
end

end #module Modelo