package U2;

    interface CalcUnit;
      method Action put(Int#(32) x);
      method ActionValue#(Int#(32)) result();
    endinterface

    interface CalcUnitChangeable;
      interface CalcUnit calc;
      method Action setParameter(Int#(32) param);
    endinterface

    interface Pipeline;
      interface CalcUnit calc;
      method Action setParam(UInt#(2) addr, Int#(32) val);
    endinterface

    module mkSimplePipeline(Pipeline);
      Reg#(Int#(32)) reg1 <- mkRegU;
      Reg#(Int#(32)) reg2 <- mkRegU;
      Reg#(Int#(32)) reg3 <- mkRegU;
      Reg#(Int#(32)) reg4 <- mkRegU;
      FIFO#(Int) input <- mkFIFO;
      FIFO#(Int) output <- mkFIFO;

      method Action setParam(UInt#(2) addr, Int#(32) val);
          
      endmethod
    
    endmodule
endpackage