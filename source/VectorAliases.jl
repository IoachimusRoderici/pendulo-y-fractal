"""
En este módulo se definen aliases cómodos para vectores de números reales.

Se asume que se importó StaticArrays antes de cargar este módulo.
"""
module VectorAliases

using ..StaticArrays

export VectorND, Vector2D, Vector3D, Vector4D

const VectorND{N} = SVector{N, Float64}
const Vector2D = VectorND{2}
const Vector3D = VectorND{3}
const Vector4D = VectorND{4}

end