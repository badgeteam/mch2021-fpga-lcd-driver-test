
`default_nettype none

module pwm (
    input        i_reset,
    input        i_clk,
    input        i_write,
    input  [7:0] i_target,
    output       o_pwm
);

reg [7:0] counter = 8'hFF;
reg [7:0] target  = 8'h00;

assign o_pwm = (counter < target);

always @ (posedge i_clk) begin
    if (i_reset) begin
        counter <= 8'hFF;
        target  <= 8'h00;
    end else begin
        counter <= counter + 1;
        if (i_write == 1'b1) begin
            target <= i_target;
        end
    end
end

endmodule
