[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=17800725&assignment_repo_type=AssignmentRepo)
# Entrega 1 del proyecto WP01

## Introducción

El proyecto consiste en el diseño e implementación del juego clásico Tetris utilizando una FPGA. Este proyecto tiene como objetivo combinar el aprendizaje de lógica digital, diseño hardware y generación de gráficos en tiempo real. La FPGA se encargará de gestionar la lógica del juego, renderizar los gráficos y recibir entradas del usuario.

## Objetivos

- Implementar la lógica del juego de Tetris (generación de piezas, movimiento, rotación y colisiones).

- Diseñar una interfaz gráfica sencilla utilizando una salida VGA.

- Permitir la interacción del usuario mediante botones.

- Implementar un contador de puntaje.

## Especificaciones del Proyecto

### Lógica del Juego

1. **Tablero:**

- Dimensiones: 10 columnas x 20 filas.

- Representación en memoria interna de la FPGA mediante una matriz de bits.

2. **Piezas:**

- Siete piezas típicas de Tetris almacenadas como configuraciones predefinidas en ROM.

3. **Comportamiento:**

- Movimiento horizontal (izquierda/derecha).

- Rotación en sentido horario.

- Descenso automático con velocidad ajustable.

- Eliminación de filas completas.

4. **Puntaje y niveles:**

- Incremento de puntos por filas eliminadas.

- Aumento de velocidad a medida que suben los niveles.

### Interfaz Gráfica

1. **Salida VGA:**

- Representación del tablero y piezas con bloques de colores.

2. **Visualización:**

- Tablero de juego.

- Puntaje actual y nivel.

- Próxima pieza a aparecer.

### Entradas del Usuario

1. **Botones:**

- Arriba: Rotar pieza.

- Izquierda/Derecha: Mover pieza.

- Abajo: Acelerar descenso.

### Módulos Principales

1. **Módulo de Control:**

- Gestiona las entradas del usuario y actualiza el estado del juego.

2. **Módulo VGA:**

- Genera las señales de sincronización.

- Renderiza el tablero y las piezas.

3. **Módulo de Piezas:**

- Controla la generación y movimiento de las piezas.

4. **Módulo de Puntaje:**

- Calcula y almacena el puntaje y nivel del jugador.

## Diagrama de Bloques
  
![image](https://github.com/user-attachments/assets/16e0f57b-bdc9-4e8a-9f5b-a4ca5bcd0c87)

## Plan de Trabajo

**Semana 1:**

- Investigación y diseño inicial del proyecto.

- Configuración del entorno de desarrollo.

**Semana 2:**

- Implementación del módulo VGA.

- Generación del tablero en la salida VGA.

**Semana 3:**

- Implementación de la lógica de control de piezas.

- Pruebas de movimiento y rotación de piezas.

**Semana 4:**

- Implementación del sistema de puntaje y niveles.

- Integración de todos los módulos.

**Semana 5:**

- Pruebas finales y depuración.

## Referencias

- Implementación de una interfaz VGA sobre FPGA - Avelino Herrera (https://avelinoherrera.com/blog/index.php?m=10&y=17&entry=entry171025-151846)

- VGA Retro Sprites and Sound Synthesis - DE0-NANO (https://www.fpgalover.com/boards/de0-nano/89-vga-retro-sprites-and-sound-synthesis)

- Implementación de diferentes proyectos en FPGA - MIT (https://fpga.mit.edu/6205/F24/final_project_archive)

- Tetris on FPGA - Pascal Heinen DutLUG (https://www.youtube.com/watch?v=6E06bwA18ik)
