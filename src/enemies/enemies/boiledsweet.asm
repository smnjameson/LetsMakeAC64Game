//BOILED SWEET FLYER = Flying candy monster bounces of scenery
Enemy_001: {
		jmp !OnSpawn+ 
		jmp !OnUpdate+ 
		jmp !OnDeath+

		.label ANIM_FRAME = $00
		.label DX = $01
		.label DY = $02

	FlyAnimation:
		.byte $2b,$2c,$2d,$2c
	__FlyAnimation:

	!OnSpawn:	
			:setStaticMemory(ANIM_FRAME, $00)	
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

			lda FlyAnimation
			:setEnemyFrame(0)
			rts

	CollisionPointsY:
			.byte 0, 20
	CollisionPointsX:
			.byte 0, 23

	!OnUpdate:	
			:exitIfStunned()


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


			:setEnemyColor(7, null)
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
			and #UTILS.COLLISION_SOLID	
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

			cmp #[PLAYER.LEFT_SCREEN_EDGE / 2]
			bcs !+
			lda #$01
			sta ENEMIES.EnemyPosition_X2, x
			lda #[PLAYER.RIGHT_SCREEN_EDGE]
			sta ENEMIES.EnemyPosition_X1, x	
			jmp !ExitBounce+
		!:
			cmp #[[PLAYER.RIGHT_SCREEN_EDGE + $100] / 2]
			bcc !+
			lda #$00
			sta ENEMIES.EnemyPosition_X2, x
			lda #[PLAYER.LEFT_SCREEN_EDGE]
			sta ENEMIES.EnemyPosition_X1, x				
			jmp !ExitBounce+
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
