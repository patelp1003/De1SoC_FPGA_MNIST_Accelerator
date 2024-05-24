`timescale 1ns / 1ps

module vga_interface(
	input wire clk,rst_n,
	//asyn_fifo IO
	input wire empty_fifo,
	input wire[7:0] din,
	output wire clk_vga,
	output reg rd_en,
	//VGA output
	output reg[7:0] vga_out_r,
	output reg[7:0] vga_out_g,
	output reg[7:0] vga_out_b,
	output wire vga_out_vs,vga_out_hs
    );
	 //FSM state declarations
	 localparam delay=0,
					idle=1,
					display=2;
					
	 reg[1:0] state_q,state_d;
	 reg [7:0] r8Bit;
	 reg [7:0] g8Bit;
	 reg [7:0] b8Bit;
	 wire[11:0] pixel_x,pixel_y;
	 //register operations
	 always @(posedge clk_out,negedge rst_n) begin
		if(!rst_n) begin
			state_q<=delay;
		end
		else begin
			state_q<=state_d;
		end
	 end
	 
	 //FSM next-state logic
	 always @* begin
	 state_d=state_q;
	 rd_en=0;
	 r8Bit = din[7:4];
	 g8Bit = din[7:4];
	 b8Bit = din[7:4];
	 r8Bit = (255/31) * r8Bit;
	 g8Bit = (255/63) * g8Bit;
	 b8Bit = (255/31) * b8Bit;
	 
	 
	 //r8Bit = (din[15:11] * 10'b1000001111 + 23) >> 7;
	 //g8Bit = (din[10:5] * 9'b100000011 + 33) >> 6;
	 //b8Bit = (din[4:0] * 10'b1000001111 + 23) >>7;
	 //r8Bit = (r8Bit/31) + 8'b0;
	 //g8Bit = (g8Bit/63) + 8'b0;
	 //b8Bit = (b8Bit/31) + 8'b0;
	 vga_out_r=0;
	 vga_out_g=0;
	 vga_out_b=0;
		case(state_q)
		  delay: if(pixel_x==1 && pixel_y==1) state_d=idle; //delay of one frame(33ms) needed to start up the camera
			idle:  if(pixel_x==1 && pixel_y==0 ) begin //wait for pixel-data coming from asyn_fifo 
							//vga_out_r=din[15:11]; 
							//vga_out_g=din[10:5];
							//vga_out_b=din[4:0];
							vga_out_r = r8Bit;
							vga_out_g = g8Bit;
							vga_out_b = b8Bit;
							rd_en=1;	
							state_d=display;
					end
		display: if(pixel_x>=1 && pixel_x<=42  && pixel_y<42) begin //we will continue to read the asyn_fifo as long as current pixel coordinate is inside the visible screen(640x480) 
						vga_out_r=r8Bit; 
						vga_out_g=g8Bit;
						vga_out_b=b8Bit;
							
						rd_en=1;	
					end
			idle: state_d=delay;
		endcase
	 end
	 
	 
	 
	assign clk_vga=clk_out;
	
	//module instantiations
	vga_core m0
	(
		.clk(clk_out), //clock must be 25MHz for 640x480
		.rst_n(rst_n),  
		.hsync(vga_out_hs),
		.vsync(vga_out_vs),
		.video_on(),
		.pixel_x(pixel_x),
		.pixel_y(pixel_y)
	);	

         clock_25_0002 clock_25_inst (
		.refclk   (clk),   //  refclk.clk
		.rst      (rst),      //   reset.reset
		.outclk_0 (clk_out), // outclk0.clk
		.locked   ()          // (terminated)
	);
 

/*
	 dcm_25MHz m1 //clock for vga(620x480 60fps) 
   (// Clock in ports
    .clk(clk),      // IN
    // Clock out ports
    .clk_out(clk_out),     // OUT
    // Status and control signals
    .RESET(RESET),// IN
    .LOCKED(LOCKED));      // OUT
*/	 


endmodule
