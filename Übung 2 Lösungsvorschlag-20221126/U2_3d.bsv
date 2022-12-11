package U2_3d;

import FIFO::*;
import FIFOF::*;
import Vector::*;

interface CalcUnit;
  method Action put(Int#(32) x);
  method ActionValue#(Int#(32)) result();
endinterface

interface CalcUnitChangeable;
  interface CalcUnit calc;
  method Action setParameter(Int#(32) param);
endinterface

module mkAddA(CalcUnitChangeable);
    Reg#(Int#(32)) a <- mkRegU;
    Wire#(Int#(32)) in <- mkWire;

    method Action setParameter(Int#(32) param);
        a <= param;
    endmethod

    interface CalcUnit calc;
        method Action put(Int#(32) x);
            in <= x;
        endmethod
      
        method ActionValue#(Int#(32)) result();
            noAction;
            return in + a;
        endmethod
    endinterface
endmodule

module mkMul(CalcUnitChangeable);
    Reg#(Int#(32)) b <- mkRegU; // or c
    Wire#(Int#(32)) in <- mkWire;

    method Action setParameter(Int#(32) param);
        b <= param;
    endmethod

    interface CalcUnit calc;
        method Action put(Int#(32) x);
            in <= x;
        endmethod
      
        method ActionValue#(Int#(32)) result();
            noAction;
            return in * b;
        endmethod
    endinterface
endmodule

module mkDiv4(CalcUnit);
    Wire#(Int#(32)) in <- mkWire;

    method Action put(Int#(32) x);
        in <= x;
    endmethod
  
    method ActionValue#(Int#(32)) result();
        noAction;
        return in / 4; // alternatively >> 2
    endmethod
endmodule

module mkAdd128(CalcUnit);
    Wire#(Int#(32)) in <- mkWire;

    method Action put(Int#(32) x);
        in <= x;
    endmethod
  
    method ActionValue#(Int#(32)) result();
        noAction;
        return in + 128;
    endmethod
endmodule

// Alternative multiply implementation which requires a variable amount of cycles
module mkMulVariable(CalcUnitChangeable);
    Reg#(Int#(32)) p <- mkRegU;
    Reg#(Int#(32)) a <- mkRegU;
    Reg#(Int#(32)) b <- mkRegU;
    Reg#(Int#(32)) w <- mkRegU;
    Reg#(Bool) got_in <- mkReg(False);

    rule compute (b != 0 && got_in);
        if (lsb(b) == 1) w <= w + a;
        a <= a << 1;
        b <= b >> 1;
    endrule

    method Action setParameter(Int#(32) param);
        p <= param;
    endmethod

    interface CalcUnit calc;
        method Action put(Int#(32) x) if (!got_in);
            a <= x;
            b <= p;
            w <= 0;
            got_in <= True;
        endmethod
      
        method ActionValue#(Int#(32)) result() if (b == 0 && got_in);
            got_in <= False;
            return w;
        endmethod
    endinterface
endmodule

interface Pipeline;
    interface CalcUnit calc;
    method Action setParam(UInt#(2) addr, Int#(32) val);
endinterface


module mkPipeline(Pipeline);
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

    Vector#(6, FIFOF#(Int#(32))) fifos <- replicateM(mkSizedFIFOF(2));
    function Bool fempty(FIFOF#(_) f) = !f.notEmpty;
    function setParamAllowed();
        Bool allDone = True;
        for(Integer i = 0; i < 3; i = i + 1) allDone = allDone && fempty(fifos[i]);
        return allDone;
    endfunction

    for(Integer i = 0; i < 5; i = i + 1) begin
        rule push;
            stages[i].put(fifos[i].first);
        endrule
    end

    for(Integer i = 1; i < 6; i = i + 1) begin
        rule pull;
            fifos[i-1].deq;
            let t <- stages[i-1].result();
            fifos[i].enq(t);
        endrule
    end

    method Action setParam(UInt#(2) addr, Int#(32) val) if(setParamAllowed());
        changeables[addr].setParameter(val);
    endmethod

    interface CalcUnit calc;
        method Action put(Int#(32) x);
            fifos[0].enq(x);
        endmethod

        method ActionValue#(Int#(32)) result();
            let res = fifos[5].first();
            fifos[5].deq;
            return res;
        endmethod
    endinterface
endmodule

endpackage