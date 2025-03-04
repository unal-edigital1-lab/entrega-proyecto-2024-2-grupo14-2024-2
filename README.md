[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=17800725&assignment_repo_type=AssignmentRepo)
# Entrega del Proyecto WP01
- Juan David Saldaña Estupiñan
- Diego José Navarro López
- Daniel Alberto Rodríguez Porras
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
A lo largo del desarrollo del proyecto, nos enfrentamos a diversas dificultades que influyeron en la evolución de nuestra propuesta inicial. En un principio, se planteó la recreación del videojuego Tetris; sin embargo, la limitada capacidad de memoria en la FPGA presentó un desafío significativo. Para mitigar este problema, intentamos implementar un factor de escalamiento que redujera el espacio requerido para almacenar las piezas del juego. A pesar de estos esfuerzos, las restricciones de hardware y la ausencia de tiempo hicieron inviable la ejecución eficiente del Tetris, por lo que optamos por una lógica más sencilla: el clásico juego de la serpiente (Snake), donde la longitud del personaje aumenta en función de los elementos recolectados.
<br> 
No obstante, el desarrollo del Snake también presentó desafíos. Aunque la lógica del juego parecía estar bien estructurada, la primera versión del movimiento utilizaba un método de sincronización y actualización de reloj sin requerir memoria RAM, lo que afectaba la interacción y fluidez del juego. Para abordar este problema y comprender mejor las mecánicas de movimiento, realizamos pruebas con puzles tipo laberinto, donde desarrollamos una interfaz gráfica basada en un buffer RAM y diseñamos la lógica de colisiones y desplazamiento.
</div>

### Lógica del Juego

1. **Tablero:**

- Dimensiones: Una cuadrícula de 40 x 30 celdas.

- Representación en memoria interna de la FPGA mediante una matriz de bits.

2. **Serpiente:**

- Objeto móvil que se alarga según la cantidad de manzanas que consume.

3. **Comportamiento:**

- Movimiento en cruz a lo largo del tablero (arriba, abajo, izquierda, derecha).

- Generación de manzanas en posiciones al azar.

- Al comer una manzana, se incrementa el tamaño de la serpiente y la puntuación.

4. **Puntaje:**

- Incremento de puntos por manzanas consumidas.

### Interfaz Gráfica

1. **Salida VGA:**

- Representación de la serpiente y la manzana con bloques de colores.

2. **Visualización:**

- Cuadrícula de juego.

- Puntaje actual.

### Entradas del Usuario

1. **Botones:**

- Arriba/Abajo/Izquierda/Derecha: Movimiento de la serpiente.

- Reset: Reiniciar Juego.

### Módulos del juego

1. **Generación de números aleatorios:**

El módulo `random_num_gen.v` se encarga de enviar las coordenadas donde aparecerá la manzana en el juego. Para ello, utiliza un registro de desplazamiento con retroalimentación lineal, implementado en `LFSR.v`.

```Verilog
module LFSR (
	input clk,              // Reloj de entrada
	input [5:0] seed,       // Valor inicial de la secuencia (no debe ser 0)
	output reg [5:0] rnd    // Número pseudoaleatorio generado
);

	// Cálculo del bit de realimentación usando una operación XOR entre los bits 5 y 4 del registro rnd
	wire feedback = rnd[5] ^ rnd[4];

	// Inicialización del registro con el valor de seed
	initial
		rnd <= seed;

	// Bloque secuencial que se ejecuta en cada flanco de subida del reloj
	always @(posedge clk)
		rnd <= (rnd == 6'h0) ? seed : {rnd[4:0], feedback}; 
		// Si rnd es 0, se reinicia con el seed; 
		// en caso contrario, se realiza un desplazamiento a la derecha y se añade el bit de realimentación.

endmodule
```

```Verilog
module random_num_gen (
	input clk,         // Reloj de entrada
	input [5:0] seed,  // Valor inicial de la secuencia aleatoria
	output reg [5:0] rnd // Número pseudoaleatorio generado
);

	// Variables internas
	wire [5:0] rnd_seq; // Salida del LFSR (secuencia de bits pseudoaleatoria)
	wire rnd_bit;       // Bit aleatorio extraído de rnd_seq
	reg [2:0] cur_bit;  // Índice del bit actual que se actualizará en rnd

	// Inicialización de valores
	initial
	begin
		rnd <= 40;   // Valor inicial del número aleatorio
		cur_bit <= 0; // Se inicia en el bit 0
	end

	// Instanciación del módulo LFSR para generar una secuencia aleatoria
	LFSR lsfr (
		.clk(clk),
		.seed(seed),
		.rnd(rnd_seq)
	);

	// Se toma el bit menos significativo de la salida del LFSR
	assign rnd_bit = rnd_seq[0];

	// Bloque secuencial que se ejecuta en cada flanco de subida del reloj
	always @(posedge clk)
	begin
		rnd[cur_bit] = rnd_bit; // Se actualiza el bit actual de rnd con un nuevo bit aleatorio

		// Se incrementa el índice del bit actual, volviendo a 0 si llega a 5
		cur_bit = (cur_bit == 5) ? 0 : cur_bit + 1;
	end

endmodule
```

2. **Manejo del reloj:**

`VGA_clk.v` toma como entrada una señal de 50 MHz y la divide a 25 MHz para sincronizar la señal VGA.

```Verilog
module VGA_clk (
    input wire clk_50MHz,  // Reloj de entrada de 50 MHz
    input wire rst,        // Reset asincrónico
    output reg clk_25MHz   // Reloj de salida aproximado a 25.175 MHz
);

    reg [1:0] counter = 0; // Contador de 2 bits para dividir por 2

    always @(posedge clk_50MHz or posedge rst) begin
        if (rst) begin
            counter <= 0;
            clk_25MHz <= 0;
        end else begin
            counter <= counter + 1;
            if (counter == 1) begin
                clk_25MHz <= ~clk_25MHz;
                counter <= 0;
            end
        end
    end

endmodule
```

`game_upd_clk.v` genera un pulso periódico que regula la velocidad de actualización del juego.

```Verilog
module game_upd_clk (
	input wire in_clk, rst, // Señal de reloj y reset
	input [9:0] x_in, // Coordenada X actual en la pantalla
	input [9:0] y_in, // Coordenada Y actual en la pantalla
	output reg out_clk // Señal de salida que indica cuándo actualizar el estado del juego
);
	reg was_updated; // Indica si la pantalla ya se actualizó en este ciclo
	reg [2:0] drawing_cycles_passed; // Contador de ciclos de dibujo completados

	// Inicialización del contador de ciclos de dibujo
	initial
	begin
		drawing_cycles_passed <= 0;
	end

	// Determina si la pantalla ha sido actualizada
	always @(posedge in_clk)
	begin
		if (out_clk)
		begin
			was_updated <= 1; // Si la salida está activa, la actualización ya ocurrió
		end
		else
		begin
			// Si se han completado los ciclos de dibujo necesarios, se marca como actualizada
			was_updated <=
				(drawing_cycles_passed == 3'd3) ?
				1:
				0;
		end
	end

	// Determina si el estado del juego debe actualizarse en este ciclo de reloj
	always @(posedge in_clk)
	begin
		out_clk <=
			(
				~was_updated && // Solo si no ha sido actualizado aún
				(drawing_cycles_passed == 3'd3) // Y si han pasado los ciclos requeridos
			);
	end

	// Contador de veces que la pantalla ha sido completamente dibujada
	always @(posedge in_clk or posedge rst)
	begin
		if (rst)
		begin
			drawing_cycles_passed <= 0; // Reinicia el contador si hay reset
		end
		else
		begin
			// Cuando se llega al último píxel de la pantalla, se incrementa el contador
			if (
				(x_in == 39) &&
				(y_in == 29)
			)
			begin
				drawing_cycles_passed <=
					(drawing_cycles_passed == 3'd3) ?
						0: // Si ya alcanzó el máximo, se reinicia
						drawing_cycles_passed + 1; // Si no, se incrementa
			end
		end
	end

endmodule
```

3. **Generación de la señal VGA:**

`VGA_Draw.v` determina el color de cada píxel según la posición y el objeto que se encuentra en ese punto.

```Verilog
module VGA_Draw(
    // Salida de color VGA
    output reg red,
    output reg green,
    output reg blue,
    
    // Posición actual en la pantalla
    input [9:0] VGA_X,
    input [9:0] VGA_Y,
    input VGA_clk,
    
    // Señales de control
    input rst,
    input Color_SW, // Modo de dibujo: 0 para juego, 1 para líneas de colores
    input [0:1] ent // Tipo de entidad a dibujar
);

// Siempre que haya un flanco de subida en el reloj VGA o un reset, se ejecuta este bloque
always @(posedge VGA_clk or posedge rst) begin
    if (rst) begin
        // Si se activa el reset, los colores se ponen en negro
        red   <= 0;
        green <= 0;
        blue  <= 0;
    end else begin
        if (Color_SW == 0) begin
            // Modo de juego: Se dibujan las entidades con colores específicos
				if (ent == 2'b11) begin
					  red   <= 0;
					  green <= 0;
					  blue  <= 0;
				end else if(ent == 2'b01 || ent == 2'b10) begin
					  red   <= 0;
					  green <= 1;
					  blue  <= 0;					  
			   end else begin
					  red   <= 1;
					  green <= 0;
					  blue  <= 0;						  
				end
        end else begin
            // Modo de líneas de colores
            if (VGA_Y < 60) begin
                red <= 1;
                green <= 1;
                blue <= 1;
            end else if (VGA_Y < 120) begin
                red <= 1;
                green <= 0;
                blue <= 1;
            end else if (VGA_Y < 180) begin
                red <= 1;
                green <= 1;
                blue <= 0;
            end else if (VGA_Y < 240) begin
                red <= 1;
                green <= 0;
                blue <= 0;
            end else if (VGA_Y < 300) begin
                red <= 0;
                green <= 1;
                blue <= 1;
            end else if (VGA_Y < 360) begin
                red <= 0;
                green <= 0;
                blue <= 1;
            end else if (VGA_Y < 420) begin
                red <= 0;
                green <= 1;
                blue <= 0;
            end else begin
                red <= 0;
                green <= 0;
                blue <= 0;
            end
        end
    end
end

endmodule
```

`VGA_Ctrl.v` gestiona la señal de control necesaria para la salida VGA.

```Verilog
module VGA_Ctrl(
    input clk,         // Señal de reloj del sistema
    input rst,         // Señal de reinicio
    // Entradas de color desde el host
    input red,
    input green,
    input blue,
    // Coordenadas actuales del píxel
    output [9:0] cur_X,
    output [9:0] cur_Y,
    // Salidas VGA
    output VGA_r,
    output VGA_g,
    output VGA_b,
    output reg VGA_hs, // Señal de sincronización horizontal
    output reg VGA_vs  // Señal de sincronización vertical
);
    
// Registros internos para el conteo de píxeles y líneas
reg [9:0] H_Cont; // Contador horizontal
reg [9:0] V_Cont; // Contador vertical

////////////////////////////////////////////////////////////
// Parámetros de sincronización VGA para 640x480 @ 60Hz
// Definición de tiempos de sincronización horizontal
localparam H_FRONT = 16;  // Margen delantero
localparam H_SYNC = 96;   // Duración del pulso de sincronización
localparam H_BACK = 48;   // Margen trasero
localparam H_ACT = 640;   // Píxeles activos
localparam H_BLANK = H_FRONT + H_SYNC + H_BACK;
localparam H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;
    
////////////////////////////////////////////////////////////
// Definición de tiempos de sincronización vertical
localparam V_FRONT = 10;  // Margen delantero
localparam V_SYNC = 2;    // Duración del pulso de sincronización
localparam V_BACK = 33;   // Margen trasero
localparam V_ACT = 480;   // Líneas activas
parameter V_BLANK = V_FRONT + V_SYNC + V_BACK;
parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;
    
////////////////////////////////////////////////////////////

// Asignación de colores VGA según la coordenada X
assign VGA_r = (cur_X > 0) ? red : 0;
assign VGA_g = (cur_X > 0) ? green : 0;
assign VGA_b = (cur_X > 0) ? blue : 0;
    
// Cálculo de coordenadas actuales en la pantalla
assign cur_X = (H_Cont >= H_BLANK) ? H_Cont - H_BLANK : 10'h0;
assign cur_Y = (V_Cont >= V_BLANK) ? V_Cont - V_BLANK : 10'h0;

////////////////////////////////////////////////////////////
// Generador de sincronización horizontal
always @(posedge clk or posedge rst) begin
    if (rst) begin
        H_Cont <= 0;
        VGA_hs <= 1;
    end else begin
        // Contador horizontal
        if (H_Cont < H_TOTAL - 1)
            H_Cont <= H_Cont + 1'b1;
        else
            H_Cont <= 0;

        // Generación del pulso de sincronización horizontal
        if (H_Cont == H_FRONT - 1)   // Fin del margen delantero
            VGA_hs <= 1'b0;         // Activa el pulso de sincronización
        if (H_Cont == H_FRONT + H_SYNC - 1) // Fin del pulso de sincronización
            VGA_hs <= 1'b1;         // Desactiva el pulso de sincronización
    end
end
    
////////////////////////////////////////////////////////////
// Generador de sincronización vertical
always @(posedge VGA_hs or posedge rst) begin
    if (rst) begin
        V_Cont <= 0;
        VGA_vs <= 1;
    end else begin
        // Contador vertical
        if (V_Cont < V_TOTAL - 1)
            V_Cont <= V_Cont + 1'b1;
        else
            V_Cont <= 0;

        // Generación del pulso de sincronización vertical
        if (V_Cont == V_FRONT - 1)   // Fin del margen delantero
            VGA_vs <= 1'b0;         // Activa el pulso de sincronización
        if (V_Cont == V_FRONT + V_SYNC - 1) // Fin del pulso de sincronización
            VGA_vs <= 1'b1;         // Desactiva el pulso de sincronización
    end
end
    
endmodule
```

4. **Visualización de la puntuación:**

`SSEG_Display.v` se encarga de mostrar la puntuación del jugador en un display de 7 segmentos.

```Verilog
module SSEG_Driver (
	clk_50M,
	reset,
	data,
	dp_in,
	sseg,
	an
);

input  wire clk_50M;       // Reloj de 50 MHz
input  wire reset;         // Señal de reinicio
input  wire [15:0] data;   // Entrada de datos de 16 bits (4 dígitos en hexadecimal)
input  wire [3:0] dp_in;   // Control de los puntos decimales (ON/OFF)
output reg [7:0] sseg;     // Salidas de los segmentos de los displays (a, b, c, d, e, f, g, dp)
output reg [3:0] an;       // Control de los ánodos de los displays (AN3, AN2, AN1, AN0)

// Separación de los 4 dígitos hexadecimales de la entrada `data`
wire [3:0] hex3, hex2, hex1, hex0;	

assign hex3 = data[15:12];  // Dígito más significativo
assign hex2 = data[11:8];
assign hex1 = data[7:4];
assign hex0 = data[3:0];    // Dígito menos significativo

// Parámetro que define el número de bits para el contador
localparam N = 18;

reg [N-1:0] q_reg;  // Registro del contador para la multiplexación de los displays
wire [N-1:0] q_next; // Valor siguiente del contador
reg [3:0] hex_in;    // Dígito actual que se va a mostrar en el display activo
reg dp;              // Control del punto decimal

// Contador para la multiplexación de los 4 displays de 7 segmentos
always@( posedge clk_50M or posedge reset )
	if( reset )
		q_reg <= 0;  // Reinicia el contador si se activa `reset`
	else
		q_reg <= q_next;  // Incrementa el contador en cada ciclo de reloj
		
assign q_next = q_reg + 1;  // Incrementa el contador

// Lógica para seleccionar el display activo y el dígito a mostrar
always@( * )
	case( q_reg[N-1:N-2] )  // Se utilizan los dos bits más significativos del contador
		2'b00:
		begin
			an = 4'b1110;  // Activa el display AN0 (el menos significativo)
			hex_in = hex0; // Muestra el primer dígito
			dp = dp_in[0]; // Control del punto decimal de AN0
		end
		
		2'b01:
		begin
			an = 4'b1101;  // Activa el display AN1
			hex_in = hex1; // Muestra el segundo dígito
			dp = dp_in[1]; // Control del punto decimal de AN1
		end	

		2'b10:
		begin
			an = 4'b1011;  // Activa el display AN2
			hex_in = hex2; // Muestra el tercer dígito
			dp = dp_in[2]; // Control del punto decimal de AN2
		end		
		
		2'b11:
		begin
			an = 4'b0111;  // Activa el display AN3 (el más significativo)
			hex_in = hex3; // Muestra el cuarto dígito
			dp = dp_in[3]; // Control del punto decimal de AN3
		end
	endcase
	
// Conversión del valor hexadecimal a los segmentos del display
always@( * )
begin
	case( hex_in )
			0 : sseg[6:0] = 7'b1000000;  // '0'
			1 : sseg[6:0] = 7'b1111001;  // '1'
			2 : sseg[6:0] = 7'b0100100;  // '2'
			3 : sseg[6:0] = 7'b0110000;  // '3'
			4 : sseg[6:0] = 7'b0011001;  // '4'
			5 : sseg[6:0] = 7'b0010010;  // '5'
			6 : sseg[6:0] = 7'b0000010;  // '6'
			7 : sseg[6:0] = 7'b1111000;  // '7'
			8 : sseg[6:0] = 7'b0000000;  // '8'
			9 : sseg[6:0] = 7'b0010000;  // '9'
			'hA : sseg[6:0] = 7'b0001000;  // 'A'
			'hB : sseg[6:0] = 7'b0000011;  // 'b'
			'hC : sseg[6:0] = 7'b1000110;  // 'C'
			'hD : sseg[6:0] = 7'b0100001;  // 'd'
			'hE : sseg[6:0] = 7'b0000110;  // 'E'
			'hF : sseg[6:0] = 7'b0001110;  // 'F'
	default : sseg[6:0] = 7'b1111111;  // Display apagado si el valor no es válido
	endcase
	
	sseg[7] = dp;  // Asigna el estado del punto decimal
end

endmodule
```

```Verilog
module SSEG_Display (
	clk_50M, reset,
	sseg_a_to_dp,
	sseg_an,
	data
);

input  wire clk_50M;            // Reloj de 50MHz como entrada
input  wire reset;              // Señal de reinicio
output wire [7:0] sseg_a_to_dp; // Salidas de los segmentos de los displays de 7 segmentos (a, b, c, d, e, f, g, dp)
output wire [3:0] sseg_an;      // Salidas para los ánodos de los displays (AN3, AN2, AN1, AN0)

input wire [15:0] data;         // Entrada de datos de 16 bits que se mostrará en los displays

// Instancia del módulo SSEG_Driver que maneja la multiplexación y control de los displays de 7 segmentos
SSEG_Driver U1 (
    .clk_50M(clk_50M),    // Conecta la señal de reloj de 50MHz
    .reset(reset),        // Conecta la señal de reinicio
    .data(data),          // Conecta la entrada de datos de 16 bits
    .sseg(sseg_a_to_dp),  // Conecta las salidas de los segmentos de los displays
    .an(sseg_an),         // Conecta las salidas de los ánodos de los displays
    .dp_in(4'b1111)       // Desactiva todos los puntos decimales (dp)
);

endmodule
```

5. **Captura de la dirección de movimiento:**

`direction_input.v` lee la entrada de los botones para determinar la dirección en la que se moverá la serpiente.

```Verilog
module direction_input(
    input clk,          // Señal de reloj
    input left,         // Entrada para el botón de dirección izquierda
    input right,        // Entrada para el botón de dirección derecha
    input up,          // Entrada para el botón de dirección arriba
    input down,        // Entrada para el botón de dirección abajo
    output reg [0:1] direction // Registro de 2 bits para representar la dirección actual
);

// Inicialización de la dirección predeterminada (movimiento hacia arriba)
initial begin
    direction = 2'b01;  
end

// Bloque siempre activo en cada flanco de subida del reloj
always @(posedge clk) begin
    // Se verifica que solo una dirección esté activada simultáneamente
    if (left + right + up + down == 3'b001) begin 
        
        // Si se presiona "izquierda" y la serpiente no va hacia la derecha
        if (left && (direction != 2'b11)) begin  
            direction = 2'b00;  // Mueve a la izquierda
        end 

        // Si se presiona "derecha" y la serpiente no va hacia la izquierda
        if (right && (direction != 2'b00)) begin  
            direction = 2'b11;  // Mueve a la derecha
        end 

        // Si se presiona "arriba" y la serpiente no va hacia abajo
        if (up && (direction != 2'b10)) begin  
            direction = 2'b01;  // Mueve hacia arriba
        end  

        // Si se presiona "abajo" y la serpiente no va hacia arriba
        if (down && (direction != 2'b01)) begin  
            direction = 2'b10;  // Mueve hacia abajo
        end 
    end 
end 

endmodule
```

6. **Lógica principal del juego:**

`game_logic.v` contiene las reglas del juego. Controla el movimiento de la serpiente, detecta colisiones que pueden hacer que el jugador pierda, y actualiza la puntuación cuando la serpiente come una manzana.

```Verilog
module game_logic (
    input vga_clk, update_clk, rst,  // Señales de reloj y reset
    input [0:1] direction,             // Dirección del movimiento de la serpiente
    input wire [9:0] x_in, y_in,        // Coordenadas de entrada (se actualizan en cada ciclo)
    output reg [0:1] entity,            // Tipo de entidad en la posición actual (serpiente, manzana o vacío)
    output reg game_over, game_won,     // Señales de fin del juego (por colisión o victoria)
    output reg [7:0] tail_count    // Contador de segmentos de la cola
);

    // Variables para almacenar las coordenadas actuales
    wire [6:0] cur_x;
    wire [5:0] cur_y;

    // Posiciones de la cabeza de la serpiente y la manzana
    reg [6:0] snake_head_x, apple_x;
    reg [5:0] snake_head_y, apple_y;

    // Bandera para verificar si la posición actual pertenece a la cola
    reg is_cur_coord_tail;

    // Arreglo que almacena las posiciones de los segmentos de la cola
    reg [11:0] tails [0:127];

    // Variables para generar posiciones aleatorias de la manzana
    wire [5:0] rand_num_x_orig, rand_num_y_orig,
               rand_num_x_fit, rand_num_y_fit;

    // Generadores de números aleatorios
    random_num_gen rng_x (
        .clk(update_clk),
        .seed(6'b100_110),
        .rnd(rand_num_x_orig)
    );

    random_num_gen rng_y (
        .clk(update_clk),
        .seed(6'b101_001),
        .rnd(rand_num_y_orig)
    );

    // Ajuste de los números aleatorios para que se ubiquen dentro del tablero
    assign rand_num_x_fit = rand_num_x_orig % 39;
    assign rand_num_y_fit = rand_num_y_orig % 29;

    // Tarea para inicializar la posición de la manzana
    task init();
    begin
        apple_x <= 34;
        apple_y <= 9;
    end
    endtask

    // Inicialización de variables
    initial begin
        init();
        snake_head_x <= 20;  // Posición inicial de la serpiente en el centro
        snake_head_y <= 15;
        tail_count <= 0;
        game_won <= 0;
    end

    // Conversión de las coordenadas de entrada a unidades de la cuadrícula
    assign cur_x = (x_in / 16);
    assign cur_y = (y_in / 16);

    // Determinar qué entidad está presente en la posición actual
    always @(posedge vga_clk) begin
        if (cur_x == snake_head_x && cur_y == snake_head_y) begin
            entity <= 2'b01;  // Cabeza de la serpiente
        end else if (cur_x == apple_x && cur_y == apple_y) begin
            entity <= 2'b00;  // Manzana
        end else if (is_cur_coord_tail) begin
            entity <= 2'b10;  // Cola de la serpiente
        end else begin
            entity <= 2'b11;  // Espacio vacío
        end
    end

    // Verificación de colisiones con la cola
    always @(posedge vga_clk or posedge rst) begin
        integer i;
        if (rst) begin
            game_over = 0;
        end else begin
            is_cur_coord_tail = 1'b0;

            for (i = 0; i < 128; i = i + 1) begin
                if (i < tail_count) begin
                    if (tails[i] == {cur_x, cur_y}) begin
                        is_cur_coord_tail = 1'b1;
                    end
                    if (tails[i] == {snake_head_x, snake_head_y}) begin
                        game_over = 1'b1;  // Si la cabeza choca con la cola, el juego termina
                    end
                end
            end
        end
    end

    // Movimiento de la serpiente basado en la dirección ingresada
    always @(posedge update_clk or posedge rst) begin
        if (rst) begin
            // Reiniciar la posición de la serpiente
            snake_head_x <= 20;
            snake_head_y <= 15;
        end else begin
            if (~game_over) begin
                case (direction)
                    2'b00:
                        snake_head_x <= (snake_head_x == 0) ?
                                        39 : (snake_head_x - 12'd1);
                    2'b01:
                        snake_head_y <= (snake_head_y == 0) ?
                                        29 : (snake_head_y - 12'd1);
                    2'b11:
                        snake_head_x <= (snake_head_x == 39) ?
                                        0 : (snake_head_x + 12'd1);
                    2'b10:
                        snake_head_y <= (snake_head_y == 29) ?
                                        0 : (snake_head_y + 12'd1);
                endcase
            end
        end
    end

    // Actualización de la cola de la serpiente
    always @(posedge update_clk or posedge rst) begin
        integer i;
        if (rst) begin
            init();
            tail_count <= 0;
        end else begin
            // Si la cabeza de la serpiente alcanza la manzana
            if (snake_head_x == apple_x && snake_head_y == apple_y) begin
                // Agregar un nuevo segmento a la cola
                if (tail_count < 128) begin
                    tails[tail_count] <= {snake_head_x, snake_head_y};
                    tail_count <= tail_count + 1;
                end
                // Generar una nueva posición para la manzana
                apple_x <= rand_num_x_fit;
                apple_y <= rand_num_y_fit;
            end else begin
                // Mover la cola desplazando los segmentos
                for (i = 0; i < 128; i = i + 1) begin
                    if (i == (tail_count - 1)) begin
                        tails[i] <= {snake_head_x, snake_head_y};
                    end else begin
                        if (i != 127) begin
                            tails[i] <= tails[i + 1];
                        end
                    end
                end
            end
        end
    end

    // Comprobación de si el jugador ha ganado
    always @(posedge update_clk or posedge rst) begin
        if (rst) begin
            game_won <= 0;
        end else if (tail_count == 128) begin
            game_won <= 1;  // Se gana cuando la serpiente alcanza el tamaño máximo
        end
    end

endmodule
```

## Diagrama de Bloques
  
![image](https://github.com/user-attachments/assets/c7214819-4518-43b9-934b-9ef9c73750c2)

# Pruebas Iniciales VGA
<div align="justify">
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


## Caja Negra: Puzzle
![image](https://github.com/user-attachments/assets/6940fc64-adb2-4e99-82e6-c879d2e89949)

## Caja Negra: Snake
![image](https://github.com/user-attachments/assets/5283e957-fa67-49de-9f3b-5a07ef45fa43)

#### Diferencias entre Implementaciones
<div align="justify">
Durante la investigación y desarrollo del proyecto, exploramos dos enfoques distintos para la gestión del escenario y la lógica de movimiento en la FPGA.

El primer enfoque, utilizado en el juego de Snake, almacena toda la información relevante sobre el estado del juego dentro del módulo game_logic, lo que significa que las posiciones de la serpiente, la manzana y las colisiones se manejan mediante lógica combinacional. Si bien esto simplifica la estructura del diseño al eliminar la necesidad de memoria adicional, incrementa significativamente la cantidad de compuertas lógicas utilizadas en la FPGA, lo que puede afectar el rendimiento y la escalabilidad del sistema.

En contraste, el segundo enfoque, aplicado a los puzzles/laberintos, introduce un buffer RAM para almacenar el escenario del juego. Este buffer RAM permite que la lógica de colisiones y movimiento acceda a los datos mediante lecturas de memoria en lugar de depender de lógica combinacional compleja. Este diseño tiene varias ventajas:

 - Reduce el uso de compuertas lógicas en la FPGA, permitiendo un uso más eficiente de los recursos.
 - Facilita la manipulación del escenario, ya que los datos pueden actualizarse fácilmente en memoria sin necesidad de modificar la estructura del código principal.
 - Permite almacenar múltiples niveles o mapas, haciendo que la implementación de nuevos escenarios sea más flexible y escalable.
</div>

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
También es importante mencionar que se observó que al presionar varios botones al tiempo o rápidamente se rompía el condicional permitiendo al jugador atravesar paredes en rápida sucesión. Por esto fue necesario agregar la condición de que todas las demás entradas de movimiento debían estar en 0. 
## Referencias

- [1] FPGA Cyclone IV - Conector VGA. (2024, July 16). parsek.com.co. (https://parsek.com.co/blogs/fpga-cyclone-iv-conector-vga)

- Implementación de una interfaz VGA sobre FPGA - Avelino Herrera (https://avelinoherrera.com/blog/index.php?m=10&y=17&entry=entry171025-151846)

- VGA Retro Sprites and Sound Synthesis - DE0-NANO (https://www.fpgalover.com/boards/de0-nano/89-vga-retro-sprites-and-sound-synthesis)

- Implementación de diferentes proyectos en FPGA - MIT (https://fpga.mit.edu/6205/F24/final_project_archive)

- Tetris on FPGA - Pascal Heinen DutLUG (https://www.youtube.com/watch?v=6E06bwA18ik)

- baliika/fpga-tetris (https://github.com/baliika/fpga-tetris)

- The Snake game for FPGA Cyclone IV (https://habr.com/ru/articles/431226/) 
