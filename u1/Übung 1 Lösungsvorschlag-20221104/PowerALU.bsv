package PowerALU;

typedef enum{Mul,Div,Add,Sub,And,Or,Pow} AluOps deriving (Eq, Bits);

interface Power;
    method Action   setOperands(Int#(32) a, Int#(32) b);
    method Int#(32) getResult();
endinterface

module mkPower(Power);
    Reg#(Bool) resultValid <- mkReg(False);
    Reg#(Int#(32)) opA    <- mkReg(0);
    Reg#(Int#(32)) opB    <- mkReg(0);
    Reg#(Int#(32)) result <- mkReg(1);

    rule calc (opB > 0);
        opB <= opB - 1;
        result <= result * opA;
    endrule

    rule calcDone (opB == 0 && !resultValid);
        resultValid <= True;
    endrule

    method Action setOperands(Int#(32) a, Int#(32) b);
        result <= 1;
        opA    <= a;
        opB    <= b;
        resultValid <= False;
    endmethod

    method Int#(32) getResult() if(resultValid);
        return result;
    endmethod
endmodule

interface HelloALU;
    method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
    method ActionValue#(Int#(32))  getResult();
endinterface

module mkHelloALU(HelloALU);
    Reg#(Bool) newOperands <- mkReg(False);
    Reg#(Bool) resultValid <- mkReg(False);
    Reg#(AluOps) operation <- mkReg(Mul);
    Reg#(Int#(32)) opA    <- mkReg(0);
    Reg#(Int#(32)) opB    <- mkReg(0);
    Reg#(Int#(32)) result <- mkReg(0);

    Power pow             <- mkPower();

    rule calculate (newOperands);
        Int#(32) rTmp = 0;
        case(operation)
            Mul: rTmp = opA * opB;
            Div: rTmp = opA / opB;
            Add: rTmp = opA + opB;
            Sub: rTmp = opA - opB;
            And: rTmp = opA & opB;
            Or:  rTmp = opA | opB;
            Pow: rTmp = pow.getResult();
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
        if(op == Pow) pow.setOperands(a,b);
    endmethod

    method ActionValue#(Int#(32)) getResult() if(resultValid);
        resultValid <= False;
        return result;
    endmethod
endmodule

module mkALUTestbench(Empty);
    HelloALU uut             <- mkHelloALU();
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
        uut.setupCalculation(Or, 32'hA,32'hA);
        testState <= testState + 1;
    endrule

    rule checkPow (testState == 12);
        uut.setupCalculation(Pow, 2, 12);
        testState <= testState + 1;
    endrule

    rule printResults (unpack(pack(testState)[0]));
        $display("Result: %d", uut.getResult());
        testState <= testState + 1;
    endrule

    rule endSim (testState == 14);
        $finish();
    endrule
endmodule
endpackage