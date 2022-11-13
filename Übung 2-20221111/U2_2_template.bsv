package U2Tb;
    import U2::*;
    import StmtFSM::*;
    import Vector::*;
    
    module mkU2Tb(Empty);
        Pipeline dut <- mkPipeline;
        Reg#(UInt#(32)) idx_put <- mkReg(0);
        Reg#(UInt#(32)) idx_get <- mkReg(0);
        Reg#(UInt#(32)) correct_tests <- mkReg(0);

        Vector#(20, Int#(32)) testvec;
        testvec[0] = 401; // values 0-9 for a = 42, b = 2, c = 13
        testvec[1] = 407;
        testvec[2] = 414;
        testvec[3] = 420;
        testvec[4] = 427;
        testvec[5] = 433;
        testvec[6] = 440;
        testvec[7] = 446;
        testvec[8] = 453;
        testvec[9] = 459;
        testvec[10] = 344; // value 10 - 19 for a = 7, b = 3, c = 17
        testvec[11] = 357;
        testvec[12] = 370;
        testvec[13] = 383;
        testvec[14] = 395;
        testvec[15] = 408;
        testvec[16] = 421;
        testvec[17] = 434;
        testvec[18] = 446;
        testvec[19] = 459;

        Stmt s = seq
            // TODO: write statement
        endseq;

        // TODO: instantiate FSM

    endmodule

endpackage