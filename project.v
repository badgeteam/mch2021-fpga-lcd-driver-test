`default_nettype none
`include "lcd.v"
`include "pwm.v"
`include "smoldvi.v"
`include "pll_12_126.v"
`include "reset_sync.v"
`include "fpga_reset.v"

module chip (
    input wire       clk_osc,
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

assign led[0] = 1;
assign led[1] = 1;
assign led[2] = 1;

// LED
/*reg [7:0] pwm_val[0:2];

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
end*/

// PMOD

/*reg [31:0] pmod_counter = 0;
reg [3:0] pmod_value = 0;

assign pmod = ~(1 << pmod_value);

always @(posedge clk_10khz) begin
    if (pmod_counter == 2000) begin
        pmod_counter <= 0;
        pmod_value <= pmod_value + 1;
    end else begin
        pmod_counter <= pmod_counter + 1;
    end
end
*/
// LCD

/*wire clk_48mhz;
SB_HFOSC #(.CLKHF_DIV("0b01")) hfosc0 (
    .CLKHFEN(1'b1),
    .CLKHFPU(1'b1),
    .CLKHF(clk_48mhz)
);*/

/*wire lcd_reset_int;
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
    .i_clk(clk_osc),
    .i_lcd_fmark(lcd_fmark),
    .o_lcd_wr(lcd_wr),
    .o_lcd_rs(lcd_rs),
    .o_lcd_data(lcd_data),
    .o_lcd_reset_inverted(lcd_reset_int),
    .o_lcd_cs_inverted(lcd_cs_int)
);*/

// DVI video out

wire clk_pix;
wire clk_bit;
wire rst_n_por;
wire rst_n_pix;
wire rst_n_bit;
wire pll_lock;

pll_12_126 #(
    .ICE40_PAD (1),
) pll_bit (
    .clock_in  (clk_osc),
    .clock_out (clk_bit),
    .locked    (pll_lock)
);

fpga_reset #(
    .SHIFT (3),
    .COUNT (0)
) rstgen (
    .clk         (clk_bit),
    .force_rst_n (pll_lock),
    .rst_n       (rst_n_por)
);

reset_sync reset_sync_bit (
    .clk       (clk_bit),
    .rst_n_in  (rst_n_por),
    .rst_n_out (rst_n_bit)
);

reset_sync reset_sync_pix (
    .clk       (clk_pix),
    .rst_n_in  (rst_n_por),
    .rst_n_out (rst_n_pix)
);


// Generate clk_pix from clk_bit with ring counter (hack)
(* keep = 1'b1 *) reg [4:0] bit_pix_div;
assign clk_pix = bit_pix_div[0];

always @ (posedge clk_bit or negedge rst_n_bit) begin
    if (!rst_n_bit) begin
        bit_pix_div <= 5'b11100;		
    end else begin
        bit_pix_div <= {bit_pix_div[3:0], bit_pix_div[4]};
    end
end

wire rgb_rdy;
reg [9:0] x_ctr;
reg [8:0] y_ctr;
reg [7:0] frame_ctr;
reg frame_ctr_dir;

always @ (posedge clk_pix or negedge rst_n_pix) begin
    if (!rst_n_pix) begin
        x_ctr <= 10'h0;
        y_ctr <= 9'h0;
        frame_ctr <= 8'h0;
        frame_ctr_dir <= 0;
    end else if (rgb_rdy) begin
        if (x_ctr == 10'd638) begin
            x_ctr <= 10'h0;
            if (y_ctr == 9'd479) begin
                y_ctr <= 9'h0;
                frame_ctr <= frame_ctr + 1'b1;
            end else begin
                y_ctr <= y_ctr + 1'b1;
            end
        end else begin
            // Note x advances by 2 because of pixel doubling
            x_ctr <= x_ctr + 2'h2;
        end
    end
end

wire [3:0] dvi_p;
wire [3:0] dvi_n;

assign pmod[0] = dvi_p[2];
assign pmod[1] = dvi_p[1];
assign pmod[2] = dvi_p[0];
assign pmod[3] = dvi_p[3];
assign pmod[4] = dvi_n[2];
assign pmod[5] = dvi_n[1];
assign pmod[6] = dvi_n[0];
assign pmod[7] = dvi_n[3];

smoldvi inst_smoldvi (
    .clk_pix   (clk_pix),
    .rst_n_pix (rst_n_pix),
    .clk_bit   (clk_bit),
    .rst_n_bit (rst_n_bit),

    .en        (1'b1),

    .r         (6'h3F - frame_ctr),
    .g         (y_ctr + 2 * frame_ctr),
    .b         (frame_ctr),
    .rgb_rdy   (rgb_rdy),

    .dvi_p     (dvi_p),
    .dvi_n     (dvi_n)
);

endmodule
