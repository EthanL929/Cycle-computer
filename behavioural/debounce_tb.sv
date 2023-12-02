module tb_debouncer () ;

timeunit 1ns;
timeprecision 100ps;

logic clock;           
logic nReset;           
logic nMode;
logic nTrip;          
logic debounced_nMode;
logic debounced_nTrip;

debouncer uut(
   .clock,
   .nReset,
   .nMode,
   .nTrip,
   .debounced_nMode,
   .debounced_nTrip
) ;

initial
   begin
     clock = 0;
     forever #15000ns clock = ~clock;
   end

initial
   begin
     nReset = 0;
     #100000ns nReset = 1;
   end   

initial
   begin
               nMode = 1;
     #10300000ns  nMode = 0;
     #3000000ns   nMode = 1;
     #3000000ns   nMode = 0;
     #3000000ns   nMode = 1;
     #3000000ns   nMode = 0;
     #3000000ns   nMode = 1;
     #3000000ns   nMode = 0;
     #3000000ns   nMode = 1;
     #3000000ns   nMode = 0;

     #300000000ns
               nMode = 1;
     #3000000ns   nMode = 0;
     #3000000ns   nMode = 1;
     #3000000ns   nMode = 0;
     #3000000ns   nMode = 1;
     #3000000ns   nMode = 0;  
     #3000000ns   nMode = 1; 
     #3000000ns   nMode = 0;
     #3000000ns   nMode = 1;      
   end

initial
   begin
               nTrip = 1;
     #10400000ns  nTrip = 0;
     #4000000ns   nTrip = 1;
     #4000000ns   nTrip = 0;
     #4000000ns   nTrip = 1;
     #4000000ns   nTrip = 0;
     #4000000ns   nTrip = 1;
     #4000000ns   nTrip = 0;
     #4000000ns   nTrip = 1;
     #4000000ns   nTrip = 0;

     #300000000ns
               nTrip = 1;
     #4000000ns   nTrip = 0;
     #4000000ns   nTrip = 1;
     #4000000ns   nTrip = 0;
     #4000000ns   nTrip = 1;
     #4000000ns   nTrip = 0;  
     #4000000ns   nTrip = 1;
     #4000000ns   nTrip = 0;
     #4000000ns   nTrip = 1;       
   end

endmodule