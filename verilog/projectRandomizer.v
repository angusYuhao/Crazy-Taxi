//FILE: contains 3 bit random number generators for obstacle and banana 

//generates a 3 bit random number every clk cycle
module randomNum3bit (input clk, randomEn, output [2:0] oLine);
	wire [2:0] seedIn;
	reg [2:0] Q;
	wire allOnes, firstIn;
	
	assign seedIn = 3'b011;
	assign firstIn = Q[0] ^ Q[1];
	assign allOnes = (Q[2] & Q[1] & Q[0]);
	
	always @(posedge clk)
	begin
		if (randomEn) 
			Q <= seedIn;
		else
			begin
				Q[2] <= firstIn;
				Q[1] <= Q[2];
				Q[0] <= Q[1];
			end
	end
	
	assign oLine = allOnes ? seedIn : Q;
	
endmodule


// randomizer for bananas
module randomBanana (input clk, reset, outputEn, output reg [2:0] randomOut);
	wire [2:0] seedIn;
	reg [2:0] Q;
	wire allOnes, firstIn;
	
	assign seedIn = 3'b100;
	assign firstIn = Q[0] ^ Q[1];
	assign allOnes = (Q[2] & Q[1] & Q[0]);
	
	always @(posedge clk)
	begin
		if (reset) 
			Q <= seedIn;
		else
			begin
				Q[2] <= firstIn;
				Q[1] <= Q[2];
				Q[0] <= Q[1];
			end
		if (outputEn)
			if (allOnes)
				randomOut <= seedIn;
			else
				randomOut <= Q;
	end
	
endmodule
