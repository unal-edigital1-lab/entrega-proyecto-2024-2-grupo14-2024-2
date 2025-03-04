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
