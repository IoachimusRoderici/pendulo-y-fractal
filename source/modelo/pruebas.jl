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

    indices_a_observar = [1,2,3,4]
    estados_iniciales = [Vector4D(1,0,0,1), Vector4D(1,0,0,0)]
    interactive_trajectory_timeseries(sistema, indices_a_observar, estados_iniciales;
                                      idxs=(1,3),
                                      timeseries_names=["θ", "φ", "dθ/dt", "dφ/dt"],
                                      axis=(xlabel="θ", ylabel="dθ/dt"))[1] 
end

