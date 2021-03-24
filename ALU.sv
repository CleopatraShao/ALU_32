`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/10 19:07:55
// Design Name: 
// Module Name: ALU
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
            3'b111: begin
                a_1[30:0] = a;
                b_1[30:0] = b;
                a_1[32] = a[31];
                b_1[32] = b[31];
                a_1[31] = 0;
                b_1[31] = 0;
                sum = (a_1 + (~b_1) + 1);
                sum[0] = sum[32];
                sum[32:1] = 0;
                res = sum[31:0];
            end
            default: res = 0;
        endcase
        if(res == 0) zero = 1;
        else zero = 0;
        end
endmodule
