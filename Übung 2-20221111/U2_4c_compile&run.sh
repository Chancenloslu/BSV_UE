#!/bin/bash -e
bsc -u -sim -g mkTU_Pipeline TU_Pipeline.bsv
bsc -u -sim -g mkCustomTest CustomTest.bsv
bsc -u -sim -g mkTestbench U2_4c_Testbench.bsv
bsc -u -sim -e mkTestbench -o U2_4c_Testbench
echo -e "\n************ start running ***********\n"
./U2_4c_Testbench