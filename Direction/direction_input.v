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
