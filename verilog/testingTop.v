//file: top modules for testing

//NOTE ON READING NAMES:
//	states					: all lower
//	FSM output signals	: capital first letter of every word
//	FSM input signals 	: capital first letter of every word except for first word

//MODULE FOR TESTING GAMESTATEFSM WITH COUNTERS ONLY
module gameStateFSMTest (
	input [3:0] KEY,
	input CLOCK_50,
	
	output [9:0] LEDR,
	output [6:0] HEX0, HEX1);
	
	wire StartScreen, EndScreen, GameScreen, LdNewObstacle, CheckGameState, CycleWaitCounterEn, ChangeStateCounterEn;
	wire changeState, startCycle;
	wire [7:0] Position;
	
	counterControl timers (CLOCK_50, CycleWaitCounterEn, ChangeStateCounterEn, CounterClear, changeState, startCycle);
	
	//manual control: startGame: KEY[0]
	//						gameState: KEY[1]
	//						restart	: KEY[2]
	gameStateFSM GSFSM (CLOCK_50, changeState, ~KEY[1], ~KEY[0], startCycle, ~KEY[2], 
							 StartScreen, EndScreen, GameScreen, LdNewObstacle, CheckGameState, CycleWaitCounterEn, ChangeStateCounterEn, CounterClear,
							 Position);
	
	HEXdecoder pos1 (Position[7:4], HEX1);
	HEXdecoder pos2 (Position[3:0], HEX0);
	
	assign LEDR[0] = StartScreen;
	assign LEDR[1] = EndScreen;
	assign LEDR[2] = GameScreen;
	assign LEDR[3] = LdNewObstacle;
	assign LEDR[4] = CheckGameState;
	assign LEDR[5] = CycleWaitCounterEn;
	assign LEDR[6] = ChangeStateCounterEn;
	assign LEDR[7] = CounterClear;
	
endmodule


//MODULE FOR TESTING GAMESTATEFSM WITH COUNTERS AND GAMESTATE SIGNAL
module gameFSMCompleteTest (
	input [3:0] KEY,
	input CLOCK_50,
	
	output [9:0] LEDR,
	output [6:0] HEX0, HEX1, HEX2, HEX3);
	
	//player controlled signals
	wire startGame, restart, shiftLeft, shiftRight;
	
	//DE1-soc control scheme
	assign startGame = ~KEY[3];
	assign restart = ~KEY[2];
	assign shiftLeft = ~KEY[1];
	assign shiftRight = ~KEY[0];
	
	//signals available for VGA display
	//MLChange, LMChange, MRChange, RMChange, StartScreen, EndScreen, GameScreen, playerPos, obstaclePos, LdNewObstacle, Position
	
	//universal clock
	wire clock;
	assign clock = CLOCK_50;
	
	//input signals to GSFSM
	wire changeState, gameState, startCycle, timeUp;
	
	//output signals from GSFSM 
	wire StartScreen, EndScreen, GameScreen, LdNewObstacle, CheckGameState, CycleWaitCounterEn, ChangeStateCounterEn, CounterClear, ScoreInc, MoveObstacle;
	wire [7:0] Position;
	
	//remaining input signals to PLFSM
	wire gameOver;
	assign gameOver = EndScreen;
	
	//output signals from PLFSM
	wire MLChange, LMChange, MRChange, RMChange, StartLoad;
	wire [2:0] LaneMap;
	
	//remaining signals for PRT and ORT
	wire [2:0] playerPos, obstaclePos;
	
	//randomizer signals
	wire [2:0] randomIn;
	
	//game score (display on EndScreen)
	wire [9:0] score;
	
	
	//module instantiations
	counterControl timers (clock, CycleWaitCounterEn, ChangeStateCounterEn, CounterClear, ScoreInc, changeState, startCycle, timeUp, score);
	
	gameStateFSM GSFSM (clock, changeState, gameState, startGame, startCycle, restart, timeUp,
							 StartScreen, EndScreen, GameScreen, LdNewObstacle, CheckGameState, CycleWaitCounterEn, ChangeStateCounterEn, CounterClear, ScoreInc,
							 MoveObstacle, Position);
	
	playerLaneFSM PLFSM (clock, shiftLeft, shiftRight, startGame, gameOver, restart, 
								MLChange, LMChange, MRChange, RMChange, StartLoad, 
								LaneMap);
	
	playerRegister PRT (clock, LaneMap, MLChange, LMChange, MRChange, RMChange, StartLoad, playerPos);
	
	obstacleRegister ORT (clock, randomIn, LdNewObstacle, obstaclePos);
	
	gameStateDetermine GSD (clock, playerPos, obstaclePos, CheckGameState, gameState);
	
	randomNum3bit RAND (clock, startGame, randomIn);
	
	HEXdecoder pos1 (Position[7:4], HEX1);
	HEXdecoder pos2 (Position[3:0], HEX0);
	HEXdecoder score1 (score[7:4], HEX3);
	HEXdecoder score2 (score[3:0], HEX2);
	
	assign LEDR[9] = StartScreen;
	assign LEDR[8] = EndScreen;
	assign LEDR[7] = GameScreen;
	assign LEDR[6:4] = obstaclePos;
	assign LEDR[2:0] = playerPos;
	
endmodule


//MODULE FOR TESTING PLAYERLANEFSM AND REGISTERS ONLY
module playerLaneFSMTest (
	input CLOCK_50,
	input [3:0] KEY,
	input [9:0] SW,
	
	output [9:0] LEDR);
	
	wire shiftLeft, shiftRight, startGame, gameOver, restart;
	wire MLChange, LMChange, MRChange, RMChange, StartLoad;
	wire [2:0] LaneMap, playerPos;
	
	//manual controls
	assign gameOver = ~KEY[3];
	assign startGame = ~KEY[2];
	assign shiftLeft = ~KEY[1];
	assign shiftRight = ~KEY[0];
	assign restart = SW[0];
	
	playerLaneFSM PLFSM (CLOCK_50, shiftLeft, shiftRight, startGame, gameOver, restart, MLChange, LMChange, MRChange, RMChange, StartLoad, LaneMap);
	
	playerRegister PR (CLOCK_50, LaneMap, MLChange, LMChange, MRChange, RMChange, StartLoad, playerPos);
	
	assign LEDR[2:0] = playerPos;
	assign LEDR[5:3] = LaneMap;
	assign LEDR[9] = MLChange;
	assign LEDR[8] = LMChange;
	assign LEDR[7] = MRChange;
	assign LEDR[6] = RMChange;
	
endmodule


//MODULE FOR TESTING RANDOM ONLY
module randomTop(input [0:0] KEY, input [0:0] SW, output [2:0] LEDR);
	randomNum3bit unit(KEY[0], SW[0], LEDR[2:0]);
endmodule


//7seg display module
module HEXdecoder(numIn, HEX);
    input [3:0] numIn;
    output reg [6:0] HEX;
   
    always @(*)
        case (numIn)
            4'h0: HEX = 7'b1000000;
            4'h1: HEX = 7'b1111001;
            4'h2: HEX = 7'b0100100;
            4'h3: HEX = 7'b0110000;
            4'h4: HEX = 7'b0011001;
            4'h5: HEX = 7'b0010010;
            4'h6: HEX = 7'b0000010;
            4'h7: HEX = 7'b1111000;
            4'h8: HEX = 7'b0000000;
            4'h9: HEX = 7'b0011000;
            4'hA: HEX = 7'b0001000;
            4'hB: HEX = 7'b0000011;
            4'hC: HEX = 7'b1000110;
            4'hD: HEX = 7'b0100001;
            4'hE: HEX = 7'b0000110;
            4'hF: HEX = 7'b0001110;   
            default: HEX = 7'h0;
        endcase
endmodule
			
