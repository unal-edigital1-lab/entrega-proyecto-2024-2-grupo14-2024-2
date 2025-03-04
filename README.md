[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=17800725&assignment_repo_type=AssignmentRepo)
# Entrega del Proyecto WP01

## Introducción
<div align="justify">
Como etapa final del curso Electrónica Digital I, este proyecto busca desafiar y poner a prueba nuestros conocimientos en la integración de fundamentos y aplicaciones avanzadas de la electrónica digital. Se abordan temas clave como el diseño e implementación de circuitos secuenciales y combinacionales, máquinas de estados algorítmicas, uso de entornos de simulación y programación en Verilog. 

Para aplicar estos conocimientos, se planteó inicialmente la recreación de un juego retro en la placa Cyclone IV.

<br>
El objetivo principal es resolver los retos que presenta la programación de videojuegos en un lenguaje de bajo nivel, abarcando aspectos como el procesamiento de señales VGA, la creación de registros de memoria RAM y la implementación de lógica combinacional para las mecánicas de movimiento. Además, se integran otros componentes, como botones y switches, para permitir la interacción del usuario con el juego en tiempo real.
</div>


## Componentes Interactivos
- Switch: Funcionará como un interruptor de encendido, al estar en el estado 1, permitirá la transmisión de la señal VGA.
- Botones: Asociados al movimiento del cuadro, permite al usuario moverse por 4 direcciones.
- Display: Aquí se mostrará el puntaje obtenido durante la partida.

### Dificultades de Desarrollo
<div align="justify">
A lo largo del desarrollo del proyecto, nos enfrentamos a diversas dificultades que influyeron en la evolución de nuestra propuesta inicial. En un principio, se planteó la recreación del videojuego Tetris; sin embargo, la limitada capacidad de memoria en la FPGA presentó un desafío significativo. Para mitigar este problema, intentamos implementar un factor de escalamiento que redujera el espacio requerido para almacenar las piezas del juego. A pesar de estos esfuerzos, las restricciones de hardware hicieron inviable la ejecución eficiente del Tetris, por lo que optamos por una lógica más sencilla: el clásico juego de la serpiente (Snake), donde la longitud del personaje aumenta en función de los elementos recolectados.
<br> 
No obstante, el desarrollo del Snake también presentó desafíos. Aunque la lógica del juego parecía estar bien estructurada, la primera versión del movimiento utilizaba un método de sincronización y actualización de reloj sin requerir memoria RAM, lo que afectaba la interacción y fluidez del juego. Para abordar este problema y comprender mejor las mecánicas de movimiento, realizamos pruebas con puzles tipo laberinto, donde desarrollamos una interfaz gráfica basada en un buffer RAM y diseñamos la lógica de colisiones y desplazamiento.
</div>


### Lógica del Juego

1. **Tablero:**

- Dimensiones: 40 columnas x 30 filas.

- Representación en memoria interna de la FPGA mediante una matriz de bits.

2. **Serpiente:**

- Objeto móvil que se alarga según la cantidad de manzanas que consume.

3. **Comportamiento:**

- Movimiento en cruz a lo largo del tablero (arriba, abajo, izquierda, derecha).

- Generación de manzanas en posiciones al azar.

- Al comer una manzana, se incrementa el tamaño de la serpiente y la puntuación.

4. **Puntaje y niveles:**

- Incremento de puntos por manzanas consumidas.

- Aumento de velocidad a medida que suben los niveles.

### Interfaz Gráfica

1. **Salida VGA:**

- Representación de la serpiente y la manzana con bloques de colores.

2. **Visualización:**

- Tablero de juego.

- Puntaje actual.

### Entradas del Usuario

1. **Botones:**

- Arriba/Abajo/Izquierda/Derecha: Mover pieza.

- Reset: Reiniciar Juego.

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

# Pruebas Iniciales VGA
<div align="justify">
Pruebas iniciales en VGA

Como primer paso en nuestra investigación, realizamos pruebas para generar señales de video VGA en la FPGA. Para ello, utilizamos repositorios de GitHub como referencia y adaptamos sus implementaciones a nuestro entorno de trabajo[1].

Uno de los primeros aspectos a definir fueron los pulsos de sincronización horizontal y vertical, los cuales son esenciales para que la pantalla pueda interpretar correctamente la imagen enviada por la FPGA. Además, establecimos los parámetros necesarios para definir la resolución de la pantalla en 640x480 píxeles a 60 Hz, asegurándonos de incluir señales adicionales como los porches delantero y trasero, que permiten una transición adecuada entre cada cuadro de imagen.
<br>
A partir del datasheet de la placa Cyclone IV, identificamos que los canales de color para VGA están limitados a 3 bits de información (1 bit por cada canal RGB: rojo, verde y azul). Esto restringe la paleta de colores a solo 8 combinaciones posibles, lo cual influyó en la forma en que representamos gráficos dentro del juego.

Para validar el correcto funcionamiento de la señal VGA, implementamos un código de prueba que genera patrones de color en la pantalla, permitiendo verificar que los pulsos de sincronización y la asignación de colores funcionaran correctamente.
</div>

#### Contadores de Píxeles y Líneas

```Verilog
always @(posedge vga_clk)
begin
    if (hcount_ov)
        hcount <= 10'd0; // Reinicia el conteo al llegar al final de la línea
    else
        hcount <= hcount + 10'd1; // Incrementa el contador de píxeles
end
assign hcount_ov = (hcount == hpixel_end); // Detecta cuando se alcanza el final de la línea

always @(posedge vga_clk)
begin
    if (hcount_ov) // Solo avanza cuando se completa una línea
    begin
        if (vcount_ov)
            vcount <= 10'd0; // Reinicia el conteo al llegar al final del cuadro
        else
            vcount <= vcount + 10'd1; // Incrementa el contador de líneas
    end
end
assign  vcount_ov = (vcount == vline_end); // Detecta cuando se alcanza el final de la pantalla
```
Estos bloques generan los contadores de posición horizontal y vertical:

- hcount se incrementa con cada pulso de vga_clk hasta llegar a 799 píxeles.
- Cuando hcount llega al final de la línea (hpixel_end), se reinicia y se incrementa vcount.
- vcount cuenta las líneas de la pantalla hasta alcanzar 524 líneas, tras lo cual se reinicia.

Esto simula el escaneo progresivo de la imagen en la pantalla.
<br>

#### Generación de las Señales de Sincronización VGA 
```Verilog
assign dat_act =    ((hcount >= hdat_begin) && (hcount < hdat_end)) &&
                    ((vcount >= vdat_begin) && (vcount < vdat_end));

assign hsync = (hcount > hsync_end); // Pulso de sincronización horizontal
assign vsync = (vcount > vsync_end); // Pulso de sincronización vertical

assign disp_RGB = (dat_act) ? data : 3'h00; 
```
- dat_act determina si el píxel actual está en la zona visible de la pantalla.
- hsync y vsync generan los pulsos de sincronización para la pantalla VGA.
- disp_RGB muestra el color del píxel solo si está en la zona visible, de lo contrario, lo pone en negro (3'h00).
<br>

#### Generación de Patrones de Color
```Verilog
always @(posedge vga_clk)
begin
    case(switch[1:0])
        2'd0: data <= h_dat;         // Barras horizontales
        2'd1: data <= v_dat;         // Barras verticales
        2'd2: data <= (v_dat ^ h_dat); // Patrón de tablero de ajedrez (XOR)
        2'd3: data <= (v_dat ~^ h_dat); // Patrón de tablero invertido (XNOR)
    endcase
end
```
- Dependiendo del estado del switch, la pantalla mostrará diferentes patrones:
- Barras horizontales (h_dat).
- Barras verticales (v_dat).
- Patrón de ajedrez (XOR entre v_dat y h_dat).
- Patrón invertido de ajedrez (XNOR entre v_dat y h_dat)

A continuación nos centraremos en el módulo fsm_game. Este es el crebro detrás de todo el funcionamiento del juego. Primeramente, se tienen dos estados básicos para definir el movimiento del jugador: Cambiar a una nueva posición en la matriz, pintandola de su color, y volviendo a definir la casilla anterior como negra. Para definir la posición exacta a la que el jugador desea moverse, o conocer su ubicación en la matrix 40x30 se emplea la fórmula  pos_x + (pos_y * ANCHO_TABLERO) , donde el ancho del tablero es de 40. 

```Verilog
always @(posedge clk) begin
    if (rst) begin
        px_wr <= 0;
        fase_dibujo <= 0;  
    end else if (((pos_x != pos_old_x) || (pos_y != pos_old_y)) &&
                 (pos_x >= LIMITE_X_MIN) && (pos_x <= LIMITE_X_MAX) &&
                 (pos_y >= LIMITE_Y_MIN) && (pos_y <= LIMITE_Y_MAX)) begin
        
        if (fase_dibujo == 0) begin
            // Borra la posición anterior
            mem_px_addr <= pos_old_x + (pos_old_y * ANCHO_TABLERO);
            mem_px_data <= 3'b000; // Negro (borrar)
            fase_dibujo <= 1;  
        end else begin
            // Dibuja en la nueva posición
            mem_px_addr <= pos_x + (pos_y * ANCHO_TABLERO);    
            mem_px_data <= 3'b100; // Rojo (dibujar)
            pos_old_x <= pos_x;
            pos_old_y <= pos_y;
            fase_dibujo <= 0;  
        end
        px_wr <= 1;  
    end else begin
        px_wr <= 0;
    end
end
```

Otra función fundamental del fsm es definir las "colisiones". Ya que el laberinto se carga desde un archivo de texto, en vez de crear objetos para representar las paredes sale más rentable antes de moverse leer la memoria ram para averiguar que color se encuentra en la casilla de destino. Si no es el que se definió para camino depejado, la posición en esa dirección no podrá cambiar más. Para esto en el módulo buffer_ram se implementó un puerto de lectura exclusivo para FSM, y se programó el bloque que se presentaa continuación:

```Verilog
always @(posedge clk) begin 
    if (move_down && !move_right && !move_left && !move_up) begin
        mem_px_read_addr <= pos_x + ((pos_y+1) * ANCHO_TABLERO);
    end else if (move_up && !move_right && !move_left && !move_down) begin
        mem_px_read_addr <= pos_x + ((pos_y-1) * ANCHO_TABLERO);
    end else if (move_right && !move_up && !move_down && !move_left) begin
        mem_px_read_addr <= (pos_x+1) + (pos_y * ANCHO_TABLERO);
    end else if (move_left && !move_up && !move_down && !move_right) begin
        mem_px_read_addr <= (pos_x-1) + (pos_y * ANCHO_TABLERO);
    end
end
```
En este se guarda la posición a la que el jugador desea moverse. Esta se comprueba en la ram, y si está ocupada, el condicional necesario para modificar el parámetro pos no se cumplirá. 

```Verilog
always @(posedge clk_game) begin 
    if (move_down && (pos_y < LIMITE_Y_MAX) && (mem_px_read_data == 3'b000) && !move_right && !move_left && !move_up) begin 
        pos_y <= pos_y + 1;
    end
    if (move_up && (pos_y > LIMITE_Y_MIN) && (mem_px_read_data == 3'b000) && !move_right && !move_left && !move_down) begin 
        pos_y <= pos_y - 1;
    end
    if (move_right && (pos_x < LIMITE_X_MAX) && (mem_px_read_data == 3'b000) && !move_up && !move_down && !move_left) begin 
        pos_x <= pos_x + 1;
    end
    if (move_left && (pos_x > LIMITE_X_MIN) && (mem_px_read_data == 3'b000) && !move_up && !move_down && !move_right) begin 
        pos_x <= pos_x - 1;
    end
end
```
También es importante mencionar que se observó que al presionar varios botones al tiempo o rápidamente se rompia el condiciional permitiendo al jugador atravesar paredes en rápida sucesión. Por esto fue necesario agregar la condición de que todas las demás entradas de movimiento debían estar en 0. 
## Referencias

- [1] FPGA Cyclone IV - Conector VGA. (2024, July 16). parsek.com.co. (https://parsek.com.co/blogs/fpga-cyclone-iv-conector-vga)

- Implementación de una interfaz VGA sobre FPGA - Avelino Herrera (https://avelinoherrera.com/blog/index.php?m=10&y=17&entry=entry171025-151846)

- VGA Retro Sprites and Sound Synthesis - DE0-NANO (https://www.fpgalover.com/boards/de0-nano/89-vga-retro-sprites-and-sound-synthesis)

- Implementación de diferentes proyectos en FPGA - MIT (https://fpga.mit.edu/6205/F24/final_project_archive)

- Tetris on FPGA - Pascal Heinen DutLUG (https://www.youtube.com/watch?v=6E06bwA18ik)
- baliika/fpga-tetris (https://github.com/baliika/fpga-tetris)
