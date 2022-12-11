package CalcUnits;
    typedef union tagged {
        UInt#(32) Unsigned;
        Int#(32) Signed;
    } SignedOrUnsigned deriving(Eq, Bits);

    interface CalcUnits;
        method Action put(SignedOrUnsigned x);
        method ActionValue#(SignedOrUnsigned) result();
    endinterface

    interface CalcUnitChangeable;
        interface CalcUnits calc;
        method Action setParameter(SignedOrUnsigned param);
    endinterface
/*
module mkAdda(CalcUnitChangeable);
Reg#(SignedOrUnsigned) a <- mkRegU;
Wire#(SignedOrUnsigned) in <- mkWire;
Wire#(SignedOrUnsigned) out <- mkWire;

rule computeSigned(a matches tagged Signed .sa &&&
in matches tagged Signed .sin);
out <= tagged Signed (sa + sin);
endrule
rule computeUnsigned(a matches tagged Unsigned .usa &&&
in matches tagged Unsigned .usin);
out <= tagged Unsigned (usa + usin);
endrule
rule crash(pack(in)[32] != pack(a)[32]); // if we input an unfitting value we crash
$display("ERROR: mkAddA got wrong input!");
$display("Tag a: %b, Tag in: %b", pack(a)[32], pack(in)[32]);
$finish();
endrule

method Action setParameter(SignedOrUnsigned param);
a <= param;
endmethod
interface CalcUnits calc;
method Action put(SignedOrUnsigned x);
in <= x;
endmethod
method ActionValue#(SignedOrUnsigned) result();
noAction;
return out;
endmethod
endinterface
endmodule
module mkMUlbc(CalcUnitChangeable);
Reg#(SignedOrUnsigned) b <- mkRegU; // or c
Wire#(SignedOrUnsigned) in <- mkWire;
Wire#(SignedOrUnsigned) out <- mkWire;

rule computeSigned(b matches tagged Signed .sb &&&
in matches tagged Signed .sin);
out <= tagged Signed (sb * sin);
endrule
rule computeUnsigned(b matches tagged Unsigned .usb &&&
in matches tagged Unsigned .usin);
out <= tagged Unsigned (usb * usin);
endrule
rule crash(pack(in)[32] != pack(b)[32]);
$display("ERROR: mkMulB got wrong input!");
$display("Tag b: %b, Tag in: %b", pack(b)[32], pack(in)[32]);
$finish();
endrule

method Action setParameter(SignedOrUnsigned param);
b <= param;
endmethod
interface CalcUnits calc;
method Action put(SignedOrUnsigned x);
in <= x;
endmethod
method ActionValue#(SignedOrUnsigned) result();
noAction;
return out;
endmethod
endinterface
endmodule
module mkDiv4(CalcUnits);
Wire#(SignedOrUnsigned) in <- mkWire;
method Action put(SignedOrUnsigned x);
in <= x;
endmethod
method ActionValue#(SignedOrUnsigned) result();
noAction;
case (in) matches
tagged Unsigned .usin : return tagged Unsigned (usin / 4);
tagged Signed .sin : return tagged Signed (sin / 4);
endcase
endmethod
endmodule : mkDiv4
module mkAdd128(CalcUnits);
Wire#(SignedOrUnsigned) in <- mkWire;
method Action put(SignedOrUnsigned x);
in <= x;
endmethod
method ActionValue#(SignedOrUnsigned) result();
noAction;
case (in) matches
tagged Unsigned .usin : return tagged Unsigned (usin + 128);
tagged Signed .sin : return tagged Signed (sin + 128);
endcase
endmethod
endmodule : mkAdd128
*/

/*
 * conclusion: the output and input of CalcUnits should be defined as **wire** type, otherwise no right
 * result. 
 */

    module mkAdda(CalcUnitChangeable);
        Reg#(SignedOrUnsigned) a <- mkRegU;
        Wire#(SignedOrUnsigned) _input <- mkWire;
        Wire#(SignedOrUnsigned) _output <- mkWire;
        
        rule doAddSigned ( a matches tagged Unsigned .usa &&& _input matches tagged Unsigned .usb );
            _output <= tagged Unsigned (usa + usb);
        endrule : doAddSigned

        rule doAddUnsigned ( a matches tagged Signed .sa &&& _input matches tagged Signed .sb );
            _output <= tagged Signed (sa + sb);
        endrule : doAddUnsigned

        method Action setParameter(SignedOrUnsigned param);
            a <= param;
        endmethod

        interface CalcUnits calc;
            method ActionValue#(SignedOrUnsigned) result();
                return _output;
            endmethod
 
            method Action put(SignedOrUnsigned x);
                _input <= x;
            endmethod
        endinterface
    endmodule

    module mkMUlbc(CalcUnitChangeable);
        Reg#(SignedOrUnsigned) bc <- mkRegU;
        Wire#(SignedOrUnsigned) _input <- mkWire;
        Wire#(SignedOrUnsigned) _output <- mkWire;
        
        rule doMUlUnsigned ( bc matches tagged Unsigned .usa &&& _input matches tagged Unsigned .usb );
            _output <= tagged Unsigned (usa * usb);
        endrule

        rule doMUlSigned ( bc matches tagged Signed .sa &&& _input matches tagged Signed .sb );
            _output <= tagged Signed (sa * sb);
        endrule

        method Action setParameter(SignedOrUnsigned param);
            bc <= param;
        endmethod

        interface CalcUnits calc;
            method ActionValue#(SignedOrUnsigned) result();
                return _output;
            endmethod
            method Action put(SignedOrUnsigned x);
                _input <= x;
            endmethod
        endinterface
    endmodule 

    module mkAdd128(CalcUnits);
        Wire#(SignedOrUnsigned) _input <- mkWire;
        Wire#(SignedOrUnsigned) _output <- mkWire;
        
        rule doAddSigned ( _input matches tagged Unsigned .usa );
            _output <= tagged Unsigned (usa + 128);
        endrule : doAddSigned

        rule doAddUnsigned ( _input matches tagged Signed .sa );
            _output <= tagged Signed (sa + 128);
        endrule : doAddUnsigned

        method ActionValue#(SignedOrUnsigned) result();
            return _output;
        endmethod

        method Action put(SignedOrUnsigned x);
            _input <= x;
        endmethod

    endmodule

    module mkDiv4(CalcUnits);
        Wire#(SignedOrUnsigned) _input <- mkWire;
        Wire#(SignedOrUnsigned) _output <- mkWire;
        
        rule doDivUnsigned ( _input matches tagged Unsigned .usa );
            _output <= tagged Unsigned (usa / 4);
        endrule

        rule doDivSigned ( _input matches tagged Signed .sa );
            _output <= tagged Signed (sa / 4);
        endrule

        method ActionValue#(SignedOrUnsigned) result();
            return _output;
        endmethod

        method Action put(SignedOrUnsigned x);
            _input <= x;
        endmethod

    endmodule

    module mkTb(Empty);
        CalcUnitChangeable add_a <- mkAdda;
        Reg#(Bool) set <- mkReg(False);

        rule paramSet (!set);
            add_a.setParameter(tagged Unsigned 42);
            add_a.calc.put(tagged Unsigned 43);
            set <= True; 
        endrule

        rule rl_print_answer (set);
                
            let t <- add_a.calc.result();
            $display ("Deep Thought says: Hello, World! The answer is %d.", t);
            $finish;
        endrule
    endmodule

endpackage : CalcUnits
