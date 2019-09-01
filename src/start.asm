BasicUpstart2(Entry)

#import "zeropage.asm"
#import "../libs/vic.asm"
#import "../libs/tables.asm"
#import "../libs/macros.asm"

#import "utils/utils.asm"
#import "utils/irq.asm"

#import "maps/maploader.asm"
#import "player/player.asm"
#import "player/hud.asm"
#import "animation/charanimations.asm"
#import "soft_sprites/softsprites.asm"

Random: {
        lda seed
        beq doEor
        asl
        beq noEor
        bcc noEor
    doEor:    
        eor #$1d
    noEor:  
        sta seed
        rts
    seed:
        .byte $76
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


		jsr IRQ.Setup

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

		//Setup generated tables
		jsr SOFTSPRITES.CreateMaskTable


		jsr MAPLOADER.DrawMap

		jsr PLAYER.Initialise
		jsr HUD.Initialise
		jsr SOFTSPRITES.Initialise

		//DEBUG
		ldx #$06 //SpriteX
		clc		 //Carry = bit 9 of Sprite X
		ldy #$05 //SpriteY
		lda #180 //Character ID
		jsr SOFTSPRITES.AddSprite

		ldx #$02 //SpriteX
		clc		 //Carry = bit 9 of Sprite X
		ldy #$55 //SpriteY
		lda #180 //Character ID
		jsr SOFTSPRITES.AddSprite


	//Inf loop
	!Loop:
		lda PerformFrameCodeFlag
		beq !Loop-
		dec PerformFrameCodeFlag

			inc ZP_COUNTER

			jsr SOFTSPRITES.ClearSprites

			lda #$00
			ldx #$02
			ldy #$01
			jsr SOFTSPRITES.MoveSprite

			lda #$01
			ldx #$02
			ldy #$ff
			jsr SOFTSPRITES.MoveSprite

			jsr SOFTSPRITES.UpdateSprites
			

			jsr PLAYER.DrawPlayer
			jsr PLAYER.PlayerControl
			jsr PLAYER.JumpAndFall
			jsr PLAYER.GetCollisions


		jmp !Loop-


	PerformFrameCodeFlag:
		.byte $00

#import "maps/assets.asm"






