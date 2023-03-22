`timescale 1ns / 1ps


module split(
    output wire out0,
    output wire out1,
    output wire out2,
    output wire out3,
    
    input wire [3:0] inp   

    );
    
    assign out0 = inp[0];
    assign out1 = inp[1];
    assign out2 = inp[2];
    assign out3 = inp[3];
    
endmodule
