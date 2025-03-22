INCLUDE "src/main/utils/hardware.inc"

SECTION "VBlankVariables", WRAM0

wVBlankCount:: db

SECTION "VBlankFunctions", ROM0

WaitForOneVBlank::
	;wait for a small amount of time
	;save our count in this variable
	ld a, 1
	ld[wVBlankCount], a 

WaitForVBlankFunction::

WaitForVBlankFunction_Loop::

	ld a, [rLY]; copy the vertical line to a
	cp 144;check if the vertical line in a is 0
	jp c, WaitForVBlankFunction_Loop ;keep looping till the scanline is still updating the screen

	;not carry here means that we are in the vblank period

	ld a, [wVBlankCount]
	sub 1
	ld [wVBlankCount], a 
	ret z

WaitForVBlankFucntion_Loop2::
	ld a, [rLY]
	cp 144
	jp nc, WaitForVBlankFunction_Loop2

	jp WaitForVBlankFunction_Loop 