package TestsMainTest;
    import StmtFSM :: *;
    import TestHelper :: *;
    import TU_Pipeline :: *;
    import Vector::*;


    (* synthesize *)
    module [Module] mkTestsMainTestSigned(TestHandler);
        TU_Pipeline dut <- mkTU_Pipeline();
        Stmt s = {
            seq
                
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
