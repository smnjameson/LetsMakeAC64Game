BONUS: {
	* = * "BONUS ACTIVE"
	BonusActive:
		.byte $00

	BonusStage:
		.byte $00

	BonusRamp:
		.byte $01,$0f,$0f,$0c,$0c,$0b,$0b,$00
		.byte $0b,$0b,$0c,$0c,$0f,$0f,$01,$01
	
	BonusRampIndex:
		.byte $00

	BonusCounters:	//x1000 + x250 + 15000
		.byte $18,$60,$01
	BonusPlayer1Counters:
		.byte $0b,$31
	BonusPlayer2Counters:
		.byte $0d,$2f
	BonusCountersOriginal:	//copied from BonusCounters at start
		.byte $00,$00,$00



	Initialise: {
			lda #$00
			sta BonusActive
			
			rts
	}

	Start: {
			lda #$01
			sta BonusActive

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
			sei
			lda #<BonusIRQ   
			ldx #>BonusIRQ
			sta IRQ_LSB   // 0314
			stx IRQ_MSB	// 0315 
			cli

			lda #%00001110
			sta $d018

			
			ldx #$00
		!:
			lda #$00
			sta SCREEN_RAM ,x
			sta SCREEN_RAM + $100 ,x
			sta SCREEN_RAM + $200 ,x
			sta SCREEN_RAM + $300 ,x
			lda #$01
			sta VIC.COLOR_RAM ,x
			sta VIC.COLOR_RAM + $100 ,x
			sta VIC.COLOR_RAM + $200 ,x
			sta VIC.COLOR_RAM + $300 ,x
			dex
			bne !-


			//Setup inital screen
			//Bonus Label
			ldx #$09
		!:
			lda BonusLabelLine1, x
			sta SCREEN_RAM + $01 * $28 + $0f, x
			lda BonusLabelLine2, x
			sta SCREEN_RAM + $02 * $28 + $0f, x
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


			rts			
	}



	PlayerBarX:
		.byte 7,27
	PlayerTextX:
		.byte 6,26
	PlayerBar1Colors:
		.byte $02,$05
	PlayerBar2Colors:
		.byte $0a,$0d
	PlayerBarHeight:
		.byte $00,$00

	PlayerText:
		.encoding "screencode_upper"
		.text "PLAYER"

	DrawPlayerBars: {
			//1b 2f   y=4-18   x=7 or 27  offset Right = 5  
			lda #<SCREEN_RAM + $03 *$28
			sta BONUS_VECTOR1 + 0
			sta BONUS_VECTOR2 + 0
			lda #>SCREEN_RAM + $03 *$28
			sta BONUS_VECTOR1 + 1
			lda #>VIC.COLOR_RAM + $03 *$28
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
			lda #$2e
			sta (BONUS_VECTOR1), y
			lda #$01
			sta (BONUS_VECTOR2), y


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



			lda #$2f
			sta (BONUS_VECTOR1), y
			lda #$01
			sta (BONUS_VECTOR2), y
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

			lda HUD.PlayerColors, x
			sta BONUS_COLOR

			
			stx BONUS_PLAYER
			lda PlayerTextX, x
			tax
			ldy #$00
		!:
			lda PlayerText,y
			sta SCREEN_RAM + $14 * $28, x
			lda BONUS_COLOR
			sta VIC.COLOR_RAM + $14 * $28, x
			lda #$30
			sta SCREEN_RAM + $16 * $28 + $01, x
			inx
			iny
			cpy #$06
			bne !-


			lda #$31
			clc
			adc BONUS_PLAYER
			pha
			ldx BONUS_PLAYER
			lda PlayerTextX, x
			clc
			adc #$07
			tax
			pla
			sta SCREEN_RAM + $14 * $28, x
			lda BONUS_COLOR
			sta VIC.COLOR_RAM + $14 * $28, x


			ldx #$00
			jsr ClearBar
			ldx #$01
			jsr ClearBar

			rts


	}



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

	*=*"Update"
	Update: {
			//First animate color ramp for bonus
			lda ZP_COUNTER
			and #$0f
			tax

			ldy #$00
		!Loop:
			lda BonusRamp, x
			sta VIC.COLOR_RAM + $01 * $28 + $0f, y
			sta VIC.COLOR_RAM + $02 * $28 + $0f, y
			inx
			cpx #$10
			bne !+
			ldx #$00
		!:
			iny
			cpy #$0a
			bne !Loop-


			//Now do bar updates
			// lda ZP_COUNTER
			// and #$07
			// bne !NoSetBar+
			// inc PlayerBarHeight + 0
			// inc PlayerBarHeight + 1
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
			rts
	}

	
	PlayerToggle:
		.byte $00
	StageIncrement: //Multiples of 250pts
		.byte $04,$01,$04
	StageIncTimer:
		.byte $03,$01,$03
	*=* "BonusStageStrings"
	.align $20
	BonusStageStrings:
		.encoding "screencode_upper"
		.text "ENEMIES@KILLED"
		.word SCREEN_RAM + $06 * $28 + $0d
		.text "@@@@@@;1000@@@"
	.align $20
		.text "@TAGGED@AREAS@"
		.word SCREEN_RAM + $0a * $28 + $0d
		.text "@@@@@@;250@@@@"
	.align $20
		.text "@P@@WINS@RACE@"
		.word SCREEN_RAM + $0e * $28 + $0d
		.text "@@@@@@<15000@@"

	DoBonusStage: {
			lda BonusStage

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
			cpx #$02
			bcc !+
			lda BonusCounters, x
			bne !+
			jmp !Exit+
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
			cpx #$02
			bcc !+
			jmp !LastStage+
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
			lda BonusCounters, x
			bne !+
			jmp !FinishStage+
		!:
			sec
			sbc #$01
			sta BonusCounters, x

			lda PlayerToggle
			eor #$01
			sta PlayerToggle
			bne !Player2+


		!Player1:
			lda BonusPlayer1Counters,x 
			beq !Player2+
			sec
			sbc #$01
			sta BonusPlayer1Counters,x
			lda PlayerBarHeight + 0
			clc
			adc StageIncrement, x
			sta PlayerBarHeight + 0
			jmp !Exit+

		!Player2:
			lda BonusPlayer2Counters,x 
			beq !Player1-
			sec
			sbc #$01
			sta BonusPlayer2Counters,x 
			lda PlayerBarHeight + 1
			clc
			adc StageIncrement, x
			sta PlayerBarHeight + 1
			jmp !Exit+



		!LastStage:
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

			//Now add 4 to get the first char of counter
			clc
			lda BONUS_VECTOR2 + 0
			adc #$2f
			sta BONUS_VECTOR2 + 0
			lda BONUS_VECTOR2 + 1
			adc #$00
			sta BONUS_VECTOR2 + 1



			lda ZP_COUNTER
			and StageIncTimer, x
			bne !DrawExitBonus+

			lda BonusCounters + 02
			sec
			sbc #$01
			tax
			lda BonusCountersOriginal + 2 //Exit bonus
			cmp #$0f
			beq !FinishStage+
			clc
			adc #$01
			sta BonusCountersOriginal + 2

			ldy BonusStage
			lda PlayerBarHeight, x
			clc
			adc StageIncrement, y
			sta PlayerBarHeight,x


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
			//Y is now 10s
			pha
			tya
			clc
			adc #$30
			ldy #$00
			cmp #$30
			bne !+
			lda #$00
		!:
			sta (BONUS_VECTOR2), y

			pla
			clc
			adc #$30
			ldy #$01
			sta (BONUS_VECTOR2), y		


			rts




		!FinishStage:
			ldx BonusStage
			inx
			stx BonusStage

		!Exit:
			rts 
	}









	SetBar: {
			// .break
		//X = player num 0,1
		//A = Bar Height 0-127, halved from 0-255
			lsr

			jsr ClearBar

			sta BONUS_BAR_TEMP

			lda PlayerBarX, x
			clc
			adc #$01
			adc #<SCREEN_RAM + $12 * $28
			sta BONUS_VECTOR1 + 0
			lda #>SCREEN_RAM + $12 * $28
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
			adc #<SCREEN_RAM + $03 * $28
			sta BONUS_VECTOR1 + 0
			lda #>SCREEN_RAM + $03 * $28
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
			.byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89
	BonusLabelLine2:
			.byte $90,$91,$92,$93,$94,$95,$96,$97,$98,$99
}