PLAYER: {
	.label COLLISION_SOLID = %00010000

	.label STATE_JUMP 		= %00000001
	.label STATE_FALL 		= %00000010
	.label STATE_WALK_LEFT  = %00000100
	.label STATE_WALK_RIGHT = %00001000

	PlayerX:
			.byte $00, $00 //1 pixel accuracy
	PlayerY:
			.byte $00 //1 pixel accuracy
			
	PlayerFloorCollision:
			.byte $00
	PlayerJumpIndex:
			.byte $00
	PlayerWalkIndex:
			.byte $00
	PlayerState:
			.byte $00

	Initialise: {
			lda #$0a
			sta VIC.SPRITE_MULTICOLOR_1
			lda #$09
			sta VIC.SPRITE_MULTICOLOR_2

			lda #$05
			sta VIC.SPRITE_COLOR_0

			lda #$40
			sta SPRITE_POINTERS + 0

			lda VIC.SPRITE_ENABLE 
			ora %00000001
			sta VIC.SPRITE_ENABLE

			lda VIC.SPRITE_MULTICOLOR
			ora %00000001
			sta VIC.SPRITE_MULTICOLOR

			rts
	}


	GetCollisions: {

		//Get floor collisions for each foot
		ldx #1
		ldy #20
		jsr PLAYER.GetCollisionPoint
		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		sta PlayerFloorCollision

		ldx #4
		ldy #20
		jsr PLAYER.GetCollisionPoint
		jsr UTILS.GetCharacterAt
		tax
		lda CHAR_COLORS, x
		ora PlayerFloorCollision
		and #$f0
		sta PlayerFloorCollision

		//DEbug /////////
		lsr
		lsr
		lsr
		lsr
		sta VIC.COLOR_RAM
		/////////////////

		rts
	}



	GetCollisionPoint: {
			//x register contains x offset (half value)
			//y register contains y offset
			.label X_PIXEL_OFFSET = TEMP1
			.label Y_PIXEL_OFFSET = TEMP2

			.label X_BORDER_OFFSET = $0b
			.label Y_BORDER_OFFSET = $32

			stx X_PIXEL_OFFSET
			sty Y_PIXEL_OFFSET

			//calculate x and y in screen space
			lda PlayerX
			cmp #X_BORDER_OFFSET
			bcs !+
			lda #X_BORDER_OFFSET
		!:	
			clc
			adc X_PIXEL_OFFSET
			sec
			sbc #X_BORDER_OFFSET
			lsr
			lsr
			tax

			lda PlayerY
			cmp #Y_BORDER_OFFSET
			bcs !+
			lda #Y_BORDER_OFFSET
		!:
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
			//Set player frame
		DefaultFrame:
			ldy #64   //Default idle frame

			lda PlayerState
			and #[STATE_WALK_RIGHT + STATE_WALK_LEFT]
			beq !SetFrame+
			lda PlayerState
			and #[STATE_JUMP + STATE_FALL]
			bne !SetFrame+

			ldx PlayerWalkIndex
			lda ZP_COUNTER
			and #$03
			bne !Skip+
			inx
			cpx #[TABLES.__PlayerWalkLeft - TABLES.PlayerWalkLeft]
			bne !+
			ldx #$00
		!:
			stx PlayerWalkIndex
		!Skip:



			lda PlayerState
			and #[STATE_WALK_RIGHT]	
			bne !Right+
		!Left:
			ldy TABLES.PlayerWalkLeft, x
			jmp !SetFrame+

		!Right:
			ldy TABLES.PlayerWalkRight, x
							
		!SetFrame:
			sty SPRITE_POINTERS + 0




			//Set player position X & Y
			lda PlayerX
			asl
			sta VIC.SPRITE_0_X
			bcc !+
			lda VIC.SPRITE_MSB
			ora #%00000001
			jmp !EndMSB+
		!:
			lda VIC.SPRITE_MSB
			and #%11111110
		!EndMSB:
			sta VIC.SPRITE_MSB

			lda PlayerY
			sta VIC.SPRITE_0_Y

			rts
	}


	PlayerControl: {
			.label JOY_PORT_2 = $dc00

			.label JOY_UP = %00001
			.label JOY_DN = %00010
			.label JOY_LT = %00100
			.label JOY_RT = %01000
			.label JOY_FR = %10000

			lda JOY_PORT_2
			sta JOY_ZP

			lda PlayerState	
			and #[255 - STATE_WALK_RIGHT - STATE_WALK_LEFT]
			sta PlayerState

		!Up:
			lda PlayerState
			and #[STATE_FALL + STATE_JUMP]
			bne !+
			lda JOY_ZP	
			and #JOY_UP
			bne !+
			lda PlayerState
			ora #STATE_JUMP
			sta PlayerState
			lda #$00
			sta PlayerJumpIndex
			jmp !Left+
		!:


		!Left:
			lda JOY_ZP
			and #JOY_LT
			bne !+

			ldx PLAYER.PlayerX
			dex
			cpx #255
			bne !Skip+
			ldx #183
		!Skip:
			stx PLAYER.PlayerX

			lda PlayerState
			ora #STATE_WALK_LEFT
			sta PlayerState
			lda #80
			sta DrawPlayer.DefaultFrame + 1
			jmp !Right+
		!:



		!Right:
			lda JOY_ZP
			and #JOY_RT
			bne !+
			ldx PLAYER.PlayerX
			inx
			cpx #184
			bne !Skip+
			ldx #$00
		!Skip:
			stx PLAYER.PlayerX
			lda PlayerState
			ora #STATE_WALK_RIGHT
			sta PlayerState
			lda #64
			sta DrawPlayer.DefaultFrame + 1
	
		!:

			rts
	}


	JumpAndFall: {
			lda PlayerState
			and #STATE_JUMP
			bne !ExitFallingCheck+

		!FallCheck:
			lda PlayerFloorCollision
			and #COLLISION_SOLID
			bne !NotFalling+

		!Falling:
			lda PlayerState
			and #STATE_FALL
			bne !ExitFallingCheck+
			lda PlayerState
			ora #STATE_FALL
			sta PlayerState
			lda #[TABLES.__JumpAndFallTable - TABLES.JumpAndFallTable - 1]
			sta PlayerJumpIndex
			jmp !ExitFallingCheck+

		!NotFalling:		
			lda PlayerState
			and #STATE_FALL
			beq !+
			lda PlayerY
			sec
			sbc #$06
			and #$f8
			ora #$06
			sta PlayerY
		!:

			lda PlayerState
			and #[255 - STATE_FALL]
			sta PlayerState
		!ExitFallingCheck:




		!ApplyFallOrJump:
			lda PlayerState
			and #STATE_FALL
			beq !Skip+

			ldx PlayerJumpIndex
			lda TABLES.JumpAndFallTable, x
			clc
			adc PlayerY
			sta PlayerY
			dex
			bpl !+
			ldx #$00
		!:
			stx PlayerJumpIndex
		!Skip:



			lda PlayerState
			and #STATE_JUMP
			beq !Skip+

			ldx PlayerJumpIndex
			lda PlayerY
			sec
			sbc TABLES.JumpAndFallTable, x
			sta PlayerY
			inx
			cpx #[TABLES.__JumpAndFallTable - TABLES.JumpAndFallTable]
			bne !+
			dex
			lda PlayerState
			and #[255 - STATE_JUMP]
			ora #STATE_FALL
			sta PlayerState
		!:
			stx PlayerJumpIndex

		!Skip:

			rts
	}
}