TITLE_SCREEN: {
	*= * "TITLE_SCREEN"
	PressFire:
		.encoding "screencode_upper"
		.text "PRESS FIRE"
	ColorIndex:
		.byte $00
	ColorRamp:
		.byte $01,$0d,$0f,$0e,$0c,$04,$0b,$09
		.byte $00,$09,$0b,$04,$0c,$0e,$0f,$0d

	Initialise: {

			ldx #$09
		!:
			lda PressFire, x
			cmp #$20
			beq !Skip+
			// clc
			// adc #$e5
			sta SCREEN_RAM + $0e * $28 + $13, x
		!Skip:
			dex
			bpl !-
			rts
	}

	Update: {


			lda #$e0
			cmp $d012
			bne *-3

			//FLASH TEXT
			lda ZP_COUNTER
			and #$01
			bne !+
			inc ColorIndex
		!:

			lda ColorIndex
			and #$0f
			tay

			ldx #$09
		!:
			lda ColorRamp, y
			sta VIC.COLOR_RAM + $0e * $28 + $13, x
			dex
			bpl !-


			//Check joysticks
			lda $dc00
			and #$10
			bne !+
		!PlayerOneFire:
			lda #$01
			sta PLAYER.PlayersActive
			sec
			rts


		!:
			lda $dc01
			and #$10
			bne !+
		!PlayerTwoFire:
			lda #$02
			sta PLAYER.PlayersActive
			sec
			rts


		!:
			clc
			rts
	}


}