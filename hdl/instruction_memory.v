module instruction_memory #(BYTE_SIZE=4, ADDR_WIDTH=32)(
input [ADDR_WIDTH-1:0] addr,
output [(BYTE_SIZE*8)-1:0] Rd 
);

reg [7:0] mem [255:0];

initial begin
$readmemh("Instructions.hex", mem, 0); // You will need this for real tests
end

genvar i;
generate
	for (i = 0; i < BYTE_SIZE; i = i + 1) begin: read_generate
		assign Rd[8*i+:8] = mem[addr+i];
	end
endgenerate

endmodule