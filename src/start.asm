#import "zeropage.asm"

BasicUpstart2(Entry)


#import "../libs/tables.asm"  
#import "../libs/vic.asm"
#import "../libs/macros.asm"

#import "utils/utils.asm"
#import "utils/irq.asm"


.var music = LoadSid("../assets/sound/cuteplatform.sid")
* = $1000 "Music"
	.fill music.size, music.getData(i)

#import "maps/maploader.asm"
#import "maps/platforms.asm"
#import "maps/door.asm"
#import "player/player.asm"
#import "player/projectiles.asm"
#import "player/hud.asm"
#import "player/crown.asm"
#import "animation/charanimations.asm"
#import "soft_sprites/softsprites.asm"
#import "animation/spritewarp.asm"

#import "enemies/enemies.asm"
#import "enemies/behaviours.asm"
#import "enemies/enemymacros.asm"
#import "enemies/pipes.asm"

#import "animation/transition.asm"
#import "intro/titlescreen.asm"
#import "animation/bonus.asm"
#import "animation/titlecard.asm"

Random: { 
        lda seed
        beq doEor
        asl
        beq noEor
        bcc noEor
    doEor:    
        eor #$1d
        eor $dc04
        eor $dd04
    noEor:  
        sta seed
        rts
    seed:
        .byte $62


    init:
        lda #$ff
        sta $dc05
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
		lda #$0e
		sta VIC.BACKGROUND_COLOR
		lda #$00
		sta VIC.BORDER_COLOR

		lda #$05
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
		jsr TITLECARD.Initialise
	!:
		lda TITLECARD.isComplete
		beq !-


	!INTRO:
	IntroCallback:
		jsr TITLE_SCREEN.Initialise
	!IntroLoop:
		jsr TITLE_SCREEN.Update
		bcc !IntroLoop-


	!GAME_ENTRY:
		sei
		lda #<IRQ.MainIRQ    
		ldx #>IRQ.MainIRQ
		sta IRQ_LSB   // 0314
		stx IRQ_MSB	// 0315
		cli

		lda #$01	//Initialize current song
		jsr $1000
		
		
		jsr MAPLOADER.DrawMap
 		jsr PLAYER.Initialise
		jsr HUD.Initialise
		jsr SOFTSPRITES.Initialise
		jsr SPRITEWARP.init
		jsr ENEMIES.Initialise
		jsr CROWN.Initialise
		jsr DOOR.Initialise
		jsr BONUS.Initialise


		//Generate all sprites
		lda #$10
		jsr SPRITEWARP.generate
		lda #$10
		jsr SPRITEWARP.generate


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
		jmp !NotNormalLoop+


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
			jsr PLATFORMS.UpdateColorOrigins
			jsr DOOR.Update
			jsr $1003
			jmp !Loop- 
		!NotNormalLoop:
		/////////////////////////////////
 
		
		/////////////////////////////////
		!EndLevelTransition:
			jsr TRANSITION.Update
			jsr $1003
			jmp !Loop- 
		// !NotEndLevelTransition:


		/////////////////////////////////
		!BonusScreen:
			jsr BONUS.Update
			jsr $1003
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


//This fixes the ghost byte issue on screen shake
//By forcing all IRQs to run indirectly from the last 
//page ensuring the ghost byte is always $FF
* = $fff0 "IRQ Indirect vector"
IRQ_Indirect:
	.label IRQ_LSB = $fff1
	.label IRQ_MSB = $fff2
	jmp $BEEF


