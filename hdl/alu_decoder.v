module alu_decoder(
    input funct7_5,
    input op_5,
    input [2:0] funct3,
    input [1:0] ALUOp,

    output reg [3:0] ALUControl
);

always @(*)
begin
    case(ALUOp)
        2'b00: ALUControl = 4'b0000;         // ADD
        2'b01: ALUControl = 4'b1011;         // SUB
        2'b10: begin
            case(funct3)
                3'b000: begin
                    ALUControl = {op_5,funct7_5} == 2'b11 ? 4'b1011 : 4'b0000;
                end
                3'b001: ALUControl = 4'b0001;
                3'b010: ALUControl = 4'b0010;
                3'b011: ALUControl = 4'b0011;
                3'b100: ALUControl = 4'b0100;
                3'b101: begin
                    ALUControl = funct7_5 == 1'b1 ? 4'b0110 : 4'b0101;
                end
                3'b110: ALUControl = 4'b0111;
                3'b111: ALUControl = 4'b1000;
            endcase
            end
        2'b11: ALUControl = 4'b1001;
    endcase
end

endmodule