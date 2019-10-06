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
				lda ENEMIES.EnemyState, x
				ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
				sta ENEMIES.EnemyState, x
				rts

		!OnUpdate:
				//Should I fall??
				:doFall(12, 21) //Check below enemy and fall if needed
				bcc !+
				jmp !Done+
			!:

			!CheckLeft:
				lda ENEMIES.EnemyState, x
				bit TABLES.Plus + ENEMIES.STATE_WALK_LEFT

				beq !CheckRight+

				//Do walk left
				:getEnemyCollisions(0, 21)
				tay
				lda CHAR_COLORS, y
				and #PLAYER.COLLISION_COLORABLE
				beq !ChangeDir+
			!WalkLeft:
				:UpdatePosition(-$080, $000)
				jmp !Done+
			!ChangeDir:
				:setEnemyFrame(21)
				lda ENEMIES.EnemyState, x
				and #[255 -[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]]
				ora #[ENEMIES.STATE_FACE_RIGHT + ENEMIES.STATE_WALK_RIGHT]
				sta ENEMIES.EnemyState, x
				jmp !Done+
				

			!CheckRight:
				bit TABLES.Plus + ENEMIES.STATE_WALK_RIGHT
				beq !+
				//Do Walk right
				:getEnemyCollisions(24, 21)
				tay
				lda CHAR_COLORS, y
				and #PLAYER.COLLISION_COLORABLE
				beq !ChangeDir+
			!WalkRight:
				:UpdatePosition($080, $000)
				jmp !Done+

			!ChangeDir:
				:setEnemyFrame(16)
				lda ENEMIES.EnemyState, x
				and #[255 -[ENEMIES.STATE_FACE_RIGHT + ENEMIES.STATE_WALK_RIGHT]]
				ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
				sta ENEMIES.EnemyState, x
				// jmp !Done+

			!:

			!Done:
				:PositionEnemy()
				rts


		!OnDeath:
				rts
	}

}





