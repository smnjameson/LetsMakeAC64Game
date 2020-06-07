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


.macro waitForRasterLine( line ) {
		lda #line
		cmp VIC.RASTER_Y
		bne *-3	
}


.macro DebugHex(address, x, y, charoffset) {
		.if(address != null) {
			lda address
		}
		pha
		and #$0f
		clc
		adc #charoffset	
		sta SCREEN_RAM + y * 40 + x + 1
		pla
		lsr 
		lsr 
		lsr
		lsr
		and #$0f
		clc
		adc #charoffset
		sta SCREEN_RAM + y * 40 + x
}



.macro easeOutBounce(start, finish, length) {
	.var d = length
	.var b = start
	.var c = finish - start

	.for(var i=0; i <= d; i++) {
		.var t = i/d;
		.if (t < (1/2.75)) {
			.byte floor(c*(7.5625*t*t) + b);
		} else {
			.if (t < (2/2.75)) {
				.byte floor(c*(7.5625*(t-=(1.5/2.75))*t + 0.75) + b)
			} else {
				.if (t < (2.5/2.75)) {
					.byte floor(c*(7.5625*(t-=(2.25/2.75))*t + 0.9375) + b)
				} else {
					.byte floor(c*(7.5625*(t-=(2.625/2.75))*t + 0.984375) + b)		
				}
			}
		} 
	}
}

.macro easeInQuart(start, finish, length) {
	.var d = length
	.var b = start
	.var c = finish - start
	
	.for(var i=0; i <= d; i++) {
		.var t = i/d;
		.byte floor(c *(t*t*t*t) + b);
	}
}

.macro easeLinear(start, finish, length) {
	.var d = length
	.var b = start
	.var c = finish - start
	
	.for(var i=0; i <= d; i++) {
		.var t = i/d;
		.byte floor(c * t + b);
	}
}
