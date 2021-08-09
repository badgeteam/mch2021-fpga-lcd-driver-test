`default_nettype none
`include "lcd.v"

module chip (
    output     [2:0] led,
    output           uart_tx,
    input            uart_rx,
    output           spi_miso,
    input            spi_mosi,
    input            spi_sck,
    input            spi_cs,
    input            ram_data1,
    output           ram_data0,
    output           ram_data2,
    output           ram_data3,
    output           ram_sck,
    output           ram_cs,
    output     [7:0] lcd_data,
    output           lcd_rs,
    output           lcd_wr,
    input            lcd_fmark
);

// PSRAM passthrough
assign spi_miso = ram_data1;
assign ram_data0 = spi_mosi;
assign ram_cs = spi_cs;
assign ram_sck = spi_sck;
assign ram_data2 = 0;
assign ram_data3 = 0;

// UART loopback
assign uart_tx = uart_rx;

wire clk;

SB_HFOSC #(.CLKHF_DIV("0b10")) OSCInst0 (
    .CLKHFEN(1'b1),
    .CLKHFPU(1'b1),
    .CLKHF(clk)
);

lcd lcd0 (
  .clk(clk),
  .led(led),
  .lcd_data(lcd_data),
  .lcd_rs(lcd_rs),
  .lcd_wr(lcd_wr),
  .lcd_fmark(lcd_fmark)
);

endmodule
