`timescale 1ns / 1ps
module spi_tb();
 
 reg clk = 0;
 reg start = 0;
 reg [11:0] din;
 wire cs, mosi, done, sclk;
   
 spi dut (.clk(clk), .start(start), .din(din), .cs(cs), .mosi(mosi), .done(done), .sclk(sclk));
 integer i = 0;
 
 initial 
 begin
     start = 1;
     for(i = 0; i < 10; i = i + 1) begin
         din = $urandom_range(10 , 200);
         @(negedge done);
     end
     $stop; 
 end
 
 always #5 clk = ~clk;
 
endmodule
