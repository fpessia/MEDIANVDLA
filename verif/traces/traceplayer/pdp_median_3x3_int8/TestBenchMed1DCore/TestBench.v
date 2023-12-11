`timescale 10ps/1ps
module TestBench(
  input clk,
  input rst,
  input [21 : 0] data0,
  output [21 : 0] pooling_MEDIAN
);

wire       core_enable; //to minimize switching activity
reg       reg2dp_int8_en;
reg       reg2dp_int16_en;
reg       reg2dp_fp16_en;
reg [21:0]  data1;

reg enable;




assign core_enable = 1'b1;

NV_NVDLA_PDP_CORE_med1d_core dut(
    .core_enable(core_enable),
    .reg2dp_int8_en(reg2dp_int8_en),
    .reg2dp_int16_en(reg2dp_int16_en),
    .reg2dp_fp16_en(reg2dp_fp16_en),
    .data0(data0),
    .data1(data1),
    .pooling_MEDIAN(pooling_MEDIAN)
);

Register r_dut (
  .clk(clk),       // Clock input
  .reset(rst),     // Reset input
  .data_in(pooling_MEDIAN),  // 22-bit input data
  .enable(enable),    // Enable input
  .data_out(data1)  // 22-bit output data
);

assign enable = 1;
assign reg2dp_fp16_en = 1'b0;
assign reg2dp_int16_en = 1'b0;
assign reg2dp_int8_en = 1'b1;

always@(posedge clk or posedge rst) begin
$display("clk=%b, rst=%b,data0=%h, data1=%h, Med1d=%h",clk,rst, data0, data1, pooling_MEDIAN);
end


endmodule


