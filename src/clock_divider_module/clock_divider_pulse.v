module clock_divider_pulse  #(
  parameter N = 10
) 
(
    input  CLK,
    output PULSE
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
 
    reg [MinBitWidth(N) - 1:0]  count;
    reg curr_state;
    reg next_state;

    always @(*) begin : FSM_COMBO
        next_state = curr_state;
        case (curr_state)
            1'b0:
            begin
                next_state = 1'b0;
            end
            default:
            begin
                next_state = 1'b0;
            end
        endcase
    end
 
    always @(posedge CLK) begin
        curr_state <= next_state;
        case(curr_state)
            1'b0:
            begin
                if (~|count) begin
                    count <= N - 1;
                end else begin
                    count <= count - 1;
                end
            end
            default:
            begin
                count <= 0;
                curr_state <= 1'b0;
            end
        endcase
    end
  
    // pulse generator
    assign PULSE = ~|count;
 
endmodule