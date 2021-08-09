data = [            [0xEF, 0x03,0x80,0x02],
            [0xCF, 0x00,0XC1,0X30],
            [0xED, 0x64,0x03,0X12,0X81],
            [0xE8, 0x85,0x00,0x78],
            [0xCB, 0x39,0x2C,0x00,0x34,0x02],
            [0xF7, 0x20],
            [0xEA, 0x00,0x00],
            [0xC0, 0x23],
            [0xC1, 0x10],
            [0xC5, 0x3e,0x28],
            [0xC7, 0x86],
            [0x36, 0x48],
            [0x3A, 0x55],
            [0xB1, 0x00,0x18],
            [0xB6, 0x08,0x82,0x27],
            [0xF2, 0x00],
            [0x26, 0x01],
            [0xE0, 0x0F,0x31,0x2B,0x0C,0x0E,0x08,0x4E,0xF1,0x37,0x07,0x10,0x03,0x0E,0x09,0x00],
            [0xE1, 0x00,0x0E,0x14,0x03,0x11,0x07,0x31,0xC1,0x48,0x08,0x0F,0x0C,0x31,0x36,0x0F],
            [0x11],
            [0x29],
            [0x36, 0x0],
            [0x2A, 0],
            [0x2B, 0],
            [0x2C]
]

def print_item(index, rs, val):
    print("if (init_sequence_counter == {}) begin".format(index))
    print("    reg_lcd_rs   <= 1'b{};".format("1" if rs else "0"))
    print("    reg_lcd_data <= 8'h{:02x};".format(val))
    print("    reg_lcd_wr   <= 1'b1;")
    print("end else ", end="")


counter = 0
for index in range(len(data)):
    cmd = data[index][0]
    par = data[index][1:]
    print_item(counter, False, cmd)
    counter += 1
    for x in par:
        print_item(counter, True, x)
        counter += 1
