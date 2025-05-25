module cond_unit(
    input [2:0]funct3,
    
    input Zero,
    input Overflow,
    input Negative,
    input CarryOut,

    output reg isCondSatisfied
);

always @(*) begin
    case (funct3)
        3'b000 : isCondSatisfied = Zero;                         // Equal
        3'b001 : isCondSatisfied = ~Zero;                        // Not equal
        3'b100 : isCondSatisfied = Negative ^ Overflow;          // Less than (signed)
        3'b101 : isCondSatisfied = ~(Negative ^ Overflow);       // Greater than or equal (signed)
        3'b110 : isCondSatisfied = ~CarryOut;                    // Less than (unsigned)
        3'b111 : isCondSatisfied = CarryOut;                     // Greater than or equal (unsigned)
        default: isCondSatisfied = 1'b0;
    endcase
end


endmodule