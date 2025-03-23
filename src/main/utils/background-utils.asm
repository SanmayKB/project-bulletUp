INCLUDE "src/main/utils/hardware.inc"

SECTION "Background", ROM0

ClearBackground::
	;turn the lcd off
	xor a
	ld [rLCDC], a 

	ld bc, 1024
	ld hl, $9800

ClearBackground_Loop::
	xor a
	ld[hli], a 
	dec bc 
	ld a, b 
	or c 
	jp nz, ClearBackground_Loop

	;turn the lcd on 

	ld a, LCDCF_ON|LCDCF_BGON|LCDCF_OBJON|LCDCF_OBJ16
	ld[rLCDC], a 

	ret 