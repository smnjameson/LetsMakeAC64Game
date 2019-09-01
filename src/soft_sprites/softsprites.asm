SOFTSPRITES: {

	.label MAX_SPRITES = 8
	.label SPRITE_FONT_START = 187
	.label SPRITE_FONT_DATA_START = CHAR_SET + SPRITE_FONT_START * 8

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
	SpriteData_Lookup_LSB:
		.fill MAX_SPRITES, $00
	SpriteData_Lookup_MSB:
		.fill MAX_SPRITES, $00

	//Constants	
	SpriteData_CharStart:
		.fill MAX_SPRITES, SPRITE_FONT_START + i * 4
	
	SpriteData_CharStart_LSB:
		.fill MAX_SPRITES, <[SPRITE_FONT_DATA_START + 32 * i]
	SpriteData_CharStart_MSB:
		.fill MAX_SPRITES, >[SPRITE_FONT_DATA_START + 32 * i]
	


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
			//Calculate font data lookup
			sta SpriteData_Lookup_LSB, x
			lda #$00
			sta SpriteData_Lookup_MSB, x
			asl SpriteData_Lookup_LSB, x
			rol SpriteData_Lookup_MSB, x
			asl SpriteData_Lookup_LSB, x
			rol SpriteData_Lookup_MSB, x
			asl SpriteData_Lookup_LSB, x
			rol SpriteData_Lookup_MSB, x
			clc
			lda #>CHAR_SET
			adc SpriteData_Lookup_MSB, x
			sta SpriteData_Lookup_MSB, x



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
			//TEMP
			cmp #168
			bcc !+
			lda #$00
		!:
			/////////////////
			sta SpriteData_Y, y


			txa
			clc
			adc SpriteData_X_LSB, y
			sta SpriteData_X_LSB, y
			lda SpriteData_X_MSB, y
			adc #$00
			sta SpriteData_X_MSB, y
			beq !+
			//TEMP
			lda SpriteData_X_LSB, y
			cmp #56
			bcc !+
			lda #$00
			sta SpriteData_X_LSB, y
			sta SpriteData_X_MSB, y
			//////////////////
		!:
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

	UpdateSprites: {
			.label OFFSET_X = TEMP1
			.label OFFSET_Y = TEMP2
			.label TEMP = TEMP3
			.label SHIFT_TEMP = TEMP4
			.label SCREEN_X = TEMP5

			.label CHAR_DATA_LEFT = VECTOR1
			.label SPRITE_LOOKUP = VECTOR2
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


				//Draw the char data in the left column
				lda SpriteData_Lookup_LSB, x
				sta SelfModLookup + 1
				lda SpriteData_Lookup_MSB, x
				sta SelfModLookup + 2

				
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
				sta (CHAR_DATA_LEFT), y
				iny
				cpy #16
				bne !-

				//Shift character horizontally
				ldy #$00
			!:	
				lda #$00
				sta SHIFT_TEMP
				lda (CHAR_DATA_LEFT), y
				ldx OFFSET_X
				beq !EndLoop+
			!InnerLoop:
				lsr
				ror SHIFT_TEMP
				dex
				bne !InnerLoop-
			!EndLoop:
				sta (CHAR_DATA_LEFT), y
				lda SHIFT_TEMP
				sta (CHAR_DATA_RIGHT), y
				
				iny
				cpy #16
				bne !-



				//TOP LEFT
				ldy SCREEN_X
				lda (SCREEN_ROW), y
				jsr GetFontLookup
				ldy #$00
			!:
				lda (CHAR_DATA_LEFT), y
				tax
				lda (ORIGINAL_DATA), y
				and Sprite_MaskTable, x
				ora (CHAR_DATA_LEFT), y
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
				
				lda CHAR_DATA_LEFT
				clc
				adc #$08
				sta CHAR_DATA_LEFT
				lda CHAR_DATA_LEFT + 1
				adc #$00
				sta CHAR_DATA_LEFT + 1

				ldy #$00
			!:
				lda (CHAR_DATA_LEFT), y
				tax
				lda (ORIGINAL_DATA), y
				and Sprite_MaskTable, x
				ora (CHAR_DATA_LEFT), y
				sta (CHAR_DATA_LEFT), y

				iny
				cpy #$08
				bne !-

				//TOP RIGHT
				ldy SCREEN_X
				iny
				lda (SCREEN_ROW), y
				jsr GetFontLookup
				
				lda CHAR_DATA_LEFT
				clc
				adc #$08
				sta CHAR_DATA_LEFT
				lda CHAR_DATA_LEFT + 1
				adc #$00
				sta CHAR_DATA_LEFT + 1

				ldy #$00
			!:
				lda (CHAR_DATA_LEFT), y
				tax
				lda (ORIGINAL_DATA), y
				and Sprite_MaskTable, x
				ora (CHAR_DATA_LEFT), y
				sta (CHAR_DATA_LEFT), y

				iny
				cpy #$08
				bne !-


				//BOTTOM RIGHT
				lda SCREEN_X
				clc
				adc #$29
				tay
				lda (SCREEN_ROW), y
				jsr GetFontLookup
				
				lda CHAR_DATA_LEFT
				clc
				adc #$08
				sta CHAR_DATA_LEFT
				lda CHAR_DATA_LEFT + 1
				adc #$00
				sta CHAR_DATA_LEFT + 1

				ldy #$00
			!:
				lda (CHAR_DATA_LEFT), y
				tax
				lda (ORIGINAL_DATA), y
				and Sprite_MaskTable, x
				ora (CHAR_DATA_LEFT), y
				sta (CHAR_DATA_LEFT), y

				iny
				cpy #$08
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
}


