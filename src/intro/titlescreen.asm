TITLE_SCREEN: {

	*= * "TITLE_SCREEN"
	PressFire:
		.encoding "screencode_upper"
		.text "PRESS FIRE"

	ScrollerFineIndex:
		.byte $00, $00

	PageNumber:
		.byte $00
	PageTimer: 
		.byte $00

	SetupPageTable:
		.word SetupPage0
		.word SetupPage1
		.word SetupPage2
		.word SetupPage3

	UpdatePageTable:
		.word UpdatePage0
		.word UpdatePage1
		.word UpdatePage2
		.word UpdatePage3

	DestroyPageTable:
		.word DestroyPage0
		.word DestroyPage1
		.word DestroyPage2
		.word DestroyPage3


	Initialise: {

			lda #$00
			sta ScrollerFineIndex
			lda #<[INTROTEXT-1]
			sta TITLESCREEN_SCROLLER_INDEX + 0
			lda #>[INTROTEXT-1]
			sta TITLESCREEN_SCROLLER_INDEX + 1

			lda #$04
			ldx #$26
		!:
			sta $d800 + $16 * $28, x
			sta $d800 + $17 * $28, x
			dex
			bpl !-





			lda $d01c
			and #%11111011
			sta $d01c

			lda #$b2
			sta SPRITE_POINTERS + 2
			lda #$38
			sta $d004
			lda #$e1
			sta $d005
			
			jsr SetupLogoSprites

			lda #$ff
			sta PageTimer	
			lda #$00
			sta PageNumber
			jsr NextPage
			

			rts
	}

	IntroSpriteFrame:
			.byte $99,$9a,$9b,$9c,$9d,$9e,$9f
	IntroSpriteBaseX:
			.byte $80,$98,$a2,$ba,$ce,$e6,$f0
	IntroSpriteX:
			.byte $80,$98,$a2,$ba,$ce,$e6,$f0
	IntroSpriteXOffset:
			.byte $00
	IntroSpriteY:
			.byte $40,$40,$40,$40,$40,$40,$40
	IntroSpriteColor:
			.byte $03,$03,$03,$03,$03,$03,$03
	ColorRampIndex:
			.byte $00
	ColorRamp:
			.byte $01, $07,$07, $07, $0a, $0a, $08, $08
			.byte $09, $09,$08, $08, $0a, $0a, $07 ,$07
	SinusIndex:
		.byte $00, $10
	SinusY:
			.fill 32, sin(i/32 * (PI * 2)) * $03 + $3f
	SinusX:
			.fill 32, sin(i/32 * (PI * 2)) * $0f + $00

	SetupLogoSprites: {
			ldx #$00
		!:
			lda IntroSpriteFrame, x
			sta SPRITE_POINTERS, x 
			inx 
			cpx #$07
			bne !-

			jsr ApplyLogoSpriteData

			lda #$ff
			sta $d015
			rts
	}


	ApplyLogoSpriteData: {
			ldy #$00
			ldx #$00
		!:
			lda IntroSpriteX, x
			sta $d000, y 
			lda IntroSpriteY, x
			sta $d001, y 
			lda IntroSpriteColor, x 
			sta $d027, x
			iny
			iny  
			inx 
			cpx #$07
			bne !-
			rts	
	}


	UpdateLogoSprites: {
			jsr ApplyLogoSpriteData
	
			lda ZP_COUNTER
			and #$01
			bne !SkipColRamp+
	
			inc ColorRampIndex
			lda ColorRampIndex
			and #$0f
			tax 
			ldy #$00
		!loop:
			lda ColorRamp, x 
			sta IntroSpriteColor, y 
			iny 
			inx 
			cpx #$10
			bne !+
			ldx #$00
		!:
			cpy #$07
			bne !loop-

		!SkipColRamp:
			lda ZP_COUNTER
			and #$01
			bne !Exit+

			inc SinusIndex + 0
			inc SinusIndex + 1



			lda SinusIndex + 0
			and #$1f
			tax 
			ldy #$00
		!loop:
			lda SinusY, x 
			sta IntroSpriteY, y 
			iny 
			iny 
			inx 
			cpx #$20
			bne !+
			ldx #$00
		!:
			cpy #$07
			bcc !loop-


			lda SinusIndex + 1
			and #$1f
			tax 
			ldy #$01
		!loop:
			lda SinusY, x 
			sta IntroSpriteY, y 
			iny 
			iny 
			inx 
			cpx #$20
			bne !+
			ldx #$00
		!:
			cpy #$07
			bcc !loop-


			lda SinusIndex + 0
			and #$1f
			tax 
			ldy #$00
		!loop:
			lda SinusX, x 
			clc
			adc IntroSpriteBaseX, y
			sta IntroSpriteX, y 
			iny 
			inx 
			cpx #$20
			bne !+
			ldx #$00
		!:
			cpy #$07
			bcc !loop-

		!Exit:

			lda #$07
			sta $d029
			lda $d015
			ora #%00000100
			sta $d015
			lda $d010
			ora #%00000100
			sta $d010

			rts

	}


	Destroy: {
			lda #$00
			ldx #$00
		!:
			sta SCREEN_RAM + $06 * $28 + 000, x
			sta SCREEN_RAM + $06 * $28 + 190, x
			sta SCREEN_RAM + $06 * $28 + 380, x
			sta SCREEN_RAM + $06 * $28 + 570, x
			inx 
			cpx #190
			bne !-
			rts
	}

	Update: {
			jsr UpdatePage
			jsr TITLE_SCREEN.UpdateLogoSprites

			ldx ScrollerFineIndex
			dex 
			cpx #$07
			bne !+
			jsr ShiftScroller
		!:
			cpx #$ff
			bne !+
			jsr ShiftScroller
			ldx #$0f
		!:
			stx ScrollerFineIndex
			txa 
			and #$07
			sta ScrollerFineIndex + 1

			jsr AnimateDitherSprite

			jmp CheckJoystick
	}


	CheckJoystick: {
			//Check joysticks
			lda $dc00
			and #$10
			bne !+
		!PlayerOneFire:
			lda #$01
			sta PLAYER.PlayersActive
			sec
			rts
		!:
			lda $dc01
			and #$10
			bne !+
		!PlayerTwoFire:
			lda #$02
			sta PLAYER.PlayersActive
			sec
			rts
		!:
			clc
			rts
	}

	AnimateDitherSprite: {
			lda $ec80
			pha
			lda $ec81
			pha
			lda $ec82
			pha

			ldx #$00
		!:
			lda $ec83, x
			sta $ec80, x
			inx
			cpx #$3c
			bne !-

			pla 
			sta $ec80 + $3e
			pla 
			sta $ec80 + $3d
			pla 
			sta $ec80 + $3c
			rts
	}

	ShiftScroller: {
			stx TITLESCREEN_TEMP1

			ldx #$00
		!:
			lda SCREEN_RAM + $16 * $28 + 1, x
			sta SCREEN_RAM + $16 * $28 + 0, x
			lda SCREEN_RAM + $17 * $28 + 1, x
			sta SCREEN_RAM + $17 * $28 + 0, x
			inx
			cpx #$27
			bne !-

			ldx TITLESCREEN_TEMP1
			bpl !+

			clc
			lda TITLESCREEN_SCROLLER_INDEX + 0
			adc #$01
			sta TITLESCREEN_SCROLLER_INDEX + 0
			lda TITLESCREEN_SCROLLER_INDEX + 1
			adc #$00
			sta TITLESCREEN_SCROLLER_INDEX + 1


		!:	
			ldy #$00
			lda (TITLESCREEN_SCROLLER_INDEX), y
			bpl !+
			lda #<[INTROTEXT]
			sta TITLESCREEN_SCROLLER_INDEX + 0
			lda #>[INTROTEXT]
			sta TITLESCREEN_SCROLLER_INDEX + 1
			lda (TITLESCREEN_SCROLLER_INDEX), y
		!:
			tay
			lda CharMap, y
			cmp #$40
			beq !Space+
			clc
			adc #$40

			cpx #$ff
			beq !+
			adc #$2c
		!:
			sta SCREEN_RAM + $16 * $28 + $27
			clc
			adc #$58
			sta SCREEN_RAM + $17 * $28 + $27
		
			rts

		!Space:
			lda #$00
			sta SCREEN_RAM + $16 * $28 + $27
			sta SCREEN_RAM + $17 * $28 + $27
			rts
	}

	CharMap:
		.encoding "screencode_upper"
		.text "@ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		.byte 64,64,64,64,64,64
		.byte 37,64,64,64,64,64
		.byte 42,38,39,64,64,41,43,40,64
		.byte 27,28,29,30,31,32,33,34,35,36
		.byte 64,64,64,64,64,64


	NextPage: {
			inc PageNumber
			lda PageNumber
			cmp #MAX_PAGE
			bne !+
			lda #$00
			sta PageNumber
		!:	
			jsr DestroyPage
			jmp SetupPage
	}


	SetupPage: {
			lda PageNumber
			asl
			tax 
			lda SetupPageTable + 0, x
			sta SMOD + 1
			lda SetupPageTable + 1, x
			sta SMOD + 2
		SMOD:
			jmp $BEEF
	}	

	UpdatePage: {
			dec PageTimer
			bne !+
			// jmp NextPage
		!:
			lda PageNumber
			asl
			tax 
			lda UpdatePageTable + 0, x
			sta SMOD + 1
			lda UpdatePageTable + 1, x
			sta SMOD + 2

		!:
			lda #$72
			cmp $d012
			bne !-

			lda #$0a
			sta $d025
			lda #$09
			sta $d026

		SMOD:
			jsr $BEEF


		!:
			lda $d011
			bpl !-
			jmp SetupLogoSprites//RestoreLogoSprites
	}

	DestroyPage: {
			lda PageNumber
			asl
			tax 
			lda DestroyPageTable + 0, x
			sta SMOD + 1
			lda DestroyPageTable + 1, x
			sta SMOD + 2
		SMOD:
			jmp $BEEF
	}

	Credits000:
			Txt("SWEET CODE")
	Credits001:
			Txt("SHALLAN50K")

	Credits002:
			Txt("SID CHEWNS")
	Credits003:
			Txt("PHAZE101 FT. RICHMONDMIKE")

	Credits004:
			Txt("SOUND BITES")
	Credits005:
			Txt("STEPZ")

	Credits006:
			Txt("EYE CANDY")
	Credits007:
			Txt("FURROY, STOKER64, STEPZ, ")
	Credits008:
			Txt("SHALLAN50K, WAULOK")


	/*	
		- 0        1        2       28 
		- HOW TO PLAY
		- Hit enemies to stun them and
		- then eat them to gain weight
        -
        - 
        -
		- Clear all enemies to enable 
		- the level exit switch
        -
        -
		- Hit the level exit switch 
		- to reveal the exit door



		- Coloring a platform will give you
		- a points bonus w

	*/

	Page0_000:
			Txt("HOW TO PLAY")
	Page0_001:
			Txt("HIT ENEMIES TO STUN AND")
	Page0_002:
			Txt("EAT THEM TO GAIN WEIGHT")
    //
    //
    //

	Page0_003:
			Txt("HOW TO ADVANCE")
	Page0_005:
			Txt("CLEAR LEVEL AND HIT THE")
	Page0_006:
			Txt("DOOR SWITCH TO EXIT")



	Highscores:
			Txt("CALORIE COUNTER")
	

	.label MAX_PAGE = $04

	SetupPage0: {

			ResetLine()
			PrintText(Page0_000, 0, 6)
			jsr AdvanceLine
			jsr AdvanceLine
			jsr AdvanceLine
			PrintText(Page0_001, 2, 4)
			PrintText(Page0_002, 2, 4)

			jsr AdvanceLine

			PrintText(Page0_003, 0, 6)
			jsr AdvanceLine
			jsr AdvanceLine
			jsr AdvanceLine
			jsr AdvanceLine
			PrintText(Page0_005, 2, 4)
			PrintText(Page0_006, 2, 4)
				
			lda #$00
			sta UpdateVars + 0
			sta UpdateVars + 1
			sta UpdateVars + 2

			rts
	}

	Page1_000:
			Txt("POWER UPS")
	Page1_001:
			Txt("SPRINT MODE")
	Page1_002:
			Txt("INVINCIBILITY")
	Page1_003:
			Txt("SWAP COLOR TAGS")
	Page1_004:
			Txt("JUMP BOOST")
	Page1_005:
			Txt("BONUS POINTS")
	Page1_006:
			Txt("FREEZE TIME")


	SetupPage1: {
			ResetLine()
			PrintText(Page1_000, 9, 6)
			jsr AdvanceLine
			PrintText(Page1_001, 5, 4)
			jsr AdvanceLine
			PrintText(Page1_002, 10, 4)
			jsr AdvanceLine
			PrintText(Page1_003, 5, 4)
			jsr AdvanceLine
			jsr AdvanceLine
			PrintText(Page1_004, 13, 4)
			jsr AdvanceLine
			PrintText(Page1_005, 5, 4)
			jsr AdvanceLine
			PrintText(Page1_006, 12, 4)
			jsr AdvanceLine
			rts
	}


	SetupPage2: {
			jsr GAMEOVER.DisplayHiScore
			
			ResetLine()
			jsr AdvanceLine
			PrintText(Highscores, 6, 4)

			rts
	}

	//Credits
	SetupPage3: {
			ResetLine()
			jsr AdvanceLine
			PrintText(Credits000, 0, 6)
			PrintText(Credits001, 3, 4)
			jsr AdvanceLine

			PrintText(Credits002, 0, 6)
			PrintText(Credits003, 3, 4)
			jsr AdvanceLine

			PrintText(Credits004, 0, 6)
			PrintText(Credits005, 3, 4)
			jsr AdvanceLine

			PrintText(Credits006, 0, 6)
			PrintText(Credits007, 3, 4)
			PrintText(Credits008, 3, 4)
			jsr AdvanceLine

		!Exit:
			rts
	}
	



	UpdateIncVar: {
			lda ZP_COUNTER
			and #$03
			bne !+
		
			inc UpdateVars, x
			tya 
			cmp UpdateVars, x
			bne !+
			lda #$00
			sta UpdateVars, x
		!:
			lda UpdateVars, x
			rts
	}

	UpdateVars:
	PlayerAnimIndex:
			.byte 00
	CountdownIndex:
	EnemyAnimIndex:
			.byte $00
	PageStageIndex:
			.byte 00
	SwitchUpdate:
			.byte 00
	SwitchColorUpdate:
			.byte 00

	UpdatePage0: {
			//Sprite 0,1,3,4,5

			//Global values
			lda #%00000011
			sta $d01c
			lda #$00
			sta $d023
			lda $d01d
			and #$fe
			sta $d01d
			lda $d017
			and #$fe
			sta $d017

			//Player
			lda #$a0
			sta $d000
			lda #$76
			sta $d001
			lda #$02
			sta $d027

			//Enemy sprite
			lda #$e0
			sta $d002
			lda #$76
			sta $d003
			lda #$02
			sta $d028


			lda PageStageIndex
			beq !Stage1+
			jmp !Stage2+

		!Stage1:
			//Animate player
			ldy #[TABLES.__PlayerThrowRight - TABLES.PlayerThrowRight]
			ldx #$00
			jsr UpdateIncVar
			tax 
			lda TABLES.PlayerThrowRight, x 
			sta SPRITE_POINTERS + 0

			//Draw projectile
			ldy #$04
		!:
			lda #$db
			sta SCREEN_RAM + $09 * $28 + $14, y
			lda #$0a
			sta VIC.COLOR_RAM + $09 * $28 + $14, y
			dey 
			bpl !-


			cpx #$03
			bcc !+
			cpx #$08
			bcs !MoveToStage2+
			txa 
			sbc #$03
			tax 
			lda #$b4
			sta SCREEN_RAM + $09 * $28 + $14, x
		!:

			//Animate enemy
			ldy #[Enemy_003.__WalkLeft - Enemy_003.WalkLeft]
			ldx #$01
			jsr UpdateIncVar
			tax 
			lda Enemy_003.WalkLeft, x 
			sta SPRITE_POINTERS + 1 
			jmp !StageComplete+
		!MoveToStage2:
			inc PageStageIndex
			lda #$00 //Countdown value
			sta CountdownIndex 
			sta PlayerAnimIndex
			lda PageStageIndex
			// jmp !StageComplete+


		!Stage2:
			cmp #$01
			bne !Stage3+

			lda Enemy_003.WalkLeft 
			sta SPRITE_POINTERS + 1 
			lda #$0c
			sta $d028
			inc CountdownIndex
			lda CountdownIndex
			cmp #$20
			bne !+
			inc PageStageIndex
			lda #$00
			sta EnemyAnimIndex
			sta PlayerAnimIndex
			lda PageStageIndex			
			jmp !Stage3+
		!:
			//Walk player to enemy
			clc 
			adc #$a0
			sta $d000

			ldy #[TABLES.__PlayerWalkRight - TABLES.PlayerWalkRight]
			ldx #$00
			jsr UpdateIncVar
			tax 
			lda TABLES.PlayerWalkRight, x
			sta SPRITE_POINTERS + 0

		!:
			jmp !StageComplete+



		!Stage3:
			cmp #$02
			bne !Stage4+

			lda #$0c
			sta $d028
			lda #$c0
			sta $d000
			
			ldx PlayerAnimIndex
			lda ZP_COUNTER
			and #$03
			bne !+
			cpx #$02
			beq !+
			inx 
			stx PlayerAnimIndex
		!:
			lda TABLES.PlayerEatRight, x
			sta SPRITE_POINTERS + 0
			cpx #$02
			beq !EnemyAnim+

			lda Enemy_003.WalkLeft 
			sta SPRITE_POINTERS + 1 
			jmp !StageComplete+

		!EnemyAnim:
			ldx EnemyAnimIndex
			lda ZP_COUNTER
			and #$03
			bne !+
			cpx #$03
			bne !adv+
			inc PageStageIndex
			lda #$00
			sta EnemyAnimIndex
			sta PlayerAnimIndex
			lda PageStageIndex	
			jmp !Stage4+
		!adv:
			inx 
			stx EnemyAnimIndex
		!:
			lda TABLES.IntroAbsorb, x 
			sta SPRITE_POINTERS + 1 
			ldy #$e0
		!:
			dey 
			dey 
			dey 
			dey 
			dex
			bpl !-
			sty $d002
			jmp !StageComplete+

		!Stage4:
			cmp #$03
			bne !Stage5+

			lda #$c0
			sta $d000
			lda #$00
			sta $d002

			lda TABLES.PlayerWalkRight
			sta SPRITE_POINTERS + 0

			ldx EnemyAnimIndex
			inx 
			stx EnemyAnimIndex
			cpx #$40
			bne !+
			inc PageStageIndex
			lda PageStageIndex
			lda #$00
			sta EnemyAnimIndex
			sta PlayerAnimIndex	
			jmp !Stage5+
		!:
			txa 
			bit TABLES.Plus + 8
			beq !+

			lda $d01d
			ora #$01
			sta $d01d
			lda #$b4
			sta $d000				
		!:
			jmp !StageComplete+

		!Stage5:

			lda #$c0
			sta $d000
			lda #$00
			sta $d002
			lda #$58
			sta SPRITE_POINTERS + 0

			inc PlayerAnimIndex
			inc PlayerAnimIndex
			bne !StageComplete+

		!Restart:
			lda #$00
			sta PageStageIndex
			sta EnemyAnimIndex
			sta PlayerAnimIndex
			jmp UpdatePage0

		!StageComplete:
			lda SPRITE_POINTERS + 0
			clc
			adc #$18
			sta SPRITE_POINTERS + 0 



		//switch
			inc SwitchColorUpdate

			ldy #$06
			ldx #$03
			jsr UpdateIncVar
			lsr 			
			asl 
			asl
			clc 
			adc #$3c 
			tax 
			ldy #$00
		!:
			txa 
			sta SCREEN_RAM + $11 * $28 + $12, y
			lda SwitchColorUpdate
			lsr
			lsr
			and #$07
			ora #$08	
			sta VIC.COLOR_RAM + $11 * $28 + $12, y
			inx 
			iny
			cpy #$04
			bne !-

		//DrawDoor
			ldx #$35
			stx SCREEN_RAM + $0e * $28 + $1a
			inx 
			stx SCREEN_RAM + $0e * $28 + $1b
			inx
			stx SCREEN_RAM + $0e * $28 + $1c
			inx
			stx SCREEN_RAM + $0e * $28 + $1d
			inx 
			stx SCREEN_RAM + $0f * $28 + $1a
			stx SCREEN_RAM + $10 * $28 + $1a
			stx SCREEN_RAM + $11 * $28 + $1a
			inx 
			stx SCREEN_RAM + $0f * $28 + $1b
			stx SCREEN_RAM + $0f * $28 + $1c
			stx SCREEN_RAM + $10 * $28 + $1b
			stx SCREEN_RAM + $10 * $28 + $1c
			stx SCREEN_RAM + $11 * $28 + $1b
			stx SCREEN_RAM + $11 * $28 + $1c
			inx 
			stx SCREEN_RAM + $0f * $28 + $1d
			stx SCREEN_RAM + $10 * $28 + $1d
			stx SCREEN_RAM + $11 * $28 + $1d

			lda #$0a
			ldx #$03
		!:
			sta VIC.COLOR_RAM + $0e * $28 + $1a, x
			sta VIC.COLOR_RAM + $0f * $28 + $1a,x
			sta VIC.COLOR_RAM + $10 * $28 + $1a,x
			sta VIC.COLOR_RAM + $11 * $28 + $1a,x
			dex 
			bpl !-

			rts 
	} 


	UpdatePage1: {
			//Global values
			lda #%00111000
			sta $d01c
			lda #$00
			sta $d023
			lda $d01d
			and #%11000111
			sta $d01d
			lda $d017
			and #%11000111
			sta $d017

			//Powerups
				lda #$38
				sta SPRITE_POINTERS + 3
				lda #$39
				sta SPRITE_POINTERS + 4
				lda #$3a
				sta SPRITE_POINTERS + 5

				lda #$6e
				sta $d006
				lda #$70
				sta $d00a
				lda #$28
				sta $d008

				//r/g/w
				lda #$02
				sta $d02a 
				lda #$0c
				sta $d02b 
				lda #$01
				sta $d02c 

				lda $d010
				and #%11000111
				ora #%00010000
				sta $d010

				lda #$75
				sta $d007
				lda #$86
				sta $d009
				lda #$97
				sta $d00b


			lda #$ab
			cmp $d012
			bne *-3

				lda #$3b
				sta SPRITE_POINTERS + 3
				lda #$3d
				sta SPRITE_POINTERS + 4
				lda #$3c
				sta SPRITE_POINTERS + 5

				lda #$28
				sta $d006
				lda #$29
				sta $d00a
				lda #$6e
				sta $d008

				//r/w/g
				lda #$02
				sta $d02a 
				lda #$05
				sta $d02b 
				lda #$01
				sta $d02c 


				lda $d010
				and #%11000111
				ora #%00101000
				sta $d010

				lda #$ad
				sta $d007
				lda #$bc
				sta $d009
				lda #$cd
				sta $d00b

			rts
	}


	UpdatePage2: 
	UpdatePage3:  {
			rts
	}

	DestroyPage0: 
	DestroyPage1: 
	DestroyPage2: 
	DestroyPage3: {
			ldx #$00
			lda #$00
		!:

			sta SCREEN_RAM + $07 * $28 + $000, x 
			sta SCREEN_RAM + $07 * $28 + $0be, x 
			sta SCREEN_RAM + $07 * $28 + $17c, x 


			inx
			cpx #$be
			bne !-
			rts
	}


	MacResetLine: {
			lda #<[SCREEN_RAM + $07 * $28 +  $0a]
			sta INTRO_SCREEN_RAM + 0
			sta INTRO_COLOR_RAM + 0
			lda #>[SCREEN_RAM + $07 * $28 +  $0a]
			sta INTRO_SCREEN_RAM + 1
			lda #>[VIC.COLOR_RAM + $07 * $28 +  $0a]
			sta INTRO_COLOR_RAM + 1
			rts
	}

	AdvanceLine: {
			clc 
		 	lda INTRO_SCREEN_RAM + 0
		 	adc #$28
		 	sta INTRO_SCREEN_RAM + 0
		 	sta INTRO_COLOR_RAM + 0
		 	bcc !+
		 	inc INTRO_SCREEN_RAM + 1
		 	inc INTRO_COLOR_RAM + 1
		 !:
		 	rts
	}

	//Pointer to text in A/X
	//Y = upper nibble color, lower nibble offset
	MacPrintText: {
			sta SMOD + 1
			stx SMOD + 2
			tya 
			lsr
			lsr
			lsr
			lsr 
			sta INTRO_TEXT_COLOR//Color
			tya 
			and #$0f 
			tay //Offset

			ldx #$00
		!:
		SMOD:
			lda $BEEF, x
			beq !Exit+
			sta (INTRO_SCREEN_RAM), y
			lda INTRO_TEXT_COLOR
			sta (INTRO_COLOR_RAM), y
			inx 
			iny 
			bne !-

		!Exit:
			jsr AdvanceLine
			rts
	}

}


.macro ResetLine() {
		jsr TITLE_SCREEN.MacResetLine
}

//Pointer to text in A/X
//Y = upper nibble color, lower nibble offset
.macro PrintText(TextAddr, offset, color) {
		lda #<TextAddr
		ldx #>TextAddr
		ldy #[[color << 4] + offset]
		jsr TITLE_SCREEN.MacPrintText
}








