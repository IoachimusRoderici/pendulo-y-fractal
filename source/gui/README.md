# GUI

En este directorio se definen las funciones para graficar, animar, e interactuar con la simulación.

Esto incluye (eventualmente) tres componentes:
- El plot del espacio donde está la trayectoria y demás.
- Plots de timeseries para debuggear.
- Controles y sliders.

En este momento está implementado el primer punto con el plot de la trayectoria. El segundo punto no está implementado en absoluto, y del tercero hay solamente un botón de pausa y un botón para borrar la línea de la trayectoria.

El siguiente paso debería ser agregar un observable que informe la velocidad de la simulación (Δt del sistema sobre Δt del reloj), y dos sliders para controlar `time_step` y `time_correction`.