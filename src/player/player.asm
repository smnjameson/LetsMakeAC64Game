* = * "Player"

PLAYER: {
	.label POWERUP_SPEED = $01 //Done
	.label POWERUP_INVULN = $02 //Done
	.label POWERUP_COLOR = $03 //Done
	.label POWERUP_JUMP = $04  //Done
	.label POWERUP_FREEZE = $05 //Done
	.label POWERUP_SCORE = $06 //Done 


	.label STATE_JUMP 		= %00000001
	.label STATE_FALL 		= %00000010
	.label STATE_WALK_LEFT  = %00000100
	.label STATE_WALK_RIGHT = %00001000
	.label STATE_FACE_LEFT  = %00010000
	.label STATE_FACE_RIGHT = %00100000
	.label STATE_THROWING 	= %01000000
	.label STATE_EATING 	= %10000000


	.label PLAYER_1 = %00000001
	.label PLAYER_2 = %00000010


	.label JOY_UP = %00001
	.label JOY_DN = %00010
	.label JOY_LT = %00100
	.label JOY_RT = %01000
	.label JOY_FR = %10000

	.label LEFT_SCREEN_EDGE = $0a //MSB = 0  ///14
	.label RIGHT_SCREEN_EDGE = $4e //MSB = 1  //44

	.label PLAYER_RIGHT_COLLISON_BOX = 19
	.label PLAYER_LEFT_COLLISON_BOX = 5
	.label FOOT_COLLISION_OFFSET = 3

	.label FIRE_HELD_THRESHOLD = 15

	FreezeColorRamp:
			.byte $03,$0e,$06,$06,$06,$06,$06,$0e
	SpeedColorRamp:
			.byte 0,0,0,1,0,0,0,1
	JumpColorRamp:
			.byte 0,0,0,1,0,0,0,1
	FreezeColorIndex:
			.byte $01
	FreezeColor:
			.byte $06
	SpeedColor:
			.byte $06
	JumpColor:
			.byte $06


	CurrentLevel:
			.byte $00

	PlayerColors:
			.byte $02, $03

	PlayerInvulnRamp:
		.byte $01,$0a,$08,$0b,$02,$0b,$08,$0a
		.byte $01,$0e,$0e,$0b,$03,$0b,$0e,$0e
			// .byte $07,$0f,$06,$0e,$06,$0f,$07,$01

	DefaultLeftRightFrames:
			.byte 67, 64
	PlayersActive:
			.byte $00

	Player_Lives:
	Player1_Lives:
		.byte $04
	Player2_Lives:
		.byte $04

	Player_Invuln:
	Player1_Invuln:
		.byte $00
	Player2_Invuln:
		.byte $00

	Player_Weight:
	Player1_Weight:
		.byte $00
	Player2_Weight:
		.byte $00

	Player1_X:
			// Fractional / LSB / MSB   
			.byte $00, $88, $00 // 1/256th pixel accuracy
	Player2_X:
			// Fractional / LSB / MSB
			.byte $00, $98, $00 // 1/256th pixel accuracy


	Player1_Y:
			.byte $c0 // 1 pixel accuracy
	Player2_Y:
			.byte $c0 // 1 pixel accuracy


	//Flags
	Player_IsDying:
	Player1_IsDying:
			.byte $00
	Player2_IsDying:
			.byte $00
	Player1_FirePressed:
			.byte $00
	Player2_FirePressed:
			.byte $00
	Player1_FireHeld:
			.byte $00
	Player2_FireHeld:
			.byte $00

	Player1_FloorCollision:
			.byte $00
	Player2_FloorCollision:
			.byte $00

	Player1_FloorANDCollision:
			.byte $00
	Player2_FloorANDCollision:
			.byte $00

	Player1_RightCollision:
			.byte $00
	Player2_RightCollision:
			.byte $00

	Player1_LeftCollision:
			.byte $00
	Player2_LeftCollision:
			.byte $00


	Player1_JumpIndex:
			.byte $00
	Player2_JumpIndex:
			.byte $00
	
	Player_WalkIndex:
	Player1_WalkIndex:
			.byte $00
	Player2_WalkIndex:
			.byte $00

	Player1_EatIndex:
			.byte $00
	Player2_EatIndex:
			.byte $00

	Player_ThrowIndex:
	Player1_ThrowIndex:
			.byte $00
	Player2_ThrowIndex:
			.byte $00

	Player_State:
	Player1_State:
			.byte $00
	Player2_State:
			.byte $00

	Player_WalkSpeed:
	Player1_WalkSpeed:
			.byte $80, $01
	Player2_WalkSpeed:
			.byte $80, $01

	PlayerWalkSpeeds_LSB:
			.byte $80,$40,$00
	PlayerWalkSpeeds_MSB:
			.byte $01,$01,$01
	Player_BoostSpeed:
			.byte $80, $00

	Player1_EatCount:
			.byte $00
	Player2_EatCount:
			.byte $00
	DefaultFrame:
			.byte $40, $40

	Player_Size:
	Player1_Size:
			.byte $00
	Player2_Size:
			.byte $00

	.label PLAYER_SIZE_TIME = $40
	Player_Size_Timer:
	Player1_Size_Timer:
			.byte $00
	Player2_Size_Timer:
			.byte $00


	Player_ExitIndex:
	Player1_ExitIndex:
			.byte $ff
	Player2_ExitIndex:
			.byte $ff

	Player_PowerupType:
	Player1_PowerupType:
			.byte $00
	Player2_PowerupType:
			.byte $00
	Player_PowerupTimer:
	Player1_PowerupTimer:
			.byte $00
	Player2_PowerupTimer:
			.byte $00
	PlayerFloorColor:
	Player1FloorColor:
			.byte $00
	Player2FloorColor:
			.byte $00
	PlayerAbsorbingCount:
			.byte $00,$00

	Player_Freeze_Active:
			.byte $00
	ColorSwitchActive:
			.byte $00
	ColorSwitchRow:
			.byte $00

		
	Initialise: {
			lda #%00001100
			sta $d018


			lda #$0a
			sta VIC.SPRITE_MULTICOLOR_1
			lda #$09
			sta VIC.SPRITE_MULTICOLOR_2

			//Reset screen/sprite attributes from intro
			lda #$ff
			sta $d01c
			lda #$00
			sta $d01d
			sta $d01b
			lda $d011
			and #%11110000
			ora #%00001000
			sta $d011
			lda $d016
			and #%11110000
			ora #%00001000
			sta $d016

			lda #$00
			sta $d023

			lda #$08
			sta VIC.SPRITE_COLOR_5

			lda PlayerColors + 0
			sta VIC.SPRITE_COLOR_6

			lda PlayerColors + 1
			sta VIC.SPRITE_COLOR_7

			lda #$40
			sta SPRITE_POINTERS + 6
			sta SPRITE_POINTERS + 7



			lda #$04
			sta Player1_Lives
			lda #$04
			sta Player2_Lives

			lda #$00
			sta Player1_Weight
			sta Player2_Weight
			sta Player1_EatCount
			sta Player2_EatCount
			sta Player1_Size
			sta Player2_Size

			sta SCREEN_SHAKE_VAL

			lda #$ff
			sta Player1_ExitIndex
			sta Player2_ExitIndex

			lda PlayersActive
			and #$01
			beq !+
			ldx #$00
			jsr SpawnPlayer

		!:

			lda PlayersActive
			and #$02
			beq !+	
			ldx #$01
			jsr SpawnPlayer

		!:

			lda #$00
			sta Player1_PowerupTimer
			sta Player2_PowerupTimer
			sta Player_Freeze_Active
			sta ColorSwitchActive
			sta ENEMIES.PowerUpTotalCount
			sta ENEMIES.EnemyTotalCount





			rts
	}


	SpawnPlayer: {
			//X = 0 or 1 = Player 1 or 2
			lda PlayersActive
			ora TABLES.PowerOfTwo, x
			sta PlayersActive


			//MAP LOOKUP
			lda #<MAPDATA.MAP_1.PlayerSpawns
			sta MAP_LOOKUP_VECTOR + 0
			lda #>MAPDATA.MAP_1.PlayerSpawns
			sta MAP_LOOKUP_VECTOR + 1



			cpx #$00
			bne !Plyr2+
		!Plyr1:
			lda #[STATE_FACE_RIGHT + STATE_WALK_RIGHT]
			sta Player1_State
			lda #$00
			sta Player1_IsDying
			lda DefaultLeftRightFrames + 1
			sta DefaultFrame + 0	


			ldy #$00
			lda (MAP_LOOKUP_VECTOR), y
			sta PLAYER.Player1_X + 1
			iny
			lda (MAP_LOOKUP_VECTOR), y
			sta PLAYER.Player1_X + 2
			iny
			lda (MAP_LOOKUP_VECTOR), y
			sta PLAYER.Player1_Y + 0

			lda #$ff 
			sta Player1_Invuln 

			lda #$00
			sta Player1_PowerupTimer

			jmp !PlayerSpecificsDone+

		!Plyr2:
			lda #[STATE_FACE_LEFT + STATE_WALK_LEFT]
			sta Player2_State
			lda #$00
			sta Player2_IsDying	
			lda DefaultLeftRightFrames + 0
			sta DefaultFrame + 1

			ldy #$03
			lda (MAP_LOOKUP_VECTOR), y
			sta PLAYER.Player2_X + 1
			iny
			lda (MAP_LOOKUP_VECTOR), y
			sta PLAYER.Player2_X + 2
			iny
			lda (MAP_LOOKUP_VECTOR), y
			sta PLAYER.Player2_Y + 0

			lda #$ff 
			sta Player2_Invuln 

			lda #$00
			sta Player2_PowerupTimer

		!PlayerSpecificsDone:
			rts
	}

	KillPlayer: {
			//Y = 0 or 1 = Player 1 or 2
			tya 
			tax
			dec Player_Lives, x
			bpl !+
			jmp GameOverPlayer
		!:
			jsr SpawnPlayer
			rts
	}

	GameOverPlayer: {
		!:
		 	dec PlayersActive
		 	dey 
		 	bpl !-

		 	pha 
		 	lda PlayersActive
		 	bne !+
		 	lda #$01
		 	jsr $1000
		 !:
		 	pla 

		 	//Record score
		 	cmp #$00
		 	bne !P2+
		 !P1:
		 	jsr HUD.RecordScoreP1
		 	rts
		 !P2:
		 	jsr HUD.RecordScoreP2
		 	rts
	}


	GetCollisions: {


		lda PlayersActive
		and #$01
		bne !+
		lda #$40
		sta Player1_FloorANDCollision
		jmp !PlayerOneComplete+
	!:

		//Get floor collisions for each foot for Player 1
		lda #$00
		ldx #PLAYER_LEFT_COLLISON_BOX + FOOT_COLLISION_OFFSET
		ldy #23
		jsr PLAYER.GetCollisionPoint

		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		sta Player1_FloorCollision
		sta Player1_FloorANDCollision
		jsr UTILS.GetColorAt
		sta Player1FloorColor
		
		// lda #$00
		// ldx #PLAYER_RIGHT_COLLISON_BOX - FOOT_COLLISION_OFFSET
		// ldy #23
		// jsr PLAYER.GetCollisionPoint
		ldx #PLAYER_RIGHT_COLLISON_BOX - FOOT_COLLISION_OFFSET
		stx COLLISION_POINT_X_OFFSET
		jsr UTILS.GetCollisionPoint


		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		ora Player1_FloorCollision
		sta Player1_FloorCollision
		lda CHAR_COLORS, x
		and Player1_FloorANDCollision
		sta Player1_FloorANDCollision
		jsr UTILS.GetColorAt
		cmp Player1FloorColor
		beq !+
		lda #$01
	!:
		sta Player1FloorColor


		//Moving inside walls check
		// lda #$00
		// ldx #$0c
		// ldy #11
		// jsr PLAYER.GetCollisionPoint
		ldx #PLAYER_RIGHT_COLLISON_BOX - FOOT_COLLISION_OFFSET
		stx COLLISION_POINT_X_OFFSET
		ldy #11
		sty COLLISION_POINT_Y_OFFSET
		jsr UTILS.GetCollisionPoint


		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		and #UTILS.COLLISION_SOLID
		bne !PlayerOneComplete+ 


		//Get Left Collision
		lda #$00
		sta Player1_LeftCollision
		lda Player1_State
		and #STATE_FACE_LEFT
		beq !Skip+

		// lda #$00
		// ldx #PLAYER_LEFT_COLLISON_BOX
		// ldy #11
		// jsr PLAYER.GetCollisionPoint
		ldx #PLAYER_LEFT_COLLISON_BOX
		stx COLLISION_POINT_X_OFFSET
		jsr UTILS.GetCollisionPoint


		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		sta Player1_LeftCollision


		// lda #$00
		// ldx #PLAYER_LEFT_COLLISON_BOX
		// ldy #18
		// jsr PLAYER.GetCollisionPoint
		ldy #18
		sty COLLISION_POINT_Y_OFFSET
		jsr UTILS.GetCollisionPoint



		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		ora Player1_LeftCollision
		sta Player1_LeftCollision



	!Skip:


		//Get Right Collision
		lda #$00
		sta Player1_RightCollision
		lda Player1_State
		and #STATE_FACE_RIGHT
		beq !Skip+

		// lda #$00
		// ldx #PLAYER_RIGHT_COLLISON_BOX
		// ldy #11
		// jsr PLAYER.GetCollisionPoint
		ldx #PLAYER_RIGHT_COLLISON_BOX
		stx COLLISION_POINT_X_OFFSET
		ldy #11
		sty COLLISION_POINT_Y_OFFSET
		jsr UTILS.GetCollisionPoint

		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		sta Player1_RightCollision

		// lda #$00
		// ldx #PLAYER_RIGHT_COLLISON_BOX
		// ldy #18
		// jsr PLAYER.GetCollisionPoint
		ldy #18
		sty COLLISION_POINT_Y_OFFSET
		jsr UTILS.GetCollisionPoint


		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		ora Player1_RightCollision
		sta Player1_RightCollision

	!:

	!Skip:
	!PlayerOneComplete:






		// Get floor collisions for each foot player 2
		lda PlayersActive
		and #$02
		bne !+
		lda #$40
		sta Player2_FloorANDCollision
		jmp !PlayerTwoComplete+
	!:

		lda #$01
		ldx #PLAYER_LEFT_COLLISON_BOX + FOOT_COLLISION_OFFSET
		ldy #23
		jsr PLAYER.GetCollisionPoint


		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		sta Player2_FloorCollision
		sta Player2_FloorANDCollision
		jsr UTILS.GetColorAt
		sta Player2FloorColor


		// lda #$01
		// ldx #PLAYER_RIGHT_COLLISON_BOX - FOOT_COLLISION_OFFSET
		// ldy #23
		// jsr PLAYER.GetCollisionPoint
		ldx #PLAYER_RIGHT_COLLISON_BOX - FOOT_COLLISION_OFFSET
		stx COLLISION_POINT_X_OFFSET
		jsr UTILS.GetCollisionPoint

		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		ora Player2_FloorCollision
		sta Player2_FloorCollision
		lda CHAR_COLORS, x
		and Player2_FloorANDCollision
		sta Player2_FloorANDCollision
		jsr UTILS.GetColorAt
		cmp Player2FloorColor
		beq !+
		lda #$01
	!:
		sta Player2FloorColor

		//Moving inside walls check
		// lda #$01
		// ldx #$0c
		// ldy #11
		// jsr PLAYER.GetCollisionPoint
		ldx #$0c
		stx COLLISION_POINT_X_OFFSET
		ldy #11
		sty COLLISION_POINT_Y_OFFSET
		jsr UTILS.GetCollisionPoint


		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		and #UTILS.COLLISION_SOLID
		bne !PlayerTwoComplete+ 


		//Get Left Collision
		lda #$00
		sta Player2_LeftCollision
		lda Player2_State
		and #STATE_FACE_LEFT
		beq !Skip+

		// lda #$01
		// ldx #PLAYER_LEFT_COLLISON_BOX
		// ldy #11
		// jsr PLAYER.GetCollisionPoint
		ldx #PLAYER_LEFT_COLLISON_BOX
		stx COLLISION_POINT_X_OFFSET
		jsr UTILS.GetCollisionPoint

		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		sta Player2_LeftCollision

		// lda #$01
		// ldx #PLAYER_LEFT_COLLISON_BOX
		// ldy #18
		// jsr PLAYER.GetCollisionPoint
		ldx #PLAYER_LEFT_COLLISON_BOX
		stx COLLISION_POINT_X_OFFSET
		ldy #18
		sty COLLISION_POINT_Y_OFFSET
		jsr UTILS.GetCollisionPoint


		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		ora Player2_LeftCollision
		sta Player2_LeftCollision

	!Skip:


		//Get Right Collision
		lda #$00
		sta Player2_RightCollision
		lda Player2_State
		and #STATE_FACE_RIGHT
		beq !Skip+

		// lda #$01
		// ldx #PLAYER_RIGHT_COLLISON_BOX
		// ldy #11
		// jsr PLAYER.GetCollisionPoint
		ldx #PLAYER_RIGHT_COLLISON_BOX
		stx COLLISION_POINT_X_OFFSET
		ldy #11
		sty COLLISION_POINT_Y_OFFSET
		jsr UTILS.GetCollisionPoint


		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		sta Player2_RightCollision

		// lda #$01
		// ldx #PLAYER_RIGHT_COLLISON_BOX
		// ldy #18
		// jsr PLAYER.GetCollisionPoint
		ldy #18
		sty COLLISION_POINT_Y_OFFSET
		jsr UTILS.GetCollisionPoint

		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		ora Player2_RightCollision
		sta Player2_RightCollision
	!Skip:
	!PlayerTwoComplete:

		rts
	}



	GetCollisionPoint: {
			//x register contains x offset (half value)
			//y register contains y offset

			.label PLAYER_POSITION = COLLISION_POINT_POSITION
			.label X_PIXEL_OFFSET = COLLISION_POINT_X_OFFSET
			.label Y_PIXEL_OFFSET = COLLISION_POINT_Y_OFFSET

			.label PLAYER_X = COLLISION_POINT_X
			.label PLAYER_Y = COLLISION_POINT_Y

			stx X_PIXEL_OFFSET
			sty Y_PIXEL_OFFSET

			cmp #$00 //Is player one?
			bne !Player2Setup+

		!Player1Setup:
			lda #<Player1_X
			sta PLAYER_X
			lda #>Player1_X
			sta PLAYER_X + 1
			lda #<Player1_Y
			sta PLAYER_Y
			lda #>Player1_Y
			sta PLAYER_Y + 1
			jmp UTILS.GetCollisionPoint

		!Player2Setup:
			lda #<Player2_X
			sta PLAYER_X
			lda #>Player2_X
			sta PLAYER_X + 1
			lda #<Player2_Y
			sta PLAYER_Y
			lda #>Player2_Y
			sta PLAYER_Y + 1
		!PlayerSetupComplete:

			jmp UTILS.GetCollisionPoint

	}





	DrawPlayer: {

		.label PlayerState = VECTOR1
		.label PlayerWalkIndex = VECTOR2
		.label PlayerX = VECTOR3
		.label PlayerY = VECTOR4

		.label CURRENT_PLAYER = TEMP2
		.label CURRENT_FRAME = TEMP3
		.label TEMP = TEMP4



		lda #$02
		sta CURRENT_PLAYER

		!Loop:

			lda CURRENT_PLAYER
			and PlayersActive
			bne !+

			jmp !SkipPlayerCompletely+
		!:

			lda CURRENT_PLAYER
			cmp #$01
			bne !Player2+

		!Player1:
			lda #<Player1_State
			sta PlayerState
			lda #>Player1_State
			sta PlayerState + 1

			lda #<Player1_WalkIndex
			sta PlayerWalkIndex
			lda #>Player1_WalkIndex
			sta PlayerWalkIndex + 1

			lda #<Player1_X
			sta PlayerX
			lda #>Player1_X
			sta PlayerX + 1

			lda #<Player1_Y
			sta PlayerY
			lda #>Player1_Y
			sta PlayerY + 1

			jmp !PlayerSetupComplete+

		!Player2:
			lda #<Player2_State
			sta PlayerState
			lda #>Player2_State
			sta PlayerState + 1

			lda #<Player2_WalkIndex
			sta PlayerWalkIndex
			lda #>Player2_WalkIndex
			sta PlayerWalkIndex + 1

			lda #<Player2_X
			sta PlayerX
			lda #>Player2_X
			sta PlayerX + 1

			lda #<Player2_Y
			sta PlayerY
			lda #>Player2_Y
			sta PlayerY + 1

		!PlayerSetupComplete:

			//Set player frame
				ldx CURRENT_PLAYER
				dex
				lda DefaultFrame, x   //Default idle frame
				sta CURRENT_FRAME

				jsr UpdatePlayerPowerup
				jsr SetPlayerSize


				txa
				clc
				adc #$01
				eor #$03
				cmp Player_Freeze_Active
				bne !+
				lda FreezeColor
				sta VIC.SPRITE_COLOR_6, x
				jmp !InvulnDone+
			!:


				lda Player_Invuln, x
				beq !NotInvuln+
				lsr 
				and #$07
				cpx #$00
				beq !Plyr1+
				clc
				adc #$08
			!Plyr1:

				tay
				lda	PlayerInvulnRamp, y
				sta VIC.SPRITE_COLOR_6, x
				dec Player_Invuln, x
				jmp !InvulnDone+
			!NotInvuln:


				lda Player_PowerupType, x
				cmp #POWERUP_SPEED
				bne !NotSpeed+
				lda SpeedColor
				beq !NormalColor+
				sta VIC.SPRITE_COLOR_6, x
				jmp !InvulnDone+
			!NotSpeed:


				lda Player_PowerupType, x
				cmp #POWERUP_JUMP
				bne !NotJump+
				lda JumpColor
				beq !NormalColor+
				sta VIC.SPRITE_COLOR_6, x
				jmp !InvulnDone+
			!NotJump:


			!NormalColor:
				lda PlayerColors, x
				sta VIC.SPRITE_COLOR_6, x
			!InvulnDone:


				ldy #$00 //Set IZPY index
			!AreWeThrowing:
				//Are we throwing?
				lda (PlayerState), y
				and #[STATE_THROWING]
				beq !NotThrowing+
				//Yes we are throwing!!
				//Grab next throw frame
				stx TEMP
				lda Player1_ThrowIndex, x
				tax
				lda (PlayerState), y
				and #[STATE_FACE_LEFT]
				beq !+
				lda TABLES.PlayerThrowLeft, x
				jmp !SkipFaceCheck+
			!:
				lda TABLES.PlayerThrowRight, x
			!SkipFaceCheck:
				sta CURRENT_FRAME	
				ldx TEMP

				//Increment Counter and turn of state if needed
				lda Player1_ThrowIndex , x
				clc
				adc #$01
				sta Player1_ThrowIndex , x
				cmp #[TABLES.__PlayerThrowLeft - TABLES.PlayerThrowLeft]
				bne !+
				lda (PlayerState), y
				and #[255 - STATE_THROWING]
				sta (PlayerState), y
			
			!:
				lda Player1_ThrowIndex , x
				cmp #$03
				bne !+
				//X is available index
				cpx #$00
				bne !CheckPlayer2+
			!CheckPlayer1:
				jsr PROJECTILES.CheckPlayer1CanShoot
				bpl !CheckComplete+
			!CheckPlayer2:
				jsr PROJECTILES.CheckPlayer2CanShoot
			!CheckComplete:
				lda TEMP //Player 1 = 00
				ldy #$01 //Projectile Type
				jsr PROJECTILES.SpawnProjectile


				:playSFX(SOUND.PlayerShoot)
				

			!:
				jmp !SetFrame+


			!NotThrowing:
				ldx CURRENT_PLAYER	
				dex
				ldy #$00
				lda (PlayerState), y
				bit TABLES.Plus + STATE_EATING
				beq !NotEating+

				lda Player1_EatIndex, x
				tay
				lda ZP_COUNTER
				and #$03
				bne !Skip+
				iny
				cpy #$02
				bcc !+
				ldy #$02
			!:
				tya
				sta Player1_EatIndex, x
			!Skip:	
				ldy #$00
				lda (PlayerState), y 

				and #[STATE_FACE_LEFT]
				beq !FaceRight+
			!FaceLeft:
				ldy Player1_EatIndex, x
				lda TABLES.PlayerEatLeft, y
				jmp !EatFrame+
			!FaceRight:
				ldy Player1_EatIndex, x
				lda TABLES.PlayerEatRight, y
			!EatFrame:
				sta CURRENT_FRAME 
				jmp !SetFrame+


			!NotEating:
				and #[STATE_WALK_RIGHT + STATE_WALK_LEFT]
				beq !SetFrame+ //If not just do default frame


				lda (PlayerState), y
				and #[STATE_JUMP + STATE_FALL]
				bne !SetFrame+

				lda (PlayerWalkIndex), y
				tax
				lda ZP_COUNTER
				and #$03
				bne !Skip+
				inx
				cpx #[TABLES.__PlayerWalkLeft - TABLES.PlayerWalkLeft]
				bne !+
				ldx #$00
			!:
				txa 
				sta (PlayerWalkIndex), y
			!Skip:






				lda (PlayerState), y
				and #[STATE_WALK_RIGHT]	
				bne !Right+
			!Left:
				lda TABLES.PlayerWalkLeft, x
				sta CURRENT_FRAME

				jmp !SetFrame+

			!Right:
				lda TABLES.PlayerWalkRight, x
				sta CURRENT_FRAME


			!SetFrame:
				ldx CURRENT_PLAYER
				dex

				//CHECK FOR EXIT ANIMATION OVERRIDE
					ldy Player_ExitIndex, x
					bmi !skipExitOverride+
					cpy #[TABLES.__PlayerExitAnimation - TABLES.PlayerExitAnimation]
					bne !+
					lda #$5f
					sta CURRENT_FRAME
					jmp !skipExitOverride+
				!:
					lda TABLES.PlayerExitAnimation, y
					sta CURRENT_FRAME
					lda ZP_COUNTER
					and #$07
					bne !+
					inc Player_ExitIndex, x
				!:
					lda CURRENT_FRAME
					jmp !NoSizeInc+
				!skipExitOverride:


				lda Player_Size, x
				tax

				lda CURRENT_FRAME
			!SizeLoop:
				cpx #$00
				beq !NoSizeInc+
				clc
				adc #$18
				dex
				jmp !SizeLoop-
			!NoSizeInc:
				ldx CURRENT_PLAYER
				sta [SPRITE_POINTERS + 5], x

				//Set player position X & Y
				ldy #$01

				dex
				txa //Convert to sprite X,Y offsets
				asl
				tax

				lda (PlayerX), y
				sta VIC.SPRITE_6_X, x 

			!Skip:
				iny

				txa
				pha

				ldx CURRENT_PLAYER
				inx
				inx
				inx
				inx
				inx

				lda (PlayerX), y
				beq !+

				lda VIC.SPRITE_MSB
				ora TABLES.PowerOfTwo, x
				jmp !EndMSB+
			!:
				lda VIC.SPRITE_MSB
				and TABLES.InvPowerOfTwo, x

			!EndMSB:
				sta VIC.SPRITE_MSB

				pla
				tax
				ldy #$00
				lda (PlayerY), y
				sta VIC.SPRITE_6_Y, x

				ldy CURRENT_PLAYER
				dey
				lda DOOR.SwitchPressed
				beq !NoSwitchAdjust+
				lda Player1_FloorANDCollision, y
				and #$40
				beq !NoSwitchAdjust+
				lda VIC.SPRITE_6_Y, x
				clc
				adc #$02
				sta VIC.SPRITE_6_Y, x
			!NoSwitchAdjust:


			!Skip:


		!SkipFrameSet:
				//Adjust for screen shake
				lda VIC.SPRITE_6_Y, x
				clc
				adc SCREEN_SHAKE_VAL
				sta VIC.SPRITE_6_Y, x


				jsr PlayerSizeAnimation

		!SkipPlayerCompletely:
			dec CURRENT_PLAYER
			beq !+
			jmp !Loop-
		!:


		// 	lda Player2_ExitIndex
		// 	beq !noswap+
		// 	cmp Player1_ExitIndex
		// 	bcs !noswap+

		// !swap:
		// 	//swap color
		// 	lda $d027 + 6
		// 	tax 
		// 	lda $d027 + 7
		// 	sta $d027 + 6
		// 	stx $d027 + 7

		// 	//swap frame
		// 	lda [SPRITE_POINTERS + 6]
		// 	tax 
		// 	lda [SPRITE_POINTERS + 7]
		// 	sta [SPRITE_POINTERS + 6]
		// 	stx [SPRITE_POINTERS + 7]

		!noswap:	

			rts
	}


	UpdatePlayerPowerup: {
			//Do any color switching


			lda ColorSwitchActive
			beq !skip+
			txa 
			pha 
			jsr DoColorSwitch
			pla
			tax 

		!skip:
			//Do powerup color ramps
			lda ZP_COUNTER
			and #$03
			bne !+
			inc FreezeColorIndex
			lda FreezeColorIndex
			and #$07
			tay 
			lda FreezeColorRamp, y 
			sta FreezeColor
			lda SpeedColorRamp, y 
			sta SpeedColor
			lda JumpColorRamp, y 
			sta JumpColor
		!:

			lda Player_PowerupTimer, x
			beq !+
			dec Player_PowerupTimer, x

			//Are we invuln
			lda Player_PowerupType, x
			cmp #POWERUP_INVULN
			bne !Skip+
			lda Player_PowerupTimer, x
			sta Player1_Invuln, x

		!Skip:
			rts
		!:
		
		//If we go from 1 to 0 on timer and powerup is freeze
		//The turn off freeze
			inx
			cpx Player_Freeze_Active
			bne !Skip+
			lda #$00
			sta Player_Freeze_Active
		!Skip:
			dex 

			lda #$00
			sta Player_PowerupType, x

			rts
	}


	PlayerSizeAnimation: {

			.label CURRENT_PLAYER = TEMP2

			ldx CURRENT_PLAYER
			dex

			lda Player_Size_Timer, x
			bne !DoAnim+
			rts
		!DoAnim:
			dec Player_Size_Timer, x
			

			txa
			pha
			tay 
			jsr CROWN.DropCrown
			pla 
			tax

			//Reset values
			lda VIC.SPRITE_X_EXPAND
			and TABLES.InvPowerOfTwo + 6, x
			sta VIC.SPRITE_X_EXPAND
			lda VIC.SPRITE_Y_EXPAND
			and TABLES.InvPowerOfTwo + 6, x
			sta VIC.SPRITE_Y_EXPAND


			lda Player_Size_Timer, x
			and #$1f
			tay
			lda SizeSinus, y
			bpl !+
			eor #$ff
		!:
			cmp #$40
			bcc !NoExpand+

			lda SizeSinus, y
			bmi !VerticalExpand+
			bpl !HorizontalExpand+
		!NoExpand:
			rts

		!HorizontalExpand:
			txa 
			asl 
			tay
			lda VIC.SPRITE_X_EXPAND
			ora TABLES.PowerOfTwo + 6, x
			sta VIC.SPRITE_X_EXPAND

			
			lda VIC.SPRITE_6_X, y
			sec
			sbc #$0c
			sta VIC.SPRITE_6_X, y	
			bcs !+
			lda VIC.SPRITE_MSB
			and TABLES.InvPowerOfTwo + 6, x
			sta VIC.SPRITE_MSB	
		!:		
			rts

		!VerticalExpand:
			txa 
			asl 
			tay		
			lda VIC.SPRITE_Y_EXPAND
			ora TABLES.PowerOfTwo + 6, x
			sta VIC.SPRITE_Y_EXPAND
		
			lda VIC.SPRITE_6_Y, y
			sec
			sbc #$15
			sta VIC.SPRITE_6_Y, y
			rts
	}

	SizeSinus:
		.fill $20, sin([i/$20] * PI * 2) * 127



	SetPlayerSize: {
		//KEEP X - DOnt BASH!
		//Set the correct playersize
			txa //Player number 0or1
			asl //Because speed value is 16 bit
			tay //Speed offset 0 or 2

			// DEBUG
			lda #$01
			sta Player_Size, x
			rts

			lda Player_Size, x
			pha

			lda Player_Weight, x
			cmp #$12
			bcs !Size1+
		!Size0:
			lda #$00
			sta Player_Size, x
			lda PlayerWalkSpeeds_LSB + 0
			sta Player_WalkSpeed + 0, y
			lda PlayerWalkSpeeds_MSB + 0
			sta Player_WalkSpeed + 1, y
			jmp !SizeComplete+
		!Size1:
			cmp #$24
			bcs !Size2+
			lda #$01
			sta Player_Size, x
			lda PlayerWalkSpeeds_LSB + 1
			sta Player_WalkSpeed + 0, y
			lda PlayerWalkSpeeds_MSB + 1
			sta Player_WalkSpeed + 1, y
			jmp !SizeComplete+
		!Size2:
			lda #$02
			sta Player_Size, x
			lda PlayerWalkSpeeds_LSB + 2
			sta Player_WalkSpeed + 0, y
			lda PlayerWalkSpeeds_MSB + 2
			sta Player_WalkSpeed + 1, y

		!SizeComplete:
			lda Player_PowerupType, x
			cmp #POWERUP_SPEED
			bne !+
			
			//SPEED POWERUP - Now double the speed
			clc
			lda Player_WalkSpeed + 0, y
			adc Player_BoostSpeed + 0 
			lda Player_WalkSpeed + 0, y
			lda Player_WalkSpeed + 1, y
			adc Player_BoostSpeed + 1  
			sta Player_WalkSpeed + 1, y

		!:
			pla
			cmp Player_Size, x
			beq !Exit+
			lda #PLAYER_SIZE_TIME
			sta Player_Size_Timer, x
		!Exit:
			rts
	}


	PlayerControl: {
		!Player1:
			lda PlayersActive
			and #$01
			bne !+
			lda PlayersActive
			beq !Player2+
			lda Player1_Lives
			bmi !Player2+
			lda $dc00
			and #$10
			bne !Player2+
			ldx #$00
			jsr SpawnPlayer
		!:	
			lda Player_Freeze_Active
			cmp #$02
			beq !Player2+
			ldy #$00
			jsr PlayerControlFunc


		!Player2:
			lda PlayersActive
			and #$02
			bne !+
			lda PlayersActive
			beq !Done+
			lda Player2_Lives
			bmi !Done+

			lda $dc01
			and #$10
			bne !Done+
			ldx #$01
			jsr SpawnPlayer
		!:
			lda Player_Freeze_Active
			cmp #$01
			beq !Done+
			ldy #$01
			jsr PlayerControlFunc

		!Done:
			rts
	}

	PlayerControlFunc: {
			lda PlayerAbsorbingCount, y
			beq !+
			rts
		!:
			.label JOY_PORT_2 = $dc00
			lda JOY_PORT_2, y
			sta JOY_ZP1, y

			lda Player1_State, y	
			and #[255 - STATE_WALK_RIGHT - STATE_WALK_LEFT]
			sta Player1_State, y

			lda Player_IsDying,y
			beq !+
			rts
		!:
			lda Player_ExitIndex, y
			bmi !+
			rts
		!:

		!Fire:
			
			lda DOOR.DoorSpawned
			beq !+
			jmp !Up+	//If door has spawned then ewe can no longer eat or throw
		!:
			lda JOY_ZP1, y
			and #JOY_FR
			bne !FirePressed+
			lda #$01
			sta Player1_FirePressed, y
			ldx Player1_FireHeld, y
			inx
			txa
			sta Player1_FireHeld, y
			cpx #FIRE_HELD_THRESHOLD
			bcs !StartEat+
			jmp !+

		!StartEat:
			lda Player1_State, y
			ora #STATE_EATING
			sta Player1_State, y
			jsr CROWN.DropCrown
			jmp !+

		!FirePressed:
			lda Player1_State, y
			bit TABLES.Plus + STATE_EATING
			beq !Skip+
			and #[255 - STATE_EATING]
			sta Player1_State, y
			lda #$00
			sta Player1_FireHeld, y
			sta Player1_FirePressed, y				
			sta Player1_EatIndex, y
			jmp !+

		!Skip:
			lda #$00
			sta Player1_FireHeld, y
			and #STATE_THROWING
			bne !+
			lda Player1_FirePressed, y
			beq !+
			lda #$00
			sta Player1_FirePressed, y	

			cpy #$00
			bne !Plyr2+
		!Plyr1:
			jsr PROJECTILES.CheckPlayer1CanShoot
			jmp !PlyrDone+
		!Plyr2:
			jsr PROJECTILES.CheckPlayer2CanShoot
		!PlyrDone:
			bmi !+ //If negative player cannot shoot


			lda Player1_State, y
			ora #STATE_THROWING
			sta Player1_State, y
			lda #$00
			sta Player1_ThrowIndex, y	
			///
		!:



		!Up:
			lda Player1_State, y
			bit TABLES.Plus + STATE_EATING
			beq !+
			jmp !SkipMovement+
		!:

			lda Player1_State, y
			and #[STATE_FALL + STATE_JUMP]
			bne !+
			lda JOY_ZP1, y
			and #JOY_UP
			bne !+
			lda Player1_State, y
			ora #STATE_JUMP
			sta Player1_State, y
			lda #$00
			sta Player1_JumpIndex, y
			jmp !Left+
		!:


		!Left:
			lda JOY_ZP1, y
			and #JOY_LT
			beq !Skip+
			jmp !+
		!Skip:

			lda Player1_LeftCollision, y
			and #UTILS.COLLISION_SOLID
			beq !skip001+
			jmp !+

		!skip001:

			cpy #$00
			bne !Plyr2+
		!Plyr1:
			sec
			lda Player1_X
			sbc Player1_WalkSpeed
			sta Player1_X
			lda Player1_X + 1
			sbc Player1_WalkSpeed + 1
			sta Player1_X + 1
			lda Player1_X + 2
			sbc #$00
			sta Player1_X + 2

			//Check screen edge
			lda Player1_X + 2
			bne !SkipEdgeCheck+
			lda Player1_X + 1
			cmp #LEFT_SCREEN_EDGE
			bcs !SkipEdgeCheck+

			// lda #$00
			// sta Player1_X + 0
			// lda #LEFT_SCREEN_EDGE
			// sta Player1_X + 1

			lda #$00
			sta Player1_X + 0
			lda #RIGHT_SCREEN_EDGE
			sta Player1_X + 1
			lda #$01
			sta Player1_X + 2

		!SkipEdgeCheck:
			jmp !PlyrDone+


		!Plyr2:
			sec
			lda Player2_X
			sbc Player2_WalkSpeed
			sta Player2_X
			lda Player2_X + 1
			sbc Player2_WalkSpeed + 1
			sta Player2_X + 1
			lda Player2_X + 2
			sbc #$00
			sta Player2_X + 2

			//CHeck screen edge
			lda Player2_X + 2
			bne !SkipEdgeCheck+
			lda Player2_X + 1
			cmp #LEFT_SCREEN_EDGE
			bcs !SkipEdgeCheck+

			// lda #$00
			// sta Player2_X + 0
			// lda #LEFT_SCREEN_EDGE
			// sta Player2_X + 1


			lda #$00
			sta Player2_X + 0
			lda #RIGHT_SCREEN_EDGE
			sta Player2_X + 1
			lda #$01
			sta Player2_X + 2

		!SkipEdgeCheck:
		!PlyrDone:

			lda Player1_State, y
			and #[255 - STATE_FACE_RIGHT - STATE_WALK_RIGHT]
			ora #[STATE_WALK_LEFT + STATE_FACE_LEFT]
			sta Player1_State, y
			lda DefaultLeftRightFrames + 0
			sta DefaultFrame, y
			jmp !Right+
		!:



		!Right:
			lda JOY_ZP1, y
			and #JOY_RT
			beq !Skip+
			jmp !+
		!Skip:

			lda Player1_RightCollision, y
			and #UTILS.COLLISION_SOLID
			beq !skip001+
			jmp !+
		!skip001:

			cpy #$00
			bne !Plyr2+

		!Plyr1:
			clc
			lda Player1_X
			adc Player1_WalkSpeed
			sta Player1_X
			lda Player1_X + 1
			adc Player1_WalkSpeed + 1
			sta Player1_X + 1
			lda Player1_X + 2
			adc #$00
			sta Player1_X + 2

			//CHeck screen edge xx/$48/$01
			lda Player1_X + 2
			beq !SkipEdgeCheck+
			lda Player1_X + 1
			cmp #RIGHT_SCREEN_EDGE
			bcc !SkipEdgeCheck+

			// lda #$00
			// sta Player1_X + 0
			// lda #RIGHT_SCREEN_EDGE
			// sta Player1_X + 1

			lda #$00
			sta Player1_X + 0
			lda #LEFT_SCREEN_EDGE
			sta Player1_X + 1
			lda #$00
			sta Player1_X + 2

		!SkipEdgeCheck:
			jmp !PlyrDone+

		!Plyr2:
			clc
			lda Player2_X
			adc Player2_WalkSpeed
			sta Player2_X
			lda Player2_X + 1
			adc Player2_WalkSpeed + 1
			sta Player2_X + 1
			lda Player2_X + 2
			adc #$00
			sta Player2_X + 2

			//CHeck screen edge xx/$48/$01
			lda Player2_X + 2
			beq !SkipEdgeCheck+
			lda Player2_X + 1
			cmp #RIGHT_SCREEN_EDGE
			bcc !SkipEdgeCheck+

			// lda #$00
			// sta Player2_X + 0
			// lda #RIGHT_SCREEN_EDGE
			// sta Player2_X + 1

			lda #$00
			sta Player2_X + 0
			lda #LEFT_SCREEN_EDGE
			sta Player2_X + 1
			lda #$00
			sta Player2_X + 2

		!SkipEdgeCheck:

		!PlyrDone:

			lda Player1_State, y
			and #[255 - STATE_FACE_LEFT - STATE_WALK_LEFT]
			ora #[STATE_WALK_RIGHT + STATE_FACE_RIGHT]
			sta Player1_State, y

			lda DefaultLeftRightFrames + 1
			sta DefaultFrame, y
		!:
		!SkipMovement:

			rts
	}


	JumpAndFall: {
			.label PlayerState = VECTOR1
			.label PlayerFloorCollision = VECTOR2
			.label PlayerJumpIndex = VECTOR3
			.label PlayerY = VECTOR4
			.label PlayerSize = VECTOR5


			.label CURRENT_PLAYER = TEMP1

		lda #$02
		sta CURRENT_PLAYER

		!Loop:
			lda CURRENT_PLAYER //1 or 2
			and PlayersActive  
			bne !+
			jmp !SkipEntireIteration+
		!:


			lda CURRENT_PLAYER
			cmp #$01
			bne !Player2+
		!Player1:
			lda #<Player1_State
			sta PlayerState
			lda #>Player1_State
			sta PlayerState + 1

			lda #<Player1_FloorCollision
			sta PlayerFloorCollision
			lda #>Player1_FloorCollision
			sta PlayerFloorCollision + 1

			lda #<Player1_JumpIndex
			sta PlayerJumpIndex
			lda #>Player1_JumpIndex
			sta PlayerJumpIndex + 1

			lda #<Player1_Y
			sta PlayerY
			lda #>Player1_Y
			sta PlayerY + 1

			lda #<Player1_Size
			sta PlayerSize
			lda #>Player1_Size
			sta PlayerSize + 1

			lda Player_IsDying + 0
			sta PLAYER_DYING 

			jmp !PlayerSetupComplete+
		!Player2:
			lda #<Player2_State
			sta PlayerState
			lda #>Player2_State
			sta PlayerState + 1

			lda #<Player2_FloorCollision
			sta PlayerFloorCollision
			lda #>Player2_FloorCollision
			sta PlayerFloorCollision + 1

			lda #<Player2_JumpIndex
			sta PlayerJumpIndex
			lda #>Player2_JumpIndex
			sta PlayerJumpIndex + 1

			lda #<Player2_Y
			sta PlayerY
			lda #>Player2_Y
			sta PlayerY + 1

			lda #<Player2_Size
			sta PlayerSize
			lda #>Player2_Size
			sta PlayerSize + 1

			lda Player_IsDying + 1
			sta PLAYER_DYING
	
		!PlayerSetupComplete:
			

			ldy #$00
			lda (PlayerState), y
			and #STATE_JUMP
			bne !ExitFallingCheck+

		!FallCheck:
			lda PLAYER_DYING
			beq !CheckCol+
			
			lda (PlayerY), y
			cmp #$e0
			bcc !Falling+

			ldy CURRENT_PLAYER
			dey
			jsr KillPlayer
			jmp !SkipEntireIteration+

		!CheckCol:
			
			lda (PlayerFloorCollision),y
			and #UTILS.COLLISION_COLORABLE
			beq !Falling+


			lda (PlayerSize), y
			cmp #$02
			bcc !NotFalling+
			lda (PlayerState), y
			and #STATE_FALL
			beq !NotFalling+

			lda (PlayerJumpIndex), y
			cmp #[TABLES.__JumpAndFallTable - TABLES.JumpAndFallTable - 5]
			bcs !NotFalling+			
			lda #$08
			sta IRQ.ScreenShakeTimer
			:playSFX(SOUND.PlayerGroundShake)
			jmp !NotFalling+

		!Falling:
			lda (PlayerState), y
			and #STATE_FALL
			bne !ExitFallingCheck+
			lda (PlayerState), y
			ora #STATE_FALL
			sta (PlayerState), y
			lda #[TABLES.__JumpAndFallTable - TABLES.JumpAndFallTable - 1]
			sta (PlayerJumpIndex), y
			jmp !ExitFallingCheck+

		!NotFalling:		
			lda (PlayerState), y
			and #STATE_FALL
			beq !+
			lda (PlayerY), y
			sec
			sbc #$02
			and #$f8
			ora #$03
			sta (PlayerY), y
		!:

			lda (PlayerState), y
			and #[255 - STATE_FALL]
			sta (PlayerState), y
		!ExitFallingCheck:




		!ApplyFallOrJump:
			lda (PlayerState), y
			and #STATE_FALL
			beq !Skip+


			lda (PlayerJumpIndex), y
			tax
			lda TABLES.JumpAndFallTable, x
			clc
			adc (PlayerY), y
			sta (PlayerY), y
			dex
			bpl !+
			ldx #$00
		!:	
			txa
			sta (PlayerJumpIndex), y
		!Skip:



			lda (PlayerState), y
			and #STATE_JUMP
			beq !Skip+

			lda (PlayerJumpIndex), y
			tax
			lda (PlayerY), y
			sec
			sbc TABLES.JumpAndFallTable, x
			sta (PlayerY), y


			//We are using a jump powerup so subtract again
			txa 
			pha
			// lda ZP_COUNTER
			// and #$01
			// beq !+
			ldx CURRENT_PLAYER
			dex
			lda Player_PowerupType, x
			cmp #POWERUP_JUMP
			bne !+
			lda (PlayerY), y
			sec
			sbc #$01//TABLES.JumpAndFallTable, x
			sta (PlayerY), y		
		!:
			pla
			tax

			inx
			cpx #[TABLES.__JumpAndFallTable - TABLES.JumpAndFallTable]
			bne !+
			dex
			lda (PlayerState), y
			and #[255 - STATE_JUMP]
			ora #STATE_FALL
			sta (PlayerState), y
		!:
			txa
			sta (PlayerJumpIndex), y

		!Skip:
		!SkipEntireIteration:
			dec CURRENT_PLAYER
			beq !+
			jmp !Loop-
		!:

			rts
	}


	DoColorSwitch: {

			ldx ColorSwitchRow

			lda TABLES.ScreenRowLSB, x
			sta SCREEN_SMOD + 1
			sta COLOR_SMOD + 1
			sta COLOR_SMOD2 + 1
			lda TABLES.ScreenRowMSB,x
			sta SCREEN_SMOD + 2
			clc
			adc #[$d8 - [>SCREEN_RAM]]
			sta COLOR_SMOD + 2
			sta COLOR_SMOD2 + 2

			ldx #$27
		!:
		SCREEN_SMOD:
			ldy $BEEF, x 
			lda CHAR_COLORS, y
			and #UTILS.COLLISION_COLORABLE
			beq !skip+
		COLOR_SMOD:
			lda $BEEF, x
			and #$0f
			tay 
			lda ColorSwitchTable, y
		COLOR_SMOD2:
			sta $BEEF,x
		!skip:
			dex
			bpl !-



			ldx ColorSwitchRow

			inx
			cpx #$16
			bne !+
	
			ldx #$00
			stx ColorSwitchActive
		!:

			stx ColorSwitchRow
			rts
	}





	ColorSwitchTable:
			.byte $00,$01,$02,$03,$04,$05,$06,$07
			.byte $08,$09,$0b,$0a,$0c,$0d,$0e,$0f
}




