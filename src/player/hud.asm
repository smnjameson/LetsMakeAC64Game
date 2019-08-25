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
}