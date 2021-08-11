
`default_nettype none

module spi (
    input        i_clk,
    input        i_spi_sck,
    input        i_spi_cs,
    input        i_spi_mosi,
    output       o_spi_miso,
    output [7:0] o_led_red_value,
    output [7:0] o_led_green_value,
    output [7:0] o_led_blue_value
);

parameter NOP=0, INIT=1, WR_INVERTED=2, WR_LEDS=4, WR_VEC=6, RD_VEC=7;

parameter INIT_SPICR0             = 0;
parameter INIT_SPICR1             = INIT_SPICR0+1;
parameter INIT_SPICR2             = INIT_SPICR1+1;
parameter INIT_SPIBR              = INIT_SPICR2+1;
parameter INIT_SPICSR             = INIT_SPIBR+1;
parameter SPI_WAIT_RECEPTION      = INIT_SPICSR+1;
parameter SPI_READ_OPCODE         = SPI_WAIT_RECEPTION+1;
parameter SPI_READ_LED_VALUE      = SPI_READ_OPCODE+1;
parameter SPI_READ_INIT           = SPI_READ_LED_VALUE+1;
parameter SPI_SEND_DATA           = SPI_READ_INIT+1;
parameter SPI_WAIT_TRANSMIT_READY = SPI_SEND_DATA+1;
parameter SPI_TRANSMIT            = SPI_WAIT_TRANSMIT_READY+1;

parameter SPI_ADDR_SPICR0  = 8'b00001000;
parameter SPI_ADDR_SPICR1  = 8'b00001001;
parameter SPI_ADDR_SPICR2  = 8'b00001010;
parameter SPI_ADDR_SPIBR   = 8'b00001011;
parameter SPI_ADDR_SPITXDR = 8'b00001101;
parameter SPI_ADDR_SPIRXDR = 8'b00001110;
parameter SPI_ADDR_SPICSR  = 8'b00001111;
parameter SPI_ADDR_SPISR   = 8'b00001100;

// Signals for the hardware SPI IP
reg        hwspi_stb      = 0;  // strobe must be set to high when read or write
reg        hwspi_rw       = 0;  // selects read or write (high = write)
reg  [7:0] hwspi_address  = 0;  // address
reg  [7:0] hwspi_data_in  = 0;  // data input
wire [7:0] hwspi_data_out;      // data output
wire       hwspi_ack;           // ack that the transfer is done (read valid or write ack)

SB_SPI SB_SPI_inst(
    .SBCLKI(i_clk),
    .SBSTBI(hwspi_stb),
    .SBRWI(hwspi_rw),
    .SBADRI0(hwspi_address[0]),
    .SBADRI1(hwspi_address[1]),
    .SBADRI2(hwspi_address[2]),
    .SBADRI3(hwspi_address[3]),
    .SBADRI4(hwspi_address[4]),
    .SBADRI5(hwspi_address[5]),
    .SBADRI6(hwspi_address[6]),
    .SBADRI7(hwspi_address[7]),
    .SBDATI0(hwspi_data_in[0]),
    .SBDATI1(hwspi_data_in[1]),
    .SBDATI2(hwspi_data_in[2]),
    .SBDATI3(hwspi_data_in[3]),
    .SBDATI4(hwspi_data_in[4]),
    .SBDATI5(hwspi_data_in[5]),
    .SBDATI6(hwspi_data_in[6]),
    .SBDATI7(hwspi_data_in[7]),
    .SBDATO0(hwspi_data_out[0]),
    .SBDATO1(hwspi_data_out[1]),
    .SBDATO2(hwspi_data_out[2]),
    .SBDATO3(hwspi_data_out[3]),
    .SBDATO4(hwspi_data_out[4]),
    .SBDATO5(hwspi_data_out[5]),
    .SBDATO6(hwspi_data_out[6]),
    .SBDATO7(hwspi_data_out[7]),
    .SBACKO(hwspi_ack),
    .SO(o_spi_miso),
    .SI(i_spi_mosi),
    .SCKI(i_spi_sck),
    .SCSNI(i_spi_cs)
);

reg is_spi_init             = 0; //waits the INIT command from the master
reg [7:0] counter_read      = 0; //count the bytes to read to form a command
reg [7:0] command_data[7:0];     //the command, saved as array of bytes
reg [7:0] counter_send      = 0; //counts the bytes to send
reg [7:0] data_to_send      = 0; //buffer for data to be written in send register
reg [7:0] data_vector[15:0];     //4*32bits = 16*8bits
reg [3:0] counter_vector    = 0;

reg [7:0] state = INIT_SPICR0;

reg [7:0] led_red_value   = 0;
reg [7:0] led_green_value = 0;
reg [7:0] led_blue_value  = 0;
assign o_led_red_value    = is_spi_init ? 255 : 0;//led_red_value;
assign o_led_green_value  = led_green_value;
assign o_led_blue_value   = led_blue_value;


always @ (posedge i_clk) begin
    hwspi_stb <= 0;
    case (state)
        INIT_SPICR0 : begin //spi control register 0, nothing interesting for this case (delay counts)
            hwspi_address <= SPI_ADDR_SPICR0;
            hwspi_data_in <= 8'b00000000;
            hwspi_stb     <= 1;
            hwspi_rw      <= 1;
            if(hwspi_ack == 1) begin
                hwspi_stb <= 0;
                state     <= INIT_SPICR1;
            end
        end
        INIT_SPICR1 : begin //spi control register 1
            hwspi_address <= SPI_ADDR_SPICR1;
            hwspi_data_in <= 8'b10000000; //bit7: enable SPI
            hwspi_stb     <= 1;
            hwspi_rw      <= 1;
            if(hwspi_ack == 1) begin
                hwspi_stb <= 0;
                state     <= INIT_SPICR2;
            end
        end
        INIT_SPICR2 : begin //spi control register 2
            hwspi_address <= SPI_ADDR_SPICR2;
            hwspi_data_in <= 8'b00000001; //bit0: lsb first
            hwspi_stb     <= 1;
            hwspi_rw      <= 1;
            if(hwspi_ack == 1) begin
                hwspi_stb <= 0;
                state     <= INIT_SPIBR;
            end
        end
        INIT_SPIBR : begin //spi clock prescale
            hwspi_address <= SPI_ADDR_SPIBR;
            hwspi_data_in <= 8'b00000000; //clock divider => 1
            hwspi_stb     <= 1;
            hwspi_rw      <= 1;
            if(hwspi_ack == 1) begin
                hwspi_stb <= 0;
                state     <= INIT_SPICSR;
            end
        end
        INIT_SPICSR : begin //SPI master chip select register, absolutely no use as SPI module set as slave
            hwspi_address <= SPI_ADDR_SPICSR;
            hwspi_data_in <= 8'b00000000;
            hwspi_stb     <= 1;
            hwspi_rw      <= 1;
            if(hwspi_ack == 1) begin
                hwspi_stb    <= 0;
                state        <= SPI_WAIT_RECEPTION;
                counter_read <= 0;
            end
        end
        SPI_WAIT_RECEPTION : begin
            hwspi_address <= SPI_ADDR_SPISR; //status register
            hwspi_stb     <= 1;
            hwspi_rw      <= 0; //read
            if(hwspi_ack == 1) begin
                hwspi_stb <= 0;
                state    <= SPI_WAIT_RECEPTION;
                //wait for bit3, tells that data is available
                if (is_spi_init == 0 && hwspi_data_out[3] == 1) begin
                    state <= SPI_READ_INIT;
                end
                if (is_spi_init == 1 && hwspi_data_out[3] == 1) begin
                    if(counter_send < 6) begin //can only send 6 bytes back
                        state <= SPI_WAIT_TRANSMIT_READY;
                    end else begin
                        state <= SPI_READ_OPCODE;
                    end
                end
            end
        end
        SPI_WAIT_TRANSMIT_READY: begin
            hwspi_address <= SPI_ADDR_SPISR; //status registers
            hwspi_stb <= 1;
            hwspi_rw <= 0; //read
            if(hwspi_ack == 1) begin
                hwspi_stb <= 0;
                //bit 4 = TRDY, transmit ready
                if (hwspi_data_out[4] == 1) begin
                    state <= SPI_TRANSMIT;
                end
            end
        end
        SPI_TRANSMIT: begin
            hwspi_address <= SPI_ADDR_SPITXDR;
            if(counter_send == 0) begin
                hwspi_data_in <= 8'b01000000;
            end else begin
                hwspi_data_in <= data_to_send;
            end

            hwspi_stb <= 1;
            hwspi_rw <= 1;
            if(hwspi_ack == 1) begin
                hwspi_stb <= 0;
                counter_send <= counter_send + 1;

                if (is_spi_init == 0) begin
                    state <= SPI_READ_INIT;
                end else begin
                    state <= SPI_READ_OPCODE;
                end
            end
        end
        SPI_READ_INIT: begin
            hwspi_address <= SPI_ADDR_SPIRXDR; //read data register
            hwspi_stb <= 1;
            hwspi_rw <= 0; //read
            if(hwspi_ack == 1) begin
                hwspi_stb <= 0;
                state <= SPI_WAIT_RECEPTION;
                command_data[counter_read] <= hwspi_data_out;

                if(hwspi_data_out == 8'h11)begin
                    counter_read <= 0;
                    is_spi_init <= 1;
                    counter_send <= 0;
                end
            end
        end
        SPI_READ_OPCODE: begin
            hwspi_address <= SPI_ADDR_SPIRXDR; //read data register
            hwspi_stb <= 1;
            hwspi_rw <= 0; //read
            if(hwspi_ack == 1) begin
                hwspi_stb <= 0;
                counter_read <= counter_read + 1;
                state <= SPI_WAIT_RECEPTION;
                command_data[counter_read] <= hwspi_data_out;
                if( counter_read == 0 ) begin
                    data_to_send <= hwspi_data_out;
                end else if( command_data[0] == WR_INVERTED )begin
                    data_to_send <= ~hwspi_data_out;
                end else if( command_data[0] == WR_LEDS )begin
                    data_to_send <= hwspi_data_out; //sends back what was written
                end else if( command_data[0] == WR_VEC )begin //send vec from host
                    if(counter_read < 5)begin //only 4 bytes after the opcode are useful
                        data_vector[counter_vector] <= hwspi_data_out;
                        counter_vector <= counter_vector + 1;
                    end
                end else if( command_data[0] == RD_VEC )begin //send vec to host
                    if(counter_read < 5)begin //only 4 bytes after the opcode are useful
                        data_to_send <= data_vector[counter_vector];
                        counter_vector <= counter_vector + 1;
                    end
                end
                if(counter_read == 7) begin
                    counter_read <= 0;
                    counter_send <= 0;
                    if( command_data[0] == WR_LEDS )begin
                        o_led_red_value   <= command_data[1]; //read the led value
                        o_led_green_value <= command_data[2]; //read the led value
                        o_led_blue_value  <= command_data[3]; //read the led value
                    end
                end
            end
        end
    endcase
end

endmodule
