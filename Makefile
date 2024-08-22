# include $(UVM_HOME)/examples/Makefile.vcs

UVM_TESTNAME := test0

COVER := 0

ifeq ($(COVER), 1)
VCS_FLAGS_COVER = -cm line+cond+fsm+tgl+branch
SIM_FLAGS_COVER = -cm line+cond+fsm+tgl+branch
endif

# 编译选项
VCSDIY = vcs
VCS_FLAGS = -sverilog +v2k $(VCS_FLAGS_COVER) -debug_all +define+SVA+ASSERT_ON -fsdb -l com.log +define+A


# 仿真选项
SIM = ./simv $(VCS_FLAGS_COVER) +fsdb+sva_success
SIM_FLAGS =

# 默认目标
all: xrun 

generate:
	python ./utils/conv_test.py
# 编译目标
sim: generate compile
	$(SIM) $(SIM_FLAGS) -l sim.log

verilator:	
	@verilator $(if $(cflags),-CFLAGS $(cflags)) --cc --trace --exe --build -j --timing csrc/*  tb/icb_slave_tb.sv rtl/* bn/*  --top-module icb_slave_tb --Wno-fatal -Wno-WIDTH -Wno-UNOPTFLAT -Wno-CASEINCOMPLETE -Wno-LITENDIAN
	@cd obj_dir/ && ./Vicb_slave_tb

xrun: generate
	xrun -f filelist.f -sv -access +rwc -svseed random -sva -input run.tcl

indago:
	indago -db SmartLogWaves.db

compile: filelist.f
	$(VCSDIY) $(VCS_FLAGS) -o $(SIM) -f $^

uvm: filelist.f
	$(VCS) +incdir+../sV \
		-f $^

run: uvm
	$(SIMV) +UVM_TESTNAME=$(UVM_TESTNAME)
	$(CHECK)

dve: sim
	dve -vpd vcdplus.vpd &

cover:
	urg -dir simv.vdb -format both -report cover
	dve -cov -dir simv.vdb &

verdi:
	verdi  -f filelist.f -ssf test.fsdb &

find:
	rm -f filelist.f
	find -name "*.sv" >> filelist.f
	find -name "*.v" >> filelist.f

# 清理目标、uvm环境中已有
clean:
	rm -rf *~ core obj_dir simv* vc_hdrs.h ucli.key urg* *.log cover *.fsdb *.vpd DVEfiles transcript .ida* .indago* *.db indago* *.d xrun* novas.*

.PHONY: all sim compile dve verdi clean find
