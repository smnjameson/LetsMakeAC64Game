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