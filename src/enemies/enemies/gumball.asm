//GUMBALL - Enemy walks back and forth on platforms
// Drops off edges but if an enemy is above it will jump

Enemy_007: {
		jmp !OnSpawn+ 
		jmp !OnUpdate+ 
		jmp !OnDeath+

		.label WALK_FRAME = $00
		.label JUMP_INDEX = $01
		.label FALLING_SPAWN = $02

	WalkLeft:
		.byte $35,$36,$37
	__WalkLeft:
	WalkRight:
		.byte $32,$33,$34
	__WalkRight:

	!OnSpawn:
			lda WalkLeft
			:setEnemyFrame(0)
			:setEnemyColor(14, null)

			jsr Random
			bmi !faceRight+

		!faceLeft:
			lda ENEMIES.EnemyState, x
			ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
			sta ENEMIES.EnemyState, x
			lda WalkLeft
			bne !faceDone+

		!faceRight:
			lda ENEMIES.EnemyState, x
			ora #[ENEMIES.STATE_FACE_RIGHT + ENEMIES.STATE_WALK_RIGHT]
			sta ENEMIES.EnemyState, x
			lda WalkRight

		!faceDone:
			:setEnemyFrame(0)

			//Set pointers
			:setStaticMemory(WALK_FRAME, 0)
			:setStaticMemory(JUMP_INDEX, $ff)	
			:setStaticMemory(FALLING_SPAWN, $01)	
			rts


	!OnUpdate:
			:exitIfStunned()
			:setEnemyColor(14, null)

			:hasHitProjectile()

			lda PLAYER.Player_Freeze_Active
			bne !Skip+
		
			//Check if enemy is already in a jump animation
			:getStaticMemory(JUMP_INDEX)
			bmi !+
			jmp !DoJumpRoutine+
		!:
			jsr CheckScreenEdges

			//Should I fall??				
			:doFall(12, 21) //Check below enemy and fall if needed
			bcc !+
			:getStaticMemory(FALLING_SPAWN)
			beq !noFallSpawn+
			jmp !Done+
		!noFallSpawn:
			jmp !LateralMove+
		!:
			:setStaticMemory(FALLING_SPAWN, $00)
		
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
			:UpdatePosition(-$100, $000)
			:getStaticMemory(WALK_FRAME)
			tay
			lda WalkLeft, y
			:setEnemyFrame(null)

			jmp !Done+


		!ChangeDir:
			jsr Random
			and #$01
			beq !Jump+
		!ActuallyChangeDir:
			lda ENEMIES.EnemyState, x
			and #[255 -[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]]
			ora #[ENEMIES.STATE_FACE_RIGHT + ENEMIES.STATE_WALK_RIGHT]
			sta ENEMIES.EnemyState, x
			jmp !Done+			
		!Jump:
			:setStaticMemory(JUMP_INDEX, 0)
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
			:UpdatePosition($100, $000)
			:getStaticMemory(WALK_FRAME)
			tay
			lda WalkRight, y
			:setEnemyFrame(null)

			jmp !Done+

		!ChangeDir:
			jsr Random
			and #$01
			beq !Jump+
		!ActuallyChangeDir:
			lda ENEMIES.EnemyState, x
			and #[255 -[ENEMIES.STATE_FACE_RIGHT + ENEMIES.STATE_WALK_RIGHT]]
			ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
			sta ENEMIES.EnemyState, x
			jmp !Done+			
		!Jump:
			:setStaticMemory(JUMP_INDEX, 0)
			jmp !Done+

		!:
		!Done:
			

			:PositionEnemy()
			rts

		!DoJumpRoutine:
			:getStaticMemory(JUMP_INDEX)
			tay 

			lda TABLES.JumpAndFallTable, y
			sta BEHAVIOUR_TEMP1
			lda ENEMIES.EnemyPosition_Y1, x
			sec
			sbc BEHAVIOUR_TEMP1
			sta ENEMIES.EnemyPosition_Y1, x
			iny
			cpy #[TABLES.__JumpAndFallTable - TABLES.JumpAndFallTable - 1]
			bne !+
		 	
			//Turn off jump here
			ldy #$ff
		!:
			tya
			:setStaticMemory(JUMP_INDEX, null)
			// jmp !Done-


		!LateralMove:
			//Lateral movement here
			lda ENEMIES.EnemyState, x
			and #[ENEMIES.STATE_FACE_RIGHT]
			beq !MoveLeft+
		!MoveRight:
			:UpdatePosition($200, 0)
			jmp !Done-
		!MoveLeft:
			:UpdatePosition(-$200, 0)
			jmp !Done-

	!OnDeath:
			rts
}

