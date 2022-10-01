module write_example_ram;

integer i;
integer fd; // file descriptor
integer char;
reg [15:0] memory_16b [1023:0]; // 16 bit memory with 1024 entries
reg [7:0] memory_8b [1023:0]; // 8 bit memory with 1024 entries

initial begin
    // Open file and read first 1024 characters (write this data to memory file)
    fd = $fopen("lorem_ipsum.txt", "r");
    i = 0;
    while (i < 1024) begin
        char = $fgetc(fd);
        if (char == 13 || char == 10) begin
            // ignore carriage return and line feed
        end else begin
            memory_8b[i] = char;
            memory_16b[i] = char;
            i = i + 1;
        end
    end
    $fclose(fd); // Close file

    $writememb("block_ram_16b.txt", memory_16b);
    $writememb("block_ram_8b.txt", memory_8b);
    $finish;
end

endmodule