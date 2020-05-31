TITLECARD: {
	
	isComplete:
		.byte $00

	CompleteCallback:
		.word $0000
	TransitionDirection:
		.byte $01
	SideSpriteIndex:
		.byte $00

	SideSpritePositions:
		.byte $32, $32

	TransitionTopIndex:
		.byte $27
	* = * "TransitionSideIndex"	
	TransitionSideIndex:
		.byte $48


	Initialise: {
			sei

			lda #$7f	//Disable CIA IRQ's to prevent crash because 
			sta $dc0d
			sta $dd0d
			lda $d01a	//Enable raster irq
			ora #%00000001	
			sta $d01a



			lda #<TransitionIRQ_1
			sta IRQ_LSB
			lda #>TransitionIRQ_1
			sta IRQ_MSB

			lda #$00
			sta $d012
			lda $d011
			and #%01110000
			sta $d011
			

			//Setup transition
			lda #$00
			sta TransitionTopIndex
			lda #$00
			sta TransitionSideIndex

			lda #$00
			sta isComplete
			lda #$32
			sta SideSpritePositions




			lda #$07
			sta $d021

			lda #$b0
			sta SPRITE_POINTERS + 6
			lda #$b1
			sta SPRITE_POINTERS + 7
			lda #$08
			sta $d02d
			sta $d02e

			lda $d01c
			and #%00111111
			sta $d01c
			lda $d010
			and #%00111111
			sta $d010

			lda $d01b
			ora #%11000000
			sta $d01b

			lda $d01d
			ora #%01000000
			sta $d01d

			lda #$18
			sta $d00c
			lda #$48
			sta $d00e

			lda #$32
			sta $d00d
			sta $d00f

			lda #%00001110
			sta $d018
			lda $d016
			ora #%00010000
			sta $d016

			asl $d019
			cli
			rts
	}

	TransitionIRQ_1: {
		sta RestoreAcc + 1
		stx RestoreX + 1
		sty RestoreY + 1

			inc ZP_COUNTER

			lda #$00
			sta SideSpriteIndex

			lda SideSpritePositions + 0
			sta SideSpritePositions + 1

			sec
			sbc #$04
			sta $d012

			lda #<TransitionIRQ_2
			sta IRQ_LSB
			lda #>TransitionIRQ_2
			sta IRQ_MSB	

		//Check is complete
		lda isComplete
		cmp #$01
		bne !+

		// lda #$02
		// sta isComplete
		// pla
		// pla

		// lda CompleteCallback + 0
		// pha 
		// lda CompleteCallback + 1
		// pha

	!:

		asl $d019 
	RestoreAcc:
		lda #$BEEF
	RestoreX:
		ldx #$BEEF
	RestoreY:
		ldy #$BEEF
		rti
	}


	TransitionIRQ_2: {
		sta RestoreAcc + 1
		stx RestoreX + 1
		sty RestoreY + 1

			lda SideSpritePositions + 1
			sta $d00d
			sta $d00f

			pha
			//Positional based stuff
			lda SideSpriteIndex
			cmp #$00
			bne !+		
			lda $d016
			ora #%00010000
			sta $d016
			jmp !MCFinished+
		!:
			cmp #$04
			bne !+	
			lda $d016
			and #%11101111
			sta $d016
			jmp !MCFinished+			
		!:	
			lda #$00 
			sta $d020
		!MCFinished:
			lda ZP_COUNTER
			and #$01
			bne !+
			ldx SideSpritePositions + 1
			cpx #$33
			bcs !+
			jsr AnimateTopTrim
		!:
			pla


			clc 
			adc #$15
			sta SideSpritePositions + 1
			bcs !Finish+


			sec 
			sbc #$04
			sta $d012

			jmp Exit

	!Finish:
			lda #<TransitionIRQ_1
			sta IRQ_LSB
			lda #>TransitionIRQ_1
			sta IRQ_MSB

			lda #$00
			sta $d012	

			ldx SideSpritePositions + 0
			dex
			cpx #$1d
			bne !+
			ldx #$32
		!:
			stx SideSpritePositions + 0

			jsr SetSideSprites
			jsr DrawTopTrim
				
			jsr CheckComplete
	Exit:
		inc SideSpriteIndex
		asl $d019 
	RestoreAcc:
		lda #$BEEF
	RestoreX:
		ldx #$BEEF
	RestoreY:
		ldy #$BEEF
		rti		
	}

	CheckComplete: {
			lda isComplete
			bne !Exit+

			lda TransitionTopIndex
			cmp #[__TopTransitionIn - TopTransitionIn - 1]
			bne !Exit+
			lda TransitionSideIndex
			cmp #[__SideTransitionIn - SideTransitionIn - 1]
			bne !Exit+
			lda #$01
			sta isComplete
		!Exit:
			rts

	}

	AnimateTopTrim: {
			//f8d8 //f8e0
			ldx #$07
		!loop:
			lda $f8d8, x
			lsr
			ror $f8e0, x
			bcc !+
			ora #$80
		!:
			sta $f8d8, x

			lda $f8d8, x
			lsr
			ror $f8e0, x
			bcc !+
			ora #$80
		!:
			sta $f8d8, x	

			dex
			bpl !loop-
			rts		
	}

	SetSideSprites: {
			lda $d01d
			ora #%01000000
			sta $d01d

			ldx TransitionSideIndex
			lda TransitionDirection
			bpl !In+
		!Out:
			lda SideTransitionOut, x
			jmp !Done+
		!In:
			lda SideTransitionIn, x
		!Done:
			sta $d00e
			sec
			sbc #$30
			bpl !+

			pha
			lda $d01d
			and #%10111111
			sta $d01d
			pla
			clc
			adc #$18
			bpl !+
			lda #$00
		!:
			sta $d00c



		//Increment or decrement index to animate
			ldx TransitionSideIndex
			inx 
			cpx #[__SideTransitionIn - SideTransitionIn]
			bne !+
			ldx #[__SideTransitionIn - SideTransitionIn - 1]
		!:
			stx TransitionSideIndex


			rts
	}

	SideTransitionIn:
			:easeOutBounce(0,71,70)
	__SideTransitionIn:	
	SideTransitionOut:
			:easeInQuart(71,0,40)
	__SideTransitionOut:	

	TopTransitionIn:
			:easeOutBounce(0,47,70)
	__TopTransitionIn:	 
	TopTransitionOut:
			:easeInQuart(47,0,40)
	__TopTransitionOut:	

	DrawTopTrim: {
			ldx TransitionTopIndex
			lda TransitionDirection
			bpl !In+
		!Out:
			lda TopTransitionOut, x
			jmp !Done+
		!In:
			lda TopTransitionIn, x
		!Done:


			sta TITLECARD_EASE_INDEX
			lsr
			lsr
			lsr
			tax 
			lda TABLES.ScreenRowLSB, x 
			sta ScreenMod + 1
			sta ColorMod + 1
			lda TABLES.ScreenRowMSB, x 
			sta ScreenMod + 2
			sta ScreenMod2 + 2
			clc
			adc #>[$d800 - SCREEN_RAM]
			sta ColorMod + 2
			sta ColorMod2 + 2


			//toggle char 1b & 1c
			ldx #$4f
		!:	
			lda #$00
			cpx #$28
			bcs ScreenMod
			txa 
			and #$01
			clc
			adc #$1b
		ScreenMod:
			sta $BEEF, x
			lda #$0a
		ColorMod:
			sta $BEEF, x
			dex
			bpl !-



			lda TITLECARD_EASE_INDEX
			lsr
			lsr
			lsr
			tax 
			beq !Exit+


			lda ScreenMod + 1
			sec 
			sbc #$28
			sta ScreenMod2 + 1
			sta ColorMod2 + 1


			ldx #$27	
		!:
			lda #$29
		ScreenMod2:
			sta $BEEF, x
			lda #$02
		ColorMod2:
			sta $BEEF, x
			dex
			bpl !-


		!Exit:
			lda TITLECARD_EASE_INDEX
			and #$07
			sta TITLECARD_TEMP1
			lda $d011
			and #%01111000
			ora TITLECARD_TEMP1
			sta $d011


		//Increment or decrement index to animate
	
			ldx TransitionTopIndex
			inx 
			cpx #[__TopTransitionIn - TopTransitionIn]
			bne !+
			ldx #[__TopTransitionIn - TopTransitionIn - 1]
		!:
			stx TransitionTopIndex

		!Exit:
			rts	
	}
}