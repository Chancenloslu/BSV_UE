package ALUFSMTb;

import StmtFSM :: *;
import ALU :: *;
import Vector::*;

    typedef struct {
    Int#(32) opA;
    Int#(32) opB;
    AluOps operator;
    Int#(32) expectedResult;
    } TestData deriving (Eq, Bits);

    module mkALUTb(Empty);

        Vector#(6, TestData) myVector;
        myVector[0] = TestData {opA: 2, opB: 4, operator: Add, expectedResult: 6};
        myVector[1] = TestData {opA: 2, opB: 4, operator: Sub, expectedResult: -2};
        myVector[2] = TestData {opA: 4, opB: 2, operator: Div, expectedResult: 2};
        myVector[3] = TestData {opA: 4, opB: 2, operator: Mul, expectedResult: 8};
        myVector[4] = TestData {opA: 10, opB: 2, operator: Or, expectedResult: 10};
        myVector[5] = TestData {opA: 4, opB: 2, operator: And, expectedResult: 0};
        HelloALU alu <- mkSimpleALU;
        Reg#(UInt#(32)) i <- mkRegU;
        Reg#(Int#(32)) out <- mkRegU;
        Stmt s = 
        seq
            for(i<=0; i<6; i<=i+1) seq
                /*
                 * conclusion: the whole action executes in one cycle
                 */
                action
                    alu.setupCalculation(myVector[i].operator, myVector[i].opA, myVector[i].opB);
                endaction
            
                action
                    let t <- alu.getResult();
                    if(t == myVector[i].expectedResult)
                        $display("test %d succeeded.", i);
                    else
                        $display("test %d failed. expected %d, got %d", i, myVector[i].expectedResult, t);
                endaction
            endseq
            
        endseq;

        mkAutoFSM(s);
    endmodule
endpackage : ALUFSMTb