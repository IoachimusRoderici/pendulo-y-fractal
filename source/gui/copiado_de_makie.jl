function interactive_trajectory(
    sistema,
    paramtros_del_sistema,
    estado_inicial = [DynamicalSystems.current_state(sistema)];
    # Selection of what to plot
    indices_a_plotear = [1, 2]
    # Time evolution
    tail_length = 1000,
    time_step = 0.01,
    pause = nothing,
    # Visualization
    colors = collect(cgrad(COLORSCHEME, length(estado_inicial); categorical = true)),
    plot_kwargs = NamedTuple(),
    markersize = 15,
    fade = 0.5,
    # parameters
    parameter_sliders = nothing,
    parameter_names = isnothing(parameter_sliders) ? nothing : Dict(keys(parameter_sliders) .=> parameter_name.(keys(parameter_sliders))),
    add_controls = true,
    # figure and axis
    figure_kwargs = (size = (800, 800),),
    axis_kwargs = NamedTuple(),
    ancho_del_plot = paramtros_del_sistema.longitud,
    starting_step = 1,
)

    sistema = non_adaptive(sistema, time_step)

    parametros_originales = initial_parameters(sistema)
    estado_original = deepcopy(estado_inicial)

    sistemas_paralelos = DynamicalSystems.ParallelDynamicalSystem(sistema, estado_inicial)
    u00s = deepcopy(current_states(sistemas_paralelos))

    # Set up trajectrory plot
    fig = Figure(; figure_kwargs...)
    statespacelayout = fig[1,1] = GridLayout()
    lims = ((-ancho_del_plot, ancho_del_plot), (-ancho_del_plot, ancho_del_plot))
    tail = get_tail(sistema, tail_length)
    final_point = Observable(tail[][end])
    statespaceax = Axis(statespacelayout[1,1], axis_kwargs...)
    tailobs, finalpoints = _init_statespace_plot!(statespacelayout, sistema, indices_a_plotear,
        lims, sistemas_paralelos, colors, plot_kwargs, markersize, tail, axis_kwargs, fade)
    # Set up layouting and add controls
    if add_controls # Notice that `run` and `step` are already observables
        reset, run, step, stepslider = _trajectory_plot_controls!(
            statespacelayout, statespace_axis, starting_step
        )
    else
        # So that we can leave the interactive UI code as is
        reset = Observable(0); run = Observable(0); step = Observable(0); stepslider = Observable(1)
    end

    # Create the dynamical system observable now with these linked
    parameter_observable = Observable(deepcopy(current_parameters(sistema)))
    sistema_observable = DynamicalSystemObservable(sistemas_paralelos, finalpoints, tailobs, parameter_observable, Observable(0), time_step)

    # Functionality of live evolution. This links all observables with triggers.
    # The run button just triggers the step button perpetually
    isrunning = Observable(false)
    on(run) do c; isrunning[] = !isrunning[]; end
    on(run) do c
        @async while isrunning[]
            step[] = step[] + 1
            isopen(fig.scene) || break # ensures computations stop if closed window
            isnothing(pause) ? yield() : sleep(pause)
        end
    end
    # while the actual observables triggering happens from the step button
    on(step) do clicks
        n = stepslider[]
        # which of course calls the stepping function on the observable
        step!(sistema_observable, n)
    end
    # Resetting system to initial states
    on(reset) do clicks
        for j in eachindex(u00s)
            set_state!(sistema_observable, copy(u00s[j]), j)
        end
    end

    # Live parameter changing
    # note here `parameter_sliders` are parameters to have a slider; all parameters
    # can be changed after creation of `dso` via `set_parameter!`
    if !isnothing(parameter_sliders)
        paramlayout = fig[2, :] = GridLayout(tellheight = true, tellwidth = false)
        slidervals, sliders = _add_ds_param_controls!(
            sistema, paramlayout, parameter_sliders, parameter_names, current_parameters(sistema)
        )
        update = Button(fig, label = "update", tellwidth = false, tellheight = true)
        urs = Button(fig, label = "u.r.s.", tellwidth = false, tellheight = true)
        resetp = Button(fig, label = "reset p", tellwidth = false, tellheight = true)
        gl = paramlayout[2, :] = GridLayout()
        gl[1,1] = update
        gl[1,2] = urs
        gl[1,3] = resetp
        # what happens when the update button gets pressed
        on(update.clicks) do clicks
            for l in keys(slidervals)
                v = slidervals[l][]
                set_parameter!(sistema_observable, l, v)
            end
        end
        # what happens when the u.r.s. button gets pressed
        on(urs.clicks) do clicks
            update.clicks[] = update.clicks[] + 1 # click update button
            reset[] = reset[] + 1 # click reset button
            step[] = step[] + 1 # click step button
        end
        # what happens when the reset p button gets pressed
        on(resetp.clicks) do clicks
            # first, reset actual dynamical system parameters
            set_parameters!(sistemas_paralelos, parametros_originales)
            # then also **visually** reset sliders to initial parameters
            for (k, slider) in sliders # remember sliders is a dictionary
                p0k = current_parameter(sistema, k, parametros_originales)
                set_close_to!(slider, p0k)
            end
        end
    end

    return fig, sistema_observable
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
Devuelve (un observable de) un buffer circular de estados para la trayectoria
del sistema.
"""
function get_tail(sistema, tail_length)
    T = typeof(current_state(sistema))
    buffer = CircularBuffer{T}(tail_length)
    fill!(buffer, current_state(sistema))
    tail = Observable(buffer)
end