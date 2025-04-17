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
module Milestone_2 (
		input logic clock,
		input logic resetn,
		input logic start,
		output logic finish,
		input logic  [15:0] SRAM_read_data,
		output logic [15:0] SRAM_write_data,
		output logic SRAM_we_n,
		output logic [17:0] SRAM_address 
);
M2_state_type state;



logic [1:0] sel;

logic FS_enable, FS_done,FS_we_n;
logic [15:0] FS_write_data;
logic [17:0] FS_address;


logic [5:0] col_block_top;
logic [5:0] row_block_top;



FetchS FS_unit(
	.clock(clock),
	.resetn(resetn),
	.fetch_start(FS_enable),
	.fetch_finish(FS_done),
	.col_block(col_block_top),
	.row_block(row_block_top),
	.sel(sel),
	.SRAM_read_data(SRAM_read_data),
	.SRAM_write_data(FS_write_data),
	.SRAM_we_n(FS_we_n),
	.SRAM_address(FS_address)
);


logic CT_enable, CT_done;
computeT CT_unit(
	.clock(clock),
	.resetn(resetn),
	.compute_t_start(CT_enable),
	.compute_t_finish(CT_done)
);

logic CS_enable, CS_done;
computeS CS_unit(
	.clock(clock),
	.resetn(resetn),
	.compute_s_start(CS_enable),
	.compute_s_finish(CS_done)
);


logic WS_enable, WS_done,WS_we_n;
logic [15:0] WS_write_data;
logic [17:0] WS_address;
writeS WS_unit(
	.clock(clock),
	.resetn(resetn),
	.write_start(WS_enable),
	.write_finish(WS_done),
	.col_block(col_block_top),
	.row_block(row_block_top),
	.SRAM_read_data(SRAM_read_data),
	.SRAM_write_data(WS_write_data),
	.SRAM_we_n(WS_we_n),
	.SRAM_address(WS_address)
);



logic [11:0] block_counter;

logic [6:0] col_block_count;
 

assign col_block_count = (sel	== 2'd0)? 6'd39 : 6'd19;
parameter row_block_count = 6'd29;
 
always_ff @(posedge clock or negedge resetn) begin
	if (!resetn) begin
		// Reset state variables
		FS_enable <= 1'd0;
		CT_enable <= 1'd0;
		CS_enable <= 1'd0;
		WS_enable <= 1'd0;


		col_block_top <= 6'd0;
		row_block_top <= 6'd0;
		block_counter <= 12'd0;
		state = IDLE;
		
		
	end else begin
		case (state)
            IDLE: begin
					finish <= 1'd0;
					if(start) begin
						 state = FETCH_ONLY;
					end
            end
            FETCH_ONLY: begin
               FS_enable <= 1'b1;	
					if (FS_done) begin
						col_block_top <= col_block_top + 6'd1;
						FS_enable <= 1'b0;    
						state <= COMPUTE_T; 
					end	
            end
            COMPUTE_T: begin
					CT_enable <= 1'b1;
					
					if (CT_done) begin
						CT_enable <= 1'b0;    
						state <= MEGA_STATE_A; 
					end	
            end
            MEGA_STATE_A: begin
					CS_enable <= 1'b1;
					FS_enable <= 1'b1;
						
					if(col_block_top == col_block_count) begin
						 col_block_top <= 0;
						 row_block_top <= row_block_top + 6'd1;
						 if(row_block_top == row_block_count) begin
							  row_block_top <= 0;
							  if(!sel) begin
									sel <= 1'b1;
							  end

						 end
					end
		
					
					if((CS_done) && (FS_done)) begin
						CS_enable <= 1'b0;
						col_block_top <= col_block_top + 6'd1;
						FS_enable <= 1'b0;
						state = MEGA_STATE_B;
					end
            end
            MEGA_STATE_B: begin
               
               WS_enable <= 1'b1;
					CT_enable <= 1'b1;
					
					if (WS_done) begin
						WS_enable <= 1'b0;
					end
					
					if (CT_done) begin
						CT_enable <= 1'b0;
					end
					
					if(((WS_done) && (CT_done)) && (block_counter < 12'd2399)) begin
						block_counter <= block_counter + 12'd1;
						state = MEGA_STATE_A;
					end else begin
						state = COMPUTE_S;
					end
					
            end
				
				COMPUTE_S: begin
               CS_enable <= 1'b1;

					if (CS_done) begin
						
						CS_enable <= 1'b0;    
						state <= WRITE_S; 
					end	
            end
            WRITE_S: begin
					WS_enable <= 1'b1;
					if (WS_done) begin
						WS_enable <= 1'b0; 
						finish <= 1'b1;
						state <= IDLE; 
					end	
            end
            default: state <= IDLE;	
           
        endcase
    end
end


always_comb begin
	SRAM_address = 18'd0;
	SRAM_we_n = 1'b1;
	SRAM_write_data = 16'd0;
	if (state == FETCH_ONLY || state == MEGA_STATE_A) begin
		SRAM_address = FS_address;
		SRAM_we_n = FS_we_n;
		SRAM_write_data = FS_write_data;
	end 
	
	if (state == WRITE_S || state == MEGA_STATE_B) begin
		SRAM_address = WS_address;
		SRAM_we_n = WS_we_n;
		SRAM_write_data = WS_write_data;
	end

end


endmodule
