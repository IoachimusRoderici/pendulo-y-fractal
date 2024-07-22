module Campos
"""
En este módulo se definen los distintos campos de aceleración que actuan o pueden
atuar sobre el péndulo.

Todos los campos reciben como primer argumento el estado del péndulo en un Vector4D
con (θ, φ, dθ/dt, dφ/dt), y como keyword arguments los parámetros que necesiten.

Todos los campos devuelven un Vector2D en coordenadas (θ, φ) con la aceleración.
"""

using ..VectorAliases

"""
Devuelve la aceleración del péndulo a causa de la gravedad.
g: aceleración de la gravedad, m/s².
"""
function gravedad(estado; params)
    θ = estado[1]
    a_θ = -params.g*sin(θ)
    return Vector2D(a_θ, 0)
end

end #module Campos