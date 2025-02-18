
`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Description:   PS/2 interface module for interpreting keyboard scancodes.
//                It enables gameplay using a standard PS/2 keyboard.
//////////////////////////////////////////////////////////////////////////////////

module ps2(

  input clk,  // System clock
  input rst,  // Reset signal
  
  // PS/2 interface signals
  input ps2_clk,  // PS/2 clock
  input ps2_data, // PS/2 data
  
  // Decoded button presses
  output reg [8:0] buttons, // {P, M, Esc, Space, Up, Down, Left, Right, Enter}
  output [7:0] ps2_debug  // Debugging output
  
);


// Define PS/2 key scan codes
parameter SCAN_CODE_RELEASE = 8'hF0;
parameter SCAN_CODE_EXTENDER = 8'hE0;
parameter SCAN_CODE_ENTER = 8'h5A;   
parameter SCAN_CODE_LEFT = 8'h6B;    
parameter SCAN_CODE_RIGHT = 8'h74;   
parameter SCAN_CODE_UP = 8'h75;      
parameter SCAN_CODE_DOWN = 8'h72;    
parameter SCAN_CODE_SPACE = 8'h29;   
parameter SCAN_CODE_P = 8'h4D;       
parameter SCAN_CODE_M = 8'h3A;       
parameter SCAN_CODE_ESC = 8'h76;     


// Shift register to store incoming PS/2 bits
reg [10:0] shr;
reg [3:0] cntr;
reg ps2_clk_prev;


// Edge detection for PS/2 clock
always @ (posedge clk) begin

  if (rst) begin
  
    cntr <= 0;
    shr <= 0;
    ps2_clk_prev <= 1;
	 
  end else if (ps2_clk_prev != ps2_clk) begin // Detect clock edge
  
    ps2_clk_prev <= ps2_clk;
	 
    if (!ps2_clk) begin // Negative edge triggers data shift
	 
      shr <= {ps2_data, shr[10:1]};
      cntr <= (cntr == 11) ? 1 : cntr + 1;
		
    end
	 
  end
  
end


// Process received data
reg [1:0] state;
parameter STATE_IDLE = 2'b01;
parameter STATE_RELEASE = 2'b11;
parameter STATE_EXTENDER = 2'b00;
wire [7:0] byte_real = shr[8:1]; // Extract valid data bits
wire byte_received = (cntr == 11);


always @ (posedge clk) begin

  if (rst) begin
  
    buttons <= 0;
    state <= STATE_IDLE;
	 
  end else if (byte_received) begin // Process valid received data
  
    case (state)
	 
      STATE_IDLE: begin
		
        if (byte_real == SCAN_CODE_EXTENDER) 
		  
          state <= STATE_EXTENDER;
			 
        else if (byte_real == SCAN_CODE_RELEASE)
		  
          state <= STATE_RELEASE;
			 
      end
		
      STATE_EXTENDER: begin
		
        if (byte_real == SCAN_CODE_RELEASE)
		  
          state <= STATE_RELEASE;
			 
        else
		  
          state <= STATE_IDLE;
			 
      end
		
      STATE_RELEASE: begin
		
        case (byte_real)
		  
          SCAN_CODE_ENTER: buttons[0] <= 1;
          SCAN_CODE_RIGHT: buttons[1] <= 1;
          SCAN_CODE_LEFT: buttons[2] <= 1;
          SCAN_CODE_DOWN: buttons[3] <= 1;
          SCAN_CODE_UP: buttons[4] <= 1;
          SCAN_CODE_SPACE: buttons[5] <= 1;
          SCAN_CODE_M: buttons[7] <= buttons[7] ^ 1;
          SCAN_CODE_P: buttons[8] <= buttons[8] ^ 1;
          SCAN_CODE_ESC: buttons[6] <= 1;
			 
        endcase
		  
        state <= STATE_IDLE;
		  
      end
		
    endcase
	 
  end
  
end


// Debugging output
assign ps2_debug = cntr;


endmodule