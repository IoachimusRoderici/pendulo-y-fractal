using Revise
using StaticArrays, DynamicalSystems, GLMakie

includet("../VectorAliases.jl")
using .VectorAliases

includet("../modelo/Modelo.jl")
using .Modelo

includet("GUI.jl")
using .GUI

"""
Simula el péndulo con sólo la gravedad.
"""
function test_gravedad(; estado_inicial = Vector4D(1, 0, 0, 1),
                         params = (g=9.8, longitud=0.35)
                      )
    f = Modelo.función_de_evolución(Campos.gravedad)
    sistema = CoupledODEs(f, estado_inicial, params)
end

sistema = test_gravedad()
c = GUI.trayectoria_animada(sistema)
c.fig