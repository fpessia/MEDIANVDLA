import os,sys
import numpy as np

def transpose(x_t):
    x =  []
    for i in range(int(len(x_t[0])/2)):
        x.append([])

    for line in range(len(x_t)):
        for el in range(int(len(x_t[line])/2)) :
            element = el*2
            x[el].append(x_t[line][element])
            x[el].append(x_t[line][element+1])

    return x[:][:]

def Convolution (w, i):
    o = np.zeros((16), dtype=np.int16)
    for kernel in range(16):
        for c in range(32):
            for x in range(8):
                for y in range(8):
                    o[kernel] += w[kernel,c,x,y] * i[c,x,y]
    return o

# WEIGHTS PARAMETERS
k_w = 16
c_w = 32
h_w = 8
w_w = 8
#INPUT TENSOR
c_i = 32
h_i = 8
w_i = 8

WeightsPath = os.path.join(
    os.getcwd(), 'weight.dat'
)
InputPath = os.path.join(
    os.getcwd(), 'sample_surf.dat'
) 

WeightsFile = open(WeightsPath, 'r')
InputFile = open(InputPath, 'r')

Weights = WeightsFile.readlines()
Inputs = InputFile.readlines()

for i in range(9):
    Inputs.pop(0)
    Weights.pop(0)
Weights.pop(0)

w = np.zeros((k_w, c_w, w_w, h_w))
i = np.zeros((c_i, w_i, h_i))

#converting weights from hex to int
KernelsCounter = 0
ChannelsCounter = 0
HeightCounter = 0
WidthCounter = 0

w_hex_T = []
for line in Weights:
    w_hex_T.append(line.split(' '))

w_hex = transpose(w_hex_T)
ToConvertInt16 = []
for line in w_hex:
    for byte in line:
        if len(ToConvertInt16) != 0:
            b = list(byte)
            #try:
            #    b.remove('\n')
            #except ValueError:
            #    pass
            
            b.pop(0)
            b.pop(0)
            ToConvertInt16 =  ToConvertInt16+b 
            ToConvertInt16 = ''.join(ToConvertInt16)
            print(ToConvertInt16)
            signed_int_16_value = int(ToConvertInt16, 16)
            if signed_int_16_value & (1 << 15):
                signed_int_16_value -= 1 << 16
            w[KernelsCounter,ChannelsCounter, WidthCounter, HeightCounter] = signed_int_16_value
            ToConvertInt16 = [] 

            WidthCounter += 1
            if WidthCounter == w_w:
                WidthCounter = 0
                HeightCounter += 1
                if HeightCounter == h_w:
                    HeightCounter = 0
                    ChannelsCounter += 1
                    if ChannelsCounter == c_w:
                        ChannelsCounter = 0
                        KernelsCounter += 1

        else:
            ToConvertInt16 = list(byte)
            try:
                ToConvertInt16.remove('\n')
            except ValueError:
                pass
            #ToConvertInt16.pop(0)
            #ToConvertInt16.pop(0)


#converting input tensor from hex to int
ChannelsCounter = 0
HeightCounter = 0
WidthCounter = 0
done = False

i_hex_T = []
for line in Inputs:
    i_hex_T.append(line.split(' '))

i_hex = transpose(i_hex_T)
ToConvertInt16 = []
for line in i_hex:
    if not(done):
        for byte in line:
            if len(ToConvertInt16) != 0:
                b = list(byte)
                #try:
                #    b.remove('\n')
                #except ValueError:
                #    pass
                b.pop(0)
                b.pop(0)
                ToConvertInt16 = ToConvertInt16+ b 
                ToConvertInt16 = ''.join(ToConvertInt16)
                signed_int_16_value = int(ToConvertInt16, 16)
                if signed_int_16_value & (1 << 15):
                    signed_int_16_value -= 1 << 16
                i[ChannelsCounter, WidthCounter, HeightCounter] = signed_int_16_value
                ToConvertInt16 = [] 
                
                WidthCounter += 1
                if WidthCounter == w_i:
                    WidthCounter = 0
                    HeightCounter += 1
                    if HeightCounter == h_i:
                        HeightCounter = 0
                        ChannelsCounter += 1
                        if ChannelsCounter == c_i:
                            done = True


            else:
                ToConvertInt16 = list(byte)
                try:
                    ToConvertInt16.remove('\n')
                except ValueError:
                    pass
                #ToConvertInt16.pop(0)
                #ToConvertInt16.pop(0)
print(w)
o = Convolution(w,i)
for k in range(16):
    print(o[k])
sys.exit()
normalized_array = (o - np.mean(o)) / np.std(o)
print(normalized_array)
for k in range(k_w):
    print(hex(int(o[k])))
