`default_nettype none

module lcd (
    input            clk,
    output     [2:0] led,
    output     [7:0] lcd_data,
    output           lcd_rs,
    output           lcd_wr,
    input            lcd_fmark,
    output           lcd_cs_inverted,
    output           lcd_reset_inverted
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
reg [31:0] slow_counter = 32'b0;

reg reg_lcd_reset_inverted;
reg reg_lcd_cs_inverted;

always @ (posedge clk) begin
    if (~reg_lcd_wr) begin
        reg_lcd_wr <= 1;
        reg_pixel_byte <= reg_pixel_byte_next;
        reg_pixel_byte_next <= 0;
    end else begin
        if (state == 2'h00) begin        
            reg_lcd_rs             <= 1'b0;
            reg_lcd_data           <= 16'h00;
            reg_lcd_wr             <= 1'b1;
            reg_pixel_byte         <= 1'b0;
            reg_pixel_byte_next    <= 1'b0;
            state                  <= 2'h01;
            reg_lcd_reset_inverted <= 1'b1; // Reset LCD
            reg_lcd_cs_inverted    <= 1'b0;
        end else if (state == 2'h01) begin
            reg_lcd_rs             <= 1'b0;
            reg_lcd_data           <= 16'h00;
            reg_lcd_wr             <= 1'b1;
            reg_pixel_byte         <= 1'b0;
            reg_pixel_byte_next    <= 1'b0;
            state                  <= 2'h02;
            reg_lcd_reset_inverted <= 1'b0;
            reg_lcd_cs_inverted    <= 1'b1; // Select LCD
        end else if (state == 2'h02) begin
            reg_pixel_byte <= 1'b0;
            reg_pixel_byte_next <= 1'b0;
            if (init_sequence_counter >= 93) begin
                state <= 2'h03;
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 0) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'hef;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 1) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h03;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 2) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h80;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 3) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h02;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 4) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'hcf;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 5) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 6) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'hc1;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 7) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h30;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 8) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'hed;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 9) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h64;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 10) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h03;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 11) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h12;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 12) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h81;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 13) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'he8;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 14) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h85;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 15) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 16) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h78;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 17) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'hcb;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 18) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h39;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 19) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h2c;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 20) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 21) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h34;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 22) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h02;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 23) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'hf7;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 24) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h20;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 25) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'hea;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 26) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 27) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 28) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'hc0;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 29) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h23;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 30) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'hc1;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 31) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h10;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 32) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'hc5;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 33) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h3e;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 34) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h28;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 35) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'hc7;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 36) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h86;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 37) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'h36;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 38) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h48;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 39) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'h3a;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 40) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h55;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 41) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'hb1;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 42) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 43) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h18;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 44) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'hb6;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 45) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h08;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 46) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h82;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 47) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h27;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 48) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'hf2;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 49) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 50) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'h26;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 51) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h01;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 52) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'he0;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 53) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h0f;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 54) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h31;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 55) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h2b;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 56) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h0c;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 57) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h0e;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 58) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h08;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 59) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h4e;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 60) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'hf1;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 61) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h37;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 62) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h07;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 63) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h10;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 64) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h03;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 65) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h0e;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 66) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h09;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 67) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 68) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'he1;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 69) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 70) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h0e;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 71) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h14;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 72) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h03;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 73) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h11;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 74) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h07;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 75) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h31;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 76) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'hc1;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 77) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h48;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 78) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h08;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 79) begin
               reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h0f;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 80) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h0c;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 81) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h31;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 82) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h36;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 83) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h0f;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 84) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'h11;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 85) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'h29;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 86) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'h36;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 87) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 88) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'h2a;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 89) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 90) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'h2b;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 91) begin
                reg_lcd_rs   <= 1'b1;
                reg_lcd_data <= 16'h00;
                reg_lcd_wr   <= 1'b0;
            end else if (init_sequence_counter == 92) begin
                reg_lcd_rs   <= 1'b0;
                reg_lcd_data <= 16'h2c;
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
                reg_lcd_data <= 16'b0000000000011111;
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
assign lcd_reset_inverted = reg_lcd_reset_inverted;
assign lcd_cs_inverted = reg_lcd_cs_inverted;

endmodule
