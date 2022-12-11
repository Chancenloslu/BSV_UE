package FSMEval;
    import StmtFSM::*;

    module mkFSMEx(Empty);
        Reg#(int) ctr <- mkReg(0);

        Stmt s1 = seq 
            $display("%t : %d", $time(), ctr);
            ctr <= ctr + 1;
            $display("%t : %d", $time(), ctr);

            par
                seq
                    $display("%t : %d", $time(), ctr);
                endseq

                seq
                    action
                        ctr <= ctr + 1;
                        $display("%t : %d", $time(), ctr);
                    endaction
                    $display("%t, %d", $time(), ctr);
                endseq
            endpar
        endseq;

        Stmt s2 = seq 
            $display("%t : %d", $time(), ctr);
            ctr <= ctr + 1;
            $display("%t : %d", $time(), ctr);

            par
                seq
                    $display("%t : %d", $time(), ctr);
                endseq

                seq
                    ctr <= ctr + 1;
                    $display("%t : %d", $time(), ctr);
                    $display("%t, %d", $time(), ctr);
                endseq
            endpar
        endseq;

        Stmt s3 = seq
            $display("%t : %d", $time(), ctr);
            ctr <= ctr + 1;
            $display("%t : %d", $time(), ctr);

            par
                seq
                    $display("%t : %d", $time(), ctr);
                    action
                        ctr <= ctr + 1;
                        ctr <= ctr + 1;
                    endaction
                    $display("%t : %d", $time(), ctr);
                endseq

                seq
                    ctr <= ctr + 1;
                    $display("%t : %d", $time(), ctr);
                    $display("%t, %d", $time(), ctr);
                endseq
            endpar
        endseq;

        mkAutoFSM(s2);  // change the parameter to reproduce the corresponding solution

    endmodule
endpackage