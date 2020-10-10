
//CANDY CANE - Enemy jumps at random intervals and in random drirections
Enemy_005: {
		jmp !OnSpawn+ 
		jmp !OnUpdate+ 
		jmp !OnDeath+

		.label WALK_FRAME = $00
		.label JUMP_TIMER = $01
		.label JUMP_INDEX = $02

	JumpLeft:
		.byte $28,$29,$2a
	__JumpLeft:
	JumpRight:
		.byte $25,$26,$27
	__JumpRight:

	!OnSpawn:
			//Set pointer
			lda JumpLeft
			:setEnemyFrame(0)
			:setEnemyColor(1, null)

			jsr Random
			bmi !faceRight+

		!faceLeft:
			lda ENEMIES.EnemyState, x
			ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
			sta ENEMIES.EnemyState, x
			lda JumpLeft
			bne !faceDone+

		!faceRight:
			lda ENEMIES.EnemyState, x
			ora #[ENEMIES.STATE_FACE_RIGHT + ENEMIES.STATE_WALK_RIGHT]
			sta ENEMIES.EnemyState, x
			lda JumpRight

		!faceDone:
			:setEnemyFrame(0)
			// :setStaticMemory(WALK_FRAME, 0)

			jsr Random
			and #$7f
			clc
			adc #$32
			:setStaticMemory(JUMP_TIMER, null)

			:setStaticMemory(JUMP_INDEX, $ff)				
			rts

	!OnUpdate:

			txa 
			and #$01
			eor ZP_COUNTER
			and #$01
			sta BEHAVE_FULL

			:exitIfStunned()
			:setEnemyColor(1, null)

			:hasHitProjectile()
		


	

			lda PLAYER.Player_Freeze_Active
			beq !+
			jmp !Skip+
		!:

			//Check if enemy is already in a jump animation
			:getStaticMemory(JUMP_INDEX)
			bpl !DoJumpRoutine+

			//Should I fall??				
			:doFall(12, 23) //Check below enemy and fall if needed
			bcc !+
			jmp !LateralMove+
		!:

			//Snap enemy to floor
			jsr snapEnemyToFloor

			//Now check jump timer
			:getStaticMemory(JUMP_TIMER)
			tay
			dey
			tya
			:setStaticMemory(JUMP_TIMER, null) 
			bne !NotJumpingYet+
		
			ldy #$02
			jmp !+
		!NotJumpingYet:
			//If we are in the last few ticks
			//of the pause before jump then set the 
			//frame accordingly
			ldy #$00
			cmp #$10	//Pre jump animation frame time
			bcs !+
			iny
		!:

			lda ENEMIES.EnemyState, x
			and #[ENEMIES.STATE_FACE_RIGHT]
			beq !FaceLeftFrame+
		!FaceRightFrame:
			lda JumpRight, y
			jmp !DoFaceFrame+
		!FaceLeftFrame:
			lda JumpLeft, y
		!DoFaceFrame:
			:setEnemyFrame(0)
			cpy #$02
			beq !StartJumpAnimation+
			jmp !Done+


		!StartJumpAnimation:
			:setStaticMemory(JUMP_INDEX, 0)

			//Now do jump routine
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
		 	
			//Reset jump timer
			jsr Random
			and #$7f
			clc
			adc #$32
			:setStaticMemory(JUMP_TIMER, null)

			ldy #$ff
		!:
			tya
			:setStaticMemory(JUMP_INDEX, null)

		!LateralMove:
			lda BEHAVE_FULL
			beq !+
			jmp !SkipFull+
		!:	

			jsr CheckScreenEdges
			//Lateral movement here
			lda ENEMIES.EnemyState, x
			and #[ENEMIES.STATE_FACE_RIGHT]
			beq !MoveLeft+
		!MoveRight:
			:UpdatePosition($300, 0)
			lda JumpRight + 2
			:setEnemyFrame(0)
			jmp !Done+
		!MoveLeft:
			:UpdatePosition(-$300, 0)
			lda JumpLeft + 2
			:setEnemyFrame(0)
		!Done:	
		!Skip:
		!SkipFull:
			:clearColorable()
	
			:PositionEnemy()
			rts

	!OnDeath:
			rts
}
