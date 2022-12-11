package FSMTests;

import StmtFSM :: *;

  typedef enum{Mul,Div,Add,Sub,And,Or,Pow} AluOps deriving (Eq, Bits, FShow);

  interface Power;
      method Action   setOperands(Int#(32) a, Int#(32) b);
      method Int#(32) getResult();
  endinterface

  module mkPower(Power);
      Reg#(Bool) resultValid <- mkReg(False);

      Reg#(Int#(32)) opA    <- mkReg(0);
      Reg#(Int#(32)) opB    <- mkReg(0);
      Reg#(Int#(32)) result <- mkReg(1);

      rule calc (opB > 0);
          opB <= opB - 1;
          result <= result * opA;
      endrule

      rule calcDone (opB == 0 && !resultValid);
          resultValid <= True;
      endrule

      method Action setOperands(Int#(32) a, Int#(32) b);
          result <= 1;
          opA    <= a;
          opB    <= b;
          resultValid <= False;
      endmethod

      method Int#(32) getResult() if(resultValid);
          return result;
      endmethod
  endmodule

  interface HelloALU;
      method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
      method ActionValue#(Int#(32))  getResult();
  endinterface

  module mkHelloALU(HelloALU);
      Reg#(Bool) newOperands <- mkReg(False);
      Reg#(Bool) resultValid <- mkReg(False);
      Reg#(AluOps) operation <- mkReg(Mul);
      Reg#(Int#(32)) opA    <- mkReg(0);
      Reg#(Int#(32)) opB    <- mkReg(0);
      Reg#(Int#(32)) result <- mkReg(0);

      Power pow             <- mkPower();

      rule calculate (newOperands);
          Int#(32) rTmp = 0;
          case(operation)
              Mul: rTmp = opA * opB;
              Div: rTmp = opA / opB;
              Add: rTmp = opA + opB;
              Sub: rTmp = opA - opB;
              And: rTmp = opA & opB;
              Or:  rTmp = opA | opB;
              Pow: rTmp = pow.getResult();
          endcase
          result <= rTmp;
          newOperands <= False;
          resultValid <= True;
      endrule

      method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b) if(!newOperands);
          opA <= a;
          opB <= b;
          operation <= op;
          newOperands <= True;
          resultValid <= False;
          if(op == Pow) pow.setOperands(a,b);
      endmethod

      method ActionValue#(Int#(32)) getResult() if(resultValid);
          resultValid <= False;
          return result;
      endmethod
  endmodule

import Vector::*;

typedef struct {
  Int#(32) opA;
  Int#(32) opB;
  AluOps    operator;
  Int#(32) expectedResult;
} TestData deriving (Eq, Bits);


module mkAluFSMTB(Empty);
  Vector#(5, TestData) myVector;
  myVector[0] = TestData {opA: 2, opB: 4, operator: Add, expectedResult: 6};
  myVector[1] = TestData {opA: 2, opB: 4, operator: Mul, expectedResult: 8};
  myVector[2] = TestData {opA: 4, opB: 2, operator: Div, expectedResult: 2};
  myVector[3] = TestData {opA: 4, opB: 0, operator: Pow, expectedResult: 1};
  myVector[4] = TestData {opA: 4, opB: 4, operator: Pow, expectedResult: 256};
  //myVector[4] = TestData {opA: 8, opB: 4, operator: Div, expectedResult: 42};

  Reg#(UInt#(32)) dataPtr <- mkReg(0);

  HelloALU uut <- mkHelloALU();

  Stmt checkStmt = {
    seq
      action
        let currentData = myVector[dataPtr];
        uut.setupCalculation(currentData.operator, currentData.opA, currentData.opB);
      endaction
      action
        let currentData = myVector[dataPtr];
        let result <- uut.getResult();
        let print  = $format("Calculation: %d ", currentData.opA) + fshow(currentData.operator) + $format("%d", currentData.opB);
        $display(print);
        if(result == currentData.expectedResult) begin
          $display("Result correct: %d", result);
        end else begin
          $display("Result incorrect: %d != ", result, currentData.expectedResult);
        end
      endaction
    endseq
  };

  FSM checkFSM <- mkFSM(checkStmt);

  Stmt mainFSM = {
    seq
      for(dataPtr <= 0; dataPtr < 5; dataPtr <= dataPtr + 1) seq
        checkFSM.start();
        checkFSM.waitTillDone();
      endseq
    endseq
  };
  mkAutoFSM(mainFSM);
endmodule


endpackage