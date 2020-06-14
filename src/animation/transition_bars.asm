TRANSITION_BARS: {

	.label SPRITE_POINTERS1 = $c3f8
	.label BANK1 = %00001100
	.label SPRITE_POINTERS2 = $c7f8
	.label BANK2 = %00011100

	Init: {	
			sei 

			pha


			lda #$7f	//Disable CIA IRQ's to prevent crash because 
			sta $dc0d
			sta $dd0d
			lda $d01a	//Enable raster irq
			ora #%00000001	
			sta $d01a



			// .break
			//Initialise the sprite data
			ldx #$3f
		!:
			lda #%00000000
			sta $cf80, x
			lda #%01010101
			sta $cfc0, x
			dex 
			bpl !-

	


			lda #<SpriteSplitIRQ
			sta IRQ_LSB
			lda #>SpriteSplitIRQ
			sta IRQ_MSB

			lda $d011
			and #$7f
			sta $d011
			lda IrqLineTable
			sta $d012

			lda #$01
			sta $d01a 

			// asl $d019
			cli
			



			jsr InitSprites
			jsr AnimateBars

			lda $d016
			and #%11110111
			sta $d016
			lda $d011
			and #%01110111
			sta $d011
			

			lda #$00
			sta ChangeDirection



			pla
			bne !Exit+
			


		!:
			lda ChangeDirection
			beq !-

			lda #$00
			sta $d01d
			sta $d017


		!Exit:
			rts
	}

	Update: {
		!Loop:
			lda FrameTimer
			beq !Loop-
			lda #$00
			sta FrameTimer

			lda HoldAnimation
			beq !+
			dec HoldAnimation
			jmp !Loop-
		!:

			lda ChangeDirection
			beq !Loop-

			lda #$00
			sta ChangeDirection
			
			lda #$7f
			sta HoldAnimation
			lda UpdateDirection
			eor #$01
			sta UpdateDirection
			beq !Loop-


			inc $d021 

		!Exit:
			rts

	}




	InitSprites: {
			lda #$ff
			sta $d015	//Turn on sprites 0-6
			sta $d017   //Set vertical expand for sprites
			sta $d01d   //set horizontal expand
			sta $d01c   //Set multicolor

			//set sprite multicolor
			lda #$07
			sta $d025

			//msb
			lda #$40
			sta $d010   //Turn on MSB-X for sprites 5 & 6

			ldx #$00
			ldy #$00
		!:
			lda SpriteX_Defaults, x 
			sta $d000, y 		//Set X
			lda SpriteY_Values
			sta $d001, y		//Set Y
			lda #$3f
			sta SPRITE_POINTERS1, x 		//Set pointer
			sta SPRITE_POINTERS2, x 		//Set pointer

			iny
			iny
			inx 
			cpx #$08
			bne !-

			// lda #$00
			// sta $d021
			rts
	}


                     			

	BankTable:
			.byte BANK1, BANK2

	SpriteX_Defaults:
			.byte $0f, $3f, $6f, $9f, $cf, $ff, $2f
	SpriteY_Values:
			.byte $32, $5c, $86, $b0, $da

	IrqIndex:
			.byte $00
	SplitIndex:
			.byte $00
	BandIndex:
			.byte $00
	POT:
			.byte 1,2,4,8,16,32,64,128


	//.byte $0f, $3f, $6f, $9f, $cf, $ff, $2f
	SpriteOffset:
			.byte $00

	AnimateBars: {
			// inc BandPositions

			ldx #$00
		!MainLoop:
			txa 
			pha
			asl
			asl
			asl
			tay

			lda BandSpriteOffsets, x
			tax
			// cmp #$e0
			// bcc !+
		// 	lda #$00
		// 	jmp !skip+
		// !:
			lda PositionSpriteLookup, x
		!skip: 
			sta SpriteOffset

			// inc SpriteOffset

			ldx #$00
			lda #$3e
		!Loop:
			cpx SpriteOffset
			bcc !+
			lda #$3f
		!:
			sta BandPointers, y
			iny
			inx
			cpx #$07
			bne !Loop-


			pla 
			tax 
			inx
			cpx #[__BandColors - BandColors]
			bne !MainLoop-

			rts

	}

	//.byte $0f, $3f, $6f, $9f, $cf, $ff, $2f
	PositionSpriteLookup:
			.fill $08, 0
			.fill $18, 1
			.fill $18, 2
			.fill $18, 3
			.fill $18, 4
			.fill $18, 5
			.fill $18, 6
			.fill $30, 7


	BandColors:
			.byte $07, $08, $02, $08, $07, $02, $08, $07, $02
	__BandColors:
	BandColorsRampNumbers:
			.byte $00, $01, $02, $01, $00, $02, $01, $00, $02, $00 //Last byte duplicates first

	BandColorRamps:
			.byte $07, $07, $07, $07, $07, $07, $07, $07
			.byte $07, $07, $07, $0f, $0c, $08, $08, $08
			.byte $07, $07, $0f, $0c, $08, $02, $02, $02


	BandPointers:
			.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
			.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00 
			.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00 
			.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00 
			.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00 
			.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00 
			.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00 
			.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00 
			.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00 


	BandSpriteOffsets:
		  //.byte $0f,$3f,$6f,$9f,$cf,$ff,$2f
			.byte $b8
			.byte $b8
			.byte $b8
			.byte $b8
			.byte $b8
			.byte $b8
			.byte $b8
			.byte $b8
			.byte $b8
			.byte $b8 //Copy of first byte

	BandSpriteOffsetsFrac:
			.fill BandSpriteOffsetsFrac - BandSpriteOffsets - 1, 0

	BandSpriteOffsetsSpeed:
			.byte $00
			.fill BandSpriteOffsetsFrac - BandSpriteOffsets - 3, random() * 128 + 128
			.byte $00
	BandSpriteOffsetsSpeedMSB:
			.byte $07
			.byte 5,3,4,3,7,4,5
			.byte $07
	BandSpriteOffsetsSpeedRightMSB:
			.byte $02
			.byte 3,6,4,6,2,4,3
			.byte $02

	FrameTimer:
		.byte $00
	HoldAnimation:
		.byte $00
	ChangeDirection:
		.byte $00
	UpdateDirection:
		.byte $00
	DirectionOffset:
		.byte $0c, $2c
	FinishedCount:
		.byte $00
		
	PREVIOUS_INDEX: 	.byte $00

	IrqTable:
			.word SpriteUpdateIRQ
				.word SpriteSplitIRQ
			.word SpriteUpdateIRQ
				.word SpriteSplitIRQ
			.word SpriteUpdateIRQ
			.word SpriteUpdateIRQ
				.word SpriteSplitIRQ
			.word SpriteUpdateIRQ
			.word SpriteUpdateIRQ
				.word SpriteSplitIRQ
			.word SpriteUpdateIRQ
				.word SpriteSplitIRQ
			.word SpriteUpdateIRQ
			.word SpriteUpdateIRQ

	IrqLineTable:
			.byte $27
				.byte $2e //S
			.byte $46
				.byte $58 //S
			.byte $68
			.byte $75
				.byte $82 //S
			.byte $8d
			.byte $a0
				.byte $ac //S
			.byte $c0
				.byte $d6 //S
			.byte $de
			.byte $e9
	__IrqLineTable:

	NextColor:		.byte $00
	NextXPosition: .byte $00
	NextD010:	.byte $00
	DummyStore:	.byte $00
	XposTemp:
		.byte $00
	Timer:
		.byte $00


	.align $100


	UpdateOffsetsLeft: {
			ldx #$00
			stx FinishedCount
		!:
			lda BandSpriteOffsetsFrac, x
			sec
			sbc BandSpriteOffsetsSpeed, x
			sta BandSpriteOffsetsFrac, x
			lda BandSpriteOffsets, x
			sbc BandSpriteOffsetsSpeedMSB, x
			sta BandSpriteOffsets, x


			cmp #$0c
			bcs !skip+
			lda #$0c
			sta BandSpriteOffsets, x
			inc FinishedCount
		!skip:

			inx
			cpx #[BandSpriteOffsetsFrac - BandSpriteOffsets - 1]
			bne !-

			lda BandSpriteOffsets
			sta [BandSpriteOffsets + [BandSpriteOffsetsFrac - BandSpriteOffsets - 1]]
			rts
	}	


	UpdateOffsetsRight: {
			ldx #$00
			stx FinishedCount
		!:
			lda BandSpriteOffsetsFrac, x
			clc
			adc BandSpriteOffsetsSpeed, x
			sta BandSpriteOffsetsFrac, x
			lda BandSpriteOffsets, x
			adc BandSpriteOffsetsSpeedRightMSB, x
			sta BandSpriteOffsets, x

			cmp #$b8
			bcc !skip+
			lda #$b8
			sta BandSpriteOffsets, x
			inc FinishedCount
		!skip:

			inx
			cpx #[BandSpriteOffsetsFrac - BandSpriteOffsets - 1]
			bne !-

			lda BandSpriteOffsets
			sta [BandSpriteOffsets + [BandSpriteOffsetsFrac - BandSpriteOffsets - 1]]
			rts
	}	





	SpriteSplitIRQ: {
			pha 
			txa 
			pha 
			tya 
			pha 

			ldx SplitIndex
			lda SpriteY_Values, x
			ldy #$00
		!:
			sta $d001, y 
			iny
			iny
			cpy #$10
			bne !-

			inc SplitIndex	

			jmp NextRaster

	}



	SpriteUpdateIRQ: {
			pha 
			txa 
			pha 
			tya 
			pha 

			nop
			nop
			nop
			nop
			nop
			nop
			nop
			bit $ea 


			lda BandIndex 
			and #$01
			tax
			lda BankTable, x
			sta $d018



			lda NextColor
			ldy NextXPosition
			ldx NextD010

			// nop
			// nop
			// nop		
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop

			sta $d025
		XPOS_MOD2:
			sty $d00e
			stx $d010





			



			//Now setup sprite pointers for the NEXT split
			//Set pointers for sprites to turn last few off


			ldx BandIndex
			lda BandSpriteOffsets + 1, x //New x position
			jsr SetXpositionAndD010

			jsr SetBankPointers

			inc BandIndex

			jmp NextRaster
	}



	SetBankPointers: {
			ldx BandIndex
			inx
			cpx #[__BandColors - BandColors]
			bne !+
			ldx #$00
		!:

			txa 
			asl
			asl
			asl
			tax 

			lda BandIndex
			and #$01
			bne !Bank2Pointers+

		!Bank1Pointers:
			lda BandPointers, x
			sta SPRITE_POINTERS2+ 0
			inx
			lda BandPointers, x
			sta SPRITE_POINTERS2+ 1
			inx
			lda BandPointers, x
			sta SPRITE_POINTERS2+ 2
			inx
			lda BandPointers, x
			sta SPRITE_POINTERS2+ 3
			inx
			lda BandPointers, x
			sta SPRITE_POINTERS2+ 4
			inx
			lda BandPointers, x
			sta SPRITE_POINTERS2+ 5
			inx
			lda BandPointers, x
			sta SPRITE_POINTERS2+ 6
			jmp !BankPointersEnd+


		!Bank2Pointers:
			lda BandPointers, x
			sta SPRITE_POINTERS1+ 0
			inx
			lda BandPointers, x
			sta SPRITE_POINTERS1+ 1
			inx
			lda BandPointers, x
			sta SPRITE_POINTERS1+ 2
			inx
			lda BandPointers, x
			sta SPRITE_POINTERS1+ 3
			inx
			lda BandPointers, x
			sta SPRITE_POINTERS1+ 4
			inx
			lda BandPointers, x
			sta SPRITE_POINTERS1+ 5
			inx
			lda BandPointers, x
			sta SPRITE_POINTERS1+ 6


		!BankPointersEnd:
			rts
	}


	SetXpositionAndD010: {
			ldy #$40
			pha
			asl
			bcc !+
			ldy #$c0
		!:
			sty NextD010
			sta NextXPosition


			pla
			ldy UpdateDirection
			sec
			sbc DirectionOffset, y
			bcs !+
			lda #$00
		!:


			cmp #$40
			bcs !Default+
			and #$3f
			lsr
			lsr
			lsr
			jmp !SetColor+
		!Default:
			lda #$07
		!SetColor:
			sta XposTemp
			lda BandColorsRampNumbers + 1, x
			asl 
			asl
			asl
			clc
			adc XposTemp
			tay

			lda BandColorRamps, y
			sta NextColor


			rts

	}

	NextRaster: {
			ldx IrqIndex
			inx
			cpx #[__IrqLineTable - IrqLineTable]
			bne !+


			// jmp !Skip+
			lda HoldAnimation
			bne !Skip+

			lda UpdateDirection
			beq !Left+
		!Right:
			jsr UpdateOffsetsRight
			jmp !UpdateDone+

		!Left:
			jsr UpdateOffsetsLeft


		!UpdateDone:
			lda FinishedCount
			cmp #[__BandColors - BandColors]
			bne !Skip+
			lda #$01
			sta ChangeDirection

		!Skip:



			jsr AnimateBars

			ldx #$00
			stx SplitIndex
			stx BandIndex


			lda #$01
			sta FrameTimer

			ldx #$00
		!:
			stx IrqIndex
			//Set next IRQ line
			lda IrqLineTable, x
			sta $d012

			txa 
			asl
			tax 
			lda IrqTable + 0, x 
			sta IRQ_LSB 
			lda IrqTable + 1, x 
			sta IRQ_MSB 

			pla 
			tay 
			pla 
			tax 
			pla 

			asl $d019
			rti
	}


	// * = $3f40 "Sprite data"
	// 	.fill 64, %00000000
	// 	.fill 64, %01010101
}