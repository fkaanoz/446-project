// some of the functionality NOT IMPLEMENTED YET

module alu #(parameter WIDTH=32)
    (
	  input [3:0] control,
	  input [WIDTH-1:0] DATA_A,
	  input [WIDTH-1:0] DATA_B,
      output reg [WIDTH-1:0] OUT,
	  
      input CI,
	  output reg CO,
	  output reg OVF,
	  output N, Z

    );


localparam Addition=4'b0000,
		  ShiftLeftLogical=4'b0001,  
		  SetLessThanSigned=4'b0010,
		  SetLessThanUnsigned=4'b0011,
		  EXOR=4'b0100,
		  ShiftRightLogical=4'b0101, 
		  ShifRightArithmetic=4'b0110,	
		  ORR=4'b0111,
		  AND=4'b1000,
		  SubtractionAB=4'b1011,
		  Move_Through=4'b1001,
		  Move_Not=4'b1010;

// Assign the zero and negative flasg here since it is very simple
assign N = OUT[WIDTH-1];
assign Z = ~(|OUT);
	 
always@(*) begin
	case(control)
		ShiftLeftLogical: begin
			OUT = DATA_A << DATA_B[4:0];
			CO = 1'b0;
			OVF = 1'b0;
		end

		ShiftRightLogical: begin
			OUT = DATA_A >> DATA_B[4:0];
			CO = 1'b0;
			OVF = 1'b0;
		end

		ShifRightArithmetic: begin
			OUT = DATA_A >>> DATA_B[4:0];
			CO = 1'b0;
			OVF = 1'b0;
		end


		SetLessThanUnsigned: begin
			OUT = ($unsigned(DATA_A) < $unsigned(DATA_B));
			CO = 1'b0;
			OVF = 1'b0;
		end

		SetLessThanSigned: begin
			OUT = ($signed(DATA_A) < $signed(DATA_B));
			CO = 1'b0;
			OVF = 1'b0;
		end

		AND:begin
			OUT = DATA_A & DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		EXOR:begin
			OUT = DATA_A ^ DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		SubtractionAB:begin
			{CO,OUT} =  DATA_A +  $unsigned(~DATA_B) +  1'b1;
			OVF = (DATA_A[WIDTH-1] & ~DATA_B[WIDTH-1] & ~OUT[WIDTH-1]) | (~DATA_A[WIDTH-1] & DATA_B[WIDTH-1] & OUT[WIDTH-1]);
		end
		Addition:begin
			{CO,OUT} = DATA_A + DATA_B;
			OVF = (DATA_A[WIDTH-1] & DATA_B[WIDTH-1] & ~OUT[WIDTH-1]) | (~DATA_A[WIDTH-1] & ~DATA_B[WIDTH-1] & OUT[WIDTH-1]);
		end
		ORR:begin
			OUT = DATA_A | DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		Move_Through:begin
			OUT = DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		Move_Not:begin
			OUT = ~DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
        
		default:begin
            OUT = {WIDTH{1'b0}};
            CO = 1'b0;
            OVF = 1'b0;
		end
	endcase
end
	 
endmodule	 