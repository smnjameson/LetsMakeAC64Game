HUD: {
	Initialise: {
			ldy #$01
			ldx #119
		!Loop:
			lda HUD_DATA, x
			sta SCREEN_RAM + 22 * 40, x
			lda #$00
			sta VIC.COLOR_RAM + 22 * 40, x
			
			dex
			bpl !Loop-

			ldx #$0e
			lda #$0a
		!Loop:
			sta VIC.COLOR_RAM + 23 * 40 + 12, x
			sta VIC.COLOR_RAM + 24 * 40 + 12, x
			dex
			bpl !Loop-

			jsr UpdateEatMeter
			rts


	}

	//Acc = Score to add (25) (BCD Format) $25 = 25
	//X = trailing zeros count (1)
	//Y = Player 
	//Positions (2,24) & (30,24)
	AddScore: {
			.label SCORE = SCOREVECTOR1
			.label SCORETOADD = SCORETEMP1
			.label TEMP = SCORETEMP2

			sta SCORETOADD
			cpy #$00
			bne !P2+
		!P1:
			lda #<[SCREEN_RAM + 24 * 40 + 0]
			sta SCORE
			lda #>[SCREEN_RAM + 24 * 40 + 0]
			sta SCORE + 1
			jmp !Done+
		!P2:
			lda #<[SCREEN_RAM + 24 * 40 + 32]
			sta SCORE
			lda #>[SCREEN_RAM + 24 * 40 + 32]
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
			cmp #230
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

	UpdateEatMeter: {
			ldx #$00
			clc
			lda PLAYER.Player1_EatCount
			adc PLAYER.Player2_EatCount
		!Loop:	
			cmp #$04
			bcc !LessThanFour+
			pha
			lda #148
			sta SCREEN_RAM + 23 * 40 + 13, x
			lda #164
			sta SCREEN_RAM + 24 * 40 + 13, x
			pla
			sec
			sbc #$04
			jmp !Next+
		!LessThanFour:
			clc
			adc #144
			sta SCREEN_RAM + 23 * 40 + 13, x
			adc #16
			sta SCREEN_RAM + 24 * 40 + 13, x
			lda #$00

		!Next:
			inx
			cpx #14
			bne !Loop-

		!Exit:

			rts
	}
}


