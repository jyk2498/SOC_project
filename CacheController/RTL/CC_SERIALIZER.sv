// Copyright (c) 2022 Sungkyunkwan University

module CC_SERIALIZER
(
	input	wire				clk,
	input	wire				rst_n,

	input	wire				fifo_empty_i,
	input	wire				fifo_aempty_i,
	input	wire	[517:0]		fifo_rdata_i, // notice upper 6 bit is offset
	output	wire				fifo_rden_o,

    output  wire    [63:0]		rdata_o,
    output  wire            	rlast_o,
    output  wire            	rvalid_o,
    input   wire            	rready_i
);

	// Fill the code here
	reg 			fifo_rden, fifo_rden_n;
	reg [63 : 0] 	rdata, rdata_n;
	reg 			rlast, rlast_n;
	reg 			rvalid, rvalid_n;

	reg [2 : 0] 	cnt, cnt_n; // to count 8 cycle

	always_ff@(posedge clk) begin
		if(!rst_n) begin
			fifo_rden		<= 1'b0;
			rdata 			<= 64'd0;
			rlast			<= 1'b0;			
			rvalid			<= 1'b0;

			cnt				<= 3'b000;
		end else begin
			fifo_rden 		<= fifo_rden_n;
			rdata 			<= rdata_n;
			rlast 			<= rlast_n;		
			rvalid 			<= rvalid_n;

			cnt				<= cnt_n;
		end
	end

	wire serializer_enabler;
	assign serializer_enabler = !fifo_aempty_i & rready_i; 	

	// Making cnt
	always_comb begin
		cnt_n = 3'd0; // preventing latch

		if(serializer_enabler) begin
			cnt_n = cnt + 1'd1;
		end
	end

	// Making fifo_rden
	always_comb begin
		if(cnt == 3'b110 && serializer_enabler) begin
			fifo_rden_n = 1'b1;
		end else begin
			fifo_rden_n = 1'b0;
		end
	end

	// Making rdata_n
	wire [2 : 0] cntaddcriticaloffset;
	assign cntaddcriticaloffset = cnt + fifo_rdata_i[517 : 515];

	always_comb begin
		rdata_n = rdata; // preventing latch

		if(serializer_enabler) begin
			case(cntaddcriticaloffset)
				3'b000: begin
					rdata_n = fifo_rdata_i[511 : 448];
				end
				3'b001: begin
					rdata_n = fifo_rdata_i[447 : 384];
				end
				3'b010: begin
					rdata_n = fifo_rdata_i[383 : 320];
				end
				3'b011: begin
					rdata_n = fifo_rdata_i[319 : 256];
				end
				3'b100: begin
					rdata_n = fifo_rdata_i[255 : 192];
				end
				3'b101: begin
					rdata_n = fifo_rdata_i[191 : 128];
				end
				3'b110: begin
					rdata_n = fifo_rdata_i[127 : 64];
				end
				3'b111: begin
					rdata_n = fifo_rdata_i[63 : 0];
				end
			endcase
		end
	end

	// Making rlast
	always_comb begin
		if(cnt == 3'b110 && serializer_enabler) begin	
			rlast_n = 1'b1;	
		end else begin
			rlast_n = 1'b0;
		end
	end

	// Making rvalid
	always_comb begin
		if(serializer_enabler) begin
			rvalid_n = 1'b1;	
		end else begin
			rvalid_n = 1'b0;
		end
	end

	//output assign
	assign fifo_rden_o 	= fifo_rden;
	assign rdata_o 		= rdata;
	assign rlast_o		= rlast;
	assign rvalid_o		= rvalid;
endmodule
