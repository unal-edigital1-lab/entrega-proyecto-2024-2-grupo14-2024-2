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
