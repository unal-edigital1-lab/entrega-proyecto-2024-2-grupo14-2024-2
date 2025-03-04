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
