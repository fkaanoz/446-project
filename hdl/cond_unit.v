module cond_unit(
    input [2:0]funct3,
    
    input Zero,
    input Overflow,
    input Negative,
    input CarryOut,

    output reg isCondSatisfied
);

always @(*)
begin
    case (funct3)
        3'b000 : isCondSatisfied = Zero;                    // Equal
        3'b001 : isCondSatisfied = ~Zero;                   // Not equal
        3'b100 : isCondSatisfied = Negative ^ Overflow;       // less than signed
        3'b101 : isCondSatisfied = (~Zero) & (~(Negative ^ Overflow));       // greater than equal signed
        3'b110 : isCondSatisfied = (~Zero) & (~CarryOut);       // less than UNSIGNED
        3'b111 : isCondSatisfied = Zero | CarryOut;             // greater than equal UNSIGNED
        default: isCondSatisfied = 1'b0;
    endcase
end

endmodule