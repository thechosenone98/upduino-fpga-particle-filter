// `include "./clock_divider_pulse.v"
`timescale 1ns/1ps
module clock_divider_pulse_tb;

    reg clk;

    wire clk_en;
    clock_divider_pulse #(.N(2)) cdp
    (
        .CLK(clk),
        .PULSE(clk_en)
    );

    //Clock process
    always #5 clk = ~clk;

    initial begin
        $display("MIN BIT WIDTH: %d", cdp.MinBitWidth(2));
        $dumpfile("clock_divider_pulse_tb.vcd");
        $dumpvars();
        clk = 'b0;
        #200 $finish;
    end


endmodule