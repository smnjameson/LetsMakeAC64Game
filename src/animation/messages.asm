MESSAGES: {
	.const MAX_MESSAGES = 5
	.const MAX_LIFE = 64


	MessageType:
		.fill MAX_MESSAGES, $ff	
	MessageDirection:
		.fill MAX_MESSAGES, 0	
	MessageLife:
		.fill MAX_MESSAGES, 0

	PositivePointer:
		.byte $8b
	NegativePointer:	
		.byte $8c
	NeutralPointer:
		.byte $88,$89,$8a

	ColorRamp1:	//Neutral
		.byte $07,$0f,$0f,$0c,$0c,$0f,$0f,$07
	ColorRamp2: //positive
		.byte $01,$0d,$0d,$05,$05,$0d,$0d,$01
	ColorRamp3: //negative
		.byte $00,$02,$02,$0a,$0a,$02,$02,$00

	Initialise: {
			ldx #MAX_MESSAGES - 1
		!:
			lda #$ff
			sta MessageType, x
			dex 
			bpl !-
			rts
	}

	AddMessage: {
			//Accumulator register will be the type
			//$ff = inactive
			//0 = neutral
			//1 = positive (+100)
			//2 = negative (-100)
			//X register will be the Enemy number

			//Message type - Set pointers
			sta MessageType, x
		!CheckNeutral:
			bne !CheckPositive+
		!:
			jsr Random
			and #$03
			cmp #$03
			beq !-
			tay
			lda NeutralPointer, y
			sta SPRITE_POINTERS, x
			bne !MesssageTypeDone+
		!CheckPositive:
			cmp #$01
			bne !CheckNegative+
			lda PositivePointer
			sta SPRITE_POINTERS, x
			bne !MesssageTypeDone+
		!CheckNegative:
			lda NegativePointer
			sta SPRITE_POINTERS, x

		!MesssageTypeDone:


			lda $d01c
			and TABLES.InvPowerOfTwo, x
			sta $d01c

 			//Set a starting life using random to delay a little
			jsr Random
			and #$0f
			sta MESSAGES_TEMP
			lda #$00
			sec
			sbc MESSAGES_TEMP
			sta MessageLife, x
			rts
	}


	Update: {
			ldx #$04
		!loop:
			//Check active
			lda MessageType, x
			bmi !skip+

			//Setup sprite x,y index doubling
			txa 
			asl
			tay
			sty MESSAGE_Y_TEMP

			//Animate
			//Up animation

			lda MessageLife, x			
			bmi !NoMove+
			lda MessageType, x
			cmp #$02
			bcc !Up+
		!Down:
			lda $d001, y 
			clc
			adc #$01
			cmp #$fe
			bcc !+
			lda #$fe
		!:
			sta $d001, y 
			jmp !MoveDone+	

		!Up:
			lda $d001, y 
			sec
			sbc #$01
			cmp #$10
			bcs !+
			lda #$10
		!:
			sta $d001, y 
		!MoveDone:
		!NoMove:


			//Color
			lda MessageLife, x
			and #$07
			tay 

			lda MessageType, x
		!CheckNeutral:
			bne !CheckPositive+
			lda ColorRamp1, y
			bpl !ChecksDone+
		!CheckPositive:
			cmp #$01
			bne !CheckNegative+
			lda ColorRamp2, y
			bpl !ChecksDone+
		!CheckNegative:
			lda ColorRamp3, y
		!ChecksDone:
			sta $d027, x


			//Advance life
			ldy MessageLife, x
			iny
			tya
			sta MessageLife, x
			cmp #MAX_LIFE
			bne !skip+
			lda #$ff
			sta MessageType, x
			//Hide offscreen
			lda #$00
			ldy MESSAGE_Y_TEMP
			sta $d001, y

		!skip:
			dex
			bpl !loop-
			rts
	}



}