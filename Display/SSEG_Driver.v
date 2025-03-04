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
