// spi_clock_div.sv
/*
  Módulo separado para divisor de clock e detecção de borda.
*/
module spi_clock_div #(
    parameter DIV_WIDTH = 8
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               master_mode,
    input  wire [DIV_WIDTH-1:0] clk_div,
    input  wire               cpol,
    input  wire               cpha,
    input  wire               sclk_in,
    output reg                sclk,
    output wire               clk_edge
);
    reg [DIV_WIDTH-1:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt  <= 0;
            sclk <= cpol;
        end else if (master_mode) begin
            if (cnt == clk_div) begin cnt <= 0; sclk <= ~sclk; end
            else cnt <= cnt + 1;
        end
    end
    assign clk_edge = master_mode ? (cnt == clk_div)
                                  : (cpha ? sclk_in : ~sclk_in);
endmodule

