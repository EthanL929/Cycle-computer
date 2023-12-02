///////////////////////////////////////////////////////////////////////
//
// comp_core module
//
//    this is the behavioural model of the bicycle computer without pads
//
///////////////////////////////////////////////////////////////////////

`include "options.sv"

module comp_core(

  output SegA,
  output SegB,
  output SegC,
  output SegD,
  output SegE,
  output SegF,
  output SegG,
  output DP,

  output logic [3:0] nDigit,
  
  input nMode, nTrip,
  input nFork, nCrank,

  input Clock, nReset

  );

timeunit 1ns;
timeprecision 100ps;

// the following is behavioural (unsynthesisable) code to output d00.0

//assign SegA = nDigit[3]; // on when Digit[3] is inactive
//assign { SegB, SegC, SegD, SegE } = '1; // always on;
//assign SegF = nDigit[3]; // on when Digit[3] is inactive
//assign SegG = ~nDigit[3]; // on when Digit[3] is active
//assign DP = ~nDigit[1]; // on when Digit[1] is active

//always
  //begin
           //nDigit = 4'b1110;
    //#2.5ms nDigit = 4'b1101;
    //#2.5ms nDigit = 4'b1011;
    //#2.5ms nDigit = 4'b0111;
    //#2.5ms nDigit = 4'b0111;
  //end

arm_soc soc_1 (

    .HCLK(Clock),
    .HRESETn(nReset),
    .nFork(nFork),
    .nMode(nMode),
    .nTrip(nTrip),
    .nCrank(nCrank),
    .SegA(SegA),
    .SegB(SegB),
    .SegC(SegC),
    .SegD(SegD),
    .SegE(SegE),
    .SegF(SegF),
    .SegG(SegG),
    .DP(DP),
    .nDigit(nDigit)

);
endmodule
