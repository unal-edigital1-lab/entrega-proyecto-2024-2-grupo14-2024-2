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



