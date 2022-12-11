package U2_6;
typedef enum {Mul,Div,Add,Sub,And,Or,Pow} AluOps deriving (Eq, Bits);
typedef union tagged {UInt#(32) Unsigned; Int#(32) Signed;} SignedOrUnsigned deriving(Bits, Eq);

interface Power;
    method Action   setOperands(SignedOrUnsigned a, SignedOrUnsigned b);
    method Int#(32) getResultSigned();
    method UInt#(32) getResultUnsigned();
endinterface

module mkPower(Power);
    Reg#(Bool) resultValid <- mkReg(False);

    Reg#(SignedOrUnsigned) opA    <- mkRegU;
    Reg#(SignedOrUnsigned) opB    <- mkRegU;
    Reg#(Int#(32)) result_signed <- mkReg(1);
    Reg#(UInt#(32)) result_unsigned <- mkReg(1);

    rule calc (pack(opB)[31:0] > 0);
        Bit#(33) b_opB = pack(opB);
        opB <= unpack({b_opB[32], b_opB[31:0] - 1});
        result_signed <= result_signed * unpack(pack(opA)[31:0]);
        result_unsigned <= result_unsigned * unpack(pack(opA)[31:0]);
    endrule

    rule calcDone (pack(opB)[31:0] == 0 && !resultValid);
        resultValid <= True;
    endrule

    method Action setOperands(SignedOrUnsigned a, SignedOrUnsigned b);
        result_signed <= 1;
        result_unsigned <= 1;
        opA    <= a;
        opB    <= b;
        resultValid <= False;
    endmethod

    method Int#(32) getResultSigned() if(resultValid);
        return result_signed;
    endmethod

    method UInt#(32) getResultUnsigned() if(resultValid);
      return result_unsigned;
  endmethod
endmodule

interface HelloALU;
    method Action setupCalculation(AluOps op, SignedOrUnsigned a, SignedOrUnsigned b);
    method ActionValue#(SignedOrUnsigned)  getResult();
endinterface

module mkHelloALU(HelloALU);
    Reg#(Bool) newOperands <- mkReg(False);
    Reg#(Bool) resultValid <- mkReg(False);
    Reg#(AluOps) operation <- mkReg(Mul);
    Reg#(SignedOrUnsigned) opA    <- mkReg(tagged Signed 0);
    Reg#(SignedOrUnsigned) opB    <- mkReg(tagged Signed 0);
    Reg#(SignedOrUnsigned) result <- mkReg(tagged Signed 0);

    Power pow <- mkPower();

    rule calculateSigned (opA matches tagged Signed .va &&& opB matches tagged Signed .vb &&& newOperands);
            Int#(32) rTmp = 0;
            case(operation)
                Mul: rTmp = va * vb;
                Div: rTmp = va / vb;
                Add: rTmp = va + vb;
                Sub: rTmp = va - vb;
                And: rTmp = va & vb;
                Or:  rTmp = va | vb;
                Pow: rTmp = pow.getResultSigned();
            endcase
            result <= tagged Signed rTmp;
            newOperands <= False;
            resultValid <= True;
    endrule

    rule calculateUnsigned (opA matches tagged Unsigned .va &&& opB matches tagged Unsigned .vb &&& newOperands);
            UInt#(32) rTmp = 0;
            case(operation)
                Mul: rTmp = va * vb;
                Div: rTmp = va / vb;
                Add: rTmp = va + vb;
                Sub: rTmp = va - vb;
                And: rTmp = va & vb;
                Or:  rTmp = va | vb;
                Pow: rTmp = pow.getResultUnsigned();
            endcase
            result <= tagged Unsigned rTmp;
            newOperands <= False;
            resultValid <= True;
    endrule

    function Bool isUnsigned(SignedOrUnsigned v);
        if(v matches tagged Unsigned .va) return True;
        else return False;
    endfunction

    rule dumpInvalid (newOperands && isUnsigned(opA) != isUnsigned(opB));
        $display("Invalid combination of Signed and Unsigned Operands");
        newOperands <= False;
        resultValid <= False;
    endrule

    method Action setupCalculation(AluOps op, SignedOrUnsigned a, SignedOrUnsigned b) if(!newOperands);
        opA <= a;
        opB <= b;
        operation <= op;
        newOperands <= True;
        resultValid <= False;
        if(op == Pow) begin
            pow.setOperands(a, b);
        end 
    endmethod

    method ActionValue#(SignedOrUnsigned) getResult() if(resultValid);
        resultValid <= False;
        return result;
    endmethod
endmodule

module mkALUTestbench(Empty);
    HelloALU uut             <- mkHelloALU();
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
        uut.setupCalculation(Sub, tagged Unsigned 12, tagged Unsigned 4);
        testState <= testState + 1;
    endrule

    rule checkAnd (testState == 8);
        uut.setupCalculation(And, tagged Unsigned 32'hA, tagged Unsigned 32'hA);
        testState <= testState + 1;
    endrule

    rule checkOr (testState == 10);
        uut.setupCalculation(Or, tagged Unsigned 32'hA, tagged Unsigned 32'hA);
        testState <= testState + 1;
    endrule

    rule checkPow (testState == 12);
        uut.setupCalculation(Pow, tagged Unsigned 2, tagged Unsigned 12);
        testState <= testState + 1;
    endrule

    rule checkMulSigned (testState == 14);
        uut.setupCalculation(Mul, tagged Signed 4, tagged Signed -5);
        testState <= testState + 1;
    endrule

    rule checkDivSigned (testState == 16);
        uut.setupCalculation(Div, tagged Signed -12,tagged Signed -4);
        testState <= testState + 1;
    endrule

    rule checkAddSigned (testState == 18);
        uut.setupCalculation(Add, tagged Signed -12, tagged Signed 4);
        testState <= testState + 1;
    endrule
    
    rule checkSubSigned (testState == 20);
        uut.setupCalculation(Sub, tagged Signed 12, tagged Signed -4);
        testState <= testState + 1;
    endrule

    rule checkAndSigned (testState == 22);
        uut.setupCalculation(And, tagged Signed 32'hA, tagged Signed 32'hA);
        testState <= testState + 1;
    endrule

    rule checkOrSigned (testState == 24);
        uut.setupCalculation(Or, tagged Signed 32'hA, tagged Signed 32'hA);
        testState <= testState + 1;
    endrule

    rule checkPowSigned (testState == 26);
        uut.setupCalculation(Pow, tagged Signed -2, tagged Signed 11);
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

    rule endSim (testState == 28);
        $finish();
    endrule
endmodule
endpackage
