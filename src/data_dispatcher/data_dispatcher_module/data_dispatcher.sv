`include "../../dual_port_block_ram/dual_port_block_ram_module/block_ram.v"

module data_dispatcher #(
    parameter dispatch_table = "NONE",
    parameter PARTICLE_MESSAGE_LENGHT_BYTE = 859,
    parameter MAP_MESSAGE_LENGHT_BYTE = 1000
) (
    input clk,
    input [7:0] data_in,
    input input_data_valid,
    input particle_data_flag,
    input map_data_flag,
    output [7:0] data_out, // Basically data_in at a later point in time
    output [9:0] waddr, // For block ram where this is sending the incoming data to
    output logic data_valid, // Used to tell the receiving block ram when to latch data in
    output logic start_particle_update // Used to tell the particle filter to start updating
);
    function integer MinBitWidth;
    input [1023:0] value;
    begin
        for (MinBitWidth = 0; value > 0; MinBitWidth = MinBitWidth + 1)
        begin
            value = value >> 1;
        end
    end
    endfunction

    localparam PARTICLE_MESSAGE_MINWIDTH = MinBitWidth(PARTICLE_MESSAGE_LENGHT_BYTE);
    localparam MAP_MESSAGE_MINWIDTH = MinBitWidth(MAP_MESSAGE_LENGHT_BYTE);
    localparam COUNTER_WIDTH = PARTICLE_MESSAGE_MINWIDTH > MAP_MESSAGE_MINWIDTH ? PARTICLE_MESSAGE_MINWIDTH : MAP_MESSAGE_MINWIDTH;


    logic [9:0] raddr_dispatch;
    logic read_en_dispatch;

    dual_port_block_ram #(
        .data_width(16),
        .addr_width(10),
        .ram_content(dispatch_table),
        .initial_content_size(1024-1)
    ) dispatch_table_ram (
        .raddr(raddr_dispatch),
        .write_en(1'b0),
        .read_en(read_en_dispatch),
        .wclk(clk),
        .rclk(clk),
        .dout(waddr)
    );

    typedef enum bit [3:0] {
        IDLE = 4'b0,
        WAITING_FOR_DATA_PARTICLE = 4'b1,
        WAITING_FOR_DATA_MAP = 4'b10,
        FETCH_DESTINATION_ADDRESS_PARTICLE = 4'b11,
        FETCH_DESTINATION_ADDRESS_MAP = 4'b100,
        WRITING_TO_DESTINATION_ADDRESS = 4'b101,
        SEND_PARTICLE_UPDATE_SIGNAL = 4'b110
    } state_t;

    state_t curr_state;
    state_t next_state;
    reg [COUNTER_WIDTH-1:0] data_counter;

    always_comb begin : FSM_COMB
        next_state = curr_state;
        data_valid = 1'b0;
        read_en_dispatch = 1'b0;
        raddr_dispatch = 0;
        start_particle_update = 1'b0;
        case (curr_state)
            IDLE: begin
                if (particle_data_flag) begin
                    next_state = WAITING_FOR_DATA_PARTICLE;
                end else if (map_data_flag) begin
                    next_state = WAITING_FOR_DATA_MAP;
                end
            end
            WAITING_FOR_DATA_PARTICLE: 
            begin
                // NO FLAG DETECTED, RESET FSM
                if (!particle_data_flag) begin
                    next_state = IDLE;
                end else if (input_data_valid) begin
                    next_state = FETCH_DESTINATION_ADDRESS_PARTICLE;
                end
            end
            WAITING_FOR_DATA_MAP:
            begin
                // NO FLAG DETECTED, RESET FSM
                if (!map_data_flag) begin
                    next_state = IDLE;
                end else if (input_data_valid) begin
                    next_state = FETCH_DESTINATION_ADDRESS_MAP;
                end
            end
            FETCH_DESTINATION_ADDRESS_PARTICLE: 
            begin
                // NO FLAG DETECTED, RESET FSM
                if (!particle_data_flag) begin
                    next_state = IDLE;
                end else begin
                    raddr_dispatch = data_counter;
                    read_en_dispatch = 1'b1;
                    next_state = WRITING_TO_DESTINATION_ADDRESS;
                end
            end
            FETCH_DESTINATION_ADDRESS_MAP: 
            begin
                // NO FLAG DETECTED, RESET FSM
                if (!map_data_flag) begin
                    next_state = IDLE;
                end else begin
                    raddr_dispatch = data_counter;
                    read_en_dispatch = 1'b1;
                    next_state = WRITING_TO_DESTINATION_ADDRESS;
                end
            end
            WRITING_TO_DESTINATION_ADDRESS: 
            begin
                data_valid = 1'b1;
                // NO FLAG DETECTED, RESET FSM (must check both flags here since state is shared)
                if (!particle_data_flag && !map_data_flag) begin
                    next_state = IDLE;
                // REACHED END OF PARTICLE MESSAGE
                end else if (particle_data_flag && data_counter == PARTICLE_MESSAGE_LENGHT_BYTE) begin
                    next_state = SEND_PARTICLE_UPDATE_SIGNAL;
                // REACHED END OF MAP MESSAGE
                end else if (map_data_flag && data_counter == MAP_MESSAGE_LENGHT_BYTE) begin
                    next_state = IDLE;
                // STILL MORE PARTICLE DATA TO BE READ
                end else if (particle_data_flag) begin
                    next_state = WAITING_FOR_DATA_PARTICLE;
                // STILL MORE MAP DATA TO BE READ
                end else if (map_data_flag) begin
                    next_state = WAITING_FOR_DATA_MAP;
                end
            end
            SEND_PARTICLE_UPDATE_SIGNAL:
            begin
                start_particle_update = 1'b1;
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_ff @( posedge clk ) begin : FSM_FF
        curr_state <= next_state;
        case(curr_state)
            IDLE:
            begin
                data_counter <= 0;
            end
            FETCH_DESTINATION_ADDRESS_PARTICLE:
            begin
                data_counter <= data_counter + 1;
            end
            FETCH_DESTINATION_ADDRESS_MAP: 
            begin
                data_counter <= data_counter + 1;
            end
        endcase
    end

    assign data_out = data_in;

endmodule