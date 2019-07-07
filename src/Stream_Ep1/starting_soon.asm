.label SCREEN_RAM = $0400
.label COLOR_RAM = $d800

BasicUpstart2(Entry)

TextMap:
	.import binary "../../assets/starting/map.bin"

ColorRamp:
	.byte $01,$07,$0f,$0a,$0c,$04,$0b,$06,$0b,$04,$0c,$0a,$0f,$07

ColorIndex:
	.byte $00

Entry: {
		//Set charset
		lda #%00011000
		sta $d018

		//Set border and background
		lda #0
		sta $d020
		sta $d021


		lda #131
		jsr ClearScreen


		//draw Text
		ldx #0
	!:
		lda TextMap, x
		sta SCREEN_RAM + 12 * 40, x
		inx
		cpx #80
		bne !-


	Loop:
		//Increment our color ramp index
		ldx ColorIndex
		inx
		cpx #14    
		bne !+ 
		ldx #0
	!:
		stx ColorIndex

		//Begin plotting colors in a loop
		ldy #0
	InnerLoop:
		lda ColorRamp, x
		sta COLOR_RAM + 12 * 40 + 8, y
		sta COLOR_RAM + 13 * 40 + 8, y

		inx //Color index
		cpx #14
		bne !+
		ldx #0
	!:
		iny	//Screen column index
		cpy #24
		bne InnerLoop


		//Wait for raster
		lda #$a0
	!:
		cmp $d012
		bne !-


		//Repeat
		jmp Loop
}



ClearScreen: {

		ldx #250
	!:
		dex
		sta SCREEN_RAM, x
		sta SCREEN_RAM + 250, x
		sta SCREEN_RAM + 500, x
		sta SCREEN_RAM + 750, x
		bne !-
		rts 
}

* = $2000
.import binary "../../assets/starting/chars.bin"










