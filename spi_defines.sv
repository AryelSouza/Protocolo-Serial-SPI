// spi_defines.sv
/*
  Parâmetros e estados comuns para o SPI
*/

`ifndef SPI_DEFINES_SV
`define SPI_DEFINES_SV

// Largura padrão de dados
`define SPI_DATA_WIDTH 8
// Profundidade padrão de FIFO
`define SPI_FIFO_DEPTH 16
// Estados da FSM
`define SPI_IDLE     2'd0
`define SPI_LOAD     2'd1
`define SPI_TRANSFER 2'd2
`define SPI_DONE     2'd3

`endif // SPI_DEFINES_SV


