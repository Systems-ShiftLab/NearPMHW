//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.2 (lin64) Build 2258646 Thu Jun 14 20:02:38 MDT 2018
//Date        : Sun May  8 14:24:22 2022
//Host        : desk053 running 64-bit Ubuntu 20.04.2 LTS
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (clk,
    reset,
    start);
  input clk;
  input reset;
  input start;

  wire clk;
  wire reset;
  wire start;

  design_1 design_1_i
       (.clk(clk),
        .reset(reset),
        .start(start));
endmodule
