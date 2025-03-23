INCLUDE "src/main/utils/hardware.inc"
INCLUDE "src/main/utils/macros/text-macros.inc"

SECTION "StoryStateASM", ROM0

InitStoryState::
	;turn the lcd on
	ld a , LCDCF_ON| LCDCF_BGON|LCDCF_OBJON|LCDCF_OBJ16
	ld [rLCDC], a 

	ret 

Story:
	.Line1 db "you are in a new", 255
	.Line2 db "for two weeks", 255
	.Line3 db "to improve your", 255
	.Line4 db "grades.", 255
	.Line5 db "find your way", 255
	.Line6 db "to your dorm", 255
	.Line7 db "good luck", 255

UpdateStoryState::
	;call the function that writes text over background and window tiles
	ld de, $9821
	ld hl, Story.Line1
	call DrawText_WithTypewriterEffect

	ld de, $9861
	ld hl, Story.Line2
	call DrawText_WithTypewriterEffect

	ld de, $98A1
	ld hl, Story.Line3
	call DrawText_WithTypewriterEffect

	ld de, $98E1
	ld hl, Story.Line4
	call DrawText_WithTypewriterEffect

	;now we wait for the user to press A
	ld a , PADF_A
	ld [mWaitKey], a 

	call WaitForKeyFunction

	ld de, $9821
	ld hl, Story.Line5
	call DrawText_WithTypewriterEffect

	ld de, $9861
	ld hl, Story.Line6
	call DrawText_WithTypewriterEffect

	ld de, $98A1
	ld hl, Story.Line7
	call DrawText_WithTypewriterEffect

	ld a, PADF_A
	ld [mWaitKey], a 
	call WaitForKeyFunction

	ld a, 2 
	ld [wGameState], a 
	jp NextGameState
	
