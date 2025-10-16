
module blink_led #(
   parameter CLK_FREQ = 100_000_000
)(
   input logic clk,
   input logic rst,
   input logic cs,
   input logic we,           // write enable
   input logic rd,
   input logic [1:0] addr,
   input logic [15:0] wr_data,
   output logic [15:0] rd_data,
   output logic [3:0] led_out
);

   logic [15:0] interval [3:0];
   logic [31:0] count [3:0];
   logic [31:0] threshold [3:0];
   
   // write logic
   always_ff @(posedge(clk)) begin
      if (we) begin
         case (addr[1:0])
            2'd0: interval[0]<=wr_data;
            2'd1: interval[1]<=wr_data;
            2'd2: interval[2]<=wr_data;
            2'd3: interval[3]<=wr_data;
         endcase
      end
   end
   
   always_comb begin
      rd_data = 16'h0000;
      if (rd) begin
         case (addr[1:0])
            2'd0: rd_data=interval[0];
            2'd1: rd_data=interval[1];
            2'd2: rd_data=interval[2];
            2'd3: rd_data=interval[3];
         endcase
      end
  end
   
   // timer logic
   genvar i;
   generate
      for (i=0; i<4; i++) begin : blink_loop
         always_ff @(posedge(clk), posedge(rst)) begin
            if(rst) begin
               count[i]<=0;
               led_out[i]<=0;
            end else begin
               if (count[i]>=threshold[i]) begin
                  count[i]<=0;
                  led_out[i]<=~led_out[i];
               end else begin
                  count[i]<=count[i]+1;
               end
            end
         end
      end
   endgenerate
endmodule

endmodule
