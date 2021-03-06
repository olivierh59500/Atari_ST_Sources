	opt	o+
	output	drawline.prg
nblig = 200-8
	offset	$800
pointsgauches:ds.w	nblig
pointsdroits:ds.w	nblig
	section	text
;
; entr�e :
;	d0=X0
;	d1=Y0
;	d2=X1
;	d3=Y1
;
; registres utilis�s :
;	a0=pointeur pour remplissage coordonn�es
;	a1=adresse retour
;	d0=X0
;	d1=Y0
;	d2=X1
;	d3=Y1
;	d4=cumul
;	d5=partie enti�re de la pente
;	d6=ymin
;	d7=ymax
;
cliphaut
	bpl.s	noline
	muls	d2,d1		;on clippe en haut
	divs	d4,d1		;d0=d0-(d1*DX)/DY
	sub	d1,d0
	clr	d1		;d1=0
	bra.s	cliphaut2
clipbas	bmi.s	noline
	move	#nblig-1,d3
	bra.s	clipbas2
noline:	JMP	(a1)
drawline:
	cmp	d1,d3		;du haut vers le bas
	beq.s	noline		;pas 2 Y pareils !!!!
	lea	pointsdroits\W,a0
	bgt.s	1$
	exg	d0,d2
	exg	d1,d3
	lea	pointsgauches\W,a0
1$
	sub	d0,d2		;dx
	move	d3,d4
	sub	d1,d4		;dy

	cmp	#nblig,d1
	bhs.s	cliphaut
cliphaut2
	cmp	#nblig,d3
	bhs.s	clipbas
clipbas2
	cmp	d6,d1
	bhs.s	.notmin
	move	d1,d6		;nouveau Y minimum
.notmin
	cmp	d7,d3
	bls.s	.notmax
	move	d3,d7		;nouveau Y maximum
.notmax
	sub	d1,d3
;	beq.s	noline
;
; ici d1=Y haut
;     d3=nb pixels verticalement
;     d4=pente en Y
;
; calcul des pointeurs pour �criture donn�es
;
	add	d1,d1
	add	d1,a0

	move	d3,d1
	add	d1,d1

	move	d4,d3
	beq	vertline

	add	d1,d1
	lsr	#1,d4		;d4=cumul
;
; d0=X d�part
; d2=delta X
; d3=delta Y
;
	tst	d2
	bpl	pente_droite
pente_gauche
	neg	d2
	cmp	d2,d3
	bhs	dysupdx

DX3	MACRO
	move	d0,(a0)+
	sub	d2,d4
	bhs.s	\@
	add	d3,d4
	subq	#1,d0
\@
	sub	d5,d0
	ENDM
;dx>dy
	ext.l	d2		;bit 15=0->cleare poids fort
	divu	d3,d2		;d2.h=reste
	move	d2,d5
	swap	d2		;nouveau deltax

	jmp	.letsgo(pc,d1.w)
.letsgo
x	set	0
	rept	nblig
	bra.w	bdx3-x
x	set	x+12
	endr

	rept	nblig-1
	DX3
	ENDR
bdx3
	move	d0,(a0)+
	JMP	(a1)

DY3	MACRO
	move	d0,(a0)+
	sub	d2,d4
	bhs.s	\@
	add	d3,d4
	subq	#1,d0
\@
	ENDM

dysupdx
	jmp	.letsgo(pc,d1.w)
.letsgo
x	set	0
	rept	nblig
	bra.w	bdy3-x
x	set	x+10
	endr

	rept	nblig-1
	DY3
	ENDR
bdy3
	move	d0,(a0)+
	JMP	(a1)

DX1	MACRO
	move	d0,(a0)+
	sub	d2,d4
	bhs.s	\@
	add	d3,d4
	addq	#1,d0
\@
	add	d5,d0
	ENDM

pente_droite
	cmp	d2,d3
	bhs	dysupdx2
;dx>dy
	ext.l	d2		;clear poids fort
	divu	d3,d2
	move	d2,d5
	swap	d2

	jmp	.letsgo(pc,d1.w)
.letsgo
x	set	0
	rept	nblig
	bra.w	bdx1-x
x	set	x+12
	endr

	rept	nblig-1
	DX1
	ENDR
bdx1
	move	d0,(a0)+
	JMP	(a1)
dysupdx2

DY1	MACRO
	move	d0,(a0)+
	sub	d2,d4
	bhs.s	\@
	add	d3,d4
	addq	#1,d0
\@
	ENDM

	jmp	.letsgo(pc,d1.w)
.letsgo
x	set	0
	rept	nblig
	bra.w	bdy1-x
x	set	x+10
	endr

	rept	nblig-1
	DY1
	ENDR
bdy1
	move	d0,(a0)+
	JMP	(a1)
vertline
	neg	d1
	add	#.letsgo-.letsgo2,d1
	jmp	.letsgo2(pc,d1.w)
.letsgo2
	rept	nblig-1
	move	d0,(a0)+
	ENDR
.letsgo
	move	d0,(a0)+
	JMP	(a1)
