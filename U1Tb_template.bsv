package U1Tb;
    // TODO: import the U1 package

    module mkU1Tb();
        // TODO: Instantiate the dut, i.e. the LEDController

        Reg#(Bool) started <- mkReg(False);
        Reg#(UInt#(33)) cycles <- mkReg(0);
        Reg#(Bool) checked <- mkReg(False);

        UInt#(33) cycle_limit = `CYCLES;
        UInt#(33) n_blinks = (cycle_limit+1) / 2;

        rule start (!started);
            started <= True;

            // TODO: Start the LED Controller
        endrule

        rule let_blink (cycles <= cycle_limit);
            // TODO: Get the state of the LED and print it, if the cycle_limit is less than 100   

            cycles <= cycles + 1;
        endrule

        rule check (cycles > cycle_limit);
            // TODO: Stop the LED Controller and store the number of blinks in a local variable (signal) called 'blinked'

            if (extend(blinked) != unpack(pack(n_blinks))) begin
                $display("LED count != Reference value. Expected %d, got %d", n_blinks, blinked);
            end
            else 
                $display("Test successful!");
            checked <= True;
        endrule

        rule shutdown (checked);
            $finish();
        endrule
    endmodule
endpackage