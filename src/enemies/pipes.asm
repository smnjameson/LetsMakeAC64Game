PIPES: {
	.label MAX_ENEMIES_ON_SCREEN = $05
	.label PIPE_UPDATE_TIME = $20

	SpawnDelayTimer:
		.byte $00
	PipesActive:	//Bulge will extend to pipe length + 1
		//		|	|	/\ 	{} 	\/
		//		/\ 	{} 	\/ 	|	|
		.byte $00,$00,$00,$00,$00
	PipeEnemyType:
		.byte $00,$00,$00,$00,$00

	MAPDATA_COPY: {	
		PipeSpawnX:
			.byte $2c, $94, $1c, $64, $84
		PipeSpawnY:
			.byte $52, $62, $a2, $b2, $92
		PipeStartX:
			.byte $08, $22, $04, $16, $1e
		PipeStartY:
			.byte $00, $00, $13, $13, $13
		PipeLengthAndDirection:	//Upper nibble = 1 if pipes goes down
			.byte $14, $16, $04, $02, $06

		DoorSpawnLoc:
			.byte $16,$02
		SwitchSpawnLoc:
			.byte $20,$04
	}
	__MAPDATA_COPY:
		NumberOfEnemies:
			.byte $00 //Autofilled by initialise function

	NextEnemyIndex:
		.byte $00

	Initialise: {
			lda #$00
			sta NextEnemyIndex
			ldx #$04
		!:
			sta PipesActive, x
			dex
			bpl !-


		//Initialise selfmods based on current level
			lda PLAYER.CurrentLevel
			asl
			tax 
			lda MAPDATA.MAP_POINTERS, x
			clc
			adc #<MAPDATA.EnemyListData
			sta Update.EnemyList + 1
			sta SpawnEnemyFromPipe.EnemyList + 1
			inx
			lda MAPDATA.MAP_POINTERS, x
			adc #>MAPDATA.EnemyListData
			sta Update.EnemyList + 2
			sta SpawnEnemyFromPipe.EnemyList + 2

			lda PLAYER.CurrentLevel
			asl
			tax 
			lda MAPDATA.MAP_POINTERS, x
			clc
			adc #<MAPDATA.PipeSpawnData
			sta SelfMod + 1
			inx
			lda MAPDATA.MAP_POINTERS, x
			adc #>MAPDATA.PipeSpawnData
			sta SelfMod + 2

			//Copy map data for easy access
			ldx #$00
		!Loop:
		SelfMod:
			lda $BEEF, x
			sta MAPDATA_COPY, x
			inx
			cpx #[__MAPDATA_COPY - MAPDATA_COPY + 1]
			bne !Loop-

			rts
	}

	Update: {
			//Check the spawn timer
			lda SpawnDelayTimer
			bne !SpawnCheckComplete+

			lda #PIPE_UPDATE_TIME
			sta SpawnDelayTimer
			jsr UpdatePipeBulges


			//Check if there are less than 5 enemies
			ldx ENEMIES.EnemyTotalCount
			ldy #$04 //Pipe to cxheck next
		!Loop:
			lda PipesActive, y
			beq !+
			inx
		!:
			dey 
			bpl !Loop-
			txa
			cmp #MAX_ENEMIES_ON_SCREEN

			bcs !SpawnCheckComplete+

			

			//If so check there are enemies left to spawn
			ldx NextEnemyIndex

		EnemyList:
			lda $BEEF, x 	//MAP_DATA EnemyList
			beq !SpawnCheckComplete+



			//Do we have an inactive pipe?
			ldx #$04
		!:
			lda PipesActive, x
			beq !FoundInactivePipe+
			dex
			bpl !-
			jmp !SpawnCheckComplete+


		!FoundInactivePipe:
			//If so spawn at a random inactive pipe
		!:
			jsr Random
			and #$07
			cmp #$05
			bcs !-
			tax 
			lda PipesActive, x
			bne !-

			inc PipesActive, x

			lda NextEnemyIndex
			sta PipeEnemyType, x
			inc NextEnemyIndex

		!SpawnCheckComplete:

			dec SpawnDelayTimer
			rts
	}


	UpdatePipeBulges: {
			// inc $d020
			ldx #$04
		!Loop:
			//Is there an active pipe?
			lda PipesActive, x
			beq !Skip+

			//Has the bulge reached the end
			lda MAPDATA_COPY.PipeLengthAndDirection, x
			and #$0f
			clc
			adc #$01	//At end when bulges is at length + 2
			cmp PipesActive, x
			bcs !DrawBulge+

			//If so clear bulge, spawn an enemy and exit
			jsr ClearBulge
			lda #$00
			sta PipesActive, x
			jsr SpawnEnemyFromPipe

			jmp !Skip+

			//Otherwise Draw the bulge
		!DrawBulge:
			jsr DrawBulge

			//Advance the "bulge" along the pipe
			inc PipesActive, x
		!Skip:
			dex
			bpl !Loop-
			// dec $d020
			rts
	}

	ClearBulge: {
			ldy MAPDATA_COPY.PipeStartY, x
			lda TABLES.ScreenRowLSB, y
			sta PIPE_DRAW + 0
			lda TABLES.ScreenRowMSB, y
			sta PIPE_DRAW + 1

			lda MAPDATA_COPY.PipeLengthAndDirection, x
			and #$f0
			sta PIPE_DIR
			lda MAPDATA_COPY.PipeLengthAndDirection, x			
			and #$0f
			sta PIPE_TEMP

			clc
		!Loop:
			ldy MAPDATA_COPY.PipeStartX, x
			lda #$25
			sta (PIPE_DRAW), y
			iny
			lda #$26
			sta (PIPE_DRAW), y
			lda PIPE_DIR
			beq !Up+
		!Down:
			lda PIPE_DRAW + 0
			adc #$28
			sta PIPE_DRAW + 0
			lda PIPE_DRAW + 1
			adc #$00
			sta PIPE_DRAW + 1
			jmp !+
		!Up:
			sec
			lda PIPE_DRAW + 0
			sbc #$28
			sta PIPE_DRAW + 0
			lda PIPE_DRAW + 1
			sbc #$00
			sta PIPE_DRAW + 1
			clc
		!:
			dec PIPE_TEMP
			bne !Loop-
			rts
	}

	DrawBulge: {
			jsr ClearBulge

			ldy MAPDATA_COPY.PipeStartY, x
			lda TABLES.ScreenRowLSB, y
			sta PIPE_DRAW + 0
			lda TABLES.ScreenRowMSB, y
			sta PIPE_DRAW + 1

			lda MAPDATA_COPY.PipeLengthAndDirection, x
			and #$f0
			sta PIPE_DIR
			lda MAPDATA_COPY.PipeLengthAndDirection, x			
			and #$0f
			sta PIPE_TEMP
			clc
			adc #$01
			sta PIPE_LENGTH

// |		1  6	//PIPE_LENGTH - PIPE_TEMP
// |		2  5	

// |		3  4
// |		4  3

// |  /\ 	5  2	2
// |  \/   	6  1 	2

			lda PIPE_DIR
			bne !Down+
		!Up:	
			ldy #$59
			sty PIPE_CHARS + 0
			iny
			sty PIPE_CHARS + 1
			iny
			sty PIPE_CHARS + 2
			iny
			sty PIPE_CHARS + 3
			jmp !DoneSetChars+

		!Down:
			ldy #$59
			sty PIPE_CHARS + 2
			iny
			sty PIPE_CHARS + 3
			iny
			sty PIPE_CHARS + 0
			iny
			sty PIPE_CHARS + 1

		!DoneSetChars:

		!Loop:
			lda PIPE_LENGTH
			sec
			sbc PIPE_TEMP
			cmp PipesActive, x
			bne !NotTop+
		!Top:
			ldy MAPDATA_COPY.PipeStartX, x
			lda PIPE_CHARS + 0
			sta (PIPE_DRAW), y
			iny
			lda PIPE_CHARS + 1
			sta (PIPE_DRAW), y
			jmp !DoneRow+
		
		!NotTop:
			clc
			adc #$01
			cmp PipesActive, x
			bne !NotBottom+
		!Bottom:
			ldy MAPDATA_COPY.PipeStartX, x
			lda PIPE_CHARS + 2
			sta (PIPE_DRAW), y
			iny
			lda PIPE_CHARS + 3
			sta (PIPE_DRAW), y
			jmp !DoneRow+
		!NotBottom:

		!DoneRow:
			clc
			lda PIPE_DIR
			beq !Up+
		!Down:
			lda PIPE_DRAW + 0
			adc #$28
			sta PIPE_DRAW + 0
			lda PIPE_DRAW + 1
			adc #$00
			sta PIPE_DRAW + 1
			jmp !+
		!Up:
			sec
			lda PIPE_DRAW + 0
			sbc #$28
			sta PIPE_DRAW + 0
			lda PIPE_DRAW + 1
			sbc #$00
			sta PIPE_DRAW + 1
		!:
			dec PIPE_TEMP
			bne !Loop-

			rts
	}

	SpawnEnemyFromPipe: {
			txa 
			pha

			//Now we have a pipe to spawn at (X)
			//Get enemy type
			
			ldy PipeEnemyType, x
		EnemyList:
			lda $BEEF, y //MAP_DATA EnemyList
			pha
			//Get Pipe X and Y
			lda MAPDATA_COPY.PipeSpawnY, x
			tay
			lda MAPDATA_COPY.PipeSpawnX, x
			tax
			pla

			jsr ENEMIES.SpawnEnemy

			pla
			tax
			rts
	}
}