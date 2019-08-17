BasicUpstart2(Entry)

#import "zeropage.asm"
#import "../libs/vic.asm"
#import "../libs/tables.asm"
#import "../libs/macros.asm"

#import "utils/utils.asm"
#import "utils/irq.asm"

#import "maps/maploader.asm"
#import "player/player.asm"


Entry:
		lda #$00
		sta VIC.BACKGROUND_COLOR
		sta VIC.BORDER_COLOR

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


		jsr MAPLOADER.DrawMap

		jsr PLAYER.Initialise


	//Inf loop
	!Loop:
		lda PerformFrameCodeFlag
		beq !Loop-
		dec PerformFrameCodeFlag

		inc $d020
			inc ZP_COUNTER

			jsr PLAYER.DrawPlayer
			jsr PLAYER.PlayerControl
			jsr PLAYER.JumpAndFall
			jsr PLAYER.GetCollisions

		dec $d020
		jmp !Loop-


	PerformFrameCodeFlag:
		.byte $00

#import "maps/assets.asm"


