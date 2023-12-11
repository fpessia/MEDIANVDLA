import numpy as np
from itertools import permutations
import sys, os

def encoding(i,j,k,w,lut,print_code = False):
    msb_i = i >> 4
    msb_j = j >> 4
    msb_k = k >> 4
    msb_w = w >> 4

    combos = list(permutations([msb_i, msb_j, msb_k, msb_w]))
    for combo in combos:
        try:
            code = lut.index(tuple(combo))
            break
        except ValueError:
            pass
                            

    
    if pow(2,12) <= code:
        print("Wrong code :" + str(code)) 
    if print_code:
        print(code)

    paking = i & 0x0F
    paking = paking | ((j & 0x0F) << 4) 
    paking = paking | ((k & 0x0F) << 8)
    paking = paking | ((w & 0x0F) << 12)
    paking = paking | ((code & 0x0FFF) << 16)

    return paking
   
def decoding(paked_info, lut, print_lut = False):
    #Unpaking
    LSBs_i = paked_info & 0x0F
    LSBs_j = (paked_info & (0x0F<< 4)) >> 4
    LSBs_k =  (paked_info & (0x0F<< 8)) >> 8
    LSBs_w = (paked_info & (0x0F<< 12)) >> 12
    code = (paked_info & (0x0FFF<< 16)) >> 16

    unsorted_MSBs = list(lut[code])
    combos = list(permutations(list(unsorted_MSBs)))

    for combo in combos:
        i = LSBs_i | (combo[0] << 4)
        j = LSBs_j | (combo[1] << 4)
        k = LSBs_k | (combo[2] << 4)
        w = LSBs_w | (combo[3] << 4)
        if i <= j <= k <= w : 
            return [i,j,k,w]
    
    #msb1, msb2,msb3,msb4 = unsorted_MSBs

    if print_lut :
        print(unsorted_MSBs)



    print("Wrong Decoding")
    sys.exit()

def NumToBin(i):
    if i == 0:
        return "0000"
    elif i == 1:
        return "0001"
    elif i ==2 :
        return "0010"
    elif i == 3:
        return "0011"
    elif i == 4 :
        return "0100"
    elif i == 5 : 
        return "0101"
    elif i == 6:
        return "0110"
    elif i == 7 : 
        return "0111"
    elif i == 8 : 
        return "1000"
    elif i == 9:
        return "1001"
    elif i == 10 : 
        return "1010"
    elif i == 11:
        return "1011"
    elif i == 12:
        return "1100"
    elif i == 13 : 
        return "1101"
    elif i == 14 : 
        return "1110"
    elif i == 15 : 
        return "1111"
    else:
        sys.exit()

def write_lut(lut,file):
    file.write("wire [3875 : 0][11 : 0] lut_content; \n\n\n")
    lut_counter = 1
    for entrance in lut :
        msbs_1,msb_2, msb_3,msb_4 = entrance
        file.write("assign lut_table["+str(lut_counter)+"] = 16'b"+str(NumToBin(msbs_1))+str(NumToBin(msb_2))+
                                                                str(NumToBin(msb_3))+str(NumToBin(msb_4))+"; \n")
        lut_counter +=1

    file.close()
    

ToTest = False
ToWrite = True

#LUT GENERATION
uint8_MSB_input1 = np.arange(0, 16, 1).tolist()
uint8_MSB_input2 = np.arange(0, 16, 1).tolist()
uint8_MSB_input3 = np.arange(0, 16, 1).tolist()
uint8_MSB_input4 = np.arange(0, 16, 1).tolist()
MAX_ADDR = pow(2,12)-1
lut_size = 0
LUT_content = []

for int8_i in uint8_MSB_input1:
    for int8_j in uint8_MSB_input2:
        for int8_k in uint8_MSB_input3:
            for int8_w in uint8_MSB_input4:
                if (LUT_content.count( (int8_i, int8_j , int8_k, int8_w)) == 0 and
                    LUT_content.count( (int8_i, int8_j , int8_w, int8_k)) == 0 and
                    LUT_content.count( (int8_i, int8_k , int8_j, int8_w)) == 0 and
                    LUT_content.count( (int8_i, int8_k , int8_w, int8_j)) == 0 and
                    LUT_content.count( (int8_i, int8_w , int8_j, int8_k)) == 0 and
                    LUT_content.count( (int8_i, int8_w , int8_k, int8_j)) == 0 and
                    LUT_content.count( (int8_j, int8_i , int8_k, int8_w)) == 0 and
                    LUT_content.count( (int8_j, int8_i , int8_w, int8_k)) == 0 and
                    LUT_content.count( (int8_j, int8_k , int8_i, int8_w)) == 0 and
                    LUT_content.count( (int8_j, int8_k , int8_w, int8_i)) == 0 and
                    LUT_content.count( (int8_j, int8_w , int8_i, int8_k)) == 0 and
                    LUT_content.count( (int8_j, int8_w , int8_k, int8_i)) == 0 and
                    LUT_content.count( (int8_k, int8_i , int8_j, int8_w)) == 0 and
                    LUT_content.count( (int8_k, int8_i , int8_w, int8_j)) == 0 and
                    LUT_content.count( (int8_k, int8_j , int8_i, int8_w)) == 0 and
                    LUT_content.count( (int8_k, int8_j , int8_w, int8_i)) == 0 and
                    LUT_content.count( (int8_k, int8_w , int8_i, int8_j)) == 0 and
                    LUT_content.count( (int8_k, int8_w , int8_j, int8_i)) == 0 and
                    LUT_content.count( (int8_w, int8_i , int8_j, int8_k)) == 0 and
                    LUT_content.count( (int8_w, int8_i , int8_k, int8_j)) == 0 and
                    LUT_content.count( (int8_w, int8_j , int8_i, int8_k)) == 0 and
                    LUT_content.count( (int8_w, int8_j , int8_k, int8_i)) == 0 and
                    LUT_content.count( (int8_w, int8_k , int8_i, int8_j)) == 0 and
                    LUT_content.count( (int8_w, int8_k , int8_j, int8_i)) == 0 ):

                        LUT_content.append((int8_i, int8_j , int8_k, int8_w))
                        lut_size += 1


print("LUT SIZE : "+ str(lut_size))
print("MAX ADDR : " + str(MAX_ADDR))



#ENCODING/DECODING PROCEDURE VALIDATION
if ToTest:
    uint8_MSB_input1 = np.arange(0, 256, 1).tolist()
    uint8_MSB_input2 = np.arange(0, 256, 1).tolist()
    uint8_MSB_input3 = np.arange(0, 256, 1).tolist()
    uint8_MSB_input4 = np.arange(0, 256, 1).tolist()


    for int8_i in uint8_MSB_input1:
        print(int8_i)
        for int8_j in uint8_MSB_input2:
            for int8_k in uint8_MSB_input3:
                for int8_w in uint8_MSB_input4:
                    l = [int8_i, int8_j, int8_k, int8_w]
                    l.sort()
                    
                    #data arrive in PDP_CORE_unit1D and are encoded
                    LUT_encoding = encoding(l[0], l[1], l[2], l[3], LUT_content)
                    # paked info arrive in PDP_CORE_cal2d and are unpaked
                    l_dec = decoding(LUT_encoding, LUT_content)

                    if l == l_dec:
                        pass
                        #print("GOOD RECONSTRUCTION")
                    else:
                        print("SOMETHING WENT WRONG")
                        print(l)
                        print(l_dec)
                        print("\n \n")
                        print(encoding(l[0], l[1], l[2], LUT_content, print_code=True))
                        print(decoding(LUT_encoding, LUT_content, print_lut=True))
                        sys.exit()

    print("TEST PASSED")

if ToWrite:
    path = os.path.join(
        os.getcwd(), "NV_NVDLA_PDP_CORE_med2d_lut.v"
    )

    file = open(path, "w+")
    write_lut(LUT_content,file)