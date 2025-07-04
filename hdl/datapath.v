module datapath(
    input clk,
    input reset,
    input CLK100MHZ, // for UART

    // control signals
    input [1:0]PCSrc,
    input RegWrite,
    input [2:0] ImmSrc,
    input ALUSrc,
    input [3:0] ALUControl,
    input MemWrite,
    input [1:0] ResultSrc,
    input [1:0] operation_byte_size, 
    
    input [2:0] MemResultCtr,

    output [6:0] op,
    output [2:0] funct3,
    output funct7_5,
   
    output Zero,
    output Negative,
    output Overflow,
    output CarryOut,

    input [4:0] Debug_Source_select,
    output [31:0] Debug_out,

    output [31:0] fetchPC,

    output [31:0]ALUResult,
    
    input [1:0] UARTOp,
    input [1:0] RegWriteSrcSelect,

    input rx,
    output tx
);

wire [31:0] PCNext;
wire [31:0] PC;
wire [31:0] Instr;
wire [31:0] PCPlus4;
wire [31:0] PCTarget;
wire [31:0] ImmExt;

wire [31:0] WriteData;
wire [31:0] SrcA;
wire [31:0] SrcB;
wire [31:0] MemReadResult;
wire [31:0] ReadData;
wire [31:0] Result;
wire [4:0] write_dest;
wire [31:0] WD3;

wire DataReadFromLine;
wire [31:0] FIFOOut;
wire [31:0] UARTReadData;

assign fetchPC = PC;

mux_4to1 #(.WIDTH(32)) mux_b_pc(.select(PCSrc), .input_0(PCPlus4), .input_1(PCTarget), .input_2(ALUResult), .input_3(32'b0), .output_value(PCNext));

register_rsten #(.WIDTH(32)) pc_reg(.clk(clk), .reset(reset), .we(1'b1), .data(PCNext), .out(PC));

instruction_memory #(.BYTE_SIZE(4), .ADDR_WIDTH(32)) inst_mem(.addr(PC), .Rd(Instr));
assign op = Instr[6:0];
assign funct3 = Instr[14:12];
assign funct7_5 = Instr[30];
assign write_dest = Instr[11:7];

adder pc_4_adder(.data_a(PC), .data_b(32'h0000_0004), .out(PCPlus4));

mux_4to1 #(.WIDTH(32)) mux_b_reg_f(.select(RegWriteSrcSelect), .input_0(PCPlus4), .input_1(PCTarget), .input_2(Result), .input_3(FIFOOut), .output_value(WD3));

register_file r_file(.clk(clk), .write_enable(RegWrite), .reset(reset), .Source_select_0(Instr[19:15]), .Source_select_1(Instr[24:20]), .Debug_Source_select(Debug_Source_select), .Destination_select(write_dest), .DATA(WD3), .out_0(SrcA), .out_1(WriteData), .Debug_out(Debug_out));

extender ext(.control(ImmSrc), .in(Instr), .out(ImmExt));

adder pc_imm_adder(.data_a(PC), .data_b(ImmExt), .out(PCTarget));

mux_2to1 #(.WIDTH(32)) mux_b_alu(.select(ALUSrc), .input_0(WriteData), .input_1(ImmExt), .output_value(SrcB));

reg CI;
alu alu_dp(.control(ALUControl), .DATA_A(SrcA), .DATA_B(SrcB), .OUT(ALUResult), .CI(CI), .CO(CarryOut), .OVF(Overflow), .N(Negative), .Z(Zero));

data_memory #(.ADDR_WIDTH(32), .BYTE_SIZE(4)) d_mem(.clk(clk), .WE(MemWrite), .ADDR(ALUResult), .operation_byte_size(operation_byte_size), .WD(WriteData), .RD(MemReadResult));

fifo #(.WIDTH(32), .DEPTH(4)) fifo_(.clk(clk), .UARTOp(UARTOp), .reset(reset), .write(DataReadFromLine),  .data_in(UARTReadData), .data_out(FIFOOut));
uart uart_(.clk(CLK100MHZ), .UARTOp(UARTOp), .WriteData(WriteData[7:0]), .ReadData(UARTReadData), .DataReadFromLine(DataReadFromLine), .rx(rx), .tx(tx));

mem_res_extender mr_ext(.in(MemReadResult), .out(ReadData), .control(MemResultCtr));

mux_4to1 #(.WIDTH(32)) mux_a_mem(.select(ResultSrc), .input_0(ALUResult), .input_1(ReadData), .input_2(PCPlus4), .input_3(32'b0), .output_value(Result));


endmodule