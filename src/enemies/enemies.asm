ENEMIES: {
	.label MAX_ENEMIES = 5
	.label STATIC_MEMORY_SIZE = 16

	.label STATE_JUMP 		= %00000001
	.label STATE_FALL 		= %00000010
	.label STATE_WALK_LEFT  = %00000100
	.label STATE_WALK_RIGHT = %00001000
	.label STATE_FACE_LEFT  = %00010000
	.label STATE_FACE_RIGHT = %00100000
	.label STATE_STUNNED    = %01000000
	.label STATE_DYING   	= %10000000


	EnemyType: 
		.fill MAX_ENEMIES, 0

	EnemyPosition_X0:
		.fill MAX_ENEMIES, 0
	EnemyPosition_X1:
		.fill MAX_ENEMIES, 0
	EnemyPosition_X2:
		.fill MAX_ENEMIES, 0

	EnemyPosition_Y0:
		.fill MAX_ENEMIES, 0
	EnemyPosition_Y1:
		.fill MAX_ENEMIES, 0

	EnemyScore:
		.fill MAX_ENEMIES, 0

	EnemyFrame:
		.fill MAX_ENEMIES, 0		
	EnemyColor:
		.fill MAX_ENEMIES, 0		

	EnemyJumpFallIndex:
		.fill MAX_ENEMIES, 0

	EnemyStunTimer:
		.fill MAX_ENEMIES, 0

	EnemyState:
		.fill MAX_ENEMIES, 0

	EnemyStaticMemory:
		.fill STATIC_MEMORY_SIZE * MAX_ENEMIES, 0


	Initialise: {
			//TEST
			lda #$01
			ldx #42 //Half value
			ldy #80
			jsr SpawnEnemy

			lda #$02
			ldx #129 //half value
			ldy #120
			jsr SpawnEnemy

			//TEST
			lda #$01
			ldx #22 //Half value
			ldy #60
			jsr SpawnEnemy

			lda #$02
			ldx #29 //half value
			ldy #80
			jsr SpawnEnemy

			//TEST
			lda #$01
			ldx #122 //Half value
			ldy #180
			jsr SpawnEnemy


			rts
	}

	UpdateEnemies: {
			.label ENEMY_BEHAVIOUR = VECTOR1
			.label TEMP = TEMP9

			ldy #MAX_ENEMIES - 1
		!Loop:
			lda EnemyType, y
			beq !Skip+

			sty TEMP
			ldx TEMP
			ldy #BEHAVIOURS.BEHAVIOUR_UPDATE
			jsr CallBehaviour
			ldy TEMP
				
		!Skip:		
			dey
			bpl !Loop-
			rts
	}


	SpawnEnemy: {
			.label SPRITE_X = TEMP1
			pha
			stx SPRITE_X

			//Find next free enemy
			ldx #MAX_ENEMIES - 1
		!Loop:
			lda EnemyType, x
			beq !Found+
			dex
			bpl !Loop-
		!Found:
			//X is our enemy index	
			//Spawn enemy

			//Yposition
			tya 
			sta EnemyPosition_Y1, x
			lda #$00
			sta EnemyPosition_Y0, x

			//XPosition
			lda SPRITE_X
			asl 
			sta EnemyPosition_X1, x
			lda #$00
			rol 
			sta EnemyPosition_X2, x
			lda #$00
			sta EnemyPosition_X0, x

			sta EnemyJumpFallIndex, x
			sta EnemyState, x

			//Type
			pla
			sta EnemyType, x

			//Call on spawn
			ldy #BEHAVIOURS.BEHAVIOUR_SPAWN

			jsr CallBehaviour
			rts
	}




	CallBehaviour: {
			//X = Free index
			//Y = Behaviour offset
			//A = enemy type
			.label BEHAVIOUR_OFFSET = TEMP2
			.label INDEX = TEMP3

			sty BEHAVIOUR_OFFSET
			stx INDEX
			tax
			clc
			lda BEHAVIOURS.EnemyLSB, x
			adc BEHAVIOUR_OFFSET
			sta SelfMod + 1
			lda BEHAVIOURS.EnemyMSB, x
			adc #00
			sta SelfMod + 2

			
			ldx INDEX
		SelfMod:
			jsr $BEEF
			rts
	}




	GetCollisionPoint: {
			//a register contains x offset
			//y register contains y offset

			.label ENEMY_X1 = TEMP5
			.label ENEMY_X2 = TEMP6
			.label X_PIXEL_OFFSET = TEMP7
			.label Y_PIXEL_OFFSET = TEMP8

			.label X_BORDER_OFFSET = $18
			.label Y_BORDER_OFFSET = $32

			sta X_PIXEL_OFFSET
			sty Y_PIXEL_OFFSET

			//Store Enemy position X
			cmp #$80
			bcs !neg+
		!pos:
			clc
			adc EnemyPosition_X1, x
			sta ENEMY_X1
			lda EnemyPosition_X2, x
			adc #$00
			sta ENEMY_X2
			bcc !done+
		!neg:		//TODO potential refactor to reduce duplication
			dec EnemyPosition_X2, x

			clc
			lda EnemyPosition_X1, x
			adc X_PIXEL_OFFSET 
			sta ENEMY_X1

			lda EnemyPosition_X2, x
			adc #$00
			sta ENEMY_X2
		!done:


			//Subtract border width
			lda ENEMY_X1
			sec
			sbc #X_BORDER_OFFSET
			sta ENEMY_X1
			lda ENEMY_X2
			sbc #$00
			sta ENEMY_X2

			//Divide by 8 to get ScreenX
			lda ENEMY_X1
			lsr ENEMY_X2 
			ror 
			lsr
			lsr
			pha //SCREEN X


			//Divide enemy Y by 8 to get ScreenY
			clc
			lda EnemyPosition_Y1, x
			adc Y_PIXEL_OFFSET
			sec
			sbc #Y_BORDER_OFFSET
			lsr
			lsr
			lsr
			tay

			cpy #$16
			bcc !+
			ldy #$15
		!:

			pla

			rts
	}


}		