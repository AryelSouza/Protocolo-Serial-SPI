// tb_spi.sv
`timescale 1ns/1ns
module tb_spi;
    // Baseline reduzido para simulação rápida (4 bits)
    reg clk, rst_n;
    reg cfg_cpol, cfg_cpha;
    reg [7:0] cfg_clk_div;
    wire sclk_m, mosi_m, ss_n_m;
    wire miso_s;
    reg [3:0] tx_data;
    reg tx_valid;
    wire tx_ready;
    wire [3:0] rx_data;
    wire rx_valid;
    reg rx_ready;
    integer mode;

    spi #(.DATA_WIDTH(4),.FIFO_DEPTH(0)) master (
        .clk(clk), .rst_n(rst_n), .cfg_master(1), .cfg_cpol(cfg_cpol), .cfg_cpha(cfg_cpha),
        .cfg_clk_div(cfg_clk_div), .sclk(sclk_m), .mosi(mosi_m), .miso(miso_s), .ss_n(ss_n_m),
        .sclk_in(1'b0), .ss_n_in(1'b1), .tx_data(tx_data), .tx_valid(tx_valid),
        .tx_ready(tx_ready), .rx_data(), .rx_valid(), .rx_ready(rx_ready)
    );
    spi #(.DATA_WIDTH(4),.FIFO_DEPTH(0)) slave (
        .clk(clk), .rst_n(rst_n), .cfg_master(0), .cfg_cpol(cfg_cpol), .cfg_cpha(cfg_cpha),
        .cfg_clk_div(cfg_clk_div), .sclk(), .mosi(), .miso(mosi_m), .ss_n(),
        .sclk_in(sclk_m), .ss_n_in(ss_n_m), .tx_data(4'h0), .tx_valid(1'b0),
        .tx_ready(), .rx_data(rx_data), .rx_valid(rx_valid), .rx_ready(1'b1)
    );
    assign miso_s = mosi_m;

    initial begin clk=0; forever #1 clk=~clk; end
    initial begin
        rst_n=0; tx_valid=0; rx_ready=0; cfg_clk_div=1; #5 rst_n=1;
        for(mode=0; mode<4; mode=mode+1) begin
            {cfg_cpol,cfg_cpha}=mode; @(posedge clk);
            tx_data=4'hA; tx_valid=1; @(posedge clk); tx_valid=0;
            @(posedge rx_valid); $display("Modo %0b%0b: %h",cfg_cpol,cfg_cpha,rx_data);
            @(posedge clk);
        end
        #5 $finish;
    end
endmodule

