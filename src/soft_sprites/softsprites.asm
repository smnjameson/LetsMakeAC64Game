SOFTSPRITES: {
	.label MAX_UNIQUE_CHARS = 4

	.label MAX_SPRITES = 8
	.label SPRITE_FONT_START = 187
	.label SPRITE_FONT_DATA_START = CHAR_SET + SPRITE_FONT_START * 8

	.label BLIT_TABLE_START = $b000

	Sprite_MaskTable:
		.fill 256, 00
	CurrentSpriteIndex:
		.byte $00
	SpriteData_ID: //180 = Player Projectile
		.fill MAX_SPRITES, $00
	SpriteData_X_MSB:  
		.fill MAX_SPRITES, $00
	SpriteData_X_LSB:  
		.fill MAX_SPRITES, $00
	SpriteData_Y:  
		.fill MAX_SPRITES, $00

	//Constants	
	SpriteData_CharStart:
		.fill MAX_SPRITES, SPRITE_FONT_START + i * 4
	
	SpriteData_CharStart_LSB:
		.fill MAX_SPRITES, <[SPRITE_FONT_DATA_START + 32 * i]
	SpriteData_CharStart_MSB:
		.fill MAX_SPRITES, >[SPRITE_FONT_DATA_START + 32 * i]
	

	BlitLookupCount:
		.byte $00
	BlitLookup_LSB:
		.fill MAX_UNIQUE_CHARS, 0
	BlitLookup_MSB:
		.fill MAX_UNIQUE_CHARS, 0


	Initialise: {
			ldx #$00
			lda #$00
			sta CurrentSpriteIndex
		!:
			sta SpriteData_ID, x
			sta SpriteData_X_MSB, x
			sta SpriteData_X_LSB, x
			sta SpriteData_Y, x
			inx
			cpx #MAX_SPRITES
			bne !-

			rts
	}



	AddSprite: {
			stx TEMP1
			ldx CurrentSpriteIndex

			sta SpriteData_ID, x

			tya 
			sta SpriteData_Y, x
			lda TEMP1
			sta SpriteData_X_LSB, x
			lda #$00
			rol
			sta SpriteData_X_MSB, x

			stx TEMP1

			inx
			cpx #MAX_SPRITES
			bne !+
			ldx #$00
		!:
			stx CurrentSpriteIndex



			lda TEMP1
			rts
	}

	MoveSprite: {
			sty TEMP1
			tay
			lda TEMP1
			clc
			adc SpriteData_Y, y
			sta SpriteData_Y, y


			txa
			clc
			adc SpriteData_X_LSB, y
			sta SpriteData_X_LSB, y
			lda SpriteData_X_MSB, y
			adc #$00
			sta SpriteData_X_MSB, y
			rts
	}



	UpdateSprites: {
			.label OFFSET_X = TEMP1
			.label OFFSET_Y = TEMP2
			.label TEMP = TEMP3
			.label SHIFT_TEMP = TEMP4
			.label SCREEN_X = TEMP5


			.label CHAR_DATA_LEFT = VECTOR1
			.label BLIT_LOOKUP = VECTOR2
			.label CHAR_DATA_RIGHT = VECTOR3
			.label SCREEN_ROW = VECTOR4
			.label ORIGINAL_DATA = VECTOR5



			ldx #$00
		!Loop:
			lda SpriteData_ID, x
			bne !+
			jmp !Skip+
		!:
				lda SpriteData_X_LSB, x
				and #$07
				sta OFFSET_X

				lda SpriteData_Y, x
				and #$07
				sta OFFSET_Y

				lda SpriteData_X_MSB, x
				lsr
				lda SpriteData_X_LSB, x
				ror
				lsr
				lsr
				sta SCREEN_X

				lda SpriteData_Y, x
				lsr
				lsr
				lsr
				tay 
				lda TABLES.ScreenRowLSB, y
				sta SCREEN_ROW
				lda TABLES.ScreenRowMSB, y
				sta SCREEN_ROW + 1


				//Get target location for font data in current charset
				lda SpriteData_CharStart_LSB, x
				sta CHAR_DATA_LEFT
				lda SpriteData_CharStart_MSB, x
				sta CHAR_DATA_LEFT + 1

				clc
				lda SpriteData_CharStart_LSB, x
				adc #$10
				sta CHAR_DATA_RIGHT
				lda SpriteData_CharStart_MSB, x
				adc #$00
				sta CHAR_DATA_RIGHT + 1


				stx TEMP //Store x iterator to retrieve at end


				//Get blit data lookup based on OFFSET X & Y
				//
				lda OFFSET_X
				lsr
				sta BLIT_LOOKUP + 1
				lda OFFSET_Y
				asl
				asl
				asl
				asl
				asl
				sta BLIT_LOOKUP

				lda SpriteData_ID, x
				tax
				dex
				lda BlitLookup_LSB,x
				clc
				adc BLIT_LOOKUP
				sta BLIT_LOOKUP
				lda BlitLookup_MSB,x
				adc BLIT_LOOKUP + 1
				sta BLIT_LOOKUP + 1






				//TOP LEFT
				ldy SCREEN_X
				lda (SCREEN_ROW), y
				jsr GetFontLookup
				ldy #$00
			!:
				lda (BLIT_LOOKUP), y
				tax
				lda (ORIGINAL_DATA), y
				and Sprite_MaskTable, x
				ora (BLIT_LOOKUP), y
				sta (CHAR_DATA_LEFT), y

				iny
				cpy #$08
				bne !-

				//BOTTOM LEFT
				lda SCREEN_X
				clc
				adc #$28
				tay
				lda (SCREEN_ROW), y
				jsr GetFontLookup
				
				//Instead of advancing through the target data
				//we keep the y register advancing sequentially and 
				//instead offset the original data
				sec
				lda ORIGINAL_DATA
				sbc #$08
				sta ORIGINAL_DATA
				lda ORIGINAL_DATA + 1
				sbc #$00
				sta ORIGINAL_DATA + 1

				ldy #$08
			!:
				lda (BLIT_LOOKUP), y
				tax
				lda (ORIGINAL_DATA), y
				and Sprite_MaskTable, x
				ora (BLIT_LOOKUP), y
				sta (CHAR_DATA_LEFT), y

				iny
				cpy #$10
				bne !-




				//TOP RIGHT
				ldy SCREEN_X
				iny
				lda (SCREEN_ROW), y
				jsr GetFontLookup
				
				//Instead of advancing through the target data
				//we keep the y register advancing sequentially and 
				//instead offset the original data
				sec
				lda ORIGINAL_DATA
				sbc #$10
				sta ORIGINAL_DATA
				lda ORIGINAL_DATA + 1
				sbc #$00
				sta ORIGINAL_DATA + 1

				ldy #$10
			!:
				lda (BLIT_LOOKUP), y
				tax
				lda (ORIGINAL_DATA), y
				and Sprite_MaskTable, x
				ora (BLIT_LOOKUP), y
				sta (CHAR_DATA_LEFT), y

				iny
				cpy #$18
				bne !-


				//BOTTOM RIGHT
				lda SCREEN_X
				clc
				adc #$29
				tay
				lda (SCREEN_ROW), y
				jsr GetFontLookup
				
				//Instead of advancing through the target data
				//we keep the y register advancing sequentially and 
				//instead offset the original data
				sec
				lda ORIGINAL_DATA
				sbc #$18
				sta ORIGINAL_DATA
				lda ORIGINAL_DATA + 1
				sbc #$00
				sta ORIGINAL_DATA + 1

				ldy #$18
			!:
				lda (BLIT_LOOKUP), y
				tax
				lda (ORIGINAL_DATA), y
				and Sprite_MaskTable, x
				ora (BLIT_LOOKUP), y
				sta (CHAR_DATA_LEFT), y

				iny
				cpy #$20
				bne !-




				//Restore x iterator
				ldx TEMP
				jsr DrawSprites
		!Skip:
			inx
			cpx #MAX_SPRITES
			beq !+
			jmp !Loop-
		!:
			rts			
	}


	DrawSprites: {
			.label SCREEN_ROW = VECTOR4
			.label SCREEN_X = TEMP5
			.label TEMP = TEMP6
				
				//0,0
				clc
				lda SpriteData_CharStart, x
				ldy SCREEN_X
				sta (SCREEN_ROW), y

				//1,0
				adc #$02
				iny
				sta (SCREEN_ROW), y

				//0,1
				sec
				sbc #$01
				sta TEMP
				tya 
				clc
				adc #$27
				tay
				lda TEMP
				sta (SCREEN_ROW), y

				//1,1
				clc
				adc #$02
				iny
				sta (SCREEN_ROW), y

			rts		
	}




	ClearSprites: {
			.label SCREEN_X = TEMP1
			.label TEMP = TEMP2
			.label SCREEN_ROW = VECTOR1
			.label BUFFER = VECTOR2

			ldx #$00
		!:
			lda SpriteData_ID, x
			beq !Skip+

				lda SpriteData_X_MSB, x
				lsr
				lda SpriteData_X_LSB, x
				ror
				lsr
				lsr
				sta SCREEN_X

				lda SpriteData_Y, x
				lsr
				lsr
				lsr
				tay 
				lda TABLES.ScreenRowLSB, y
				sta SCREEN_ROW
				lda TABLES.ScreenRowMSB, y
				sta SCREEN_ROW + 1
				lda TABLES.BufferLSB, y
				sta BUFFER
				lda TABLES.BufferMSB, y
				sta BUFFER + 1


				//0,0
				ldy SCREEN_X
				lda (BUFFER), y
				sta (SCREEN_ROW), y

				//1,0
				iny
				lda (BUFFER), y
				sta (SCREEN_ROW), y

				//0,1
				tya 
				clc
				adc #$27
				tay
				lda (BUFFER), y
				sta (SCREEN_ROW), y

				//1,1
				iny
				lda (BUFFER), y
				sta (SCREEN_ROW), y


		!Skip:
			inx
			cpx #MAX_SPRITES
			bne !-

			rts	
	}


	CreateMaskTable: {
		    ldx #$00
		Loop:
		    txa
		    and #%10101010
		    sta TEMP1

		    lsr
		    ora TEMP1    
		    sta TEMP1

		    txa 
		    and #%01010101
		    sta TEMP2
		    asl
		    ora TEMP2
		    ora TEMP1

		    eor #$ff

		    sta Sprite_MaskTable, x
		    inx    
		    bne Loop

		    rts
	}

	GetFontLookup: {
			ldy #$00
			sty TEMP6
			asl
			rol TEMP6
			asl
			rol TEMP6
			asl
			rol TEMP6
			sta VECTOR5
			lda TEMP6
			adc #>CHAR_SET
			sta VECTOR5 + 1
			rts
	}


	BLIT_DATA_LSB:
		.byte <BLIT_TABLE_START
	BLIT_DATA_MSB:
		.byte >BLIT_TABLE_START

	CreateSpriteBlitTable: {
			.label OFFSET_X = TEMP1
			.label OFFSET_Y = TEMP2
			.label SHIFT_TEMP = TEMP3

			.label BLIT_DATA = VECTOR1
			.label BLIT_DATA_RIGHT = VECTOR2
			.label FONT_DATA_LOOKUP = VECTOR5

			jsr GetFontLookup //Get the font data lookup into VECTOR5

			//Set the font lookup
			lda FONT_DATA_LOOKUP
			sta SelfModLookup + 1
			lda FONT_DATA_LOOKUP + 1
			sta SelfModLookup + 2

			//Set the startlookup for BlitLookup_LSB/MSB tables
			ldx BlitLookupCount
			lda BLIT_DATA_LSB
			sta BlitLookup_LSB, x 
			lda BLIT_DATA_MSB
			sta BlitLookup_MSB, x
			inx
			stx BlitLookupCount


			//Reset the offsets
			lda #$00
			sta OFFSET_X
			sta OFFSET_Y


		!FullLoop:
			//Set the blitdata position
			lda BLIT_DATA_LSB
			sta BLIT_DATA 
			lda BLIT_DATA_MSB
			sta BLIT_DATA + 1


			lda BLIT_DATA_LSB
			clc
			adc #$10
			sta BLIT_DATA_RIGHT
			lda BLIT_DATA_MSB
			adc #$00
			sta BLIT_DATA_RIGHT + 1


			//Do vertical shift first
			ldy #$00
			ldx #$00
		!:
			lda #$00
			cpy OFFSET_Y
			bcc !NoDataYet+
			cpx #$08
			bcs !NoDataYet+
		SelfModLookup:
			lda $BEEF, x
			inx

		!NoDataYet:
			sta (BLIT_DATA), y
			iny
			cpy #16
			bne !-


			//Shift horizontally now
			ldy #$00
		!:	
			lda #$00
			sta SHIFT_TEMP
			lda (BLIT_DATA), y
			ldx OFFSET_X
			beq !EndLoop+
		!InnerLoop:
			lsr
			ror SHIFT_TEMP
			dex
			bne !InnerLoop-
		!EndLoop:
			sta (BLIT_DATA), y
			lda SHIFT_TEMP
			sta (BLIT_DATA_RIGHT), y
			
			iny
			cpy #16
			bne !-


			//Update the offsets top to bottom, Left to right , 32 total (1024 byte blit table)

			ldy OFFSET_Y
			iny
			cpy #$08
			bne !+
			ldy #$00
			ldx OFFSET_X
			inx
			inx
			cpx #$08
			beq !Exit+
			stx OFFSET_X
		!:
			sty OFFSET_Y
			



			//Increase Table offset by 32 bytes
			clc
			lda BLIT_DATA_LSB
			adc #$20
			sta BLIT_DATA_LSB
			lda BLIT_DATA_MSB
			adc #$00
			sta BLIT_DATA_MSB

			//Repeat
			jmp !FullLoop-

		!Exit:
			rts
	}
}


