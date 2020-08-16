SOFTSPRITES: {
	.label MAX_UNIQUE_CHARS = 4			//Maximum number of unique char IDs 
	.label MAX_SPRITES_PER_FRAME = 4	//Maximum number of sprites to update per frame
	//.label MAX_SPRITES //DEFINED in ZERO PAGE file

	.label SPRITE_FONT_START = 187
	.label SPRITE_FONT_DATA_START = CHAR_SET + SPRITE_FONT_START * 8
	.label BLIT_TABLE_START = $b000

.align $100
	CurrentSpriteIndex:
		.byte $00
	SpriteData_ID: //180 = Player Projectile
		.fill MAX_SPRITES, $00
	SpriteColor:
		.fill MAX_SPRITES, $00

	SpriteData_CLEAR_LSB:
		.fill MAX_SPRITES, $00
	SpriteData_CLEAR_MSB:
		.fill MAX_SPRITES, $00

	SpriteData_TARGET_X_MSB:  
		.fill MAX_SPRITES, $00
	SpriteData_TARGET_X_LSB:  
		.fill MAX_SPRITES, $00
	SpriteData_TARGET_Y:  
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

	Times16:
		.fill 8, i*16

	Initialise: {
			ldx #$00
			lda #$00
			sta CurrentSpriteIndex
		!:
			sta SpriteData_ID, x
			sta SpriteData_X_MSB, x
			sta SpriteData_X_LSB, x
			sta SpriteData_CLEAR_MSB, x
			sta SpriteData_CLEAR_LSB, x
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
			sta SpriteData_TARGET_Y, x
			lda TEMP1
			sta SpriteData_X_LSB, x
			sta SpriteData_TARGET_X_LSB, x
			lda #$00
			rol
			sta SpriteData_X_MSB, x
			sta SpriteData_TARGET_X_MSB, x

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



	
	SpriteUpdateIndex:
		.byte $00
		
	UpdateSprites: {
			.label SCREEN_X = TEMP5
			.label UPDATE_COUNTER = TEMP6
			.label UPDATE_INDEX = TEMP7

			.label SCREEN_ROW = VECTOR4
			.label COLOR_ROW = VECTOR6



			lda #MAX_SPRITES_PER_FRAME		//Max to update per frame
			sta UPDATE_COUNTER
			ldx SpriteUpdateIndex
			stx UPDATE_INDEX


		!Loop:

				//PRE CLEAR SCREEN BUFFER
				lda SpriteData_CLEAR_MSB, x
				beq !+
				jsr ClearSprite
				lda SpriteData_ID, x
				bne !+
				lda #$00
				sta SpriteData_CLEAR_MSB, x
				jmp !Skip+
			!:
				lda SpriteData_ID, x
				bne !+
				jmp !Skip+
			!:


				//Only update on alternate frames
				lda UPDATE_COUNTER
				bne !+
				jmp !NoApplyUpdate+
			!:
			
				//Apply new target locations
				lda SpriteData_TARGET_X_LSB, x
				sta SpriteData_X_LSB, x
				lda SpriteData_TARGET_X_MSB, x
				sta SpriteData_X_MSB, x
				lda SpriteData_TARGET_Y, x
				sta SpriteData_Y, x
			!NoApplyUpdate:


				lda SpriteData_X_LSB, x
				and #$07
				sta BLIT_LOOKUP + 2	//OFFSET X

				lda SpriteData_Y, x
				and #$07
				sta BLIT_LOOKUP + 1 //OFFSET Y

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
				clc
				adc SCREEN_X
				sta SCREEN_ROW
				sta COLOR_ROW

				lda TABLES.ScreenRowMSB, y
				adc #$00
				sta SCREEN_ROW + 1
				adc #>[VIC.COLOR_RAM-SCREEN_RAM]
				sta COLOR_ROW + 1


				//Only update a few per frame
				lda UPDATE_COUNTER
				bne !+
				jmp !OnlyDraw+
			!:

				//Get target location for font data in current charset
				lda SpriteData_CharStart_LSB, x
				sta CHAR_DATA_LEFT + 1
				lda SpriteData_CharStart_MSB, x
				sta CHAR_DATA_LEFT + 2


				//Set blity lookup from generated offsets earlier
				lda SpriteData_ID, x
				tay
				dey

				lda BLIT_LOOKUP + 1	
				asl
				asl
				asl
				asl
				asl
				clc
				adc BlitLookup_LSB,y
				sta BLIT_LOOKUP + 1	

				lda BLIT_LOOKUP + 2
				lsr
				clc
				adc BlitLookup_MSB,y
				sta BLIT_LOOKUP + 2


				//Draw to char, Using self mod lookups and targets
				ldy #$1f
			!:
			BLIT_LOOKUP:
				lda $BEEF, y
			CHAR_DATA_LEFT:
				sta $BEEF, y
				dey
				bpl !-

				dec UPDATE_COUNTER


		!OnlyDraw:	
			jsr DrawSprites
			
		!Skip:

			lda UPDATE_INDEX //4
			clc //2
			adc #$01 //2
			and #[MAX_SPRITES - 1] //2
			sta UPDATE_INDEX //4

			cmp SpriteUpdateIndex //When we are back to the index we started at we've done all sprites
			beq !+
			tax //2
			jmp !Loop-


		!:
			//Make sure next sprite index is the first sprite that was not updated
			lda SpriteUpdateIndex
			clc
			adc #MAX_SPRITES_PER_FRAME //max per frame
			sec
			sbc UPDATE_COUNTER
			cmp #MAX_SPRITES
			bcc !NoWrap+
			sec
			sbc #MAX_SPRITES
		!NoWrap:
			sta SpriteUpdateIndex

			rts			
	}



	DrawSprites: {
			.label SCREEN_ROW = VECTOR4
			.label COLOR_ROW = VECTOR6
			.label TEMP = TEMP8

				lda VECTOR4
				sta SpriteData_CLEAR_LSB, x
				lda VECTOR4 + 1
				sta SpriteData_CLEAR_MSB, x

				//0,0
				stx TEMP
				clc
				ldy #$00
				lda (SCREEN_ROW), y
				tax
				lda CHAR_COLORS, x
				ldx TEMP
				and #UTILS.COLLISION_COLORABLE
				bne !+

				lda SpriteData_CharStart, x
				sta (SCREEN_ROW), y
				lda SpriteColor, x
				sta (COLOR_ROW), y
			!:


				//1,0
				stx TEMP
				clc
				ldy #$01
				lda (SCREEN_ROW), y
				tax
				lda CHAR_COLORS, x
				ldx TEMP
				and #UTILS.COLLISION_COLORABLE
				bne !+

				lda SpriteData_CharStart, x
				adc #$02
				sta (SCREEN_ROW), y
				lda SpriteColor, x
				sta (COLOR_ROW), y
 			!:

				//0,1
				stx TEMP
				clc
				ldy #$28
				lda (SCREEN_ROW), y
				tax
				lda CHAR_COLORS, x
				ldx TEMP
				and #UTILS.COLLISION_COLORABLE
				bne !+				

				lda SpriteData_CharStart, x
				adc #$01
				ldy #$28
				sta (SCREEN_ROW), y
				lda SpriteColor, x
				sta (COLOR_ROW), y
			!:

				//1,1
				stx TEMP
				clc
				ldy #$29
				lda (SCREEN_ROW), y
				tax
				lda CHAR_COLORS, x
				ldx TEMP
				and #UTILS.COLLISION_COLORABLE
				bne !+	

				lda SpriteData_CharStart, x
				adc #$03
				ldy #$29
				sta (SCREEN_ROW), y
				lda SpriteColor, x
				sta (COLOR_ROW), y
			!:

			rts		
	}



	ColorableByte:
			.byte UTILS.COLLISION_COLORABLE

	ClearSprite: {
			.label SCREEN_ROW = VECTOR1
			.label BUFFER = VECTOR2

				lda SpriteData_CLEAR_MSB, x
				ora SpriteData_CLEAR_LSB, x
				bne !+
				rts
			!:
				/*
					 OPtimisation is to not restore color
					 however this recudes the variance in BG graphics
					 BUT it does allow the floor effects to work with 
					 less cycle usage 
				*/
				// $c2f0
				// $01f0
				lda SpriteData_CLEAR_MSB, x
				sta SCREEN_ROW + 1
				sec
				sbc #>[SCREEN_RAM- MAPLOADER.BUFFER]
				sta BUFFER + 1
				lda SCREEN_ROW + 1
				clc
				adc #[$d8 - [>SCREEN_RAM]]
				sta COLOR_RESTORE + 1  


				lda SpriteData_CLEAR_LSB, x
				sta SCREEN_ROW + 0
				sta BUFFER + 0 
				sta COLOR_RESTORE + 0

			
				stx restoreX + 1

				//0,0
				ldy #$00
				lda (BUFFER), y
				sta (SCREEN_ROW), y
				tax 
				lda CHAR_COLORS, x
				bit ColorableByte
				bne !+
				sta (COLOR_RESTORE), y
			!:

				//1,0
				ldy #$01
				lda (BUFFER), y
				sta (SCREEN_ROW), y
				tax 
				lda CHAR_COLORS, x
				bit ColorableByte
				bne !+				
				sta (COLOR_RESTORE), y
			!:

				//0,1
				ldy #$28
				lda (BUFFER), y
				sta (SCREEN_ROW), y
				tax 
				lda CHAR_COLORS, x
				bit ColorableByte
				bne !+				
				sta (COLOR_RESTORE), y
			!:

				//1,1
				ldy #$29
				lda (BUFFER), y
				sta (SCREEN_ROW), y
				tax 
				lda CHAR_COLORS, x
				bit ColorableByte
				bne !+
				sta (COLOR_RESTORE), y
			!:
			
			restoreX:
				ldx #$BEEF 
			rts	
	}


	GetFontLookup: {
			//Acc = character to get
			clc
			adc #$03
			ldy #$00
			sty TEMP8
			asl
			rol TEMP8
			asl
			rol TEMP8
			asl
			rol TEMP8
			sec
			sbc #$18
			sta VECTOR5
			lda TEMP8
			sbc #$00
			clc
			adc #>CHAR_SET
			sta VECTOR5 + 1
			rts
	}

	BLIT_DATA_LSB:
		.byte <BLIT_TABLE_START
	BLIT_DATA_MSB:
		.byte >BLIT_TABLE_START

	/*
		Creates a blitting table upfron for a given projectile
		takes a Character ID in accumulator
	*/
	CreateSpriteBlitTable: {
			.label OFFSET_X = TEMP1
			.label OFFSET_Y = TEMP2
			.label SHIFT_TEMP = TEMP3
			.label FRAME_COUNT = TEMP4
			.label CURR_CHAR = TEMP5
			.label CURR_FRAME = TEMP6

			.label BLIT_DATA = VECTOR1
			.label BLIT_DATA_RIGHT = VECTOR2

			.label FONT_DATA_LOOKUP = VECTOR5

			stx FRAME_COUNT
			sta CURR_CHAR
			lda #$00
			sta CURR_FRAME

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
			lda CURR_CHAR
			clc
			adc CURR_FRAME
			jsr GetFontLookup //Get the font data lookup into VECTOR5

			//Set the font lookup
			lda FONT_DATA_LOOKUP
			sta SelfModLookup + 1
			lda FONT_DATA_LOOKUP + 1
			sta SelfModLookup + 2


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
			lsr
			ror SHIFT_TEMP
			dex
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
			cpy #$08 //ROWS
			bne !Skip+
			
			//Update frame animation
			ldy CURR_FRAME
			iny
			cpy FRAME_COUNT	
			bne !+
			ldy #$00
		!:
			sty CURR_FRAME


			ldy #$00
			ldx OFFSET_X
			inx
			inx
			cpx #$08 //COLUMNS
			beq !Exit+
			stx OFFSET_X
		!Skip:
			sty OFFSET_Y
			

			//Increase Table offset by 32 bytes
			clc
			lda BLIT_DATA_LSB
			adc #$20
			sta BLIT_DATA_LSB
			lda BLIT_DATA_MSB
			adc #$00
			sta BLIT_DATA_MSB


			jmp !FullLoop-

		!Exit:
			rts
	}
}
