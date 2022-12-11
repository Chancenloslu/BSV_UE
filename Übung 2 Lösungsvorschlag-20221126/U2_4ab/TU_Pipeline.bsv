package TU_Pipeline;

import FIFO::*;
import Vector::*;
import CalcUnits::*;


interface TU_Pipeline;
    interface CalcUnit calc;
    method Action setParam(UInt#(2) addr, SignedOrUnsigned val);
endinterface


module mkTU_Pipeline(TU_Pipeline);
    CalcUnitChangeable stage1 <- mkAddA;
    CalcUnitChangeable stage2 <- mkMul;
    CalcUnitChangeable stage3 <- mkMul;
    CalcUnit stage4 <- mkDiv4;
    CalcUnit stage5 <- mkAdd128;

    Vector#(3, CalcUnitChangeable) changeables;
    changeables[0] = stage1;
    changeables[1] = stage2;
    changeables[2] = stage3;

    Vector#(5, CalcUnit) stages;
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

    interface CalcUnit calc;
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

endpackage
