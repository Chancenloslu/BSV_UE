package CustomTest;
    import StmtFSM :: *;
    import CalcUnits::*;
    import TU_Pipeline :: *;
    import Vector::*;

    interface TestHandler;
        method Action go();
        method Bool done();
    endinterface

    function Stmt setup(TU_Pipeline dut, SignedOrUnsigned a, SignedOrUnsigned b, SignedOrUnsigned c);
        return seq 
            dut.setParam(0, a);
            dut.setParam(1, b);
            dut.setParam(2, c);
            $display("Initialized parameters, starting test...");
        endseq;
    endfunction

    (* synthesize *)
    module [Module] mkCustomTest#(parameter SignedOrUnsigned a, parameter SignedOrUnsigned b, parameter SignedOrUnsigned c,
     parameter SignedOrUnsigned in, parameter SignedOrUnsigned expOut)(TestHandler);

        TU_Pipeline dut <- mkTU_Pipeline();

        Stmt s = {
            seq
                setup(dut, a, b, c);
                // TODO: extend statement
                dut.calc.put(in);
                
                action
                    let t <- dut.calc.result();
                    if(t == expOut) begin
                        $display("Test %d succeeded!");
                    end
                    else begin
                        $display("Test %d faild. The expected value is %d, but got %h", pack(in)[31:0], pack(expOut)[31:0], pack(t)[31:0]);
                    end
                endaction
                
            endseq
        };

        FSM testFSM <- mkFSM(s);
        method Action go();
            testFSM.start();
        endmethod
        method Bool done();
            return testFSM.done();
        endmethod
    endmodule
endpackage