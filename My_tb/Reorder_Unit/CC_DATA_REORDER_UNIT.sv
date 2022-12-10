// Copyright (c) 2022 Sungkyunkwan University

module CC_DATA_REORDER_UNIT
(
    input   wire            clk,
    input   wire            rst_n,
	
    // AMBA AXI interface between MEM and CC (R channel)
    input   wire    [63:0]  mem_rdata_i,
    input   wire            mem_rlast_i,
    input   wire            mem_rvalid_i,
    output  wire            mem_rready_o,    

    // Hit Flag FIFO write interface
    output  wire            hit_flag_fifo_afull_o,
    input   wire            hit_flag_fifo_wren_i,
    input   wire            hit_flag_fifo_wdata_i,

    // Hit data FIFO write interface
    output  wire            hit_data_fifo_afull_o,
    input   wire            hit_data_fifo_wren_i,
    input   wire    [517:0] hit_data_fifo_wdata_i,

	// AMBA AXI interface between INCT and CC (R channel)
    output  wire    [63:0]  inct_rdata_o,
    output  wire            inct_rlast_o,
    output  wire            inct_rvalid_o,
    input   wire            inct_rready_i
);

    // Fill the code here

    // wire and reg to hit flag fifo's read interface
    wire hit_flag_fifo_aempty_w;
    reg  hit_flag_fifo_rden_w, hit_flag_fifo_rden_w_n;
    wire hit_flag_fifo_rdata_w;

    // instantiation the Hit Flag FIFO
    CC_FIFO 
    # (
        .FIFO_DEPTH(10),
        .DATA_WIDTH(1),
        .AFULL_THRESHOLD(9), // should be DEPTH - 1 !!
        .AEMPTY_THRESHOLD(0)
    ) HIT_FLAG_FIFO (
        .clk(clk),
        .rst_n(rst_n),

        .full_o(),
        .afull_o(hit_flag_fifo_afull_o),
        .wren_i(hit_flag_fifo_wren_i),
        .wdata_i(hit_flag_fifo_wdata_i),

        .empty_o(),
        .aempty_o(hit_flag_fifo_aempty_w),
        .rden_i(hit_flag_fifo_rden_w),
        .rdata_o(hit_flag_fifo_rdata_w)
    );

    // wire to data fifo's read interfcae 
    wire            data_fifo_aempty_w;
    wire            data_fifo_rden_w;
    wire [517 : 0]  data_fifo_rdata_w;

    //instantiation of Hit data & offset FIFO
    CC_FIFO 
    # (
        .FIFO_DEPTH(80), // should be HIT_FLAG_FIFO_DEPTH * 8
        .DATA_WIDTH(518),
        .AFULL_THRESHOLD(72), // should be DEPTH - 8 !!
        .AEMPTY_THRESHOLD(0)
    ) HIT_DATA_AND_OFFSET_FIFO (
        .clk(clk),
        .rst_n(rst_n),

        .full_o(),
        .afull_o(hit_data_fifo_afull_o),
        .wren_i(hit_data_fifo_wren_i),
        .wdata_i(hit_data_fifo_wdata_i),

        .empty_o(),
        .aempty_o(data_fifo_aempty_w),
        .rden_i(data_fifo_rden_w),
        .rdata_o(data_fifo_rdata_w)
    );

    // wire to get Serializer's signal
    wire [63 : 0]   serializer_rdata_w;
    wire            serializer_rlast_w;
    wire            serializer_rvalid_w;
    
    reg             serializer_rready_w, serializer_rready_w_n;

    //instantiation of serializer
    CC_SERIALIZER CC_SERIALIZER_inst0 (
        .clk(clk),
        .rst_n(rst_n),

        .fifo_empty_i(data_fifo_empty_w),
        .fifo_aempty_i(data_fifo_aempty_w),
        .fifo_rdata_i(data_fifo_rdata_w),
        .fifo_rden_o(data_fifo_rden_w),

        .rdata_o(serializer_rdata_w),
        .rlast_o(serializer_rlast_w),
        .rvalid_o(serializer_rvalid_w),
        .rready_i(serializer_rready_w)
    );

    reg             mem_rready, mem_rready_n;

    reg [63 : 0]    inct_rdata, inct_rdata_n;
    reg             inct_rlast, inct_rlast_n;
    reg             inct_rvalid, inct_rvalid_n;

    always_ff@(posedge clk) begin
        if(!rst_n) begin
            hit_flag_fifo_rden_w    <= 1'b0;

            serializer_rready_w     <= 1'b0;

            mem_rready              <= 1'b0;

            inct_rdata              <= 64'd0;
            inct_rlast              <= 1'b0;
            inct_rvalid             <= 1'b0;
        end else begin
            hit_flag_fifo_rden_w    <= hit_flag_fifo_rden_w_n;

            serializer_rready_w     <= serializer_rready_w_n;

            mem_rready              <= mem_rready_n;

            inct_rdata              <= inct_rdata_n;
            inct_rlast              <= inct_rlast_n;
            inct_rvalid             <= inct_rvalid_n;
        end
    end

    always_comb begin
        hit_flag_fifo_rden_w_n  = 1'b0;

        serializer_rready_w_n   = 1'b0;

        mem_rready_n            = 1'b0;

        inct_rdata_n            = 64'd0;
        inct_rlast_n            = 1'b0;
        inct_rvalid_n           = 1'b0;

        if(!hit_flag_fifo_aempty_w & hit_flag_fifo_rdata_w) begin // tag hit!
            // if tag is hit, data should come from serializer
            serializer_rready_w_n   = 1'b1; 
            // mem_rready_n            = 1'b0;

            if(serializer_rready_w & serializer_rvalid_w) begin // handshake
                inct_rdata_n    = serializer_rdata_w; 
                inct_rvalid_n   = 1'b1;

                if(serializer_rlast_w) begin // last data
                    inct_rlast_n            = 1'b1;
                    hit_flag_fifo_rden_w_n  = 1'b1;
                end
            end
        end else if(!hit_flag_fifo_aempty_w & !hit_flag_fifo_rdata_w) begin // tag miss!
            // if tag is miss, data should come from MC R channel
            // serializer_rready_w_n   = 1'b0;
            mem_rready_n            = 1'b1;
            
            if(mem_rready & mem_rvalid_i) begin
                inct_rdata_n    = mem_rdata_i;
                inct_rvalid_n   = 1'b1;

                if(mem_rlast_i) begin
                    inct_rlast_n            = 1'b1;
                    hit_flag_fifo_rden_w_n  = 1'b1;
                end
            end
        end
    end

    // assign output
    assign mem_rready_o = mem_rready;
    assign inct_rdata_o = inct_rdata;
    assign inct_rlast   = inct_rlast;
    assign inct_rvalid  = inct_rvalid;

endmodule