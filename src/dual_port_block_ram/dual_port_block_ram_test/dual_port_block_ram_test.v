`include "../../serial_port/serial_module/serial_tx.v"
`include "../../clock_divider_module/clock_divider_pulse.v"
`include "../dual_port_block_ram_module/block_ram.v"

module dual_port_block_ram_test(
    output ser_tx,
    output led_blue,
    output led_green,
    output led_red,
    output spi_ssn
);

    wire led_green_tog;
    wire led_red_tog;
    wire led_blue_tog;
    assign led_blue_tog = 1'b0;
    assign spi_ssn = 1'b1;
    SB_RGBA_DRV rgb (
        .RGBLEDEN (1'b1),
        .RGB0PWM  (led_blue_tog),
        .RGB1PWM  (led_green_tog),
        .RGB2PWM  (led_red_tog),
        .CURREN   (1'b1),
        .RGB0     (led_blue),
        .RGB1     (led_green),
        .RGB2     (led_red)
    );
    defparam rgb.CURRENT_MODE = "0b1";
    defparam rgb.RGB0_CURRENT = "0b000001";
    defparam rgb.RGB1_CURRENT = "0b000001";
    defparam rgb.RGB2_CURRENT = "0b000001";

    wire [9:0] raddr;
    wire clk_div;
    wire [7:0] data_out;
    wire clk;
    SB_HFOSC inthosc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
    clock_divider_pulse #(.N(500000)) clkdivp (.CLK(clk), .PULSE(clk_div));
    counter cnt (.clk(clk), .clk_en(clk_div), .count(raddr));
    dual_port_block_ram #(
        .data_width(8),
        .addr_width(10),
        .ram_content("./demo_ramfile_generator/block_ram_8b.txt"),
        .initial_content_size(1024-1)
    ) ram (
            .raddr(raddr),
            .write_en(1'b0),
            .read_en(clk_div),
            .wclk(clk),
            .rclk(clk),
            .dout(data_out)
    );
    serial_tx stx(
        .i_Clock(clk),
        .i_Tx_DV(clk_div),
        .i_Tx_Byte(data_out),
        .o_Tx_Serial(ser_tx),
        .o_Tx_Done(led_green_tog),
        .o_Tx_Active(led_red_tog)
    );

endmodule