package ALU;
    typedef enum{Mul,Div,Add,Sub,And,Or} AluOps deriving (Eq, Bits);

    interface HelloALU;
        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
        method ActionValue#(Int#(32)) getResult();
    endinterface

    module mkSimpleALU(HelloALU);
        Reg#(Bool)      resultReady <- mkReg(False);
        Reg#(AluOps)    alu         <- mkReg(Mul);
        Reg#(Int#(32))  op1         <- mkReg(0);
        Reg#(Int#(32))  op2         <- mkReg(0);
        Reg#(Int#(32))  res         <- mkReg(0);
        
        rule rl_print_answer if(!resultReady);
            case(alu)
                Mul: res <= op1 * op2;
                Div: res <= op1 / op2;
                Add: res <= op1 + op2;
                Sub: res <= op1 - op2;
                And: res <= op1 & op2;
                Or:  res <= op1 | op2;
            endcase
            resultReady <= True;
        endrule

        method ActionValue#(Int#(32)) getResult() if(resultReady);
            return res;
        endmethod

        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
            resultReady <= False;
            alu <= op;
            op1 <= a;
            op2 <= b;
        endmethod
        

    endmodule
endpackage : ALU
