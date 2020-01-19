//FILE: top modules for game logic


//complete game logic top module
module gameFSMCompleteTest (
	input aiMode, left, space, right,
	input CLK,
	input [9:9] sw, 
	input startGame,
	output [9:0] ledr,
	output [6:0] hex0, hex1, hex2, hex3,
	// this is the position for the up to down 0 is at top and 7 is at bottom same as car 
	output [7:0] Position,
	// where there is a 1, what lane has a car (just telling u theres a car) 
	output [2:0] obstaclePos, playerPos, bananaPos,
	output [3:0] stateOutput,
	output [9:0] score,
	output [1:0] gameState,
	output [4:0] aistate,
	output [2:0] steps,
	
	//signals for display modules
	output MLChange, LMChange, MRChange, RMChange, StartScreen, EndScreen, GameScreen, WinScreen, StartLoad, LdNewObstacle, 
				bananaEn, MoveObstacle, MoveBanana, TimeupOver, StartDraw, StartBanana, Confused, runOver, drawExplosion);
	
	//player controlled signals
	wire restart, shiftLeft, shiftRight;
	
	//control scheme
	assign restart = sw[9];
	assign shiftLeft = aiMode ? aiLeft: left;
	assign shiftRight = aiMode ? aiRight : right;
	
	//universal clock
	wire clock;
	assign clock = CLK;
	
	//input signals to GSFSM
	wire changeState, startCycle, timeUp, bananaState;
	
	//output signals from GSFSM 
	wire CheckGameState, CycleWaitCounterEn, ChangeStateCounterEn, CounterClear, ScoreInc, CheckBanana;
	
	//remaining input signals to PLFSM
	wire gameOver, recover;
	assign gameOver = EndScreen;
	
	//output signals from PLFSM
	wire StartRecover, OverConfirm;
	
	wire [2:0] LaneMap;
	wire [2:0] randomIn;
	wire [2:0] randBanana;
	
	wire explosionDone;
	wire AICheckCar, AICheckBanana;
	wire startStep, stepDone, startRelease, releaseDone;
	
	//AI signals
	wire LM, ML, RM, MR;
	wire AIClear;
	wire aiLeft, aiRight;
	assign aiLeft = (ML || RM);
	assign aiRight = (LM || MR);
	
	
	//module instantiations
	counterControl timers (clock, CycleWaitCounterEn, ChangeStateCounterEn, CounterClear, AIClear, ScoreInc, StartRecover, runOver, startStep, startRelease, changeState, startCycle, recover, explosionDone, stepDone, releaseDone,timeUp, score);
	
	gameStateFSM GSFSM (clock, changeState, startGame, startCycle, restart, timeUp, OverConfirm, gameState, score,
							 StartScreen, EndScreen, GameScreen, WinScreen, LdNewObstacle, CheckGameState, CycleWaitCounterEn, ChangeStateCounterEn, CounterClear, ScoreInc,
							 MoveObstacle, MoveBanana, TimeupOver, StartDraw, bananaEn, StartBanana, CheckBanana, AICheckCar, AICheckBanana, AIClear, Position);
	
	playerLaneFSM PLFSM (clock, shiftLeft, shiftRight, startGame, EndScreen, restart, bananaState, recover, 
								MLChange, LMChange, MRChange, RMChange, StartLoad, StartRecover, OverConfirm, Confused,
								LaneMap, stateOutput);
	

	AIFSM AFSM (clock, stepDone, releaseDone, steps, playerPos, AICheckCar, AICheckBanana,LM, ML, RM, MR, startStep, startRelease, aistate);
	
	playerRegister PRT (clock, LaneMap, MLChange, LMChange, MRChange, RMChange, StartLoad, CounterClear, playerPos);
	
	obstacleRegister ORT (clock, randomIn, LdNewObstacle, CounterClear, obstaclePos);
	
	bananaRegister BRT (clock, randBanana, bananaEn, CounterClear, bananaPos);
	
	gameStateDetermine GSD (clock, playerPos, obstaclePos, CheckGameState, CounterClear, gameState, runOver);
	
	bananaDetermine BND (clock, playerPos, bananaPos, CheckBanana, bananaState);
	
	randomNum3bit RAND (clock, startGame, randomIn);
	
	randomBanana RANDB (clock, startGame, bananaEn, randBanana);
	
	explosionLength EXPL (clock, CounterClear, runOver, explosionDone, drawExplosion);
	
	aipath AIP (clock, AICheckBanana, AICheckCar, bananaPos, obstaclePos, playerPos, steps);
	
	
endmodule

