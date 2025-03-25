INCLUDE "src/main/utils/hardware.inc"
INCLUDE "src/main/utils/macros/text-macros.inc"

SECTION "BackgroundVariables",WRAM0
mBackgroundScroll:: dw

SECTION "GameplayBackgroundSection", ROM0

stage1Map:INCBIN "src/generated/backgrounds/stage-1.tilemap"
stage1MapEnd:

stage1TileData: INCBIN "src/generated/backgrounds/stage-1.2bpp"
stage1TileDataEnd:

InitializeBackground::
	;copy the tiledata 
	ld de, stage1TileData
	ld hl, $9340
	ld bc, stage1TileDataEnd - stage1TileData
	call CopyDEintoMemoryAtHL

	;copy the tilemap
	ld de, stage1Map
	ld hl, $9800
	ld bc, stage1MapEnd - stage1Map
	call CopyDEintoMemoryAtHL_With52Offset

	xor a 
	ld[mBackgroundScroll], a 
	ld [mBackgroundScroll +1], a 
	ret 

;this is called every frame of the game
UpdateBackground::
	;increase our scaled integer by 5
	;get our true non scaled value and save it in bc for later use
	ld a , [mBackgroundScroll]
	add a, 5
	ld b, a 
	ld [mBackgroundScroll], a 
	ld a, [mBackgroundScroll+1]
	adc 0
	ld c, a 
	ld [mBackgroundScroll+1], a 

	;descale our scaled integer
	;shifts bits to the right four phases
	srl c 
	rr b 
	srl c 
	rr b 
	srl c 
	rr b 
	srl c 
	rr b 

	;use the descaled low byte as background position
	ld a , b 
	ld [rSCY], a 
	ret 