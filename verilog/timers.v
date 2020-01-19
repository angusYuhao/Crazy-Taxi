//FILE: game logic counters

//control unit for the two counters: provides signal for changing state and cycle
module counterControl (
	input clk, CycleWaitCounterEn, ChangeStateCounterEn, CounterClear, AIClear, ScoreInc, StartRecover, runOver, startStep, startRelease,
	output changeState, startCycle, recover, explosionDone, stepDone,releaseDone,
	output reg timeUp,
	output [9:0] score);
	
	wire [25:0] DCquarterOut;
	wire [25:0] DChalfOut;
	wire [25:0] DCGwholeOut;
	wire [25:0] recoverOut;
	wire [25:0] explosionOut;
	wire [25:0] aiOut, releaseOut;
	wire [5:0] timeEllapsed;
	wire secEn;
	
	DCquartersec unit1 (clk, changeState, ChangeStateCounterEn, CounterClear, DCquarterOut);
	DCwholesec unit2 (clk, startCycle, CycleWaitCounterEn, CounterClear, DChalfOut);
	Gwholesec unit3 (clk, secEn, CounterClear, DCGwholeOut);
	gameSeconds unit4 (clk, secEn, CounterClear, timeEllapsed);
	scoreCounter unit5 (clk, ScoreInc, CounterClear, score);
	recoverCounter unit6 (clk, recover, CounterClear, StartRecover, recoverOut);
	explosionCounter unit7(clk, runOver, CounterClear, explosionOut);
	aiCounter unit8 (clk, AIClear, startStep, stepDone, aiOut);
	releaseCounter unit9 (clk, AIClear, startRelease, releaseDone, releaseOut);
	
	assign changeState = ~(|DCquarterOut);
	assign startCycle = ~(|DChalfOut);
	assign secEn = ~(|DCGwholeOut);
	assign timeUpPulse = (&timeEllapsed);
	assign recover = ~(|recoverOut);
	assign explosionDone = ~(|explosionOut);
	assign stepDone = ~(|aiOut);
	assign releaseDone = ~(|releaseOut);
	
	always @(posedge clk)
	begin
		if (CounterClear)
			timeUp = 0;
		else if (timeUpPulse)
			timeUp = 1;
	end
endmodule


//counter for changing obstacle state
module DCquartersec (input clk, loadEn, ChangeStateCounterEn, CounterClear, output reg [25:0] Q);
	always @(posedge clk)
	begin
		if (CounterClear)
			Q <= 26'd0;
		else if (loadEn & ChangeStateCounterEn)
			Q <= 26'd5880000;
		else
			Q <= Q - 1;
	end
endmodule


//counter for changing obstacle cycle
module DCwholesec (input clk, loadEn, CycleWaitCounterEn, CounterClear, output reg [25:0] Q);
	always @(posedge clk) 
	begin
		if (CounterClear)
			Q <= 26'd0;
		else if(loadEn & CycleWaitCounterEn)
			Q <= 26'd50000000;
		else
			Q <= Q - 1;
	end
endmodule


//up counter for counting seconds since game started
module gameSeconds (
	input clk, secondIn, CounterClear,
	output reg [5:0] timeEllapsed);
	
	always @(posedge clk)
	begin
		if (CounterClear)
			timeEllapsed <= 0;
		else if (secondIn)
			timeEllapsed <= timeEllapsed + 1;
	end
endmodule


//down counter for game seconds
module Gwholesec (
	input clk, loadEn, CounterClear, 
	output reg [25:0] Q);
	
	always @(posedge clk) 
	begin
		if (CounterClear)
			Q <= 26'd0;
		else if(loadEn)
			Q <= 26'd50000000;
		else
			Q <= Q - 1;
	end
endmodule


//score counter increment every cycle
module scoreCounter (
	input clk, ScoreInc, CounterClear,
	output reg [9:0] score);
	
	always @(posedge clk)
	begin
		if (CounterClear)
			score <= 0;
		if (ScoreInc)
			score <= score + 1;
	end
endmodule


//recover counter 1 second
module recoverCounter (
	input clk, loadEn, CounterClear, StartRecover,
	output reg [25:0] Q);
	
	always @(posedge clk) 
	begin
		if (CounterClear)
			Q <= 26'd0;
		else if (StartRecover)
			if(loadEn)
				Q <= 26'd50000000;
			else
				Q <= Q - 1;
	end
endmodule


//eighth second counter for changing obstacle state
module explosionCounter (input clk, runOver, CounterClear, output reg [25:0] Q);
	always @(posedge clk)
	begin
		if (CounterClear)
			Q <= 26'd0;
		else if (runOver)
			Q <= 26'd15000000;
		else
			Q <= Q - 1;
	end
endmodule


//counter for AI decisions
module aiCounter (input clk, CounterClear, timerEnable, enable, output reg [25:0] Q);
	always @(posedge clk)
	begin
		if (CounterClear)
			Q <= 26'd1;
		else if (timerEnable & enable)
			Q <= 26'd3528985;
			
		else
			Q <= Q - 1;
	end
endmodule


//counter for AI inaction
module releaseCounter (input clk, CounterClear, timerEnable, enable, output reg [25:0] Q);
	always @(posedge clk)
	begin
		if (CounterClear)
			Q <= 26'd1;
		else if (timerEnable & enable)
			Q <= 26'd50000;
			
		else
			Q <= Q - 1;
	end
endmodule

	