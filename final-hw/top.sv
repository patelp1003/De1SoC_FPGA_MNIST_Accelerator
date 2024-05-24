module top
#( 
	parameter data_width 	= 8,
	parameter weight_width 	= 8
) (	
	input logic clk,
	input logic rstn,
	
	input logic [data_width-1 : 0] image,
	output logic [31 : 0] image_idx,

	// Software
	input logic	      go,
	input logic  [ 2 : 0] layer_index,
	input logic  [31 : 0] data_address,
	input logic  [31 : 0] data_size,
	input logic  [31 : 0] weight_address,
	input logic  [31 : 0] weight_size,
	input logic  [31 : 0] result_address,
	output logic [ 2 : 0] done
);

	// Control Unit -> Kernel
	logic	      en;
	logic 	      init;
	logic	      [1:0] mode;
	logic	      bias_en;

	// Control Unit -> Memories
	logic [31 : 0] data_idx;
	logic [31 : 0] weight_idx;
	logic [31 : 0] result_idx;
	logic	       write_enable;

	// Memories -> Kernel
	logic [  data_width-1 : 0] result;
	logic [  data_width-1 : 0] data;
	logic [weight_width-1 : 0] weight;

	logic [  data_width-1 : 0] data_kernel;
	
	assign image_idx = data_idx;
	
	assign data_kernel = (mode == 0) ? image : data;
	
	
	
	cu 	     control_unit (.clk(clk), .rstn(rstn), .go(go), .layer_index(layer_index), .data_address( data_address), .data_size(data_size), 
	                       .weight_address(weight_address), .weight_size(weight_size), .result_address(result_address), .done(done), .en(en), 
	                       .init(init), .mode(mode), .bias_en(bias_en), .data_idx(data_idx), .weight_idx(weight_idx), .result_idx(result_idx), .write_enable(write_enable));
	
	
	kernel   kernel_unit  (.clk(clk), .en(en), .init(init), .mode(mode), .bias_en(bias_en), .data(data_kernel), .weight(weight), .result(result));
	
	
	memory   memory_unit (.clk(clk), .rstn(rstn), .mode(mode), .data_idx(data_idx), .weight_idx(weight_idx), .result_idx(result_idx), 
	                      .write_enable(write_enable), .data(data), .weight(weight), .result(result));

endmodule
	
