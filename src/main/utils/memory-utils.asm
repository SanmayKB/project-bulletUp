SECTION "Memory utils", ROM0

CopyDEintoMemoryAtHL::
	ld a, [de]
	ld [hli], a 
	inc de 
	dec bc
	ld a, b 
	or c
	jp nz, CopyDEintoMemoryAtHL 
	ret 

CopyDEintoMemoryAtHL_With52Offset::
	ld[de], a 
	add a, 52
	ld [hli], a 
	inc de
	dec bc 
	ld a, b 
	or c 
	jp nz, CopyDEintoMemoryAtHL_With52Offset
	ret