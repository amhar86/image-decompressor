/*
Copyright by Henry Ko and Nicola Nicolici
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif
`include "define_state.h"

// This is the top module
// It connects the SRAM and VGA together
// It will first write RGB data of an image with 8x8 rectangles of size 40x30 pixels into the SRAM
// The VGA will then read the SRAM and display the image
module FetchS (
		input logic clock,
		input logic resetn,
		input logic fetch_start,
		output logic fetch_finish,
		input logic [5:0] col_block,
		input logic [5:0] row_block,
		input logic [1:0] sel,
		input logic  [15:0] SRAM_read_data,
		output logic [15:0] SRAM_write_data,
		output logic SRAM_we_n,
		output logic [17:0] SRAM_address
		
);


fetchS_state_type state;


logic [6:0] address_0, address_1;
logic [31:0] write_data_a;
logic [31:0] write_data_b;
logic [1:0] write_enable_a;
logic [1:0] write_enable_b;
logic [31:0] read_data_a;
logic [31:0] read_data_b;



// Instantiate DPRAM for fetching S' 

dual_port_RAM0 dual_port_RAM_inst0 (
	.address_a (address_0),
	.address_b (address_1),
	.clock (clock),
	.data_a (write_data_a),
	.data_b (write_data_b),
	.wren_a (write_enable_a),
	.wren_b (write_enable_b),
	.q_a (read_data_a),
	.q_b (read_data_b)
	);


parameter IDCT_OFFSET = 18'd76800;
parameter Y_OFFSET = 18'd0;
parameter U_OFFSET = 18'd38400;
parameter V_OFFSET = 18'd57600;


//fetch counters
logic [3:0] fetch_counter;
logic [3:0] row_counter;
logic [3:0] counter1;


//fetch buffers
logic [15:0] fetch_buff;

always_ff @(posedge clock or negedge resetn) begin
	if (!resetn) begin
		// Reset state variables
		fetch_counter <= 4'd0;
		SRAM_address <= IDCT_OFFSET;
		address_0 <= 7'd0;
		address_1 <= 7'd0;
		fetch_buff <= 16'd0;
		fetch_finish <= 1'd0;
		counter1 <= 4'd0;
		row_counter <= 4'd0;
		read_data_a <= 1'b0;
		read_data_b <= 1'b0;
		address_0 <= 7'd0;
		address_1 <= 7'd0;
		state <= Fetch_IDLE;
	end else begin
		case (state)
			Fetch_IDLE: begin
				
				if(fetch_start) begin
					fetch_counter <= 4'd0;
					SRAM_address <= IDCT_OFFSET;
					write_enable_a[0] <= 1'b0;

					address_1 <= 7'd0;
					fetch_buff <= 16'd0;
					fetch_finish <= 1'd0;
					counter1 <= 4'd0;
					row_counter <= 4'd0;
					read_data_a[0] <= 1'b0;
					read_data_b[0] <= 1'b0;

					state <= Fetch_S0;
				end
			end
					
						
			Fetch_S0: begin			
		
				SRAM_we_n <= 1'b1;
				SRAM_address <= IDCT_OFFSET + fetch_counter + (col_block << 3) + ((row_counter << 8) + (row_counter << 6)) + (((row_block << 8) + (row_block << 6)) << 3); // block column change + multiplication by 320 to change rows within a block
				fetch_counter <= fetch_counter + 4'd1; //0
				state <= Fetch_S1;
				
				if(row_counter == 4'd8) begin // one block done
					fetch_finish <= 1'd1;
					state <= Fetch_IDLE;
				end
			end
                        
		
			Fetch_S1: begin
				SRAM_address <= IDCT_OFFSET+ fetch_counter + (col_block << 3) + ((row_counter << 8) + (row_counter << 6)) + (((row_block << 8) + (row_block << 6)) << 3);
				fetch_counter <= fetch_counter + 4'd1; //1
				state <= Fetch_S2;
			end
		
			Fetch_S2:begin
				SRAM_address <= IDCT_OFFSET + fetch_counter + (col_block << 3) + ((row_counter << 8) + (row_counter << 6)) + (((row_block << 8) + (row_block << 6)) << 3);
				fetch_counter <= fetch_counter + 4'd1;//2
				
				state <= Fetch_S3;
				
			end
		
			Fetch_S3:begin
				SRAM_address <= IDCT_OFFSET + fetch_counter + (col_block << 3) + ((row_counter << 8) + (row_counter << 6)) + (((row_block << 8) + (row_block << 6)) << 3);
				fetch_counter <= fetch_counter + 4'd1;//3
				
				if(counter1 == 2'd0) begin
					address_0 <= address_0 + 7'd0;
				end else begin
					address_0 <= address_0 + 1'd1;
				end
				
				write_enable_a <= 1'b1;
				fetch_buff <= SRAM_read_data;
				
				state <= Fetch_S4;
			end
			
			Fetch_S4: begin
				SRAM_address <= IDCT_OFFSET + fetch_counter + (col_block << 3) + ((row_counter << 8) + (row_counter << 6)) + (((row_block << 8) + (row_block << 6)) << 3);
				fetch_counter <= fetch_counter + 4'd1; //4
				
				write_data_a= {fetch_buff, SRAM_read_data};
				write_enable_a <= 1'b1;
				
				counter1 <= counter1 + 1'd1;
				
				if(counter1 == 2'd1) begin
					state <= Fetch_S5;
				end else begin
					state <= Fetch_S3;
				end	
				
			end
		
		
			Fetch_S5: begin
				SRAM_address <= IDCT_OFFSET + fetch_counter + (col_block << 3) + ((row_counter << 8) + (row_counter << 6)) + (((row_block << 8) + (row_block << 6)) << 3);
				fetch_counter <= fetch_counter + 4'd1;
			
				address_0 <= address_0 + 1'd1;
				write_enable_a<= 1'b0;
			
				fetch_buff <= SRAM_read_data;
				
				state <= Fetch_S6; 
			
			end
		
			Fetch_S6: begin	
				write_data_a<= {fetch_buff,SRAM_read_data};
				write_enable_a <= 1'b1;
				state <= Fetch_S7;
			end
		
			Fetch_S7: begin
				address_0 <= address_0 + 1'd1;
				write_enable_a<= 1'b0;
			
				fetch_buff <= SRAM_read_data;
				
				state <= Fetch_S8; 
			
			end
		
			Fetch_S8: begin	
				write_data_a <= {fetch_buff,SRAM_read_data};
				write_enable_a <= 1'b1;
				state <= Fetch_IDLE;
				
				row_counter <= row_counter + 4'd1;
				fetch_counter <= 0;
				state <= Fetch_S0;
			
			end
				default: state <= Fetch_IDLE;
        endcase
    end
end

endmodule