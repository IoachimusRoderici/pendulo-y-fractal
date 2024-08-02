"""
En este archivo se definen funciones para crear Observables
de el sistema y de los gráficos y animación.
"""

"""
Devuelve un Observable de la posición del sistema, proyectada a
coordenadas xy, como un Point2f.
- sistema: el sistema a observar.
- parámetros: los parámetros del sistema
"""
function get_posición_proyectada_observable(sistema_observable, parámetros)
    lift(sistema_observable) do sistema
        Point2f(posición_proyectada(current_state(sistema), parámetros.longitud))
    end
end

"""
Devuelve un observable que al ser notificado hace avanzar al sistema
un tiempo time_step_obs (que es un observable).

exact determina si la cantidad de tiempo que se evoluciona en cada
paso es exacta o aproximada.

El observable devuelto también sirve como contador de pasos.
"""
function get_observable_evolucionador(sistema_obsevable, time_step_obs; exact=false)
    pasos = Observable(0)
    on(pasos) do _
        step!(sistema_obsevable[], time_step_obs[], exact)
        notify(sistema_obsevable)
    end

    return pasos
end

"""
Crea un bucle de animación asíncrono que incrementa el contador de pasos
y espera el tiempo entre frames, haciendo que la animación avance en tiempo
(más o menos) real.

Argumentos:
- time_step_obs: Observable del tiempo avanzado por el sistema en cada frame.
- pasos:         Observable con el contador de pasos.
- fig:           La figura donde está la animación.

El tiempo de espera entre frames es igual a time_step más una corrección por
el tiempo de cómputo.

Devuelve dos nuevos Observables:
- time_correction: Corrección en el tiempo dormido entre frames (se suma al time_step).
- avanzando:       true si la animación está avanzando, false si no. (valor inicial: false)

El bucle se reinicia cada vez que se notifica a avanzando, y se corta cuando el valor
de avanzando es false o cuando se cierra la figura.
"""
function agregar_bucle_de_animación(time_step_obs, pasos, fig)
    time_correction = Observable(0.0)
    avanzando = Observable(false)

    on(avanzando) do _
        @async while avanzando[]
            pasos[] += 1
            sleep(time_step_obs[] + time_correction[])

            isopen(fig.scene) || (avanzando[] = false)
        end
    end

    return time_correction, avanzando
end

"""
Devuelve un Observable de un Vector{Point2f} que guarda la trayectoria.
"""
function get_trayectoria_observable(posición_observable)
    trayectoria = Observable([posición_observable[]])
    
    on(posición_observable) do posición
        push!(trayectoria[], posición)
        notify(trayectoria)
    end

    return trayectoria
end