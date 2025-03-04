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
