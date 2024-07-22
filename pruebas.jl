using StaticArrays, DynamicalSystems

include("source/VectorAliases.jl")
using .VectorAliases

include("source/campos/Campos.jl")
using .Campos

include("source/ecuaciones_de_movimiento/EcuacionesDeMovimiento.jl")
using .EcuacionesDeMovimiento

eom = ecuación_de_movimiento(Campos.gravedad)
params = (g=9.9, r=0.3)
estado = Vector4D(1, 0, 0, 0)
sistema = CoupledODEs(eom, estado, params)

trayectoria, tiempo = trajectory(sistema, 3)