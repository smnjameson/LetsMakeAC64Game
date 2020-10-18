* = * "Sound"
SOUND: {
	CurrentGameTrack:
		.byte $ff

	TrackDisplayState:
		.byte $01

	TrackNames:
		.encoding "screencode_upper"
		.text "  GUMMY BEARS   "
		.text "   WINE GUMS    "
		.text "COCONUT MUSHROOM"
		.text "    JAZZIES     "
		.text " CHERRY WHEELS  "
		.text "  JELLY BABIES  "
		.text "  FIZZY SNAKES  "
		.text "   LIQUORICE    "
		.text "    CANDYMAN    "

	TrackArtists:
		.encoding "screencode_upper"
		.text "   PHAZE101     "	
		.text " MIKE RICHMOND  "


	ClearSoundRegisters: {
			lda #$00
			sta $d404
			sta $d40b
			sta $d412
			lda #$00
			sta $d418
			rts
	}

	SelectRandomGameTrack: {
		!:
			jsr Random
			lsr
			lsr
			and #$0f
			cmp #$09
			bcs !-
			cmp CurrentGameTrack
			beq !-
			sta CurrentGameTrack
			clc
			adc #$03
			jsr $1000
			lda #$01
			sta TrackDisplayState
			rts
	}

	CheckForSkipAndMute: {

				//Set DDR to allow selecting a keyboard column
		lda #%11111111
		sta $dc02
			//Select a column
			lda #%11111110
			sta $dc00

			lda $dc01
			and #%00100000
			bne !+

			lda TrackDisplayState
			bne !+

			jsr SelectRandomGameTrack
			inc TrackDisplayState	

		!:
		//Restore joystick Control
		lda #%00000000
		sta $dc02
		rts
	}

	UpdateTrackDisplay: {
			jsr CheckForSkipAndMute

			lda TrackDisplayState
			beq !exit+

			cmp #$01
			bne !+
			jmp CopyTrackInfo //Tail call
		!:
			inc TrackDisplayState
			bne !+
			jsr HUD.InitialiseEatMeter
			jsr HUD.UpdateEatMeter
			rts
		!:
			lda TrackDisplayState
			cmp #$40
			bcs !Fadeout+
			lsr
			lsr
			tax 
			lda #$01
			sta $d800 + $17 * $28 + $0c, x
			sta $d800 + $18 * $28 + $0c, x
			jmp !exit+

		!Fadeout:
			cmp #$c0
			bcc !exit+
			sbc #$c0
			lsr
			lsr
			tax 
			lda #$00
			sta $d800 + $17 * $28 + $0c, x
			sta $d800 + $18 * $28 + $0c, x

		!exit:
			rts
	}


	CopyTrackInfo: {
			lda CurrentGameTrack
			asl
			asl
			asl
			asl
			tax 

			ldy #$00
		!loop:
			lda TrackNames ,x
			cmp #$20
			bne !+
			lda #$db
			jmp !apply+
		!:
			clc
			adc #$e5
		!apply:
			sta SCREEN_RAM + $17 * $28 + $0c, y
			lda #$00
			sta $d800 + $17 * $28 + $0c, y
			inx
			iny 
			cpy #$10
			bne !loop-


			lda CurrentGameTrack
			ldx #$00
			cmp #$08
			bne !+
			ldx #$10
		!:

			ldy #$00
		!loop:
			lda TrackArtists ,x
			cmp #$20
			bne !+
			lda #$db
			jmp !apply+
		!:
			cmp #$30 
			bcc !+
			clc
			adc #$ac
			jmp !apply+
		!:
			clc
			adc #$e5
		!apply:
			sta SCREEN_RAM + $18 * $28 + $0c, y
			lda #$00
			sta $d800 + $18 * $28 + $0c, y
			inx
			iny 
			cpy #$10
			bne !loop-	

			inc TrackDisplayState
			rts
	}

/*
sfx 01. player fires shot
sfx 02. player hits enemy with shot
sfx 08. player shoots floor (color change)
sfx 07. player makes ground shake (fat)
sfx 06. player eats
sfx 11. switch lightly pressed
sfx 09. enemy begins moving through pipe
sfx 10. enemy appears out of pipe
sfx 03. player collects bonus
sfx 04. player collects crown
sfx 12. switch fully pressed & door appears
sfx 14. player exits through door
sfx 05. player death
*/
	PlayerShoot:
		.import binary "../../assets/sound/phaze101/sfx_1.bin"
	PlayerHit:
		.import binary "../../assets/sound/phaze101/sfx_2.bin"
	FloorColorChange:
		.import binary "../../assets/sound/phaze101/sfx_8.bin"
	PlayerGroundShake:
		.import binary "../../assets/sound/phaze101/sfx_7.bin"
	PlayerEat:
		.import binary "../../assets/sound/phaze101/sfx_6.bin"
	PressSwitchLite:
		.import binary "../../assets/sound/phaze101/sfx_11.bin"
	EnemyPipeStart:
		.import binary "../../assets/sound/phaze101/sfx_9.bin"
	EnemyPipeSpawn:
		.import binary "../../assets/sound/phaze101/sfx_10.bin"
	PlayerBonus:
		.import binary "../../assets/sound/phaze101/sfx_3.bin"
	PlayerCrown:
		.import binary "../../assets/sound/phaze101/sfx_4.bin"
	PressSwitchFull:
		.import binary "../../assets/sound/phaze101/sfx_12.bin"
	DoorExit:
		.import binary "../../assets/sound/phaze101/sfx_14.bin"
	PlayerDeath:
		.import binary "../../assets/sound/phaze101/sfx_5.bin"

}

.macro playSFX(label) {
	pha
	txa 
	pha 
	tya 
	pha 
	lda #<label        //Start address of sound effect data 
    ldy #>label 
    ldx #14       //0, 7 or 14 for channels 1-3 
   	jsr $1006
   	pla 
   	tay
   	pla 
   	tax
   	pla
}