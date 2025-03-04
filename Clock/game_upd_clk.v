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