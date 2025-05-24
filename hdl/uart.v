module uart(
    input clk,
    input [1:0] UARTOp,
    input [7:0] WriteData,
    output reg [31:0] ReadData,
    output reg DataReadFromLine,        // indicator for FIFO to read

    input rx,            
    output reg tx
);

// Clock frequency for Nexys A7 is 100MHz when using CLK100MHZ
parameter CLK_FREQUENCY = 100_000_000;  // Changed from 50MHz to 100MHz
parameter BAUD_RATE = 9600;
parameter REQ_CLKS_FOR_BIT = CLK_FREQUENCY / BAUD_RATE;        

// States 
localparam IDLE = 2'b00;
localparam START_BIT = 2'b01;
localparam DATA_BITS = 2'b10;
localparam STOP_BIT = 2'b11;

// Initialize tx to idle state (high)
initial begin
    tx = 1'b1;
    DataReadFromLine = 1'b0;
    ReadData = 32'b0;
end

// TX related signals
reg [1:0] tx_state = IDLE;
reg [15:0] tx_clk_count = 0;  // Increased to 16 bits for 100MHz clock
reg [2:0] tx_bit_index = 0;
reg [7:0] tx_data = 0;
reg tx_active = 0;
reg tx_start_req = 0;

// RX related signals
reg [1:0] rx_state = IDLE;
reg [15:0] rx_clk_count = 0;  // Increased to 16 bits for 100MHz clock
reg [2:0] rx_bit_index = 0;
reg [7:0] rx_read_data_int = 0;

// Input synchronization for RX
reg rx_sync_0 = 1'b1;
reg rx_sync_1 = 1'b1;
reg rx_sync_2 = 1'b1;  // Added third stage for better metastability protection
wire rx_in;

// Synchronize RX input (3-stage synchronizer)
always @(posedge clk) begin
    rx_sync_0 <= rx;
    rx_sync_1 <= rx_sync_0;
    rx_sync_2 <= rx_sync_1;
end

assign rx_in = rx_sync_2;

// Edge detection for start condition
reg rx_prev = 1'b1;
wire rx_negedge;

always @(posedge clk) begin
    rx_prev <= rx_in;
end

assign rx_negedge = rx_prev & ~rx_in;  // Falling edge detection

// TX State Machine
always @(posedge clk) begin
    // Handle new transmission request
    if (UARTOp == 2'b10 && !tx_active && tx_state == IDLE) begin
        tx_data <= WriteData;
        tx_active <= 1'b1;
        tx_state <= START_BIT;
        tx_clk_count <= 0;
        tx_bit_index <= 0;
    end

    // TX state machine
    if (tx_active) begin 
        case(tx_state)
            START_BIT: begin
                tx <= 1'b0;    // Send start bit (low)

                if (tx_clk_count < REQ_CLKS_FOR_BIT - 1) begin
                    tx_clk_count <= tx_clk_count + 1;
                end else begin
                    tx_clk_count <= 0;
                    tx_state <= DATA_BITS;
                    tx_bit_index <= 0;
                end
            end

            DATA_BITS: begin
                tx <= tx_data[tx_bit_index];  // Send data bits LSB first

                if (tx_clk_count < REQ_CLKS_FOR_BIT - 1) begin
                    tx_clk_count <= tx_clk_count + 1;
                end else begin
                    tx_clk_count <= 0;
                    
                    if (tx_bit_index < 7) begin
                        tx_bit_index <= tx_bit_index + 1;
                    end else begin
                        tx_state <= STOP_BIT;
                    end
                end
            end

            STOP_BIT: begin
                tx <= 1'b1;  // Send stop bit (high)
                
                if (tx_clk_count < REQ_CLKS_FOR_BIT - 1) begin
                    tx_clk_count <= tx_clk_count + 1;
                end else begin
                    tx_state <= IDLE;
                    tx_clk_count <= 0;
                    tx_active <= 1'b0;
                end
            end

            default: begin  // IDLE state
                tx <= 1'b1;
                tx_active <= 1'b0;
                tx_state <= IDLE;
            end
        endcase
    end else begin
        // When not active, keep tx high (idle state)
        tx <= 1'b1;
    end
end

// RX State Machine
always @(posedge clk) begin
    // Clear the data ready flag by default
    DataReadFromLine <= 1'b0;

    case(rx_state)
        IDLE: begin
            rx_clk_count <= 0;
            rx_bit_index <= 0;

            // Look for start bit (falling edge)
            if (rx_negedge) begin
                rx_state <= START_BIT;
                rx_clk_count <= 0;
            end
        end

        START_BIT: begin
            if (rx_clk_count < REQ_CLKS_FOR_BIT - 1) begin
                rx_clk_count <= rx_clk_count + 1;
            end else begin
                // Sample in the middle of the bit period
                if (rx_in == 1'b0) begin  // Valid start bit
                    rx_clk_count <= 0;
                    rx_state <= DATA_BITS;
                    rx_bit_index <= 0;
                end else begin  // False start bit
                    rx_state <= IDLE;
                end
            end
        end
            
        DATA_BITS: begin
            if (rx_clk_count < REQ_CLKS_FOR_BIT - 1) begin
                rx_clk_count <= rx_clk_count + 1;
            end else begin
                // Sample data bit in the middle of the bit period
                rx_read_data_int[rx_bit_index] <= rx_in;
                rx_clk_count <= 0;
                
                if (rx_bit_index < 7) begin
                    rx_bit_index <= rx_bit_index + 1;
                end else begin
                    rx_state <= STOP_BIT;
                end
            end
        end
            
        STOP_BIT: begin
            if (rx_clk_count < REQ_CLKS_FOR_BIT - 1) begin
                rx_clk_count <= rx_clk_count + 1;
            end else begin
                // Sample stop bit
                if (rx_in == 1'b1) begin  // Valid stop bit
                    DataReadFromLine <= 1'b1;       
                    ReadData <= {24'b0, rx_read_data_int};    
                end
                // Return to idle regardless of stop bit validity
                rx_state <= IDLE;     
                rx_clk_count <= 0;
            end
        end

        default: begin
            rx_state <= IDLE;
        end
    endcase 
end

endmodule