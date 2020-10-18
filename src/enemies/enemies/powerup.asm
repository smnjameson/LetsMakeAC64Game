//Powerup behaviour
PowerUpColorsA:
		.byte 2,12,1,2,1,5
PowerUpFrames:
		.byte $38,$39,$3a,$3b,$3c,$3d

		
PowerUp: {
		jmp !OnSpawn+ 
		jmp !OnUpdate+ 
		jmp !OnDeath+

		.label POWERUP_TYPE = $00
		.label BOUNCE = $01
		.label FRAME = $02

	!OnSpawn:
		!:
			jsr Random
			and #$07
			cmp #$06
			bcs !-
			//Temporary force powerup
			lda #$02
			tay
			:setStaticMemory(POWERUP_TYPE, null)
			:setStaticMemory(BOUNCE, $00)

			lda PowerUpFrames, y
			:setEnemyFrame(0)
			lda PowerUpColorsA, y
			sta ENEMIES.EnemyColor, x
			rts

	!OnUpdate:

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