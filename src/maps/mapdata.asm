MAPDATA: {
	MAP_POINTERS:
		.word MAP_1
		.word MAP_2

	.label PlayerSpawnData = MAP_1.PlayerSpawns - MAP_1
	.label PipeSpawnData = MAP_1.PipeSpawnX - MAP_1
	.label DoorSpawnData = MAP_1.DoorSpawnLoc - MAP_1
	.label SwitchSpawnData = MAP_1.SwitchSpawnLoc - MAP_1
	.label EnemyWeightData = MAP_1.EnemyWeight - MAP_1
	.label NumberEnemiesData = MAP_1.NumberEnemies - MAP_1
	.label EnemyListData = MAP_1.EnemyList - MAP_1

	MAP_1: {
		Level:	//Level ALWAYS first data in map data
			.import binary "../../assets/maps/map_2.bin"

		PlayerSpawns:
			.byte $98,$00,$b8	//Player1  X,XMSB, Y
			.byte $a6,$00,$b8	//Player2

			//Sprite space from Char space (X is  half values)
			//X = cx * 4 + 12
			//Y = cy * 8 + 50
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
			.byte $0a,$10

		.label NUMBER_OF_ENEMIES = 8
		NumberEnemies:
			.byte NUMBER_OF_ENEMIES //__EnemyList - EnemyList - Countof255

		EnemyWeight:
			.byte max(1, round(56/NUMBER_OF_ENEMIES))

		NumberOfPowerups:
			.byte 3
			
		//Additional static values go here, above order msut stay intact


		//Dynamically sized data from this point only
		EnemyList:
			.byte 4,255,4,255,4,4,4,255,4,4,4
		__EnemyList:
			.byte 0

		BarUnits:
			//A list of values 0-56 in intervals numbering the same as total enemies
			.fill NUMBER_OF_ENEMIES, [[i*56]/NUMBER_OF_ENEMIES]
			.byte 56
	}


	MAP_2: {
		Level:
			.import binary "../../assets/maps/map_2.bin"

		PlayerSpawns:
			.byte $38,$00,$b8	//Player1  X,XMSB, Y
			.byte $26,$01,$b8	//Player2

			//Sprite space from Char space (X is  half values)
			//X = cx * 4 + 12
			//Y = cy * 8 + 50
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

		NumberEnemies:
			.byte 4 //__EnemyList - EnemyList - Countof255

		EnemyWeight:
			.byte max(1, round(56/[__EnemyList - EnemyList]))
		//Additional static values go here, above order msut stay intact

		NumberOfPowerups:
			.byte 0

		EnemyList:
			.byte 2,2,2,2
		__EnemyList:
			.byte 0

		BarUnits:
			.fill [__EnemyList - EnemyList], [[i*56]/[__EnemyList - EnemyList]]
			.byte 56
	}



}