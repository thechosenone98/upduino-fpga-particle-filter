//Include list
`include "../serial_module/serial_tx.v"
`include "../serial_module/serial_rx.v"

module serial_echo (
    input ser_rx,
    output led_red,
    output led_green,
    output led_blue,
    output ser_tx,
    output spi_ssn
);

    //Due to using UART, the SPI_SSN pin must be held high to avoid interfering with further programming of the flash
    assign spi_ssn = 1'b1;
    // LED toggles
    wire led_red_tog;
    wire led_green_tog;
    reg led_blue_tog;

    // Clock instantiation
    wire clk;
    SB_HFOSC inthosc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
    
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


    // Serial instantiation
    wire [7:0] serial_buff;
    wire data_valid;

    serial_rx #(.CLOCK_FREQUENCY(48000000),.BAUDRATE(115200)) s_rx  (
        .i_Clock(clk),
        .i_Rx_Serial(ser_rx),
        .o_Rx_Byte(serial_buff),
        .o_Rx_DV(data_valid)
    );

    serial_tx #(.CLOCK_FREQUENCY(48000000),.BAUDRATE(115200)) s_tx  (
        .i_Clock(clk),
        .i_Tx_DV(data_valid),
        .i_Tx_Byte(serial_buff),
        .o_Tx_Serial(ser_tx),
        .o_Tx_Active(led_red_tog),
        .o_Tx_Done(led_green_tog)
    );

    always @(posedge clk) begin
        if (data_valid) begin
            led_blue_tog <= ~led_blue_tog;
        end
    end

endmodule