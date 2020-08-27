//JELLY BEAN - Enemy walks back and forth on platforms
//				But charges at player if in range
Enemy_002: {
		jmp !OnSpawn+ 
		jmp !OnUpdate+ 
		jmp !OnDeath+

		.label WALK_FRAME = $00

	WalkLeft:
		.byte $13,$14,$15
	__WalkLeft:
	WalkRight:
		.byte $10,$11,$12
	__WalkRight:

	PlayerIsInRange:
		.byte $00

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
			:exitIfStunned()
			:setEnemyColor(2, null)

			:hasHitProjectile()
			//Should I fall??
			:doFall(12, 23) //Check below enemy and fall if needed
			bcc !+
			jmp !Done+
		!:
			lda PLAYER.Player_Freeze_Active
			beq !+
			jmp !Skip+
		!:



			//Snap enemy to floor
			jsr snapEnemyToFloor

			.const Y_RANGE = $10
			.const X_RANGE = $40 //MAximum $7f

			//Check if ANY player is in range
			lda #$00
			sta PlayerIsInRange
			//First player 1
			lda PLAYER.PlayersActive
			and #$01
			beq !Player2+

			lda ENEMIES.EnemyPosition_Y1, x
			sec
			sbc PLAYER.Player1_Y
			clc
			adc #Y_RANGE
			cmp #[Y_RANGE*2]
			bcc !InRangeY+

		!Player2:
			//Now player 2
			lda PLAYER.PlayersActive
			and #$02
			bne !+
			jmp !NotInRange+
		!:

			lda ENEMIES.EnemyPosition_Y1, x
			sec
			sbc PLAYER.Player2_Y
			clc
			adc #Y_RANGE
			cmp #[Y_RANGE*2]
			bcc !InRangeY+
			jmp !NotInRange+

		!InRangeY:
			//Now check X range
			lda PLAYER.PlayersActive
			and #$01
			beq !Player2+

			lda ENEMIES.EnemyPosition_X1, x
			sec
			sbc PLAYER.Player1_X + 1
			sta BEHAVIOUR_TEMPWORD1 + 0
			lda ENEMIES.EnemyPosition_X2, x
			sbc PLAYER.Player1_X + 2
			sta BEHAVIOUR_TEMPWORD1 + 1

			clc
			lda BEHAVIOUR_TEMPWORD1 + 0
			adc #X_RANGE
			sta BEHAVIOUR_TEMPWORD1 + 0
			lda BEHAVIOUR_TEMPWORD1 + 1
			adc #$00
			sta BEHAVIOUR_TEMPWORD1 + 1
			bne !Player2+

			lda BEHAVIOUR_TEMPWORD1 + 0
			cmp #[X_RANGE*2]
			bcs !Player2+
			lda ENEMIES.EnemyState, x
			and #ENEMIES.STATE_FACE_LEFT
			beq !FacingRight+
		!FacingLeft:
			lda BEHAVIOUR_TEMPWORD1 + 0
			cmp #[X_RANGE]
			bcs !InRangeX+
			jmp !Player2+	
		!FacingRight:
			lda BEHAVIOUR_TEMPWORD1 + 0
			cmp #[X_RANGE]
			bcc !InRangeX+

		!Player2:
			lda PLAYER.PlayersActive
			and #$02
			beq !NotInRange+

			lda ENEMIES.EnemyPosition_X1, x
			sec
			sbc PLAYER.Player2_X + 1
			sta BEHAVIOUR_TEMPWORD1 + 0
			lda ENEMIES.EnemyPosition_X2, x
			sbc PLAYER.Player2_X + 2
			sta BEHAVIOUR_TEMPWORD1 + 1

			clc
			lda BEHAVIOUR_TEMPWORD1 + 0
			adc #X_RANGE
			sta BEHAVIOUR_TEMPWORD1 + 0
			lda BEHAVIOUR_TEMPWORD1 + 1
			adc #$00
			sta BEHAVIOUR_TEMPWORD1 + 1
			bne !NotInRange+

			lda BEHAVIOUR_TEMPWORD1 + 0
			cmp #[X_RANGE*2]
			bcs !NotInRange+

			lda ENEMIES.EnemyState, x
			and #ENEMIES.STATE_FACE_LEFT
			beq !FacingRight+
		!FacingLeft:
			lda BEHAVIOUR_TEMPWORD1 + 0
			cmp #[X_RANGE]
			bcs !InRangeX+
			jmp !NotInRange+	
		!FacingRight:
			lda BEHAVIOUR_TEMPWORD1 + 0
			cmp #[X_RANGE]
			bcc !InRangeX+



			jmp !NotInRange+


		!InRangeX:
			lda #$01
			sta PlayerIsInRange
	
		!NotInRange:


		!CheckLeft:
			lda ENEMIES.EnemyState, x
			bit TABLES.Plus + ENEMIES.STATE_WALK_LEFT

			beq !CheckRight+

			//Do walk left
			:getEnemyCollisions(0, 23)
			tay
			lda CHAR_COLORS, y
			and #UTILS.COLLISION_COLORABLE
			beq !ChangeDir+
		!WalkLeft:
			:UpdatePosition(-$080, $000)
			lda PlayerIsInRange
			beq !+
			:UpdatePosition(-$100, $000)
		!:
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
			:getEnemyCollisions(24, 23)
			tay
			lda CHAR_COLORS, y
			and #UTILS.COLLISION_COLORABLE
			beq !ChangeDir+
		!WalkRight:
			:UpdatePosition($080, $000)
			lda PlayerIsInRange
			beq !+
			:UpdatePosition($100, $000)
		!:
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
			lda PlayerIsInRange
			beq !+
			lda ZP_COUNTER
			and #$01
			bne !Skip+		
			jmp !SetFrame+	
		!:
			//TODO: Optimise
			//Do walk animation
			lda ZP_COUNTER
			and #$07
			bne !Skip+
		!SetFrame:
			:getStaticMemory(WALK_FRAME)
			clc
			adc #1
			cmp #[__WalkRight - WalkRight]
			bne !+
			lda #$00
		!:
			:setStaticMemory(WALK_FRAME, null)
		!Skip:

			:PositionEnemy()
			rts

	!OnDeath:
			rts
}

