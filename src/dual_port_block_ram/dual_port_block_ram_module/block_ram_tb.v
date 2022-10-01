`timescale 1ns/1ps
module block_ram_tb;

    wire [15:0] din;
    wire [15:0] dout;
    reg [9:0] raddr;
    reg [9:0] waddr;  
    reg write_en;
    reg wclk;
    reg rclk;

    dual_port_block_ram #(
        .data_width(16), 
        .addr_width(10), 
        .ram_content("block_ram.txt"), 
        .initial_content_size(1024-1)
    ) ram_inst (
        .din(din), 
        .waddr(waddr), 
        .raddr(raddr), 
        .write_en(data_in), 
        .wclk(wclk), 
        .rclk(rclk),
        .dout(dout)
    );

    //Clock
    always #5 wclk = ~wclk;
    always #5 rclk = ~rclk;

    integer i;
    initial begin
        $dumpfile("block_ram_tb.vcd");
        $dumpvars();
        $display("Starting simulation");
        wclk = 0;
        rclk = 0;
        write_en = 0;
        for (i=0; i<1024; i++) begin
            raddr = i;
            #10;
        end
        #100 $finish;
    end
endmodule