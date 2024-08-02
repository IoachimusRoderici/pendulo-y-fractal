using StaticArrays, DynamicalSystems, GLMakie

include("../VectorAliases.jl")
using .VectorAliases

include("../modelo/Modelo.jl")
using .Modelo

include("GUI.jl")
using .GUI

"""
Simula el péndulo con sólo la gravedad.
"""
function test_gravedad(; estado_inicial = Vector4D(1, 0, 0, 1),
                         params = (g=9.8, longitud=0.35)
                      )
    f = Modelo.función_de_evolución(Campos.gravedad)
    sistema = CoupledODEs(f, estado_inicial, params)
    GUI.trayectoria_animada(sistema)
end

c = test_gravedad()
c.avanzando[] = true
c.fig