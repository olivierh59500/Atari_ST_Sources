nbpts=	4

 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	move.l	$70.w,OLD_VBL
	move.l	#NEW_VBL,$70.w
	BSR	INITS
 	BSR	CLS
	BSR	CLR_REGISTERS
	BSR	MAKE_YTABLE
	BSR	CLR_REGISTERS
	MOVE.W	#0,$FFFF8240
	MOVE.W	#$FFF,$FFFF8242
	BSR	GEN_CODE
	lea.l 	colors,a0
	lea.l 	$FFFF9800,a1
	move.l 	(a0)+,4(a1)
	move.l 	(a0),8(a1)
	move.l 	(a0)+,12(a1)
	move.l 	(a0),16(a1)
	move.l 	(a0),20(a1)
	move.l 	(a0),24(a1)
	move.l 	(a0)+,28(a1)
	move.l 	(a0),32(a1)
	move.l 	(a0),36(a1)
	move.l 	(a0),40(a1)
	move.l 	(a0),44(a1)
	move.l 	(a0),48(a1)
	move.l 	(a0),52(a1)
	move.l 	(a0),56(a1)
	move.l 	(a0),60(a1)
LOOP
	bsr	TEST_FACE
	cmpi.w	#0,ZDEP
	bgt.s	NO_ZOOM
	addq	#2,ZDEP
NO_ZOOM
	move.l	#0,$FFFF9800
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT1
	MOVE.L	#$FF000000,$FFFF9800
NO_ALt1
	BSR	EFFA
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT2
	MOVE.L	#$00FF0000,$FFFF9800
NO_ALT2
	BSR	MAKE_CUBE
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT3
	MOVE.L	#$FFFF00FF,$FFFF9800
NO_ALT3
	BSR	TRACE
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b 	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w

	MOVEM.L	(SP)+,A1-A2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.L	#$00FF,$FFFF9800
NO_ALT
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE	LOOP
	BRA	SORTIE
*********************
MAKE_CUBE
*	MOVE.W	#7,-(SP)
*	TRAP	#1
*	ADDQ.L	#2,SP
*	ADD.W	#4,X_ANGLE
*	CMPI.W	#720,X_ANGLE
*	BLT.S	NO_STOP
*	CLR.W	X_ANGLE
*NO_STOP
*	CMPI.B	#80,$FFFFC02
*	BNE.S	NO_STOP2
	ADD.W	#4,Y_ANGLE
	CMPI.W	#720,Y_ANGLE
	BLT.S	NO_STOP2 
	CLR.W	Y_ANGLE
NO_STOP2
	ADD.W	#2,Z_ANGLE
	CMPI.W	#720,Z_ANGLE
	BLT.S	NO_STOP3
	CLR.W	Z_ANGLE
NO_STOP3
	BSR	TRIGO
	LEA	XE1,A0
	LEA	DX,A5
	LEA	DY,A4
	MOVE	#7,D0
	MOVE.L	#$3111,D6		;cache on
	MOVEC.L	D6,CACR
	MOVEQ.W	#9,D6
LOOP_TRIGO
	MOVEM.L	D0/A1-A2,-(SP)		
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	LEA	XDEP,A3
	MOVEM.W	(A3)+,D3-D5
	ASL.L	D6,D3		;xdep*512
	ASL.L	D6,D4		;ydep*512
	ASL.L	D6,D5		;zdep*512
	MOVE.L	D3,A1
	MOVE.L	D4,A2
	MOVE.L	D5,A3

	LEA	VAR_3D,A6
	MOVE.W	D0,D3
	MOVE.W	D1,D4
	MOVE.W	D2,D5

	MULS	(A6)+,D3		;d3=c*xe*512
	MULS	(A6)+,D4		;d4=f*ye*512
	MULS	(A6)+,D5		;d5=i*ze*512
	ADD.L	D4,D5		;+f*ye*512
	ADD.L	D3,D5		;+c*xe*512
	ADD.L	A3,D5		;+zdep*512
	ASR.L	#8,D5
	
	MOVE.W	#512,D7
	SUB.W	D5,D7		;d7=512*q
				;d7=512*(1-new_ze/z_pt_fuite)
	MOVE.W	D0,D3		;d3=xe
	MOVE.W	D1,D4		;d4=ye
	MOVE.W	D2,D5		;d5=ze

	MULS	(A6)+,D3		;d3=a*xe*512
	MULS	(A6)+,D4		;d4=d*ye*512
	MULS	(A6)+,D5		;d5=g*ze*512
	ADD.L	D4,D5		
	ADD.L	D3,D5
	ADD.L	A1,D5
	DIVS	D7,D5		;d5=new_xe/q

	MULS	(A6)+,D0		;d0=b*xe*512
	MULS	(A6)+,D1		;d1=e*ye*512
	MULS	(A6)+,D2		;d2=h*ze*512
	ADD.L	D0,D1		
	ADD.L	D1,D2
	ADD.L	A2,D2
	DIVS	D7,D2		;d2=new_ye/q
	ADD.W	#192,D5	
	ADD.W	#120,D2
	MOVEM.L	(SP)+,D0/A1-A2
	MOVE.W	D5,(A5)+
	MOVE.W	D2,(A4)+
	DBF	D0,LOOP_TRIGO
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
***************************************************************************************************
***************************INITIALISATIONS*********************************************************
***************************************************************************************************
INITS
	MOVEC.L	CACR,D0			
	MOVE.L	D0,OLD_CACR
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR

	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		
	MOVE.W	#88,-(SP)		
	TRAP	#14			
	ADDQ.L	#4,SP			
	MOVE.W	D0,OLDMODECODE	

	MOVE.L	#SCREEN,D0	
	ADD.L	#10000,D0
	ANDI.L	#$FFFFFF00,D0
	MOVE.L	D0,SCREEN_ADD

;		  XXXXXXXFSOPV8NNN : flags pour rezs
 	MOVE.W	#%0000000001100011,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP

 	move.l	$44e.w,d0
	MOVE.L	d0,A1
	add.l	#46080*2,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	RTS

*******************************SOUS ROUTINES*****************************************
NEW_VBL
	addq	#1,$466.w
	rte
TRACE
	MOVE.W	DX,X1
	MOVE.W	DY,Y1
	MOVE.W	DX+4,X2
	MOVE.W	DY+4,Y2
	MOVE.W	DX+6,X3
	MOVE.W	DY+6,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BGT	NO_FACE
	MOVE.W	DY,PTS
	MOVE.W	DY+2,PTS+2
	MOVE.W	DY+4,PTS+4
	MOVE.W	DY+6,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+6,CX2
	MOVE.W	DY+6,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX,CX2
	MOVE.W	DY,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI
NO_FACE
	MOVE.W	DX+8,X1
	MOVE.W	DY+8,Y1
	MOVE.W	DX+14,X2
	MOVE.W	DY+14,Y2
	MOVE.W	DX+12,X3
	MOVE.W	DY+12,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BGT	NO_FACE2
;face2
	MOVE.W	DY+8,PTS
	MOVE.W	DY+10,PTS+2
	MOVE.W	DY+12,PTS+4
	MOVE.W	DY+14,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+14,CX2
	MOVE.W	DY+14,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI
NO_FACE2
	MOVE.W	DX+10,X1
	MOVE.W	DY+10,Y1
	MOVE.W	DX+2,X2
	MOVE.W	DY+2,Y2
	MOVE.W	DX,X3
	MOVE.W	DY,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BGT	NO_FACE3
;face3
	MOVE.W	DY+10,PTS
	MOVE.W	DY,PTS+2
	MOVE.W	DY+2,PTS+4
	MOVE.W	DY+12,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX,CX2
	MOVE.W	DY,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX,CX2
	MOVE.W	DY,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	TRACE_FACE
	MOVEQ	#2,D4
	BSR	REMPLI
NO_FACE3
	MOVE.W	DX+8,X1
	MOVE.W	DY+8,Y1
	MOVE.W	DX+6,X2
	MOVE.W	DY+6,Y2
	MOVE.W	DX+4,X3
	MOVE.W	DY+4,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BGT	NO_FACE4
;face4
	MOVE.W	DY+14,PTS
	MOVE.W	DY+4,PTS+2
	MOVE.W	DY+8,PTS+4
	MOVE.W	DY+6,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+6,CX2
	MOVE.W	DY+6,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+8,CX2
	MOVE.W	DY+8,CY2
	BSR	TRACE_FACE
	MOVEQ	#2,D4
	BSR	REMPLI
NO_FACE4
	rts
EFFA
	move.l	WORKECR,a0
	moveq	#0,d1
	move	#235/2,d0
	MOVE.L	#$3111,D7		;active cache
	MOVEC.L	D7,CACR
CLR_2PL
ASM	set	0
	rept	48
	move.l	d1,ASM(a0)
ASM	set	ASM+16
	endr
	lea	192*4(a0),a0
	dbf	d0,CLR_2PL
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	rts
VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
CLS
	MOVEM.L	D0/A0-a1,-(SP)
	MOVE.L	AFFECR,A0
	move.l 	workecr,a1
	MOVE.W	#(11520*2)-1,D0
	MOVEQ	#0,D1
	MOVE.L	#$3111,D6		;cache on
	MOVEC.L	D6,CACR
OK
	MOVE.L	D1,(A0)+
	MOVE.L 	D1,(a1)+
	DBF	D0,OK
	MOVE.L	#$2510,D6		;cache off
	MOVEC.L	D6,CACR		
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d7/a0-a6
	rts
MAKE_YTABLE
	LEA	Y_TABLE,A1
	MOVE.B	#250,D1
	MOVEQ.L	#0,D2
MAKE
	MOVE.L	D2,(A1)+
	ADD.L	#384,D2
	DBF	D1,MAKE
	RTS
TEST_FACE
	MOVE.W	DX,X1
	MOVE.W	DY,Y1
	MOVE.W	DX+4,X2
	MOVE.W	DY+4,Y2
	MOVE.W	DX+6,X3
	MOVE.W	DY+6,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BGT	NO_COLOR
	BSR	TEST_COL_PLAN1
NO_COLOR
	MOVE.W	DX+8,X1
	MOVE.W	DY+8,Y1
	MOVE.W	DX+14,X2
	MOVE.W	DY+14,Y2
	MOVE.W	DX+12,X3
	MOVE.W	DY+12,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BGT	NO_COLOR2
	BSR	TEST_COL_PLAN1
NO_COLOR2
	MOVE.W	DX+10,X1
	MOVE.W	DY+10,Y1
	MOVE.W	DX+2,X2
	MOVE.W	DY+2,Y2
	MOVE.W	DX,X3
	MOVE.W	DY,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BGT	NO_COLOR3
	BSR	TEST_COL_PLAN2
NO_COLOR3
	MOVE.W	DX+8,X1
	MOVE.W	DY+8,Y1
	MOVE.W	DX+6,X2
	MOVE.W	DY+6,Y2
	MOVE.W	DX+4,X3
	MOVE.W	DY+4,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BGT	NO_COLOR4
	BSR	TEST_COL_PLAN2
NO_COLOR4
	rts
TEST_COL_PLAN1
	neg.l	d3
	lea	TAB,a0
	cmp2	(a0),d3
	bcc.s	NO_COL1
	move.l	#$843000bc,$ffff9804
	bra	NO_COL16
NO_COL1
	cmp2	2(a0),d3
	bcc.s	NO_COL2
	move.l	#$803000b8,$ffff9804
	bra	NO_COL16
NO_COl2
	cmp2	4(a0),d3
	bcc.s	NO_COL3
	move.l	#$7c3000b0,$ffff9804
	bra	NO_COL16
NO_COl3
	cmp2	6(a0),d3
	bcc.s	NO_COL4
	move.l	#$783000a8,$ffff9804
	bra	NO_COL16
NO_COl4
	cmp2	8(a0),d3
	bcc.s	NO_COL5
	move.l	#$743000a4,$ffff9804
	bra	NO_COL16
NO_COl5
	cmp2	10(a0),d3
	bcc.s	NO_COL6
	move.l	#$7030009c,$ffff9804
	bra	NO_COL16
NO_COl6
	cmp2	12(a0),d3
	bcc.s	NO_COL7
	move.l	#$6c300094,$ffff9804
	bra	NO_COL16
NO_COl7
	cmp2	14(a0),d3
	bcc.s	NO_COL8
	move.l	#$6830008c,$ffff9804
	bra	NO_COL16
NO_COl8
	cmp2	16(a0),d3
	bcc.s	NO_COL9
	move.l	#$64300088,$ffff9804
	bra	NO_COL16
NO_COl9
	cmp2	18(a0),d3
	bcc.s	NO_COL10
	move.l	#$60300080,$ffff9804
	bra.s	NO_COL16
NO_COl10
	cmp2	20(a0),d3
	bcc.s	NO_COL11
	move.l	#$5c300078,$ffff9804
	bra.s	NO_COL16
NO_COl11
	cmp2	22(a0),d3
	bcc.s	NO_COL12
	move.l	#$58300070,$ffff9804
	bra.s	NO_COL16
NO_COl12
	cmp2	24(a0),d3
	bcc.s	NO_COL13
	move.l	#$5430006c,$ffff9804
	bra.s	NO_COL16
NO_COl13
	cmp2	26(a0),d3
	bcc.s	NO_COL14
	move.l	#$50300064,$ffff9804
	bra.s	NO_COL16
NO_COl14
	cmp2	28(a0),d3
	bcc.s	NO_COL15
	move.l	#$4c30005c,$ffff9804
	bra.s	NO_COL16
NO_COl15
	cmp2	30(a0),d3
	bcc.s	NO_COL16
	move.l	#$48300054,$ffff9804
NO_COl16
	rts
TEST_COL_PLAN2
	neg.l	d3
	lea	TAB,a0
	cmp2	(a0),d3
	bcc.s	NO_COLO1
	move.l	#$843000bc,$ffff9808
	move.l	#$843000bc,$ffff980C
	bra	NO_COLO16
NO_COLO1
	cmp2	2(a0),d3
	bcc.s	NO_COLO2
	move.l	#$803000b8,$ffff9808
	move.l	#$803000b8,$ffff980C
	bra	NO_COLO16
NO_COlO2
	cmp2	4(a0),d3
	bcc.s	NO_COLO3
	move.l	#$7c3000b0,$ffff9808
	move.l	#$7c3000b0,$ffff980C
	bra	NO_COLO16
NO_COlO3
	cmp2	6(a0),d3
	bcc.s	NO_COLO4
	move.l	#$783000a8,$ffff9808
	move.l	#$783000a8,$ffff980C
	bra	NO_COLO16
NO_COlO4
	cmp2	8(a0),d3
	bcc.s	NO_COLO5
	move.l	#$743000a4,$ffff9808
	move.l	#$743000a4,$ffff980C
	bra	NO_COLO16
NO_COlO5
	cmp2	10(a0),d3
	bcc.s	NO_COLO6
	move.l	#$7030009c,$ffff9808
	move.l	#$7030009c,$ffff980C
	bra	NO_COLO16
NO_COlO6
	cmp2	12(a0),d3
	bcc.s	NO_COLO7
	move.l	#$6c300094,$ffff9808
	move.l	#$6c300094,$ffff980C
	bra	NO_COLO16
NO_COlO7
	cmp2	14(a0),d3
	bcc.s	NO_COLO8
	move.l	#$6830008c,$ffff9808
	move.l	#$6830008c,$ffff980C
	bra	NO_COLO16
NO_COlO8
	cmp2	16(a0),d3
	bcc.s	NO_COLO9
	move.l	#$64300088,$ffff9808
	move.l	#$64300088,$ffff980C
	bra	NO_COLO16
NO_COlO9
	cmp2	18(a0),d3
	bcc.s	NO_COLO10
	move.l	#$60300080,$ffff9808
	move.l	#$60300080,$ffff980C
	bra	NO_COLO16
NO_COlO10
	cmp2	20(a0),d3
	bcc.s	NO_COLO11
	move.l	#$5c300078,$ffff9808
	move.l	#$5c300078,$ffff980C
	bra	NO_COLO16
NO_COlO11
	cmp2	22(a0),d3
	bcc.s	NO_COLO12
	move.l	#$58300070,$ffff9808
	move.l	#$58300070,$ffff980C
	bra.s	NO_COLO16
NO_COlO12
	cmp2	24(a0),d3
	bcc.s	NO_COLO13
	move.l	#$5430006c,$ffff9808
	move.l	#$5430006c,$ffff980C
	bra.s	NO_COLO16
NO_COlO13
	cmp2	26(a0),d3
	bcc.s	NO_COLO14
	move.l	#$50300064,$ffff9808
	move.l	#$50300064,$ffff980C
	bra.s	NO_COLO16
NO_COlO14
	cmp2	28(a0),d3
	bcc.s	NO_COLO15
	move.l	#$4c30005c,$ffff9808
	move.l	#$4c30005c,$ffff980C
	bra.s	NO_COLO16
NO_COlO15
	cmp2	30(a0),d3
	bcc.s	NO_COLO16
	move.l	#$48300054,$ffff9808
	move.l	#$48300054,$ffff980C
NO_COlO16
	rts
****************************ROUTINE DE CALCUL************************************
********************************************************
*precalculs trigonometriques			*
*en entree:x_angle,y_angle,z_angle(angles de rotation) *	
*en sortie:(A,B,C,D,E,F,G,H,I)*512		*				
********************************************************


TRIGO
	MOVEM.L	D0-D7/A4-A6,-(SP)
	LEA	COS_TAB,A4
	LEA	SIN_TAB,A5
	LEA	X_ANGLE,A6
	MOVE.W	(A6)+,D2	;d2=x angle
	MOVE.W	(A6)+,D1	;d1=y ...
	MOVE.W	(A6)+,D0	;d0=z ...

	MOVE.W	(A5,D2.W),D5	;d5=sinx
	MOVE.W	(A4,D2.W),D4	;d4=cosx
	MOVE.W	(A5,D1.W),D3	;d3=siny
	MOVE.W	(A4,D1.W),D2	;d2=cosy
	MOVE.W	(A5,D0.W),D1	;d1=sinz
	MOVE.W	(A4,D0.W),D0	;d0=cosz

	LEA	VAR_3D,A6		;zone sauvegarde calc intermediaire
	MOVEQ	#9,D7
	;**********CALCUL DE C************
SP_C
	MOVE.W	D3,D6		;siny
	NEG.W	D6		;-siny	
	MOVE.W	D6,(A6)+
	;**********CALCUL DE F************
SP_F	
	MOVE.W	D2,D6		;cosy
	MULS	D5,D6		;cosy*sinx
	ASR.L	D7,D6		;/512
	MOVE.W	D6,(A6)+
	;**********CALCUL DE I************
SP_I
	MOVE.W	D2,D6		;cosy
	MULS	D4,D6		;cosy*cosx
	ASR.L	D7,D6		;/512
	MOVE.W	D6,(A6)+		
	;**********CALCUL DE A************
SP_A
	MOVE.W	D0,D6		;cosz
	MULS	D2,D6		;cosz*cosy
	ASR.L	D7,D6		
	MOVE.W	D6,(A6)+
	;**********CALCUL DE D************
SP_D
	MOVE.W	D1,D6		;sinz	
	MULS	D4,D6		;sinz*cosx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D0,D6		;cosz
	MULS	D3,D6		;cosz*siny
	ASR.L	D7,D6		
	MULS	D5,D6		;cosz*siny*sinx
	ASR.L	D7,D6
	SUB.W	A4,D6		;(cosz*siny*sinx)-(sinz*cosx)
	MOVE.W	D6,(A6)+
	;**********CALCUL DE G************
SP_G
	MOVE.W	D7,D6		;sinz
	MULS	D5,D6		;sinz*sinx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D0,D6		;cosz
	MULS	D3,D6		;cosz*siny
	ASR.L	D7,D6
	MULS	D4,D6		;cosz*siny*cosx
	ASR.L	D7,D6
	ADD.W	A4,D6		;(cosz*siny*cosx)+(sinz*sinx)
	MOVE.W	D6,(A6)+
	;**********CALCUL DE B************
SP_B
	MOVE.W	D1,D6		;sinz		
	MULS	D2,D6		;sinz*cosy
	ASR.L	D7,D6
	MOVE.W	D6,(A6)+
	;**********CALCUL DE E************
SP_E
	MOVE.W	D0,D6		;cosz
	MULS	D4,D6		;cosz*cosx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D1,D6		;sinz
	MULS	D3,D6		;sinz*siny
	ASR.L	D7,D6
	MULS	D5,D6		;sinz*siny*sinx
	ASR.L	D7,D6
	ADD.W	A4,D6		;(sinz*siny*sinx)+(cosz*cosx)
	MOVE.W	D6,(A6)+	
	;**********CALCUL DE H*************
SP_H
	MOVE.W	D0,D6		;cosz
	MULS	D5,D6		;cosz*sinx
	ASR.L	D7,D6	
	MOVE.W	D6,A4

	MOVE.W	D1,D6		;sinz
	MULS	D3,D6		;sinz*siny		
	ASR.L	D7,D6
	MULS	D4,D6		;sinz*siny*cosx
	ASR.L	D7,D6
	SUB.W	A4,D6		;(sinz*siny*cosx)-(cosz*sinx)
	MOVE.W	D6,(A6)+
	MOVEM.L	(SP)+,D0-D7/A4-A6
	RTS
SORTIE
	MOVE.L	OLD_VBL,$70.W
	MOVE.L	OLD_CACR,D0
	MOVEC.L	D0,CACR
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FULLFACE\NEW_FACE\GEN_04.S"
	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FULLFACE\NEW_FACE\REMPLI03.S"
	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\3D_ROUTS\CACHE3.S"
	SECTION 	DATA
OLD_VBL		DC.L	0 
X1		DC.W	0
Y1		DC.W	0
Z1		DC.W	0
X2		DC.W	0
Y2		DC.W	0
Z2		DC.W	0
X3		DC.W	0
Y3		DC.W	0
Z3		DC.W	0
OLD_CACR		DC.L	0
SAV_CY1		DC.W	0
IND		DC.B	0
colors		dc.l	$00400060,$00600080,$008000A0,$00C000E0
AFFECR:		DC.L 	1
WORKECR:		DC.L 	1
OLDXBIOS2:		DC.L	1
OLDMODECODE	DC.W	1
COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB		EQU	COS_TAB+720	
****GRAND CUBE**********
XE1		DC.W	-60
YE1		DC.W	60
ZE1		DC.W	60
;
HXE2		DC.W	-60
YE2		DC.W	-60
ZE2		DC.W	60
;
XE3		DC.W	60
YE3		DC.W	-60
ZE3		DC.W	60
;
XE4		DC.W	60
YE4		DC.W	60
ZE4		DC.W	60
;
XE5		DC.W	60
YE5		DC.W	60
ZE5		DC.W	-60
;
XE6		DC.W	-60
YE6		DC.W	60
ZE6		DC.W	-60
;
XE7		DC.W	-60
YE7		DC.W	-60
ZE7		DC.W	-60
;
XE8		DC.W	60
YE8		DC.W	-60
ZE8		DC.W	-60
*****************
XE		DC.W	0
YE		DC.W	0
ZE		DC.W	0
XDEP		DC.W	0
YDEP		DC.W	0
ZDEP		DC.W	-500
X_ANGLE		DC.W	0
Y_ANGLE		DC.W	0
Z_ANGLE		DC.W	0
CX1		DC.W	0
CX2		DC.W	0
CY1		DC.W	0
CY2		DC.W	0
SCREEN_ADD		DC.L	0
YMAX		DC.W	0
YMIN		DC.W	0
HAUTEUR		DC.W	0
COLOR:		DC.L	0
TAB		DC.W	25000,23560,22348,20874,19320,17554,15730,13734,11956,10080,8236,6496,4730,3074,1664,408,0
PIX_TAB		
		DC.W	0
		DC.W	384
		DC.W	(384+384)
		DC.W	(384+384+383)
		DC.W	(384+384+383+382)
		DC.W	(384+384+383+382+381)
		DC.W	(384+384+383+382+381+380)
		DC.W	(384+384+383+382+381+380+379)
		DC.W	(384+384+383+382+381+380+379+378)
		DC.W	(384+384+383+382+381+380+379+378+377)
		DC.W	(384+384+383+382+381+380+379+378+377+376)
		DC.W	(384+384+383+382+381+380+379+378+377+376+375)
		DC.W	(384+384+383+382+381+380+379+378+377+376+375+374)
		DC.W	(384+384+383+382+381+380+379+378+377+376+375+374+373)
		DC.W	(384+384+383+382+381+380+379+378+377+376+375+374+373+372)
		DC.W	(384+384+383+382+381+380+379+378+377+376+375+374+373+372+371)
	SECTION	BSS
GEN		DS.B	485000
ADR_TAB		DS.B	1000*25
DX		DS.W	50
DY		DS.W	50
XP		DS.W	1
YP		DS.W	1

VAR_3D		DS.W	9
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
SCREEN		DS.W	200000
XMAX		DS.W	300
XMIN		DS.W	300
Y_TABLE		DS.L	300
PTS		DS.W	10
	END
 																																								  																									  																																																																				  																																																															 	  																																		  							

								  																									  																																																																																					  																									  																																												  																														