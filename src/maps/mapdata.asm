* = * "Map Data"
MAPDATA: {

	MAP_1: {
		Level:	//Level ALWAYS first data in map data
			.import binary "../../assets/maps/map_4.bin"

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

		.label NUMBER_OF_ENEMIES = 1
		NumberEnemies:
			.byte NUMBER_OF_ENEMIES //__EnemyList - EnemyList - Countof255

		EnemyWeight:
			.byte max(1, round(56/NUMBER_OF_ENEMIES))

		NumberOfPowerups:
			.byte 0
		
		TransparentColor:
			.byte 6
		MultiColor:
			.byte 12
		PipeColor:
			.byte 13
		DoorColor:
			.byte 10

		//Additional static values go here, above order msut stay intact


		//Dynamically sized data from this point only
		EnemyList:
			.byte 2//,255,2,255,3,4,5,255,6,7,8
		__EnemyList:
			.byte 0


		BarUnits:
			//A list of values 0-56 in intervals numbering the same as total enemies
			.fill NUMBER_OF_ENEMIES, [[i*56]/NUMBER_OF_ENEMIES]
			.byte 56
	}


	// .import binary "Exomizedlevel1"

}