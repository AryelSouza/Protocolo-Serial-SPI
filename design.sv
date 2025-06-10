// design.sv

`include "spi_defines.sv"
`include "spi_clock_div.sv"
`include "spi_fifo.sv"
`include "spi_fsm.sv"

module spi #(
    parameter DATA_WIDTH = `SPI_DATA_WIDTH,
    parameter FIFO_DEPTH = `SPI_FIFO_DEPTH
)(
    input  wire              clk, rst_n,
    input  wire              cfg_master, cfg_cpol, cfg_cpha,
    input  wire [7:0]        cfg_clk_div,
    output wire              sclk, mosi, ss_n,
    input  wire              miso, sclk_in, ss_n_in,
    input  wire [DATA_WIDTH-1:0] tx_data,
    input  wire              tx_valid,
    output wire              tx_ready,
    output wire [DATA_WIDTH-1:0] rx_data,
    output wire              rx_valid,
    input  wire              rx_ready
);
    wire clk_edge;
    spi_clock_div u_div(
        .clk(clk),.rst_n(rst_n),.master_mode(cfg_master),.clk_div(cfg_clk_div),
        .cpol(cfg_cpol),.cpha(cfg_cpha),.sclk_in(sclk_in),.sclk(sclk),.clk_edge(clk_edge)
    );
    wire [DATA_WIDTH-1:0] tx_dout;
    wire                  tx_empty;
    wire                  tx_rd_en;
    spi_fifo #(.DATA_WIDTH(DATA_WIDTH),.DEPTH(FIFO_DEPTH)) u_fifo_tx(
        .clk(clk),.rst_n(rst_n),.din(tx_data),.wr_en(tx_valid),.full(),
        .dout(tx_dout),.rd_en(tx_rd_en),.empty(tx_empty)
    );
    wire [DATA_WIDTH-1:0] rx_dout;
    wire                  rx_empty;
    wire                  rx_wr_en;
    spi_fifo #(.DATA_WIDTH(DATA_WIDTH),.DEPTH(FIFO_DEPTH)) u_fifo_rx(
        .clk(clk),.rst_n(rst_n),.din(),.wr_en(rx_wr_en),.full(),
        .dout(rx_dout),.rd_en(rx_ready),.empty(rx_empty)
    );
    spi_fsm #(.DATA_WIDTH(DATA_WIDTH)) u_fsm(
        .clk(clk),.rst_n(rst_n),.master_mode(cfg_master),.cpol(cfg_cpol),
        .cpha(cfg_cpha),.clk_edge(clk_edge),.tx_data(tx_data),.tx_valid(tx_valid),
        .tx_ready(tx_ready),.miso(miso),.mosi(mosi),.ss_n(ss_n),
        .fifo_tx_dout(tx_dout),.fifo_tx_empty(tx_empty),.fifo_tx_rd_en(tx_rd_en),
        .fifo_rx_dout(rx_dout),.fifo_rx_empty(rx_empty),.fifo_rx_wr_en(rx_wr_en),
        .rx_ready(rx_ready),.rx_data(rx_data),.rx_valid(rx_valid)
    );
endmodule

