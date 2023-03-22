`timescale 1 ns / 1 ps

	module multi_thread_scheduler_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 32,
		parameter integer C_M_AXI_DATA_WIDTH	= 32,
        parameter integer C_M_AXI_ADDR_WIDTH    = 32,        
        parameter integer  NUM_NEARPM_UNITS     = 4
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,
        output [31:0] COMMAND_BROADCAST,
        output [NUM_NEARPM_UNITS-1:0] COMMAND_BROADCAST_VALID,
        output [19:0] OID_OFFSET_LOOKUP,
        output OID_VALID,        
		
		input [71:0] PMEM_OBJ_OFFSET,
        input PMEM_OBJ_OFFSET_VALID, 
		
		output STALL_MEM_CHANNEL,
		input [NUM_NEARPM_UNITS -1 :0] NEARPMUNIT_DONE  ,
        output [NUM_NEARPM_UNITS - 1:0] NEARPM_STATRT,
        output [31:0] CURRENT_LOG_ADDR,
/*
		input wire M_AXI_ACLK,
        input wire M_AXI_ARESETN,
        output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
        output wire [2 : 0] M_AXI_AWPROT,
        output wire M_AXI_AWVALID,
        input wire M_AXI_AWREADY,
        output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
        output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
        output wire M_AXI_WVALID,
        input wire M_AXI_WREADY,
        input wire [1 : 0] M_AXI_BRESP,
        input wire M_AXI_BVALID,
        output wire M_AXI_BREADY,
        output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
        output wire [2 : 0] M_AXI_ARPROT,
        output wire M_AXI_ARVALID,
        input wire M_AXI_ARREADY,
        input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
        input wire [1 : 0] M_AXI_RRESP,
        input wire M_AXI_RVALID,
        output wire M_AXI_RREADY,
 */       
        //Testing
        output wire [31:0] testout00 
 /*       output wire [31:0] testout01 ,
        output wire [31:0] testout02 ,
        output wire [31:0] testout03 ,
        output wire [31:0] testout04 ,
        output wire [31:0] testout10, 
        output wire [31:0] testout11 ,
        output wire [31:0] testout12 ,
        output wire [31:0] testout13 ,
        output wire [31:0] testout14 */
	);
// Instantiation of Axi Bus Interface S00_AXI
	multi_thread_scheduler_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH),
		.NUM_NEARPM_UNITS(NUM_NEARPM_UNITS)
	) multi_thread_scheduler_v1_0_S00_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		.command_broadcast(COMMAND_BROADCAST),
        .command_broadcast_valid(COMMAND_BROADCAST_VALID),
        .oid_offset_lookup(OID_OFFSET_LOOKUP),
        .pmem_obj_offset(PMEM_OBJ_OFFSET),
        .pmem_obj_offset_valid(PMEM_OBJ_OFFSET_VALID), 
        .oid_valid(OID_VALID),
        .slall_mem_channel(STALL_MEM_CHANNEL),
        .nearpmunit_done(NEARPMUNIT_DONE),
        .nearpm_go_ahead(NEARPM_STATRT),
        .current_log_addr(CURRENT_LOG_ADDR),
		.testout00(testout00)
/*		.testout11(testout11),
		.testout12(testout12),
		.testout13(testout13),
		.testout14(testout14),
		.testout00(testout00),
		.testout01(testout01),
		.testout02(testout02),
		.testout03(testout03),
		.testout04(testout04)*/
	);
	/*
	axi_data_writer #(
	.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
    .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH))
	 writer_inst(
	    .M_AXI_ACLK(M_AXI_ACLK),
        .M_AXI_ARESETN(M_AXI_ARESETN),
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

	// Add user logic here

	// User logic ends
*/
	endmodule
