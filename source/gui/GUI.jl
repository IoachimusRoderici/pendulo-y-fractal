"""
En este módulo se definen las funciones relacionadas a los
gráficos de la simulación, interactivos o no.
"""
module GUI

using Makie, DynamicalSystems, DataStructures

include("../Coordenadas.jl")
using .Coordenadas


"""
Genera una animación interactiva de la trayectoria del sistema dado.
- sistema: el sistema a animar.
- time_step: intervalo de tiempo usado para la integración.
- medio_ancho: la mitad del ancho del plot.
- figure_kwargs se pasa al constructor de Figure.
- axis_kwargs se pasa al constructor de Axis.
- hide_decorations se pasa a hide_decorations.
"""
function trayectoria_interactiva(sistema;
                                 medio_ancho = nothing,
                                 time_step = 0.01,
                                 figure_kwargs = NamedTuple(),
                                 axis_kwargs = NamedTuple(),
                                 hide_decorations = NamedTuple()
                                )
    #sistema = non_adaptive(sistema, time_step)
    parámetros = current_parameters(sistema)

    if isnothing(medio_ancho)
        medio_ancho = 1.1parámetros.longitud
    end

    fig, ax = get_trajectory_figure(; medio_ancho, figure_kwargs, axis_kwargs, hide_decorations)
    
    paso = Observable(0)
    on(paso) do paso
        step!(sistema, time_step)
    end

    estado_actual = lift(paso) do paso
        current_state(sistema)
    end

    posición = lift(estado_actual) do estado_actual
        Point2f(posición_proyectada(estado_actual, parámetros.longitud))
    end

    scatter!(ax, posición)

    going = Observable(false)
    on(going) do going
        @async for i in 1:1000
            paso[] = paso[] + 1
        end
    end

    return Dict(:fig=>fig, :ax=>ax, :paso=>paso, :estado=>estado_actual, :pos=>posición, :going=>going)
end

"""
Devuelve una copia sel sistema dado, modificada para que la evolución
en el tiempo no sea adaptive.
dt es el paso de tiempo que se usa para evolucionar el nuevo sistema.
"""
function non_adaptive(sistema, dt)
    newdiffeq = (sistema.diffeq..., adaptive = false, dt = dt)
    return CoupledODEs(sistema, newdiffeq)
end

"""
Construye la figura usada para plotear la trayectoria.
- medio_ancho es la mitad del ancho del plot.
- figure_kwargs se pasa al constructor de Figure.
- axis_kwargs se pasa al constructor de Axis.
- hide_decorations se pasa a hide_decorations.

Devuelve (fig, ax).
"""
function get_trajectory_figure(; medio_ancho,
                                 figure_kwargs = NamedTuple(),
                                 axis_kwargs = NamedTuple(),
                                 hide_decorations = NamedTuple()
                              )
    fig = Figure(; size = (650, 650), figure_kwargs...)
    ax = Axis(fig[1,1]; aspect=1, limits = centered_square_limits(medio_ancho), axis_kwargs...)

    hidedecorations!(ax, hide_decorations...)

    return fig, ax
end


"""
Devuelve los límites que hay que pasar a Axis para que el plot
sea un cuadrado centrado en el origen, de tamaño half_width.
"""
centered_square_limits(half_width) = ((-half_width, half_width), (-half_width, half_width))

"""
Plotea la trayectoria como una línea que crece indefinidamente.
"""
function plot_complete_trajectory(ax)
    
end

end #module GUI