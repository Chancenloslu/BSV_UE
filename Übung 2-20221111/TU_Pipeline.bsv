package TU_Pipeline;

import FIFO :: *;
import FIFOF :: *;
import Vector :: *;
import CalcUnits :: *;

    interface TU_Pipeline;
        interface CalcUnits calc;
        method Action setParam(UInt#(2)addr, SignedOrUnsigned param);
    endinterface
/*
module mkTU_Pipeline(TU_Pipeline);
CalcUnitChangeable stage1 <- mkAdda;
CalcUnitChangeable stage2 <- mkMUlbc;
CalcUnitChangeable stage3 <- mkMUlbc;
CalcUnits stage4 <- mkDiv4;
CalcUnits stage5 <- mkAdd128;
Vector#(3, CalcUnitChangeable) changeables;
changeables[0] = stage1;
changeables[1] = stage2;
changeables[2] = stage3;
Vector#(5, CalcUnits) stages;
stages[0] = stage1.calc;
stages[1] = stage2.calc;
stages[2] = stage3.calc;
stages[3] = stage4;
stages[4] = stage5;
Vector#(6, FIFO#(SignedOrUnsigned)) fifos <- replicateM(mkSizedFIFO(2));
for(Integer i = 0; i < 5; i = i + 1) begin
rule push;
stages[i].put(fifos[i].first);
fifos[i].deq;
endrule
end
for(Integer i = 1; i < 6; i = i + 1) begin
rule pull;
let t <- stages[i-1].result();
fifos[i].enq(t);
endrule
end
method Action setParam(UInt#(2) addr, SignedOrUnsigned val);
changeables[addr].setParameter(val);
endmethod
    interface CalcUnits calc;
    method Action put(SignedOrUnsigned x);
    fifos[0].enq(x);
    endmethod
        method ActionValue#(SignedOrUnsigned) result();
        let res = fifos[5].first();
        fifos[5].deq;
        return res;
        endmethod
    endinterface
endmodule
*/

    module mkTU_Pipeline(TU_Pipeline);
        CalcUnitChangeable stage1 <- mkAdda;
        CalcUnitChangeable stage2 <- mkMUlbc;
        CalcUnitChangeable stage3 <- mkMUlbc;
        CalcUnits stage4 <- mkDiv4;
        CalcUnits stage5 <- mkAdd128;

        Vector#(5, CalcUnits) stages;
        stages[0] = stage1.calc;
        stages[1] = stage2.calc;
        stages[2] = stage3.calc;
        stages[3] = stage4;
        stages[4] = stage5;


        FIFOF#(SignedOrUnsigned) fifo_in <- mkFIFOF;
        FIFO#(SignedOrUnsigned) fifo_out <- mkFIFO;
        Vector#(4, Array#(Reg#(Maybe#(SignedOrUnsigned)))) regSets <- replicateM(mkCReg(2, tagged Invalid));
        
        rule s1_pull if(fifo_in.notEmpty);
            stages[0].put(fifo_in.first);
            fifo_in.deq;
        endrule

        rule s5_push;
            let t <- stages[4].result();
            fifo_out.enq(t);
        endrule

        for(int i=0; i<4;i=i+1) begin
            rule pull (regSets[i][0] matches tagged Valid .x);
                regSets[i][0] <= tagged Invalid;
                stages[i+1].put(x);
            endrule
        end

        for(int i=0; i<4; i = i+1) begin
            rule push (regSets[i][1] matches tagged Invalid);
                //regSets[i-1][0] <= tagged Invalid;
                let t <- stages[i].result();
                regSets[i][1]<=tagged Valid t;
            endrule
        end
        
        method Action setParam(UInt#(2)addr, SignedOrUnsigned param);
            case (addr)
                0: stage1.setParameter(param); 
                1: stage2.setParameter(param);
                2: stage3.setParameter(param);
            endcase
        endmethod
        interface CalcUnits calc;
            method Action put(SignedOrUnsigned x);
                fifo_in.enq(x);
            endmethod
            method ActionValue#(SignedOrUnsigned) result();
                fifo_out.deq();
                return fifo_out.first();
            endmethod
        endinterface

    endmodule

endpackage : TU_Pipeline
