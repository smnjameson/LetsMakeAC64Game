*=* "Map Loader"
  MAPLOADER: {

  	.label BUFFER = $bc00

  	DoorChars:
  		.byte $35,$36,$37,$38,$39,$3b
  	__DoorChars:
  	PipeChars:
  		.byte $1d,$1e,$1f,$20,$21,$22,$23,$24,$25,$26
  		.byte $59,$5a,$5b,$5c
  	__PipeChars:

  	LoadLevel: {
  			.label LEVEL_DATA = VECTOR1
  			.label NEXT_LEVEL_DATA = VECTOR2
  			.label TARGET_DATA = VECTOR3

  			lda PLAYER.CurrentLevel
  			asl
  			tax 
  			lda LevelLookup, x
  			sta LEVEL_DATA + 0
  			sta NEXT_LEVEL_DATA + 0
  			inx
  			lda LevelLookup, x
  			sta LEVEL_DATA + 1
  			sta NEXT_LEVEL_DATA + 1

  			lda #<MAPDATA
  			sta TARGET_DATA + 0
  			lda #>MAPDATA
  			sta TARGET_DATA + 1


  			//Copy just 1 page
  			ldx #$03
  			ldy #$00
  		!loop:
  			lda (LEVEL_DATA), y
  			sta (TARGET_DATA), y
  			iny
  			bne !loop-
  			dex 
  			beq !Exit+
  			inc LEVEL_DATA + 1
  			inc TARGET_DATA + 1
  			jmp !loop-


  		!Exit:
  			//decompress A = LSB, X = MSB
  			//Start at last byte of level
  			//eg for level 1:
  			// $8300 + (LevelLookup.LEVEL002 - LevelLookup.LEVEL001) - 1
  			// lda NEXT_LEVEL_DATA + 0
  			// sta LEVEL_DATA + 0
  			// lda NEXT_LEVEL_DATA + 1
  			// sta LEVEL_DATA + 1
  			// clc
  			// lda PLAYER.CurrentLevel
  			// adc #$01
  			// asl
  			// tax 
  			// lda LevelLookup, x
  			// sta NEXT_LEVEL_DATA + 0
  			// inx
  			// lda LevelLookup, x
  			// sta NEXT_LEVEL_DATA + 1

  			// sec 
  			// lda NEXT_LEVEL_DATA + 0
  			// sbc LEVEL_DATA + 0
  			// sta LEVEL_DATA + 0
  			// lda NEXT_LEVEL_DATA + 1
  			// sbc LEVEL_DATA + 1
  			// clc
  			// adc #$83
  			// sta LEVEL_DATA + 1


			// lda #$00
			// ldx #$83
			// // .break
			// jsr EXODECRUNCH.Start

  		
  			rts
  	}



	DrawMap: {
			jsr LoadLevel

			lda MAPDATA.MAP_1.TransparentColor
			sta $d021
			lda MAPDATA.MAP_1.MultiColor
			sta $d022	
			lda #$00
			sta $d023


			//First set door and pipe colors
			lda MAPDATA.MAP_1.PipeColor
			ldy #[__PipeChars - PipeChars - 1]
		!:
			ldx PipeChars, y
			sta CHAR_COLORS,x
			dey 
			bpl !-

			lda MAPDATA.MAP_1.DoorColor
			ldy #[__DoorChars - DoorChars - 1]
		!:
			ldx DoorChars, y
			sta CHAR_COLORS,x
			dey 
			bpl !-
			
			ldx #$0f
			lda MAPDATA.MAP_1.DoorColor
		!:
			sta CHAR_COLORS + $80,x
			dex
			bpl !-
			
			//Label the ZP temp vars for use here
			.label Row = TEMP1
			.label Col = TEMP2

			//Initialise the screen/color ram self mod code
			lda #<SCREEN_RAM //$00  
			sta Scr + 1
			// sta Color + 1

			lda #>SCREEN_RAM //$c0  
			sta Scr + 2
			// lda #>VIC.COLOR_RAM //$c0  
			// sta Color + 2


			//Initialise the map lookup self mod
			lda #<MAPDATA.MAP_1
			sta Tile + 1
			lda #>MAPDATA.MAP_1
			sta Tile + 2


			//Reset row counter
			lda	#$00
			sta Row
			
		!RowLoop:
			//Reset col counter
			lda	#$00
			sta Col			

		!ColumnLoop:
			ldy #$00

			//Reset the tilelookup self mod, only the MSB as LSB is immediately set
			lda #$00
			sta TileLookup + 2

		Tile:
			//Calculate MAP_TILES + TileNumber * 4
			lda $BEEF	
			//Times by 4				
			sta TileLookup + 1		
			asl TileLookup + 1
			rol TileLookup + 2
			asl TileLookup + 1
			rol TileLookup + 2

			//Add the MAP_TILES address
			clc
			lda #<MAP_TILES
			adc TileLookup + 1
			sta TileLookup + 1
			lda #>MAP_TILES
			adc TileLookup + 2
			sta TileLookup + 2



		TileLookup:
			lda $BEEF, y //Self modified tile data lookup
			ldx TABLES.TileScreenLocations2x2, y 
		Scr: 
			sta $BEEF, x  //Self modifidied screen ram  
			tax
			lda CHAR_COLORS, x
			ldx TABLES.TileScreenLocations2x2, y 
		// Color:
		// 	sta $BEEF, x //Self modified color ram

			iny
			cpy #$04
			bne TileLookup

			//Increment position in map data
			clc 
			lda Tile + 1
			adc #$01
			sta Tile + 1
			lda Tile + 2
			adc #$00
			sta Tile + 2

			//Increment position in screen and color ram
			clc 
			lda Scr + 1
			adc #$02
			sta Scr + 1
			// sta Color + 1
			bcc !+
			inc Scr + 2
			// inc Color + 2
		!:

			//Advance 1 column
			inc Col
			ldx Col
			cpx #20
			beq !+
			jmp !ColumnLoop-
		!:

			//Advance 1 row
			clc 
			lda Scr + 1
			adc #$28
			sta Scr + 1
			// sta Color + 1
			bcc !+
			inc Scr + 2
			// inc Color + 2
		!:
			
			inc Row
			ldx Row
			cpx #11

			beq !+
			jmp !RowLoop-
		!:
			
			jsr BufferMap

			jsr PIPES.Initialise
			rts
	}

	BufferMap: {
			ldx #$00
		!:
			lda SCREEN_RAM, x
			sta BUFFER, x
			lda SCREEN_RAM + 250, x
			sta BUFFER + 250, x
			lda SCREEN_RAM + 500, x
			sta BUFFER + 500, x
			lda SCREEN_RAM + 750, x
			sta BUFFER + 750, x
			inx
			cpx #250
			bne !-
			rts
	}
}