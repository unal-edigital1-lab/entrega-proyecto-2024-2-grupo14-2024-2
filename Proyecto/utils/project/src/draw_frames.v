
`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Description:   Logic for drawing borders around the different elements:
//                - Game space
//                - Next building block preview
//                - User statistics
//                - Instructions screen
//////////////////////////////////////////////////////////////////////////////////

module draw_frames(

  input vga_clk,  // VGA clock signal
  input rst,  // Reset signal
  input [10:0] x, // Current pixel X coordinate
  input [9:0] y,  // Current pixel Y coordinate
  input [3:0] game_state,  // Current state of the game
  output reg [2:0] RGB,  // Combined RGB color output
  output reg dav  // Data valid signal
  
);

parameter STATE_LOGO = 4'b0000;  // Game state for the logo screen

always @ (posedge vga_clk) begin

  if (rst) begin
    RGB <= 3'b000;
    dav <= 0;
  end else begin
    // Main game area frame
    if ((y == 125 || y == 549) && (x >= 136 && x <= 392)) begin  // Top & Bottom borders
      RGB <= 3'b011; // Cyan
      dav <= 1;
    end else if ((x == 136 || x == 392) && (y >= 125 && y <= 549)) begin  // Left & Right borders
      RGB <= 3'b011; // Cyan
      dav <= 1;
    
    // Scoreboard frame
    end else if ((y == 125 || y == 235) && (x >= 404 && x <= 660)) begin  // Top & Bottom borders
      RGB <= 3'b110; // Yellow
      dav <= 1;
    end else if ((x == 404 || x == 660) && (y >= 125 && y <= 235)) begin  // Left & Right borders
      RGB <= 3'b110; // Yellow
      dav <= 1;
    
    // Next block preview frame (hidden during logo state)
    end else if ((game_state != STATE_LOGO) && (y == 247 || y == 335) && (x >= 404 && x <= 660)) begin
      RGB <= 3'b101; // Magenta
      dav <= 1;
    end else if ((game_state != STATE_LOGO) && (x == 404 || x == 660) && (y >= 247 && y <= 335)) begin
      RGB <= 3'b101; // Magenta
      dav <= 1;
    
    // Instructions/help frame (only shown in logo state)
    end else if ((game_state == STATE_LOGO) && (y == 247 || y == 389) && (x >= 404 && x <= 660)) begin
      RGB <= 3'b101; // Magenta
      dav <= 1;
    end else if ((game_state == STATE_LOGO) && (x == 404 || x == 660) && (y >= 247 && y <= 389)) begin
      RGB <= 3'b101; // Magenta
      dav <= 1;
    
    // Default case (no frame drawn)
    end else begin
      dav <= 0;
    end
  end
  
end

endmodule