`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2022 04:05:38 PM
// Design Name: 
// Module Name: test_multi_thread_scheduler
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


module test_multi_thread_scheduler(

    );
    reg clk;
    reg reset;
    reg start;
    
    initial
    begin
    reset = 1'b1;
    start = 1'b0;
    #40;
    reset = 1'b0;
    #40;
    reset = 1'b1;
    #40;
    start =1'b1;
    #40;
    start = 1'b0;
    end
    
    always
    begin
    clk = 1'b0;
    #20;
    clk = 1'b1;
    #20;
    end
    
    design_1 dut(clk, reset, start);
    
    
endmodule
