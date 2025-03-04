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
