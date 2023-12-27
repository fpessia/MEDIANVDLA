`timescale 10ps/1ps
module NV_NVDLA_PDP_CORE_med1d_core(
   input       core_enable, //to minimize switching activity
   input       reg2dp_int8_en,
   input       reg2dp_int16_en,
   input       reg2dp_fp16_en,
   input[21:0]  data0,
   input[21:0]  data1,
   output [21:0] pooling_MEDIAN
);

wire [21:0]  min_16int;
wire [21:0] int16_data0;
wire [21:0] int16_data1;
wire        min_16int_ff;
wire        zero_wired_0;
wire        zero_wired_1;
wire [21:0]  min_fp16;
wire [21:0] fp16_data0;
wire [21:0] fp16_data1;

wire [21 : 0] uint8_data0;
wire [21 : 0] uint8_data1;
wire [21 : 0] uint8_med_out;
wire          enable_uint_core;


assign  int16_data0 = (reg2dp_int16_en & core_enable) ? data0 : 22'b0;
assign  zero_wired_0 = (int16_data0[15 : 0] == 16'h0) ? 1'b1 : 1'b0;
assign  int16_data1 = (reg2dp_int16_en & core_enable) ? data1 : 22'b0;
assign  zero_wired_1 = (int16_data1[15 : 0] == 16'h0) ? 1'b1 : 1'b0;
      
assign  fp16_data0  = (reg2dp_fp16_en & core_enable) ? data0 : 22'b0;
assign  fp16_data1  = (reg2dp_fp16_en & core_enable) ? data1 : 22'b0;

assign  uint8_data0 = (reg2dp_int8_en & core_enable) ? data0 : 22'b0;
assign  uint8_data1 = (reg2dp_int8_en & core_enable) ? data1 : 22'b0;

assign enable_uint_core = (reg2dp_int8_en & core_enable);

NV_NVDLA_PDP_CORE_int8_med1d_core uint8_med_core(
        .enable_core(enable_uint_core),
        .uint8_A(uint8_data0),
        .uint8_B(uint8_data1),
        .uint8_med_out(uint8_med_out)
);

assign  min_16int_ff    = ($signed(int16_data0) <  $signed(int16_data1)); /*for int16 anf fp16 med --> min1D, max 2D*/
assign  min_16int    = (zero_wired_0 & ~(zero_wired_1)) ? int16_data1 : 
                       (zero_wired_1 & ~(zero_wired_0)) ? int16_data0 : 
                        (min_16int_ff) ? int16_data0 : int16_data1;

assign  min_fp16     = ((~fp16_data0[15]) & (~fp16_data1[15])) ? ((fp16_data0[14:0] < fp16_data1[14:0]) ? fp16_data0 : fp16_data1) : 
                     (((fp16_data0[15]) & (fp16_data1[15]))?  ((fp16_data0[14:0] > fp16_data1[14:0])? fp16_data0 : fp16_data1) : 
                     (((fp16_data0[15]) & (~fp16_data1[15]))?  fp16_data0 : fp16_data1));


assign   pooling_MEDIAN  = (reg2dp_fp16_en & core_enable) ? min_fp16 : 
                        (reg2dp_int16_en & core_enable) ? min_16int : 
                        (reg2dp_int8_en & core_enable) ? uint8_med_out : 0;
endmodule


