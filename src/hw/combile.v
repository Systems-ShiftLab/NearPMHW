`timescale 1ns / 1ps


module combile(
    input wire in0,
    input wire in1,
    input wire in2,
    input wire in3,
    
    output wire [3:0] outp   

    );
    
    assign outp = {in3,in2,in1,in0};
    
endmodule
