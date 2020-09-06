* = * "Transition bars"

TRANSITION_CHARS: {

	BarLengths:
		.fill 25, 0 
	BarColors:
		.fill 25, 7 
	BarSpeeds:
		// .fill 25, mod(i, 2) + 1
		.byte 3,3,3
		.byte 4,4,4,4
		.byte 5,5
		.byte 4,4,4
		.byte 3,3
		.byte 3,3,3,3
		.byte 4,4,4
		.byte 5
		.byte 3,3,3
	BandColorsRampNumbers:
		.byte 0,0,0
		.byte 1,1,1,1
		.byte 2,2
		.byte 1,1,1
		.byte 0,0
		.byte 2,2,2,2
		.byte 1,1,1
		.byte 0
		.byte 2,2,2

	Direction:
		.byte $01

	BandColorRamps:
			// .byte $07, $07, $07, $07, $07, $07, $07, $07
			.byte $07,$07,$07,$07,$07,$07,$07,$07
			.byte $02,$04,$05,$05,$03,$03,$07,$07
			.byte $04,$05,$05,$03,$03,$07,$07,$07
			// .byte $07, $07, $07, $03, $03, $05, $05, $04


	Init: {
			//Set new screen
			lda #%00011100
			sta $d018	

			jsr ResetBars
			jsr DrawAllRowsFull
			jsr UpdateRows

			rts
	}	

	ResetBars: {
			ldx #$18
		!Loop:
			lda #$00
			sta BarLengths, x
			dex
			bpl !Loop-
			rts
	}



	GetRowColor: {
			tay 
			lda Direction
			bne !+
			tya 
			clc
			adc #$d8
			eor #$ff
			tay 
		!:
			cpy #$1f
			bcc !+
			ldy #$1e
		!:
			tya
			lsr  
			lsr  
			// lda #$07
			sta TRANSITION_TEMP5


			lda BandColorsRampNumbers, x 
			asl  
			asl
			asl 
			clc
			adc TRANSITION_TEMP5

			tay 
			lda BandColorRamps, y
			sta BarColors, x

			rts
	}	


	UpdateRows: {

			!OuterLoop:
				lda #$19
				sta TRANSITION_TEMP3

				ldx #$00
			!Loop:
				lda BarLengths, x
				clc 
				adc BarSpeeds, x
				cmp #$28
				bcc !+
				dec TRANSITION_TEMP3
				lda #$28
			!:
				sta BarLengths, x

				jsr GetRowColor


			// 	cmp #$08
			// 	bcc !+
			// 	lda #$07
			// !:
			// 	tay 
			// 	lda BandColorRamps, y
			// 	sta BarColors, x

				inx
				cpx #$19
				bne !Loop-

				jsr DrawAllRowsFull

				lda TRANSITION_TEMP3
				beq !Exit+

				// lda #$ff
				// cmp $d012
				// bne *-3

				jmp !OuterLoop-

			!Exit:
				rts
	}





	DrawAllRowsFull: {
			ldx #$00
		!:
			txa 
			pha 
			jsr DrawRowFull
			pla 
			tax 
			inx
			cpx #$19
			bne !-
			rts
	}



	BranchOpcodes:
			.byte $b0, $90
	DrawRowFull: {
			ldy Direction
			lda BranchOpcodes, y
			sta BranchSM

			lda TABLES.ScreenRowLSB, x
			sta ScreenFetchSM + 1
			sta ScreenSM + 1
			sta ColorSM + 1
			lda TABLES.ScreenRowMSB, x
			sta ScreenFetchSM + 2
			clc 
			adc #$04
			sta ScreenSM + 2
			adc #>[$d800 - $c400]
			sta ColorSM + 2

			lda BarLengths, x
			sta TRANSITION_TEMP1

			lda BarColors, x
			sta TRANSITION_TEMP4


			ldy #$27
		!Loop:
			lda TRANSITION_TEMP4
			sta TRANSITION_TEMP2
			lda #$9d
			cpy TRANSITION_TEMP1
		BranchSM:
			bcs !+
		ScreenFetchSM:
			lda $BEEF, y
			tax 
			pha 
			lda CHAR_COLORS, x 
			sta TRANSITION_TEMP2
			pla
		!:
		ScreenSM:
			sta $BEEF, y 
			lda TRANSITION_TEMP2	
		ColorSM:
			sta $BEEF, y
			dey
			bpl !Loop-
			rts

	}


}