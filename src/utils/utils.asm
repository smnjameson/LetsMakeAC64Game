UTILS: {
	

	GetCharacterAt: {
		//x register = x char position
		//y register = y char position

		.label COLLISION_LOOKUP = TEMP1

		lda TABLES.BufferLSB ,y
		sta COLLISION_LOOKUP
		lda TABLES.BufferMSB ,y
		sta COLLISION_LOOKUP + 1

		txa
		tay
		lda (COLLISION_LOOKUP), y		
		rts
	}

}