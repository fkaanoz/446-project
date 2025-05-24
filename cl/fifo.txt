module fifo #(
    parameter WIDTH = 32, 
    parameter DEPTH = 16
)(
    input clk, reset, write, 
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out,
    input [1:0] UARTOp,
    
    input read_clk
);

localparam ADDR_WIDTH = $clog2(DEPTH);

reg [WIDTH-1:0] cir_buffer [0:DEPTH-1];
reg [ADDR_WIDTH-1:0] write_ptr;
reg [ADDR_WIDTH-1:0] read_ptr;
reg [ADDR_WIDTH:0] data_counter = 0;

// Synchronizers for clock domain crossing
reg [1:0] uart_op_sync_1, uart_op_sync_2;
reg uart_read_req_sync_1, uart_read_req_sync_2;
reg uart_read_req_prev;
wire uart_read_pulse;

// Synchronize UARTOp to write clock domain
always @(posedge clk) begin
    if (reset) begin
        uart_op_sync_1 <= 2'b00;
        uart_op_sync_2 <= 2'b00;
    end else begin
        uart_op_sync_1 <= UARTOp;
        uart_op_sync_2 <= uart_op_sync_1;
    end
end

// Generate read request pulse in read clock domain
always @(posedge read_clk) begin
    if (reset) begin
        uart_read_req_prev <= 1'b0;
    end else begin
        uart_read_req_prev <= (UARTOp == 2'b01);
    end
end

assign uart_read_pulse = (UARTOp == 2'b01) && !uart_read_req_prev;

// Synchronize read request to write clock domain
always @(posedge clk) begin
    if (reset) begin
        uart_read_req_sync_1 <= 1'b0;
        uart_read_req_sync_2 <= 1'b0;
    end else begin
        uart_read_req_sync_1 <= uart_read_pulse;
        uart_read_req_sync_2 <= uart_read_req_sync_1;
    end
end

// Write clock domain operations
always @(posedge clk) begin
    if (reset) begin
        write_ptr <= 0;
        read_ptr <= 0;
        data_counter <= 0;
    end else begin
        // Handle read request from other clock domain
        if (uart_read_req_sync_2 && data_counter != 0) begin
            read_ptr <= (read_ptr == DEPTH-1) ? 0 : read_ptr + 1;
            data_counter <= data_counter - 1;
        end

        // Handle write operations
        if (write) begin
            cir_buffer[write_ptr] <= data_in;
            if (data_counter == DEPTH) begin
                // Buffer full, overwrite oldest data
                read_ptr <= (read_ptr == DEPTH-1) ? 0 : read_ptr + 1;
            end else begin
                data_counter <= data_counter + 1;
            end
            write_ptr <= (write_ptr == DEPTH-1) ? 0 : write_ptr + 1;
        end
    end
end

// Read clock domain operations
always @(posedge read_clk) begin
    if (reset) begin
        data_out <= 0;
    end else begin
        if (UARTOp == 2'b01) begin
            if (data_counter != 0) begin
                data_out <= cir_buffer[read_ptr];
            end else begin
                data_out <= 32'hFFFFFFFF; // Return 0 instead of 0xFFFFFFFF when no data
            end
        end
    end
end

endmodule