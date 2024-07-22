# Ecuaciones de Movimiento

Acá se definen las ecuaciones de movimiento del péndulo, basandose en los
campos de aceleración definidos en `../campos`.

## Cinemática, Newton, y eso

Las ecuaciones de movimiento del péndulo se obtienen de:

$$
\mathbf{F} = m \cdot \mathbf{a}
$$

Esta ecuación se simplifica dividiendo por la masa:
$$
\frac{\mathbf{F}}{m} = \mathbf{a}
$$

El lado izquierdo de la ecuación es el campo de aceleración debido a las fuerzas externas, y se calcula con las funciones definidas en `../campos`.

El lado derecho de la ecuación es la aceleración. Según [Wikipedia](https://en.wikipedia.org/wiki/Spherical_coordinate_system#Kinematics) la aceleración, escrita en coordenadas esféricas y considerando que el radio es constante, queda así:

$$
\mathbf{a} =
r(\ddot{\theta} - \dot{\varphi}^2 \sin{\theta} \cos{\theta})\cdot \mathbf{e_\theta}
+ r(\ddot{\varphi} \sin{\theta} + 2\ \dot{\theta}\ \dot{\varphi}\ \cos{\theta}) \cdot \mathbf{e_\varphi}
$$

Separando esta ecuación en las dos componentes ($\theta$ y $\varphi$), podemos despejar $\ddot{\theta}$ y $\ddot{\varphi}$:

$$
\ddot{\theta} = \frac{a_\theta}{r} + \dot{\varphi}^2\sin{\theta}\cos{\theta}
$$

$$
\ddot{\varphi} = \frac{1}{\sin{\theta}} \left( \frac{a_\varphi}{r} - 2\ \dot{\theta}\ \dot{\varphi} \cos{\theta} \right)
$$

## Derivada del vector de estado

Las librerías de ecuaciones diferenciales requieren que describamos el sistema con una ecuación de la forma $\dot{\mathbf{u}} = f(\mathbf{u}, t, p \dots)$, donde $\mathbf{u}$ es el vector de estado, $t$ es el tiempo, y $p\dots$ son los parámetros el sistema.

En nuestro caso, el vector de estado es $\mathbf{u} = (\theta, \varphi, \dot{\theta}, \dot{\varphi})$, y su derivada es $\dot{\mathbf{u}} = (\dot{\theta}, \dot{\varphi}, \ddot{\theta}, \ddot{\varphi})$, donde $\ddot{\theta}$ y $\ddot{\varphi}$ se calculan según las ecuaciones de arriba y dependen del estado actual y del campo de aceleración elegido.