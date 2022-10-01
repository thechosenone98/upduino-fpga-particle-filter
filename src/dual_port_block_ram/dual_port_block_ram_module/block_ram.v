module dual_port_block_ram 
#(
    parameter data_width = 16,
    parameter addr_width = 10, // 10 = 1024 block depth
    parameter ram_content = "NONE",
    parameter initial_content_size = 0
)
(
    input [data_width-1:0] din,
    input [addr_width-1:0] waddr,
    input [addr_width-1:0] raddr,
    input write_en, 
    input read_en,
    input wclk, 
    input rclk,
    output reg [data_width-1:0] dout
);

    // Block RAM (infered)
    reg [data_width-1:0] mem [(1<<addr_width)-1:0];
    
    initial begin
        if (ram_content != "NONE") begin
            $readmemb(ram_content, mem, 0, initial_content_size);
        end
    end

    always @(posedge wclk) // Write memory.
    begin
    if (write_en)
        mem[waddr] <= din; // Using write address bus.
    end
    always @(posedge rclk) // Read memory.
    begin
    if (read_en) begin
        dout <= mem[raddr]; // Using read address bus.
    end
    end

endmodule