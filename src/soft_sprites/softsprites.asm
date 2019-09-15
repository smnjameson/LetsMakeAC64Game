SOFTSPRITES: {
	.label MAX_UNIQUE_CHARS = 4			//Maximum number of unique char IDs 
	.label MAX_SPRITES_PER_FRAME = 4	//Maximum number of sprites to update per frame
	//.label MAX_SPRITES //DEFINED in ZERO PAGE file

	.label SPRITE_FONT_START = 187
	.label SPRITE_FONT_DATA_START = CHAR_SET + SPRITE_FONT_START * 8
	.label BLIT_TABLE_START = $b000

.align $100
	Sprite_MaskTable:
		.fill 256, 00
	Sprite_MaskTable_Inverted:
		.fill 256, 00

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
			.label OFFSET_X = TEMP1
			.label OFFSET_Y = TEMP2
			.label TEMP = TEMP3
			.label TEMP_OFFSET = TEMP4
			.label SCREEN_X = TEMP5
			.label UPDATE_COUNTER = TEMP6
			.label UPDATE_INDEX = TEMP7

			.label CHAR_DATA_LEFT = VECTOR1
			.label BLIT_LOOKUP = VECTOR2
			.label CHAR_DATA_RIGHT = VECTOR3
			.label SCREEN_ROW = VECTOR4
			.label ORIGINAL_DATA = VECTOR5
			.label COLOR_ROW = VECTOR6


			//PRE CLEAR SCREEN BUFFER
			ldx #$00
		!Loop:
			jsr ClearSprite
		!:
			inx
			cpx #MAX_SPRITES
			bne !Loop-



			lda #MAX_SPRITES_PER_FRAME		//Max to update per frame
			sta UPDATE_COUNTER
			ldx SpriteUpdateIndex
			stx UPDATE_INDEX


			// ldx #$00
		!Loop:
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
				sta CHAR_DATA_LEFT
				lda SpriteData_CharStart_MSB, x
				sta CHAR_DATA_LEFT + 1




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




				// TOP LEFT ////////////////////////
				ldy #$00
				lda (SCREEN_ROW), y
				jsr GetFontLookup

				ldy #$00
			!SIMPLE_BLIT_01:
				cpy OFFSET_Y
				bcs !FULL_BLIT_01+
				lda (ORIGINAL_DATA), y	
				sta (CHAR_DATA_LEFT), y
				iny
				bcc !SIMPLE_BLIT_01-

			!FULL_BLIT_01:
				lax (BLIT_LOOKUP), y //4

				lda (ORIGINAL_DATA), y			   
				and Sprite_MaskTable, x            
				ora Sprite_MaskTable_Inverted, x

				sta (CHAR_DATA_LEFT), y
				iny
				cpy #$08
				bne !FULL_BLIT_01-
				////////////////////////////////////




				//BOTTOM LEFT ////////////////////////
				ldy #$28
				lda (SCREEN_ROW), y
				sec
				sbc #$01
				jsr GetFontLookup
				
				clc
				lda OFFSET_Y
				adc #$08
				sta TEMP_OFFSET

				ldy #$08
				cpy TEMP_OFFSET
				bcs !SIMPLE_BLIT_02+				
			!FULL_BLIT_02:
				lax (BLIT_LOOKUP), y
				lda (ORIGINAL_DATA), y			   
				and Sprite_MaskTable, x            
				ora Sprite_MaskTable_Inverted, x

				sta (CHAR_DATA_LEFT), y
				iny
				cpy TEMP_OFFSET
				bcc !FULL_BLIT_02-

			!SIMPLE_BLIT_02:	
				lda (ORIGINAL_DATA), y	
				sta (CHAR_DATA_LEFT), y
				iny
				cpy #$10
				bne !SIMPLE_BLIT_02-
				////////////////////////////////////


				//TOP RIGHT ////////////////////////////////////
				ldy #$01
				lda (SCREEN_ROW), y
				sec
				sbc #$02
				jsr GetFontLookup
				
				clc
				lda OFFSET_Y
				adc #$10
				sta TEMP_OFFSET

				ldy #$10
			!SIMPLE_BLIT_03:
				cpy TEMP_OFFSET
				bcs !FULL_BLIT_03+
				lda (ORIGINAL_DATA), y	
				sta (CHAR_DATA_LEFT), y
				iny
				bcc !SIMPLE_BLIT_03-
			!FULL_BLIT_03:
				lax (BLIT_LOOKUP), y        
				lda (ORIGINAL_DATA), y	
				and Sprite_MaskTable, x           
				ora Sprite_MaskTable_Inverted, x

				sta (CHAR_DATA_LEFT), y
				iny
				cpy #$18
				bne !FULL_BLIT_03-
				////////////////////////////////////



				//BOTTOM RIGHT ////////////////////////////////////
				ldy #$29
				lda (SCREEN_ROW), y
				sec
				sbc #$03
				jsr GetFontLookup
				
				clc
				lda OFFSET_Y
				adc #$18
				sta TEMP_OFFSET				

				ldy #$18
				cpy TEMP_OFFSET
				bcs !SIMPLE_BLIT_04+					
			!FULL_BLIT_04:
				lax (BLIT_LOOKUP), y
				lda (ORIGINAL_DATA), y			   
				and Sprite_MaskTable, x            
				ora Sprite_MaskTable_Inverted, x
									   
				sta (CHAR_DATA_LEFT), y
				iny
				cpy TEMP_OFFSET
				bcc !FULL_BLIT_04-

			!SIMPLE_BLIT_04:	
				lda (ORIGINAL_DATA), y	
				sta (CHAR_DATA_LEFT), y
				iny
				cpy #$20
				bne !SIMPLE_BLIT_04-
				////////////////////////////////////

			
				dec UPDATE_COUNTER

				//Restore x iterator
				ldx TEMP
		!OnlyDraw:				
				jsr DrawSprites

		!Skip:
			lda UPDATE_INDEX
			clc
			adc #$01
			cmp #MAX_SPRITES
			bcc !NoWrap+
			sec
			sbc #MAX_SPRITES
		!NoWrap:
			sta UPDATE_INDEX
			tax
			cmp SpriteUpdateIndex //When we are back to the index we started at we've done all sprites
			beq !+
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
				
				lda VECTOR4
				sta SpriteData_CLEAR_LSB, x
				lda VECTOR4 + 1
				sta SpriteData_CLEAR_MSB, x

				//0,0
				clc
				lda SpriteData_CharStart, x
				ldy #$00
				sta (SCREEN_ROW), y
				lda SpriteColor, x
				sta (COLOR_ROW), y

				//1,0
				lda SpriteData_CharStart, x
				adc #$02
				ldy #$01
				sta (SCREEN_ROW), y
				lda SpriteColor, x
				sta (COLOR_ROW), y

				//0,1
				lda SpriteData_CharStart, x
				adc #$01
				ldy #$28
				sta (SCREEN_ROW), y
				lda SpriteColor, x
				sta (COLOR_ROW), y

				//1,1
				lda SpriteData_CharStart, x
				adc #$03
				ldy #$29
				sta (SCREEN_ROW), y
				lda SpriteColor, x
				sta (COLOR_ROW), y


			rts		
	}




	ClearSprite: {
			.label TEMP = TEMP2
			.label SCREEN_ROW = VECTOR1
			.label BUFFER = VECTOR2
			.label COLOR_ROW= VECTOR3

				stx TEMP

				lda SpriteData_CLEAR_MSB, x
				bne !+
				rts
			!:
				sta SCREEN_ROW + 1
				clc
				adc #>[VIC.COLOR_RAM - SCREEN_RAM]
				sta COLOR_ROW + 1	
				sec
				sbc #>[VIC.COLOR_RAM - MAPLOADER.BUFFER]
				sta BUFFER + 1

				lda SpriteData_CLEAR_LSB, x
				sta SCREEN_ROW
				sta COLOR_ROW
				sta BUFFER

				//0,0
				ldy #$00
				lax (BUFFER), y
				sta (SCREEN_ROW), y
				lda CHAR_COLORS, x
				sta (COLOR_ROW), y

				//1,0
				ldy #$01
				lax (BUFFER), y
				sta (SCREEN_ROW), y
				lda CHAR_COLORS, x
				sta (COLOR_ROW), y

				//0,1
				ldy #$28
				lax (BUFFER), y
				sta (SCREEN_ROW), y
				lda CHAR_COLORS, x
				sta (COLOR_ROW), y

				//1,1
				ldy #$29
				lax (BUFFER), y
				sta (SCREEN_ROW), y
				lda CHAR_COLORS, x
				sta (COLOR_ROW), y

				ldx TEMP
			rts	
	}






	CreateMaskTable: {
		    ldx #$00
		Loop:
		    lda TABLES.ColorSwapTable, x
		    and #%10101010
		    sta TEMP1

		    lsr
		    ora TEMP1    
		    sta TEMP1

		    lda TABLES.ColorSwapTable, x
		    and #%01010101
		    sta TEMP2
		    asl
		    ora TEMP2
		    ora TEMP1


		    eor #$ff
		    sta Sprite_MaskTable, x

		    eor #$ff
		    sta TEMP2
		    txa
		    and TEMP2
			sta Sprite_MaskTable_Inverted, x
		    
		    inx    
		    bne Loop

		    rts
	}



	GetFontLookup: {
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
			lda #$aa
			sta SHIFT_TEMP
			lda (BLIT_DATA), y
			ldx OFFSET_X
			beq !EndLoop+
		!InnerLoop:
			lsr
			ror SHIFT_TEMP
			sec
			ror
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
