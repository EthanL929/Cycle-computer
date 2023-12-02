// Example code for an M0 AHBLite System
//  Iain McNally
//  ECS, University of Soutampton
//
// This module is an AHB-Lite Slave containing three read-only locations
//
// Number of addressable locations : 3
// Size of each addressable location : 32 bits
// Supported transfer sizes : Word
// Alignment of base address : Double Word aligned
//
// Address map :
//   Base addess + 0 : 
//     Read Switches Entered via Button[0]
//   Base addess + 4 : 
//     Read Switches Entered via Button[1]
//   Base addess + 8 : 
//     Read Status_d of Switches Entered via Buttons
//
// Bits within Status register :
//   Bit 1   DataValid_d[1]
//     (data has been entered via Button[1]
//      this Status bit is cleared when this data is read by the bus master)
//   Bit 0   DataValid_d[0] 
//     (data has been entered via Button[0]
//      this Status bit is cleared when this data is read by the bus master)

// For simplicity, this interface supports only 32-bit transfers.
// The most significant 16 bits of the value read will always be 0
// since there are only 16 switches.


module ahb_switches(

  // AHB Global Signals
  input HCLK,
  input HRESETn,

  // AHB Signals from Master to Slave
  input [31:0] HADDR, // With this interface only HADDR[3:2] is used (other bits are ignored)
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
  input  nFork,
  input  nMode,
  input  nTrip,
  input  nCrank


);

timeunit 1ns;
timeprecision 100ps;
//----------------
logic [31:0] count_c, count_f, output_count_f, output_count_c, button_count;
logic button_count_B, button_count_M, button_count_T;


  // AHB transfer codes needed in this module
  localparam No_Transfer = 2'b0;

  // Storage for two different switch values  
  //logic [15:0] SwitchData[0:1];

  // Storage for Status_d bits 
  logic DataValid_d, DataValid_b, DataValid_c;

  // last_buttons is used for simple edge detection  
  //logic [1:0] last_buttons;

  //control signals are stored in registers
  logic read_enable;
  logic [2:0] word_address;
 
  logic [31:0] Status_d, Status_b, Status_c;
  logic LastFork, LastCrank, LastMode, LastTrip;



  //--------------------nFork
  always_ff @(posedge HCLK, negedge HRESETn)
    begin
	 if ( ! HRESETn )
      begin
	   LastFork <= 1;
	  end
	 else if (!nFork) begin
	   LastFork <= 0; end
	 else begin
	   LastFork <= 1; end
	end
	
//  	Crank
	
always_ff @(posedge HCLK, negedge HRESETn)
    begin
	 if ( ! HRESETn )
      begin
	   LastCrank <= 1;
	  end
	 else if (!nCrank) begin
	   LastCrank <= 0; end
	 else begin
	   LastCrank <= 1; end
	end
	
// Mode	
	
always_ff @(posedge HCLK, negedge HRESETn)
    begin
	 if ( ! HRESETn )
      begin
	   LastMode <= 1;
	  end
	 else if (!nMode) begin
	   LastMode <= 0; end
	 else begin
	   LastMode <= 1; end
	end
	
// Trip
	
always_ff @(posedge HCLK, negedge HRESETn)
    begin
	 if ( ! HRESETn )
      begin
	   LastTrip <= 1;
	  end
	 else if (!nTrip) begin
	   LastTrip <= 0; end
	 else begin
	   LastTrip <= 1; end
	end
	

//////////////////////////////////////////////

   always_ff @(posedge HCLK, negedge HRESETn)
    begin
	 if ( ! HRESETn )
      begin
	   count_c <= '0;
	   count_f <= '0;
	   output_count_f <= '0;
	   output_count_c <= '0;
	   button_count_M <= '0;
	   button_count_T <= '0;
	   button_count_B <= '0;
	   button_count <= '0;
	   DataValid_d <= '0;
       DataValid_b <= '0; //adjustment
	   DataValid_c <= '0;
	  end
	 else
      begin	 
////////////////////////// Button1

	  if (nMode == 0 && nTrip == 1)
	   begin
	    button_count_M <=  1;
		
	   end
	 else if (nMode == 1 && nTrip == 0)
       begin
        button_count_T <=  1;
		
       end
     else if (nMode == 0 && nTrip == 0)
       begin
        button_count_B <=  1;
		
	   end
	 else if (nMode == 1 && nTrip == 1)
	   begin
	    button_count_M <= '0;
		button_count_T <= '0;
		button_count_B <= '0;
	   end
///////////////// Button2

	 if (nMode == 1 && nTrip == 1 && (LastMode == 0 || LastTrip == 0)) 
	  begin
	   if (button_count_B == 1) begin
  	    button_count <= { 29'b0, 3'b100 }; 
	    DataValid_b <= 1; end
	   else if (button_count_M == 1) begin
        button_count <= { 29'b0, 3'b010 }; 
	    DataValid_b <= 1; end
	   else if (button_count_T == 1) begin
  	    button_count <= { 29'b0, 3'b001 }; 
	    DataValid_b <= 1; end
	  end
	 else if ( read_enable && ( word_address == 2 ))
	  begin
	   DataValid_b <= 0;
	  end

///////////////////////////////////// Fork
	  
	  if (LastFork == 1 && nFork == 0)
	  begin
	   count_f <= 0;
	   output_count_f <= count_f;
	   DataValid_d <= 1;
	  end
	 else if ( read_enable && ( word_address == 3 ) )
	  begin
	   DataValid_d <= 0;
	   count_f <= count_f + 1;
	  end
	 else if (count_f < 131072) // 2^15
	  begin
	   count_f <= count_f + 1;
	  end
	  
///////////////////////////////////// Crank
	  if (LastCrank == 1 && nCrank == 0)
	  begin
	   count_c <= 0;
	   output_count_c <= count_c;
	   DataValid_c <= 1;
	  end
	 else if ( read_enable && ( word_address == 5 ) )
	  begin
	   DataValid_c <= 0;
	   count_c <= count_c + 1;
	  end
	 else // 2^15
	  begin
	   count_c <= count_c + 1;
	  end
	  
	  
	 end
	end
	
	
  //Generate the control signals in the address phase
  always_ff @(posedge HCLK, negedge HRESETn)
    if ( ! HRESETn )
      begin
        read_enable <= '0;
        word_address <= '0;
      end
    else if ( HREADY && HSEL && (HTRANS != No_Transfer) )
      begin
        read_enable <= ! HWRITE;
        word_address <= HADDR[4:2];
     end
    else
      begin
        read_enable <= '0;
        word_address <= '0;
     end
	 

  //Act on control signals in the data phase

  // define the bits in the Status_d register
  assign Status_d = { 31'b0, DataValid_d};
  assign Status_b = { 31'b0, DataValid_b};
  assign Status_c = { 31'b0, DataValid_c};
  // read
  always_comb
    if ( ! read_enable )
      // (output of zero when not enabled for read is not necessary
      //  but may help with debugging)
      HRDATA = '0;
    else
      case (word_address)
        0 : HRDATA = Status_d;
		1 : HRDATA = Status_b;
        2 : HRDATA = button_count;
		3 : HRDATA = output_count_f;
		4 : HRDATA = Status_c;
		5 : HRDATA = output_count_c;
        // unused address - returns zero
        default : HRDATA = '0;
      endcase

  //Transfer Response
  assign HREADYOUT = '1; //Single cycle Write & Read. Zero Wait state operations



endmodule
