TABLES: {
	TileScreenLocations2x2:
		.byte 0,1,40,41		//Table to speed up tile to screen location conversion
	ScreenRowLSB:
		.fill 25, <[$c000 + i * $28]
	ScreenRowMSB:
		.fill 25, >[$c000 + i * $28]

	JumpAndFallTable:
		.byte $04, $04, $03, $03, $03
		.byte $02, $02, $02, $02
		.byte $01, $01, $01, $01, $01, $00, $00
	__JumpAndFallTable:

	PlayerWalkLeft: 
		.byte 80,81,82,83,84,85,86,87
	__PlayerWalkLeft: 

	PlayerWalkRight: 
		.byte 64,65,66,67,68,69,70,71
	__PlayerWalkRight: 

	PowerOfTwo:
		.byte 1,2,4,8,16,32,64,128
	InvPowerOfTwo:
		.byte 255-1, 255-2, 255-4, 255-8, 255-16, 255-32, 255-64, 255-128

}




