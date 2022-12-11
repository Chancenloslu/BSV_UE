package U2_3;
    import FIFOF :: *;
    import FIFO ::*;
    typedef enum {A=0, B=1, C=2} InputParam deriving (Eq, Bits);

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
      //oder Vector#(4. Reg#(Maybe#(Int#(32)))) regs <- replicateM(mkReg(taaged Invalid))
      // in BSV Vector wird ofter verwendet als Array
      Reg#(Maybe#(Int#(32))) reg1 <- mkReg(tagged Invalid);
      Reg#(Maybe#(Int#(32))) reg2 <- mkReg(tagged Invalid);
      Reg#(Maybe#(Int#(32))) reg3 <- mkReg(tagged Invalid);
      Reg#(Maybe#(Int#(32))) reg4 <- mkReg(tagged Invalid);

      FIFOF#(Int#(32)) fifo_in  <- mkFIFOF; //FIFOF hat 2 methode notEmpty notFull
      FIFOF#(Int#(32)) fifo_out <- mkFIFOF;
      
      Reg#(Int#(32)) param_a <- mkRegU;
      Reg#(Int#(32)) param_b <- mkRegU;
      Reg#(Int#(32)) param_c <- mkRegU;

      Reg#(InputParam) a <- mkReg(A);
      Reg#(InputParam) b <- mkReg(B);
      Reg#(InputParam) c <- mkReg(C);

      rule r1;
          if(fifo_in.notEmpty) begin
            let x = fifo_in.first;
            fifo_in.deq;
            reg1 <= tagged Valid (x + param_a);
          end else begin
            reg1 <= tagged Invalid;
          end

          if(reg1 matches tagged Valid .reg_value1) begin
            reg2 <= tagged Valid (reg_value1 * param_b);
          end else begin
            reg2 <= tagged Invalid;
          end

          if(reg2 matches tagged Valid .reg_value2) begin
            reg3 <= tagged Valid (reg_value2 * param_c);
          end else begin
            reg3 <= tagged Invalid;
          end

          if(reg3 matches tagged Valid .reg_value3) begin
            reg4 <= tagged Valid (reg_value3 / 4);
          end else begin
            reg4 <= tagged Invalid;
          end

          if(reg4 matches tagged Valid .reg_value4) begin
            fifo_out.enq(reg_value4 + 128);
          end

      endrule

      method Action setParam(UInt#(2) addr, Int#(32) val);
          case(addr)
            unpack(pack(a)): param_a <= val;
            unpack(pack(b)): param_b <= val;
            unpack(pack(c)): param_c <= val;
          endcase
      endmethod

      interface CalcUnit calc;
        method Action put(Int#(32) x);
          fifo_in.enq(x);
        endmethod
        method ActionValue#(Int#(32)) result() if(fifo_out.notEmpty);
          fifo_out.deq;
          return fifo_out.first;
        endmethod
      endinterface
    
    endmodule

endpackage