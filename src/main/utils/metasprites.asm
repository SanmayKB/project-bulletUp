INCLUDE "src/main/utils/constants.inc"
SECTION "MetaSpritesVariables", WRAM0

wMetaspriteAddress:: dw
wMetaspriteX::db
wMetaspriteY::db

SECTION "MetaSprites", ROM0

DrawMetasprites::
	;get the meta sprite address
	ld a, [wMetaspriteAddress]
	ld l, a 
	ld a, [wMetaspriteAddress+1]
	ld h, a 

	;get the Y position
	ld a, [hli]
	ld b, a 

	;stop if the y position is 128
	ld a, b 
	cp 128 
	ret z 
	ld a, [wMetaspriteY]
	add b 
	ld [wMetaspriteY], a 


	;get the x position
	ld a, [hli]
	ld c, a 

	ld a, [wMetaspriteX]
	add c 
	ld [wMetaspriteX], a 


	;get the tile position

	ld a, [hli]
	ld d,a  

	;get the flag position
	ld a, [hli]
	ld e, a 


	;get our offset address in hl
	ld a ,[wLastOAMAddress+0]
	ld l, a 
	ld a, HIGH(wShadowOAM)
	ld h, a 

	ld a, [wMetaspriteY]
	ld [hli], a 

	ld a, [wMetaspriteX]
	ld [hli], a 

	ld a, e 
	ld[hli], a 

	call NextOAMSprite

	;increase the wmetasprite address
	ld a , [wMetaspriteAddress]
	add a, METASPRITE_BYTES_COUNT
	ld [wMetaspriteAddress], a 
	ld a, [wMetaspriteAddress+1]
	adc 0 
	ld [wMetaspriteAddress+1], a 

	jp DrawMetasprites
