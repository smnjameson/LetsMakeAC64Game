//MALLOW - Enemy jumps at random intervals and in random drirections
Enemy_006: {
		jmp !OnSpawn+ 
		jmp !OnUpdate+ 
		jmp !OnDeath+

		.label WALK_FRAME = $00
		.label JUMP_TIMER = $01
		.label JUMP_INDEX = $02
		.label SLAM_COUNTER = $03
		.label WAS_FALLING = $04
	MallowJumpAndFallTable:
		.byte $04, $04, $04, $04, $04, $04, $03, $03,$03, $03
		.byte $03,$03, $02, $02, $02,$02, $02, $02, $02, $02
		.byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
		.byte $00, $00
	__MallowJumpAndFallTable:


	StaticFrame:
		.byte $2e
	PreJumpFrame:
		.byte $2f
	JumpFrame:
		.byte $2f
	FallFrame:
		.byte $30
	SlamFrame:
		.byte $31

	.const JUMP_TIMER_MIN = $32
	.const JUMP_TIMER_RANDOM = $3f

	!OnSpawn:
			//Set pointer
			lda StaticFrame
			:setEnemyFrame(0)
			:setEnemyColor(2, null)

			//Choose inital jump direction
			jsr Random
			bmi !faceRight+
		!faceLeft:
			lda ENEMIES.EnemyState, x
			ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
			sta ENEMIES.EnemyState, x
			bne !faceDone+
		!faceRight:
			lda ENEMIES.EnemyState, x
			ora #[ENEMIES.STATE_FACE_RIGHT + ENEMIES.STATE_WALK_RIGHT]
			sta ENEMIES.EnemyState, x
		!faceDone:

			//Setup the jump timer
			jsr Random
			and #JUMP_TIMER_RANDOM
			clc
			adc #JUMP_TIMER_MIN
			:setStaticMemory(JUMP_TIMER, null)
			:setStaticMemory(JUMP_INDEX, $ff)				
			:setStaticMemory(SLAM_COUNTER, $00)				
			:setStaticMemory(WAS_FALLING, $00)				
			rts

	!OnUpdate:
			:exitIfStunned()
			:setEnemyColor(2, null)
			:hasHitProjectile()
			
			//What if we are frozen via a powerup?
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
			:setStaticMemory(WAS_FALLING, $01)
			lda FallFrame
			:setEnemyFrame(0)
			:doFall(12, 23) //Check below enemy and fall if needed
			bcc !+			
			:setStaticMemory(WAS_FALLING, $01)
			jmp !Done+
		!:
			:getStaticMemory(WAS_FALLING)
			beq !+
			:setStaticMemory(WAS_FALLING, $00)
			:setStaticMemory(SLAM_COUNTER, $0c)
			lda #$04
			sta IRQ.ScreenShakeTimer
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
			cmp #$04	//Pre jump animation frame time
			bcs !+
			iny
		!:

			lda StaticFrame, y
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

			lda MallowJumpAndFallTable, y
			sta BEHAVIOUR_TEMP1
			lda ENEMIES.EnemyPosition_Y1, x
			sec
			sbc BEHAVIOUR_TEMP1
			sta ENEMIES.EnemyPosition_Y1, x
			iny
			cpy #[__MallowJumpAndFallTable - MallowJumpAndFallTable - 1]
			bne !+
		 	
			//Reset jump timer
			jsr Random
			and #JUMP_TIMER_RANDOM
			clc
			adc #JUMP_TIMER_MIN
			:setStaticMemory(JUMP_TIMER, null)
			ldy #$ff
		!:
			tya
			:setStaticMemory(JUMP_INDEX, null)


		!LateralMove:
			jsr CheckScreenEdges

			//Lateral movement here
			lda ENEMIES.EnemyState, x
			and #[ENEMIES.STATE_FACE_RIGHT]
			beq !MoveLeft+
		!MoveRight:
			:UpdatePosition($300, 0)
			jmp !Done+
		!MoveLeft:
			:UpdatePosition(-$300, 0)
		!Done:	
		!Skip:
			

			//Set slam frame if necessary

			:getStaticMemory(SLAM_COUNTER)
			beq !+
			sec
			sbc #$01
			:setStaticMemory(SLAM_COUNTER, null)
			lda SlamFrame
			:setEnemyFrame(0)
		!:
			:clearColorable()
			:PositionEnemy()
			rts

	!OnDeath:
			rts
}


