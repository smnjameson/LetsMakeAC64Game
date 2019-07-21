PLAYER: {
	PlayerX:
			.byte $01 //2 pixel accuracy
	PlayerY:
			.byte $00 //1 pixel accuracy

	Initialise: {
			lda #$0a
			sta VIC.SPRITE_MULTICOLOR_1
			lda #$09
			sta VIC.SPRITE_MULTICOLOR_2

			lda #$05
			sta VIC.SPRITE_COLOR_0

			lda #$40
			sta SPRITE_POINTERS + 0

			lda VIC.SPRITE_ENABLE 
			ora %00000001
			sta VIC.SPRITE_ENABLE

			lda VIC.SPRITE_MULTICOLOR
			ora %00000001
			sta VIC.SPRITE_MULTICOLOR

			rts
	}

	GetCollisions: {
			.label X_OFFSET = 13
			.label Y_OFFSET = 46


			//calculate x and y in screen space
			lda PlayerX
			cmp #X_OFFSET
			bcs !+
			lda #X_OFFSET
		!:	
			sec
			sbc #X_OFFSET
			lsr
			lsr
			sta COLLISION_X

			lda PlayerY
			cmp #Y_OFFSET
			bcs !+
			lda #Y_OFFSET
		!:
			sec
			sbc #Y_OFFSET
			lsr
			lsr
			lsr
			sta COLLISION_Y

			rts
	}

	DrawPlayer: {
			lda PlayerX
			asl
			sta VIC.SPRITE_0_X
			bcc !+
			lda VIC.SPRITE_MSB
			ora #%00000001
			jmp !EndMSB+
		!:
			lda VIC.SPRITE_MSB
			and #%11111110
		!EndMSB:
			sta VIC.SPRITE_MSB

			lda PlayerY
			sta VIC.SPRITE_0_Y

			rts
	}


	PlayerControl: {
			.label JOY_PORT_2 = $dc00

			.label JOY_UP = %00001
			.label JOY_DN = %00010
			.label JOY_LT = %00100
			.label JOY_RT = %01000
			.label JOY_FR = %10000

			lda JOY_PORT_2
			sta JOY_ZP


		!Up:
			lda JOY_ZP	
			and #JOY_UP
			bne !+
			dec PlayerY
			dec PlayerY
			jmp !Left+
		!:

		!Down:
			lda JOY_ZP
			and #JOY_DN
			bne !+
			inc PlayerY
			inc PlayerY
		!:

		!Left:
			lda JOY_ZP
			and #JOY_LT
			bne !+
			ldx PLAYER.PlayerX
			dex
			cpx #255
			bne !Skip+
			ldx #183
		!Skip:
			stx PLAYER.PlayerX
			jmp !Right+
		!:

		!Right:
			lda JOY_ZP
			and #JOY_RT
			bne !+
			ldx PLAYER.PlayerX
			inx
			cpx #184
			bne !Skip+
			ldx #$00
		!Skip:
			stx PLAYER.PlayerX
		!:

			rts
	}
}