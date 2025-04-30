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

    output KeepPC,
    output AUIPC
);

wire Branch;
wire [1:0] ALUOp;
wire Jump;

main_decoder m_decod(.op(op), .funct3(funct3), .RegWrite(RegWrite), .ImmSrc(ImmSrc), .ALUSrc(ALUSrc), .MemWrite(MemWrite),  .Branch(Branch), .ALUOp(ALUOp), .Jump(Jump), .ResultSrc(ResultSrc), .operation_byte_size(operation_byte_size), .MemResultCtr(MemResultCtr), .KeepPC(KeepPC), .AUIPC(AUIPC));

alu_decoder a_decod(.funct7_5(funct7_5), .op_5(op[5]), .funct3(funct3), .ALUOp(ALUOp), .ALUControl(ALUControl));

pc_logic p_logic(.funct3(funct3), .Zero(Zero), .Overflow(Overflow), .Negative(Negative), .CarryOut(CarryOut), .Branch(Branch), .Jump(Jump), .PCSrc(PCSrc));


endmodule