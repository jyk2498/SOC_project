// Copyright (c) 2022 Sungkyunkwan University

module CC_DATA_FILL_UNIT
(
    input   wire            clk,
    input   wire            rst_n,
	
    // AMBA AXI interface between MEM and CC (R channel)
    input   wire    [63:0]  mem_rdata_i,
    input   wire            mem_rlast_i,
    input   wire            mem_rvalid_i,
    input   wire            mem_rready_i,

    // Miss Addr FIFO read interface 
    input   wire            miss_addr_fifo_empty_i,
    input   wire    [31:0]  miss_addr_fifo_rdata_i,
    output  wire            miss_addr_fifo_rden_o,

    // SRAM write port interface
    output  wire                wren_o,
    output  wire    [8:0]       waddr_o,
    output  wire    [17:0]      wdata_tag_o,
    output  wire    [511:0]     wdata_data_o   
);

    // Fill the code here
    reg miss_addr_fifo_rden, miss_addr_fifo_rden_n;

    reg             wren, wren_n;
    reg [8 : 0]     waddr, waddr_n;
    reg [17 : 0]    wdata_tag, wdata_tag_n;
    reg [511 : 0]   wdata_data, wdata_data_n;

    reg [3 : 0]     cnt, cnt_n;

    always_ff@(posedge clk) begin
        if(!rst_n) begin
            miss_addr_fifo_rden <= 1'b0;

            wren                <= 1'b0;
            waddr               <= 9'd0;
            wdata_tag           <= 18'd0;
            wdata_data          <= 512'd0;

            cnt                 <= 3'b000;
        end else begin
            miss_addr_fifo_rden <= miss_addr_fifo_rden_n;

            wren                <= wren_n;
            waddr               <= waddr_n;
            wdata_tag           <= wdata_tag_n;
            wdata_data          <= wdata_data_n;

            cnt                 <= cnt_n;
        end
    end

    wire [3 : 0] wrptr;
    assign wrptr = cnt + miss_addr_fifo_rdata_i[5 : 3];
    always_comb begin
        miss_addr_fifo_rden_n   = 1'b0;

        wren_n                  = 1'b0;
        waddr_n                 = waddr;
        wdata_data_n            = wdata_data;
        wdata_tag_n             = 18'd0;

        cnt_n                   = 3'b000;
        if(mem_rready_i & mem_rvalid_i & !miss_addr_fifo_empty_i) begin
            wren_n                  = 1'b1;
            cnt_n                   = cnt + 1'd1;
            wdata_tag_n             = miss_addr_fifo_rdata_i[31 : 15];
            waddr_n                 = miss_addr_fifo_rdata_i[14 : 6];

            case(wrptr)
                3'b000: begin
                    wdata_data_n[511 : 448] = mem_rdata_i; 
                end
                3'b001: begin
                    wdata_data_n[447 : 384] = mem_rdata_i; 
                end
                3'b010: begin
                    wdata_data_n[383 : 320] = mem_rdata_i; 
                end
                3'b011: begin
                    wdata_data_n[319 : 256] = mem_rdata_i; 
                end
                3'b100: begin
                    wdata_data_n[255 : 192] = mem_rdata_i; 
                end
                3'b101: begin
                    wdata_data_n[191 : 128] = mem_rdata_i; 
                end
                3'b110: begin
                    wdata_data_n[127 : 64]  = mem_rdata_i; 
                end
                3'b111: begin
                    wdata_data_n[63 : 0]    = mem_rdata_i; 
                end
            endcase

        end 

        if(mem_rlast_i) begin
            miss_addr_fifo_rden_n = 1'b1;
        end
    end

    // output assign
    assign miss_addr_fifo_rden_o    = miss_addr_fifo_rden;

    assign wren_o           = wren;
    assign waddr_o          = waddr;
    assign wdata_tag_o      = wdata_tag;
    assign wdata_data_o     = wdata_data;   
endmodule