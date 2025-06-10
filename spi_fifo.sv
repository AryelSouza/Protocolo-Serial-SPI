// spi_fifo.sv
/*
  Módulo parametrizado de FIFO circular.
*/
module spi_fifo #(
    parameter DATA_WIDTH = `SPI_DATA_WIDTH,
    parameter DEPTH      = `SPI_FIFO_DEPTH
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire [DATA_WIDTH-1:0] din,
    input  wire                  wr_en,
    output wire                  full,
    output wire [DATA_WIDTH-1:0] dout,
    input  wire                  rd_en,
    output wire                  empty
);
    localparam ADDR_WIDTH = DEPTH>0 ? $clog2(DEPTH) : 1;
    reg [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
    reg [ADDR_WIDTH:0]   count;
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) wr_ptr <= 0;
        else if (wr_en && !full) begin
        mem[wr_ptr] <= din;
        wr_ptr <= wr_ptr + 1;
    end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) rd_ptr <= 0;
        else if (rd_en && !empty) rd_ptr <= rd_ptr + 1;
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) count <= 0;
        else case ({wr_en && !full, rd_en && !empty})
            2'b10: count <= count + 1;
            2'b01: count <= count - 1;
            default: count <= count;
        endcase
    end
    assign full  = (count == DEPTH);
    assign empty = (count == 0);
    assign dout  = mem[rd_ptr];
endmodule
