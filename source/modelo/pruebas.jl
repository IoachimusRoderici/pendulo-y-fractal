using StaticArrays, DynamicalSystems

include("../VectorAliases.jl")
using .VectorAliases

include("Modelo.jl")
using .Modelo

"""
Simula el péndulo con sólo la gravedad.
"""
function test_gravedad(; estado_inicial = Vector4D(1, 0, 0, 0),
                         params = (g=9.8, longitud=0.35),
                         tiempo = 5)

    f = Modelo.función_de_evolución(Campos.gravedad)
    sistema = CoupledODEs(f, estado_inicial, params)

    proyección = (estado) -> Modelo.esféricas_a_cartesianas(estado[1:2], params.longitud)
    sistema_proyectado = ProjectedDynamicalSystem(sistema, proyección, (x)->estado_inicial)

    return trajectory(sistema_proyectado, tiempo, estado_inicial)
end