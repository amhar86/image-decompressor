// Copyright (C) 2019  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details, at
// https://fpgasoftware.intel.com/eula.


// Generated by Quartus Prime Version 19.1 (Build Build 670 09/22/2019)
// Created on Sun Nov 24 18:43:12 2024

dual_port_RAM1 dual_port_RAM1_inst
(
	.address_a(address_a_sig) ,	// input [6:0] address_a_sig
	.address_b(address_b_sig) ,	// input [6:0] address_b_sig
	.clock(clock_sig) ,	// input  clock_sig
	.data_a(data_a_sig) ,	// input [31:0] data_a_sig
	.data_b(data_b_sig) ,	// input [31:0] data_b_sig
	.wren_a(wren_a_sig) ,	// input  wren_a_sig
	.wren_b(wren_b_sig) ,	// input  wren_b_sig
	.q_a(q_a_sig) ,	// output [31:0] q_a_sig
	.q_b(q_b_sig) 	// output [31:0] q_b_sig
);

