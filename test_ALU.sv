`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/11 08:43:21
// Design Name: 
// Module Name: test_ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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
