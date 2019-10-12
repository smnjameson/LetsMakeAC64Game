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

			.label WALK_FRAME = $00

		WalkLeft:
			.byte 16,17,18,19,20
		__WalkLeft:
		WalkRight:
			.byte 21,22,23,24,25
		__WalkRight:

		!OnSpawn:
				//Set pointer
				:setEnemyFrame(16)
				:setEnemyColor(7, null)
				lda ENEMIES.EnemyState, x
				ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
				sta ENEMIES.EnemyState, x
				:setStaticMemory(WALK_FRAME, 0)
				rts

		!OnUpdate:
				//Should I fall??
				:doFall(12, 21) //Check below enemy and fall if needed
				bcc !+
				jmp !Done+
			!:
				//Do walk animation
				lda ZP_COUNTER
				and #$03
				bne !Skip+
				:getStaticMemory(WALK_FRAME)
				clc
				adc #1
				cmp #[__WalkRight - WalkRight]
				bne !+
				lda #$00
			!:
				:setStaticMemory(WALK_FRAME, null)
			!Skip:


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

				:getStaticMemory(WALK_FRAME)
				tay
				lda WalkLeft, y
				:setEnemyFrame(null)

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

				:getStaticMemory(WALK_FRAME)
				tay
				lda WalkRight, y
				:setEnemyFrame(null)

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



	Enemy_002: {
			jmp !OnSpawn+ 
			jmp !OnUpdate+ 
			jmp !OnDeath+

			.label WALK_FRAME = $00

		WalkLeft:
			.byte 16,17,18,19,20
		__WalkLeft:
		WalkRight:
			.byte 21,22,23,24,25
		__WalkRight:

		!OnSpawn:
				//Set pointer
				:setEnemyFrame(16)
				:setEnemyColor(7, null)
				lda ENEMIES.EnemyState, x
				ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
				sta ENEMIES.EnemyState, x
				:setStaticMemory(WALK_FRAME, 0)
				rts

		!OnUpdate:
				:setEnemyColor(5, 14)

				//Should I fall??
				:doFall(12, 21) //Check below enemy and fall if needed
				bcc !+
				jmp !Done+
			!:
				//Do walk animation
				lda ZP_COUNTER
				and #$03
				bne !Skip+
				:getStaticMemory(WALK_FRAME)
				clc
				adc #1
				cmp #[__WalkRight - WalkRight]
				bne !+
				lda #$00
			!:
				:setStaticMemory(WALK_FRAME, null)
			!Skip:


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

				:getStaticMemory(WALK_FRAME)
				tay
				lda WalkLeft, y
				:setEnemyFrame(null)

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

				:getStaticMemory(WALK_FRAME)
				tay
				lda WalkRight, y
				:setEnemyFrame(null)

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





