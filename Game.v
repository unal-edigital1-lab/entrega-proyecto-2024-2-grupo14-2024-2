module Game (
	input wire clk, // Reloj de 50MHz
	input Left,
	Right,
	Up,
	Down,
	// Entradas VGA
	input wire
		reset,  // Señal de reinicio del juego
		color,  // Cambia entre dos configuraciones de color

	// Salidas VGA
	output wire
		VGA_HS, // Señal de sincronización horizontal
		VGA_VS, // Señal de sincronización vertical
		VGA_R,  // Canal Rojo de la señal VGA
		VGA_G,  // Canal Verde de la señal VGA
		VGA_B,  // Canal Azul de la señal VGA

	// Salidas del display de 7 segmentos
	output wire
		[7:0] sseg_a_to_dp, // Señales para los segmentos del display de 7 segmentos
	output wire
		[3:0] sseg_an  // Anodos de los displays de 7 segmentos
);

	// Generación de relojes
	wire vga_clk, update_clk;
	
	// Módulo que genera el reloj para VGA a partir del reloj de 50MHz
	VGA_clk vga_clk_gen (
		.clk_50MHz(clk), // Reloj de entrada de 50MHz
		.rst(reset), // Reinicio del juego
		.clk_25MHz(vga_clk) // Reloj de salida para VGA
	);

	// Módulo que genera el reloj de actualización del juego basado en la posición VGA
	game_upd_clk upd_clk(
		.in_clk(vga_clk), // Se usa el reloj de VGA
		.rst(reset),    // Reinicio del juego
		.x_in(mVGA_X),    // Posición X en pantalla
		.y_in(mVGA_Y),    // Posición Y en pantalla
		.out_clk(update_clk) // Reloj de actualización del juego
	);

	wire [0:1] dir;
	direction_input di(
	.clk(update_clk),
	.left(Left),
	.right(Right),
	.up(Up),
	.down(Down),
	.direction(dir)
	);
	

	// Lógica del juego
	wire [0:1] cur_ent_code; // Código de la entidad en la posición actual
	wire [7:0] game_score; // Puntuación del juego basada en el tamaño de la serpiente

	// Instancia del módulo que maneja la lógica del juego
	game_logic game_logic_module (
		.vga_clk(vga_clk), // Reloj de VGA
		.update_clk(update_clk), // Reloj de actualización del juego
		.rst(reset), // Reinicio del juego
		.direction(dir), // Dirección del movimiento
		.x_in(mVGA_X), // Posición X en pantalla
		.y_in(mVGA_Y), // Posición Y en pantalla
		.entity(cur_ent_code), // Código de la entidad en la posición actual
		.tail_count(game_score) // Puntuación del juego (longitud de la serpiente)
	);

	// Señales VGA
	wire	[9:0]	mVGA_X; // Coordenada X en pantalla
	wire	[9:0]	mVGA_Y; // Coordenada Y en pantalla
	wire	mVGA_R; // Canal rojo de la salida VGA
	wire	mVGA_G; // Canal verde de la salida VGA
	wire	mVGA_B; // Canal azul de la salida VGA

	wire	sVGA_R; // Canal rojo procesado
	wire	sVGA_G; // Canal verde procesado
	wire	sVGA_B; // Canal azul procesado

	// Módulo encargado de dibujar la serpiente y los objetos en pantalla
	VGA_Draw	u3 
		(	// Salidas de color
			.red(mVGA_R),
			.green(mVGA_G),
			.blue(mVGA_B),
			// Entradas de coordenadas VGA
			.VGA_X(mVGA_X),
			.VGA_Y(mVGA_Y),
			.VGA_clk(vga_clk),
			// Señales de control
			.rst(reset),
			.Color_SW(color), // Cambia entre diferentes colores
			.ent(cur_ent_code) // Código de la entidad en la posición actual
		);

	// Módulo que genera las señales de sincronización y control para la pantalla VGA
	VGA_Ctrl	u2 
		(	// Señales de control
			.clk(vga_clk),
			.rst(reset),// Salida de coordenadas actuales
			// Entradas de color
			.red(mVGA_R),
			.green(mVGA_G),
			.blue(mVGA_B),
			// Coordenadas actuales del píxel
			.cur_X(mVGA_X),
			.cur_Y(mVGA_Y),
			// Salidas VGA
			.VGA_r(sVGA_R),
			.VGA_g(sVGA_G),
			.VGA_b(sVGA_B),
			.VGA_hs(VGA_HS), // Señal de sincronización horizontal
			.VGA_vs(VGA_VS) // Señal de sincronización vertical
		);

	// Asignación de colores procesados a la salida VGA
	assign VGA_R = sVGA_R;
	assign VGA_G = sVGA_G;
	assign VGA_B = sVGA_B;

	// Módulo controlador de display de 7 segmentos para mostrar la puntuación
	SSEG_Display sseg_d(
		.clk_50M(clk), // Reloj de 50MHz
		.reset(reset), // Señal de reinicio
		.sseg_a_to_dp(sseg_a_to_dp), // Salida de los segmentos del display
		.sseg_an(sseg_an), // Salida de los anodos
		.data(game_score) // Puntuación del juego (longitud de la serpiente)
	);

endmodule
