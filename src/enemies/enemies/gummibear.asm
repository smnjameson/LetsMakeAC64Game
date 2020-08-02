//Gummi bear - Enemy walks back and forth on platforms
//             
Enemy_008: {
		jmp !OnSpawn+ 
		jmp !OnUpdate+ 
		jmp !OnDeath+

		.label WALK_FRAME = $00

	WalkLeft:
		.byte $16,$17,$18
	__WalkLeft:
	WalkRight:
		.byte $19,$1a,$1b
	__WalkRight:


	!OnSpawn:
			//Set pointer
			lda WalkLeft
			:setEnemyFrame(0)
			:setEnemyColor(7, 15)
			lda ENEMIES.EnemyState, x
			ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
			sta ENEMIES.EnemyState, x
			:setStaticMemory(WALK_FRAME, 0)
			rts

	!OnUpdate:
			:exitIfStunned()
			:setEnemyColor(7, 15)

			:hasHitProjectile()
			//Should I fall??
			:doFall(12, 21) //Check below enemy and fall if needed
			bcc !+
			jmp !Done+
		!:
			lda PLAYER.Player_Freeze_Active
			bne !Skip+
			//TODO: Optimise
			//Do walk animation
			lda ZP_COUNTER
			and #$07
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

			//Snap enemy to floor
			jsr snapEnemyToFloor

		!CheckLeft:
			lda ENEMIES.EnemyState, x
			bit TABLES.Plus + ENEMIES.STATE_WALK_LEFT

			beq !CheckRight+

			//Do walk left
			:getEnemyCollisions(0, 21)
			tay
			lda CHAR_COLORS, y
			and #UTILS.COLLISION_COLORABLE
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
			and #UTILS.COLLISION_COLORABLE
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

