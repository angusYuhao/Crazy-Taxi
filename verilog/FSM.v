//FILE: display FSM and maybe other stuff lmao

//NOTE ON READING NAMES:
//	states					: all lower
//	FSM output signals	: capital first letter of every word
//	FSM input signals 	: capital first letter of every word except for first word


//general gameState FSM
module gameStateFSM (
	//clock
	input clk,
	
	//state changing signals
	input changeState, startGame, startCycle, restart, timeUp, OverConfirm,
	input [1:0] gameState,
	input [9:0] score,
	
	//output signals
	output reg StartScreen, EndScreen, GameScreen, WinScreen, LdNewObstacle, CheckGameState, CycleWaitCounterEn, ChangeStateCounterEn, CounterClear, ScoreInc,
	output reg MoveObstacle, MoveBanana, TimeupOver, StartDraw, LoadBanana, StartBanana, CheckBanana, AICheckCar, AICheckBanana, AIClear,
	output reg [7:0] Position
	);
	
	
	reg [4:0] currentState, nextState;
	localparam	
					start		= 5'd0,
					cycle		= 5'd1,
					cyclewait= 5'd2,
					c1 		= 5'd3,
					c1wait	= 5'd4,
					c2			= 5'd5,
					c2wait	= 5'd6,
					c3			= 5'd7,
					c3wait	= 5'd8,
					c4			= 5'd9,
					c4wait	= 5'd10,
					c5			= 5'd11,
					c5wait	= 5'd12,
					c6			= 5'd13,
					c6wait	= 5'd14,
					c7			= 5'd15,
					c7wait	= 5'd16,
					c8			= 5'd17,
					c8wait	= 5'd18,
					check		= 5'd19,
					checkwait= 5'd20,
					over		= 5'd21,
					timeover = 5'd22,
					restartwait = 5'd23,
					win		= 5'd24;

	//state table
	always @(*)
	begin
		case(currentState)
			start : nextState = startGame ? cycle : start;
			cycle: nextState = changeState ? cyclewait : cycle;
			cyclewait: nextState = changeState ? cyclewait : c1;
			c1		: 
			begin
				if (changeState)
					nextState = c1wait;
				else if (~changeState)
					nextState = c1;
			end
			c1wait: nextState = changeState ? c1wait : c2;
			c2		: nextState = changeState ? c2wait : c2;
			c2wait: nextState = changeState ? c2wait : c3;
			c3		: nextState = changeState ? c3wait : c3;
			c3wait: nextState = changeState ? c3wait : c4;
			c4		: nextState = changeState ? c4wait : c4;
			c4wait: nextState = changeState ? c4wait : c5;
			c5		: nextState = changeState ? c5wait : c5;
			c5wait: nextState = changeState ? c5wait : c6;
			c6		: nextState = changeState ? c6wait : c6;
			c6wait: nextState = changeState ? c6wait : c7;
			c7		: nextState = changeState ? c7wait : c7;
			c7wait: nextState = changeState ? c7wait : c8;
			c8		: nextState = changeState ? c8wait : c8;
			c8wait: nextState = changeState ? c8wait : check;
			check	: nextState = changeState ? checkwait : check;
			checkwait:
			begin
				if (gameState == 2'b00)
					nextState = over;
				else if (score == 10'd30)
					nextState = win;
				else
					nextState = c1;
			end
			over 	: nextState = restart ? restartwait : over;
			timeover: nextState = restart? restartwait : timeover;
			restartwait: nextState = restart? restartwait : start;
			win: nextState = restart? restartwait : win;
			default: nextState = start;
		endcase
	end
	
	//output logic
	always @(*)
	begin: control_signal_gameState
	
		//default values of control signals
		StartScreen = 1'b0;
		EndScreen = 1'b0;
		GameScreen = 1'b1;
		LdNewObstacle = 1'b0;
		CheckGameState = 1'b0;
		CycleWaitCounterEn = 1'b0;
		ChangeStateCounterEn = 1'b0;
		CounterClear = 1'b0;
		Position = 8'b0;
		ScoreInc = 1'b0;
		MoveObstacle = 1'b1;
		MoveBanana = 1'b1;
		TimeupOver = 1'b0;
		StartDraw = 1'b0;
		LoadBanana = 1'b0;
		StartBanana = 1'b0;
		CheckBanana = 1'b0;
		WinScreen = 1'b0;
		AICheckCar = 1'b0;
		AICheckBanana = 1'b0;
		AIClear = 1'b0;
		
		
		case(currentState) 
			start: 
			begin
				AIClear = 1'b1;
				StartScreen = 1'b1;
				GameScreen = 1'b0;
				CounterClear = 1'b1;
				MoveObstacle = 1'b0;
				MoveBanana = 1'b0;
			end
			cycle: 
			begin
				ChangeStateCounterEn = 1'b1;
				MoveObstacle = 1'b0;
				MoveBanana = 1'b0;
			end
			c1: 
			begin
				LdNewObstacle = 1'b1;
				Position[0] = 1'b1;
				ChangeStateCounterEn = 1'b1;
			end
			c1wait: begin 
				AIClear = 1'b1;
				StartDraw = 1'b1; 
			end 
			c2:
			begin
				Position[1] = 1'b1;
				ChangeStateCounterEn = 1'b1;
			end
			c3:
			begin
				Position[2] = 1'b1;
				ChangeStateCounterEn = 1'b1;
				CheckBanana = 1'b1;
			end
			c4:
			begin
				Position[3] = 1'b1;
				ChangeStateCounterEn = 1'b1;
				LoadBanana = 1'b1;
			end
			c4wait: StartBanana = 1'b1;
			c5:
			begin
				Position[4] = 1'b1;
				ChangeStateCounterEn = 1'b1;
			end
			c6:
			begin
				Position[5] = 1'b1;
				ChangeStateCounterEn = 1'b1;
			end
			c6wait: AICheckCar = 1'b1;
			c7: 
			begin
				Position[6] = 1'b1;
				ChangeStateCounterEn = 1'b1;
			end
			c8:
			begin
				Position[7] = 1'b1;
				ChangeStateCounterEn = 1'b1;
			end
			check:
			begin
				CheckGameState = 1'b1;
				ChangeStateCounterEn = 1'b1;
			end
			checkwait: 
			begin
				AICheckBanana = 1'b1;
				ScoreInc = 1'b1;
			end
			over:
			begin
				EndScreen = 1'b1;
				GameScreen = 1'b0;
				MoveObstacle = 1'b0;
				MoveBanana = 1'b0;
			end
			timeover:
			begin
				TimeupOver = 1'b1;
				GameScreen = 1'b0;
				MoveObstacle = 1'b0;
				MoveBanana = 1'b0;
			end
			restartwait:
			begin
				CounterClear = 1'b1;
				MoveObstacle = 1'b0;
				AIClear = 1'b1;
				MoveBanana = 1'b0;
			end
			win:
			begin
				WinScreen = 1'b1;
				GameScreen = 1'b0;
				MoveObstacle = 1'b0;
				MoveBanana = 1'b0;
			end
		endcase
	end
	
	//state transition
	always @(posedge clk)
	begin
		if (restart) 
			currentState <= start;
		else if (OverConfirm)
			currentState <= over;
		else
			currentState <= nextState;
	end
	
endmodule


//player lane control FSM
module playerLaneFSM (
	input clk,
	input shiftLeft, shiftRight, startGame, gameOver, restart, bananaState, recover,
	output reg MLChange, LMChange, MRChange, RMChange, StartLoad, StartRecover, OverConfirm, Confused,
	output reg [2:0] LaneMap,
	output [3:0] stateOutput);
	
	
	assign stateOutput = currentState;
	
	reg [3:0] currentState, nextState;
	
	localparam	initpos	= 4'd1,
					startwait= 4'd2,
					middle	= 4'd3,
					left		= 4'd4,
					right		= 4'd5,
					mlwait	= 4'd6,
					lmwait	= 4'd7,
					mrwait	= 4'd8,
					rmwait	= 4'd9,
					middleHit= 4'd10,
					leftHit  = 4'd11,
					rightHit = 4'd12,
					overwait = 4'd13,
					over 		= 4'd14;
	
	//state table
	always @(*)
	begin
		case(currentState)
			initpos: nextState = startGame ? startwait : initpos;
			startwait: nextState = startGame ? startwait : middle;
			middle:
			begin
				if (gameOver) nextState = over;
				else if (~bananaState) nextState = middleHit;
				else if (shiftLeft) nextState = mlwait;
				else if (shiftRight) nextState = mrwait;
				else nextState = middle;
			end
			left:
			begin
				if (gameOver) nextState = over;
				else if (~bananaState) nextState = leftHit;
				else if (shiftLeft) nextState = left;
				else if (shiftRight) nextState = lmwait;
				else nextState = left;
			end
			right:
			begin
				if (gameOver) nextState = over;
				else if (~bananaState) nextState = rightHit;
				else if (shiftLeft) nextState = rmwait;
				else if (shiftRight) nextState = right;
				else nextState = right;
			end
			mlwait: 
			begin
				if (gameOver) nextState = over;
				else if (~bananaState) nextState = leftHit;
				else if (shiftLeft) nextState = mlwait;
				else nextState = left;
			end
			lmwait: 
			begin
				if (gameOver) nextState = over;
				else if (~bananaState) nextState = middleHit;
				else if (shiftRight) nextState = lmwait;
				else nextState = middle;
			end
			mrwait: 
			begin
				if (gameOver) nextState = over;
				else if (~bananaState) nextState = rightHit;
				else if (shiftRight) nextState = mrwait;
				else nextState = right;
			end
			rmwait: 
			begin
				if (gameOver) nextState = over;
				else if (~bananaState) nextState = middleHit;
				else if (shiftLeft) nextState = rmwait;
				else nextState = middle;
			end
			middleHit: nextState = recover ? middle : middleHit;
			leftHit: nextState = recover ? left : leftHit;
			rightHit: nextState = recover ? right : rightHit;
			overwait: nextState = over;
			over: nextState = restart ? initpos : over;
			default: nextState = initpos;
		endcase
	end
	
	//output logic
	always @(*)
	begin: control_signals_lane
		
		//default values of output control signals
		LaneMap = 3'b000;
		MLChange = 1'b0;
		LMChange = 1'b0;
		MRChange = 1'b0;
		RMChange = 1'b0;
		StartLoad = 1'b0;
		StartRecover = 1'b0;
		OverConfirm = 1'b0;
		Confused = 1'b0;
		
		case(currentState)
			initpos: LaneMap = 3'b100;
			startwait: 
			begin
				StartLoad = 1'b1;
				LaneMap = 3'b010;
			end
			middle: LaneMap = 3'b010;
			left: LaneMap = 3'b100;
			right: LaneMap = 3'b001;
			mlwait:
			begin
				MLChange = 1'b1;
				LaneMap = 3'b100;
			end
			lmwait:
			begin
				LMChange = 1'b1;
				LaneMap = 3'b010;
			end
			mrwait:
			begin
				MRChange = 1'b1;
				LaneMap = 3'b001;
			end
			rmwait:
			begin
				RMChange = 1'b1;
				LaneMap = 3'b010;
			end
			middleHit:
			begin
				StartRecover = 1'b1;
				LaneMap = 3'b010;
				Confused = 1'b1;
			end
			leftHit:
			begin
				StartRecover = 1'b1;
				LaneMap = 3'b100;
				Confused = 1'b1;
			end
			rightHit:
			begin
				StartRecover = 1'b1;
				LaneMap = 3'b001;
				Confused = 1'b1;
			end
			over: 
			begin
				OverConfirm = 1'b1;
				LaneMap =3'b000;
			end
		endcase
	end
	
	//state transition
	always @(posedge clk)
	begin
		if (restart) 
			currentState <= initpos;
		else
			currentState <= nextState;
	end
	
endmodule


//AI FSM
module AIFSM (
	input clk,
	input timer, timer2,
	input [2:0] steps, playerPos, 
	input AICheckCar, AICheckBanana,
	
	output reg LM, ML, RM, MR, StartStep, StartRelease,
	output [4:0] aistate);
	
	assign aistate = currentState;
	
	reg [4:0] currentState, nextState;
	
	localparam 	aiwait = 5'd0,
					checkcar = 5'd1,
					checkbanana = 5'd2,
					receiveSteps = 5'd3,
					move1 = 5'd4,
					wait1 = 5'd7,
					movewait = 5'd5,
					move2 = 5'd6;
					
	//state table
	always@(*) begin
		case(currentState)
			aiwait:
			begin
				if (AICheckCar)
					nextState = checkcar;
				else if (AICheckBanana)
					nextState = checkbanana;
				else 
					nextState = aiwait;
			end
			checkcar : nextState = move1;
			checkbanana : nextState = move1;
			receiveSteps : 
			begin
				if (steps == 3'b000)
					nextState = aiwait;
				else nextState = move1;
			end 
			move1: 
			begin
				 if (steps == 3'b011 || steps == 3'b100)
				 nextState = timer ? wait1 : move1;
				 else if (steps == 3'b001 || steps == 3'b010)
				 nextState = timer ? aiwait : move1;
				 else nextState = timer? aiwait: move1;
				 
			end 
			wait1: nextState = movewait;
			movewait : nextState = timer2 ? move2 : movewait;
			move2: 
			begin
				 nextState = timer? aiwait: move2;

			end
		endcase
	end

	//output logic
	always @(*)
	begin: signals
	
		LM = 1'd0;
		ML = 1'd0;
		RM = 1'd0;
		MR = 1'd0;
		StartStep = 1'd0;
		StartRelease = 1'd0;
		
		case(currentState)
			move1: 
			begin
				StartStep = 1;
				if (steps == 3'b001 && playerPos[2])
				LM = 1;
				else if (steps == 3'b001 && playerPos[1])
				MR = 1;
				else if (steps == 3'b010 && playerPos[0])
				RM = 1;
				else if (steps == 3'b010 && playerPos[1])
				ML = 1;
				else if (steps == 3'b011)
				LM =1 ;
				else if (steps == 3'b100)
				RM  = 1;
				
			end
			movewait: StartRelease = 1;
			move2: 
			begin
				if (steps == 3'b011) begin 
				LM = 1;
				MR  = 1;
				end
				else if (steps == 3'b100)
				begin 
				RM = 1;
				ML  = 1;
				end 
			end
		endcase
	end
	
	//state transitions
	always @(posedge clk) begin
		currentState <= nextState;
	end
	
endmodule



