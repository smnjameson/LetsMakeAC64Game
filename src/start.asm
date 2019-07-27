BasicUpstart2(Entry)

#import "zeropage.asm"
#import "../libs/vic.asm"
#import "../libs/tables.asm"
#import "utils/utils.asm"

#import "maps/maploader.asm"
#import "player/player.asm"

Entry:
		lda #$00
		sta VIC.BACKGROUND_COLOR
		sta VIC.BORDER_COLOR

		lda #$7f	//Disable CIA IRQ's to prevent crash because 
		sta $dc0d
		sta $dd0d

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


		jsr MAPLOADER.DrawMap

		jsr PLAYER.Initialise


	//Inf loop
	!Loop:
		:waitForRasterLine($ff)

		inc $d020

		inc ZP_COUNTER

		jsr PLAYER.DrawPlayer
		
		jsr PLAYER.PlayerControl
		
		jsr PLAYER.JumpAndFall

		jsr PLAYER.GetCollisions

		dec $d020
		
		:waitForRasterLine($82)

		jmp !Loop-


#import "maps/assets.asm"


