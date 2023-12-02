
// Example code for an M0 AHBLite System
//  Iain McNally
//  ECS, University of Soutampton
//
// This module is an AHB-Lite Slave containing two read/write registers
//
// Number of addressable locations : 2
// Size of each addressable location : 32 bits
// Supported transfer sizes : Word
// Alignment of base address : Word aligned
//
// Address map :
//   Base addess + 0 : 
//     Read DataOut register
//     Write DataOut register, Copy NextDataValid to DataValid
//   Base addess + 4 : 
//     Read Status register
//     Write NextDataValid register
//
// Bits within status register :
//   Bit 1   NextDataValid
//   Bit 0   DataValid


// In order to update the output, the software should update the NextDataValid
// register followed by the DataOut register.


module ahb_out(

  // AHB Global Signals
  input HCLK,
  input HRESETn,

  // AHB Signals from Master to Slave
  input [31:0] HADDR, // With this interface only HADDR[2] is used (other bits are ignored)
  input [31:0] HWDATA,
  input [2:0] HSIZE,
  input [1:0] HTRANS,
  input HWRITE,
  input HREADY,
  input HSEL,

  // AHB Signals from Slave to Master
  output logic [31:0] HRDATA,
  output HREADYOUT,

  //Non-AHB Signals
  output logic SegA,
  output logic SegB,
  output logic SegC,
  output logic SegD,
  output logic SegE,
  output logic SegF,
  output logic SegG,
  output logic DP,

  output logic [3:0] nDigit

);

timeunit 1ns;
timeprecision 100ps;

  // AHB transfer codes needed in this module
  localparam No_Transfer = 2'b0;

  //control signals are stored in registers
  logic write_enable, read_enable;
  logic word_address;
 
  //Generate the control signals in the address phase
  always_ff @(posedge HCLK, negedge HRESETn)
    if ( ! HRESETn )
      begin
        write_enable <= '0;
        read_enable <= '0;
        word_address <= '0;
      end
    else if ( HREADY && HSEL && (HTRANS != No_Transfer) )
      begin
        write_enable <= HWRITE;
        read_enable <= ! HWRITE;
        word_address <= HADDR[2];
     end
    else
      begin
        write_enable <= '0;
        read_enable <= '0;
        word_address <= '0;
     end

  //main function

logic [31:0] load;
logic [1:0] state;
logic [7:0] digit_0, digit_1, digit_2, digit_3;

always_ff @(posedge HCLK, negedge HRESETn)
   begin
    if (!HRESETn)
	 begin
	 load <= '0;
	 end
	else if ( write_enable && (word_address==0))
	begin
     load <= HWDATA;
	end
   end
   
   
always_ff @(posedge HCLK, negedge HRESETn)  
begin
 if (!HRESETn)
  begin
    digit_3[7] <= 0;
	digit_2[7] <= 0;
	digit_1[7] <= 0;
	digit_0[7] <= 0;
	digit_3[6:0] <= '0;
  end
 else
  begin
   case (load[31:29])  
    1:
     begin
      digit_3[7] <= 0;
	  digit_2[7] <= 0;
	  digit_1[7] <= 1;
	  digit_0[7] <= 0;
      // d <==> 23457 <==> 12346
      digit_3[6:0] <= 7'b1011110;
	 end
	
	2:  // size
     begin
      digit_3[7] <= 0;
	  digit_2[7] <= 0;
	  digit_1[7] <= 0;
	  digit_0[7] <= 0;
      // c(mirror) > 236
      digit_3[6:0] <= 7'b1001100;
	 end
	
	3:  // speed
     begin
      digit_3[7] <= 0;
	  digit_2[7] <= 0;
	  digit_1[7] <= 1;
	  digit_0[7] <= 0;
      // v > 23
      digit_3[6:0] <= 7'b0001100;
	 end
	
	4: // Cadence Meter
     begin
      digit_3[7] <= 0;
	  digit_2[7] <= 0;
	  digit_1[7] <= 0;
	  digit_0[7] <= 1;
      // c > 346
      digit_3[6:0] <= 7'b1011000;
	 end
	
	5: // Trip Timer
     begin
      digit_3[7] <= 0;
	  digit_2[7] <= 1;
	  digit_1[7] <= 0;
	  digit_0[7] <= 0;
      // t > 3456
      digit_3[6:0] <= 7'b1111000;
	 end
	
    default:
     begin
     digit_3[7] <= 0;
 	 digit_2[7] <= 0;
  	 digit_1[7] <= 0;
	 digit_0[7] <= 0;
	 digit_3[6:0] <= '0;
     end
	 
	endcase
  end
end

  
always_ff @(posedge HCLK, negedge HRESETn)
  begin
   if (!HRESETn)
    begin
	 digit_0[6:0] <= '0;
	 digit_1[6:0] <= '0;
	 digit_2[6:0] <= '0;
	end
   else
    begin
	 digit_0[6:0] <= load[6:0];
	 digit_1[6:0] <= load[13:7];
	 digit_2[6:0] <= load[20:14];
	end
  end
  

always_ff @(posedge HCLK, negedge HRESETn)
 begin
  if (!HRESETn)
   state <= '0;
  else
   state <= state + 1;
 end


always_ff @(posedge HCLK, negedge HRESETn)
 begin
  if (!HRESETn)
   begin 
      SegA <= '0;
      SegB <= '0;
      SegC <= '0;
      SegD <= '0;
      SegE <= '0;
      SegF <= '0;
      SegG <= '0;
      DP   <= '0;
	  nDigit <= '0;
   end
  else
   begin
  case (state)
  0: begin
      SegA <= digit_0[0];
      SegB <= digit_0[1];
      SegC <= digit_0[2];
      SegD <= digit_0[3];
      SegE <= digit_0[4];
      SegF <= digit_0[5];
      SegG <= digit_0[6];
      DP   <= digit_0[7];
	  nDigit <= 4'b1110;
     end
	
  1: begin
      SegA <= digit_1[0];
      SegB <= digit_1[1];
      SegC <= digit_1[2];
      SegD <= digit_1[3];
      SegE <= digit_1[4];
      SegF <= digit_1[5];
      SegG <= digit_1[6];
      DP   <= digit_1[7];
	  nDigit <= 4'b1101;
     end
	 
  2: begin
      SegA <= digit_2[0];
      SegB <= digit_2[1];
      SegC <= digit_2[2];
      SegD <= digit_2[3];
      SegE <= digit_2[4];
      SegF <= digit_2[5];
      SegG <= digit_2[6];
      DP   <= digit_2[7];
	  nDigit <= 4'b1011;
     end
	 
  3: begin
      SegA <= digit_3[0];
      SegB <= digit_3[1];
      SegC <= digit_3[2];
      SegD <= digit_3[3];
      SegE <= digit_3[4];
      SegF <= digit_3[5];
      SegG <= digit_3[6];
      DP   <= digit_3[7];
	  nDigit <= 4'b0111;
     end
  endcase
   end
 end

 
  //Transfer Response
  assign HREADYOUT = '1; //Single cycle Write & Read. Zero Wait state operations


endmodule
