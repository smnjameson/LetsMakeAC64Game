* = * "Tables"
TABLES: {
	TileScreenLocations2x2:
		.byte 0,1,40,41		//Table to speed up tile to screen location conversion
	ScreenRowLSB:
		.fill 25, <[$c000 + i * $28]
	ScreenRowMSB:
		.fill 25, >[$c000 + i * $28]
	BufferLSB:
		.fill 25, <[MAPLOADER.BUFFER + i * $28]
	BufferMSB:
		.fill 25, >[MAPLOADER.BUFFER + i * $28]

	JumpAndFallTable:
		.byte $04, $04, $04, $03, $03
		.byte $03, $02, $02, $02
		.byte $02, $01, $01, $01, $01, $01, $00
	__JumpAndFallTable:

	PlayerWalkLeft: 
		.byte 67,68,69,68
	__PlayerWalkLeft: 

	PlayerWalkRight: 
		.byte 64,65,66,65
	__PlayerWalkRight: 

	PlayerCrownBob:
		.byte 3,4,3,4
	__PlayerCrownBob:
	PlayerThrowCrownX:
		.byte 1, 1,0,2,2, 2,2,2,2,2, 2,2,2, 0,0
	_PlayerThrowCrownX:
	PlayerThrowCrownY:
		.byte 3, 4,5,4,4, 4,4,4,4,4 ,4,4,4, 5,5
	_PlayerThrowCrownY:
	PlayerSizeCrownOffset:
		.byte 0,1,6
	__PlayerSizeCrownOffset:
	
	PlayerEatLeft: 
		.byte 84,85,86
	__PlayerEatLeft: 

	PlayerEatRight: 
		.byte 80,81,82
	__PlayerEatRight: 

	
	PlayerThrowLeft: 
		.byte 76,77,78,79, 79,79,79,79,79, 78,78,78, 77,77
	__PlayerThrowLeft: 

	PlayerThrowRight: 
		.byte 72,73,74,75,75,75,75,75,75,74,74,74,73,73
	__PlayerThrowRight: 

	PlayerExitAnimation: 
		.byte $90,$91,$92,$93,$94,$95,$96,$97,$98,$96,$97,$98
	__PlayerExitAnimation: 

	PowerOfTwo:
		.byte 1,2,4,8,16,32,64,128
	InvPowerOfTwo:
		.byte 255-1, 255-2, 255-4, 255-8, 255-16, 255-32, 255-64, 255-128

	Plus:
		.fill 129, i
}



