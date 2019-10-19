HUD: {
	Initialise: {
			ldy #$01
			ldx #119
		!:
			lda HUD_DATA, x
			sta SCREEN_RAM + 22 * 40, x
			lda #$00
			sta VIC.COLOR_RAM + 22 * 40, x
			
			dex
			bpl !-
			rts
	}

	//Acc = Score to add (25) (BCD Format) $25 = 25
	//X = trailing zeros count (1)
	//Y = Player 
	//Positions (2,24) & (30,24)
	AddScore: {
			.label SCORE = VECTOR6;
			.label SCORETOADD = TEMP9
			.label TEMP = TEMP10

			sta SCORETOADD
			cpy #$00
			bne !P2+
		!P1:
			lda #<[SCREEN_RAM + 24 * 40 + 2]
			sta SCORE
			lda #>[SCREEN_RAM + 24 * 40 + 2]
			sta SCORE + 1
			jmp !Done+
		!P2:
			lda #<[SCREEN_RAM + 24 * 40 + 30]
			sta SCORE
			lda #>[SCREEN_RAM + 24 * 40 + 30]
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
}


