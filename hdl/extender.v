module extender (
    output reg [31:0] out,
    input [31:0] in,
    input [2:0] control
);

always @(*) begin
    case (control)
        3'b000: out = {{20{in[31]}}, in[31:20]};    // sign extend for I TYPE 
        3'b001: out = {{20{in[31]}}, in[31:25], in[11:7]};
        3'b010: out = {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0};
        3'b011: out = {{12{in[31]}}, in[19:12], in[20], in[30:21], 1'b0};
        3'b100: out = {{in[31:12]}, {12{1'b0}}};
        3'b101: out = {{20{1'b0}}, in[31:20]};      // zero extend for I TYPE
        default: out = 32'd0;
    endcase
end
endmodule