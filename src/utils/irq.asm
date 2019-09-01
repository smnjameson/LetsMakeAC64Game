IRQ: {
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

			ldx #WHITE
			lda VIC.SCREEN_CONTROL_2
			and #%11101111
			tay
			
			stx VIC.BACKGROUND_COLOR
			sty VIC.SCREEN_CONTROL_2



			////////
			:waitForRasterLine($ea)

			lda #$07
			sta IRQ_TEMP1

			ldy RampIndex
		!:
			tya
			and #$0f
			tax

			lda ColorRamp1, x
			sta VIC.BACKGROUND_COLOR


			lda VIC.RASTER_Y
			cmp VIC.RASTER_Y
			beq *-3

			dey
			dec IRQ_TEMP1
			bne !-
			


			lda ZP_COUNTER
			and #$01
			beq !+
			dec RampIndex
		!:

			lda #$01
			sta VIC.BACKGROUND_COLOR

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
			lda #BLACK
			sta VIC.BACKGROUND_COLOR
			lda VIC.SCREEN_CONTROL_2
			ora #%00010000 
			sta VIC.SCREEN_CONTROL_2

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