module serial_msg_receiver #(
	parameter START_PARTICLE_MESSAGE = "ABCDE",
	parameter START_PARTICLE_MESSAGE_LENGTH_BYTE = 5,
	parameter START_MAP_MESSAGE = "FGHIJ",
	parameter START_MAP_MESSAGE_LENGTH_BYTE = 5,
	parameter PARTICLE_MESSAGE_LENGHT = 8,
	parameter MAP_MESSAGE_LENGHT = 16
)
(
	input clk,
	input [7:0] rx_data,
	input rx_data_ready,
	output reg [7:0] msg_out,
	output reg particle_data_flag,
	output reg map_data_flag,
	output data_valid
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


	localparam START_PARTICLE_MESSAGE_WIDTH = START_PARTICLE_MESSAGE_LENGTH_BYTE * 8;
	localparam START_MAP_MESSAGE_WIDTH = START_MAP_MESSAGE_LENGTH_BYTE * 8;
	localparam START_MESSAGE_LENGHT = START_PARTICLE_MESSAGE_LENGTH_BYTE > START_MAP_MESSAGE_LENGTH_BYTE ? START_PARTICLE_MESSAGE_LENGTH_BYTE : START_MAP_MESSAGE_LENGTH_BYTE;
	localparam DATA_MESSAGE_LENGHT = PARTICLE_MESSAGE_LENGHT > MAP_MESSAGE_LENGHT ? PARTICLE_MESSAGE_LENGHT : MAP_MESSAGE_LENGHT;
	localparam DATA_MESSAGE_COUNTER_WIDTH = MinBitWidth(DATA_MESSAGE_LENGHT);
	localparam START_MESSAGE_COUNTER_WIDTH = MinBitWidth(START_MESSAGE_LENGHT);
	reg [7:0] rx_data_reg;
	reg data_read;
	reg data_processed;
	reg [2:0] curr_state;
	reg [2:0] next_state;
	reg [DATA_MESSAGE_COUNTER_WIDTH - 1:0] data_countdown;
	reg [START_MESSAGE_COUNTER_WIDTH + 3 - 1:0] counter;

	// FSM for detecting the type of message received and informing the next module of the type of data incoming
	always @(*) begin : FSM_COMBO
		next_state = curr_state;
		case (curr_state)
			3'd0:
			begin
				if (rx_data_ready) begin
					next_state = 3'd1;
				end
			end
			3'd1:
			begin
				if (data_processed && rx_data_reg == START_PARTICLE_MESSAGE[START_PARTICLE_MESSAGE_WIDTH - counter - 1 -: 8] && rx_data_reg != START_MAP_MESSAGE[START_MAP_MESSAGE_WIDTH - counter - 1 -: 8]) begin
					next_state = 3'd2;
				end else if (data_processed && rx_data_reg == START_MAP_MESSAGE[START_MAP_MESSAGE_WIDTH - counter - 1 -: 8] && rx_data_reg != START_PARTICLE_MESSAGE[START_MAP_MESSAGE_WIDTH - counter - 1 -: 8]) begin
					next_state = 3'd3;
				end else if (rx_data_reg != START_MAP_MESSAGE[START_MAP_MESSAGE_WIDTH - counter - 1 -: 8] && rx_data_reg != START_PARTICLE_MESSAGE[START_MAP_MESSAGE_WIDTH - counter - 1 -: 8]) begin
					next_state = 3'd0;
				end
			end
			3'd2:
			begin
				if (data_processed && rx_data_reg != START_PARTICLE_MESSAGE[START_PARTICLE_MESSAGE_WIDTH - counter - 1 -: 8]) begin
					next_state = 3'd0;
				end else if (counter == START_PARTICLE_MESSAGE_WIDTH - 8) begin
					next_state = 3'd4;
				end
			end
			3'd3:
				if (data_processed && rx_data_reg != START_MAP_MESSAGE[START_MAP_MESSAGE_WIDTH - counter - 1 -: 8]) begin
					next_state = 3'd0;
				end else if (counter == START_MAP_MESSAGE_WIDTH - 8) begin
					next_state = 3'd4;
				end
			3'd4:
			begin
				if (data_countdown == 0) begin
					next_state = 3'd0;
				end
			end
			default: 
			begin
				next_state = 3'd0;
			end
		endcase
	end

	// Output part of the FSM
	always @(posedge clk) begin : FSM_SEQ
		curr_state <= next_state;
		case (curr_state)
			3'd0: begin
				counter <= 'b0;
				particle_data_flag <= 1'b0;
				map_data_flag <= 1'b0;
				data_read <= 1'b0;
				data_processed <= 1'b0;
				if(curr_state != next_state) begin
					rx_data_reg <= rx_data;
					data_read <= 1'b1;
					data_processed <= 1'b1;
				end
			end
			3'd1:
			begin
				if (rx_data_ready && !data_read) begin
					rx_data_reg <= rx_data;
					data_read <= 1'b1;
				end else if (data_read && !data_processed) begin
					counter <= counter + 4'd8;
					data_processed <= 1'b1;
				end else if(data_processed && !rx_data_ready) begin
					data_read <= 1'b0;
					data_processed <= 1'b0;
				end
			end
			3'd2: 
			begin
				data_countdown <= PARTICLE_MESSAGE_LENGHT;
				particle_data_flag  <= 1'b1;
				if (rx_data_ready && !data_read) begin
					rx_data_reg <= rx_data;
					data_read <= 1'b1;
				end else if (data_read && !data_processed) begin
					counter <= counter + 4'd8;
					data_processed <= 1'b1;
				end else if(data_processed && !rx_data_ready) begin
					data_read <= 1'b0;
					data_processed <= 1'b0;
				end
			end
			3'd3:
			begin
				data_countdown <= MAP_MESSAGE_LENGHT;
				map_data_flag  <= 1'b1;
				if (rx_data_ready && !data_read) begin
					rx_data_reg <= rx_data;
					data_read <= 1'b1;
				end else if (data_read && !data_processed) begin
					counter <= counter + 4'd8;
					data_processed <= 1'b1;
				end else if(data_processed && !rx_data_ready) begin
					data_read <= 1'b0;
					data_processed <= 1'b0;
				end
			end
			3'd4:
			begin
				if (rx_data_ready && !data_read) begin
					rx_data_reg <= rx_data;
					data_read <= 1'b1;
				end else if (data_read && !data_processed) begin
					msg_out <= rx_data_reg;
					data_countdown <= data_countdown - 1'b1;
					data_processed <= 1'b1;
				end else if(data_processed && !rx_data_ready) begin
					data_read <= 1'b0;
					data_processed <= 1'b0;
				end
			end
			default:
			begin
				curr_state <= 3'd0;
				counter <= 'b0;
				data_processed <= 1'b0;
				particle_data_flag <= 1'b0;
				map_data_flag <= 1'b0;
				data_read <= 1'b0;
			end
		endcase
	end

	assign data_valid = data_processed && (curr_state == 3'd4);

endmodule
