`timescale 1ns / 1ps
module dimm_scheduler#(

		parameter integer C_S_AXI_DATA_WIDTH	= 32,

		parameter integer C_S_AXI_ADDR_WIDTH	= 4,
		parameter integer  NUM_NEARPM_UNITS     = 4,
		parameter integer NUM_THREADS = 16,
		parameter integer DIMM_ID = 0,
		parameter integer DIMM_SIZE = 32'h2000_0000,
		parameter integer DIMM_BASE_ADDR = 32'h8000_0000,
		parameter integer NUM_DIMMS = 2
	)
	(
		
		input clk,		
		input aresetn,
		output [31:0] command_broadcast,
        output [NUM_NEARPM_UNITS-1:0] command_broadcast_valid,
      //  output [19:0] oid_offset_lookup,
      //  output oid_valid,
        //input [71:0] pmem_obj_offset,
      //  input pmem_obj_offset_valid, 
        input [NUM_NEARPM_UNITS -1 :0] nearpmunit_done,
        output [NUM_NEARPM_UNITS - 1:0] nearpm_go_ahead,
        output [31:0] current_log_addr,
		
		output wire slall_mem_channel,
		input [31:0] command_in,
        input command_valid,
        input [11:0] complete_split_cmd_idx_in,
        input complete_split_cmd_idx_valid_in,
        output wire [19:0] complete_split_out,
        output wire pending_complete_split_out,
        input wire read_complete_split,
        input wire awvalid,
        input wire [31:0] awaddr,
		////testing interfaces
		output wire [7:0] test_nearrPM_status,
		output wire [4:0] test_scheduler_state

	);

       
       wire    fifo_full;
       reg    fifo_wr_en;
       reg     fifo_rd_en;
       wire    fifo_empty;
       wire    fifo_data_valid;
       wire [191:0] fifo_data_in;
       wire [191:0] fifo_data_out;
       
      
       //wire fifo_rd_rst_busy;
       //wire fifo_wr_rst_busy;
       
       reg [31:0] cmd_reg [5:0];
       wire [31:0] cmd_out [5:0];
       reg [4:0] command_counter;
       integer i;
       reg reciveing_cmd;
       
       
       assign fifo_data_in = {cmd_reg[0],cmd_reg[1],cmd_reg[2],cmd_reg[3],cmd_reg[4],cmd_reg[5]};
       assign {cmd_out[0],cmd_out[1],cmd_out[2],cmd_out[3],cmd_out[4],cmd_out[5]} = fifo_data_out;
       always @( posedge clk )
       begin
           if ( aresetn == 1'b0 ) begin
                for ( i = 0; i < 6 ; i = i + 1)
                    cmd_reg[i] <= 32'd0; 
                command_counter <= 5'd0;
                fifo_wr_en <= 1'b0;
                reciveing_cmd <= 1'b0;
           end
           else begin
                if(command_valid) begin
                    cmd_reg[command_counter] <= command_in;
                    command_counter <= command_counter + 5'd1;
                    reciveing_cmd <= 1'b1;
                end
                else begin
                    command_counter <= 5'd0;
                    reciveing_cmd <= 1'b0;
                end
                    
                if(command_counter == 5'd5)
                    fifo_wr_en <= 1'b1;
                else
                    fifo_wr_en <= 1'b0;
           end
       end
       
       //only write when a new command is recieved
       
       xpm_fifo_sync #(
           .DOUT_RESET_VALUE("0"),    // String
           .ECC_MODE("no_ecc"),       // String
           .FIFO_MEMORY_TYPE("auto"), // String
           .FIFO_READ_LATENCY(1),     // DECIMAL
           .FIFO_WRITE_DEPTH(16),   // DECIMAL
           .FULL_RESET_VALUE(0),      // DECIMAL
           .PROG_EMPTY_THRESH(10),    // DECIMAL
           .PROG_FULL_THRESH(10),     // DECIMAL
           .RD_DATA_COUNT_WIDTH(1),   // DECIMAL
           .READ_DATA_WIDTH(192),      // DECIMAL
           .READ_MODE("std"),         // String
           .USE_ADV_FEATURES("0707"), // String
           .WAKEUP_TIME(0),           // DECIMAL
           .WRITE_DATA_WIDTH(192),     // DECIMAL
           .WR_DATA_COUNT_WIDTH(1)    // DECIMAL
       )
       ordering_fifo (    
           .data_valid(fifo_data_valid),       // 1-bit output: Read Data Valid: When asserted, this signal indicates
                                            // that valid data is available on the output bus (dout).    
           .dout(fifo_data_out),                   // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
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
           .din(fifo_data_in),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
                                            // writing the FIFO.    
           .rd_en(fifo_rd_en),                 // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
                                            // signal causes data (on dout) to be read from the FIFO. Must be held
                                            // active-low when rd_rst_busy is active high. .    
           .rst(~aresetn),                     // 1-bit input: Reset: Must be synchronous to wr_clk. Must be applied only
                                            // when wr_clk is stable and free-running.    
           .wr_clk(clk),               // 1-bit input: Write clock: Used for write operation. wr_clk must be a
                                           // free running clock.    
           .wr_en(fifo_wr_en)                  // 1-bit input: Write Enable: If the FIFO is not full, asserting this
                                            // signal causes data (on din) to be written to the FIFO Must be held
                                            // active-low when rst or wr_rst_busy or rd_rst_busy is active high
       );
    reg [102:0] locked_address_lookup [NUM_NEARPM_UNITS -1:0];

    //scheduler state machine
    reg [3:0] scheduler_state;
    reg [7:0] PMunit_status_reg;
    reg [7:0] assigned_PMunit_id;
    reg [2:0] command_idx_counter;
    
    reg [31:0] command_broadcast;
    //one valid for each PMunit
    reg [7:0] command_broadcast_valid;
    
    
    reg [31:0] log_start_addr[(NUM_THREADS -1):0];
    
    wire [7:0] opcode;
    reg opcode_has_addr;
    
    reg scheduler_decode_stage;
    reg [1:0] nearpm_state;
    reg [3:0] nearpm_dependence;
    
    reg [2:0] state_nearpm_go_ahead;
    reg [NUM_NEARPM_UNITS - 1:0] nearpm_go_ahead;
    reg has_pending_nearpm_units;
    reg [NUM_NEARPM_UNITS - 1:0] dpendece_check;
    

    reg [31:0] current_log_addr;
    reg [15:0] log_size;
   
    integer j;
    assign opcode = fifo_data_out[191:184];
    
    reg [7:0] nearpm_completeion_status [NUM_NEARPM_UNITS - 1:0];
    reg [20:0] completed_cmd[NUM_NEARPM_UNITS - 1:0];
    
    reg [12:0] split_idx_store [15:0];
    reg has_no_split_match;
    reg [4:0] next_split_idx_store;
    wire [15:0] split_idx_store_status;
    
    always @( posedge clk )
    begin
        if ( aresetn == 1'b0 ) begin      
            
            scheduler_state <= 4'd0;
            fifo_rd_en <= 1'b0;
            command_idx_counter <= 3'd0;
            command_broadcast <= 32'd0;
            command_broadcast_valid <= 8'b0;
            PMunit_status_reg <= 8'd0;
            assigned_PMunit_id <= 8'd0;

            for ( i = 0; i <= NUM_NEARPM_UNITS -1; i = i + 1)begin
                locked_address_lookup[i] <= 103'd0;
                nearpm_completeion_status[i] <= 8'd0;
                completed_cmd[i] <= 21'd0;
            end
                
            state_nearpm_go_ahead <= 3'd0;
            nearpm_go_ahead <= 32'd0;
            
            for( i = 0; i <= NUM_THREADS -1; i = i + 1)
                log_start_addr[i] = 32'hC0000000 + i*32'h04000000;
            current_log_addr <= 32'd0;
            log_size <= 16'd0;
            scheduler_decode_stage <= 1'b0;
            opcode_has_addr <= 1'b0;
            
            for( i = 0; i < 16; i = i + 1)
                split_idx_store[i] <= 13'd0;
                
            
        end
        else begin            
            command_broadcast <= 32'd0;
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
            end         
            4'd2:begin
                //decision on where to execute command NearPM unit or scheduler
                if(opcode == 8'd3)
                    scheduler_state <= 4'd7;
                else
                    scheduler_state <= 4'd3;
            end   
            4'd3: begin                                  
                 //assign a NearPM unit
                 casez (PMunit_status_reg)
                    8'b???????0:begin
                        PMunit_status_reg <= 8'b00000001 | PMunit_status_reg;
                        assigned_PMunit_id <= 8'd0;
                        scheduler_state <= 4'd4;
                    end   
                    8'b??????0?:begin
                        PMunit_status_reg <= 8'b00000010 | PMunit_status_reg;
                        assigned_PMunit_id <= 8'd1;
                        scheduler_state <= 4'd4;
                    end
              /*      8'b?????0??:begin
                        PMunit_status_reg <= 8'b00000100 | PMunit_status_reg;
                        assigned_PMunit_id <= 8'd2;
                        scheduler_state <= 4'd4;
                    end
                    8'b????0???:begin
                        PMunit_status_reg <= 8'b00001000 | PMunit_status_reg;
                        assigned_PMunit_id <= 8'd3;
                        scheduler_state <= 4'd4;
                    end */
                 /*          8'bxxx0_xxxx: ndp_start[4] = 8'b00010000;
                           8'bxx0x_xxxx: ndp_start[5] = 8'b00100000;
                           8'bx0xx_xxxx: ndp_start[6] = 8'b01000000;
                           8'b0xxx_xxxx: ndp_start[7] = 8'b10000000;
                */         
                 //   default :PMunit_status_reg  <= 8'd0;
                endcase             
                command_idx_counter <= 3'd0;  
      
            end
            4'd4: begin                
                if (command_idx_counter == 3'd5) scheduler_state <= 4'd5;
                else command_idx_counter <= command_idx_counter + 3'd1;
                
                command_broadcast_valid[assigned_PMunit_id] <= 1'b1;
                //Adjust start address and size covoered by nearpm unit
                if(command_idx_counter == 3'd1) begin
                    if((DIMM_BASE_ADDR <= cmd_out[1])) 
                        command_broadcast <= cmd_out[1];
                    else 
                        command_broadcast <= DIMM_BASE_ADDR;
                end  
                
                if(command_idx_counter == 3'd3) begin
                    if((cmd_out[1] + cmd_out[3][31:16]) < (DIMM_BASE_ADDR + DIMM_SIZE))
                        command_broadcast <= cmd_out[3];
                    else begin
                        if((DIMM_BASE_ADDR <= cmd_out[1])) 
                            command_broadcast <= { DIMM_BASE_ADDR - cmd_out[1],16'd0};
                        else
                            command_broadcast <= { DIMM_BASE_ADDR - DIMM_BASE_ADDR,16'd0};
                    end
                end
                else    
                    command_broadcast <= cmd_out[command_idx_counter];
                    
                current_log_addr <= log_start_addr[cmd_out[0][15:8]];
            end
            4'd5: begin       
                //initialize state for dependence handling
                locked_address_lookup[assigned_PMunit_id][79:48] <= 32'd0;//cmd_out[command_idx_counter];
                locked_address_lookup[assigned_PMunit_id][47:16] <= cmd_out[1];
                locked_address_lookup[assigned_PMunit_id][15:0] <= cmd_out[3][31:16];  
                locked_address_lookup[assigned_PMunit_id][86] <= 1'b1;   
                locked_address_lookup[assigned_PMunit_id][102:87] <= cmd_out[5][15:0];   
                //storing dependence information                               
                locked_address_lookup[assigned_PMunit_id][81:80] <= nearpm_state;
                locked_address_lookup[assigned_PMunit_id][85:82] <= nearpm_dependence;
                log_size <= cmd_out[3][31:16];
                scheduler_state <= 4'd6;
                
            end
            4'd6: begin
                scheduler_decode_stage <= 1'b0;
                scheduler_state <= 4'd0;
                command_broadcast_valid[assigned_PMunit_id] <= 1'b0;    
                //now we can reset buffers to recieve more commands
                //set next undolog addresses
                log_start_addr[cmd_out[0][15:8]] <= 
                        current_log_addr + {16'd0,log_size};
            end
            4'd7:begin
                scheduler_decode_stage <= 1'b0;
                scheduler_state <= 4'd0;  
                log_start_addr[cmd_out[0][15:8]] <= 32'hC0000000 + cmd_out[0][15:8]*32'h04000000;          
            end
            default: 
                scheduler_state <= 4'd0;
            endcase   
           
            
            //Store translated address and information to track depencencies
            // locked address holds sevaral data components about the scheduled command
            // |valid|dependent nearpm units|execuion state|physical address|size|
            //dependent nearpm units: ex 4'b0101 -> this entry has an dependency to nearpm 0 and nearpm 2
            //execution state 1'b00: not assigned 1'b01: no dependecy -> can execuet 1'b10: executing 1'b11: has dependency
         /*   if(pmem_obj_offset_valid)  begin
                    //indicate that the address translation is valid
                locked_address_lookup[pmem_obj_offset[71:64]][86] <= 1'b1;   
                //storing dependence information                               
                locked_address_lookup[pmem_obj_offset[71:64]][81:80] <= nearpm_state;
                locked_address_lookup[pmem_obj_offset[71:64]][85:82] <= nearpm_dependence;
                PMunit_addr_translation_pending[pmem_obj_offset[71:64]] <= 1'b0;         
            end
         */   
            //go ahead state machine
            //checks for dependency inbetween executing commands and the next in line commands
            // if no dependecy will execute
            // if there is a depence will wait for the dependent commands to complete
            nearpm_go_ahead <= 32'd0;
            case(state_nearpm_go_ahead)
                3'd0: begin
                    if(has_pending_nearpm_units) 
                        state_nearpm_go_ahead <= 3'd1;               
                end
                //give go ahead to independent nearpms
                3'd1: begin
                    for(i = 0; i < NUM_NEARPM_UNITS; i = i + 1) begin
                        if((locked_address_lookup[i][86] == 1'b1) && (locked_address_lookup[i][81:80] == 2'b01)) begin
                            nearpm_go_ahead[i] <= 1'b1;
                            locked_address_lookup[i][81:80] <= 2'b10;
                        end
                    end
                    state_nearpm_go_ahead <= 3'd2; 
                end  
                //handle dependent nearpms 
                3'd2: begin
                    for(i = 0; i < NUM_NEARPM_UNITS; i = i + 1) begin
                        if((locked_address_lookup[i][86] == 1'b1) && (locked_address_lookup[i][81:80] == 2'b11)) begin
                            if(!dpendece_check[i]) begin
                                nearpm_go_ahead[i] <= 1'b1;
                                locked_address_lookup[i][81:80] <= 2'b10;
                            end
                        end
                    end
                    state_nearpm_go_ahead <= 3'd0; 
                end             
            endcase
            
          
            //Handling completed nearpmunits
            for(i = 0; i < NUM_NEARPM_UNITS; i = i + 1) begin
                 completed_cmd[i] <= 21'd0;
                if(nearpmunit_done[i]) begin
                    //locked_address_lookup[i][86] <= 1'b0;
                    completed_cmd[i][19:0] <= {DIMM_ID, locked_address_lookup[i][102:87]};
                    completed_cmd[i][20] <= 1'b1;
                end     
            end 
            //register all completed split commands
            if(complete_split_cmd_idx_valid_in) begin
                for(i = 0; i < NUM_NEARPM_UNITS; i = i + 1) begin 
                    if((locked_address_lookup[i][81:80] == 2'b10) &&(locked_address_lookup[i][86] == 1'b1) &&
                            complete_split_cmd_idx_in[7:0] == locked_address_lookup[i][102:95]) begin        
                        nearpm_completeion_status[i][complete_split_cmd_idx_in[11:8]] <= 1'b1;
                    end                   
                end                    
                
                if(has_no_split_match)                 
                    split_idx_store[next_split_idx_store] <= {1'b1,complete_split_cmd_idx_in};
            end
            
            if(|split_idx_store_status) begin
                for(j = 0; j < 16; j = j + 1) begin
                    for(i = 0; i < NUM_NEARPM_UNITS; i = i + 1)begin
                        if((locked_address_lookup[i][81:80] == 2'b10) &&(locked_address_lookup[i][86] == 1'b1) &&
                                        split_idx_store[j][7:0] == locked_address_lookup[i][102:95] &&
                                        split_idx_store[j][8]) begin        
                            nearpm_completeion_status[i][split_idx_store[j][11:8]] <= 1'b1;
                            split_idx_store[j] <= 13'd0;
                         end                   
                    end          
                end     
            end
                
            
            //Handling completed nearpmunits
            for(i = 0; i < NUM_NEARPM_UNITS; i = i + 1) begin
                if((locked_address_lookup[i][81:80] == 2'b10) &&(locked_address_lookup[i][86] == 1'b1) &&
                    (nearpm_completeion_status[i] == locked_address_lookup[i][94:87])) begin
                    locked_address_lookup[i][86] <= 1'b0;
                    PMunit_status_reg[i] <= 1'b0;
                    nearpm_completeion_status[i] <= 8'd0;
                    for(j = 0; j < NUM_NEARPM_UNITS; j = j + 1)
                        locked_address_lookup[j][82 + i] <= 1'b0;
                end     
            end
            
        end
    end
    
    wire [15:0] tmp;
    assign tmp = locked_address_lookup[1][102:87];
    //Combinatitonal logic to check dependence
    //between scheduled and next in line commands
    wire [63:0] newcmd_addr;
    wire [15:0] newcmd_size;
    assign newcmd_addr = cmd_out[1];//locked_address_lookup[pmem_obj_offset[71:64]][79:16] - pmem_obj_offset[63:0];
    assign newcmd_size = cmd_out[3][31:16];//locked_address_lookup[pmem_obj_offset[71:64]][15:0];
    
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
    
    //check dependece between executing NearPM and incomming writes
    reg has_write_dependence;
    //awvalid,
    //awaddr,
    always@(*) begin   
        has_write_dependence = 1'b0;
        for(i = 0; i < NUM_NEARPM_UNITS; i = i + 1)begin
            if(awvalid && locked_address_lookup[i][86] && 
            (locked_address_lookup[i][79:16] <= awaddr  < (locked_address_lookup[i][79:16] + locked_address_lookup[i][15:0]))) begin
                has_write_dependence = has_write_dependence | 1'b1;  
            end         
            else begin           
                has_write_dependence = has_write_dependence | 1'b0;
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
    
    assign slall_mem_channel = scheduler_decode_stage || fifo_wr_en || ~fifo_empty || reciveing_cmd | has_write_dependence;
    //Test
    assign test_nearrPM_status = PMunit_status_reg;
    assign test_scheduler_state = scheduler_state;
    //////
  
    wire    done_fifo_full;
    wire    done_fifo_wr_en;
    reg     done_fifo_rd_en;
    wire    done_fifo_empty;
    wire    done_fifo_data_valid;
    wire [21*NUM_NEARPM_UNITS-1:0] done_fifo_data_in;
    wire [21*NUM_NEARPM_UNITS-1:0] done_fifo_data_out;
    reg  [3:0] state;
    assign done_fifo_data_in = {completed_cmd[3],completed_cmd[2],completed_cmd[1],completed_cmd[0]};
    assign done_fifo_wr_en = |{completed_cmd[3][20],completed_cmd[2][20],completed_cmd[1][20],completed_cmd[0][20]};
    
    reg [20:0] completed_cmd_out[NUM_NEARPM_UNITS - 1:0];
    
    
    reg [19 :0] bus_fifo_data_in;
    reg    bus_fifo_wr_en;
    reg [3:0] counter;
    always @( posedge clk )
    begin
        if ( aresetn == 1'b0 ) begin
            //for ( i = 0; i < 6 ; i = i + 1)
            done_fifo_rd_en <=1'b0;
            state <= 3'd0;
            bus_fifo_data_in <= 21'd0;
            bus_fifo_wr_en <= 1'b0;
            counter <= 4'd0;
            
            for ( i = 0; i < NUM_NEARPM_UNITS ; i = i + 1)
                completed_cmd_out[i] <= 21'd0;
        end
        else begin
            case(state)
            3'd0: begin         
                  
                if(!done_fifo_empty) begin
                    state <= 3'd1;
                    done_fifo_rd_en <= 1'b1;
                end
            end
            3'd1: begin
                state <= 3'd2;
                done_fifo_rd_en <= 1'b0;
            end
            3'd2: begin
                state <= 3'd3; 
                counter <= 4'd0;   
                {completed_cmd_out[3],completed_cmd_out[2],completed_cmd_out[1],completed_cmd_out[0]} 
                                        =  done_fifo_data_out;
            end
            3'd3: begin
                if(counter == 4'd4)begin
                    state <= 3'd0;
                    bus_fifo_wr_en <= 1'b0;
                end
                else begin
                    counter <= counter + 4'd1;
                    bus_fifo_wr_en <= 1'b0;
                    
                    if(completed_cmd_out[counter][20]) begin
                        bus_fifo_wr_en <= 1'b1;
                        bus_fifo_data_in <= completed_cmd_out[counter][19:0];
                    end
                end
            end
            endcase
        end
    end
    xpm_fifo_sync #(
        .DOUT_RESET_VALUE("0"),    // String
        .ECC_MODE("no_ecc"),       // String
        .FIFO_MEMORY_TYPE("auto"), // String
        .FIFO_READ_LATENCY(1),     // DECIMAL
        .FIFO_WRITE_DEPTH(16),   // DECIMAL
        .FULL_RESET_VALUE(0),      // DECIMAL
        .PROG_EMPTY_THRESH(10),    // DECIMAL
        .PROG_FULL_THRESH(10),     // DECIMAL
        .RD_DATA_COUNT_WIDTH(1),   // DECIMAL
        .READ_DATA_WIDTH(84),      // DECIMAL
        .READ_MODE("std"),         // String
        .USE_ADV_FEATURES("0707"), // String
        .WAKEUP_TIME(0),           // DECIMAL
        .WRITE_DATA_WIDTH(84),     // DECIMAL
        .WR_DATA_COUNT_WIDTH(1)    // DECIMAL
    )
    done_fifo (    
        .data_valid(done_fifo_data_valid),       
        .dout(done_fifo_data_out),                  
        .empty(done_fifo_empty),                 
        .full(done_fifo_full),                   
        .din(done_fifo_data_in),                    
        .rd_en(done_fifo_rd_en),                 
        .rst(~aresetn),                
        .wr_clk(clk),           
        .wr_en(done_fifo_wr_en)             
   );
   
    wire    bus_fifo_full;
    wire     bus_fifo_rd_en;
    wire    bus_fifo_empty;
    wire    bus_fifo_data_valid;
    
    wire [19 :0] bus_fifo_data_out;
  
   
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
        .READ_DATA_WIDTH(20),      // DECIMAL
        .READ_MODE("std"),         // String
        .USE_ADV_FEATURES("0707"), // String
        .WAKEUP_TIME(0),           // DECIMAL
        .WRITE_DATA_WIDTH(20),     // DECIMAL
        .WR_DATA_COUNT_WIDTH(1)    // DECIMAL
    )
    bus_fifo (    
        .data_valid(bus_fifo_data_valid),       
        .dout(bus_fifo_data_out),                  
        .empty(bus_fifo_empty),                 
        .full(bus_fifo_full),                   
        .din(bus_fifo_data_in),                    
        .rd_en(bus_fifo_rd_en),                 
        .rst(~aresetn),                
        .wr_clk(clk),           
        .wr_en(bus_fifo_wr_en)             
   );
   
   assign complete_split_out = bus_fifo_data_out;
   assign pending_complete_split_out = ~bus_fifo_empty;
   assign bus_fifo_rd_en = read_complete_split;
   
   
   
   
   always@(*) begin        
        if(complete_split_cmd_idx_valid_in) begin
            has_no_split_match = 1'b1;
            for(i = 0; i < NUM_NEARPM_UNITS; i = i + 1) begin
                if((locked_address_lookup[i][81:80] == 2'b10) &&(locked_address_lookup[i][86] == 1'b1) &&
                                            complete_split_cmd_idx_in[7:0] == locked_address_lookup[i][102:95])
                    has_no_split_match = 1'b0;
                else
                    has_no_split_match = has_no_split_match & 1'b1;
            end   
        end
        else
            has_no_split_match = 1'b0;
   end
   
   
   
   
   assign split_idx_store_status = {split_idx_store[15][12],
                                    split_idx_store[14][12],
                                    split_idx_store[13][12],
                                    split_idx_store[12][12],
                                    split_idx_store[11][12],
                                    split_idx_store[10][12],
                                    split_idx_store[9][12],
                                    split_idx_store[8][12],
                                    split_idx_store[7][12],
                                    split_idx_store[6][12],
                                    split_idx_store[5][12],
                                    split_idx_store[4][12],
                                    split_idx_store[3][12],
                                    split_idx_store[2][12],
                                    split_idx_store[1][12],
                                    split_idx_store[0][12]};
                                    
   always@(*) begin
    casez(split_idx_store_status)
        16'b????_????_????_???0: next_split_idx_store = 4'd0;
        16'b????_????_????_??0?: next_split_idx_store = 4'd1;
        16'b????_????_????_?0??: next_split_idx_store = 4'd2;
        16'b????_????_????_0???: next_split_idx_store = 4'd3;
        16'b????_????_???0_????: next_split_idx_store = 4'd4;
        16'b????_????_??0?_????: next_split_idx_store = 4'd5;
        16'b????_????_?0??_????: next_split_idx_store = 4'd6;
        16'b????_????_0???_????: next_split_idx_store = 4'd7;
        16'b????_???0_????_????: next_split_idx_store = 4'd8;
        16'b????_??0?_????_????: next_split_idx_store = 4'd9;
        16'b????_?0??_????_????: next_split_idx_store = 4'd10;
        16'b????_0???_????_????: next_split_idx_store = 4'd11;
        16'b???0_????_????_????: next_split_idx_store = 4'd12;
        16'b??0?_????_????_????: next_split_idx_store = 4'd13;
        16'b?0??_????_????_????: next_split_idx_store = 4'd14;
        16'b0???_????_????_????: next_split_idx_store = 4'd15;    
        default: next_split_idx_store = 4'd0;
    endcase
   end
   
endmodule
