module uart(
    input clk,
    input [1:0] UARTOp,
    input [7:0] WriteData,
    output reg [31:0] ReadData,
    output reg DataReadFromLine,        // indicator for FIFO to read

    input rx,            
    output reg tx
);

// if something read from the line  => DataReadFromLine = 1 !
// and update ReadData    => it will go to Fifo
// if UARTOp = 10 => write to line ! <=  UARTOp  => 10 for UART WRITE


parameter CLK_FREQUENCY = 50_000_000;
parameter BAUD_RATE = 9600;
parameter REQ_CLKS_FOR_BIT = CLK_FREQUENCY / BAUD_RATE;        
// Required clock count for one bit!


// States 
localparam IDLE = 2'b00;
localparam START_BIT = 2'b01;
localparam DATA_BITS = 2'b10;
localparam STOP_BIT = 2'b11;

initial begin
    tx = 1'b1;
end

// tx related
reg [1:0] tx_state = IDLE;
reg [15:0] tx_clk_count = 0;
reg [2:0] tx_bit_index = 0;         // hold we are at which bits!
reg [7:0] tx_data = 0;
reg tx_active = 0;

// rx related
reg [1:0] rx_state = IDLE;
reg [15:0] rx_clk_count = 0;
reg [2:0] rx_bit_index = 0;
reg [7:0] rx_read_data_int;



// Transmission 
always @(posedge clk) begin
    if (UARTOp == 2'b10 && !tx_active) begin
        tx_data <= WriteData;
        tx_active <= 1'b1;
        tx_state <= START_BIT;
        tx_clk_count <= 0;
        tx_bit_index <= 0;
    end

    if (tx_active) begin 
        case(tx_state)
            IDLE: begin
                tx <= 1'b1;
                tx_active <= 1'b0;
            end

            START_BIT: begin
                tx <= 1'b0;    // send all 0 until REQ_CLKS_FOR_BIT times clock hits.

                if (tx_clk_count < REQ_CLKS_FOR_BIT - 1) begin
                    tx_clk_count <= tx_clk_count + 1;
                end else begin
                    tx_clk_count <= 0;
                    tx_state <= DATA_BITS;
                end
            end


            DATA_BITS: begin
                tx <= tx_data[tx_bit_index];

                if (tx_clk_count < REQ_CLKS_FOR_BIT - 1) begin
                        tx_clk_count <= tx_clk_count + 1;
                    end else begin
                        tx_clk_count <= 0;
                        
                        if (tx_bit_index < 7) begin
                            tx_bit_index <= tx_bit_index + 1;
                        end else begin
                            tx_bit_index <= 0;
                            tx_state <= STOP_BIT;
                        end
                end
            end

            STOP_BIT: begin
                tx <= 1'b1;
                if (tx_clk_count < REQ_CLKS_FOR_BIT - 1) begin
                    tx_clk_count <= tx_clk_count + 1;
                end else begin
                    tx_state <= IDLE;
                    tx_clk_count <= 0;
                    tx_active <= 1'b0;
                end
            end

        endcase
    end

end




reg rx_sync_0 = 1;
reg rx_sync_1 = 1;
wire rx_in;

always @(posedge clk) begin
        rx_sync_0 <= rx;
        rx_sync_1 <= rx_sync_0;
end

assign rx_in = rx_sync_1;


// Recieve Operation
always @(posedge clk) begin
    DataReadFromLine <= 1'b0;

    case(rx_state)
        IDLE: begin
            rx_clk_count <= 0;
            rx_bit_index <= 0;

            if (rx_in == 1'b0) begin
                rx_state <= START_BIT;
            end
        end

        START_BIT: begin
                if (rx_clk_count == (REQ_CLKS_FOR_BIT - 1) / 2) begin
                    if (rx_in == 1'b0) begin
                        rx_clk_count <= rx_clk_count + 1;
                    end else begin
                        rx_state <= IDLE;
                    end
                end else if (rx_clk_count < REQ_CLKS_FOR_BIT - 1) begin
                    rx_clk_count <= rx_clk_count + 1;
                end else begin
                    rx_clk_count <= 0;
                    rx_state <= DATA_BITS;
                end
        end
            
        DATA_BITS: begin
            if (rx_clk_count == (REQ_CLKS_FOR_BIT - 1) / 2) begin
                rx_read_data_int[rx_bit_index] <= rx_in;  
            end
            
            if (rx_clk_count < REQ_CLKS_FOR_BIT - 1) begin
                rx_clk_count <= rx_clk_count + 1;
            end else begin
                rx_clk_count <= 0;
                if (rx_bit_index < 7) begin
                    rx_bit_index <= rx_bit_index + 1;
                end else begin
                    rx_bit_index <= 0;
                    rx_state <= STOP_BIT;
                end
            end
        end
            
        STOP_BIT: begin
            if (rx_clk_count < REQ_CLKS_FOR_BIT - 1) begin
                rx_clk_count <= rx_clk_count + 1;
            end else begin
                if (rx_in == 1'b1) begin        // if the transmission is complete
                    DataReadFromLine <= 1'b1;       
                    ReadData <= {24'b0, rx_read_data_int};    
                end
                rx_state <= IDLE;     
                rx_clk_count <= 0;
            end
        end
    endcase 
end

endmodule