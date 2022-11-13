package U1;
    interface Blinky;
        method int blink();
        method Action start();
        method ActionValue#(int) stop();
    endinterface

    module mkBlinky(Blinky);
        Reg# (int) led_on <- mkReg(0);      //den Status der LED angeben 
        Reg# (int) ctrl_on <- mkReg(0);     //ob die steuerung eingeschaltet ist
        Reg# (int) blink_crtl <- mkReg(0);  //wie oft die LED eingeschaltet
        
        rule blinkRun (ctrl_on == 1);

            if(led_on == 0) begin
                led_on <= 1;
                blink_crtl <= blink_crtl + 1;
            end
            else begin
                led_on <= 0;
            end
        endrule

        //rule  (  );
        //endrule : 

        method int blink();
            return led_on;
        endmethod

        method Action start() if(ctrl_on == 0);
            ctrl_on <= 1;
            blink_crtl <= 0;
        endmethod

        method ActionValue# (int) stop() if(ctrl_on == 1);
            ctrl_on <= 0;
            led_on <= 0;
            return blink_crtl;
        endmethod
    endmodule
endpackage : U1