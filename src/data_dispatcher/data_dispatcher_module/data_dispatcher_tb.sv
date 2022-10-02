module data_dispatcher_tb;

    logic [7:0] data_to_dispatch;
    logic data_to_dispatch_valid;
    logic particle_data_flag;
    logic map_data_flag;
    logic [7:0] data_to_write;
    logic [9:0] address_to_write;
    logic data_to_write_valid;
    logic start_particle_update;
    logic clk;

    data_dispatcher #(
        .dispatch_table("TEST_DISPATCH_TABLE.txt"),
        .PARTICLE_MESSAGE_LENGHT_BYTE(8),
        .MAP_MESSAGE_LENGHT_BYTE(10)
    ) dd (
        .clk(clk),
        .data_in(data_to_dispatch),
        .input_data_valid(data_to_dispatch_valid),
        .particle_data_flag(particle_data_flag),
        .map_data_flag(map_data_flag),
        .data_out(data_to_write),
        .waddr(address_to_write),
        .data_valid(data_to_write_valid),
        .start_particle_update(start_particle_update)
    );

    dual_port_block_ram #(
        .data_width(8),
        .addr_width(10),
        .ram_content("NONE")
    ) destination_block_ram (
        .write_en(data_to_write_valid),
        .waddr(address_to_write),
        .din(data_to_write),
        .read_en(1'b0),
        .wclk(clk),
        .rclk(clk)
    );

    always #5 clk = ~clk;
    integer idx;
    initial begin
        $dumpfile("data_dispatcher_tb.vcd");
        for (idx = 0; idx < 8; idx = idx + 1) $dumpvars(0, destination_block_ram.mem[idx]);
        for (idx = 0; idx < 8; idx = idx + 1) $dumpvars(0, dd.dispatch_table_ram.mem[idx]);

        $dumpvars();
        clk = 0;
        #10 
        map_data_flag = 1;
        #23
        data_to_dispatch = 8'h01;
        data_to_dispatch_valid = 1;
        #10 data_to_dispatch_valid = 0;
        #20
        data_to_dispatch = 8'h02;
        data_to_dispatch_valid = 1;
        #10 data_to_dispatch_valid = 0;
        #20
        data_to_dispatch = 8'h03;
        data_to_dispatch_valid = 1;
        #10 data_to_dispatch_valid = 0;
        #20
        data_to_dispatch = 8'h04;
        data_to_dispatch_valid = 1;
        #10 data_to_dispatch_valid = 0;
        #20
        data_to_dispatch = 8'h05;
        data_to_dispatch_valid = 1;
        #10 data_to_dispatch_valid = 0;
        #20
        data_to_dispatch = 8'h06;
        data_to_dispatch_valid = 1;
        #10 data_to_dispatch_valid = 0;
        #20
        data_to_dispatch = 8'h07;
        data_to_dispatch_valid = 1;
        #10 data_to_dispatch_valid = 0;
        #20
        data_to_dispatch = 8'h08;
        data_to_dispatch_valid = 1;
        #10 data_to_dispatch_valid = 0;
        #20
        data_to_dispatch = 8'h09;
        data_to_dispatch_valid = 1;
        #10 data_to_dispatch_valid = 0;
        #20
        data_to_dispatch = 8'h0A;
        data_to_dispatch_valid = 1;
        #10 data_to_dispatch_valid = 0;
        #20

        #100;
        $finish;
    end

endmodule