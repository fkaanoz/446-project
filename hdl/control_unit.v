module control_unit(

    output [1:0] PCSrc,
    output RegWrite,
    output [2:0] ImmSrc,
    output ALUSrc,
    output [3:0] ALUControl,
    output MemWrite,
    output [1:0] ResultSrc,
    output [1:0] operation_byte_size,

    output [2:0] MemResultCtr,
    
    input [6:0] op,
    input [2:0] funct3,
    input funct7_5,
    
    input Zero,
    input Negative,
    input Overflow,
    input CarryOut,

    input [31:0] ALUResult,         // for UART

    output [1:0] UARTOp,

    output [1:0] RegWriteSrcSelect
);

wire Branch;
wire [1:0] ALUOp;
wire Jump;
wire MemWriteINT;      // internal signal for Memory Write

main_decoder m_decod(.op(op), .funct3(funct3), .RegWrite(RegWrite), .ImmSrc(ImmSrc), .ALUSrc(ALUSrc), .MemWrite(MemWriteINT),  .Branch(Branch), .ALUOp(ALUOp), .Jump(Jump), .ResultSrc(ResultSrc), .operation_byte_size(operation_byte_size), .MemResultCtr(MemResultCtr), .RegWriteSrcSelect(RegWriteSrcSelect), .UARTOp(UARTOp));

alu_decoder a_decod(.funct7_5(funct7_5), .op_5(op[5]), .funct3(funct3), .ALUOp(ALUOp), .ALUControl(ALUControl));

pc_logic p_logic(.funct3(funct3), .Zero(Zero), .Overflow(Overflow), .Negative(Negative), .CarryOut(CarryOut), .Branch(Branch), .Jump(Jump), .PCSrc(PCSrc));

uart_cont u_cont(.op(op), .funct3(funct3), .ALUResult(ALUResult), .UARTOp(UARTOp) );

// Prevent MemWrite when UART Write or Read
assign MemWrite = MemWriteINT & ~(UARTOp == 2'b10 | UARTOp == 2'b01);   

endmodule