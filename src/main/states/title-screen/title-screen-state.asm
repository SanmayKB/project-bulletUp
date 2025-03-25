INCLUDE "src/main/utils/hardware.inc"
INCLUDE "src/main/utils/macros/text-macros.inc"

SECTION "TitleScreenState", ROM0

	PressPlayText:: db "press a to play", 255

	titleScreenTileData: INCBIN "src/generated/backgrounds/title-screen.2bpp"
	titleScreenTileDataEnd:

	titleScreenTileMap: INCBIN "src/generated/backgrounds/title-screen.tilemap"
	titleScreenTileMapEnd:

InitTitleScreenState::
	call DrawTitleScreen

	;drawing the press play text

	;call our function that draws text into background/window tiles

	ld de, $99C3
	ld hl, PressPlayText
	call DrawTextTilesLoop

	;Now we turn the lcd on

	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16
	ld [rLCDC], a 

	ret 



DrawTitleScreen::
	;copy the tile data 
	ld de, titleScreenTileData ;de contains the data from where the data will be copied
	ld hl, $9340 ; hl contains the data where the data will be copied
	ld bc, titleScreenTileDataEnd - titleScreenTileData ;bc contains the number of bytes
	call CopyDEintoMemoryAtHL

	;copy the tilemap
	ld de, 	titleScreenTileMap
	ld hl, $9800
	ld bc, titleScreenTileMapEnd - titleScreenTileMap
	jp CopyDEintoMemoryAtHL_With52Offset

UpdateTitleScreenState::
	;we wait for the user to input a

	ld a, PADF_A
	ld [mWaitKey], a 
	call WaitForKeyFunction

	ld a, 1
	ld [wGameState], a 
	jp NextGameState



	