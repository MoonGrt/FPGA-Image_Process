`timescale 1ns / 1ps
module image_cut#(
    parameter  H_DISP = 12'd1920,
    parameter  V_DISP = 12'd1080,
    parameter	INPUT_X_RES_WIDTH =	 11,		//Widths of input/output resolution control signals
    parameter	INPUT_Y_RES_WIDTH =	 11,
    parameter	OUTPUT_X_RES_WIDTH = 11,
    parameter	OUTPUT_Y_RES_WIDTH = 11
)(
    input wire clk,
    
    input wire [INPUT_X_RES_WIDTH-1:0] start_x,
    input wire [INPUT_Y_RES_WIDTH-1:0] start_y,
    input wire [OUTPUT_X_RES_WIDTH-1:0] end_x,
    input wire [OUTPUT_Y_RES_WIDTH-1:0] end_y,
    
    input wire hs_i,
    input wire vs_i,
    input wire de_i,
    input wire [23:0] rgb_i,
    
    output wire de_o,
    output wire vs_o,
    output wire [23:0] rgb_o,
    output reg  state = 0
);

reg [11:0] pixel_x = 0;
reg [11:0] pixel_y = 0;
assign rgb_o = de_o ? rgb_i : 24'dz;
assign de_o = ((pixel_x >= start_x && pixel_x < end_x) && (pixel_y >= start_y && pixel_y < end_y)) ? de_i&state : 0;
assign vs_o = (start_x == 0 && start_y == 0) ? vs_i : (pixel_x == start_x)&(pixel_y == start_y);

always@(posedge clk)
begin
	if(vs_i)
        state <= 1;
	else
        state <= state;
end

always@(posedge clk)
begin
    if(state)
       if(vs_i)
           pixel_x <= 0;
	   else if(de_i)
	       if(pixel_x == H_DISP - 1)
	           pixel_x <= 0;
	       else
	           pixel_x <= pixel_x + 1;
	   else
	       pixel_x <= pixel_x;
    else
        pixel_x <= 0;
end

always@(posedge clk)
begin
    if(state)
       if(vs_i)
           pixel_y <= 0;
	   else if(de_i)
	      if(pixel_x == H_DISP - 1)
	          if(pixel_y == V_DISP - 1)
	              pixel_y <= 0;
	          else
	              pixel_y <= pixel_y + 1;
	      else
	          pixel_y <= pixel_y;
	   else
           pixel_y <= pixel_y;
    else
        pixel_y <= 0;
end

endmodule
