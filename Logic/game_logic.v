module game_logic (
    input vga_clk, update_clk, rst,  // Señales de reloj y reset
    input [0:1] direction,             // Dirección del movimiento de la serpiente
    input wire [9:0] x_in, y_in,        // Coordenadas de entrada (se actualizan en cada ciclo)
    output reg [0:1] entity,            // Tipo de entidad en la posición actual (serpiente, manzana o vacío)
    output reg game_over, game_won,     // Señales de fin del juego (por colisión o victoria)
    output reg [7:0] tail_count    // Contador de segmentos de la cola
);

    // Variables para almacenar las coordenadas actuales
    wire [6:0] cur_x;
    wire [5:0] cur_y;

    // Posiciones de la cabeza de la serpiente y la manzana
    reg [6:0] snake_head_x, apple_x;
    reg [5:0] snake_head_y, apple_y;

    // Bandera para verificar si la posición actual pertenece a la cola
    reg is_cur_coord_tail;

    // Arreglo que almacena las posiciones de los segmentos de la cola
    reg [11:0] tails [0:127];

    // Variables para generar posiciones aleatorias de la manzana
    wire [5:0] rand_num_x_orig, rand_num_y_orig,
               rand_num_x_fit, rand_num_y_fit;

    // Generadores de números aleatorios
    random_num_gen rng_x (
        .clk(update_clk),
        .seed(6'b100_110),
        .rnd(rand_num_x_orig)
    );

    random_num_gen rng_y (
        .clk(update_clk),
        .seed(6'b101_001),
        .rnd(rand_num_y_orig)
    );

    // Ajuste de los números aleatorios para que se ubiquen dentro del tablero
    assign rand_num_x_fit = rand_num_x_orig % 39;
    assign rand_num_y_fit = rand_num_y_orig % 29;

    // Tarea para inicializar la posición de la manzana
    task init();
    begin
        apple_x <= 34;
        apple_y <= 9;
    end
    endtask

    // Inicialización de variables
    initial begin
        init();
        snake_head_x <= 20;  // Posición inicial de la serpiente en el centro
        snake_head_y <= 15;
        tail_count <= 0;
        game_won <= 0;
    end

    // Conversión de las coordenadas de entrada a unidades de la cuadrícula
    assign cur_x = (x_in / 16);
    assign cur_y = (y_in / 16);

    // Determinar qué entidad está presente en la posición actual
    always @(posedge vga_clk) begin
        if (cur_x == snake_head_x && cur_y == snake_head_y) begin
            entity <= 2'b01;  // Cabeza de la serpiente
        end else if (cur_x == apple_x && cur_y == apple_y) begin
            entity <= 2'b00;  // Manzana
        end else if (is_cur_coord_tail) begin
            entity <= 2'b10;  // Cola de la serpiente
        end else begin
            entity <= 2'b11;  // Espacio vacío
        end
    end

    // Verificación de colisiones con la cola
    always @(posedge vga_clk or posedge rst) begin
        integer i;
        if (rst) begin
            game_over = 0;
        end else begin
            is_cur_coord_tail = 1'b0;

            for (i = 0; i < 128; i = i + 1) begin
                if (i < tail_count) begin
                    if (tails[i] == {cur_x, cur_y}) begin
                        is_cur_coord_tail = 1'b1;
                    end
                    if (tails[i] == {snake_head_x, snake_head_y}) begin
                        game_over = 1'b1;  // Si la cabeza choca con la cola, el juego termina
                    end
                end
            end
        end
    end

    // Movimiento de la serpiente basado en la dirección ingresada
    always @(posedge update_clk or posedge rst) begin
        if (rst) begin
            // Reiniciar la posición de la serpiente
            snake_head_x <= 20;
            snake_head_y <= 15;
        end else begin
            if (~game_over) begin
                case (direction)
                    2'b00:
                        snake_head_x <= (snake_head_x == 0) ?
                                        39 : (snake_head_x - 12'd1);
                    2'b01:
                        snake_head_y <= (snake_head_y == 0) ?
                                        29 : (snake_head_y - 12'd1);
                    2'b11:
                        snake_head_x <= (snake_head_x == 39) ?
                                        0 : (snake_head_x + 12'd1);
                    2'b10:
                        snake_head_y <= (snake_head_y == 29) ?
                                        0 : (snake_head_y + 12'd1);
                endcase
            end
        end
    end

    // Actualización de la cola de la serpiente
    always @(posedge update_clk or posedge rst) begin
        integer i;
        if (rst) begin
            init();
            tail_count <= 0;
        end else begin
            // Si la cabeza de la serpiente alcanza la manzana
            if (snake_head_x == apple_x && snake_head_y == apple_y) begin
                // Agregar un nuevo segmento a la cola
                if (tail_count < 128) begin
                    tails[tail_count] <= {snake_head_x, snake_head_y};
                    tail_count <= tail_count + 1;
                end
                // Generar una nueva posición para la manzana
                apple_x <= rand_num_x_fit;
                apple_y <= rand_num_y_fit;
            end else begin
                // Mover la cola desplazando los segmentos
                for (i = 0; i < 128; i = i + 1) begin
                    if (i == (tail_count - 1)) begin
                        tails[i] <= {snake_head_x, snake_head_y};
                    end else begin
                        if (i != 127) begin
                            tails[i] <= tails[i + 1];
                        end
                    end
                end
            end
        end
    end

    // Comprobación de si el jugador ha ganado
    always @(posedge update_clk or posedge rst) begin
        if (rst) begin
            game_won <= 0;
        end else if (tail_count == 128) begin
            game_won <= 1;  // Se gana cuando la serpiente alcanza el tamaño máximo
        end
    end

endmodule
