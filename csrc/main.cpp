#include "Vicb_slave_tb.h"
#include <verilated.h>

#if VM_TRACE
#include <verilated_vcd_c.h>
#endif

vluint64_t simtime = 0;       // Current simulation time

double sc_time_stamp () {       // Called by $time in Verilog
	return simtime;       // converts to double, to match
				// what SystemC does
}

int main(int argc, char **argv, char **env) {
	Verilated::commandArgs(argc, argv);
	Vicb_slave_tb* top = new Vicb_slave_tb;
	int cnt = 0;
	simtime = 0;

#if VM_TRACE
	Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
#if VCDTRACE
	top->trace (tfp, 99);
        tfp->open ("dump.vcd");
#endif
#endif

	// reset
	top->clk = 0;
	top->eval();
// #if VM_TRACE && VCDTRACE
// 	tfp->dump(simtime);
// #endif
// 	simtime++;
// 	top->rst_n = 0;
// 	top->eval();
// #if VM_TRACE && VCDTRACE
// 	tfp->dump(simtime);
// #endif
// 	simtime++;
// 	top->rst_n = 0;
// 	top->eval();
// #if VM_TRACE && VCDTRACE
// 	tfp->dump(simtime);
// #endif
	simtime++;

	while (!Verilated::gotFinish() && cnt < (1 << 22)) {

		if (simtime % 2 == 0) {
			top->clk = !top->clk;
		}
		top->eval();
#if VM_TRACE && VCDTRACE
		tfp->dump(simtime);
#endif
		simtime++;
		cnt++;
	}
	delete top;

#if VM_TRACE
#if VCDTRACE
	tfp->close();
#endif
	delete tfp;
#endif

	if (!Verilated::gotFinish()) {
		printf("Simulation time out! Forced stop ...\n");
		return 1;
	} else {
#if VM_COVERAGE
		VerilatedCov::write("coverage.dat");
#endif // VM_COVERAGE
		return 0;
	}
}