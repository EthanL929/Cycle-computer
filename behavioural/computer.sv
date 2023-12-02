module computer (
  input  nMode,
  input  ScanEnable,
  input  nReset,
  output [3:0] nDigit,
  input  SDI,
  input  Test,
  output SegF,
  input  nCrank,
  output DP,
  output SegC,
  output SegE,
  output SegD,
  output SegA,
  input  nTrip,
  output SDO,
  output SegB,
  input  Clock,
  input  nFork,
  output SegG
);

  wire CORE_nMode;
  wire CORE_ScanEnable;
  wire CORE_nReset;
  wire [3:0] CORE_nDigit;
  wire CORE_SDI;
  wire CORE_Test;
  wire CORE_SegF;
  wire CORE_nCrank;
  wire CORE_DP;
  wire CORE_SegC;
  wire CORE_SegE;
  wire CORE_SegD;
  wire CORE_SegA;
  wire CORE_nTrip;
  wire CORE_SDO;
  wire CORE_SegB;
  wire CORE_Clock;
  wire CORE_nFork;
  wire CORE_SegG;
  wire SYNC_MID_nReset;
  wire SYNC_IN_nReset;
  wire SYNC_MID_nMode;
  wire SYNC_IN_nMode;
  wire SYNC_MID_nTrip;
  wire SYNC_IN_nTrip;
  wire SYNC_MID_nFork;
  wire SYNC_IN_nFork;
  wire SYNC_MID_nCrank;
  wire SYNC_IN_nCrank;

 //synopsys dc_tcl_script_begin
  //set_dont_touch [get_cells RESET_SYNC_FF*]
 //synopsys dc_tcl_script_end

DFC1 RESET_SYNC_FF1 (
  .D('1),              .Q(SYNC_MID_nReset), .C(CORE_Clock), .RN(SYNC_IN_nReset)
);

DFC1 RESET_SYNC_FF2 (
   .D(SYNC_MID_nReset), .Q(CORE_nReset),    .C(CORE_Clock), .RN(SYNC_IN_nReset)
);

//nMode input synchronous
DFP1 MODE_SYNC_FF1 (
  .D(SYNC_IN_nMode),              .Q(SYNC_MID_nMode), .C(CORE_Clock), .SN(CORE_nReset)
);

DFP1 MODE_SYNC_FF2 (
   .D(SYNC_MID_nMode), .Q(CORE_nMode),    .C(CORE_Clock), .SN(CORE_nReset)
);

//nTrip input synchronous
DFP1 TRIP_SYNC_FF1 (
  .D(SYNC_IN_nTrip),              .Q(SYNC_MID_nTrip), .C(CORE_Clock), .SN(CORE_nReset)
);

DFP1 TRIP_SYNC_FF2 (
   .D(SYNC_MID_nTrip), .Q(CORE_nTrip),    .C(CORE_Clock), .SN(CORE_nReset)
);

//nFork input synchronous
DFP1 FORK_SYNC_FF1 (
  .D(SYNC_IN_nFork),              .Q(SYNC_MID_nFork), .C(CORE_Clock), .SN(CORE_nReset)
);

DFP1 FORK_SYNC_FF2 (
   .D(SYNC_MID_nFork), .Q(CORE_nFork),    .C(CORE_Clock), .SN(CORE_nReset)
);

//nCrank input synchronous
DFP1 CRANK_SYNC_FF1 (
  .D(SYNC_IN_nCrank),              .Q(SYNC_MID_nCrank), .C(CORE_Clock), .SN(CORE_nReset)
);

DFP1 CRANK_SYNC_FF2 (
   .D(SYNC_MID_nCrank), .Q(CORE_nCrank),    .C(CORE_Clock), .SN(CORE_nReset)
);

  BU8P PAD_SegA ( .PAD(SegA), .A(CORE_SegA) );
  BU8P PAD_SegB ( .PAD(SegB), .A(CORE_SegB) );
  BU8P PAD_SegC ( .PAD(SegC), .A(CORE_SegC) );
  BU8P PAD_SegD ( .PAD(SegD), .A(CORE_SegD) );
  BU8P PAD_SegE ( .PAD(SegE), .A(CORE_SegE) );
  ICCK2P PAD_Clock ( .PAD(Clock), .Y(CORE_Clock) );
  ICP PAD_nReset ( .PAD(nReset), .Y(SYNC_IN_nReset) );   /////////SYNC_IN_nReset
  ICP PAD_ScanEnable ( .PAD(ScanEnable), .Y(CORE_ScanEnable) );
  ICP PAD_Test ( .PAD(Test), .Y(CORE_Test) );
  ICP PAD_SDI ( .PAD(SDI), .Y(CORE_SDI) );
  BU8P PAD_SDO ( .PAD(SDO), .A(CORE_SDO) );
  ICUP PAD_nMode ( .PAD(nMode), .Y(SYNC_IN_nMode) ); //ICP -> ICUP //integral pull_up resistor
  ICUP PAD_nTrip ( .PAD(nTrip), .Y(SYNC_IN_nTrip) ); //ICP -> ICUP
  ICUP PAD_nFork ( .PAD(nFork), .Y(SYNC_IN_nFork) ); //ICP -> ICUP
  ICUP PAD_nCrank ( .PAD(nCrank), .Y(SYNC_IN_nCrank) ); //ICP -> ICUP
  BU8P PAD_nDigit_3 ( .PAD(nDigit[3]), .A(CORE_nDigit[3]) );
  BU8P PAD_SegF ( .PAD(SegF), .A(CORE_SegF) );
  BU8P PAD_SegG ( .PAD(SegG), .A(CORE_SegG) );
  BU8P PAD_DP ( .PAD(DP), .A(CORE_DP) );
  BU8P PAD_nDigit_0 ( .PAD(nDigit[0]), .A(CORE_nDigit[0]) );
  BU8P PAD_nDigit_1 ( .PAD(nDigit[1]), .A(CORE_nDigit[1]) );
  BU8P PAD_nDigit_2 ( .PAD(nDigit[2]), .A(CORE_nDigit[2]) );

  comp_core core_inst (
    .nMode(CORE_nMode),
    //.ScanEnable(CORE_ScanEnable),
    .nReset(CORE_nReset),
    .nDigit(CORE_nDigit),
    //.SDI(CORE_SDI),
    //.Test(CORE_Test),
    .SegF(CORE_SegF),
    .nCrank(CORE_nCrank),
    .DP(CORE_DP),
    .SegC(CORE_SegC),
    .SegE(CORE_SegE),
    .SegD(CORE_SegD),
    .SegA(CORE_SegA),
    .nTrip(CORE_nTrip),
    //.SDO(CORE_SDO),
    .SegB(CORE_SegB),
    .Clock(CORE_Clock),
    .nFork(CORE_nFork),
    .SegG(CORE_SegG)
  );

endmodule
