PIPES: {
	.label MAX_ENEMIES_ON_SCREEN = $05
	.label PIPE_UPDATE_TIME = $20

	SpawnDelayTimer:
		.byte $00
	PipesActive:	//Bulge will extend to pipe length + 1
		//		|	|	/\ 	{} 	\/
		//		/\ 	{} 	\/ 	|	|
		* = * "PIPE ACTIVE"
		.byte $00,$00,$00,$00,$00





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
			ldy #$04
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
			lda MAPDATA.MAP_1.EnemyList, x
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
			lda MAPDATA.MAP_1.PipeLengthAndDirection, x
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
			ldy MAPDATA.MAP_1.PipeStartY, x
			lda TABLES.ScreenRowLSB, y
			sta PIPE_DRAW + 0
			lda TABLES.ScreenRowMSB, y
			sta PIPE_DRAW + 1

			lda MAPDATA.MAP_1.PipeLengthAndDirection, x
			and #$f0
			sta PIPE_DIR
			lda MAPDATA.MAP_1.PipeLengthAndDirection, x			
			and #$0f
			sta PIPE_TEMP

			clc
		!Loop:
			ldy MAPDATA.MAP_1.PipeStartX, x
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

			ldy MAPDATA.MAP_1.PipeStartY, x
			lda TABLES.ScreenRowLSB, y
			sta PIPE_DRAW + 0
			lda TABLES.ScreenRowMSB, y
			sta PIPE_DRAW + 1

			lda MAPDATA.MAP_1.PipeLengthAndDirection, x
			and #$f0
			sta PIPE_DIR
			lda MAPDATA.MAP_1.PipeLengthAndDirection, x			
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
			ldy MAPDATA.MAP_1.PipeStartX, x
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
			ldy MAPDATA.MAP_1.PipeStartX, x
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
			ldy NextEnemyIndex
			lda MAPDATA.MAP_1.EnemyList, y
			pha
			//Get Pipe X and Y
			lda MAPDATA.MAP_1.PipeSpawnY, x
			tay
			lda MAPDATA.MAP_1.PipeSpawnX, x
			tax
			pla
			inc NextEnemyIndex

			jsr ENEMIES.SpawnEnemy

			pla
			tax
			rts
	}
}