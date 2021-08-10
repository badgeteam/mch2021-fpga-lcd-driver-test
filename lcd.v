`default_nettype none

module lcd (
    input            clk,
    output     [2:0] led,
    output     [7:0] lcd_data,
    output           lcd_rs,
    output           lcd_wr,
    input            lcd_fmark
);

reg reg_lcd_wr = 1'b1;
reg reg_lcd_rs = 1'b1;
reg [15:0] reg_lcd_data = 8'h00;
reg reg_pixel_byte = 1'b0;
reg reg_pixel_byte_next = 1'b0;
reg [12:0] reg_pixel_x = 0;
reg [12:0] reg_pixel_y = 0;
reg [12:0] reg_counter = 0;

reg[7:0] init_sequence_counter = 8'b0;
reg debug1 = 0;
reg debug2 = 0;
reg debug3 = 0;
reg [2:0] state = 2'h00;

reg  [8:0] init_sequence[0:92];

initial begin
    init_sequence[8'h00] <= 9'h0ef;
    init_sequence[8'h01] <= 9'h103;
    init_sequence[8'h02] <= 9'h180;
    init_sequence[8'h03] <= 9'h102;
    init_sequence[8'h04] <= 9'h0cf;
    init_sequence[8'h05] <= 9'h100;
    init_sequence[8'h06] <= 9'h1c1;
    init_sequence[8'h07] <= 9'h130;
    init_sequence[8'h08] <= 9'h0ed;
    init_sequence[8'h09] <= 9'h164;
    init_sequence[8'h0a] <= 9'h103;
    init_sequence[8'h0b] <= 9'h112;
    init_sequence[8'h0c] <= 9'h181;
    init_sequence[8'h0d] <= 9'h0e8;
    init_sequence[8'h0e] <= 9'h185;
    init_sequence[8'h0f] <= 9'h100;
    init_sequence[8'h10] <= 9'h178;
    init_sequence[8'h11] <= 9'h0cb;
    init_sequence[8'h12] <= 9'h139;
    init_sequence[8'h13] <= 9'h12c;
    init_sequence[8'h14] <= 9'h100;
    init_sequence[8'h15] <= 9'h134;
    init_sequence[8'h16] <= 9'h102;
    init_sequence[8'h17] <= 9'h0f7;
    init_sequence[8'h18] <= 9'h120;
    init_sequence[8'h19] <= 9'h0ea;
    init_sequence[8'h1a] <= 9'h100;
    init_sequence[8'h1b] <= 9'h100;
    init_sequence[8'h1c] <= 9'h0c0;
    init_sequence[8'h1d] <= 9'h123;
    init_sequence[8'h1e] <= 9'h0c1;
    init_sequence[8'h1f] <= 9'h110;
    init_sequence[8'h20] <= 9'h0c5;
    init_sequence[8'h21] <= 9'h13e;
    init_sequence[8'h22] <= 9'h128;
    init_sequence[8'h23] <= 9'h0c7;
    init_sequence[8'h24] <= 9'h186;
    init_sequence[8'h25] <= 9'h036;
    init_sequence[8'h26] <= 9'h148;
    init_sequence[8'h27] <= 9'h03a;
    init_sequence[8'h28] <= 9'h155;
    init_sequence[8'h29] <= 9'h0b1;
    init_sequence[8'h2a] <= 9'h100;
    init_sequence[8'h2b] <= 9'h118;
    init_sequence[8'h2c] <= 9'h0b6;
    init_sequence[8'h2d] <= 9'h108;
    init_sequence[8'h2e] <= 9'h182;
    init_sequence[8'h2f] <= 9'h127;
    init_sequence[8'h30] <= 9'h0f2;
    init_sequence[8'h31] <= 9'h100;
    init_sequence[8'h32] <= 9'h026;
    init_sequence[8'h33] <= 9'h101;
    init_sequence[8'h34] <= 9'h0e0;
    init_sequence[8'h35] <= 9'h10f;
    init_sequence[8'h36] <= 9'h131;
    init_sequence[8'h37] <= 9'h12b;
    init_sequence[8'h38] <= 9'h10c;
    init_sequence[8'h39] <= 9'h10e;
    init_sequence[8'h3a] <= 9'h108;
    init_sequence[8'h3b] <= 9'h14e;
    init_sequence[8'h3c] <= 9'h1f1;
    init_sequence[8'h3d] <= 9'h137;
    init_sequence[8'h3e] <= 9'h107;
    init_sequence[8'h3f] <= 9'h110;
    init_sequence[8'h40] <= 9'h103;
    init_sequence[8'h41] <= 9'h10e;
    init_sequence[8'h42] <= 9'h109;
    init_sequence[8'h43] <= 9'h100;
    init_sequence[8'h44] <= 9'h0e1;
    init_sequence[8'h45] <= 9'h100;
    init_sequence[8'h46] <= 9'h10e;
    init_sequence[8'h47] <= 9'h114;
    init_sequence[8'h48] <= 9'h103;
    init_sequence[8'h49] <= 9'h111;
    init_sequence[8'h4a] <= 9'h107;
    init_sequence[8'h4b] <= 9'h131;
    init_sequence[8'h4c] <= 9'h1c1;
    init_sequence[8'h4d] <= 9'h148;
    init_sequence[8'h4e] <= 9'h108;
    init_sequence[8'h4f] <= 9'h10f;
    init_sequence[8'h50] <= 9'h10c;
    init_sequence[8'h51] <= 9'h131;
    init_sequence[8'h52] <= 9'h136;
    init_sequence[8'h53] <= 9'h10f;
    init_sequence[8'h54] <= 9'h011;
    init_sequence[8'h55] <= 9'h029;
    init_sequence[8'h56] <= 9'h036;
    init_sequence[8'h57] <= 9'h100;
    init_sequence[8'h58] <= 9'h02a;
    init_sequence[8'h59] <= 9'h100;
    init_sequence[8'h5a] <= 9'h02b;
    init_sequence[8'h5b] <= 9'h100;
    init_sequence[8'h5c] <= 9'h02c;
end

always @ (posedge clk) begin
    if (~reg_lcd_wr) begin
        reg_lcd_wr <= 1;
        reg_pixel_byte <= reg_pixel_byte_next;
        reg_pixel_byte_next <= 0;
    end else begin
        if (state == 2'h00) begin
            reg_lcd_rs   <= 1'b0;
            reg_lcd_data <= 16'h00;
            reg_lcd_wr   <= 1'b1;
            reg_pixel_byte <= 1'b0;
            reg_pixel_byte_next <= 1'b0;
            state        <= 2'h01;
        end else if (state == 2'h01) begin
            reg_pixel_byte <= 1'b0;
            reg_pixel_byte_next <= 1'b0;
            if (init_sequence_counter >= 93) begin
                state <= 2'h02;
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else begin
                reg_lcd_rs   <= init_sequence[init_sequence_counter][8];
                reg_lcd_data <= init_sequence[init_sequence_counter][7:0];
                reg_lcd_wr   <= 1'b0;
            end
            init_sequence_counter <= init_sequence_counter + 1;
        end else if (reg_pixel_byte == 1'b1) begin
            reg_lcd_rs   <= 1'b1;
            reg_lcd_wr <= 1'b0;
            reg_pixel_byte <= 1'b0;
            reg_pixel_byte_next <= 1'b0;
        end else begin
            reg_lcd_rs   <= 1'b1;
            if (reg_pixel_y == 16) begin
                reg_lcd_data <= 16'b1111100000000000;
            end else if (reg_pixel_x == reg_counter) begin
                reg_lcd_data <= 16'b0000011111100000;
            end else begin
                reg_lcd_data <= 16'b0000000000000000;
            end
            reg_lcd_wr   <= 1'b0;
            reg_pixel_byte_next <= 1'b1;
            if (reg_pixel_y >= 239) begin
                reg_pixel_y <= 0;
                if (reg_pixel_x >= 319) begin
                    reg_pixel_x <= 0;
                    if (reg_counter >= 319) begin
                        reg_counter <= 0;
                    end else begin
                        reg_counter <= reg_counter + 1;
                    end
                end else begin
                    reg_pixel_x <= reg_pixel_x + 1;
                end
            end else begin
                reg_pixel_y <= reg_pixel_y + 1;
            end
        end
    end
end


assign lcd_wr   = reg_lcd_wr;
assign lcd_rs   = reg_lcd_rs;
assign lcd_data = reg_pixel_byte ? reg_lcd_data[15:8] : reg_lcd_data[7:0];
assign led[0]   = ~debug1;
assign led[1]   = ~debug2;
assign led[2]   = ~debug3;

endmodule
