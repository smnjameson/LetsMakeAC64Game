PLATFORMS: {
		.label MAX_PLATFORMS = 16
	* =* "COLOR PLATFROM"
	COLOR_ORIGIN_LSB:
		.fill MAX_PLATFORMS, 0	
	COLOR_ORIGIN_MSB:
		.fill MAX_PLATFORMS, 0
	ORIGINAL_COLOR:
		.fill MAX_PLATFORMS, 0
	NEW_COLOR:
		.fill MAX_PLATFORMS, 0
	NEXT_COLOR_INDEX:
		.byte $00

	AddNewColorOrigin:{
			//A = LSB
			//Y = MSB
			//x = Projectile index	
			stx PLATFORM_TEMP //X = DO NOT BASH
			pha
			lda PROJECTILES.Player_Projectile_Color, x

			ldx NEXT_COLOR_INDEX
			sta NEW_COLOR, x 
			pla
			sta COLOR_ORIGIN_LSB, x 
			tya 
			sta COLOR_ORIGIN_MSB, x


			lda COLOR_ORIGIN_LSB, x
			sta PLATFORM_LOOKUP + 0
			lda COLOR_ORIGIN_MSB, x
			sta PLATFORM_LOOKUP + 1
			ldy #$00
			lda (PLATFORM_LOOKUP), y
			and #$0f
			sta ORIGINAL_COLOR, x

			inx 
			cpx #MAX_PLATFORMS
			bne !+
			ldx #$00
		!:
			stx NEXT_COLOR_INDEX

			ldx PLATFORM_TEMP
			rts
	}

	UpdateColorOrigins: {
			ldx #MAX_PLATFORMS - 1
		!Loop:
			lda COLOR_ORIGIN_LSB, x
			sta PLATFORM_LOOKUP + 0
			lda COLOR_ORIGIN_MSB, x
			sta PLATFORM_LOOKUP + 1
			bne !+
			beq !Skip+
		!:

			jsr FillPlatform

		!Skip:
			dex
			bpl !Loop-
			rts
	}

	FillPlatformToggle:
			.byte $00
	FillPlatform: {
			inc FillPlatformToggle
			lda FillPlatformToggle
			and #$01
			beq !+
			rts
		!:
			lda #$00
			sta PLATFORM_COMPLETE

			//left
		!Loop:
			ldy #$00
			lda (PLATFORM_LOOKUP), y
			and #$0f
			cmp NEW_COLOR, x
			bne !FoundNewColor+

			lda PLATFORM_LOOKUP + 0
			sec
			sbc #$01
			sta PLATFORM_LOOKUP + 0
			lda PLATFORM_LOOKUP + 1
			sbc #$00
			sta PLATFORM_LOOKUP + 1
			jmp !Loop-

		!FoundNewColor:
			cmp ORIGINAL_COLOR, x
			bne !LeftComplete+

			ldy #$00
			lda NEW_COLOR,x
			sta (PLATFORM_LOOKUP), y
			jmp !DoneLeft+
		!LeftComplete:
			inc PLATFORM_COMPLETE
		!DoneLeft:


			//right
			ldy #$01
		!Loop:
			lda (PLATFORM_LOOKUP), y
			and #$0f
			cmp NEW_COLOR, x
			bne !FoundNewColor+
			iny
			bne !Loop-
		!FoundNewColor:
			cmp ORIGINAL_COLOR, x
			bne !RightComplete+

			lda NEW_COLOR,x
			sta (PLATFORM_LOOKUP), y
			jmp !DoneRight+
		!RightComplete:
			inc PLATFORM_COMPLETE
		!DoneRight:	

			lda PLATFORM_COMPLETE
			cmp #$02
			bcc !+

			//Turn off update
			lda #$00
			sta COLOR_ORIGIN_MSB, x
		!:
			rts

	}
}