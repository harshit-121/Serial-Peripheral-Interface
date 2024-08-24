`timescale 1ns / 1ps
module spi(
    input clk, start,
    input [11:0] din,
    output [11:0] dout,
    output done
    );
    
    wire sclk, cs, mosi;
    
  spi_master master(clk, start, din, sclk, cs, mosi);
    spi_slave slave(sclk, cs, mosi, dout, done);
endmodule

module spi_master(
    input clk, start,
    input [11:0] din,
    output sclk,
    output reg cs,mosi
    );
    
    reg sclkt = 0;
    integer count = 0;
    always@(posedge clk)begin
        if (count < 10)
            count <= count +1;
        else begin
            count <= 0;
            sclkt = ~sclkt;
        end
    end
    
    parameter idle = 0, start_tx = 1, send = 2, end_tx = 3; 
    reg [1:0] state = idle;
    reg [11:0] temp_m;
    integer bitcount = 0;
     
    always@(posedge sclkt)
    begin
                case(state)
                idle: begin
                   mosi <= 1'b0;
                   cs   <= 1'b1;
                   //done <= 1'b0;
                   
                   if(start)
                     state <= start_tx;
                   else
                     state <= idle;
                end
                
                
                start_tx : begin
                  cs    <= 1'b0;
                  temp_m  <= din; 
                  state <= send; 
                end
                
                send : 
                begin
                   if(bitcount <= 11) 
                   begin
                     bitcount <= bitcount + 1;
                     mosi     <= temp_m[bitcount];
                     state    <= send;
                   end
                   else
                    begin
                    bitcount <= 0;
                    state    <= end_tx;
                    mosi     <= 1'b0; 
                    end
                end
                
                end_tx : begin
                   cs    <= 1'b1;
                   state <= idle;
                   //done  <= 1'b1;
                end
                
                default : state <= idle;
                endcase
    end
     
     
    assign sclk = sclkt;
 
endmodule

module spi_slave(
    input sclk, cs, mosi,
    output [11:0] dout,
    output reg done
    );
    
  	parameter detect = 0 , read_data = 1;
  //typedef enum bit {detect_start = 1'b0, read_data = 1'b1} state_type;
    reg state = detect;
    
    reg [11:0] temp_s = 12'h000;
    integer count = 0;
    
    always@(posedge sclk)
    begin
      case(state)
            detect:
            begin
                done <= 1'b0;
                if(cs == 1'b0)
                    state <= read_data;
                else
                    state <= detect;     
            end
            ////////////////
            read_data:
            begin
                if(count <= 11)
                begin
                    count <= count + 1;
                    temp_s <= {mosi, temp_s[11:1]}; 
                end
                else
                begin
                    count <= 0;
                    done <= 1'b1;
                    state <= detect;
                end
            end
        default: state <= detect;
        endcase
    end
    
    assign dout = temp_s;
endmodule
