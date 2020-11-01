*=* "Hud"
HUD_DATA:
	.import binary "../../assets/maps/hud.bin"


HUD: {
	EatMeter:
		.import binary "../../assets/maps/eatmeter.bin"
	PreviousPlayersActive:
			.byte $00

	Initialise: {
			ldy #$01

			ldx #119
		!Loop:
			lda HUD_DATA, x
			sta SCREEN_RAM + 22 * 40, x
			dex
			bpl !Loop-

			ldx #39
		!Loop:
			lda #$00
			sta VIC.COLOR_RAM + 22 * 40, x
			lda #$01
			sta VIC.COLOR_RAM + 23 * 40, x
			sta VIC.COLOR_RAM + 24 * 40, x
			dex
			bpl !Loop-

			

			jsr ColorTheMeter
			jsr UpdateEatMeter

			lda #$00
			sta PreviousPlayersActive
			jsr Update

			jsr SetScores
			rts
	}


	InitialiseEatMeter: {
			ldx #15
		!Loop:
			lda EatMeter, x
			sta SCREEN_RAM + 23 * 40 +12, x
			lda EatMeter + 16, x
			sta SCREEN_RAM + 24 * 40 + 12, x
			dex
			bpl !Loop-


			ldx #39
		!Loop:
			lda #$00
			sta VIC.COLOR_RAM + 22 * 40, x
			dex
			bpl !Loop-

			ldx #$1b
		!Loop:
			lda #$01
			sta VIC.COLOR_RAM + 23 * 40, x
			sta VIC.COLOR_RAM + 24 * 40, x
			dex
			cpx #$0b
			bne !Loop-

			jsr ColorTheMeter
			jsr UpdateEatMeter
			jsr Update
			rts
	}


	ColorTheMeter: {
			//Color the meter
			ldx #$0e
			lda #$0e
		!Loop:
			sta VIC.COLOR_RAM + 23 * 40 + 12, x
			sta VIC.COLOR_RAM + 24 * 40 + 12, x
			dex
			bpl !Loop-

			lda #$01
			sta VIC.COLOR_RAM + 23 * 40 + 12
			sta VIC.COLOR_RAM + 24 * 40 + 12
			sta VIC.COLOR_RAM + 23 * 40 + 27
			sta VIC.COLOR_RAM + 24 * 40 + 27
			rts
	}


		.encoding "screencode_upper"
	Player1Row1:
		.text "PLAYER "
		.byte $f8
	Player2Row1:
		.text "PLAYER "
		.byte $f9
	PlayerRow2:	
		.text "00000000"

	PressFireRow1a:
		.text "P"
		.byte $f8
		.text " PRESS"
	PressFireRow1b:
		.text "P"
		.byte $f9
		.text " PRESS"
	PressFireRow2:	
		.text "  FIRE  "
	GameOverRow1:
		.text "  GAME  "
	GameOverRow2:
		.text "  OVER  "
	// PlayerColors: 
	// 	.byte $02,$05
	PlayerActiveColors:
		.byte $00,$00


	SetGameOver: {

			lda PLAYER.PlayersActive
			beq !Player1GameOver+
			lda PLAYER.Player1_Lives
			bpl !P1Done+
		!Player1GameOver:
			ldx #$07
		!loop:
			lda GameOverRow1, x
			clc
			adc #$e5
			cmp #$05
			bne !+
			lda #$00
		!:
			sta SCREEN_RAM + 23 * 40 + 0, x
			lda PLAYER.PlayerColors + 0
			sta VIC.COLOR_RAM + 23 * 40 + 0, x

			lda GameOverRow2, x
			clc
			adc #$e5
			cmp #$05
			bne !+
			lda #$00
		!:
			sta SCREEN_RAM + 24 * 40 + 0, x
			lda PLAYER.PlayerColors + 0
			sta VIC.COLOR_RAM + 24 * 40 + 0, x
			dex
			bpl !loop-
		!P1Done:

			lda PLAYER.PlayersActive
			beq !Player2GameOver+
			lda PLAYER.Player2_Lives
			bpl !P2Done+
		!Player2GameOver:
			ldx #$07
		!loop:
			lda GameOverRow1, x
			clc
			adc #$e5
			cmp #$05
			bne !+
			lda #$00
		!:
			sta SCREEN_RAM + 23 * 40 + 32, x
			lda PLAYER.PlayerColors + 1
			sta VIC.COLOR_RAM + 23 * 40 + 32, x

			lda GameOverRow2, x
			clc
			adc #$e5
			cmp #$05
			bne !+
			lda #$00
		!:
			sta SCREEN_RAM + 24 * 40 + 32, x
			lda PLAYER.PlayerColors + 1
			sta VIC.COLOR_RAM + 24 * 40 + 32, x

			dex
			bpl !loop-
		!P2Done:
			rts
	}




	FlashInsertCoin: {
			lda PLAYER.PlayersActive
			cmp #$03
			bne !+
			rts
		!:

	FlashGameOver:
			lda ZP_COUNTER
			and #$10
			beq !On+
		!Off:
			lda #$00
			sta PlayerActiveColors + 0
			sta PlayerActiveColors + 1
			jmp !Done+
		!On:
			lda PLAYER.PlayerColors + 0
			sta PlayerActiveColors + 0
			lda PLAYER.PlayerColors + 1
			sta PlayerActiveColors + 1
		!Done:



		ColorPlayerNames:
			lda PLAYER.PlayersActive
			and #$01
			bne !Player2+
		!Player1:
			ldx #$07
			lda PlayerActiveColors + 0
		!:
			sta VIC.COLOR_RAM + 23 * 40 + 0, x
			sta VIC.COLOR_RAM + 24 * 40 + 0, x
			dex
			bpl !-


		!Player2:
			lda PLAYER.PlayersActive
			and #$02
			bne !PlayerDone+

			ldx #$07
			lda PlayerActiveColors + 1
		!:
			sta VIC.COLOR_RAM + 23 * 40 + 32, x
			sta VIC.COLOR_RAM + 24 * 40 + 32, x
			dex
			bpl !-

		!PlayerDone:
			rts
	}

	Update: {
			lda PreviousPlayersActive
			cmp PLAYER.PlayersActive
			bne !+

			lda PLAYER.PlayersActive
			bne !FlashCoin+

			jmp FlashInsertCoin.FlashGameOver

		!FlashCoin:
			
			jmp FlashInsertCoin
		!:

			
		

			//Previos playes active does not equal
			//current players active so update text
			

			lda PLAYER.PlayersActive
			bne !+
			sta PreviousPlayersActive
			jmp SetGameOver

		!:
			lda PreviousPlayersActive
			and #$01
			bne !Player1Done+
			lda PLAYER.PlayersActive 
			and #$01
			beq !Player1Inactive+

		!Player1Active:
			ldx #$07
		!loop:
			lda Player1Row1, x
			clc
			adc #$e5
			cmp #$05
			bne !+
			lda #$00
		!:
			sta SCREEN_RAM + 23 * 40 + 0, x
			lda PLAYER.PlayerColors + 0
			sta VIC.COLOR_RAM + 23 * 40 + 0, x
			lda #$dc
			sta SCREEN_RAM + 24 * 40 + 0, x
			lda #$01
			sta VIC.COLOR_RAM + 24 * 40 + 0, x
			dex
			bpl !loop-
			jmp !Player1Done+


		!Player1Inactive:
			ldx #$07
		!loop:
			lda PressFireRow1a, x
			clc
			adc #$e5
			cmp #$05
			bne !+
			lda #$00
		!:
			sta SCREEN_RAM + 23 * 40 + 0, x
			lda PLAYER.PlayerColors + 0
			sta VIC.COLOR_RAM + 23 * 40 + 0, x


			lda PressFireRow2, x
			clc
			adc #$e5
			cmp #$05
			bne !+
			lda #$00
		!:
			sta SCREEN_RAM + 24 * 40 + 0, x
			lda PLAYER.PlayerColors + 0
			sta VIC.COLOR_RAM + 24 * 40 + 0, x			
			dex
			bpl !loop-
		!Player1Done:


			lda PreviousPlayersActive
			and #$02
			bne !Player2Done+
			lda PLAYER.PlayersActive 
			and #$02
			beq !Player2Inactive+

		!Player2Active:
			ldx #$07
		!loop:
			lda Player2Row1, x
			clc
			adc #$e5
			cmp #$05
			bne !+
			lda #$00
		!:
			sta SCREEN_RAM + 23 * 40 +32, x
			lda PLAYER.PlayerColors + 1
			sta VIC.COLOR_RAM + 23 * 40 + 32, x
			lda #$dc
			sta SCREEN_RAM + 24 * 40 + 32, x
			lda #$01
			sta VIC.COLOR_RAM + 24 * 40 + 32, x
			dex
			bpl !loop-
			jmp !Player2Done+

		!Player2Inactive:
			ldx #$07
		!loop:
			lda PressFireRow1b, x
			clc
			adc #$e5
			cmp #$05
			bne !+
			lda #$00
		!:
			sta SCREEN_RAM + 23 * 40 + 32, x
			lda PLAYER.PlayerColors + 1
			sta VIC.COLOR_RAM + 23 * 40 + 32, x


			lda PressFireRow2, x
			clc
			adc #$e5
			cmp #$05
			bne !+
			lda #$00
		!:
			sta SCREEN_RAM + 24 * 40 + 32, x
			lda PLAYER.PlayerColors + 1
			sta VIC.COLOR_RAM + 24 * 40 + 32, x			
			dex
			bpl !loop-
		!Player2Done:


			lda PLAYER.PlayersActive
			sta PreviousPlayersActive


			jsr SetGameOver

			rts
	}



	//Acc = Score to add (25) (BCD Format) $25 = 25
	//X = trailing zeros count (1)
	//Y = Player 
	//Positions (2,24) & (30,24)
	AddScore: {
			.label SCORE = SCOREVECTOR1
			.label SCORETOADD = SCORETEMP1
			.label TEMP = SCORETEMP2

			sta SCORETOADD
			cpy #$00
			bne !P2+
		!P1:
			lda #<[SCREEN_RAM + 24 * 40 + 0]
			sta SCORE
			lda #>[SCREEN_RAM + 24 * 40 + 0]
			sta SCORE + 1
			jmp !Done+
		!P2:
			lda #<[SCREEN_RAM + 24 * 40 + 32]
			sta SCORE
			lda #>[SCREEN_RAM + 24 * 40 + 32]
			sta SCORE + 1
		!Done:

			stx TEMP
			lda #$07
			sec
			sbc TEMP
			tay


			clc
		!Loop:
			lda SCORETOADD
			and #$0f
			adc (SCORE), y 
			cmp #230
			bcc !+
			sbc #10
		!:
			sta (SCORE), y 
			php //SAVE CARRY
			
			lda SCORETOADD
			lsr
			lsr
			lsr
			lsr
			sta SCORETOADD
			plp //RESTORE CARRY
			dey
			bpl !Loop-

			rts
	}

	UpdateEatMeter: {
			lda SOUND.TrackDisplayState
			beq !+
			rts
		!:
			clc
			lda PLAYER.Player1_EatCount
			adc PLAYER.Player2_EatCount
			bne !+
			rts
		!:
			pha

			//Accumulator has total eaten
			//Bar has 56 units total
			//Therefore we need to show (TotalEaten * 56) / TotalEnemies
					// lda PLAYER.CurrentLevel
					// asl
					// tax
					// lda MAPDATA.MAP_POINTERS, x
					// clc
					// adc #<MAPDATA.EnemyListData
					lda #<MAPDATA.MAP_1.EnemyList
					sta SelfMod + 1
					// inx
					// lda MAPDATA.MAP_POINTERS, x
					// adc #>MAPDATA.EnemyListData
					lda #>MAPDATA.MAP_1.EnemyList
					sta SelfMod + 2

					//Add number of enemies to get to BArUnits
					lda SelfMod + 1
					clc
					adc MAPDATA.MAP_1.NumberEnemies
					sta SelfMod + 1
					lda SelfMod + 2
					adc #$00
					sta SelfMod + 2

					lda SelfMod + 1
					clc
					adc MAPDATA.MAP_1.NumberOfPowerups
					sta SelfMod + 1
					lda SelfMod + 2
					adc #$00
					sta SelfMod + 2


			pla
			tax
	
			// inx //Fixes the offset casued by the null byte at the end of EnemyList


		SelfMod:
			lda $BEEF, x
			ldx #$00
		!Loop:	
			cmp #$04
			bcc !LessThanFour+
			pha
			lda #148
			sta SCREEN_RAM + 23 * 40 + 13, x
			lda #164
			sta SCREEN_RAM + 24 * 40 + 13, x
			pla
			sec
			sbc #$04
			jmp !Next+
		!LessThanFour:
			clc
			adc #144
			sta SCREEN_RAM + 23 * 40 + 13, x
			adc #16
			sta SCREEN_RAM + 24 * 40 + 13, x
			lda #$00

		!Next:
			inx
			cpx #14
			bne !Loop-

		!Exit:

			rts
	}

.align $10
	LivesLocations:
		.byte 49,9,50,10
		.byte 70,30,69,29


	DrawLives: {
			ldx #$01
		!Loop:	
			stx HUD_LIVES_TEMP1

					//Little self mod to set the correct player
					txa 
					asl 
					asl
					clc
					adc #<LivesLocations
					sta PlayerMod + 1

					ldy #$03
				!InnerLoop:
						ldx HUD_LIVES_TEMP1

						txa 
						clc 
						adc #$01
						and PLAYER.PlayersActive
						bne !+
						lda #$00
						jmp !Done+
					!:
						tya
						cmp PLAYER.Player_Lives, x
						bcs !+
						lda #$aa
						jmp !Done+
					!:
						lda #$a9
					!Done:
						pha
					PlayerMod:
						lda LivesLocations, y
						tax
						pla
						sta SCREEN_RAM + 23 * $28, x

					
					dey
					bpl !InnerLoop-

					//Now check if this player has more than 4 lives

					ldx HUD_LIVES_TEMP1
					lda #$09
					cpx #$01
					bne !+
					lda #$1d
				!:
					sta LIVES_POS_TEMP
					
					lda PLAYER.Player_Lives, x
					cmp #$05
					bcc !livesDone+
					bmi !livesDone+
					ldy #$00
				!tens:
					cmp #$0a 
					bcc !units+
					iny
					sbc #$0a 
					jmp !tens-

				!units:
					//Y contains tens and acc contains units
					clc
					adc #$dc
					ldx LIVES_POS_TEMP
					inx
					sta SCREEN_RAM + 24 * $28, x

				!drawTens:
					ldx LIVES_POS_TEMP 
					tya 
					beq !livesDone+
					clc
					adc #$dc					
					sta SCREEN_RAM + 24 * $28, x

				!livesDone:



			ldx HUD_LIVES_TEMP1
			dex
			bpl !Loop-

			rts
	}

	//Positions (2,24) & (30,24)
	RecordScore: {
			lda PLAYER.PlayersActive
			and #$01
			beq !+
			jsr RecordScoreP1
		!:
			lda PLAYER.PlayersActive
			and #$02
			beq !+
			jsr RecordScoreP2
		!:
			rts
	}


	ResetScores: {
			jsr ResetScoreP1
			jsr ResetScoreP2
			rts
	}

	ResetScoreP1: {
			lda #$30
			ldx #$07
		!:
			sta P1_SCORE, x
			dex
			bpl !-
			rts	
	}


	ResetScoreP2: {
			ldx #$07
			lda #$30
		!:
			sta P2_SCORE, x
			dex
			bpl !-
			rts		
	}

	RecordScoreP1: {
			ldx #$07
		!:
			lda SCREEN_RAM + 24 * $28, x
			sec 
			sbc #$ac
			sta P1_SCORE, x

			dex
			bpl !-
			rts

	}

	RecordScoreP2: {
			ldx #$07
		!:
			lda SCREEN_RAM + 24 * $28 + 32, x
			sec 
			sbc #$ac
			sta P2_SCORE, x

			dex
			bpl !-
			rts
	}




	SetScores: {
			clc 

		!p1:	
			lda PLAYER.PlayersActive
			and #$01
			beq !p2+

			ldx #$07
		!:
			lda P1_SCORE, x	
			adc #[$dc - $30]		
			sta SCREEN_RAM + 24 * 40 + 0, x
			dex
			bpl !-


		!p2:
			lda PLAYER.PlayersActive
			and #$02
			beq !Exit+
			ldx #$07
		!:
			lda P2_SCORE, x	
			adc #[$dc - $30]		
			sta SCREEN_RAM + 24 * 40 + 32, x
			dex
			bpl !-

		!Exit:
			rts	
	}
}


