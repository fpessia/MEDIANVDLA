`timescale 10ps/1ps
module NV_NVDLA_PDP_CORE_med2d_core3x3(
    input enable,
    input [111 : 0] A,
    input [111 : 0] B,

    input [3 : 0][11 : 0] codes,/*lut interface for operator2D_1*/
    output [3 : 0][3 : 0] msb_i,
    output [3 : 0][3 : 0] msb_j,    
    output [3 : 0][3 : 0] msb_k,
    output [3 : 0][3 : 0] msb_w,

    output [3 : 0][11 : 0] to_decode, /*lut interface for operator2D_2*/
    input  [3 : 0][3 : 0] decoded_msbs_i,
    input  [3 : 0][3 : 0] decoded_msbs_j,
    input  [3 : 0][3 : 0] decoded_msbs_k,
    input  [3 : 0][3 : 0] decoded_msbs_w,

    output[111 : 0] Median
);

wire [3 : 0] sel_operator;
wire [3 : 0][27 : 0] operands_A;
wire [3 : 0][27 : 0] operands_B;

wire [3 : 0][2 : 0][4 : 0] lsbs_suboperands_A;
wire [3 : 0][2 : 0][4 : 0] lsbs_suboperands_B;
wire [3 : 0][6 : 0] codes_A;
wire [3 : 0][6 : 0] codes_B;
wire [2 : 0][3 : 0][2 : 0] MSBs_A;
wire [2 : 0][3 : 0][2 : 0] MSBs_B;
wire [1 : 0][6 : 0] unused_lut_encoding;
wire [3 : 0][2 : 0][5 : 0][7 : 0] combos_A;
wire [3 : 0][2 : 0][5 : 0][7 : 0] combos_B;
wire [3 : 0][5 : 0] sorted_combo_A;
wire [3 : 0][5 : 0] sorted_combo_B;
wire [3 : 0][2 : 0][7 : 0] suboperands_A;
wire [3 : 0][2 : 0][7 : 0] suboperands_B;
wire [3 : 0][11 : 0] comparator_tree_flags;
wire [3 : 0][31 : 0] sorted_concatenated_drop_suboperands;/*at this stage we can drop up to 2 data since we know for sure that are not going to be median value*/
wire [111 : 0] operator2D_1_out;


wire [3 : 0][1 : 0] sel_operands2;
wire [3 : 0][1 : 0] sel_operands1;
wire [3 : 0][3 : 0][7 : 0] operands1;
wire [3 : 0][2 : 0][7 : 0] operands2;
wire        [2 : 0][7 : 0] zero_operand;
wire [3 : 0][3 : 0][3 : 0] LSBs_operands1;
wire [3 : 0][3 : 0][23 : 0][7 : 0] combos_operands1;
wire [3 : 0][23 : 0] sorted_combos_operands1;
wire        [3 : 0]     zeros_LSBs;
wire        [7 : 0]     zeros_operand1;
wire [3 : 0][8 : 0] median_comparator_tree_flags;
wire [3 : 0]        to_extend_sign;
wire [111 : 0] operator2D_2_out;

/*unpaking operands*/
assign operands_A[0] = A[27 : 0];
assign operands_A[1] = A[55 : 28];
assign operands_A[2] = A[83 : 56];
assign operands_A[3] = A[111 : 84];

assign operands_B[0] = B[27 : 0];
assign operands_B[1] = B[55 : 28];
assign operands_B[2] = B[83 : 56];
assign operands_B[3] = B[111 : 84];

/*check if msbs are only sign extention or have been already modifyed by this unit, 1--sel_op_2D_1, 0--sel_op_2D_2 */
assign sel_operator[0] = ((operands_A[0][27] & operands_A[0][26] & operands_A[0][25] & operands_A[0][24] & operands_A[0][23] & operands_A[0][22]) ||
            (~(operands_A[0][27]) & ~(operands_A[0][26]) & ~(operands_A[0][25]) & ~(operands_A[0][24]) & ~(operands_A[0][23]) & ~(operands_A[0][22]))) &
            ((operands_B[0][27] & operands_B[0][26] & operands_B[0][25] & operands_B[0][24] & operands_B[0][23] & operands_B[0][22]) ||
            (~(operands_B[0][27]) & ~(operands_B[0][26]) & ~(operands_B[0][25]) & ~(operands_B[0][24]) & ~(operands_B[0][23]) & ~(operands_B[0][22])));

assign sel_operator[1] = ((operands_A[1][27] & operands_A[1][26] & operands_A[1][25] & operands_A[1][24] & operands_A[1][23] & operands_A[1][22]) ||
            (~(operands_A[1][27]) & ~(operands_A[1][26]) & ~(operands_A[1][25]) & ~(operands_A[1][24]) & ~(operands_A[1][23]) & ~(operands_A[1][22]))) &
            ((operands_B[1][27] & operands_B[1][26] & operands_B[1][25] & operands_B[1][24] & operands_B[1][23] & operands_B[1][22]) ||
            (~(operands_B[1][27]) & ~(operands_B[1][26]) & ~(operands_B[1][25]) & ~(operands_B[1][24]) & ~(operands_B[1][23]) & ~(operands_B[1][22])));

assign sel_operator[2] = ((operands_A[2][27] & operands_A[2][26] & operands_A[2][25] & operands_A[2][24] & operands_A[2][23] & operands_A[2][22]) ||
            (~(operands_A[2][27]) & ~(operands_A[2][26]) & ~(operands_A[2][25]) & ~(operands_A[2][24]) & ~(operands_A[2][23]) & ~(operands_A[2][22]))) &
            ((operands_B[2][27] & operands_B[2][26] & operands_B[2][25] & operands_B[2][24] & operands_B[2][23] & operands_B[2][22]) ||
            (~(operands_B[2][27]) & ~(operands_B[2][26]) & ~(operands_B[2][25]) & ~(operands_B[2][24]) & ~(operands_B[2][23]) & ~(operands_B[2][22])));

assign sel_operator[3] = ((operands_A[3][27] & operands_A[3][26] & operands_A[3][25] & operands_A[3][24] & operands_A[3][23] & operands_A[3][22]) ||
            (~(operands_A[3][27]) & ~(operands_A[3][26]) & ~(operands_A[3][25]) & ~(operands_A[3][24]) & ~(operands_A[3][23]) & ~(operands_A[3][22]))) &
            ((operands_B[3][27] & operands_B[3][26] & operands_B[3][25] & operands_B[3][24] & operands_B[3][23] & operands_B[3][22]) ||
            (~(operands_B[3][27]) & ~(operands_B[3][26]) & ~(operands_B[3][25]) & ~(operands_B[3][24]) & ~(operands_B[3][23]) & ~(operands_B[3][22])));


assign Median[27 : 0] = (sel_operator[0] & enable) ? operator2D_1_out[27 : 0] : (enable) ?  operator2D_2_out[27 : 0] : 0;
assign Median[55 : 28] = (sel_operator[1] & enable) ? operator2D_1_out[55 : 28] : (enable) ? operator2D_2_out[55 : 28] : 0;
assign Median[83 : 56] = (sel_operator[2] & enable) ? operator2D_1_out[83 : 56] : (enable) ?  operator2D_2_out[83 : 56] : 0;
assign Median[111 : 84] = (sel_operator[3] & enable) ? operator2D_1_out[111 : 84] : (enable) ? operator2D_2_out[111 : 84] : 0;



/*OPERATOR 2D_1*/

/*unpaking suboperands*/
assign lsbs_suboperands_A[0][0] = operands_A[0][4 : 0];
assign lsbs_suboperands_A[0][1] = operands_A[0][9 : 5];
assign lsbs_suboperands_A[0][2] = operands_A[0][14 : 10];

assign lsbs_suboperands_A[1][0] = operands_A[1][4 : 0];
assign lsbs_suboperands_A[1][1] = operands_A[1][9 : 5];
assign lsbs_suboperands_A[1][2] = operands_A[1][14 : 10];

assign lsbs_suboperands_A[2][0] = operands_A[2][4 : 0];
assign lsbs_suboperands_A[2][1] = operands_A[2][9 : 5];
assign lsbs_suboperands_A[2][2] = operands_A[2][14 : 10];

assign lsbs_suboperands_A[3][0] = operands_A[3][4 : 0];
assign lsbs_suboperands_A[3][1] = operands_A[3][9 : 5];
assign lsbs_suboperands_A[3][2] = operands_A[3][14 : 10];

assign lsbs_suboperands_B[0][0] = operands_B[0][4 : 0];
assign lsbs_suboperands_B[0][1] = operands_B[0][9 : 5];
assign lsbs_suboperands_B[0][2] = operands_B[0][14 : 10];

assign lsbs_suboperands_B[1][0] = operands_B[1][4 : 0];
assign lsbs_suboperands_B[1][1] = operands_B[1][9 : 5];
assign lsbs_suboperands_B[1][2] = operands_B[1][14 : 10];

assign lsbs_suboperands_B[2][0] = operands_B[2][4 : 0];
assign lsbs_suboperands_B[2][1] = operands_B[2][9 : 5];
assign lsbs_suboperands_B[2][2] = operands_B[2][14 : 10];

assign lsbs_suboperands_B[3][0] = operands_B[3][4 : 0];
assign lsbs_suboperands_B[3][1] = operands_B[3][9 : 5];
assign lsbs_suboperands_B[3][2] = operands_B[3][14 : 10];

assign codes_A[0] = operands_A[0][21 : 15];
assign codes_A[1] = operands_A[1][21 : 15];
assign codes_A[2] = operands_A[2][21 : 15];
assign codes_A[3] = operands_A[3][21 : 15];

assign codes_B[0] = operands_B[0][21 : 15];
assign codes_B[1] = operands_B[1][21 : 15];
assign codes_B[2] = operands_B[2][21 : 15];
assign codes_B[3] = operands_B[3][21 : 15];

/*MSBs reconstruction, decoding method lut1d.py, latency =  1 signed comparator + 1 lut acces */
NV_NVDLA_PDP_CORE_med1d_lut lut0(
.encoding(1'b0), //to reduce power consumption from LUT
.decoding(enable),
.uint8_A_msbs(3'b0),
.uint8_B_msbs(3'b0),
.uint8_C_msbs(3'b0),
.to_decode(codes_A),
.LUT_encoding(unused_lut_encoding[0]),
.decoded_msb_i(MSBs_A[0]),
.decoded_msb_j(MSBs_A[1]),
.decoded_msb_k(MSBs_A[2])
);


NV_NVDLA_PDP_CORE_med1d_lut lut1(
.encoding(1'b0), //to reduce power consumption from LUT
.decoding(enable),
.uint8_A_msbs(3'b0),
.uint8_B_msbs(3'b0),
.uint8_C_msbs(3'b0),
.to_decode(codes_B),
.LUT_encoding(unused_lut_encoding[1]),
.decoded_msb_i(MSBs_B[0]),
.decoded_msb_j(MSBs_B[1]),
.decoded_msb_k(MSBs_B[2])
);


assign combos_A[0][0][0] = {MSBs_A[0][0] , lsbs_suboperands_A[0][0]}; 
assign combos_A[0][1][0] = {MSBs_A[1][0] , lsbs_suboperands_A[0][1]}; 
assign combos_A[0][2][0] = {MSBs_A[2][0] , lsbs_suboperands_A[0][2]};
assign combos_A[0][0][1] = {MSBs_A[0][0] , lsbs_suboperands_A[0][0]}; 
assign combos_A[0][1][1] = {MSBs_A[2][0] , lsbs_suboperands_A[0][1]}; 
assign combos_A[0][2][1] = {MSBs_A[1][0] , lsbs_suboperands_A[0][2]}; 
assign combos_A[0][0][2] = {MSBs_A[1][0] , lsbs_suboperands_A[0][0]}; 
assign combos_A[0][1][2] = {MSBs_A[0][0] , lsbs_suboperands_A[0][1]}; 
assign combos_A[0][2][2] = {MSBs_A[2][0] , lsbs_suboperands_A[0][2]}; 
assign combos_A[0][0][3] = {MSBs_A[1][0] , lsbs_suboperands_A[0][0]}; 
assign combos_A[0][1][3] = {MSBs_A[2][0] , lsbs_suboperands_A[0][1]}; 
assign combos_A[0][2][3] = {MSBs_A[0][0] , lsbs_suboperands_A[0][2]}; 
assign combos_A[0][0][4] = {MSBs_A[2][0] , lsbs_suboperands_A[0][0]}; 
assign combos_A[0][1][4] = {MSBs_A[0][0] , lsbs_suboperands_A[0][1]}; 
assign combos_A[0][2][4] = {MSBs_A[1][0] , lsbs_suboperands_A[0][2]}; 
assign combos_A[0][0][5] = {MSBs_A[2][0] , lsbs_suboperands_A[0][0]}; 
assign combos_A[0][1][5] = {MSBs_A[1][0] , lsbs_suboperands_A[0][1]}; 
assign combos_A[0][2][5] = {MSBs_A[0][0] , lsbs_suboperands_A[0][2]}; 

assign combos_A[1][0][0] = {MSBs_A[1][1] , lsbs_suboperands_A[1][0]}; 
assign combos_A[1][1][0] = {MSBs_A[1][1] , lsbs_suboperands_A[1][1]}; 
assign combos_A[1][2][0] = {MSBs_A[2][1] , lsbs_suboperands_A[1][2]};
assign combos_A[1][0][1] = {MSBs_A[0][1] , lsbs_suboperands_A[1][0]}; 
assign combos_A[1][1][1] = {MSBs_A[2][1] , lsbs_suboperands_A[1][1]}; 
assign combos_A[1][2][1] = {MSBs_A[1][1] , lsbs_suboperands_A[1][2]}; 
assign combos_A[1][0][2] = {MSBs_A[1][1] , lsbs_suboperands_A[1][0]}; 
assign combos_A[1][1][2] = {MSBs_A[0][1] , lsbs_suboperands_A[1][1]}; 
assign combos_A[1][2][2] = {MSBs_A[2][1] , lsbs_suboperands_A[1][2]}; 
assign combos_A[1][0][3] = {MSBs_A[1][1] , lsbs_suboperands_A[1][0]}; 
assign combos_A[1][1][3] = {MSBs_A[2][1] , lsbs_suboperands_A[1][1]}; 
assign combos_A[1][2][3] = {MSBs_A[0][1] , lsbs_suboperands_A[1][2]}; 
assign combos_A[1][0][4] = {MSBs_A[2][1] , lsbs_suboperands_A[1][0]}; 
assign combos_A[1][1][4] = {MSBs_A[0][1] , lsbs_suboperands_A[1][1]}; 
assign combos_A[1][2][4] = {MSBs_A[1][1] , lsbs_suboperands_A[1][2]}; 
assign combos_A[1][0][5] = {MSBs_A[2][1] , lsbs_suboperands_A[1][0]}; 
assign combos_A[1][1][5] = {MSBs_A[1][1] , lsbs_suboperands_A[1][1]}; 
assign combos_A[1][2][5] = {MSBs_A[0][1] , lsbs_suboperands_A[1][2]}; 

assign combos_A[2][0][0] = {MSBs_A[0][2] , lsbs_suboperands_A[2][0]}; 
assign combos_A[2][1][0] = {MSBs_A[1][2] , lsbs_suboperands_A[2][1]}; 
assign combos_A[2][2][0] = {MSBs_A[2][2] , lsbs_suboperands_A[2][2]};
assign combos_A[2][0][1] = {MSBs_A[0][2] , lsbs_suboperands_A[2][0]}; 
assign combos_A[2][1][1] = {MSBs_A[2][2] , lsbs_suboperands_A[2][1]}; 
assign combos_A[2][2][1] = {MSBs_A[1][2] , lsbs_suboperands_A[2][2]}; 
assign combos_A[2][0][2] = {MSBs_A[1][2] , lsbs_suboperands_A[2][0]}; 
assign combos_A[2][1][2] = {MSBs_A[0][2] , lsbs_suboperands_A[2][1]}; 
assign combos_A[2][2][2] = {MSBs_A[2][2] , lsbs_suboperands_A[2][2]}; 
assign combos_A[2][0][3] = {MSBs_A[1][2] , lsbs_suboperands_A[2][0]}; 
assign combos_A[2][1][3] = {MSBs_A[2][2] , lsbs_suboperands_A[2][1]}; 
assign combos_A[2][2][3] = {MSBs_A[0][2] , lsbs_suboperands_A[2][2]}; 
assign combos_A[2][0][4] = {MSBs_A[2][2] , lsbs_suboperands_A[2][0]}; 
assign combos_A[2][1][4] = {MSBs_A[0][2] , lsbs_suboperands_A[2][1]}; 
assign combos_A[2][2][4] = {MSBs_A[1][2] , lsbs_suboperands_A[2][2]}; 
assign combos_A[2][0][5] = {MSBs_A[2][2] , lsbs_suboperands_A[2][0]}; 
assign combos_A[2][1][5] = {MSBs_A[1][2] , lsbs_suboperands_A[2][1]}; 
assign combos_A[2][2][5] = {MSBs_A[0][2] , lsbs_suboperands_A[2][2]}; 

assign combos_A[3][0][0] = {MSBs_A[0][3] , lsbs_suboperands_A[3][0]}; 
assign combos_A[3][1][0] = {MSBs_A[1][3] , lsbs_suboperands_A[3][1]}; 
assign combos_A[3][2][0] = {MSBs_A[2][3] , lsbs_suboperands_A[3][2]};
assign combos_A[3][0][1] = {MSBs_A[0][3] , lsbs_suboperands_A[3][0]}; 
assign combos_A[3][1][1] = {MSBs_A[2][3] , lsbs_suboperands_A[3][1]}; 
assign combos_A[3][2][1] = {MSBs_A[1][3] , lsbs_suboperands_A[3][2]}; 
assign combos_A[3][0][2] = {MSBs_A[1][3] , lsbs_suboperands_A[3][0]}; 
assign combos_A[3][1][2] = {MSBs_A[0][3] , lsbs_suboperands_A[3][1]}; 
assign combos_A[3][2][2] = {MSBs_A[2][3] , lsbs_suboperands_A[3][2]}; 
assign combos_A[3][0][3] = {MSBs_A[1][3] , lsbs_suboperands_A[3][0]}; 
assign combos_A[3][1][3] = {MSBs_A[2][3] , lsbs_suboperands_A[3][1]}; 
assign combos_A[3][2][3] = {MSBs_A[0][3] , lsbs_suboperands_A[3][2]}; 
assign combos_A[3][0][4] = {MSBs_A[2][3] , lsbs_suboperands_A[3][0]}; 
assign combos_A[3][1][4] = {MSBs_A[0][3] , lsbs_suboperands_A[3][1]}; 
assign combos_A[3][2][4] = {MSBs_A[1][3] , lsbs_suboperands_A[3][2]}; 
assign combos_A[3][0][5] = {MSBs_A[2][3] , lsbs_suboperands_A[3][0]}; 
assign combos_A[3][1][5] = {MSBs_A[1][3] , lsbs_suboperands_A[3][1]}; 
assign combos_A[3][2][5] = {MSBs_A[0][3] , lsbs_suboperands_A[3][2]}; 




assign combos_B[0][0][0] = {MSBs_B[0][0] , lsbs_suboperands_B[0][0]}; 
assign combos_B[0][1][0] = {MSBs_B[1][0] , lsbs_suboperands_B[0][1]}; 
assign combos_B[0][2][0] = {MSBs_B[2][0] , lsbs_suboperands_B[0][2]};
assign combos_B[0][0][1] = {MSBs_B[0][0] , lsbs_suboperands_B[0][0]}; 
assign combos_B[0][1][1] = {MSBs_B[2][0] , lsbs_suboperands_B[0][1]}; 
assign combos_B[0][2][1] = {MSBs_B[1][0] , lsbs_suboperands_B[0][2]}; 
assign combos_B[0][0][2] = {MSBs_B[1][0] , lsbs_suboperands_B[0][0]}; 
assign combos_B[0][1][2] = {MSBs_B[0][0] , lsbs_suboperands_B[0][1]}; 
assign combos_B[0][2][2] = {MSBs_B[2][0] , lsbs_suboperands_B[0][2]}; 
assign combos_B[0][0][3] = {MSBs_B[1][0] , lsbs_suboperands_B[0][0]}; 
assign combos_B[0][1][3] = {MSBs_B[2][0] , lsbs_suboperands_B[0][1]}; 
assign combos_B[0][2][3] = {MSBs_B[0][0] , lsbs_suboperands_B[0][2]}; 
assign combos_B[0][0][4] = {MSBs_B[2][0] , lsbs_suboperands_B[0][0]}; 
assign combos_B[0][1][4] = {MSBs_B[0][0] , lsbs_suboperands_B[0][1]}; 
assign combos_B[0][2][4] = {MSBs_B[1][0] , lsbs_suboperands_B[0][2]}; 
assign combos_B[0][0][5] = {MSBs_B[2][0] , lsbs_suboperands_B[0][0]}; 
assign combos_B[0][1][5] = {MSBs_B[1][0] , lsbs_suboperands_B[0][1]}; 
assign combos_B[0][2][5] = {MSBs_B[0][0] , lsbs_suboperands_B[0][2]}; 

assign combos_B[1][0][0] = {MSBs_B[0][1] , lsbs_suboperands_B[1][0]}; 
assign combos_B[1][1][0] = {MSBs_B[1][1] , lsbs_suboperands_B[1][1]}; 
assign combos_B[1][2][0] = {MSBs_B[2][1] , lsbs_suboperands_B[1][2]};
assign combos_B[1][0][1] = {MSBs_B[0][1] , lsbs_suboperands_B[1][0]}; 
assign combos_B[1][1][1] = {MSBs_B[2][1] , lsbs_suboperands_B[1][1]}; 
assign combos_B[1][2][1] = {MSBs_B[1][1] , lsbs_suboperands_B[1][2]}; 
assign combos_B[1][0][2] = {MSBs_B[1][1] , lsbs_suboperands_B[1][0]}; 
assign combos_B[1][1][2] = {MSBs_B[0][1] , lsbs_suboperands_B[1][1]}; 
assign combos_B[1][2][2] = {MSBs_B[2][1] , lsbs_suboperands_B[1][2]}; 
assign combos_B[1][0][3] = {MSBs_B[1][1] , lsbs_suboperands_B[1][0]}; 
assign combos_B[1][1][3] = {MSBs_B[2][1] , lsbs_suboperands_B[1][1]}; 
assign combos_B[1][2][3] = {MSBs_B[0][1] , lsbs_suboperands_B[1][2]}; 
assign combos_B[1][0][4] = {MSBs_B[2][1] , lsbs_suboperands_B[1][0]}; 
assign combos_B[1][1][4] = {MSBs_B[0][1] , lsbs_suboperands_B[1][1]}; 
assign combos_B[1][2][4] = {MSBs_B[1][1] , lsbs_suboperands_B[1][2]}; 
assign combos_B[1][0][5] = {MSBs_B[2][1] , lsbs_suboperands_B[1][0]}; 
assign combos_B[1][1][5] = {MSBs_B[1][1] , lsbs_suboperands_B[1][1]}; 
assign combos_B[1][2][5] = {MSBs_B[0][1] , lsbs_suboperands_B[1][2]}; 

assign combos_B[2][0][0] = {MSBs_B[0][2] , lsbs_suboperands_B[2][0]}; 
assign combos_B[2][1][0] = {MSBs_B[1][2] , lsbs_suboperands_B[2][1]}; 
assign combos_B[2][2][0] = {MSBs_B[2][2] , lsbs_suboperands_B[2][2]};
assign combos_B[2][0][1] = {MSBs_B[0][2] , lsbs_suboperands_B[2][0]}; 
assign combos_B[2][1][1] = {MSBs_B[2][2] , lsbs_suboperands_B[2][1]}; 
assign combos_B[2][2][1] = {MSBs_B[1][2] , lsbs_suboperands_B[2][2]}; 
assign combos_B[2][0][2] = {MSBs_B[1][2] , lsbs_suboperands_B[2][0]}; 
assign combos_B[2][1][2] = {MSBs_B[0][2] , lsbs_suboperands_B[2][1]}; 
assign combos_B[2][2][2] = {MSBs_B[2][2] , lsbs_suboperands_B[2][2]}; 
assign combos_B[2][0][3] = {MSBs_B[1][2] , lsbs_suboperands_B[2][0]}; 
assign combos_B[2][1][3] = {MSBs_B[2][2] , lsbs_suboperands_B[2][1]}; 
assign combos_B[2][2][3] = {MSBs_B[0][2] , lsbs_suboperands_B[2][2]}; 
assign combos_B[2][0][4] = {MSBs_B[2][2] , lsbs_suboperands_B[2][0]}; 
assign combos_B[2][1][4] = {MSBs_B[0][2] , lsbs_suboperands_B[2][1]}; 
assign combos_B[2][2][4] = {MSBs_B[1][2] , lsbs_suboperands_B[2][2]}; 
assign combos_B[2][0][5] = {MSBs_B[2][2] , lsbs_suboperands_B[2][0]}; 
assign combos_B[2][1][5] = {MSBs_B[1][2] , lsbs_suboperands_B[2][1]}; 
assign combos_B[2][2][5] = {MSBs_B[0][2] , lsbs_suboperands_B[2][2]}; 

assign combos_B[3][0][0] = {MSBs_B[0][3] , lsbs_suboperands_B[3][0]}; 
assign combos_B[3][1][0] = {MSBs_B[1][3] , lsbs_suboperands_B[3][1]}; 
assign combos_B[3][2][0] = {MSBs_B[2][3] , lsbs_suboperands_B[3][2]};
assign combos_B[3][0][1] = {MSBs_B[0][3] , lsbs_suboperands_B[3][0]}; 
assign combos_B[3][1][1] = {MSBs_B[2][3] , lsbs_suboperands_B[3][1]}; 
assign combos_B[3][2][1] = {MSBs_B[1][3] , lsbs_suboperands_B[3][2]}; 
assign combos_B[3][0][2] = {MSBs_B[1][3] , lsbs_suboperands_B[3][0]}; 
assign combos_B[3][1][2] = {MSBs_B[0][3] , lsbs_suboperands_B[3][1]}; 
assign combos_B[3][2][2] = {MSBs_B[2][3] , lsbs_suboperands_B[3][2]}; 
assign combos_B[3][0][3] = {MSBs_B[1][3] , lsbs_suboperands_B[3][0]}; 
assign combos_B[3][1][3] = {MSBs_B[2][3] , lsbs_suboperands_B[3][1]}; 
assign combos_B[3][2][3] = {MSBs_B[0][3] , lsbs_suboperands_B[3][2]}; 
assign combos_B[3][0][4] = {MSBs_B[2][3] , lsbs_suboperands_B[3][0]}; 
assign combos_B[3][1][4] = {MSBs_B[0][3] , lsbs_suboperands_B[3][1]}; 
assign combos_B[3][2][4] = {MSBs_B[1][3] , lsbs_suboperands_B[3][2]}; 
assign combos_B[3][0][5] = {MSBs_B[2][3] , lsbs_suboperands_B[3][0]}; 
assign combos_B[3][1][5] = {MSBs_B[1][3] , lsbs_suboperands_B[3][1]}; 
assign combos_B[3][2][5] = {MSBs_B[0][3] , lsbs_suboperands_B[3][2]}; 



assign sorted_combo_A[0][0] = ($signed(combos_A[0][2][0]) <= $signed(combos_A[0][1][0]) && $signed(combos_A[0][1][0]) <= $signed(combos_A[0][0][0])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[0][1] = ($signed(combos_A[0][2][1]) <= $signed(combos_A[0][1][1]) && $signed(combos_A[0][1][1]) <= $signed(combos_A[0][0][1])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[0][2] = ($signed(combos_A[0][2][2]) <= $signed(combos_A[0][1][2]) && $signed(combos_A[0][1][2]) <= $signed(combos_A[0][0][2])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[0][3] = ($signed(combos_A[0][2][3]) <= $signed(combos_A[0][1][3]) && $signed(combos_A[0][1][3]) <= $signed(combos_A[0][0][3])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[0][4] = ($signed(combos_A[0][2][4]) <= $signed(combos_A[0][1][4]) && $signed(combos_A[0][1][4]) <= $signed(combos_A[0][0][4])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[0][5] = ($signed(combos_A[0][2][5]) <= $signed(combos_A[0][1][5]) && $signed(combos_A[0][1][5]) <= $signed(combos_A[0][0][5])) ? 1'b1 : 1'b0; 

assign suboperands_A[0][0] = (sorted_combo_A[0][0]) ? combos_A[0][0][0] : 
                             (sorted_combo_A[0][1]) ? combos_A[0][0][1] :
                             (sorted_combo_A[0][2]) ? combos_A[0][0][2] :
                             (sorted_combo_A[0][3]) ? combos_A[0][0][3] :   
                             (sorted_combo_A[0][4]) ? combos_A[0][0][4] : 
                             (sorted_combo_A[0][5]) ? combos_A[0][0][5] : 8'b0;

assign suboperands_A[0][1] = (sorted_combo_A[0][0]) ? combos_A[0][1][0] : 
                             (sorted_combo_A[0][1]) ? combos_A[0][1][1] :
                             (sorted_combo_A[0][2]) ? combos_A[0][1][2] :
                             (sorted_combo_A[0][3]) ? combos_A[0][1][3] :   
                             (sorted_combo_A[0][4]) ? combos_A[0][1][4] : 
                             (sorted_combo_A[0][5]) ? combos_A[0][1][5] : 8'b0;

assign suboperands_A[0][2] = (sorted_combo_A[0][0]) ? combos_A[0][2][0] : 
                             (sorted_combo_A[0][1]) ? combos_A[0][2][1] :
                             (sorted_combo_A[0][2]) ? combos_A[0][2][2] :
                             (sorted_combo_A[0][3]) ? combos_A[0][2][3] :   
                             (sorted_combo_A[0][4]) ? combos_A[0][2][4] : 
                             (sorted_combo_A[0][5]) ? combos_A[0][2][5] : 8'b0;


assign sorted_combo_A[1][0] = ($signed(combos_A[1][2][0]) <= $signed(combos_A[1][1][0]) && $signed(combos_A[1][1][0]) <= $signed(combos_A[1][0][0])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[1][1] = ($signed(combos_A[1][2][1]) <= $signed(combos_A[1][1][1]) && $signed(combos_A[1][1][1]) <= $signed(combos_A[1][0][1])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[1][2] = ($signed(combos_A[1][2][2]) <= $signed(combos_A[1][1][2]) && $signed(combos_A[1][1][2]) <= $signed(combos_A[1][0][2])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[1][3] = ($signed(combos_A[1][2][3]) <= $signed(combos_A[1][1][3]) && $signed(combos_A[1][1][3]) <= $signed(combos_A[1][0][3])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[1][4] = ($signed(combos_A[1][2][4]) <= $signed(combos_A[1][1][4]) && $signed(combos_A[1][1][4]) <= $signed(combos_A[1][0][4])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[1][5] = ($signed(combos_A[1][2][5]) <= $signed(combos_A[1][1][5]) && $signed(combos_A[1][1][5]) <= $signed(combos_A[1][0][5])) ? 1'b1 : 1'b0;  

assign suboperands_A[1][0] = (sorted_combo_A[1][0]) ? combos_A[1][0][0] : 
                             (sorted_combo_A[1][1]) ? combos_A[1][0][1] :
                             (sorted_combo_A[1][2]) ? combos_A[1][0][2] :
                             (sorted_combo_A[1][3]) ? combos_A[1][0][3] :   
                             (sorted_combo_A[1][4]) ? combos_A[1][0][4] : 
                             (sorted_combo_A[1][5]) ? combos_A[1][0][5] : 8'b0;

assign suboperands_A[1][1] = (sorted_combo_A[1][0]) ? combos_A[1][1][0] : 
                             (sorted_combo_A[1][1]) ? combos_A[1][1][1] :
                             (sorted_combo_A[1][2]) ? combos_A[1][1][2] :
                             (sorted_combo_A[1][3]) ? combos_A[1][1][3] :   
                             (sorted_combo_A[1][4]) ? combos_A[1][1][4] : 
                             (sorted_combo_A[1][5]) ? combos_A[1][1][5] : 8'b0;

assign suboperands_A[1][2] = (sorted_combo_A[1][0]) ? combos_A[1][2][0] : 
                             (sorted_combo_A[1][1]) ? combos_A[1][2][1] :
                             (sorted_combo_A[1][2]) ? combos_A[1][2][2] :
                             (sorted_combo_A[1][3]) ? combos_A[1][2][3] :   
                             (sorted_combo_A[1][4]) ? combos_A[1][2][4] : 
                             (sorted_combo_A[1][5]) ? combos_A[1][2][5] : 8'b0;


assign sorted_combo_A[2][0] = ($signed(combos_A[2][2][0]) <= $signed(combos_A[2][1][0]) && $signed(combos_A[2][1][0]) <= $signed(combos_A[2][0][0])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[2][1] = ($signed(combos_A[2][2][1]) <= $signed(combos_A[2][1][1]) && $signed(combos_A[2][1][1]) <= $signed(combos_A[2][0][1])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[2][2] = ($signed(combos_A[2][2][2]) <= $signed(combos_A[2][1][2]) && $signed(combos_A[2][1][2]) <= $signed(combos_A[2][0][2])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[2][3] = ($signed(combos_A[2][2][3]) <= $signed(combos_A[2][1][3]) && $signed(combos_A[2][1][3]) <= $signed(combos_A[2][0][3])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[2][4] = ($signed(combos_A[2][2][4]) <= $signed(combos_A[2][1][4]) && $signed(combos_A[2][1][4]) <= $signed(combos_A[2][0][4])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[2][5] = ($signed(combos_A[2][2][5]) <= $signed(combos_A[2][1][5]) && $signed(combos_A[2][1][5]) <= $signed(combos_A[2][0][5])) ? 1'b1 : 1'b0; 

assign suboperands_A[2][0] = (sorted_combo_A[2][0]) ? combos_A[2][0][0] : 
                             (sorted_combo_A[2][1]) ? combos_A[2][0][1] :
                             (sorted_combo_A[2][2]) ? combos_A[2][0][2] :
                             (sorted_combo_A[2][3]) ? combos_A[2][0][3] :   
                             (sorted_combo_A[2][4]) ? combos_A[2][0][4] : 
                             (sorted_combo_A[2][5]) ? combos_A[2][0][5] : 8'b0;

assign suboperands_A[2][1] = (sorted_combo_A[2][0]) ? combos_A[2][1][0] : 
                             (sorted_combo_A[2][1]) ? combos_A[2][1][1] :
                             (sorted_combo_A[2][2]) ? combos_A[2][1][2] :
                             (sorted_combo_A[2][3]) ? combos_A[2][1][3] :   
                             (sorted_combo_A[2][4]) ? combos_A[2][1][4] : 
                             (sorted_combo_A[2][5]) ? combos_A[2][1][5] : 8'b0;

assign suboperands_A[2][2] = (sorted_combo_A[2][0]) ? combos_A[2][2][0] : 
                             (sorted_combo_A[2][1]) ? combos_A[2][2][1] :
                             (sorted_combo_A[2][2]) ? combos_A[2][2][2] :
                             (sorted_combo_A[2][3]) ? combos_A[2][2][3] :   
                             (sorted_combo_A[2][4]) ? combos_A[2][2][4] : 
                             (sorted_combo_A[2][5]) ? combos_A[2][2][5] : 8'b0;


assign sorted_combo_A[3][0] = ($signed(combos_A[3][2][0]) <= $signed(combos_A[3][1][0]) && $signed(combos_A[3][1][0]) <= $signed(combos_A[3][0][0])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[3][1] = ($signed(combos_A[3][2][1]) <= $signed(combos_A[3][1][1]) && $signed(combos_A[3][1][1]) <= $signed(combos_A[3][0][1])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[3][2] = ($signed(combos_A[3][2][2]) <= $signed(combos_A[3][1][2]) && $signed(combos_A[3][1][2]) <= $signed(combos_A[3][0][2])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[3][3] = ($signed(combos_A[3][2][3]) <= $signed(combos_A[3][1][3]) && $signed(combos_A[3][1][3]) <= $signed(combos_A[3][0][3])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[3][4] = ($signed(combos_A[3][2][4]) <= $signed(combos_A[3][1][4]) && $signed(combos_A[3][1][4]) <= $signed(combos_A[3][0][4])) ? 1'b1 : 1'b0; 
assign sorted_combo_A[3][5] = ($signed(combos_A[3][2][5]) <= $signed(combos_A[3][1][5]) && $signed(combos_A[3][1][5]) <= $signed(combos_A[3][0][5])) ? 1'b1 : 1'b0; 

assign suboperands_A[3][0] = (sorted_combo_A[3][0]) ? combos_A[3][0][0] : 
                             (sorted_combo_A[3][1]) ? combos_A[3][0][1] :
                             (sorted_combo_A[3][2]) ? combos_A[3][0][2] :
                             (sorted_combo_A[3][3]) ? combos_A[3][0][3] :   
                             (sorted_combo_A[3][4]) ? combos_A[3][0][4] : 
                             (sorted_combo_A[3][5]) ? combos_A[3][0][5] : 8'b0;

assign suboperands_A[3][1] = (sorted_combo_A[3][0]) ? combos_A[3][1][0] : 
                             (sorted_combo_A[3][1]) ? combos_A[3][1][1] :
                             (sorted_combo_A[3][2]) ? combos_A[3][1][2] :
                             (sorted_combo_A[3][3]) ? combos_A[3][1][3] :   
                             (sorted_combo_A[3][4]) ? combos_A[3][1][4] : 
                             (sorted_combo_A[3][5]) ? combos_A[3][1][5] : 8'b0;

assign suboperands_A[3][2] = (sorted_combo_A[3][0]) ? combos_A[3][2][0] : 
                             (sorted_combo_A[3][1]) ? combos_A[3][2][1] :
                             (sorted_combo_A[3][2]) ? combos_A[3][2][2] :
                             (sorted_combo_A[3][3]) ? combos_A[3][2][3] :   
                             (sorted_combo_A[3][4]) ? combos_A[3][2][4] : 
                             (sorted_combo_A[3][5]) ? combos_A[3][2][5] : 8'b0;


assign sorted_combo_B[0][0] = ($signed(combos_B[0][2][0]) <= $signed(combos_B[0][1][0]) && $signed(combos_B[0][1][0]) <= $signed(combos_B[0][0][0])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[0][1] = ($signed(combos_B[0][2][1]) <= $signed(combos_B[0][1][1]) && $signed(combos_B[0][1][1]) <= $signed(combos_B[0][0][1])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[0][2] = ($signed(combos_B[0][2][2]) <= $signed(combos_B[0][1][2]) && $signed(combos_B[0][1][2]) <= $signed(combos_B[0][0][2])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[0][3] = ($signed(combos_B[0][2][3]) <= $signed(combos_B[0][1][3]) && $signed(combos_B[0][1][3]) <= $signed(combos_B[0][0][3])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[0][4] = ($signed(combos_B[0][2][4]) <= $signed(combos_B[0][1][4]) && $signed(combos_B[0][1][4]) <= $signed(combos_B[0][0][4])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[0][5] = ($signed(combos_B[0][2][5]) <= $signed(combos_B[0][1][5]) && $signed(combos_B[0][1][5]) <= $signed(combos_B[0][0][5])) ? 1'b1 : 1'b0; 

assign suboperands_B[0][0] = (sorted_combo_B[0][0]) ? combos_B[0][0][0] : 
                             (sorted_combo_B[0][1]) ? combos_B[0][0][1] :
                             (sorted_combo_B[0][2]) ? combos_B[0][0][2] :
                             (sorted_combo_B[0][3]) ? combos_B[0][0][3] :   
                             (sorted_combo_B[0][4]) ? combos_B[0][0][4] : 
                             (sorted_combo_B[0][5]) ? combos_B[0][0][5] : 8'b0;

assign suboperands_B[0][1] = (sorted_combo_B[0][0]) ? combos_B[0][1][0] : 
                             (sorted_combo_B[0][1]) ? combos_B[0][1][1] :
                             (sorted_combo_B[0][2]) ? combos_B[0][1][2] :
                             (sorted_combo_B[0][3]) ? combos_B[0][1][3] :   
                             (sorted_combo_B[0][4]) ? combos_B[0][1][4] : 
                             (sorted_combo_B[0][5]) ? combos_B[0][1][5] : 8'b0;

assign suboperands_B[0][2] = (sorted_combo_B[0][0]) ? combos_B[0][2][0] : 
                             (sorted_combo_B[0][1]) ? combos_B[0][2][1] :
                             (sorted_combo_B[0][2]) ? combos_B[0][2][2] :
                             (sorted_combo_B[0][3]) ? combos_B[0][2][3] :   
                             (sorted_combo_B[0][4]) ? combos_B[0][2][4] : 
                             (sorted_combo_B[0][5]) ? combos_B[0][2][5] : 8'b0;


assign sorted_combo_B[1][0] = ($signed(combos_B[1][2][0]) <= $signed(combos_B[1][1][0]) && $signed(combos_B[1][1][0]) <= $signed(combos_B[1][0][0])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[1][1] = ($signed(combos_B[1][2][1]) <= $signed(combos_B[1][1][1]) && $signed(combos_B[1][1][1]) <= $signed(combos_B[1][0][1])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[1][2] = ($signed(combos_B[1][2][2]) <= $signed(combos_B[1][1][2]) && $signed(combos_B[1][1][2]) <= $signed(combos_B[1][0][2])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[1][3] = ($signed(combos_B[1][2][3]) <= $signed(combos_B[1][1][3]) && $signed(combos_B[1][1][3]) <= $signed(combos_B[1][0][3])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[1][4] = ($signed(combos_B[1][2][4]) <= $signed(combos_B[1][1][4]) && $signed(combos_B[1][1][4]) <= $signed(combos_B[1][0][4])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[1][5] = ($signed(combos_B[1][2][5]) <= $signed(combos_B[1][1][5]) && $signed(combos_B[1][1][5]) <= $signed(combos_B[1][0][5])) ? 1'b1 : 1'b0; 

assign suboperands_B[1][0] = (sorted_combo_B[1][0]) ? combos_B[1][0][0] : 
                             (sorted_combo_B[1][1]) ? combos_B[1][0][1] :
                             (sorted_combo_B[1][2]) ? combos_B[1][0][2] :
                             (sorted_combo_B[1][3]) ? combos_B[1][0][3] :   
                             (sorted_combo_B[1][4]) ? combos_B[1][0][4] : 
                             (sorted_combo_B[1][5]) ? combos_B[1][0][5] : 8'b0;

assign suboperands_B[1][1] = (sorted_combo_B[1][0]) ? combos_B[1][1][0] : 
                             (sorted_combo_B[1][1]) ? combos_B[1][1][1] :
                             (sorted_combo_B[1][2]) ? combos_B[1][1][2] :
                             (sorted_combo_B[1][3]) ? combos_B[1][1][3] :   
                             (sorted_combo_B[1][4]) ? combos_B[1][1][4] : 
                             (sorted_combo_B[1][5]) ? combos_B[1][1][5] : 8'b0;

assign suboperands_B[1][2] = (sorted_combo_B[1][0]) ? combos_B[1][2][0] : 
                             (sorted_combo_B[1][1]) ? combos_B[1][2][1] :
                             (sorted_combo_B[1][2]) ? combos_B[1][2][2] :
                             (sorted_combo_B[1][3]) ? combos_B[1][2][3] :   
                             (sorted_combo_B[1][4]) ? combos_B[1][2][4] : 
                             (sorted_combo_B[1][5]) ? combos_B[1][2][5] : 8'b0;


assign sorted_combo_B[2][0] = ($signed(combos_B[2][2][0]) <= $signed(combos_B[2][1][0]) && $signed(combos_B[2][1][0]) <= $signed(combos_B[2][0][0])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[2][1] = ($signed(combos_B[2][2][1]) <= $signed(combos_B[2][1][1]) && $signed(combos_B[2][1][1]) <= $signed(combos_B[2][0][1])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[2][2] = ($signed(combos_B[2][2][2]) <= $signed(combos_B[2][1][2]) && $signed(combos_B[2][1][2]) <= $signed(combos_B[2][0][2])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[2][3] = ($signed(combos_B[2][2][3]) <= $signed(combos_B[2][1][3]) && $signed(combos_B[2][1][3]) <= $signed(combos_B[2][0][3])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[2][4] = ($signed(combos_B[2][2][4]) <= $signed(combos_B[2][1][4]) && $signed(combos_B[2][1][4]) <= $signed(combos_B[2][0][4])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[2][5] = ($signed(combos_B[2][2][5]) <= $signed(combos_B[2][1][5]) && $signed(combos_B[2][1][5]) <= $signed(combos_B[2][0][5])) ? 1'b1 : 1'b0; 

assign suboperands_B[2][0] = (sorted_combo_B[2][0]) ? combos_B[2][0][0] : 
                             (sorted_combo_B[2][1]) ? combos_B[2][0][1] :
                             (sorted_combo_B[2][2]) ? combos_B[2][0][2] :
                             (sorted_combo_B[2][3]) ? combos_B[2][0][3] :   
                             (sorted_combo_B[2][4]) ? combos_B[2][0][4] : 
                             (sorted_combo_B[2][5]) ? combos_B[2][0][5] : 8'b0;

assign suboperands_B[2][1] = (sorted_combo_B[2][0]) ? combos_B[2][1][0] : 
                             (sorted_combo_B[2][1]) ? combos_B[2][1][1] :
                             (sorted_combo_B[2][2]) ? combos_B[2][1][2] :
                             (sorted_combo_B[2][3]) ? combos_B[2][1][3] :   
                             (sorted_combo_B[2][4]) ? combos_B[2][1][4] : 
                             (sorted_combo_B[2][5]) ? combos_B[2][1][5] : 8'b0;

assign suboperands_B[2][2] = (sorted_combo_B[2][0]) ? combos_B[2][2][0] : 
                             (sorted_combo_B[2][1]) ? combos_B[2][2][1] :
                             (sorted_combo_B[2][2]) ? combos_B[2][2][2] :
                             (sorted_combo_B[2][3]) ? combos_B[2][2][3] :   
                             (sorted_combo_B[2][4]) ? combos_B[2][2][4] : 
                             (sorted_combo_B[2][5]) ? combos_B[2][2][5] : 8'b0;

assign sorted_combo_B[3][0] = ($signed(combos_B[3][2][0]) <= $signed(combos_B[3][1][0]) && $signed(combos_B[3][1][0]) <= $signed(combos_B[3][0][0])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[3][1] = ($signed(combos_B[3][2][1]) <= $signed(combos_B[3][1][1]) && $signed(combos_B[3][1][1]) <= $signed(combos_B[3][0][1])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[3][2] = ($signed(combos_B[3][2][2]) <= $signed(combos_B[3][1][2]) && $signed(combos_B[3][1][2]) <= $signed(combos_B[3][0][2])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[3][3] = ($signed(combos_B[3][2][3]) <= $signed(combos_B[3][1][3]) && $signed(combos_B[3][1][3]) <= $signed(combos_B[3][0][3])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[3][4] = ($signed(combos_B[3][2][4]) <= $signed(combos_B[3][1][4]) && $signed(combos_B[3][1][4]) <= $signed(combos_B[3][0][4])) ? 1'b1 : 1'b0; 
assign sorted_combo_B[3][5] = ($signed(combos_B[3][2][5]) <= $signed(combos_B[3][1][5]) && $signed(combos_B[3][1][5]) <= $signed(combos_B[3][0][5])) ? 1'b1 : 1'b0; 

assign suboperands_B[3][0] = (sorted_combo_B[3][0]) ? combos_B[3][0][0] : 
                             (sorted_combo_B[3][1]) ? combos_B[3][0][1] :
                             (sorted_combo_B[3][2]) ? combos_B[3][0][2] :
                             (sorted_combo_B[3][3]) ? combos_B[3][0][3] :   
                             (sorted_combo_B[3][4]) ? combos_B[3][0][4] : 
                             (sorted_combo_B[3][5]) ? combos_B[3][0][5] : 8'b0;

assign suboperands_B[3][1] = (sorted_combo_B[3][0]) ? combos_B[3][1][0] : 
                             (sorted_combo_B[3][1]) ? combos_B[3][1][1] :
                             (sorted_combo_B[3][2]) ? combos_B[3][1][2] :
                             (sorted_combo_B[3][3]) ? combos_B[3][1][3] :   
                             (sorted_combo_B[3][4]) ? combos_B[3][1][4] : 
                             (sorted_combo_B[3][5]) ? combos_B[3][1][5] : 8'b0;

assign suboperands_B[3][2] = (sorted_combo_B[3][0]) ? combos_B[3][2][0] : 
                             (sorted_combo_B[3][1]) ? combos_B[3][2][1] :
                             (sorted_combo_B[3][2]) ? combos_B[3][2][2] :
                             (sorted_combo_B[3][3]) ? combos_B[3][2][3] :   
                             (sorted_combo_B[3][4]) ? combos_B[3][2][4] : 
                             (sorted_combo_B[3][5]) ? combos_B[3][2][5] : 8'b0;


/*SORTING PARTIALLY SORTED SUBOPERANDS, comparations performed in parallel
 and tree sequence sorting, overall_latency = 1 signed  + muxes(negligible) */
assign comparator_tree_flags[0][0] = ($signed(suboperands_A[0][1]) < $signed(suboperands_B[0][1])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[0][1] = ($signed(suboperands_A[0][0]) < $signed(suboperands_B[0][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[0][2] = ($signed(suboperands_A[0][0]) < $signed(suboperands_B[0][1])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[0][3] = ($signed(suboperands_A[0][1]) < $signed(suboperands_B[0][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[0][4] = ($signed(suboperands_A[0][2]) < $signed(suboperands_B[0][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[0][5] = ($signed(suboperands_A[0][0]) < $signed(suboperands_B[0][0])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[0][6] = 1'b0;
assign comparator_tree_flags[0][7] = ($signed(suboperands_B[0][0]) < $signed(suboperands_A[0][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[0][8] = ($signed(suboperands_B[0][0]) < $signed(suboperands_A[0][1])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[0][9] = ($signed(suboperands_B[0][1]) < $signed(suboperands_A[0][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[0][10] = ($signed(suboperands_A[0][2]) < $signed(suboperands_B[0][2])) ? 1'b0 : 1'b1; 
assign comparator_tree_flags[0][11] = ($signed(suboperands_A[0][0]) < $signed(suboperands_B[0][0])) ? 1'b0 : 1'b1;

assign comparator_tree_flags[1][0] = ($signed(suboperands_A[1][1]) < $signed(suboperands_B[1][1])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[1][1] = ($signed(suboperands_A[1][0]) < $signed(suboperands_B[1][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[1][2] = ($signed(suboperands_A[1][0]) < $signed(suboperands_B[1][1])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[1][3] = ($signed(suboperands_A[1][1]) < $signed(suboperands_B[1][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[1][4] = ($signed(suboperands_A[1][2]) < $signed(suboperands_B[1][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[1][5] = ($signed(suboperands_A[1][0]) < $signed(suboperands_B[1][0])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[1][6] = 1'b0;
assign comparator_tree_flags[1][7] = ($signed(suboperands_B[1][0]) < $signed(suboperands_A[1][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[1][8] = ($signed(suboperands_B[1][0]) < $signed(suboperands_A[1][1])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[1][9] = ($signed(suboperands_B[1][1]) < $signed(suboperands_A[1][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[1][10] = ($signed(suboperands_A[1][2]) < $signed(suboperands_B[1][2])) ? 1'b0 : 1'b1;
assign comparator_tree_flags[1][11] = ($signed(suboperands_A[1][0]) < $signed(suboperands_B[1][0])) ? 1'b0 : 1'b1;

assign comparator_tree_flags[2][0] = ($signed(suboperands_A[2][1]) < $signed(suboperands_B[2][1])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[2][1] = ($signed(suboperands_A[2][0]) < $signed(suboperands_B[2][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[2][2] = ($signed(suboperands_A[2][0]) < $signed(suboperands_B[2][1])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[2][3] = ($signed(suboperands_A[2][1]) < $signed(suboperands_B[2][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[2][4] = ($signed(suboperands_A[2][2]) < $signed(suboperands_B[2][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[2][5] = ($signed(suboperands_A[2][0]) < $signed(suboperands_B[2][0])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[2][6] = 1'b0;
assign comparator_tree_flags[2][7] = ($signed(suboperands_B[2][0]) < $signed(suboperands_A[2][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[2][8] = ($signed(suboperands_B[2][0]) < $signed(suboperands_A[2][1])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[2][9] = ($signed(suboperands_B[2][1]) < $signed(suboperands_A[2][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[2][10] = ($signed(suboperands_A[2][2]) < $signed(suboperands_B[2][2])) ? 1'b0 : 1'b1; 
assign comparator_tree_flags[2][11] = ($signed(suboperands_A[2][0]) < $signed(suboperands_B[2][0])) ? 1'b0 : 1'b1; 

assign comparator_tree_flags[3][0] = ($signed(suboperands_A[3][1]) < $signed(suboperands_B[3][1])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[3][1] = ($signed(suboperands_A[3][0]) < $signed(suboperands_B[3][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[3][2] = ($signed(suboperands_A[3][0]) < $signed(suboperands_B[3][1])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[3][3] = ($signed(suboperands_A[3][1]) < $signed(suboperands_B[3][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[3][4] = ($signed(suboperands_A[3][2]) < $signed(suboperands_B[3][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[3][5] = ($signed(suboperands_A[3][0]) < $signed(suboperands_B[3][0])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[3][6] = 1'b0;
assign comparator_tree_flags[3][7] = ($signed(suboperands_B[3][0]) < $signed(suboperands_A[3][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[3][8] = ($signed(suboperands_B[3][0]) < $signed(suboperands_A[3][1])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[3][9] = ($signed(suboperands_B[3][1]) < $signed(suboperands_A[3][2])) ? 1'b1 : 1'b0; 
assign comparator_tree_flags[3][10] = ($signed(suboperands_A[3][2]) < $signed(suboperands_B[3][2])) ? 1'b0 : 1'b1;
assign comparator_tree_flags[3][11] = ($signed(suboperands_A[3][0]) < $signed(suboperands_B[3][0])) ? 1'b0 : 1'b1; 



assign sorted_concatenated_drop_suboperands[0] = (comparator_tree_flags[0][0] & comparator_tree_flags[0][1]) ? {suboperands_A[0][1], suboperands_A[0][0], suboperands_B[0][2], suboperands_B[0][1]} : 
                    (comparator_tree_flags[0][0] & ~(comparator_tree_flags[0][1]) & comparator_tree_flags[0][2] & comparator_tree_flags[0][3]) ? {suboperands_A[0][1], suboperands_B[0][2], suboperands_A[0][0], suboperands_B[0][1]} :
                    (comparator_tree_flags[0][0] & ~(comparator_tree_flags[0][1]) & comparator_tree_flags[0][2] &  ~(comparator_tree_flags[0][3]) & comparator_tree_flags[0][4]) ? {suboperands_B[0][2], suboperands_A[0][1], suboperands_A[0][0], suboperands_B[0][1]} : 
                    (comparator_tree_flags[0][0] & ~(comparator_tree_flags[0][1]) & comparator_tree_flags[0][2] &  ~(comparator_tree_flags[0][3]) &  ~(comparator_tree_flags[0][4])) ? {suboperands_A[0][2], suboperands_A[0][1], suboperands_A[0][0], suboperands_B[0][1]} :                
                    (comparator_tree_flags[0][0] & ~(comparator_tree_flags[0][1]) & comparator_tree_flags[0][3] &  ~(comparator_tree_flags[0][2]) & comparator_tree_flags[0][5]) ? {suboperands_A[0][1], suboperands_B[0][2], suboperands_B[0][1], suboperands_A[0][0]} : 
                    (comparator_tree_flags[0][0] & ~(comparator_tree_flags[0][1]) & comparator_tree_flags[0][3] &  ~(comparator_tree_flags[0][2]) & ~(comparator_tree_flags[0][5])) ? {suboperands_A[0][1], suboperands_B[0][2], suboperands_B[0][1], suboperands_B[0][0]} : 
                    (comparator_tree_flags[0][0] & ~(comparator_tree_flags[0][1]) & ~(comparator_tree_flags[0][2]) & ~(comparator_tree_flags[0][3]) & comparator_tree_flags[0][4] & comparator_tree_flags[0][5]) ? {suboperands_B[0][2], suboperands_A[0][1], suboperands_B[0][1],suboperands_A[0][0]} :
                    (comparator_tree_flags[0][0] & ~(comparator_tree_flags[0][1]) & ~(comparator_tree_flags[0][2]) & ~(comparator_tree_flags[0][3]) & comparator_tree_flags[0][4] & ~(comparator_tree_flags[0][5])) ? {suboperands_B[0][2], suboperands_A[0][1], suboperands_B[0][1],suboperands_B[0][0]} :
                    (comparator_tree_flags[0][0] & ~(comparator_tree_flags[0][1]) & ~(comparator_tree_flags[0][2]) & ~(comparator_tree_flags[0][3]) & comparator_tree_flags[0][5] & ~(comparator_tree_flags[0][4])) ? {suboperands_A[0][2],suboperands_A[0][1],suboperands_B[0][1], suboperands_A[0][0]} : 
                    (comparator_tree_flags[0][0] & ~(comparator_tree_flags[0][1]) & ~(comparator_tree_flags[0][2]) & ~(comparator_tree_flags[0][3]) & ~(comparator_tree_flags[0][4]) & ~(comparator_tree_flags[0][5])) ? {suboperands_A[0][2],suboperands_A[0][1], suboperands_B[0][1],suboperands_B[0][0]} : 
                    (~(comparator_tree_flags[0][0]) & comparator_tree_flags[0][7] ) ? {suboperands_B[0][1], suboperands_B[0][0], suboperands_A[0][2], suboperands_A[0][1]} : 
                    (~(comparator_tree_flags[0][0]) & ~(comparator_tree_flags[0][7]) & comparator_tree_flags[0][8] & comparator_tree_flags[0][9]) ? {suboperands_B[0][1], suboperands_A[0][2], suboperands_B[0][0], suboperands_A[0][1]} : 
                    (~(comparator_tree_flags[0][0]) & ~(comparator_tree_flags[0][7]) & comparator_tree_flags[0][8] & ~(comparator_tree_flags[0][9]) & comparator_tree_flags[0][10]) ? {suboperands_A[0][2], suboperands_B[0][1], suboperands_B[0][0], suboperands_A[0][1]} :
                    (~(comparator_tree_flags[0][0]) & ~(comparator_tree_flags[0][7]) & comparator_tree_flags[0][8] & ~(comparator_tree_flags[0][9]) & ~(comparator_tree_flags[0][10]) ) ? {suboperands_B[0][2], suboperands_B[0][1], suboperands_B[0][0], suboperands_A[0][1]} :
                    (~(comparator_tree_flags[0][0]) &  ~(comparator_tree_flags[0][7]) &  ~(comparator_tree_flags[0][8]) & comparator_tree_flags[0][9] & comparator_tree_flags[0][11]) ? {suboperands_B[0][1], suboperands_A[0][2], suboperands_A[0][1], suboperands_B[0][0]} : 
                    (~(comparator_tree_flags[0][0]) &  ~(comparator_tree_flags[0][7]) &  ~(comparator_tree_flags[0][8]) & comparator_tree_flags[0][9] & ~(comparator_tree_flags[0][11])) ? {suboperands_B[0][1], suboperands_A[0][2], suboperands_A[0][1], suboperands_A[0][0]} :
                    (~(comparator_tree_flags[0][0]) &  ~(comparator_tree_flags[0][7]) &  ~(comparator_tree_flags[0][8]) & ~(comparator_tree_flags[0][9]) & comparator_tree_flags[0][10] & comparator_tree_flags[0][11]) ? {suboperands_A[0][2],suboperands_B[0][1], suboperands_A[0][1], suboperands_B[0][0]} : 
                    (~(comparator_tree_flags[0][0]) &  ~(comparator_tree_flags[0][7]) &  ~(comparator_tree_flags[0][8]) & ~(comparator_tree_flags[0][9]) & comparator_tree_flags[0][10] & ~(comparator_tree_flags[0][11]) ) ? {suboperands_A[0][2],suboperands_B[0][1], suboperands_A[0][1], suboperands_A[0][0]} : 
                    (~(comparator_tree_flags[0][0]) &  ~(comparator_tree_flags[0][7]) &  ~(comparator_tree_flags[0][8]) & ~(comparator_tree_flags[0][9]) & comparator_tree_flags[0][11] & ~(comparator_tree_flags[0][10]) ) ? {suboperands_B[0][2],suboperands_B[0][1], suboperands_A[0][1], suboperands_B[0][0]} : 
                    (~(comparator_tree_flags[0][0]) &  ~(comparator_tree_flags[0][7]) &  ~(comparator_tree_flags[0][8]) & ~(comparator_tree_flags[0][9]) & ~(comparator_tree_flags[0][11]) & ~(comparator_tree_flags[0][10]) ) ? {suboperands_B[0][2],suboperands_B[0][1], suboperands_A[0][1], suboperands_A[0][0]} : 32'b0;

assign sorted_concatenated_drop_suboperands[1] = (comparator_tree_flags[1][0] & comparator_tree_flags[1][1]) ? {suboperands_A[1][1], suboperands_A[1][0], suboperands_B[1][2], suboperands_B[1][1]} : 
                    (comparator_tree_flags[1][0] & ~(comparator_tree_flags[1][1]) & comparator_tree_flags[1][2] & comparator_tree_flags[1][3]) ? {suboperands_A[1][1], suboperands_B[1][2], suboperands_A[1][0], suboperands_B[1][1]} :
                    (comparator_tree_flags[1][0] & ~(comparator_tree_flags[1][1]) & comparator_tree_flags[1][2] &  ~(comparator_tree_flags[1][3]) & comparator_tree_flags[1][4]) ? {suboperands_B[1][2], suboperands_A[1][1], suboperands_A[1][0], suboperands_B[1][1]} : 
                    (comparator_tree_flags[1][0] & ~(comparator_tree_flags[1][1]) & comparator_tree_flags[1][2] &  ~(comparator_tree_flags[1][3]) &  ~(comparator_tree_flags[1][4])) ? {suboperands_A[1][2], suboperands_A[1][1], suboperands_A[1][0], suboperands_B[1][1]} :                
                    (comparator_tree_flags[1][0] & ~(comparator_tree_flags[1][1]) & comparator_tree_flags[1][3] &  ~(comparator_tree_flags[1][2]) & comparator_tree_flags[1][5]) ? {suboperands_A[1][1], suboperands_B[1][2], suboperands_B[1][1], suboperands_A[1][0]} : 
                    (comparator_tree_flags[1][0] & ~(comparator_tree_flags[1][1]) & comparator_tree_flags[1][3] &  ~(comparator_tree_flags[1][2]) & ~(comparator_tree_flags[1][5])) ? {suboperands_A[1][1], suboperands_B[1][2], suboperands_B[1][1], suboperands_B[1][0]} : 
                    (comparator_tree_flags[1][0] & ~(comparator_tree_flags[1][1]) & ~(comparator_tree_flags[1][2]) & ~(comparator_tree_flags[1][3]) & comparator_tree_flags[1][4] & comparator_tree_flags[1][5]) ? {suboperands_B[1][2], suboperands_A[1][1], suboperands_B[1][1],suboperands_A[1][0]} :
                    (comparator_tree_flags[1][0] & ~(comparator_tree_flags[1][1]) & ~(comparator_tree_flags[1][2]) & ~(comparator_tree_flags[1][3]) & comparator_tree_flags[1][4] & ~(comparator_tree_flags[1][5])) ? {suboperands_B[1][2], suboperands_A[1][1], suboperands_B[1][1],suboperands_B[1][0]} :
                    (comparator_tree_flags[1][0] & ~(comparator_tree_flags[1][1]) & ~(comparator_tree_flags[1][2]) & ~(comparator_tree_flags[1][3]) & comparator_tree_flags[1][5] & ~(comparator_tree_flags[1][4])) ? {suboperands_A[1][2],suboperands_A[1][1],suboperands_B[1][1], suboperands_A[1][0]} : 
                    (comparator_tree_flags[1][0] & ~(comparator_tree_flags[1][1]) & ~(comparator_tree_flags[1][2]) & ~(comparator_tree_flags[1][3]) & ~(comparator_tree_flags[1][4]) & ~(comparator_tree_flags[1][5])) ? {suboperands_A[1][2],suboperands_A[1][1], suboperands_B[1][1],suboperands_B[1][0]} : 
                    (~(comparator_tree_flags[1][0]) & comparator_tree_flags[1][7] ) ? {suboperands_B[1][1], suboperands_B[1][0], suboperands_A[1][2], suboperands_A[1][1]} : 
                    (~(comparator_tree_flags[1][0]) & ~(comparator_tree_flags[1][7]) & comparator_tree_flags[1][8] & comparator_tree_flags[1][9]) ? {suboperands_B[1][1], suboperands_A[1][2], suboperands_B[1][0], suboperands_A[1][1]} : 
                    (~(comparator_tree_flags[1][0]) & ~(comparator_tree_flags[1][7]) & comparator_tree_flags[1][8] & ~(comparator_tree_flags[1][9]) & comparator_tree_flags[1][10]) ? {suboperands_A[1][2], suboperands_B[1][1], suboperands_B[1][0], suboperands_A[1][1]} :
                    (~(comparator_tree_flags[1][0]) & ~(comparator_tree_flags[1][7]) & comparator_tree_flags[1][8] & ~(comparator_tree_flags[1][9]) & ~(comparator_tree_flags[1][10]) ) ? {suboperands_B[1][2], suboperands_B[1][1], suboperands_B[1][0], suboperands_A[1][1]} :
                    (~(comparator_tree_flags[1][0]) &  ~(comparator_tree_flags[1][7]) &  ~(comparator_tree_flags[1][8]) & comparator_tree_flags[1][9] & comparator_tree_flags[1][11]) ? {suboperands_B[1][1], suboperands_A[1][2], suboperands_A[1][1], suboperands_B[1][0]} : 
                    (~(comparator_tree_flags[1][0]) &  ~(comparator_tree_flags[1][7]) &  ~(comparator_tree_flags[1][8]) & comparator_tree_flags[1][9] & ~(comparator_tree_flags[1][11])) ? {suboperands_B[1][1], suboperands_A[1][2], suboperands_A[1][1], suboperands_A[1][0]} :
                    (~(comparator_tree_flags[1][0]) &  ~(comparator_tree_flags[1][7]) &  ~(comparator_tree_flags[1][8]) & ~(comparator_tree_flags[1][9]) & comparator_tree_flags[1][10] & comparator_tree_flags[1][11]) ? {suboperands_A[1][2],suboperands_B[1][1], suboperands_A[1][1], suboperands_B[1][0]} : 
                    (~(comparator_tree_flags[1][0]) &  ~(comparator_tree_flags[1][7]) &  ~(comparator_tree_flags[1][8]) & ~(comparator_tree_flags[1][9]) & comparator_tree_flags[1][10] & ~(comparator_tree_flags[1][11]) ) ? {suboperands_A[1][2],suboperands_B[1][1], suboperands_A[1][1], suboperands_A[1][0]} : 
                    (~(comparator_tree_flags[1][0]) &  ~(comparator_tree_flags[1][7]) &  ~(comparator_tree_flags[1][8]) & ~(comparator_tree_flags[1][9]) & comparator_tree_flags[1][11] & ~(comparator_tree_flags[1][10]) ) ? {suboperands_B[1][2],suboperands_B[1][1], suboperands_A[1][1], suboperands_B[1][0]} : 
                    (~(comparator_tree_flags[1][0]) &  ~(comparator_tree_flags[1][7]) &  ~(comparator_tree_flags[1][8]) & ~(comparator_tree_flags[1][9]) & ~(comparator_tree_flags[1][11]) & ~(comparator_tree_flags[1][10]) ) ? {suboperands_B[1][2],suboperands_B[1][1], suboperands_A[1][1], suboperands_A[1][0]} : 32'b0;

assign sorted_concatenated_drop_suboperands[2] = (comparator_tree_flags[2][0] & comparator_tree_flags[2][1]) ? {suboperands_A[2][1], suboperands_A[2][0], suboperands_B[2][2], suboperands_B[2][1]} : 
                    (comparator_tree_flags[2][0] & ~(comparator_tree_flags[2][1]) & comparator_tree_flags[2][2] & comparator_tree_flags[2][3]) ? {suboperands_A[2][1], suboperands_B[2][2], suboperands_A[2][0], suboperands_B[2][1]} :
                    (comparator_tree_flags[2][0] & ~(comparator_tree_flags[2][1]) & comparator_tree_flags[2][2] &  ~(comparator_tree_flags[2][3]) & comparator_tree_flags[2][4]) ? {suboperands_B[2][2], suboperands_A[2][1], suboperands_A[2][0], suboperands_B[2][1]} : 
                    (comparator_tree_flags[2][0] & ~(comparator_tree_flags[2][1]) & comparator_tree_flags[2][2] &  ~(comparator_tree_flags[2][3]) &  ~(comparator_tree_flags[2][4])) ? {suboperands_A[2][2], suboperands_A[2][1], suboperands_A[2][0], suboperands_B[2][1]} :                
                    (comparator_tree_flags[2][0] & ~(comparator_tree_flags[2][1]) & comparator_tree_flags[2][3] &  ~(comparator_tree_flags[2][2]) & comparator_tree_flags[2][5]) ? {suboperands_A[2][1], suboperands_B[2][2], suboperands_B[2][1], suboperands_A[2][0]} : 
                    (comparator_tree_flags[2][0] & ~(comparator_tree_flags[2][1]) & comparator_tree_flags[2][3] &  ~(comparator_tree_flags[2][2]) & ~(comparator_tree_flags[2][5])) ? {suboperands_A[2][1], suboperands_B[2][2], suboperands_B[2][1], suboperands_B[2][0]} : 
                    (comparator_tree_flags[2][0] & ~(comparator_tree_flags[2][1]) & ~(comparator_tree_flags[2][2]) & ~(comparator_tree_flags[2][3]) & comparator_tree_flags[2][4] & comparator_tree_flags[2][5]) ? {suboperands_B[2][2], suboperands_A[2][1], suboperands_B[2][1],suboperands_A[2][0]} :
                    (comparator_tree_flags[2][0] & ~(comparator_tree_flags[2][1]) & ~(comparator_tree_flags[2][2]) & ~(comparator_tree_flags[2][3]) & comparator_tree_flags[2][4] & ~(comparator_tree_flags[2][5])) ? {suboperands_B[2][2], suboperands_A[2][1], suboperands_B[2][1],suboperands_B[2][0]} :
                    (comparator_tree_flags[2][0] & ~(comparator_tree_flags[2][1]) & ~(comparator_tree_flags[2][2]) & ~(comparator_tree_flags[2][3]) & comparator_tree_flags[2][5] & ~(comparator_tree_flags[2][4])) ? {suboperands_A[2][2],suboperands_A[2][1],suboperands_B[2][1], suboperands_A[2][0]} : 
                    (comparator_tree_flags[2][0] & ~(comparator_tree_flags[2][1]) & ~(comparator_tree_flags[2][2]) & ~(comparator_tree_flags[2][3]) & ~(comparator_tree_flags[2][4]) & ~(comparator_tree_flags[2][5])) ? {suboperands_A[2][2],suboperands_A[2][1], suboperands_B[2][1],suboperands_B[2][0]} : 
                    (~(comparator_tree_flags[2][0]) & comparator_tree_flags[2][7] ) ? {suboperands_B[2][1], suboperands_B[2][0], suboperands_A[2][2], suboperands_A[2][1]} : 
                    (~(comparator_tree_flags[2][0]) & ~(comparator_tree_flags[2][7]) & comparator_tree_flags[2][8] & comparator_tree_flags[2][9]) ? {suboperands_B[2][1], suboperands_A[2][2], suboperands_B[2][0], suboperands_A[2][1]} : 
                    (~(comparator_tree_flags[2][0]) & ~(comparator_tree_flags[2][7]) & comparator_tree_flags[2][8] & ~(comparator_tree_flags[2][9]) & comparator_tree_flags[2][10]) ? {suboperands_A[2][2], suboperands_B[2][1], suboperands_B[2][0], suboperands_A[2][1]} :
                    (~(comparator_tree_flags[2][0]) & ~(comparator_tree_flags[2][7]) & comparator_tree_flags[2][8] & ~(comparator_tree_flags[2][9]) & ~(comparator_tree_flags[2][10]) ) ? {suboperands_B[2][2], suboperands_B[2][1], suboperands_B[2][0], suboperands_A[2][1]} :
                    (~(comparator_tree_flags[2][0]) &  ~(comparator_tree_flags[2][7]) &  ~(comparator_tree_flags[2][8]) & comparator_tree_flags[2][9] & comparator_tree_flags[2][11]) ? {suboperands_B[2][1], suboperands_A[2][2], suboperands_A[2][1], suboperands_B[2][0]} : 
                    (~(comparator_tree_flags[2][0]) &  ~(comparator_tree_flags[2][7]) &  ~(comparator_tree_flags[2][8]) & comparator_tree_flags[2][9] & ~(comparator_tree_flags[2][11])) ? {suboperands_B[2][1], suboperands_A[2][2], suboperands_A[2][1], suboperands_A[2][0]} :
                    (~(comparator_tree_flags[2][0]) &  ~(comparator_tree_flags[2][7]) &  ~(comparator_tree_flags[2][8]) & ~(comparator_tree_flags[2][9]) & comparator_tree_flags[2][10] & comparator_tree_flags[2][11]) ? {suboperands_A[2][2],suboperands_B[2][1], suboperands_A[2][1], suboperands_B[2][0]} : 
                    (~(comparator_tree_flags[2][0]) &  ~(comparator_tree_flags[2][7]) &  ~(comparator_tree_flags[2][8]) & ~(comparator_tree_flags[2][9]) & comparator_tree_flags[2][10] & ~(comparator_tree_flags[2][11]) ) ? {suboperands_A[2][2],suboperands_B[2][1], suboperands_A[2][1], suboperands_A[2][0]} : 
                    (~(comparator_tree_flags[2][0]) &  ~(comparator_tree_flags[2][7]) &  ~(comparator_tree_flags[2][8]) & ~(comparator_tree_flags[2][9]) & comparator_tree_flags[2][11] & ~(comparator_tree_flags[2][10]) ) ? {suboperands_B[2][2],suboperands_B[2][1], suboperands_A[2][1], suboperands_B[2][0]} : 
                    (~(comparator_tree_flags[2][0]) &  ~(comparator_tree_flags[2][7]) &  ~(comparator_tree_flags[2][8]) & ~(comparator_tree_flags[2][9]) & ~(comparator_tree_flags[2][11]) & ~(comparator_tree_flags[2][10]) ) ? {suboperands_B[2][2],suboperands_B[2][1], suboperands_A[2][1], suboperands_A[2][0]} : 32'b0;


assign sorted_concatenated_drop_suboperands[3] = (comparator_tree_flags[3][0] & comparator_tree_flags[3][1]) ? {suboperands_A[3][1], suboperands_A[3][0], suboperands_B[3][2], suboperands_B[3][1]} : 
                    (comparator_tree_flags[3][0] & ~(comparator_tree_flags[3][1]) & comparator_tree_flags[3][2] & comparator_tree_flags[3][3]) ? {suboperands_A[3][1], suboperands_B[3][2], suboperands_A[3][0], suboperands_B[3][1]} :
                    (comparator_tree_flags[3][0] & ~(comparator_tree_flags[3][1]) & comparator_tree_flags[3][2] &  ~(comparator_tree_flags[3][3]) & comparator_tree_flags[3][4]) ? {suboperands_B[3][2], suboperands_A[3][1], suboperands_A[3][0], suboperands_B[3][1]} : 
                    (comparator_tree_flags[3][0] & ~(comparator_tree_flags[3][1]) & comparator_tree_flags[3][2] &  ~(comparator_tree_flags[3][3]) &  ~(comparator_tree_flags[3][4])) ? {suboperands_A[3][2], suboperands_A[3][1], suboperands_A[3][0], suboperands_B[3][1]} :                
                    (comparator_tree_flags[3][0] & ~(comparator_tree_flags[3][1]) & comparator_tree_flags[3][3] &  ~(comparator_tree_flags[3][2]) & comparator_tree_flags[3][5]) ? {suboperands_A[3][1], suboperands_B[3][2], suboperands_B[3][1], suboperands_A[3][0]} : 
                    (comparator_tree_flags[3][0] & ~(comparator_tree_flags[3][1]) & comparator_tree_flags[3][3] &  ~(comparator_tree_flags[3][2]) & ~(comparator_tree_flags[3][5])) ? {suboperands_A[3][1], suboperands_B[3][2], suboperands_B[3][1], suboperands_B[3][0]} : 
                    (comparator_tree_flags[3][0] & ~(comparator_tree_flags[3][1]) & ~(comparator_tree_flags[3][2]) & ~(comparator_tree_flags[3][3]) & comparator_tree_flags[3][4] & comparator_tree_flags[3][5]) ? {suboperands_B[3][2], suboperands_A[3][1], suboperands_B[3][1],suboperands_A[3][0]} :
                    (comparator_tree_flags[3][0] & ~(comparator_tree_flags[3][1]) & ~(comparator_tree_flags[3][2]) & ~(comparator_tree_flags[3][3]) & comparator_tree_flags[3][4] & ~(comparator_tree_flags[3][5])) ? {suboperands_B[3][2], suboperands_A[3][1], suboperands_B[3][1],suboperands_B[3][0]} :
                    (comparator_tree_flags[3][0] & ~(comparator_tree_flags[3][1]) & ~(comparator_tree_flags[3][2]) & ~(comparator_tree_flags[3][3]) & comparator_tree_flags[3][5] & ~(comparator_tree_flags[3][4])) ? {suboperands_A[3][2],suboperands_A[3][1],suboperands_B[3][1], suboperands_A[3][0]} : 
                    (comparator_tree_flags[3][0] & ~(comparator_tree_flags[3][1]) & ~(comparator_tree_flags[3][2]) & ~(comparator_tree_flags[3][3]) & ~(comparator_tree_flags[3][4]) & ~(comparator_tree_flags[3][5])) ? {suboperands_A[3][2],suboperands_A[3][1], suboperands_B[3][1],suboperands_B[3][0]} : 
                    (~(comparator_tree_flags[3][0]) & comparator_tree_flags[3][7] ) ? {suboperands_B[3][1], suboperands_B[3][0], suboperands_A[3][2], suboperands_A[3][1]} : 
                    (~(comparator_tree_flags[3][0]) & ~(comparator_tree_flags[3][7]) & comparator_tree_flags[3][8] & comparator_tree_flags[3][9]) ? {suboperands_B[3][1], suboperands_A[3][2], suboperands_B[3][0], suboperands_A[3][1]} : 
                    (~(comparator_tree_flags[3][0]) & ~(comparator_tree_flags[3][7]) & comparator_tree_flags[3][8] & ~(comparator_tree_flags[3][9]) & comparator_tree_flags[3][10]) ? {suboperands_A[3][2], suboperands_B[3][1], suboperands_B[3][0], suboperands_A[3][1]} :
                    (~(comparator_tree_flags[3][0]) & ~(comparator_tree_flags[3][7]) & comparator_tree_flags[3][8] & ~(comparator_tree_flags[3][9]) & ~(comparator_tree_flags[3][10]) ) ? {suboperands_B[3][2], suboperands_B[3][1], suboperands_B[3][0], suboperands_A[3][1]} :
                    (~(comparator_tree_flags[3][0]) &  ~(comparator_tree_flags[3][7]) &  ~(comparator_tree_flags[3][8]) & comparator_tree_flags[3][9] & comparator_tree_flags[3][11]) ? {suboperands_B[3][1], suboperands_A[3][2], suboperands_A[3][1], suboperands_B[3][0]} : 
                    (~(comparator_tree_flags[3][0]) &  ~(comparator_tree_flags[3][7]) &  ~(comparator_tree_flags[3][8]) & comparator_tree_flags[3][9] & ~(comparator_tree_flags[3][11])) ? {suboperands_B[3][1], suboperands_A[3][2], suboperands_A[3][1], suboperands_A[3][0]} :
                    (~(comparator_tree_flags[3][0]) &  ~(comparator_tree_flags[3][7]) &  ~(comparator_tree_flags[3][8]) & ~(comparator_tree_flags[3][9]) & comparator_tree_flags[3][10] & comparator_tree_flags[3][11]) ? {suboperands_A[3][2],suboperands_B[3][1], suboperands_A[3][1], suboperands_B[3][0]} : 
                    (~(comparator_tree_flags[3][0]) &  ~(comparator_tree_flags[3][7]) &  ~(comparator_tree_flags[3][8]) & ~(comparator_tree_flags[3][9]) & comparator_tree_flags[3][10] & ~(comparator_tree_flags[3][11]) ) ? {suboperands_A[3][2],suboperands_B[3][1], suboperands_A[3][1], suboperands_A[3][0]} : 
                    (~(comparator_tree_flags[3][0]) &  ~(comparator_tree_flags[3][7]) &  ~(comparator_tree_flags[3][8]) & ~(comparator_tree_flags[3][9]) & comparator_tree_flags[3][11] & ~(comparator_tree_flags[3][10]) ) ? {suboperands_B[3][2],suboperands_B[3][1], suboperands_A[3][1], suboperands_B[3][0]} : 
                    (~(comparator_tree_flags[3][0]) &  ~(comparator_tree_flags[3][7]) &  ~(comparator_tree_flags[3][8]) & ~(comparator_tree_flags[3][9]) & ~(comparator_tree_flags[3][11]) & ~(comparator_tree_flags[3][10]) ) ? {suboperands_B[3][2],suboperands_B[3][1], suboperands_A[3][1], suboperands_A[3][0]} : 32'b0;

/*paking data for operator 2D_2, latency = lut encoding*/ 
/*latency operator 2d_1 = 2 comparators + 1 lut acces +1 lut encoding + muxes(negligible)*/
assign operator2D_1_out[3 : 0] = sorted_concatenated_drop_suboperands[0][3 : 0];
assign operator2D_1_out[7 : 4] = sorted_concatenated_drop_suboperands[0][11 : 8];
assign operator2D_1_out[11 : 8] = sorted_concatenated_drop_suboperands[0][19 : 16];
assign operator2D_1_out[14 : 12] = sorted_concatenated_drop_suboperands[0][27 : 25];
assign operator2D_1_out[26 : 15] = codes[0][11 : 0];
assign operator2D_1_out[27] = 1'b1; //flag for operator 2d2
assign msb_i[0] = sorted_concatenated_drop_suboperands[0][31 : 28];
assign msb_j[0] = sorted_concatenated_drop_suboperands[0][23 : 20];
assign msb_k[0] = sorted_concatenated_drop_suboperands[0][15 : 12];
assign msb_w[0] = sorted_concatenated_drop_suboperands[0][7 : 4];

assign operator2D_1_out[31 : 28] = sorted_concatenated_drop_suboperands[1][3 : 0];
assign operator2D_1_out[35 : 32] = sorted_concatenated_drop_suboperands[1][11 : 8];
assign operator2D_1_out[39 : 36] = sorted_concatenated_drop_suboperands[1][19 : 16];
assign operator2D_1_out[42 : 40] = sorted_concatenated_drop_suboperands[1][27 : 25];
assign operator2D_1_out[54 : 43] = codes[1][11 : 0];
assign operator2D_1_out[55] = 1'b1; //flag for operator 2d2
assign msb_i[1] = sorted_concatenated_drop_suboperands[1][31 : 28];
assign msb_j[1] = sorted_concatenated_drop_suboperands[1][23 : 20];
assign msb_k[1] = sorted_concatenated_drop_suboperands[1][15 : 12];
assign msb_w[1] = sorted_concatenated_drop_suboperands[1][7 : 4];

assign operator2D_1_out[59 : 56] = sorted_concatenated_drop_suboperands[2][3 : 0];
assign operator2D_1_out[63 : 60] = sorted_concatenated_drop_suboperands[2][11 : 8];
assign operator2D_1_out[67 : 64] = sorted_concatenated_drop_suboperands[2][19 : 16];
assign operator2D_1_out[70 : 68] = sorted_concatenated_drop_suboperands[2][27 : 25];
assign operator2D_1_out[82 : 71] = codes[2][11 : 0];
assign operator2D_1_out[83] = 1'b1; //flag for operator 2d2
assign msb_i[2] = sorted_concatenated_drop_suboperands[2][31 : 28];
assign msb_j[2] = sorted_concatenated_drop_suboperands[2][23 : 20];
assign msb_k[2] = sorted_concatenated_drop_suboperands[2][15 : 12];
assign msb_w[2] = sorted_concatenated_drop_suboperands[2][7 : 4];

assign operator2D_1_out[87 : 84] = sorted_concatenated_drop_suboperands[3][3 : 0];
assign operator2D_1_out[91 : 88] = sorted_concatenated_drop_suboperands[3][11 : 8];
assign operator2D_1_out[95 : 92] = sorted_concatenated_drop_suboperands[3][19 : 16];
assign operator2D_1_out[98 : 96] = sorted_concatenated_drop_suboperands[3][27 : 25];
assign operator2D_1_out[110 : 99] = codes[3][11 : 0];
assign operator2D_1_out[111] = 1'b1; //flag for operator 2d2
assign msb_i[3] = sorted_concatenated_drop_suboperands[3][31 : 28];
assign msb_j[3] = sorted_concatenated_drop_suboperands[3][23 : 20];
assign msb_k[3] = sorted_concatenated_drop_suboperands[3][15 : 12];
assign msb_w[3] = sorted_concatenated_drop_suboperands[3][7 : 4];

/*OPERATOR 2D_2*/
assign zero_operand[0] = 8'b0;
assign zero_operand[1] = 8'b0;
assign zero_operand[2] = 8'b0;

assign sel_operands2[0]  = (operands_A[0][27 : 22] == 6'b000000 || operands_A[0][27 : 22] == 6'b111111) ? 2'b00 : 
                            (operands_B[0][27 : 22] == 6'b000000 || operands_B[0][27 : 22] == 6'b111111) ? 2'b01 : 2'b11;
assign sel_operands2[1]  = (operands_A[1][27 : 22] == 6'b000000 || operands_A[1][27 : 22] == 6'b111111) ? 2'b00 : 
                            (operands_B[1][27 : 22] == 6'b000000 || operands_B[1][27 : 22] == 6'b111111) ? 2'b01 : 2'b11;
assign sel_operands2[2]  = (operands_A[2][27 : 22] == 6'b000000 || operands_A[2][27 : 22] == 6'b111111) ? 2'b00 : 
                            (operands_B[2][27 : 22] == 6'b000000 || operands_B[2][27 : 22] == 6'b111111) ? 2'b01 : 2'b11;
assign sel_operands2[3]  = (operands_A[3][27 : 22] == 6'b000000 || operands_A[3][27 : 22] == 6'b111111) ? 2'b00 : 
                            (operands_B[3][27 : 22] == 6'b000000 || operands_B[3][27 : 22] == 6'b111111) ? 2'b01 : 2'b11;

assign operands2[0] = (sel_operands2[0] == 2'b00) ? suboperands_A[0] : 
                      (sel_operands2[0] == 2'b01) ? suboperands_B[0] : zero_operand;
assign operands2[1] = (sel_operands2[1] == 2'b00) ? suboperands_A[1] : 
                      (sel_operands2[1] == 2'b01) ? suboperands_B[1] : zero_operand;
assign operands2[2] = (sel_operands2[2] == 2'b00) ? suboperands_A[2] : 
                      (sel_operands2[2] == 2'b01) ? suboperands_B[2] : zero_operand;
assign operands2[3] = (sel_operands2[3] == 2'b00) ? suboperands_A[3] : 
                      (sel_operands2[3] == 2'b01) ? suboperands_B[3] : zero_operand;

assign sel_operands1[0] = (operands_A[0][27] == 1'b1 & operands_A[0][26 : 22] != 5'b11111) ? 2'b00 : 
                          (operands_B[0][27] == 1'b1 & operands_B[0][26 : 22] != 5'b11111) ? 2'b01 : 2'b11;                         
assign sel_operands1[1] = (operands_A[1][27] == 1'b1 & operands_A[1][26 : 22] != 5'b11111) ? 2'b00 : 
                          (operands_B[1][27] == 1'b1 & operands_B[1][26 : 22] != 5'b11111) ? 2'b01 : 2'b11;
assign sel_operands1[2] = (operands_A[2][27] == 1'b1 & operands_A[2][26 : 22] != 5'b11111) ? 2'b00 : 
                          (operands_B[2][27] == 1'b1 & operands_B[2][26 : 22] != 5'b11111) ? 2'b01 : 2'b11;
assign sel_operands1[3] = (operands_A[3][27] == 1'b1 & operands_A[3][26 : 22] != 5'b11111) ? 2'b00 : 
                          (operands_B[3][27] == 1'b1 & operands_B[3][26 : 22] != 5'b11111) ? 2'b01 : 2'b11;

assign to_decode[0] = (sel_operands1[0] == 2'b00) ? operands_A[0][26 : 15] : 
                      (sel_operands1[0] == 2'b01) ? operands_B[0][26 : 15] : 0;      
assign to_decode[1] = (sel_operands1[1] == 2'b00) ? operands_A[1][26 : 15] : 
                      (sel_operands1[1] == 2'b01) ? operands_B[1][26 : 15] : 0;                     
assign to_decode[2] = (sel_operands1[2] == 2'b00) ? operands_A[2][26 : 15] : 
                      (sel_operands1[2] == 2'b01) ? operands_B[2][26 : 15] : 0;
assign to_decode[3] = (sel_operands1[3] == 2'b00) ? operands_A[3][26 : 15] : 
                      (sel_operands1[3] == 2'b01) ? operands_B[3][26 : 15] : 0;

/*isolating lsbs , reading lsbs from lut2d and reconstructing operands, latency = 1 comparator + lut access + muxes*/
assign zeros_LSBs = 4'b0;

assign LSBs_operands1[0][0] = (sel_operands1[0] == 2'b00) ? operands_A[0][3 : 0] : 
                              (sel_operands1[0] == 2'b01) ? operands_B[0][3 : 0] : zeros_LSBs;
assign LSBs_operands1[0][1] = (sel_operands1[0] == 2'b00) ? operands_A[0][7 : 4] : 
                              (sel_operands1[0] == 2'b01) ? operands_B[0][7 : 4] : zeros_LSBs;
assign LSBs_operands1[0][2] = (sel_operands1[0] == 2'b00) ? operands_A[0][11 : 8] : 
                              (sel_operands1[0] == 2'b01) ? operands_B[0][11 : 8] : zeros_LSBs;
assign LSBs_operands1[0][3][3 : 1] = (sel_operands1[0] == 2'b00) ? operands_A[0][14 : 12] : 
                              (sel_operands1[0] == 2'b01) ? operands_B[0][14 : 12] : 3'b0;
assign LSBs_operands1[0][3][0] = 1'b0; /*loss of information due to parallelism constrains*/


assign LSBs_operands1[1][0] = (sel_operands1[1] == 2'b00) ? operands_A[1][3 : 0] : 
                              (sel_operands1[1] == 2'b01) ? operands_B[1][3 : 0] : zeros_LSBs;
assign LSBs_operands1[1][1] = (sel_operands1[1] == 2'b00) ? operands_A[1][7 : 4] : 
                              (sel_operands1[1] == 2'b01) ? operands_B[1][7 : 4] : zeros_LSBs;
assign LSBs_operands1[1][2] = (sel_operands1[1] == 2'b00) ? operands_A[1][11 : 8] : 
                              (sel_operands1[1] == 2'b01) ? operands_B[1][11 : 8] : zeros_LSBs;
assign LSBs_operands1[1][3][3 : 1] = (sel_operands1[1] == 2'b00) ? operands_A[1][14 : 12] : 
                              (sel_operands1[1] == 2'b01) ? operands_B[1][14 : 12] : 3'b0;
assign LSBs_operands1[1][3][0] = 1'b0; /*loss of information due to parallelism constrains*/


assign LSBs_operands1[2][0] = (sel_operands1[2] == 2'b00) ? operands_A[2][3 : 0] : 
                              (sel_operands1[2] == 2'b01) ? operands_B[2][3 : 0] : zeros_LSBs;
assign LSBs_operands1[2][1] = (sel_operands1[2] == 2'b00) ? operands_A[2][7 : 4] : 
                              (sel_operands1[2] == 2'b01) ? operands_B[2][7 : 4] : zeros_LSBs;
assign LSBs_operands1[2][2] = (sel_operands1[2] == 2'b00) ? operands_A[2][11 : 8] : 
                              (sel_operands1[2] == 2'b01) ? operands_B[2][11 : 8] : zeros_LSBs;
assign LSBs_operands1[2][3][3 : 1] = (sel_operands1[2] == 2'b00) ? operands_A[2][14 : 12] : 
                              (sel_operands1[2] == 2'b01) ? operands_B[2][14 : 12] : 3'b0;
assign LSBs_operands1[2][3][0] = 1'b0; /*loss of information due to parallelism constrains*/

assign LSBs_operands1[3][0] = (sel_operands1[3] == 2'b00) ? operands_A[3][3 : 0] : 
                              (sel_operands1[3] == 2'b01) ? operands_B[3][3 : 0] : zeros_LSBs;
assign LSBs_operands1[3][1] = (sel_operands1[3] == 2'b00) ? operands_A[3][7 : 4] : 
                              (sel_operands1[3] == 2'b01) ? operands_B[3][7 : 4] : zeros_LSBs;
assign LSBs_operands1[3][2] = (sel_operands1[3] == 2'b00) ? operands_A[3][11 : 8] : 
                              (sel_operands1[3] == 2'b01) ? operands_B[3][11 : 8] : zeros_LSBs;
assign LSBs_operands1[3][3][3 : 1] = (sel_operands1[3] == 2'b00) ? operands_A[3][14 : 12] : 
                              (sel_operands1[3] == 2'b01) ? operands_B[3][14 : 12] : 3'b0;
assign LSBs_operands1[3][3][0] = 1'b0; /*loss of information due to parallelism constrains*/


assign combos_operands1[0][0][0] = {decoded_msbs_w[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][0] = {decoded_msbs_k[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][0] = {decoded_msbs_j[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][0] = {decoded_msbs_i[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][1] = {decoded_msbs_k[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][1] = {decoded_msbs_w[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][1] = {decoded_msbs_j[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][1] = {decoded_msbs_i[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][2] = {decoded_msbs_w[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][2] = {decoded_msbs_j[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][2] = {decoded_msbs_k[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][2] = {decoded_msbs_i[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][3] = {decoded_msbs_j[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][3] = {decoded_msbs_w[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][3] = {decoded_msbs_k[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][3] = {decoded_msbs_i[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][4] = {decoded_msbs_k[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][4] = {decoded_msbs_j[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][4] = {decoded_msbs_w[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][4] = {decoded_msbs_i[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][5] = {decoded_msbs_j[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][5] = {decoded_msbs_k[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][5] = {decoded_msbs_w[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][5] = {decoded_msbs_i[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][6] = {decoded_msbs_w[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][6] = {decoded_msbs_k[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][6] = {decoded_msbs_i[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][6] = {decoded_msbs_j[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][7] = {decoded_msbs_k[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][7] = {decoded_msbs_w[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][7] = {decoded_msbs_i[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][7] = {decoded_msbs_j[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][8] = {decoded_msbs_w[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][8] = {decoded_msbs_i[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][8] = {decoded_msbs_k[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][8] = {decoded_msbs_j[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][9] = {decoded_msbs_i[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][9] = {decoded_msbs_w[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][9] = {decoded_msbs_k[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][9] = {decoded_msbs_j[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][10] = {decoded_msbs_k[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][10] = {decoded_msbs_i[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][10] = {decoded_msbs_w[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][10] = {decoded_msbs_j[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][11] = {decoded_msbs_i[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][11] = {decoded_msbs_k[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][11] = {decoded_msbs_w[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][11] = {decoded_msbs_j[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][12] = {decoded_msbs_w[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][12] = {decoded_msbs_j[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][12] = {decoded_msbs_i[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][12] = {decoded_msbs_k[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][13] = {decoded_msbs_j[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][13] = {decoded_msbs_w[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][13] = {decoded_msbs_i[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][13] = {decoded_msbs_k[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][14] = {decoded_msbs_w[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][14] = {decoded_msbs_i[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][14] = {decoded_msbs_j[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][14] = {decoded_msbs_k[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][15] = {decoded_msbs_i[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][15] = {decoded_msbs_w[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][15] = {decoded_msbs_j[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][15] = {decoded_msbs_k[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][16] = {decoded_msbs_j[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][16] = {decoded_msbs_i[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][16] = {decoded_msbs_w[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][16] = {decoded_msbs_k[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][17] = {decoded_msbs_i[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][17] = {decoded_msbs_j[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][17] = {decoded_msbs_w[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][17] = {decoded_msbs_k[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][18] = {decoded_msbs_k[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][18] = {decoded_msbs_j[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][18] = {decoded_msbs_i[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][18] = {decoded_msbs_w[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][19] = {decoded_msbs_j[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][19] = {decoded_msbs_k[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][19] = {decoded_msbs_i[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][19] = {decoded_msbs_w[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][20] = {decoded_msbs_k[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][20] = {decoded_msbs_i[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][20] = {decoded_msbs_j[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][20] = {decoded_msbs_w[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][21] = {decoded_msbs_i[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][21] = {decoded_msbs_k[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][21] = {decoded_msbs_j[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][21] = {decoded_msbs_w[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][22] = {decoded_msbs_j[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][22] = {decoded_msbs_i[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][22] = {decoded_msbs_k[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][22] = {decoded_msbs_w[0], LSBs_operands1[0][3]};
assign combos_operands1[0][0][23] = {decoded_msbs_i[0], LSBs_operands1[0][0]};
assign combos_operands1[0][1][23] = {decoded_msbs_j[0], LSBs_operands1[0][1]};
assign combos_operands1[0][2][23] = {decoded_msbs_k[0], LSBs_operands1[0][2]};
assign combos_operands1[0][3][23] = {decoded_msbs_w[0], LSBs_operands1[0][3]};



assign combos_operands1[1][0][0] = {decoded_msbs_w[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][0] = {decoded_msbs_k[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][0] = {decoded_msbs_j[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][0] = {decoded_msbs_i[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][1] = {decoded_msbs_k[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][1] = {decoded_msbs_w[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][1] = {decoded_msbs_j[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][1] = {decoded_msbs_i[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][2] = {decoded_msbs_w[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][2] = {decoded_msbs_j[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][2] = {decoded_msbs_k[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][2] = {decoded_msbs_i[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][3] = {decoded_msbs_j[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][3] = {decoded_msbs_w[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][3] = {decoded_msbs_k[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][3] = {decoded_msbs_i[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][4] = {decoded_msbs_k[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][4] = {decoded_msbs_j[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][4] = {decoded_msbs_w[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][4] = {decoded_msbs_i[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][5] = {decoded_msbs_j[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][5] = {decoded_msbs_k[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][5] = {decoded_msbs_w[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][5] = {decoded_msbs_i[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][6] = {decoded_msbs_w[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][6] = {decoded_msbs_k[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][6] = {decoded_msbs_i[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][6] = {decoded_msbs_j[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][7] = {decoded_msbs_k[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][7] = {decoded_msbs_w[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][7] = {decoded_msbs_i[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][7] = {decoded_msbs_j[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][8] = {decoded_msbs_w[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][8] = {decoded_msbs_i[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][8] = {decoded_msbs_k[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][8] = {decoded_msbs_j[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][9] = {decoded_msbs_i[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][9] = {decoded_msbs_w[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][9] = {decoded_msbs_k[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][9] = {decoded_msbs_j[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][10] = {decoded_msbs_k[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][10] = {decoded_msbs_i[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][10] = {decoded_msbs_w[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][10] = {decoded_msbs_j[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][11] = {decoded_msbs_i[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][11] = {decoded_msbs_k[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][11] = {decoded_msbs_w[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][11] = {decoded_msbs_j[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][12] = {decoded_msbs_w[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][12] = {decoded_msbs_j[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][12] = {decoded_msbs_i[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][12] = {decoded_msbs_k[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][13] = {decoded_msbs_j[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][13] = {decoded_msbs_w[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][13] = {decoded_msbs_i[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][13] = {decoded_msbs_k[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][14] = {decoded_msbs_w[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][14] = {decoded_msbs_i[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][14] = {decoded_msbs_j[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][14] = {decoded_msbs_k[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][15] = {decoded_msbs_i[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][15] = {decoded_msbs_w[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][15] = {decoded_msbs_j[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][15] = {decoded_msbs_k[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][16] = {decoded_msbs_j[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][16] = {decoded_msbs_i[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][16] = {decoded_msbs_w[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][16] = {decoded_msbs_k[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][17] = {decoded_msbs_i[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][17] = {decoded_msbs_j[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][17] = {decoded_msbs_w[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][17] = {decoded_msbs_k[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][18] = {decoded_msbs_k[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][18] = {decoded_msbs_j[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][18] = {decoded_msbs_i[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][18] = {decoded_msbs_w[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][19] = {decoded_msbs_j[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][19] = {decoded_msbs_k[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][19] = {decoded_msbs_i[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][19] = {decoded_msbs_w[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][20] = {decoded_msbs_k[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][20] = {decoded_msbs_i[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][20] = {decoded_msbs_j[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][20] = {decoded_msbs_w[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][21] = {decoded_msbs_i[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][21] = {decoded_msbs_k[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][21] = {decoded_msbs_j[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][21] = {decoded_msbs_w[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][22] = {decoded_msbs_j[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][22] = {decoded_msbs_i[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][22] = {decoded_msbs_k[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][22] = {decoded_msbs_w[1], LSBs_operands1[1][3]};
assign combos_operands1[1][0][23] = {decoded_msbs_i[1], LSBs_operands1[1][0]};
assign combos_operands1[1][1][23] = {decoded_msbs_j[1], LSBs_operands1[1][1]};
assign combos_operands1[1][2][23] = {decoded_msbs_k[1], LSBs_operands1[1][2]};
assign combos_operands1[1][3][23] = {decoded_msbs_w[1], LSBs_operands1[1][3]};



assign combos_operands1[2][0][0] = {decoded_msbs_w[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][0] = {decoded_msbs_k[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][0] = {decoded_msbs_j[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][0] = {decoded_msbs_i[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][1] = {decoded_msbs_k[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][1] = {decoded_msbs_w[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][1] = {decoded_msbs_j[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][1] = {decoded_msbs_i[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][2] = {decoded_msbs_w[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][2] = {decoded_msbs_j[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][2] = {decoded_msbs_k[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][2] = {decoded_msbs_i[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][3] = {decoded_msbs_j[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][3] = {decoded_msbs_w[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][3] = {decoded_msbs_k[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][3] = {decoded_msbs_i[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][4] = {decoded_msbs_k[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][4] = {decoded_msbs_j[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][4] = {decoded_msbs_w[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][4] = {decoded_msbs_i[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][5] = {decoded_msbs_j[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][5] = {decoded_msbs_k[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][5] = {decoded_msbs_w[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][5] = {decoded_msbs_i[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][6] = {decoded_msbs_w[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][6] = {decoded_msbs_k[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][6] = {decoded_msbs_i[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][6] = {decoded_msbs_j[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][7] = {decoded_msbs_k[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][7] = {decoded_msbs_w[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][7] = {decoded_msbs_i[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][7] = {decoded_msbs_j[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][8] = {decoded_msbs_w[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][8] = {decoded_msbs_i[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][8] = {decoded_msbs_k[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][8] = {decoded_msbs_j[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][9] = {decoded_msbs_i[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][9] = {decoded_msbs_w[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][9] = {decoded_msbs_k[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][9] = {decoded_msbs_j[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][10] = {decoded_msbs_k[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][10] = {decoded_msbs_i[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][10] = {decoded_msbs_w[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][10] = {decoded_msbs_j[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][11] = {decoded_msbs_i[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][11] = {decoded_msbs_k[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][11] = {decoded_msbs_w[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][11] = {decoded_msbs_j[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][12] = {decoded_msbs_w[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][12] = {decoded_msbs_j[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][12] = {decoded_msbs_i[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][12] = {decoded_msbs_k[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][13] = {decoded_msbs_j[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][13] = {decoded_msbs_w[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][13] = {decoded_msbs_i[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][13] = {decoded_msbs_k[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][14] = {decoded_msbs_w[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][14] = {decoded_msbs_i[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][14] = {decoded_msbs_j[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][14] = {decoded_msbs_k[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][15] = {decoded_msbs_i[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][15] = {decoded_msbs_w[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][15] = {decoded_msbs_j[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][15] = {decoded_msbs_k[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][16] = {decoded_msbs_j[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][16] = {decoded_msbs_i[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][16] = {decoded_msbs_w[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][16] = {decoded_msbs_k[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][17] = {decoded_msbs_i[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][17] = {decoded_msbs_j[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][17] = {decoded_msbs_w[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][17] = {decoded_msbs_k[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][18] = {decoded_msbs_k[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][18] = {decoded_msbs_j[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][18] = {decoded_msbs_i[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][18] = {decoded_msbs_w[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][19] = {decoded_msbs_j[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][19] = {decoded_msbs_k[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][19] = {decoded_msbs_i[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][19] = {decoded_msbs_w[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][20] = {decoded_msbs_k[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][20] = {decoded_msbs_i[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][20] = {decoded_msbs_j[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][20] = {decoded_msbs_w[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][21] = {decoded_msbs_i[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][21] = {decoded_msbs_k[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][21] = {decoded_msbs_j[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][21] = {decoded_msbs_w[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][22] = {decoded_msbs_j[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][22] = {decoded_msbs_i[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][22] = {decoded_msbs_k[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][22] = {decoded_msbs_w[2], LSBs_operands1[2][3]};
assign combos_operands1[2][0][23] = {decoded_msbs_i[2], LSBs_operands1[2][0]};
assign combos_operands1[2][1][23] = {decoded_msbs_j[2], LSBs_operands1[2][1]};
assign combos_operands1[2][2][23] = {decoded_msbs_k[2], LSBs_operands1[2][2]};
assign combos_operands1[2][3][23] = {decoded_msbs_w[2], LSBs_operands1[2][3]};



assign combos_operands1[3][0][0] = {decoded_msbs_w[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][0] = {decoded_msbs_k[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][0] = {decoded_msbs_j[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][0] = {decoded_msbs_i[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][1] = {decoded_msbs_k[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][1] = {decoded_msbs_w[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][1] = {decoded_msbs_j[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][1] = {decoded_msbs_i[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][2] = {decoded_msbs_w[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][2] = {decoded_msbs_j[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][2] = {decoded_msbs_k[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][2] = {decoded_msbs_i[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][3] = {decoded_msbs_j[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][3] = {decoded_msbs_w[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][3] = {decoded_msbs_k[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][3] = {decoded_msbs_i[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][4] = {decoded_msbs_k[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][4] = {decoded_msbs_j[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][4] = {decoded_msbs_w[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][4] = {decoded_msbs_i[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][5] = {decoded_msbs_j[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][5] = {decoded_msbs_k[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][5] = {decoded_msbs_w[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][5] = {decoded_msbs_i[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][6] = {decoded_msbs_w[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][6] = {decoded_msbs_k[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][6] = {decoded_msbs_i[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][6] = {decoded_msbs_j[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][7] = {decoded_msbs_k[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][7] = {decoded_msbs_w[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][7] = {decoded_msbs_i[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][7] = {decoded_msbs_j[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][8] = {decoded_msbs_w[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][8] = {decoded_msbs_i[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][8] = {decoded_msbs_k[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][8] = {decoded_msbs_j[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][9] = {decoded_msbs_i[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][9] = {decoded_msbs_w[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][9] = {decoded_msbs_k[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][9] = {decoded_msbs_j[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][10] = {decoded_msbs_k[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][10] = {decoded_msbs_i[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][10] = {decoded_msbs_w[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][10] = {decoded_msbs_j[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][11] = {decoded_msbs_i[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][11] = {decoded_msbs_k[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][11] = {decoded_msbs_w[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][11] = {decoded_msbs_j[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][12] = {decoded_msbs_w[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][12] = {decoded_msbs_j[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][12] = {decoded_msbs_i[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][12] = {decoded_msbs_k[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][13] = {decoded_msbs_j[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][13] = {decoded_msbs_w[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][13] = {decoded_msbs_i[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][13] = {decoded_msbs_k[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][14] = {decoded_msbs_w[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][14] = {decoded_msbs_i[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][14] = {decoded_msbs_j[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][14] = {decoded_msbs_k[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][15] = {decoded_msbs_i[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][15] = {decoded_msbs_w[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][15] = {decoded_msbs_j[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][15] = {decoded_msbs_k[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][16] = {decoded_msbs_j[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][16] = {decoded_msbs_i[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][16] = {decoded_msbs_w[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][16] = {decoded_msbs_k[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][17] = {decoded_msbs_i[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][17] = {decoded_msbs_j[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][17] = {decoded_msbs_w[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][17] = {decoded_msbs_k[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][18] = {decoded_msbs_k[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][18] = {decoded_msbs_j[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][18] = {decoded_msbs_i[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][18] = {decoded_msbs_w[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][19] = {decoded_msbs_j[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][19] = {decoded_msbs_k[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][19] = {decoded_msbs_i[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][19] = {decoded_msbs_w[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][20] = {decoded_msbs_k[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][20] = {decoded_msbs_i[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][20] = {decoded_msbs_j[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][20] = {decoded_msbs_w[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][21] = {decoded_msbs_i[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][21] = {decoded_msbs_k[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][21] = {decoded_msbs_j[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][21] = {decoded_msbs_w[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][22] = {decoded_msbs_j[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][22] = {decoded_msbs_i[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][22] = {decoded_msbs_k[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][22] = {decoded_msbs_w[3], LSBs_operands1[3][3]};
assign combos_operands1[3][0][23] = {decoded_msbs_i[3], LSBs_operands1[3][0]};
assign combos_operands1[3][1][23] = {decoded_msbs_j[3], LSBs_operands1[3][1]};
assign combos_operands1[3][2][23] = {decoded_msbs_k[3], LSBs_operands1[3][2]};
assign combos_operands1[3][3][23] = {decoded_msbs_w[3], LSBs_operands1[3][3]};


assign sorted_combos_operands1[0][0] = ($signed(combos_operands1[0][3][0]) <= $signed(combos_operands1[0][2][0]) && $signed(combos_operands1[0][2][0]) <= $signed(combos_operands1[0][1][0]) && $signed(combos_operands1[0][1][0]) <= $signed(combos_operands1[0][0][0])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][1] = ($signed(combos_operands1[0][3][1]) <= $signed(combos_operands1[0][2][1]) && $signed(combos_operands1[0][2][1]) <= $signed(combos_operands1[0][1][1]) && $signed(combos_operands1[0][1][1]) <= $signed(combos_operands1[0][0][1])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][2] = ($signed(combos_operands1[0][3][2]) <= $signed(combos_operands1[0][2][2]) && $signed(combos_operands1[0][2][2]) <= $signed(combos_operands1[0][1][2]) && $signed(combos_operands1[0][1][2]) <= $signed(combos_operands1[0][0][2])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][3] = ($signed(combos_operands1[0][3][3]) <= $signed(combos_operands1[0][2][3]) && $signed(combos_operands1[0][2][3]) <= $signed(combos_operands1[0][1][3]) && $signed(combos_operands1[0][1][3]) <= $signed(combos_operands1[0][0][3])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][4] = ($signed(combos_operands1[0][3][4]) <= $signed(combos_operands1[0][2][4]) && $signed(combos_operands1[0][2][4]) <= $signed(combos_operands1[0][1][4]) && $signed(combos_operands1[0][1][4]) <= $signed(combos_operands1[0][0][4])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][5] = ($signed(combos_operands1[0][3][5]) <= $signed(combos_operands1[0][2][5]) && $signed(combos_operands1[0][2][5]) <= $signed(combos_operands1[0][1][5]) && $signed(combos_operands1[0][1][5]) <= $signed(combos_operands1[0][0][5])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][6] = ($signed(combos_operands1[0][3][6]) <= $signed(combos_operands1[0][2][6]) && $signed(combos_operands1[0][2][6]) <= $signed(combos_operands1[0][1][6]) && $signed(combos_operands1[0][1][6]) <= $signed(combos_operands1[0][0][6])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][7] = ($signed(combos_operands1[0][3][7]) <= $signed(combos_operands1[0][2][7]) && $signed(combos_operands1[0][2][7]) <= $signed(combos_operands1[0][1][7]) && $signed(combos_operands1[0][1][7]) <= $signed(combos_operands1[0][0][7])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][8] = ($signed(combos_operands1[0][3][8]) <= $signed(combos_operands1[0][2][8]) && $signed(combos_operands1[0][2][8]) <= $signed(combos_operands1[0][1][8]) && $signed(combos_operands1[0][1][8]) <= $signed(combos_operands1[0][0][8])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][9] = ($signed(combos_operands1[0][3][9]) <= $signed(combos_operands1[0][2][9]) && $signed(combos_operands1[0][2][9]) <= $signed(combos_operands1[0][1][9]) && $signed(combos_operands1[0][1][9]) <= $signed(combos_operands1[0][0][9])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][10] = ($signed(combos_operands1[0][3][10]) <= $signed(combos_operands1[0][2][10]) && $signed(combos_operands1[0][2][10]) <= $signed(combos_operands1[0][1][10]) && $signed(combos_operands1[0][1][10]) <= $signed(combos_operands1[0][0][10])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][11] = ($signed(combos_operands1[0][3][11]) <= $signed(combos_operands1[0][2][11]) && $signed(combos_operands1[0][2][11]) <= $signed(combos_operands1[0][1][11]) && $signed(combos_operands1[0][1][11]) <= $signed(combos_operands1[0][0][11])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][12] = ($signed(combos_operands1[0][3][12]) <= $signed(combos_operands1[0][2][12]) && $signed(combos_operands1[0][2][12]) <= $signed(combos_operands1[0][1][12]) && $signed(combos_operands1[0][1][12]) <= $signed(combos_operands1[0][0][12])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][13] = ($signed(combos_operands1[0][3][13]) <= $signed(combos_operands1[0][2][13]) && $signed(combos_operands1[0][2][13]) <= $signed(combos_operands1[0][1][13]) && $signed(combos_operands1[0][1][13]) <= $signed(combos_operands1[0][0][13])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][14] = ($signed(combos_operands1[0][3][14]) <= $signed(combos_operands1[0][2][14]) && $signed(combos_operands1[0][2][14]) <= $signed(combos_operands1[0][1][14]) && $signed(combos_operands1[0][1][14]) <= $signed(combos_operands1[0][0][14])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][15] = ($signed(combos_operands1[0][3][15]) <= $signed(combos_operands1[0][2][15]) && $signed(combos_operands1[0][2][15]) <= $signed(combos_operands1[0][1][15]) && $signed(combos_operands1[0][1][15]) <= $signed(combos_operands1[0][0][15])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][16] = ($signed(combos_operands1[0][3][16]) <= $signed(combos_operands1[0][2][16]) && $signed(combos_operands1[0][2][16]) <= $signed(combos_operands1[0][1][16]) && $signed(combos_operands1[0][1][16]) <= $signed(combos_operands1[0][0][16])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][17] = ($signed(combos_operands1[0][3][17]) <= $signed(combos_operands1[0][2][17]) && $signed(combos_operands1[0][2][17]) <= $signed(combos_operands1[0][1][17]) && $signed(combos_operands1[0][1][17]) <= $signed(combos_operands1[0][0][17])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][18] = ($signed(combos_operands1[0][3][18]) <= $signed(combos_operands1[0][2][18]) && $signed(combos_operands1[0][2][18]) <= $signed(combos_operands1[0][1][18]) && $signed(combos_operands1[0][1][18]) <= $signed(combos_operands1[0][0][18])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][19] = ($signed(combos_operands1[0][3][19]) <= $signed(combos_operands1[0][2][19]) && $signed(combos_operands1[0][2][19]) <= $signed(combos_operands1[0][1][19]) && $signed(combos_operands1[0][1][19]) <= $signed(combos_operands1[0][0][19])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][20] = ($signed(combos_operands1[0][3][20]) <= $signed(combos_operands1[0][2][20]) && $signed(combos_operands1[0][2][20]) <= $signed(combos_operands1[0][1][20]) && $signed(combos_operands1[0][1][20]) <= $signed(combos_operands1[0][0][20])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][21] = ($signed(combos_operands1[0][3][21]) <= $signed(combos_operands1[0][2][21]) && $signed(combos_operands1[0][2][21]) <= $signed(combos_operands1[0][1][21]) && $signed(combos_operands1[0][1][21]) <= $signed(combos_operands1[0][0][21])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][22] = ($signed(combos_operands1[0][3][22]) <= $signed(combos_operands1[0][2][22]) && $signed(combos_operands1[0][2][22]) <= $signed(combos_operands1[0][1][22]) && $signed(combos_operands1[0][1][22]) <= $signed(combos_operands1[0][0][22])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[0][23] = ($signed(combos_operands1[0][3][23]) <= $signed(combos_operands1[0][2][23]) && $signed(combos_operands1[0][2][23]) <= $signed(combos_operands1[0][1][23]) && $signed(combos_operands1[0][1][23]) <= $signed(combos_operands1[0][0][23])) ? 1'b1 : 1'b0;



assign sorted_combos_operands1[1][0] = ($signed(combos_operands1[1][3][0]) <= $signed(combos_operands1[1][2][0]) && $signed(combos_operands1[1][2][0]) <= $signed(combos_operands1[1][1][0]) && $signed(combos_operands1[1][1][0]) <= $signed(combos_operands1[1][0][0])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][1] = ($signed(combos_operands1[1][3][1]) <= $signed(combos_operands1[1][2][1]) && $signed(combos_operands1[1][2][1]) <= $signed(combos_operands1[1][1][1]) && $signed(combos_operands1[1][1][1]) <= $signed(combos_operands1[1][0][1])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][2] = ($signed(combos_operands1[1][3][2]) <= $signed(combos_operands1[1][2][2]) && $signed(combos_operands1[1][2][2]) <= $signed(combos_operands1[1][1][2]) && $signed(combos_operands1[1][1][2]) <= $signed(combos_operands1[1][0][2])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][3] = ($signed(combos_operands1[1][3][3]) <= $signed(combos_operands1[1][2][3]) && $signed(combos_operands1[1][2][3]) <= $signed(combos_operands1[1][1][3]) && $signed(combos_operands1[1][1][3]) <= $signed(combos_operands1[1][0][3])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][4] = ($signed(combos_operands1[1][3][4]) <= $signed(combos_operands1[1][2][4]) && $signed(combos_operands1[1][2][4]) <= $signed(combos_operands1[1][1][4]) && $signed(combos_operands1[1][1][4]) <= $signed(combos_operands1[1][0][4])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][5] = ($signed(combos_operands1[1][3][5]) <= $signed(combos_operands1[1][2][5]) && $signed(combos_operands1[1][2][5]) <= $signed(combos_operands1[1][1][5]) && $signed(combos_operands1[1][1][5]) <= $signed(combos_operands1[1][0][5])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][6] = ($signed(combos_operands1[1][3][6]) <= $signed(combos_operands1[1][2][6]) && $signed(combos_operands1[1][2][6]) <= $signed(combos_operands1[1][1][6]) && $signed(combos_operands1[1][1][6]) <= $signed(combos_operands1[1][0][6])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][7] = ($signed(combos_operands1[1][3][7]) <= $signed(combos_operands1[1][2][7]) && $signed(combos_operands1[1][2][7]) <= $signed(combos_operands1[1][1][7]) && $signed(combos_operands1[1][1][7]) <= $signed(combos_operands1[1][0][7])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][8] = ($signed(combos_operands1[1][3][8]) <= $signed(combos_operands1[1][2][8]) && $signed(combos_operands1[1][2][8]) <= $signed(combos_operands1[1][1][8]) && $signed(combos_operands1[1][1][8]) <= $signed(combos_operands1[1][0][8])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][9] = ($signed(combos_operands1[1][3][9]) <= $signed(combos_operands1[1][2][9]) && $signed(combos_operands1[1][2][9]) <= $signed(combos_operands1[1][1][9]) && $signed(combos_operands1[1][1][9]) <= $signed(combos_operands1[1][0][9])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][10] = ($signed(combos_operands1[1][3][10]) <= $signed(combos_operands1[1][2][10]) && $signed(combos_operands1[1][2][10]) <= $signed(combos_operands1[1][1][10]) && $signed(combos_operands1[1][1][10]) <= $signed(combos_operands1[1][0][10])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][11] = ($signed(combos_operands1[1][3][11]) <= $signed(combos_operands1[1][2][11]) && $signed(combos_operands1[1][2][11]) <= $signed(combos_operands1[1][1][11]) && $signed(combos_operands1[1][1][11]) <= $signed(combos_operands1[1][0][11])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][12] = ($signed(combos_operands1[1][3][12]) <= $signed(combos_operands1[1][2][12]) && $signed(combos_operands1[1][2][12]) <= $signed(combos_operands1[1][1][12]) && $signed(combos_operands1[1][1][12]) <= $signed(combos_operands1[1][0][12])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][13] = ($signed(combos_operands1[1][3][13]) <= $signed(combos_operands1[1][2][13]) && $signed(combos_operands1[1][2][13]) <= $signed(combos_operands1[1][1][13]) && $signed(combos_operands1[1][1][13]) <= $signed(combos_operands1[1][0][13])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][14] = ($signed(combos_operands1[1][3][14]) <= $signed(combos_operands1[1][2][14]) && $signed(combos_operands1[1][2][14]) <= $signed(combos_operands1[1][1][14]) && $signed(combos_operands1[1][1][14]) <= $signed(combos_operands1[1][0][14])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][15] = ($signed(combos_operands1[1][3][15]) <= $signed(combos_operands1[1][2][15]) && $signed(combos_operands1[1][2][15]) <= $signed(combos_operands1[1][1][15]) && $signed(combos_operands1[1][1][15]) <= $signed(combos_operands1[1][0][15])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][16] = ($signed(combos_operands1[1][3][16]) <= $signed(combos_operands1[1][2][16]) && $signed(combos_operands1[1][2][16]) <= $signed(combos_operands1[1][1][16]) && $signed(combos_operands1[1][1][16]) <= $signed(combos_operands1[1][0][16])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][17] = ($signed(combos_operands1[1][3][17]) <= $signed(combos_operands1[1][2][17]) && $signed(combos_operands1[1][2][17]) <= $signed(combos_operands1[1][1][17]) && $signed(combos_operands1[1][1][17]) <= $signed(combos_operands1[1][0][17])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][18] = ($signed(combos_operands1[1][3][18]) <= $signed(combos_operands1[1][2][18]) && $signed(combos_operands1[1][2][18]) <= $signed(combos_operands1[1][1][18]) && $signed(combos_operands1[1][1][18]) <= $signed(combos_operands1[1][0][18])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][19] = ($signed(combos_operands1[1][3][19]) <= $signed(combos_operands1[1][2][19]) && $signed(combos_operands1[1][2][19]) <= $signed(combos_operands1[1][1][19]) && $signed(combos_operands1[1][1][19]) <= $signed(combos_operands1[1][0][19])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][20] = ($signed(combos_operands1[1][3][20]) <= $signed(combos_operands1[1][2][20]) && $signed(combos_operands1[1][2][20]) <= $signed(combos_operands1[1][1][20]) && $signed(combos_operands1[1][1][20]) <= $signed(combos_operands1[1][0][20])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][21] = ($signed(combos_operands1[1][3][21]) <= $signed(combos_operands1[1][2][21]) && $signed(combos_operands1[1][2][21]) <= $signed(combos_operands1[1][1][21]) && $signed(combos_operands1[1][1][21]) <= $signed(combos_operands1[1][0][21])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][22] = ($signed(combos_operands1[1][3][22]) <= $signed(combos_operands1[1][2][22]) && $signed(combos_operands1[1][2][22]) <= $signed(combos_operands1[1][1][22]) && $signed(combos_operands1[1][1][22]) <= $signed(combos_operands1[1][0][22])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[1][23] = ($signed(combos_operands1[1][3][23]) <= $signed(combos_operands1[1][2][23]) && $signed(combos_operands1[1][2][23]) <= $signed(combos_operands1[1][1][23]) && $signed(combos_operands1[1][1][23]) <= $signed(combos_operands1[1][0][23])) ? 1'b1 : 1'b0;



assign sorted_combos_operands1[2][0] = ($signed(combos_operands1[2][3][0]) <= $signed(combos_operands1[2][2][0]) && $signed(combos_operands1[2][2][0]) <= $signed(combos_operands1[2][1][0]) && $signed(combos_operands1[2][1][0]) <= $signed(combos_operands1[2][0][0])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][1] = ($signed(combos_operands1[2][3][1]) <= $signed(combos_operands1[2][2][1]) && $signed(combos_operands1[2][2][1]) <= $signed(combos_operands1[2][1][1]) && $signed(combos_operands1[2][1][1]) <= $signed(combos_operands1[2][0][1])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][2] = ($signed(combos_operands1[2][3][2]) <= $signed(combos_operands1[2][2][2]) && $signed(combos_operands1[2][2][2]) <= $signed(combos_operands1[2][1][2]) && $signed(combos_operands1[2][1][2]) <= $signed(combos_operands1[2][0][2])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][3] = ($signed(combos_operands1[2][3][3]) <= $signed(combos_operands1[2][2][3]) && $signed(combos_operands1[2][2][3]) <= $signed(combos_operands1[2][1][3]) && $signed(combos_operands1[2][1][3]) <= $signed(combos_operands1[2][0][3])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][4] = ($signed(combos_operands1[2][3][4]) <= $signed(combos_operands1[2][2][4]) && $signed(combos_operands1[2][2][4]) <= $signed(combos_operands1[2][1][4]) && $signed(combos_operands1[2][1][4]) <= $signed(combos_operands1[2][0][4])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][5] = ($signed(combos_operands1[2][3][5]) <= $signed(combos_operands1[2][2][5]) && $signed(combos_operands1[2][2][5]) <= $signed(combos_operands1[2][1][5]) && $signed(combos_operands1[2][1][5]) <= $signed(combos_operands1[2][0][5])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][6] = ($signed(combos_operands1[2][3][6]) <= $signed(combos_operands1[2][2][6]) && $signed(combos_operands1[2][2][6]) <= $signed(combos_operands1[2][1][6]) && $signed(combos_operands1[2][1][6]) <= $signed(combos_operands1[2][0][6])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][7] = ($signed(combos_operands1[2][3][7]) <= $signed(combos_operands1[2][2][7]) && $signed(combos_operands1[2][2][7]) <= $signed(combos_operands1[2][1][7]) && $signed(combos_operands1[2][1][7]) <= $signed(combos_operands1[2][0][7])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][8] = ($signed(combos_operands1[2][3][8]) <= $signed(combos_operands1[2][2][8]) && $signed(combos_operands1[2][2][8]) <= $signed(combos_operands1[2][1][8]) && $signed(combos_operands1[2][1][8]) <= $signed(combos_operands1[2][0][8])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][9] = ($signed(combos_operands1[2][3][9]) <= $signed(combos_operands1[2][2][9]) && $signed(combos_operands1[2][2][9]) <= $signed(combos_operands1[2][1][9]) && $signed(combos_operands1[2][1][9]) <= $signed(combos_operands1[2][0][9])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][10] = ($signed(combos_operands1[2][3][10]) <= $signed(combos_operands1[2][2][10]) && $signed(combos_operands1[2][2][10]) <= $signed(combos_operands1[2][1][10]) && $signed(combos_operands1[2][1][10]) <= $signed(combos_operands1[2][0][10])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][11] = ($signed(combos_operands1[2][3][11]) <= $signed(combos_operands1[2][2][11]) && $signed(combos_operands1[2][2][11]) <= $signed(combos_operands1[2][1][11]) && $signed(combos_operands1[2][1][11]) <= $signed(combos_operands1[2][0][11])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][12] = ($signed(combos_operands1[2][3][12]) <= $signed(combos_operands1[2][2][12]) && $signed(combos_operands1[2][2][12]) <= $signed(combos_operands1[2][1][12]) && $signed(combos_operands1[2][1][12]) <= $signed(combos_operands1[2][0][12])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][13] = ($signed(combos_operands1[2][3][13]) <= $signed(combos_operands1[2][2][13]) && $signed(combos_operands1[2][2][13]) <= $signed(combos_operands1[2][1][13]) && $signed(combos_operands1[2][1][13]) <= $signed(combos_operands1[2][0][13])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][14] = ($signed(combos_operands1[2][3][14]) <= $signed(combos_operands1[2][2][14]) && $signed(combos_operands1[2][2][14]) <= $signed(combos_operands1[2][1][14]) && $signed(combos_operands1[2][1][14]) <= $signed(combos_operands1[2][0][14])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][15] = ($signed(combos_operands1[2][3][15]) <= $signed(combos_operands1[2][2][15]) && $signed(combos_operands1[2][2][15]) <= $signed(combos_operands1[2][1][15]) && $signed(combos_operands1[2][1][15]) <= $signed(combos_operands1[2][0][15])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][16] = ($signed(combos_operands1[2][3][16]) <= $signed(combos_operands1[2][2][16]) && $signed(combos_operands1[2][2][16]) <= $signed(combos_operands1[2][1][16]) && $signed(combos_operands1[2][1][16]) <= $signed(combos_operands1[2][0][16])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][17] = ($signed(combos_operands1[2][3][17]) <= $signed(combos_operands1[2][2][17]) && $signed(combos_operands1[2][2][17]) <= $signed(combos_operands1[2][1][17]) && $signed(combos_operands1[2][1][17]) <= $signed(combos_operands1[2][0][17])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][18] = ($signed(combos_operands1[2][3][18]) <= $signed(combos_operands1[2][2][18]) && $signed(combos_operands1[2][2][18]) <= $signed(combos_operands1[2][1][18]) && $signed(combos_operands1[2][1][18]) <= $signed(combos_operands1[2][0][18])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][19] = ($signed(combos_operands1[2][3][19]) <= $signed(combos_operands1[2][2][19]) && $signed(combos_operands1[2][2][19]) <= $signed(combos_operands1[2][1][19]) && $signed(combos_operands1[2][1][19]) <= $signed(combos_operands1[2][0][19])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][20] = ($signed(combos_operands1[2][3][20]) <= $signed(combos_operands1[2][2][20]) && $signed(combos_operands1[2][2][20]) <= $signed(combos_operands1[2][1][20]) && $signed(combos_operands1[2][1][20]) <= $signed(combos_operands1[2][0][20])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][21] = ($signed(combos_operands1[2][3][21]) <= $signed(combos_operands1[2][2][21]) && $signed(combos_operands1[2][2][21]) <= $signed(combos_operands1[2][1][21]) && $signed(combos_operands1[2][1][21]) <= $signed(combos_operands1[2][0][21])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][22] = ($signed(combos_operands1[2][3][22]) <= $signed(combos_operands1[2][2][22]) && $signed(combos_operands1[2][2][22]) <= $signed(combos_operands1[2][1][22]) && $signed(combos_operands1[2][1][22]) <= $signed(combos_operands1[2][0][22])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[2][23] = ($signed(combos_operands1[2][3][23]) <= $signed(combos_operands1[2][2][23]) && $signed(combos_operands1[2][2][23]) <= $signed(combos_operands1[2][1][23]) && $signed(combos_operands1[2][1][23]) <= $signed(combos_operands1[2][0][23])) ? 1'b1 : 1'b0;



assign sorted_combos_operands1[3][0] = ($signed(combos_operands1[3][3][0]) <= $signed(combos_operands1[3][2][0]) && $signed(combos_operands1[3][2][0]) <= $signed(combos_operands1[3][1][0]) && $signed(combos_operands1[3][1][0]) <= $signed(combos_operands1[3][0][0])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][1] = ($signed(combos_operands1[3][3][1]) <= $signed(combos_operands1[3][2][1]) && $signed(combos_operands1[3][2][1]) <= $signed(combos_operands1[3][1][1]) && $signed(combos_operands1[3][1][1]) <= $signed(combos_operands1[3][0][1])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][2] = ($signed(combos_operands1[3][3][2]) <= $signed(combos_operands1[3][2][2]) && $signed(combos_operands1[3][2][2]) <= $signed(combos_operands1[3][1][2]) && $signed(combos_operands1[3][1][2]) <= $signed(combos_operands1[3][0][2])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][3] = ($signed(combos_operands1[3][3][3]) <= $signed(combos_operands1[3][2][3]) && $signed(combos_operands1[3][2][3]) <= $signed(combos_operands1[3][1][3]) && $signed(combos_operands1[3][1][3]) <= $signed(combos_operands1[3][0][3])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][4] = ($signed(combos_operands1[3][3][4]) <= $signed(combos_operands1[3][2][4]) && $signed(combos_operands1[3][2][4]) <= $signed(combos_operands1[3][1][4]) && $signed(combos_operands1[3][1][4]) <= $signed(combos_operands1[3][0][4])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][5] = ($signed(combos_operands1[3][3][5]) <= $signed(combos_operands1[3][2][5]) && $signed(combos_operands1[3][2][5]) <= $signed(combos_operands1[3][1][5]) && $signed(combos_operands1[3][1][5]) <= $signed(combos_operands1[3][0][5])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][6] = ($signed(combos_operands1[3][3][6]) <= $signed(combos_operands1[3][2][6]) && $signed(combos_operands1[3][2][6]) <= $signed(combos_operands1[3][1][6]) && $signed(combos_operands1[3][1][6]) <= $signed(combos_operands1[3][0][6])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][7] = ($signed(combos_operands1[3][3][7]) <= $signed(combos_operands1[3][2][7]) && $signed(combos_operands1[3][2][7]) <= $signed(combos_operands1[3][1][7]) && $signed(combos_operands1[3][1][7]) <= $signed(combos_operands1[3][0][7])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][8] = ($signed(combos_operands1[3][3][8]) <= $signed(combos_operands1[3][2][8]) && $signed(combos_operands1[3][2][8]) <= $signed(combos_operands1[3][1][8]) && $signed(combos_operands1[3][1][8]) <= $signed(combos_operands1[3][0][8])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][9] = ($signed(combos_operands1[3][3][9]) <= $signed(combos_operands1[3][2][9]) && $signed(combos_operands1[3][2][9]) <= $signed(combos_operands1[3][1][9]) && $signed(combos_operands1[3][1][9]) <= $signed(combos_operands1[3][0][9])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][10] = ($signed(combos_operands1[3][3][10]) <= $signed(combos_operands1[3][2][10]) && $signed(combos_operands1[3][2][10]) <= $signed(combos_operands1[3][1][10]) && $signed(combos_operands1[3][1][10]) <= $signed(combos_operands1[3][0][10])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][11] = ($signed(combos_operands1[3][3][11]) <= $signed(combos_operands1[3][2][11]) && $signed(combos_operands1[3][2][11]) <= $signed(combos_operands1[3][1][11]) && $signed(combos_operands1[3][1][11]) <= $signed(combos_operands1[3][0][11])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][12] = ($signed(combos_operands1[3][3][12]) <= $signed(combos_operands1[3][2][12]) && $signed(combos_operands1[3][2][12]) <= $signed(combos_operands1[3][1][12]) && $signed(combos_operands1[3][1][12]) <= $signed(combos_operands1[3][0][12])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][13] = ($signed(combos_operands1[3][3][13]) <= $signed(combos_operands1[3][2][13]) && $signed(combos_operands1[3][2][13]) <= $signed(combos_operands1[3][1][13]) && $signed(combos_operands1[3][1][13]) <= $signed(combos_operands1[3][0][13])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][14] = ($signed(combos_operands1[3][3][14]) <= $signed(combos_operands1[3][2][14]) && $signed(combos_operands1[3][2][14]) <= $signed(combos_operands1[3][1][14]) && $signed(combos_operands1[3][1][14]) <= $signed(combos_operands1[3][0][14])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][15] = ($signed(combos_operands1[3][3][15]) <= $signed(combos_operands1[3][2][15]) && $signed(combos_operands1[3][2][15]) <= $signed(combos_operands1[3][1][15]) && $signed(combos_operands1[3][1][15]) <= $signed(combos_operands1[3][0][15])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][16] = ($signed(combos_operands1[3][3][16]) <= $signed(combos_operands1[3][2][16]) && $signed(combos_operands1[3][2][16]) <= $signed(combos_operands1[3][1][16]) && $signed(combos_operands1[3][1][16]) <= $signed(combos_operands1[3][0][16])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][17] = ($signed(combos_operands1[3][3][17]) <= $signed(combos_operands1[3][2][17]) && $signed(combos_operands1[3][2][17]) <= $signed(combos_operands1[3][1][17]) && $signed(combos_operands1[3][1][17]) <= $signed(combos_operands1[3][0][17])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][18] = ($signed(combos_operands1[3][3][18]) <= $signed(combos_operands1[3][2][18]) && $signed(combos_operands1[3][2][18]) <= $signed(combos_operands1[3][1][18]) && $signed(combos_operands1[3][1][18]) <= $signed(combos_operands1[3][0][18])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][19] = ($signed(combos_operands1[3][3][19]) <= $signed(combos_operands1[3][2][19]) && $signed(combos_operands1[3][2][19]) <= $signed(combos_operands1[3][1][19]) && $signed(combos_operands1[3][1][19]) <= $signed(combos_operands1[3][0][19])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][20] = ($signed(combos_operands1[3][3][20]) <= $signed(combos_operands1[3][2][20]) && $signed(combos_operands1[3][2][20]) <= $signed(combos_operands1[3][1][20]) && $signed(combos_operands1[3][1][20]) <= $signed(combos_operands1[3][0][20])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][21] = ($signed(combos_operands1[3][3][21]) <= $signed(combos_operands1[3][2][21]) && $signed(combos_operands1[3][2][21]) <= $signed(combos_operands1[3][1][21]) && $signed(combos_operands1[3][1][21]) <= $signed(combos_operands1[3][0][21])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][22] = ($signed(combos_operands1[3][3][22]) <= $signed(combos_operands1[3][2][22]) && $signed(combos_operands1[3][2][22]) <= $signed(combos_operands1[3][1][22]) && $signed(combos_operands1[3][1][22]) <= $signed(combos_operands1[3][0][22])) ? 1'b1 : 1'b0;
assign sorted_combos_operands1[3][23] = ($signed(combos_operands1[3][3][23]) <= $signed(combos_operands1[3][2][23]) && $signed(combos_operands1[3][2][23]) <= $signed(combos_operands1[3][1][23]) && $signed(combos_operands1[3][1][23]) <= $signed(combos_operands1[3][0][23])) ? 1'b1 : 1'b0;



assign zeros_operand1= 8'b0;


assign operands1[0][0] = (sorted_combos_operands1[0][0]) ? combos_operands1[0][0][0][7 : 0] :
                      (sorted_combos_operands1[0][1]) ? combos_operands1[0][0][1][7 : 0] :
                      (sorted_combos_operands1[0][2]) ? combos_operands1[0][0][2][7 : 0] :
                      (sorted_combos_operands1[0][3]) ? combos_operands1[0][0][3][7 : 0] :
                      (sorted_combos_operands1[0][4]) ? combos_operands1[0][0][4][7 : 0] :
                      (sorted_combos_operands1[0][5]) ? combos_operands1[0][0][5][7 : 0] :
                      (sorted_combos_operands1[0][6]) ? combos_operands1[0][0][6][7 : 0] :
                      (sorted_combos_operands1[0][7]) ? combos_operands1[0][0][7][7 : 0] :
                      (sorted_combos_operands1[0][8]) ? combos_operands1[0][0][8][7 : 0] :
                      (sorted_combos_operands1[0][9]) ? combos_operands1[0][0][9][7 : 0] :
                      (sorted_combos_operands1[0][10]) ? combos_operands1[0][0][10][7 : 0] :
                      (sorted_combos_operands1[0][11]) ? combos_operands1[0][0][11][7 : 0] :
                      (sorted_combos_operands1[0][12]) ? combos_operands1[0][0][12][7 : 0] :
                      (sorted_combos_operands1[0][13]) ? combos_operands1[0][0][13][7 : 0] :
                      (sorted_combos_operands1[0][14]) ? combos_operands1[0][0][14][7 : 0] :
                      (sorted_combos_operands1[0][15]) ? combos_operands1[0][0][15][7 : 0] :
                      (sorted_combos_operands1[0][16]) ? combos_operands1[0][0][16][7 : 0] :
                      (sorted_combos_operands1[0][17]) ? combos_operands1[0][0][17][7 : 0] :
                      (sorted_combos_operands1[0][18]) ? combos_operands1[0][0][18][7 : 0] :
                      (sorted_combos_operands1[0][19]) ? combos_operands1[0][0][19][7 : 0] :
                      (sorted_combos_operands1[0][20]) ? combos_operands1[0][0][20][7 : 0] :
                      (sorted_combos_operands1[0][21]) ? combos_operands1[0][0][21][7 : 0] :
                      (sorted_combos_operands1[0][22]) ? combos_operands1[0][0][22][7 : 0] :
                      (sorted_combos_operands1[0][23]) ? combos_operands1[0][0][23][7 : 0] : zeros_operand1;

assign operands1[0][1] = (sorted_combos_operands1[0][0]) ? combos_operands1[0][1][0][7 : 0] :
                      (sorted_combos_operands1[0][1]) ? combos_operands1[0][1][1][7 : 0] :
                      (sorted_combos_operands1[0][2]) ? combos_operands1[0][1][2][7 : 0] :
                      (sorted_combos_operands1[0][3]) ? combos_operands1[0][1][3][7 : 0] :
                      (sorted_combos_operands1[0][4]) ? combos_operands1[0][1][4][7 : 0] :
                      (sorted_combos_operands1[0][5]) ? combos_operands1[0][1][5][7 : 0] :
                      (sorted_combos_operands1[0][6]) ? combos_operands1[0][1][6][7 : 0] :
                      (sorted_combos_operands1[0][7]) ? combos_operands1[0][1][7][7 : 0] :
                      (sorted_combos_operands1[0][8]) ? combos_operands1[0][1][8][7 : 0] :
                      (sorted_combos_operands1[0][9]) ? combos_operands1[0][1][9][7 : 0] :
                      (sorted_combos_operands1[0][10]) ? combos_operands1[0][1][10][7 : 0] :
                      (sorted_combos_operands1[0][11]) ? combos_operands1[0][1][11][7 : 0] :
                      (sorted_combos_operands1[0][12]) ? combos_operands1[0][1][12][7 : 0] :
                      (sorted_combos_operands1[0][13]) ? combos_operands1[0][1][13][7 : 0] :
                      (sorted_combos_operands1[0][14]) ? combos_operands1[0][1][14][7 : 0] :
                      (sorted_combos_operands1[0][15]) ? combos_operands1[0][1][15][7 : 0] :
                      (sorted_combos_operands1[0][16]) ? combos_operands1[0][1][16][7 : 0] :
                      (sorted_combos_operands1[0][17]) ? combos_operands1[0][1][17][7 : 0] :
                      (sorted_combos_operands1[0][18]) ? combos_operands1[0][1][18][7 : 0] :
                      (sorted_combos_operands1[0][19]) ? combos_operands1[0][1][19][7 : 0] :
                      (sorted_combos_operands1[0][20]) ? combos_operands1[0][1][20][7 : 0] :
                      (sorted_combos_operands1[0][21]) ? combos_operands1[0][1][21][7 : 0] :
                      (sorted_combos_operands1[0][22]) ? combos_operands1[0][1][22][7 : 0] :
                      (sorted_combos_operands1[0][23]) ? combos_operands1[0][1][23][7 : 0] : zeros_operand1;

assign operands1[0][2] = (sorted_combos_operands1[0][0]) ? combos_operands1[0][2][0][7 : 0] :
                      (sorted_combos_operands1[0][1]) ? combos_operands1[0][2][1][7 : 0] :
                      (sorted_combos_operands1[0][2]) ? combos_operands1[0][2][2][7 : 0] :
                      (sorted_combos_operands1[0][3]) ? combos_operands1[0][2][3][7 : 0] :
                      (sorted_combos_operands1[0][4]) ? combos_operands1[0][2][4][7 : 0] :
                      (sorted_combos_operands1[0][5]) ? combos_operands1[0][2][5][7 : 0] :
                      (sorted_combos_operands1[0][6]) ? combos_operands1[0][2][6][7 : 0] :
                      (sorted_combos_operands1[0][7]) ? combos_operands1[0][2][7][7 : 0] :
                      (sorted_combos_operands1[0][8]) ? combos_operands1[0][2][8][7 : 0] :
                      (sorted_combos_operands1[0][9]) ? combos_operands1[0][2][9][7 : 0] :
                      (sorted_combos_operands1[0][10]) ? combos_operands1[0][2][10][7 : 0] :
                      (sorted_combos_operands1[0][11]) ? combos_operands1[0][2][11][7 : 0] :
                      (sorted_combos_operands1[0][12]) ? combos_operands1[0][2][12][7 : 0] :
                      (sorted_combos_operands1[0][13]) ? combos_operands1[0][2][13][7 : 0] :
                      (sorted_combos_operands1[0][14]) ? combos_operands1[0][2][14][7 : 0] :
                      (sorted_combos_operands1[0][15]) ? combos_operands1[0][2][15][7 : 0] :
                      (sorted_combos_operands1[0][16]) ? combos_operands1[0][2][16][7 : 0] :
                      (sorted_combos_operands1[0][17]) ? combos_operands1[0][2][17][7 : 0] :
                      (sorted_combos_operands1[0][18]) ? combos_operands1[0][2][18][7 : 0] :
                      (sorted_combos_operands1[0][19]) ? combos_operands1[0][2][19][7 : 0] :
                      (sorted_combos_operands1[0][20]) ? combos_operands1[0][2][20][7 : 0] :
                      (sorted_combos_operands1[0][21]) ? combos_operands1[0][2][21][7 : 0] :
                      (sorted_combos_operands1[0][22]) ? combos_operands1[0][2][22][7 : 0] :
                      (sorted_combos_operands1[0][23]) ? combos_operands1[0][2][23][7 : 0] : zeros_operand1;

assign operands1[0][3] = (sorted_combos_operands1[0][0]) ? combos_operands1[0][3][0][7 : 0] :
                      (sorted_combos_operands1[0][1]) ? combos_operands1[0][3][1][7 : 0] :
                      (sorted_combos_operands1[0][2]) ? combos_operands1[0][3][2][7 : 0] :
                      (sorted_combos_operands1[0][3]) ? combos_operands1[0][3][3][7 : 0] :
                      (sorted_combos_operands1[0][4]) ? combos_operands1[0][3][4][7 : 0] :
                      (sorted_combos_operands1[0][5]) ? combos_operands1[0][3][5][7 : 0] :
                      (sorted_combos_operands1[0][6]) ? combos_operands1[0][3][6][7 : 0] :
                      (sorted_combos_operands1[0][7]) ? combos_operands1[0][3][7][7 : 0] :
                      (sorted_combos_operands1[0][8]) ? combos_operands1[0][3][8][7 : 0] :
                      (sorted_combos_operands1[0][9]) ? combos_operands1[0][3][9][7 : 0] :
                      (sorted_combos_operands1[0][10]) ? combos_operands1[0][3][10][7 : 0] :
                      (sorted_combos_operands1[0][11]) ? combos_operands1[0][3][11][7 : 0] :
                      (sorted_combos_operands1[0][12]) ? combos_operands1[0][3][12][7 : 0] :
                      (sorted_combos_operands1[0][13]) ? combos_operands1[0][3][13][7 : 0] :
                      (sorted_combos_operands1[0][14]) ? combos_operands1[0][3][14][7 : 0] :
                      (sorted_combos_operands1[0][15]) ? combos_operands1[0][3][15][7 : 0] :
                      (sorted_combos_operands1[0][16]) ? combos_operands1[0][3][16][7 : 0] :
                      (sorted_combos_operands1[0][17]) ? combos_operands1[0][3][17][7 : 0] :
                      (sorted_combos_operands1[0][18]) ? combos_operands1[0][3][18][7 : 0] :
                      (sorted_combos_operands1[0][19]) ? combos_operands1[0][3][19][7 : 0] :
                      (sorted_combos_operands1[0][20]) ? combos_operands1[0][3][20][7 : 0] :
                      (sorted_combos_operands1[0][21]) ? combos_operands1[0][3][21][7 : 0] :
                      (sorted_combos_operands1[0][22]) ? combos_operands1[0][3][22][7 : 0] :
                      (sorted_combos_operands1[0][23]) ? combos_operands1[0][3][23][7 : 0] : zeros_operand1;



assign operands1[1][0] = (sorted_combos_operands1[1][0]) ? combos_operands1[1][0][0][7 : 0] :
                      (sorted_combos_operands1[1][1]) ? combos_operands1[1][0][1][7 : 0] :
                      (sorted_combos_operands1[1][2]) ? combos_operands1[1][0][2][7 : 0] :
                      (sorted_combos_operands1[1][3]) ? combos_operands1[1][0][3][7 : 0] :
                      (sorted_combos_operands1[1][4]) ? combos_operands1[1][0][4][7 : 0] :
                      (sorted_combos_operands1[1][5]) ? combos_operands1[1][0][5][7 : 0] :
                      (sorted_combos_operands1[1][6]) ? combos_operands1[1][0][6][7 : 0] :
                      (sorted_combos_operands1[1][7]) ? combos_operands1[1][0][7][7 : 0] :
                      (sorted_combos_operands1[1][8]) ? combos_operands1[1][0][8][7 : 0] :
                      (sorted_combos_operands1[1][9]) ? combos_operands1[1][0][9][7 : 0] :
                      (sorted_combos_operands1[1][10]) ? combos_operands1[1][0][10][7 : 0] :
                      (sorted_combos_operands1[1][11]) ? combos_operands1[1][0][11][7 : 0] :
                      (sorted_combos_operands1[1][12]) ? combos_operands1[1][0][12][7 : 0] :
                      (sorted_combos_operands1[1][13]) ? combos_operands1[1][0][13][7 : 0] :
                      (sorted_combos_operands1[1][14]) ? combos_operands1[1][0][14][7 : 0] :
                      (sorted_combos_operands1[1][15]) ? combos_operands1[1][0][15][7 : 0] :
                      (sorted_combos_operands1[1][16]) ? combos_operands1[1][0][16][7 : 0] :
                      (sorted_combos_operands1[1][17]) ? combos_operands1[1][0][17][7 : 0] :
                      (sorted_combos_operands1[1][18]) ? combos_operands1[1][0][18][7 : 0] :
                      (sorted_combos_operands1[1][19]) ? combos_operands1[1][0][19][7 : 0] :
                      (sorted_combos_operands1[1][20]) ? combos_operands1[1][0][20][7 : 0] :
                      (sorted_combos_operands1[1][21]) ? combos_operands1[1][0][21][7 : 0] :
                      (sorted_combos_operands1[1][22]) ? combos_operands1[1][0][22][7 : 0] :
                      (sorted_combos_operands1[1][23]) ? combos_operands1[1][0][23][7 : 0] : zeros_operand1;

assign operands1[1][1] = (sorted_combos_operands1[1][0]) ? combos_operands1[1][1][0][7 : 0] :
                      (sorted_combos_operands1[1][1]) ? combos_operands1[1][1][1][7 : 0] :
                      (sorted_combos_operands1[1][2]) ? combos_operands1[1][1][2][7 : 0] :
                      (sorted_combos_operands1[1][3]) ? combos_operands1[1][1][3][7 : 0] :
                      (sorted_combos_operands1[1][4]) ? combos_operands1[1][1][4][7 : 0] :
                      (sorted_combos_operands1[1][5]) ? combos_operands1[1][1][5][7 : 0] :
                      (sorted_combos_operands1[1][6]) ? combos_operands1[1][1][6][7 : 0] :
                      (sorted_combos_operands1[1][7]) ? combos_operands1[1][1][7][7 : 0] :
                      (sorted_combos_operands1[1][8]) ? combos_operands1[1][1][8][7 : 0] :
                      (sorted_combos_operands1[1][9]) ? combos_operands1[1][1][9][7 : 0] :
                      (sorted_combos_operands1[1][10]) ? combos_operands1[1][1][10][7 : 0] :
                      (sorted_combos_operands1[1][11]) ? combos_operands1[1][1][11][7 : 0] :
                      (sorted_combos_operands1[1][12]) ? combos_operands1[1][1][12][7 : 0] :
                      (sorted_combos_operands1[1][13]) ? combos_operands1[1][1][13][7 : 0] :
                      (sorted_combos_operands1[1][14]) ? combos_operands1[1][1][14][7 : 0] :
                      (sorted_combos_operands1[1][15]) ? combos_operands1[1][1][15][7 : 0] :
                      (sorted_combos_operands1[1][16]) ? combos_operands1[1][1][16][7 : 0] :
                      (sorted_combos_operands1[1][17]) ? combos_operands1[1][1][17][7 : 0] :
                      (sorted_combos_operands1[1][18]) ? combos_operands1[1][1][18][7 : 0] :
                      (sorted_combos_operands1[1][19]) ? combos_operands1[1][1][19][7 : 0] :
                      (sorted_combos_operands1[1][20]) ? combos_operands1[1][1][20][7 : 0] :
                      (sorted_combos_operands1[1][21]) ? combos_operands1[1][1][21][7 : 0] :
                      (sorted_combos_operands1[1][22]) ? combos_operands1[1][1][22][7 : 0] :
                      (sorted_combos_operands1[1][23]) ? combos_operands1[1][1][23][7 : 0] : zeros_operand1;

assign operands1[1][2] = (sorted_combos_operands1[1][0]) ? combos_operands1[1][2][0][7 : 0] :
                      (sorted_combos_operands1[1][1]) ? combos_operands1[1][2][1][7 : 0] :
                      (sorted_combos_operands1[1][2]) ? combos_operands1[1][2][2][7 : 0] :
                      (sorted_combos_operands1[1][3]) ? combos_operands1[1][2][3][7 : 0] :
                      (sorted_combos_operands1[1][4]) ? combos_operands1[1][2][4][7 : 0] :
                      (sorted_combos_operands1[1][5]) ? combos_operands1[1][2][5][7 : 0] :
                      (sorted_combos_operands1[1][6]) ? combos_operands1[1][2][6][7 : 0] :
                      (sorted_combos_operands1[1][7]) ? combos_operands1[1][2][7][7 : 0] :
                      (sorted_combos_operands1[1][8]) ? combos_operands1[1][2][8][7 : 0] :
                      (sorted_combos_operands1[1][9]) ? combos_operands1[1][2][9][7 : 0] :
                      (sorted_combos_operands1[1][10]) ? combos_operands1[1][2][10][7 : 0] :
                      (sorted_combos_operands1[1][11]) ? combos_operands1[1][2][11][7 : 0] :
                      (sorted_combos_operands1[1][12]) ? combos_operands1[1][2][12][7 : 0] :
                      (sorted_combos_operands1[1][13]) ? combos_operands1[1][2][13][7 : 0] :
                      (sorted_combos_operands1[1][14]) ? combos_operands1[1][2][14][7 : 0] :
                      (sorted_combos_operands1[1][15]) ? combos_operands1[1][2][15][7 : 0] :
                      (sorted_combos_operands1[1][16]) ? combos_operands1[1][2][16][7 : 0] :
                      (sorted_combos_operands1[1][17]) ? combos_operands1[1][2][17][7 : 0] :
                      (sorted_combos_operands1[1][18]) ? combos_operands1[1][2][18][7 : 0] :
                      (sorted_combos_operands1[1][19]) ? combos_operands1[1][2][19][7 : 0] :
                      (sorted_combos_operands1[1][20]) ? combos_operands1[1][2][20][7 : 0] :
                      (sorted_combos_operands1[1][21]) ? combos_operands1[1][2][21][7 : 0] :
                      (sorted_combos_operands1[1][22]) ? combos_operands1[1][2][22][7 : 0] :
                      (sorted_combos_operands1[1][23]) ? combos_operands1[1][2][23][7 : 0] : zeros_operand1;

assign operands1[1][3] = (sorted_combos_operands1[1][0]) ? combos_operands1[1][3][0][7 : 0] :
                      (sorted_combos_operands1[1][1]) ? combos_operands1[1][3][1][7 : 0] :
                      (sorted_combos_operands1[1][2]) ? combos_operands1[1][3][2][7 : 0] :
                      (sorted_combos_operands1[1][3]) ? combos_operands1[1][3][3][7 : 0] :
                      (sorted_combos_operands1[1][4]) ? combos_operands1[1][3][4][7 : 0] :
                      (sorted_combos_operands1[1][5]) ? combos_operands1[1][3][5][7 : 0] :
                      (sorted_combos_operands1[1][6]) ? combos_operands1[1][3][6][7 : 0] :
                      (sorted_combos_operands1[1][7]) ? combos_operands1[1][3][7][7 : 0] :
                      (sorted_combos_operands1[1][8]) ? combos_operands1[1][3][8][7 : 0] :
                      (sorted_combos_operands1[1][9]) ? combos_operands1[1][3][9][7 : 0] :
                      (sorted_combos_operands1[1][10]) ? combos_operands1[1][3][10][7 : 0] :
                      (sorted_combos_operands1[1][11]) ? combos_operands1[1][3][11][7 : 0] :
                      (sorted_combos_operands1[1][12]) ? combos_operands1[1][3][12][7 : 0] :
                      (sorted_combos_operands1[1][13]) ? combos_operands1[1][3][13][7 : 0] :
                      (sorted_combos_operands1[1][14]) ? combos_operands1[1][3][14][7 : 0] :
                      (sorted_combos_operands1[1][15]) ? combos_operands1[1][3][15][7 : 0] :
                      (sorted_combos_operands1[1][16]) ? combos_operands1[1][3][16][7 : 0] :
                      (sorted_combos_operands1[1][17]) ? combos_operands1[1][3][17][7 : 0] :
                      (sorted_combos_operands1[1][18]) ? combos_operands1[1][3][18][7 : 0] :
                      (sorted_combos_operands1[1][19]) ? combos_operands1[1][3][19][7 : 0] :
                      (sorted_combos_operands1[1][20]) ? combos_operands1[1][3][20][7 : 0] :
                      (sorted_combos_operands1[1][21]) ? combos_operands1[1][3][21][7 : 0] :
                      (sorted_combos_operands1[1][22]) ? combos_operands1[1][3][22][7 : 0] :
                      (sorted_combos_operands1[1][23]) ? combos_operands1[1][3][23][7 : 0] : zeros_operand1;



assign operands1[2][0] = (sorted_combos_operands1[2][0]) ? combos_operands1[2][0][0][7 : 0] :
                      (sorted_combos_operands1[2][1]) ? combos_operands1[2][0][1][7 : 0] :
                      (sorted_combos_operands1[2][2]) ? combos_operands1[2][0][2][7 : 0] :
                      (sorted_combos_operands1[2][3]) ? combos_operands1[2][0][3][7 : 0] :
                      (sorted_combos_operands1[2][4]) ? combos_operands1[2][0][4][7 : 0] :
                      (sorted_combos_operands1[2][5]) ? combos_operands1[2][0][5][7 : 0] :
                      (sorted_combos_operands1[2][6]) ? combos_operands1[2][0][6][7 : 0] :
                      (sorted_combos_operands1[2][7]) ? combos_operands1[2][0][7][7 : 0] :
                      (sorted_combos_operands1[2][8]) ? combos_operands1[2][0][8][7 : 0] :
                      (sorted_combos_operands1[2][9]) ? combos_operands1[2][0][9][7 : 0] :
                      (sorted_combos_operands1[2][10]) ? combos_operands1[2][0][10][7 : 0] :
                      (sorted_combos_operands1[2][11]) ? combos_operands1[2][0][11][7 : 0] :
                      (sorted_combos_operands1[2][12]) ? combos_operands1[2][0][12][7 : 0] :
                      (sorted_combos_operands1[2][13]) ? combos_operands1[2][0][13][7 : 0] :
                      (sorted_combos_operands1[2][14]) ? combos_operands1[2][0][14][7 : 0] :
                      (sorted_combos_operands1[2][15]) ? combos_operands1[2][0][15][7 : 0] :
                      (sorted_combos_operands1[2][16]) ? combos_operands1[2][0][16][7 : 0] :
                      (sorted_combos_operands1[2][17]) ? combos_operands1[2][0][17][7 : 0] :
                      (sorted_combos_operands1[2][18]) ? combos_operands1[2][0][18][7 : 0] :
                      (sorted_combos_operands1[2][19]) ? combos_operands1[2][0][19][7 : 0] :
                      (sorted_combos_operands1[2][20]) ? combos_operands1[2][0][20][7 : 0] :
                      (sorted_combos_operands1[2][21]) ? combos_operands1[2][0][21][7 : 0] :
                      (sorted_combos_operands1[2][22]) ? combos_operands1[2][0][22][7 : 0] :
                      (sorted_combos_operands1[2][23]) ? combos_operands1[2][0][23][7 : 0] : zeros_operand1;

assign operands1[2][1] = (sorted_combos_operands1[2][0]) ? combos_operands1[2][1][0][7 : 0] :
                      (sorted_combos_operands1[2][1]) ? combos_operands1[2][1][1][7 : 0] :
                      (sorted_combos_operands1[2][2]) ? combos_operands1[2][1][2][7 : 0] :
                      (sorted_combos_operands1[2][3]) ? combos_operands1[2][1][3][7 : 0] :
                      (sorted_combos_operands1[2][4]) ? combos_operands1[2][1][4][7 : 0] :
                      (sorted_combos_operands1[2][5]) ? combos_operands1[2][1][5][7 : 0] :
                      (sorted_combos_operands1[2][6]) ? combos_operands1[2][1][6][7 : 0] :
                      (sorted_combos_operands1[2][7]) ? combos_operands1[2][1][7][7 : 0] :
                      (sorted_combos_operands1[2][8]) ? combos_operands1[2][1][8][7 : 0] :
                      (sorted_combos_operands1[2][9]) ? combos_operands1[2][1][9][7 : 0] :
                      (sorted_combos_operands1[2][10]) ? combos_operands1[2][1][10][7 : 0] :
                      (sorted_combos_operands1[2][11]) ? combos_operands1[2][1][11][7 : 0] :
                      (sorted_combos_operands1[2][12]) ? combos_operands1[2][1][12][7 : 0] :
                      (sorted_combos_operands1[2][13]) ? combos_operands1[2][1][13][7 : 0] :
                      (sorted_combos_operands1[2][14]) ? combos_operands1[2][1][14][7 : 0] :
                      (sorted_combos_operands1[2][15]) ? combos_operands1[2][1][15][7 : 0] :
                      (sorted_combos_operands1[2][16]) ? combos_operands1[2][1][16][7 : 0] :
                      (sorted_combos_operands1[2][17]) ? combos_operands1[2][1][17][7 : 0] :
                      (sorted_combos_operands1[2][18]) ? combos_operands1[2][1][18][7 : 0] :
                      (sorted_combos_operands1[2][19]) ? combos_operands1[2][1][19][7 : 0] :
                      (sorted_combos_operands1[2][20]) ? combos_operands1[2][1][20][7 : 0] :
                      (sorted_combos_operands1[2][21]) ? combos_operands1[2][1][21][7 : 0] :
                      (sorted_combos_operands1[2][22]) ? combos_operands1[2][1][22][7 : 0] :
                      (sorted_combos_operands1[2][23]) ? combos_operands1[2][1][23][7 : 0] : zeros_operand1;

assign operands1[2][2] = (sorted_combos_operands1[2][0]) ? combos_operands1[2][2][0][7 : 0] :
                      (sorted_combos_operands1[2][1]) ? combos_operands1[2][2][1][7 : 0] :
                      (sorted_combos_operands1[2][2]) ? combos_operands1[2][2][2][7 : 0] :
                      (sorted_combos_operands1[2][3]) ? combos_operands1[2][2][3][7 : 0] :
                      (sorted_combos_operands1[2][4]) ? combos_operands1[2][2][4][7 : 0] :
                      (sorted_combos_operands1[2][5]) ? combos_operands1[2][2][5][7 : 0] :
                      (sorted_combos_operands1[2][6]) ? combos_operands1[2][2][6][7 : 0] :
                      (sorted_combos_operands1[2][7]) ? combos_operands1[2][2][7][7 : 0] :
                      (sorted_combos_operands1[2][8]) ? combos_operands1[2][2][8][7 : 0] :
                      (sorted_combos_operands1[2][9]) ? combos_operands1[2][2][9][7 : 0] :
                      (sorted_combos_operands1[2][10]) ? combos_operands1[2][2][10][7 : 0] :
                      (sorted_combos_operands1[2][11]) ? combos_operands1[2][2][11][7 : 0] :
                      (sorted_combos_operands1[2][12]) ? combos_operands1[2][2][12][7 : 0] :
                      (sorted_combos_operands1[2][13]) ? combos_operands1[2][2][13][7 : 0] :
                      (sorted_combos_operands1[2][14]) ? combos_operands1[2][2][14][7 : 0] :
                      (sorted_combos_operands1[2][15]) ? combos_operands1[2][2][15][7 : 0] :
                      (sorted_combos_operands1[2][16]) ? combos_operands1[2][2][16][7 : 0] :
                      (sorted_combos_operands1[2][17]) ? combos_operands1[2][2][17][7 : 0] :
                      (sorted_combos_operands1[2][18]) ? combos_operands1[2][2][18][7 : 0] :
                      (sorted_combos_operands1[2][19]) ? combos_operands1[2][2][19][7 : 0] :
                      (sorted_combos_operands1[2][20]) ? combos_operands1[2][2][20][7 : 0] :
                      (sorted_combos_operands1[2][21]) ? combos_operands1[2][2][21][7 : 0] :
                      (sorted_combos_operands1[2][22]) ? combos_operands1[2][2][22][7 : 0] :
                      (sorted_combos_operands1[2][23]) ? combos_operands1[2][2][23][7 : 0] : zeros_operand1;

assign operands1[2][3] = (sorted_combos_operands1[2][0]) ? combos_operands1[2][3][0][7 : 0] :
                      (sorted_combos_operands1[2][1]) ? combos_operands1[2][3][1][7 : 0] :
                      (sorted_combos_operands1[2][2]) ? combos_operands1[2][3][2][7 : 0] :
                      (sorted_combos_operands1[2][3]) ? combos_operands1[2][3][3][7 : 0] :
                      (sorted_combos_operands1[2][4]) ? combos_operands1[2][3][4][7 : 0] :
                      (sorted_combos_operands1[2][5]) ? combos_operands1[2][3][5][7 : 0] :
                      (sorted_combos_operands1[2][6]) ? combos_operands1[2][3][6][7 : 0] :
                      (sorted_combos_operands1[2][7]) ? combos_operands1[2][3][7][7 : 0] :
                      (sorted_combos_operands1[2][8]) ? combos_operands1[2][3][8][7 : 0] :
                      (sorted_combos_operands1[2][9]) ? combos_operands1[2][3][9][7 : 0] :
                      (sorted_combos_operands1[2][10]) ? combos_operands1[2][3][10][7 : 0] :
                      (sorted_combos_operands1[2][11]) ? combos_operands1[2][3][11][7 : 0] :
                      (sorted_combos_operands1[2][12]) ? combos_operands1[2][3][12][7 : 0] :
                      (sorted_combos_operands1[2][13]) ? combos_operands1[2][3][13][7 : 0] :
                      (sorted_combos_operands1[2][14]) ? combos_operands1[2][3][14][7 : 0] :
                      (sorted_combos_operands1[2][15]) ? combos_operands1[2][3][15][7 : 0] :
                      (sorted_combos_operands1[2][16]) ? combos_operands1[2][3][16][7 : 0] :
                      (sorted_combos_operands1[2][17]) ? combos_operands1[2][3][17][7 : 0] :
                      (sorted_combos_operands1[2][18]) ? combos_operands1[2][3][18][7 : 0] :
                      (sorted_combos_operands1[2][19]) ? combos_operands1[2][3][19][7 : 0] :
                      (sorted_combos_operands1[2][20]) ? combos_operands1[2][3][20][7 : 0] :
                      (sorted_combos_operands1[2][21]) ? combos_operands1[2][3][21][7 : 0] :
                      (sorted_combos_operands1[2][22]) ? combos_operands1[2][3][22][7 : 0] :
                      (sorted_combos_operands1[2][23]) ? combos_operands1[2][3][23][7 : 0] : zeros_operand1;




assign operands1[3][0] = (sorted_combos_operands1[3][0]) ? combos_operands1[3][0][0][7 : 0] :
                      (sorted_combos_operands1[3][1]) ? combos_operands1[3][0][1][7 : 0] :
                      (sorted_combos_operands1[3][2]) ? combos_operands1[3][0][2][7 : 0] :
                      (sorted_combos_operands1[3][3]) ? combos_operands1[3][0][3][7 : 0] :
                      (sorted_combos_operands1[3][4]) ? combos_operands1[3][0][4][7 : 0] :
                      (sorted_combos_operands1[3][5]) ? combos_operands1[3][0][5][7 : 0] :
                      (sorted_combos_operands1[3][6]) ? combos_operands1[3][0][6][7 : 0] :
                      (sorted_combos_operands1[3][7]) ? combos_operands1[3][0][7][7 : 0] :
                      (sorted_combos_operands1[3][8]) ? combos_operands1[3][0][8][7 : 0] :
                      (sorted_combos_operands1[3][9]) ? combos_operands1[3][0][9][7 : 0] :
                      (sorted_combos_operands1[3][10]) ? combos_operands1[3][0][10][7 : 0] :
                      (sorted_combos_operands1[3][11]) ? combos_operands1[3][0][11][7 : 0] :
                      (sorted_combos_operands1[3][12]) ? combos_operands1[3][0][12][7 : 0] :
                      (sorted_combos_operands1[3][13]) ? combos_operands1[3][0][13][7 : 0] :
                      (sorted_combos_operands1[3][14]) ? combos_operands1[3][0][14][7 : 0] :
                      (sorted_combos_operands1[3][15]) ? combos_operands1[3][0][15][7 : 0] :
                      (sorted_combos_operands1[3][16]) ? combos_operands1[3][0][16][7 : 0] :
                      (sorted_combos_operands1[3][17]) ? combos_operands1[3][0][17][7 : 0] :
                      (sorted_combos_operands1[3][18]) ? combos_operands1[3][0][18][7 : 0] :
                      (sorted_combos_operands1[3][19]) ? combos_operands1[3][0][19][7 : 0] :
                      (sorted_combos_operands1[3][20]) ? combos_operands1[3][0][20][7 : 0] :
                      (sorted_combos_operands1[3][21]) ? combos_operands1[3][0][21][7 : 0] :
                      (sorted_combos_operands1[3][22]) ? combos_operands1[3][0][22][7 : 0] :
                      (sorted_combos_operands1[3][23]) ? combos_operands1[3][0][23][7 : 0] : zeros_operand1;

assign operands1[3][1] = (sorted_combos_operands1[3][0]) ? combos_operands1[3][1][0][7 : 0] :
                      (sorted_combos_operands1[3][1]) ? combos_operands1[3][1][1][7 : 0] :
                      (sorted_combos_operands1[3][2]) ? combos_operands1[3][1][2][7 : 0] :
                      (sorted_combos_operands1[3][3]) ? combos_operands1[3][1][3][7 : 0] :
                      (sorted_combos_operands1[3][4]) ? combos_operands1[3][1][4][7 : 0] :
                      (sorted_combos_operands1[3][5]) ? combos_operands1[3][1][5][7 : 0] :
                      (sorted_combos_operands1[3][6]) ? combos_operands1[3][1][6][7 : 0] :
                      (sorted_combos_operands1[3][7]) ? combos_operands1[3][1][7][7 : 0] :
                      (sorted_combos_operands1[3][8]) ? combos_operands1[3][1][8][7 : 0] :
                      (sorted_combos_operands1[3][9]) ? combos_operands1[3][1][9][7 : 0] :
                      (sorted_combos_operands1[3][10]) ? combos_operands1[3][1][10][7 : 0] :
                      (sorted_combos_operands1[3][11]) ? combos_operands1[3][1][11][7 : 0] :
                      (sorted_combos_operands1[3][12]) ? combos_operands1[3][1][12][7 : 0] :
                      (sorted_combos_operands1[3][13]) ? combos_operands1[3][1][13][7 : 0] :
                      (sorted_combos_operands1[3][14]) ? combos_operands1[3][1][14][7 : 0] :
                      (sorted_combos_operands1[3][15]) ? combos_operands1[3][1][15][7 : 0] :
                      (sorted_combos_operands1[3][16]) ? combos_operands1[3][1][16][7 : 0] :
                      (sorted_combos_operands1[3][17]) ? combos_operands1[3][1][17][7 : 0] :
                      (sorted_combos_operands1[3][18]) ? combos_operands1[3][1][18][7 : 0] :
                      (sorted_combos_operands1[3][19]) ? combos_operands1[3][1][19][7 : 0] :
                      (sorted_combos_operands1[3][20]) ? combos_operands1[3][1][20][7 : 0] :
                      (sorted_combos_operands1[3][21]) ? combos_operands1[3][1][21][7 : 0] :
                      (sorted_combos_operands1[3][22]) ? combos_operands1[3][1][22][7 : 0] :
                      (sorted_combos_operands1[3][23]) ? combos_operands1[3][1][23][7 : 0] : zeros_operand1;

assign operands1[3][2] = (sorted_combos_operands1[3][0]) ? combos_operands1[3][2][0][7 : 0] :
                      (sorted_combos_operands1[3][1]) ? combos_operands1[3][2][1][7 : 0] :
                      (sorted_combos_operands1[3][2]) ? combos_operands1[3][2][2][7 : 0] :
                      (sorted_combos_operands1[3][3]) ? combos_operands1[3][2][3][7 : 0] :
                      (sorted_combos_operands1[3][4]) ? combos_operands1[3][2][4][7 : 0] :
                      (sorted_combos_operands1[3][5]) ? combos_operands1[3][2][5][7 : 0] :
                      (sorted_combos_operands1[3][6]) ? combos_operands1[3][2][6][7 : 0] :
                      (sorted_combos_operands1[3][7]) ? combos_operands1[3][2][7][7 : 0] :
                      (sorted_combos_operands1[3][8]) ? combos_operands1[3][2][8][7 : 0] :
                      (sorted_combos_operands1[3][9]) ? combos_operands1[3][2][9][7 : 0] :
                      (sorted_combos_operands1[3][10]) ? combos_operands1[3][2][10][7 : 0] :
                      (sorted_combos_operands1[3][11]) ? combos_operands1[3][2][11][7 : 0] :
                      (sorted_combos_operands1[3][12]) ? combos_operands1[3][2][12][7 : 0] :
                      (sorted_combos_operands1[3][13]) ? combos_operands1[3][2][13][7 : 0] :
                      (sorted_combos_operands1[3][14]) ? combos_operands1[3][2][14][7 : 0] :
                      (sorted_combos_operands1[3][15]) ? combos_operands1[3][2][15][7 : 0] :
                      (sorted_combos_operands1[3][16]) ? combos_operands1[3][2][16][7 : 0] :
                      (sorted_combos_operands1[3][17]) ? combos_operands1[3][2][17][7 : 0] :
                      (sorted_combos_operands1[3][18]) ? combos_operands1[3][2][18][7 : 0] :
                      (sorted_combos_operands1[3][19]) ? combos_operands1[3][2][19][7 : 0] :
                      (sorted_combos_operands1[3][20]) ? combos_operands1[3][2][20][7 : 0] :
                      (sorted_combos_operands1[3][21]) ? combos_operands1[3][2][21][7 : 0] :
                      (sorted_combos_operands1[3][22]) ? combos_operands1[3][2][22][7 : 0] :
                      (sorted_combos_operands1[3][23]) ? combos_operands1[3][2][23][7 : 0] : zeros_operand1;

assign operands1[3][3] = (sorted_combos_operands1[3][0]) ? combos_operands1[3][3][0][7 : 0] :
                      (sorted_combos_operands1[3][1]) ? combos_operands1[3][3][1][7 : 0] :
                      (sorted_combos_operands1[3][2]) ? combos_operands1[3][3][2][7 : 0] :
                      (sorted_combos_operands1[3][3]) ? combos_operands1[3][3][3][7 : 0] :
                      (sorted_combos_operands1[3][4]) ? combos_operands1[3][3][4][7 : 0] :
                      (sorted_combos_operands1[3][5]) ? combos_operands1[3][3][5][7 : 0] :
                      (sorted_combos_operands1[3][6]) ? combos_operands1[3][3][6][7 : 0] :
                      (sorted_combos_operands1[3][7]) ? combos_operands1[3][3][7][7 : 0] :
                      (sorted_combos_operands1[3][8]) ? combos_operands1[3][3][8][7 : 0] :
                      (sorted_combos_operands1[3][9]) ? combos_operands1[3][3][9][7 : 0] :
                      (sorted_combos_operands1[3][10]) ? combos_operands1[3][3][10][7 : 0] :
                      (sorted_combos_operands1[3][11]) ? combos_operands1[3][3][11][7 : 0] :
                      (sorted_combos_operands1[3][12]) ? combos_operands1[3][3][12][7 : 0] :
                      (sorted_combos_operands1[3][13]) ? combos_operands1[3][3][13][7 : 0] :
                      (sorted_combos_operands1[3][14]) ? combos_operands1[3][3][14][7 : 0] :
                      (sorted_combos_operands1[3][15]) ? combos_operands1[3][3][15][7 : 0] :
                      (sorted_combos_operands1[3][16]) ? combos_operands1[3][3][16][7 : 0] :
                      (sorted_combos_operands1[3][17]) ? combos_operands1[3][3][17][7 : 0] :
                      (sorted_combos_operands1[3][18]) ? combos_operands1[3][3][18][7 : 0] :
                      (sorted_combos_operands1[3][19]) ? combos_operands1[3][3][19][7 : 0] :
                      (sorted_combos_operands1[3][20]) ? combos_operands1[3][3][20][7 : 0] :
                      (sorted_combos_operands1[3][21]) ? combos_operands1[3][3][21][7 : 0] :
                      (sorted_combos_operands1[3][22]) ? combos_operands1[3][3][22][7 : 0] :
                      (sorted_combos_operands1[3][23]) ? combos_operands1[3][3][23][7 : 0] : zeros_operand1;

/*now that i reconstruct the operands --> extrapolate median point*/
assign median_comparator_tree_flags[0][0] = ($signed(operands2[0][0]) <= $signed(operands1[0][3])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[0][1] = ($signed(operands1[0][0]) <= $signed(operands2[0][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[0][2] = ($signed(operands1[0][3]) <= $signed(operands2[0][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[0][3] = ($signed(operands2[0][2]) <= $signed(operands1[0][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[0][4] = ($signed(operands2[0][1]) <= $signed(operands1[0][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[0][5] = ($signed(operands1[0][2]) <= $signed(operands2[0][0])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[0][6] = ($signed(operands2[0][1]) <= $signed(operands1[0][1])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[0][7] = ($signed(operands1[0][3]) <= $signed(operands1[0][1])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[0][8] = ($signed(operands2[0][1]) <= $signed(operands1[0][1])) ? 1'b1 : 1'b0;

assign median_comparator_tree_flags[1][0] = ($signed(operands2[1][0]) <= $signed(operands1[1][3])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[1][1] = ($signed(operands1[1][0]) <= $signed(operands2[1][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[1][2] = ($signed(operands1[1][3]) <= $signed(operands2[1][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[1][3] = ($signed(operands2[1][2]) <= $signed(operands1[1][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[1][4] = ($signed(operands2[1][1]) <= $signed(operands1[1][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[1][5] = ($signed(operands1[1][2]) <= $signed(operands2[1][0])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[1][6] = ($signed(operands2[1][1]) <= $signed(operands1[1][1])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[1][7] = ($signed(operands1[1][3]) <= $signed(operands1[1][1])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[1][8] = ($signed(operands2[1][1]) <= $signed(operands1[1][1])) ? 1'b1 : 1'b0;

assign median_comparator_tree_flags[2][0] = ($signed(operands2[2][0]) <= $signed(operands1[2][3])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[2][1] = ($signed(operands1[2][0]) <= $signed(operands2[2][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[2][2] = ($signed(operands1[2][3]) <= $signed(operands2[2][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[2][3] = ($signed(operands2[2][2]) <= $signed(operands1[2][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[2][4] = ($signed(operands2[2][1]) <= $signed(operands1[2][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[2][5] = ($signed(operands1[2][2]) <= $signed(operands2[2][0])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[2][6] = ($signed(operands2[2][1]) <= $signed(operands1[2][1])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[2][7] = ($signed(operands1[2][3]) <= $signed(operands1[2][1])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[2][8] = ($signed(operands2[2][1]) <= $signed(operands1[2][1])) ? 1'b1 : 1'b0;

assign median_comparator_tree_flags[3][0] = ($signed(operands2[3][0]) <= $signed(operands1[3][3])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[3][1] = ($signed(operands1[3][0]) <= $signed(operands2[3][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[3][2] = ($signed(operands1[3][3]) <= $signed(operands2[3][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[3][3] = ($signed(operands2[3][2]) <= $signed(operands1[3][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[3][4] = ($signed(operands2[3][1]) <= $signed(operands1[3][2])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[3][5] = ($signed(operands1[3][2]) <= $signed(operands2[3][0])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[3][6] = ($signed(operands2[3][1]) <= $signed(operands1[3][1])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[3][7] = ($signed(operands1[3][3]) <= $signed(operands1[3][1])) ? 1'b1 : 1'b0;
assign median_comparator_tree_flags[3][8] = ($signed(operands2[3][1]) <= $signed(operands1[3][1])) ? 1'b1 : 1'b0;

assign {to_extend_sign[0],operator2D_2_out[6 : 0]} = (median_comparator_tree_flags[0][0] & ~(median_comparator_tree_flags[0][1])) ? operands1[0][3] : 
                                 (median_comparator_tree_flags[0][1] & ~(median_comparator_tree_flags[0][0])) ? operands1[0][0] : 
                                 (~(median_comparator_tree_flags[0][0]) & ~(median_comparator_tree_flags[0][1]) & median_comparator_tree_flags[0][2] & median_comparator_tree_flags[0][3] & median_comparator_tree_flags[0][4] & median_comparator_tree_flags[0][5]) ? operands1[0][2] : 
                                 (~(median_comparator_tree_flags[0][0]) & ~(median_comparator_tree_flags[0][1]) & median_comparator_tree_flags[0][2] & median_comparator_tree_flags[0][3] & median_comparator_tree_flags[0][4] & ~(median_comparator_tree_flags[0][5])) ? operands2[0][0] : 
                                 (~(median_comparator_tree_flags[0][0]) & ~(median_comparator_tree_flags[0][1]) & median_comparator_tree_flags[0][2] & median_comparator_tree_flags[0][3] & ~(median_comparator_tree_flags[0][4]) & median_comparator_tree_flags[0][6] ) ? operands2[0][1] : 
                                 (~(median_comparator_tree_flags[0][0]) & ~(median_comparator_tree_flags[0][1]) & median_comparator_tree_flags[0][3] & ~(median_comparator_tree_flags[0][4]) & ~(median_comparator_tree_flags[0][6]) ) ? operands1[0][1] : 
                                 (~(median_comparator_tree_flags[0][0]) & ~(median_comparator_tree_flags[0][1]) & median_comparator_tree_flags[0][2] & ~(median_comparator_tree_flags[0][3]) & median_comparator_tree_flags[0][8] & median_comparator_tree_flags[0][6]) ? operands2[0][1] :    
                                 (~(median_comparator_tree_flags[0][0]) & ~(median_comparator_tree_flags[0][1]) & median_comparator_tree_flags[0][2] & ~(median_comparator_tree_flags[0][3]) & median_comparator_tree_flags[0][8] & ~(median_comparator_tree_flags[0][6]) ) ? operands1[0][1] :                     
                                 (~(median_comparator_tree_flags[0][0]) & ~(median_comparator_tree_flags[0][1]) & median_comparator_tree_flags[0][2] & ~(median_comparator_tree_flags[0][3]) & ~(median_comparator_tree_flags[0][8]) ) ? operands2[0][2] : 
                                 (~(median_comparator_tree_flags[0][0]) & ~(median_comparator_tree_flags[0][1]) & ~(median_comparator_tree_flags[0][2]) & median_comparator_tree_flags[0][7] & median_comparator_tree_flags[0][4] & ~(median_comparator_tree_flags[0][5])) ? operands2[0][0] : 
                                 (~(median_comparator_tree_flags[0][0]) & ~(median_comparator_tree_flags[0][1]) & ~(median_comparator_tree_flags[0][2]) & median_comparator_tree_flags[0][7] & median_comparator_tree_flags[0][4] & median_comparator_tree_flags[0][5]) ? operands1[0][2] : 
                                 (~(median_comparator_tree_flags[0][0]) & ~(median_comparator_tree_flags[0][1]) & ~(median_comparator_tree_flags[0][2]) & median_comparator_tree_flags[0][7] & ~(median_comparator_tree_flags[0][4]) & median_comparator_tree_flags[0][6]) ? operands2[0][1] :
                                 (~(median_comparator_tree_flags[0][0]) & ~(median_comparator_tree_flags[0][1]) & ~(median_comparator_tree_flags[0][2]) & median_comparator_tree_flags[0][7] & ~(median_comparator_tree_flags[0][4]) & ~(median_comparator_tree_flags[0][6]))  ? operands1[0][1] :                                  
                                 (~(median_comparator_tree_flags[0][0]) & ~(median_comparator_tree_flags[0][1]) & ~(median_comparator_tree_flags[0][2]) & ~(median_comparator_tree_flags[0][7]) & ~(median_comparator_tree_flags[0][5])) ? operands2[0][0] :  
                                 (~(median_comparator_tree_flags[0][0]) & ~(median_comparator_tree_flags[0][1]) & ~(median_comparator_tree_flags[0][2]) & ~(median_comparator_tree_flags[0][7]) & median_comparator_tree_flags[0][5]) ? operands1[0][2] : 8'b0;

assign{to_extend_sign[1], operator2D_2_out[34 : 28]} = (median_comparator_tree_flags[1][0] & ~(median_comparator_tree_flags[1][1])) ? operands1[1][3] : 
                                 (median_comparator_tree_flags[1][1] & ~(median_comparator_tree_flags[1][0])) ? operands1[1][0] : 
                                 (~(median_comparator_tree_flags[1][0]) & ~(median_comparator_tree_flags[1][1]) & median_comparator_tree_flags[1][2] & median_comparator_tree_flags[1][3] & median_comparator_tree_flags[1][4] & median_comparator_tree_flags[1][5]) ? operands1[1][2] : 
                                 (~(median_comparator_tree_flags[1][0]) & ~(median_comparator_tree_flags[1][1]) & median_comparator_tree_flags[1][2] & median_comparator_tree_flags[1][3] & median_comparator_tree_flags[1][4] & ~(median_comparator_tree_flags[1][5])) ? operands2[1][0] : 
                                 (~(median_comparator_tree_flags[1][0]) & ~(median_comparator_tree_flags[1][1]) & median_comparator_tree_flags[1][2] & median_comparator_tree_flags[1][3] & ~(median_comparator_tree_flags[1][4]) & median_comparator_tree_flags[1][6] ) ? operands2[1][1] : 
                                 (~(median_comparator_tree_flags[1][0]) & ~(median_comparator_tree_flags[1][1]) & median_comparator_tree_flags[1][3] & ~(median_comparator_tree_flags[1][4]) & ~(median_comparator_tree_flags[1][6]) ) ? operands1[1][1] : 
                                 (~(median_comparator_tree_flags[1][0]) & ~(median_comparator_tree_flags[1][1]) & median_comparator_tree_flags[1][2] & ~(median_comparator_tree_flags[1][3]) & median_comparator_tree_flags[1][8] & median_comparator_tree_flags[1][6]) ? operands2[1][1] :    
                                 (~(median_comparator_tree_flags[1][0]) & ~(median_comparator_tree_flags[1][1]) & median_comparator_tree_flags[1][2] & ~(median_comparator_tree_flags[1][3]) & median_comparator_tree_flags[1][8] & ~(median_comparator_tree_flags[1][6]) ) ? operands1[1][1] :                     
                                 (~(median_comparator_tree_flags[1][0]) & ~(median_comparator_tree_flags[1][1]) & median_comparator_tree_flags[1][2] & ~(median_comparator_tree_flags[1][3]) & ~(median_comparator_tree_flags[1][8]) ) ? operands2[1][2] : 
                                 (~(median_comparator_tree_flags[1][0]) & ~(median_comparator_tree_flags[1][1]) & ~(median_comparator_tree_flags[1][2]) & median_comparator_tree_flags[1][7] & median_comparator_tree_flags[1][4] & ~(median_comparator_tree_flags[1][5])) ? operands2[1][0] : 
                                 (~(median_comparator_tree_flags[1][0]) & ~(median_comparator_tree_flags[1][1]) & ~(median_comparator_tree_flags[1][2]) & median_comparator_tree_flags[1][7] & median_comparator_tree_flags[1][4] & median_comparator_tree_flags[1][5]) ? operands1[1][2] : 
                                 (~(median_comparator_tree_flags[1][0]) & ~(median_comparator_tree_flags[1][1]) & ~(median_comparator_tree_flags[1][2]) & median_comparator_tree_flags[1][7] & ~(median_comparator_tree_flags[1][4]) & median_comparator_tree_flags[1][6]) ? operands2[1][1] :
                                 (~(median_comparator_tree_flags[1][0]) & ~(median_comparator_tree_flags[1][1]) & ~(median_comparator_tree_flags[1][2]) & median_comparator_tree_flags[1][7] & ~(median_comparator_tree_flags[1][4]) & ~(median_comparator_tree_flags[1][6]))  ? operands1[1][1] :                                  
                                 (~(median_comparator_tree_flags[1][0]) & ~(median_comparator_tree_flags[1][1]) & ~(median_comparator_tree_flags[1][2]) & ~(median_comparator_tree_flags[1][7]) & ~(median_comparator_tree_flags[1][5])) ? operands2[1][0] :  
                                 (~(median_comparator_tree_flags[1][0]) & ~(median_comparator_tree_flags[1][1]) & ~(median_comparator_tree_flags[1][2]) & ~(median_comparator_tree_flags[1][7]) & median_comparator_tree_flags[1][5]) ? operands1[1][2] : 8'b0;


assign {to_extend_sign[2], operator2D_2_out[62 : 56]} = (median_comparator_tree_flags[2][0] & ~(median_comparator_tree_flags[2][1])) ? operands1[2][3] : 
                                 (median_comparator_tree_flags[2][1] & ~(median_comparator_tree_flags[2][0])) ? operands1[2][0] : 
                                 (~(median_comparator_tree_flags[2][0]) & ~(median_comparator_tree_flags[2][1]) & median_comparator_tree_flags[2][2] & median_comparator_tree_flags[2][3] & median_comparator_tree_flags[2][4] & median_comparator_tree_flags[2][5]) ? operands1[2][2] : 
                                 (~(median_comparator_tree_flags[2][0]) & ~(median_comparator_tree_flags[2][1]) & median_comparator_tree_flags[2][2] & median_comparator_tree_flags[2][3] & median_comparator_tree_flags[2][4] & ~(median_comparator_tree_flags[2][5])) ? operands2[2][0] : 
                                 (~(median_comparator_tree_flags[2][0]) & ~(median_comparator_tree_flags[2][1]) & median_comparator_tree_flags[2][2] & median_comparator_tree_flags[2][3] & ~(median_comparator_tree_flags[2][4]) & median_comparator_tree_flags[2][6] ) ? operands2[2][1] : 
                                 (~(median_comparator_tree_flags[2][0]) & ~(median_comparator_tree_flags[2][1]) & median_comparator_tree_flags[2][3] & ~(median_comparator_tree_flags[2][4]) & ~(median_comparator_tree_flags[2][6]) ) ? operands1[2][1] : 
                                 (~(median_comparator_tree_flags[2][0]) & ~(median_comparator_tree_flags[2][1]) & median_comparator_tree_flags[2][2] & ~(median_comparator_tree_flags[2][3]) & median_comparator_tree_flags[2][8] & median_comparator_tree_flags[2][6]) ? operands2[2][1] :    
                                 (~(median_comparator_tree_flags[2][0]) & ~(median_comparator_tree_flags[2][1]) & median_comparator_tree_flags[2][2] & ~(median_comparator_tree_flags[2][3]) & median_comparator_tree_flags[2][8] & ~(median_comparator_tree_flags[2][6]) ) ? operands1[2][1] :                     
                                 (~(median_comparator_tree_flags[2][0]) & ~(median_comparator_tree_flags[2][1]) & median_comparator_tree_flags[2][2] & ~(median_comparator_tree_flags[2][3]) & ~(median_comparator_tree_flags[2][8]) ) ? operands2[2][2] : 
                                 (~(median_comparator_tree_flags[2][0]) & ~(median_comparator_tree_flags[2][1]) & ~(median_comparator_tree_flags[2][2]) & median_comparator_tree_flags[2][7] & median_comparator_tree_flags[2][4] & ~(median_comparator_tree_flags[2][5])) ? operands2[2][0] : 
                                 (~(median_comparator_tree_flags[2][0]) & ~(median_comparator_tree_flags[2][1]) & ~(median_comparator_tree_flags[2][2]) & median_comparator_tree_flags[2][7] & median_comparator_tree_flags[2][4] & median_comparator_tree_flags[2][5]) ? operands1[2][2] : 
                                 (~(median_comparator_tree_flags[2][0]) & ~(median_comparator_tree_flags[2][1]) & ~(median_comparator_tree_flags[2][2]) & median_comparator_tree_flags[2][7] & ~(median_comparator_tree_flags[2][4]) & median_comparator_tree_flags[2][6]) ? operands2[2][1] :
                                 (~(median_comparator_tree_flags[2][0]) & ~(median_comparator_tree_flags[2][1]) & ~(median_comparator_tree_flags[2][2]) & median_comparator_tree_flags[2][7] & ~(median_comparator_tree_flags[2][4]) & ~(median_comparator_tree_flags[2][6]))  ? operands1[2][1] :                                  
                                 (~(median_comparator_tree_flags[2][0]) & ~(median_comparator_tree_flags[2][1]) & ~(median_comparator_tree_flags[2][2]) & ~(median_comparator_tree_flags[2][7]) & ~(median_comparator_tree_flags[2][5])) ? operands2[2][0] :  
                                 (~(median_comparator_tree_flags[2][0]) & ~(median_comparator_tree_flags[2][1]) & ~(median_comparator_tree_flags[2][2]) & ~(median_comparator_tree_flags[2][7]) & median_comparator_tree_flags[2][5]) ? operands1[2][2] : 8'b0;

assign{to_extend_sign[3], operator2D_2_out[90 : 84]} = (median_comparator_tree_flags[3][0] & ~(median_comparator_tree_flags[3][1])) ? operands1[3][3] : 
                                 (median_comparator_tree_flags[3][1] & ~(median_comparator_tree_flags[3][0])) ? operands1[3][0] : 
                                 (~(median_comparator_tree_flags[3][0]) & ~(median_comparator_tree_flags[3][1]) & median_comparator_tree_flags[3][2] & median_comparator_tree_flags[3][3] & median_comparator_tree_flags[3][4] & median_comparator_tree_flags[3][5]) ? operands1[3][2] : 
                                 (~(median_comparator_tree_flags[3][0]) & ~(median_comparator_tree_flags[3][1]) & median_comparator_tree_flags[3][2] & median_comparator_tree_flags[3][3] & median_comparator_tree_flags[3][4] & ~(median_comparator_tree_flags[3][5])) ? operands2[3][0] : 
                                 (~(median_comparator_tree_flags[3][0]) & ~(median_comparator_tree_flags[3][1]) & median_comparator_tree_flags[3][2] & median_comparator_tree_flags[3][3] & ~(median_comparator_tree_flags[3][4]) & median_comparator_tree_flags[3][6] ) ? operands2[3][1] : 
                                 (~(median_comparator_tree_flags[3][0]) & ~(median_comparator_tree_flags[3][1]) & median_comparator_tree_flags[3][3] & ~(median_comparator_tree_flags[3][4]) & ~(median_comparator_tree_flags[3][6]) ) ? operands1[3][1] : 
                                 (~(median_comparator_tree_flags[3][0]) & ~(median_comparator_tree_flags[3][1]) & median_comparator_tree_flags[3][2] & ~(median_comparator_tree_flags[3][3]) & median_comparator_tree_flags[3][8] & median_comparator_tree_flags[3][6]) ? operands2[3][1] :    
                                 (~(median_comparator_tree_flags[3][0]) & ~(median_comparator_tree_flags[3][1]) & median_comparator_tree_flags[3][2] & ~(median_comparator_tree_flags[3][3]) & median_comparator_tree_flags[3][8] & ~(median_comparator_tree_flags[3][6]) ) ? operands1[3][1] :                     
                                 (~(median_comparator_tree_flags[3][0]) & ~(median_comparator_tree_flags[3][1]) & median_comparator_tree_flags[3][2] & ~(median_comparator_tree_flags[3][3]) & ~(median_comparator_tree_flags[3][8]) ) ? operands2[3][2] : 
                                 (~(median_comparator_tree_flags[3][0]) & ~(median_comparator_tree_flags[3][1]) & ~(median_comparator_tree_flags[3][2]) & median_comparator_tree_flags[3][7] & median_comparator_tree_flags[3][4] & ~(median_comparator_tree_flags[3][5])) ? operands2[3][0] : 
                                 (~(median_comparator_tree_flags[3][0]) & ~(median_comparator_tree_flags[3][1]) & ~(median_comparator_tree_flags[3][2]) & median_comparator_tree_flags[3][7] & median_comparator_tree_flags[3][4] & median_comparator_tree_flags[3][5]) ? operands1[3][2] : 
                                 (~(median_comparator_tree_flags[3][0]) & ~(median_comparator_tree_flags[3][1]) & ~(median_comparator_tree_flags[3][2]) & median_comparator_tree_flags[3][7] & ~(median_comparator_tree_flags[3][4]) & median_comparator_tree_flags[3][6]) ? operands2[3][1] :
                                 (~(median_comparator_tree_flags[3][0]) & ~(median_comparator_tree_flags[3][1]) & ~(median_comparator_tree_flags[3][2]) & median_comparator_tree_flags[3][7] & ~(median_comparator_tree_flags[3][4]) & ~(median_comparator_tree_flags[3][6]))  ? operands1[3][1] :                                  
                                 (~(median_comparator_tree_flags[3][0]) & ~(median_comparator_tree_flags[3][1]) & ~(median_comparator_tree_flags[3][2]) & ~(median_comparator_tree_flags[3][7]) &  ~(median_comparator_tree_flags[3][5])) ? operands2[3][0] :  
                                 (~(median_comparator_tree_flags[3][0]) & ~(median_comparator_tree_flags[03][1]) & ~(median_comparator_tree_flags[3][2]) & ~(median_comparator_tree_flags[3][7]) & median_comparator_tree_flags[3][5]) ? operands1[3][2] : 8'b0;

/*sign extention*/
assign operator2D_2_out[27 : 7] = {21{to_extend_sign[0]}};
assign operator2D_2_out[55 : 35] = {21{to_extend_sign[1]}};
assign operator2D_2_out[83: 63] = {21{to_extend_sign[2]}};
assign operator2D_2_out[111 : 91] = {21{to_extend_sign[3]}};

endmodule
