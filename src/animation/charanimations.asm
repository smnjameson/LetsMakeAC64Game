CHAR_ANIMATIONS: {
	AnimateWater: {
			.label CHAR = $f000 + 12 * 8
			ldx #$07
		!Loop:
			clc
			lda CHAR, x 
			ror
			bcc !+
			ora #$80	
		!:
			ror
			bcc !+
			ora #$80	
		!:
			sta CHAR, x

			dex
			bpl !Loop-

			.label CHAR2 = $f000 + 13 * 8
			ldx #$07
		!Loop:
			clc
			lda CHAR2, x 

			ror
			bcc !+
			ora #$80	
		!:
			sta CHAR2, x

			dex
			bpl !Loop-



			rts
	}


	FlickerTimer:
			.byte $80

	FlickerLights: {
			dec FlickerTimer
			beq !+
			rts
		!:
			jsr Random
			asl
			asl
			asl
			asl
			sta FlickerTimer	

			.label CHAR1 = $f000 + 11 * 8
			.label CHAR2 = $f000 + 14 * 8

			ldx #$07
		!Loop:
			clc
			lda CHAR1, x 
			pha
			lda CHAR2, x
			sta CHAR1, x
			pla
			sta CHAR2, x

			dex
			bpl !Loop-

			rts
	}
}





