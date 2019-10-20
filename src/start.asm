#import "zeropage.asm"

BasicUpstart2(Entry)

#import "../libs/tables.asm" 
#import "../libs/vic.asm"
#import "../libs/macros.asm"

#import "utils/utils.asm"
#import "utils/irq.asm"

#import "maps/maploader.asm"
#import "player/player.asm"
#import "player/projectiles.asm"
#import "player/hud.asm"
#import "animation/charanimations.asm"
#import "soft_sprites/softsprites.asm"

#import "enemies/enemies.asm"
#import "enemies/behaviours.asm"

#import "enemies/enemymacros.asm"

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
		lda #$00
		sta VIC.BACKGROUND_COLOR
		lda #$00
		sta VIC.BORDER_COLOR

		lda #$05
		sta VIC.EXTENDED_BG_COLOR_1
		lda #$0e
		sta VIC.EXTENDED_BG_COLOR_2

		lda #$ff
		sta VIC.SPRITE_ENABLE
		sta VIC.SPRITE_MULTICOLOR	

		jsr IRQ.Setup

		//Bank out BASIC and Kernal ROM
		lda $01
		and #%11111000 
		ora #%00000101
		sta $01

		//Set VIC BANK 3
		// lda $dd00
		and #%11111100
		sta $dd00

		//Set screen and character memory
		lda #%00001100
		sta VIC.MEMORY_SETUP

		jsr Random.init

		//Setup generated tables
		jsr SOFTSPRITES.CreateMaskTable
		lda #180
		ldx #$04
		jsr SOFTSPRITES.CreateSpriteBlitTable


		jsr MAPLOADER.DrawMap
 

		jsr PLAYER.Initialise
		jsr HUD.Initialise
		jsr SOFTSPRITES.Initialise

		jsr ENEMIES.Initialise



	//Inf loop
	!Loop:
		lda PerformFrameCodeFlag
		beq !Loop-
		dec PerformFrameCodeFlag

			
			inc ZP_COUNTER
			

			// inc $d020 //1
			jsr SOFTSPRITES.UpdateSprites
			
			// inc $d020 //2
			jsr PLAYER.DrawPlayer
			// inc $d020 //3
			jsr PLAYER.PlayerControl
			// inc $d020 //4
			jsr PLAYER.JumpAndFall
			// inc $d020 //5
 			jsr PLAYER.GetCollisions

			// inc $d020 //6
			jsr PROJECTILES.UpdateProjectiles

			// inc $d020 //7
			jsr ENEMIES.UpdateEnemies

			lda #$00
			// sta $d020
		jmp !Loop- 


	PerformFrameCodeFlag:
		.byte $00

	Counter:
		.byte $00, $00
	SinTableX:
		.fill 256, (sin((i/256) * (PI * 2)) * cos((i/128) * (PI * 2)) * 60 + 150) & $fe 
	CosTableY:
		.fill 256, cos((i/256) * (PI * 2)) * 60 + 80
#import "maps/assets.asm"

 