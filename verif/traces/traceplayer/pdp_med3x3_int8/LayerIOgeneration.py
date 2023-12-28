import torch
from Median_pooling_layer import Median_pooling_layer

import os, sys
import random



if __name__ == '__main__':
    path = os.path.join(os.getcwd(),'input_feature_map.dat')
    InputTensor = torch.zeros((64,8,8), dtype = torch.int16)
    #randomly generating input tensor
    hex_bytes = []
    for i in range(256):
        if i != 128 : 
            hex_bytes.append(i-128)
    
    for c in range(64):
        for w in range(8):
            for h in range(8):
                #generate int8
                InputTensor[c,w,h] = int(random.choice(hex_bytes))

    
    #Storing in memory Surface packed, Little Endianess
    I = open(path, 'w+')
    lines = [[] for _ in range(256)]
    count = 0
    for c in range(64):
        for w in range(8):
            for h in range(8):
                Lsb = int(InputTensor[c,w,h]) & 0x0F 
                MsB = (int(InputTensor[c,w,h]) & 0x0F0) >> 4
                s = '0x'
                if MsB < 10 : 
                    s +=  str(MsB)
                elif MsB == 10:
                    s += 'a'
                elif MsB == 11:
                    s += 'b'
                elif MsB == 12:
                    s += 'c'
                elif MsB == 13:
                    s += 'd'
                elif MsB == 14 : 
                    s += 'e'
                elif MsB == 15:
                    s += 'f'
                else:
                    print('Error while translating msb in hex')
                    print(MsB)
                    sys.exit()
                
                if Lsb < 10 : 
                    s +=  str(Lsb)
                elif Lsb == 10:
                    s += 'a'
                elif Lsb == 11:
                    s += 'b'
                elif Lsb == 12:
                    s += 'c'
                elif Lsb == 13:
                    s += 'd'
                elif Lsb == 14 : 
                    s += 'e'
                elif Lsb == 15:
                    s+= 'f'
                else:
                    print('Error while translating lsb in hex')
                    print(Lsb)
                    sys.exit()
                s += ' '
                if InputTensor[c,w,h].item() >= 0 : 
                    s += '0x00'
                else : 
                    s += '0xff'
                s += ' '
                lines[count].append(s)
                count += 1
                if count == 256 : 
                    count = 0
    for line in lines : 
        for string in line : 
            I.write(string)
        I.write('\n')
    I.close()

    #Now I allocate median pooling layer, execute it and store the results
    path = os.path.join(os.getcwd(), 'output_feature_map.dat')
    O = open(path, 'w+')
    MedFilter = Median_pooling_layer(pooling_size=3,stride_x=1,stride_y=1)
    OutputTensor = MedFilter.forward(InputTensor)
    print(OutputTensor)
    c_o,w_o,h_o = OutputTensor.size()
    print('co : ' + str(c_o) + ' wo : ' + str(w_o) + ' ho : '+ str(h_o))

    #Storing results surface packed, little endianess
    lines = [[] for _ in range(144)]
    count = 0
    for c in range(c_o):
        for w in range(w_o):
            for h in range(h_o):
                Lsb = int(OutputTensor[c,w,h]) & 0x0F
                MsB = (int(OutputTensor[c,w,h]) & 0x0F0) >> 4
                s = '0x'
                if MsB < 10 : 
                    s +=  str(MsB)
                elif MsB == 10:
                    s += 'a'
                elif MsB == 11:
                    s += 'b'
                elif MsB == 12:
                    s += 'c'
                elif MsB == 13:
                    s += 'd'
                elif MsB == 14 : 
                    s += 'e'
                elif MsB == 15:
                    s += 'f'
                else:
                    print('Error while translating msb in hex')
                    print(MsB)
                    sys.exit()
            
                if Lsb < 10 : 
                    s +=  str(Lsb)
                elif Lsb == 10:
                    s += 'a'
                elif Lsb == 11:
                    s += 'b'
                elif Lsb == 12:
                    s += 'c'
                elif Lsb == 13:
                    s += 'd'
                elif Lsb == 14 : 
                    s += 'e'
                elif Lsb == 15:
                    s+= 'f'
                else:
                    print('Error while translating lsb in hex')
                    print(Lsb)
                    sys.exit()
                s += ' '
                if OutputTensor[c,w,h].item() >= 0 :
                    s += '0x00'
                else:
                    s += '0xff'
                s += ' '
                lines[count].append(s)
                count += 1
                if count == 196 : 
                    count = 0
    for line in lines : 
        for string in line : 
            O.write(string)
        O.write('\n')
    O.close()


    

                
    




