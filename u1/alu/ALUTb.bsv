package  ALUTb;
    import ALU :: *;
    module mkALUTb(Empty);
        HelloALU dut <- mkSimpleALU;
        /*
         * conclusion: it is not possible to run all of these statements in only one Clk cycle
         */
        /*rule check;
            dut.setupCalculation(Mul, 4, 5);
            $display ("result is %d.", dut.getResult());
            dut.setupCalculation(Div, 10, 5);
            $display ("result is %d.", dut.getResult());
            dut.setupCalculation(Add, 4, 5);
            $display ("result is %d.", dut.getResult());
            dut.setupCalculation(Sub, 4, 5);
            $display ("result is %d.", dut.getResult());
            dut.setupCalculation(And, 4, 5);
            $display ("result is %d.", dut.getResult());
            dut.setupCalculation(Or, 4, 5);
            $display ("result is %d.", dut.getResult());
            $finish();
        endrule : check*/
        
        
        Reg#(Int#(8)) testState <- mkReg(0);
        //AluOps op = `OP;
        rule checkMul (testState == 0);
            dut.setupCalculation(Mul, 4, 5);
            $display ("result is %d.", dut.getResult());
            testState <= testState + 1;
        endrule

        rule checkDiv (testState == 2);
            dut.setupCalculation(Div, 10, 5);
            $display ("result is %d.", dut.getResult());
            testState <= testState + 1;
        endrule

        rule checkAdd (testState == 4);
            dut.setupCalculation(Add, 12,4);
            $display ("result is %d.", dut.getResult());
            testState <= testState + 1;
        endrule
        rule checkSub (testState == 6);
            dut.setupCalculation(Sub, 12,4);
            $display ("result is %d.", dut.getResult());
            testState <= testState + 1;
        endrule
        rule checkAnd (testState == 8);
            dut.setupCalculation(And, 32'hA,32'hA);
            $display ("result is %d.", dut.getResult());
            testState <= testState + 1;
        endrule
        rule checkOr (testState == 10);
            dut.setupCalculation(Or, 32'hA,32'hB);
            $display ("result is %d.", dut.getResult());
            testState <= testState + 1;
        endrule

        rule printResult(unpack(pack(testState)[0])); //testState -> (pack)Bit# -> 0th bit -> (unpack)Bool#
            $display ("result is %d.", dut.getResult());
            testState <= testState + 1;
        endrule

        rule endSim(testState == 12);
            $finish();
        endrule
    endmodule
endpackage :  ALUTb
