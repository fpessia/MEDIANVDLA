`timescale 10ps/1ps
module Counter(
  input wire clk,    // Clock input
  input wire reset,  // Asynchronous reset input
  output reg [3:0] count  // 4-bit counter output
);

  always @(posedge clk or posedge reset) begin
    if (reset)
      count <= 4'b0000; // Reset the counter to 0
    else
      count <= count + 1; // Increment the counter on each clock edge
  end

endmodule


