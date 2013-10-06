	CLR.L -(SP)
	MOVE.W #$20,-(SP)
	TRAP #1
	ADD.L #6,SP
	MOVEM.L PALETTE(PC),D0-D7
	MOVEM.L D0-D7,$FFFF8240.W
	BSR CLEARSCREENS
	BSR MAKEUPSTARS
	
LOOP
	MOVE.W #37,-(SP)
	TRAP #14
	ADD.L #2,SP
	MOVE.W #$700,$FFFF8240.W
	MOVE.L #$78000,LOGBASE
	MOVE.L #$70000,D0
	LSR.W #8,D0
	MOVE.L D0,$FFFF8200.W
	MOVE.L #OLDSTARS,OLDSTARPOINT
	BSR ERASESUB			ERASE STARS SUBROUTINE
	BSR STARSSUB			DRAW STARS ROUTINE
	CLR.W $FFFF8240.W
	MOVE.W #37,-(SP)
	TRAP #14
	ADD.L #2,SP
	MOVE.W #$700,$FFFF8240.W
	MOVE.L #$70000,LOGBASE
	MOVE.L #$78000,D0
	LSR.W #8,D0
	MOVE.L D0,$FFFF8200.W
	MOVE.L #OLDSTARS1,OLDSTARPOINT
	BSR ERASESUB			ERASE STARS SUBROUTINE
	BSR STARSSUB			DRAW STARS ROUTINE
	CLR.W $FFFF8240.W
	BRA LOOP

CLEARSCREENS
	LEA $70000,A0
	MOVE.W #16383,D0
CL_LOOP
	CLR.L (A0)+
	DBF D0,CL_LOOP
	RTS

***************************** STAR ROUTINE ************************	


****ERASE OLD STARS
ERASESUB

	MOVE.L OLDSTARPOINT,A0
	MOVEQ #0,D1
	REPT 200
	MOVE.L (A0)+,A6		GET POSITION
	MOVE.W D1,(A6)		WIPE EM OUT
	ENDR
	RTS

STARSSUB
	LEA STARS(PC),A0
	MOVE.L LOGBASE(PC),A1
	MOVE.L OLDSTARPOINT(PC),A5
	MOVE.W #199,D0
	MOVE.W #$FFFF,D1
DRAWLOOP
	MOVE.L (A0)+,A2
	MOVE.W (A2)+,D2
	CMP.W D1,D2
	BNE.S CONT
	MOVE.L (A0),-(A0)
	BRA.S DRAWLOOP
CONT
	MOVE.W (A2)+,D3
	MOVE.L A2,-(A0)
	LEA 8(A0),A0
	LEA (A1,D3.W),A3
	OR.W D2,(A3)
	MOVE.L A3,(A5)+
	DBF D0,DRAWLOOP
	RTS

POINTTAB1	
	DC.W %1000000000000000
	DC.W %0100000000000000
	DC.W %0010000000000000
	DC.W %0001000000000000
	DC.W %0000100000000000
	DC.W %0000010000000000
	DC.W %0000001000000000
	DC.W %0000000100000000
	DC.W %0000000010000000
	DC.W %0000000001000000
	DC.W %0000000000100000
	DC.W %0000000000010000
	DC.W %0000000000001000
	DC.W %0000000000000100
	DC.W %0000000000000010
	DC.W %0000000000000001

MAKEUPSTARS
	LEA DEFSTARS(PC),A0
	MOVE.W #199,D7
MAKELOOP1
	MOVE.W #29,D2
MAKELOOP
	MOVE.W (A0),D0
	MOVE.W 2(A0),D1
	
	CMP.W #1,D0
	BLE 	NEWDATA		IF SO THEN GET NEW DATA
	CMP.W #319,D0		INTO STAR
	BGE	NEWDATA
	CMP.W #8,D1
	BLE	NEWDATA
	CMP.W #167,D1
	BGE	NEWDATA
	
	MULU #160,D1
	MOVE.W D0,D3
	AND.L #15,D0
	AND.L #$FFF0,D3
	ADD.W D0,D0
	MOVE.W POINTTAB1(PC,D0.W),D0
	LSR.W #1,D3
	ADD.L D3,D1
	ADD.L #2,D1

LOOPEND
	MOVE.W D0,(A0)+
	MOVE.W D1,(A0)+
	DBF D2,MAKELOOP

	MOVE.W #29,D2
MAKELOOP2
	MOVE.W (A0),D0
	MOVE.W 2(A0),D1
	
	CMP.W #1,D0
	BLE 	NEWDATA2	IF SO THEN GET NEW DATA
	CMP.W #319,D0		INTO STAR
	BGE	NEWDATA2
	CMP.W #8,D1
	BLE	NEWDATA2
	CMP.W #167,D1
	BGE	NEWDATA2
	
	MULU #160,D1
	MOVE.W D0,D3
	AND.L #15,D0
	AND.L #$FFF0,D3
	ADD.W D0,D0
	MOVE.W POINTTAB(PC,D0.W),D0
	LSR.W #1,D3
	ADD.L D3,D1
	ADD.L #4,D1

LOOPEND2
	MOVE.W D0,(A0)+
	MOVE.W D1,(A0)+
	DBF D2,MAKELOOP2

	MOVE.W #29,D2
MAKELOOP3
	MOVE.W (A0),D0
	MOVE.W 2(A0),D1
	
	CMP.W #1,D0
	BLE 	NEWDATA3		IF SO THEN GET NEW DATA
	CMP.W #319,D0		INTO STAR
	BGE	NEWDATA3
	CMP.W #8,D1
	BLE	NEWDATA3
	CMP.W #167,D1
	BGE	NEWDATA3
	
	MULU #160,D1
	MOVE.W D0,D3
	AND.L #15,D0
	AND.L #$FFF0,D3
	ADD.W D0,D0
	MOVE.W POINTTAB(PC,D0.W),D0
	LSR.W #1,D3
	ADD.L D3,D1
	ADD.L #6,D1

LOOPEND3
	MOVE.W D0,(A0)+
	MOVE.W D1,(A0)+
	DBF D2,MAKELOOP3

	DBF D7,MAKELOOP1
	BSR NEXTBIT	

	RTS

POINTTAB	
	DC.W %1000000000000000
	DC.W %0100000000000000
	DC.W %0010000000000000
	DC.W %0001000000000000
	DC.W %0000100000000000
	DC.W %0000010000000000
	DC.W %0000001000000000
	DC.W %0000000100000000
	DC.W %0000000010000000
	DC.W %0000000001000000
	DC.W %0000000000100000
	DC.W %0000000000010000
	DC.W %0000000000001000
	DC.W %0000000000000100
	DC.W %0000000000000010
	DC.W %0000000000000001

NEWDATA
	MOVE.W #$FFFF,D0
	MOVE.W #$FFFF,D1
	BRA LOOPEND
NEWDATA3
	MOVE.W #$FFFF,D0
	MOVE.W #$FFFF,D1
	BRA LOOPEND3
NEWDATA2
	MOVE.W #$FFFF,D0
	MOVE.W #$FFFF,D1
	BRA LOOPEND2
NEXTBIT
	LEA STARS(PC),A0
	MOVEQ #0,D0
	MOVE.W #85,D1
CVLOOP
	MOVE.L (A0),A1
	ADD.L D0,A1
	MOVE.L A1,(A0)
	LEA 8(A0),A0
	MOVE.L (A0),A1
	ADD.L D0,A1
	MOVE.L A1,(A0)
	LEA 8(A0),A0
	ADD.L #4,D0
	DBF D1,CVLOOP

	MOVEQ #0,D0
	MOVE.W #27,D1
CVLOOP1
	MOVE.L (A0),A1
	ADD.L D0,A1
	MOVE.L A1,(A0)
	LEA 8(A0),A0
	ADD.L #12,D0
	DBF D1,CVLOOP1
	RTS

PALETTE	DC.W $000,$777,$555,$777,$333,$777,$555,$777
	DC.W $000,$000,$000,$000,$000,$000,$000,$000

*************************************
* VARIABLES ETC FOR THE STARS
*************************************

LOGBASE		DC.L 0
OLDSTARPOINT	DC.L 0

OLDSTARS	
	REPT 200
	DC.L $78000
	ENDR

OLDSTARS1
	REPT 200
	DC.L $78000
	ENDR

STARS	
ADDIT	SET 0
	REPT 200
	DC.L DEFSTARS+ADDIT,DEFSTARS+ADDIT
ADDIT	SET ADDIT+360
	ENDR
	
DEFSTARS	INCBIN "STARS\STARS.DAT"

