`timescale 1ns / 1ps
module tb_spi;
    reg clk = 0;
    reg start = 0;
    reg [11:0] din = 0;
    wire [11:0] dout;
    wire done;
    integer i=0;

    // Clock generation: 50 MHz clock
    always #10 clk = ~clk;

    // Instantiate the SPI module
    spi dut(clk, start, din, dout, done);

    initial begin
        // Optional: Reset sequence if reset is added to SPI module
        // rst = 1;
        // repeat(5) @(posedge clk);
        // rst = 0;

        // Test sequence
        for (i = 0; i < 10; i = i + 1) begin
            din = $urandom & 12'hFFF; // 12-bit random value
            start = 1;
            @(posedge dut.sclk);      // Hold start for one clock cycle
            start = 0;
            @(negedge done);           // Wait until the transaction is done
            //@(posedge clk);           // Wait a clock cycle before next start
        end 
        $stop;     
    end

    // VCD Dump for waveform analysis
    initial begin
        $dumpfile("spi.vcd");   // Specify the name of the dump file
        $dumpvars(0, tb_spi);    // Dump all variables in the tb_spi module
    end
endmodule
