GAMEOVER: {
	GameOverExited: .byte $00
	HiscorePositions:
		.byte $ff,$ff
	HiscoreEntryIndex:
		.byte $00,$00

	HiScoreValueData:
		.text "00100000"
		.text "00075000"
		.text "00050000"
		.text "00020000"
		.text "00010000"
		.text "00001000"
		.text "00000500"
		.text "00000100"


	HiScoreNameData:
		.text "ACE....."
		.text "BCE....."
		.text "CCE....."
		.text "DCE....."
		.text "ECE....."
		.text "FCE....."
		.text "GCE....."
		.text "HCE....."


	Start: {	
			lda #$00
			sta GameOverExited
			sta TITLECARD.IsBonus

			lda #$ff
			sta HiscorePositions + 0
			sta HiscorePositions + 1
			sta HiscoreEntryIndex + 0
			sta HiscoreEntryIndex + 1

			jsr CheckHiScore
			jsr DisplayHiScore
			rts
	}

	debounce:	.byte $00 

	HiscoreNameLSB:
			.byte <[SCREEN_RAM + $0a * $28 + $1a]
			.byte <[SCREEN_RAM + $0b * $28 + $1a]
			.byte <[SCREEN_RAM + $0c * $28 + $1a]
			.byte <[SCREEN_RAM + $0d * $28 + $1a]
			.byte <[SCREEN_RAM + $0e * $28 + $1a]
			.byte <[SCREEN_RAM + $0f * $28 + $1a]
			.byte <[SCREEN_RAM + $10 * $28 + $1a]
			.byte <[SCREEN_RAM + $11 * $28 + $1a]
	HiscoreNameMSB:
			.byte >[SCREEN_RAM + $0a * $28 + $1a]
			.byte >[SCREEN_RAM + $0b * $28 + $1a]
			.byte >[SCREEN_RAM + $0c * $28 + $1a]
			.byte >[SCREEN_RAM + $0d * $28 + $1a]
			.byte >[SCREEN_RAM + $0e * $28 + $1a]
			.byte >[SCREEN_RAM + $0f * $28 + $1a]
			.byte >[SCREEN_RAM + $10 * $28 + $1a]
			.byte >[SCREEN_RAM + $11 * $28 + $1a]

	PlayerNameEntry: {

			ldx #$00
		!:
			lda HiscorePositions, x 
			bmi !Skip+
			tay
			lda HiscoreNameLSB, y
			sta HISCORE_ENTRY + 0
			lda HiscoreNameMSB, y
			sta HISCORE_ENTRY + 1

			lda HiscoreEntryIndex, x 
			tay 
			lda #$ff
			sta (HISCORE_ENTRY), y

		!Skip: 
			inx
			cpx #$02
			bne !-
			rts
	}


	Update: {	

			lda HiscoreEntryIndex + 0
			bpl !+
			lda HiscoreEntryIndex + 1
			bpl !+
			jmp ExitGameOverCheck
		!:
			jsr PlayerNameEntry
			rts

		ExitGameOverCheck:
			lda debounce 
			bne !B2+
			lda $dc00
			and #$10
			bne !+
			inc debounce
		!:
			rts

		!B2:
			lda $dc00
			and #$10
			beq !-
			inc GameOverExited
			dec debounce
			rts	
	}	




	DisplayHiScore: {
			.label COLOR = VECTOR7
			.label SCREEN = VECTOR8

			lda #<[SCREEN_RAM + $0a * $28 + $0d]
			sta SCREEN + 0
			sta COLOR + 0
			lda #>[SCREEN_RAM + $0a * $28 + $0d]
			sta SCREEN + 1
			lda #>[$d800 + $0c * $28 + $10]
			sta COLOR + 1



			ldx #$00
		!:
			txa 
			pha 

			//Position number
			clc 
			adc #$dd
			ldy #$00
			sta (SCREEN), y 
			lda #$00
			sta (COLOR), y 

			iny
			iny
			iny

			txa 
			asl
			asl 
			asl 
			tax
			lda #$08
			sta TEMP1 
		!Loop1:
			lda HiScoreValueData, x
			clc
			adc #$ac
			sta (SCREEN), y 
			lda #$00
			sta (COLOR), y 		
			iny
			inx 
			dec TEMP1
			bne !Loop1-

			iny
			iny

			pla 
			pha
			asl
			asl 
			asl 
			tax
			lda #$08
			sta TEMP1 
		!Loop1:
			lda HiScoreNameData, x
			clc
			adc #$e5
			sta (SCREEN), y 
			lda #$00
			sta (COLOR), y 		
			iny
			inx 
			dec TEMP1
			bne !Loop1-


			//Advance row
			lda SCREEN + 0
			clc
			adc #$28
			sta SCREEN + 0
			sta COLOR + 0
			bcc !skip+
			inc SCREEN + 1
			inc COLOR + 1

		!skip:
			pla 
			tax 
			inx
			cpx #$08
			bne !-
			rts
	}


	CheckHiScore: {
			.label PLAYER_CHECK_COUNT = TEMP1
			.label HISCORE_ENTRY_INDEX = TEMP2

			lda #$00
			sta TEMP1

			lda #P1_SCORE
			sta SM_FETCH + 1
			sta SM_STORE + 1

		!NextPlayer:
			ldy #$00	//Hiscore digit index
			ldx #$00	//Player Digit Index
		!FetchDigits:
			lda HiScoreValueData, y
		SM_FETCH:
			cmp $FF, x
		!CheckEqual: //Move one digit right 
			bne !CheckMore+
			iny 
			inx 
			cpx #$08
			beq !MoveDown+
			jmp !FetchDigits-

		!CheckMore:	//Move down a row (if row>8 no hiscore)
			bcc !HasHiscore+
		!MoveDown:
			tya 
			clc
			adc #$08
			tay 
			cpy #$40
			bcs !Skip+ //No hiscore
			jmp !FetchDigits-
			//00800
			//-----
			//01 0 00
			//00(7)00

		!HasHiscore:	//We have hiscore
			ldx TEMP1
			tya
			lsr 
			lsr 
			lsr
			sta HiscorePositions, x  //Stores player position in table
			lda #$00
			sta HiscoreEntryIndex, x

			ldx #$00
			tya 
			and #%11111000
			tay
			sty HISCORE_ENTRY_INDEX

			cpy #$38
			beq !InsertScore+

			//Shift hiscores down
			ldy #$38
		!:
			dey 
			lda HiScoreValueData - $08, y 
			sta HiScoreValueData + $00, y 
			lda HiScoreNameData - $08, y 
			sta HiScoreNameData + $00, y 
			cpy HISCORE_ENTRY_INDEX
			bne !-



		!InsertScore:
			//Insert new score
			ldy HISCORE_ENTRY_INDEX
		!:	
		SM_STORE:
			lda $FF, x 
			sta HiScoreValueData, y 
			lda #$9f
			sta HiScoreNameData, y 
			iny
			inx
			cpx #$08
			bne !-

		!Skip:
			lda #P2_SCORE
			sta SM_FETCH + 1
			sta SM_STORE + 1

			inc TEMP1
			lda TEMP1 
			cmp #$02
			bne !NextPlayer-
			rts

	}


}