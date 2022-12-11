package ALU;
    typedef enum{Mul,Div,Add,Sub,And,Or} AluOps deriving (Eq, Bits);
    typedef union tagged {UInt#(32) Unsigned; Int#(32) Signed;} SignedOrUnsigned deriving(Bits, Eq);

    interface HelloALU;
        method Action setupCalculation(AluOps op, SignedOrUnsigned a, SignedOrUnsigned b);
        method ActionValue#(SignedOrUnsigned) getResult();
    endinterface

    module mkSimpleALU(HelloALU);
        Reg#(Bool)      resultReady <- mkReg(False);
        Reg#(AluOps)    alu         <- mkReg(Mul);
        Reg#(SignedOrUnsigned)  op1 <- mkRegU;
        Reg#(SignedOrUnsigned)  op2 <- mkRegU;
        Reg#(SignedOrUnsigned)  res <- mkRegU;

        rule alu_Signed if(op1 matches tagged Signed .a &&& op2 matches tagged Signed .b &&& !resultReady);
            Int#(32) temp = 0;
            case(alu)
                Mul: temp = a * b;
                Div: temp = a / b;
                Add: temp = a + b;
                Sub: temp = a - b;
                And: temp = a & b;
                Or:  temp = a | b;
            endcase
            res <= tagged Signed temp;
            resultReady <= True;
        endrule
        rule alu_Unsigned if(op1 matches tagged Unsigned .a &&& op2 matches tagged Unsigned .b &&& !resultReady);
            UInt#(32) temp = 0;
            case(alu)
                Mul: temp = a * b;
                Div: temp = a / b;
                Add: temp = a + b;
                Sub: temp = a - b;
                And: temp = a & b;
                Or:  temp = a | b;
            endcase
            res <= tagged Unsigned temp;
            resultReady <= True;
        endrule

        method ActionValue#(SignedOrUnsigned) getResult() if(resultReady);
            return res;
        endmethod

        method Action setupCalculation(AluOps op, SignedOrUnsigned a, SignedOrUnsigned b);
            resultReady <= False;
            alu <= op;
            op1 <= a;
            op2 <= b;
        endmethod
    endmodule

    module mkTb(Empty); 
        HelloALU uut <- mkSimpleALU();
        Reg#(UInt#(8)) testState <- mkReg(0);
        rule checkMul (testState == 0);
            uut.setupCalculation(Mul, tagged Unsigned 4, tagged Unsigned 5);
            testState <= testState + 1;
        endrule
rule checkDiv (testState == 2);
uut.setupCalculation(Div, tagged Unsigned 12,tagged Unsigned 4);
testState <= testState + 1;
endrule
rule checkAdd (testState == 4);
uut.setupCalculation(Add, tagged Unsigned 12, tagged Unsigned 4);
testState <= testState + 1;
endrule
rule checkSub (testState == 6);
uut.setupCalculation(Sub, tagged Signed 4, tagged Signed 12);
testState <= testState + 1;
endrule

rule printResults (unpack(pack(testState)[0]));
let result <- uut.getResult();
if (result matches tagged Signed .r) begin
$display("Result (Signed): %d", r);
end else if (result matches tagged Unsigned .r) begin
$display("Result (Unsigned): %d", r);
end
testState <= testState + 1;
endrule
rule endSim (testState == 8);
$finish();
endrule
    endmodule
endpackage : ALU
