module register_rsten #(parameter WIDTH=32) (
	  input  clk, reset,we,
	  input	[WIDTH-1:0] data,
	  output reg [WIDTH-1:0] out
    );

initial begin
	out<=0;
end	
	 
always@(posedge clk) begin
	if (reset == 1'b1)
		out<={WIDTH{1'b0}};
	else if(we==1'b1)	
		out<=data;
end

	 
endmodule	 