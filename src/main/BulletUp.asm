INCLUDE "src/main/utils/hardware.inc"

SECTION "GameVariables", WRAM0
	wLastKeys:: db
	wCurKeys:: db
	wNewKeys:: db
	wGameState:: db

SECTION "Header", ROM0[$100]
	jp EntryPoint

	ds $150 - @, 0 ;making room for the header, all the bytes from the current position to address 150 will be initialised to 0

EntryPoint:
	;turn off audio circuitry
	xor a ;a really fast and efficient way to initalise a to 0
	ld [rNR52], a 
	ld [wGameState], a 

	call WaitForOneVBlank;we are waiting for a vblank before initiating the library

	;now that we have waited for the library we call the sprobj library
	call InitSprObjLibWrapper

	;Turn the LCD off
	xor a 
	ld [rLCDC],a 


	;loading our common text font into VRAM
	call LoadTextFontIntoVRAM

	;turning on the screen 
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON |LCDCF_WIN9C00
	ld [rLCDC], a 

	;during the first blank frame we load the pallate to both the background and objects
	ld %11100100
	ld [rBGP],a 
	ld [rOBP0], a 
	



	