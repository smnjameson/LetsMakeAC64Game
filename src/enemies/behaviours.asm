BEHAVIOURS: {

	EnemyLSB:
		.byte $ff
		.byte <Enemy_001
		.byte <Enemy_002

	EnemyMSB:
		.byte $ff
		.byte >Enemy_001
		.byte >Enemy_002


	.label BEHAVIOUR_SPAWN = 0;
	.label BEHAVIOUR_UPDATE = 3;
	.label BEHAVIOUR_DEATH = 6;



	//Flying candy monster bounces of scenery
	Enemy_001: {
			jmp !OnSpawn+ 
			jmp !OnUpdate+ 
			jmp !OnDeath+

			.label ANIM_FRAME = $00
			.label DX = $01
			.label DY = $02

		FlyAnimation:
			.byte 16,17,18,19,20
		__FlyAnimation:

		!OnSpawn:		
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

				:setEnemyFrame(16)
				rts

		CollisionPointsY:
				.byte 0, 20
		CollisionPointsX:
				.byte 0, 23

		!OnUpdate:	
				:exitIfStunned()
				:setEnemyColor(7, 13)
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
				and #PLAYER.COLLISION_SOLID	
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
				and #PLAYER.COLLISION_SOLID	
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


	//Enemy walks back and forth on platforms
	Enemy_002: {
			jmp !OnSpawn+ 
			jmp !OnUpdate+ 
			jmp !OnDeath+

			.label WALK_FRAME = $00

		WalkLeft:
			.byte 16,17,18,19,20
		__WalkLeft:
		WalkRight:
			.byte 21,22,23,24,25
		__WalkRight:

		!OnSpawn:
				//Set pointer
				:setEnemyFrame(16)
				:setEnemyColor(7, null)
				lda ENEMIES.EnemyState, x
				ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
				sta ENEMIES.EnemyState, x
				:setStaticMemory(WALK_FRAME, 0)
				rts

		!OnUpdate:
				:exitIfStunned()
				:setEnemyColor(5, 14)

				:hasHitProjectile()
				//Should I fall??
				:doFall(12, 21) //Check below enemy and fall if needed
				bcc !+
				jmp !Done+
			!:
				//Do walk animation
				lda ZP_COUNTER
				and #$03
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
				:snapEnemyToFloor()

			!CheckLeft:
				lda ENEMIES.EnemyState, x
				bit TABLES.Plus + ENEMIES.STATE_WALK_LEFT

				beq !CheckRight+

				//Do walk left
				:getEnemyCollisions(0, 21)
				tay
				lda CHAR_COLORS, y
				and #PLAYER.COLLISION_COLORABLE
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
				and #PLAYER.COLLISION_COLORABLE
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
		.label TimeBetweenEatFrames = $02

		setup: {
			txa
			clc
			adc #$bb //Calculate the sprite pointer
			:setEnemyFrame(null)

			//Determine the start of the eat absorb animation
			// Type * $0400 + (EnemyIsFacingRight * $0200) + $5c00
			lda #$00
			sta ENEMIES.EnemyEatPointerLSB, x
			lda ENEMIES.EnemyType, x
			asl
			asl
			sta ENEMIES.EnemyEatPointerMSB, x

			lda ENEMIES.EnemyEatOffsetX, x
			bmi !+
			lda #$5e //MSB of $5c00 + $0200
			
			jmp !DoAdd+
		!:
			lda #$5c

		!DoAdd:
			adc ENEMIES.EnemyEatPointerMSB, x
			sta ENEMIES.EnemyEatPointerMSB, x

			//Add 350 score for absorbing
			txa

			pha //Stack = EnemyNum

			lda ENEMIES.EnemyEatenBy, x
			.break
			pha	//Stack = EnemyNum, PlayerNum
			tay
			dey
			lda #$35
			ldx #$01
			jsr HUD.AddScore

			//Increment eat meter for player
			pla //Gets PlayerNum, Stack = EnmemyNum
			tax
			dex
		//DEBUG////////////////
			cpx #$ff
			bne !+
			.break
			nop
		!:
		
		///////////////////////

		// :DebugHex(null, 9, 23, 220)
			inc PLAYER.Player1_EatCount, x
			jsr HUD.UpdateEatMeter

			pla //Gets enemyNum
			tax 

			

			lda #$08 //Number of frames in eat animation
			sta ENEMIES.EnemyEatenIndex, x
			lda #$01 //Frame timer
			sta ENEMIES.EnemyEatenCounter, x

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





