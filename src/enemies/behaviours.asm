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

	//Flying candy monster bounces of scenery
	Enemy_001: {
			jmp !OnSpawn+ 
			jmp !OnUpdate+ 
			jmp !OnDeath+

			.label ANIM_FRAME = $00
			.label DX = $01
			.label DY = $02

		FlyAnimation:
			.byte 16,17,18,19,20
		__FlyAnimation:

		!OnSpawn:		
				jsr Random
				and #$01
				asl
				clc
				adc #$ff
				:setStaticMemory(DX, null)

				jsr Random
				and #$01
				asl
				clc
				adc #$ff
				:setStaticMemory(DY, null)

				:setEnemyFrame(16)
				rts

		CollisionPointsY:
				.byte 0, 20
		CollisionPointsX:
				.byte 0, 23

		!OnUpdate:	
				:setEnemyColor(7, 13)
				:hasHitProjectile()
				:getStaticMemory(DY)
				tay
				:getStaticMemory(DX)
				:UpdatePosition(null, null)

			!YBounce:
				lda ENEMIES.EnemyPosition_Y1, x
				cmp #$32
				bcc !DoYBounce+
				cmp #$cd
				bcs !DoYBounce+
			!:
				* = * 
				:getStaticMemory(DY)
				clc
				adc #$01
				lsr
				tay
				lda CollisionPointsY, y
				tay
				lda #$0a
				:getEnemyCollisions(null, null)
				tay
				lda CHAR_COLORS, y
				and #PLAYER.COLLISION_SOLID	
				beq !NoYBounce+
			!DoYBounce:
				:getStaticMemory(DY)
				eor #$ff
				clc
				adc #$01
				:setStaticMemory(DY, null)

			!NoYBounce:	

			!XBounce:
				lda ENEMIES.EnemyPosition_X2, x
				lsr
				lda ENEMIES.EnemyPosition_X1, x
				ror

				cmp #$0c
				bcc !DoXBounce+
				cmp #$a0
				bcs !DoXBounce+
			!:

				:getStaticMemory(DX)
				clc
				adc #$01
				lsr
				tay
				lda CollisionPointsX, y
				ldy #$0c
				:getEnemyCollisions(null, null)
				tay
				lda CHAR_COLORS, y
				and #PLAYER.COLLISION_SOLID	
				beq !NoXBounce+
			!DoXBounce:
				:getStaticMemory(DX)
				eor #$ff
				clc
				adc #$01
				:setStaticMemory(DX, null)
			!NoXBounce:	
			!ExitBounce:

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
				:hasHitProjectile()
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

				//Snap enemy to floor
				:snapEnemyToFloor()

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


	StunnedBehaviuor: {
		update: {
			lda ENEMIES.EnemyState, x
			:setEnemyColor($02, $0a)

		}
	}

}





