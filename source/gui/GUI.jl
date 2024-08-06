"""
En este módulo se definen las funciones relacionadas a los gráficos de la
simulación, interactivos o no.

La mayoría de las funciones devuelven NamedTuples con todos los objetos
asociados al sistema, los gráficos, y la animación, que son mutables y
pueden ser modificados para configurar las cosas, o bien son Observables
y pueden ser modificados y notificados para actualizar cosas.
"""
module GUI

using Makie, DynamicalSystems, DataStructures, Format

include("../Coordenadas.jl")
using .Coordenadas

include("mis_observables.jl")

"""
Agrega controles a la animación de la trayectoria.
- fig:             La figura.
- sistema:         Observable del sistema.
- avanzando:       El observable que controla si el sistema está avanzando.
- trayectoria:     El observable de la trayectoria.
- time_step:       El observable del tiempo avanzado en cada frame.
- time_correction: El observable de la corrección a time_step.
- donde:           Índices del layout de la figura donde poner los controles.

Devuelve una NamedTuple con los objetos creados.
"""
function agregar_controles!(fig, sistema, avanzando, trayectoria, time_step, time_correction; donde=(2,1))
    buttoncolor = :lightblue1
    layout = GridLayout(fig[donde...], tellwidth = false)

    # Botón de pausa:
    label = @lift $avanzando ? "Pausa" : "Avanzar"
    botón_pausa = layout[1,1] = Button(fig; label, buttoncolor, width=65)

    on(botón_pausa.clicks) do _
        avanzando[] = !avanzando[]
    end

    # Botón para borrar la trayectoria:
    botón_borrar_trayectoria = layout[1,2] = Button(fig; label="Borrar Trayectoria", buttoncolor)
    on(botón_borrar_trayectoria.clicks) do _
        empty!(trayectoria)
    end

    # Medidor de velocidad:
    velocidades = get_medidor_de_velocidad(sistema, buffer_length=100)
    texto = @lift format("{1:.1f}X  {2:0>3.0f}fps", $velocidades.velocidad_relativa, $velocidades.framerate)
    texto_velocidades = Label(layout[1,3], texto, fontsize=17)

    # Sliders de tiempo:
    time_correction_range = @lift -$time_step:0.001:0.05
    sliders = SliderGrid(layout[2,:],
                         (label="Speed Correction", range=time_correction_range, startvalue=time_correction[], format="{:.3f}s")
                        )
    repeat!(time_correction, sliders.sliders[1].value)

    return (; layout, botón_pausa, botón_borrar_trayectoria, texto_velocidades, sliders)
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
        objetos_de_los_controles = agregar_controles!(objetos.fig, objetos.sistema, objetos.avanzando, trayectoria_observable, objetos.time_step, objetos.time_correction, donde=controles)
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