import numpy as np
import sys

def encoding(i,j, k,lut,print_code = False):
    msb_i = i >> 5
    msb_j = j >> 5
    msb_k = k >> 5

    comb1 = (msb_i, msb_j, msb_k)
    comb2 = (msb_i, msb_k, msb_j)
    comb3 = (msb_j, msb_i, msb_k)
    comb4 = (msb_j, msb_k, msb_i)
    comb5 = (msb_k, msb_i, msb_j)
    comb6 = (msb_k, msb_j, msb_i)

    try:
        code = lut.index(comb1)
    except ValueError:
        try:
            code = lut.index(comb2)
        except ValueError:
            try:
                code = lut.index(comb3)
            except ValueError:
                try:
                    code = lut.index(comb4)
                except ValueError:
                    try:
                        code = lut.index(comb5)
                    except ValueError:
                        try:
                            code = lut.index(comb6)
                        except:
                            pass    
    
    if pow(2,7) <= code:
        print("Wrong code :" + str(code)) 
    if print_code:
        print(code)

    paking = i & 0x1F
    paking = paking | ((j & 0x1F) << 5) 
    paking = paking | ((k & 0x1F) << 10)
    paking = paking | ((code & 0x7F) << 15)

    return paking
   
def decoding(paked_info, lut, print_lut = False):
    #Unpaking
    LSBs_i = paked_info & 0x1F
    LSBs_j = (paked_info & (0x1F<< 5)) >> 5
    LSBs_k =  (paked_info & (0x1F<< 10)) >> 10
    code = (paked_info & (0x7F<< 15)) >> 15

    unsorted_MSBs = lut[code]
    msb1, msb2,msb3 = unsorted_MSBs

    if print_lut :
        print(unsorted_MSBs)


    #combo1
    i = LSBs_i | (msb1 << 5)
    j = LSBs_j | (msb2 << 5)
    k = LSBs_k | (msb3 << 5)
    if i <= j <= k :
        return [i,j,k]
    
    #combo2
    i = LSBs_i | (msb1 << 5)
    j = LSBs_j | (msb3 << 5)
    k = LSBs_k | (msb2 << 5)
    if i <= j <= k :
        return [i,j,k]
    
    #combo3
    i = LSBs_i | (msb2 << 5)
    j = LSBs_j | (msb1 << 5)
    k = LSBs_k | (msb3 << 5)
    if i <= j <= k :
        return [i,j,k]

    #combo4
    i = LSBs_i | (msb2 << 5)
    j = LSBs_j | (msb3 << 5)
    k = LSBs_k | (msb1 << 5)
    if i <= j <= k :
        return [i,j,k]
    
    #combo5
    i = LSBs_i | (msb3 << 5)
    j = LSBs_j | (msb1 << 5)
    k = LSBs_k | (msb2 << 5)
    if i <= j <= k :
        return [i,j,k]
    
    #combo6
    i = LSBs_i | (msb3 << 5)
    j = LSBs_j | (msb2 << 5)
    k = LSBs_k | (msb1 << 5)
    if i <= j <= k :
        return [i,j,k]

    print("Wrong Decoding")
    sys.exit()


#LUT GENERATION
uint8_MSB_input1 = np.arange(0, 8, 1).tolist()
uint8_MSB_input2 = np.arange(0, 8, 1).tolist()
uint8_MSB_input3 = np.arange(0, 8, 1).tolist()
MAX_ADDR = pow(2,7)-1
lut_size = 0
LUT_content = []

for int8_i in uint8_MSB_input1:
    for int8_j in uint8_MSB_input2:
        for int8_k in uint8_MSB_input3:
            if (LUT_content.count( (int8_i, int8_j , int8_k)) == 0 and
                LUT_content.count( (int8_i, int8_k , int8_j)) == 0 and
                LUT_content.count( (int8_j, int8_i , int8_k)) == 0 and
                LUT_content.count( (int8_j, int8_k , int8_i)) == 0 and
                LUT_content.count( (int8_k, int8_i , int8_j)) == 0 and
                LUT_content.count( (int8_k, int8_j , int8_i)) == 0 ):

                LUT_content.append((int8_i, int8_j , int8_k))
                lut_size += 1


print("LUT SIZE : "+ str(lut_size))
print("MAX ADDR : " + str(MAX_ADDR))

#ENCODING/DECODING PROCEDURE VALIDATION
uint8_MSB_input1 = np.arange(0, 256, 1).tolist()
uint8_MSB_input2 = np.arange(0, 256, 1).tolist()
uint8_MSB_input3 = np.arange(0, 256, 1).tolist()


for int8_i in uint8_MSB_input1:
    for int8_j in uint8_MSB_input2:
        for int8_k in uint8_MSB_input3:
            l = [int8_i, int8_j, int8_k]
            l.sort()
            
            #data arrive in PDP_CORE_unit1D and are encoded
            LUT_encoding = encoding(l[0], l[1], l[2], LUT_content)
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
