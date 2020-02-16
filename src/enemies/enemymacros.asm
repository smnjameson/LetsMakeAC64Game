.macro PositionEnemy() {
		.label INDEX = TEMP8
		.label STOREY = TEMP7

		sty STOREY
		stx INDEX

		lda ENEMIES.EnemyFrame, x
		sta SPRITE_POINTERS + 0, x
		lda ENEMIES.EnemyColor, x
		sta VIC.SPRITE_COLOR_0, x

		txa
		tay
		asl
		tax
		lda ENEMIES.EnemyPosition_X1, y
		sta VIC.SPRITE_0_X + [0 * 2], x
		lda ENEMIES.EnemyPosition_Y1, y
		clc
		adc SCREEN_SHAKE_VAL
		sta VIC.SPRITE_0_Y + [0 * 2], x
		ldx INDEX
		ldy ENEMIES.EnemyPosition_X2, x

		lda $d010
		and TABLES.InvPowerOfTwo, x
		cpy #$00
		beq !Skip+
		ora TABLES.PowerOfTwo, x
	!Skip:
		sta $d010
		ldy STOREY
		ldx INDEX
}


.macro UpdatePosition(xpos, ypos) {
	.if(xpos == null && ypos == null) {
		sty TEMP10

		cmp #$80
		bcc !Pos+
		dec ENEMIES.EnemyPosition_X2, x 
	!Pos:
		clc
		adc ENEMIES.EnemyPosition_X1, x
		sta ENEMIES.EnemyPosition_X1, x 
		lda ENEMIES.EnemyPosition_X2, x
		adc #$00
		sta ENEMIES.EnemyPosition_X2, x 
		jmp !Skip+
	!Skip:

		lda TEMP10
		clc
		adc ENEMIES.EnemyPosition_Y1, x
		sta ENEMIES.EnemyPosition_Y1, x 

	} else { 

		.if(xpos > 0) {
			clc
			lda ENEMIES.EnemyPosition_X0, x
			adc #<xpos
			sta ENEMIES.EnemyPosition_X0, x 
			lda ENEMIES.EnemyPosition_X1, x
			adc #>xpos
			sta ENEMIES.EnemyPosition_X1, x 
			lda ENEMIES.EnemyPosition_X2, x
			adc #$00
			sta ENEMIES.EnemyPosition_X2, x 
		}
		.if(xpos < 0) {
			.eval xpos = xpos * -1
			sec
			lda ENEMIES.EnemyPosition_X0, x
			sbc #<xpos
			sta ENEMIES.EnemyPosition_X0, x 
			lda ENEMIES.EnemyPosition_X1, x
			sbc #>xpos
			sta ENEMIES.EnemyPosition_X1, x 
			lda ENEMIES.EnemyPosition_X2, x
			sbc #$00
			sta ENEMIES.EnemyPosition_X2, x 
		}	

		.if(ypos > 0) {
			clc
			lda ENEMIES.EnemyPosition_Y0, x
			adc #<ypos
			sta ENEMIES.EnemyPosition_Y0, x 
			lda ENEMIES.EnemyPosition_Y1, x
			adc #>ypos
			sta ENEMIES.EnemyPosition_Y1, x 
		} 
		.if(ypos < 0) {
			.eval ypos = ypos * -1
			sec
			lda ENEMIES.EnemyPosition_Y0, x
			sbc #<ypos
			sta ENEMIES.EnemyPosition_Y0, x 
			lda ENEMIES.EnemyPosition_Y1, x
			sbc #>ypos
			sta ENEMIES.EnemyPosition_Y1, x 
		}	
	}
}

.macro setEnemyFrame(frame) {
	.if(frame != 0 && frame != null) {
		lda #frame
	}
	sta ENEMIES.EnemyFrame, x
}


.macro setEnemyColor(color, color2) {
	.if(color2 !=  null) {
		lda ZP_COUNTER
		and #$01
		beq !+
		lda #color
		jmp !Skip+
	!:
		lda #color2
	!Skip:
	} else {
		.if(color != 0 && color != null) {
			lda #color
		}
	}
	sta ENEMIES.EnemyColor, x
}

.macro setStaticMemory(index, value) {
	.if(value != null) {
		lda #value
	}
	sta ENEMIES.EnemyStaticMemory + index * ENEMIES.MAX_ENEMIES, x
}


.macro getStaticMemory(index) {
	lda ENEMIES.EnemyStaticMemory + index * ENEMIES.MAX_ENEMIES, x
}



.macro getEnemyCollisions(xoffset, yoffset) {
		.label TEMP = TEMP8
		.if(xoffset != null) {
			lda #xoffset
			ldy #yoffset
		}
		jsr ENEMIES.GetCollisionPoint

 		stx TEMP
		tax
		jsr UTILS.GetCharacterAt

	!End:
		ldx TEMP
}

.macro doFall(xcheck, ycheck) {
		:getEnemyCollisions(xcheck, ycheck)
		tay
		lda CHAR_COLORS, y
		and #UTILS.COLLISION_COLORABLE
		beq !Fall+

		lda ENEMIES.EnemyState, x
		and #[255 - ENEMIES.STATE_FALL]
		sta ENEMIES.EnemyState, x
		clc
		jmp !NoFall+

	!Fall:
		lda ENEMIES.EnemyState, x
		bit TABLES.Plus + ENEMIES.STATE_FALL
		bne !+
		ora #ENEMIES.STATE_FALL
		sta ENEMIES.EnemyState, x
		lda #[TABLES.__JumpAndFallTable -  TABLES.JumpAndFallTable - 1]
		sta ENEMIES.EnemyJumpFallIndex, x

	!:
		lda ENEMIES.EnemyJumpFallIndex, x
		tay 
		lda TABLES.JumpAndFallTable, y
		clc
		adc ENEMIES.EnemyPosition_Y1, x
		sta ENEMIES.EnemyPosition_Y1, x 

		dec ENEMIES.EnemyJumpFallIndex, x
		bpl !+
		lda #$00
		sta ENEMIES.EnemyJumpFallIndex, x	
	!:
		sec 

	!NoFall:
}

.macro snapEnemyToFloor() {
		lda ENEMIES.EnemyPosition_Y1, x
		sec
		sbc #$06
		and #$f8
		ora #$06
		sta ENEMIES.EnemyPosition_Y1, x
}

.macro hasHitProjectile() {
		jsr CheckVsProjectiles
}

.macro exitIfStunned() {
		lda ENEMIES.EnemyState, x 
		and #ENEMIES.STATE_STUNNED
		beq !Exit+
		lda ENEMIES.EnemyEatenBy, x
		beq !+
		jmp BEHAVIOURS.AbsorbBehaviour.update
	!:
		jmp CheckVsPlayerEat
	!Exit:
}

CheckVsPlayerEat: {
		.label X_THRESHOLD = $30
		.label Y_THRESHOLD = $18

		.label PLAYER_X = VECTOR6
		.label XY_DIFF = VECTOR5
		
		ldy #$01	
	!Loop:
		lda PLAYER.Player1_State, y
		sty TEMP10 //Temproary store Y
		and #PLAYER.STATE_EATING
		bne !+
		jmp !End+
	!:
		//Record indirect lookup for player X
		cpy #$00

		beq !+
		lda #<PLAYER.Player2_X
		sta PLAYER_X 
		lda #>PLAYER.Player2_X
		sta PLAYER_X + 1 
		jmp !Skip+
	!:
		lda #<PLAYER.Player1_X
		sta PLAYER_X 
		lda #>PLAYER.Player1_X
		sta PLAYER_X + 1 		
	!Skip:

		

		//Check direction player is facing, and that the enemy is on the correct side
		lda PLAYER.Player1_State, y
		and #PLAYER.STATE_FACE_LEFT
		beq !PlayerFacingRight+

	!PlayerFacingLeft:
		//Check if enemy in front of player
		sec
		ldy #$01
		lda (PLAYER_X), y
		sbc ENEMIES.EnemyPosition_X1, x 
		sta XY_DIFF
		iny
		lda (PLAYER_X), y
		sbc ENEMIES.EnemyPosition_X2, x 
		sta XY_DIFF + 1
		bpl !+
		jmp !End+
	!:
		beq !+
		jmp !End+
	!:

		//Is enemy in range on X
		lda XY_DIFF
		cmp #X_THRESHOLD
		bcs !End+

		//Check if player is in Y range
		ldy TEMP10
		sec
		lda PLAYER.Player1_Y, y
		sbc ENEMIES.EnemyPosition_Y1, x
		sta TEMP9 
		clc
		adc #Y_THRESHOLD
		lsr
		cmp #Y_THRESHOLD
		bcs !End+

		tya
		clc
		adc #$01
		sta ENEMIES.EnemyEatenBy, x //Store which player is eating me
		lda XY_DIFF
		sta ENEMIES.EnemyEatOffsetX, x //Store offset for moving enemy to player
		lda TEMP9
		sta ENEMIES.EnemyEatOffsetY, x //Store offset for moving enemy to player
		jsr BEHAVIOURS.AbsorbBehaviour.setup
		jmp BEHAVIOURS.AbsorbBehaviour.update


	!PlayerFacingRight:
		//Check if enemy in front of player
		sec
		ldy #$01
		lda ENEMIES.EnemyPosition_X1, x 
		sbc (PLAYER_X), y
		sta XY_DIFF
		iny
		lda ENEMIES.EnemyPosition_X2, x 
		sbc (PLAYER_X), y
		sta XY_DIFF + 1
		bmi !End+
		bne !End+

		//Is enemy in range on X
		lda XY_DIFF
		cmp #X_THRESHOLD
		bcs !End+

		//Check if player is in Y range
		ldy TEMP10
		sec
		lda ENEMIES.EnemyPosition_Y1, x 
		sbc PLAYER.Player1_Y, y
		sta TEMP9
		clc
		adc #Y_THRESHOLD
		lsr
		cmp #Y_THRESHOLD
		bcs !End+

		tya
		clc
		adc #$01		
		sta ENEMIES.EnemyEatenBy, x	 //Store which player is eating me
		lda XY_DIFF
		eor #$ff
		adc #$01		
		sta ENEMIES.EnemyEatOffsetX, x //Store offset for moving enemy to player
		lda TEMP9
		eor #$ff
		adc #$01		
		sta ENEMIES.EnemyEatOffsetY, x //Store offset for moving enemy to player
		jsr BEHAVIOURS.AbsorbBehaviour.setup
		jmp BEHAVIOURS.AbsorbBehaviour.update


	!End:
		ldy TEMP10
		dey
		bmi !+
		jmp !Loop-
	!:

		jmp BEHAVIOURS.StunnedBehaviour.update
}


CheckVsProjectiles: {
		ldy #$00
	!Loop:
		lda PROJECTILES.Player1_Proj_Type, y
		beq !Skip+
		//// Y
		lda ENEMIES.EnemyPosition_Y1, x
		sec
		sbc #$32 //Subtract border
		sta TEMP10

		lda PROJECTILES.Player1_Proj_Y1, y
		sec
		sbc TEMP10
		clc
		adc #$08
		cmp #21 + 8
		bcs !Skip+
		//////////////

		/// X
		lda PROJECTILES.Player1_Proj_X2, y
		lsr
		lda PROJECTILES.Player1_Proj_X1, y
		ror
		pha

		lda ENEMIES.EnemyPosition_X2, x
		lsr
		lda ENEMIES.EnemyPosition_X1, x
		ror
		sec
		sbc #$0c //Subtract border
		sta TEMP10 

		pla
		sec
		sbc TEMP10

		clc
		adc #$00	//Start of left edge (inv)
		cmp #$08	//width of collision box
		bcs !Skip+
		jmp !Collide+
		////////////////
	!Skip:
		iny
		cpy #$04
		bne !Loop-
		jmp !+

	!Collide:
		lda ENEMIES.EnemyState, x
		and #%01111100
		ora #%01000000
		sta ENEMIES.EnemyState, x

		lda #$ff
		sta ENEMIES.EnemyStunTimer, x


		txa
		pha 
		tya 
		pha

		lsr 
		tay
		lda #$01
		ldx #$02
		jsr HUD.AddScore	

		pla 
		tay 
		pla 
		tax

		lda #$00
		sta PROJECTILES.Player1_Proj_Type, y
		sta SOFTSPRITES.SpriteData_ID, y

		stx SelfModRestore + 1
		tya 
		tax 
		jsr SOFTSPRITES.ClearSprite
	SelfModRestore:
		ldx #$BB
	!:
		rts
}