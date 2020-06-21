TITLECARD: {
	
	isComplete:
		.byte $00

	CompleteCallback:
		.word $0000
	TransitionDirection:
		.byte $01
	IsBonus:
		.byte $00

	SideSpriteIndex:
		.byte $00

	SideSpritePositions:
		.byte $24, $24

	TransitionTopIndex:
		.byte $27
	* = * "TransitionSideIndex"	
	TransitionSideIndex:
		.byte $48

	UpdateReady:
		.byte $00

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
			lda #$35
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

			lda #%11000000
			sta $d015

			lda #$32
			sta $d00d
			sta $d00f

			lda #%00001110
			sta $d018
			lda $d016
			ora #%00010000
			sta $d016

			jsr SetSideSprites
			jsr DrawTopTrim

			lda #$04
			sta $d023

			asl $d019
			cli
			rts
	}

	TransitionIn: {
			//Backup the sprites at C400-C7ff to 0400-07ff
			// Duplicate screen data from c000 to c400
			ldx #$00
		!:
			.for(var i = 0; i<4; i++) {
				lda $c400 + i * $100, x
				sta $0400 + i * $100, x
				lda $c000 + i * $100, x
				sta $c400 + i * $100, x
			}
			dex
			bne !-

			lda #$00
			sta TRANSITION_BARS.UpdateDirection
			lda #$00
			jsr TRANSITION_BARS.Init

			lda #$01
			sta TITLECARD.TransitionDirection
			jsr TITLECARD.Initialise
			lda $d011
			pha
			lda #$5b
			sta $d011
			jsr TITLECARD.ClearTitleCardScreen
			pla
			sta $d011

		!:
			lda TITLECARD.isComplete
			beq !-
			rts
	}

	TransitionOut: {
			lda #$ff
			sta TITLECARD.TransitionDirection
			jsr TITLECARD.Initialise
		!:
			lda TITLECARD.isComplete
			beq !-

			lda $d011
			bmi *-3
			lda $d011
			bpl *-3
				
			sei
			lda #$01
			sta TRANSITION_BARS.UpdateDirection
			lda #$01
			jsr TRANSITION_BARS.Init


			lda #$0e
			sta $d021
			lda #$00
			sta $d023
			lda #%00001100
			sta $d018
			lda $d016
			and #%11110000
			ora #%00011000
			sta $d016			
			lda $d011	
			and #%11110000
			ora #%00001011
			sta $d011	

					//TODO Draw the correct stuff behind the transition sprites
					jsr MAPLOADER.DrawMap

					jsr CopyTitleCardScreen

					jsr BlackOutHUD

		!:
			lda TRANSITION_BARS.ChangeDirection
			beq !-

			sei

			//Restore the sprites to C400-C7ff from 0400-07ff
			ldx #$00
		!:
			.for(var i = 0; i<4; i++) {
				lda $0400 + i * $100, x
				sta $c400 + i * $100, x
			}
			dex
			bne !-

			lda #$00
			sta $d01d
			sta $d017
			rts
	}

	CopyTitleCardScreen: {
			ldx #$00
		!:	
			.for(var i=0 ;i<4; i++) {
				lda $c000 + i * $fa, x
				sta $c400 + i * $fa, x
			}
			inx
			cpx #$fa
			bne !-
			rts
	}

	ClearTitleCardScreen: {
			ldx #$00

		!:	
			.for(var i=0 ;i<4; i++) {
				lda #$00
				sta $c000 + i * $fa, x
				lda #$04
				sta $d800 + i * $fa, x
			}
			inx
			cpx #$fa
			bne !-
			rts
	}

	BlackOutHUD: {
				ldx #$77
			!:
				lda #$90
				sta SCREEN_RAM + $16 * $28, x 
				sta SCREEN_RAM + $0400 + $16 * $28, x 
				lda #$08
				sta $d800 + $16 * $28, x 
				dex
				bpl !-
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

			sta $d012

			lda #<TransitionIRQ_2
			sta IRQ_LSB
			lda #>TransitionIRQ_2
			sta IRQ_MSB	

		//Check is complete
		lda isComplete
		cmp #$01
		bne !+

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
			//SPRITE LINE 0
			lda SideSpriteIndex
			cmp #$00
			bne !+		
			lda $d016
			and #%11100000
			ora #%00010000
			sta $d016
			lda #$ff
			sta $d01b

			lda TransitionTopIndex
			cmp #$46
			bne !noBGChange+
			lda #$02
			sta $d021
		!noBGChange:



			lda ZP_COUNTER
			and #$01
			bne !skip+
			jsr AnimateTopTrim
		!skip:
			jmp !MCFinished+

			//SPRITE LINE 1
		!:	
			cmp #$02
			bne !+	
			lda #$07
			sta $d021


		!:
			cmp #$04
			bne !+	
			lda $d016
			and #%11101111
			sta $d016

			lda #$00
			sta $d01b
			jmp !MCFinished+			

		!:	
			cmp #$08	
			bne !+

			lda IsBonus
			bne !IsInBonus+
			lda $d016
			and #%11101000
			ora TITLE_SCREEN.ScrollerFineIndex + 1
			sta $d016

			lda #$00
			sta $d01b
		!IsInBonus:
			jmp !MCFinished+			
		!:	


		!MCFinished:

			pla


			clc 
			adc #$15
			sta SideSpritePositions + 1
			bcs !Finish+


			sec 
			sbc #$02
			sta $d012

			jmp Exit

	!Finish:
			lda #<TransitionIRQ_1
			sta IRQ_LSB
			lda #>TransitionIRQ_1
			sta IRQ_MSB

			lda #$00
			sta $d012	

			jsr SetSideSprites
			jsr DrawTopTrim
			jsr AnimateSideSprites
			jsr CheckComplete

			lda #$01
			sta UpdateReady
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

			lda TransitionDirection
			bpl !In+
		!Out:
			lda TransitionTopIndex
			cmp #[__TopTransitionOut - TopTransitionOut - 1]
			bne !Exit+
			lda TransitionSideIndex
			cmp #[__SideTransitionOut - SideTransitionOut - 1]
			bne !Exit+
			lda #$01
			sta isComplete		
			jmp !Exit+
		!In:	
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

	AnimateSideSprites: {
			ldy $ec42
			ldx #$00
		!:
			lda $ec45, x
			sta $ec42, x
			inx
			inx 
			inx 
			cpx #$3f
			bne !-
			sty $ec42 + $3c
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
			:easeLinear(47,0,40)
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


			//Draw space below trim then trim
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
			beq !NoSpaceBehindTrim+ //Dont draw red space behind if trim on last line


			//Draw red space behind trim
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
		!NoSpaceBehindTrim:


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

