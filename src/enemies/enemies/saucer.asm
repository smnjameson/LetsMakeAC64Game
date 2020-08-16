//SAUCER FLYER = Flys left and right changing direction at random
Enemy_004: {
		jmp !OnSpawn+ 
		jmp !OnUpdate+ 
		jmp !OnDeath+

		.label ANIM_FRAME = $00
		.label DX = $01
		.label WAVE_INDEX = $02

	FlyAnimation:
		.byte $1c,$1d,$1e,$1d
	__FlyAnimation:

	WaveOffsets:
		.byte 0,0,0,1,1,1,1,2,2,2,3,3,4
		.byte 3,3,2,2,2,1,1,1,1
		.byte 0,0,0,-1,-1,-1,-1,-2,-2,-2,-3,-3,-4
		.byte -3,-3,-2,-2,-2,-1,-1,-1,-1
	__WaveOffsets:

	!OnSpawn:	
			:setStaticMemory(ANIM_FRAME, $00)	
			:setStaticMemory(WAVE_INDEX, $00)	
			jsr Random
			and #$01
			asl
			clc
			adc #$ff
			:setStaticMemory(DX, null)

			lda FlyAnimation
			:setEnemyFrame(0)
			rts

	CollisionPointsY:
			.byte 0, 20
	CollisionPointsX:
			.byte 0, 23
	CollisionValues:
			.byte 0, 0
	!OnUpdate:	
			:exitIfStunned()

			//Increment wave index
			:getStaticMemory(WAVE_INDEX)
			tay
			jsr Random
			cmp #$02
			bcs !normal+
		!random:
			tya
			clc
			adc  #[[__WaveOffsets - WaveOffsets]/2]
			jmp !done+		
		!normal:
			tya
			clc
			adc #$01
		!done:
			cmp #[__WaveOffsets - WaveOffsets]		
			bcc !+
			sbc #[__WaveOffsets - WaveOffsets]
		!:
			:setStaticMemory(WAVE_INDEX, null)


	
		!skip:

			//Check collision on top and bottom
			ldy CollisionPointsY + 0
			lda #$0c
			:getEnemyCollisions(null, null)
			tay
			lda CHAR_COLORS, y
			and #UTILS.COLLISION_SOLID	
			sta CollisionValues + 0

			ldy CollisionPointsY + 1
			lda #$0c
			:getEnemyCollisions(null, null)
			tay
			lda CHAR_COLORS, y
			and #UTILS.COLLISION_SOLID	
			sta CollisionValues + 1

			lda FlyAnimation + 1
			sta ENEMIES.EnemyFrame, x
			:setEnemyColor(8, null)
			:hasHitProjectile()
			:getStaticMemory(WAVE_INDEX)
			tay
			lda WaveOffsets, y
			tay
			beq !ApplyMovement+
			bmi !neg+
		!pos:
			lda FlyAnimation + 2
			sta ENEMIES.EnemyFrame, x
			lda CollisionValues + 1	
			cmp #UTILS.COLLISION_SOLID
			bne !ApplyMovement+
			jmp !CancelMovement+
		!neg:
			lda FlyAnimation + 0
			sta ENEMIES.EnemyFrame, x
			lda CollisionValues + 0
			cmp #UTILS.COLLISION_SOLID
			bne !ApplyMovement+

		!CancelMovement:
			ldy #$00
		!ApplyMovement:
			:getStaticMemory(DX)
			:UpdatePosition(null, null)				

			// jsr CheckScreenEdges




		!XBounce:
			jsr Random
			cmp #$02
			bcc !DoXBounce+ 

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
			and #UTILS.COLLISION_SOLID	

			// lda CollisionValues, y
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
