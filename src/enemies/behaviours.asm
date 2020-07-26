BEHAVIOURS: {
	NumberOfEnemyBehaviours:
		.byte (EnemyMSB-EnemyLSB / 2)

	EnemyLSB:
		.byte <PowerUp
		.byte <Enemy_001
		.byte <Enemy_002
		.byte <Enemy_003
		.byte <Enemy_004
		.byte <Enemy_005

	EnemyMSB:
		.byte >PowerUp
		.byte >Enemy_001
		.byte >Enemy_002
		.byte >Enemy_003
		.byte >Enemy_004
		.byte >Enemy_005


	.label BEHAVIOUR_SPAWN = 0;
	.label BEHAVIOUR_UPDATE = 3;
	.label BEHAVIOUR_DEATH = 6;


	//Powerup behaviour
	PowerUpColorsA:
			.byte 1,7,3,4,5,6
	PowerUpColorsB:
			.byte 1,7,3,8,5,6

	PowerUpFrames:
			.byte $3b,$3c,$3d,$3c
	__PowerUpFrames:
			
	PowerUp: {
			jmp !OnSpawn+ 
			jmp !OnUpdate+ 
			jmp !OnDeath+

			.label POWERUP_TYPE = $00
			.label BOUNCE = $01
			.label FRAME = $02

		!OnSpawn:
				jsr Random
				and #$03
				:setStaticMemory(POWERUP_TYPE, null)
				:setStaticMemory(BOUNCE, $00)
				:setStaticMemory(FRAME, $00)
				lda PowerUpFrames
				:setEnemyFrame(0)
				rts

		!OnUpdate:
				:getStaticMemory(POWERUP_TYPE)
				tay
				lda ZP_COUNTER
				and #$01
				beq !Col2+
			!Col1:		
				lda PowerUpColorsA, y 
				bne !Apply+
			!Col2:
				lda PowerUpColorsB, y 
			!Apply:
				sta ENEMIES.EnemyColor, x


				:getStaticMemory(FRAME)
				tay
				lda ZP_COUNTER
				and #$07
				bne !+
				iny
				cpy #[__PowerUpFrames - PowerUpFrames]
				bne !+
				ldy #$00
			!:
				tya 
				:setStaticMemory(FRAME, null)
				lda PowerUpFrames, y
				sta ENEMIES.EnemyFrame, x
			!skip:


				:getStaticMemory(BOUNCE)
				beq !Fall+
				sec 
				sbc #$01
				:setStaticMemory(BOUNCE, null)
				:UpdatePosition(0, -96)
				jmp !Finish+

			!Fall:
				:doFall(12, 22)
				bcs !Finish+
				:setStaticMemory(BOUNCE, $10)
				
			!Finish:
				:PositionEnemy() //Draw!!
				rts

		!OnDeath:	
				// .break
				lda #$00
				sta ENEMIES.EnemyType, x
				:getStaticMemory(POWERUP_TYPE)

				rts

	}

	//BOILED SWEET FLYER = Flying candy monster bounces of scenery
	Enemy_001: {
			jmp !OnSpawn+ 
			jmp !OnUpdate+ 
			jmp !OnDeath+

			.label ANIM_FRAME = $00
			.label DX = $01
			.label DY = $02

		FlyAnimation:
			.byte $2b,$2c,$2d,$2c
		__FlyAnimation:

		!OnSpawn:	
				:setStaticMemory(ANIM_FRAME, $00)	
				jsr Random
				and #$01
				asl
				clc
				adc #$ff
				:setStaticMemory(DX, null)

				jsr Random
				and #$01
				asl
				clc 
				adc #$ff
				:setStaticMemory(DY, null)

				lda FlyAnimation
				:setEnemyFrame(0)
				rts

		CollisionPointsY:
				.byte 0, 20
		CollisionPointsX:
				.byte 0, 23

		!OnUpdate:	
				:exitIfStunned()


				:getStaticMemory(ANIM_FRAME)
				//TODO: Optimise
				tay
				lda ZP_COUNTER
				and #$03
				bne !+
				iny
				cpy #[__FlyAnimation - FlyAnimation]
				bne !+
				ldy #$00
			!:
				tya 
				:setStaticMemory(ANIM_FRAME, null)
				lda FlyAnimation, y
				sta ENEMIES.EnemyFrame, x
			!skip:


				:setEnemyColor(7, null)
				:hasHitProjectile()
				:getStaticMemory(DY)
				tay
				:getStaticMemory(DX)
				:UpdatePosition(null, null)				

			!YBounce:
				lda ENEMIES.EnemyPosition_Y1, x
				cmp #$32
				bcc !DoYBounce+
				cmp #$cd
				bcs !DoYBounce+
			!:
				:getStaticMemory(DY)
				clc
				adc #$01
				lsr
				tay
				lda CollisionPointsY, y
				tay
				lda #$0a
				:getEnemyCollisions(null, null)
				tay
				lda CHAR_COLORS, y
				and #UTILS.COLLISION_SOLID	
				beq !NoYBounce+
			!DoYBounce:
				:getStaticMemory(DY)
				eor #$ff
				clc
				adc #$01
				:setStaticMemory(DY, null)

			!NoYBounce:	

			!XBounce:
				lda ENEMIES.EnemyPosition_X2, x
				lsr
				lda ENEMIES.EnemyPosition_X1, x
				ror

				cmp #$0c
				bcc !DoXBounce+
				cmp #$a0
				bcs !DoXBounce+
			!:

				:getStaticMemory(DX)
				clc
				adc #$01
				lsr
				tay
				lda CollisionPointsX, y
				ldy #$0c
				:getEnemyCollisions(null, null)
				tay
				lda CHAR_COLORS, y
				and #UTILS.COLLISION_SOLID	
				beq !NoXBounce+
			!DoXBounce:
				:getStaticMemory(DX)
				eor #$ff
				clc
				adc #$01
				:setStaticMemory(DX, null)
			!NoXBounce:	
			!ExitBounce:

				:PositionEnemy()
				rts

		!OnDeath:
				rts
	}


	//JELLY BEAN - Enemy walks back and forth on platforms
	Enemy_002: {
			jmp !OnSpawn+ 
			jmp !OnUpdate+ 
			jmp !OnDeath+

			.label WALK_FRAME = $00

		WalkLeft:
			.byte $13,$14,$15
		__WalkLeft:
		WalkRight:
			.byte $10,$11,$12
		__WalkRight:

		!OnSpawn:
				//Set pointer
				lda WalkLeft
				:setEnemyFrame(0)
				:setEnemyColor(2, null)
				lda ENEMIES.EnemyState, x
				ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
				sta ENEMIES.EnemyState, x
				:setStaticMemory(WALK_FRAME, 0)
				rts

		!OnUpdate:
				:exitIfStunned()
				:setEnemyColor(2, null)

				:hasHitProjectile()
				//Should I fall??
				:doFall(12, 21) //Check below enemy and fall if needed
				bcc !+
				jmp !Done+
			!:
				lda PLAYER.Player_Freeze_Active
				bne !Skip+
				//TODO: Optimise
				//Do walk animation
				lda ZP_COUNTER
				and #$07
				bne !Skip+
				:getStaticMemory(WALK_FRAME)
				clc
				adc #1
				cmp #[__WalkRight - WalkRight]
				bne !+
				lda #$00
			!:
				:setStaticMemory(WALK_FRAME, null)
			!Skip:

				//Snap enemy to floor
				jsr snapEnemyToFloor

			!CheckLeft:
				lda ENEMIES.EnemyState, x
				bit TABLES.Plus + ENEMIES.STATE_WALK_LEFT

				beq !CheckRight+

				//Do walk left
				:getEnemyCollisions(0, 21)
				tay
				lda CHAR_COLORS, y
				and #UTILS.COLLISION_COLORABLE
				beq !ChangeDir+
			!WalkLeft:
				:UpdatePosition(-$080, $000)

				:getStaticMemory(WALK_FRAME)
				tay
				lda WalkLeft, y
				:setEnemyFrame(null)

				jmp !Done+

			!ChangeDir:
				:setEnemyFrame(21)
				lda ENEMIES.EnemyState, x
				and #[255 -[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]]
				ora #[ENEMIES.STATE_FACE_RIGHT + ENEMIES.STATE_WALK_RIGHT]
				sta ENEMIES.EnemyState, x
				jmp !Done+
				

			!CheckRight:
				bit TABLES.Plus + ENEMIES.STATE_WALK_RIGHT
				beq !+
				//Do Walk right
				:getEnemyCollisions(24, 21)
				tay
				lda CHAR_COLORS, y
				and #UTILS.COLLISION_COLORABLE
				beq !ChangeDir+
			!WalkRight:
				:UpdatePosition($080, $000)

				:getStaticMemory(WALK_FRAME)
				tay
				lda WalkRight, y
				:setEnemyFrame(null)

				jmp !Done+

			!ChangeDir:
				:setEnemyFrame(16)
				lda ENEMIES.EnemyState, x
				and #[255 -[ENEMIES.STATE_FACE_RIGHT + ENEMIES.STATE_WALK_RIGHT]]
				ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
				sta ENEMIES.EnemyState, x
				// jmp !Done+
			!:

			!Done:
				:PositionEnemy()
				rts

		!OnDeath:
				rts
	}


	//COLA BOTTLE - Enemy walks back and forth on platforms
	Enemy_003: {
			jmp !OnSpawn+ 
			jmp !OnUpdate+ 
			jmp !OnDeath+

			.label WALK_FRAME = $00

		WalkLeft:
			.byte $22,$23,$24
		__WalkLeft:
		WalkRight:
			.byte $1f,$20,$21
		__WalkRight:

		!OnSpawn:
				//Set pointer
				lda WalkLeft
				:setEnemyFrame(0)
				:setEnemyColor(2, null)
				lda ENEMIES.EnemyState, x
				ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
				sta ENEMIES.EnemyState, x
				:setStaticMemory(WALK_FRAME, 0)
				rts

		!OnUpdate:
				:exitIfStunned()
				:setEnemyColor(2, null)

				:hasHitProjectile()
				//Should I fall??
				:doFall(12, 21) //Check below enemy and fall if needed
				bcc !+
				jmp !Done+
			!:
				lda PLAYER.Player_Freeze_Active
				bne !Skip+
				//TODO: Optimise
				//Do walk animation
				lda ZP_COUNTER
				and #$07
				bne !Skip+
				:getStaticMemory(WALK_FRAME)
				clc
				adc #1
				cmp #[__WalkRight - WalkRight]
				bne !+
				lda #$00
			!:
				:setStaticMemory(WALK_FRAME, null)
			!Skip:

				//Snap enemy to floor
				jsr snapEnemyToFloor

			!CheckLeft:
				lda ENEMIES.EnemyState, x
				bit TABLES.Plus + ENEMIES.STATE_WALK_LEFT

				beq !CheckRight+

				//Do walk left
				jsr CheckScreenEdges
				beq !ChangeDir+
			!WalkLeft:
				:UpdatePosition(-$080, $000)

				:getStaticMemory(WALK_FRAME)
				tay
				lda WalkLeft, y
				:setEnemyFrame(null)

				jmp !Done+

			!ChangeDir:
				:setEnemyFrame(31)
				jmp !Done+
				

			!CheckRight:
				bit TABLES.Plus + ENEMIES.STATE_WALK_RIGHT
				beq !+

				//Do Walk right
				jsr CheckScreenEdges
				beq !ChangeDir+
			!WalkRight:
				:UpdatePosition($080, $000)

				:getStaticMemory(WALK_FRAME)
				tay
				lda WalkRight, y
				:setEnemyFrame(null)

				jmp !Done+

			!ChangeDir:
				:setEnemyFrame(36)
				// jmp !Done+
			!:

			!Done:
				:PositionEnemy()
				rts

		!OnDeath:
				rts
	}


	//SAUCER FLYER = Flys left and right changing direction at random
	Enemy_004: {
			jmp !OnSpawn+ 
			jmp !OnUpdate+ 
			jmp !OnDeath+

			.label ANIM_FRAME = $00
			.label DX = $01

		FlyAnimation:
			.byte $1c,$1d,$1e,$1d
		__FlyAnimation:

		!OnSpawn:	
				:setStaticMemory(ANIM_FRAME, $00)	
				jsr Random
				and #$01
				asl
				clc
				adc #$ff
				:setStaticMemory(DX, null)

				lda FlyAnimation
				:setEnemyFrame(0)
				rts

		CollisionPointsY:
				.byte 0, 20
		CollisionPointsX:
				.byte 0, 23

		!OnUpdate:	
				:exitIfStunned()

				//Set the enmy frame
				:getStaticMemory(ANIM_FRAME)
				//TODO: Optimise
				tay
				lda ZP_COUNTER
				and #$03
				bne !+
				iny
				cpy #[__FlyAnimation - FlyAnimation]
				bne !+
				ldy #$00
			!:
				tya 
				:setStaticMemory(ANIM_FRAME, null)
				lda FlyAnimation, y
				sta ENEMIES.EnemyFrame, x
			!skip:


				:setEnemyColor(8, null)
				:hasHitProjectile()
				:getStaticMemory(DX)
				ldy #$00
				:UpdatePosition(null, null)				



			!XBounce:
				jsr Random
				cmp #$04
				bcc !DoXBounce+ 


				lda ENEMIES.EnemyPosition_X2, x
				lsr
				lda ENEMIES.EnemyPosition_X1, x
				ror

				cmp #$0c
				bcc !DoXBounce+
				cmp #$a0
				bcs !DoXBounce+
			!:
				:getStaticMemory(DX)
				clc
				adc #$01
				lsr
				tay
				lda CollisionPointsX, y
				ldy #$0c
				:getEnemyCollisions(null, null)
				tay
				lda CHAR_COLORS, y
				and #UTILS.COLLISION_SOLID	
				beq !NoXBounce+
			!DoXBounce:
				:getStaticMemory(DX)
				eor #$ff
				clc
				adc #$01
				:setStaticMemory(DX, null)
			!NoXBounce:	
			!ExitBounce:

				:PositionEnemy()
				rts

		!OnDeath:
				rts
	}


	//CANDY CANE - Enemy walks back and forth on platforms
	//				but jumps at the edges
	Enemy_005: {
			jmp !OnSpawn+ 
			jmp !OnUpdate+ 
			jmp !OnDeath+

			.label WALK_FRAME = $00
			.label JUMP_TIMER = $01
			.label JUMP_INDEX = $02

		JumpLeft:
			.byte $28,$29,$2a
		__JumpLeft:
		JumpRight:
			.byte $25,$26,$27
		__JumpRight:

		!OnSpawn:
				//Set pointer
				lda JumpLeft
				:setEnemyFrame(0)
				:setEnemyColor(1, null)

				jsr Random
				bmi !faceRight+

			!faceLeft:
				lda ENEMIES.EnemyState, x
				ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
				sta ENEMIES.EnemyState, x
				lda JumpLeft
				bne !faceDone+

			!faceRight:
				lda ENEMIES.EnemyState, x
				ora #[ENEMIES.STATE_FACE_RIGHT + ENEMIES.STATE_WALK_RIGHT]
				sta ENEMIES.EnemyState, x
				lda JumpRight

			!faceDone:
				:setEnemyFrame(0)
				// :setStaticMemory(WALK_FRAME, 0)

				jsr Random
				and #$7f
				clc
				adc #$32
				:setStaticMemory(JUMP_TIMER, null)

				:setStaticMemory(JUMP_INDEX, $ff)				
				rts

		!OnUpdate:
				:exitIfStunned()
				:setEnemyColor(1, null)

				:hasHitProjectile()
			
				lda PLAYER.Player_Freeze_Active
				bne !Skip+

				//Check if enemy is already in a jump anmimation
				:getStaticMemory(JUMP_INDEX)
				bpl !DoJumpRoutine+

				//Should I fall??				
				:doFall(12, 21) //Check below enemy and fall if needed
				bcc !+
				jmp !Done+
			!:

				//Snap enemy to floor
				jsr snapEnemyToFloor

				:getStaticMemory(JUMP_TIMER)
				tay
				dey
				tya
				:setStaticMemory(JUMP_TIMER, 0) 
				bne !Done+
				:setStaticMemory(JUMP_INDEX, 0)	

				//Now do jump routine
			!DoJumpRoutine:
				:getStaticMemory(JUMP_INDEX)
				tay 

				lda TABLES.JumpAndFallTable, y
				sta BEHAVIOUR_TEMP1
				lda ENEMIES.EnemyPosition_Y1, x
				sec
				sbc BEHAVIOUR_TEMP1
				sta ENEMIES.EnemyPosition_Y1, x
				// dec ENEMIES.EnemyPosition_Y1, x
				iny
				cpy #[TABLES.__JumpAndFallTable - TABLES.JumpAndFallTable - 1]
				bne !+
				
				//Reset jump timer
				jsr Random
				and #$7f
				clc
				adc #$32
				:setStaticMemory(JUMP_TIMER, null)

				ldy #$ff
			!:
				tya
				:setStaticMemory(JUMP_INDEX, null)

			!Done:	
			!Skip:
			
				:PositionEnemy()
				rts

		!OnDeath:
				rts
	}













	StunnedBehaviour: {
		update: {
			lda ZP_COUNTER
			and #$03
			bne !+
			dec ENEMIES.EnemyStunTimer, x
			bne !+
			lda ENEMIES.EnemyState, x
			and #[255 - ENEMIES.STATE_STUNNED]
			sta ENEMIES.EnemyState, x
			rts
		!:	
			lda ENEMIES.EnemyStunTimer, x
			cmp #$30
			bcs !SetColorNormal+
			and #$01
			beq !SetColor2+
		!SetColor1:
			:setEnemyColor($0c, null)
			jmp !Skip+
		!SetColor2:
			:setEnemyColor($02, null)
			jmp !Skip+
		!SetColorNormal:
			:setEnemyColor($0c, null)
		!Skip:

			:doFall(12, 21)
		// 	bcs !+
		// 	:snapEnemyToFloor()
		// !:
			:PositionEnemy()
			rts
		}
	}



	AbsorbBehaviour: {
		.label TimeBetweenEatFrames = $04

		setup: {
			txa
			clc
			adc #$bb //Calculate the sprite pointer
			:setEnemyFrame(null)

			//Determine the start of the eat absorb animation
			// Type * $0200 + (EnemyIsFacingRight * $0100) + $6a00
			lda #$00
			sta ENEMIES.EnemyEatPointerLSB, x
			lda ENEMIES.EnemyType, x
			asl
			sta ENEMIES.EnemyEatPointerMSB, x

			lda ENEMIES.EnemyEatOffsetX, x
			bmi !+
			lda #$6b //MSB of $6a00 + $0100
			
			jmp !DoAdd+
		!:
			lda #$6a

		!DoAdd:
			adc ENEMIES.EnemyEatPointerMSB, x
			sta ENEMIES.EnemyEatPointerMSB, x

			//Add 350 score for absorbing
			txa

			pha //Stack = EnemyNum

			lda ENEMIES.EnemyEatenBy, x
			pha	//Stack = EnemyNum, PlayerNum
			tay
			dey
			lda #$35
			ldx #$01
			jsr HUD.AddScore

			dec ENEMIES.EnemyTotalCount
			//Increment eat meter for player
			pla //Gets PlayerNum, Stack = EnmemyNum
			tax
			dex

			lda PIPES.EnemyWeight		
			clc
			adc PLAYER.Player_Weight, x
			sta PLAYER.Player_Weight, x
			inc PLAYER.Player1_EatCount, x
			jsr HUD.UpdateEatMeter

			pla //Gets enemyNum
			tax 

			

			lda #$04 //Number of frames in eat animation
			sta ENEMIES.EnemyEatenIndex, x
			lda #$01 //Frame timer
			sta ENEMIES.EnemyEatenCounter, x

			:playSFX(SOUND.PlayerEat)
			
			rts
		}


		update: {	
			.label SpriteFrom = VECTOR7
			.label SpriteTo = VECTOR8

			//Move enemy along X
			lda ENEMIES.EnemyEatOffsetX, x
			beq !DoneMoveHoriz+
			bmi !MoveRight+
		!MoveLeft:
			dec ENEMIES.EnemyEatOffsetX, x
			:UpdatePosition($100, $000)
			jmp !DoneMoveHoriz+
		!MoveRight:
			inc ENEMIES.EnemyEatOffsetX, x
			:UpdatePosition(-$100, $000)
		!DoneMoveHoriz:	

			//Move enemy along Y
			lda ENEMIES.EnemyEatOffsetY, x
			beq !DoneMoveVert+
			bmi !MoveUp+
		!MoveDown:
			dec ENEMIES.EnemyEatOffsetY, x
			:UpdatePosition($000, $100)
			jmp !DoneMoveVert+
		!MoveUp:
			inc ENEMIES.EnemyEatOffsetY, x
			:UpdatePosition($000, -$100)
		!DoneMoveVert:	

			//Initialise sprite copy vectors
			lda ENEMIES.EnemyEatPointerLSB,x
			sta SpriteFrom
			lda ENEMIES.EnemyEatPointerMSB,x
			sta SpriteFrom + 1
			txa
			asl
			tay
			lda EatData, y
			sta SpriteTo
			lda EatData + 1, y
			sta SpriteTo + 1

			//Do we draw the frame?
			dec ENEMIES.EnemyEatenCounter, x
			bne !NoFrameCopy+
			lda #TimeBetweenEatFrames
			sta ENEMIES.EnemyEatenCounter, x

			lda ENEMIES.EnemyEatenIndex, x
			bne !NotFinished+ //Have we finished eating?
		!Finished:
			lda #$00
			sta ENEMIES.EnemyType, x
			rts	//No need to continue	

		!NotFinished:
			dec ENEMIES.EnemyEatenIndex, x

			//Copy sprite data for absorb
			ldy #$3f
		!Loop:
			lda (SpriteFrom), y
			sta (SpriteTo), y
			dey
			bpl !Loop-

			//Update frame
			clc
			lda ENEMIES.EnemyEatPointerLSB,x
			adc #$40
			sta ENEMIES.EnemyEatPointerLSB,x
			lda ENEMIES.EnemyEatPointerMSB,x
			adc #$00
			sta ENEMIES.EnemyEatPointerMSB,x

		//Update position color/frame etc
		//No frame Copy
		!NoFrameCopy:
			:PositionEnemy()
			rts
		}
	}

	EatData:
		.word $eec0
		.word $ef00
		.word $ef40
		.word $ef80
		.word $efc0
}





