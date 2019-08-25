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

	MainIRQ: {		
		:StoreState()
			.for(var i=0; i<10; i++) {
				nop
			}

			ldx #WHITE
			lda VIC.SCREEN_CONTROL_2
			and #%11101111
			tay
			
			stx VIC.BACKGROUND_COLOR
			sty VIC.SCREEN_CONTROL_2



			////////
			:waitForRasterLine($ea)
			ldy #$08
		!:
			



			lda #$01
			sta PerformFrameCodeFlag

			asl $d019 //Acknowledging the interrupt
		:RestoreState();
		rti
	}
}