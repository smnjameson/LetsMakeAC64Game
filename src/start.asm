#import "zeropage.asm"
.segment Code [outPrg="start.prg"]

BasicUpstart2(Entry)

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
		lda #180
		jsr SOFTSPRITES.CreateSpriteBlitTable


		jsr MAPLOADER.DrawMap

		jsr PLAYER.Initialise
		jsr HUD.Initialise
		jsr SOFTSPRITES.Initialise



		//DEBUG
		ldx #$04 	//SpriteX
		clc	 		//Carry = bit 9 of Sprite X
		ldy #$05 	//SpriteY
		lda #1 		//Character ID
		jsr SOFTSPRITES.AddSprite
		tax
		lda #$0f
		sta SOFTSPRITES.SpriteColor, X

		ldx #$24 	//SpriteX
		clc	 		//Carry = bit 9 of Sprite X
		ldy #$25 	//SpriteY
		lda #1 		//Character ID
		jsr SOFTSPRITES.AddSprite
		tax
		lda #$0e
		sta SOFTSPRITES.SpriteColor, X

		ldx #$44 	//SpriteX
		clc	 		//Carry = bit 9 of Sprite X
		ldy #$45 	//SpriteY
		lda #1 		//Character ID
		jsr SOFTSPRITES.AddSprite
		tax
		lda #$0d
		sta SOFTSPRITES.SpriteColor, X

		ldx #$64 	//SpriteX
		clc	 		//Carry = bit 9 of Sprite X
		ldy #$85 	//SpriteY
		lda #1 		//Character ID
		jsr SOFTSPRITES.AddSprite
		tax
		lda #$0c
		sta SOFTSPRITES.SpriteColor, X
		
		ldx #$84 	//SpriteX
		clc	 		//Carry = bit 9 of Sprite X
		ldy #$05 	//SpriteY
		lda #1 		//Character ID
		jsr SOFTSPRITES.AddSprite
		tax
		lda #$0b
		sta SOFTSPRITES.SpriteColor, X

		ldx #$a4 	//SpriteX
		clc	 		//Carry = bit 9 of Sprite X
		ldy #$25 	//SpriteY
		lda #1 		//Character ID
		jsr SOFTSPRITES.AddSprite
		tax
		lda #$0a
		sta SOFTSPRITES.SpriteColor, X

		ldx #$c4 	//SpriteX
		clc	 		//Carry = bit 9 of Sprite X
		ldy #$45 	//SpriteY
		lda #1 		//Character ID
		jsr SOFTSPRITES.AddSprite
		tax
		lda #$0d
		sta SOFTSPRITES.SpriteColor, X

		ldx #$e4 	//SpriteX
		clc	 		//Carry = bit 9 of Sprite X
		ldy #$85 	//SpriteY
		lda #1 		//Character ID
		jsr SOFTSPRITES.AddSprite
		tax
		lda #$0c
		sta SOFTSPRITES.SpriteColor, X

	//Inf loop
	!Loop:
		lda PerformFrameCodeFlag
		beq !Loop-
		dec PerformFrameCodeFlag

			inc ZP_COUNTER

			
			jsr SOFTSPRITES.ClearSprites

			lda #$00
			ldx #$02
			ldy #$00
			jsr SOFTSPRITES.MoveSprite

			lda #$01
			ldx #$00
			ldy #$02
			jsr SOFTSPRITES.MoveSprite

			lda #$02
			ldx #$00
			ldy #$03
			jsr SOFTSPRITES.MoveSprite

			lda #$03
			ldx #$04
			ldy #$00
			jsr SOFTSPRITES.MoveSprite

			lda #$04
			ldx #$02
			ldy #$00
			jsr SOFTSPRITES.MoveSprite

			lda #$05
			ldx #$00
			ldy #$02
			jsr SOFTSPRITES.MoveSprite

			lda #$06
			ldx #$04
			ldy #$00
			jsr SOFTSPRITES.MoveSprite

			lda #$07
			ldx #$00
			ldy #$03
			jsr SOFTSPRITES.MoveSprite


			inc $d020
			jsr SOFTSPRITES.UpdateSprites
			lda #$00
			sta $d020

			jsr PLAYER.DrawPlayer
			jsr PLAYER.PlayerControl
			jsr PLAYER.JumpAndFall
			jsr PLAYER.GetCollisions


		jmp !Loop- 


	PerformFrameCodeFlag:
		.byte $00

#import "maps/assets.asm"






