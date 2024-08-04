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
- fig: La figura.
- avanzando: El observable que controla si el sistema está avanzando.
- donde: índices del layout de la figura donde poner los controles.

Devuelve una NamedTuple con los objetos asociados.
"""
function agregar_controles!(fig, avanzando; donde=(2,1))
    layout = fig[donde...] = GridLayout(tellwidth = false)

    # Agregar botón de pausa:
    label = @lift $avanzando ? "pausa" : "avanzar"
    botón_pausa = Button(fig; label, tellwidth=false)
    on(botón_pausa.clicks) do _
        avanzando[] = !avanzando[]
    end

    layout[1,1] = botón_pausa

    return (; layout, botón_pausa)
end

"""
Genera una animación de la trayectoria del sistema dado.
- sistema:          El sistema a animar.
- controles:        La ubicación de los controles en el layout de la figura, o nothing para no incluirlos.
- time_step_exact:  Dice si los pasos de tiempo tienen que ser exactos.
- figure_kwargs:    Se pasa al constructor de Figure.
- axis_kwargs:      Se pasa al constructor de Axis.
- hide_decorations: Se pasa a hide_decorations.

Devuelve una NamedTuple con todos los objetos asociados:
- sistema:         El sistema (Observable).
- fig, ax:         La figura y el eje.
- time_step:       La cantidad de tiempo que el sistema avanza entre frames.
- time_correction: Corrección en el tiempo dormido entre frames (se suma al time_step).
- pasos:           La cantidad de pasos (frames) que avanzó la animación.
- avanzando:       true si la animación está avanzando, false si no.
- pos:             La posición actual (en coordenadas xy), y su plot.
- trayectoria:     La trayectoria del sistema, y su plot.
- controles:       Los objetos asociados a los controles.
"""
function trayectoria_animada(sistema;
                             controles = (2, 1),
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
    pos_plot = scatter!(objetos.ax, objetos.pos)
    pos = (; observable = objetos.pos, plot = pos_plot)

    # Agregar los controles:
    if !isnothing(controles)
        objetos_de_los_controles = agregar_controles!(objetos.fig, objetos.avanzando, donde=controles)
    else
        objetos_de_los_controles = nothing
    end

    return (; objetos..., pos, trayectoria, controles=objetos_de_los_controles)
end

"""
Crea  los primeros objetos necesarios para graficar el sistema.
- sistema: el sistema a animar.
- time_step_exact dice si los pasos de tiempo tienen que ser exactos.
- figure_kwargs se pasa al constructor de Figure.
- axis_kwargs se pasa al constructor de Axis.
- hide_decorations se pasa a hide_decorations.

Devuelve una NamedTuple con:
- sistema:         El sistema (Observable).
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

    time_step = Observable(0.005)
    pasos = get_observable_evolucionador(sistema_observable, time_step; exact=time_step_exact)
    pos = get_posición_proyectada_observable(sistema_observable)
    
    # Crear la figura:
    medio_ancho = 1.1 * current_parameter(sistema, :longitud) # valor por defecto, puede ser cambiado después.
    fig, ax = get_trajectory_figure(; medio_ancho, figure_kwargs, axis_kwargs, hide_decorations)

    time_correction, avanzando = agregar_bucle_de_animación(time_step, pasos, fig)

    return (; sistema=sistema_observable, pos, avanzando,
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