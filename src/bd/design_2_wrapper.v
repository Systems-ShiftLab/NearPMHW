//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.2 (lin64) Build 2258646 Thu Jun 14 20:02:38 MDT 2018
//Date        : Fri May  6 15:03:09 2022
//Host        : desk053 running 64-bit Ubuntu 20.04.2 LTS
//Command     : generate_target design_2_wrapper.bd
//Design      : design_2_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_2_wrapper
   (areset,
    clk,
    start);
  input areset;
  input clk;
  input start;

  wire areset;
  wire clk;
  wire start;

  design_2 design_2_i
       (.areset(areset),
        .clk(clk),
        .start(start));
endmodule
