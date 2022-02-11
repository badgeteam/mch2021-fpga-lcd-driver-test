`default_nettype none
`include "lcd.v"

module chip (
    input            clk,
    output     [2:0] led,
    output           uart_tx,
    input            uart_rx,
    output           spi_miso,
    input            spi_mosi,
    input            spi_sck,
    input            spi_cs,
    output           ram_data0,
    input            ram_data1,
    output           ram_data2,
    output           ram_data3,
    output           ram_sck,
    output           ram_cs,
    output     [7:0] lcd_data,
    output           lcd_rs,
    output           lcd_wr,
    input            lcd_fmark,
    output     [7:0] pmod
);

// PSRAM passthrough
assign spi_miso = ram_data1;
assign ram_data0 = spi_mosi;
assign ram_cs = spi_cs;
assign ram_sck = spi_sck;
assign ram_data2 = 1;
assign ram_data3 = 1;

// UART loopback
assign uart_tx = uart_rx;

reg [27:0] counter = 0;
reg [7:0] value = 0;

// LED
assign led[0] = value[0];
assign led[1] = value[1];
assign led[2] = value[2];

// Internal oscillator

/*wire clk;

SB_HFOSC #(.CLKHF_DIV("0b10")) OSCInst0 (
    .CLKHFEN(1'b1),
    .CLKHFPU(1'b1),
    .CLKHF(clk)
);*/

lcd lcd0 (
  .clk(clk),
  //.led(led),
  .lcd_data(lcd_data),
  .lcd_rs(lcd_rs),
  .lcd_wr(lcd_wr),
  .lcd_fmark(lcd_fmark)
);

always @(posedge clk) begin
    if (counter == 0) begin
        counter <= 11999999;
        pmod <= value;
        value <= value + 1;
    end else begin
        counter <= counter - 1;
    end
end

endmodule
