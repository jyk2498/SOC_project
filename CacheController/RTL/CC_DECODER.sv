// Copyright (c) 2022 Sungkyunkwan University

module CC_DECODER
(
	input	wire	[31:0]	inct_araddr_i,
	input	wire			inct_arvalid_i,
	output	wire			inct_arready_o,

	input	wire			miss_addr_fifo_afull_i,
	input	wire			miss_req_fifo_afull_i,
	input	wire			hit_flag_fifo_afull_i,
	input	wire			hit_data_fifo_afull_i,

	output	wire	[16:0]	tag_o,
	output	wire	[8:0]	index_o,
	output	wire	[5:0]	offset_o,
	
	output	wire			hs_pulse_o
);

	// Fill the code here
	assign tag_o   	= inct_araddr_i[31 : 15];
	assign index_o 	= inct_araddr_i[14 : 6];
	assign offset_o = inct_araddr_i[5 : 0];

	// if there is at least 1 FIFO is afull, then stop the decoder
	wire atLeastoneAfull; // if this signal is one, that means there exist at least 1 afull signal
	assign atLeastoneAfull = miss_addr_fifo_afull_i | miss_req_fifo_afull_i 
			| hit_flag_fifo_afull_i | hit_data_fifo_afull_i;

	assign inct_arready_o = ~atLeastoneAfull;
	assign hs_pulse_o = (~atLeastoneAfull) & inct_arvalid_i;

endmodule
