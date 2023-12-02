module ahb_debouncer #( 
   parameter CLK_CYCLE    =  9   ,           // 25ms = 830 clock cycles 
   parameter IS_ACTIVEH   =  1               // Optional: '1' for active high button, '0' for active low button                                                 
) 
(
   input  HCLK,           
   input  HRESETn,           
   input  nMode,
   input  nTrip,           
   output debounced_nMode,
   output debounced_nTrip           
)
;

timeunit 1ns;
timeprecision 100ps;

logic mid_signal_M, mid_signal_M_sync;
logic mid_signal_T, mid_signal_T_sync;        
logic signal_reg_M, signal_debounced_reg_M;
logic signal_reg_T, signal_debounced_reg_T;
logic [CLK_CYCLE : 0] count_M; 
logic [CLK_CYCLE : 0] count_T;

always_ff @(posedge HCLK, negedge HRESETn) begin  //synchronous
   if (!HRESETn) begin
      mid_signal_M      <= IS_ACTIVEH;
      mid_signal_M_sync <= IS_ACTIVEH;
      mid_signal_T      <= IS_ACTIVEH;
      mid_signal_T_sync <= IS_ACTIVEH;
   end
   else begin
      mid_signal_M      <= nMode;      
      mid_signal_M_sync <= mid_signal_M;
      mid_signal_T      <= nTrip;   
      mid_signal_T_sync <= mid_signal_T;
   end
end

always @(posedge HCLK, negedge HRESETn) begin   //count for bounce
   if (!HRESETn) begin
      signal_reg_M           <= IS_ACTIVEH; 
      signal_debounced_reg_M <= IS_ACTIVEH;
      signal_reg_T           <= IS_ACTIVEH;
      signal_debounced_reg_T <= IS_ACTIVEH;
      count_M                <=  0;
      count_T                <=  0;
   end
   else begin     
      signal_reg_M <= mid_signal_M_sync;
      signal_reg_T <= mid_signal_T_sync;
      count_M <= (signal_reg_M != signal_debounced_reg_M) ? count_M + 1 : 
                    (count_M > 0) ? count_M - 1 : count_M;
      count_T <= (signal_reg_T != signal_debounced_reg_T) ? count_T + 1 : 
                    (count_T > 0) ? count_T - 1 : count_T;              
      if (count_M == 830) begin
         signal_debounced_reg_M <= signal_reg_M;
      end
      if (count_T == 830) begin
         signal_debounced_reg_T <= signal_reg_T;
      end
   end
end

assign debounced_nMode = signal_debounced_reg_M;  //continous assignment
assign debounced_nTrip = signal_debounced_reg_T;


endmodule
