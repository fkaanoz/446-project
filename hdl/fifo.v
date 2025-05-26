module fifo #(
    parameter WIDTH = 32, 
    parameter DEPTH = 16
)(
    input clk, reset, write, 
    input [1:0] UARTOp, 
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

localparam ADDR_WIDTH = $clog2(DEPTH);

wire read = (UARTOp == 2'b01);

reg [WIDTH-1:0] cir_buffer [0:DEPTH-1];
reg [ADDR_WIDTH-1:0] write_ptr;
reg [ADDR_WIDTH-1:0] read_ptr;
reg [ADDR_WIDTH:0] data_counter = 0;

always @(posedge clk) begin
    if (reset) begin
        write_ptr <= 0;
        read_ptr <= 0;
        data_out <= 0;
        data_counter <= 0;
    end else begin
        if (read && data_counter != 0) begin
            data_out <= cir_buffer[read_ptr];
            read_ptr <= (read_ptr == DEPTH-1) ? 0 : read_ptr + 1;
            data_counter <= data_counter - 1;
        end else if(read && data_counter == 0) begin
            data_out <= 32'hFFFFFFFF;
        end

        if (write) begin
            cir_buffer[write_ptr] <= data_in;
            if (data_counter == DEPTH) begin
                read_ptr <= (read_ptr == DEPTH-1) ? 0 : read_ptr + 1;
            end else begin
                data_counter <= data_counter + 1;
            end
            write_ptr <= (write_ptr == DEPTH-1) ? 0 : write_ptr + 1;
        end
    end
end

endmodule