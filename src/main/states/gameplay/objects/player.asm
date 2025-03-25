INCLUDE "src/main/utils/hardware.inc"
INCLUDE "src/main/utils/constants.inc"

SECTION "PlayerVariables",WRAM0
wPlayerPositionX:: db
wPlayerPositionY:: db

mPlayerFlash:dw

SECTION "player", ROM0

playerTileData: INCBIN "src/generated/sprites/player.2bpp"
playerTileDataEnd:

playerTestMetaSprite::
	.metasprite1:db 0,0,0,0
	.metasprite2: db 0,8,2,0
	.metaspriteEnd: db 128

InitializePlayer::
	xor a
	ld [mPlayerFlash], a 
	ld [mPlayerFlash + 1 ],a 

	xor a 
	ld [wPlayerPositionX], a 
	ld [wPlayerPositionY], a 

	ld a, 5 
	ld[wPlayerPositionX+1], a 
	ld [wPlayerPositionY+1], a 


CopyPlayerTileDataIntoVRAM:
	;copy the player's data in the vram
	ld de, playerTileData
	ld hl, PLAYER_TILES_START
	ld bc, playerTileDataEnd - playerTileData
	call CopyDEintoMemoryAtHL

	ret 


UpdatePlayer::

UpdatePlayer_HandleInput:
	ld a,[wCurKeys]
	and PADF_UP
	call nz, MoveUp

	ld a,[wCurKeys]
	and PADF_DOWN
	call nz, MoveDown

	ld a,[wCurKeys]
	and PADF_LEFT
	call nz, MoveLeft

	ld a,[wCurKeys]
	and PADF_RIGHT
	call nz, MoveRight

	ld a,[wCurKeys]
	and PADF_A
	call nz, TryShoot

	ld a, [mPlayerFlash+0]
	ld b, a 
	ld a ,[mPlayerFlash+1]
	ld c, a 

UpdatePlayer_UpdateSprite_CheckFlashing:
	ld a, b 
	or c 
	jp UpdatePlayer_UpdateSprite 

	;dec by 5 
	ld a, b 
	sub 5 
	ld b, a 
	ld a ,c 
	sbc 0 
	ld c, a 

UpdatePlayer_UpdateSprite_DecreaseFlashing:
	ld a, b 
	ld [mPlayerFlash], a 
	ld a,c 
	ld [mPlayerFlash+1], a

	;descale bc 
	srl c 
	rr b  
	srl c 
	rr b
	srl c 
	rr b
	srl c 
	rr b

	ld a, b 
	cp 5 
	jp c , UpdatePlayer_UpdateSprite_StopFlashing

	bit 0,b
	jp z, UpdatePlayer_UpdateSprite

UpdatePlayer_UpdateSprite_Flashing:
	ret 

UpdatePlayer_UpdateSprite_StopFlashing:
	xor a
	ld[mPlayerFlash], a 
	ld[mPlayerFlash+1], a 

UpdatePlayer_UpdateSprite:
	;get the unscaled player position in b 
	ld a , [wPlayerPositionY]
	ld b,a 
	ld a, [wPlayerPositionY+1]
	ld d , a 

	srl d 
	rr b 
	srl d 
	rr b 
	srl d 
	rr b 
	srl d 
	rr b

	;get the unscaled x position in c 
	ld a, [wPlayerPositionX]
	ld c , a 
	ld a , [wPlayerPositionX+1]
	ld e, a 

	srl e 
	rr c 
	srl e 
	rr c 
	srl e 
	rr c 
	srl e 
	rr c 

	;draw the player metasprite
	ld a, LOW(playerTestMetaSprite)
    ld [wMetaspriteAddress+0], a
    ld a, HIGH(playerTestMetaSprite)
    ld [wMetaspriteAddress+1], a


    ; Save the x position
    ld a, b
    ld [wMetaspriteX], a

    ; Save the y position
    ld a, c
    ld [wMetaspriteY], a

    ; Actually call the 'DrawMetasprites function
    call DrawMetasprites;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ret

DamagePlayer::
	xor a 
	ld [mPlayerFlash], a 
	inc a 
	ld [mPlayerFlash+1], a 

	ld a, [wLives]
	dec a 
	ld [wLives],a 

	ret 






TryShoot:
	ld a, [wLastKeys]
	and PADF_A
	ret nz
	jp FireNextBullet

MoveUp:
	;decrease player's y positon
	ld a, [wPlayerPositionY]
	sub PLAYER_MOVE_SPEED
	ld [wPlayerPositionY], a 

	ld a, [wPlayerPositionY]
	sbc a 
	ld [wPlayerPositionY], a

	ret

MoveDown:
	ld a, [wPlayerPositionY]
	add PLAYER_MOVE_SPEED
	ld [wPlayerPositionY], a 

	ld a, [wPlayerPositionY+1]
	adc a 
	ld [wPlayerPositionY+1], a

	ret

MoveLeft:
	ld a, [wPlayerPositionX]
	sub PLAYER_MOVE_SPEED
	ld [wPlayerPositionX], a 

	ld a, [wPlayerPositionY+1]
	sbc a 
	ld [wPlayerPositionY+1], a

	ret

MoveRight:
	ld a, [wPlayerPositionX]
	add PLAYER_MOVE_SPEED
	ld [wPlayerPositionX], a 

	ld a, [wPlayerPositionY+1]
	adc a 
	ld [wPlayerPositionY+1], a

	ret

