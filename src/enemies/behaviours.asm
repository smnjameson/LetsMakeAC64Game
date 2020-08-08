BEHAVIOURS: {
	NumberOfEnemyBehaviours:
		.byte (EnemyMSB-EnemyLSB / 2)

	EnemyLSB:
		.byte <PowerUp
		.byte <Enemy_001 //Bolied sweetr
		.byte <Enemy_002 //jelly bean
		.byte <Enemy_003 //cola bottle
		.byte <Enemy_004 //saucer
		.byte <Enemy_005 //candy cane
		.byte <Enemy_006 //Mallow
		.byte <Enemy_007 //Gumball
		.byte <Enemy_008 //Gumball

	EnemyMSB:
		.byte >PowerUp
		.byte >Enemy_001
		.byte >Enemy_002
		.byte >Enemy_003
		.byte >Enemy_004
		.byte >Enemy_005
		.byte >Enemy_006
		.byte >Enemy_007
		.byte >Enemy_008


	.label BEHAVIOUR_SPAWN = 0;
	.label BEHAVIOUR_UPDATE = 3;
	.label BEHAVIOUR_DEATH = 6;


	#import "enemies/powerup.asm"
	#import "enemies/boiledsweet.asm"
	#import "enemies/jellybean.asm"
	#import "enemies/colabottle.asm"
	#import "enemies/saucer.asm"
	#import "enemies/candycane.asm"
	#import "enemies/mallow.asm"
	#import "enemies/gumball.asm"
	#import "enemies/gummibear.asm"


	StunnedBehaviour: {
		update: {
			lda ZP_COUNTER
			and #$03
			bne !+
			dec ENEMIES.EnemyStunTimer, x
			bne !+
			lda ENEMIES.EnemyState, x
			and #[255 - ENEMIES.STATE_STUNNED]
			sta ENEMIES.EnemyState, x
			rts
		!:	
			lda ENEMIES.EnemyStunTimer, x
			cmp #$30
			bcs !SetColorNormal+
			and #$01
			beq !SetColor2+
		!SetColor1:
			:setEnemyColor($0c, null)
			jmp !Skip+
		!SetColor2:
			:setEnemyColor($02, null)
			jmp !Skip+
		!SetColorNormal:
			:setEnemyColor($0c, null)
		!Skip:

			:doFall(12, 21)
		// 	bcs !+
		// 	:snapEnemyToFloor()
		// !:
			:PositionEnemy()
			rts
		}
	}



	AbsorbBehaviour: {
		.label TimeBetweenEatFrames = $04

		setup: {
			txa
			clc
			adc #$bb //Calculate the sprite pointer
			:setEnemyFrame(null)

			//Set the start of the eat absorb animation
			lda #$00
			lda #$7e
			sta ENEMIES.EnemyEatPointerMSB, x



			//Add 350 score for absorbing
			txa

			pha //Stack = EnemyNum

			lda ENEMIES.EnemyEatenBy, x
			pha	//Stack = EnemyNum, PlayerNum
			tay
			dey
			lda #$35
			ldx #$01
			jsr HUD.AddScore

			dec ENEMIES.EnemyTotalCount
			//Increment eat meter for player
			pla //Gets PlayerNum, Stack = EnmemyNum
			tax
			dex

			lda PIPES.EnemyWeight		
			clc
			adc PLAYER.Player_Weight, x
			sta PLAYER.Player_Weight, x
			inc PLAYER.Player1_EatCount, x
			jsr HUD.UpdateEatMeter

			pla //Gets enemyNum
			tax 

			

			lda #$04 //Number of frames in eat animation
			sta ENEMIES.EnemyEatenIndex, x
			lda #$01 //Frame timer
			sta ENEMIES.EnemyEatenCounter, x

			:playSFX(SOUND.PlayerEat)
			
			rts
		}


		update: {	
			.label SpriteFrom = VECTOR7
			.label SpriteTo = VECTOR8

			//Move enemy along X
			lda ENEMIES.EnemyEatOffsetX, x
			beq !DoneMoveHoriz+
			bmi !MoveRight+
		!MoveLeft:
			dec ENEMIES.EnemyEatOffsetX, x
			:UpdatePosition($100, $000)
			jmp !DoneMoveHoriz+
		!MoveRight:
			inc ENEMIES.EnemyEatOffsetX, x
			:UpdatePosition(-$100, $000)
		!DoneMoveHoriz:	

			//Move enemy along Y
			lda ENEMIES.EnemyEatOffsetY, x
			beq !DoneMoveVert+
			bmi !MoveUp+
		!MoveDown:
			dec ENEMIES.EnemyEatOffsetY, x
			:UpdatePosition($000, $100)
			jmp !DoneMoveVert+
		!MoveUp:
			inc ENEMIES.EnemyEatOffsetY, x
			:UpdatePosition($000, -$100)
		!DoneMoveVert:	

			//Initialise sprite copy vectors
			lda ENEMIES.EnemyEatPointerLSB,x
			sta SpriteFrom
			lda ENEMIES.EnemyEatPointerMSB,x
			sta SpriteFrom + 1
			txa
			asl
			tay
			lda EatData, y
			sta SpriteTo
			lda EatData + 1, y
			sta SpriteTo + 1

			//Do we draw the frame?
			dec ENEMIES.EnemyEatenCounter, x
			bne !NoFrameCopy+
			lda #TimeBetweenEatFrames
			sta ENEMIES.EnemyEatenCounter, x

			lda ENEMIES.EnemyEatenIndex, x
			bne !NotFinished+ //Have we finished eating?
		!Finished:
			lda #$00
			sta ENEMIES.EnemyType, x
			// jsr MESSAGES.AddMessage
			rts	//No need to continue	

		!NotFinished:
			dec ENEMIES.EnemyEatenIndex, x

			//Copy sprite data for absorb
			ldy #$3f
		!Loop:
			lda (SpriteFrom), y
			sta (SpriteTo), y
			dey
			bpl !Loop-

			//Update frame
			clc
			lda ENEMIES.EnemyEatPointerLSB,x
			adc #$40
			sta ENEMIES.EnemyEatPointerLSB,x
			lda ENEMIES.EnemyEatPointerMSB,x
			adc #$00
			sta ENEMIES.EnemyEatPointerMSB,x

		//Update position color/frame etc
		//No frame Copy
		!NoFrameCopy:
			:PositionEnemy()
			rts
		}
	}

	EatData:
		.word $eec0
		.word $ef00
		.word $ef40
		.word $ef80
		.word $efc0
}





