//FILE: registers for obstacle and player positon (lane)
//		  and gameState determiner

//obstacle register
module obstacleRegister (
	input clk,
	input [2:0] randomIn, 
	input loadObstacle, CounterClear,
	
	output reg [2:0] obstaclePos);
	
	always @(posedge clk)
	begin
		if (CounterClear)
			obstaclePos <= 3'b000;
		if (loadObstacle)
			obstaclePos <= randomIn;
	end
endmodule

//player lane register
module playerRegister (
	input clk,
	input [2:0] laneMap,
	input MLChange, LMChange, MRChange, RMChange, StartLoad, CounterClear,
	
	output reg [2:0] playerPos);
	
	always @(posedge clk)
	begin
		if (CounterClear)
			playerPos <= 3'b010;
		if (MLChange | LMChange | MRChange | RMChange | StartLoad)
			playerPos <= laneMap;
	end
endmodule

//banana register
module bananaRegister (
	input clk,
	input [2:0] randomBanana,
	input loadBanana, CounterClear,
	
	output reg [2:0] bananaPos);
	
	always @(posedge clk)
	begin
		if (CounterClear)
			bananaPos <= 3'b000;
		if (loadBanana) 
			bananaPos <= randomBanana;
	end
endmodule


//determine game state from the outputs of player register and obstacle register
module gameStateDetermine (
	input clk,
	input [2:0] playerPos, obstaclePos,
	input checkGameState, CounterClear,
	
	output reg [1:0] gameState,
	output reg runOver);
	
	reg temp;
	
	always @(posedge clk)
	begin
		if (CounterClear) begin
			gameState <= 2'b10;
			runOver <= 1'b0;
			temp <= 1'b1;
		end
		else if (checkGameState) begin
			if ((playerPos[0] & obstaclePos[0]) | (playerPos[1] & obstaclePos[1]) | (playerPos[2] & obstaclePos[2])) begin
				if (temp == 1'b1) begin
					gameState <= gameState - 1'b1;
					runOver <= 1'b1;
					temp <= 1'b0;
				end
				else
					runOver <= 1'b0;
			end 
		end
		else
			temp <= 1'b1;
	end
	
endmodule


//register for producing a prolonged runOver signal
module explosionLength(
	input clk,
	input CounterClear, runOver, reset,
	output reg drawExplosion);
	
	always @(posedge clk)
	begin
		if (CounterClear)
			drawExplosion <= 0;
		else if (runOver)
			drawExplosion <= 1;
		else if (reset)
			drawExplosion <= 0;
	end
endmodule


//determine the state of the player based on the postion of the banana
module bananaDetermine (
	input clk,
	input [2:0] playerPos, bananaPos,
	input CheckBanana,
	
	output reg bananaState);
	
	//bananaState: 1 = miss, 0 = hit;
	always @(posedge clk)
	begin
		if (CheckBanana)
			bananaState <= ~((playerPos[0] & bananaPos[0]) | (playerPos[1] & bananaPos[1]) | (playerPos[2] & bananaPos[2]));
		else
			bananaState <= 1'b1;
	end
	
endmodule


//ai path finding
module aipath (
	input clk,
	input AICheckBanana, AICheckCar,
	input [2:0] bananaPos, obstaclePos, playerPos,
	output reg [2:0] steps);
	
	always @(posedge clk)
	begin
		if (AICheckBanana) begin
			if (~((playerPos[0] & bananaPos[0]) | (playerPos[1] & bananaPos[1]) | (playerPos[2] & bananaPos[2])))
				steps <= 3'd0;
			else if (playerPos == 3'b100 & bananaPos == 3'b100)
				steps <= 3'd1;
			else if (playerPos == 3'b100 & bananaPos == 3'b110)
				steps <= 3'd3;
			else if (playerPos == 3'b100 & bananaPos == 3'b101)
				steps <= 3'd1;
			else if (playerPos == 3'b010 & bananaPos == 3'b110)
				steps <= 3'd1;	
			else if (playerPos == 3'b010 & bananaPos == 3'b011)
				steps <= 3'd2;	
			else if (playerPos == 3'b010 & bananaPos == 3'b010)
				steps <= 3'd2;	
			else if (playerPos == 3'b001 & bananaPos == 3'b011)
				steps <= 3'd4;
			else if (playerPos == 3'b001 & bananaPos == 3'b101)
				steps <= 3'd2;
			else if (playerPos == 3'b001 & bananaPos == 3'b001)
				steps <= 3'd2;	
		end
		else if (AICheckCar) begin
			if (~((playerPos[0] & obstaclePos[0]) | (playerPos[1] & obstaclePos[1]) | (playerPos[2] & obstaclePos[2])))
				steps <= 3'd0;
			else if (playerPos == 3'b100 & obstaclePos == 3'b100)
				steps <= 3'd1;
			else if (playerPos == 3'b100 & obstaclePos == 3'b110)
				steps <= 3'd3;
			else if (playerPos == 3'b100 & obstaclePos == 3'b101)
				steps <= 3'd1;
			else if (playerPos == 3'b010 & obstaclePos == 3'b110)
				steps <= 3'd1;	
			else if (playerPos == 3'b010 & obstaclePos == 3'b011)
				steps <= 3'd2;	
			else if (playerPos == 3'b010 & obstaclePos == 3'b010)
				steps <= 3'd2;	
			else if (playerPos == 3'b001 & obstaclePos == 3'b011)
				steps <= 3'd4;
			else if (playerPos == 3'b001 & obstaclePos == 3'b101)
				steps <= 3'd2;
			else if (playerPos == 3'b001 & obstaclePos == 3'b001)
				steps <= 3'd2;	
		end
			
	end
	
endmodule
