SPRITEWARP: {

	init: {
		lda #$90
		sta $d004
		sta $d005
		lda #$3f
		sta SPRITE_POINTERS + 2

		rts
	}

	generate: {
			.label TEMP = TEMP1

			lda #<$c400
			sta SPRITE_SOURCE + 0
			lda #>$c400
			sta SPRITE_SOURCE + 1
			lda #<$cfc0
			sta SPRITE_TARGET + 0
			lda #>$cfc0
			sta SPRITE_TARGET + 1
			jsr copySprite


			ldy #$00 //Pointer into warp table
			sty TEMP
		!Loop:

			//Do shifts
			lda WarpTable, y
			tay
		!:
			beq !FinishShift+
			jsr shiftLeft
			jmp !-
		!FinishShift:

			//Do dissolves
			.for(var i=0; i<7; i++) {
				ldy TEMP
				lda WarpTable + i + 1, y
				tay
				ldx #i
				jsr dissolve		
			}

			lda #<$cfc0
			sta SPRITE_SOURCE + 0
			lda #>$cfc0
			sta SPRITE_SOURCE + 1
		GenTargetLSB:
			lda #$00
			sta SPRITE_TARGET + 0
		GenTargetMSB:
			lda #$60
			sta SPRITE_TARGET + 1
			jsr copySprite
			


			clc
			lda GenTargetLSB + 1
			adc #$40
			sta GenTargetLSB + 1
			lda GenTargetMSB + 1
			adc #$00
			sta GenTargetMSB + 1

			lda TEMP
			clc
			adc #$08
			sta TEMP
			tay
			cpy #$40
			bcs !+
			jmp !Loop-
		!:

			//Copy last 8 sprites flipped
			// lda GenTargetLSB
			// sta SPRITE_TARGET + 0
			// sta SPRITE_SOURCE + 0
			// lda GenTargetMSB
			// sta SPRITE_TARGET + 1

			rts
	}

	// 0- Num to shift left
	// 1-7 Col0-6 squeeze amount
	WarpTable: 
		.byte 1, 4,3,3,2,2,1,1
		.byte 2, 4,3,3,2,2,1,1
		.byte 1, 4,3,3,2,2,1,1
		.byte 2, 4,3,3,2,2,1,1
		.byte 1, 4,3,3,2,2,1,1
		.byte 2, 4,3,3,2,2,1,1
		.byte 1, 4,3,3,2,2,1,1
		.byte 2, 4,3,3,2,2,1,1
	

	copySprite: {
			ldy #$3f
		!Loop:
			lda (SPRITE_SOURCE), y
			sta (SPRITE_TARGET), y
			dey
			bpl !Loop-
			rts
	}


	copySpriteFlipped: {
			ldy #$00
		!Loop:

			lda (SPRITE_SOURCE), y
			tax
			lda SpriteFlipTable, x
			pha
			iny
			iny
			lda (SPRITE_SOURCE), y
			tax
			lda SpriteFlipTable, x
			dey
			dey
			sta (SPRITE_TARGET), y

			iny
			lda (SPRITE_SOURCE), y
			tax
			lda SpriteFlipTable, x
			sta (SPRITE_TARGET), y

			iny
			pla
			sta (SPRITE_TARGET), y
			
			iny
			cpy #$3f
			bcc !Loop-

			rts
	}



	shiftLeft: {
			ldx #$00
		!Loop:
			asl $cfc0 + 2, x
			rol $cfc0 + 1, x
			rol $cfc0 + 0, x

			asl $cfc0 + 2, x
			rol $cfc0 + 1, x
			rol $cfc0 + 0, x
			inx
			inx
			inx
			cpx #$3f
			bcc !Loop-
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

			sty SQUEEZE_COUNT


			clc
			lda ByteOffsets, x
			adc #$1b
			sta TARGET

			lda ByteOffsets, x
			adc TopOffset, y
			sta SOURCE

		!Loop:
			ldy SOURCE
			bpl !+
			lda #$00
			sta TEMP
			jmp !Skip+
		!:
			lda $cfc0, y
			and BitMasks, x
			sta TEMP
			lda $cfc0, y
			and InvBitMasks, x
			sta $cfc0, y
		!Skip:

			ldy TARGET
			lda $cfc0, y
			and InvBitMasks, x
			ora TEMP
			sta $cfc0, y

			lda SOURCE
			sec
			sbc #$03
			sta SOURCE
			lda TARGET
			sec
			sbc #$03
			sta TARGET
			bpl !Loop-


			ldy SQUEEZE_COUNT

			clc
			lda ByteOffsets, x
			adc #$21
			sta TARGET

			lda ByteOffsets, x
			adc BottomOffset, y
			sta SOURCE

		!Loop:
			ldy SOURCE
			cpy #$3f
			bcc !+
			lda #$00
			sta TEMP
			jmp !Skip+
		!:
			lda $cfc0, y
			and BitMasks, x
			sta TEMP
			lda $cfc0, y
			and InvBitMasks, x
			sta $cfc0, y
		!Skip:

			ldy TARGET
			lda $cfc0, y
			and InvBitMasks, x
			ora TEMP
			sta $cfc0, y


			lda SOURCE
			clc
			adc #$03
			sta SOURCE

			lda TARGET
			clc
			adc #$03
			sta TARGET
			cmp #$3f
			bcc !Loop-

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


	SpriteFlipTable:
		.for(var i=0; i<256; i++) {
			.var b = ((i & $c0)  >> 6) | ((i & $30)  >> 2) | ((i & $0c)  << 2) | ((i & $03)  << 6)
			.byte b
		}
}


