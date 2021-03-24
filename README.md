# ALU_32
采用system verilog完成32bit-ALU，同时提供测试代码

### ALU代码

#### 编写SLT时遇到的困难与两个解决方案

在编写ALU代码的时候，我主要遇到的困难在于完成STL功能。

我的最初想法是一条简单的代码，res = (a < b) ? 1 : 0;然而通过后续的测试代码(实现`SLT 0, -1`时)发现发生了错误。通过查看资料得知，原因在于system verilog不会将32'bffffffff认定为-1的补码表示，而是看作一个32位的无符号整数，因此会得到0<32'bffffffff的结果，即correct为1，与期望的结果-1相反。

后面我想到了一种解决方案——**先通过最高位(符号位)判断正负，然后进行比较**，代码如下：

```verilog
if(a[31] == 1 && b[31] == 0) res = 1;//若a为负b为正，则显然a小于b，res为1
else if(a[31] == 0 && b[31] == 1) res = 0;//若a为正b为负，则显然a大于b，res为0
else res = a[30:0] < b[30:0] ? 1 : 0;//当a、b同号时，可以直接用<进行比较判断
```

最后验证能够通过测试代码。



后续我又思考：**能否不通过事先判断a和b的正负，直接通过与或非这些基础的运算给出统一的代码进行判断**？

这是可行的。其基本思路不再是res = a < b，而是**res = (a - b) < 0，即先进行减法操作，然后判断减法所得结果的正负**，这样可以避免出现之前的问题。具体方法如下：

1. 首先新增三个变量`logic [32:0] a_1`，`logic [32:0] b_1`以及`logic [32:0] sum`。
2. 将a，b的低31位赋值给a_1， b_1，最高位(第31位)赋值给a_1，b_1的最高位(第33位)
3. 将a，b的第32位(次高位)置0
4. 计算a_1 + ((~b_1) + 1)，由于最高位为1时，表明a - b的结果为负数，则SLT的结果为1；而最高位为0时，表明a - b的结果为正数，则SLT的结果为0。因此，最高位，也就是sum[32]就是SLT的结果。
5. 最后将sum的最高位放入res中即可。

具体代码如下：

```verilog
                a_1[30:0] = a;
                b_1[30:0] = b;
                a_1[32] = a[31];
                b_1[32] = b[31];
                a_1[31] = 0;
                b_1[31] = 0;
				sum = (a_1 + (~b_1) + 1);//sum的最高位即为SLT的结果

                sum[0] = sum[32];//将结果放入res中
                sum[32:1] = 0;
                res = sum[31:0];
```



#### 完整代码

在其余功能的完成中并没有遇到什么困难，直接根据PPT中所给功能表写出代码即可。完整代码如下：

```verilog
module ALU(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [2:0] alucount,
    output logic [31:0] res,
    output logic zero
    );
    
    logic [32:0] a_1;
    logic [32:0] b_1;
    logic [32:0] sum;
    always_comb
        begin
        case(alucount)
            3'b000: res = a & b;
            3'b001: res = a | b;
            3'b010: res = a + b;
            3'b100: res = a & ~b;
            3'b101: res = a | ~b;
            3'b110: res = a - b;
            3'b111: begin  //SLT
                a_1[30:0] = a;
                b_1[30:0] = b;
                a_1[32] = a[31];
                b_1[32] = b[31];
                a_1[31] = 0;
                b_1[31] = 0;
                sum = (a_1 + (~b_1) + 1);//sum即为SLT的结果
                sum[0] = sum[32];//将结果放入res中
                sum[32:1] = 0;
                res = sum[31:0];
            end
            default: res = 0;
        endcase
        if(res == 0) zero = 1;
        else zero = 0;
        end
endmodule
```



### 表格

将PPT中的表格补全如下：

| Test                  | ALUcont | A        | B        | result   | zero |
| --------------------- | ------- | -------- | -------- | -------- | ---- |
| ADD 0+0               | 2       | 00000000 | 00000000 | 00000000 | 1    |
| ADD 0+(-1)            | 2       | 00000000 | FFFFFFFF | FFFFFFFF | 0    |
| ADD 1+(-1)            | 2       | 00000001 | FFFFFFFF | 00000000 | 1    |
| ADD FF+1              | 2       | 000000FF | 00000001 | 00000100 | 0    |
| SUB 0-0               | 6       | 00000000 | 00000000 | 00000000 | 1    |
| SUB 0-(-1)            | 6       | 00000000 | FFFFFFFF | 00000001 | 0    |
| SUB 1-1               | 6       | 00000001 | 00000001 | 00000000 | 1    |
| SUB 100-1             | 6       | 00000100 | 00000001 | 000000FF | 0    |
| SLT 0,0               | 7       | 00000000 | 00000000 | 00000000 | 1    |
| SLT 0,1               | 7       | 00000000 | 00000001 | 00000001 | 0    |
| SLT 0,-1              | 7       | 00000000 | FFFFFFFF | 00000000 | 1    |
| SLT 1,0               | 7       | 00000001 | 00000000 | 00000000 | 1    |
| SLT -1,0              | 7       | FFFFFFFF | 00000000 | 00000001 | 0    |
| AND FFFFFFFF,FFFFFFFF | 0       | FFFFFFFF | FFFFFFFF | FFFFFFFF | 0    |
| AND FFFFFFFF,12345678 | 0       | FFFFFFFF | 12345678 | 12345678 | 0    |
| AND 12345678,87654321 | 0       | 12345678 | 87654321 | 02244220 | 0    |
| AND 00000000,FFFFFFFF | 0       | 00000000 | FFFFFFFF | 00000000 | 1    |
| OR FFFFFFFF,FFFFFFFF  | 1       | FFFFFFFF | FFFFFFFF | FFFFFFFF | 0    |
| OR 12345678,87654321  | 1       | 12345678 | 87654321 | 97755779 | 0    |
| OR 00000000,FFFFFFFF  | 1       | 00000000 | FFFFFFFF | FFFFFFFF | 0    |
| OR 00000000,00000000  | 1       | 00000000 | 00000000 | 00000000 | 1    |



### 测试代码(三种方案)

我采用PPT中表格列出的情况作为测试样例。然而，由于测试表中数据较多，单纯用肉眼比对波形图容易出错，因此我想到了以下三种测试方案。

1. **$display(‘str’, variable)**

   ​	采用display可以以类似日志的方式进行输出，是可视化效果较好的方案。且更方便的是，可以设置一个位数较多的变量，每一位由低到高代表一次实验的结果，最后直接查看日志检测代码是否正确即可。这一方法也可以与下述的第三种方案结合，先检查出是否出错，然后通过这一方案能够迅速精确查找出哪个部分出了错。

2. **assert(expr)     else $error('xxx failed')**

   ​	类似于标准的单元测试，可以获得清晰的文字输出。

3. **测试变量correct**

   ​	我新增了一个变量correct，它相当于常见编程中的bool类型变量，当correct为1时表示结果正确，当correct为0时表示结果错误。

   ​	在本实验中，需要根据res(即result)和zero两个变量的结果判断是否正确，因此我才用`&`进行逻辑连接，这样只需要检测波形图中的correct变量结果是否为1即可判断代码是否正确。

具体代码如下：

```verilog
module test_ALU();
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] result;
    logic [2:0] alucount;
    logic zero;
    logic correct;
    
    ALU ALU(a, b, alucount, result, zero);
    initial begin
        correct = 1;
        //case 1:add 0, 0
        a = 0;b = 0;alucount = 2;
        #10
        correct = ((zero == 1) & (result == 0));
        
        //case2: add 0 + (-1)
        a = 0; b = 32'hffffffff; alucount = 2;
        #10
        correct = ((zero == 0) & (result == 32'hffffffff));
        
        //case 3:add 1 + (-1)
        a = 1; b = 32'hffffffff; alucount = 2;
        #10
        correct = ((zero == 1) & (result == 0));
        
        //case 4:add FF, 1
        a = 32'h000000ff; b = 1; alucount = 2;
        #10
        correct = ((zero == 0) & (result == 32'h00000100));
        
        //case 5:sub 0, 0
        a = 32'h00000000; b = 32'h000000000; alucount = 6;
        #10
        correct = ((zero == 1) & (result == 0));
        
        //case 6:sub 0, -1
        a = 32'h00000000;b = 32'hffffffff; alucount = 6;
        #10
        correct = ((zero == 0) & (result == 1));
        
        //case7: sub 1, 1
        a = 32'h00000001; b = 32'h00000001; alucount = 6;
        #10
        correct = ((zero == 1) & (result == 0));
        
        //case 8:sub 0x100, 1
        a = 32'h00000100; b = 32'h00000001; alucount = 6;
        #10
        correct = ((zero == 0) & (result == 32'h000000ff));
        
        //case 9:slt 0, 0
        a = 32'h00000000;b = 32'h00000000; alucount = 7;
        #10
        correct = ((zero == 1) & (result == 0));
        
        //case 10:slt 0, 1
        a = 32'h00000000; b = 32'h00000001; alucount = 7;
        #10
        correct = ((zero == 0) & (result == 1));
        
        //case 11:slt 0, -1
        a = 32'h00000000; b = 32'hffffffff; alucount = 7;
        #10
        correct = ((zero == 1) & (result == 0));
        
        //case 12:slt 1, 0
        a = 32'h00000001; b = 32'h00000000; alucount = 7;
        #10
        correct = ((zero == 1) & (result == 0));
        
        //case 13:slt -1, 0
        a = 32'hffffffff; b = 32'h00000000; alucount = 7;
        #10
        correct = ((zero == 0) & (result == 1));
        
        //case 14:and -1, -1
        a = 32'hffffffff; b = 32'hffffffff; alucount = 0;
        #10
        correct = ((zero == 0) & (result == 32'hffffffff));
        
        //case 15:and 0xffffffff, 0x12345678
        a = 32'hffffffff; b = 32'h12345678; alucount = 0;
        #10
        correct = ((zero == 0) & (result == 32'h12345678));
        
        //case 16: and 0x12345678, 0x87654321
        a = 32'h12345678; b= 32'h87654321; alucount = 0;
        #10
        correct = ((zero == 0) & (result == 32'h02244220));
        
        //case 17: and 0, 0xffffffff
        a = 32'h00000000; b = 32'hffffffff; alucount = 0;
        #10
        correct = ((zero == 1) & (result == 0));
        
        //case 18: or -1, -1
        a = 32'hffffffff; b = 32'hffffffff; alucount = 1;
        #10
        correct = ((zero == 0) & (result == 32'hffffffff));
        
        //case 19:or 0x12345678, 0x87654321
        a = 32'h12345678; b = 32'h87654321; alucount = 1;
        #10
        correct = ((zero == 0) & (result == 32'h97755779));
        
        //case 20:or 0, -1
        a = 0; b = 32'hffffffff; alucount = 1;
        #10
        correct = ((zero == 0) & (result == 32'hffffffff));
        
        //case 21:or 0, 0
        a = 0; b = 0; alucount = 1;
        #10
        correct = ((zero == 1) & (result == 0));
        
        end
        
endmodule
```

