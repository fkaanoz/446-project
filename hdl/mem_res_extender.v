module mem_res_extender (
    output reg [31:0] out,
    input [31:0] in,
    input [2:0] control
);

always @(*) begin
    case (control)
        3'b000: out = in;    // default case => NON Load instruction will be there
        3'b001: out = {{24{in[7]}}, in[7:0]};      // for lb => load byte
        3'b010: out = {{16{in[15]}}, in[15:0]};    // for lh => load half 
        3'b011: out = in;       // lw
        3'b100: out = {{24{1'b0}}, in[7:0]};       // lbu
        3'b101: out = {{16{1'b0}}, in[15:0]};      // lhu
        default: out = in;
    endcase
end

endmodule