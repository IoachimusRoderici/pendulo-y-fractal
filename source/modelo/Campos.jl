"""
En este módulo se definen los distintos campos de aceleración que actúan o pueden
actuar sobre el péndulo. Las explicaciones están en el README.md de este directorio.

Para cada campo se definen dos métodos: uno que recibe como primer argumento el
vector de estado y como keyword arguments los parámetros que necesita, y otro que
recibe como primer argumento el vector de estado y como segundo argumento un contenedor
de parámetros.

El contenedor de parámetros es una estructura, tupla nombrada, o similar, que contiene
los parámetros del modelo.

Todos los campos devuelven un Vector2D con la aceleración en coordenadas (θ, φ).

La lista completa de campos implementados es:
- gravedad
"""
module Campos

using ..VectorAliases

"""
Devuelve la aceleración del péndulo a causa de la gravedad.
g: aceleración de la gravedad, m/s².
"""
function gravedad(estado; g)
    θ = estado[1]
    a_θ = -g*sin(θ)
    return Vector2D(a_θ, 0)
end

gravedad(estado, parámetros) = gravedad(estado; parámetros.g)

end #module Campos