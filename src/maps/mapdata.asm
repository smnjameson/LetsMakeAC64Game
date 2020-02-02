MAPDATA: {

	MAP_1: {
		Level:
			.import binary "../../assets/maps/map_1.bin"

		PlayerSpawns:
			.byte $98,$00,$b8	//Player1  X,XMSB, Y
			.byte $a6,$00,$b8	//Player2

			//Sprite space from Char space (X is  half values)
			//X = cx * 4 + 12
			//Y = cy * 8 + 50
		PipeSpawnX:
			.byte $2c, $94, $1c, $64, $84
		PipeSpawnY:
			.byte $52, $62, $6a, $b2, $92
		PipeLength:
			.byte $00, $00, $00, $00, $00
		PipeUpOrDown:
			.byte $00, $00, $00, $00, $00

		DoorSpawnLoc:
			.byte $16,$02
		SwitchSpawnLoc:
			.byte $20,$04

		EnemyList:
			.byte 1,1,1,1, 2,2,2,2, 1,1,2,2
			.byte 1,1,1,1, 2,2,2,2, 1,1,2,2
			.byte 0
	}

}