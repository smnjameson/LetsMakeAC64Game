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