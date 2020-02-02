IRQ: {
	/*
	furroy: need screen shake when fat guy jumps and lands !!!!!!
	*/

	ScreenShakeTimer:
		.byte $00

	ScreenShakeValues:
		.byte 0,0,1,0,2,0,3,0,4

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
		sta $fffe   // 0314
		stx $ffff	// 0315

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
			ldx #$04
		!:
			dex
			bne !-
			
			lda #$00	//Hide sprites
			sta $d00c
			sta $d00e

			ldx #WHITE
			lda VIC.SCREEN_CONTROL_2
			and #%11111000
			ora #%00011000 
			tay
			
			stx VIC.BACKGROUND_COLOR
			sty VIC.SCREEN_CONTROL_2
			lda #$0a
			sta VIC.EXTENDED_BG_COLOR_1

			lda #$01
			sta PerformFrameCodeFlag

			lda #<SecondIRQ    
			ldx #>SecondIRQ
			sta $fffe   // 0314
			stx $ffff	// 0315

			lda #$00
			sta $d012
			lda $d011
			and #%11111111
			sta $d011	

			asl $d019 //Acknowledging the interrupt
		:RestoreState();
		rti
	}


	SecondIRQ: {
		:StoreState()


			//Reset Values set by IRQ	
			lda #LIGHT_BLUE
			sta VIC.BACKGROUND_COLOR
			lda VIC.SCREEN_CONTROL_2
			and #%11110000
			ora #%00010000 
			sta VIC.SCREEN_CONTROL_2
			lda #$05
			sta VIC.EXTENDED_BG_COLOR_1

			

				//Now shake the screen
				lda ScreenShakeTimer
				beq !NoShake+
				dec ScreenShakeTimer
				ldx ScreenShakeTimer
				lda ScreenShakeValues, x
				sta RANDOM_VAL
				lda VIC.SCREEN_CONTROL_2
				and #%11111000
				ora RANDOM_VAL
				sta VIC.SCREEN_CONTROL_2	
			!NoShake:


			lda #<MainIRQ    
			ldx #>MainIRQ
			sta $fffe   // 0314
			stx $ffff	// 0315

			lda #$e2
			sta $d012
			lda $d011
			and #%01111111
			sta $d011	

			asl $d019 //Acknowledging the interrupt
		:RestoreState();
		rti
	}
}