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

		lda #$ff
		sta $d012
		lda $d011
		and #%01111111
		sta $d011	

		asl $d019
		cli
		rts
	}

	MainIRQ: {		
		:StoreState();

			lda #$01
			sta PerformFrameCodeFlag

			lda #$02
			sta $d020
			jsr CHAR_ANIMATIONS.AnimateWater
			jsr CHAR_ANIMATIONS.FlickerLights
			lda #$00
			sta $d020

			asl $d019 //Acknowledging the interrupt
		:RestoreState();
		rti
	}
}