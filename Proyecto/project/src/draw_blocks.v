
`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Description:   Logic for drawing the game space
//////////////////////////////////////////////////////////////////////////////////

module draw_blocks(

  input vga_clk,  // Clock signal for VGA synchronization
  input rst,  // Reset signal
  input [10:0] x, // Current pixel X coordinate
  input [9:0] y,  // Current pixel Y coordinate
  input [3:0] game_state,  // Current state of the game
  input [11:0] game_area_data,  // Data representing the game area blocks
  output reg [4:0] game_area_addr,  // Address for reading game area data
  input [7:8] game_block_next,  // Data representing the next block to be displayed
  output reg [2:0] RGB,  // Combined RGB color output
  output reg dav  // Data valid signal
  
);

parameter STATE_LOGO = 4'b0000;  // Game state when the logo is displayed

// Determines if the current line is within the valid game area
reg valid_line;

always @ (posedge vga_clk) begin
  if (rst) begin
    valid_line <= 0;
    game_area_addr <= 0;
  end else begin
    if ((y >= 129) && (y <= 545)) begin  // Check if Y is within game area
      game_area_addr <= (y - 129) / 21;  // Map Y coordinate to game area row
      valid_line <= 1;
    end else begin
      valid_line <= 0;
    end
  end
end

// Multiplexer for game area data
wire [11:0] game_area_mx;
assign game_area_mx = valid_line ? game_area_data : 12'h000;

// Determine the block to be displayed next
reg [3:0] nextblock_mx;

always @ (posedge vga_clk) begin
  if (rst) begin
    nextblock_mx <= 0;
  end else if (game_state != STATE_LOGO) begin  // Avoid flickering on next block preview
    if ((y >= 272) && (y <= 310)) begin
      nextblock_mx <= (game_block_next == 8'hCC) ? 6 : game_block_next[3:0];
    end else begin
      nextblock_mx <= 0;
    end
  end else begin
    nextblock_mx <= 0;
  end
end

// Assign colors to game area pixels based on their position and state
always @ (posedge vga_clk) begin
  if (rst) begin
    RGB <= 3'b000;
    dav <= 0;
  end else begin
    if (game_area_mx != 0) begin
      RGB <= 3'b111;  // White color for active blocks
      dav <= 1;
    end else if (nextblock_mx != 0) begin
      RGB <= 3'b111;  // White color for next block preview
      dav <= 1;
    end else begin
      dav <= 0;
    end
  end
end

endmodule