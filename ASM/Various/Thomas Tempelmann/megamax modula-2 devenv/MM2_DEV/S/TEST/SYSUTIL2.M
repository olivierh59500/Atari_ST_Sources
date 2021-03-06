MODULE T; (*$E MOS *)

(*$C-*)
from terminal import WriteString, writeln, write, writepg, read;
FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD, VAL;
from strconv import lhextostr, hextostr;
import sysutil2;

var ad: ADDRESS;
    ch, c: char;
    b: byte;

PROCEDURE fehler (s: ARRAY OF CHAR): BOOLEAN;
  BEGIN
    writeln;
    WriteString (s);
    WriteString (' (Y/N) ? ');
    read (ch);
    writeln;
    RETURN cap (ch) = 'Y'
  END fehler;

PROCEDURE zeige (s: Array of char);
  BEGIN
    WriteString (s);
    writeln;
  END zeige;

VAR ljbuf1: SysUtil2.JumpBuf;

PROCEDURE zwei;

  PROCEDURE lokal;
    BEGIN
       IF fehler ('lokal') THEN SysUtil2.LongJump (ljbuf1, 1) END;
    END lokal;

  BEGIN (* von 'zwei' *)
    lokal;
    IF fehler ('zwei') THEN SysUtil2.LongJump (ljbuf1, 2) END;
  END zwei;

PROCEDURE haupt;
  BEGIN
    CASE SysUtil2.SetJump (ljbuf1) OF
      0: (* Label wurde deklariert -> 'zwei' aufrufen: *)
         zwei;
         (* 'zwei' kehrte ohne Fehler zur�ck *)
         zeige ('Kein Fehler.')
    | 1: zeige ('Fehler in Prozedur "lokal" !')
    | 2: zeige ('Fehler in Prozedur "zwei" !')
    END;
  END haupt;

var svm: SysUtil2.ModeBuf;
    sysbase [$4f2]: ADDRESS;

BEGIN
  writepg;
  haupt;
  haupt;
  haupt;
  haupt;
  writeln;
  sysutil2.supervisormode (svm);
  WriteString ('OS-Base: ');
  WriteString (lhextoStr (sysbase,0));
  sysutil2.usermode (svm);
  writeln;
  WriteString ('3 = ');
  WriteString (hextoStr (sysutil2.irmask(),0));
  writeln;
  sysutil2.setirmask(2);
  WriteString ('2 = ');
  WriteString (hextoStr (sysutil2.irmask(),0));
  writeln;
  read (c)
END T.
 