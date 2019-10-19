// #define NIGHT

.label SCREEN_RAM = $0400
.label COLOR_RAM = $d800
.label SPRITE_POINTERS = SCREEN_RAM + $03f8

.label CLEAR_CHAR = 228

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
VECTOR1: .word $0000
VECTOR2: .word $0000
MESSAGE_LOC: .word $0000
GlobalTimer: .byte $00
VerticalPositions:
		.fill 40, 19
VerticalPositionsMinor:
		.fill 40, 19	
NonIRQFlag:
		.byte $00
*=*"LOOKUP" virtual
CHARLOOKUP:
	.fill 80, 0


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
				lda #1
				sta COLOR_RAM + pos
			}
		#endif


		
		ldx #$00
	!:
		lda TextFadeIn, x
		sta COLOR_RAM + 19 * 40, x
		sta COLOR_RAM + 20 * 40, x
		sta COLOR_RAM + 21 * 40, x
		sta COLOR_RAM + 22 * 40, x
		sta COLOR_RAM + 23 * 40, x
		sta COLOR_RAM + 24 * 40, x
		lda #0
		sta VerticalPositions,x

		inx
		cpx #40
		bne !-


		ldx #$00
		ldy #$00
	!:
		tya
		sta SCREEN_RAM + 19 * 40, x
		iny
		tya
		sta SCREEN_RAM + 20 * 40, x
		iny
		tya
		sta SCREEN_RAM + 21 * 40, x
		iny
		tya
		sta SCREEN_RAM + 22 * 40, x
		iny
		tya
		sta SCREEN_RAM + 23 * 40, x
		iny
		tya
		sta SCREEN_RAM + 24 * 40, x
		iny
		inx
		cpx #40
		bne !-

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



	.for(var i=0;i<40; i++) {
		lda #<[$2800  + 48 * i]
		sta CHARLOOKUP + i * 2
		lda #>[$2800  + 48 * i]
		sta CHARLOOKUP + i * 2 + 1
	}

		lda #<MESSAGE
		sta MESSAGE_LOC + 0
		lda #>MESSAGE
		sta MESSAGE_LOC + 1


	!Loop:
		lda NonIRQFlag
		beq !Loop-
		dec NonIRQFlag	


		jsr UpdateVerticalTextPositions	

		//Repeat
		jmp !Loop-
}

ScrollMessage: {
		clc
		ldy #$00
		lda (MESSAGE_LOC), y
		bne !+

		lda #<MESSAGE
		sta MESSAGE_LOC + 0
		lda #>MESSAGE
		sta MESSAGE_LOC + 1		
		rts

	!:

		lda MESSAGE_LOC + 0
		adc #$01
		sta MESSAGE_LOC + 0
		lda MESSAGE_LOC + 1
		adc #$00
		sta MESSAGE_LOC + 1

		rts
}

ROW_LSB:
		.fill 25, <[$0400 + [i * 40]]
ROW_MSB:
		.fill 25, >[$0400 + [i * 40]]
DYCPIndex:
		.byte $00
*=*"DYCP"
DYCPWaveMajor:
		.label WAVE_LENGTH = 4;
		.fill 256, floor((sin((i/256) * PI * 2 * WAVE_LENGTH) + 1) * 18.99) + 1
DYCP_XScroll:
		.byte $07

UpdateVerticalTextPositions: {
		inc DYCPIndex

		dec DYCP_XScroll
		lda DYCP_XScroll
		and #$07
		sta DYCP_XScroll
		cmp #$07
		bne !+
		jsr ScrollMessage
	!:

		ldy DYCPIndex	
		ldx #$00
	!:
		lda DYCPWaveMajor, y
		sta VerticalPositions, x
		iny
		inx
		cpx #40
		bne !-



       	clc
       	ldx #$00 //Column
	!Loop:
       	txa
       	asl
       	tax

		lda CHARLOOKUP, x
       	sta VECTOR1 + 0
       	lda CHARLOOKUP + 1, x
       	sta VECTOR1 + 1

       	txa
       	lsr
       	tax

    	tay
		lda (MESSAGE_LOC), y
		// txa
		asl
		asl
		asl
       	sta VECTOR2 + 0
       	lda #$00
       	adc #$40
       	sta VECTOR2 + 1

       	sec
       	lda VECTOR2 + 0
       	sbc VerticalPositions, x
       	sta VECTOR2 + 0
       	lda VECTOR2 + 1
       	sbc #00
       	sta VECTOR2 + 1

       	ldy VerticalPositions, x
       	dey
       	dey


		lda #$00
		sta (VECTOR1), y
		iny
		lda #$00
		sta (VECTOR1), y
		iny
		.for(var i=0; i<8; i++) {
			lda (VECTOR2), y
			sta (VECTOR1), y
			iny
		}
		lda #$00
		sta (VECTOR1), y
		iny
		lda #$00
		sta (VECTOR1), y
		


		inx
		cpx #40
		bne !Loop-

		rts
}




TextFadeIn: 
		.byte $06,$0e,$03,$0d,$01
		.fill 29, $01
		.byte $01,$0d,$03,$0e,$06,$06

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

		lda #$08
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
			//Set BASE charset
			lda #%00011000
			sta $d018



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

			lda #<MainIRQ2  
			ldx #>MainIRQ2
			sta $fffe   // 0314
			stx $ffff	// 0315

			lda #$7c
			sta $d012


			asl $d019 //Acknowledging the interrupt
		:RestoreState();
		rti
	}

	MainIRQ2:{
			:StoreState()

			jsr DoWaves
			lda #<MainIRQ2a 
			ldx #>MainIRQ2a
			sta $fffe   // 0314
			stx $ffff	// 0315

			lda #$91
			sta $d012


			asl $d019 //Acknowledging the interrupt
		:RestoreState();
		rti
	}

	MainIRQ2a:{
			:StoreState()	

			ldx #$0f
			dex
			bne *-1

			jsr ColorIndexLoop





			lda #<MainIRQ3  
			ldx #>MainIRQ3
			sta $fffe   // 0314
			stx $ffff	// 0315

			lda #$a2
			sta $d012

			asl $d019 //Acknowledging the interrupt
		:RestoreState();
		rti
	}

	MainIRQ3:{
		:StoreState()
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

		lda DYCP_XScroll
		ora #$c0
		sta $d016

			//Set DYCP charset
			lda #%00011010
			sta $d018	

			lda #<MainIRQ4 
			ldx #>MainIRQ4
			sta $fffe   // 0314
			stx $ffff	// 0315

			lda #$c8
			sta $d012

			asl $d019 //Acknowledging the interrupt
		:RestoreState();
		rti
	}

	MainIRQ4:{
		:StoreState()

			jsr DoWaves2




			lda #<MainIRQ5 
			ldx #>MainIRQ5
			sta $fffe   // 0314
			stx $ffff	// 0315

			lda #$ff
			sta $d012

			asl $d019 //Acknowledging the interrupt
		:RestoreState();
		rti
	}

	MainIRQ5:{
		:StoreState()

			lda #$01
			sta NonIRQFlag

			lda #<MainIRQ  
			ldx #>MainIRQ
			sta $fffe   // 0314
			stx $ffff	// 0315

			lda #$08
			sta $d012

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
		lda #$bf
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
		cpx #$05
		bne !Loop-


		//UPDATE?
		lda GlobalTimer
		and #$07
		beq !+
		jmp !End+
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
		cpx #$05
		bne !Loop-

	!End:
		lda #207
		sta SPRITE_POINTERS + 6
		lda #$07
		sta $d02d
		lda #$e8
		sta $d00c
		lda #$e0
		sta $d00d
		lda $d010
		and #$bf
		sta $d010
		lda #$40
		sta $d01b

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
		cpx #$05
		bne !Loop-

		//UPDATE?
		lda GlobalTimer
		and #$03
		beq !+
		jmp !End+
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
		cpx #$05
		bne !Loop-

	!End:



		#if NIGHT
			lda #206
			sta SPRITE_POINTERS + 6
		#endif
	// inc $d020
			:WaitForLine($de)
			ldy reflectIndex
			ldx #$00
		!Loop:
			lda reflectSin,y
			sta $d00c
		#if NIGHT
			lda #1			
		#else
			lda colorBands, y
		#endif
			sta $d02d
			iny
			inx
			cpx #21
			beq !+
			:WaitForNextLine()
			jmp !Loop-
		!:



		lda GlobalTimer
		and #$02
		bne !+

			inc reflectIndex
			ldx reflectIndex
			cpx #21
			bne !+
			ldx #$00
			stx reflectIndex
		!:

		rts
}
reflectIndex:
	.byte $00
colorBands:
	.byte 6,7,6,7,6,7,6,7,6,7,6,7,6,7,6,7,6,7,6,7,6
	.byte 6,7,6,7,6,7,6,7,6,7,6,7,6,7,6,7,6,7,6,7,6
reflectSin:
	.fill 21,  (cos(i/7 * PI) *  sin(i/3 * PI) + cos(i/7 * PI) + sin(i/21 * PI)) * $04 + $e0 
	.fill 21,  (cos(i/7 * PI) *  sin(i/3 * PI) + cos(i/7 * PI) + sin(i/21 * PI)) * $04 + $e0 

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
		jmp !Exit+
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


	!Exit:
		lda #$e8
		sta $d00c
		lda #$50
		sta $d00d
		lda $d010
		and #$bf
		sta $d010
		lda #$01
		sta $d02d
		lda #198
		sta SPRITE_POINTERS + 6
		lda $d017
		and #$bf
		sta $d017	
		

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
		lda #$bf
		sta $d01d

		ldy #$08
		ldx #$04
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


		lda #$e8
		sta $d00c
		lda #$50
		sta $d00d
		lda $d010
		and #$bf
		sta $d010
		lda #$07
		sta $d02d
		lda #199
		sta SPRITE_POINTERS + 6
		lda $d017
		and #$bf
		sta $d017		
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


* = $3000
.import binary "../../assets/starting/sprites.bin"

* = $4000
.import binary "../../assets/starting/smallfont.bin"





ClearDYCP: {
	lda #00

	.for(var i=0; i<240 * 8; i++) {
		sta $2800 + i
	}
	rts
}


MESSAGE:
		.text "                                            "
		.import text "../../assets/starting/message.txt"
		// .text "LET'S MAKE A COMMODORE 64 GAME - EPISODE 10 - 14/09/2019"
		.text "@"
		.text "                                            "
