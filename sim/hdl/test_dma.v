`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2022 10:50:23 AM
// Design Name: 
// Module Name: test_dma
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


module test_dma(

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
     
     design_2 dut(
        .areset(reset),
        .clk(clk),
        .start(start));
     
     
 endmodule