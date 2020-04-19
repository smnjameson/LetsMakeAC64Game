BONUS: {
	* = * "BONUS ACTIVE"
	BonusActive:
		.byte $00

	BonusStage:
		.byte $00

	BonusRamp:
		.byte $01,$0f,$0f,$0c,$0c,$0b,$0b,$00
		.byte $0b,$0b,$0c,$0c,$0f,$0f,$01,$01
	
	BonusRampIndex:
		.byte $00

	Initialise: {
			lda #$00
			sta BonusActive
			rts
	}

	Start: {
			lda #$01
			sta BonusActive

			sei
			lda #<BonusIRQ   
			ldx #>BonusIRQ
			sta IRQ_LSB   // 0314
			stx IRQ_MSB	// 0315 
			cli

			lda #%00001110
			sta $d018

			
			ldx #$00
		!:
			lda #$00
			sta SCREEN_RAM ,x
			sta SCREEN_RAM + $100 ,x
			sta SCREEN_RAM + $200 ,x
			sta SCREEN_RAM + $300 ,x
			lda #$01
			sta VIC.COLOR_RAM ,x
			sta VIC.COLOR_RAM + $100 ,x
			sta VIC.COLOR_RAM + $200 ,x
			sta VIC.COLOR_RAM + $300 ,x
			dex
			bne !-


			//Setup inital screen
			//Bonus Label
			ldx #$09
		!:
			lda BonusLabelLine1, x
			sta SCREEN_RAM + $01 * $28 + $0f, x
			lda BonusLabelLine2, x
			sta SCREEN_RAM + $02 * $28 + $0f, x
			dex
			bpl !-

			//Player Data
			lda PLAYER.PlayersActive
			and #$01
			beq !+
			ldx #$00
			jsr DrawPlayerBars
		!:
			lda PLAYER.PlayersActive
			and #$02
			beq !+
			ldx #$01
			jsr DrawPlayerBars
		!:


			rts			
	}



	PlayerBarX:
		.byte 7,27
	PlayerTextX:
		.byte 6,26
	PlayerBar1Colors:
		.byte $02,$05
	PlayerBar2Colors:
		.byte $0a,$0d

	PlayerText:
		.encoding "screencode_upper"
		.text "PLAYER"

	DrawPlayerBars: {
			//1b 2f   y=4-18   x=7 or 27  offset Right = 5  
			lda #<SCREEN_RAM + $03 *$28
			sta BONUS_VECTOR1 + 0
			sta BONUS_VECTOR2 + 0
			lda #>SCREEN_RAM + $03 *$28
			sta BONUS_VECTOR1 + 1
			lda #>VIC.COLOR_RAM + $03 *$28
			sta BONUS_VECTOR2 + 1

			txa
			pha

			lda PlayerBar1Colors, x
			sta BONUS_PLAYER_BAR_COLOR1
			lda PlayerBar2Colors, x
			sta BONUS_PLAYER_BAR_COLOR2
			lda PlayerBarX, x
			tay

			ldx #$0f	
		!Loop:
			lda #$2e
			sta (BONUS_VECTOR1), y
			lda #$01
			sta (BONUS_VECTOR2), y


			iny
			lda #$26
			sta (BONUS_VECTOR1), y
			lda BONUS_PLAYER_BAR_COLOR1
			sta (BONUS_VECTOR2), y
			iny
			lda #$26
			sta (BONUS_VECTOR1), y
			lda BONUS_PLAYER_BAR_COLOR1
			sta (BONUS_VECTOR2), y
			iny
			lda #$26
			sta (BONUS_VECTOR1), y
			lda BONUS_PLAYER_BAR_COLOR2
			sta (BONUS_VECTOR2), y
			iny
			lda #$26
			sta (BONUS_VECTOR1), y
			lda BONUS_PLAYER_BAR_COLOR2
			sta (BONUS_VECTOR2), y
			iny



			lda #$2f
			sta (BONUS_VECTOR1), y
			lda #$01
			sta (BONUS_VECTOR2), y
			tya 
			sec
			sbc #$05
			tay
			

			lda BONUS_VECTOR1 + 0
			clc 
			adc #$28
			sta BONUS_VECTOR1 + 0
			sta BONUS_VECTOR2 + 0
			bcc !+
			inc BONUS_VECTOR1 + 1
			inc BONUS_VECTOR2 + 1
		!:
			dex
			bpl !Loop-

			pla
			tax

			lda HUD.PlayerColors, x
			sta BONUS_COLOR

			
			stx BONUS_PLAYER
			lda PlayerTextX, x
			tax
			ldy #$00
		!:
			lda PlayerText,y
			sta SCREEN_RAM + $14 * $28, x
			lda BONUS_COLOR
			sta VIC.COLOR_RAM + $14 * $28, x
			lda #$30
			sta SCREEN_RAM + $16 * $28 + $01, x
			inx
			iny
			cpy #$06
			bne !-


			lda #$31
			clc
			adc BONUS_PLAYER
			pha
			ldx BONUS_PLAYER
			lda PlayerTextX, x
			clc
			adc #$07
			tax
			pla
			sta SCREEN_RAM + $14 * $28, x
			lda BONUS_COLOR
			sta VIC.COLOR_RAM + $14 * $28, x
			rts


	}



	BonusIRQ: {
			pha

				lda $d016
				and #%11101111
				sta $d016

				lda #$01
				sta PerformFrameCodeFlag


				asl $d019
			pla
			rti
	}


	Update: {
			//First animate color ramp for bonus
			lda ZP_COUNTER
			and #$0f
			tax

			ldy #$00
		!Loop:
			lda BonusRamp, x
			sta VIC.COLOR_RAM + $01 * $28 + $0f, y
			inx
			cpx #$10
			bne !+
			ldx #$00
		!:
			iny
			cpy #$0a
			bne !Loop-


			lda ZP_COUNTER
			and #$0f
			tax	

			ldy #$09
		!Loop:
			lda BonusRamp, x
			sta VIC.COLOR_RAM + $02 * $28 + $0f, y

			inx
			cpx #$10
			bne !+
			ldx #$00
		!:
			dey
			bpl !Loop-

			rts
	}

	SetBar: {
		//X = player num 0,1
		//A = Bar Height 0-128

			rts
	}

	////////// TEXTS
	BonusLabelLine1:
			.byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89
	BonusLabelLine2:
			.byte $90,$91,$92,$93,$94,$95,$96,$97,$98,$99
}