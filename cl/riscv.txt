// Top module for risc-v computer
module riscv(
    input clk,
    input CLK100MHZ,
    input reset,
    input [4:0] debug_reg_select,
    output [31:0] debug_reg_out,
    output [31:0] fetchPC,

    input rx,
    output tx
);

// internal signals
wire [1:0] PCSrc;
wire RegWrite;
wire [2:0] ImmSrc;
wire ALUSrc;
wire [3:0] ALUControl;
wire MemWrite;
wire [1:0] ResultSrc;
wire [1:0] operation_byte_size;

wire [2:0] MemResultCtr;

wire [6:0] op;
wire [2:0] funct3;
wire funct7_5;

wire Zero;
wire Negative;
wire Overflow;
wire CarryOut;


wire [31:0] ALUResult;
wire [1:0] UARTOp;

wire [1:0] RegWriteSrcSelect;

datapath my_datapath(
    .clk(clk),
    .CLK100MHZ(CLK100MHZ),
    .reset(reset),

    .PCSrc(PCSrc),
    .RegWrite(RegWrite),
    .ImmSrc(ImmSrc),
    .ALUSrc(ALUSrc),
    .ALUControl(ALUControl),
    .MemWrite(MemWrite),
    .ResultSrc(ResultSrc),
    .operation_byte_size(operation_byte_size),

    .MemResultCtr(MemResultCtr),

    .op(op),
    .funct3(funct3),
    .funct7_5(funct7_5),

    .Zero(Zero),
    .Negative(Negative),
    .Overflow(Overflow),
    .CarryOut(CarryOut),

    .Debug_Source_select(debug_reg_select),
    .Debug_out(debug_reg_out),

    .fetchPC(fetchPC), 


    .ALUResult(ALUResult),

    .UARTOp(UARTOp),

    .RegWriteSrcSelect(RegWriteSrcSelect),

    .rx(rx),
    .tx(tx)
);


control_unit my_controller(
    .PCSrc(PCSrc),
    .RegWrite(RegWrite),
    .ImmSrc(ImmSrc),
    .ALUSrc(ALUSrc),
    .ALUControl(ALUControl),
    .MemWrite(MemWrite),
    .ResultSrc(ResultSrc),
    .operation_byte_size(operation_byte_size),

    .MemResultCtr(MemResultCtr),

    .op(op),
    .funct3(funct3),
    .funct7_5(funct7_5),

    .Zero(Zero),
    .Negative(Negative),
    .Overflow(Overflow),
    .CarryOut(CarryOut),

    .ALUResult(ALUResult),

    .UARTOp(UARTOp),

    .RegWriteSrcSelect(RegWriteSrcSelect)
);


endmodule
