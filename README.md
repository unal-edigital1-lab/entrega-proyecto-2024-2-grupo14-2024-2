[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=17800725&assignment_repo_type=AssignmentRepo)
# Entrega del Proyecto WP01

## Introducción
<div align="justify">
Como etapa final del curso Electrónica Digital I, se busca desafíar y probar nuestros conocimientos en la integración de los fundamentos y aplicaciones avanzadas en sistemas de electrónica digital. Se abarcan temas claves como, diseño e implementación de circuitos secuenciales y combinacionales, máquinas de estados algorítmos, uso de entornos de simulación y programación de Hardaware en Verilog. Es así, como para la aplicación de estos conocimientos, se planteó en un inicio la recreación de un juego retro con la placa Cyclone IV.
Como objetivo principal, es dar solución a los retos que presenta la programación de videjuegos en un lenguaje de programación de bajo nivel. Como el procesamiento de señales en VGA, creación de registros de memoria RAM y lógica combinacional para mecánicas de movimiento. Además, se integran otros componentes, como botones y switches para dar al usuario una interacción con el juego en tiempo de ejecución.
</div>
## Especificaciones del Proyecto

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

# 10 de Febrero: Pruebas VGA  
<div align="justify">
La implementación gráfica se realiza a través del puerto VGA de nuestra tarjeta Cyclone IV. Es fundamental definir qué parámetros podemos modificar y cuáles son nuestras limitaciones.

En primer lugar, el conector VGA es una interfaz de pantalla utilizada para transmitir señales de video analógicas. Para facilitar su proyección en dispositivos más modernos, se emplea un adaptador VGA a HDMI, permitiendo visualizar los resultados como una salida digital.

Luego, según el datasheet de nuestra tarjeta, en el apartado Pin Planner se observa que cada canal de color del formato RGB cuenta con únicamente 1 bit de información, lo que limita la gama de colores a 8 posibles combinaciones.

Finalmente, dado que la pantalla requiere una frecuencia de 60 Hz para su correcto funcionamiento, se ejecuta el siguiente código [1], el cual permite generar diferentes patrones de color (barras horizontales, barras verticales, tablero de ajedrez y tablero de ajedrez invertido), evaluando así su sincronización con la pantalla digital.
</div>

```Verilog
module VGA(
   clock,          // Reloj de 50 MHz de la FPGA
   switch,         // Switch para seleccionar el patrón de colores
   disp_RGB,       // Salida de color VGA (3 bits: Rojo, Verde, Azul)
   hsync,          // Señal de sincronización horizontal
   vsync           // Señal de sincronización vertical
);

input  clock;       // Entrada del reloj de la FPGA (50MHz)
input  [1:0]switch; // Entrada del switch (2 bits para seleccionar patrón)
output [2:0]disp_RGB; // Salida de color VGA (1 bit por canal RGB)
output  hsync;     // Salida de sincronización horizontal
output  vsync;     // Salida de sincronización vertical

// ----------------------------- Definición de Registros -----------------------------

reg [9:0] hcount;  // Contador para el escaneo horizontal (posición en la línea)
reg [9:0] vcount;  // Contador para el escaneo vertical (línea en la pantalla)
reg [2:0] data;    // Registra el color actual en pantalla
reg [2:0] h_dat;   // Color de barras horizontales
reg [2:0] v_dat;   // Color de barras verticales

reg   flag;         // Bandera auxiliar (No utilizada en el código final)
wire  hcount_ov;    // Señal de desbordamiento del contador horizontal
wire  vcount_ov;    // Señal de desbordamiento del contador vertical
wire  dat_act;      // Indica si el píxel actual está en la zona visible
reg  vga_clk;       // Reloj reducido para VGA

// ----------------------------- Generación del Reloj VGA -----------------------------

always @(posedge clock)
begin
    vga_clk = ~vga_clk; // Reduce la frecuencia del reloj (50MHz -> 25MHz)
end

// ----------------------------- Definición de los Parámetros VGA -----------------------------
// Valores de sincronización para 640x480 @ 60Hz

parameter hsync_end   = 10'd95,   // Duración del pulso de sincronización horizontal
          hdat_begin  = 10'd143,  // Inicio del área visible en horizontal
          hdat_end    = 10'd783,  // Fin del área visible en horizontal
          hpixel_end  = 10'd799,  // Número total de píxeles por línea (800)

          vsync_end   = 10'd1,    // Duración del pulso de sincronización vertical
          vdat_begin  = 10'd34,   // Inicio del área visible en vertical
          vdat_end    = 10'd514,  // Fin del área visible en vertical
          vline_end   = 10'd524;  // Número total de líneas por cuadro (525)

// ----------------------------- Contador de Píxeles y Líneas -----------------------------

// Contador horizontal (avanza los píxeles en una línea)
always @(posedge vga_clk)
begin
    if (hcount_ov)
        hcount <= 10'd0; // Reinicia el conteo al llegar al final de la línea
    else
        hcount <= hcount + 10'd1; // Incrementa el contador de píxeles
end
assign hcount_ov = (hcount == hpixel_end); // Detecta cuando se alcanza el final de la línea

// Contador vertical (avanza las líneas en la pantalla)
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

// ----------------------------- Generación de las Señales de Sincronización -----------------------------

// Define el área visible de la pantalla (dentro de 640x480)
assign dat_act =    ((hcount >= hdat_begin) && (hcount < hdat_end)) &&
                    ((vcount >= vdat_begin) && (vcount < vdat_end));

// Generación de señales de sincronización VGA
assign hsync = (hcount > hsync_end); // Pulso de sincronización horizontal
assign vsync = (vcount > vsync_end); // Pulso de sincronización vertical

// Asigna el color solo cuando está en la zona visible, en caso contrario, muestra negro
assign disp_RGB = (dat_act) ? data : 3'h00; 

// ----------------------------- Generación de Patrones de Color -----------------------------

// Selecciona el patrón de color según el switch
always @(posedge vga_clk)
begin
    case(switch[1:0])
        2'd0: data <= h_dat;         // Barras horizontales
        2'd1: data <= v_dat;         // Barras verticales
        2'd2: data <= (v_dat ^ h_dat); // Patrón de tablero de ajedrez (XOR)
        2'd3: data <= (v_dat ~^ h_dat); // Patrón de tablero invertido (XNOR)
    endcase
end

// ----------------------------- Definición de Barras de Color -----------------------------

// Genera barras de colores verticales
always @(posedge vga_clk)  
begin
    if(hcount < 223)
        v_dat <= 3'h7;   // Blanco
    else if(hcount < 303)
        v_dat <= 3'h6;   // Cian
    else if(hcount < 383)
        v_dat <= 3'h5;   // Magenta
    else if(hcount < 463)
        v_dat <= 3'h4;   // Azul
    else if(hcount < 543)
        v_dat <= 3'h3;   // Amarillo
    else if(hcount < 623)
        v_dat <= 3'h2;   // Verde
    else if(hcount < 703)
        v_dat <= 3'h1;   // Rojo
    else 
        v_dat <= 3'h0;   // Negro
end

// Genera barras de colores horizontales
always @(posedge vga_clk) 
begin
    if(vcount < 94)
        h_dat <= 3'h7;   // Blanco
    else if(vcount < 154)
        h_dat <= 3'h6;   // Cian
    else if(vcount < 214)
        h_dat <= 3'h5;   // Magenta
    else if(vcount < 274)
        h_dat <= 3'h4;   // Azul
    else if(vcount < 334)
        h_dat <= 3'h3;   // Amarillo
    else if(vcount < 394)
        h_dat <= 3'h2;   // Verde
    else if(vcount < 454)
        h_dat <= 3'h1;   // Rojo
    else 
        h_dat <= 3'h0;   // Negro
end

endmodule

```

## Referencias

- [1] FPGA Cyclone IV - Conector VGA. (2024, July 16). parsek.com.co. (https://parsek.com.co/blogs/fpga-cyclone-iv-conector-vga)

- Implementación de una interfaz VGA sobre FPGA - Avelino Herrera (https://avelinoherrera.com/blog/index.php?m=10&y=17&entry=entry171025-151846)

- VGA Retro Sprites and Sound Synthesis - DE0-NANO (https://www.fpgalover.com/boards/de0-nano/89-vga-retro-sprites-and-sound-synthesis)

- Implementación de diferentes proyectos en FPGA - MIT (https://fpga.mit.edu/6205/F24/final_project_archive)

- Tetris on FPGA - Pascal Heinen DutLUG (https://www.youtube.com/watch?v=6E06bwA18ik)
- baliika/fpga-tetris (https://github.com/baliika/fpga-tetris)
