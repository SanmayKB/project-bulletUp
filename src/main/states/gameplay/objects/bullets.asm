INCLUDE "src/main/utils/hardware.inc"
INCLUDE "src/main/utils/constants.inc"

SECTION "BulletVariables", WRAM0
wSpawnBullet: db
wActiveBulletCounter: db;how many bullets are on screen 
wUpdateBulletCounter: db ;how many bullets we have updated
wBullets: ds MAX_BULLET_COUNT*PER_BULLET_BYTES_COUNT

SECTION"Bullets", ROM0
bulletMetasprite::
	.metasprite1: db 0,0,0,0
	.metaspriteEnd: db 128 

bulletTileData:: INCBIN"src/generated/sprites/bullet.2bpp"
bulletTileDataEnd::

InitializeBullets::
	xor a
	ld [wSpawnBullet], a 

	;copy the bullet tile data into vram
	ld de, bulletTileData
	ld hl, BULLET_TILES_START
	ld bc, bulletTileDataEnd - bulletTileData 
	call CopyDEintoMemoryAtHL

	;reset the number of active bullets to 0 
	xor a 
	ld [wActiveBulletCounter], a 

	ld b, a 
	ld hl, wBullets
	ld [hl], a 

InitializeBullets_Loop:
	;increase the address 
	ld a, 1 
	add PER_BULLET_BYTES_COUNT
	ld l, a 
	ld a, h 
	adc 0 
	ld h, a 


	;increase the number of initialized bullets
	ld a, b 
	inc a 
	ld b, a 

	cp MAX_BULLET_COUNT
	ret z 

	jp InitializeBullets_Loop

;updating the bullets
UpdateBullets::
	;make sure we have some active enemies
	ld a ,[wSpawnBullet]
	ld b, a 
	ld a , [wActiveBulletCounter]
	or b 
	cp 0 
	ret z 

	;reset our counter for the number of bullets we have checked
	xor a 
	ld [wUpdateBulletCounter], a 

	;get the address of the first bullet in hl 
	ld a , LOW(wBullets)
	ld l, a
	ld a, HIGH(wBullets)
	ld h, a 

	jp UpdateBullets_PerBullet

UpdateBullets_Loop:
	;check our counter if it is zero 
	;stop the function 	
	ld a, [wUpdateBulletCounter]
	inc a 
	ld [wUpdateBulletCounter], a 

	;check if we have already 
	ld a, [wUpdateBulletCounter]
	cp MAX_BULLET_COUNT
	ret nc 


	;increase the bullet data our address is pointing to 
	ld a, l  
	add PER_BULLET_BYTES_COUNT
	ld l, a 
	ld a, h 
	adc 0 
	ld h, a 

UpdateBullets_PerBullet:
	;the first byte indicates wether the bullet is active or not
	;if it is not zero then it is active and go to the normal update section

	ld a, [hl]
	and a 
	jp nz, UpdateBullets_PerBullet_Normal

	;if we need to spawn the bullet then go ahead and spawn it 
	ld a, [wSpawnBullet]
	and a 
	jp z, UpdateBulets_Loop

UpdateBullets_PerBullet_SpawnDeactivatedBullet:
	;reset the variable so that we do no spawn anymore
	xor a 
	ld [wSpawnBullet],a 

	;increase how many bullets are active
	ld a, [wActiveBulletCounter]

	push hl

	;set the current bullet as active 
	ld a, 1 
	ld [hli], a 

	;get the unscaled player x position in b 
	ld a, [wPlayerPositionX]
	ld b, a 
	ld a, [wPlayerPositionX+1]
	ld d, a 
	srl d
	rr b 
	srl d
	rr b 
	srl d 
	rr b 
	srl d 
	rr b 

	;set the position as the position of player
	ld a, b 
	ld [hli],a

	;set the y position
	ld a, [wPlayerPositionY]
	ld[hli], a 
	ld a, [wPlayerPositionY+1]
	ld [hli],a 
	pop hl


UpdateBullets_PerBullet_Normal:
	;save our active byte
	push hl
	inc hl 

	;get our x position
	ld a, [hli] 
	ld b, a 

	;get our 16 bit y position
	ld a, [hl] 
	sub BULLET_MOVE_SPEED
	ld[hli], a 
	ld c,a 
	ld a, [hl] 
	sbc 0 
	ld [hl], a 
	ld d, a 

	pop hl; go to the active byte


	;descale the y position
	srl d 
	rr c 
	srl d 
	rr c 
	srl d 
	rr c 
	srl d 
	rr c 

	;see if our non scaled byte is above 160 
	ld a,c 
	cp 178
	;if it is below 160, deactivate
	jp nc, UpdateBullets_PerBullet_SpawnDeActivateIfOutOfBounds

	push hl 

	;draw a metasprite

	 ; Save the address of the metasprite into the 'wMetaspriteAddress' variable
    ; Our DrawMetasprites functoin uses that variable

    ld a, LOW(bulletMetasprite)
    ld [wMetaspriteAddress],  a 
    ld a, HIGH(bulletMetasprite)
    ld [wMetaspriteAddress+1], a

    ;save the x position 
    ld a, b 
    ld [wMetaspriteX], a 


    ;save the y position
    ld a, c 
    ld [wMetaspriteY], a 


    ;actually call the drawMetasprites function
    call DrawMetasprites

    pop hl 

    jp UpdateBullets_Loop

UpdateBullets_PerBullet_SpawnDeActivateIfOutOfBounds:
	;if it's y value is greater than 160 
	;set as inactive 
	xor a 
	ld [hl], a 

	;decrease counter 
	ld a, [wActiveBulletCounter] 
	dec a 
	ld [wActiveBulletCounter], a 

	jp UpdateBullets_Loop

FireNextBullet::
	ld a, [wActiveBulletCounter]
	cp MAX_BULLET_COUNT
	ret nc 

	;set our spawn bullet variable to 0 
	ld a , 1 
	ld [wSpawnBullet], a 
	ret 