import torch

class Median_pooling_layer():
    def __init__(self,pooling_size,stride_x, stride_y, padding_top = 0, padding_bottom = 0, padding_left = 0, padding_right = 0):
        self.pooling_size = pooling_size
        self.stride_x = stride_x
        self.stride_y = stride_y
        self.padding = (padding_top, padding_bottom, padding_left, padding_right)

    def padd(self, input):
        self.x_pad = self.i + self.padding[0] + self.padding[1]
        self.y_pad = self.j + self.padding[2] + self.padding[3]
        output = torch.zeros(self.c, self.x_pad, self.y_pad)

        for c in range(self.c):
            for i in range(self.i):
                for j in range(self.j):
                    output[c,i+self.padding[0], j + self.padding[2]] = input[c,i,j].item()
        
        return output  

    def forward(self, input):
        #ZERO PADDING
        self.c,self.i,self.j = input.size()
        x = self.padd(input)


        y = torch.zeros(self.c, int((self.x_pad - self.pooling_size)/ self.stride_x) + 1 ,int((self.y_pad - self.pooling_size)/ self.stride_y) + 1 )
        for c in range(self.c):
            for w in range(int((self.x_pad - self.pooling_size)/ self.stride_x) + 1 ):
                for h in range(int((self.y_pad - self.pooling_size)/ self.stride_y) + 1):
                    median_list = []
                    for p1 in range(self.pooling_size):
                        for p2 in range(self.pooling_size):
                            median_list.append(x[c,w*self.stride_x+p1, h*self.stride_y+p2].item())
                    median_list.sort()
                    if len(median_list) % 2 == 0:
                        y[c,w,h] = median_list[int(len(median_list)/2) -1]
                    else: 
                        y[c,w,h] = median_list[int(len(median_list)/2) ]
        return y