module CC_SERIALIZER_tb();
    reg             clk, rst_n; // special inputs

    reg             fifo_empty_i;
    reg             fifo_aempty_i;
    reg [517 : 0]   fifo_rdata_i;
    wire            fifo_rden_o;

    wire [63 : 0]   rdata_o;
    wire            rlast_o;
    wire            rvalid_o;
    reg             rready_i;

    CC_SERIALIZER CC_SERIALIZER_inst(
        .clk(clk),
        .rst_n(rst_n),

        .fifo_empty_i(fifo_empty_i),
        .fifo_aempty_i(fifo_aempty_i),
        .fifo_rdata_i(fifo_rdata_i), // notice upper 6 bit is offset
        .fifo_rden_o(fifo_rden_o),

        .rdata_o(rdata_o),
        .rlast_o(rlast_o),
        .rvalid_o(rvalid_o),
        .rready_i(rready_i)
    );

    initial begin
        // initialize the input
        clk     = 1'b0;
        rst_n   = 1'b0;

        fifo_empty_i    = 1'b0;
        fifo_aempty_i   = 1'b0;
        fifo_rdata_i    = 518'd0;
        
        rready_i        = 1'b0;

        @(posedge clk) #1
        rst_n           = 1'b1;
        fifo_empty_i    = 1'b0;
        fifo_aempty_i   = 1'b0;
        rready_i        = 1'b1;
        fifo_rdata_i    = {6'b011000, 64'd0, 64'd1, 64'd22, 64'd333, 64'd444, 64'd5, 64'd66, 64'd777};
        // critical word offset is 3

        @(posedge clk); // rvalid signal should be 1
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk); // fifo_rden_o should 1 tick here
        @(posedge clk); // waiting 8 cycle
        // rlast_o signal should be 1 tick
        #1 fifo_rdata_i    = {6'b101000, 64'd0, 64'd11, 64'd2, 64'd33, 64'd44, 64'd55, 64'd666, 64'd7};
        // critical word offset is 5

        @(posedge clk); // rvalid signal should be 1
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk); // fifo_rden_o should 1 tick here
        @(posedge clk); // waiting 8 cycle
        // rlast_o signal should be 1 tick
        #1
        fifo_empty_i = 1'b1;
        fifo_rdata_i    = {6'b010000, 64'd0, 64'd11, 64'd2, 64'd33, 64'd44, 64'd55, 64'd666, 64'd7};

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk); // waiting 8 cycle
        #1 
        fifo_empty_i    = 1'b0;
        rready_i        = 1'b0;
        fifo_rdata_i    = {6'b010000, 64'd0, 64'd11, 64'd2, 64'd33, 64'd44, 64'd55, 64'd666, 64'd7};


        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk); // waiting 8 cycle

    end

    always begin
        #10 clk <= ~clk;
    end

endmodule