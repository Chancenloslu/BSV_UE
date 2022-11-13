module mkExample(Empty);
    Blinky b <- mkBlinky;

    int clock_limit = 30;
    Reg# (int) t <- mkReg(0);

    rule start_blink ( t < clock_limit);
        b.start();
        t <= t + 1;
        
    endrule

    rule stop ( t >= clock_limit );
        int num = b.stop();
        $display ("the time: the number of blink is %d", num);
        $finish;
    endrule
endmodule