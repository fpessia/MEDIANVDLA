import torch
from Median2d import MedianPool2d

import os, sys
import random



if __name__ == '__main__':
    path = os.path.join(os.getcwd(),'input_feature_map.dat')
    InputTensor = torch.zeros((64,8,8), dtype=torch.int16)
    #randomly generating input tensor
    for c in range(64):
        for w in range(8):
            for h in range(8):
                hex_bytes= [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
                #generate MSB
                MSB = random.choice(hex_bytes) 
                InputTensor[c,w,h] += MSB*16
                #generate LSB
                LSB = random.choice(hex_bytes)
                InputTensor[c,w,h] += LSB
                #byte 3/4 --> all zeros
    
    #Storing in memory Surface packed, Little Endianess
    I = open(path, 'a')
    lines = [[] for _ in range(256)]
    count = 0
    for c in range(64):
        for w in range(8):
            for h in range(8):
                Lsb = int(InputTensor[c,w,h]) % 16
                MsB = int(InputTensor[c,w,h]) - Lsb
                s = '0x'
                if MsB < 10 : 
                    s +=  str(MsB)
                elif MsB == 10:
                    s += 'A'
                elif MsB == 11:
                    s += 'B'
                elif MsB == 12:
                    s += 'C'
                elif MsB == 13:
                    s += 'D'
                elif MsB == 14 : 
                    s += 'E'
                elif MsB == 15:
                    s += 'F'
                else:
                    print('Error while translating in hex')
                    sys.exit()
                
                s += ' '
                s += '0x'
                if Lsb < 10 : 
                    s +=  str(Lsb)
                elif Lsb == 10:
                    s += 'A'
                elif Lsb == 11:
                    s += 'B'
                elif Lsb == 12:
                    s += 'C'
                elif Lsb == 13:
                    s += 'D'
                elif Lsb == 14 : 
                    s += 'E'
                elif Lsb == 15:
                    s+= 'F'
                else:
                    print('Error while translating in hex')
                    sys.exit()
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
    O = open(path, 'a')
    MedFilter = MedianPool2d(kernel_size=2,stride=1, padding=0)
    OutputTensor = MedFilter.forward(InputTensor)
    c_o,w_o,h_o = OutputTensor.size()
    print('co : ' + str(c_o) + ' wo : ' + str(w_o) + ' ho : '+ str(h_o))

    #Storing results surface packed, little endianess
    lines = [[] for _ in range(196)]
    count = 0
    for c in range(c_o):
        for w in range(w_o):
            for h in range(h_o):
                Lsb = int(OutputTensor[c,w,h]) % 16
                MsB = int(OutputTensor[c,w,h]) - Lsb
                s = '0x'
                if MsB < 10 : 
                    s +=  str(MsB)
                elif MsB == 10:
                    s += 'A'
                elif MsB == 11:
                    s += 'B'
                elif MsB == 12:
                    s += 'C'
                elif MsB == 13:
                    s += 'D'
                elif MsB == 14 : 
                    s += 'E'
                elif MsB == 15:
                    s += 'F'
                else:
                    print('Error while translating in hex')
                    sys.exit()
                
                s += ' '
                s += '0x'
                if Lsb < 10 : 
                    s +=  str(Lsb)
                elif Lsb == 10:
                    s += 'A'
                elif Lsb == 11:
                    s += 'B'
                elif Lsb == 12:
                    s += 'C'
                elif Lsb == 13:
                    s += 'D'
                elif Lsb == 14 : 
                    s += 'E'
                elif Lsb == 15:
                    s+= 'F'
                else:
                    print('Error while translating in hex')
                    sys.exit()
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


    

                
    




