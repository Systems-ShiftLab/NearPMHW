`timescale 1ns / 1ps



module pmunit_controller_multidimm#(
     parameter integer  NUM_NEARPM_UNITS     = 4,
     parameter integer COMMAND_WORDS = 5)
    (
    input wire clk,
    input wire reset, //acive low
    input wire [31:0] COMMAND_BUS,
    input wire [31:0] CURRENT_LOG_ADDR,
    input wire COMMAND_VALID,
    input wire START_EXECUTION,
    input wire [63:0] ADDR_OFFSET,
    input wire ADDR_OFFSET_VALID,
    output reg PMUNIT_STATE,
    
    output reg DMA_START,
    output reg [31:0] DMA_SRC,
    output reg [31:0] DMA_DEST,
    output reg [31:0] DMA_LEN,
    input wire DMA_DONE
    );
    //registtter address offset
    reg [63:0] addr_offset_reg;
    reg addr_offset_valid_reg;
    reg start_execution_reg;
    
    always @( posedge clk )
    begin
        if ( reset == 1'b0 )
        begin
            addr_offset_reg <= 64'd0;
            addr_offset_valid_reg <= 1'd0;
            start_execution_reg <= 1'd0;
        end
        else begin
            if(ADDR_OFFSET_VALID) begin
                addr_offset_reg <= ADDR_OFFSET;
                addr_offset_valid_reg <= 1'b1;
            end
            
            if(START_EXECUTION)
                start_execution_reg <= 1'd1;
                
            if(DMA_DONE) begin
                addr_offset_valid_reg <= 1'b0;
                start_execution_reg <= 1'd0;
            end
        end        
    end
    
    
    //execution state machine
    reg [3:0] execution_state;
    reg [31:0] instruction [COMMAND_WORDS:0];
    reg [2:0] packet_counter;
    
    
    integer i;
    
    //decoding all operands for ease of  use
    
    wire [159:0]    full_command;
    reg  [63:0]     src_phy_addr;
    wire [63:0]     src_addr;
    wire [15:0]     data_size;
    wire [31:0]     undolog_addr;
    reg  [31:0]      secondary_addr;
    
    
    assign full_command     = {instruction[0],instruction[1], instruction[2] ,instruction[3], instruction[4]};
    assign src_addr         = full_command[127:64];
    assign data_size        = full_command[63:48];
    
    always @( posedge clk )
    begin
        if ( reset == 1'b0 )
        begin
            execution_state <= 4'd0;
            PMUNIT_STATE <= 1'b0;     
            for(i=0; i<=COMMAND_WORDS; i=i+1) 
                instruction[i] <= 32'd0;    
            packet_counter <= 3'd0;  
            src_phy_addr  <= 32'd0;
            DMA_START <=1'b0;
            DMA_SRC <= 32'd0;
            DMA_DEST <= 32'd0;
            secondary_addr <= 32'd0;
            DMA_LEN <= 32'd0;
        end 
        else
        begin    
            //execution statte machine
            PMUNIT_STATE <= 1'b0;
            case(execution_state)
                4'd0:begin
                    if(COMMAND_VALID) begin
                        instruction[0] <= COMMAND_BUS;  
                        secondary_addr <= CURRENT_LOG_ADDR;                       
                        packet_counter <= 3'd1;  
                        execution_state <= 4'd1;                        
                    end                
                end
                4'd1:begin
                    if(COMMAND_VALID) begin
                        instruction[packet_counter] <= COMMAND_BUS;
                        packet_counter <= packet_counter + 1;
                    end
                    else
                        execution_state <= 4'd2;
                    
                end
                4'd2:begin //address translate
                  //  if(addr_offset_valid_reg)begin
                        src_phy_addr <= instruction[1];
                        execution_state <= 4'd3;
                 //   end
                end
                4'd3:begin
                    if(start_execution_reg) begin
                        case(full_command[159:152])
                            //8'd0:
                            8'd2:begin
                                DMA_START <=1'b1;
                                DMA_SRC <= src_phy_addr;
                                DMA_DEST <= secondary_addr;
                                DMA_LEN <= {16'd0, data_size};
                                execution_state <= 4'd4;
                            end                            
                        endcase
                    end
                end
                4'd4:begin //wait for operattion to complete
                    DMA_START <=1'b0;
                    if(DMA_DONE)begin
                        
                        PMUNIT_STATE <= 1'b1;
                        execution_state <= 4'd0;
                    end
                end
                    
            endcase     
        end       
    end
endmodule
