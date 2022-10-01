module counter(
    input clk,
    input clk_en,
    output reg [9:0] count
);
    reg curr_state;
    reg next_state;

    always @(*) begin : FSM_COMBO
        next_state = curr_state;
        case(curr_state)
            0: 
            begin
                next_state = 0;
            end
            default:
            begin
                next_state = 0;
            end
        endcase
    end

    always @(posedge clk) begin : FSM_SEQ
        if (clk_en) begin
            curr_state <= next_state;
            case(curr_state)
                1'b0:
                begin
                    count <= count + 1;
                end
                default:
                begin
                    count <= 0;
                    curr_state <= 1'b0;
                end
            endcase
        end
    end
endmodule