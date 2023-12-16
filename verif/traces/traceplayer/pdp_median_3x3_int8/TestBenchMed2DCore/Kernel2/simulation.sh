rm -rf obj_dir
#/usr/local/bin/verilator -DNO_PLI_OR_EMU -DNO_PLI -DDESIGNWARE_NOEXIST -DSYNTHESIS -Wno-moddup -cc TestBench.v --Mdir ./outdir --exe TestBench --timing
verilator -cc TestBench.v -Wno-UNOPTFLAT  --timing
verilator -I/usr/local/share/verilator/include -Wall --trace --exe --build -cc TestBench.cpp TestBench.v 
clear
./obj_dir/VTestBench




