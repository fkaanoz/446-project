module uart_cont(
    input [31:0] ALUResult,
    input [6:0] op,
    input [2:0] funct3,
    output reg [1:0] UARTOp
);

// encoding 
// UARTOp  => 00 for not UART Operations
// UARTOp  => 01 for UART READ
// UARTOp  => 10 for UART WRITE

always @(*)
begin
  if(op == 7'b010_0011 & funct3 == 3'b000 & ALUResult == 32'h0000_0400) begin    // Store Byte and Dest 0x0000_0400
    UARTOp = 2'b10;     // UART Write
  end else if(op == 7'b000_0011 & funct3 == 3'b010 & ALUResult == 32'h0000_0404) begin  // Load Word and Dest 0x0000_0404
    UARTOp = 2'b01;     // UART Read
  end else begin
    UARTOp = 2'b00;     // no UART
  end
end

endmodule