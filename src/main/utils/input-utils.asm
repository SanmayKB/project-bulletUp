SECTION "input variables", WRAM0
mWaitKey:: db

SECTION "input utils", ROM0 
WaitForKeyFunction::
	;save our original value in the stack
	push bc 

WaitForKeyFunction_Loop::
	;save the keys in the last frame
	ld a, [wCurKeys]
	ld [wLastKeys], a 

	;from here we are going to read input from the user which is not a trivial task in the gameboy
	call Input 

	ld a, [mWaitKey]
	ld b,a 
	ld a, [wCurKeys]
	and b
	jp z, WaitForKeyFunction_NotPressed

	ld a, [wLastKeys]
	and b
	jp nz, WaitForKeyFunction_NotPressed

	;restore the original value
	pop bc 

	ret 

WaitForKeyFunction_NotPressed::
	;;Wait a small amount of time
	;save our count in this variable
	ld a, 1 
	ld[wVBlankCount], a 
	;call our function that performs the code
	call waitForVBlankFunction

	jp WaitForKeyFunction_Loop
