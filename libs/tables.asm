TABLES: {
	TileScreenLocations2x2:
		.byte 0,1,40,41		//Table to speed up tile to screen location conversion
	ScreenRowLSB:
		.fill 25, <[$c000 + i * $28]
	ScreenRowMSB:
		.fill 25, >[$c000 + i * $28]
}




