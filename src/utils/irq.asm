IRQ: {
	/*
	furroy: need screen shake when fat guy jumps and lands !!!!!!
	*/

	ScreenShakeTimer:
		.byte $00

	ScreenShakeValues:
		.byte 3,3,4,3,5,3,6,3,7

	Setup: {
		sei

		lda #$7f	//Disable CIA IRQ's to prevent crash because 
		sta $dc0d
		sta $dd0d

		lda $d01a
		ora #%00000001	
		sta $d01a

		lda #<MainIRQ    
		ldx #>MainIRQ
		sta IRQ_LSB   // 0314
		stx IRQ_MSB	// 0315


		lda #<IRQ_Indirect
		sta $fffe
		lda #>IRQ_Indirect
		sta $ffff

		lda #$e2
		sta $d012
		lda $d011
		and #%01111111
		sta $d011	

		asl $d019
		cli
		rts
	}

	ColorRamp1:
		.byte $0b, $02, $02, $04, $0e, $03, $0d, $01

		.byte $01, $0d, $03, $0e, $04, $02, $0b, $0b
	RampIndex:
		.byte $07

	MainIRQ: {		
		:StoreState()
			ldx #$03
		!:
			dex
			bne !-

			ldx #BLACK
			stx VIC.BACKGROUND_COLOR

			lda #$00	//Hide sprites
			sta $d00c
			sta $d00e 

			lda VIC.SCREEN_CONTROL_1
			and #%01111000
			ora #%00000011
			sta VIC.SCREEN_CONTROL_1

			lda VIC.SCREEN_CONTROL_2
			ora #%00010000
			sta VIC.SCREEN_CONTROL_2


			lda #$0a
			sta VIC.EXTENDED_BG_COLOR_1

			lda #$00	//Hide sprites
			sta $d00a
			lda $d010 
			and #%00011111 
			sta $d010 


			lda #$01
			sta PerformFrameCodeFlag


			//Calculate any screen shake ready
			//for the next IRQ
			lda ScreenShakeValues
			sta SCREEN_SHAKE_VAL
			ldx ScreenShakeTimer
			beq !NoShake+
			dec ScreenShakeTimer
			ldx ScreenShakeTimer
			lda ScreenShakeValues, x
		!NoShake:
			sec
			sbc #$03
			sta SCREEN_SHAKE_VAL


			lda #<SecondIRQ    
			ldx #>SecondIRQ
			sta IRQ_LSB   // 0314
			stx IRQ_MSB	// 0315

			lda #$01
			sta $d012
			lda $d011
			and #%01111111
			sta $d011	




			asl $d019 //Acknowledging the interrupt
		:RestoreState()
		rti
	}


	SecondIRQ: {
		:StoreState()

			lda TRANSITION.TransitionFLDActive
			beq !+
			jmp HudFLDIRQSetup
		!:
			//Reset Values set by IRQ	
			lda #LIGHT_BLUE
			sta VIC.BACKGROUND_COLOR
			lda VIC.SCREEN_CONTROL_1
			and #%01111000
			ora #%00000011 
			sta VIC.SCREEN_CONTROL_1
			lda #$05
			sta VIC.EXTENDED_BG_COLOR_1
			lda VIC.SCREEN_CONTROL_2
			ora #%00010000
			sta VIC.SCREEN_CONTROL_2
			

			//Now shake the screen
			lda VIC.SCREEN_CONTROL_1
			and #%01111000
			ora SCREEN_SHAKE_VAL
			clc
			adc #$03
			sta VIC.SCREEN_CONTROL_1	

			

				// lda #<FLDIRQ    
				// ldx #>FLDIRQ
				// sta IRQ_LSB   // 0314
				// stx IRQ_MSB	// 0315

				// lda #$20 //Adjust for screen Vscroll
				// clc
				// adc SCREEN_SHAKE_VAL
				// sta $d012
				// lda $d011
				// and #%01111111
				// sta $d011	

				// jmp !ExitIRQ+
			!:

			lda #<MainIRQ    
			ldx #>MainIRQ
			sta IRQ_LSB   // 0314
			stx IRQ_MSB	// 0315

			lda #$e2 //Adjust for screen Vscroll
			clc
			adc SCREEN_SHAKE_VAL
			sta $d012
			lda $d011
			and #%01111111
			sta $d011	

		!ExitIRQ:

			asl $d019 //Acknowledging the interrupt
		:RestoreState()
		rti
	}




















	HudFLDIRQSetup: {
			lda #<HudFLDIRQ    
			ldx #>HudFLDIRQ
			sta IRQ_LSB   // 0314
			stx IRQ_MSB	// 0315

			lda #$e2 //Adjust for screen Vscroll
			sta $d012
			lda $d011
			and #%01111111
			sta $d011	

		!ExitIRQ:

			asl $d019 //Acknowledging the interrupt
		:RestoreState()
		rti
	}


	HudFLDIRQ: {
		:StoreState()	
			lda #$00
			sta $d015

			lda $d012
			cmp $d012
			beq *-3

				lda $d011
				pha
				
				ldy TRANSITION.TransitionFLDIndex
			!Loop:
				lda $d012
				clc
				adc #$01
				and #$07
				ora #$18
				

				ldx $d012
				cpx #$d012
				beq *-3

				sta $d011

				dey
				bpl !Loop- //5	

				//Now force a badline
				// nop
				// nop

				// lda $d012
				// clc
				// adc #$01
				// and #$07
				// ora #$d018
				// sta $d011

				pla 
				sta $d011

			lda #$01
			sta PerformFrameCodeFlag

		!ExitIRQ:
			asl $d019 //Acknowledging the interrupt
		:RestoreState()
		rti		
	}
}