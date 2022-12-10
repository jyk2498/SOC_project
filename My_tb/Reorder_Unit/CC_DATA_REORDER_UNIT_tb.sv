module CC_DATA_REORDER_UNIT_tb();
    reg clk;
    reg rst_n;

    reg [63 : 0]    mem_rdata_i;
    reg             mem_rlast_i;
    reg             mem_rvalid_i;
    wire            mem_rready_o;

    wire            hit_flag_fifo_afull_o;
    reg             hit_flag_fifo_wren_i;
    reg             hit_flag_fifo_wdata_i;

    wire            hit_data_fifo_afull_o;
    reg             hit_data_fifo_wren_i;
    reg [517 : 0]   hit_data_fifo_wdata_i;

    wire [63 : 0]   inct_rdata_o;
    wire            inct_rlast_o;
    wire            inct_rvalid_o;
    reg             inct_rready_i;

    CC_DATA_REORDER_UNIT CC_DATA_REORDER_UNIT_inst0 (
        .clk(clk),
        .rst_n(rst_n),

        .mem_rdata_i(mem_rdata_i),
        .mem_rlast_i(mem_rlast_i),
        .mem_rvalid_i(mem_rvalid_i),
        .mem_rready_o(mem_rready_o),

        .hit_flag_fifo_afull_o(hit_flag_fifo_afull_o),
        .hit_flag_fifo_wren_i(hit_flag_fifo_wren_i),
        .hit_flag_fifo_wdata_i(hit_flag_fifo_wdata_i),

        .hit_data_fifo_afull_o(hit_data_fifo_afull_o),
        .hit_data_fifo_wren_i(hit_data_fifo_wren_i),
        .hit_data_fifo_wdata_i(hit_data_fifo_wdata_i),

        .inct_rdata_o(inct_rdata_o),
        .inct_rlast_o(inct_rlast_o),
        .inct_rvalid_o(inct_rvalid_o),
        .inct_rready_i(inct_rready_i)
    );

    initial begin
        // initialize the input
        clk                     = 1'b0;
        rst_n                   = 1'b0;

        mem_rdata_i             = 64'd0;
        mem_rlast_i             = 1'b0;
        mem_rvalid_i            = 1'b0;
        
        hit_flag_fifo_wren_i    = 1'b0;
        hit_flag_fifo_wdata_i   = 1'b0;

        hit_data_fifo_wren_i    = 1'b0;
        hit_data_fifo_wdata_i   = 518'd0;

        inct_rready_i           = 1'b0;

        @(posedge clk) #1
        rst_n       = 1'b1;
          
    end

    // Making clk
    always begin
        #10 clk <= ~clk;
    end
endmodule