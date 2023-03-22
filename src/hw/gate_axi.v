`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2021 07:41:52 PM
// Design Name: 
// Module Name: gate_axi
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


module gate_axi(
    input clk_src,
    input clk_dest,
    input aresetn,
    input awvalid_in,
    input awready_in,
    input arvalid_in,
    input arready_in,
    input wvalid_in,
    input wready_in,
    input bvalid_in,
    input bready_in,
    input rvalid_in,
    input rready_in,
    
    input [31:0] awaddr_in,
    
    input stall_channel,
    
    output awvalid_out,
    output awready_out,
    output arvalid_out,
    output arready_out,
    output wvalid_out,
    output wready_out,
    output bvalid_out,
    output bready_out,
    output rvalid_out,
    output rready_out,
    
    output [31:0] awaddr_out,
    
    
    
    output wire ndp_not_inuse_out
    );
    
    wire stall_channel_sync;
   // wire ndp_not_inuse_sync;
    xpm_cdc_single #(
          .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
          .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
          .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
          .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
       )
       xpm_cdc_single_inst (
          .dest_out(stall_channel_sync), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                               // registered.
    
          .dest_clk(clk_dest), // 1-bit input: Clock signal for the destination clock domain.
          .src_clk(clk_src),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
          .src_in(stall_channel )      // 1-bit input: Input signal to be synchronized to dest_clk domain.
       );


      
    
    wire all_wvalid_zero;
    assign all_wvalid_zero = ~(awvalid_in | wvalid_in | bvalid_in);
    
    reg stall_set;
    always @(posedge clk_dest) begin
        if (aresetn==1) begin
            stall_set <= 1'b0;
        end
        else begin
            if(all_wvalid_zero && stall_channel_sync) begin
                stall_set <= 1'b1;            
            end
            
            if(~stall_channel_sync)
                stall_set <= 1'b0;
        end
    end
      
    assign ndp_not_inuse_out = ~((stall_channel_sync & all_wvalid_zero) | stall_set);
    
    
    assign awready_out = ndp_not_inuse_out & awready_in;
    assign awvalid_out = ndp_not_inuse_out & awvalid_in;
    
   // assign arready_out = ndp_not_inuse_out & arready_in;
   // assign arvalid_out = ndp_not_inuse_out & arvalid_in;
  
    assign arready_out = arready_in;
    assign arvalid_out = arvalid_in;
    
   // assign wready_out = ndp_not_inuse_out & wready_in;
   // assign wvalid_out = ndp_not_inuse_out & wvalid_in;
    
    assign wready_out = wready_in;
    assign wvalid_out = wvalid_in;
      
   // assign rready_out = ndp_not_inuse_out & rready_in;
   // assign rvalid_out = ndp_not_inuse_out & rvalid_in;
    
    assign rready_out = rready_in;
    assign rvalid_out = rvalid_in;
  
    
   // assign bready_out = ndp_not_inuse_out & bready_in; 
   // assign bvalid_out = ndp_not_inuse_out & bvalid_in;
    
    assign bready_out = bready_in; 
    assign bvalid_out = bvalid_in;
    
    assign awaddr_out = ndp_not_inuse_out ? awaddr_in : 32'd0;
    
    
  
endmodule
