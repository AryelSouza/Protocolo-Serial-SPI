// spi_fsm.sv
/*
  FSM principal gerencia a transferência SPI, instanciando FIFOs e clock_div.
*/
`include "spi_defines.sv"
module spi_fsm #(
    parameter DATA_WIDTH = `SPI_DATA_WIDTH
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  master_mode,
    input  wire                  cpol,
    input  wire                  cpha,
    input  wire                  clk_edge,
    input  wire [DATA_WIDTH-1:0] tx_data,
    input  wire                  tx_valid,
    output reg                   tx_ready,
    input  wire                  miso,
    output reg                   mosi,
    output reg                   ss_n,
    output reg [DATA_WIDTH-1:0]  rx_data,
    output reg                   rx_valid,
    input  wire                  rx_ready,
    input  wire [DATA_WIDTH-1:0] fifo_tx_dout,
    input  wire                  fifo_tx_empty,
    output wire                  fifo_tx_rd_en,
    input  wire [DATA_WIDTH-1:0] fifo_rx_dout,
    input  wire                  fifo_rx_empty,
    output wire                  fifo_rx_wr_en
);
    reg [1:0] state;
    reg [3:0] bit_cnt;
    reg [DATA_WIDTH-1:0] shift_reg;

    assign fifo_tx_rd_en = (state==`SPI_LOAD) && !fifo_tx_empty;
    assign fifo_rx_wr_en = (state==`SPI_TRANSFER) && clk_edge && (((master_mode?ss_n:1'b0) ^ cpha)==0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= `SPI_IDLE;
            tx_ready <= 1;
            rx_valid <= 0;
            ss_n     <= 1;
            shift_reg<= 0;
        end else begin
            case (state)
                `SPI_IDLE: if ((!fifo_tx_empty && master_mode) || (tx_valid && !master_mode)) begin
                    state <= `SPI_LOAD; tx_ready <= 0;
                end
                `SPI_LOAD: begin
                    ss_n <= master_mode?0:ss_n;
                    bit_cnt <= DATA_WIDTH;
                    shift_reg <= fifo_tx_empty? tx_data : fifo_tx_dout;
                    state <= `SPI_TRANSFER;
                end
                `SPI_TRANSFER: if (clk_edge && (((master_mode?ss_n:1'b0) ^ cpha)==0)) begin
                    mosi <= shift_reg[DATA_WIDTH-1];
                    shift_reg <= {shift_reg[DATA_WIDTH-2:0], miso};
                    bit_cnt <= bit_cnt - 1;
                    if (bit_cnt==1) state<=`SPI_DONE;
                end
                `SPI_DONE: begin
                    ss_n <= master_mode?1:ss_n;
                    rx_data <= fifo_rx_empty? shift_reg : fifo_rx_dout;
                    rx_valid<=1; tx_ready<=1; state<=`SPI_IDLE;
                end
            endcase
            if (rx_ready && rx_valid) rx_valid <= 0;
        end
    end
endmodule
