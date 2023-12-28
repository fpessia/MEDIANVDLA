`timescale 10ps/1ps
module NV_NVDLA_PDP_CORE_med2d_core2x2(
    input [111 : 0] A,
    input [111 : 0] B,
    input      enable,
    output[111 : 0] Median2x2
);
/*
wire [3: 0]  control;
wire [3 : 0] double_control_A;
wire [3 : 0] double_control_B;
*/
wire [3 : 0][27 : 0] operands_A;
wire [3 : 0][27 : 0] operands_B;
wire [3:0][1 : 0][7 : 0] suboperand_A;
wire [3:0][1 : 0][7 : 0] suboperand_B;
wire [3:0][7 : 0] min_max;
wire [3:0][7 : 0] max_min;
wire [3 : 0] to_extend_signs;
wire [111: 0] M;




assign operands_A[0] = A[27 : 0];
assign operands_A[1] = A[55 : 28];
assign operands_A[2] = A[83 : 56];
assign operands_A[3] = A[111 : 84];

assign operands_B[0] = B[27 : 0];
assign operands_B[1] = B[55 : 28];
assign operands_B[2] = B[83 : 56];
assign operands_B[3] = B[111 : 84];
/*
assign control[0] = (operands_A[0][21 : 20] == 2'h3) & (operands_B[0][21 : 20] == 2'h3) & enable; 
assign control[1] = (operands_A[1][21 : 20] == 2'h3) & (operands_B[1][21 : 20] == 2'h3) & enable; 
assign control[2] = (operands_A[2][21 : 20] == 2'h3) & (operands_B[2][21 : 20] == 2'h3) & enable; 
assign control[3] = (operands_A[3][21 : 20] == 2'h3) & (operands_B[3][21 : 20] == 2'h3) & enable; 

assign double_control_A[0] = (operands_A[0][21 : 20] == 2'h3); 
assign double_control_A[1] = (operands_A[1][21 : 20] == 2'h3); 
assign double_control_A[2] = (operands_A[2][21 : 20] == 2'h3); 
assign double_control_A[3] = (operands_A[3][21 : 20] == 2'h3); 

assign double_control_B[0] = (operands_B[0][21 : 20] == 2'h3); 
assign double_control_B[1] = (operands_B[1][21 : 20] == 2'h3); 
assign double_control_B[2] = (operands_B[2][21 : 20] == 2'h3); 
assign double_control_B[3] = (operands_B[3][21 : 20] == 2'h3); 
*/

/*sub operand division*/
assign suboperand_A[0][0] = operands_A[0][7 : 0];
assign suboperand_A[0][1] = operands_A[0][15 : 8];
assign suboperand_A[1][0] = operands_A[1][7 : 0];
assign suboperand_A[1][1] = operands_A[1][15 : 8];
assign suboperand_A[2][0] = operands_A[2][7 : 0];
assign suboperand_A[2][1] = operands_A[2][15 : 8];
assign suboperand_A[3][0] = operands_A[3][7 : 0];
assign suboperand_A[3][1] = operands_A[3][15 : 8];

assign suboperand_B[0][0] = operands_B[0][7 : 0];
assign suboperand_B[0][1] = operands_B[0][15 : 8];
assign suboperand_B[1][0] = operands_B[1][7 : 0];
assign suboperand_B[1][1] = operands_B[1][15 : 8];
assign suboperand_B[2][0] = operands_B[2][7 : 0];
assign suboperand_B[2][1] = operands_B[2][15 : 8];
assign suboperand_B[3][0] = operands_B[3][7 : 0];
assign suboperand_B[3][1] = operands_B[3][15 : 8];

/*sub operand sorting and median*/
assign min_max[0] = ($signed(suboperand_A[0][0]) < $signed(suboperand_B[0][0])) ? suboperand_A[0][0] : suboperand_B[0][0];
assign max_min[0] = ($signed(suboperand_A[0][1]) < $signed(suboperand_B[0][1])) ? suboperand_B[0][1] : suboperand_A[0][1];
assign {to_extend_signs[0], M[6 : 0]} = ($signed(min_max[0]) < $signed(max_min[0])) ? min_max[0] : max_min[0];


assign min_max[1] = ($signed(suboperand_A[1][0]) < $signed(suboperand_B[1][0])) ? suboperand_A[1][0] : suboperand_B[1][0];
assign max_min[1] = ($signed(suboperand_A[1][1]) < $signed(suboperand_B[1][1])) ? suboperand_B[1][1] : suboperand_A[1][1];
assign {to_extend_signs[1],M[34 : 28]} = ($signed(min_max[1]) < $signed(max_min[1])) ? min_max[1] : max_min[1];


assign min_max[2] = ($signed(suboperand_A[2][0]) < $signed(suboperand_B[2][0])) ? suboperand_A[2][0] : suboperand_B[2][0];
assign max_min[2] = ($signed(suboperand_A[2][1]) < $signed(suboperand_B[2][1])) ? suboperand_B[2][1] : suboperand_A[2][1];
assign {to_extend_signs[2],M[62 : 56]} = ($signed(min_max[2]) < $signed(max_min[2])) ? min_max[2] : max_min[2];


assign min_max[3] = ($signed(suboperand_A[3][0]) < $signed(suboperand_B[3][0])) ? suboperand_A[3][0] : suboperand_B[3][0];
assign max_min[3] = ($signed(suboperand_A[3][1]) < $signed(suboperand_B[3][1])) ? suboperand_B[3][1] : suboperand_A[3][1];
assign {to_extend_signs[3],M[90 : 84]} = ($signed(min_max[3]) < $signed(max_min[3])) ? min_max[3] : max_min[3];

/*sign extenetions*/
assign M[27 : 7] = {21{to_extend_signs[0]}};
assign M[55 : 35] = {21{to_extend_signs[1]}};
assign M[83 : 63] = {21{to_extend_signs[2]}};
assign M[111 : 91] = {21{to_extend_signs[3]}};


assign Median2x2[111 : 84] = enable ? M[111 : 84] : 28'b0;
assign Median2x2[83 : 56] = enable ? M[83 : 56] : 28'b0;
assign Median2x2[55 : 28] = enable ? M[55 : 28] : 28'b0;
assign Median2x2[27 : 0] = enable ? M[27 : 0] : 28'b0;

/*
assign Median2x2[111 : 84] = (control[3]) ? M[111 : 84] :  
                             (double_control_A[3] & ~(double_control_B[3]) & enable) ? operands_A[3] : 
                             (double_control_B[3] & ~(double_control_A[3]) & enable) ? operands_B[3] :  28'b0;

assign Median2x2[83 : 56] = (control[2]) ? M[83 : 56] :  
                             (double_control_A[2] & ~(double_control_B[2]) & enable) ? operands_A[2] : 
                             (double_control_B[2] & ~(double_control_A[2]) & enable) ? operands_B[2] :  28'b0;

assign Median2x2[55 : 28] = (control[1]) ? M[55 : 28] :  
                             (double_control_A[1] & ~(double_control_B[1]) & enable) ? operands_A[1] : 
                             (double_control_B[1] & ~(double_control_A[1]) & enable) ? operands_B[1] :  28'b0;

assign Median2x2[27 : 0] = (control[0]) ? M[27 : 0] :  
                             (double_control_A[0] & ~(double_control_B[0]) & enable) ? operands_A[0] : 
                             (double_control_B[0] & ~(double_control_A[0]) & enable) ? operands_B[0] :  28'b0;

*/
endmodule

