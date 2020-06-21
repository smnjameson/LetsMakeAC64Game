TRANSITION: {
	TransitionActive:
		.byte $00
	TransitionComplete:
		.byte $00
	TransitionHUDActive:
		.byte $00
	TransitionIndex:
		.byte $00
				
	TransitionHUDIndex:
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
			sta TransitionHUDActive
			sta TransitionHUDIndex
			rts
	}

	Update: {	

			lda TransitionHUDActive

			beq !+
			jmp UpdateHUDTransition
		!:

			lda TransitionActive
			bne !+
			jsr Init
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
			sta TransitionHUDIndex
			sta TransitionHUDActive
		!:
			rts
	}

	UpdateHUDTransition: {

			// lda ZP_COUNTER
			// and #$01
			// bne !end+
			ldx TransitionHUDIndex
			inx
			cpx #$29
			bne !+
			
			jsr BONUS.Start
		!:
			stx TransitionHUDIndex


			ldx #$26
		!:
			lda SCREEN_RAM + $28 * $17, x
			sta SCREEN_RAM + $28 * $17 + 1, x
			lda SCREEN_RAM + $28 * $18, x
			sta SCREEN_RAM + $28 * $18 + 1, x
			lda VIC.COLOR_RAM + $28 * $17, x
			sta VIC.COLOR_RAM + $28 * $17 + 1, x
			lda VIC.COLOR_RAM + $28 * $18, x
			sta VIC.COLOR_RAM + $28 * $18 + 1, x
			dex
			bpl !-
			lda #$00
			sta SCREEN_RAM + $28 * $17
			sta SCREEN_RAM + $28 * $18


		!end:
			rts
	}

}