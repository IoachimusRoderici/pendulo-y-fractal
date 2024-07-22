module EcuacionesDeMovimiento

using ..VectorAliases

export ecuación_de_movimiento

"""
Recibe un campo de aceleración y devuelve la función
(u, p, t) -> du/dt
"""
function ecuación_de_movimiento(aceleración)
    function estado_derivado(estado, params, t)
        θ, φ, dθ, dφ = estado
        a_θ, a_φ = aceleración(estado; params)

        ddθ = a_θ/params.r + dφ^2 * sin(θ) * cos(θ)
        ddφ = (a_φ/params.r - 2 * dθ * dφ * cos(θ))

        return Vector4D(dθ, dφ, ddθ, ddφ)
    end

    return estado_derivado
end
    
end #module EcuacionesDeMovimiento