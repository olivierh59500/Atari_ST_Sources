	SECTION	text
convert16To8
	lea	sampleInfoTable,a3

	cmpi.w	#16,sampleResolution(a3)
	bne	.not16bit

	graf_mouse	#2,#0

	tst.w	sampleMode(a3)
	bne	.convert16To8D2D

	move.l	sampleDataSize(a3),d3
	ror.l	#1,d3

	move.l	sampleAddress(a3),a0
	move.l	sampleDataSize(a3),d0
	move.l	d3,sampleDataSize(a3)

	move.w	#8,sampleResolution(a3)

	move.l	a0,a1
	subq.l	#1,d0

.loop
	move.w	(a0)+,d2
	ror.w	#8,d2
	move.b	d2,(a1)+
	subq.l	#2,d0
	bgt	.loop

	tst.w	sampleMode(a3)
	bne	.not16bit	; use for the rts
; shrink memory
	m_shrink	d3,sampleAddress(a3)

	clr.w	redrawCached

	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler

	jsr	enterSampleInfo

	lea	blockArea,a0
	clr.l	blockX(a0)
	clr.l	blockX2(a0)
	clr.w	blockDefined(a0)
	move.l	sampleDataSize(a3),d0
	clr.l	blockStart
	move.l	d0,blockEnd
	move.l	d0,blockSize

	graf_mouse	#0,#0

	rts

.not16bit
	rts
;-------------------------------------------------------------------
.convert16To8D2D
	clr.l	blockStart
	move.l	sampleDataSize(a3),d0
	move.l	d0,blockSize
	move.l	d0,blockEnd
	lea	blockArea,a0
	clr.l	blockX(a0)
	clr.l	blockX2(a0)
	clr.w	blockDefined(a0)	; remove defined block

	jsr	initD2DFunction	; open files and read/write
				; header info
; d2 = D2D Buffer Size
; d4 = read file handle
; d5 = write file handle
	move.l	blockSize,d6	; size to process
	move.l	d2,d3
	asr.l	#1,d3	; find half buffer size

	lea	.loop,a4
.loopD2D
	cmp.l	d3,d6
	bgt	.load
	move.l	d6,d3
.load
	f_read	D2DBuffer,d3,d4	; read into buffer

	move.l	D2DBuffer,a0
	move.l	a0,a1
	add.l	d3,a1

	move.l	d3,d0
	move.l	a1,-(sp)
	pea	.returnD2D
	jmp	(a4)
.returnD2D
	move.l	(sp)+,a1
	move.l	d3,d2
	asr.l	#1,d2
	f_write	a1,d2,d5
	cmp.l	d0,d2
	bne	diskFull

	sub.l	d3,d6
	bgt	.loopD2D

	f_close	d4

	lea	sampleInfoTable,a3
	move.l	sampleDataSize(a3),d0
	asr.l	#1,d0
	move.l	d0,sampleDataSize(a3)
	move.w	#8,sampleResolution(a3)
	f_seek	#0,d5,#0
	movem.l	d1-d7/a0-a6,-(sp)
	callModule	#4
	movem.l	(sp)+,d1-d7/a0-a6
	move.w	sampleHeaderSize(a3),d0
	ext.l	d0
	f_write	#sampleHeader,d0,d5
	f_close	d5

	jsr	copyFileD2D

	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler

	jsr	enterSampleInfo
	graf_mouse	#0,#0
	rts