// #define NIGHT

.label SCREEN_RAM = $0400
.label COLOR_RAM = $d800
.label SPRITE_POINTERS = SCREEN_RAM + $03f8

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

.macro WaitForNextLine() {
		lda $d012
		cmp $d012
		beq *-3
}

.macro WaitForLine(line) {
		lda #line
		cmp $d012
		bne *-3
}

* = $02 "Zeropage setup" virtual
TEMP1:	.byte $00
GlobalTimer: .byte $00


BasicUpstart2(Entry)

TextMap:
	#if NIGHT
	.import binary "../../assets/starting/map2.bin"
	#else
		.import binary "../../assets/starting/map.bin"
	#endif

ColorRamp:
	#if NIGHT
		.byte $01,$0d,$03,$0e,$04,$0b,$06,$00,$06,$0b,$04,$0e,$03,$0d
	#else
		.byte $01,$07,$0f,$0a,$0c,$04,$0b,$06,$0b,$04,$0c,$0a,$0f,$07
	#endif
	

ColorIndex:
	.byte $00

Counter:
	.byte $00, $00


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


		lda #255
		jsr ClearScreen

		//Set charset
		lda #%00011000
		sta $d018



		//draw Text
		ldx #0
	!:
		lda TextMap, x
		sta SCREEN_RAM + 12 * 40, x
		lda #$06
		sta COLOR_RAM + 12 * 40, x
		inx
		cpx #160
		bne !-


		ldx #0
	!:
		#if NIGHT
			lda #$00
		#else
			lda #$0e
		#endif
		sta COLOR_RAM + 12 * 40, x
		inx
		cpx #80
		bne !-


		#if NIGHT
			.for(var i=0; i< 30; i++) {
				.var pos = random() * 400
				lda #[105 + random() * 4]
				sta SCREEN_RAM + pos
				.if(pos > 80) {
					sta SCREEN_RAM + 999 - (pos -  mod(pos,40)) + 82 - (40 - mod(pos,40))
				}
				lda #1
				sta COLOR_RAM + pos
			}
		#endif

		//Setup sprites
		lda #$ff
		sta $d015
		sta $d01c
		lda #$01
		sta $d025
		lda #$0e
		sta $d026
		lda #$0c
		ldx #$07
	!:
		sta $d027, x
		dex
		bpl !-

	Loop:
		//Repeat
		jmp Loop
}


ColorIndexLoop: {
		//Increment our color ramp index
		ldx ColorIndex

		lda GlobalTimer
		and #$03
		bne !NoAnim+

		inx
		cpx #14    
		bne !+ 
		ldx #0
	!:
		stx ColorIndex
	!NoAnim:


		//Begin plotting colors in a loop
		ldy #0
	InnerLoop:
		lda ColorRamp, x
		sta $d021
		inx //Color index
		cpx #14
		bne !+
		ldx #0
	!:
		:WaitForNextLine()
		iny	//Screen column index
		cpy #12
		bne InnerLoop

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

			#if NIGHT
				lda #$00
			#else
				lda #$0e
			#endif
			sta $d021	
			lda #$c4
			sta $d016

			#if NIGHT
				jsr DoStars
			#else
				jsr DoClouds
			#endif

			
			jsr CalculateRipple
			inc GlobalTimer

			:WaitForLine($7c)
			jsr DoWaves

			:WaitForLine($91)
			ldx #$12
			dex
			bne *-1

			jsr ColorIndexLoop



			inc $d020
			// 

			lda #$00
			sta $d020

			:WaitForLine($a2)
			ldx #$03
			dex
			bne *-1

			lda #$06
			sta $d021


			ldy ColorIndex
			:WaitForNextLine()
			ldx #$01
		!:
			lda RippleTable,x
			sta $d016


			lda RippleColTable, y
			// lda #$0e
			sta $d021
			iny
			inx
			cpx #$0e
			beq !+
			:WaitForNextLine()
			bne !-
		!:

			lda #$06
			sta $d021
			:WaitForNextLine()			
			:WaitForNextLine()

			lda #$c4
			sta $d016

			:WaitForLine(200)
			jsr DoWaves2
			
		
			jsr Random
			tax
			lda #$0e
			sta COLOR_RAM + 16 * 40,x
			jsr Random
			tax
			lda #$0f
			sta COLOR_RAM + 18 * 40 + 24,x
			jsr Random
			tax
			lda #$0f
			sta COLOR_RAM + 16 * 40,x
			jsr Random
			tax
			lda #$06
			sta COLOR_RAM + 18 * 40 + 24,x


			asl $d019 //Acknowledging the interrupt
		:RestoreState();
		rti
	}
}



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


*=*"wave data"
WaveX:
	.fill 8, random() * 160
WaveY:
	.fill 8, random() * 44 + 172
WaveFrame:
	.fill 8, random()* 64
Wave2X:
	.fill 8, random() * 160
Wave2Y:
	.fill 8, random() * 40 + 216
Wave2Frame:
	.fill 8, random()* 64


DoWaves: {


		lda #$24
		sta $d00e
		lda #$a4
		sta $d00f
		lda #$06
		sta $d02e
		lda #205
		sta SPRITE_POINTERS + 7


		lda #$00
		sta $d010
		lda #$80
		sta $d01d
		lda #$ff
		sta $d01c

		ldx #$00
		ldy #$00
	!Loop:
		lda WaveY, x
		sta $d001, y
		lda WaveX, x
		asl
		sta $d000, y

		lda $d010 
		bcc !NoMSB+
	!MSB:
		ora POT, x
	!NoMSB:
	!Set:
		sta $d010

		lda WaveFrame, x
		cmp #$07
		bcs !NoWave+

		txa 
		pha
			lda WaveFrame, x
			tax
			lda WaveAnim, x	
			sta TEMP1
		pla
		tax 
			lda TEMP1			
			// lda #192
			sta SPRITE_POINTERS, x

		jmp !SpriteDone+
	!NoWave:
		lda #191
		sta SPRITE_POINTERS, x
	!SpriteDone:
		iny
		iny
		inx
		cpx #$07
		bne !Loop-


		//UPDATE?
		lda GlobalTimer
		and #$07
		beq !+
		rts
	!:

		ldx #$00
	!Loop:
		dec WaveFrame, x

		lda WaveFrame,x
		cmp #$ff
		bne !Next+

		jsr Random
		and #$1f
		clc 
		adc #$07
		sta WaveFrame, x

	!:
		jsr Random
		and #$1f
		// cmp #44
		// bcs !-
		adc #172
		sta WaveY, x
!:
		jsr Random
		asl
		sta WaveX, x

	!Next:
		cmp #$07
		bcs !+
			dec WaveY, x
	!:	
		inx
		cpx #$07
		bne !Loop-



		rts
}

DoWaves2: {

		ldx #$00
		ldy #$00
	!Loop:
		lda Wave2Y, x
		sta $d001, y
		lda Wave2X, x
		asl
		sta $d000, y

		lda $d010 
		bcc !NoMSB+
	!MSB:
		ora POT, x
		jmp !Set+
	!NoMSB:
		and INVPOT, x
	!Set:
		sta $d010

		lda Wave2Frame, x
		cmp #$07
		bcs !NoWave+

		txa 
		pha
			lda Wave2Frame, x
			tax
			lda WaveAnim, x	
			sta TEMP1
		pla
		tax 
			lda TEMP1			
			// lda #192
			sta SPRITE_POINTERS, x

		jmp !SpriteDone+
	!NoWave:
		lda #191
		sta SPRITE_POINTERS, x
	!SpriteDone:
		iny
		iny
		inx
		cpx #$07
		bne !Loop-

		//UPDATE?
		lda GlobalTimer
		and #$03
		beq !+
		rts
	!:


		ldx #$00
	!Loop:
		dec Wave2Frame, x

		lda Wave2Frame,x
		cmp #$ff
		bne !Next+

		jsr Random
		and #$1f
		clc 
		adc #$07
		sta Wave2Frame, x

	!:
		jsr Random
		and #$1f
		// bcs !-
		adc #216
		sta Wave2Y, x
!:
		jsr Random
		asl
		sta Wave2X, x

	!Next:
		cmp #$07
		bcs !+
			dec Wave2Y, x
			dec Wave2Y, x
	!:
		inx
		cpx #$07
		bne !Loop-
		rts
}

WaveAnim:
	.byte 195,194,193,192,193,194,195
StarAnim:
	.byte 204,203,202,201,202,203,204
POT:
	.byte 1,2,4,8,16,32,64,128
INVPOT:
	.byte 255-1,255-2,255-4,255-8, 255-16,255-32,255-64,255-128






StarX:
	.fill 8, random() * 160
StarY:
	.fill 8, random() * 40 + 64
StarFrame:
	.fill 3, random()* 64
	.fill 5, 191
DoStars: {
		lda #$00
		sta $d010
		sta $d01d
		lda #$00
		sta $d01c

		ldx #$00
		ldy #$00
	!Loop:
		lda StarY, x
		sta $d001, y
		lda StarX, x
		asl
		sta $d000, y

		lda $d010 
		bcc !NoMSB+
	!MSB:
		ora POT, x
	!NoMSB:
	!Set:
		sta $d010

		lda StarFrame, x
		cmp #$07
		bcs !NoWave+

		txa 
		pha
			lda StarFrame, x
			tax
			lda StarAnim, x	
			sta TEMP1
		pla
		tax 
			lda TEMP1			
			// lda #192
			sta SPRITE_POINTERS, x

		jmp !SpriteDone+
	!NoWave:
		lda #191
		sta SPRITE_POINTERS, x

	!SpriteDone:
		lda #$01
		sta $d027, x
		iny
		iny
		inx
		cpx #$08
		bne !Loop-


		//UPDATE?
		lda GlobalTimer
		and #$03
		beq !+
		rts
	!:

		ldx #$00
	!Loop:
		dec StarFrame, x

		lda StarFrame,x
		cmp #$ff
		bne !Next+

		jsr Random
		and #$3f
		clc 
		adc #$07
		sta StarFrame, x

	!:
		jsr Random
		and #$3f
		// cmp #44
		// bcs !-
		adc #40
		sta StarY, x
!:
		jsr Random
		asl
		sta StarX, x

	!Next:
		inx
		cpx #$03
		bne !Loop-
		rts
}


CloudXF:
	.fill 8, 0
CloudX:
	.fill 8, random() * 256
CloudXMSB:
	.fill 8, random() * 2
CloudY:
	.fill 8, random() * 40 + 64
CloudSpeedX:
	.byte 1,1,1,0,0,0,0,0
CloudSpeedXF:
	.fill 3, random() * 128
	.fill 2, random() * 96 + 160
	.fill 3, random() * 32 + 128

CloudColor:
	.byte 1,1,1,15,15,12,12,12


DoClouds: {
		lda #$00
		sta $d010
		lda #$00
		sta $d01c
		lda #$ff
		sta $d01d

		ldy #$0a
		ldx #$05
	!:
		lda #200
		sta SPRITE_POINTERS, x
		lda CloudColor, x
		sta $d027, x
		lda CloudY, x
		sta $d001, y
		lda CloudX, x
		sta $d000, y
		lda CloudXMSB, x
		beq !Skip+
		lda POT, x
		ora $d010
		sta $d010
	!Skip:


		lda CloudXF, x
		sec
		sbc CloudSpeedXF, x
		sta CloudXF, x
		lda CloudX, x
		sbc CloudSpeedX, x
		sta CloudX, x
		bcs !NoBorrow+
		lda CloudXMSB, x
		eor #$01
		sta CloudXMSB, x
		beq !NoBorrow+
		lda CloudX, x
		sec
		sbc #$08
		sta CloudX, x
	!NoBorrow:

		lda CloudXMSB, x
		beq !NoRepos+
		lda CloudX, x
		cmp #200
		bcc !NoRepos+
		cmp #220
		bcs !NoRepos+
		jsr Random
		and #$3f
		clc
		adc #40
		sta CloudY, x
		lda #199
		sta CloudX, x
	!NoRepos:
		dey
		dey
		dex
		bpl !-
		rts
}	












RippleTable: 
	.fill 16, $c8
RippleColTable: 
	.byte 14,6,14,6,6,14,14,6,14,6,14,6,6,14
	.byte 14,6,14,6,6,14,14,6,14,6,14,6,6,14
SinTables:
	.for(var j = 3.5; j >= 0; j-=0.5) {
		.fill 16, sin((i/16) * PI * 2) * j + 4 + $c0
	}
RippleCounter:
	.byte $00

CalculateRipple: {
		
		lda GlobalTimer
		and #$03
		beq !+
		rts
	!:
		ldx RippleCounter
		
		inx
		txa
		and #$0f
		sta RippleCounter

	!:
		ldy #$00

		.for(var i=0; i< 8; i++) {
			lda SinTables + 16 * (7-i), x
			sta RippleTable, y
			iny
			sta RippleTable, y
			iny

			inx
			txa
			and #$0f
			tax
		}
		
		rts
}













* = $2000
.import binary "../../assets/starting/chars.bin"



* = $2fc0
	.fill 64, 0 //Blank sprite
* = $3000
.import binary "../../assets/starting/sprites.bin"





