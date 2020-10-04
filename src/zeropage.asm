*=$02 "Temp vars zero page" virtual

COLOR_RESTORE:	.word $00

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
TEMP11:		.byte $00

SCORETEMP1:	.byte $00
SCORETEMP2:	.byte $00
SCOREVECTOR1: .word $00

COLLISION_POINT_X: 	.word $00 
COLLISION_POINT_X1: .word $00
COLLISION_POINT_Y: 	.word $00
COLLISION_POINT_Y1: .word $00
COLLISION_WIDTH: .byte $00
COLLISION_WIDTH1: .byte $00
COLLISION_HEIGHT: .byte $00
COLLISION_HEIGHT1: .byte $00
COLLISION_POINT_X_OFFSET:	.byte $00
COLLISION_POINT_X1_OFFSET:	.byte $00
COLLISION_POINT_Y_OFFSET:	.byte $00
COLLISION_POINT_Y1_OFFSET:	.byte $00
COLLISION_TEMP:
COLLISION_POINT_POSITION:	.word $00
COLLISION_X_DIFF: .word $0100
COLLISION_Y_DIFF: .byte $00

VECTOR1: 	.word $00
VECTOR2: 	.word $00
VECTOR3: 	.word $00
VECTOR4: 	.word $00
VECTOR5: 	.word $00
VECTOR6: 	.word $00
VECTOR7: 	.word $00
VECTOR8: 	.word $00




IRQ_TEMP1: 	.byte $00


COLLISION_X1: 	.byte $00
COLLISION_X2: 	.byte $00
COLLISION_Y1: 	.byte $00
COLLISION_Y2: 	.byte $00

ZP_COUNTER: 	.byte $00

JOY_ZP1: 	.byte $00
JOY_ZP2: 	.byte $00

SPRITE_SOURCE: .word $0000
SPRITE_TARGET: .word $0000

.label MAX_SPRITES = 8  //Power of two!!
SPRITE_SCREEN_ROW:	.fill MAX_SPRITES * 2, $00
SPRITE_SCREEN_X:	.fill MAX_SPRITES, $00

CROWN_POS_X: .word $0000
CROWN_POS_Y: .word $0000

ENEMY_COLLISION_TEMP1: .byte $00
CROWN_OFFSET_TEMP1: .byte $00
CROWN_OFFSET_TEMP2: .byte $00

PLAYER_DYING: .byte $00
HUD_LIVES_TEMP1: .byte $00
HUD_LIVES_TEMP2: .byte $00

PLAYER_X_POINTER: .word $0000
PLAYER_Y_POINTER: .word $0000
DROP_CROWN_TEMP: .byte $00
CROWN_THROW_OFFSET_X:	.byte $00
ENEMY_COUNT_TEMP: .byte $00

CROWN_X: .word $0000

SCREEN_SHAKE_VAL: .byte $00

PIPE_DRAW: .word $0000
PIPE_TEMP: .byte $00
PIPE_DIR: .byte $00
PIPE_LENGTH: .byte $00
PIPE_CHARS: .dword $00000000

MAP_LOOKUP_VECTOR: .word $0000

PLATFORM_TEMP: .byte $00
// PLATFORM_LOOKUP: .word $0000
PLATFORM_LOOKUP_L: .word $0000
PLATFORM_LOOKUP_R: .word $0000
// PLATFORM_CHAR_LOOKUP: .word $0000
PLATFORM_CHAR_LOOKUP_L: .word $0000
PLATFORM_CHAR_LOOKUP_R: .word $0000
PLATFORM_COMPLETE: .byte $00
PLATFORM_COMPLETE_BASE: .byte $00

DOOR_VECTOR1: .word $0000
DOOR_VECTOR2: .word $0000
DOOR_TEMP1: .byte $00
DOOR_TEMP2: .byte $00
DOOR_POSITION_X: .byte $00
DOOR_POSITION_Y: .byte $00

BONUS_VECTOR1: .word $0000
BONUS_VECTOR2: .word $0000
BONUS_COLOR: .byte $00
BONUS_PLAYER: .byte $00
BONUS_PLAYER_BAR_COLOR1: .byte $00
BONUS_PLAYER_BAR_COLOR2: .byte $00
BONUS_BAR_TEMP: .byte $00
BONUS_BAR_TEMP2: .byte $00

POWERUP_PLAYER_NUM: .byte $00

TITLECARD_TEMP1:	.byte $00
TITLECARD_EASE_INDEX:	.byte $00

TITLESCREEN_TEMP1:	.byte $00
TITLESCREEN_SCROLLER_INDEX: .word $0000

UPDATE_POSITION_TEMP: .word $00

BEHAVIOUR_TEMP1: .byte $00
BEHAVIOUR_TEMPWORD1: .word $0000

MESSAGES_TEMP:	.byte $00
MESSAGE_Y_TEMP: .byte $00

FLOOR_COLOR_LOOKUP: .word $0000

SCORE_NEGATIVE_TEMP: .byte $00

TRANSITION_TEMP1:		.byte $00
TRANSITION_TEMP2:		.byte $00
TRANSITION_TEMP3:		.byte $00
TRANSITION_TEMP4:		.byte $00
TRANSITION_TEMP5:		.byte $00


CURRENT_LEVEL: .byte $00
P1_SCORE:
	.fill 8, $00
P1_BONUS_SCORE:
	.fill 6, $30
P2_SCORE:
	.fill 8, $00
P2_BONUS_SCORE:
	.fill 6, $30



zp_len_lo: .byte $00
zp_src_lo: .byte $00
zp_src_hi: .byte $00
zp_bits_hi: .byte $00
zp_bitbuf: .byte $00
zp_dest_lo: .byte $00
zp_dest_hi: .byte $00