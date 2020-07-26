DOOR: {
	.label FONT_DATA = $f000
	.label DOOR_FONT_DATA = $f400

	DoorSpawned:
		.byte $00
	DoorAnimRow:
		.byte $00

	SwitchPressed:
		.byte $00
	SwitchColorTimer:
		.byte $00
	SwitchRamp:
		.byte $09,$0f,$0b,$0d,$0c,$0a,$0e,$08
	__SwitchRamp:

	Initialise: {
			lda #$00
			sta DoorSpawned
			sta DoorAnimRow
			sta SwitchPressed
			rts
	}

	SwitchUpdate: {
			lda SwitchPressed
			beq !+
			rts
		!:
			//Sets up switch lookup
			clc
			ldx PIPES.MAPDATA_COPY.SwitchSpawnLoc + 1
			lda TABLES.ScreenRowLSB, x
			adc PIPES.MAPDATA_COPY.SwitchSpawnLoc + 0
			sta DOOR_VECTOR1 + 0
			lda TABLES.ScreenRowMSB, x
			adc #$00
			sta DOOR_VECTOR1 + 1

			//First check if level is complete
			//Is the bar full?
			lda PLAYER.Player1_EatCount
			clc
			adc PLAYER.Player2_EatCount 
			cmp PIPES.NumberOfEnemies
			bne !Player1+

				//cycle the switch colors
				lda DOOR_VECTOR1 + 0
				sta DOOR_VECTOR2 + 0
				lda DOOR_VECTOR1 + 1
				clc
				adc #$18 //Map to color from screen ram
				sta DOOR_VECTOR2 + 1
				inc SwitchColorTimer
				lda SwitchColorTimer
				lsr
				and #$07
				tax
				lda SwitchRamp, x
				ldy #$03
			!Loop:
				sta (DOOR_VECTOR2), y
				dey
				bpl !Loop-

			

			lda PLAYER.Player1_State
			and #%11000000
			bne !DonePlayerChecks+
			
			lda PLAYER.Player2_State
			and #%11000000
			bne !DonePlayerChecks+

			lda PLAYER.Player1_FloorANDCollision
			and PLAYER.Player2_FloorANDCollision
			and #$40
			beq !Player1+

			//Both players on switch
			lda #$01
			sta SwitchPressed
			lda #$0c
			ldy #$03
		!Loop:
			sta (DOOR_VECTOR2), y
			dey
			bpl !Loop-
			jmp !FullyActivateSwitch+


			//Check player 1 first
		!Player1:
			lda PLAYER.PlayersActive + 0
			beq !DonePlayerChecks+
			lda PLAYER.Player1_FloorANDCollision
			and #$40
			beq !Player2+
			lda PLAYER.Player1_Size
			beq !Player2+
			jmp !SwitchOnAndPartialActive+

		!Player2:
			lda PLAYER.PlayersActive + 1
			beq !DonePlayerChecks+
			lda PLAYER.Player2_FloorANDCollision
			and #$40
			beq !DonePlayerChecks+
			lda PLAYER.Player2_Size
			beq !DonePlayerChecks+
			jmp !SwitchOnAndPartialActive+

		!DonePlayerChecks:
			jmp !SwitchNotActive+


		!FullyActivateSwitch:
			ldy #$00
			lda (DOOR_VECTOR1), y
			cmp #$44
			beq !+
			:playSFX(SOUND.PressSwitchFull)
			// :playSFX(SOUND.DoorAppear)
		!:		
			lda #$44
			sta (DOOR_VECTOR1), y
			iny
			lda #$45
			sta (DOOR_VECTOR1), y
			iny
			lda #$46
			sta (DOOR_VECTOR1), y
			iny
			lda #$47
			sta (DOOR_VECTOR1), y
			jmp !Exit+

		!SwitchOnAndPartialActive:

			ldy #$00
			lda (DOOR_VECTOR1), y
			cmp #$40
			beq !+
			:playSFX(SOUND.PressSwitchLite)
		!:

			lda #$40
			sta (DOOR_VECTOR1), y
			iny
			lda #$41
			sta (DOOR_VECTOR1), y
			iny
			lda #$42
			sta (DOOR_VECTOR1), y
			iny
			lda #$43
			sta (DOOR_VECTOR1), y

		

			jmp !Exit+


		!SwitchNotActive:
			ldy #$00
			lda #$3c
			sta (DOOR_VECTOR1), y
			iny
			lda #$3d
			sta (DOOR_VECTOR1), y
			iny
			lda #$3e
			sta (DOOR_VECTOR1), y
			iny
			lda #$3f
			sta (DOOR_VECTOR1), y

			jmp !Exit+

		!Exit:
			rts
	}

	Player1Exiting:
			.byte $00
	Player2Exiting:
			.byte $00
	ExitUpdate: {
			.label DOOR_WIDTH = $10
			.label DOOR_HEIGHT = $20

			lda DoorSpawned
			bne !+
			rts
		!:	
			lda DoorAnimRow
			cmp #$1f	
			beq !+
			rts
		!:

			//Set Door bounding box (half x)
			lda PIPES.MAPDATA_COPY.DoorSpawnLoc + 0 //X char pos
			asl
			asl
			adc #$0c //Add border			
			sta DOOR_POSITION_X
			lda PIPES.MAPDATA_COPY.DoorSpawnLoc + 1 //Y char pos
			asl
			asl
			asl
			adc #$32 //add border
			sta DOOR_POSITION_Y


			//Check each player
			ldx #$01
		!Loop:
			//Only check if not exiting
			lda PLAYER.Player_ExitIndex, x
			bpl !Skip+

			//Check Y
			lda PLAYER.Player1_Y + 0, x
			clc
			adc #$15	//Add player height
			cmp DOOR_POSITION_Y
			bcc !Skip+
			lda PLAYER.Player1_Y + 0, x
			sec
			sbc #DOOR_HEIGHT
			cmp DOOR_POSITION_Y
			bcs !Skip+

			//Check X
			//Get player bounding box
			cpx #$00
			bne !Plyr2+
		!Plyr1:
			lda PLAYER.Player1_X + 2
			lsr
			lda PLAYER.Player1_X + 1
			jmp !DonePlyr+
		!Plyr2:
			lda PLAYER.Player2_X + 2
			lsr
			lda PLAYER.Player2_X + 1
		!DonePlyr:
			ror
			sta DOOR_TEMP1
			sec
			sbc #$02
			cmp DOOR_POSITION_X
			bcc !Skip+
			lda DOOR_TEMP1
			sec
			sbc #DOOR_WIDTH
			clc
			adc #$0c
			cmp DOOR_POSITION_X
			bcs !Skip+



			
			//Only able to exit if on the ground
			lda PLAYER.Player_State, x
			and #[PLAYER.STATE_JUMP + PLAYER.STATE_FALL]
			bne !Skip+



			ldy PLAYER.Player_Size, x
			lda PlayerSizeAnimIndexStart, y
			sta PLAYER.Player_ExitIndex, x
			:playSFX(SOUND.DoorExit)
		!Skip:
			dex
			bpl !Loop-



			rts
	}

	PlayerSizeAnimIndexStart:
		.byte $06,$03,$00

	Update: {
			jsr ExitUpdate
			jsr SwitchUpdate
			//Has door spawned? If not should it?
			lda DoorSpawned
			bne !Spawned+

			//Is the bar full?
			lda SwitchPressed
			bne !SpawnDoor+
			rts

		!SpawnDoor:
			//setup draw location
			ldy PIPES.MAPDATA_COPY.DoorSpawnLoc + 1 //Y
			lda TABLES.ScreenRowLSB, y 
			sta DOOR_VECTOR1 + 0
			sta DOOR_VECTOR2 + 0
			lda TABLES.ScreenRowMSB, y 
			sta DOOR_VECTOR1 + 1
			clc
			adc #$18	//Color from screen location
			sta DOOR_VECTOR2 + 1

			ldy PIPES.MAPDATA_COPY.DoorSpawnLoc + 0 //X
			
			//Draw four rows
			lda #$04
			sta DOOR_TEMP1
			lda #$80
			ldx #$04	
		!Loop:
			sta (DOOR_VECTOR1), y
			sta DOOR_TEMP2
			lda #$0c
			sta (DOOR_VECTOR2), y
			lda DOOR_TEMP2
			clc
			adc #$04
			iny
			dex
			bne !Loop-

			sta DOOR_TEMP2
			tya
			clc
			adc #$24
			tay 
			lda DOOR_TEMP2
			sec 
			sbc #$0f
			ldx #$04
			dec DOOR_TEMP1
			bne !Loop-

			//Clear the intial data
			lda #$00
			ldx #$7f
		!:
			sta DOOR_FONT_DATA, x
			dex
			bpl !-

			lda #$01
			sta DoorSpawned

		!Spawned:
			//It has spawned so advance the update
			lda ZP_COUNTER
			and #$01
			beq !+
			rts
		!:
			//Do we need to shift?
			lda DoorAnimRow
			cmp #$1f
			bcc !+
			rts
		!:
			//Shift Data
			ldx #$01
		!Loop:
			lda DOOR_FONT_DATA + 0, x
			sta DOOR_FONT_DATA - 1, x
			lda DOOR_FONT_DATA + 32, x
			sta DOOR_FONT_DATA + 31, x
			lda DOOR_FONT_DATA + 64, x
			sta DOOR_FONT_DATA + 63, x
			lda DOOR_FONT_DATA + 96, x
			sta DOOR_FONT_DATA + 95, x
			inx
			cpx #$20
			bne !Loop-


			//Add next row
			ldy #$00
			clc
			ldx DoorAnimRow
			lda DoorDataLSB, x
			sta DOOR_VECTOR1 + 0
			lda DoorDataMSB, x
			sta DOOR_VECTOR1 + 1
			lda (DOOR_VECTOR1), y
			sta DOOR_FONT_DATA + 31

			jsr UpdatePos
			lda (DOOR_VECTOR1), y
			sta DOOR_FONT_DATA + 63

			jsr UpdatePos
			lda (DOOR_VECTOR1), y
			sta DOOR_FONT_DATA + 95

			jsr UpdatePos
			lda (DOOR_VECTOR1), y
			sta DOOR_FONT_DATA + 127

			inc DoorAnimRow
			rts

		UpdatePos:
			txa 
			adc #$20
			tax
			lda DoorDataLSB, x
			sta DOOR_VECTOR1 + 0
			lda DoorDataMSB, x
			sta DOOR_VECTOR1 + 1
			rts
	}

	DoorDataLSB:
		.fill 8, <[FONT_DATA + 53 * 8 + i]
		.fill 8, <[FONT_DATA + 57 * 8 + i]
		.fill 8, <[FONT_DATA + 57 * 8 + i]
		.fill 8, <[FONT_DATA + 57 * 8 + i]

		.fill 8, <[FONT_DATA + 54 * 8 + i]
		.fill 8, <[FONT_DATA + 58 * 8 + i]
		.fill 8, <[FONT_DATA + 58 * 8 + i]
		.fill 8, <[FONT_DATA + 58 * 8 + i]

		.fill 8, <[FONT_DATA + 55 * 8 + i]
		.fill 8, <[FONT_DATA + 58 * 8 + i]
		.fill 8, <[FONT_DATA + 58 * 8 + i]
		.fill 8, <[FONT_DATA + 58 * 8 + i]

		.fill 8, <[FONT_DATA + 56 * 8 + i]
		.fill 8, <[FONT_DATA + 59 * 8 + i]
		.fill 8, <[FONT_DATA + 59 * 8 + i]
		.fill 8, <[FONT_DATA + 59 * 8 + i]
	DoorDataMSB:
		.fill 8, >[FONT_DATA + 53 * 8 + i]
		.fill 8, >[FONT_DATA + 57 * 8 + i]
		.fill 8, >[FONT_DATA + 57 * 8 + i]
		.fill 8, >[FONT_DATA + 57 * 8 + i]

		.fill 8, >[FONT_DATA + 54 * 8 + i]
		.fill 8, >[FONT_DATA + 58 * 8 + i]
		.fill 8, >[FONT_DATA + 58 * 8 + i]
		.fill 8, >[FONT_DATA + 58 * 8 + i]

		.fill 8, >[FONT_DATA + 55 * 8 + i]
		.fill 8, >[FONT_DATA + 58 * 8 + i]
		.fill 8, >[FONT_DATA + 58 * 8 + i]
		.fill 8, >[FONT_DATA + 58 * 8 + i]

		.fill 8, >[FONT_DATA + 56 * 8 + i]
		.fill 8, >[FONT_DATA + 59 * 8 + i]
		.fill 8, >[FONT_DATA + 59 * 8 + i]
		.fill 8, >[FONT_DATA + 59 * 8 + i]		

}