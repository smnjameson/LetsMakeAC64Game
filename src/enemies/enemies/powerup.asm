//Powerup behaviour
PowerUpColorsA:
		.byte 1,7,3,4,5,6
PowerUpColorsB:
		.byte 1,7,3,8,5,6

PowerUpFrames:
		.byte $3b,$3c,$3d,$3c
__PowerUpFrames:
		
PowerUp: {
		jmp !OnSpawn+ 
		jmp !OnUpdate+ 
		jmp !OnDeath+

		.label POWERUP_TYPE = $00
		.label BOUNCE = $01
		.label FRAME = $02

	!OnSpawn:
			jsr Random
			and #$03
			:setStaticMemory(POWERUP_TYPE, null)
			:setStaticMemory(BOUNCE, $00)
			:setStaticMemory(FRAME, $00)
			lda PowerUpFrames
			:setEnemyFrame(0)
			rts

	!OnUpdate:
			:getStaticMemory(POWERUP_TYPE)
			tay
		// 	lda ZP_COUNTER
		// 	and #$01
		// 	beq !Col2+
		// !Col1:		
			lda PowerUpColorsA, y 
			bne !Apply+
		// !Col2:
		// 	lda PowerUpColorsB, y 
		!Apply:
			sta ENEMIES.EnemyColor, x


			:getStaticMemory(FRAME)
			tay
			lda ZP_COUNTER
			lsr 
			and #$03
			bne !+
			iny
			cpy #[__PowerUpFrames - PowerUpFrames]
			bne !+
			ldy #$00
		!:
			tya 
			:setStaticMemory(FRAME, null)
			lda PowerUpFrames, y
			sta ENEMIES.EnemyFrame, x
		!skip:


			:getStaticMemory(BOUNCE)
			beq !Fall+
			sec 
			sbc #$01
			:setStaticMemory(BOUNCE, null)
			:UpdatePosition(0, -$c0)
			jmp !Finish+

		!Fall:
			:doFall(12, 22)
			bcs !Finish+
			:setStaticMemory(BOUNCE, $10)
			
		!Finish:
			:PositionEnemy() //Draw!!
			rts

	!OnDeath:	
			// .break
			lda #$00
			sta ENEMIES.EnemyType, x
			:getStaticMemory(POWERUP_TYPE)

			rts

}