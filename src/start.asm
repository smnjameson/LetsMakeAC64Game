BasicUpstart2(Entry)

#import "zeropage.asm"
#import "../libs/vic.asm"

START:
#import "maps/maploader.asm"
.print ("MAP LOADER = "+ (*-START))

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

	//Set screen and characther memory
	lda #%00001100
	sta VIC.MEMORY_SETUP



	jsr MAPLOADER.DrawMap

	//Inf loop
	jmp *
	

#import "maps/assets.asm"


