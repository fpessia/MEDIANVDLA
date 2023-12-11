
`timescale 10ps/1ps

module NV_NVDLA_PDP_CORE_int8_med1d_core(
input enable_core, //to reduce power consumption from LUT
input [21 : 0] uint8_A,
input [21 : 0] uint8_B,
output[21 : 0] uint8_med_out
);
wire [21 : 0] A_wire;
wire [21 : 0] B_wire;
wire  [1 : 0] A_MSBs;
wire  [1 : 0] B_MSBs;
wire  [1 : 0] sel_op;
wire          operator1;
wire          operator2;
wire          operator3;

wire [21 : 0] operator1_output;
wire          zero_wired_A;
wire          zero_wired_B;
wire          neg_A;
wire          neg_B;

wire [21 : 0] operator2_output;
wire          comparison_result;

wire [21 : 0] operator3_output;
wire [7 : 0] unpacked_operandA;
wire [7 : 0] unpacked_operandB;
wire [7 : 0] operand_C;
wire         paked_A;
wire         paked_B;
wire         comparison1;
wire         comaprison2;




wire [2 : 0] unused_decored_i;
wire [2 : 0] unused_decored_j;
wire [2 : 0] unused_decored_k;

assign neg_A = (uint8_A[21 : 8] == 14'b11111111111111) ? 1'b1 : 1'b0;
assign neg_B = (uint8_B[21 : 8] == 14'b11111111111111) ? 1'b1 : 1'b0;

assign A_wire = neg_A ? (uint8_A & 22'h0000FF) : uint8_A;
assign B_wire = neg_B ? (uint8_B & 22'h0000FF) : uint8_B;
assign A_MSBs = A_wire[21 : 20];
assign B_MSBs = B_wire[21 : 20];


assign paked_A = (A_MSBs[1] & A_MSBs[0]);
assign paked_B = (B_MSBs[1] & B_MSBs[0]);

assign sel_op = (~(A_MSBs[1]) & ~(B_MSBs[1])) ? 2'b0 : 
                ((A_MSBs[1] & ~(A_MSBs[0])) | (B_MSBs[1] & ~(B_MSBs[0]))) ? 2'b1 : 
                ( paked_A | paked_B) ? 2'h2 : 2'b0; 

//operator 1 , zero discart, flag for operator2 next cycle
assign zero_wired_A = (A_wire == 22'h0) ? 1'b1  : 1'b0 ;
assign zero_wired_B = (B_wire == 22'h0) ? 1'b1  : 1'b0 ;
assign operator1_output[21] = 1'b1;
assign operator1_output[20 : 8] = 13'b0;
assign operator1_output[7 : 0] = zero_wired_A ? B_wire[7 : 0] : 
                                 zero_wired_B ? A_wire[7 : 0] : 
                                 comparison_result ? B_wire[7 : 0] : A_wire[7 : 0] ;


//operator 2 , 2 uint8  sorting and concatenation + flag for operator 3 if kernel size is equal to 3, otherwise ready for core2D
assign operator2_output[21 : 20] = 2'h3;
assign comparison_result = ($signed(A_wire[7 : 0]) > $signed(B_wire[7 : 0]));

assign operator2_output[7 : 0] = (comparison_result) ? A_wire[7 : 0] : B_wire[7 : 0];
assign operator2_output[15 : 8] = (comparison_result) ? B_wire[7 : 0] : A_wire[7 : 0];
assign operator2_output[19 : 16] = 4'b0;

//operator 3, 3 uint8 sorting,concatenation, compression (24 bits --> 22 bits) from LUT 
/*unpacking*/
assign unpacked_operandA = (paked_A) ? A_wire[7 : 0] : 
                            (paked_B) ? B_wire[7 : 0] : 8'b0;
assign unpacked_operandB = (paked_A) ? A_wire[15 : 8] : 
                            (paked_B) ? B_wire[15 : 8] : 8'b0;
assign operand_C = (paked_A) ? B_wire[7 : 0] : 
                    (paked_B) ? A_wire[7 : 0] : 8'b0;

/*sorting*/
assign comparison1 = ($signed(unpacked_operandA) > $signed(operand_C));
assign  comaprison2 = ($signed(unpacked_operandB) > $signed(operand_C));
/*paking operand LSBs*/
assign operator3_output[4 : 0] = comparison1 ? unpacked_operandA[4 : 0] : operand_C[4 : 0];
assign operator3_output[9 : 5] = (comparison1 & ~(comaprison2)) ? operand_C[4 : 0] : 
                                 (comparison1 & comaprison2) ? unpacked_operandB[4 : 0] : 
                                 (~(comparison1) & ~(comaprison2) ) ? unpacked_operandA[4 : 0] : 5'b0;
assign operator3_output[14 : 10] = comaprison2 ? operand_C[4 : 0] : unpacked_operandB[4 : 0];

/* encoding MSBs, bus parallelism constrain*/
NV_NVDLA_PDP_CORE_med1d_lut LUT(
    .encoding(enable_core),
    .decoding(1'b0),
    .uint8_A_msbs(unpacked_operandA[7 : 5]),
    .uint8_B_msbs(unpacked_operandB[7 : 5]),
    .uint8_C_msbs(operand_C[7 : 5]),
    .to_decode(7'b0),
    .LUT_encoding(operator3_output[21 : 15]),
    .decoded_msb_i(unused_decored_i),
    .decoded_msb_j(unused_decored_j),
    .decoded_msb_k(unused_decored_k)
);

/*operator selection&propagation*/
assign operator1 = (sel_op == 2'h0);
assign operator2 = (sel_op == 2'h1);
assign operator3 = (sel_op == 2'h2);

assign uint8_med_out = (operator1) ? operator1_output : 
                        (operator2) ? operator2_output:
                        (operator3) ? operator3_output : 0;
                   
endmodule



