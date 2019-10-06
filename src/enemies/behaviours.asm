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
			:setEnemyFrame(64)
			rts

		!OnUpdate:
			:PositionEnemy()
			// :UpdatePosition($100, $100)
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
			:setEnemyFrame(16)
			rts

		!OnUpdate:
			//Should I fall??
			:doFall(12, 21) //Check below enemy and fall if needed
		!:
			:PositionEnemy()
			rts

		!OnDeath:
			rts
	}

}





