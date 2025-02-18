
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
  output [2:0] vga_RGB
  
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
wire [2:0] drawframes_RGB;
wire drawframes_dav;
draw_frames drawFrames(

  .vga_clk(clk), .rst(rst), .x(cntr_hr), .y(cntr_vr),
  .game_state(game_state), .RGB(drawframes_RGB), .dav(drawframes_dav)

  );

  
// Blocks
wire [2:0] drawblocks_RGB;
wire drawblocks_dav;
draw_blocks drawBlocks(

  .vga_clk(clk), .rst(rst), .x(cntr_hr), .y(cntr_vr),
  .game_state(game_state), .game_area_data(game_area_data),
  .game_area_addr(game_area_addr), .game_block_next(game_block_next),
  .RGB(drawblocks_RGB), .dav(drawblocks_dav)
  
);


// Score, Lines, and Level
wire drawscore_dav, drawlines_dav, drawlevel_dav;
wire [11:0] drawscore_addr, drawlines_addr, drawlevel_addr;


// Number rendering for score
wire [2:0] drawnumbers_RGB, numbers_data;
wire drawnumbers_dav;
reg [11:0] drawnumbers_addr;
assign drawnumbers_RGB = {numbers_data, numbers_data, numbers_data};
assign drawnumbers_dav = drawscore_dav | drawlevel_dav | drawlines_dav;


// Data multiplexer
reg [2:0] RGB;
always @ (posedge clk) begin
  if(drawframes_dav) begin
    RGB <= drawframes_RGB;
  end else if(drawblocks_dav) begin
    RGB <= drawblocks_RGB;
  end else if(drawnumbers_dav) begin
    RGB <= drawnumbers_RGB;  
  end else begin // Default background color
    RGB <= 3'b000;
  end
end


// VGA color output assignment
assign vga_RGB = blank_region ? 3'b000 : RGB;

endmodule