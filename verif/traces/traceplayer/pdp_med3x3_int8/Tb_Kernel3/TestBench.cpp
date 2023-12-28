#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include "obj_dir/VTestBench.h"


#define MAX_TIME 10
vluint64_t sim_time = 0;


int main(int argc, const char **argv, char **env){
    VTestBench *dut = new VTestBench;
    dut->rst = 0;
    dut->clk = 0;
    //m_trace->dump(sim_time);
    sim_time ++;
    dut->rst = 1;
    sim_time++;
    //m_trace->dump(sim_time);
    while (sim_time < MAX_TIME)
    {
        dut->clk^=1;
        dut->rst = 0;
        dut->eval();
        sim_time++;
    }

//m_trace ->close();
delete dut;
exit(EXIT_SUCCESS);
    

}