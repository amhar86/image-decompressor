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
module computeS (
		input logic clock,
		input logic resetn,
		input logic compute_s_start,
		output logic compute_s_finish
);

computeS_state_type state;

logic [31:0] m2op1, m2op2, mult2;
logic [63:0] mult2_long;

logic [31:0] C1, C2, C3;

logic [4:0] m1_c;
logic [4:0] m2_c;
logic [4:0] m3_c;

logic [31:0] m1op1, m1op2, mult1;
logic [63:0] mult1_long;

logic [31:0] m3op1, m3op2, mult3;
logic [63:0] mult3_long;

logic [31:0] add1, add2, add3, add4, add5;

logic [2:0] cc_counter;

logic [4:0] col_counter;

assign mult1_long = m1op1 * C1;
assign mult2_long = m2op1 * C2;
assign mult3_long = m3op1 * C3;

assign mult1 = mult1_long[31:0];
assign mult2 = mult2_long[31:0];
assign mult3 = mult3_long[31:0];

logic [6:0] address_2, address_3, address_4, address_5; 
logic [31:0] write_data_a[2:0];
logic [31:0] write_data_b[2:0];
logic write_enable_a[2:0];
logic write_enable_b[2:0];
logic [31:0] read_data_a[2:0];
logic [31:0] read_data_b[2:0];



// FETCHING T
dual_port_RAM1 dual_port_RAM_inst1 (
	.address_a (address_2),
	.address_b (address_3),//write_data!!!
	.clock (clock),
	.data_a (write_data_a[1]),
	.data_b (write_data_b[1]),
	.wren_a (write_enable_a[1]),
	.wren_b (write_enable_b[1]),
	.q_a (read_data_a[1]),
	.q_b (read_data_b[1])
	);	

//writing for S 
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


always_ff @(posedge clock or negedge resetn) begin
	if (!resetn) begin
		// Reset state variables
		write_enable_a[2] <= 1'b0;
		write_enable_b[2] <= 1'b0;

		address_4 <= 7'd0;
		address_5 <= 7'd0;
		address_2 <= 7'd0;
		address_3 <= 7'd0;
		
		compute_s_finish <= 1'd0;
		
		cc_counter <= 3'd0;
		col_counter <= 5'd0;
		
		add1 <= 32'b0;
		add2 <= 32'b0;
		add3 <= 32'b0;
		add4 <= 32'b0;
		add5 <= 32'b0;
		
		m1op1 <= 32'b0;
		m1op2 <= 32'b0;
		m2op1 <= 32'b0;
		m2op2 <= 32'b0;
		m3op1 <= 32'b0;
		m3op2 <= 32'b0;

		state <= Compute_S_IDLE;
	end else begin
		case (state)
			
			Compute_S_IDLE: begin
				
				if(compute_s_start) begin
					write_enable_a[2] <= 1'b0;
					write_enable_b[2] <= 1'b0;
					
					address_4 <= 7'd0;
					address_5 <= 7'd0;
					address_2 <= 7'd0;
					address_3 <= 7'd0;
					
					compute_s_finish <= 1'd0;
					
					cc_counter <= 3'd0;
					col_counter <= 5'd0;
					
					add1 <= 32'b0;
					add2 <= 32'b0;
					add3 <= 32'b0;
					add4 <= 32'b0;
					add5 <= 32'b0;
					
					m1op1 <= 32'b0;
					m1op2 <= 32'b0;
					m2op1 <= 32'b0;
					m2op2 <= 32'b0;
					m3op1 <= 32'b0;
					m3op2 <= 32'b0;
					state <= LI0_CS;
				end
			end
			LI0_CS: begin
				address_2 <= 4'd0 + col_counter;
				address_3 <= 4'd8 + col_counter;
				cc_counter <= 1'd0;
				state <= LI1_CS; 
				end
				
			LI1_CS: begin

				m1op1 <= read_data_a[1];
				m1_c <= 1'd0;
				
				m2op1 <= read_data_a[1];
				m2_c <= 1'd0;
				
				m3op1 <= read_data_b[1];
				m3_c <= 1'd0;
				
				state <= LI2_CS; 
			end 
			
			LI2_CS: begin
				address_2 <= address_2 + 4'd16;
				address_3 <= address_3 + 4'd16;
				
				m1op1 <= read_data_b[1];
				m1_c <= m1_c + 1'd1;
				
				m2op1 <= read_data_a[1];
				m2_c <= m2_c + 1'd1;
				
				m3op1 <= read_data_a[1];
				m3_c <= m3_c + 1'd1;
				
				add1 <= mult1 + mult3;
				add2 <= mult2;
				
				state <= LI3_CS; 
			end
			LI3_CS: begin
				
				m1op1 <= read_data_a[1];
				m1_c <= m1_c + 1'd1;
				
				m2op1 <= read_data_a[1];
				m2_c <= m2_c + 1'd1;
				
				m3op1 <= read_data_b[1];
				m3_c <= m3_c + 1'd1;
				
				add2 <= add2 + mult1;
				add3 <= mult2 + mult3;
				
				state <= LI4_CS; 
			end
			LI4_CS: begin
				address_2 <= address_2 + 4'd16;
				address_3 <= address_3 + 4'd16;
				
				
				m1op1 <= read_data_b[1];
				m1_c <= m1_c + 1'd1;
				
				m2op1 <= read_data_a[1];
				m2_c <= m2_c + 1'd1;
				
				m3op1 <= read_data_b[1];
				m3_c <= m3_c + 1'd1;
				
				add1 <= add1 + mult1 + mult3;
				add2 <= add2 + mult2;
				state <= LI5_CS; 
			end 
			LI5_CS: begin
				
				m1op1 <= read_data_a[1];
				m1_c <= m1_c + 1'd1;
				
				m2op1 <= read_data_a[1];
				m2_c <= m2_c + 1'd1;
				
				m3op1 <= read_data_b[1];
				m3_c <= m3_c + 1'd1;
				
				add2 <= add2 + mult1;
				add3 <= add3 + mult2 + mult3;
				state <= LI6_CS; 
			end
			LI6_CS: begin
				address_2 <= address_2 + 4'd16;
				address_3 <= address_3 + 4'd16;
				
				m1op1 <= read_data_b[1];
				m1_c <= m1_c + 1'd1;
				
				m2op1 <= read_data_a[1];
				m2_c <= m2_c + 1'd1;
				
				m3op1 <= read_data_b[1];
				m3_c <= m3_c + 1'd1;
				
				add1 <= add1 + mult1 + mult3;
				add2 <= add2 + mult2;
				state <= LI7_CS; 
			end
			LI7_CS: begin
				
				m1op1 <= read_data_a[1];
				m1_c <= m1_c + 1'd1;
				
				m2op1 <= read_data_a[1];
				m2_c <= m2_c + 1'd1;
				
				m3op1 <= read_data_b[1];
				m3_c <= m3_c + 1'd1;
				
				add2 <= add2 + mult1;
				add3 <= add3 + mult2 + mult3;
				state <= LI8_CS; 
			end
			LI8_CS: begin
				address_2 <= 7'd0;
				address_3 <= 7'd8;
				
				m1op1 <= read_data_b[1];
				m1_c <= m1_c + 1'd1;
				
				m2op1 <= read_data_a[1];
				m2_c <= m2_c + 1'd1;
				
				m3op1 <= read_data_b[1];
				m3_c <= m3_c + 1'd1;
				
				add1 <= add1 + mult1 + mult3;
				add2 <= add2 + mult2;
				state <= CC0_CS; 
			end
			
			CC0_CS: begin
				if(cc_counter == 1'd0) begin
					address_4 <= 1'd0 + col_counter;
					address_5 <= 4'd8 + col_counter;
				end
				
				m1op1 <= read_data_a[1];
				m1_c <= m1_c + 1'd1;
				
				m2op1 <= read_data_a[1];
				m2_c <= m2_c + 1'd1;
				
				m3op1 <= read_data_b[1];
				m3_c <= m3_c + 1'd1;
				
				add2 <= add2 + mult1;
				add3 <= add3 + mult2 + mult3;
				
				state <= CC1_CS; 
			end 
			CC1_CS: begin
				address_2 <= address_2 + 4'd16;
				address_3 <= address_3 + 4'd16;
				
				m1op1 <= read_data_b[1];
				m1_c <= m1_c + 1'd1;
				
				if(cc_counter == 1'd0) begin
					m2op1 <= read_data_a[1];
					m2_c <= m2_c + 1'd1;
					
					m3op1 <= read_data_b[1];
					m3_c <= m3_c + 1'd1;
				end
				
				add1 <= mult1 + mult3;
				add2 <= mult2;
				
				write_data_a[2] <= $signed(add1);
				write_enable_a[2] <= 1'b1;
				address_4 <= address_4 + 5'd16;
				
				
				write_data_b[2] <= $signed(add2);
				write_enable_b[2] <= 1'b1;
				address_5 <= address_5 + 5'd24;
				
				
				state <= CC2_CS; 
			end
			CC2_CS: begin
				
				m1op1 <= read_data_a[1];
				m1_c <= m1_c + 1'd1;
				
				m2op1 <= read_data_a[1];
				m2_c <= m2_c + 1'd1;
				
				m3op1 <= read_data_b[1];
				m3_c <= m3_c + 1'd1;
				
				add2 <= add2 + mult1;
				
				write_data_a[2] <= $signed(add3);
				write_enable_a[2] <= 1'b1;
				address_4 <= address_4 + 5'd16;
				
				if(cc_counter == 1'd0) begin
					add3 <= mult2 + mult3;
				end
				
				state <= CC3_CS; 
			end
			CC3_CS: begin
				address_2 <= address_2 + 4'd16;
				address_3 <= address_3 + 4'd16;
				
				m1op1 <= read_data_b[1];
				m1_c <= m1_c + 1'd1;
				
				if(cc_counter == 1'd0) begin
					m2op1 <= read_data_a[1];
					m2_c <= m2_c + 1'd1;
					
					m3op1 <= read_data_b[1];
					m3_c <= m3_c + 1'd1;
				end
				
				add1 <= add1 + mult1 + mult3;
				add2 <= add2 + mult2;
				state <= CC4_CS; 
			end 
			CC4_CS: begin
				
				m1op1 <= read_data_a[1];
				m1_c <= m1_c + 1'd1;
				
				m2op1 <= read_data_a[1];
				m2_c <= m2_c + 1'd1;
				
				m3op1 <= read_data_b[1];
				m3_c <= m3_c + 1'd1;
				
				add2 <= add2 + mult1;
				
				if(cc_counter == 1'd0) begin
					add3 <= add3 + mult2 + mult3;
				end
				state <= CC5_CS; 
			end
			CC5_CS: begin
				address_2 <= address_2 + 4'd16;
				address_3 <= address_3 + 4'd16;
				
				m1op1 <= read_data_b[1];
				m1_c <= m1_c + 1'd1;
				
				if(cc_counter == 1'd0) begin
					m2op1 <= read_data_a[1];
					m2_c <= m2_c + 1'd1;
					
					m3op1 <= read_data_b[1];
					m3_c <= m3_c + 1'd1;
				end
				
				add1 <= add1 + mult1 + mult3;
				add2 <= add2 + mult2;
				state <= CC6_CS; 
			end
			CC6_CS: begin
				
				m1op1 <= read_data_a[1];
				m1_c <= m1_c + 1'd1;
				
				m2op1 <= read_data_a[1];
				m2_c <= m2_c + 1'd1;
				
				m3op1 <= read_data_b[1];
				m3_c <= m3_c + 1'd1;
				
				add2 <= add2 + mult1;
				
				if(cc_counter == 1'd0) begin
					add3 <= add3 + mult2 + mult3;
				end
			
				state <= CC7_CS;
			end
			CC7_CS: begin
				if(cc_counter == 1'd0) begin
					address_4 <= 1'd0 + col_counter;
					address_5 <= 4'd8 + col_counter;
				end
				
				m1op1 <= read_data_b[1];
				m1_c <= m1_c + 1'd1;
				
				if(cc_counter == 1'd0) begin
					m2op1 <= read_data_a[1];
					m2_c <= m2_c + 1'd1;
					
					m3op1 <= read_data_b[1];
					m3_c <= m3_c + 1'd1;
				end
				
				add1 <= add1 + mult1 + mult3;
				add2 <= add2 + mult2;
				
				cc_counter <= cc_counter + 1'd1;
				
				if(cc_counter == 1'd1) begin
					state <= LO0_CS; 
				end else begin
					state <= CC0_CS; 
				end
			end
			
			LO0_CS: begin
				
				add2 <= add2 + mult1;
				
				state <= LO1_CS;
				
			end
			
			LO1_CS: begin
				write_data_a[2] <= $signed(add1);
				write_enable_a[2] <= 1'b1;

				write_data_b[2] <= $signed(add2);
				write_enable_b[2] <= 1'b1;
				
				col_counter <= col_counter + 5'd1;
				
				if(col_counter == 5'd7) begin
					compute_s_finish <= 1'd1;
					state <= Compute_S_IDLE;
				end else begin
					state <= LI0_CS;
				end	
				
			end

			default: state <= Compute_S_IDLE;
       endcase
    end
end
		

//C Matrix for C indices used in m1
always_comb begin
	case(m1_c)
	0:  C1 = 32'sd1448;   //C00
	1:  C1 = 32'sd1702;   //C11
	2:  C1 = 32'sd1892;   //C20
	3:  C1 = -32'sd399;   //C31
	4:  C1 = 32'sd1448;   //C40
	5:  C1 = -32'sd2008;  //C51
	6:  C1 = 32'sd783;    //C60
	7:  C1 = -32'sd1137;  //C71
	8:  C1 = 32'sd1448;   //C03
	9:  C1 = -32'sd399;   //C14
	10:  C1 = -32'sd1892;  //C23
	11:  C1 = 32'sd1137;   //C34
	12:  C1 = 32'sd1448;   //C43
	13:  C1 = -32'sd1702;  //C54
	14:  C1 = -32'sd783;   //C63
	15:  C1 = 32'sd2008;   //C74
	16:  C1 = 32'sd1448;   //C06
	17:  C1 = -32'sd2008;  //C17
	18:  C1 = 32'sd783;    //C26
	19:  C1 = -32'sd1702;  //C37
	20:  C1 = -32'sd1448;  //C46
   21:  C1 = -32'sd1137;  //C57
   22:  C1 = -32'sd1892;  //C66
   23:  C1 = -32'sd399;   //C77
	default: C1 = 32'sd1448;
	endcase
end


//C Matrix for C indices used in m2
always_comb begin
	case(m2_c)
	0:  C2 = 32'sd1448;   //C01
	1:  C2 = 32'sd1448;   //C02
	2:  C2 = 32'sd783;    //C21
	3:  C2 = -32'sd783;   //C22
	4:  C2 = -32'sd1448;  //C41
	5:  C2 = -32'sd1448;  //C42
	6:  C2 = -32'sd1892;  //C61
	7:  C2 = 32'sd1892;   //C62
	8:  C2 = 32'sd1448;   //C04
	9:  C2 = 32'sd1448;   //C05
	10:  C2 = -32'sd1892;  //C24
	11:  C2 = -32'sd783;   //C25
	12:  C2 = 32'sd1448;   //C44
	13:  C2 = -32'sd1448;  //C45
	14:  C2 = -32'sd783;   //C64
	15:  C2 = 32'sd1892;   //C65
	16:  C2 = 32'sd1448;   //C07
	17:  C2 = 32'sd1892;   //C27
	18:  C2 = 32'sd1448;   //C47
	19:  C2 = 32'sd783;    //C67
	default: C2 = 32'sd1448;
	endcase
end

//C Matrix for C indices used in m3
always_comb begin
	case(m3_c)
	0:  C3 = 32'sd2008;   //C10
	1:  C3 = 32'sd1137;   //C12
	2:  C3 = 32'sd1702;   //C30
	3:  C3 = -32'sd2008;  //C32
	4:  C3 = 32'sd1137;   //C50
	5:  C3 = 32'sd399;    //C52
	6:  C3 = 32'sd399;    //C70
   7:  C3 = 32'sd1702;   //C72 ///			
	8:  C3 = 32'sd399;    //C13
	9:  C3 = -32'sd1137;  //C15
	10:  C3 = -32'sd1137;  //C33
	11:  C3 = 32'sd2008;   //C35
	12:  C3 = 32'sd1702;   //C53
	13:  C3 = -32'sd399;   //C55
	14:  C3 = -32'sd2008;  //C73
   15:  C3 = -32'sd1702;  //C75
	16:  C3 = -32'sd1702;  //C16
	17:  C3 = 32'sd399;    //C36
	18:  C3 = 32'sd2008;   //C56	
	19:  C3 = 32'sd1137;   //C76
	default: C3 = 32'sd2008;
	endcase
end
endmodule


