* = * "Projectiles"
//Player projectile number in X (0-3)
.macro DestroyPlayerProjectile() {
	lda #$00	
	sta PROJECTILES.Player1_Proj_Type, x
	sta SOFTSPRITES.SpriteData_ID, x
}


PROJECTILES: {

	Player_Proj_Speed_X: //Fractional /LSB
			.byte $80, $02
	Player_Proj_Speed_Y: //Fractional /LSB
			.byte $80, $fe
	Player_Proj_Gravity:
			.byte $18, $00

	// Player_Projectile_Color:
	// Player1_Projectile_Color:
	// 		.byte $0a, $0a
	// Player2_Projectile_Color:
	// 		.byte $0f, $0f

	Player_Projectile_XOffset: //Horizontal spawn offset based on player direction
			.byte $10, $08


	Player1_Proj_Type:	//Index into the cached software sprite types	
			.byte $00, $00
	Player2_Proj_Type:
			.byte $00, $00

	//Positions
	Player1_Proj_X0:
			.byte $00, $00
	Player2_Proj_X0:
			.byte $00, $00

	Player1_Proj_X1:
			.byte $00, $00
	Player2_Proj_X1:
			.byte $00, $00

	Player1_Proj_X2:
			.byte $00, $00
	Player2_Proj_X2:
			.byte $00, $00

	Player1_Proj_Y0:
			.byte $00, $00
	Player2_Proj_Y0:
			.byte $00, $00

	Player1_Proj_Y1:
			.byte $00, $00
	Player2_Proj_Y1:
			.byte $00, $00


	//Projectile speeds
	Player1_Proj_Speed_X0:
			.byte $00, $00
	Player2_Proj_Speed_X0:
			.byte $00, $00

	Player1_Proj_Speed_X1:
			.byte $00, $00
	Player2_Proj_Speed_X1:
			.byte $00, $00

	Player1_Proj_Speed_Y0:
			.byte $00, $00
	Player2_Proj_Speed_Y0:
			.byte $00, $00

	Player1_Proj_Speed_Y1:
			.byte $00, $00
	Player2_Proj_Speed_Y1:
			.byte $00, $00


	Player1_Proj_Direction:
			.byte $00, $00
	Player2_Proj_Direction:
			.byte $00, $00


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



	UpdateProjectiles: {
			ldx #$03
		!Loop:
			lda Player1_Proj_Type, x
			bne !+
			jmp !Skip+
		!:

			lda Player1_Proj_Direction, x
			beq !MovingLeft+

		!MovingRight:
			clc
			lda Player1_Proj_X0, x
			adc Player1_Proj_Speed_X0, x
			sta Player1_Proj_X0, x
			lda Player1_Proj_X1, x
			adc Player1_Proj_Speed_X1, x
			sta Player1_Proj_X1, x
			lda Player1_Proj_X2, x
			adc #$00
			sta Player1_Proj_X2, X

			beq !SkipDestroyCheck+
			lda Player1_Proj_X1, x
			cmp #$3a
			bcc !SkipDestroyCheck+
			:DestroyPlayerProjectile()

		!SkipDestroyCheck:
			jmp !MovingComplete+

		!MovingLeft:
			sec
			lda Player1_Proj_X0, x
			sbc Player1_Proj_Speed_X0, x
			sta Player1_Proj_X0, x
			lda Player1_Proj_X1, x
			sbc Player1_Proj_Speed_X1, x
			sta Player1_Proj_X1, x
			lda Player1_Proj_X2, x
			sbc #$00
			sta Player1_Proj_X2, X

			bpl !+
			:DestroyPlayerProjectile()

		!:

		!MovingComplete:


		//YSpeed adjustments
			clc
			lda Player1_Proj_Y0, x
			adc Player1_Proj_Speed_Y0, x
			sta Player1_Proj_Y0, x
			lda Player1_Proj_Y1, x
			adc Player1_Proj_Speed_Y1, x
			sta Player1_Proj_Y1, x
			cmp #$a8
			bcc !+
			cmp #$b8
			bcs !+
			:DestroyPlayerProjectile()
		!:

		//Gravity
			clc
			lda Player1_Proj_Speed_Y0, x
			adc Player_Proj_Gravity + 0
			sta Player1_Proj_Speed_Y0, x
			lda Player1_Proj_Speed_Y1, x
			adc Player_Proj_Gravity + 1
			sta Player1_Proj_Speed_Y1, x
			


			//TODO: Should we just use softsprite x,y directly?
			lda Player1_Proj_X1, x
			sta SOFTSPRITES.SpriteData_TARGET_X_LSB, x 
			lda Player1_Proj_X2, x
			sta SOFTSPRITES.SpriteData_TARGET_X_MSB, x 
			lda Player1_Proj_Y1, x
			sta SOFTSPRITES.SpriteData_TARGET_Y, x 


			jsr CheckProjectileCollision


		!Skip:
			dex
			bmi !+
			jmp !Loop-
		!:
			rts
	}

	//X register = softsprite/projectile
	CheckProjectileCollision: {
			.label SCREEN_LOOKUP = VECTOR1
			.label COLOR_LOOKUP = VECTOR1
			.label COLLISION_DATA = TEMP1
			.label TEMP = TEMP2
			stx TEMP

			lda SOFTSPRITES.SpriteData_Y, x 
			cmp #$a8
			bcc !+
			lda #$00
			sta COLLISION_DATA
			beq  !skipCollision+
		!:

			//Center 4,3
			lda Player1_Proj_Y1, x
			clc
			adc #$03
			lsr
			lsr
			lsr
			tay	
			lda TABLES.BufferLSB, y
			sta SCREEN_LOOKUP
			lda TABLES.BufferMSB, y
			sta SCREEN_LOOKUP + 1

			lda Player1_Proj_X2, x
			lsr
			lda Player1_Proj_X1, x
			ror
			clc
			adc #$02
			lsr
			lsr
			tay

			lda (SCREEN_LOOKUP), y
			tax
			lda CHAR_COLORS, x
			sta COLLISION_DATA




			ldx TEMP
			lda COLLISION_DATA	
			and #UTILS.COLLISION_COLORABLE
			beq !+

			// inc $d020
			lda SCREEN_LOOKUP + 1
			clc
			adc #>[$d800 - MAPLOADER.BUFFER]
			sta SCREEN_LOOKUP + 1

			tya 
			clc
			adc COLOR_LOOKUP + 0
			sta COLOR_LOOKUP + 0
			lda COLOR_LOOKUP + 1
			adc #$00
			sta COLOR_LOOKUP + 1
			lda COLOR_LOOKUP + 0
			ldy COLOR_LOOKUP + 1
			jsr PLATFORMS.AddNewColorOrigin

			
			
		// !b1:
		// 	jmp !b1-


			:DestroyPlayerProjectile()
		!:
		!skipCollision:
			rts
	}




	// X register = Available sprite index (0-1)
	// Y register = Player projectile type
	// A register = Player number (0-1)
	SpawnProjectile: {
			.label TEMP = TEMP5
			.label PLAYER_NUM = TEMP6

			sta PLAYER_NUM

			//Works out and stores the softsprite index based on 
			//available player proj. and player number
			stx SOFTSPRITES.CurrentSpriteIndex
			asl
			clc
			adc SOFTSPRITES.CurrentSpriteIndex
			sta SOFTSPRITES.CurrentSpriteIndex
			tax
			//X register is now (0-3) based on player number and proj. number

			
			//Set the player projectile type and 
			//reset fractional values
			tya
			sta PROJECTILES.Player1_Proj_Type, x
			lda #$00
			sta PROJECTILES.Player1_Proj_X0, x
			sta PROJECTILES.Player1_Proj_Y0, x


			// Get the players facing direction 
			ldy PLAYER_NUM
			lda PLAYER.Player1_State, y
			and #$30
			lsr
			lsr
			lsr
			lsr //Direction value in A ( 1 or 2 )
			tay
			dey //Convert to 0 or 1
			sty TEMP

			tya
			sta Player1_Proj_Direction, x

			//Subtract the LEFT border + Projectile Offset
			ldy PLAYER_NUM
			cpy #$00
			bne !PlayerTwo+
		!PlayerOne:
			lda PLAYER.Player1_X + 2
			pha
			lda PLAYER.Player1_X + 1
			jmp !PlayerCheckDone+
		!PlayerTwo:
			lda PLAYER.Player2_X + 2
			pha
			lda PLAYER.Player2_X + 1
		!PlayerCheckDone:


			//Set projectiles x position
			ldy TEMP
			sec
			sbc PROJECTILES.Player_Projectile_XOffset, y //Subtract border but include x offset
			sta PROJECTILES.Player1_Proj_X1, x
			pla
			sbc #$00
			sta PROJECTILES.Player1_Proj_X2, x


			//Set the projectiles Y position
			//Subtract the top border
			ldy PLAYER_NUM
			lda PLAYER.Player1_Y, y
			sec
			sbc #$30
			clc
			adc #$07 //Y Offset to move to player eye level
			sta PROJECTILES.Player1_Proj_Y1, x


			//Apply  speeds
			lda PROJECTILES.Player_Proj_Speed_X + 0
			sta PROJECTILES.Player1_Proj_Speed_X0, x
			lda PROJECTILES.Player_Proj_Speed_X + 1
			sta PROJECTILES.Player1_Proj_Speed_X1, x

			lda Player_Proj_Speed_Y + 0
			sta PROJECTILES.Player1_Proj_Speed_Y0, x
			lda Player_Proj_Speed_Y + 1
			sta PROJECTILES.Player1_Proj_Speed_Y1, x


			//Create the sprite
			lda PROJECTILES.Player1_Proj_X2, x
			cmp #$01
			lda PROJECTILES.Player1_Proj_X1, x
			sta TEMP

			lda PROJECTILES.Player1_Proj_Type, x
			ldy PROJECTILES.Player1_Proj_Y1, x
			ldx TEMP


			jsr SOFTSPRITES.AddSprite
			tax
			lda #$0f //TODO : Look up the color in a type table

			lda PLAYER_NUM
			// asl
			tay
			// lda Player_Projectile_Color, y
			lda PLAYER.PlayerColors, y
			clc
			adc #$08
			sta SOFTSPRITES.SpriteColor, X

			rts
	}



}