`include "../msg_receiver_module/serial_msg_receiver.v"
`include "../../serial_port/serial_module/serial_rx.v"
`include "../../serial_port/serial_module/serial_tx.v"
`include "../../clock_divider_module/clock_divider_pulse.v"

module msg_receiver_echo (
    input ser_rx,
    output ser_tx,
    output spi_ssn,
    output led_blue,
    output led_green,
    output led_red
);

    //Due to using UART, the SPI_SSN pin must be held high to avoid interfering with further programming of the flash
    assign spi_ssn = 1'b1;

    // Clock instantiation
    wire clk;
    SB_HFOSC inthosc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

    // LED MODULE --------------------------------------------------------------
    // LED toggles
    reg led_red_tog_reg;
    reg led_green_tog_reg;
    wire led_green_tog;
    wire led_red_tog;
    wire led_blue_tog;
    SB_RGBA_DRV rgb (
        .RGBLEDEN (1'b1),
        .RGB0PWM  (led_blue_tog),
        .RGB1PWM  (led_green_tog_reg),
        .RGB2PWM  (led_red_tog_reg),
        .CURREN   (1'b1),
        .RGB0     (led_blue),
        .RGB1     (led_green),
        .RGB2     (led_red)
    );
    defparam rgb.CURRENT_MODE = "0b1";
    defparam rgb.RGB0_CURRENT = "0b000001";
    defparam rgb.RGB1_CURRENT = "0b000001";
    defparam rgb.RGB2_CURRENT = "0b000001";
    // LED MODULE --------------------------------------------------------------

    //CLOCK STROBE MODULE ------------------------------------------------------
    wire clk_en;
    clock_divider_pulse #(.N(2)) cdp
    (
        .CLK(clk),
        .PULSE(clk_en)
    );
    //CLOCK STROBE MODULE ------------------------------------------------------


    // SERIAL RX MODULE --------------------------------------------------------
    wire [7:0] serial_buff_rx;
    wire [7:0] serial_buff_tx;
    wire data_valid_rx;
    wire data_valid_tx;

    serial_rx #(.CLOCK_FREQUENCY(24000000),.BAUDRATE(576000)) s_rx  (
        .i_Clock(clk_en),
        .i_Rx_Serial(ser_rx),
        .o_Rx_Byte(serial_buff_rx),
        .o_Rx_DV(data_valid_rx)
    );
    // SERIAL RX MODULE --------------------------------------------------------

    // MSG RECEIVER MODULE -----------------------------------------------------
    serial_msg_receiver #(
        .START_PARTICLE_MESSAGE("ABCDE"),
        .START_PARTICLE_MESSAGE_LENGTH_BYTE(5),
        .START_MAP_MESSAGE("FGHIJ"),
        .START_MAP_MESSAGE_LENGTH_BYTE(5),
        .PARTICLE_MESSAGE_LENGHT(8),
        .MAP_MESSAGE_LENGHT(8)
    ) smr (
        .clk(clk_en),
        .rx_data(serial_buff_rx),
        .rx_data_ready(data_valid_rx),
        .msg_out(serial_buff_tx),
        .particle_data_flag(led_red_tog),
        .map_data_flag(led_green_tog),
        .data_valid(data_valid_tx)
    );
    // MSG RECEIVER MODULE -----------------------------------------------------

    // SERIAL TX MODULE --------------------------------------------------------
    serial_tx #(.CLOCK_FREQUENCY(24000000),.BAUDRATE(576000)) s_tx  (
        .i_Clock(clk_en),
        .i_Tx_Byte(serial_buff_tx),
        .i_Tx_DV(data_valid_tx),
        .o_Tx_Serial(ser_tx),
        .o_Tx_Done(led_blue_tog)
    );
    // SERIAL TX MODULE --------------------------------------------------------


    always @(posedge clk) begin
        led_green_tog_reg <= led_green_tog;
        led_red_tog_reg <= led_red_tog;
    end
    
endmodule