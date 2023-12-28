`timescale 10ps/1ps
module NV_NVDLA_PDP_CORE_med1d_lut(
input encoding, //to reduce power consumption from LUT
input decoding,
input [2 : 0] uint8_A_msbs,
input [2 : 0] uint8_B_msbs,
input [2 : 0] uint8_C_msbs,
input [3 : 0][6 : 0] to_decode,

output[6 : 0] LUT_encoding,
output [3 : 0][2 : 0] decoded_msb_i,
output [3 : 0][2 : 0] decoded_msb_j,
output [3 : 0][2 : 0] decoded_msb_k
);

wire [119 : 0][8:0]  lut_content; 
reg [6 : 0]        encoder_output;
reg [3 : 0][8 : 0]   decoded_MSBs;

/*LUT INSTANTIATION*/
assign lut_content[0][8 : 0] = 9'b000000000;//(0, 0, 0)
assign lut_content[1][8 : 0] = 9'b000000001;//(0, 0, 1)
assign lut_content[2][8 : 0] = 9'b000000010; //(0, 0, 2)
assign lut_content[3][8 : 0] = 9'b000000011;// (0, 0, 3)
assign lut_content[4][8 : 0] = 9'b000000100;//(0, 0, 4)
assign lut_content[5][8 : 0] = 9'b000000101;//(0, 0, 5)
assign lut_content[6][8 : 0] = 9'b000000110;//(0, 0, 6)
assign lut_content[7][8 : 0] = 9'b000000111;//(0, 0, 7)
assign lut_content[8][8 : 0] = 9'b000001001;//(0, 1, 1)
assign lut_content[9][8 : 0] = 9'b000001010;//(0, 1, 2)
assign lut_content[10][8 : 0] = 9'b000001011;//(0, 1, 3)
assign lut_content[11][8 : 0] = 9'b000001100;//(0, 1, 4)
assign lut_content[12][8 : 0] = 9'b000001101;//(0, 1, 5)
assign lut_content[13][8 : 0] = 9'b000001110;//(0, 1, 6)
assign lut_content[14][8 : 0] = 9'b000001111;//(0, 1, 7)
assign lut_content[15][8 : 0] = 9'b000010010;//(0, 2, 2)
assign lut_content[16][8 : 0] = 9'b000010011;//(0, 2, 3)
assign lut_content[17][8 : 0] = 9'b000010100;//(0, 2, 4)
assign lut_content[18][8 : 0] = 9'b000010101;//(0, 2, 5)
assign lut_content[19][8 : 0] = 9'b000010110;//(0, 2, 6)
assign lut_content[20][8 : 0] = 9'b000010111;//(0, 2, 7)
assign lut_content[21][8 : 0] = 9'b000011011;//(0, 3, 3)
assign lut_content[22][8 : 0] = 9'b000011100;//(0, 3, 4)
assign lut_content[23][8 : 0] = 9'b000011101;//(0, 3, 5)
assign lut_content[24][8 : 0] = 9'b000011110;//(0, 3, 6)
assign lut_content[25][8 : 0] = 9'b000011111;//(0, 3, 7)
assign lut_content[26][8 : 0] = 9'b000100100;//(0, 4, 4)
assign lut_content[27][8 : 0] = 9'b000100101;//(0, 4, 5)
assign lut_content[28][8 : 0] = 9'b000100110;//(0, 4, 6)
assign lut_content[29][8 : 0] = 9'b000100111;//(0, 4, 7)
assign lut_content[30][8 : 0] = 9'b000101101;//(0, 5, 5)
assign lut_content[31][8 : 0] = 9'b000101110;//(0, 5, 6)
assign lut_content[32][8 : 0] = 9'b000101111;//(0, 5, 7)
assign lut_content[33][8 : 0] = 9'b000110110;//(0, 6, 6)
assign lut_content[34][8 : 0] = 9'b000110111;//(0, 6, 7)
assign lut_content[35][8 : 0] = 9'b000111111;//(0, 7, 7)
assign lut_content[36][8 : 0] = 9'b001001001;//(1, 1, 1)
assign lut_content[37][8 : 0] = 9'b001001010;//(1, 1, 2)
assign lut_content[38][8 : 0] = 9'b001001011;//(1, 1, 3)
assign lut_content[39][8 : 0] = 9'b001001100;//(1, 1, 4)
assign lut_content[40][8 : 0] = 9'b001001101;//(1, 1, 5)
assign lut_content[41][8 : 0] = 9'b001001110;//(1, 1, 6)
assign lut_content[42][8 : 0] = 9'b001001111;//(1, 1, 7)
assign lut_content[43][8 : 0] = 9'b001010010;//(1, 2, 2)
assign lut_content[44][8 : 0] = 9'b001010011;//(1, 2, 3)
assign lut_content[45][8 : 0] = 9'b001010100;//(1, 2, 4)
assign lut_content[46][8 : 0] = 9'b001010101;//(1, 2, 5)
assign lut_content[47][8 : 0] = 9'b001010110;//(1, 2, 6)
assign lut_content[48][8 : 0] = 9'b001010111;//(1, 2, 7)
assign lut_content[49][8 : 0] = 9'b001011011;//(1, 3, 3)
assign lut_content[50][8 : 0] = 9'b001011100;//(1, 3, 4)
assign lut_content[51][8 : 0] = 9'b001011101;//(1, 3, 5)
assign lut_content[52][8 : 0] = 9'b001011110;//(1, 3, 6)
assign lut_content[53][8 : 0] = 9'b001011111;//(1, 3, 7)
assign lut_content[54][8 : 0] = 9'b001100100;//(1, 4, 4)
assign lut_content[55][8 : 0] = 9'b001100101;//(1, 4, 5)
assign lut_content[56][8 : 0] = 9'b001100110;//(1, 4, 6)
assign lut_content[57][8 : 0] = 9'b001100111;//(1, 4, 7)
assign lut_content[58][8 : 0] = 9'b001101101;//(1, 5, 5)
assign lut_content[59][8 : 0] = 9'b001101110;//(1, 5, 6)
assign lut_content[60][8 : 0] = 9'b001101111;//(1, 5, 7)
assign lut_content[61][8 : 0] = 9'b001110110;//(1, 6, 6)
assign lut_content[62][8 : 0] = 9'b001110111;//(1, 6, 7)
assign lut_content[63][8 : 0] = 9'b001111111;//(1, 7, 7)
assign lut_content[64][8 : 0] = 9'b010010010;//(2, 2, 2)
assign lut_content[65][8 : 0] = 9'b010010011;//(2, 2, 4)
assign lut_content[66][8 : 0] = 9'b010010100;//(2, 2, 4)
assign lut_content[67][8 : 0] = 9'b010010101;//(2, 2, 5)
assign lut_content[68][8 : 0] = 9'b010010110;//(2, 2, 6)
assign lut_content[69][8 : 0] = 9'b010010111;//(2, 2, 7)
assign lut_content[70][8 : 0] = 9'b010011011;//(2, 3, 3)
assign lut_content[71][8 : 0] = 9'b010011100;//(2, 3, 4)
assign lut_content[72][8 : 0] = 9'b010011101;//(2, 3, 5)
assign lut_content[73][8 : 0] = 9'b010011110;//(2, 3, 6)
assign lut_content[74][8 : 0]= 9'b010011111;//(2, 3, 7)
assign lut_content[75][8 : 0] = 9'b010100100;//(2, 4, 4)
assign lut_content[76][8 : 0] = 9'b010100101;//(2, 4, 5)
assign lut_content[77][8 : 0] = 9'b010100110;//(2, 4, 6)
assign lut_content[78][8 : 0] = 9'b010100111;//(2, 4, 7)
assign lut_content[79][8 : 0] = 9'b010101101;//(2, 5, 5)
assign lut_content[80][8 : 0] = 9'b010101110;//(2, 5, 6)
assign lut_content[81][8 : 0] = 9'b010101111;//(2, 5, 7)
assign lut_content[82][8 : 0] = 9'b010110110;//(2, 6, 6)
assign lut_content[83][8 : 0] = 9'b010110111;//(2, 6, 7)
assign lut_content[84][8 : 0] = 9'b010111111;//(2, 7, 7)
assign lut_content[85][8 : 0] = 9'b011011011;//(3, 3, 3)
assign lut_content[86][8 : 0] = 9'b011011100;//(3, 3, 4)
assign lut_content[87][8 : 0] = 9'b011011101;//(3, 3, 5)
assign lut_content[88][8 : 0] = 9'b011011110;//(3, 3, 6)
assign lut_content[89][8 : 0] = 9'b011011111;//(3, 3, 7)
assign lut_content[90][8 : 0] = 9'b011100100;//(3, 4, 4)
assign lut_content[91][8 : 0] = 9'b011100101;//(3, 4, 5)
assign lut_content[92][8 : 0] = 9'b011100110;//(3, 4, 6)
assign lut_content[93][8 : 0] = 9'b011100111;//(3, 4, 7)
assign lut_content[94][8 : 0] = 9'b011101101;//(3, 5, 5)
assign lut_content[95][8 : 0] = 9'b011101110;//(3, 5, 6)
assign lut_content[96][8 : 0] = 9'b011101111;//(3, 5, 7)
assign lut_content[97][8 : 0] = 9'b011110110;//(3, 6, 6)
assign lut_content[98][8 : 0] = 9'b011110111;//(3, 6, 7)
assign lut_content[99][8 : 0] = 9'b011111111;//(3, 7, 7)
assign lut_content[100][8 : 0] = 9'b100100100;//(4, 4, 4)
assign lut_content[101][8 : 0] = 9'b100100101;//(4, 4, 5)
assign lut_content[102][8 : 0] = 9'b100100110;//(4, 4, 6)
assign lut_content[103][8 : 0] = 9'b100100111;//(4, 4, 7)
assign lut_content[104][8 : 0] = 9'b100101101;//(4, 5, 5)
assign lut_content[105][8 : 0] = 9'b100101110;//(4, 5, 6)
assign lut_content[106][8 : 0] = 9'b100101111;//(4, 5, 7)
assign lut_content[107][8 : 0] = 9'b100110110;//(4, 6, 6)
assign lut_content[108][8 : 0] = 9'b100110111;//(4, 6, 7)
assign lut_content[109][8 : 0] = 9'b100111111;//(4, 7, 7)
assign lut_content[110][8 : 0] = 9'b101101101;//(5, 5, 5)
assign lut_content[111][8 : 0] = 9'b101101110;//(5, 5, 6)
assign lut_content[112][8 : 0] = 9'b101101111;//(5, 5, 7)
assign lut_content[113][8 : 0] = 9'b101110110;//(5, 6, 6)
assign lut_content[114][8 : 0] = 9'b101110111;//(5, 6, 7)
assign lut_content[115][8 : 0] = 9'b101111111;
assign lut_content[116][8 : 0] = 9'b110110110;
assign lut_content[117][8 : 0] = 9'b110110111;
assign lut_content[118][8 : 0] = 9'b110111111;
assign lut_content[119][8 : 0] = 9'b111111111;


/*ENCODING*/
generate
    always@(uint8_A_msbs or uint8_B_msbs or uint8_C_msbs) begin
      encoder_output = 7'b0;
      for (int i = 0; i < 120; i = i + 1) begin
        if ((lut_content[i][8 : 6]==uint8_A_msbs)&&(lut_content[i][5 : 3]==uint8_B_msbs) && (lut_content[i][2 : 0] == uint8_C_msbs) ||
            (lut_content[i][8 : 6]==uint8_A_msbs)&&(lut_content[i][5 : 3]==uint8_C_msbs) && (lut_content[i][2 : 0] == uint8_B_msbs) ||
            (lut_content[i][8 : 6]==uint8_B_msbs)&&(lut_content[i][5 : 3]==uint8_A_msbs) && (lut_content[i][2 : 0] == uint8_C_msbs) ||
            (lut_content[i][8 : 6]==uint8_B_msbs)&&(lut_content[i][5 : 3]==uint8_C_msbs) && (lut_content[i][2 : 0] == uint8_A_msbs) ||
            (lut_content[i][8 : 6]==uint8_C_msbs)&&(lut_content[i][5 : 3]==uint8_A_msbs) && (lut_content[i][2 : 0] == uint8_B_msbs) ||
            (lut_content[i][8 : 6]==uint8_C_msbs)&&(lut_content[i][5 : 3]==uint8_B_msbs) && (lut_content[i][2 : 0] == uint8_A_msbs) 
          ) begin
        encoder_output = i[6 : 0];
        end /*else begin
        encoder_output = 7'b0;
        end*/
    end
  end
endgenerate

assign LUT_encoding = (encoding) ?  encoder_output : 7'b0;


/*DECODING*/
always@(decoding or to_decode) begin
    if (decoding == 1'b1) begin
        decoded_MSBs[0] = lut_content[to_decode[0]][8 : 0];
        decoded_MSBs[1] = lut_content[to_decode[1]][8 : 0];
        decoded_MSBs[2] = lut_content[to_decode[2]][8 : 0];
        decoded_MSBs[3] = lut_content[to_decode[3]][8 : 0];
    end else begin
        decoded_MSBs[0] = 9'b0;
        decoded_MSBs[1] = 9'b0;
        decoded_MSBs[2] = 9'b0;
        decoded_MSBs[3] = 9'b0;
    end
end

assign decoded_msb_k[0] = decoded_MSBs[0][8 : 6]; 
assign decoded_msb_j[0] = decoded_MSBs[0][5 : 3]; 
assign decoded_msb_i[0] = decoded_MSBs[0][2 : 0];

assign decoded_msb_k[1] = decoded_MSBs[1][8 : 6]; 
assign decoded_msb_j[1] = decoded_MSBs[1][5 : 3]; 
assign decoded_msb_i[1] = decoded_MSBs[1][2 : 0];

assign decoded_msb_k[2] = decoded_MSBs[2][8 : 6]; 
assign decoded_msb_j[2] = decoded_MSBs[2][5 : 3]; 
assign decoded_msb_i[2] = decoded_MSBs[2][2 : 0];

assign decoded_msb_k[3] = decoded_MSBs[3][8 : 6]; 
assign decoded_msb_j[3] = decoded_MSBs[3][5 : 3]; 
assign decoded_msb_i[3] = decoded_MSBs[3][2 : 0];

endmodule


