CROWN: {
	*=* "CROWN"
	PlayerHasCrown:
			.byte $00

	Crown_X:
			.byte $00, $6a, $00
	Crown_Y:
			.byte $31
	CrownFallIndex:
			.byte $00
	CrownAvailable:
			.byte $00


	Initialise: {
			// lda #$46
			// sta SPRITE_POINTERS + 5	
			lda #$00
			sta CrownAvailable
			rts
	}

	DrawCrown: {
		/*
		 hayesmaker64: because it would be quite funny 
		 if the crown fell off when you opened your mouth 
		 to eat... making it possible for the other player
		 to grab it.. and take an advantage somehow
		 */
		 	//Enable crown if it is active
			//Crown sprite
			lda CrownAvailable
			bne !+
			rts

		!:
			lda PlayerHasCrown	
			bpl !+
			jmp !NoCrown+
		!:

		!Crown:

			lda $d015
			ora #%00100000
			sta $d015
			lda PlayerHasCrown
			bne !+
			lda #$8e
			jmp !ApplyCrown+
		!:
			tay
			dey
				//Disable if player exiting
				lda PLAYER.Player_ExitIndex, y
				bmi !+
				lda $d015
				and #%11011111
				sta $d015			
		!:

			sty CROWN_OFFSET_TEMP1
			lda PLAYER.Player1_State, y
			and #[PLAYER.STATE_FACE_LEFT]
			bne !FaceLeft+
		!FaceRight:
			lda #$47
			jmp !ApplyCrown+
		!FaceLeft:
			lda #$46
		!ApplyCrown:
			sta SPRITE_POINTERS + 5
		!NotOnPlayer:
			

			//Now attach crown to player
			lda PlayerHasCrown   //0, 1 or 2
			asl
			tax
			lda CrownPosTableX + 0, x
			sta CROWN_POS_X + 0
			lda CrownPosTableX + 1, x
			sta CROWN_POS_X + 1
			lda CrownPosTableY + 0, x
			sta CROWN_POS_Y + 0
			lda CrownPosTableY + 1, x
			sta CROWN_POS_Y + 1


			ldy #$00
			lda (CROWN_POS_Y), y //Y lsb
			sta VIC.SPRITE_5_Y
			tya 
			pha 
				lda #$01
				sta CROWN_THROW_OFFSET_X

				lda PlayerHasCrown 
				beq !SkipThrowOffset+

				//Check for crown offset
				ldy CROWN_OFFSET_TEMP1
				lda PLAYER.Player_State, y
				and #[PLAYER.STATE_THROWING]
				beq !NotThrowingOffset+


				lda PLAYER.Player_ThrowIndex, y
				tay

				lda VIC.SPRITE_5_Y
				sec
				sbc TABLES.PlayerThrowCrownY, y
				sta VIC.SPRITE_5_Y

				lda TABLES.PlayerThrowCrownX, y
				sta CROWN_THROW_OFFSET_X


				jmp !SkipThrowOffset+


				//Adjust the player crown when walking
			!NotThrowingOffset:
				ldy CROWN_OFFSET_TEMP1
				lda PLAYER.Player_State, y
				and #[PLAYER.STATE_WALK_LEFT + PLAYER.STATE_WALK_RIGHT]
				beq !+
				lda PLAYER.Player_WalkIndex, y
				tay
				jmp !FetchedOffset+
			!:
				ldy #$00
			!FetchedOffset:
				//Y is the current walk index
				ldx PlayerHasCrown
				dex
				lda PLAYER.Player_Size, x
				cmp #$02
				bcc !AddBob+
				lda VIC.SPRITE_5_Y
				jmp !NoAddBob+
				
			!AddBob:
				lda VIC.SPRITE_5_Y
				sec
				sbc TABLES.PlayerCrownBob, y
			!NoAddBob:
				ldy PLAYER.Player_Size, x
				sec
				sbc TABLES.PlayerSizeCrownOffset, y
				sta VIC.SPRITE_5_Y


		!SkipThrowOffset:
			ldy CROWN_OFFSET_TEMP1
			lda PLAYER.Player_State, y
			and #[PLAYER.STATE_FACE_LEFT]
			bne !FacingLeft+

		!FacingRight:
			pla
			tay
			iny

			lda (CROWN_POS_X), y
			clc
		 	adc CROWN_THROW_OFFSET_X
			sta CROWN_X
			iny
			lda (CROWN_POS_X), y
			adc #$00
			sta CROWN_X + 1

			lda CROWN_X
			sec
			sbc #$01
			sta CROWN_X
			lda CROWN_X + 1
			sbc #$00
			sta CROWN_X + 1
			jmp !Apply+

		!FacingLeft:
			pla
			tay
			iny

			lda (CROWN_POS_X), y
			sec
		 	sbc CROWN_THROW_OFFSET_X
			sta CROWN_X
			iny
			lda (CROWN_POS_X), y
			sbc #$00
			sta CROWN_X + 1

			lda CROWN_X
			clc
			adc #$01
			sta CROWN_X
			lda CROWN_X + 1
			adc #$00
			sta CROWN_X + 1


		!Apply:
			//Apply new offset values
			lda CROWN_X
			sta VIC.SPRITE_5_X
			lda $d010
			and #%11011111
			tax
			lda CROWN_X + 1
			beq !noMsb+
			txa
			ora #%00100000
			tax
		!noMsb:
			txa
			sta $d010


		// 	lda (CROWN_POS_X), y //X lsb
		// 	clc
		// 	adc CROWN_THROW_OFFSET_X
		// 	sta VIC.SPRITE_5_X

		// 	lda $d010
		// 	and #%11011111
		// 	tax
		// 	iny
		// 	lda (CROWN_POS_X), y //msb
		// 	adc #$00
		// 	beq !noMsb+
		// 	txa
		// 	ora #%00100000
		// 	tax
		// !noMsb:
		// 	txa
		// 	sta $d010

			//Only fall if player doesnt have crown
			lda PlayerHasCrown
			bne !+
			jsr Fall
			jsr PickUp
		!:

			lda VIC.SPRITE_5_Y	
			clc
			adc SCREEN_SHAKE_VAL
			sta VIC.SPRITE_5_Y
			rts



		!NoCrown:
			lda $d015
			and #%11011111
			sta $d015
			rts

		CrownPosTableX:
			.word Crown_X
			.word PLAYER.Player1_X
			.word PLAYER.Player2_X
		CrownPosTableY:
			.word Crown_Y
			.word PLAYER.Player1_Y
			.word PLAYER.Player2_Y
	}


	DropCrown: {
			iny	
			cpy CROWN.PlayerHasCrown
			bne !SkipDrop+

			sty DROP_CROWN_TEMP
			cpy #$01
			bne !Player2+
		!Player1:
			lda #<PLAYER.Player1_X
			sta PLAYER_X_POINTER + 0
			lda #>PLAYER.Player1_X
			sta PLAYER_X_POINTER + 1
			lda #<PLAYER.Player1_Y
			sta PLAYER_Y_POINTER + 0
			lda #>PLAYER.Player1_Y
			sta PLAYER_Y_POINTER + 1
			jmp !PlayerPointerDone+
		!Player2:
			lda #<PLAYER.Player2_X
			sta PLAYER_X_POINTER + 0
			lda #>PLAYER.Player2_X
			sta PLAYER_X_POINTER + 1
			lda #<PLAYER.Player2_Y
			sta PLAYER_Y_POINTER + 0
			lda #>PLAYER.Player2_Y
			sta PLAYER_Y_POINTER + 1		
		!PlayerPointerDone:

			ldy #$00
			lda (PLAYER_X_POINTER), y
			sta CROWN.Crown_X + 0
			iny
			lda (PLAYER_X_POINTER), y
			sta CROWN.Crown_X + 1
			iny
			lda (PLAYER_X_POINTER), y
			sta CROWN.Crown_X + 2
			ldy #$00
			lda (PLAYER_Y_POINTER), y
			sta CROWN.Crown_Y
			lda #$00
			sta CROWN.PlayerHasCrown


			ldy DROP_CROWN_TEMP
		!SkipDrop:
			dey
			rts
	}



	Fall: {
			lda #<Crown_X
			sta COLLISION_POINT_X + 0
			lda #>Crown_X
			sta COLLISION_POINT_X + 1
			lda #<Crown_Y
			sta COLLISION_POINT_Y + 0
			lda #>Crown_Y
			sta COLLISION_POINT_Y + 1


			lda #$0e
			sta COLLISION_POINT_X_OFFSET
			lda #$0a
			sta COLLISION_POINT_Y_OFFSET
			jsr UTILS.GetCollisionPoint

			jsr UTILS.GetCharacterAt
			tax
			lda CHAR_COLORS, x
			and #UTILS.COLLISION_SOLID
			beq !Fall+
		!NotFall:
			lda #[TABLES.__JumpAndFallTable - TABLES.JumpAndFallTable - 1]
			sta CrownFallIndex
			lda Crown_Y
			and #$f8
			ora #$01
			sta Crown_Y

			jmp !FallComplete+
		!Fall:
			ldx CrownFallIndex
			lda Crown_Y
			clc 
			adc TABLES.JumpAndFallTable, x
			sta Crown_Y
			dex 
			bpl !+
			inx
		!:
			stx CrownFallIndex
		!FallComplete:

			rts
	}

	PickUp: {
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

			lda CrownAvailable
			bne !+
			rts
		!:

			//Define crown dimenisons
			lda #<Crown_X
			ldx #>Crown_X
			sta Sprite2_X + 0
			stx Sprite2_X + 1 

			lda #<Crown_Y
			ldx #>Crown_Y
			sta Sprite2_Y + 0
			stx Sprite2_Y + 1 

			lda #$05
			sta Sprite2_XOFF
			lda #$0c
			sta Sprite2_W

			lda #$00
			sta Sprite2_YOFF
			lda #$07 
			sta Sprite2_H



			//Player 1
			lda PLAYER.PlayersActive
			and #$01
			beq !+
			lda PLAYER.Player1_State
			and #[PLAYER.STATE_EATING]
			bne !+
			
			lda PLAYER.Player1_IsDying
			bne !+
	
			lda PLAYER.Player1_Size_Timer
			bne !+

			lda #<PLAYER.Player1_X
			ldx #>PLAYER.Player1_X
			sta Sprite1_X + 0
			stx Sprite1_X + 1

			lda #<PLAYER.Player1_Y
			ldx #>PLAYER.Player1_Y
			sta Sprite1_Y + 0
			stx Sprite1_Y + 1

			lda #$04
			sta Sprite1_XOFF
			lda #$10
			sta Sprite1_W	
			lda #$15
			sta Sprite1_H
			jsr UTILS.GetSpriteCollision
			bcc !+
			lda #$01
			sta PlayerHasCrown
			:playSFX(SOUND.PlayerCrown)
			jmp !Exit+
		!:



			//Player 2
			lda PLAYER.PlayersActive
			and #$02
			beq !+
			lda PLAYER.Player2_State
			and #[PLAYER.STATE_EATING]
			bne !+

			

			lda PLAYER.Player2_IsDying
			bne !+

			lda PLAYER.Player2_Size_Timer
			bne !+

			lda #<PLAYER.Player2_X
			ldx #>PLAYER.Player2_X
			sta Sprite1_X + 0
			stx Sprite1_X + 1

			lda #<PLAYER.Player2_Y
			ldx #>PLAYER.Player2_Y
			sta Sprite1_Y + 0
			stx Sprite1_Y + 1

			lda #$04
			sta Sprite1_XOFF
			lda #$10
			sta Sprite1_W
			// lda #$06
			// sta Sprite1_YOFF				
			lda #$15
			sta Sprite1_H
			jsr UTILS.GetSpriteCollision
			bcc !+
			lda #$02
			sta PlayerHasCrown
			:playSFX(SOUND.PlayerCrown)
			jmp !Exit+
		!:
		

		!Exit:
			rts
	}
}