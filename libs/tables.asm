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
		.byte $04, $04, $03, $03, $03
		.byte $02, $02, $02, $02
		.byte $01, $01, $01, $01, $01, $00, $00
	__JumpAndFallTable:

	PlayerWalkLeft: 
		.byte 67,68,69,68
	__PlayerWalkLeft: 

	PlayerWalkRight: 
		.byte 64,65,66,65
	__PlayerWalkRight: 

	PlayerThrowLeft: 
		.byte 76,77,78,79,79,79,79,79,79,78,78,78,77,77
	__PlayerThrowLeft: 

	PlayerThrowRight: 
		.byte 72,73,74,75,75,75,75,75,75,74,74,74,73,73
	__PlayerThrowRight: 

	PowerOfTwo:
		.byte 1,2,4,8,16,32,64,128
	InvPowerOfTwo:
		.byte 255-1, 255-2, 255-4, 255-8, 255-16, 255-32, 255-64, 255-128

.align $100
*=*"COLOR"
	ColorSwapTable:
		.label SWAP1 = %10
		.label SWAP2 = %00

		.for(var i=0; i<256; i++) {
			.var a = (i & %00000011)
			.var b = (i & %00001100)
			.var c = (i & %00110000)
			.var d = (i & %11000000)

			.if(a == SWAP1			) .eval a = SWAP2;
			else
			.if(a == SWAP2			) .eval a = SWAP1;

			.if(b == (SWAP1 * 4)	) .eval b = (SWAP2 * 4);
			else
			.if(b == (SWAP2 * 4)	) .eval b = (SWAP1 * 4);
			
			.if(c == (SWAP1 * 16)	) .eval c = (SWAP2 * 16);
			else
			.if(c == (SWAP2 * 16)	) .eval c = (SWAP1 * 16);
		
			.if(d == (SWAP1 * 64)	) .eval d = (SWAP2 * 64);
			else
			.if(d == (SWAP2 * 64)	) .eval d = (SWAP1 * 64);
			

			.byte (a+b+c+d)	
		}
}



