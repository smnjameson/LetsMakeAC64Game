.macro PositionEnemy() {
		jsr PositionEnemySR
}

PositionEnemySR: {
		.label INDEX = TEMP8
		.label STOREY = TEMP7


		sty STOREY
		stx INDEX

		lda ENEMIES.EnemyFrame, x
		sta SPRITE_POINTERS + 0, x


		lda ENEMIES.EnemyColor, x
	!Skip:
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


		lda PLAYER.Player_Freeze_Active
		beq !+
		lda PLAYER.FreezeColor
		sta VIC.SPRITE_COLOR_0, x
	!:
		rts
}


UpdatePositionSR01: {
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
		rts
}

CheckScreenEdges: {
		//First check both directions
		//and dont change if both are blocked
		:getEnemyCollisions(8, 15)
		tay
		lda CHAR_COLORS, y
		and #UTILS.COLLISION_SOLID
		sta BEHAVIOUR_TEMP1
		:getEnemyCollisions(16, 15)
		tay
		lda CHAR_COLORS, y
		and #UTILS.COLLISION_SOLID
		and BEHAVIOUR_TEMP1
		beq !CheckLeft+
		jmp !Done+
		
	!CheckLeft:
		lda ENEMIES.EnemyState, x
		and #ENEMIES.STATE_WALK_LEFT
		beq !CheckRight+

		:getEnemyCollisions(8, 15)
		tay
		lda CHAR_COLORS, y
		and #UTILS.COLLISION_SOLID
		bne !Change+

		lda ENEMIES.EnemyPosition_X2, x
		bne !Done+
		lda ENEMIES.EnemyPosition_X1, x
		cmp #$18
		bcs !Done+


	!Change:
		//ChangeDir
		lda ENEMIES.EnemyState, x
		and #[255 -[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]]
		ora #[ENEMIES.STATE_FACE_RIGHT + ENEMIES.STATE_WALK_RIGHT]
		sta ENEMIES.EnemyState, x

		lda #$00
		rts

	!CheckRight:
		lda ENEMIES.EnemyState, x
		and #ENEMIES.STATE_WALK_RIGHT
		beq !Done+

		:getEnemyCollisions(16, 15)
		tay
		lda CHAR_COLORS, y
		and #UTILS.COLLISION_SOLID
		bne !Change+

		lda ENEMIES.EnemyPosition_X2, x
		beq !Done+
		lda ENEMIES.EnemyPosition_X1, x
		cmp #$40
		bcc !Done+

	!Change:
		//ChangeDir
		lda ENEMIES.EnemyState, x
		and #[255 -[ENEMIES.STATE_FACE_RIGHT + ENEMIES.STATE_WALK_RIGHT]]
		ora #[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]
		sta ENEMIES.EnemyState, x

		lda #$00
		rts

	!Done:
		lda #$01
		rts
}
ChangeDirToRight: {
	lda ENEMIES.EnemyState, x
	and #[255 -[ENEMIES.STATE_FACE_LEFT + ENEMIES.STATE_WALK_LEFT]]
	ora #[ENEMIES.STATE_FACE_RIGHT + ENEMIES.STATE_WALK_RIGHT]
	sta ENEMIES.EnemyState, x
	rts
}


UpdatePositionSR02: {
		clc
		lda ENEMIES.EnemyPosition_X0, x
		adc UPDATE_POSITION_TEMP + 0
		sta ENEMIES.EnemyPosition_X0, x 
		lda ENEMIES.EnemyPosition_X1, x
		adc UPDATE_POSITION_TEMP + 1
		sta ENEMIES.EnemyPosition_X1, x 
		lda ENEMIES.EnemyPosition_X2, x
		adc #$00
		sta ENEMIES.EnemyPosition_X2, x 
		rts
}
UpdatePositionSR03: {
		sec
		lda ENEMIES.EnemyPosition_X0, x
		sbc UPDATE_POSITION_TEMP + 0
		sta ENEMIES.EnemyPosition_X0, x 
		lda ENEMIES.EnemyPosition_X1, x
		sbc UPDATE_POSITION_TEMP + 1
		sta ENEMIES.EnemyPosition_X1, x 
		lda ENEMIES.EnemyPosition_X2, x
		sbc #$00
		sta ENEMIES.EnemyPosition_X2, x	
		rts
}
UpdatePositionSR04: {
		clc
		lda ENEMIES.EnemyPosition_Y0, x
		adc UPDATE_POSITION_TEMP + 0
		sta ENEMIES.EnemyPosition_Y0, x 
		lda ENEMIES.EnemyPosition_Y1, x
		adc UPDATE_POSITION_TEMP + 1
		sta ENEMIES.EnemyPosition_Y1, x 
		rts
}
UpdatePositionSR05: {
		sec
		lda ENEMIES.EnemyPosition_Y0, x
		sbc UPDATE_POSITION_TEMP + 0
		sta ENEMIES.EnemyPosition_Y0, x 
		lda ENEMIES.EnemyPosition_Y1, x
		sbc UPDATE_POSITION_TEMP + 1
		sta ENEMIES.EnemyPosition_Y1, x	
		rts
}

.macro UpdatePosition(xpos, ypos) {
		pha
		lda PLAYER.Player_Freeze_Active
		beq !+
		pla
		jmp !EndMacro+
	!:
		pla
	.if(xpos == null && ypos == null) {
		jsr UpdatePositionSR01
	} else { 

		.if(xpos > 0) {
			lda #<xpos
			sta UPDATE_POSITION_TEMP + 0
			lda #>xpos
			sta UPDATE_POSITION_TEMP + 1
			jsr UpdatePositionSR02
		}
		.if(xpos < 0) {
			.eval xpos = xpos * -1
			lda #<xpos
			sta UPDATE_POSITION_TEMP + 0
			lda #>xpos
			sta UPDATE_POSITION_TEMP + 1			 
			jsr UpdatePositionSR03
		}	

		.if(ypos > 0) {
			lda #<ypos
			sta UPDATE_POSITION_TEMP + 0
			lda #>ypos
			sta UPDATE_POSITION_TEMP + 1
			jsr UpdatePositionSR04
		} 
		.if(ypos < 0) {
			.eval ypos = ypos * -1
			lda #<ypos
			sta UPDATE_POSITION_TEMP + 0
			lda #>ypos
			sta UPDATE_POSITION_TEMP + 1

			jsr UpdatePositionSR05
		}	
	}
	!EndMacro:
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
	!Set:
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
		.if(xoffset != null) {
			lda #xoffset
			ldy #yoffset
		}	
		jsr getEnemyCollisionsSR
}

getEnemyCollisionsSR: {
		.label TEMP = TEMP8

		jsr ENEMIES.GetCollisionPoint

 		stx TEMP
		tax
		jsr UTILS.GetCharacterAt

	!End:
		ldx TEMP
		rts
}


.macro doFall(xcheck, ycheck) {
		:getEnemyCollisions(xcheck, ycheck)
		jsr doFallSR
}

doFallSR: {
		tay
		lda CHAR_COLORS, y
		bit TABLES.Plus + UTILS.COLLISION_COLORABLE
		beq !Fall+

		bit TABLES.Plus + UTILS.COLLISION_SWITCH
		beq !+
		sta ENEMIES.EnemyOnSwitch
	!:

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
		rts
}

snapEnemyToFloor: {
		lda ENEMIES.EnemyPosition_Y1, x
		sec
		sbc #$02
		and #$f8
		ora #$03
		sta ENEMIES.EnemyPosition_Y1, x
		rts
}

.macro hasHitProjectile() {
		jsr CheckVsProjectiles
}

// .macro exitIfStunned() {
// 		jsr exitIfStunnedSR
// }

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

// exitIfStunnedSR: {
// 		lda ENEMIES.EnemyState, x 
// 		and #ENEMIES.STATE_STUNNED
// 		beq !Exit+
// 		pla
// 		pla
// 		lda ENEMIES.EnemyEatenBy, x
// 		beq !+
// 		jmp BEHAVIOURS.AbsorbBehaviour.update
// 	!:
// 		jmp CheckVsPlayerEat
// 	!Exit:
// 		rts
// }

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
		bcc !Skip1+
		jmp !End+
	!Skip1:

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
		// rts
		
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
		:playSFX(SOUND.PlayerHit)
		
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