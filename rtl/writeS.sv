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

module writeS (
		input logic clock,
		input logic resetn,
		input logic write_start,
		output logic write_finish, 
		input logic col_block,
		input logic row_block,
		input logic  [15:0] SRAM_read_data,
		output logic [15:0] SRAM_write_data,
		output logic SRAM_we_n,
		output logic [17:0] SRAM_address
);
 
 
logic [6:0] address_4, address_5; 
logic [31:0] write_data_a[2:0];
logic [31:0] write_data_b[2:0];
logic write_enable_a[2:0];
logic write_enable_b[2:0];
logic [31:0] read_data_a[2:0];
logic [31:0] read_data_b[2:0]; 
 
 

//fetching for S 
dual_port_RAM2 dual_port_RAM_inst2 (
	.address_a (address_4),
	.address_b (address_5),
	.clock (clock),
	.data_a (write_data_a[2]),
	.data_b (write_data_b[2]),
	.wren_a (write_enable_a[2]),
	.wren_b (write_enable_b[2]),
	.q_a (read_data_a[2]),
	.q_b (read_data_b[2])
	);

writeS_state_type state;
 
parameter IDCT_OFFSET = 18'd76800;
parameter Y_OFFSET = 18'd0;
parameter U_OFFSET = 18'd38400;
parameter V_OFFSET = 18'd57600;

logic [31:0] S0, S1;
logic [7:0] row_counter;
logic [12:0] sram_row_count;
logic [3:0] write_counter;

logic [7:0] S0_clip, S1_clip;


always_ff @(posedge clock or negedge resetn) begin
	if (!resetn) begin

		S0 <= 32'd0;
		S1 <= 32'd0;
		
		write_finish <= 1'b0;
		
		row_counter <= 8'd0;
		sram_row_count <= 8'd0;
		write_counter <= 8'd0;

		
		address_4 <= 7'd0;
		address_5 <= 7'd0;
		
		SRAM_we_n <= 1'b1;
		SRAM_write_data <= 16'd0;
		SRAM_address <= 18'd0;


		state <= WS_IDLE;
	end else begin
		case (state)
			WS_IDLE: begin
				
				if(write_start) begin

					S0 <= 32'd0;
					S1 <= 32'd0;
					
					write_finish <= 1'b0;
					
					row_counter <= 8'd0;
					sram_row_count <= 8'd0;
					write_counter <= 8'd0;

					address_4 <= 7'd0;
					address_5 <= 7'd0;
					
					SRAM_we_n <= 1'b1;
					SRAM_write_data <= 16'd0;
					SRAM_address <= 18'd0;
					state <= WS_0;
				end
			end
			WS_0: begin
				SRAM_we_n <= 1'd1;
				
				if (sram_row_count == 11'd1120) begin
					write_finish <= 1'b1;
					state <= WS_IDLE; 
				end else begin
				  state <= WS_1;       
				end
			end
			
			WS_1: begin
				 address_4 <= 1'd0 + row_counter; // Set address for dual-port RAM
				 address_5 <= 1'd1 + row_counter;
				 state <= WS_2;
			end
			
			WS_2: begin
				 S0 <= read_data_a[2]; // Set address for dual-port RAM
				 S1 <= read_data_b[2];
				 
				 address_4 <= address_4 + 2'd2;
				 address_5 <= address_5 + 2'd2;
				 
				 state <= WS_3;
			end

			WS_3: begin
				SRAM_we_n <= 1'd0;
				SRAM_address <= Y_OFFSET + write_counter + (col_block << 2) + ((sram_row_count << 5) + (sram_row_count << 7)) + (((row_block << 7) + (row_block << 7)) << 2);
				write_counter <= write_counter + 1;
				SRAM_write_data <= {S0_clip, S1_clip};
				
				if(write_counter == 3'd4) begin
					row_counter <= row_counter + 4'd8;
					sram_row_count <= sram_row_count + 1'd1;
				end
			
				 state <= WS_0;
			end

				default: state <= WS_IDLE;
        endcase
    end
end


always_comb begin
	if (S0[31] == 1'b1) S0_clip = 8'd0;
	else if (|S0[30:24] ==1'b1) S0_clip = 8'd255;
	else S0_clip = S0[23:16];
end

always_comb begin
	if (S1[31] == 1'b1) S1_clip = 8'd0;
	else if (|S1[30:24] ==1'b1) S1_clip = 8'd255;
	else S1_clip = S1[23:16];
end

endmodule
