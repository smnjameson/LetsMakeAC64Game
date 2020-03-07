DOOR: {
	.label FONT_DATA = $f000
	.label DOOR_FONT_DATA = $f400

	DoorSpawned:
		.byte $00
	DoorAnimRow:
		.byte $00

	Initialise: {
			lda #$00
			sta DoorSpawned
			sta DoorAnimRow
			rts
	}

	Update: {
			//Has door spawned? If not should it?
			lda DoorSpawned
			bne !Spawned+

			//Is the bar full?
			lda PLAYER.Player1_EatCount
			clc
			adc PLAYER.Player2_EatCount 
			cmp PIPES.NumberOfEnemies
			beq !SpawnDoor+
			rts

		!SpawnDoor:
			//setup draw location
			ldy PIPES.MAPDATA_COPY.DoorSpawnLoc + 1 //Y
			lda TABLES.ScreenRowLSB, y 
			sta DOOR_VECTOR1 + 0
			sta DOOR_VECTOR2 + 0
			lda TABLES.ScreenRowMSB, y 
			sta DOOR_VECTOR1 + 1
			clc
			adc #$18	//Color from screen location
			sta DOOR_VECTOR2 + 1

			ldy PIPES.MAPDATA_COPY.DoorSpawnLoc + 0 //X
			
			//Draw four rows
			lda #$04
			sta DOOR_TEMP1
			lda #$80
			ldx #$04	
		!Loop:
			sta (DOOR_VECTOR1), y
			sta DOOR_TEMP2
			lda #$0c
			sta (DOOR_VECTOR2), y
			lda DOOR_TEMP2
			clc
			adc #$04
			iny
			dex
			bne !Loop-

			sta DOOR_TEMP2
			tya
			clc
			adc #$24
			tay 
			lda DOOR_TEMP2
			sec 
			sbc #$0f
			ldx #$04
			dec DOOR_TEMP1
			bne !Loop-

			//Clear the intial data
			lda #$00
			ldx #$7f
		!:
			sta DOOR_FONT_DATA, x
			dex
			bpl !-

			lda #$01
			sta DoorSpawned

		!Spawned:
			//It has spawned so advance the update
			
			//Do we need to shift?
			lda DoorAnimRow
			cmp #$1f
			bcc !+
			rts
		!:
			//Shift Data
			ldx #$01
		!Loop:
			lda DOOR_FONT_DATA + 0, x
			sta DOOR_FONT_DATA - 1, x
			lda DOOR_FONT_DATA + 32, x
			sta DOOR_FONT_DATA + 31, x
			lda DOOR_FONT_DATA + 64, x
			sta DOOR_FONT_DATA + 63, x
			lda DOOR_FONT_DATA + 96, x
			sta DOOR_FONT_DATA + 95, x
			inx
			cpx #$20
			bne !Loop-


			//Add next row
			ldy #$00
			clc
			ldx DoorAnimRow
			lda DoorDataLSB, x
			sta DOOR_VECTOR1 + 0
			lda DoorDataMSB, x
			sta DOOR_VECTOR1 + 1
			lda (DOOR_VECTOR1), y
			sta DOOR_FONT_DATA + 31

			jsr UpdatePos
			lda (DOOR_VECTOR1), y
			sta DOOR_FONT_DATA + 63

			jsr UpdatePos
			lda (DOOR_VECTOR1), y
			sta DOOR_FONT_DATA + 95

			jsr UpdatePos
			lda (DOOR_VECTOR1), y
			sta DOOR_FONT_DATA + 127

			inc DoorAnimRow
			rts

		UpdatePos:
			txa 
			adc #$20
			tax
			lda DoorDataLSB, x
			sta DOOR_VECTOR1 + 0
			lda DoorDataMSB, x
			sta DOOR_VECTOR1 + 1
			rts
	}

	DoorDataLSB:
		.fill 8, <[FONT_DATA + 53 * 8 + i]
		.fill 8, <[FONT_DATA + 57 * 8 + i]
		.fill 8, <[FONT_DATA + 57 * 8 + i]
		.fill 8, <[FONT_DATA + 57 * 8 + i]

		.fill 8, <[FONT_DATA + 54 * 8 + i]
		.fill 8, <[FONT_DATA + 58 * 8 + i]
		.fill 8, <[FONT_DATA + 58 * 8 + i]
		.fill 8, <[FONT_DATA + 58 * 8 + i]

		.fill 8, <[FONT_DATA + 55 * 8 + i]
		.fill 8, <[FONT_DATA + 58 * 8 + i]
		.fill 8, <[FONT_DATA + 58 * 8 + i]
		.fill 8, <[FONT_DATA + 58 * 8 + i]

		.fill 8, <[FONT_DATA + 56 * 8 + i]
		.fill 8, <[FONT_DATA + 59 * 8 + i]
		.fill 8, <[FONT_DATA + 59 * 8 + i]
		.fill 8, <[FONT_DATA + 59 * 8 + i]
	DoorDataMSB:
		.fill 8, >[FONT_DATA + 53 * 8 + i]
		.fill 8, >[FONT_DATA + 57 * 8 + i]
		.fill 8, >[FONT_DATA + 57 * 8 + i]
		.fill 8, >[FONT_DATA + 57 * 8 + i]

		.fill 8, >[FONT_DATA + 54 * 8 + i]
		.fill 8, >[FONT_DATA + 58 * 8 + i]
		.fill 8, >[FONT_DATA + 58 * 8 + i]
		.fill 8, >[FONT_DATA + 58 * 8 + i]

		.fill 8, >[FONT_DATA + 55 * 8 + i]
		.fill 8, >[FONT_DATA + 58 * 8 + i]
		.fill 8, >[FONT_DATA + 58 * 8 + i]
		.fill 8, >[FONT_DATA + 58 * 8 + i]

		.fill 8, >[FONT_DATA + 56 * 8 + i]
		.fill 8, >[FONT_DATA + 59 * 8 + i]
		.fill 8, >[FONT_DATA + 59 * 8 + i]
		.fill 8, >[FONT_DATA + 59 * 8 + i]		

}