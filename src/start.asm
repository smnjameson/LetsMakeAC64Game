#import "zeropage.asm"

BasicUpstart2(Entry)

#import "../libs/tables.asm"   
#import "../libs/vic.asm" 
#import "../libs/macros.asm"

#import "utils/utils.asm"
#import "utils/irq.asm"
#import "maps/door.asm"


.var music = LoadSid("../assets/sound/phaze101/piknmix.sid")
* = $1000 "Music"
	.fill music.size, music.getData(i)
	.fill $2800-*, 0

#import "maps/maploader.asm"
#import "maps/platforms.asm"
// 
#import "player/projectiles.asm"
#import "player/player.asm"
#import "player/hud.asm"
#import "player/crown.asm" 
#import "animation/charanimations.asm"
#import "animation/messages.asm"
#import "soft_sprites/softsprites.asm"

#import "enemies/enemies.asm"
#import "enemies/behaviours.asm"
#import "enemies/enemymacros.asm"
#import "enemies/pipes.asm" 


#import "intro/titlescreen.asm"
#import "animation/bonus.asm"
#import "animation/gameover.asm"
#import "animation/titlecard.asm"
// #import "animation/transition_bars.asm"
#import "animation/transition_chars.asm"
#import "sound/sound.asm"

Random: { 
        lda seed
        beq doEor
        asl
        beq noEor
        bcc noEor
    doEor:    
        eor #$1d
        // eor $dc04 
    noEor:  
        sta seed
        rts
    seed:
        .byte $62


    init:  
        lda #$13 
        sta $dc05
        lda #$ff
        sta $dd05
        lda #$7f
        sta $dc04
        lda #$37
        sta $dd04

        lda #$91
        sta $dc0e
        sta $dd0e
        rts
}
		

		
Entry:
		lda #$00
		sta VIC.BACKGROUND_COLOR
		lda #$00
		sta VIC.BORDER_COLOR


		lda #$0f
		sta VIC.EXTENDED_BG_COLOR_1
		lda #$00
		sta VIC.EXTENDED_BG_COLOR_2

		lda #$ff
		sta VIC.SPRITE_ENABLE
		sta VIC.SPRITE_MULTICOLOR	

		//Disable CIA interrupts
		sei
		lda #$7f
		sta $dc0d
		sta $dc0d
		cli

		//Bank out BASIC and Kernal ROM
		lda $01
		and #%11111000 
		ora #%00000101
		sta $01


		//Set VIC BANK 3	
		lda $dd00
		and #%11111100
		sta $dd00 

		//Set screen and character memory
		lda #%00001100
		sta VIC.MEMORY_SETUP
		jsr Random.init


		//Setup generated tables
		lda #180
		ldx #$04
		jsr SOFTSPRITES.CreateSpriteBlitTable

		jsr IRQ.Setup 




	!INTRO_TRANSITION:
		lda #$00	//Initialize current song
		jsr $1000

		jsr HUD.ResetScores

		lda #$00
		sta TITLECARD.IsBonus
		jsr TITLECARD.TransitionIn
		lda #$04 
		sta TITLECARD.SpriteMSB_Main
		lda #$00 
		sta TITLECARD.SpriteMC_Main

	!INTRO:
				lda #$00
				sta PLAYER.CurrentLevel
			IntroCallback:
				jsr TITLE_SCREEN.Initialise
			!IntroLoop:
				lda TITLECARD.UpdateReady
				beq !IntroLoop- 

				lda #$00
				sta TITLECARD.UpdateReady
				jsr SOUND.PlayMusic
				jsr Random
				jsr TITLE_SCREEN.Update
				bcc !IntroLoop-
				jsr TITLE_SCREEN.Destroy

		jsr SOUND.ClearSoundRegisters
		jsr TITLECARD.TransitionOut

 
		lda #$00
		sta PLAYER.CurrentLevel		
		jsr CROWN.Initialise
		jsr HUD.ResetScoreP1
		jsr HUD.ResetScoreP2
		

	!GAME_ENTRY:
		sei
		jsr SOUND.SelectRandomGameTrack
 		jsr PLAYER.Initialise
		

		jsr SOFTSPRITES.Initialise
		jsr ENEMIES.Initialise
		
		jsr DOOR.Initialise
		jsr BONUS.Initialise
		jsr MESSAGES.Initialise

		jsr IRQ.InitGameIRQ

		lda #$fa
		cmp $d012
		bne *-3

		jsr HUD.Initialise
		
		lda #$00
		sta GameOverCounter


	//Inf loop
	!Loop:
		lda PerformFrameCodeFlag
		beq !Loop-
		dec PerformFrameCodeFlag

		inc ZP_COUNTER


		//Check if transition is over and jump to Bonus screen if so
		lda BONUS .BonusActive
		beq !+
		jmp !BonusScreen+
	!:	

		//debug
		// lda #$03
		// sta PLAYER.PlayersActive
		// jmp !EndLevelTransition+

		//Are we both exiting?? Are we in normal loop?
		lda PLAYER.PlayersActive
		and #$01
		beq !+
		lda PLAYER.Player1_ExitIndex
		cmp #[TABLES.__PlayerExitAnimation - TABLES.PlayerExitAnimation]
		bne !NormalLoop+

	!:
		lda PLAYER.PlayersActive
		and #$02
		beq !+
		lda PLAYER.Player2_ExitIndex
		cmp #[TABLES.__PlayerExitAnimation - TABLES.PlayerExitAnimation]
		bne !NormalLoop+
	!:

		lda PLAYER.PlayersActive
		beq !NormalLoop+

		jmp !EndLevelTransition+

		
		/// NORMAL GAME LOOP ///////////////////////////////////////////
		!NormalLoop:
			jsr SOFTSPRITES.UpdateSprites

			jsr PLAYER.PlayerControl
			jsr PLAYER.JumpAndFall
			jsr PLAYER.GetCollisions
			jsr PLAYER.DrawPlayer
			jsr CROWN.DrawCrown

			jsr PROJECTILES.UpdateProjectiles


			jsr PIPES.Update

			jsr HUD.DrawLives
			jsr HUD.Update


			jsr SOUND.UpdateTrackDisplay
			jsr PLATFORMS.UpdateColorOrigins
			jsr DOOR.Update
			jsr MESSAGES.Update

			jsr SOUND.PlayMusic

			jsr ENEMIES.UpdateEnemies

			//Check for game over condition
			lda PLAYER.PlayersActive
			bne !+
			lda GameOverCounter
			cmp #$30
			beq !CheckForFire+
			inc GameOverCounter
			jmp !+
		!CheckForFire:
			
			lda $dc00 
			and #$10  
			and $dc01 //$10

			bne !+
			jsr SOUND.ClearSoundRegisters
			jmp !GameOver+
		!:
			jmp !Loop- 
		!NotNormalLoop:
		/////////////////////////////////
 			

		
		/////////////////////////////////
		!EndLevelTransition:
				lda #$00
				sta $d015
				jsr HUD.RecordScore

				lda $d011
				and #%11111000
				sta $d011

				jsr SOUND.ClearSoundRegisters

				jsr BONUS.InitialiseTransition
				lda #$01
				sta TITLECARD.IsBonus
				jsr TITLECARD.TransitionIn
				lda #$10 
				sta TITLECARD.SpriteMSB_Main
				lda #$1c
				sta TITLECARD.SpriteMC_Main

				jsr BONUS.Start
		
				lda #$02
				jsr $1000
				
			!EndLevelLoop:
				lda TITLECARD.UpdateReady
				beq !EndLevelLoop-
				lda #$00
				sta TITLECARD.UpdateReady

					jsr BONUS.Update
					jsr SOUND.PlayMusic


		/////////////////////////////////
		!BonusScreen:

			lda BONUS.BonusExited
			bne !BonusExiting+
			jmp !EndLevelLoop- 

		!BonusExiting:
	 
			jsr TITLE_SCREEN.Destroy

			ldx #$00
		!:
			lda #$29
			sta SCREEN_RAM, x 
			lda #$02
			sta $d800 , x 
			inx  
			cpx #$c8
			bne !-

			//reset player stuff
			lda #$00
			sta PLAYER.Player1_Size
			sta PLAYER.Player2_Size
			jsr SOUND.ClearSoundRegisters
			jsr TITLECARD.TransitionOut
			jmp !GAME_ENTRY-



			
		/////////////////////////////////
		!GameOver:


				lda #$00
				sta $d015

				lda $d011
				and #%11111000
				sta $d011

				jsr BONUS.InitialiseTransition
				lda #$01
				sta TITLECARD.IsBonus
				jsr TITLECARD.TransitionIn



				jsr GAMEOVER.Start	

				lda GAMEOVER.HiscorePositions + 0
				bpl !yes+
				lda GAMEOVER.HiscorePositions + 1
				bpl !yes+
				jmp !GameOverExiting+
			!yes:
				lda #$02
				jsr $1000

			!GameoverLoop:
				lda TITLECARD.UpdateReady
				beq !GameoverLoop-
				lda #$00
				sta TITLECARD.UpdateReady

				jsr GAMEOVER.Update
				jsr SOUND.PlayMusic

			/////////////////////////////////
				lda GAMEOVER.GameOverExited
				bne !GameOverExiting+


				jmp !GameoverLoop- 	

			!GameOverExiting:
				lda #$00	//Initialize current song
				jsr $1000
				jsr HUD.ResetScores
				lda #$00
				sta TITLECARD.IsBonus
				// jsr TITLECARD.TransitionIn

				jmp !INTRO-



	PerformFrameCodeFlag:
		.byte $00

	Counter:
		.byte $00, $00

	GameOverCounter:
		.byte $00

#import "maps/assets.asm"




//This fixes the ghost byte issue on screen shake
//By forcing all IRQs to run indirectly from the last 
//page ensuring the ghost byte is always $FF
* = $fff0 "IRQ Indirect vector"
IRQ_Indirect:
	.label IRQ_LSB = $fff1
	.label IRQ_MSB = $fff2
	jmp $BEEF


