SOFTSPRITES: {

	.label MAX_SPRITES = 8
	.label SPRITE_FONT_START = 187
	.label SPRITE_FONT_DATA_START = CHAR_SET + SPRITE_FONT_START * 8
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
			sty TEMP1
			ldy CurrentSpriteIndex

			sta SpriteData_ID, y
			lda TEMP1
			sta SpriteData_Y, y
			txa 
			sta SpriteData_X_LSB, y
			lda #$00
			rol
			sta SpriteData_X_MSB, y

			tya

			iny
			cpy #MAX_SPRITES
			bne !+
			ldy #$00
		!:
			sty CurrentSpriteIndex
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
			.label SCREEN_ROW = VECTOR1
			.label BUFFER = VECTOR2

			ldx #$00
		!:
			lda SpriteData_ID, x
			beq !Skip+

				lda SpriteData_X_LSB, x
				and #$07
				sta OFFSET_X

				lda SpriteData_Y, x
				and #$07
				sta OFFSET_Y



		!Skip:
			inx
			cpx #MAX_SPRITES
			bne !-

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

	DrawSprites: {
			.label SCREEN_X = TEMP1
			.label TEMP = TEMP2
			.label SCREEN_ROW = VECTOR1

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


		!Skip:
			inx
			cpx #MAX_SPRITES
			bne !-

			rts		
	}
}