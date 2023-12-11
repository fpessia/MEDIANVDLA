#include <stdlib.h>
#include <iostream>
#include <verilated.h>
//#include <verilated_vdc_c.h>
#include "obj_dir/VTestBench.h"


#define MAX_TIME 20
vluint64_t sim_time = 0;


int main(int argc, const char **argv, char **env){
    VTestBench *dut = new VTestBench;
    int inputs[] = {10,14,-122,15,16,17,18,19,20,21,22,23};
    int i = 0;
    dut->rst = 0;
    dut->clk = 0;
    dut->data0 = inputs[i];
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
        if (dut->clk == 0){
           i++;
           dut->data0  = inputs[i]; 
        }
        sim_time++;
    }

//m_trace ->close();
delete dut;
exit(EXIT_SUCCESS);
    

}