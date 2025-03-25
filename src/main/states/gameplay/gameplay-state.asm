INCLUDE "src/main/utils/hardware.inc"
INCLUDE "src/main/utils/macros/text-macros.inc"

SECTION "Gameplay Variables", WRAM0

wScore:: ds 6
wLives:: db


SECTION "GamePlayState", ROM0

wScoreText:: db "score", 255
wLivesText:: db "lives", 255

InitGameplayState::
	ld a, 3
	ld [wLives], a 

	xor a 
	ld [wScore], a
	ld [wScore + 1], a
	ld [wScore+2], a
	ld [wScore+3], a 
	ld [wScore+4], a
	ld [wScore+5], a

	call InitializeBackground
	call InitializePlayer
	call InitializeBullets
	call InitializeEnemies

	;initiate STAT interrupts

	call InitStatInterrupts

	;calling the function that displays texts on the background and window layer

	ld de, $9C00
	ld hl, wScoreText
	call DrawTextTilesLoop

	ld de , $9C0D
	ld hl, wLivesText
	call DrawTextTilesLoop


	call DrawScore
	call DrawLives

	ld a, 0 
	ld [rWY], a 
	ld a, 7
	ld [rWX], a 

	;turn the lcd back on 

	ld a , LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00|LCDCF_BG9800
	ld [rLCDC], a 

	ret 

UpdateGameplayState::
	;save the keys from the last frame (WHY DO WE NEED TO DO THIS????)

	ld a, [wCurKeys]
	ld[wLastKeys], a 

	call Input;from the input.asm takes from https://gbdev.io/gb-asm-tutorial/part2/input.html

	call ResetShadowOAM
	call ResetOAMSpriteAddress

	;now updating the gameplay elements

	call UpdatePlayer
	call UpdateEnemies
	call UpdateBullets
	call UpdateBackground


	;clear the remaining sprites
	call ClearRemainingSprites


	;checking if we need to continue gameplay state or not

	ld a, [wLives]
	cp 250
	jp nc, EndGameplay

	;calling the wait for vblank code 

	call WaitForOneVBlank


	ld a, HIGH(wShadowOAM)
	call hOAMDMA

	call WaitForOneVBlank

	jp UpdateGameplayState


EndGameplay::
	ld a, 0
	ld [wGameState], a 
	jp NextGameState



