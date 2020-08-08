MESSAGES: {
	.const MAX_MESSAGES = 5

	// MessageX0:
	// 	.fill MAX_MESSAGES, 0	
	// MessageX1:
	// 	.fill MAX_MESSAGES, 0	
	// MessageX2:
	// 	.fill MAX_MESSAGES, 0	
	// MessageY0:
	// 	.fill MAX_MESSAGES, 0	
	// MessageY1:
	// 	.fill MAX_MESSAGES, 0	
	MessageType:
		.fill MAX_MESSAGES, 0	
	MessageDirection:
		.fill MAX_MESSAGES, 0	
	MessageLife:
		.fill MAX_MESSAGES, 0

	PositivePointer:
		.byte $8a
	NegativePointer:	
		.byte $8b
	NeutralPointer:
		.byte $88,$89,$8a

	Initialise: {
			rts
	}

	AddMessage: {
			//Accumulator register will be the type
			//0 = neutral
			//1 = positive (+100)
			//2 = negative (-100)
			//X register will be the Enemy number
			//Y register will be Player number

			//Setup the self mode with address of
			//Player1_X or Player2_X depending on Y
			lda NeutralPointer
			sta SPRITE_POINTERS, x

			lda $d01c
			and TABLES.InvPowerOfTwo, x
			sta $d01c
			rts
	}
}