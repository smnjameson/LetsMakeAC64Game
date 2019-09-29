ENEMIES: {
	.label MAX_ENEMIES = 5

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


	Initialise: {
			//TEST
			lda #$01
			ldx #100 //Half value
			ldy #80
			jsr SpawnEnemy

			lda #$02
			ldx #129 //half value
			ldy #40
			jsr SpawnEnemy

			rts
	}

	UpdateEnemies: {
			.label ENEMY_BEHAVIOUR = VECTOR1
			.label TEMP = TEMP1

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


}		