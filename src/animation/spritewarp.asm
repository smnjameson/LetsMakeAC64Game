SPRITEWARP: {

	init: {
		lda #$90
		sta $d004
		sta $d005
		lda #$3f
		sta SPRITE_POINTERS + 2

		lda #$cf
		sta SPRITE_WARP_DATA + 1
		rts
	}


	// x - column
	// y - number to squeeze
	// a - $80 or $c0, sprite 62 or 63
	dissolve: {
			.label SQUEEZE_COUNT = TEMP4
			.label SOURCE = TEMP3
			.label TARGET = TEMP2
			.label TEMP = TEMP5

			sta SPRITE_WARP_DATA
			sty SQUEEZE_COUNT

			clc
			lda ByteOffsets, x
			adc TopOffset
			sta TARGET

			lda ByteOffsets, x
			adc TopOffset, y
			sta SOURCE



		!Loop:
			ldy SOURCE
			lda (SPRITE_WARP_DATA), y
			sta TEMP
			and InvBitMasks, x
			sta (SPRITE_WARP_DATA), y

			lda TEMP
			and BitMasks, x 
			sta TEMP

			ldy TARGET
			lda (SPRITE_WARP_DATA), y
			and InvBitMasks, x
			ora TEMP
			sta (SPRITE_WARP_DATA), y

			sec
			lda TARGET
			sbc #$03
			sta TARGET

			lda SOURCE
			sbc #$03
			sta SOURCE
			bpl !Loop-



			clc
			ldy SQUEEZE_COUNT
			lda ByteOffsets, x
			adc BottomOffset, y
			sta TARGET

			clc
		!:
			adc #$03
			dey
			bne !-
			sta SOURCE

		!Loop:
			ldy SOURCE

			lda (SPRITE_WARP_DATA), y
			sta TEMP
			and InvBitMasks, x
			sta (SPRITE_WARP_DATA), y

			lda TEMP
			and BitMasks, x 
			sta TEMP

			ldy TARGET
			lda (SPRITE_WARP_DATA), y
			and InvBitMasks, x
			ora TEMP
			sta (SPRITE_WARP_DATA), y

			clc
			lda TARGET
			adc #$03
			sta TARGET

			lda SOURCE
			adc #$03
			sta SOURCE

			cmp #$3f
			bcs !Loop-

			rts
	}





	ByteOffsets:
		.byte 0,0,0,0, 1,1,1,1, 2,2,2,2
	BitMasks:
		.byte $c0, $30, $0c, $03
		.byte $c0, $30, $0c, $03
		.byte $c0, $30, $0c, $03
	InvBitMasks:
		.byte $3f, $cf, $f3, $fc
		.byte $3f, $cf, $f3, $fc
		.byte $3f, $cf, $f3, $fc
	TopOffset:
		.byte $1b, $18, $15, $12, $0f
		.byte $0c, $09, $06, $03, $00
	BottomOffset:
		.byte $21, $24, $27, $2a, $2d
		.byte $30, $33, $36, $39, $3c

		// .byte $3f, $3c, $39, $36, $33
		// .byte $30, $2d, $2a, $27, $24
}