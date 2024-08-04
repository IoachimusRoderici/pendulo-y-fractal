"""
En este módulo se definen las transformaciones de coordenadas
y otras operaciones asociadas.
"""
module Coordenadas

using DynamicalSystems

export esféricas_a_cartesianas,
       esféricas_a_cartesianas_proyectadas,
       posición_proyectada

using ...VectorAliases

"""
Recibe coordenadas esféricas y las convierte a cartesianas xy.
"""
function esféricas_a_cartesianas_proyectadas(θφ, r)
    θ, φ = θφ
    x = r * sin(θ) * cos(φ)
    y = r * sin(θ) * sin(φ)
    return Vector2D(x, y)
end

"""
Recibe coordenadas esféricas y las convierte a cartesianas.
"""
function esféricas_a_cartesianas(θφ, r)
    θ, φ = θφ
    x = r * sin(θ) * cos(φ)
    y = r * sin(θ) * sin(φ)
    z = r * cos(θ)
    return Vector3D(x, y, z)
end

"""
Devuelve las coordenadas xy actuales del sistema.
"""
posición_proyectada(sistema) = esféricas_a_cartesianas_proyectadas(current_state(sistema)[1:2], current_parameter(sistema, :longitud))

end