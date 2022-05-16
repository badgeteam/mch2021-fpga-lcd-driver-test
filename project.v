`default_nettype none
`include "lcd.v"
`include "pwm.v"

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
    output     [7:0] pmod,
    input            lcd_mode,
    inout            lcd_reset,
    inout            lcd_cs
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

// LED
reg [7:0] pwm_val[0:2];

wire pwm0_output;
wire pwm1_output;
wire pwm2_output;
assign led[0] = ~pwm0_output;
assign led[1] = ~pwm1_output;
assign led[2] = ~pwm2_output;

wire clk_10khz;
SB_LFOSC SB_LFOSC_inst(
    .CLKLFEN(1),
    .CLKLFPU(1),
    .CLKLF(clk_10khz)
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


reg [7:0] counter = 0;
reg led_dir = 0;
reg [2:0] led_sel = 0;
always @(posedge clk_10khz) begin
    if(counter == 0) begin
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
    end
    counter <= counter + 1;
end

// PMOD

reg [7:0] pmod_counter = 0;
reg [7:0] value;

always @(posedge clk) begin
    if (pmod_counter == 0) begin
        pmod_counter <= 11999999;
        pmod <= value;
        value <= value + 1;
    end else begin
        pmod_counter <= pmod_counter - 1;
    end
end

// LCD

/*wire clk_48mhz;
SB_HFOSC #(.CLKHF_DIV("0b01")) hfosc0 (
    .CLKHFEN(1'b1),
    .CLKHFPU(1'b1),
    .CLKHF(clk_48mhz)
);*/

wire lcd_reset_int;
wire lcd_cs_int;

SB_IO #(
    .PIN_TYPE(6'b 1010_01),
) lcd_reset_sb_io (
    .PACKAGE_PIN(lcd_reset),
    .OUTPUT_ENABLE(lcd_reset_int),
    .D_OUT_0(0)
);

SB_IO #(
    .PIN_TYPE(6'b 1010_01),
) lcd_cs_sb_io (
    .PACKAGE_PIN(lcd_cs),
    .OUTPUT_ENABLE(lcd_cs_int),
    .D_OUT_0(0)
);

lcd lcd0 (
    .i_reset(0),
    .i_clk(clk),
    .i_lcd_fmark(lcd_fmark),
    .o_lcd_wr(lcd_wr),
    .o_lcd_rs(lcd_rs),
    .o_lcd_data(lcd_data),
    .o_lcd_reset_inverted(lcd_reset_int),
    .o_lcd_cs_inverted(lcd_cs_int)
);

endmodule
