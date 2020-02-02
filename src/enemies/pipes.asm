PIPES: {
	SpawnDelayTimer:
		.byte $00
	PipesActive:
		.byte $00,$00,$00,$00,$00

	NextEnemyIndex:
		.byte $00

	Initialise: {
			lda #$00
			sta NextEnemyIndex
			rts
	}

	Update: {
			//Check the spawn timer
			lda SpawnDelayTimer
			bne !SpawnCheckComplete+

			//Check if there are less than 5 enemies
			lda ENEMIES.EnemyTotalCount
			cmp #$05
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


		!SpawnCheckComplete:
			//TODO
			//Is there an active pipe?

			//If so advance the "bulge" along the pipe

			//Has the bulge reached the end

			//If so spawn an enemy
			dec SpawnDelayTimer
			rts
	}
}