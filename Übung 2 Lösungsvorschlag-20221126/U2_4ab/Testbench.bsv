package Testbench;
    import Vector :: *;
    import StmtFSM :: *;

    // Project Modules
    import CustomTest :: *;
    import CalcUnits::*;

    typedef 20 TestAmount;

    (* synthesize *)
    module [Module] mkTestbench();
        Vector#(20, Int#(32)) testvals;
        testvals[0] = 401; // values 0-9 for a = 42, b = 2, c = 13, tagged signed
        testvals[1] = 407;
        testvals[2] = 414;
        testvals[3] = 420;
        testvals[4] = 427;
        testvals[5] = 433;
        testvals[6] = 440;
        testvals[7] = 446;
        testvals[8] = 453;
        testvals[9] = 459;
        testvals[10] = 344; // value 10 - 19 for a = 7, b = 3, c = 17, tagged unsigned
        testvals[11] = 357;
        testvals[12] = 370;
        testvals[13] = 383;
        testvals[14] = 395;
        testvals[15] = 408;
        testvals[16] = 421;
        testvals[17] = 434;
        testvals[18] = 446;
        testvals[19] = 459;

        Vector#(TestAmount, TestHandler) testVec;
        for(Integer i = 0; i < 10; i = i + 1) begin
            testVec[i] <- mkCustomTest(tagged Signed 42, tagged Signed 2, tagged Signed 13, tagged Signed fromInteger(i), tagged Signed testvals[i]);
        end

        for(Integer i = 10; i < 20; i = i + 1) begin
            testVec[i] <- mkCustomTest(tagged Unsigned 7, tagged Unsigned 3, tagged Unsigned 17, tagged Unsigned fromInteger(i), tagged Unsigned unpack(pack(testvals[i])));
        end

        Reg#(UInt#(32)) testCounter <- mkReg(0);
        Stmt s = {
            seq
                for(testCounter <= 0;
                    testCounter < fromInteger(valueOf(TestAmount));
                    testCounter <= testCounter + 1)
                seq
                    testVec[testCounter].go();
                    await(testVec[testCounter].done());
                endseq
            endseq
        };
        mkAutoFSM(s);
    endmodule

endpackage
