TRANSITION: {
	TransitionActive:
		.byte $00
	TransitionComplete:
		.byte $00
	TransitionFLDActive:
		.byte $00
	TransitionIndex:
		.byte $00


	Random: { 
	        lda seed
	        beq doEor
	        asl
	        beq noEor
	        bcc noEor
	    doEor:    
	        eor #$1d
	    noEor:  
	        sta seed
	        rts
	    seed:
	        .byte $62
	}


	Init: {
			lda #$01
			sta TransitionActive
			lda #$00
			sta TransitionComplete
			sta TransitionIndex
			sta TransitionFLDActive
			rts
	}

	Update: {
			lda TransitionActive
			bne !+
			jsr Init
		!:

			lda TransitionFLDActive
			beq !+
			jmp UpdateFLD
		!:
			ldx #$03
		!Loop:
			jsr Random
			cmp #$dc
			bcs !+
			tay
			lda #$08
			sta $d800, y
			sta $d800 + 220, y
			sta $d800 + 440, y
			sta $d800 + 660, y
			lda #$5f
			sta SCREEN_RAM, y
			sta SCREEN_RAM + 220, y
			sta SCREEN_RAM + 440, y
			sta SCREEN_RAM + 660, y
		!:
			inc TransitionIndex
			dex
			bpl !Loop-

			lda TransitionIndex
			bne !+
			lda #$01
			sta TransitionFLDActive
		!:
			rts
	}

	UpdateFLD: {
			rts
	}

}