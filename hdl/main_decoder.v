module main_decoder(
    input [6:0] op,
    input [2:0] funct3,
    input [1:0] UARTOp,

    output reg RegWrite,
    output reg [2:0] ImmSrc,
    output reg ALUSrc,
    output reg MemWrite,
    output reg Branch,
    output reg [1:0] ALUOp,
    output reg Jump,
    output reg [1:0] ResultSrc,

    output reg [1:0] operation_byte_size,
    output reg [2:0] MemResultCtr,

    output reg [1:0] RegWriteSrcSelect
);


always @(*)
begin
    // only for Str and B, it should be ZERO.
    RegWrite = ~(op[5:0] == 6'b100011) | (op[6:0] == 7'b1100111 | op[6:0] == 7'b1101111); 

    // ImmSrc => 3 bits
    case (op)
        7'b0000_011: ImmSrc = 3'b000;   // I type (LOAD)
        7'b0010_011: ImmSrc = (funct3 == 3'b001 | funct3 == 3'b101) ? 3'b101 : 3'b000;
        7'b0010_111: ImmSrc = 3'b100;   // U type
        7'b0100_011: ImmSrc = 3'b001;   // S type
        7'b0110_011: ImmSrc = 3'b000;   // think about it  => R type NOT USED
        7'b0110_111: ImmSrc = 3'b100;   // U type
        7'b1100_011: ImmSrc = 3'b010;   // B type
        7'b1100_111: ImmSrc = 3'b000;   // JALR   => I type !!!!
        7'b1101_111: ImmSrc = 3'b011;   // JAL
        default: ImmSrc = 3'b000;
    endcase

    // ALUSrc => 
    ALUSrc = ~(op[6:0] == 7'b0110_011 | op[6:0] == 7'b1100_011);        // for R and B types ALUSRC is ZERO

    // MemWrite
    MemWrite = (op[6:0] == 7'b0100_011);          // only for S type, it is ONE

    // Branch  => it is different than JUMP ! Be aware!
    Branch = (op[6:0] == 7'b1100_011);

    // ALUOp
    case (op)
        7'b0000_011: ALUOp =2'b00;      // load
        7'b0010_011: ALUOp =2'b10;      // arithmetic
        7'b0010_111: ALUOp =2'b00;   // Do not care
        7'b0100_011: ALUOp =2'b00;      //store
        7'b0110_011: ALUOp =2'b10;      // arithmetic
        7'b0110_111: ALUOp =2'b11;       // it will use move through !   => LUI
        7'b1100_011: ALUOp =2'b01;      //  Brach
        7'b1100_111: ALUOp =2'b00;      // JALR
        7'b1101_111: ALUOp =2'b00;   // Do not care
        default: ALUOp =2'b00;
    endcase

    // Jump
    Jump = (op == 7'b1101_111 | op ==  7'b1100_111);


    // ResultSrc
    ResultSrc[1] = (op == 7'b1101_111);     // only HIGH for JAL 
    ResultSrc[0] = (op == 7'b0000_011);     // only HIGH for LOAD


    // operation_byte_size   => Encoding not exact size!
    if({op, funct3} == 10'b01_0001_1000) begin // str byte
        operation_byte_size = 2'b00;            
    end else if({op, funct3} == 10'b01_0001_1001) begin     // str half word
        operation_byte_size = 2'b01; 
    end else begin
        operation_byte_size = 2'b11;        // otherwise it will be 4 byte long !
    end

    // MemResultCtr
    case ({op, funct3})
        10'b00_0001_1000: MemResultCtr = 3'b001;
        10'b00_0001_1001: MemResultCtr = 3'b010;
        10'b00_0001_1010: MemResultCtr = 3'b011;
        10'b00_0001_1100: MemResultCtr = 3'b100;
        10'b00_0001_1101: MemResultCtr = 3'b101;
        default: MemResultCtr = 3'b000;
    endcase

    // RegWriteSrcSelect
    case (op)
        7'b1101_111: RegWriteSrcSelect = 2'b00;           // KeepPC
        7'b1100_111: RegWriteSrcSelect = 2'b00;           // KeepPC   

        7'b0010_111: RegWriteSrcSelect = 2'b01;           // AUIPC


        // PC + 4 should be selected 
        7'b1100_111: RegWriteSrcSelect = 2'b00;           
        7'b1101_111: RegWriteSrcSelect = 2'b00;           

        default: begin 
            if(UARTOp == 2'b01) begin           // UART Read Case 
                 RegWriteSrcSelect = 2'b11;
            end else begin
                RegWriteSrcSelect = 2'b10;     // Result        
            end
        end     
    endcase

end

endmodule