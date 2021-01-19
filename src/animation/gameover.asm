GAMEOVER: {
	GameOverExited: .byte $00
	HiscorePositions:
		.byte $ff,$ff
	HiscoreEntryIndex:
		.byte $00,$00

	HiScoreValueData:
		.text "00250000"
		.text "00150000"
		.text "00100000"
		.text "00075000"
		.text "00050000"
		.text "00002000"
			//
		.text "00001000"
		.text "00000100"


	HiScoreNameData:
		.text "HAYESMKR"
		.text "STEPZ"
		.byte $f6,$f6,$f6
		.text "SP"
		.byte $f8,$fe,$fc,$f6,$f6,$f6
		.text "ELDRITCH"
		.text "PROW"
		.byte $fe,$f6,$f6,$f6
		.text "MORGAN"
		.byte $f6,$f6
		.text "AKMAFIN"
		.byte $f6
		.text "AMK"
		.byte $f6,$f6,$f6,$f6,$f6
		

	Start: {	
			jsr TITLE_SCREEN.SpriteInit

			lda #$00
			sta GameOverExited
			sta TITLECARD.IsBonus

			lda #$ff
			sta HiscorePositions + 0
			sta HiscorePositions + 1
			sta HiscoreEntryIndex + 0
			sta HiscoreEntryIndex + 1

			jsr CheckHiScore

			lda HiscorePositions + 0
			bpl !yes+
			lda HiscorePositions + 1
			bpl !yes+
			rts


		!yes:
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



	HiscoreDebounce:
			.byte $1f, $1f

	PlayerNameEntry: {

			ldx #$00 //Player index

		!loop:
			lda HiscorePositions, x 
			bpl !+
			jmp !Skip+ //Do we have high score?
		!:
			tay // Y = High score position

			lda HiscoreNameLSB, y
			sta HISCORE_ENTRY + 0
			sta HISCORE_ENTRY_COLOR + 0
			lda HiscoreNameMSB, y
			sta HISCORE_ENTRY + 1
			clc
			adc #>[$d800-SCREEN_RAM]
			sta HISCORE_ENTRY_COLOR + 1

			lda HiscoreEntryIndex, x 
			tay //Index of letter to update
			cpy #$08
			bcc !+
			lda #$ff
			sta HiscoreEntryIndex, x 
			jmp !Skip+
		!:
			
			lda ZP_COUNTER
			and #$08 
			beq !+
			lda #$07
		!:
			sta (HISCORE_ENTRY_COLOR), y


			lda HiscoreDebounce, x 
			cmp #$1f
			beq !DoJoy+
			lda $dc00, x
			and #$1f
			sta HiscoreDebounce, x 
			jmp !Skip+
		!DoJoy:
			lda $dc00, x
			and #$1f
			sta HiscoreDebounce, x 
		!Up:
			lsr 
			bcs !NotUp+

			lda (HISCORE_ENTRY), y 
			sec 
			sbc #$01
			jsr VerifyCharDn
			sta (HISCORE_ENTRY), y 

			jmp !Fire+
		!NotUp:

		!Dn:
			lsr
			bcs !NotDn+

			lda (HISCORE_ENTRY), y 
			clc 
			adc #$01
			jsr VerifyCharUp
			sta (HISCORE_ENTRY), y 
			jmp !Fire+
		!NotDn:
		!UpDnDone:

		!Left:
			lda HiscoreDebounce, x
			and #$04
			bne !Fire+
			lda HiscoreEntryIndex, x
			beq !Skip+
			lda #$db
			sta (HISCORE_ENTRY), y 
			lda #$00
			sta (HISCORE_ENTRY_COLOR), y
			dec HiscoreEntryIndex, x
			jmp !Skip+

		!Fire:
			lda HiscoreDebounce, x
			and #$10 
			bne !Skip+
			lda HiscoreEntryIndex, x 
			clc 
			adc #$01
			sta HiscoreEntryIndex, x 
			lda #$00
			sta (HISCORE_ENTRY_COLOR), y
			iny
			cpy #$08
			beq !+
			lda #$e6
			sta (HISCORE_ENTRY), y 
			jmp !Skip+

		!:
			//If we have entered all 8 chars
			//then copy name into memory table
			lda HiscorePositions, x
			asl 
			asl 
			asl
			clc 
			adc #<HiScoreNameData
			sta HISCORE_RAM_ENTRY+ 0
			lda #>HiScoreNameData
			adc #$00
			sta HISCORE_RAM_ENTRY+ 1

			ldy #$00
		!:
			lda (HISCORE_ENTRY), y
			sec 
			sbc #$e5
			sta (HISCORE_RAM_ENTRY), y 
			iny
			cpy #$08
			bne !-

		!Skip: 
			inx
			cpx #$02
			beq !+
			jmp !loop-
		!:


			rts
	}


	VerifyCharUp: {
			//$db - Space
			//$dc-e5 - Numbers
			//$e6-$ff - Letters
			//_ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789


			cmp #$dc 
			bne !+
			lda #$e6
			rts
		!:
			cmp #$00 
			bne !+
			lda #$dc
			rts
		!:
			cmp #$e6 
			bne !+
			lda #$db
			rts
		!:
			rts 
	}
	VerifyCharDn: {
			//$db - Space
			//$dc-e5 - Numbers
			//$e6-$ff - Letters
			//_ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

			cmp #$da 
			bne !+
			lda #$e5
			rts
		!:
			cmp #$e5 
			bne !+
			lda #$db
			rts
		!:
			cmp #$db 
			bne !+
			lda #$ff
			rts
		!:
			rts 
	}

	Update: {	
			jsr TITLE_SCREEN.UpdateLogoSprites


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
			eor #$ff
 			sta DEBOUNCE_CHECK
 			lda $dc01 
 			eor #$ff
 			ora DEBOUNCE_CHECK
 			and #$10
			beq !+
			inc debounce
		!:


			rts

		!B2:
			lda $dc00
			eor #$ff
 			sta DEBOUNCE_CHECK
 			lda $dc01 
 			eor #$ff
 			ora DEBOUNCE_CHECK
			and #$10
			bne !-
			inc GameOverExited
			dec debounce
			rts	
	}	



	ColorToggle:
			.byte $06

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


			lda #$04
			sta ColorToggle

			ldx #$00
		!:
			txa 
			pha 

			//Position number
			clc 
			adc #$dd
			ldy #$00
			sta (SCREEN), y 
			lda ColorToggle
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
			lda ColorToggle
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
			lda ColorToggle
			sta (COLOR), y 	


			iny
			inx 
			dec TEMP1
			bne !Loop1-


			lda ColorToggle
			eor #%010
			sta ColorToggle
			
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
		
			//Now check other player if this is p2 
			//to see if their position needs moving down
			cpx #$01
			bne !skipCheckOtherPlayer+
				lda HiscorePositions
				bmi !skipCheckOtherPlayer+
				cmp HiscorePositions, x 
				bcc !skipCheckOtherPlayer+

				inc HiscorePositions

				lda HiscorePositions
				cmp #$08
				bcc !skipCheckOtherPlayer+
				lda #$ff
				sta HiscorePositions
				sta HiscoreEntryIndex

		!skipCheckOtherPlayer:

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

			ldy #$40
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
		
		
			lda #$01
		!:	
			sta HiScoreNameData, y 
		SM_STORE:
			lda $FF, x 
			sta HiScoreValueData, y 
			iny
			inx
			lda #$f6
			cpx #$08
			bne !-

		!Skip:
			lda #P2_SCORE
			sta SM_FETCH + 1
			sta SM_STORE + 1

			inc TEMP1
			lda TEMP1 
			cmp #$02
			beq !+
			jmp !NextPlayer-
		!:
			rts

	}


}