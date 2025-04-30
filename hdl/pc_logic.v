module pc_logic(
    input [2:0] funct3,
    
    input Zero,
    input Overflow,
    input Negative,
    input CarryOut,

    input Branch, 
    input Jump, 

    output reg [1:0] PCSrc
);

wire isCondSatisfied;

cond_unit c_unit(.Zero(Zero), .Negative(Negative), .CarryOut(CarryOut), .Overflow(Overflow), .funct3(funct3), .isCondSatisfied(isCondSatisfied));


always @(*)
begin
    if (Jump == 1'b1 & funct3 == 3'b000) begin
        PCSrc = 2'b10;  // JALR
    end else if (Jump == 1'b1 |( Branch == 1'b1 & isCondSatisfied == 1'b1)) begin
        PCSrc = 2'b01;  // JAL   or   Branch with satisfied condition
    end else begin
        PCSrc = 2'b00; 
    end
end

endmodule