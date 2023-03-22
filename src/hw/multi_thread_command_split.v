`timescale 1ns / 1ps

module multi_thread_command_split #(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 4,
		parameter integer  NUM_NEARPM_UNITS     = 4,
		parameter integer DIMM0_START_ADDR = 32'h80000000,
		parameter integer DIMM0_END_ADDR = 32'h9FFFFFFF,
		parameter integer DIMM1_START_ADDR = 32'hA0000000,
		parameter integer DIMM1_END_ADDR = 32'hBFFFFFFF
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY,
		
		output [31:0] command_broadcast,
        output [NUM_NEARPM_UNITS-1:0] command_broadcast_valid,
        output [19:0] oid_offset_lookup,
        output oid_valid,
        input [71:0] pmem_obj_offset,
        input pmem_obj_offset_valid, 
       // input [NUM_NEARPM_UNITS -1 :0] nearpmunit_done,
       // output [NUM_NEARPM_UNITS - 1:0] nearpm_go_ahead,
      //  output [31:0] current_log_addr,
		
	//	output wire slall_mem_channel,
		////testing interfaces
		output wire [3:0] test_scheduler_state,
		output wire test_buffer0_select_valid,
        output wire test_buffer1_select_valid,
        output wire [31:0] test_fifo_buffer_full, 
        output reg [31:0] test_counter 
	/*	output wire [31:0] testout01 ,
		output wire [31:0] testout02 ,
		output wire [31:0] testout03 ,
		output wire [31:0] testout04,
		output wire [31:0] testout10,
		output wire [31:0] testout11,
		output wire [31:0] testout12,
		output wire [31:0] testout13,
		output wire [31:0] testout14*/
		
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 4
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      aw_en <= 1'b1;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	          aw_en <= 1'b0;
	        end
	        else if (S_AXI_BREADY && axi_bvalid)
	            begin
	              aw_en <= 1'b1;
	              axi_awready <= 1'b0;
	            end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 


   
    reg stall_cmd;    
    wire    fifo_full;
    
    
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en && ~stall_cmd && ~fifo_full)
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       
	

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    //UILITY FUNCTION
    // function called clogb2 that returns an integer which has the
    // value of the ceiling of the log base 2
    
    function integer clogb2 (input integer bit_depth);
        begin
            for(clogb2 = 0; bit_depth>0; clogb2 = clogb2+1)
                bit_depth = bit_depth >> 1;
        end
    endfunction
    ///

    localparam NUM_THREADS = 32'd16;
    localparam NUM_ELEMENTS= 32'd5;
    
    localparam CMD_COMPLETE_REG = 4;
    
    reg [31:0] cmd_ordering_buffer0[(NUM_ELEMENTS - 1):0][(NUM_THREADS -1):0];
    reg [31:0] cmd_ordering_buffer1[(NUM_ELEMENTS - 1):0][(NUM_THREADS -1):0];
    reg [31:0] ordering_index[(NUM_THREADS -1):0];
    integer i,j;

    wire thread_id;
    reg  [(NUM_THREADS -1):0] buffer0_full;
    reg  [(NUM_THREADS -1):0] buffer1_full;
    reg  [(NUM_THREADS -1):0] last_written_buffer; 
    
    //signals toreset buffers
    reg reset_buffer0;
    reg reset_buffer1; 
    
    reg [clogb2(NUM_THREADS-1):0]buffer0_select;
    reg [clogb2(NUM_THREADS-1):0]buffer1_select;
    

    //Command queue used to identify the order commands reached NearPM and they will be executed in that order
    //reg  [(NUM_THREADS -1):0] cmd_queue0 [(NUM_THREADS -1):0];
    //reg  [(NUM_THREADS -1):0] cmd_queue1 [(NUM_THREADS -1):0];
    
    
    assign thread_id = S_AXI_WDATA[31:24];
    
    
    always@(*) begin
        stall_cmd = 1'b0;
        for(i = 0; i < NUM_THREADS; i = i + 1)
            stall_cmd = stall_cmd | (buffer0_full[i] && buffer1_full[i] && S_AXI_WDATA[31:24] == i);
    end

    
    always@(*) begin
        for(i = 0; i < NUM_THREADS; i = i + 1) begin
            buffer0_full[i] = 1'b0;
            buffer1_full[i] = 1'b0;
        end
        for(i = 0; i < NUM_THREADS; i = i + 1) begin
            buffer0_full[i] = cmd_ordering_buffer0[CMD_COMPLETE_REG][i][23:0] == 24'hFF_FFFF;
            buffer1_full[i] = cmd_ordering_buffer1[CMD_COMPLETE_REG][i][23:0] == 24'hFF_FFFF;
        end
    end

    //reorder the incomming command   
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin	    
	       for ( i = 0; i <= NUM_THREADS -1; i = i + 1)
	       begin
	           ordering_index[i] <= 32'd0;
	           last_written_buffer[i] <= 1'b0;
	           for ( j = 0; j <= NUM_ELEMENTS -1; j = j + 1) begin
                    cmd_ordering_buffer0[j][i] <= 32'd0;
                    cmd_ordering_buffer1[j][i] <= 32'd0;
               end
           end
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	      if(ordering_index[thread_id] == 32'd6) begin
	           ordering_index[thread_id] <= 32'd0;
	      end
	      else
	           ordering_index[thread_id] <= ordering_index[thread_id] + 1;
	           
          case({last_written_buffer[thread_id],buffer0_full[thread_id],buffer1_full[thread_id]})
          3'b000, 3'b001,3'b101: begin
              last_written_buffer[thread_id] <= 1'b0;
              case(ordering_index[thread_id] % 4)
                  2'b00:
                  begin
                    cmd_ordering_buffer0[(ordering_index[thread_id]>>2)*3][thread_id][31:8] <= S_AXI_WDATA[23:0];
                  end
                  2'b01:
                  begin
                    cmd_ordering_buffer0[(ordering_index[thread_id]>>2)*3][thread_id][7:0] <= S_AXI_WDATA[23:16];
                    cmd_ordering_buffer0[(ordering_index[thread_id]>>2)*3 + 1][thread_id][31:16] <= S_AXI_WDATA[15:0];
                  end
                  2'b10:
                  begin
                    cmd_ordering_buffer0[(ordering_index[thread_id]>>2)*3 + 1][thread_id][15:0] <= S_AXI_WDATA[23:8];
                    cmd_ordering_buffer0[(ordering_index[thread_id]>>2)*3 + 2][thread_id][31:24] <= S_AXI_WDATA[7:0];
                  end
                  2'b11:
                  begin
                    cmd_ordering_buffer0[(ordering_index[thread_id]>>2)*3 + 2][thread_id][23:0] <= S_AXI_WDATA[23:0];
                  end     
              endcase
          end      
          3'b100, 3'b010, 3'b110: begin
              last_written_buffer[thread_id] <= 1'b1;
              case(ordering_index[thread_id] % 4)
                  2'b00:
                  begin
                    cmd_ordering_buffer1[(ordering_index[thread_id]>>2)*3][thread_id][31:8] <= S_AXI_WDATA[23:0];
                  end
                  2'b01:
                  begin
                    cmd_ordering_buffer1[(ordering_index[thread_id]>>2)*3][thread_id][7:0] <= S_AXI_WDATA[23:16];
                    cmd_ordering_buffer1[(ordering_index[thread_id]>>2)*3 + 1][thread_id][31:16] <= S_AXI_WDATA[15:0];
                  end
                  2'b10:
                  begin
                    cmd_ordering_buffer1[(ordering_index[thread_id]>>2)*3 + 1][thread_id][15:0] <= S_AXI_WDATA[23:8];
                    cmd_ordering_buffer1[(ordering_index[thread_id]>>2)*3 + 2][thread_id][31:24] <= S_AXI_WDATA[7:0];
                  end
                  2'b11:
                  begin
                    cmd_ordering_buffer1[(ordering_index[thread_id]>>2)*3 + 2][thread_id][23:0] <= S_AXI_WDATA[23:0];
                  end     
              endcase 
           end
           endcase
          end
          
          if(reset_buffer0)
            cmd_ordering_buffer0[NUM_ELEMENTS-1][buffer0_select] <= 32'd0;
          if(reset_buffer1)
            cmd_ordering_buffer1[NUM_ELEMENTS-1][buffer1_select] <= 32'd0;
          
      end
	end    
	
	
    //FIFO to rack order in which commands are recieved
    //FIFO write logic
    //Guaraneed one bit to be changed because writes are recieved one after the other to buffers
    reg     [(2*NUM_THREADS -1):0] buffer_full_old;
    wire    [(2*NUM_THREADS -1):0] fifo_buffer_full;    
    wire    fifo_wr_en;
    reg     fifo_rd_en;
    wire    fifo_empty;
    wire    fifo_data_valid;
    //wire fifo_rd_rst_busy;
    //wire fifo_wr_rst_busy;
    
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 ) begin
            buffer_full_old <= 64'd0;
        end
        else begin
            buffer_full_old <= {buffer0_full,buffer1_full};
        end
    end
    
    //only write when a new command is recieved
    assign fifo_wr_en = ((buffer_full_old != {buffer0_full,buffer1_full}) && (buffer_full_old < {buffer0_full,buffer1_full}))? 1 : 0;
    
    xpm_fifo_sync #(
        .DOUT_RESET_VALUE("0"),    // String
        .ECC_MODE("no_ecc"),       // String
        .FIFO_MEMORY_TYPE("auto"), // String
        .FIFO_READ_LATENCY(1),     // DECIMAL
        .FIFO_WRITE_DEPTH(32),   // DECIMAL
        .FULL_RESET_VALUE(0),      // DECIMAL
        .PROG_EMPTY_THRESH(10),    // DECIMAL
        .PROG_FULL_THRESH(10),     // DECIMAL
        .RD_DATA_COUNT_WIDTH(1),   // DECIMAL
        .READ_DATA_WIDTH(64),      // DECIMAL
        .READ_MODE("std"),         // String
        .USE_ADV_FEATURES("0707"), // String
        .WAKEUP_TIME(0),           // DECIMAL
        .WRITE_DATA_WIDTH(64),     // DECIMAL
        .WR_DATA_COUNT_WIDTH(1)    // DECIMAL
    )
    ordering_fifo (    
        .data_valid(fifo_data_valid),       // 1-bit output: Read Data Valid: When asserted, this signal indicates
                                         // that valid data is available on the output bus (dout).    
        .dout(fifo_buffer_full),                   // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
                                        // when reading the FIFO.    
        .empty(fifo_empty),                 // 1-bit output: Empty Flag: When asserted, this signal indicates that the
                                         // FIFO is empty. Read requests are ignored when the FIFO is empty,
                                         // initiating a read while empty is not destructive to the FIFO.    
        .full(fifo_full),                   // 1-bit output: Full Flag: When asserted, this signal indicates that the
                                         // FIFO is full. Write requests are ignored when the FIFO is full,
                                         // initiating a write when the FIFO is full is not destructive to the
                                         // contents of the FIFO.    
        //.overflow(overflow),           // 1-bit output: Overflow: This signal indicates that a write request
                                         // (wren) during the prior clock cycle was rejected, because the FIFO is
                                         // full. Overflowing the FIFO is not destructive to the contents of the
                                         // FIFO.    
        //.rd_rst_busy(fifo_rd_rst_busy),     // 1-bit output: Read Reset Busy: Active-High indicator that the FIFO read
                                         // domain is currently in a reset state.      
        //.wr_rst_busy(fifo_wr_rst_busy),     // 1-bit output: Write Reset Busy: Active-High indicator that the FIFO
                                         // write domain is currently in a reset state.    
        .din(~buffer_full_old & {buffer0_full,buffer1_full}),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
                                         // writing the FIFO.    
        .rd_en(fifo_rd_en),                 // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
                                         // signal causes data (on dout) to be read from the FIFO. Must be held
                                         // active-low when rd_rst_busy is active high. .    
        .rst(~S_AXI_ARESETN),                     // 1-bit input: Reset: Must be synchronous to wr_clk. Must be applied only
                                         // when wr_clk is stable and free-running.    
        .wr_clk(S_AXI_ACLK),               // 1-bit input: Write clock: Used for write operation. wr_clk must be a
                                        // free running clock.    
        .wr_en(fifo_wr_en)                  // 1-bit input: Write Enable: If the FIFO is not full, asserting this
                                         // signal causes data (on din) to be written to the FIFO Must be held
                                         // active-low when rst or wr_rst_busy or rd_rst_busy is active high
    );

    assign test_fifo_buffer_full = fifo_buffer_full;
    //encoder to encode which command to execute   
    wire buffer0_select_valid;
    wire buffer1_select_valid;
    
    assign test_buffer0_select_valid = buffer0_select_valid;
    assign test_buffer1_select_valid = buffer1_select_valid;
    
    assign buffer0_select_valid = |fifo_buffer_full[31:16];
    assign buffer1_select_valid = |fifo_buffer_full[15:0];
    
    always@(*)
    begin
        case (fifo_buffer_full[31:16]) 
            16'h0001 : buffer0_select = 0; 
            16'h0002 : buffer0_select = 1; 
            16'h0004 : buffer0_select = 2; 
            16'h0008 : buffer0_select = 3; 
            16'h0010 : buffer0_select = 4;
            16'h0020 : buffer0_select = 5; 
            16'h0040 : buffer0_select = 6; 
            16'h0080 : buffer0_select = 7; 
            16'h0100 : buffer0_select = 8;
            16'h0200 : buffer0_select = 9;
            16'h0400 : buffer0_select = 10; 
            16'h0800 : buffer0_select = 11; 
            16'h1000 : buffer0_select = 12; 
            16'h2000 : buffer0_select = 13; 
            16'h4000 : buffer0_select = 14; 
            16'h8000 : buffer0_select = 15; 
            default: buffer0_select = 0; 
        endcase
    end
    always@(*)
    begin
        case (fifo_buffer_full[15:0]) 
            16'h0001 : buffer1_select = 0; 
            16'h0002 : buffer1_select = 1; 
            16'h0004 : buffer1_select = 2; 
            16'h0008 : buffer1_select = 3; 
            16'h0010 : buffer1_select = 4;
            16'h0020 : buffer1_select = 5; 
            16'h0040 : buffer1_select = 6; 
            16'h0080 : buffer1_select = 7; 
            16'h0100 : buffer1_select = 8;
            16'h0200 : buffer1_select = 9;
            16'h0400 : buffer1_select = 10; 
            16'h0800 : buffer1_select = 11; 
            16'h1000 : buffer1_select = 12; 
            16'h2000 : buffer1_select = 13; 
            16'h4000 : buffer1_select = 14; 
            16'h8000 : buffer1_select = 15; 
            default: buffer1_select = 0; 
        endcase
    end
    //table to store address ranges currently operated on
    reg [86:0] locked_address_lookup [NUM_NEARPM_UNITS -1:0];

    //scheduler state machine
    reg [3:0] scheduler_state;
    reg [7:0] PMunit_status_reg;
    reg [7:0] DIMM_distribution;
    reg [2:0] command_idx_counter;
    
    reg [31:0] command_broadcast;
    //one valid for each PMunit
    reg [7:0] command_broadcast_valid;
    
    reg [19:0] oid_offset_lookup;
    reg oid_valid;
    
    wire [7:0] opcode0;
    wire [7:0] opcode1;
    reg opcode_has_vaddr;
    reg [NUM_NEARPM_UNITS - 1:0] PMunit_addr_translation_pending;
    reg scheduler_decode_stage;
    reg [1:0] nearpm_state;
    reg [3:0] nearpm_dependence;
    
   // reg [2:0] state_nearpm_go_ahead;
   // reg [NUM_NEARPM_UNITS - 1:0] nearpm_go_ahead;
    reg has_pending_nearpm_units;
    reg [NUM_NEARPM_UNITS - 1:0] dpendece_check;
    
    //to track undo log start address
   // reg [31:0] log_start_addr[(NUM_THREADS -1):0];
   // reg [31:0] current_log_addr;
    reg [15:0] log_size;
   
    reg [31:0] cmd_reg [4:0];
    reg [63:0] vaddr0;
    reg [63:0] vaddr1;
    
    reg [7:0] split_id;
    assign opcode0 = cmd_ordering_buffer0[0][buffer0_select][31:24];
    assign opcode1 = cmd_ordering_buffer1[0][buffer1_select][31:24];
    
    always @( posedge S_AXI_ACLK )
    begin
        if ( S_AXI_ARESETN == 1'b0 ) begin      
            reset_buffer0 <= 1'b0;
            reset_buffer1 <= 1'b0;  
            
            scheduler_state <= 4'd0;
            fifo_rd_en <= 1'b0;
            command_idx_counter <= 3'd0;
            command_broadcast <= 32'd0;
            command_broadcast_valid <= 8'b0;
            PMunit_status_reg <= 8'd0;
            DIMM_distribution <= 8'd0;
            
            oid_offset_lookup <= 19'd0;
            oid_valid <= 1'd0;
            
            PMunit_addr_translation_pending <= 32'd0;
            
            opcode_has_vaddr <= 1'b0;
        //    for ( i = 0; i <= NUM_NEARPM_UNITS -1; i = i + 1)
        //        locked_address_lookup[i] <= 87'd0;
                
         //   state_nearpm_go_ahead <= 3'd0;
        //    nearpm_go_ahead <= 32'd0;
            
    //        for( i = 0; i <= NUM_THREADS -1; i = i + 1)
    //            log_start_addr[i] = 32'hC0000000 + i*32'h04000000;
    //        current_log_addr <= 32'd0;
            log_size <= 16'd0;
            scheduler_decode_stage <= 1'b0;
            
            for( i = 0; i <= 4; i = i + 1)
                cmd_reg[i] <= 32'd0;
            
            vaddr0 <= 64'd0;
            vaddr1 <= 64'd0;
            
            split_id <= 8'd0;
            test_counter <= 32'd0;
            
        end
        else begin            
            command_broadcast <= 32'd0;
            reset_buffer0 <= 1'b0;
            reset_buffer1 <= 1'b0; 
            
            //State machine for assigning nearPM unit and start address translation
            case(scheduler_state)
            4'd0: begin                
                if(!fifo_empty) begin                                   
                    scheduler_state <= 4'd1; 
                    fifo_rd_en <= 1'b1;       
                    scheduler_decode_stage <= 1'b1;            
                end
            end
            4'd1: begin
                //read commands in the order they arrived
                fifo_rd_en <= 1'b0;
                scheduler_state <= 4'd2;
                command_idx_counter <= 3'd0;
                test_counter = test_counter + 1'd1;
            end 
            4'd2: begin
                if(buffer0_select_valid) begin
                    //format
                    // |PMuint id | Thread ID | Object ID | 
                    //PMunitt id from earlier implementation not needed for multi DIMM
                    oid_offset_lookup <= {8'd0, cmd_ordering_buffer0[command_idx_counter][buffer0_select][15:8], cmd_ordering_buffer0[command_idx_counter][buffer0_select][3:0]};
                    oid_valid <= 1'd1;
                    
                    vaddr0 <= {cmd_ordering_buffer0[1][buffer0_select],cmd_ordering_buffer0[2][buffer0_select]};
                    
                    cmd_reg[0] <= cmd_ordering_buffer0[0][buffer0_select];
                    //cmd_reg[1] <= cmd_ordering_buffer0[1][buffer0_select];
                    //cmd_reg[2] <= cmd_ordering_buffer0[2][buffer0_select];
                    cmd_reg[3] <= cmd_ordering_buffer0[3][buffer0_select];
                    cmd_reg[4] <= cmd_ordering_buffer0[4][buffer0_select];
                    scheduler_state <= 4'd3;
                end
                if(buffer1_select_valid) begin
                    oid_offset_lookup <= {8'd0, cmd_ordering_buffer1[command_idx_counter][buffer1_select][15:8], cmd_ordering_buffer1[command_idx_counter][buffer1_select][3:0]};
                    oid_valid <= 1'd1;        
                    
                    vaddr0 <= {cmd_ordering_buffer1[1][buffer1_select],cmd_ordering_buffer1[2][buffer1_select]};
                    
                    cmd_reg[0] <= cmd_ordering_buffer1[0][buffer1_select];
                    //cmd_reg[1] <= cmd_ordering_buffer1[1][buffer1_select];
                    //cmd_reg[2] <= cmd_ordering_buffer1[2][buffer1_select];
                    cmd_reg[3] <= cmd_ordering_buffer1[3][buffer1_select];
                    cmd_reg[4] <= cmd_ordering_buffer1[4][buffer1_select];     
                    scheduler_state <= 4'd3;   
                end                
                
            end    
            4'd3: begin
                oid_valid <= 1'd0;  
                //wait for address translation offset
                if(pmem_obj_offset_valid)  begin
                    //the physical address is stored in cmd_reg[1]
                    cmd_reg[1] <= vaddr0 - pmem_obj_offset[63:0];
                    log_size <= cmd_reg[3][31:16];
                    scheduler_state <= 4'd4;
                end            
            end
            4'd4:begin
                //check for command split requirement
                if((cmd_reg[1] + log_size) <= DIMM0_END_ADDR )
                    DIMM_distribution <= 8'b0000_0001;
                else if(DIMM0_END_ADDR  < cmd_reg[1])
                    DIMM_distribution <= 8'b0000_0010;
                else if(cmd_reg[1] <= DIMM0_END_ADDR < (cmd_reg[1] + log_size) )
                    DIMM_distribution <= 8'b0000_0011;
                    
                scheduler_state <= 4'd5;
                command_idx_counter <= 3'd0;
            end
            4'd5: begin                
                if (command_idx_counter == 3'd6) begin
                    scheduler_state <= 4'd6;                    
                    command_broadcast_valid <= 32'd0;
                    
                    if(buffer0_select_valid) reset_buffer0 <= 1'b1; 
                    if(buffer1_select_valid) reset_buffer1 <= 1'b1; 
                end
                else begin
                    command_idx_counter <= command_idx_counter + 3'd1;
                    if(command_idx_counter == 3'd5) begin
                        split_id <= split_id + 8'd1;
                        command_broadcast <=  {16'd0,split_id,DIMM_distribution};
                    end
                    else
                        command_broadcast <=  cmd_reg[command_idx_counter];
                    command_broadcast_valid <= DIMM_distribution;
                end
                
                
            end            
            //handle buffer resetting          
            default: 
                scheduler_state <= 4'd0;
            endcase   

        end
    end
    
    assign test_scheduler_state = scheduler_state;
 /*   
    //Combinatitonal logic to capture dependence
    //between scheduled and next in line commands
    wire [63:0] newcmd_addr;
    wire [15:0] newcmd_size;
    assign newcmd_addr = locked_address_lookup[pmem_obj_offset[71:64]][79:16] - pmem_obj_offset[63:0];
    assign newcmd_size = locked_address_lookup[pmem_obj_offset[71:64]][15:0];
    
    always@(*) begin   
        nearpm_state = 2'b01;
        nearpm_dependence = 4'd0;     
        for(i = 0; i < NUM_NEARPM_UNITS; i = i + 1)begin
            if(locked_address_lookup[i][86] && (locked_address_lookup[i][79:16] < (newcmd_addr + newcmd_size)) 
                        && (newcmd_addr < (locked_address_lookup[i][79:16] + locked_address_lookup[i][15:0]))) begin
                nearpm_state = nearpm_state | 2'b10;  
                nearpm_dependence[i] = 1'b1;  
            end         
            else begin           
                nearpm_state = nearpm_state | 2'b01;
                nearpm_dependence[i] = 1'b0; 
            end
        end
    end
    
    //Combinational logic to check if there are pending commands to get the go ahead
    always@(*) begin   
        has_pending_nearpm_units = 1'b0;
        for(i = 0; i < NUM_NEARPM_UNITS; i = i + 1)
            has_pending_nearpm_units = has_pending_nearpm_units | ((locked_address_lookup[i][86] == 1'b1) && (locked_address_lookup[i][81:80] != 2'b10));
    end
    

    //Combinational logic to check if dependent commands have completted execution    
    always@(*) begin
        dpendece_check = 4'd0;
        for(i = 0; i < NUM_NEARPM_UNITS; i = i + 1) begin
            for(j = 0; j < NUM_NEARPM_UNITS; j = j + 1)begin
                if(locked_address_lookup[i][82 + j] && locked_address_lookup[j][86])
                    dpendece_check[i] = dpendece_check[i] | 1'b1;
                else 
                    dpendece_check[i] = dpendece_check[i] | 1'b0;
            
            end
        
        end    
    end
    
    assign slall_mem_channel = scheduler_decode_stage | fifo_wr_en || ~fifo_empty || (|PMunit_addr_translation_pending) || stall_cmd;
    //Test
    assign testout00 = PMunit_status_reg;
    assign testout01 = cmd_ordering_buffer0[1][1];
    assign testout02 = cmd_ordering_buffer0[2][1];
    assign testout03 = cmd_ordering_buffer0[3][1];
    assign testout04 = cmd_ordering_buffer0[4][1];
    
    assign testout10 = cmd_ordering_buffer1[0][1];
    assign testout11 = cmd_ordering_buffer1[1][1];
    assign testout12 = cmd_ordering_buffer1[2][1];
    assign testout13 = cmd_ordering_buffer1[3][1];
    assign testout14 = cmd_ordering_buffer1[4][1];*/

    //End test support

    



	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        2'h0   : reg_data_out <= slv_reg0;
	        2'h1   : reg_data_out <= slv_reg1;
	        2'h2   : reg_data_out <= slv_reg2;
	        2'h3   : reg_data_out <= slv_reg3;
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	// Add user logic here

	// User logic ends
endmodule

