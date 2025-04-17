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
module Milestone_1 (
		/////// board clocks ////////////
		input logic clock,
		input logic resetn,
		input logic start,
		output logic done,
		input logic  [15:0] SRAM_read_data,
		output logic [15:0] SRAM_write_data,
		output logic SRAM_we_n,
		output logic [17:0] SRAM_address 
);


M1_state_type state;


logic [31:0] Re, Ge, Be;
logic [31:0] Ro, Go, Bo;

logic [7:0] Re_clip, Ge_clip, Be_clip;
logic [7:0] Ro_clip, Go_clip, Bo_clip;

logic [31:0] Go_buff, Bo_buff;

logic [31:0] y_odd;

logic [7:0] u_5[1:0]; //U[(J-5)/2] = 1, U[(J+5)/2]= 0
logic [7:0] u_3[1:0]; //U[(J-3)/2] = 1, U[(J+3)/2]= 0
logic [7:0] u_1[1:0];
logic [7:0] v_5[1:0];
logic [7:0] v_3[1:0];
logic [7:0] v_1[1:0];
	

logic [17:0] data_counter, write_counter, row_counter;

logic [17:0] y_counter, u_counter, v_counter;

logic [15:0] y_reg;
logic [15:0] u_reg;
logic [15:0] v_reg;

logic [31:0] m1_buff, m3_buff;
logic [31:0] a2_buff, a3_buff;


logic [31:0] m2op1, m2op2, mult2;
logic [63:0] mult2_long;

logic [31:0] m1op1, m1op2, mult1;
logic [63:0] mult1_long;

logic [31:0] m3op1, m3op2, mult3;
logic [63:0] mult3_long;

logic [31:0] add1, add2, add3, add4, add5;




parameter y_address = 18'd0;
parameter u_address = 18'd38400;
parameter v_address = 18'd57600;
parameter rgb_address = 18'd146944;





always_ff @ (posedge clock or negedge resetn) begin
	if (resetn == 1'b0) begin
		state <= S_M1_IDLE;		
		SRAM_we_n <= 1'b1;
		SRAM_write_data <= 16'd0;
		SRAM_address <= 18'd0;
		Re <= 32'b0;														
		Ge <= 32'b0;
		Be <= 32'b0;
		Ro <= 32'b0;
		Go <= 32'b0;
		Bo <= 32'b0;
		
		Go_buff <= 32'b0;
		Bo_buff <= 32'b0;
		
		y_odd <= 32'b0;

		u_5[0] <= 8'b0;
		u_5[1] <= 8'b0;
		u_3[0] <= 8'b0;
		u_3[1] <= 8'b0;
		u_1[0] <= 8'b0;
		u_1[1] <= 8'b0;
		v_5[0] <= 8'b0;
		v_5[1] <= 8'b0;
		v_3[0] <= 8'b0;
		v_3[1] <= 8'b0;
		v_1[0] <= 8'b0;
		v_1[1] <= 8'b0;
		
		m1op1 <= 32'b0;
		m1op2 <= 32'b0;
		m2op1 <= 32'b0;
		m2op2 <= 32'b0;
		m3op1 <= 32'b0;
		m3op2 <= 32'b0;
		
		m1_buff <= 32'b0;
		m3_buff <= 32'b0;
		
		a2_buff <= 32'b0;
		a3_buff <= 32'b0;
		row_counter <= 18'd0;

		add1 <= 32'b0;
		add2 <= 32'b0;
		add3 <= 32'b0;
		add4 <= 32'b0;
		add5 <= 32'b0;
		
		data_counter <= 18'b0;
		y_counter <= 18'b0;
		u_counter <= 18'b0;
		v_counter <= 18'b0;
		
		write_counter <= 18'b0;
		y_reg <= 16'b0;
		u_reg <= 16'b0;
		v_reg <= 16'b0;

	end else begin
		case (state)
			S_M1_IDLE: begin
				done <= 1'd0;
				if (start) begin					
					state <= S_LI_0;		
					SRAM_we_n <= 1'b1;
					SRAM_write_data <= 16'd0;
					SRAM_address <= 18'd0;
					Re <= 32'b0;														
					Ge <= 32'b0;
					Be <= 32'b0;
					Ro <= 32'b0;
					Go <= 32'b0;
					Bo <= 32'b0;
					
					Go_buff <= 32'b0;
					Bo_buff <= 32'b0;
					
					y_odd <= 32'b0;

					u_5[0] <= 8'b0;
					u_5[1] <= 8'b0;
					u_3[0] <= 8'b0;
					u_3[1] <= 8'b0;
					u_1[0] <= 8'b0;
					u_1[1] <= 8'b0;
					v_5[0] <= 8'b0;
					v_5[1] <= 8'b0;
					v_3[0] <= 8'b0;
					v_3[1] <= 8'b0;
					v_1[0] <= 8'b0;
					v_1[1] <= 8'b0;
					
					m1op1 <= 32'b0;
					m1op2 <= 32'b0;
					m2op1 <= 32'b0;
					m2op2 <= 32'b0;
					m3op1 <= 32'b0;
					m3op2 <= 32'b0;

					m1_buff <= 32'b0;
					m3_buff <= 32'b0;
					
					a2_buff <= 32'b0;
					a3_buff <= 32'b0;
					
					add1 <= 32'b0;
					add2 <= 32'b0;
					add3 <= 32'b0;
					add4 <= 32'b0;
					add5 <= 32'b0;
					
					data_counter <= 18'b0;
					y_counter <= 18'b0;
					u_counter <= 18'b0;
					v_counter <= 18'b0;
					
					row_counter <= 18'd0;
					write_counter <= 18'b0;
					y_reg <= 16'b0;
					u_reg <= 16'b0;
					v_reg <= 16'b0;

					
				end
			end
			
			S_LI_0: begin
				SRAM_we_n <= 1'b1;
				
				SRAM_address <= y_address + data_counter + row_counter;
				y_counter <= y_counter + 18'd1;
				
				state <= S_LI_1;
			end
			
			S_LI_1: begin
				SRAM_we_n <= 1'b1;
				
				SRAM_address <= v_address + data_counter + (row_counter>>1);
				v_counter <= v_counter + 18'd1;

				state <= S_LI_2;
			end
			
			S_LI_2 : begin
				data_counter <= data_counter + 18'd1;
				SRAM_we_n <= 1'b1;
				SRAM_address <= u_address + data_counter + (row_counter>>1);
				v_counter <= v_counter + 18'd1;

				state <= S_LI_3;
			end	
			
			S_LI_3 : begin
				SRAM_we_n <= 1'b1;
				y_reg <= SRAM_read_data;
				
				SRAM_address <= v_address + data_counter + (row_counter>>1);
				u_counter <= u_counter + 18'd1;

				state <= S_LI_4;
			end
			
			S_LI_4 : begin
				SRAM_we_n <= 1'b1;
				
				v_reg <= SRAM_read_data;
				SRAM_address <= u_address + data_counter + (row_counter>>1);
				u_counter <= u_counter + 18'd1;
							
				v_5[1] <= SRAM_read_data[15:8];
				v_3[1] <= SRAM_read_data[15:8];
				v_1[1] <= SRAM_read_data[15:8];
				v_1[0] <= SRAM_read_data[7:0];

				state <= S_LI_5;	
			end
		
			S_LI_5 : begin
				SRAM_we_n <= 1'b1;
				
				u_reg <= SRAM_read_data;
				u_5[1] <= SRAM_read_data[15:8];
				u_3[1] <= SRAM_read_data[15:8];
				u_1[1] <= SRAM_read_data[15:8];
				u_1[0] <= SRAM_read_data[7:0];
				
				state <= S_LI_6;

			end	
			S_LI_6 : begin
				SRAM_we_n <= 1'b1;
				
				v_5[0] <= SRAM_read_data[7:0];
				v_3[0] <= SRAM_read_data[15:8];	
			
				state <= S_LI_7;
			end
			
			S_LI_7 : begin
				SRAM_we_n <= 1'b1;
				
				u_5[0] <= SRAM_read_data[7:0];
				u_3[0] <= SRAM_read_data[15:8];
				
								
				add2 <= y_reg[15:8] - 8'd16; //ye
				add3 <= y_reg[7:0] - 8'd16;  //yo
								
				state <= S_LI_8;
			end
			
			S_LI_8 : begin //0
			
				SRAM_we_n <= 1'b1;
				
				SRAM_address <= y_address + data_counter + row_counter;
				y_counter <= y_counter + 18'd1;

				//mult
				m3op1 <= add2;
				m3op2 <= 18'd76284;
				
				//add
				
				add2 <= u_1[1] - 8'd128;
				
				add4 <= v_5[1] + v_5[0];
				add5 <= v_3[1] + v_3[0];
				
				y_odd <= add3;

				
				state <= S_LI_9;
			end
			
			S_LI_9: begin
				SRAM_we_n <= 1'b1;
				
				SRAM_address <= v_address + ((data_counter + row_counter + 3'd3) >>1);
				
				v_counter <= v_counter + 18'd1;
				
				//mult
				m1op1 <= add4;
				m1op2 <= 8'd21;
				
				m2op1 <= add5;
				m2op2 <= 8'd52;
				
				m3op1 <= add2;
				m3op2 <= 32'd25624;
				
				
				//add
				add2 <= v_1[1] - 8'd128;
				add4 <= v_1[1] + v_1[0];
				add5 <= u_5[1] + u_5[0];
				
				a3_buff <= {24'd0,add2};
				
				m1_buff <= mult3;
				
				state <= S_LI_10;
			end
			
			S_LI_10: begin
				SRAM_we_n <= 1'b1;
				
				SRAM_address <= u_address + ((data_counter + row_counter + 3'd3) >>1);
				
				u_counter <= u_counter + 18'd1;
				
				//mult
				m1op1 <= add4;
				m1op2 <= 18'd159;
				
				m2op1 <= add5;
				m2op2 <= 18'd21;
				
				m3op1 <= add2;
				m3op2 <= 18'd104595;
				
				
				//add
				add1 <= m1_buff - mult3;
				add2 <= mult1 - mult2;
				add4 <= u_3[1] + u_3[0];
				add5 <= u_1[1] + u_1[0];
				
				a2_buff <= add2;
				
				m3_buff <= mult3;
				
				state <= S_LI_11;
			end
			
			S_LI_11: begin
				y_reg <= SRAM_read_data;
				
				SRAM_we_n <= 1'b1;
				
				//mult
				m1op1 <= add4;
				m1op2 <= 18'd52;
				
				m2op1 <= add5;
				m2op2 <= 18'd159;
				
				m3op1 <= a2_buff;
				m3op2 <= 18'd53281;
				
				//add
				add1 <= m1_buff - m3_buff;
				add2 <= mult2 + 18'd128;
				add4 <= $signed(add2 + mult1 + 18'd128) >> 8;
				
				m3_buff <= mult3;
		
				
				state <= S_LI_12;
			end
			
			S_LI_12: begin

				SRAM_we_n <= 1'b1;	
				
				v_reg <= SRAM_read_data;
				
				//mult
				m3op1 <= a3_buff;
				m3op2 <= 18'd132251;
				
				//add												
				add1 <= add4 - 18'd128;
				add2 <= $signed(m1_buff + m3_buff);
				add3 <= $signed(add1 - mult3);
				add4 <= $signed(add2 - mult1 + mult2) >> 8;
				
				state <= S_LI_13;
			end
			
			S_LI_13: begin
				SRAM_we_n <= 1'b1;
				
				u_reg <= SRAM_read_data;
				
				//mult
				m1op1 <= y_odd;
				m1op2 <= 18'd76284;
				
				m2op1 <= add1;
				m2op2 <= 18'd104595;
				
				m3op1 <= add1;
				m3op2 <= 18'd53281;
				
				//add
				add1 <= add4 - 18'd128;
				add5 <= $signed(m1_buff + mult3);	
	
				Re <= add2;
				Ge <= add3;
				
				state <= S_LI_14;
			end
			
			S_LI_14: begin
				
				SRAM_we_n <= 1'b0;
				SRAM_address <= rgb_address + write_counter;
				write_counter <= write_counter + 1'd1;
				SRAM_write_data <= {Re_clip, Ge_clip};

				//mult
				m1op1 <= add1;
				m1op2 <= 18'd25624;
				
				m2op1 <= add1;
				m2op2 <= 18'd132251;
				
				
				//add
				add1 <= $signed(mult1 + mult2);
				add2 <= y_reg[15:8] - 16'd16; //ye
				add3 <= y_reg[7:0] - 16'd16;  //yo
				
				m1_buff <= mult1;
				m3_buff <= mult3;
				
				v_5[0] <= v_reg[15:8];
				v_5[1] <= v_3[1];
				v_3[1] <= v_1[1];
				v_1[1] <= v_1[0];
				v_1[0] <= v_3[0];
				v_3[0] <= v_5[0];
				
				u_5[0] <= u_reg[15:8];					
				u_5[1] <= u_3[1];
				u_3[1] <= u_1[1];
				u_1[1] <= u_1[0];
				u_1[0] <= u_3[0];
				u_3[0] <= u_5[0];	
				
				
				data_counter <= data_counter + 1'd1;
				state <= S_CC_0;
			end
	
			
			S_CC_0: begin
				SRAM_we_n <= 1'b1;
				SRAM_address <= y_address + data_counter + row_counter;
				y_counter <= y_counter + 18'd1;
				
				//mult
				m3op1 <= add2;
				m3op2 <= 18'd76284;
				
				//add
				add1 <= $signed(m1_buff - mult1 - m3_buff) ;
				add2 <= u_1[1] - 18'd128;
				add3 <= $signed(m1_buff + mult2);
				add4 <= v_5[1] + v_5[0];
				add5 <= v_3[1] + v_3[0];
				
				y_odd <= add3;
				
				Ro <= add1;
				Be <= add5;
				
				state <= S_CC_1;
			end
			
			S_CC_1: begin
				SRAM_we_n <= 1'b1;
				
				//mult
				m1op1 <= add4;
				m1op2 <= 8'd21;
				
				m2op1 <= add5;
				m2op2 <= 8'd52;
				
				m3op1 <= add2;
				m3op2 <= 32'd25624;
				
				//add
				add2 <= v_1[1] - 8'd128;
				add4 <= v_1[1] + v_1[0];
				add5 <= u_5[1] + u_5[0];
				
				a3_buff <= {24'd0,add2};
				
				Go_buff <= add1;
				Bo_buff <= add3;
				
				m1_buff <= mult3;
				
				state <= S_CC_2;
			end
			
			S_CC_2: begin
				SRAM_we_n <= 1'b1;
				
				//mult
				m1op1 <= add4;
				m1op2 <= 18'd159;
				
				m2op1 <= add5;
				m2op2 <= 18'd21;
				
				m3op1 <= add2;
				m3op2 <= 18'd104595;
				
				//add
				add1 <= m1_buff - mult3;
				add2 <= mult1 - mult2;
				add4 <= u_3[1] + u_3[0];
				add5 <= u_1[1] + u_1	[0];
				
				a2_buff <= {24'd0,add2};
				
				m3_buff <= mult3;
				
				state <= S_CC_3;
			end
			
			S_CC_3: begin
		
				SRAM_we_n <= 1'b0;
				y_reg <= SRAM_read_data;
				SRAM_address <= rgb_address + write_counter;
				write_counter <= write_counter + 1'd1;
				SRAM_write_data <= {Be_clip, Ro_clip};
				
				Go <= Go_buff;
				Bo <= Bo_buff;			
			
				//mult
				m1op1 <= add4;
				m1op2 <= 18'd52;
				
				m2op1 <= add5;
				m2op2 <= 18'd159;
				
				m3op1 <= a2_buff;
				m3op2 <= 18'd53281;
				
				//add
				add1 <= m1_buff - m3_buff;
				add2 <= mult2 + 18'd128;
				add4 <= $signed(add2 + mult1 + 18'd128) >> 8;
				
				m3_buff <= mult3;
				
				state <= S_CC_4;
			end
			
			S_CC_4: begin
				SRAM_we_n <= 1'b0;
				SRAM_address <= rgb_address + write_counter;
				write_counter <= write_counter + 1'd1;
				SRAM_write_data <= {Go_clip, Bo_clip};
								
				//mult
				m3op1 <= a3_buff;
				m3op2 <= 18'd132251;
				
				//add												
				add1 <= add4 - 18'd128;
				add2 <= $signed(m1_buff + m3_buff);
				add3 <= $signed(add1 - mult3);
				add4 <= $signed(add2 - mult1 + mult2) >> 8;
				
				state <= S_CC_5;
			end
			
			S_CC_5: begin
				SRAM_we_n <= 1'b1;
				
				//mult
				m1op1 <= y_odd;
				m1op2 <= 18'd76284;
				
				m2op1 <= add1;
				m2op2 <= 18'd104595;
				
				m3op1 <= add1;
				m3op2 <= 18'd53281;
				
				//add
				add1 <= add4 - 18'd128;
				add5 <= $signed(m1_buff + mult3) ;	
	
				Re <= add2;
				Ge <= add3;
				
				state <= S_CC_6;
			end
			
			S_CC_6: begin
				SRAM_we_n <= 1'b0;
				// write (Re, Ge)
				SRAM_address <= rgb_address + write_counter;
				write_counter <= write_counter + 1'd1;
				SRAM_write_data <= {Re_clip, Ge_clip};

				//mult
				m1op1 <= add1;
				m1op2 <= 18'd25624;
				
				m2op1 <= add1;
				m2op2 <= 18'd132251;
				
				//add
				add1 <= $signed(mult1 + mult2);
				add2 <= y_reg[15:8] - 16'd16; //ye
				add3 <= y_reg[7:0] - 16'd16;  //yo
				
				m1_buff <= mult1;
				m3_buff <= mult3;
				
				
				if (data_counter< 9'd157) begin
					v_5[0] <= v_reg[7:0];
					u_5[0] <= u_reg[7:0];
				
				end

				//shift register
				v_5[1] <= v_3[1];
				v_3[1] <= v_1[1];
				v_1[1] <= v_1[0];
				v_1[0] <= v_3[0];
				v_3[0] <= v_5[0];
				
									
				u_5[1] <= u_3[1];
				u_3[1] <= u_1[1];
				u_1[1] <= u_1[0];
				u_1[0] <= u_3[0];
				u_3[0] <= u_5[0];	
				
				data_counter <= data_counter + 1'd1;
				state <= S_CC_7;				
			end
			
			S_CC_7: begin //0
				SRAM_we_n <= 1'b1;
				SRAM_address <= y_address + y_counter;
				y_counter <= y_counter + 18'd1;
				
				//mult
				m3op1 <= add2;
				m3op2 <= 18'd76284;
				
				//add
				add1 <= $signed(m1_buff - mult1 - m3_buff);
				add2 <= u_1[1] - 8'd128;
				add3 <= $signed(m1_buff + mult2);
				add4 <= v_5[1] + v_5[0];
				add5 <= v_3[1] + v_3[0];
				
				y_odd <= add3;
				
				Ro <= add1;
				Be <= add5;
				
				state <= S_CC_8;
				
			end
			
			S_CC_8: begin
				SRAM_we_n <= 1'b1;
				v_counter <= v_counter + 18'd1;
				
				SRAM_address <= v_address + ((data_counter + row_counter + 3'd3) >>1);
				
				//mult
				m1op1 <= add4;
				m1op2 <= 8'd21;
				
				m2op1 <= add5;
				m2op2 <= 8'd52;
				
				m3op1 <= add2;
				m3op2 <= 32'd25624;
				
				//add
				add2 <= v_1[1] - 8'd128;
				add4 <= v_1[1] + v_1[0];
				add5 <= u_5[1] + u_5[0];
				
				a3_buff <= {24'd0,add2};

				
				Go_buff <= add1;
				Bo_buff <= add3;
				
				m1_buff <= mult3;
				
				state <= S_CC_9;
			end
			
			S_CC_9: begin
				SRAM_we_n <= 1'b1;
				SRAM_address <= u_address + ((data_counter + row_counter + 3'd3) >>1);
				u_counter <= u_counter + 18'd1;
				
				//mult
				m1op1 <= add4;
				m1op2 <= 18'd159;
				
				m2op1 <= add5;
				m2op2 <= 18'd21;
				
				m3op1 <= add2;
				m3op2 <= 18'd104595;
				
				//add
				add1 <= m1_buff - mult3;
				add2 <= mult1 - mult2;
				add4 <= u_3[1] + u_3[0];
				add5 <= u_1[1] + u_1[0];
				
				a2_buff <= {24'd0,add2};
				
				m3_buff <= mult3;
				
				state <= S_CC_10;
				
			end
			
			S_CC_10: begin
				// Y
				y_reg <= SRAM_read_data;
				
				SRAM_we_n <= 1'b0;
				SRAM_address <= rgb_address + write_counter;
				write_counter <= write_counter + 18'd1;
				SRAM_write_data <= {Be_clip, Ro_clip};
				
				Go <= Go_buff;
				Bo <= Bo_buff;			

				//mult
				m1op1 <= add4;
				m1op2 <= 18'd52;
				
				m2op1 <= add5;
				m2op2 <= 18'd159;
				
				m3op1 <= a2_buff;
				m3op2 <= 18'd53281;
				
				//add
				add1 <= m1_buff - m3_buff;
				add2 <= mult2 + 18'd128;
				add4 <= $signed(add2 + mult1 + 18'd128) >> 8;
				
				m3_buff <= mult3;
				
				state <= S_CC_11;
			end
			
			S_CC_11: begin
				SRAM_we_n <= 1'b0;
				SRAM_address <= rgb_address + write_counter;
				write_counter <= write_counter + 18'd1;
				SRAM_write_data <= {Go_clip, Bo_clip};
				
				if (data_counter< 9'd157) begin
					v_reg <= SRAM_read_data;
				end
								
				//mult
				m3op1 <= a3_buff;
				m3op2 <= 18'd132251;
				
				//add												
				add1 <= add4 - 18'd128;
				add2 <= $signed(m1_buff + m3_buff);
				add3 <= $signed(add1 - mult3) ;
				add4 <= $signed(add2 - mult1 + mult2) >> 8;
				state <= S_CC_12;
				
			end
			
			S_CC_12: begin
				SRAM_we_n <= 1'b1;
				
				if (data_counter< 9'd157) begin
					u_reg <= SRAM_read_data;
				end
				
				//mult
				m1op1 <= y_odd;
				m1op2 <= 18'd76284;
				
				m2op1 <= add1;
				m2op2 <= 18'd104595;
				
				m3op1 <= add1;
				m3op2 <= 18'd53281;
				
				//add
				add1 <= add4 - 18'd128;
				add5 <= $signed(m1_buff + mult3);	
	
				Re <= add2;
				Ge <= add3;
				
				state <= S_CC_13;
			end
			
			S_CC_13: begin
				SRAM_we_n <= 1'b0;
				SRAM_address <= rgb_address + write_counter;
				write_counter <= write_counter + 1'd1;
				SRAM_write_data <= {Re_clip, Ge_clip};

				//mult
				m1op1 <= add1;
				m1op2 <= 18'd25624;
				
				m2op1 <= add1;
				m2op2 <= 18'd132251;
				
				//add
				add1 <= $signed(mult1 + mult2);
				add2 <= y_reg[15:8] - 16'd16; //ye
				add3 <= y_reg[7:0] - 16'd16;  //yo
				
				m1_buff <= mult1;
				m3_buff <= mult3;
				
				if (data_counter< 9'd157) begin
					v_5[0] <= v_reg[15:8];
					u_5[0] <= u_reg[15:8];	
				
				end
				
				v_5[1] <= v_3[1];
				v_3[1] <= v_1[1];
				v_1[1] <= v_1[0];
				v_1[0] <= v_3[0];
				v_3[0] <= v_5[0];
				
								
				u_5[1] <= u_3[1];
				u_3[1] <= u_1[1];
				u_1[1] <= u_1[0];
				u_1[0] <= u_3[0];
				u_3[0] <= u_5[0];	
				
				data_counter <= data_counter + 1'd1;
				
				if(data_counter > 18'd158) begin
					state <= S_LO_0;
				end else begin
					state <= S_CC_0;
				end	
				
				
			end
			
			S_LO_0: begin
				SRAM_we_n <= 1'b1;
				
   			//mult
				m3op1 <= add2;
				m3op2 <= 18'd76284;		
				
				//add
				add1 <= $signed(m1_buff - mult1 - m3_buff);
				add2 <= u_1[1] - 8'd128;
				add3 <= $signed(m1_buff + mult2);
				add4 <= v_5[1] + v_5[0];
				add5 <= v_3[1] + v_3[0];
				
				y_odd <= add3;
				
				Ro <= add1;
				Be <= add5;
				
				state <= S_LO_1;
			end

			S_LO_1: begin
    			SRAM_we_n <= 1'b1;
				//mult
				m1op1 <= add4;
				m1op2 <= 8'd21;
				
				m2op1 <= add5;
				m2op2 <= 8'd52;
				
				m3op1 <= add2;
				m3op2 <= 32'd25624;
				
				//add
				add2 <= v_1[1] - 8'd128;
				add4 <= v_1[1] + v_1[0];
				add5 <= u_5[1] + u_5[0];
				
				a3_buff <= {24'd0,add2};

				
				Go_buff <= add1;
				Bo_buff <= add3;
				
				m1_buff <= mult3;
				
				state <= S_LO_2;
			end

			S_LO_2: begin
				SRAM_we_n <= 1'b1;
  			  	//mult
				m1op1 <= add4;
				m1op2 <= 18'd159;
				
				m2op1 <= add5;
				m2op2 <= 18'd21;
				
				m3op1 <= add2;
				m3op2 <= 18'd104595;
				
				//add
				add1 <= m1_buff - mult3;
				add2 <= mult1 - mult2;
				add4 <= u_3[1] + u_3[0];
				add5 <= u_1[1] + u_1[0];
				
				a2_buff <= {24'd0,add2};
				
				m3_buff <= mult3;
				
				state <= S_LO_3;
			end

			S_LO_3: begin
				SRAM_we_n <= 1'b0;
    			SRAM_address <= rgb_address + write_counter;
				write_counter <= write_counter + 1'd1;
				SRAM_write_data <= {{Be_clip}, {Ro_clip}};
				
				Go <= Go_buff;
				Bo <= Bo_buff;			
				
				//mult
				m1op1 <= add4;
				m1op2 <= 18'd52;
				
				m2op1 <= add5;
				m2op2 <= 18'd159;
				
				m3op1 <= a2_buff;
				m3op2 <= 18'd53281;
				
				//add
				add1 <= m1_buff - m3_buff;
				add2 <= mult2 + 18'd128;
				add4 <= $signed(add2 + mult1 + 18'd128) >> 8;
				
				m3_buff <= mult3;
				
				state <= S_LO_4;
			end

			S_LO_4: begin
				SRAM_we_n <= 1'b0;
    			SRAM_address <= rgb_address + write_counter;
				write_counter <= write_counter + 1'd1;
				SRAM_write_data <= {{Go_clip}, {Bo_clip}};
				
				//mult
				m3op1 <= a3_buff;
				m3op2 <= 18'd132251;
				
				//add
				add1 <= add4 - 18'd128;
				add2 <= $signed(m1_buff + m3_buff) ;
				add3 <= $signed(add1 - mult3) ;
				add4 <= $signed(add2 - mult1 + mult2) >> 8;
				
				state <= S_LO_5;
			end

			S_LO_5: begin
				SRAM_we_n <= 1'b1;
				
				//mult
				m1op1 <= y_odd;
				m1op2 <= 18'd76284;
				
				m2op1 <= add1;
				m2op2 <= 18'd104595;
				
				m3op1 <= add1;
				m3op2 <= 18'd53281;
				
				//add
				add1 <= add4 - 18'd128;
				add5 <= $signed(m1_buff + mult3) ;	
				
				Re <= add2;
				Ge <= add3;
				
				state <= S_LO_6;
			end

			S_LO_6: begin
				SRAM_we_n <= 1'b0;
    				// write (Re, Ge)
				SRAM_address <= rgb_address + write_counter;
				write_counter <= write_counter + 1;
				SRAM_write_data <= {{Re_clip}, {Ge_clip}};

				//mult
				m1op1 <= add1;
				m1op2 <= 18'd25624;
				
				m2op1 <= add1;
				m2op2 <= 18'd132251;
				
				//add
				add1 <= (mult1 + mult2);
				
				m1_buff <= mult1;
				m3_buff <= mult3;
				
				state <= S_LO_7;
				
			end
			
			S_LO_7: begin
				SRAM_we_n <= 1'b1;
				
				add1 <= $signed(m1_buff - mult1 - m3_buff);
				add3 <= $signed(m1_buff + mult2);
				
				Ro <= add1;
				Be <= add5;
				
				state <= S_LO_8;
			end
			
			S_LO_8: begin
				SRAM_we_n <= 1'b0;
				
				// write (Ro, Be)
				SRAM_address <= rgb_address + write_counter;
				write_counter <= write_counter + 1;
				SRAM_write_data <= {{Be_clip}, {Ro_clip}};
				
				Go <= add1;
				Bo <= add3;
  
				state <= S_LO_9;
			end
			
			
			S_LO_9: begin
				SRAM_we_n <= 1'b0;
			
				// write (Go, Bo)
				SRAM_address <= rgb_address + write_counter;
				write_counter <= write_counter + 1;
				SRAM_write_data <= {{Go_clip}, {Bo_clip}};
				data_counter <= 18'd0;
				
				
				if(row_counter + data_counter == 18'd38400) begin
					done <= 1'b1;
					state <= S_M1_IDLE;
				end else begin
					data_counter <= 18'd0;
					row_counter <= row_counter + 18'd160;
					state <= S_LI_0;
				end
			end

			default: state <= S_M1_IDLE;			
			
		endcase
	end
end



always_comb begin
	if (Re[31] == 1'b1) Re_clip = 8'd0;
	else if (|Re[30:24] ==1'b1) Re_clip = 8'd255;
	else Re_clip = Re[23:16];
end

always_comb begin
	if (Ge[31] == 1'b1) Ge_clip = 8'd0;
	else if (|Ge[30:24] ==1'b1) Ge_clip = 8'd255;
	else Ge_clip = Ge[23:16];
end

always_comb begin
	if (Be[31] == 1'b1) Be_clip = 8'd0;
	else if (|Be[30:24] ==1'b1) Be_clip = 8'd255;
	else Be_clip = Be[23:16];
end

always_comb begin
	if (Ro[31] == 1'b1) Ro_clip = 8'd0;
	else if (|Ro[30:24] ==1'b1) Ro_clip = 8'd255;
	else Ro_clip = Ro[23:16];
end

always_comb begin
	if (Go[31] == 1'b1) Go_clip = 8'd0;
	else if (|Go[30:24] ==1'b1) Go_clip = 8'd255;
	else Go_clip = Go[23:16];
end

always_comb begin
	if (Bo[31] == 1'b1) Bo_clip = 8'd0;
	else if (|Bo[30:24] ==1'b1) Bo_clip = 8'd255;
	else Bo_clip = Bo[23:16];
end


assign mult1_long = m1op1 * m1op2;
assign mult2_long = m2op1 * m2op2;
assign mult3_long = m3op1 * m3op2;

assign mult1 = mult1_long[31:0];
assign mult2 = mult2_long[31:0];
assign mult3 = mult3_long[31:0];


endmodule