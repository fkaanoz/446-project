module adder(
	  input	[31:0] data_a,
	  input	[31:0] data_b,
	  output [31:0] out
    );
	 
assign out = data_a + data_b;
	 
endmodule	 