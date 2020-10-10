//COLA BOTTLE - Enemy walks back and forth on platforms
Enemy_003: {
		jmp !OnSpawn+ 
		jmp !OnUpdate+ 
		jmp !OnDeath+

		.label WALK_FRAME = $00

	WalkLeft:
		.byte $22,$23,$24
	__WalkLeft:
	WalkRight:
		.byte $1f,$20,$21
	__WalkRight:

	!OnSpawn:
			//Set pointer
			lda WalkLeft
			:setEnemyFrame(0)
			:setEnemyColor(2, null)
			lda ENEMIES.EnemyState, x
			ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
			sta ENEMIES.EnemyState, x
			:setStaticMemory(WALK_FRAME, 0)
			rts

	!OnUpdate:
			lda #$02
			sta $d020

			txa 
			and #$01
			eor ZP_COUNTER
			and #$01
			sta BEHAVE_FULL

			:exitIfStunned()
			:setEnemyColor(2, null)

			:hasHitProjectile()
			//Should I fall??
			:doFall(12, 23) //Check below enemy and fall if needed
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


			lda BEHAVE_FULL
			beq !+
			jmp !SkipFull+
		!:

		!CheckLeft:
			lda ENEMIES.EnemyState, x
			bit TABLES.Plus + ENEMIES.STATE_WALK_LEFT

			beq !CheckRight+

			//Do walk left
			jsr CheckScreenEdges.CheckScreenEdgesBasic
			beq !ChangeDir+
		!WalkLeft:
			:UpdatePosition(-$100, $000)

			:getStaticMemory(WALK_FRAME)
			tay
			lda WalkLeft, y
			:setEnemyFrame(null)

			jmp !Done+

		!ChangeDir:
			:setEnemyFrame(31)
			jmp !Done+
		



		!CheckRight:
			bit TABLES.Plus + ENEMIES.STATE_WALK_RIGHT
			beq !+

			//Do Walk right
			jsr CheckScreenEdges
			beq !ChangeDir+
		!WalkRight:
			:UpdatePosition($100, $000)

			:getStaticMemory(WALK_FRAME)
			tay
			lda WalkRight, y
			:setEnemyFrame(null)

			jmp !Done+

		!ChangeDir:
			:setEnemyFrame(36)
			// jmp !Done+
		!:
		!SkipFull:


		!Done:
			:clearColorable()
			:PositionEnemy()
			rts

	!OnDeath:
			rts
}

