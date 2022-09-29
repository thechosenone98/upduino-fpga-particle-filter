// Testbench for serial_msg receiver

// Include the module under test
// `include "serial_msg_receiver.v"
`timescale 1ns/1ps
module serial_msg_receiver_tb ();
    reg clk;
    reg reset;
    wire [7:0] data_out;
    wire particle_data_flag;
    wire map_data_flag;
    reg [7:0] serial_data;
    reg rx_data_ready;


    // Instantiate the Device Under Test (DUT)
    serial_msg_receiver dut (
        .clk(clk),
        .reset(reset),
        .rx_data_ready(rx_data_ready),
        .rx_data(serial_data),
        .msg_out(data_out),
        .particle_data_flag(particle_data_flag),
        .map_data_flag(map_data_flag)
    );

    //Clock process
    always #5 clk = ~clk;

    initial begin
	    $display("PARTICLE_MESSAGE_LENGHT: %d", dut.PARTICLE_MESSAGE_LENGHT);
        $display("DATA_MESSAGE_LENGHT: %d", dut.DATA_MESSAGE_LENGHT);
        $display("MAP_MESSAGE_LENGHT: %d", dut.MAP_MESSAGE_LENGHT);
        // Initialize Inputs
        $dumpfile("serial_msg_receiver_tb.vcd");
        $dumpvars;
        reset = 1'b0;
        clk = 1'b0;
        rx_data_ready = 1'b0;
        serial_data = 8'd5;
        #10;
        reset = 1'b1;
        #10;
        reset = 1'b0;
        #100;
        rx_data_ready = 1'b1;
        serial_data = 8'd70;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd71;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd72;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd73;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd74;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd1;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd2;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd3;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd4;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd5;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd6;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd7;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd8;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd9;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd10;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd11;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd12;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd13;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd14;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd15;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        rx_data_ready = 1'b1;
        serial_data = 8'd16;
        @ (posedge clk);
        @ (posedge clk);
        rx_data_ready = 1'b0;
        @ (posedge clk);
        @ (posedge clk);
        @ (posedge clk);
        @ (posedge clk);
        @ (posedge clk);
        @ (posedge clk);
        @ (posedge clk);
        @ (posedge clk);
        #100;
        $finish;
    end
endmodule