`timescale 1ns / 1ps

module split_com_arbitter#(
parameter integer NUM_DIMMS = 2

)(
    input clk,
    input aresetn,
    input wire [19:0] complete_split_in0,
    input wire pending_complete_split_in0,
    output wire read_complete_split0,
    input wire [19:0] complete_split_in1,
    input wire pending_complete_split_in1,
    output wire read_complete_split1,
    output reg [11:0] complete_split_cmd,
    output reg [NUM_DIMMS-1:0] complete_split_cmd_valid 
    );
    
    wire [19:0] complete_split[NUM_DIMMS-1:0];
    wire [NUM_DIMMS-1:0] pending_complete_split;
    reg [NUM_DIMMS-1:0] read_complete_split;
    
    assign complete_split[0] = complete_split_in0;
    assign complete_split[1] = complete_split_in1;
    
    assign pending_complete_split[0] = pending_complete_split_in0;
    assign pending_complete_split[1] = pending_complete_split_in1;
    
    assign read_complete_split0 = read_complete_split[0]; 
    assign read_complete_split1 = read_complete_split[1]; 
    
    reg [3:0] counter;
    reg [3:0] state;
    
    integer i;
    always @( posedge clk )
    begin
        if ( aresetn == 1'b0 ) begin  
              //  for ( i = 0; i < NUM_NEARPM_UNITS ; i = i + 1)
            complete_split_cmd <= 12'd0;
            complete_split_cmd_valid <= 1'b0;
            counter <= 4'd0;
            state <= 4'd0;
            for ( i = 0; i < NUM_DIMMS ; i = i + 1)
                read_complete_split[i] <= 1'b0; 
        end
        else begin
            //counter <= counter + 4'd1;
            //if(counter == NUM_DIMMS-1)
            //    counter <= 4'd0;
            //state machine to read and broadcast
            case(state)
            4'd0:begin
                complete_split_cmd_valid <= 32'd0;  
                if(pending_complete_split[counter])
                    state <= 4'd1;
                else begin
                    counter <= counter +4'd1;
                    if(counter == NUM_DIMMS-1)
                        counter <= 4'd0;
                end  
            end
            4'd1: begin
                state <= 4'd2;  
                read_complete_split[counter] <= 1'b1;         
            end
            4'd2: begin
                state <= 4'd3;  
                read_complete_split[counter] <= 1'b0;         
            end
            4'd3: begin
                state <= 4'd0;  
                complete_split_cmd <= complete_split[counter][19:8];    
                complete_split_cmd_valid <= complete_split[counter][7:0];  
            end          
           
            endcase
            
             
        end
    end
    
endmodule
