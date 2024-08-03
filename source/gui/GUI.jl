"""
En este módulo se definen las funciones relacionadas a los gráficos de la
simulación, interactivos o no.

La mayoría de las funciones devuelven NamedTuples con todos los objetos
asociados al sistema, los gráficos, y la animación, que son mutables y
pueden ser modificados para configurar las cosas, o bien son Observables
y pueden ser modificados y notificados para actualizar cosas.
"""
module GUI

using Makie, DynamicalSystems, DataStructures

include("../Coordenadas.jl")
using .Coordenadas

include("mis_observables.jl")

"""
Agrega controles a la animación de la trayectoria.

"""
function agregar_controles!(objetos)
    label = lift(objetos.avanzando) do avanzando
        avanzando ? "pausa" : "avanzar"
    end
    boton = Button(objetos.fig; label, tellwidth=false)

    on(boton.clicks) do _
        objetos.avanzando[] = !objetos.avanzando[]
    end

    objetos.fig[2, 1][1,1] = boton

    return boton
end

"""
Genera una animación de la trayectoria del sistema dado.
- sistema: el sistema a animar.
- time_step_exact dice si los pasos de tiempo tienen que ser exactos.
- figure_kwargs se pasa al constructor de Figure.
- axis_kwargs se pasa al constructor de Axis.
- hide_decorations se pasa a hide_decorations.

Devuelve una NamedTuple con todos los objetos asociados:
- sistema, params: El sistema y sus parámetros.
- fig, ax:         La figura y el eje.
- time_step:       La cantidad de tiempo que el sistema avanza entre frames.
- time_correction: Corrección en el tiempo dormido entre frames (se suma al time_step).
- pasos:           La cantidad de pasos (frames) que avanzó la animación.
- pos:             La posición actual (en coordenadas xy).
- avanzando:       true si la animación está avanzando, false si no.
- punto_actual:    NamedTuple con el markersize y el plot del punto actual.
- trayectoria:     NamedTuple con los objetos asociados al plot de la trayectoria.
"""
function trayectoria_animada(sistema;
                             time_step_exact = false,
                             figure_kwargs = NamedTuple(),
                             axis_kwargs = NamedTuple(),
                             hide_decorations = NamedTuple()
                            )
    objetos = get_sistema_animado(sistema; time_step_exact, figure_kwargs, axis_kwargs, hide_decorations)

    # Plotear la trayectoria:
    trayectoria_observable = get_trayectoria_observable(objetos.pos)
    trayectoria_plot = lines!(objetos.ax, trayectoria_observable)
    trayectoria = (; observable = trayectoria_observable, plot = trayectoria_plot)


    # Plotear la posición actual:
    markersize = Observable(10)
    punto_actual_plot = scatter!(objetos.ax, objetos.pos; markersize)
    punto_actual = (; markersize, plot = punto_actual_plot)

    return (; objetos..., punto_actual, trayectoria)
end

"""
Crea  los primeros objetos necesarios para graficar el sistema.
- sistema: el sistema a animar.
- time_step_exact dice si los pasos de tiempo tienen que ser exactos.
- figure_kwargs se pasa al constructor de Figure.
- axis_kwargs se pasa al constructor de Axis.
- hide_decorations se pasa a hide_decorations.

Devuelve una NamedTuple con:
- sistema, params: El sistema (Observable) y sus parámetros.
- pos:             La posición actual (en coordenadas xy).
- avanzando:       true si la animación está avanzando, false si no. (valor inicial: false)
- fig, ax:         La figura y el eje de la trayectoria.
- time_step:       La cantidad de tiempo que el sistema avanza entre frames.
- time_correction: Corrección en el tiempo dormido entre frames (se suma al time_step).
- pasos:           La cantidad de pasos (frames) que avanzó la animación.
"""
function get_sistema_animado(sistema;
                             time_step_exact = false,
                             figure_kwargs = NamedTuple(),
                             axis_kwargs = NamedTuple(),
                             hide_decorations = NamedTuple()
                            )
    # Crear Observables para evolucionar el sistema y seguir su estado:
    sistema_observable = Observable(sistema)
    params = current_parameters(sistema)

    time_step = Observable(0.005)
    pasos = get_observable_evolucionador(sistema_observable, time_step; exact=time_step_exact)
    pos = get_posición_proyectada_observable(sistema_observable, params)
    
    # Crear la figura:
    medio_ancho = 1.1 * params.longitud # valor por defecto, puede ser cambiado después.
    fig, ax = get_trajectory_figure(; medio_ancho, figure_kwargs, axis_kwargs, hide_decorations)

    time_correction, avanzando = agregar_bucle_de_animación(time_step, pasos, fig)

    return (; sistema=sistema_observable, params, pos, avanzando,
              fig, ax, time_step, time_correction, pasos)
end

"""
Construye la figura usada para plotear la trayectoria.
- medio_ancho es la mitad del ancho del plot.
- figure_kwargs se pasa al constructor de Figure.
- axis_kwargs se pasa al constructor de Axis.
- hide_decorations se pasa a hide_decorations.

Devuelve fig, ax.
"""
function get_trajectory_figure(; medio_ancho,
                                 figure_kwargs = NamedTuple(),
                                 axis_kwargs = NamedTuple(),
                                 hide_decorations = NamedTuple()
                              )
    fig = Figure(; size = (600, 600), figure_kwargs...)
    ax = Axis(fig[1,1]; aspect=1, limits = centered_square_limits(medio_ancho), axis_kwargs...)

    hidedecorations!(ax, hide_decorations...)

    return fig, ax
end


"""
Devuelve los límites que hay que pasar a Axis para que el plot
sea un cuadrado centrado en el origen, de tamaño half_width.
"""
centered_square_limits(half_width) = ((-half_width, half_width), (-half_width, half_width))

end #module GUI