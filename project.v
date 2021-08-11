`default_nettype none
`include "lcd.v"
`include "pwm.v"
`include "spi.v"

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
    input            lcd_fmark,
    //output     [7:0] pmod
);

assign spi_miso = spi_mosi;

// PSRAM passthrough
//assign spi_miso = ram_data1;
//assign ram_data0 = spi_mosi;
//assign ram_cs = spi_cs;
//assign ram_sck = spi_sck;
//assign ram_data2 = 0;
//assign ram_data3 = 0;

// UART loopback
assign uart_tx = uart_rx;

// LED
reg [7:0] pwm_val[0:2];

wire pwm0_output;
wire pwm1_output;
wire pwm2_output;
assign led[0] = ~pwm0_output;
assign led[1] = spi_cs;//pwm1_output;
assign led[2] = ~pwm2_output;

wire clk_10khz;
SB_LFOSC SB_LFOSC_inst(
    .CLKLFEN(1),
    .CLKLFPU(1),
    .CLKLF(clk_10khz)
);

wire clk_48mhz;
SB_HFOSC #(.CLKHF_DIV("0b01")) hfosc0 (
    .CLKHFEN(1'b1),
    .CLKHFPU(1'b1),
    .CLKHF(clk_48mhz)
);
/*
spi spi0 (
    .i_clk(clk_48mhz),
    .i_spi_sck(spi_sck),
    .i_spi_cs(spi_cs),
    .i_spi_mosi(spi_mosi),
    .o_spi_miso(spi_miso),
    .o_led_red_value(pwm_val[0]),
    .o_led_green_value(pwm_val[1]),
    .o_led_blue_value(pwm_val[2])
);*/

lcd lcd0 (
    .i_reset(0),
    .i_clk(clk_48mhz),
    .i_lcd_fmark(lcd_fmark),
    .o_lcd_wr(lcd_wr),
    .o_lcd_rs(lcd_rs),
    .o_lcd_data(lcd_data)
);

pwm pwm0 (
    .i_reset(0),
    .i_clk(clk_10khz),
    .i_write(1),
    .i_target(pwm_val[0]),
    .o_pwm(pwm0_output)
);

pwm pwm1 (
    .i_reset(0),
    .i_clk(clk_10khz),
    .i_write(1),
    .i_target(pwm_val[1]),
    .o_pwm(pwm1_output)
);

pwm pwm2 (
    .i_reset(0),
    .i_clk(clk_10khz),
    .i_write(1),
    .i_target(pwm_val[2]),
    .o_pwm(pwm2_output)
);


/*reg [7:0] counter = 0;
reg led_dir = 0;
reg [2:0] led_sel = 0;
always @(posedge clk_10khz) begin
    if(counter == 0) begin
        pwm0_write <= 1;
        pwm1_write <= 1;
        pwm2_write <= 1;
        if (led_dir == 0) begin
            if (pwm_val[led_sel] == 32) begin
                led_dir <= 1;
                pwm_val[led_sel] <= pwm_val[led_sel] - 1;
            end else begin
                pwm_val[led_sel] <= pwm_val[led_sel] + 1;
            end
        end else begin
            if (pwm_val[led_sel] == 0) begin
                led_dir <= 0;
                if (led_sel < 2) begin
                    led_sel <= led_sel + 1;
                    pwm_val[led_sel+1] <= pwm_val[led_sel+1] + 1;
                end else begin
                    led_sel <= 0;
                    pwm_val[0] <= pwm_val[0] + 1;
                end
            end else begin
                pwm_val[led_sel] <= pwm_val[led_sel] - 1;
            end
        end
    end else begin
        pwm0_write <= 0;
        pwm1_write <= 0;
        pwm2_write <= 0;
    end
    counter <= counter + 1;
end*/

/*
wire clk_100mhz;
SB_PLL40_CORE #(
    .FEEDBACK_PATH("SIMPLE"),
    .PLLOUT_SELECT("GENCLK"),
    .DIVR(4'b0010),
    .DIVF(7'b0110001),
    .DIVQ(3'b011),
    .FILTER_RANGE(3'b001),
) SB_PLL40_CORE_inst (
    .RESETB(1'b1),
    .BYPASS(1'b0),
    .PLLOUTCORE(clk_100mhz),
    .REFERENCECLK(clk_48mhz)
);
*/

//assign pmod = (clk_100mhz << 7) | (clk_100mhz << 6) | (clk_100mhz << 5) | (clk_100mhz << 4) | (clk_100mhz << 3) | (clk_100mhz << 2) | (clk_100mhz << 1) | clk_100mhz;

endmodule
