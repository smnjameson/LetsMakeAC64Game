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

	EnemyTotalCount:
		.byte $00

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

	EnemyEatenBy:
		.fill MAX_ENEMIES, 0
	EnemyEatenIndex:
		.fill MAX_ENEMIES, 0
	EnemyEatenCounter:
		.fill MAX_ENEMIES, 0
	EnemyEatOffsetX:
		.fill MAX_ENEMIES, 0
	EnemyEatOffsetY:
		.fill MAX_ENEMIES, 0
	EnemyEatPointerLSB:
		.fill MAX_ENEMIES, 0
	EnemyEatPointerMSB:
		.fill MAX_ENEMIES, 0


	EnemyStaticMemory:
		.fill STATIC_MEMORY_SIZE * MAX_ENEMIES, 0


	Initialise: {
			rts
	}


	UpdateEnemies: {
			.label ENEMY_BEHAVIOUR = VECTOR1
			.label TEMP = TEMP11

			ldy #MAX_ENEMIES - 1
		!Loop:
			lda EnemyType, y
			bne !Active+
		//EnemyIsNotActive
			lda VIC.SPRITE_ENABLE
			and TABLES.InvPowerOfTwo, y
			sta VIC.SPRITE_ENABLE	
			jmp !Skip+

		!Active:
		//EnemyIsActive
			lda VIC.SPRITE_ENABLE
			ora TABLES.PowerOfTwo, y
			sta VIC.SPRITE_ENABLE
			lda EnemyType, y
			sty TEMP
			ldx TEMP
			ldy #BEHAVIOURS.BEHAVIOUR_UPDATE
			jsr CallBehaviour
			ldy TEMP
			jsr CheckPlayerCollision
			ldy TEMP
				
		!Skip:		
			dey
			bpl !Loop-

			rts
	}

	CheckPlayerCollision: {
		//Y is the current enemy
			.label Sprite1_X = COLLISION_POINT_X
			.label Sprite1_Y = COLLISION_POINT_Y
			.label Sprite2_X = COLLISION_POINT_X1
			.label Sprite2_Y = COLLISION_POINT_Y1

			.label Sprite1_W = COLLISION_WIDTH
			.label Sprite2_W = COLLISION_WIDTH1
			.label Sprite1_H = COLLISION_HEIGHT
			.label Sprite2_H = COLLISION_HEIGHT1

			.label Sprite1_XOFF = COLLISION_POINT_X_OFFSET
			.label Sprite2_XOFF = COLLISION_POINT_X1_OFFSET
			.label Sprite1_YOFF = COLLISION_POINT_Y_OFFSET
			.label Sprite2_YOFF = COLLISION_POINT_Y1_OFFSET
		ldx #$01
	!Loop:
			
		//Define player dimenisons
			//Player 1
			// lda PLAYER.Player1_State
			// and #[PLAYER.STATE_EATING]
			// bne !+
			lda PLAYER.Player_IsDying, x
			beq !+
			jmp !Next+
		!:
			lda PLAYER.Player_Invuln, x
			beq !+	
			jmp !Next+
		!:

			cpx #$01
			beq !Player2+
		!Player1:
			lda #<PLAYER.Player1_X
			sta Sprite2_X + 0
			lda #>PLAYER.Player1_X
			sta Sprite2_X + 1 

			lda #<PLAYER.Player1_Y
			sta Sprite2_Y + 0
			lda #>PLAYER.Player1_Y
			sta Sprite2_Y + 1 
			jmp !DeterminedPlayer+

		!Player2:
			lda #<PLAYER.Player2_X
			sta Sprite2_X + 0
			lda #>PLAYER.Player2_X
			sta Sprite2_X + 1 

			lda #<PLAYER.Player2_Y
			sta Sprite2_Y + 0
			lda #>PLAYER.Player2_Y
			sta Sprite2_Y + 1 
		!DeterminedPlayer:

			lda #$04
			sta Sprite2_XOFF
			lda #$10
			sta Sprite2_W

			lda #$06
			sta Sprite2_YOFF
			lda #$0f 
			sta Sprite2_H


			lda EnemyState, y
			and #[STATE_STUNNED]
			beq !+
			jmp !Next+
		!:

			//Inefficient copy due to enemy data format
			lda EnemyPosition_X1, y
			sta EnemyXCopy + 1
			lda EnemyPosition_X2, y
			sta EnemyXCopy + 2
			lda EnemyPosition_Y1, y
			sta EnemyYCopy

			lda #<EnemyXCopy
			sta Sprite1_X + 0
			lda #>EnemyXCopy
			sta Sprite1_X + 1

			lda #<EnemyYCopy
			sta Sprite1_Y + 0
			lda #>EnemyYCopy
			sta Sprite1_Y + 1

			lda #$04
			sta Sprite1_XOFF
			lda #$10
			sta Sprite1_W
			lda #$06
			sta Sprite1_YOFF				
			lda #$15
			sta Sprite1_H

			sty ENEMY_COLLISION_TEMP1
			jsr UTILS.GetSpriteCollision
			ldy ENEMY_COLLISION_TEMP1

			bcc !+	

				//Initiate a jump for death anim
				lda PLAYER.Player1_State, x
				and #[255 - (STATE_FALL + STATE_JUMP)]
				ora #STATE_JUMP
				sta PLAYER.Player1_State, x
				lda #$00
				sta PLAYER.Player1_JumpIndex, x	

			lda #$01
			sta PLAYER.Player_IsDying, x
			//Check if we have crown
			sty ENEMY_COLLISION_TEMP1
			txa 
			tay
			jsr CROWN.DropCrown
			ldy ENEMY_COLLISION_TEMP1

		!:
		!Next:
			dex
			bmi !+
			jmp !Loop-
		!:
			rts
	}

	EnemyXCopy:
		.byte $00,$00,$00	
	EnemyYCopy:
		.byte $00
		

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
			//No free enemy so restore stack and exit
			pla 
			rts 

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
			sta EnemyFrame, x
			sta EnemyColor, x
			sta EnemyStunTimer, x
			sta EnemyEatenBy, x
			sta EnemyEatenIndex, x
			sta EnemyEatenCounter, x

			//Type
			pla
			sta EnemyType, x

			inc EnemyTotalCount

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
			sty $eebf
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
		SelfMod: //TODO : Investigate re: CPU JAM
					//seems to be incorrect x index
					//CPU JAM #1 addr was set to $771e
					//CPU JAM #2 addr was set to $BD7F
* = * "Behaviour self mod"
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