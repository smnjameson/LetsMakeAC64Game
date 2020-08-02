//SAUCER FLYER = Flys left and right changing direction at random
Enemy_004: {
		jmp !OnSpawn+ 
		jmp !OnUpdate+ 
		jmp !OnDeath+

		.label ANIM_FRAME = $00
		.label DX = $01

	FlyAnimation:
		.byte $1c,$1d,$1e,$1d
	__FlyAnimation:

	!OnSpawn:	
			:setStaticMemory(ANIM_FRAME, $00)	
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

	!OnUpdate:	
			:exitIfStunned()

			//Set the enmy frame
			:getStaticMemory(ANIM_FRAME)
			//TODO: Optimise
			tay
			lda ZP_COUNTER
			and #$03
			bne !+
			iny
			cpy #[__FlyAnimation - FlyAnimation]
			bne !+
			ldy #$00
		!:
			tya 
			:setStaticMemory(ANIM_FRAME, null)
			lda FlyAnimation, y
			sta ENEMIES.EnemyFrame, x
		!skip:


			:setEnemyColor(8, null)
			:hasHitProjectile()
			:getStaticMemory(DX)
			ldy #$00
			:UpdatePosition(null, null)				



		!XBounce:
			jsr Random
			cmp #$04
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
