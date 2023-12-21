`timescale 10ps/1ps
module Register (
  input wire clk,       // Clock input
  input wire reset,     // Reset input
  input wire [7 : 0][111:0] data_in,  // 22-bit input data
  input wire enable,    // Enable input
  output reg [7 : 0][111:0] data_out  // 22-bit output data
);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      data_out[0] <= 112'b0;  // Reset the register on positive edge of reset
      data_out[1] <= 112'b0; 
      data_out[2] <= 112'b0; 
      data_out[3] <= 112'b0; 
      data_out[4] <= 112'b0; 
      data_out[5] <= 112'b0; 
      data_out[6] <= 112'b0; 
      data_out[7] <= 112'b0; 
    end else if (enable) begin
      data_out <= data_in;  // Update the register with input data on positive edge of clock when enable is asserted
    end
  end

endmodule

