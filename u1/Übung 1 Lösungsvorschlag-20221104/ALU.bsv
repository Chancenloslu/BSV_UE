package ALU;

    typedef enum{Mul,Div,Add,Sub,And,Or,Pow} AluOps deriving (Eq, Bits);

    interface HelloALU;
        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
        method ActionValue#(Int#(32))  getResult();
    endinterface

    module mkSimpleALU(HelloALU);
        Reg#(Bool) newOperands <- mkReg(False);
        Reg#(Bool) resultValid <- mkReg(False);
        Reg#(AluOps) operation <- mkReg(Mul);
        Reg#(Int#(32)) opA    <- mkReg(0);
        Reg#(Int#(32)) opB    <- mkReg(0);
        Reg#(Int#(32)) result <- mkReg(0);

        rule calculate (newOperands && !resultValid);
            Int#(32) rTmp = 0;
            case(operation)
                Mul: rTmp = opA * opB;
                Div: rTmp = opA / opB;
                Add: rTmp = opA + opB;
                Sub: rTmp = opA - opB;
                And: rTmp = opA & opB;
                Or:  rTmp = opA | opB;
            endcase
            result <= rTmp;
            newOperands <= False;
            resultValid <= True;
        endrule

        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b) if(!newOperands);
            opA <= a;
            opB <= b;
            operation <= op;
            newOperands <= True;
            resultValid <= False;
        endmethod

        method ActionValue#(Int#(32)) getResult() if(resultValid);
            resultValid <= False;
            return result;
        endmethod
    endmodule

    module mkALUTestbench(Empty);
        HelloALU uut             <- mkSimpleALU();
        Reg#(UInt#(8)) testState <- mkReg(0);

        rule checkMul (testState == 0);
            uut.setupCalculation(Mul, 4,5);
            testState <= testState + 1;
        endrule

        rule checkDiv (testState == 2);
            uut.setupCalculation(Div, 12,4);
            testState <= testState + 1;
        endrule

        rule checkAdd (testState == 4);
            uut.setupCalculation(Add, 12,4);
            testState <= testState + 1;
        endrule
        
        rule checkSub (testState == 6);
            uut.setupCalculation(Sub, 12,4);
            testState <= testState + 1;
        endrule

        rule checkAnd (testState == 8);
            uut.setupCalculation(And, 32'hA,32'hA);
            testState <= testState + 1;
        endrule

        rule checkOr (testState == 10);
            uut.setupCalculation(Or, 32'hA,32'hB);
            testState <= testState + 1;
        endrule

        rule printResults (unpack(pack(testState)[0]));
            $display("Result: %d", uut.getResult());
            testState <= testState + 1;
        endrule

        rule endSim (testState == 12);
            $finish();
        endrule
    endmodule


endpackage