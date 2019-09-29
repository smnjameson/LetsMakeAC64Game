BEHAVIOURS: {

	EnemyLSB:
		.byte $ff
		.byte <Enemy_001
		.byte <Enemy_002

	EnemyMSB:
		.byte $ff
		.byte >Enemy_001
		.byte >Enemy_002


	.label BEHAVIOUR_SPAWN = 0;
	.label BEHAVIOUR_UPDATE = 3;
	.label BEHAVIOUR_DEATH = 6;



	Enemy_001: {
			jmp !OnSpawn+ 
			jmp !OnUpdate+ 
			jmp !OnDeath+

		!OnSpawn:
			//Set pointer
			lda #64
			sta SPRITE_POINTERS + 3, x
			rts

		!OnUpdate:

			:PositionEnemy()
			inc ENEMIES.EnemyPosition_Y1, x
			rts

		!OnDeath:
			rts
	}



	Enemy_002: {
			jmp !OnSpawn+ 
			jmp !OnUpdate+ 
			jmp !OnDeath+

		!OnSpawn:
			//Set pointer
			lda #64 + 19
			sta SPRITE_POINTERS + 3, x
			rts

		!OnUpdate:
			:PositionEnemy()
			dec ENEMIES.EnemyPosition_Y1, x
			rts

		!OnDeath:
			rts
	}

}





.macro PositionEnemy() {
		.label INDEX = TEMP8
		.label STOREY = TEMP7

		stx INDEX
		txa
		tay
		asl
		tax
		lda ENEMIES.EnemyPosition_X1, y
		sta VIC.SPRITE_0_X + [3 * 2], x
		lda ENEMIES.EnemyPosition_Y1, y
		sta VIC.SPRITE_0_Y + [3 * 2], x
		ldx INDEX
		ldy ENEMIES.EnemyPosition_X2, x
		inx
		inx
		inx
		lda $d010
		and TABLES.InvPowerOfTwo, x
		cpy #$00
		beq !+
		ora TABLES.PowerOfTwo, x
	!:
		sta $d010
		dex
		dex
		dex
		ldy STOREY
}