using StaticArrays, DynamicalSystems, GLMakie

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
    return ProjectedDynamicalSystem(sistema, proyección, (x)->estado_inicial)
end

sistema_proyectado = test_gravedad()
sistema_sin_proyectar = sistema_proyectado.ds

interactive_trajectory_timeseries(s.ds, [1,2,3,4], [Vector4D(1,0,0,1), Vector4D(1,0,0,0)],
                                  idxs=(1,3), timeseries_names=["θ", "φ", "dθ/dt", "dφ/dt"],
                                  axis=(xlabel="θ", ylabel="dθ/dt"))[1]