.var PC_MapData = *
* = * "Map Data" virtual
MAPDATA: {

	MAP_1: {
		Level:	//Level ALWAYS first data in map data
			.import binary "../../assets/maps/map_3.bin"

		PlayerSpawns:
			.byte $98,$00,$b8	//Player1  X,XMSB, Y
			.byte $a6,$00,$b8	//Player2

			//Sprite space from Char space (X is  half values)
			//X = cx * 4 + 12
			//Y = cy * 8 + 50
		PipeSpawnX:
			// .byte $2c, $94, $1c, $64, $84
			.byte $2c, $94, $1c, $00, $00
		PipeSpawnY:
			// .byte $52, $62, $a2, $b2, $92
			.byte $52, $62, $a2, $00, $00
		PipeStartX:
			// .byte $08, $22, $04, $16, $1e
			.byte $08, $22, $04, $00, $00
		PipeStartY:
			// .byte $00, $00, $13, $13, $13
			.byte $00, $00, $13, $00, $00
		PipeLengthAndDirection:	//Upper nibble = 1 if pipes goes down
			// .byte $14, $16, $04, $02, $06
			.byte $14, $16, $04, $00, $00

		DoorSpawnLoc:
			.byte $16,$02
		SwitchSpawnLoc:
			.byte $0a,$10

		.label NUMBER_OF_ENEMIES = 6
		NumberEnemies:
			.byte NUMBER_OF_ENEMIES //__EnemyList - EnemyList - Countof255

		EnemyWeight:
			.byte max(1, round(56/NUMBER_OF_ENEMIES))

		NumberOfPowerups:
			.byte 1
		
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
			.byte 7,6,6,6,7,7,255
		__EnemyList:
			.byte 0


		BarUnits:
			//A list of values 0-56 in intervals numbering the same as total enemies
			.fill NUMBER_OF_ENEMIES, [[i*56]/NUMBER_OF_ENEMIES]
			.byte 56
	}

	.fill 256, 0
	// .import binary "Exomizedlevel1"

}

* = $8300 "DEMO MAP"
	.import binary "../../assets/maps/map_001.bin"


* = $8600 "Exodecrunch"
		#import "../libs/exodecrunch.asm"

* = $8800 "Level Lookup"
	LevelLookup:
		.word LEVEL001
		.word LEVEL002
		.word LEVEL003
		.word LEVELEND

* = $8880 "Compressed Levels"
	LEVEL001:
		.import binary "../../assets/compressed/map0.bin"
	LEVEL002:
		.import binary "../../assets/compressed/map1.bin"
	LEVEL003:
		.import binary "../../assets/compressed/map2.bin"
	LEVELEND:


