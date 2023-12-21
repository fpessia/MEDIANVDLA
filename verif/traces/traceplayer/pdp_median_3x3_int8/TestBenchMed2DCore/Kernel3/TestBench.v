`timescale 10ps/1ps
module TestBench(
  input clk,
  input rst
);

wire [2 : 0] kernel_h;
wire [2 : 0] kernel_w;
wire [6 : 0][111 : 0] zero_channels;
wire [1 : 0][3 : 0][27 : 0] input_channel;
reg [7 : 0][111 : 0] data0;
reg [7 : 0][111 : 0] data1;
reg [7 : 0][111 : 0] data1_w;
wire [7:0][111:0] med2d_out; 
wire [6 : 0][111 : 0] unused_bits;

reg [3:0] count; 

assign kernel_h = 3'h2; //Kw = K_w +1 
assign kernel_w = 3'h2;


/*STIMULI*/
assign zero_channels[0] = 112'h0; 
assign zero_channels[1] = 112'h0; 
assign zero_channels[2] = 112'h0; 
assign zero_channels[3] = 112'h0; 
assign zero_channels[4] = 112'h0; 
assign zero_channels[5] = 112'h0; 
assign zero_channels[6] = 112'h0; 


assign input_channel[0][0][14 : 0] = 15'h087F; 
assign input_channel[0][0][27 : 15] = 13'b0;


assign input_channel[0][1][14 : 0] = 15'h05AF; 
assign input_channel[0][1][27 : 15] = 13'b0;


assign input_channel[0][2][14 : 0] = 15'h0879; 
assign input_channel[0][2][27 : 15] =  13'b0000000000001;


assign input_channel[0][3][14 : 0] = 15'h004AF; 
assign input_channel[0][3][27 : 15] = 13'b0;


assign input_channel[1][0][14 : 0] = 15'h04AF; 
assign input_channel[1][0][27 : 15] = 13'b0;


assign input_channel[1][1][14 : 0] = 15'h0857; 
assign input_channel[1][1][27 : 15] = 13'b0;


assign input_channel[1][2][14 : 0] = 15'h0428; 
assign input_channel[1][2][27 : 15] = 13'b0;

assign input_channel[1][3][14 : 0] = 15'h0400; 
assign input_channel[1][3][27 : 15] = 13'b0;







Counter c0(
  .clk(clk),    // Clock input
  .reset(rst),  // Asynchronous reset input
  .count(count)  // 4-bit counter output
);

Register r0 (
  .clk(clk),       // Clock input
  .reset(rst),     // Reset input
  .data_in(med2d_out),  
  .enable(1'b1),    // Enable input
  .data_out(data1)  // 22-bit output data
);

assign data1_w[0][111 : 0] = (count == 4'b1) ?  112'b0 : data1[0];
assign data1_w[7 : 1] = data1[7 : 1];


always@(posedge clk or posedge rst) begin
    if (rst) begin
      data0[7 : 1] <= zero_channels;
      data0[0][111 : 0] <= 112'b0;
    end else begin
      if (count < 2) begin
        data0[7 : 1] <= zero_channels;
        data0[0][27 : 0] <= input_channel[count][0];
        data0[0][55 : 28] <= input_channel[count][1];
        data0[0][83 : 56] <= input_channel[count][2];
        data0[0][111 : 84] <= input_channel[count][3];
      end 
    end
end


NV_NVDLA_PDP_CORE_med2d_core dut(
  .reg2dp_int8_en(1'b1),
  .reg2dp_int16_en(1'b0),
  .reg2dp_fp16_en(1'b0),
  .pooling_type(2'b11),
  .kernel_w(kernel_w),
  .kernel_h(kernel_h),
  .data0_valid(8'b11111111),
  .cores_enable(8'b00000001),
  .data0(data0), 
  .data1(data1_w),
  .med2d_out(med2d_out) 
);



assign unused_bits = med2d_out[7 : 1];

always@(posedge clk or posedge rst) begin
  $display("A[27 : 0] : %h , B[27 : 0] : %h, Med2d : %h" , data0[0][27 : 0], data1_w[0][27 : 0], med2d_out[0][27 : 0]);
  $display("A[55 : 28] : %h , B[55 : 28] : %h, Med2d : %h" , data0[0][55 : 28], data1_w[0][55 : 28], med2d_out[0][55 : 28]);
  $display("A[83 : 56] : %h , B[83 : 56] : %h, Med2d : %h" , data0[0][83 : 56], data1_w[0][83 : 56], med2d_out[0][83 : 56]);
  $display("A[111 : 84] : %h , B[111 : 84] : %h, Med2d : %h" , data0[0][111 : 84], data1_w[0][111 : 84], med2d_out[0][111 : 84]);
  $display("\n\n");
end


endmodule


