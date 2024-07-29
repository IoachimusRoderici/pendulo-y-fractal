"""
En este módulo se definen las transformaciones de coordenadas
y otras operaciones asociadas.
"""
module Coordenadas

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
Recibe el vector de estado y el radio, y devuelve las coordenadas xy actuales.
"""
function posición_proyectada(estado, radio)
    return esféricas_a_cartesianas_proyectadas(estado[1:2], radio)
end

end