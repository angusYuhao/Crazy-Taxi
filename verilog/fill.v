module datapath (
	input clk, 
	input [7:0] position, 
	input [2:0] obstaclePos, playerPos, bananaPos,
	input MLChange, LMChange, MRChange, RMChange, StartScreen, EndScreen, WinScreen, TimeupOver, GameScreen, StartLoad, LdNewObstacle, bananaEn, StartBanana,
			StartDraw, Confused, runOver,drawExplosion,MoveObstacle, MoveBanana,
	input [9:0] score,
	input [1:0] gameState,
	input ld_value, ld_movingLM, ld_movingRM, ld_movingML, ld_movingMR, ld_endScreen, ld_startScreen, atLeft, atMiddle, atRight, reset_clock,
			initialize, enable, updateCoor,
	output reg [7:0] x_out, 
	output reg [6:0] y_out,
	output reg [2:0] colour_out
	);
	
	reg [7:0]  q;
	reg [7:0]  explosionCounter;
	reg [7:0]  confusedCarCounter; 
	reg [7:0]  x; 
	reg [6:0]  y;
	reg [7:0]  obstacle1, obstacle2, obstacle3;
	reg [7:0]  bananaCounter1, bananaCounter2, bananaCounter3;
	reg [7:0]  xCounter;
	reg [6:0]  yCounterForObstacle, yCounterForBanana;
	reg [5:0]  xCounterForObstacle, xCounterForBanana;
	reg [7:0]  xCounterForCloud;
	reg [7:0]  wholeHeartCounter, halfHeartCounter;
	reg [7:0] actualWholeHeartCounter, actualHalfHeartCounter;

	reg [14:0] counterWholeScreen;
	reg [7:0]  currentX;
	reg [7:0]  counterNum0, counter2Num0, counterNum1, counter2Num1, counterNum2, counter2Num2, counterNum3, counterNum4, 
				  counterNum5, counterNum6, counterNum7, counterNum8, counterNum9;
				 
	wire [7:0]  mem_address_car;
	wire [7:0]  mem_address_explosion;
	wire [7:0]  mem_address_confusedCar;
		wire [7:0] 	mem_address_wholeHeart,mem_address_halfHeart;

	wire [7:0]  mem_address_banana1, mem_address_banana2, mem_address_banana3 ;
	wire [14:0] mem_address_background, mem_address_startScreen, mem_address_endScreen,mem_address_winScreen ;
	wire [7:0]  mem_address_obstacle1, mem_address_obstacle2, mem_address_obstacle3;
	wire [7:0]  mem_address_num0, mem_address2_num0, mem_address_num1, mem_address2_num1, mem_address_num2,mem_address2_num2, mem_address_num3, 
				   mem_address_num4, mem_address_num5, mem_address_num6, mem_address_num7, mem_address_num8, mem_address_num9;
	
	wire [2:0] output_car;
		wire [2:0] output_wholeHeart, output_halfHeart;
	wire [2:0] output_explosion;
	wire [2:0] output_confusedCar;
	wire [2:0] output_banana1, output_banana2, output_banana3 ;
	wire [2:0] output_background;
	wire [2:0] output_startScreen, output_endScreen, output_winScreen;
	wire [2:0] output_obstacle1, output_obstacle2, output_obstacle3;
	wire [2:0] output_num0, output2_num0, output_num1, output2_num1, output_num2, output2_num2, output_num3, output_num4, output_num5, 
				  output_num6, output_num7, output_num8, output_num9;
	
	wire [7:0] xValueOfCar;
	wire [7:0] lane1, lane2, lane3;
	wire downEnableObstacle, downEnableObstacleXDirection, downEnableCloud, downEnableBanana; 

	assign lane1 = 8'd58;
	assign lane2 = 8'd73;
	assign lane3 = 8'd88;
	
	assign mem_address_explosion   = (explosionCounter[7:4]*16)+explosionCounter[3:0];
	assign mem_address_car 			 = (q[7:4]*16)+q[3:0];
	assign mem_address_banana1 	 = (bananaCounter1[7:4]*16)+bananaCounter1[3:0]+1;
	assign mem_address_banana2		 = (bananaCounter2[7:4]*16)+bananaCounter2[3:0]+1;
	assign mem_address_banana3 	 = (bananaCounter3[7:4]*16)+bananaCounter3[3:0]+1;
	assign mem_address_background  = (counterWholeScreen[14:8]*160)+counterWholeScreen[7:0];
	assign mem_address_obstacle1   = (obstacle1[7:4]*16)+obstacle1[3:0]+1;
	assign mem_address_obstacle2   = (obstacle2[7:4]*16)+obstacle2[3:0]+1;
	assign mem_address_obstacle3   = (obstacle3[7:4]*16)+obstacle3[3:0]+1;
	assign mem_address_startScreen = (counterWholeScreen[14:8]*160)+counterWholeScreen[7:0];
	assign mem_address_endScreen   = (counterWholeScreen[14:8]*160)+counterWholeScreen[7:0];
	assign mem_address_confusedCar = (confusedCarCounter[7:4]*16)+confusedCarCounter[3:0]-1;
	assign mem_address_winScreen = (counterWholeScreen[14:8]*160)+counterWholeScreen[7:0];
	assign mem_address_num0  = (counterNum0[7:4]*16)+counterNum0[3:0];
	assign mem_address2_num0 = (counter2Num0[7:4]*16)+counter2Num0[3:0];
	assign mem_address_num1  = (counterNum1[7:4]*16)+counterNum1[3:0];
	assign mem_address2_num1 = (counter2Num1[7:4]*16)+counter2Num1[3:0];
	assign mem_address_num2  = (counterNum2[7:4]*16)+counterNum2[3:0];
	assign mem_address2_num2  = (counter2Num2[7:4]*16)+counter2Num2[3:0];
	assign mem_address_num3  = (counterNum3[7:4]*16)+counterNum3[3:0];
	assign mem_address_num4  = (counterNum4[7:4]*16)+counterNum4[3:0];
	assign mem_address_num5  = (counterNum5[7:4]*16)+counterNum5[3:0];
	assign mem_address_num6  = (counterNum6[7:4]*16)+counterNum6[3:0];
	assign mem_address_num7  = (counterNum7[7:4]*16)+counterNum7[3:0];
	assign mem_address_num8  = (counterNum8[7:4]*16)+counterNum8[3:0];
	assign mem_address_num9  = (counterNum9[7:4]*16)+counterNum9[3:0];

	
	assign mem_address_wholeHeart  = (actualWholeHeartCounter[7:4]*16)+actualWholeHeartCounter[3:0];
	assign mem_address_halfHeart  = (actualHalfHeartCounter[7:4]*16)+actualHalfHeartCounter[3:0];
	
	car car0 (mem_address_car, clk, 3'b110, 0, output_car);
	background background0 (mem_address_background, clk, 3'b000, 0, output_background);
	confused confusedCar0 (mem_address_confusedCar, clk, output_confusedCar);
	
	gSemi1 obstacleSemi1 (mem_address_obstacle1, clk, output_obstacle1);
	gSemi1 obstacleSemi2 (mem_address_obstacle2, clk, output_obstacle2);
	gSemi1 obstacleSemi3 (mem_address_obstacle3, clk, output_obstacle3);
	
	startScreen startScreen0 (mem_address_startScreen, clk, output_startScreen);
	endScreen endScreen0 (mem_address_endScreen, clk, output_endScreen);
	winScreen winScreen0 (mem_address_winScreen, clk, output_winScreen);
	banana banana1 (mem_address_banana1, clk, output_banana1);
	banana banana2 (mem_address_banana2, clk, output_banana2);
	banana banana3 (mem_address_banana3, clk, output_banana3);

	number0 num0_2 (mem_address2_num0, clk, output2_num0);
	number0 num0   (mem_address_num0, clk, output_num0);
	number1 num1   (mem_address_num1, clk, output_num1);
	number1 num1_2  (mem_address2_num1, clk, output2_num1);
	number2 num2   (mem_address_num2, clk, output_num2);
	number2 num2_2   (mem_address2_num2, clk, output2_num2);
	number3 num3   (mem_address_num3, clk, output_num3);
	number4 num4   (mem_address_num4, clk, output_num4);
	number5 num5   (mem_address_num5, clk, output_num5);
	number6 num6   (mem_address_num6, clk, output_num6);
	number7 num7   (mem_address_num7, clk, output_num7);
	number8 num8   (mem_address_num8, clk, output_num8);
	number9 num9   (mem_address_num9, clk, output_num9);
	
	explosion explosion0 (mem_address_explosion, clk, output_explosion);
	halfHeart heartHalf (mem_address_halfHeart, clk, output_halfHeart);
	wholeHeart heartWhole (mem_address_wholeHeart, clk, output_wholeHeart);
	
	DCobstacle downCounterObstacle (clk, LdNewObstacle, downEnableObstacle);
	DCbanana downCounterBanana (clk, bananaEn, downEnableBanana);
	
	DCobstacleXDirection downCounterObstacleX (clk, LdNewObstacle, downEnableObstacleXDirection);
	
	reg temp, temp2;
	reg currentScore;
	
	// counter for loading in the new obstacle wave, if loading, counter resets, otherwise increment by 1
	always@(posedge clk) begin 
	
		if (downEnableObstacle) begin 
		
			temp <= ~temp;
			yCounterForObstacle <= yCounterForObstacle + 1'b1;
			if (temp)  
				xCounterForObstacle <= xCounterForObstacle + 1'b1;

		end 
		
		if (downEnableBanana) begin 
			
			temp2 <= ~temp2;
			yCounterForBanana <= yCounterForBanana + 1'b1;
			if (temp2)  
				xCounterForBanana <= xCounterForBanana + 1'b1;

		end 
		
		if (StartDraw) begin 
			yCounterForObstacle <= 7'd36;
			xCounterForObstacle <= 1'b0;
		end 
		
		if (StartBanana) begin 
			yCounterForBanana <= 7'd36;
			xCounterForBanana <= 1'b0;
		end 
				
	end
	
	// loading in the initial value (not really needed, can take out later)
	always@(posedge clk) begin
	
		if(ld_value) begin
			x <= 8'b01001000;
			y <= 7'b1100100;
		end
		
	end
	
	// counter for the whole screen, it is incrementing on the CLOCK_50, also stores the currentX location
	always@(posedge clk) begin 
	
		counterWholeScreen <= counterWholeScreen+1'b1;
		
		if (atMiddle)
			currentX <= 8'd73;
		else if (atLeft)
			currentX <= 8'd30;
		else if (atRight)
			currentX <= 8'd116;
		
	end 
	
	// counter for the obstacles 
	always@(posedge clk) begin 
	
		if (MoveObstacle) begin 
		
			if (counterWholeScreen[14:8] == yCounterForObstacle + obstacle1[7:4] && counterWholeScreen[7:0] == lane1 + obstacle1[3:0] - xCounterForObstacle)
				obstacle1 <= obstacle1 + 1'b1;
			if (counterWholeScreen[14:8] == yCounterForObstacle + obstacle2[7:4] && counterWholeScreen[7:0] == lane2 + obstacle2[3:0])
				obstacle2 <= obstacle2 + 1'b1;
			if (counterWholeScreen[14:8] == yCounterForObstacle + obstacle3[7:4] && counterWholeScreen[7:0] == lane3 + obstacle3[3:0] + xCounterForObstacle)
				obstacle3 <= obstacle3 + 1'b1;
				
		end
		
		if (MoveBanana) begin 
		
			if (counterWholeScreen[14:8] == yCounterForBanana + bananaCounter1[7:4] && counterWholeScreen[7:0] == lane1 + bananaCounter1[3:0] - xCounterForBanana)
				bananaCounter1 <= bananaCounter1 + 1'b1;
			if (counterWholeScreen[14:8] == yCounterForBanana + bananaCounter2[7:4] && counterWholeScreen[7:0] == lane2 + bananaCounter2[3:0])
				bananaCounter2 <= bananaCounter2 + 1'b1;
			if (counterWholeScreen[14:8] == yCounterForBanana + bananaCounter3[7:4] && counterWholeScreen[7:0] == lane3 + bananaCounter3[3:0] + xCounterForBanana)
				bananaCounter3 <= bananaCounter3 + 1'b1;	
				
		end
		
		
		if (gameState == 2'b10 && counterWholeScreen[14:8] == 7'd50 + actualWholeHeartCounter[7:4] && counterWholeScreen[7:0] == 8'd16 + actualWholeHeartCounter[3:0])
				actualWholeHeartCounter <= actualWholeHeartCounter +1;
		
		if (gameState == 2'b01 && counterWholeScreen[14:8] == 7'd50 + actualHalfHeartCounter[7:4] && counterWholeScreen[7:0] == 8'd16 + actualHalfHeartCounter[3:0])
				actualHalfHeartCounter <= actualHalfHeartCounter +1;
//						case (gameState)
//					2'b10: begin 
//						if (counterWholeScreen[14:8] == 7'd30 + actualWholeHeartCounter[7:4] && counterWholeScreen[7:0] == 8'd27 + actualWholeHeartCounter[3:0])begin 
//								actualWholeHeartCounter <= actualWholeHeartCounter + 1;
//						end
//					end 
//					
//					2'b01: begin 
//						if (counterWholeScreen[14:8] == 7'd50 + actualHalfHeartCounter[7:4] && counterWholeScreen[7:0] == 8'd17 + actualHalfHeartCounter[3:0])begin 
//								actualHalfHeartCounter <= actualHalfHeartCounter + 1;
//						end
//
//					end 
//				
//				endcase 
//				end
//			
	end
	
	// all the counter action for q to draw the car 
	always@(posedge clk) begin 
	
		if (updateCoor)
			xCounter <= xCounter + 4;
			
			
		if (!Confused) 
			confusedCarCounter <= 0;

		if (!drawExplosion)
			explosionCounter <= 0;
		
		if (reset_clock) begin 
			q <= 0;
			xCounter <= 0;
		end 
		
			
		else if (ld_movingML) begin
			if (counterWholeScreen[14:8] == 7'b1100100 + q[7:4] && counterWholeScreen[7:0] == x - xCounter + q[3:0]) begin 
					 if (drawExplosion && counterWholeScreen[14:8] == 7'b1100100 + explosionCounter[7:4] && counterWholeScreen[7:0] ==  x - xCounter + explosionCounter[3:0]) begin 
								explosionCounter <= explosionCounter+1;
									end
				else if (Confused && (counterWholeScreen[14:8] == 7'b1100100 + confusedCarCounter[7:4] && counterWholeScreen[7:0] == x - xCounter + confusedCarCounter[3:0])) confusedCarCounter <= confusedCarCounter + 1'b1;
			
				q <= q + 1;
			end
		end
		
		else if (ld_movingLM) begin
			if (counterWholeScreen[14:8] == 7'b1100100 + q[7:4] && counterWholeScreen[7:0] == 8'd30 + xCounter + q[3:0]) begin 
								 if (drawExplosion && counterWholeScreen[14:8] == 7'b1100100 + explosionCounter[7:4] && counterWholeScreen[7:0] ==  8'd30 + xCounter + explosionCounter[3:0]) begin 
								explosionCounter <= explosionCounter+1;
									end
								else if (Confused && (counterWholeScreen[14:8] == 7'b1100100 + confusedCarCounter[7:4] && counterWholeScreen[7:0] == 8'd30 + xCounter + confusedCarCounter[3:0]) ) confusedCarCounter <= confusedCarCounter + 1'b1;
								
				q <= q + 1;
			end
		end
		
		else if (ld_movingMR) begin
			if (counterWholeScreen[14:8] == 7'b1100100 + q[7:4] && counterWholeScreen[7:0] == x + xCounter + q[3:0]) begin 
							 if (drawExplosion && counterWholeScreen[14:8] == 7'b1100100 + explosionCounter[7:4] && counterWholeScreen[7:0] == x + xCounter + explosionCounter[3:0]) begin 
								explosionCounter <= explosionCounter+1;
									end
							else if (Confused && counterWholeScreen[14:8] == 7'b1100100 + confusedCarCounter[7:4] && counterWholeScreen[7:0] == x + xCounter + confusedCarCounter[3:0]) confusedCarCounter <= confusedCarCounter + 1'b1;

				q <= q + 1;
			end
		end
	
		else if (ld_movingRM) begin
			if (counterWholeScreen[14:8] == 7'b1100100 + q[7:4] && counterWholeScreen[7:0] == 8'd116 - xCounter + q[3:0]) begin 
								 if (drawExplosion && counterWholeScreen[14:8] == 7'b1100100 + explosionCounter[7:4] && counterWholeScreen[7:0] == 8'd116 - xCounter + explosionCounter[3:0]) begin 
								explosionCounter <= explosionCounter+1;
									end
								else if (Confused && counterWholeScreen[14:8] == 7'b1100100 + confusedCarCounter[7:4] && counterWholeScreen[7:0] == 8'd116 - xCounter + confusedCarCounter[3:0]) confusedCarCounter <= confusedCarCounter + 1'b1;
								
				q <= q + 1;
			end
		end
		
		else if (counterWholeScreen[14:8] == 7'b1100100 + q[7:4] && counterWholeScreen[7:0] == currentX + q[3:0]) begin 
								 if (drawExplosion && counterWholeScreen[14:8] == 7'b1100100 + explosionCounter[7:4] && counterWholeScreen[7:0] == currentX + explosionCounter[3:0]) begin 
								explosionCounter <= explosionCounter+1;
									end 
								else if (Confused && counterWholeScreen[14:8] == 7'b1100100 + confusedCarCounter[7:4] && counterWholeScreen[7:0] == currentX + confusedCarCounter[3:0])
								confusedCarCounter <= confusedCarCounter + 1'b1;
								
				q <= q + 1;
		end
		
	end	
	
	always@(posedge clk) begin
	
		x_out <= counterWholeScreen[7:0]-1'b1;
		y_out <= counterWholeScreen[14:8];
		
		begin
		
			if (WinScreen) 
				colour_out <= output_winScreen;
			
			else if (ld_startScreen) begin 
				colour_out <= output_startScreen;
				end 
			else if (ld_endScreen) 
				colour_out <= output_endScreen;
				
			else if (initialize)
				colour_out <= (counterWholeScreen[14:8] == 7'b1100100 + q[7:4] && counterWholeScreen[7:0] == 8'd73 + q[3:0]) ? output_car: output_background;
				else if (gameState == 2'b10 && counterWholeScreen[14:8] == 7'd50 + actualWholeHeartCounter[7:4] && counterWholeScreen[7:0] == 8'd16 + actualWholeHeartCounter[3:0])
							 colour_out <= (output_wholeHeart == 3'b000) ? output_background : output_wholeHeart;
					else if (gameState == 2'b01 && counterWholeScreen[14:8] == 7'd50 + actualHalfHeartCounter[7:4] && counterWholeScreen[7:0] == 8'd16 + actualHalfHeartCounter[3:0])
													colour_out <= (output_halfHeart == 3'b000) ? output_background : output_halfHeart;

//			else if (counterWholeScreen[7:0] >= 15'd17 && counterWholeScreen[7:0] <= 15'd47 && counterWholeScreen[14:8] >= 15'd30 && counterWholeScreen[14:8] <= 15'd60) begin 
//				
//				case (gameState)
//					2'b10: begin 
//						if (counterWholeScreen[14:8] == 7'd30 + actualWholeHeartCounter[7:4] && counterWholeScreen[7:0] == 8'd27 + actualWholeHeartCounter[3:0])begin 
//								//actualWholeHeartCounter <= actualWholeHeartCounter + 1;
//								colour_out <= output_wholeHeart; 
//						end
//						else colour_out <= 3'b110;
//					end 
//					
//					2'b01: begin 
//						if (counterWholeScreen[14:8] == 7'd50 + actualHalfHeartCounter[7:4] && counterWholeScreen[7:0] == 8'd17 + actualHalfHeartCounter[3:0])begin 
//							//	actualHalfHeartCounter <= actualHalfHeartCounter + 1;
//								colour_out <= output_halfHeart; 
//						end
//												else colour_out <= 3'b011;
//
//					end 
//					
//					default : 								colour_out <= 3'b010; 
//
//				
//				endcase 
//			end 
//			
			else if (counterWholeScreen[7:0] >= 15'd64 && counterWholeScreen[7:0] <= 15'd96 && counterWholeScreen[14:8] >= 15'd10 && counterWholeScreen[14:8] <= 15'd26) begin 
				
				case(score)
					
						9'd0: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum0[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum0[3:0])begin 
								counterNum0 <= counterNum0 + 1;
								colour_out <= output_num0; 
							end
							if (counterWholeScreen[14:8] == 7'd10 + counter2Num0[7:4] && counterWholeScreen[7:0] == 8'd80 + counter2Num0[3:0])begin
								counter2Num0 <= counter2Num0 + 1;
								colour_out <= output2_num0;
							end
						end
						
						9'd1: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum0[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum0[3:0])begin
								counterNum0 <= counterNum0 + 1;
								colour_out <= output_num0;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum1[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum1[3:0])begin
								counterNum1 <= counterNum1 + 1;
								colour_out <= output_num1;
							end
						end
						
						9'd2: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum0[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum0[3:0])begin
								counterNum0 <= counterNum0 + 1;
								colour_out <= output_num0;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum2[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum2[3:0])begin
								counterNum2 <= counterNum2 + 1;
								colour_out <= output_num2;
							end
						end
						
						9'd3: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum0[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum0[3:0])begin
								counterNum0 <= counterNum0 + 1;
								colour_out <= output_num0;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum3[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum3[3:0])begin
								counterNum3 <= counterNum3 + 1;
								colour_out <= output_num3;
							end
						end
						
						9'd4: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum0[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum0[3:0])begin
								counterNum0 <= counterNum0 + 1;
								colour_out <= output_num0;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum4[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum4[3:0])begin
								counterNum4 <= counterNum4 + 1;
								colour_out <= output_num4;
							end
						end
						
						9'd5: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum0[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum0[3:0])begin
								counterNum0 <= counterNum0 + 1;
								colour_out <= output_num0;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum5[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum5[3:0])begin
								counterNum5 <= counterNum5 + 1;
								colour_out <= output_num5;
							end
						end
						
						9'd6: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum0[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum0[3:0])begin
								counterNum0 <= counterNum0 + 1;
								colour_out <= output_num0;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum6[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum6[3:0])begin
								counterNum6 <= counterNum6 + 1;
								colour_out <= output_num6;
							end
						end
						
						9'd7: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum0[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum0[3:0])begin
								counterNum0 <= counterNum0 + 1;
								colour_out <= output_num0;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum7[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum7[3:0])begin
								counterNum7 <= counterNum7 + 1;
								colour_out <= output_num7;
							end
						end
						
						9'd8: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum0[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum0[3:0])begin
								counterNum0 <= counterNum0 + 1;
								colour_out <= output_num0;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum8[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum8[3:0])	begin
								counterNum8 <= counterNum8 + 1;
								colour_out <= output_num8;
							end
						end
						
						9'd9: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum0[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum0[3:0])begin
								counterNum0 <= counterNum0 + 1;
								colour_out <= output_num0;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum9[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum9[3:0])begin
								counterNum9 <= counterNum9 + 1;
								colour_out <= output_num9;
							end
						end
						
						9'd10: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum1[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum1[3:0])begin
								counterNum1 <= counterNum1 + 1;
								colour_out <= output_num1;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum0[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum0[3:0])	begin
								counterNum0 <= counterNum0 + 1;
								colour_out <= output_num0;
							end
						end
						
						9'd11: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum1[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum1[3:0])begin
								counterNum1 <= counterNum1 + 1;
								colour_out <= output_num1;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counter2Num1[7:4] && counterWholeScreen[7:0] == 8'd80 + counter2Num1[3:0])	begin
								counter2Num1 <= counter2Num1 + 1;
								colour_out <= output2_num1;
							end
						end


						9'd12: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum1[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum1[3:0])begin
								counterNum1 <= counterNum1 + 1;
								colour_out <= output_num1;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum2[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum2[3:0])	begin
								counterNum2 <= counterNum2 + 1;
								colour_out <= output_num2;
							end
						end
						
						9'd13: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum1[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum1[3:0])begin
								counterNum1 <= counterNum1 + 1;
								colour_out <= output_num1;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum3[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum3[3:0])	begin
								counterNum3 <= counterNum3 + 1;
								colour_out <= output_num3;
							end
						end
						
						9'd14: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum1[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum1[3:0])begin
								counterNum1 <= counterNum1 + 1;
								colour_out <= output_num1;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum4[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum4[3:0])	begin
								counterNum4 <= counterNum4 + 1;
								colour_out <= output_num4;
							end
						end
						
						9'd15: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum1[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum1[3:0])begin
								counterNum1 <= counterNum1 + 1;
								colour_out <= output_num1;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum5[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum5[3:0])	begin
								counterNum5 <= counterNum5 + 1;
								colour_out <= output_num5;
							end
						end
						
						9'd16: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum1[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum1[3:0])begin
								counterNum1 <= counterNum1 + 1;
								colour_out <= output_num1;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum6[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum6[3:0])	begin
								counterNum6 <= counterNum6 + 1;
								colour_out <= output_num6;
							end
						end
						
						9'd17: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum1[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum1[3:0])begin
								counterNum1 <= counterNum1 + 1;
								colour_out <= output_num1;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum7[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum7[3:0])	begin
								counterNum7 <= counterNum7 + 1;
								colour_out <= output_num7;
							end
						end
						
						9'd18: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum1[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum1[3:0])begin
								counterNum1 <= counterNum1 + 1;
								colour_out <= output_num1;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum8[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum8[3:0])	begin
								counterNum8 <= counterNum8 + 1;
								colour_out <= output_num8;
							end
						end
						
						9'd19: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum1[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum1[3:0])begin
								counterNum1 <= counterNum1 + 1;
								colour_out <= output_num1;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum9[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum9[3:0])	begin
								counterNum9 <= counterNum9 + 1;
								colour_out <= output_num9;
							end
						end
						
						9'd20: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum2[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum2[3:0])begin
								counterNum2 <= counterNum2 + 1;
								colour_out <= output_num2;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum0[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum0[3:0])	begin
								counterNum0 <= counterNum0 + 1;
								colour_out <= output_num0;
							end
						end
						
						9'd21: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum2[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum2[3:0])begin
								counterNum2 <= counterNum2 + 1;
								colour_out <= output_num2;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum1[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum1[3:0])	begin
								counterNum1 <= counterNum1 + 1;
								colour_out <= output_num1;
							end
						end
						
						9'd22: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum2[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum2[3:0])begin
								counterNum2 <= counterNum2 + 1;
								colour_out <= output_num2;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counter2Num2[7:4] && counterWholeScreen[7:0] == 8'd80 + counter2Num2[3:0])	begin
								counter2Num2 <= counter2Num2 + 1;
								colour_out <= output2_num2;
							end
						end
						
						9'd23: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum2[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum2[3:0])begin
								counterNum2 <= counterNum2 + 1;
								colour_out <= output_num2;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum3[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum3[3:0])	begin
								counterNum3 <= counterNum3 + 1;
								colour_out <= output_num3;
							end
						end
						
						9'd24: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum2[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum2[3:0])begin
								counterNum2 <= counterNum2 + 1;
								colour_out <= output_num2;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum4[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum4[3:0])	begin
								counterNum4 <= counterNum4 + 1;
								colour_out <= output_num4;
							end
						end
						
						9'd25: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum2[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum2[3:0])begin
								counterNum2 <= counterNum2 + 1;
								colour_out <= output_num2;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum5[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum5[3:0])	begin
								counterNum5 <= counterNum5 + 1;
								colour_out <= output_num5;
							end
						end
						
						9'd26: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum2[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum2[3:0])begin
								counterNum2 <= counterNum2 + 1;
								colour_out <= output_num2;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum6[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum6[3:0])	begin
								counterNum6 <= counterNum6 + 1;
								colour_out <= output_num6;
							end
						end
						
						9'd27: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum2[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum2[3:0])begin
								counterNum2 <= counterNum2 + 1;
								colour_out <= output_num2;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum7[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum7[3:0])	begin
								counterNum7 <= counterNum7 + 1;
								colour_out <= output_num7;
							end
						end
						
						9'd28: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum2[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum2[3:0])begin
								counterNum2 <= counterNum2 + 1;
								colour_out <= output_num2;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum8[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum8[3:0])	begin
								counterNum8 <= counterNum8 + 1;
								colour_out <= output_num8;
							end
						end
						
						9'd29: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum2[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum2[3:0])begin
								counterNum2 <= counterNum2 + 1;
								colour_out <= output_num2;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum9[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum9[3:0])	begin
								counterNum9 <= counterNum9 + 1;
								colour_out <= output_num9;
							end
						end
						
						9'd30: begin 
							if (counterWholeScreen[14:8] == 7'd10 + counterNum3[7:4] && counterWholeScreen[7:0] == 8'd64 + counterNum3[3:0])begin
								counterNum3 <= counterNum3 + 1;
								colour_out <= output_num3;
							end
							if (counterWholeScreen[14:8] == 7'd10 + counterNum0[7:4] && counterWholeScreen[7:0] == 8'd80 + counterNum0[3:0])	begin
								counterNum0 <= counterNum0 + 1;
								colour_out <= output_num0;
							end
						end
					endcase
					
			end 
			
			else if (ld_movingML) begin

				if ((counterWholeScreen[14:8] == 7'b1100100 + q[7:4] && counterWholeScreen[7:0] == x - xCounter + q[3:0])) begin 
					
				 if (drawExplosion && counterWholeScreen[14:8] == 7'b1100100 + explosionCounter[7:4] && counterWholeScreen[7:0] == currentX + explosionCounter[3:0]) begin 
							colour_out <= (output_car == 3'b000) ? output_background :output_explosion;
					end
				else if (Confused && (counterWholeScreen[14:8] == 7'b1100100 + confusedCarCounter[7:4] && counterWholeScreen[7:0] == x - xCounter + confusedCarCounter[3:0])) begin 
						colour_out <= (output_car == 3'b000) ? output_background : output_confusedCar;	
					end 	
					else 
						colour_out <= (output_car == 3'b000) ? output_background : output_car;	
				end 
				else if (obstaclePos[2] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle1[7:4] && counterWholeScreen[7:0] == lane1 + obstacle1[3:0] - xCounterForObstacle)
					colour_out <= (output_obstacle1 == 3'b000) ? output_background : output_obstacle1;

				else if (obstaclePos[1] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle2[7:4] && counterWholeScreen[7:0] == lane2 + obstacle2[3:0])
					colour_out <= (output_obstacle2 == 3'b000) ? output_background : output_obstacle2;
				
				else if (obstaclePos[0] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle3[7:4] && counterWholeScreen[7:0] == lane3 + obstacle3[3:0] + xCounterForObstacle)
					colour_out <= (output_obstacle3 == 3'b000) ? output_background : output_obstacle3;
			
				else if (bananaPos[2]  &&  !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter1[7:4] && counterWholeScreen[7:0] == lane1 + bananaCounter1[3:0] - xCounterForBanana)
					colour_out <= (output_banana1 == 3'b000) ? output_background : output_banana1;

				else if (bananaPos[1]  && !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter2[7:4] && counterWholeScreen[7:0] == lane2 + bananaCounter2[3:0])
					colour_out <= (output_banana2 == 3'b000) ? output_background : output_banana2;
				
				else if (bananaPos[0]  && !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter3[7:4] && counterWholeScreen[7:0] == lane3 + bananaCounter3[3:0] + xCounterForBanana)
					colour_out <= (output_banana3 == 3'b000) ? output_background : output_banana3;
					
				else 
					colour_out <= output_background;
						
			end 
				
				else if (ld_movingLM) begin 

				if ((counterWholeScreen[14:8] == 7'b1100100 + q[7:4] && counterWholeScreen[7:0] == 8'd30 + xCounter + q[3:0])) begin 
					
					 if (drawExplosion && counterWholeScreen[14:8] == 7'b1100100 + explosionCounter[7:4] && counterWholeScreen[7:0] == currentX + explosionCounter[3:0]) begin 
							colour_out <= (output_car == 3'b000) ? output_background :output_explosion;
					end	
					else if (Confused && (counterWholeScreen[14:8] == 7'b1100100 + confusedCarCounter[7:4] && counterWholeScreen[7:0] == 8'd30 + xCounter + confusedCarCounter[3:0])) begin 
						colour_out <= (output_car == 3'b000) ? output_background : output_confusedCar;	
					end 
					else 
						colour_out <= (output_car == 3'b000) ? output_background : output_car;	
				end 
	
				else if (obstaclePos[2] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle1[7:4] && counterWholeScreen[7:0] == lane1 + obstacle1[3:0] - xCounterForObstacle)
					colour_out <= (output_obstacle1 == 3'b000) ? output_background : output_obstacle1;

				else if (obstaclePos[1] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle2[7:4] && counterWholeScreen[7:0] == lane2 + obstacle2[3:0])
					colour_out <= (output_obstacle2 == 3'b000) ? output_background : output_obstacle2;
				
				else if (obstaclePos[0] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle3[7:4] && counterWholeScreen[7:0] == lane3 + obstacle3[3:0] + xCounterForObstacle)
					colour_out <= (output_obstacle3 == 3'b000) ? output_background : output_obstacle3;
						
				else if (bananaPos[2]  &&  !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter1[7:4] && counterWholeScreen[7:0] == lane1 + bananaCounter1[3:0] - xCounterForBanana)
					colour_out <= (output_banana1 == 3'b000) ? output_background : output_banana1;

				else if (bananaPos[1]  && !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter2[7:4] && counterWholeScreen[7:0] == lane2 + bananaCounter2[3:0])
					colour_out <= (output_banana2 == 3'b000) ? output_background : output_banana2;
				
				else if (bananaPos[0]  && !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter3[7:4] && counterWholeScreen[7:0] == lane3 + bananaCounter3[3:0] + xCounterForBanana)
					colour_out <= (output_banana3 == 3'b000) ? output_background : output_banana3;
					
				else 
					colour_out <= output_background;
					
				end 
				
				else if (ld_movingMR) begin 

					if ((counterWholeScreen[14:8] == 7'b1100100 + q[7:4] && counterWholeScreen[7:0] == x + xCounter + q[3:0])) begin 
						
						 if (drawExplosion && counterWholeScreen[14:8] == 7'b1100100 + explosionCounter[7:4] && counterWholeScreen[7:0] == currentX + explosionCounter[3:0]) begin 
							colour_out <= (output_car == 3'b000) ? output_background :output_explosion;
					end	
					else if (Confused && counterWholeScreen[14:8] == 7'b1100100 + confusedCarCounter[7:4] && counterWholeScreen[7:0] == x + xCounter + confusedCarCounter[3:0]) begin 
							colour_out <= (output_car == 3'b000) ? output_background : output_confusedCar;	
						end 
						else 
							colour_out <= (output_car == 3'b000) ? output_background : output_car;	
					end 
						
					else if (obstaclePos[2] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle1[7:4] && counterWholeScreen[7:0] == lane1 + obstacle1[3:0] - xCounterForObstacle)
					colour_out <= (output_obstacle1 == 3'b000) ? output_background : output_obstacle1;

				else if (obstaclePos[1] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle2[7:4] && counterWholeScreen[7:0] == lane2 + obstacle2[3:0])
					colour_out <= (output_obstacle2 == 3'b000) ? output_background : output_obstacle2;
				
				else if (obstaclePos[0] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle3[7:4] && counterWholeScreen[7:0] == lane3 + obstacle3[3:0] + xCounterForObstacle)
					colour_out <= (output_obstacle3 == 3'b000) ? output_background : output_obstacle3;
					else if (bananaPos[2]  &&  !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter1[7:4] && counterWholeScreen[7:0] == lane1 + bananaCounter1[3:0] - xCounterForBanana)
					colour_out <= (output_banana1 == 3'b000) ? output_background : output_banana1;

				else if (bananaPos[1]  && !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter2[7:4] && counterWholeScreen[7:0] == lane2 + bananaCounter2[3:0])
					colour_out <= (output_banana2 == 3'b000) ? output_background : output_banana2;
				
				else if (bananaPos[0]  && !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter3[7:4] && counterWholeScreen[7:0] == lane3 + bananaCounter3[3:0] + xCounterForBanana)
					colour_out <= (output_banana3 == 3'b000) ? output_background : output_banana3;
					else 
						colour_out <= output_background;
				end 
				
				else if (ld_movingRM) begin 

					if ((counterWholeScreen[14:8] == 7'b1100100 + q[7:4] && counterWholeScreen[7:0] == 8'd116 - xCounter + q[3:0])) begin 
						
						 if (drawExplosion && counterWholeScreen[14:8] == 7'b1100100 + explosionCounter[7:4] && counterWholeScreen[7:0] == currentX + explosionCounter[3:0]) begin 
							colour_out <= (output_car == 3'b000) ? output_background :output_explosion;
					end	
					else if (Confused && counterWholeScreen[14:8] == 7'b1100100 + confusedCarCounter[7:4] && counterWholeScreen[7:0] == 8'd116 - xCounter + confusedCarCounter[3:0]) begin 
							colour_out <= (output_car == 3'b000) ? output_background : output_confusedCar;	
						end 
						else 
							colour_out <= (output_car == 3'b000) ? output_background : output_car;	
					end 
					
					else if (obstaclePos[2] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle1[7:4] && counterWholeScreen[7:0] == lane1 + obstacle1[3:0] - xCounterForObstacle)
					colour_out <= (output_obstacle1 == 3'b000) ? output_background : output_obstacle1;

				else if (obstaclePos[1] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle2[7:4] && counterWholeScreen[7:0] == lane2 + obstacle2[3:0])
					colour_out <= (output_obstacle2 == 3'b000) ? output_background : output_obstacle2;
				
				else if (obstaclePos[0] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle3[7:4] && counterWholeScreen[7:0] == lane3 + obstacle3[3:0] + xCounterForObstacle)
					colour_out <= (output_obstacle3 == 3'b000) ? output_background : output_obstacle3;
					else if (bananaPos[2]  &&  !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter1[7:4] && counterWholeScreen[7:0] == lane1 + bananaCounter1[3:0] - xCounterForBanana)
					colour_out <= (output_banana1 == 3'b000) ? output_background : output_banana1;

				else if (bananaPos[1]  && !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter2[7:4] && counterWholeScreen[7:0] == lane2 + bananaCounter2[3:0])
					colour_out <= (output_banana2 == 3'b000) ? output_background : output_banana2;
				
				else if (bananaPos[0]  && !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter3[7:4] && counterWholeScreen[7:0] == lane3 + bananaCounter3[3:0] + xCounterForBanana)
					colour_out <= (output_banana3 == 3'b000) ? output_background : output_banana3;
					else  
						colour_out <= output_background;
				end 
				
				// when car is stationary 
				else if (atLeft || atRight || atMiddle)
				
				begin 
				


					 if ((counterWholeScreen[14:8] == 7'b1100100 + q[7:4] && counterWholeScreen[7:0] == currentX + q[3:0])) begin 
						
						 if (drawExplosion && counterWholeScreen[14:8] == 7'b1100100 + explosionCounter[7:4] && counterWholeScreen[7:0] == currentX + explosionCounter[3:0]) begin 
							colour_out <= (output_car == 3'b000) ? output_background :output_explosion;
					end	
					else if (Confused && counterWholeScreen[14:8] == 7'b1100100 + confusedCarCounter[7:4] && counterWholeScreen[7:0] == currentX + confusedCarCounter[3:0]) begin 
							colour_out <= (output_car == 3'b000) ? output_background : output_confusedCar;	
						end 
						else 
							colour_out <= (output_car == 3'b000) ? output_background : output_car;	
					end 
						
					else if (obstaclePos[2] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle1[7:4] && counterWholeScreen[7:0] == lane1 + obstacle1[3:0] - xCounterForObstacle)
					colour_out <= (output_obstacle1 == 3'b000) ? output_background : output_obstacle1;

				else if (obstaclePos[1] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle2[7:4] && counterWholeScreen[7:0] == lane2 + obstacle2[3:0])
					colour_out <= (output_obstacle2 == 3'b000) ? output_background : output_obstacle2;
				
				else if (obstaclePos[0] && !LdNewObstacle && counterWholeScreen[14:8] == yCounterForObstacle + obstacle3[7:4] && counterWholeScreen[7:0] == lane3 + obstacle3[3:0] + xCounterForObstacle)
					colour_out <= (output_obstacle3 == 3'b000) ? output_background : output_obstacle3;
				else if (bananaPos[2]  &&  !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter1[7:4] && counterWholeScreen[7:0] == lane1 + bananaCounter1[3:0] - xCounterForBanana)
					colour_out <= (output_banana1 == 3'b000) ? output_background : output_banana1;

				else if (bananaPos[1]  && !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter2[7:4] && counterWholeScreen[7:0] == lane2 + bananaCounter2[3:0])
					colour_out <= (output_banana2 == 3'b000) ? output_background : output_banana2;
				
				else if (bananaPos[0]  && !bananaEn && counterWholeScreen[14:8] == yCounterForBanana + bananaCounter3[7:4] && counterWholeScreen[7:0] == lane3 + bananaCounter3[3:0] + xCounterForBanana)
					colour_out <= (output_banana3 == 3'b000) ? output_background : output_banana3;
					else 
						colour_out <= output_background;
				end 
				
				
			end 
			
	
				
			end	
	
endmodule			
	
	
	
module control(
	input clk,position,
	input [2:0] obstaclePos, playerPos,bananaPos,
	input MLChange, LMChange, MRChange, RMChange, StartScreen, EndScreen, GameScreen,StartLoad, startGame, LdNewObstacle,bananaEn,StartBanana,downEnable2, downEnable3,
	input [3:0] keys,
	input resetGame, 
	input [9:0] score, 
	output reg ld_value, ld_movingLM, ld_movingRM, ld_movingML, ld_movingMR, enable, updateCoor, atLeft, atMiddle, atRight, reset_clock,initialize, ld_endScreen, ld_startScreen
	);
	
	reg movingDone;
	reg [4:0] current_state, next_state;
	wire loadValue, movingLeft, movingRight;	
	assign loadValue = ~keys[2];
	assign movingLeft = ~keys[3];
	assign movingRight = ~keys[1];
	
	always @ (*) begin 
		if (current_state == 5'd8 || current_state == 5'd13  || current_state == 5'd14 )
			movingDone <= 0;
		else if (downEnable3) 
			movingDone <= 1;
		
	end 
	
	localparam  	S_STARTSCREEN = 5'd0,
					S_LD_VALUE_WAIT = 5'd3,
					S_ENDSCREEN = 5'd22,
					S_WAIT_MIDDLE = 5'd1,
					S_WAIT_LEFT = 5'd12,
					S_UPDATE_ML = 5'd6,
					S_UPDATE_MR = 5'd18,
					S_UPDATE_RM = 5'd19,
					S_AT_LEFT = 5'd7,
					S_RSCLK_MIDDLE = 5'd8,
					S_RSCLK_LEFT = 5'd13,
					S_WAIT_RIGHT= 5'd15,
					S_RSCLK_RIGHT = 5'd14,
					S_MOVING_LM = 5'd9,
					S_MOVING_MR = 5'd20,
					S_MOVING_RM = 5'd21,
					S_UPDATE_LM = 5'd10,
					S_AT_MIDDLE = 5'd11,
					S_AT_RIGHT = 5'd16,
					S_MOVING_ML = 5'd2;
					
	  
	 always@(*) begin: state_table
	
		case (current_state)
		
			S_STARTSCREEN: next_state = startGame ? S_LD_VALUE_WAIT: S_STARTSCREEN;
			S_LD_VALUE_WAIT : next_state = downEnable2 ? S_RSCLK_MIDDLE: S_LD_VALUE_WAIT;
			
			S_RSCLK_MIDDLE : next_state =  S_WAIT_MIDDLE;
			S_RSCLK_LEFT:  next_state =  S_WAIT_LEFT;
			S_RSCLK_RIGHT: next_state =  S_WAIT_RIGHT;
			
			S_WAIT_MIDDLE: begin 
				if (MLChange)
					next_state = S_MOVING_ML;
				else if (MRChange)
					next_state = S_MOVING_MR;
				else 
					next_state = S_WAIT_MIDDLE;
			end
			
			S_WAIT_LEFT: begin 
				if (LMChange)
					next_state = S_MOVING_LM;
				else 
					next_state = S_WAIT_LEFT;
			end
			
			S_WAIT_RIGHT: begin 
				if (RMChange)
					next_state = S_MOVING_RM;
				else 
					next_state = S_WAIT_RIGHT;
			end
			
			S_MOVING_ML: next_state = downEnable2 ? S_UPDATE_ML : S_MOVING_ML; 
			S_UPDATE_ML: next_state =  movingDone ? S_AT_LEFT : S_MOVING_ML;
			S_AT_LEFT: next_state = S_RSCLK_LEFT;
			
			S_MOVING_MR : next_state = downEnable2 ? S_UPDATE_MR : S_MOVING_MR;
			S_UPDATE_MR : next_state = movingDone ? S_AT_RIGHT : S_MOVING_MR;
			S_AT_RIGHT: next_state = S_RSCLK_RIGHT;
			
			S_MOVING_LM : next_state = downEnable2 ? S_UPDATE_LM : S_MOVING_LM;
			S_UPDATE_LM : next_state = movingDone ? S_AT_MIDDLE : S_MOVING_LM;
			
			S_MOVING_RM: next_state = downEnable2 ? S_UPDATE_RM : S_MOVING_RM; 
			S_UPDATE_RM: next_state =  movingDone ? S_AT_MIDDLE : S_MOVING_RM;
			
			S_AT_MIDDLE: next_state = S_RSCLK_MIDDLE;
			
			S_ENDSCREEN: next_state = resetGame ? S_STARTSCREEN : S_ENDSCREEN;
		endcase
	 
	end
	 
	 always @ (*) begin: enable_signals
	 
		// ld value is the very beginning, from gameStart to having a car in the middle 
		ld_value = 1'b0;
		// enabling draw 
		enable = 1'b0;	
		// currently moving to the left 
		ld_movingLM = 1'b0;
		ld_movingRM = 1'b0;
		ld_movingML = 1'b0;
		ld_movingMR = 1'b0; 
		// erasing the car 
		// update the coordinates 
		updateCoor = 1'b0;
		atLeft = 1'b0;
		atMiddle = 1'b0;
		atRight = 1'b0;
		reset_clock = 1'b0;
		initialize = 1'b0;
		ld_endScreen = 1'b0;
		ld_startScreen = 1'b0;
		
		case(current_state)
		
			S_STARTSCREEN: begin enable = 1'b1; ld_value = 1'b1; ld_startScreen = 1'b1; end
			S_LD_VALUE_WAIT: begin enable = 1'b1; initialize = 1'b1; atMiddle = 1'b1; end 
			
			S_MOVING_ML: begin enable = 1'b1; ld_movingML = 1'b1; end
			S_MOVING_LM: begin enable = 1'b1; ld_movingLM = 1'b1; end 
			S_MOVING_RM: begin enable = 1'b1; ld_movingRM = 1'b1; end
			S_MOVING_MR: begin enable = 1'b1; ld_movingMR = 1'b1; end 

			S_UPDATE_ML: updateCoor = 1'b1;	
			S_UPDATE_MR: updateCoor = 1'b1;	
			S_UPDATE_RM: updateCoor = 1'b1;	
			S_UPDATE_LM: updateCoor = 1'b1;	

			S_RSCLK_MIDDLE: reset_clock = 1'b1;
			S_RSCLK_LEFT: reset_clock = 1'b1;
			S_RSCLK_RIGHT: reset_clock = 1'b1;

			S_WAIT_LEFT: begin atLeft = 1'b1; enable = 1'b1; end 
			S_WAIT_MIDDLE: begin atMiddle= 1'b1; enable = 1'b1; end 
			S_WAIT_RIGHT: begin atRight = 1'b1; enable = 1'b1; end 
			
			S_ENDSCREEN: begin enable = 1'b1; ld_endScreen = 1'b1; end 
		endcase
	
	end
	  
	  always@(posedge clk) begin: state_FFs
		if (resetGame) 
			current_state <= S_STARTSCREEN;
		else if (EndScreen)
			current_state <= S_ENDSCREEN;
		else 
			current_state <= next_state;
	  end
	 
endmodule
	 
	 

module topLevel
	(
		CLOCK_50,						//	On Board 50 MHz
		KEY,								// On Board Keys
		SW,								// On Board Switches
		PS2_CLK, PS2_DAT, 
		LEDR,
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   							//	VGA Blue[9:0]
	);

	input	CLOCK_50;				
	input	[3:0]	KEY;	
	input [9:0] SW;
	inout PS2_CLK, PS2_DAT;
	output [9:0] LEDR;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire [7:0] output_keyboard;


	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	wire left, right, space, keyboard_enable, reset_game;
	PS2_Demo inputsFromKB (CLOCK_50, resetn, PS2_CLK, PS2_DAT, output_keyboard);
	
	kbDecoder decoderForKB (output_keyboard ,left, right, space, reset_game);
	
		link l0(CLOCK_50, SW[0], reset_game, left, space, right, resetn, x, y, colour, writeEn, LEDR);
//		link l0(CLOCK_50, SW, KEY[3], KEY[2], KEY[1], resetn, x, y, colour, writeEn, LEDR);
	
	
	
	
endmodule


module kbDecoder (output_keyboard, left, right, space, reset_game);
	input [7:0] output_keyboard;
	output reg left, right, space, reset_game;
	
		
	
	always@(*) begin
		
		left = 1'b0;
		right = 1'b0;
		space = 1'b0;
		reset_game = 1'b0; 
		
	case (output_keyboard)
		8'h29: space = 1'b1;
		8'h6B: left = 1'b1;
		8'h74: right = 1'b1;
		8'h76: reset_game = 1'b1;

	endcase 
	
	end 
	
endmodule 


module link(
		input clk,
		input aiMode,
		input reset_game,
		input left, space, right,
		input resetn,
		output [7:0]out_x,
		output [6:0]out_y,
		output [2:0]out_colour,
		output out_writeEn,
		output [9:0] LEDR
		);
		
		wire ld_value,ld_movingLM, ld_movingRM, ld_movingML, ld_movingMR,  downEnable2, updateCoor,
				atLeft,atMiddle, atRight,downEnable3,reset_clock, LdNewObstacle,bananaEn,initialize,ld_endScreen,ld_startScreen, StartDraw, runOver;
				
		wire [9:0] ledr;
		wire [6:0] hex0, hex1, hex2, hex3;
		wire startGame, drawExplosion, WinScreen;
		assign startGame = space;
		
		wire [7:0] position;
		wire [2:0] obstaclePos, playerPos, bananaPos;
		wire MLChange, LMChange, MRChange, RMChange, StartScreen, EndScreen, GameScreen, StartLoad, MoveObstacle, MoveBanana, TimeupOver, StartBanana, Confused;
		wire [3:0] stateOutput;
		wire [9:0] score;
		wire [1:0] gameState;
		wire [4:0] aistate;
		wire [2:0] steps;
		down_Counter2 downC2(clk,reset_clock,downEnable2);
		down_CounterCAR downCAR (clk, ld_movingLM, ld_movingRM, ld_movingML, ld_movingMR,  reset_clock,downEnable3);

		control C0 (clk,position,obstaclePos, playerPos,bananaPos, MLChange, LMChange, MRChange, RMChange, StartScreen, EndScreen,
						GameScreen,StartLoad, startGame, LdNewObstacle,bananaEn, StartBanana,downEnable2,downEnable3,keys, reset_game, score, ld_value, ld_movingLM, ld_movingRM, ld_movingML, 
						ld_movingMR, out_writeEn, updateCoor, atLeft,atMiddle,atRight,reset_clock,initialize, ld_endScreen, ld_startScreen);
						
		datapath D0 (clk, position, obstaclePos, playerPos,bananaPos, MLChange, LMChange, MRChange, RMChange, StartScreen, EndScreen, WinScreen, TimeupOver,
						GameScreen,StartLoad,LdNewObstacle,bananaEn,StartBanana,StartDraw, Confused, runOver,drawExplosion,MoveObstacle,MoveBanana, score, gameState,ld_value, ld_movingLM, ld_movingRM, ld_movingML, ld_movingMR,ld_endScreen, ld_startScreen,atLeft, atMiddle,
						atRight, reset_clock,initialize, out_writeEn, updateCoor, out_x, out_y, out_colour);
	
		gameFSMCompleteTest gameLogic (aiMode, left, space, right, clk, reset_game, startGame, ledr,hex0, hex1, hex2, hex3, position, obstaclePos, playerPos, bananaPos,stateOutput, score, gameState, aistate,steps, MLChange, 
												LMChange, MRChange, RMChange, StartScreen, EndScreen, GameScreen, WinScreen, StartLoad, LdNewObstacle, bananaEn, MoveObstacle, MoveBanana, TimeupOver, StartDraw, StartBanana, Confused, runOver, drawExplosion);				
		
		
						
					assign LEDR[9:7] = steps;	
//		assign LEDR[9:7] = obstaclePos;
	assign LEDR[4:0] = aistate;
//		assign LEDR[9:0] = score;
//		assign LEDR[5:4] = gameState;
		assign LEDR[6] = drawExplosion;
						
endmodule


module down_CounterCAR(clk,ld_movingLM, ld_movingRM, ld_movingML, ld_movingMR, reset_clock, downEnable3);

	input clk;
	input ld_movingLM;
	input ld_movingRM;
	input ld_movingML;
	input ld_movingMR;
	input reset_clock;
	output downEnable3;
	reg [25:0]Q;
	
	
	
	always@(posedge clk) begin
	if (ld_movingLM || ld_movingRM || ld_movingML || ld_movingMR)
			Q <= Q - 1;
		else if (reset_clock|| downEnable3) 
			Q <= 26'd3528985;
		
	end
		
	assign downEnable3 = (Q == 26'd0) ? 1 : 0;
	
endmodule

// to give enough time to draw the car 
module down_Counter2(clk, reset_clock,downEnable2);

	input clk;
	input reset_clock;
	output downEnable2;
	reg [21:0]Q;
	
	always@(posedge clk) begin
		if (reset_clock || downEnable2) 
			Q <= 22'd436531;
		else 
			Q <= Q - 1;
	end
		
	assign downEnable2 = (Q == 22'b0) ? 1 : 0;
	
endmodule




module DCobstacle (clk, LdNewObstacle, downEnableObstacle);

	input clk;
	input LdNewObstacle;
	output downEnableObstacle;
	reg [20:0] Q;
	
	always@(posedge clk) begin
		if (LdNewObstacle || downEnableObstacle) 
			Q <= 21'd828169;
		else 
			Q <= Q - 1;
	end
	
	assign downEnableObstacle = (Q == 21'b0) ? 1 : 0;

endmodule



module DCbanana (clk, bananaEn, downEnableBanana);

	input clk;
	input bananaEn;
	output downEnableBanana;
	reg [20:0] Q;
	
	always@(posedge clk) begin
		if (bananaEn || downEnableBanana) 
			Q <= 21'd828169;
		else 
			Q <= Q - 1;
	end
	
	assign downEnableBanana = (Q == 21'b0) ? 1 : 0;

endmodule


module DCobstacleXDirection (clk, LdNewObstacle, downEnableObstacleXDirection);

	input clk;
	input LdNewObstacle;
	output downEnableObstacleXDirection;
	reg [21:0] Q;
	
	always@(posedge clk) begin
		if (LdNewObstacle || downEnableObstacleXDirection) 
			Q <= 22'd2381000;
		else 
			Q <= Q - 1;
	end
	
	assign downEnableObstacleXDirection = (Q == 22'b0) ? 1 : 0;

endmodule




module cloudCounter (clk, downEnableCloud);

	input clk;
	output downEnableCloud;
	reg [22:0] Q;
	
	always@(posedge clk) begin
		if (downEnableCloud) 
			Q <= 23'd4761904;
		else 
			Q <= Q - 1;
	end
	
	assign downEnableCloud = (Q == 23'b0) ? 1 : 0;

endmodule
