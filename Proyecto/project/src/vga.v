
`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Description:   VGA display module for handling the graphical output of the game.
//////////////////////////////////////////////////////////////////////////////////

module vga(

  input clk,  // System clock
  input rst,  // Reset signal
  
  // Game state inputs
  input [3:0] game_state,
  input [11:0] game_area_data,
  output [4:0] game_area_addr,
  input [7:0] game_block_next,
  input [25:0] game_points,
  input [25:0] game_lines,
  input [3:0] game_level,
  
  // VGA output signals
  output reg vga_hs,  // Horizontal sync
  output reg vga_vs,  // Vertical sync
  output [1:0] vga_red,
  output [1:0] vga_green,
  output [1:0] vga_blue
  
);


// Horizontal and vertical counters for pixel tracking
reg [10:0] cntr_hr;
reg [9:0] cntr_vr;


// Counter update logic
always @ (posedge clk) begin

  if (rst) begin
  
    cntr_hr <= 0;
    cntr_vr <= 0;
	 
  end else begin
  
    if (cntr_hr == 1039) begin
	 
      cntr_hr <= 0;
      cntr_vr <= (cntr_vr == 665) ? 0 : cntr_vr + 1;
		
    end else begin
	 
      cntr_hr <= cntr_hr + 1;
		
    end
	 
  end
  
end


// Blank region detection
wire blank_hr = (cntr_hr >= 800);
wire blank_vr = (cntr_vr >= 600);
reg blank_region;


always @ (posedge clk) begin

  blank_region <= blank_hr | blank_vr;
  
end


// Sync signal generation
always @ (posedge clk) begin

  vga_hs <= (cntr_hr >= 856 && cntr_hr <= 975);
  vga_vs <= (cntr_vr >= 637 && cntr_vr <= 643);
  
end


// Modules for rendering different elements
// Frames
wire [1:0] drawframes_r, drawframes_g, drawframes_b;
wire drawframes_dav;
draw_frames drawFrames(

  .vga_clk(clk), .rst(rst), .x(cntr_hr), .y(cntr_vr),
  .game_state(game_state), .r(drawframes_r), .g(drawframes_g), .b(drawframes_b), .dav(drawframes_dav)

  );

  
// Blocks
wire [1:0] drawblocks_r, drawblocks_g, drawblocks_b;
wire drawblocks_dav;
draw_blocks drawBlocks(

  .vga_clk(clk), .rst(rst), .x(cntr_hr), .y(cntr_vr),
  .game_state(game_state), .game_area_data(game_area_data),
  .game_area_addr(game_area_addr), .game_block_next(game_block_next),
  .r(drawblocks_r), .g(drawblocks_g), .b(drawblocks_b), .dav(drawblocks_dav)
  
);


// Score, Lines, and Level
wire drawscore_dav, drawlines_dav, drawlevel_dav;
wire [11:0] drawscore_addr, drawlines_addr, drawlevel_addr;


// Number rendering for score
wire [1:0] drawnumbers_r, drawnumbers_g, drawnumbers_b, numbers_data;
wire drawnumbers_dav;
reg [11:0] drawnumbers_addr;
assign drawnumbers_r = numbers_data;
assign drawnumbers_g = numbers_data;
assign drawnumbers_b = numbers_data;
assign drawnumbers_dav = drawscore_dav | drawlevel_dav | drawlines_dav;


// Data multiplexer
reg [1:0] red, green, blue;
always @ (posedge clk) begin
  if(drawframes_dav) begin
    red <= drawframes_r; green <= drawframes_g; blue <= drawframes_b;
  end else if(drawblocks_dav) begin
    red <= drawblocks_r; green <= drawblocks_g; blue <= drawblocks_b;
  end else if(drawnumbers_dav) begin
    red <= drawnumbers_r; green <= drawnumbers_g; blue <= drawnumbers_b;  
  end else begin // Default background color
    red <= 2'b00; green <= 2'b00; blue <= 2'b00;
  end
end


// VGA color output assignment
assign vga_red = blank_region ? 2'b00 : red;
assign vga_green = blank_region ? 2'b00 : green;
assign vga_blue = blank_region ? 2'b00 : blue;

endmodule
