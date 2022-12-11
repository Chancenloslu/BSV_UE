package U2_4;
typedef union tagged {
        UInt#(32) Unsigned;
        Int#(32) Signed;
        } SignedOrUnsigned deriving(Eq, Bits);


        module mkExample(Empty);
        SignedOrUnsigned a = tagged Unsigned 43;
        SignedOrUnsigned b = tagged Unsigned 42;
        Reg#(SignedOrUnsigned) c <- mkRegU;
        Reg#(UInt#(32)) index <- mkReg(0);
        
        /*rule doAdd (pack(a)[32] == pack(b)[32]);
                case (a) matches
                tagged Unsigned .usa: begin
                        UInt#(32) usb = unpack(pack(b)[31:0]);
                        c <= tagged Unsigned (usa+usb);
                end
                tagged Signed .sa: begin
                        Int#(32) sb = unpack(pack(b)[31:0]);
                        c <= tagged Signed (sa + sb);
                end
                endcase
                $display("%h", c);
        endrule*/

        rule doAddUnsigned (a matches tagged Unsigned .usa &&& b matches tagged Unsigned .usb);
                c <= tagged Unsigned (usa + usb);
        endrule

        rule doAddSigned ( a matches tagged Signed .sa &&& b matches tagged Signed .sb );
                c <= tagged Signed (sa + sb);
        endrule

        rule run (index <= 10);
        //for(int k = 0 ; k <= index; k = k + 1)
                $display("time:", $time, "%d", c);
                index <= index + 1;
        endrule : run

        rule fin ( index > 10 );
                $finish();
        endrule : fin
        endmodule

endpackage : U2_4 
