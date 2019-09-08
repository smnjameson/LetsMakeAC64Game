PLAYER: {
	.label COLLISION_SOLID = %00010000

	.label STATE_JUMP 		= %00000001
	.label STATE_FALL 		= %00000010
	.label STATE_WALK_LEFT  = %00000100
	.label STATE_WALK_RIGHT = %00001000
	.label STATE_FACE_LEFT  = %00010000
	.label STATE_FACE_RIGHT = %00100000

	.label PLAYER_1 = %00000001
	.label PLAYER_2 = %00000010

	.label JOY_UP = %00001
	.label JOY_DN = %00010
	.label JOY_LT = %00100
	.label JOY_RT = %01000
	.label JOY_FR = %10000


	PlayersActive:
			.byte $00

	Player_Projectile_XOffset:
			.byte $20, $08

	Player1_X:
			// Fractional / LSB / MSB
			.byte $00, $48, $00 // 1/256th pixel accuracy
	Player1_Y:
			.byte $70 // 1 pixel accuracy

	Player1_FirePressed:
			.byte $00
	Player1_Proj_Type:
			.byte $00, $00
	Player1_Proj_X0:
			.byte $00, $00
	Player1_Proj_X1:
			.byte $00, $00
	Player1_Proj_X2:
			.byte $00, $00
	Player1_Proj_Y0:
			.byte $00, $00
	Player1_Proj_Y1:
			.byte $00, $00
				

	Player2_X:
			// Fractional / LSB / MSB
			.byte $00, $48, $00 // 1/256th pixel accuracy
	Player2_Y:
			.byte $70 // 1 pixel accuracy

	Player2_FirePressed:
			.byte $00
	Player2_Proj_Type:
			.byte $00, $00
	Player2_Proj_X0:
			.byte $00, $00
	Player2_Proj_X1:
			.byte $00, $00
	Player2_Proj_X2:
			.byte $00, $00
	Player2_Proj_Y0:
			.byte $00, $00
	Player2_Proj_Y1:
			.byte $00, $00

	Player1_FloorCollision:
			.byte $00
	Player1_LeftCollision:
			.byte $00
	Player1_RightCollision:
			.byte $00

	Player2_FloorCollision:
			.byte $00
	Player2_LeftCollision:
			.byte $00
	Player2_RightCollision:
			.byte $00


	Player1_JumpIndex:
			.byte $00
	Player2_JumpIndex:
			.byte $00

	Player1_WalkIndex:
			.byte $00
	Player2_WalkIndex:
			.byte $00

	Player1_State:
			.byte $00
	Player2_State:
			.byte $00

	Player1_WalkSpeed:
			.byte $80, $01
	Player2_WalkSpeed:
			.byte $80, $01

	DefaultFrame:
			.byte $40, $40


	Initialise: {
			lda #$0a
			sta VIC.SPRITE_MULTICOLOR_1
			lda #$09
			sta VIC.SPRITE_MULTICOLOR_2

			lda #$05
			sta VIC.SPRITE_COLOR_0

			lda #$02
			sta VIC.SPRITE_COLOR_1

			lda #$40
			sta SPRITE_POINTERS + 0
			sta SPRITE_POINTERS + 1

			lda VIC.SPRITE_ENABLE 
			ora #%00000011
			sta VIC.SPRITE_ENABLE

			lda VIC.SPRITE_MULTICOLOR
			ora #%00000011
			sta VIC.SPRITE_MULTICOLOR

			lda #[PLAYER_1 + PLAYER_2]
			sta PlayersActive

			lda #STATE_FACE_RIGHT
			sta Player1_State
			sta Player2_State
			rts
	}


	GetCollisions: {

		//Get floor collisions for each foot for Player 1
		lda #$00
		ldx #4
		ldy #20
		jsr PLAYER.GetCollisionPoint

		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		sta Player1_FloorCollision

		
		lda #$00
		ldx #10
		ldy #20
		jsr PLAYER.GetCollisionPoint

		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		ora Player1_FloorCollision
		sta Player1_FloorCollision




		//Get Left Collision
		lda #$00
		ldx #0
		ldy #11
		jsr PLAYER.GetCollisionPoint
		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		sta Player1_LeftCollision

		lda #$00
		ldx #0
		ldy #18
		jsr PLAYER.GetCollisionPoint
		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		ora Player1_LeftCollision
		sta Player1_LeftCollision


		//Get Right Collision
		lda #$00
		ldx #13
		ldy #11
		jsr PLAYER.GetCollisionPoint
		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		sta Player1_RightCollision

		lda #$00
		ldx #13
		ldy #18
		jsr PLAYER.GetCollisionPoint
		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		ora Player1_RightCollision
		sta Player1_RightCollision










		//Get floor collisions for each foot player 2
		lda #$01
		ldx #4
		ldy #20
		jsr PLAYER.GetCollisionPoint

		

		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		sta Player2_FloorCollision

		
		lda #$01
		ldx #10
		ldy #20
		jsr PLAYER.GetCollisionPoint

		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		ora Player2_FloorCollision
		sta Player2_FloorCollision


		//Get Left Collision
		lda #$01
		ldx #0
		ldy #11
		jsr PLAYER.GetCollisionPoint
		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		sta Player2_LeftCollision

		lda #$01
		ldx #0
		ldy #18
		jsr PLAYER.GetCollisionPoint
		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		ora Player2_LeftCollision
		sta Player2_LeftCollision



		//Get Right Collision
		lda #$01
		ldx #13
		ldy #11
		jsr PLAYER.GetCollisionPoint
		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		sta Player2_RightCollision

		lda #$01
		ldx #13
		ldy #18
		jsr PLAYER.GetCollisionPoint
		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		ora Player2_RightCollision
		sta Player2_RightCollision

		rts
	}



	GetCollisionPoint: {
			//x register contains x offset (half value)
			//y register contains y offset

			.label PLAYER_POSITION = TEMP1
			.label X_PIXEL_OFFSET = TEMP3
			.label Y_PIXEL_OFFSET = TEMP4

			.label X_BORDER_OFFSET = $18
			.label Y_BORDER_OFFSET = $32

			.label PLAYER_X = VECTOR1
			.label PLAYER_Y = VECTOR2


			stx X_PIXEL_OFFSET
			sty Y_PIXEL_OFFSET

			cmp #$00 //Is player one?
			bne !Player2Setup+

		!Player1Setup:
			lda #<Player1_X
			sta PLAYER_X
			lda #>Player1_X
			sta PLAYER_X + 1
			lda #<Player1_Y
			sta PLAYER_Y
			lda #>Player1_Y
			sta PLAYER_Y + 1
			jmp !PlayerSetupComplete+

		!Player2Setup:
			lda #<Player2_X
			sta PLAYER_X
			lda #>Player2_X
			sta PLAYER_X + 1
			lda #<Player2_Y
			sta PLAYER_Y
			lda #>Player2_Y
			sta PLAYER_Y + 1

		!PlayerSetupComplete:

			//Store Player position X
			ldy #$01
			lda (PLAYER_X), y
			sta PLAYER_POSITION
			iny
			lda (PLAYER_X), y
			sta PLAYER_POSITION + 1
		
			//Add sprite offset X
			lda PLAYER_POSITION
			clc
			adc X_PIXEL_OFFSET
			sta PLAYER_POSITION
			lda PLAYER_POSITION + 1
			adc #$00
			sta PLAYER_POSITION + 1

			//Subtract border width
			lda PLAYER_POSITION
			sec
			sbc #X_BORDER_OFFSET
			sta PLAYER_POSITION
			lda PLAYER_POSITION + 1
			sbc #$00
			sta PLAYER_POSITION + 1

			
			//Divide by 8 to get ScreenX
			lda PLAYER_POSITION
			lsr PLAYER_POSITION + 1
			ror 
			lsr
			lsr
			tax


			//Divide player Y by 8 to get ScreenY
			ldy #$00
			lda (PLAYER_Y), y
			clc
			adc Y_PIXEL_OFFSET
			sec
			sbc #Y_BORDER_OFFSET
			lsr
			lsr
			lsr
			tay

			rts
	}





	DrawPlayer: {
		.label PlayerState = VECTOR1
		.label PlayerWalkIndex = VECTOR2
		.label PlayerX = VECTOR3
		.label PlayerY = VECTOR4

		.label CURRENT_PLAYER = TEMP1
		.label CURRENT_FRAME = TEMP2


		lda #$02
		sta CURRENT_PLAYER

		!Loop:
			lda CURRENT_PLAYER
			cmp #$01
			bne !Player2+
		!Player1:
			lda #<Player1_State
			sta PlayerState
			lda #>Player1_State
			sta PlayerState + 1

			lda #<Player1_WalkIndex
			sta PlayerWalkIndex
			lda #>Player1_WalkIndex
			sta PlayerWalkIndex + 1

			lda #<Player1_X
			sta PlayerX
			lda #>Player1_X
			sta PlayerX + 1

			lda #<Player1_Y
			sta PlayerY
			lda #>Player1_Y
			sta PlayerY + 1

			jmp !PlayerSetupComplete+

		!Player2:
			lda #<Player2_State
			sta PlayerState
			lda #>Player2_State
			sta PlayerState + 1

			lda #<Player2_WalkIndex
			sta PlayerWalkIndex
			lda #>Player2_WalkIndex
			sta PlayerWalkIndex + 1

			lda #<Player2_X
			sta PlayerX
			lda #>Player2_X
			sta PlayerX + 1

			lda #<Player2_Y
			sta PlayerY
			lda #>Player2_Y
			sta PlayerY + 1

		!PlayerSetupComplete:


			//Set player frame
				ldx CURRENT_PLAYER
				dex
				lda DefaultFrame, x   //Default idle frame
				sta CURRENT_FRAME

				ldy #$00
				lda (PlayerState), y
				and #[STATE_WALK_RIGHT + STATE_WALK_LEFT]
				beq !SetFrame+
				lda (PlayerState), y
				and #[STATE_JUMP + STATE_FALL]
				bne !SetFrame+

				lda (PlayerWalkIndex), y
				tax
				lda ZP_COUNTER
				and #$03
				bne !Skip+
				inx
				cpx #[TABLES.__PlayerWalkLeft - TABLES.PlayerWalkLeft]
				bne !+
				ldx #$00
			!:
				txa 
				sta (PlayerWalkIndex), y
			!Skip:



				lda (PlayerState), y
				and #[STATE_WALK_RIGHT]	
				bne !Right+
			!Left:
				lda TABLES.PlayerWalkLeft, x
				sta CURRENT_FRAME

				jmp !SetFrame+

			!Right:
				lda TABLES.PlayerWalkRight, x
				sta CURRENT_FRAME

			!SetFrame:
				lda CURRENT_FRAME
				ldx CURRENT_PLAYER
				sta [SPRITE_POINTERS - 1], x

				//Set player position X & Y
				ldy #$01

				dex
				txa //Convert to sprite X,Y offsets
				asl
				tax

				lda (PlayerX), y
				sta VIC.SPRITE_0_X, x 
				iny

				txa
				pha

				ldx CURRENT_PLAYER
				dex

				lda (PlayerX), y
				beq !+

				lda VIC.SPRITE_MSB
				ora TABLES.PowerOfTwo, x
				jmp !EndMSB+
			!:
				lda VIC.SPRITE_MSB
				and TABLES.InvPowerOfTwo, x

			!EndMSB:
				sta VIC.SPRITE_MSB


				pla
				tax
				ldy #$00
				lda (PlayerY), y
				sta VIC.SPRITE_0_Y, x


			dec CURRENT_PLAYER
			beq !+
			jmp !Loop-
		!:



			rts
	}


	CheckPlayer1CanShoot: {
			//Returns in X register: -1 if no available slot for new projectile
			//otherwise returns the index (0 or 1)
			ldx #$00
			lda Player1_Proj_Type, x
			bne !+
			rts
		!:
			inx
			lda Player1_Proj_Type, x
			bne !+
			rts
		!:
			ldx #$ff
			rts
	}


	CheckPlayer2CanShoot: {
			//Returns in X register: -1 if no available slot for new projectile
			//otherwise returns the index (0 or 1)
			ldx #$00
			lda Player2_Proj_Type, x
			bne !+
			rts
		!:
			inx
			lda Player2_Proj_Type, x
			bne !+
			rts
		!:
			ldx #$ff
			rts
	}


	PlayerControl: {
		jsr Player1Control
		jsr Player2Control
		rts
	}


	Player1Control: {
			.label JOY_PORT_2 = $dc00

			lda JOY_PORT_2
			sta JOY_ZP1

			lda Player1_State	
			and #[255 - STATE_WALK_RIGHT - STATE_WALK_LEFT]
			sta Player1_State


		!Fire:
			lda JOY_ZP1
			and #JOY_FR
			beq !FirePressed+
			lda #$00
			sta Player1_FirePressed	
			jmp !+

		!FirePressed:
			lda Player1_FirePressed	
			bne !+
			lda #$01
			sta Player1_FirePressed	
			jsr CheckPlayer1CanShoot
			bmi !+

			//Set the player projectile values
			lda #$01
			sta Player1_Proj_Type, x
			lda #$00
			sta Player1_Proj_X0, x
			sta Player1_Proj_Y0, x

			lda Player1_State
			and #$30
			lsr
			lsr
			lsr
			lsr
			tay
			dey


			//Subtract the LEFT border + Projectile Offset
			lda Player1_X + 1
			sec
			sbc Player_Projectile_XOffset, y 	//Subtract border but include x offset
			sta Player1_Proj_X1, x
			lda Player1_X + 2
			sbc #$00
			sta Player1_Proj_X2, x


			//Subtract the top border
			lda Player1_Y
			sec
			sbc #$30
			clc
			adc #$07 //Y Offset to move to player eye level
			sta Player1_Proj_Y1, x


			//Create the sprite
			lda Player1_Proj_X2, x
			cmp #$01
			lda Player1_Proj_X1, x
			sta TEMP1

			lda Player1_Proj_Type, x
			ldy Player1_Proj_Y1, x
			ldx TEMP1

			jsr SOFTSPRITES.AddSprite
			tax
			lda #$0f
			sta SOFTSPRITES.SpriteColor, X


			///

		!:


		!Up:
			lda Player1_State
			and #[STATE_FALL + STATE_JUMP]
			bne !+
			lda JOY_ZP1 
			and #JOY_UP
			bne !+
			lda Player1_State
			ora #STATE_JUMP
			sta Player1_State
			lda #$00
			sta Player1_JumpIndex
			jmp !Left+
		!:


		!Left:
			lda JOY_ZP1
			and #JOY_LT
			bne !+

			lda Player1_LeftCollision
			and #COLLISION_SOLID
			bne !+

			sec
			lda Player1_X
			sbc Player1_WalkSpeed
			sta Player1_X
			lda Player1_X + 1
			sbc Player1_WalkSpeed + 1
			sta Player1_X + 1
			lda Player1_X + 2
			sbc #$00
			sta Player1_X + 2

			lda Player1_State
			and #[255 - STATE_FACE_LEFT - STATE_FACE_RIGHT]
			ora #[STATE_WALK_LEFT + STATE_FACE_LEFT]
			sta Player1_State
			lda #80
			sta DefaultFrame
			jmp !Right+
		!:



		!Right:
			lda JOY_ZP1
			and #JOY_RT
			bne !+

			lda Player1_RightCollision
			and #COLLISION_SOLID
			bne !+

			clc
			lda Player1_X
			adc Player1_WalkSpeed
			sta Player1_X
			lda Player1_X + 1
			adc Player1_WalkSpeed + 1
			sta Player1_X + 1
			lda Player1_X + 2
			adc #$00
			sta Player1_X + 2

			lda Player1_State
			and #[255 - STATE_FACE_LEFT - STATE_FACE_RIGHT]
			ora #[STATE_WALK_RIGHT + STATE_FACE_RIGHT]
			sta Player1_State

			lda #64
			sta DefaultFrame
	
		!:
			rts
	}



	Player2Control: {
			.label JOY_PORT_1 = $dc01

			lda JOY_PORT_1
			sta JOY_ZP2

			lda Player2_State	
			and #[255 - STATE_WALK_RIGHT - STATE_WALK_LEFT]
			sta Player2_State

		!Fire:
			lda JOY_ZP2
			and #JOY_FR
			beq !FirePressed+
			lda #$00
			sta Player2_FirePressed	
			jmp !+

		!FirePressed:
			lda Player2_FirePressed	
			bne !+
			lda #$01
			sta Player2_FirePressed	
			jsr CheckPlayer2CanShoot
			bmi !+

			//Set the player projectile values
			lda #$01
			sta Player2_Proj_Type, x
			lda #$00
			sta Player2_Proj_X0, x
			sta Player2_Proj_Y0, x

			lda Player2_State
			and #$30
			lsr
			lsr
			lsr
			lsr
			tay
			dey


			//Subtract the LEFT border + Projectile Offset
			lda Player2_X + 1
			sec
			sbc Player_Projectile_XOffset, y 	//Subtract border but include x offset
			sta Player2_Proj_X1, x
			lda Player2_X + 2
			sbc #$00
			sta Player2_Proj_X2, x


			//Subtract the top border
			lda Player2_Y
			sec
			sbc #$30
			clc
			adc #$07 //Y Offset to move to player eye level
			sta Player2_Proj_Y1, x


			//Create the sprite
			lda Player2_Proj_X2, x
			cmp #$01
			lda Player2_Proj_X1, x
			sta TEMP1

			lda Player2_Proj_Type, x
			ldy Player2_Proj_Y1, x
			ldx TEMP1

			jsr SOFTSPRITES.AddSprite
			tax
			lda #$0f
			sta SOFTSPRITES.SpriteColor, X
			///

		!:


		!Up:
			lda Player2_State
			and #[STATE_FALL + STATE_JUMP]
			bne !+
			lda JOY_ZP2	
			and #JOY_UP
			bne !+
			lda Player2_State
			ora #STATE_JUMP
			sta Player2_State
			lda #$00
			sta Player2_JumpIndex
			jmp !Left+
		!:


		!Left:
			lda JOY_ZP2
			and #JOY_LT
			bne !+

			lda Player2_LeftCollision
			and #COLLISION_SOLID
			bne !+		

			sec
			lda Player2_X
			sbc Player2_WalkSpeed
			sta Player2_X
			lda Player2_X + 1
			sbc Player2_WalkSpeed + 1
			sta Player2_X + 1
			lda Player2_X + 2
			sbc #$00
			sta Player2_X + 2

			lda Player2_State
			and #[255 - STATE_FACE_LEFT - STATE_FACE_RIGHT]
			ora #[STATE_WALK_LEFT + STATE_FACE_LEFT]
			sta Player2_State
			lda #80
			sta DefaultFrame + 1
			jmp !Right+
		!:


		!Right:
			lda JOY_ZP2
			and #JOY_RT
			bne !+

			lda Player2_RightCollision
			and #COLLISION_SOLID
			bne !+		

			clc
			lda Player2_X
			adc Player2_WalkSpeed
			sta Player2_X
			lda Player2_X + 1
			adc Player2_WalkSpeed + 1
			sta Player2_X + 1
			lda Player2_X + 2
			adc #$00
			sta Player2_X + 2

			lda Player2_State
			and #[255 - STATE_FACE_LEFT - STATE_FACE_RIGHT]
			ora #[STATE_WALK_RIGHT + STATE_FACE_RIGHT]
			sta Player2_State
			lda #64
			sta DefaultFrame + 1
	
		!:
			rts
	}




	JumpAndFall: {
			.label PlayerState = VECTOR1
			.label PlayerFloorCollision = VECTOR2
			.label PlayerJumpIndex = VECTOR3
			.label PlayerY = VECTOR4

			.label CURRENT_PLAYER = TEMP1

		lda #$02
		sta CURRENT_PLAYER

		!Loop:
			lda CURRENT_PLAYER
			cmp #$01
			bne !Player2+
		!Player1:
			lda #<Player1_State
			sta PlayerState
			lda #>Player1_State
			sta PlayerState + 1

			lda #<Player1_FloorCollision
			sta PlayerFloorCollision
			lda #>Player1_FloorCollision
			sta PlayerFloorCollision + 1

			lda #<Player1_JumpIndex
			sta PlayerJumpIndex
			lda #>Player1_JumpIndex
			sta PlayerJumpIndex + 1

			lda #<Player1_Y
			sta PlayerY
			lda #>Player1_Y
			sta PlayerY + 1

			jmp !PlayerSetupComplete+
		!Player2:
			lda #<Player2_State
			sta PlayerState
			lda #>Player2_State
			sta PlayerState + 1

			lda #<Player2_FloorCollision
			sta PlayerFloorCollision
			lda #>Player2_FloorCollision
			sta PlayerFloorCollision + 1

			lda #<Player2_JumpIndex
			sta PlayerJumpIndex
			lda #>Player2_JumpIndex
			sta PlayerJumpIndex + 1

			lda #<Player2_Y
			sta PlayerY
			lda #>Player2_Y
			sta PlayerY + 1

		!PlayerSetupComplete:
		


			ldy #$00
			lda (PlayerState), y
			and #STATE_JUMP
			bne !ExitFallingCheck+

		!FallCheck:
			lda (PlayerFloorCollision),y
			and #COLLISION_SOLID
			bne !NotFalling+

		!Falling:
			lda (PlayerState), y
			and #STATE_FALL
			bne !ExitFallingCheck+
			lda (PlayerState), y
			ora #STATE_FALL
			sta (PlayerState), y
			lda #[TABLES.__JumpAndFallTable - TABLES.JumpAndFallTable - 1]
			sta (PlayerJumpIndex), y
			jmp !ExitFallingCheck+

		!NotFalling:		
			lda (PlayerState), y
			and #STATE_FALL
			beq !+
			lda (PlayerY), y
			sec
			sbc #$06
			and #$f8
			ora #$06
			sta (PlayerY), y
		!:

			lda (PlayerState), y
			and #[255 - STATE_FALL]
			sta (PlayerState), y
		!ExitFallingCheck:




		!ApplyFallOrJump:
			lda (PlayerState), y
			and #STATE_FALL
			beq !Skip+


			lda (PlayerJumpIndex), y
			tax
			lda TABLES.JumpAndFallTable, x
			clc
			adc (PlayerY), y
			sta (PlayerY), y
			dex
			bpl !+
			ldx #$00
		!:	
			txa
			sta (PlayerJumpIndex), y
		!Skip:



			lda (PlayerState), y
			and #STATE_JUMP
			beq !Skip+

			lda (PlayerJumpIndex), y
			tax
			lda (PlayerY), y
			sec
			sbc TABLES.JumpAndFallTable, x
			sta (PlayerY), y
			inx
			cpx #[TABLES.__JumpAndFallTable - TABLES.JumpAndFallTable]
			bne !+
			dex
			lda (PlayerState), y
			and #[255 - STATE_JUMP]
			ora #STATE_FALL
			sta (PlayerState), y
		!:
			txa
			sta (PlayerJumpIndex), y

		!Skip:

			dec CURRENT_PLAYER
			beq !+
			jmp !Loop-
		!:

			rts
	}
}




