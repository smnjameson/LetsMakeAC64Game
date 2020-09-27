TITLE_SCREEN: {
	*= * "TITLE_SCREEN"
	PressFire:
		.encoding "screencode_upper"
		.text "PRESS FIRE"

	ScrollerFineIndex:
		.byte $00, $00

	Initialise: {

			lda #$00
			sta ScrollerFineIndex
			lda #<[INTROTEXT-1]
			sta TITLESCREEN_SCROLLER_INDEX + 0
			lda #>[INTROTEXT-1]
			sta TITLESCREEN_SCROLLER_INDEX + 1

			lda #$04
			ldx #$26
		!:
			sta $d800 + $16 * $28, x
			sta $d800 + $17 * $28, x
			dex
			bpl !-

			lda #$07
			sta $d029
			lda $d015
			ora #%00000100
			sta $d015
			lda $d010
			ora #%00000100
			sta $d010

			lda #$38
			sta $d004
			lda #$e1
			sta $d005

			lda $d01c
			and #%11111011
			sta $d01c

			lda #$b2
			sta SPRITE_POINTERS + 2

			
			rts
	}

	Destroy: {
			lda #$00
			ldx #$00
		!:
			sta SCREEN_RAM + $06 * $28 + 000, x
			sta SCREEN_RAM + $06 * $28 + 190, x
			sta SCREEN_RAM + $06 * $28 + 380, x
			sta SCREEN_RAM + $06 * $28 + 570, x
			inx 
			cpx #190
			bne !-
			rts
	}

	Update: {

			ldx ScrollerFineIndex
			dex 
			cpx #$07
			bne !+
			jsr ShiftScroller
		!:
			cpx #$ff
			bne !+
			jsr ShiftScroller
			ldx #$0f
		!:
			stx ScrollerFineIndex
			txa 
			and #$07
			sta ScrollerFineIndex + 1

			jsr AnimateDitherSprite

			jmp CheckJoystick
	}


	CheckJoystick: {
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

	AnimateDitherSprite: {
			lda $ec80
			pha
			lda $ec81
			pha
			lda $ec82
			pha

			ldx #$00
		!:
			lda $ec83, x
			sta $ec80, x
			inx
			cpx #$3c
			bne !-

			pla 
			sta $ec80 + $3e
			pla 
			sta $ec80 + $3d
			pla 
			sta $ec80 + $3c
			rts
	}

	ShiftScroller: {
			stx TITLESCREEN_TEMP1

			ldx #$00
		!:
			lda SCREEN_RAM + $16 * $28 + 1, x
			sta SCREEN_RAM + $16 * $28 + 0, x
			lda SCREEN_RAM + $17 * $28 + 1, x
			sta SCREEN_RAM + $17 * $28 + 0, x
			inx
			cpx #$27
			bne !-

			ldx TITLESCREEN_TEMP1
			bpl !+

			clc
			lda TITLESCREEN_SCROLLER_INDEX + 0
			adc #$01
			sta TITLESCREEN_SCROLLER_INDEX + 0
			lda TITLESCREEN_SCROLLER_INDEX + 1
			adc #$00
			sta TITLESCREEN_SCROLLER_INDEX + 1


		!:	
			ldy #$00
			lda (TITLESCREEN_SCROLLER_INDEX), y
			bpl !+
			lda #<[INTROTEXT]
			sta TITLESCREEN_SCROLLER_INDEX + 0
			lda #>[INTROTEXT]
			sta TITLESCREEN_SCROLLER_INDEX + 1
			lda (TITLESCREEN_SCROLLER_INDEX), y
		!:
			tay
			lda CharMap, y
			cmp #$40
			beq !Space+
			clc
			adc #$40

			cpx #$ff
			beq !+
			adc #$2c
		!:
			sta SCREEN_RAM + $16 * $28 + $27
			clc
			adc #$58
			sta SCREEN_RAM + $17 * $28 + $27
		
			rts

		!Space:
			lda #$00
			sta SCREEN_RAM + $16 * $28 + $27
			sta SCREEN_RAM + $17 * $28 + $27
			rts
	}

	CharMap:
		.encoding "screencode_upper"
		.text "@ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		.byte 64,64,64,64,64,64
		.byte 37,64,64,64,64,64
		.byte 42,38,39,64,64,41,43,40,64
		.byte 27,28,29,30,31,32,33,34,35,36
		.byte 64,64,64,64,64,64

}