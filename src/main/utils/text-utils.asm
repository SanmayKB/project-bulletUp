SECTION "Text", ROM0


textFontTileData: INCBIN "src/generated/backgrounds/text-font.2bpp"
textFontTileDataEnd:

LoadTextFontIntoVRAM::
	; Copy the tile data
	ld de, textFontTileData ; de contains the address where data will be copied from;
	ld hl, $9000 ; hl contains the address where data will be copied to;
	ld bc, textFontTileDataEnd - textFontTileData ; bc contains how many bytes we have to copy.
    jp CopyDEintoMemoryAtHL
   

DrawTextTilesLoop::
	;de stores which tile to start in  
	;hl stores the address of our text

	ld a, [hl] 
	cp 255
	ret z


	;write the current character in hl to the current address on the tilemap in de

	ld a, [hl]
	ld [de], a 
	inc hl
	inc de 

	;move on to the next background tile and next character
	jp DrawTextTilesLoop



DrawText_WithTypewriterEffect::

	;wait a small amount of time
	;save our count in this variable
	ld a, 3
	ld [wVBlankCount], a  

	;call our function that waits for the VBlank
	call waitForVBlankFunction

	ld a, [hl]
	cp 255 
	ret z 


	;write the current character in hl to the current location in de
	ld a, [hl]
	ld [de], a 

	inc hl 
	inc de 
	jp DrawText_WithTypewriterEffect