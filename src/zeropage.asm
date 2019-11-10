*=$02 "Temp vars zero page" virtual

TEMP1:		.byte $00
TEMP2:		.byte $00
TEMP3:		.byte $00
TEMP4:		.byte $00
TEMP5:		.byte $00
TEMP6:		.byte $00
TEMP7:		.byte $00
TEMP8:		.byte $00
TEMP9:		.byte $00
TEMP10:		.byte $00

VECTOR1: 	.word $00
VECTOR2: 	.word $00
VECTOR3: 	.word $00
VECTOR4: 	.word $00
VECTOR5: 	.word $00
VECTOR6: 	.word $00

IRQ_TEMP1: 	.byte $00


COLLISION_X1: 	.byte $00
COLLISION_X2: 	.byte $00
COLLISION_Y1: 	.byte $00
COLLISION_Y2: 	.byte $00

ZP_COUNTER: 	.byte $00

JOY_ZP1: 	.byte $00
JOY_ZP2: 	.byte $00


.label MAX_SPRITES = 8  //Power of two!!
SPRITE_SCREEN_ROW:	.fill MAX_SPRITES * 2, $00
SPRITE_SCREEN_X:	.fill MAX_SPRITES, $00



