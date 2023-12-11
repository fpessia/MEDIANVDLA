`timescale 10ps/1ps
module NV_NVDLA_PDP_CORE_med2d_core(
input       reg2dp_int8_en,
input       reg2dp_int16_en,
input       reg2dp_fp16_en,
input[1:0]  pooling_type,
input[2 :0] kernel_w,
input[2 :0] kernel_h,
input[7:0]  data0_valid,
input[7:0]  cores_enable,
input[7:0][111:0] data0, 
input[7:0][111:0] data1,
output[7:0][111:0] med2d_out 
);


wire core_enable ;
wire MED2x2;
wire MED3x3;
wire [7 : 0] lut_enable;
wire [7 : 0] cores_2x2_enable;
wire [7 : 0][3 : 0][3 : 0] msbs_i;
wire [7 : 0][3 : 0][3 : 0] msbs_j;
wire [7 : 0][3 : 0][3 : 0] msbs_k;
wire [7 : 0][3 : 0][3 : 0] msbs_w;
wire [7 : 0][3 : 0][11 : 0] code;
wire [7 : 0][3 : 0][11 : 0] to_decode;
wire [7 : 0][3 : 0][3 : 0] decoded_msbs_i;
wire [7 : 0][3 : 0][3 : 0] decoded_msbs_j;
wire [7 : 0][3 : 0][3 : 0] decoded_msbs_k;
wire [7 : 0][3 : 0][3 : 0] decoded_msbs_w;

wire[7:0][111:0] int8_med_out;
wire[7:0][111:0] int8_med_2x2_out;
wire[7:0][111:0] int8_med_3x3_out;


reg[7:0][111:0] int16_med_out;
reg[7:0][3 : 0][27 : 0] operands0;
reg[7:0][3 : 0][27 : 0] operands1;


reg[7:0][111:0] fp16_med_out;
reg[7:0][3 : 0][27 : 0] operands_fp0;
reg[7:0][3 : 0][27 : 0] operands_fp1;





assign core_enable = (pooling_type == 2'h3);


/*int8*/
assign MED2x2 = (kernel_h == 3'h1 && kernel_w == 3'h1); //K(W) = k_w+1
assign MED3x3 = (kernel_h == 3'h2 && kernel_w == 3'h2); //K(H) = k_h+1

assign int8_med_out = MED2x2 ? int8_med_2x2_out : 
                       MED3x3 ? int8_med_3x3_out : 0;


/*Kernel = 2x2*/
assign cores_2x2_enable =  data0_valid & {8{(MED2x2 & core_enable)}};

NV_NVDLA_PDPD_CORE_med2d_core2x2 core2x2_0(
    .A(data0[0]),
    .B(data1[0]),
    .enable(cores_2x2_enable[0]),
    .Median2x2(int8_med_2x2_out[0])
);

NV_NVDLA_PDPD_CORE_med2d_core2x2 core2x2_1(
    .A(data0[1]),
    .B(data1[1]),
    .enable(cores_2x2_enable[1]),
    .Median2x2(int8_med_2x2_out[1])
);

NV_NVDLA_PDPD_CORE_med2d_core2x2 core2x2_2(
    .A(data0[2]),
    .B(data1[2]),
    .enable(cores_2x2_enable[2]),
    .Median2x2(int8_med_2x2_out[2])
);

NV_NVDLA_PDPD_CORE_med2d_core2x2 core2x2_3(
    .A(data0[3]),
    .B(data1[3]),
    .enable(cores_2x2_enable[3]),
    .Median2x2(int8_med_2x2_out[3])
);

NV_NVDLA_PDPD_CORE_med2d_core2x2 core2x2_4(
    .A(data0[4]),
    .B(data1[4]),
    .enable(cores_2x2_enable[4]),
    .Median2x2(int8_med_2x2_out[4])
);

NV_NVDLA_PDPD_CORE_med2d_core2x2 core2x2_5(
    .A(data0[5]),
    .B(data1[5]),
    .enable(cores_2x2_enable[5]),
    .Median2x2(int8_med_2x2_out[5])
);

NV_NVDLA_PDPD_CORE_med2d_core2x2 core2x2_6(
    .A(data0[6]),
    .B(data1[6]),
    .enable(cores_2x2_enable[6]),
    .Median2x2(int8_med_2x2_out[6])
);

NV_NVDLA_PDPD_CORE_med2d_core2x2 core2x2_0(
    .A(data0[7]),
    .B(data1[7]),
    .enable(cores_2x2_enable[7]),
    .Median2x2(int8_med_2x2_out[7])
);
/*Kernel = 3x3*/


assign lut_enable[7 : 0] = data0_valid & {(core_enable & MED3x3),(core_enable & MED3x3),(core_enable & MED3x3),(core_enable & MED3x3),
                                          (core_enable & MED3x3),(core_enable & MED3x3),(core_enable & MED3x3),(core_enable & MED3x3)};
NV_NVDLA_PDP_CORE_med2d_lut lut (
  .encoding(lut_enable),
  .decoding(lut_enable),
  .msbs_i(msbs_i),
  .msbs_j(msbs_j),
  .msbs_k(msbs_k),
  .msbs_w(msbs_w),
  .code_o(code),
  .to_decode(to_decode),
  .decoded_msbs_i(decoded_msbs_i),
  .decoded_msbs_j(decoded_msbs_j),
  .decoded_msbs_k(decoded_msbs_k),
  .decoded_msbs_w(decoded_msbs_k)

);


NV_NVDLA_PDPD_CORE_med2d_core3x3 core3x3_0(
    .enable(lut_enable[0]),
    .A(data0[0]),
    .B(data1[0]),
    .codes(code[0]),/*lut interface for operator2D_1*/
    .msb_i(msb_i[0]),
    .msb_j(msb_j[0]),    
    .msb_k(msb_k[0]),
    .msb_w(msb_w[0]),
    .to_decode(to_decode[0]), /*lut interface for operator2D_2*/
    .decoded_msbs_i(decoded_msbs_i[0]),
    .decoded_msbs_j(decoded_msbs_j[0]),
    .decoded_msbs_k(decoded_msbs_k[0]),
    .decoded_msbs_w(decoded_msb_w[0]),
    .Median(int8_med_3x3_out[0])
);


NV_NVDLA_PDPD_CORE_med2d_core3x3 core3x3_1(
    .enable(lut_enable[1]),
    .A(data0[1]),
    .B(data1[1]),
    .codes(code[1]),/*lut interface for operator2D_1*/
    .msb_i(msb_i[1]),
    .msb_j(msb_j[1]),    
    .msb_k(msb_k[1]),
    .msb_w(msb_w[1]),
    .to_decode(to_decode[1]), /*lut interface for operator2D_2*/
    .decoded_msbs_i(decoded_msbs_i[1]),
    .decoded_msbs_j(decoded_msbs_j[1]),
    .decoded_msbs_k(decoded_msbs_k[1]),
    .decoded_msbs_w(decoded_msb_w[1]),
    .Median(int8_med_3x3_out[1])
);


NV_NVDLA_PDPD_CORE_med2d_core3x3 core3x3_2(
    .enable(lut_enable[2]),
    .A(data0[2]),
    .B(data1[2]),
    .codes(code[2]),/*lut interface for operator2D_1*/
    .msb_i(msb_i[2]),
    .msb_j(msb_j[2]),    
    .msb_k(msb_k[2]),
    .msb_w(msb_w[2]),
    .to_decode(to_decode[2]), /*lut interface for operator2D_2*/
    .decoded_msbs_i(decoded_msbs_i[2]),
    .decoded_msbs_j(decoded_msbs_j[2]),
    .decoded_msbs_k(decoded_msbs_k[2]),
    .decoded_msbs_w(decoded_msb_w[2]),
    .Median(int8_med_3x3_out[2])
);


NV_NVDLA_PDPD_CORE_med2d_core3x3 core3x3_3(
    .enable(lut_enable[3]),
    .A(data0[3]),
    .B(data1[3]),
    .codes(code[3]),/*lut interface for operator2D_1*/
    .msb_i(msb_i[3]),
    .msb_j(msb_j[3]),    
    .msb_k(msb_k[3]),
    .msb_w(msb_w[3]),
    .to_decode(to_decode[3]), /*lut interface for operator2D_2*/
    .decoded_msbs_i(decoded_msbs_i[3]),
    .decoded_msbs_j(decoded_msbs_j[3]),
    .decoded_msbs_k(decoded_msbs_k[3]),
    .decoded_msbs_w(decoded_msb_w[3]),
    .Median(int8_med_3x3_out[3])
);

NV_NVDLA_PDPD_CORE_med2d_core3x3 core3x3_4(
    .enable(lut_enable[4]),
    .A(data0[4]),
    .B(data1[4]),
    .codes(code[4]),/*lut interface for operator2D_1*/
    .msb_i(msb_i[4]),
    .msb_j(msb_j[4]),    
    .msb_k(msb_k[4]),
    .msb_w(msb_w[4]),
    .to_decode(to_decode[4]), /*lut interface for operator2D_2*/
    .decoded_msbs_i(decoded_msbs_i[4]),
    .decoded_msbs_j(decoded_msbs_j[4]),
    .decoded_msbs_k(decoded_msbs_k[4]),
    .decoded_msbs_w(decoded_msb_w[4]),
    .Median(int8_med_3x3_out[4])
);

NV_NVDLA_PDPD_CORE_med2d_core3x3 core3x3_5(
    .enable(lut_enable[5]),
    .A(data0[5]),
    .B(data1[5]),
    .codes(code[5]),/*lut interface for operator2D_1*/
    .msb_i(msb_i[5]),
    .msb_j(msb_j[5]),    
    .msb_k(msb_k[5]),
    .msb_w(msb_w[5]),
    .to_decode(to_decode[5]), /*lut interface for operator2D_2*/
    .decoded_msbs_i(decoded_msbs_i[5]),
    .decoded_msbs_j(decoded_msbs_j[5]),
    .decoded_msbs_k(decoded_msbs_k[5]),
    .decoded_msbs_w(decoded_msb_w[5]),
    .Median(int8_med_3x3_out[5])
);


NV_NVDLA_PDPD_CORE_med2d_core3x3 core3x3_6(
    .enable(lut_enable[6]),
    .A(data0[6]),
    .B(data1[6]),
    .codes(code[6]),/*lut interface for operator2D_1*/
    .msb_i(msb_i[6]),
    .msb_j(msb_j[6]),    
    .msb_k(msb_k[6]),
    .msb_w(msb_w[6]),
    .to_decode(to_decode[6]), /*lut interface for operator2D_2*/
    .decoded_msbs_i(decoded_msbs_i[6]),
    .decoded_msbs_j(decoded_msbs_j[6]),
    .decoded_msbs_k(decoded_msbs_k[6]),
    .decoded_msbs_w(decoded_msb_w[6]),
    .Median(int8_med_3x3_out[6])
);

NV_NVDLA_PDPD_CORE_med2d_core3x3 core3x3_7(
    .enable(lut_enable[7]),
    .A(data0[7]),
    .B(data1[7]),
    .codes(code[7]),/*lut interface for operator2D_1*/
    .msb_i(msb_i[7]),
    .msb_j(msb_j[7]),    
    .msb_k(msb_k[7]),
    .msb_w(msb_w[7]),
    .to_decode(to_decode[7]), /*lut interface for operator2D_2*/
    .decoded_msbs_i(decoded_msbs_i[7]),
    .decoded_msbs_j(decoded_msbs_j[7]),
    .decoded_msbs_k(decoded_msbs_k[7]),
    .decoded_msbs_w(decoded_msb_w[7]),
    .Median(int8_med_3x3_out[7])
);


/*int16*/
always@(core_enable or data_valid or data0 or dat1 or reg2dp_int16_en) begin
  if (core_enable == 1'b1 && reg2dp_int16_en == 1'b1) begin
    for (int b = 0; b < 8; b = b+1) begin
      if (data0_valid[b] == 1'b1) begin
        operands0[b][0] = data0[27 : 0];
        operands0[b][1] = data0[55 : 28];
        operands0[b][2] = data0[83 : 56];
        operands0[b][3] = data0[111 : 84];

        operands1[b][0] = data1[27 : 0];
        operands1[b][1] = data1[55 : 28];
        operands1[b][2] = data1[83 : 56];
        operands1[b][3] = data1[111 : 84];
      end

    end 

  end
end

always@(operands0 or operands1) begin
    for (int b = 0; b < 8; b = b+1) begin
      if($signed(operands0[b][0]) < $signed(operands1[b][0])) begin
          int16_med_out[b][27 : 0] = operands1[b][0];
        end else begin 
          int16_med_out[b][27 : 0] = operands0[b][0];
        end

        if($signed(operands0[b][1]) < $signed(operands1[b][1])) begin
          int16_med_out[b][55 : 28] = operands1[b][1];
        end else begin 
          int16_med_out[b][55 : 28] = operands0[b][1];
        end

        if($signed(operands0[b][2]) < $signed(operands1[b][2])) begin
          int16_med_out[b][83 : 56] = operands1[b][2];
        end else begin 
          int16_med_out[b][83 : 56] = operands0[b][2];
        end

        if($signed(operands0[b][3]) < $signed(operands1[b][3])) begin
          int16_med_out[b][111 : 84] = operands1[b][3];
        end else begin 
          int16_med_out[b][111 : 84] = operands0[b][3];
        end
    end 
end


/*fp16*/
always@(core_enable or data_valid or data0 or dat1 or reg2dp_fp16_en) begin
  if (core_enable == 1'b1 && reg2dp_fp16_en == 1'b1) begin
    for (int b = 0; b < 8; b = b+1) begin
      if (data0_valid[b] == 1'b1) begin
        operands_fp0[b][0] = data0[27 : 0];
        operands_fp0[b][1] = data0[55 : 28];
        operands_fp0[b][2] = data0[83 : 56];
        operands_fp0[b][3] = data0[111 : 84];

        operands_fp1[b][0] = data1[27 : 0];
        operands_fp1[b][1] = data1[55 : 28];
        operands_fp1[b][2] = data1[83 : 56];
        operands_fp1[b][3] = data1[111 : 84];
      end

    end 

  end
end

always@(operands_fp0 or operands_fp1) begin
    for (int b = 0; b < 8; b = b+1) begin
      if( ((operands_fp0[b][0][15] == 1'b0) && (operands_fp1[b][0][15] == 1'b0) && (operands_fp0[b][0][14 : 0] > operands_fp1[b][0][14 : 0] ) ) ||
           ((operands_fp0[b][0][15] == 1'b1) && (operands_fp1[b][0][15] == 1'b1) && (operands_fp0[b][0][14 : 0] < operands_fp1[b][0][14 : 0] ) ) ||
            (operands_fp0[b][0][15] == 1'b0) && (operands_fp1[b][0][15] == 1'b1)
      ) begin
          fp16_med_out[b][27 : 0] = operands_fp0[b][0];
        end else begin 
          fp6_med_out[b][27 : 0] = operands_fp1[b][0];
        end

        if(
          ((operands_fp0[b][1][15] == 1'b0) && (operands_fp1[b][1][15] == 1'b0) && (operands_fp0[b][1][14 : 0] > operands_fp1[b][1][14 : 0] ) ) ||
           ((operands_fp0[b][1][15] == 1'b1) && (operands_fp1[b][1][15] == 1'b1) && (operands_fp0[b][1][14 : 0] < operands_fp1[b][1][14 : 0] ) ) ||
            (operands_fp0[b][1][15] == 1'b0) && (operands_fp1[b][1][15] == 1'b1)
        ) begin
          fp16_med_out[b][55 : 28] = operands_fp0[b][1];
        end else begin 
          fp16_med_out[b][55 : 28] = operands_fp1[b][1];
        end

        if(
          ((operands_fp0[b][2][15] == 1'b0) && (operands_fp1[b][2][15] == 1'b0) && (operands_fp0[b][2][14 : 0] > operands_fp1[b][2][14 : 0] ) ) ||
           ((operands_fp0[b][2][15] == 1'b1) && (operands_fp1[b][2][15] == 1'b1) && (operands_fp0[b][2][14 : 0] < operands_fp1[b][2][14 : 0] ) ) ||
            (operands_fp0[b][2][15] == 1'b0) && (operands_fp1[b][2][15] == 1'b1)
        ) begin
          fp16_med_out[b][83 : 56] = operands_fp0[b][2];
        end else begin 
          fp16_med_out[b][83 : 56] = operands_fp1[b][2];
        end

        if(
          ((operands_fp0[b][3][15] == 1'b0) && (operands_fp1[b][3][15] == 1'b0) && (operands_fp0[b][3][14 : 0] > operands_fp1[b][3][14 : 0] ) ) ||
           ((operands_fp0[b][3][15] == 1'b1) && (operands_fp1[b][3][15] == 1'b1) && (operands_fp0[b][3][14 : 0] < operands_fp1[b][3][14 : 0] ) ) ||
            (operands_fp0[b][3][15] == 1'b0) && (operands_fp1[b][3][15] == 1'b1)
        ) begin
          fp16_med_out[b][111 : 84] = operands_fp0[b][3];
        end else begin 
          fp16_med_out[b][111 : 84] = operands_fp1[b][3];
        end
    end 
end

assign med2d_out =  (reg2dp_int8_en & core_enable) ? int8_med_out : 
                    (reg2dp_int16_en & core_enable) ? int16_med_out : 
                    (reg2dp_fp16_en & core_enable) ? fp16_med_out : 0;

endmodule
