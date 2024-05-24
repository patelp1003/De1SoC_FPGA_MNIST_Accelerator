/*
 * Avalon memory-mapped peripheral controlling OV7670 to BRAM
 *
 * Prathmesh 
 * Columbia University
 */

module vga_ball(input logic   clk,
	    input logic 	    reset,
		input logic [7:0]   writedata,
		input logic 	    write,
		input 		        chipselect,
		input logic [2:0]   address,
		output logic [7:0]  readdata,
		input logic 	    read,

		////////////////BUTTON/////////////////
		input wire  [3:0]   VGA_KEY,
		
		/////////////////LEDS//////////////////
		output wire [9:0]   VGA_LEDR,

		/////////////////CAMERA//////////////////
		input wire          VGA_CMOS_PCLK,VGA_CMOS_HREF,VGA_CMOS_VSYNC,
	    input wire  [7:0]   VGA_CMOS_DB,
	    inout               VGA_CMOS_SDA,VGA_CMOS_SCL,
	    
		output wire         VGA_CMOS_RST_N, VGA_CMOS_PWDN, VGA_CMOS_XCLK,
		output wire         VGA_CMOS_PWR, VGA_CMOS_GND,
		
	    /////////////////VGA//////////////////
	    output logic [7:0]  VGA_R, VGA_G, VGA_B,
		output logic 	    VGA_CLK, VGA_HS, VGA_VS

		
		);
	
	 wire[15:0] dout;
	 wire[15:0] din;
	 wire       empty_fifo;
	 wire       state;
	 wire       rd_en;
     wire       rd_en_cam;
     wire       rd_en_to_avalon;
	 
	 reg [27:0] c;
	 wire[7:0]  button_count;
	 wire[7:0]  pixel_data;
	 //wire[12:0] row_count;
	 //wire[12:0] column_count;
	 reg[15:0] read_ptr_avalon;
	   
	 
	 //reg[7:0] read_ptr_avalon_lower_bits;
	 //reg[2:0] read_ptr_avalon_upper_bits;
	 //cases for memory read inquiry coming from software
	 localparam BUTTON_COUNT    = 0,
	            PIXEL_DATA      = 1,
	            LAYER_DONE      = 2;
	/*            
	 always @(posedge clk) begin
	     if (reset) begin
	        readdata <= 8'h0;
         end else if (chipselect && read) begin
             case (address)
	            BUTTON_COUNT : begin 
	                readdata <= button_count;
	                read_flag <= 0;
	            end
	            PIXEL_DATA : begin 
	                readdata <= pixel_data;
	                read_flag <= 0;
	            end
	            LAYER_DONE : begin 
	                rd_en_to_avalon<=0;
	                readdata <= done;
	            end
             endcase
         end
    end*/ 
       
       
       localparam WRITE_PIXEL_LOW       = 0,
                  WRITE_PIXEL_UP        = 1,
                  WRITE_GO              = 2,
                  WRITE_LAYER_IDX       = 3,
                  WRITE_DATA_ADDR_LOW   = 4,
                  WRITE_DATA_ADDR_UP    = 5,
                  WRITE_WEIGHT_ADDR_LOW = 6,
                  WRITE_WEIGHT_ADDR_UP  = 7;
                  
       logic read_flag;
       assign read_flag = 1;
       
        always @(posedge clk) begin
	        if (reset) begin
	            read_ptr_avalon <= 8'h0;
	            //read_flag <= 0;
	            readdata        <= 8'h0;
	        end else if (chipselect && write) begin
                case (address)
	                WRITE_PIXEL_LOW :  begin
	                            read_ptr_avalon[7:0] <= writedata;
	                            //read_flag <= 1;
	                        end
	                WRITE_PIXEL_UP : begin
	                            read_ptr_avalon[15:8] <= writedata;
	                            //read_flag <= 1;
	                        end
	                /*WRITE_GO :         begin
	                            go<=writedata;
	                            read_flag <= 0;
	                        end
	                WRITE_LAYER_IDX :  begin
	                            layer_index<=writedata;
	                            read_flag <= 0;
	                        end
	                WRITE_DATA_ADDR_LOW :  begin
	                            data_address[7:0]<=writedata;
	                            read_flag <= 0;
	                        end
	                WRITE_DATA_ADDR_UP :  begin
	                            data_address[15:8]<=writedata;
	                            read_flag <= 0;
	                        end
	                WRITE_WEIGHT_ADDR_LOW :  begin
	                            weight_address[7:0]<=writedata;
	                            read_flag <= 0;
	                        end
	                WRITE_WEIGHT_ADDR_UP :  begin
	                            weight_address[15:8]<=writedata;
	                            read_flag <= 0;
	                        end*/
	                
	                //default:    read_flag <= 0;                
                endcase
            end else if (chipselect && read) begin
                case (address)
	                BUTTON_COUNT : begin 
	                    readdata <= button_count;
	                    //read_flag <= 0;
	                end
	                PIXEL_DATA : begin 
	                    readdata <= pixel_data;
	                    //read_flag <= 0;
	                end
	                //LAYER_DONE : begin 
	                //    rd_en_to_avalon<=0;
	                //    readdata <= done;
	                //end
                endcase
            end
	    end

 
    always @(posedge clk) begin
        if(reset)
            c <= 0;
    
        else begin
            if(c[27])begin   
    
                VGA_LEDR[3] <= 0;
              // led0_r<=0;
              // led0_g<=0;
                VGA_LEDR[4] <= 0;
            end
    
            else begin
             VGA_LEDR[3] <= 1;
            // led0_r<=1;
            // led0_g<=1;
             VGA_LEDR[4] <= 1;
            end
   
            c <= c + 1;
       end
        
    end
    
    wire pir;
    assign pir = 0;
    assign VGA_CMOS_PWR     = 1;
    assign VGA_CMOS_GND     = 0;
    assign VGA_LEDR[8]      = !(reset);
    //assign VGA_LEDR[7:5]    = 3'b000;
    //assign VGA_LEDR[9]      =!(reset);
    
    
    logic [15:0] memory_idx;
    assign memory_idx = (read_flag) ? read_ptr_avalon : image_idx[15:0];
    
	camera_interface m0 //control logic for retrieving data from camera, storing data to asyn_fifo, and  sending data to sdram
	(
		.clk(clk),
		.clk_100(clk),
		.clk_vga(VGA_CLK),
		.rst_n(!reset),
		.key(VGA_KEY),
		.pir(pir),
		.rd_en_vga(rd_en),
		.rd_en(rd_en),
		.dout_vga(din),
		.button_count_q(button_count),
		
		//camera pinouts
		.cmos_pclk(VGA_CMOS_PCLK),
		.cmos_href(VGA_CMOS_HREF),
		.cmos_vsync(VGA_CMOS_VSYNC),
		.cmos_db(VGA_CMOS_DB),
		.cmos_sda(VGA_CMOS_SDA),
		.cmos_scl(VGA_CMOS_SCL), 
		.cmos_rst_n(VGA_CMOS_RST_N),
		.cmos_pwdn(VGA_CMOS_PWDN),
		.cmos_xclk(VGA_CMOS_XCLK),
		
		//memory to avalon
		.rd_en_to_avalon(rd_en_to_avalon),
		.pixel_data(pixel_data),
		.rd_ptr_from_avalon(memory_idx),
		
		//Debugging
		.led_start(VGA_LEDR[2]),
		.flag(VGA_LEDR[0]),
		.flag2(VGA_LEDR[1])
		
    );
   
    vga_interface m2 //control logic for retrieving data from sdram, storing data to asyn_fifo, and sending data to vga
    (
		.clk(clk),
		.rst_n(!reset),
		//asyn_fifo IO
		.din(din),
		.clk_vga(VGA_CLK),
		.rd_en(rd_en),   

		//VGA output
		.vga_out_r(VGA_R),
		.vga_out_g(VGA_G),
		.vga_out_b(VGA_B),
		.vga_out_vs(VGA_VS),
		.vga_out_hs(VGA_HS)
    );
    
    
    logic [7 : 0] image;
    logic [31 : 0] image_idx;
    
    assign image = pixel_data;

	// Software
	logic	        go;             //write
	logic  [ 2 : 0] layer_index;    //write
	logic  [15 : 0] data_address;   //write
	logic  [31 : 0] data_size;      //not needed
	logic  [15 : 0] weight_address; //write
	logic  [31 : 0] weight_size;    //not needed
	logic  [31 : 0] result_address; //not needed
	logic  [ 2 : 0]        done;           //read
	
	//assign data_address[31:16] = 0;
	//assign weight_address[31:16] = 0;
	
	assign data_size = 0;
	assign weight_size = 0;
	assign result_address = 0;
	
	logic rstn;
	assign rstn = ~reset;
	
	top top_acc (.clk(clk), .rstn(rstn), .image(image), .image_idx(image_idx), .go(go), .layer_index(layer_index), 
	             .data_address({{16{1'b0}}, data_address}), .data_size(data_size), .weight_address({{16{1'b0}},weight_address}), 
	             .weight_size(weight_size),  .result_address(result_address), .done(done));
    
    
endmodule
