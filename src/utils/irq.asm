*=* "IRQ"
IRQ: {
	ScreenShakeTimer:
		.byte $00

	ScreenShakeValues:
		.byte 3,4,3,5,3,6,3,6,3
	
	Setup: {
		sei

		lda #$7f	//Disable CIA IRQ's to prevent crash because 
		sta $dc0d
		sta $dd0d

		lda #<NMI
		sta $fffa
		lda #>NMI
		sta $fffb

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
	NMI:
		rti
	}

	InitGameIRQ: {
		sei

			lda #<SecondIRQ    
			ldx #>SecondIRQ
			sta IRQ_LSB   // 0314
			stx IRQ_MSB	// 0315

			lda #$01
			sta $d012
			lda $d011
			and #%01111111
			sta $d011


		asl $d019
		
		cli
		rts
	}
	// ColorRamp1:
	// 	.byte $0b, $02, $02, $04, $0e, $03, $0d, $01
	// 	.byte $01, $0d, $03, $0e, $04, $02, $0b, $0b
	// RampIndex:
	// 	.byte $07

	MainIRQ: {		
		:StoreState()
			ldx #$03
		!:
			dex
			bne !-
			
			lda $d011
			and #%01111000
			ora #%00000011 
			sta $d011

			//HUD Color
			ldx #$00
			stx VIC.BACKGROUND_COLOR



			ldx $d012
			inx
			cpx $d012
			bne *-3



			lda #$00	//Hide sprites
			sta $d00c
			sta $d00e 



			lda VIC.SCREEN_CONTROL_2
			ora #%00010000
			sta VIC.SCREEN_CONTROL_2




			lda #$00	//Hide sprites
			sta $d00a
			lda $d010 
			and #%00011111 
			sta $d010 


			lda #$01
			sta PerformFrameCodeFlag


			//Calculate any screen shake ready
			//for the next IRQ
			lda DOOR.Player1Exiting
			ora DOOR.Player2Exiting
			bne !NoShake+

			lda ScreenShakeValues
			sta SCREEN_SHAKE_VAL
			ldx ScreenShakeTimer
			beq !NoShake+
			dec ScreenShakeTimer
			lda ScreenShakeTimer
			and #$07
			tax
			lda ScreenShakeValues, x
		!NoShake:
			sec
			sbc #$03
			sta SCREEN_SHAKE_VAL


			lda #$0e
			sta VIC.EXTENDED_BG_COLOR_1


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

		// 	lda TRANSITION.TransitionHUDActive
		// 	beq !+
		// 	jmp HudFLDIRQSetup
		// !:
			//Reset Values set by IRQ	
	
			lda PIPES.MAPDATA_COPY.TransparentColor
			sta VIC.BACKGROUND_COLOR

			lda VIC.SCREEN_CONTROL_1
			and #%01111000
			ora #%00000000 
			sta VIC.SCREEN_CONTROL_1

			lda PIPES.MAPDATA_COPY.MultiColor
			sta VIC.EXTENDED_BG_COLOR_1
			lda VIC.SCREEN_CONTROL_2
			ora #%00010000
			sta VIC.SCREEN_CONTROL_2
			

			//Now shake the screen
			lda VIC.SCREEN_CONTROL_1
			and #%01111000
			// ora #$00
			ora SCREEN_SHAKE_VAL
			clc
			// adc #$03
			sta VIC.SCREEN_CONTROL_1	

			
			!:

			lda #<MainIRQ    
			ldx #>MainIRQ
			sta IRQ_LSB   // 0314
			stx IRQ_MSB	// 0315

			lda #$de //Adjust for screen Vscroll
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
			lda #<HudTransitionIRQ    
			ldx #>HudTransitionIRQ
			sta IRQ_LSB   // 0314
			stx IRQ_MSB	// 0315

			lda #$fc //Adjust for screen Vscroll
			sta $d012
			lda $d011
			and #%01111111
			sta $d011	

		!ExitIRQ:

			asl $d019 //Acknowledging the interrupt
		:RestoreState()
		rti
	}


	HudTransitionIRQ: {
		:StoreState()	
			lda #$00
			sta $d015

			lda #$01
			sta PerformFrameCodeFlag

		!ExitIRQ:
			asl $d019 //Acknowledging the interrupt
		:RestoreState()
		rti		
	}
}