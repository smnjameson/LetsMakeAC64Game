UTILS: {
	.label COLLISION_SOLID = %00010000
	.label COLLISION_COLORABLE = %00100000

	GetCharacterAt: {
		//x register = x char position
		//y register = y char position

		.label COLLISION_LOOKUP = TEMP1

		lda TABLES.BufferLSB ,y
		sta COLLISION_LOOKUP
		lda TABLES.BufferMSB ,y
		sta COLLISION_LOOKUP + 1

		txa
		tay
		lda (COLLISION_LOOKUP), y		
		rts
	}



	GetCollisionPoint: {
			.label X_BORDER_OFFSET = $18
			.label Y_BORDER_OFFSET = $32

			//Store Player position X
			ldy #$01
			lda (COLLISION_POINT_X), y
			sta COLLISION_POINT_POSITION
			iny
			lda (COLLISION_POINT_X), y
			sta COLLISION_POINT_POSITION + 1
		
			//Add sprite offset X
			lda COLLISION_POINT_POSITION
			clc
			adc COLLISION_POINT_X_OFFSET
			sta COLLISION_POINT_POSITION
			lda COLLISION_POINT_POSITION + 1
			adc #$00
			sta COLLISION_POINT_POSITION + 1

			//Subtract border width
			lda COLLISION_POINT_POSITION
			sec
			sbc #X_BORDER_OFFSET
			sta COLLISION_POINT_POSITION
			lda COLLISION_POINT_POSITION + 1
			sbc #$00
			sta COLLISION_POINT_POSITION + 1

			
			//Divide by 8 to get ScreenX
			lda COLLISION_POINT_POSITION
			lsr COLLISION_POINT_POSITION + 1
			ror 
			lsr
			lsr
			tax

			//Divide player Y by 8 to get ScreenY
			ldy #$00
			lda (COLLISION_POINT_Y), y
			clc
			adc COLLISION_POINT_Y_OFFSET
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
			rts
	}


	GetSpriteCollision: {
		/*
			Given two sprite X,Y positions
			and width, height sizes (ie rectangles)
			sets carry flag if overlapping
			clears if not 
		*/
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


			//get (X1 + X1Off) - (X2 + X2Off)
			ldy #$01
			lda (Sprite1_X), y
			sec 
			sbc (Sprite2_X), y
			sta COLLISION_X_DIFF
			iny
			lda (Sprite1_X), y
			sec 
			sbc (Sprite2_X), y
			sta COLLISION_X_DIFF + 1
			bne !NoCollision+

			lda Sprite1_XOFF
			sec
			sbc Sprite2_XOFF  //-1
			clc
			adc COLLISION_X_DIFF //SEC
			sta COLLISION_X_DIFF
		

			//get (Y1 + Y1Off) - (Y2 + Y2Off)
			ldy #$00
			lda (Sprite1_Y), y
			sec 
			sbc (Sprite2_Y), y
			sta COLLISION_Y_DIFF
			lda Sprite1_YOFF
			sec
			sbc Sprite2_YOFF
			clc
			adc COLLISION_Y_DIFF
			sta COLLISION_Y_DIFF



			//Check X collision
			lda COLLISION_X_DIFF //BX
			clc
			adc Sprite2_W
			bmi !NoCollision+
			pha
			lda Sprite2_W
			clc
			adc Sprite1_W
			sta COLLISION_TEMP
			pla 
			cmp COLLISION_TEMP
			bcs !NoCollision+


			//Check Y Collision
			lda COLLISION_Y_DIFF //BY
			clc
			adc Sprite2_H
			bmi !NoCollision+
			pha
			lda Sprite2_H
			clc
			adc Sprite1_H
			sta COLLISION_TEMP
			pla 
			cmp COLLISION_TEMP
			bcs !NoCollision+



		!Collision:
			sec
			rts
		!NoCollision:
			clc
			rts
	}
}