.label SCREEN_RAM = $0400
.label COLOR_RAM = $d800

.macro StoreState() {
		pha //A
		txa 
		pha //X
		tya 
		pha //Y
}

.macro RestoreState() {
		pla 
		tay
		pla 
		tax 
		pla 
}


*=$02 "Temp vars zero page" virtual
.label maxSprites = $18
.label maxSprites_space = $18
.label spritePadding = $04
//SPRITES
SpriteSortedIndexes:
	.fill maxSprites_space, 0
spriteXpos:
	.fill maxSprites_space, 0
spriteXMSB:
	.fill maxSprites_space, 0
spriteYpos:
	.fill maxSprites_space, 0
spriteFrame:
	.fill maxSprites_space, 0
spriteColor:
	.fill maxSprites_space, 0
spritePriority:
	.fill maxSprites_space, 0

IRQ_TEMP1: 	.byte $00
IRQ_TEMP2: 	.byte $00
IRQ_TEMP3:	.byte $00
IRQ_TEMP4:	.byte $00

IRQ_TEMP5:	.byte $00

BasicUpstart2(Entry)

TextMap:
	.import binary "../../assets/starting/map2.bin"

ColorRamp:
	.byte $01,$07,$0f,$0a,$0c,$04,$0b,$06,$0b,$04,$0c,$0a,$0f,$07

ColorIndex:
	.byte $00

Counter:
	.byte $00, $00
SinTableX:
	// .fill 256, (sin((i/256) * (PI * 2)) ) * 80 + 150 + 24
	.fill 256, (sin((i/256) * (PI * 2))* cos((i/128) * (PI * 2) ) )* 80 * 1 + 150 + 24
CosTableY:
	// .fill 256, cos((i/256) * (PI * 2)) * 85 + 80 + 64
	.fill 256, (cos((i/256) * (PI * 2)) * sin((i/256) * (PI * 2) ))* 85 * 2 + 80 + 64


.label SPRITE_POINTERS = SCREEN_RAM + $03f8
	

Entry: {
	// .break
		//Set border and background
		lda #0
		sta $d020
		sta $d021

		sei
		lda $01
		and #%11111000 
		ora #%00000101
		sta $01

		jsr IRQ.Setup


		lda #131
		jsr ClearScreen

		//Set charset
		lda #%00011000
		sta $d018



		//draw Text
		ldx #0
	!:
		lda TextMap, x
		sta SCREEN_RAM + 12 * 40, x
		inx
		cpx #80
		bne !-


		//Setup sprites
		ldx #$00
	!:
		txa
		and #$0f
		bne !Skip+
		lda #$07
	!Skip:
		sta spriteColor, x
		lda #$c0
		sta spriteFrame, x
		txa
		sta SpriteSortedIndexes, x
		inx
		cpx #maxSprites
		bne !-

		lda #$ff
		sta $d015
		sta $d01c
		sta $d01b

		lda #$0b
		sta $d025
		lda #$01
		sta $d026

	Loop:
		//Wait for raster


		//Repeat
		jmp Loop
}


ColorIndexLoop: {
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
		rts
}

UpdateSprites: {
			//DEBUG SPRITE ROTATION PATTERN
			lda Counter
			sta Counter + 1
			ldx #$00
		!Loop:
			ldy Counter + 1
			lda SinTableX, y
			sta spriteXpos, x
			lda CosTableY, y
			sta spriteYpos, x
			

			lda #$00
			cpy #$80
			bcs !+
			lda #$01
		!:
			sta spritePriority, x

			lda Counter + 1
			clc
			adc #[[256 + maxSprites/2] / maxSprites]
			sta Counter + 1
			inx
			cpx #maxSprites
			bne !Loop-
			inc Counter
			////////////////////////////////
			rts
}

SortSprites: {
			restart:
				//SWIV adapted SORT
                ldy #$00 
                tya 
		sortloop:       
				ldx SpriteSortedIndexes,y
                cmp spriteYpos,x 
                beq noswap2 
                bcc noswap1 
                sty IRQ_TEMP1 
                stx IRQ_TEMP2 
                lda spriteYpos,x 
                ldx SpriteSortedIndexes-1,y
                stx SpriteSortedIndexes,y 
                dex 
                beq swapdone 
		swaploop:       
				ldx SpriteSortedIndexes-1,y 
                stx SpriteSortedIndexes,y 
                cmp spriteYpos,x 
                bcs swapdone 
                dey 
                bne swaploop 
		swapdone:       
				ldx IRQ_TEMP2 
                stx SpriteSortedIndexes,y
                ldy IRQ_TEMP1 
                ldx SpriteSortedIndexes,y 
		noswap1:
	 	    	lda spriteYpos, x 

		noswap2:
		        iny
                cpy #maxSprites
                bne sortloop 
               	rts
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

IRQ: {
	Setup: {
		sei

		lda #$7f	//Disable CIA IRQ's to prevent crash because 
		sta $dc0d
		sta $dd0d

		lda $d01a
		ora #%00000001	
		sta $d01a

		lda #<MainIRQ    
		ldx #>MainIRQ
		sta $fffe   // 0314
		stx $ffff	// 0315

		lda #$00
		sta $d012
		lda $d011
		and #%01111111
		sta $d011	

		asl $d019
		cli
		rts
	}


	SpritePhaseIndex:
		.byte $00
	MainIRQ: {		
		:StoreState()
			
			
			lda SpritePhaseIndex
			bne !+
			jsr UpdateSprites
			jsr SortSprites
		!:
			



			ldx #$04
			stx IRQ_TEMP4
			
			ldx #$00
			lda SpritePhaseIndex
			and #$04
			beq !+
			ldx #$04
			txa
			clc
			adc #$04
			sta IRQ_TEMP4
		!:


			lda #$00
			sta IRQ_TEMP5


			ldy SpritePhaseIndex	
		!Loop:
			sty IRQ_TEMP3
			lda SpriteSortedIndexes, y
			tay

			lda spriteFrame, y
			bne !+
			clc
			txa
			asl
			tax
			lda #$00
			sta $d000, x
			sta $d001, x
			txa
			lsr
			tax
			jmp !Skip+
		!:
			sta SPRITE_POINTERS, x
			lda spriteColor, y
			sta $d027, x

			lda spriteYpos, y
			pha
			lda spriteXpos, y
			pha

			clc
			txa
			asl
			tax
			pla
			sta $d000, x
			pla
			sta $d001, x
			txa
			lsr
			tax

		!Skip:

			ldy IRQ_TEMP3
			inx
			iny
			cpx IRQ_TEMP4
			bne !Loop-


			lda SpritePhaseIndex	
			clc
			adc #$04
			cmp #maxSprites
			bcs !ResetIRQ+


			sta SpritePhaseIndex 
			// jsr ColorIndexLoop

			lda SpritePhaseIndex
			tax
			lda SpriteSortedIndexes, x
			tax
			lda spriteYpos, x
			sec
			sbc #spritePadding	//PADDING
			sta $d012
			// jmp !EndIRQ+



			asl $d019 //Acknowledging the interrupt
			:RestoreState();
			rti


		!ResetIRQ:
			lda #$00
			sta SpritePhaseIndex

			lda #$ff
			sta $d012
			lda $d011
			and #%11111111
			sta $d011	

		!EndIRQ:

			jsr ColorIndexLoop



			asl $d019 //Acknowledging the interrupt
		:RestoreState();
		rti
	}


}


* = $2000
.import binary "../../assets/starting/chars.bin"




* = $3000
.byte $00,$54,$00,$01,$a9,$00,$06,$aa,$40,$05,$ae,$40,$16,$ab,$90,$19
.byte $ab,$90,$16,$aa,$90,$19,$aa,$90,$16,$6a,$90,$19,$aa,$90,$16,$6a
.byte $90,$05,$9a,$40,$06,$66,$40,$01,$99,$00,$00,$54,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$85





