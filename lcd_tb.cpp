#include <cstdint>
#include "Vlcd.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
int main(int argc, char **argv, char **env)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    Vlcd* lcd = new Vlcd;
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    lcd->trace(m_trace, 99);
    m_trace->open("../trace.vcd");
    uint64_t clk = 0;
    while ((!Verilated::gotFinish()) && (clk < 16000000)) {
        lcd->i_clk = clk & 1;
        lcd->eval();
        m_trace->dump(clk);

        if (clk & 1) printf("%08u %s %s %02x\n", clk, lcd->o_lcd_wr ? "H" : "L", lcd->o_lcd_rs ? "D" : "C", lcd->o_lcd_data);
        clk++;
    }
    m_trace->close();
    delete lcd;
    exit(0);
}
