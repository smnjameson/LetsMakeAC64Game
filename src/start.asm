#import "zeropage.asm"

BasicUpstart2(Entry)

 
#import "../libs/tables.asm"  
#import "../libs/vic.asm"
#import "../libs/macros.asm"

#import "utils/utils.asm"
#import "utils/irq.asm"

#import "intro/introtext.asm"

.var music = LoadSid("../assets/sound/phaze101/piknmix.sid")
* = $1000 "Music"
	.fill music.size, music.getData(i)
	.fill $2800-*, 0

#import "maps/maploader.asm"
#import "maps/platforms.asm"
#import "maps/door.asm"
#import "player/player.asm"
#import "player/projectiles.asm"
#import "player/hud.asm"
#import "player/crown.asm"
#import "animation/charanimations.asm"
#import "animation/messages.asm"
#import "soft_sprites/softsprites.asm"
// #import "animation/spritewarp.asm"

#import "enemies/enemies.asm"
#import "enemies/behaviours.asm"
#import "enemies/enemymacros.asm"
#import "enemies/pipes.asm"

#import "animation/transition.asm"

#import "intro/titlescreen.asm"
#import "animation/bonus.asm"
#import "animation/titlecard.asm"
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
        // eor $dd04
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

		lda #$04
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

		lda #$00
		sta TITLECARD.IsBonus
		jsr TITLECARD.TransitionIn

			!INTRO:
			IntroCallback:
				jsr TITLE_SCREEN.Initialise
			!IntroLoop:
				lda TITLECARD.UpdateReady
				beq !IntroLoop-
				lda #$00
				sta TITLECARD.UpdateReady
				jsr $1003
				jsr Random
				jsr TITLE_SCREEN.Update
				bcc !IntroLoop-
				jsr TITLE_SCREEN.Destroy

		jsr SOUND.ClearSoundRegisters
		jsr TITLECARD.TransitionOut


		
		

	!GAME_ENTRY:
		jsr SOUND.SelectRandomGameTrack
 		jsr PLAYER.Initialise
		jsr HUD.Initialise
		jsr IRQ.InitGameIRQ

		jsr SOFTSPRITES.Initialise
		// jsr SPRITEWARP.init
		jsr ENEMIES.Initialise
		jsr CROWN.Initialise
		jsr DOOR.Initialise
		jsr BONUS.Initialise
		jsr MESSAGES.Initialise




	//Inf loop
	!Loop:
		lda PerformFrameCodeFlag
		beq !Loop-
		dec PerformFrameCodeFlag

		inc ZP_COUNTER


		//Check if transiiton is over and jump to Bonus screen if so
		lda BONUS.BonusActive
		beq !+
		jmp !BonusScreen+
	!:

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

			jsr ENEMIES.UpdateEnemies
			jsr PIPES.Update
			jsr HUD.DrawLives
			jsr HUD.Update
			jsr SOUND.UpdateTrackDisplay
			jsr PLATFORMS.UpdateColorOrigins
			jsr DOOR.Update
			jsr MESSAGES.Update
			jsr $1003
			jmp !Loop- 
		!NotNormalLoop:
		/////////////////////////////////
 
		
		/////////////////////////////////
		!EndLevelTransition:
				jsr BONUS.InitialiseTransition
				lda #$01
				sta TITLECARD.IsBonus
				jsr TITLECARD.TransitionIn

				jsr BONUS.Start
				
			!EndLevelLoop:
				lda TITLECARD.UpdateReady
				beq !EndLevelLoop-
				lda #$00
				sta TITLECARD.UpdateReady

					jsr BONUS.Update
					jsr $1003
				clc
				bcc !EndLevelLoop-

				// jsr TITLE_SCREEN.Destroy

				jsr TITLECARD.TransitionOut

				jmp !GAME_ENTRY-




		/////////////////////////////////
		!BonusScreen:
			// lda TITLECARD.UpdateReady
			// beq !IntroLoop-
			// lda #$00
			// sta TITLECARD.UpdateReady
			//UPDATE BONUS

			jmp !Loop- 
			
		/////////////////////////////////
		
	PerformFrameCodeFlag:
		.byte $00

	Counter:
		.byte $00, $00
	SinTableX:
		.fill 256, (sin((i/256) * (PI * 2)) * cos((i/128) * (PI * 2)) * 60 + 150) & $fe 
	CosTableY:
		.fill 256, cos((i/256) * (PI * 2)) * 60 + 80

#import "maps/assets.asm"


* = $b600 "Transition Bars"
#import "animation/transition_bars.asm"

//This fixes the ghost byte issue on screen shake
//By forcing all IRQs to run indirectly from the last 
//page ensuring the ghost byte is always $FF
* = $fff0 "IRQ Indirect vector"
IRQ_Indirect:
	.label IRQ_LSB = $fff1
	.label IRQ_MSB = $fff2
	jmp $BEEF


