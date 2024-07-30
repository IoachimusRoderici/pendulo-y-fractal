"""
En este módulo se definen las funciones relacionadas a los
gráficos de la simulación, interactivos o no.
"""
module GUI

using Makie, DynamicalSystems, DataStructures

include("../Coordenadas.jl")
using .Coordenadas


"""
Genera una animación de la trayectoria del sistema dado.
- sistema: el sistema a animar.
- figure_kwargs se pasa al constructor de Figure.
- axis_kwargs se pasa al constructor de Axis.
- hide_decorations se pasa a hide_decorations.

Devuelve un diccionario con todos los objetos asociados, que son mutables y pueden
ser modificados para configurar la animación:
- sistema, params: El sistema y sus parámetros.
- fig, ax:         La figura y el eje.
- ancho:           La mitad del ancho de la figura (en unidades del sistema).
- time_step:       La cantidad de tiempo que el sistema avanza entre frames.
- time_correction: Corrección en el tiempo dormido entre frames (se suma al time_step).
- paso:            La cantidad de pasos (frames) que avanzó la animación.
- pos:             La posición actual (en coordenadas xy).
- avanzando:       true si la animación está avanzando, false si no.
"""
function trayectoria_animada(sistema;
                             figure_kwargs = NamedTuple(),
                             axis_kwargs = NamedTuple(),
                             hide_decorations = NamedTuple()
                            )
    parámetros = current_parameters(sistema)

    # Crear Observables para evolucionar el sistema y seguir su estado:
    time_step = Observable(0.01) # valor por defecto, puede ser cambiado después.
    pasos = evolucionador(sistema, time_step)
    posición = lift(pasos) do pasos
        Point2f(posición_proyectada(current_state(sistema), parámetros.longitud))
    end
    
    # Crear la figura:
    medio_ancho = 1.1 * parámetros.longitud # valor por defecto, puede ser cambiado después.
    fig, ax = get_trajectory_figure(; medio_ancho, figure_kwargs, axis_kwargs, hide_decorations)
    scatter!(ax, posición)

    # Bucle principal de la animación, controlado por el valor de avanzando:
    time_correction = Observable(0.0) # valor por defecto, puede ser cambiado después.
    avanzando = Observable(false)
    on(avanzando) do _
        @async while avanzando[]
            pasos[] += 1
            sleep(time_step[] + time_correction[])

            isopen(fig.scene) || (avanzando[] = false)
        end
    end

    return Dict(:sistema         => sistema,
                :params          => parámetros,
                :fig             => fig,
                :ax              => ax,
                :time_step       => time_step,
                :time_correction => time_correction,
                :paso            => pasos,
                :pos             => posición,
                :avanzando       => avanzando
               )
end

"""
Devuelve un observable que al ser notificado hace avanzar al sistema
un tiempo time_step_obs (que es un observable).

El valor del observable devuelto es el número de pasos.
"""
function evolucionador(sistema, time_step_obs)
    pasos = Observable(0)
    on(pasos) do _
        step!(sistema, time_step_obs[])
    end

    return pasos
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