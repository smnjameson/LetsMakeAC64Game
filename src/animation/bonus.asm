BONUS: {
	.const PLAYER_BASE_Y = $d2
	.const PLAYER1_X = $7c
	.const PLAYER2_X = $11a

	BonusActive:
		.byte $00

	BonusStage:
		.byte $00

	BonusRamp:
		.byte 1,1,1,1,1,1,1,1
		.byte 1,1,1,1,1,1,1,1
		// .byte $01,$0f,$0f,$0c,$0c,$0b,$0b,$00
		// .byte $0b,$0b,$0c,$0c,$0f,$0f,$01,$01
	
	BonusRampIndex:
		.byte $00

	BonusCounters:	//x1000 + x250 + 15000
		.byte $38,$10,$02,$01  //Maximum combined totals (3rd is player 1 or 2 that got to exit first, 4th is crown wearer)
	BonusPlayer1Counters:
		.byte $00,$00	//Player 1+ player 2 should NOT exceed totals
	BonusPlayer2Counters:
		.byte $38,$10
	BonusCountersOriginal:	//copied from BonusCounters at start
		.byte $00,$00,$00,$00
	ActivePlayers:
		.byte %00000000, %00001000, %00010000, %00011000 

	CrownTweeenIndex:
		.byte $00
	CrownOffTween:
		.fill 32, $d2 - (sin((i/24) * (PI - PI/4) + (PI/4)) - sin(PI/4)) * ($ff-$d2) 

	*=*"BonusExited"
	BonusExited:
		.byte $00

	CountTaggedAreas: {
			.label ROW = TEMP1
			.label SCREEN_FETCH = VECTOR1
			.label COLOR_FETCH = VECTOR2

			lda #$00
			sta BonusPlayer1Counters + 1
			sta BonusPlayer2Counters + 1
			sta SCREEN_FETCH + 0
			sta COLOR_FETCH + 0
			lda #$c0
			sta SCREEN_FETCH + 1
			lda #$d8
			sta COLOR_FETCH + 1

			lda PLAYER.PlayerColors + 0
			clc
			adc #$08
			sta ShiftedColors + 0
			lda PLAYER.PlayerColors + 1
			clc
			adc #$08
			sta ShiftedColors + 1


			lda #$16
			sta ROW
		!RowLoop:
			ldy #$00
		!ColumnLoop:
			lda (SCREEN_FETCH), y 
			tax 
			lda CHAR_COLORS, x 
			and #UTILS.COLLISION_COLORABLE
			beq !Skip+
			lda (COLOR_FETCH), y 
			and #$0f
			cmp ShiftedColors + 0
			bne !p2+
		!p1:
			inc BonusPlayer1Counters + 1
			jmp !pdone+
		!p2:		
			cmp ShiftedColors + 1
			bne !pdone+
			inc BonusPlayer2Counters + 1
		!pdone:
		!Skip:
			iny
			cpy #$28
			bne !ColumnLoop-

			dec ROW
			beq !Exit+

			clc
			lda SCREEN_FETCH + 0
			adc #$28
			sta SCREEN_FETCH + 0
			sta COLOR_FETCH + 0
			bcc !+
			inc SCREEN_FETCH + 1
			inc COLOR_FETCH + 1
		!:
			jmp !RowLoop-
		!Exit:


			lda BonusPlayer1Counters + 1
			clc
			adc BonusPlayer2Counters + 1
			sta BonusCounters + 1

			rts
	}
	ShiftedColors:
			.byte $00,$00



	Initialise: {

			lda #$00
			sta BonusActive
			lda #$00
			sta CrownTweeenIndex
			rts
	}
	


	InitialiseTransition: {
			sei
			lda MAPDATA.MAP_1.TransparentColor
			sta $d021
			lda MAPDATA.MAP_1.MultiColor
			sta $d022

			jsr CountTaggedAreas

			jsr TITLECARD.BlackOutHUD
			rts
	}

	Start: {
			lda #$00
			sta BonusExited

			lda #$01
			sta BonusActive

			//set the bonus values
			lda CROWN.PlayerHasCrown
			sta BonusCounters + 3

			lda PLAYER.Player1_EatCount
			sta BonusPlayer1Counters + 0
			lda PLAYER.Player2_EatCount
			sta BonusPlayer2Counters + 0
			clc 
			adc BonusPlayer1Counters + 0
			sta BonusCounters + 0


			lda DOOR.FirstThroughDoor
			sta BonusCounters + 2

			lda #$00
			sta PlayerBarHeight + 0
			sta PlayerBarHeight + 1

			//Color default text black
			lda #$00
			ldx #$00
		!:
			sta $d900, x
			sta $da00, x
			sta $db00, x
			dex
			bne !-


			lda #$00
			sta BonusStage

			lda BonusCounters + 00
			sta BonusCountersOriginal + 00
			lda BonusCounters + 01
			sta BonusCountersOriginal + 01
			lda BonusCounters + 02
			beq !+
			lda #$00
			sta BonusCountersOriginal + 02
		!:
			lda BonusCounters + 03
			beq !+
			lda #$00
			sta BonusCountersOriginal + 03
		!:

			lda #%00001110
			sta $d018

			//Setup inital screen
			//Bonus Label
			ldx #$09
		!:
			lda BonusLabelLine1, x
			sta SCREEN_RAM + $01 * $28 + $13, x
			lda BonusLabelLine2, x
			sta SCREEN_RAM + $02 * $28 + $13, x
			dex
			bpl !-


			//Player Data
			lda PLAYER.PlayersActive
			and #$01
			beq !+
			ldx #$00
			jsr DrawPlayerBars
		!:
			lda PLAYER.PlayersActive
			and #$02
			beq !+
			ldx #$01
			jsr DrawPlayerBars
		!:


			//Level sprite
			lda #$8d
			sta SPRITE_POINTERS + 0
			lda #$00
			sta $d027
			lda $d010
			and #%11111110
			sta $d010
			lda #$3e
			sta $d001
			lda #$30 
			sta $d000
			lda $d01b
			and #%11111110
			sta $d01b 
			lda $d01c
			and #%11111110
			sta $d01c 
			lda $d015
			ora #%00000001
			sta $d015

			jsr DrawLevelNumber

			jsr ShiftLevelNumber
			
			//Initialise scores
			lda #$30
			ldx #$05
		!:
			sta P1_BONUS_SCORE, x
			sta P2_BONUS_SCORE, x 
			dex
			bpl !-



			//Initialise player sprites in 3 & 4
			ldx PLAYER.PlayersActive
			lda $d015
			ora ActivePlayers, x
			sta $d015
			lda $d01c
			ora #%00011100
			sta $d01c
			lda PLAYER.PlayerColors + 0
			sta $d02a
			lda PLAYER.PlayerColors + 1
			sta $d02b
			ldx PLAYER.Player1_Size
			lda Player1Sizes, x
			sta SPRITE_POINTERS + 3
			ldx PLAYER.Player2_Size
			lda Player2Sizes, x
			sta SPRITE_POINTERS + 4

			lda #PLAYER_BASE_Y
			sta $d007
			sta $d009

			lda #PLAYER1_X
			sta $d006
			lda #<PLAYER2_X
			sta $d008
			lda $d010
			and #%11100111
			ora #%00010000
			sta $d010


			//Initialise crown sprite
			lda $d015
			and #%11111011
			ora #%00000100
			sta $d015
			lda #$00
			sta $d004
			lda #$08
			sta $d029
			ldx BonusCounters + 3
			beq !NoCrown+

			lda PlayerCrownFrame - 1, x
			sta SPRITE_POINTERS + 2


			cpx #$02
			beq !p2+
		!p1:	
			lda #PLAYER1_X 
			sta $d004
			lda $d010
			and #%11111011
			sta $d010
			jmp !pdone+

		!p2:
			lda #PLAYER2_X 
			sta $d004
			
			lda $d010
			ora #%00000100
			sta $d010


		!pdone:
			lda CrownOffTween
			sta $d005
	


		!NoCrown:

			lda PLAYER.CurrentLevel
			cmp #$09
			bcs !+
			jmp !exit+
		!:

			ldx #$04
		!:
			jsr ShiftLevelNumber
			dex
			bne !-


		!exit:
			rts			
	}

	PlayerCrownFrame:
		.byte $47, $46
	Player1Sizes:
		.byte $40, $58, $70
	Player2Sizes:
		.byte $43, $5b, $73
	BonusAnimationOffset:
		.byte $00, $00

	AnimatePlayer: {
			lda BonusAnimationOffset, y 
			clc
			adc #$01
			cmp #$03
			bne !+
			lda #$00
		!:
			sta BonusAnimationOffset, y 
			rts
	}


	ShiftLevelNumber: {
			.for(var i=0; i<7; i++) {
				lsr $e340 + 42 + i*3
				ror $e340 + 43 + i*3
				ror $e340 + 44 + i*3
			}
			rts 
	}	

	DrawLevelNumber: {
			//first clear numbers
			ldx #$18
			lda #$00
		!:
			sta $e340 + 42, x  //Sprite location
			dex 
			bpl !-

			ldx #$00
			lda PLAYER.CurrentLevel
			clc
			adc #$01
		!:		
			cmp #$0a
			bcc !units+
			sec 
			sbc #$0a
			inx 
			bne !-
		!units:
			pha  

			cpx #$00
			beq !PrintUnits+


		!PrintTens:
			txa 
			asl
			asl 
			asl 
			tax 
			ldy #$00
		!:
			lda $f980, x
			sta $e340 + 42, y 
			inx 
			iny
			iny
			iny 
			cpy #$15
			bne !-

		!PrintUnits:
			pla
			asl
			asl 
			asl 
			tax 
			ldy #$00
		!:
			lda $f980, x
			sta $e340 + 43, y 
			inx 
			iny
			iny
			iny 
			cpy #$15
			bne !-	

			rts
	}

	Player1Text:
		.text "PLAYER" 
		.byte $00
		.text "1"
	Player2Text:
		.text "PLAYER"
		.byte $00
		.text "2"
	DrawTotalScores: {
			//Draw total scores
			ldx #$07
		!loop:
			lda PLAYER.PlayersActive
			and #$01
			beq !noP1+
			lda Player1Text, x
			sta SCREEN_RAM + 01 * $28 + 10, x
			lda #$07
			sta $d800 + 01 * $28 + 10, x

			lda P1_SCORE, x
			sta SCREEN_RAM + 03 * $28 + 10, x
			lda #$07
			sta $d800 + 03 * $28 + 10, x

			cpx #$06
			bcs !+
			lda P1_BONUS_SCORE, x
			sta SCREEN_RAM + $17 * $28 + 11, x
		!:


		!noP1:

			lda PLAYER.PlayersActive
			and #$02
			beq !noP2+
			lda Player2Text, x
			sta SCREEN_RAM + 01 * $28 + 30, x
			lda #$07
			sta $d800 + 01 * $28 + 30, x
			lda P2_SCORE, x
			sta SCREEN_RAM + 03 * $28 + 30, x
			lda #$07
			sta $d800 + 03 * $28 + 30, x

			cpx #$06
			bcs !+
			lda P2_BONUS_SCORE, x
			sta SCREEN_RAM + $17 * $28 + 31, x
		!:
		!noP2:

			dex
			bpl !loop-
			rts
	}


	PlayerBarX:
		.byte 11,31
	PlayerTextX:
		.byte 9,29
	PlayerBar1Colors:
		.byte $02,$03
	PlayerBar2Colors:
		.byte $02,$03
	PlayerBarHeight:
		.byte $00,$00

	// PlayerText:
	// 	.encoding "screencode_upper"
	// 	.text "P"

	DrawPlayerBars: {
			//1b 2f   y=4-18   x=7 or 27  offset Right = 5  
			lda #<SCREEN_RAM + $06 *$28
			sta BONUS_VECTOR1 + 0
			sta BONUS_VECTOR2 + 0
			lda #>SCREEN_RAM + $06 *$28
			sta BONUS_VECTOR1 + 1
			lda #>VIC.COLOR_RAM + $06 *$28
			sta BONUS_VECTOR2 + 1

			txa
			pha

			lda PlayerBar1Colors, x
			sta BONUS_PLAYER_BAR_COLOR1
			lda PlayerBar2Colors, x
			sta BONUS_PLAYER_BAR_COLOR2
			lda PlayerBarX, x
			tay

			ldx #$0f	
		!Loop:
			// lda #$2e
			// sta (BONUS_VECTOR1), y
			// lda #$01
			// sta (BONUS_VECTOR2), y


			iny
			lda BONUS_PLAYER_BAR_COLOR1
			sta (BONUS_VECTOR2), y
			iny
			lda BONUS_PLAYER_BAR_COLOR1
			sta (BONUS_VECTOR2), y
			iny
			lda BONUS_PLAYER_BAR_COLOR2
			sta (BONUS_VECTOR2), y
			iny
			lda BONUS_PLAYER_BAR_COLOR2
			sta (BONUS_VECTOR2), y
			iny



			// lda #$2f
			// sta (BONUS_VECTOR1), y
			// lda #$01
			// sta (BONUS_VECTOR2), y
			tya 
			sec
			sbc #$05
			tay
			

			lda BONUS_VECTOR1 + 0
			clc 
			adc #$28
			sta BONUS_VECTOR1 + 0
			sta BONUS_VECTOR2 + 0
			bcc !+
			inc BONUS_VECTOR1 + 1
			inc BONUS_VECTOR2 + 1
		!:
			dex
			bpl !Loop-

			pla
			tax

			lda PLAYER.PlayerColors, x
			sta BONUS_COLOR

			
			stx BONUS_PLAYER

			lda PlayerTextX, x
			tax

		 	ldy #$00
		 !:
		 	lda #$30
		 	sta SCREEN_RAM + $17 * $28 + $02, x
		 	lda BONUS_COLOR
		 	sta VIC.COLOR_RAM + $17 * $28 + $02, x
		 	inx
			iny
			cpy #$06
		 	bne !-



			ldx #$00
			jsr ClearBar
			ldx #$01
			jsr ClearBar


			// jsr DrawCrownBonus
			rts


	}

	// CrownTextLine1:
	// 	.encoding "screencode_upper"
	// 	.text "CROWN"
	// CrownTextLine2:
	// 	.text "BONUS"
	// CrownTextLine3:
	// 	.text ";1:25"
	// CrownTextPosition: 
	// 	.byte $02, $02


	// DrawCrownBonus: {
	// 		lda PLAYER.PlayersActive
	// 		cmp #$03
	// 		beq !+
	// 		rts
	// 	!:

	// 		lda CROWN.PlayerHasCrown
	// 		bne !+
	// 		rts
	// 	!:

	// 		sec
	// 		sbc #$01
	// 		tax
	// 		lda CrownTextPosition, x
	// 		tay

	// 		ldx #$00
	// 	!:
	// 		lda CrownTextLine1, x
	// 		sta SCREEN_RAM + $09 * $28, y
	// 		lda CrownTextLine2, x
	// 		sta SCREEN_RAM + $0a * $28, y
	// 		lda CrownTextLine3, x
	// 		sta SCREEN_RAM + $0d * $28, y
	// 		iny
	// 		inx
	// 		cpx #$05
	// 		bne !-


	// 		rts
	// }

	BonusIRQ: {
			pha

				lda $d016
				and #%11101111
				sta $d016

				lda #$01
				sta PerformFrameCodeFlag


				asl $d019
			pla
			rti
	}

	Update: {
			lda BonusCounters + 3
			beq !+


			ldx CrownTweeenIndex
			cpx #$20
			beq !+
			inc CrownTweeenIndex

			lda CrownOffTween, x
			sta $d005
		!:

			//First animate color ramp for bonus
			lda ZP_COUNTER
			and #$0f
			tax

			ldy #$00
		!Loop:
			lda BonusRamp, x
			sta VIC.COLOR_RAM + $01 * $28 + $13, y
			sta VIC.COLOR_RAM + $02 * $28 + $13, y
			inx
			cpx #$10
			bne !+
			ldx #$00
		!:
			iny
			cpy #$0a
			bne !Loop-


			jsr DoBonusStage

			lda PLAYER.PlayersActive
			and #$01
			beq !+
			ldx #$00
			lda PlayerBarHeight + 0
			jsr SetBar
		!:

			lda PLAYER.PlayersActive
			and #$02
			beq !+
			ldx #$01
			lda PlayerBarHeight + 1
			jsr SetBar
		!:
		!NoSetBar:

			jsr DrawTotalScores

			rts
	}


	PlayerToggle:
		.byte $00
	StageIncrement: //Multiples of 250pts
		.byte $04,$01,$01,$04
	StageIncTimer:
		.byte $03,$03,$01,$03

	.align $20
	BonusStageStrings:
		.encoding "screencode_upper"
		.text "@P@@HAS@CROWN@"
		.word SCREEN_RAM + $08 * $28 + $11
		.text "@@@@<10000@@@@"
	.align $20
		.text "ENEMIES@KILLED"
		.word SCREEN_RAM + $0c * $28 + $11
		.text "@@@@@@;250@@@@"
	.align $20
		.text "@TAGGED@AREAS@"
		.word SCREEN_RAM + $10 * $28 + $11
		.text "@@@@@@;250@@@@"
	.align $20
		.text "@P@@WINS@RACE@"
		.word SCREEN_RAM + $14 * $28 + $11
		.text "@@@@<5000@@@@@"

	DoBonusStage: {
			lda BonusStage
			cmp #$04
			bcc !+
			jsr AwardCrown
			jsr CheckForCloseBonus
			rts
		!:
			asl
			asl
			asl
			asl
			asl
			clc
			adc #<BonusStageStrings
			sta BONUS_VECTOR1 + 0
			lda #>BonusStageStrings
			adc #$00
			sta BONUS_VECTOR1 + 1
			
			ldy #$0e	//Screen location lookup
			lda (BONUS_VECTOR1), y			
			sta BONUS_VECTOR2 + 0
			iny
			lda (BONUS_VECTOR1), y			
			sta BONUS_VECTOR2 + 1


			//If we are on last stage (Race win)
			//Skip whole thing if 1 player
			ldx BonusStage
			cpx #$03
			bne !+
			lda PLAYER.PlayersActive	
			cmp #$03
			beq !+
			jmp !FinishStage+
		!:

			//If we are on first stage (Crown win)
			//Skip whole thing if 1 player
			ldx BonusStage
			cpx #$00
			bne !+
			lda BonusCounters + 3
			bne !+
			inc BonusStage
			rts
		!: 

			//Draw bonus title eg: "ENEMIES KILLED"
			ldy #$0d
		!:
			lda (BONUS_VECTOR1), y
			sta (BONUS_VECTOR2), y
			dey
			bpl !-


			clc
			lda BONUS_VECTOR1 + 0
			adc #$10
			sta BONUS_VECTOR1 + 0
			lda BONUS_VECTOR1 + 1
			adc #$00
			sta BONUS_VECTOR1 + 1

			clc
			lda BONUS_VECTOR2 + 0
			adc #$28
			sta BONUS_VECTOR2 + 0
			lda BONUS_VECTOR2 + 1
			adc #$00
			sta BONUS_VECTOR2 + 1

			//Draw counter template value
			ldy #$0d
		!:
			lda (BONUS_VECTOR1), y
			sta (BONUS_VECTOR2), y
			dey
			bpl !-


			//If we are on last stage (Race win)
			//then jump to last stage counter
			ldx BonusStage
			cpx #$03
			bne !+
			jmp !LastStage+
		!:

			//If we are on first stage (Crown win)
			//then jump to crown stage counter
			ldx BonusStage
			bne !+
			jmp !CrownStage+
		!:


			//Now add 4 to get the first char of counter
			clc
			lda BONUS_VECTOR2 + 0
			adc #$04
			sta BONUS_VECTOR2 + 0
			lda BONUS_VECTOR2 + 1
			adc #$00
			sta BONUS_VECTOR2 + 1


			ldx BonusStage
			lda BonusCountersOriginal - 1, x
			sec
			sbc BonusCounters - 1, x
		//Calculate 10s
			ldy #$00
		!:
			cmp #$0a
			bcc !done+
			sec
			sbc #$0a
			iny
			jmp !-
		!done:
			//Y is now 10s
			pha
			tya
			clc
			adc #$30
			ldy #$00
			sta (BONUS_VECTOR2), y

			pla
			clc
			adc #$30
			ldy #$01
			sta (BONUS_VECTOR2), y		


			lda ZP_COUNTER
			and StageIncTimer, x
			beq !+
			jmp !Exit+
		!:

			//Decrease counter for players and total
			ldx BonusStage
			lda BonusCounters - 1, x
			bne !+
			jmp !FinishStage+
		!:
			sec
			sbc #$01
			sta BonusCounters - 1, x

			lda PlayerToggle
			eor #$01
			sta PlayerToggle
			bne !Player2+


		!Player1:
			lda BonusPlayer1Counters - 1,x 
			beq !Player2+
			sec
			sbc #$01
			sta BonusPlayer1Counters - 1,x
			lda PlayerBarHeight + 0
			clc
			adc StageIncrement, x
			sta PlayerBarHeight + 0

			txa 
			pha 
			lda StageIncrement, x
			ldy #$00
			jsr AddScore

			pla
			tax
			lda StageIncrement, x
			ldy #$00
			jsr AddScoreTotal
			ldy #$00
			jsr AnimatePlayer

			jmp !Exit+

		!Player2:
			lda BonusPlayer2Counters - 1,x 
			beq !Player1-
			sec
			sbc #$01
			sta BonusPlayer2Counters - 1,x 
			lda PlayerBarHeight + 1
			clc
			adc StageIncrement, x
			sta PlayerBarHeight + 1

			txa 
			pha 
			lda StageIncrement, x
			ldy #$01
			jsr AddScore

			pla
			tax
			lda StageIncrement, x
			ldy #$01
			jsr AddScoreTotal
			ldy #$01
			jsr AnimatePlayer

			jmp !Exit+



		!LastStage:
			// .break

			sec
			lda BONUS_VECTOR2 + 0
			sbc #$28
			sta BONUS_VECTOR2 + 0
			lda BONUS_VECTOR2 + 1
			sbc #$00
			sta BONUS_VECTOR2 + 1

			ldy #$02
			lda BonusCounters + 02
			clc
			adc #$30
			sta (BONUS_VECTOR2), y

			lda ZP_COUNTER
			and StageIncTimer, x
			bne !DrawExitBonus+

			lda BonusCounters + 02
			sec
			sbc #$01
			tax
			lda BonusCountersOriginal + 2 //Exit bonus
			cmp #$05
			bne !+
			jmp !FinishStage+
		!:
			clc
			adc #$01
			sta BonusCountersOriginal + 2

			ldy BonusStage
			lda PlayerBarHeight, x
			clc
			adc StageIncrement, y
			sta PlayerBarHeight,x


			tya 
			pha 
			lda StageIncrement, y
			
			ldy BonusCounters + 02
			dey
			jsr AddScore

			pla
			tay 
			lda StageIncrement, y
			ldy BonusCounters + 02
			dey
			jsr AddScoreTotal
			ldy BonusCounters + 02
			dey
			jsr AnimatePlayer



		!DrawExitBonus:
			//Draw counter
			ldx BonusStage
			lda BonusCountersOriginal, x
			sec
			sbc BonusCounters, x
		//Calculate 10s
			ldy #$00
		!:
			cmp #$0a
			bcc !done+
			sec
			sbc #$0a
			iny
			jmp !-
		!done:


			rts



		!CrownStage:
			sec
			lda BONUS_VECTOR2 + 0
			sbc #$28
			sta BONUS_VECTOR2 + 0
			lda BONUS_VECTOR2 + 1
			sbc #$00
			sta BONUS_VECTOR2 + 1

			//Add the player number to the Label
			ldy #$02
			lda BonusCounters + 03
			clc
			adc #$30
			sta (BONUS_VECTOR2), y


			lda ZP_COUNTER
			and StageIncTimer, x
			bne !DrawCrownBonus+

			lda BonusCounters + 03
			sec
			sbc #$01
			tax
			lda BonusCountersOriginal + 3 //Exit bonus
			cmp #$0a //How many ticks?
			beq !FinishStage+
			clc
			adc #$01
			sta BonusCountersOriginal + 3

			ldy BonusStage
			lda PlayerBarHeight, x
			clc
			adc StageIncrement, y
			sta PlayerBarHeight,x


			tya 
			pha 
			lda StageIncrement, y	
			ldy BonusCounters + 03
			dey
			jsr AddScore

			pla
			tay 
			lda StageIncrement, y
			ldy BonusCounters + 03
			dey
			jsr AddScoreTotal
			ldy BonusCounters + 03
			dey
			jsr AnimatePlayer



		!DrawCrownBonus:
			//Draw counter
			// ldx BonusStage
			lda BonusCountersOriginal +3
			sec
			sbc BonusCounters + 3
		//Calculate 10s
			ldy #$00
		!:
			cmp #$0a
			bcc !done+
			sec
			sbc #$0a
			iny
			jmp !-
		!done:



			rts




		!FinishStage:
			ldx BonusStage
			inx
			stx BonusStage
			cpx #$04
			bne !+
			inc PLAYER.CurrentLevel
		!:

		!Exit:
			rts 
	}

	AwardCrown: {
			jsr WhoHasHighestScore
			cpy #$00
			beq !Exit+
			cpy #$02
			beq !p2+

		!p1:
			lda PlayerCrownFrame - 1, y
			sta SPRITE_POINTERS + 2
			lda #$01
			sta CROWN.PlayerHasCrown
			sta CROWN.CrownAvailable
			lda #PLAYER1_X
			sta $d004
			lda $d010
			and #%11111011
			sta $d010
			lda $d005
			clc
			adc #$06
			cmp $d007
			bcs !Exit+
			inc $d005
			inc $d005
			inc $d005
			jmp !Exit+
		!p2:

			lda PlayerCrownFrame - 1, y
			sta SPRITE_POINTERS + 2
			lda #$02
			sta CROWN.PlayerHasCrown
			sta CROWN.CrownAvailable
			lda #<PLAYER2_X
			sta $d004
			lda $d010
			ora #%00000100
			sta $d010
			lda $d005
			clc
			adc #$06
			cmp $d009
			bcs !Exit+
			inc $d005
			inc $d005
			inc $d005
			jmp !Exit+

		!Exit:
			
			rts
	}

	CheckForCloseBonus: {
			lda $dc00
			and #$10
			beq !ExitBonus+
			lda $dc01
			and #$10
			beq !ExitBonus+
			jmp !exit+
		!ExitBonus:
			
			lda #$01
			
			sta BonusExited
		!exit:
			rts
	}


	ScoreTable:
			.byte $00,$25,$50,$75,$10
	ScoreTableZeros:
			.byte $00,$01,$01,$01,$02
	//Acc starts as how many mutlipes of 250
	//Acc = Score to add (25) (BCD Format) $25 = 25
	//X = trailing zeros count (1)
	//Y = Player 
	AddScore: {
			.label SCORE = SCOREVECTOR1
			.label SCORETOADD = SCORETEMP1
			.label TEMP = SCORETEMP2
			tax 
			lda ScoreTable, x 
			pha 
			lda ScoreTableZeros, x 
			tax 
			pla 

			sta SCORETOADD
			cpy #$00
			bne !P2+
		!P1:
			lda #<P1_BONUS_SCORE
			sta SCORE
			lda #>P1_BONUS_SCORE
			sta SCORE + 1
			jmp !Done+

		!P2:
			lda #<P2_BONUS_SCORE
			sta SCORE
			lda #>P2_BONUS_SCORE
			sta SCORE + 1
		!Done:

			stx TEMP
			lda #$05
			sec
			sbc TEMP
			tay


			clc
		!Loop:
			lda SCORETOADD
			and #$0f
			adc (SCORE), y 
			cmp #58
			bcc !+
			sbc #10
		!:
			sta (SCORE), y 
			php //SAVE CARRY
			
			lda SCORETOADD
			lsr
			lsr
			lsr
			lsr
			sta SCORETOADD
			plp //RESTORE CARRY
			dey
			bpl !Loop-



			rts
	}

	WhoHasHighestScore: {
			ldy #$00
			lda PLAYER.PlayersActive

			cmp #$03
			beq !+
			rts
		!:


			ldx #$00
		!:
			lda P1_BONUS_SCORE, x
			cmp P2_BONUS_SCORE, x
			beq !skip+
			bcc !p2+
		!p1:
			ldy #$01
			rts
		!p2:
			ldy #$02
			rts
		!skip:
			inx
			cpx #$06
			bne !-

			rts
	}


	//Acc starts as how many mutlipes of 250
	//Acc = Score to add (25) (BCD Format) $25 = 25
	//X = trailing zeros count (1)
	//Y = Player 
	AddScoreTotal: {
			.label SCORE = SCOREVECTOR1
			.label SCORETOADD = SCORETEMP1
			.label TEMP = SCORETEMP2
			tax 
			lda ScoreTable, x 
			pha 
			lda ScoreTableZeros, x 
			tax 
			pla 

			sta SCORETOADD
			cpy #$00
			bne !P2+
		!P1:
			lda #<P1_SCORE
			sta SCORE
			lda #>P1_SCORE
			sta SCORE + 1
			jmp !Done+

		!P2:
			lda #<P2_SCORE
			sta SCORE
			lda #>P2_SCORE
			sta SCORE + 1
		!Done:

			stx TEMP
			lda #$07
			sec
			sbc TEMP
			tay


			clc
		!Loop:
			lda SCORETOADD
			and #$0f
			adc (SCORE), y 
			cmp #58
			bcc !+
			sbc #10
		!:
			sta (SCORE), y 
			php //SAVE CARRY
			
			lda SCORETOADD
			lsr
			lsr
			lsr
			lsr
			sta SCORETOADD
			plp //RESTORE CARRY
			dey
			bpl !Loop-

			rts
	}


	SetBar: {
			ldy CROWN.PlayerHasCrown
			dey
			bmi !+
			sty BONUS_BAR_TEMP
			cpx BONUS_BAR_TEMP
			bne !+
			pha
			lsr
			lsr
			sta BONUS_BAR_TEMP
			pla
			clc
			adc BONUS_BAR_TEMP
		!:
			// .break
		//X = player num 0,1
		//A = Bar Height 0-127, halved from 0-255
			lsr

			//Move Player
			sta BONUS_BAR_TEMP2
			cpx #$00
			bne !p2+

			ldy PLAYER.Player1_Size
			lda Player1Sizes, y
			clc
			adc BonusAnimationOffset, x
			sta SPRITE_POINTERS + 3
			jmp !p12done+
		!p2:
			ldy PLAYER.Player2_Size
			lda Player2Sizes, y
			clc
			adc BonusAnimationOffset, x
			sta SPRITE_POINTERS + 4
		!p12done:

			txa 
			pha 
			asl 
			tax 
			lda #PLAYER_BASE_Y
			sec
			sbc BONUS_BAR_TEMP2
			sta $d007, x



			pla 
			tax
			lda BONUS_BAR_TEMP2


			jsr ClearBar

			sta BONUS_BAR_TEMP

			lda PlayerBarX, x
			clc
			adc #$01
			adc #<SCREEN_RAM + $15 * $28
			sta BONUS_VECTOR1 + 0
			lda #>SCREEN_RAM + $15 * $28
			adc #$00
			sta BONUS_VECTOR1 + 1

		!Loop:
			lda BONUS_BAR_TEMP
			cmp #$08
			bcc !FinalPiece+
			sec
			sbc #$08
			sta BONUS_BAR_TEMP

			lda #$27
			ldy #$03
		!InnerLoop:
			sta (BONUS_VECTOR1), y
			dey
			bpl !InnerLoop-	

			sec
			lda BONUS_VECTOR1 + 0
			sbc #$28
			sta BONUS_VECTOR1 + 0
			lda BONUS_VECTOR1 + 1
			sbc #$00
			sta BONUS_VECTOR1 + 1
			jmp !Loop-

		!FinalPiece:
			beq !+
			clc
			adc #$1f
			ldy #$03
		!InnerLoop:
			sta (BONUS_VECTOR1), y
			dey
			bpl !InnerLoop-		
		!:
			rts
	}

	ClearBar: {	
		pha
		txa 
		pha

		// y=4-18   x=7 or 27 
			lda PlayerBarX, x
			clc
			adc #$01
			adc #<SCREEN_RAM + $06 * $28
			sta BONUS_VECTOR1 + 0
			lda #>SCREEN_RAM + $06 * $28
			adc #$00
			sta BONUS_VECTOR1 + 1

			
			ldx #$0f
		!OuterLoop:
			lda #$00
			ldy #$03
		!InnerLoop:
			sta (BONUS_VECTOR1), y
			dey
			bpl !InnerLoop-

			clc
			lda BONUS_VECTOR1 + 0
			adc #$28
			sta BONUS_VECTOR1 + 0
			lda BONUS_VECTOR1 + 1
			adc #$00
			sta BONUS_VECTOR1 + 1

			dex
			bpl !OuterLoop-

		pla
		tax
		pla
		rts
	}


	////////// TEXTS
	BonusLabelLine1:
			.byte 66,110,79,123,78,122,85,129,83,127
	BonusLabelLine2:
			.byte 154,198,167,211,166,210,173,217,171,215
}