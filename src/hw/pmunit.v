`timescale 1ns / 1ps

module pmunit#(
     parameter integer  NUM_NEARPM_UNITS     = 4,
     parameter integer COMMAND_WORDS         = 5,
     parameter integer C_M_AXI_ADDR_WIDTH	 = 32,
     parameter integer C_M_AXI_DATA_WIDTH    = 32
    )
    (
    input wire clk,
    input wire reset, //acive low
    input wire [31:0] COMMAND_BUS,
    input wire [31:0] CURRENT_LOG_ADDR,
    input wire COMMAND_VALID,
    input wire START_EXECUTION,
    input wire [63:0] ADDR_OFFSET,
    input wire ADDR_OFFSET_VALID,
    output wire PMUNIT_STATE,
    
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
    output wire [2 : 0] M_AXI_AWPROT,
    output wire  M_AXI_AWVALID,
    input wire  M_AXI_AWREADY,
    output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
    output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
    output wire  M_AXI_WVALID,
    input wire  M_AXI_WREADY,
    input wire [1 : 0] M_AXI_BRESP,
    input wire  M_AXI_BVALID,
    output wire  M_AXI_BREADY,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
    output wire [2 : 0] M_AXI_ARPROT,
    output wire  M_AXI_ARVALID,
    input wire  M_AXI_ARREADY,
    input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
    input wire [1 : 0] M_AXI_RRESP,
    input wire  M_AXI_RVALID,
    output wire  M_AXI_RREADY
    
    );
    
    wire DMA_START;
    wire [31:0] DMA_SRC;
    wire [31:0] DMA_DEST;
    wire [31:0] DMA_LEN;
    wire DMA_DONE;
        
    pmunit_controller#(
    .NUM_NEARPM_UNITS( NUM_NEARPM_UNITS),
    .COMMAND_WORDS(COMMAND_WORDS)
    )
    controller(
    .clk(clk),
    .reset(reset),
    .COMMAND_BUS(COMMAND_BUS),
    .CURRENT_LOG_ADDR(CURRENT_LOG_ADDR),
    .COMMAND_VALID(COMMAND_VALID),
    .START_EXECUTION(START_EXECUTION),
    .ADDR_OFFSET(ADDR_OFFSET),
    .ADDR_OFFSET_VALID(ADDR_OFFSET_VALID),
    .PMUNIT_STATE(PMUNIT_STATE),
    .DMA_START(DMA_START),
    .DMA_SRC(DMA_SRC),
    .DMA_DEST(DMA_DEST),
    .DMA_LEN(DMA_LEN),
    .DMA_DONE(DMA_DONE)
    );
    
    dma_driver driver(
    .DMA_START(DMA_START),
    .DMA_SRC(DMA_SRC),
    .DMA_DEST(DMA_DEST),
    .DMA_LEN(DMA_LEN),
    .DMA_DONE(DMA_DONE),
   // output [3:0] mst_exec_state,


    .M_AXI_ACLK(clk),
    .M_AXI_ARESETN(reset),
    .M_AXI_AWADDR(M_AXI_AWADDR),
    .M_AXI_AWPROT(M_AXI_AWPROT),
    .M_AXI_AWVALID(M_AXI_AWVALID),
    .M_AXI_AWREADY(M_AXI_AWREADY),
    .M_AXI_WDATA(M_AXI_WDATA),
    .M_AXI_WSTRB(M_AXI_WSTRB),
    .M_AXI_WVALID(M_AXI_WVALID),
    .M_AXI_WREADY(M_AXI_WREADY),
    .M_AXI_BRESP(M_AXI_BRESP),
    .M_AXI_BVALID(M_AXI_BVALID),
    .M_AXI_BREADY(M_AXI_BREADY),
    .M_AXI_ARADDR(M_AXI_ARADDR),
    .M_AXI_ARPROT(M_AXI_ARPROT),
    .M_AXI_ARVALID(M_AXI_ARVALID),
    .M_AXI_ARREADY(M_AXI_ARREADY),
    .M_AXI_RDATA(M_AXI_RDATA),
    .M_AXI_RRESP(M_AXI_RRESP),
    .M_AXI_RVALID(M_AXI_RVALID),
    .M_AXI_RREADY(M_AXI_RREADY)
    
    );
   
endmodule
