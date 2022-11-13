//
// Generated by Bluespec Compiler, version 2022.01-36-ga6304315 (build a6304315)
//
// On Mon Oct 24 14:58:16 CEST 2022
//
//
// Ports:
// Name                         I/O  size props
// CLK                            I     1 unused
// RST_N                          I     1 unused
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkTb(CLK,
	    RST_N);
  input  CLK;
  input  RST_N;

  // handling of system tasks

  // synopsys translate_off
  always@(negedge CLK)
  begin
    #0;
    $display("Hello World!");
    $finish(32'd0);
  end
  // synopsys translate_on
endmodule  // mkTb

