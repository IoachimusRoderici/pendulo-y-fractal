"""
En este archivo se definen funciones para crear Observables
de el sistema y de los gráficos y animación.
"""

"""
Devuelve un Observable de la posición del sistema, proyectada a
coordenadas xy, como un Point2f.
"""
get_posición_proyectada_observable(sistema) = @lift Point2f(posición_proyectada($sistema))

"""
Devuelve un observable que al ser notificado hace avanzar al sistema
un tiempo time_step_obs (que es un observable).

exact determina si la cantidad de tiempo que se evoluciona en cada
paso es exacta o aproximada.

El observable devuelto también sirve como contador de pasos.
"""
function get_observable_evolucionador(sistema_observable, time_step_obs; exact=false)
    pasos = Observable(0)
    on(pasos) do _
        step!(sistema_observable[], time_step_obs[], exact)
        notify(sistema_observable)
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

"""
Calls empty! on the contents of an Observable, followed by notify.
"""
function Base.empty!(obs::Observable)
    empty!(obs[])
    notify(obs)
    return nothing
end

"""
Devuelve un medidor de la velocidad a la que avanza el sistema y su animación.
- sistema_observable: El sistema cuya velocidad se va a medir.
- buffer_length:      La cantidad de frames que se usan para calcular la velocidad.

El objeto devuelto es un Observable de una NamedTuple con:
- velocidad_relativa: Cociente entre el tiempo avanzado por el sistema y el tiempo avanzado por el reloj.
- framerate:          El framerate de la animación, en fps.
"""
function get_medidor_de_velocidad(sistema_observable; buffer_length=20)
    # Vamos a guardar en un buffer circular los tiempos de cada frame (tiempo del sistema y del reloj):
    NamedTupleDeTiempos = @NamedTuple{del_sistema::Float64, del_reloj::Float64}
    buffer = CircularBuffer{NamedTupleDeTiempos}(buffer_length)

    # Y vamos a usar esos tiempos para para calcular nuestro Observable:
    velocidades = lift(sistema_observable) do sistema
        # Poner los últimos tiempos en el buffer:
        tiempo_actual = (del_sistema = current_time(sistema), del_reloj = time())
        push!(buffer, tiempo_actual)

        # Calcular la velocidad:
        tiempo_anterior = first(buffer)
        Δt_sistema = tiempo_actual.del_sistema - tiempo_anterior.del_sistema
        Δt_reloj = tiempo_actual.del_reloj - tiempo_anterior.del_reloj

        if Δt_reloj != 0
            velocidad_relativa = Δt_sistema / Δt_reloj
            framerate = buffer_length / Δt_reloj
        else
            velocidad_relativa = 0.0
            framerate = 0.0
        end

        return (; velocidad_relativa, framerate)
    end
    
    return velocidades
end
