# Pendulo y Fractal

Recreando la simulación de [mi video favorito](https://www.youtube.com/watch?v=C5Jkgvw-Z6E) de YouTube.

## El Sistema a Ser Simulado

El sistema que queremos simular es un péndulo formado por una bola de metal ferromagnético que cuelga de un hilo sobre tres imanes:

![foto](figures/foto_del_experimento.png)

El sistema tiene muchos parámetros que podrían ser variados y/o generalizados. Definimos el siguiente conjunto de valores como la configuración canónica:

- Longitud del péndulo: 35 cm
- Altura del péndulo: 36 cm
- Masa del péndulo: TBD
- Número de imanes: 3
- Distribución de los imanes: triangular centrada, radio 10 cm
- Intensidad de los imanes: TBD

## Coordenadas

Definimos el origen de coordenadas en el punto fijo del péndulo.

El sistema de coordenadas cartesianas tiene los ejes $x$ e $y$ en el plano horizontal y el eje $z$ apuntando hacia arriba.

Pero las cuentas se hacen en corrdenadas esféricas.
El sistema de coordenadas esféricas mide $\theta$ desde el eje $-z$ hacia arriba, y $\varphi$ desde el eje $x$ hacia el eje $y$.

![sistema de coordenadas](figures/coordenadas.png)

El estado del sistema está definido por la posición y velocidad del péndulo. Esta información se representa en un `Vector4D`:

$$
\mathbf{u} = (\theta, \varphi, \dot{\theta}, \dot{\varphi})
$$