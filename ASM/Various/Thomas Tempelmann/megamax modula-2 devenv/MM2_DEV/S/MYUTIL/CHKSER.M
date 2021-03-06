MODULE CheckSerial;

(*    =======================================
       Vertraulich! Keinesfalls weitergeben!
      =======================================
   
      Seriennummern im Compiler �berpr�fen
        
      15.12.87  jm   /1.0/  lauff�hige Version
                            (meldet nur, wenn ok; keine weitere Analyse)
     
*)

FROM Files   IMPORT File, Open, Create, Close, Remove, State,
                    Access, ReplaceMode;
FROM Binary  IMPORT SeekMode, Seek, ReadBytes, ReadWord, WriteWord, FileSize;
FROM Paths   IMPORT PathList, StdPaths, SearchFile, ListPos;
FROM InOut   IMPORT WriteString, WriteLn, Read, WriteCard, ReadCard, WriteHex;
FROM Storage IMPORT ALLOCATE;
FROM Strings IMPORT Concat;
FROM StrConv IMPORT CardToStr;
FROM SYSTEM  IMPORT ADDRESS;
FROM PrgCtrl IMPORT TermProcess;


CONST   compname = 'A:\M2.MOD';          (* Name des Codefiles *)
          NrKeys = 2;                 (* Anzahl verschiedener Schl�ssel *)
        maxCount = 10;                (* max. Anzahl Referenzen pro Nummer *)

TYPE     PosList = ARRAY [1..maxCount] OF LONGCARD;

VAR
             lead,                    (* LeadIn-Worte vor Seriennummern  *)
         expCount,                    (* erwartete Anzahl der Vorkommen  *)
            value: ARRAY [0..NrKeys] OF CARDINAL;
          offsets: ARRAY [0..NrKeys] OF PosList;

           RegLen,
         FeedBack,
          Iterate: ARRAY [1..NrKeys] OF CARDINAL;


PROCEDURE err (s: ARRAY OF CHAR; fatal: BOOLEAN);
  VAR c: CHAR;
  BEGIN
    WriteLn; WriteString ('>> '); WriteString (s); WriteLn;
    IF fatal THEN
      Read (c); TermProcess (1);
    END
  END err;
  

PROCEDURE ReadCompiler (VAR a: ADDRESS; VAR size: LONGCARD;
                         name: ARRAY OF CHAR): BOOLEAN;
  
  (* Sucht Datei <name> auf DefaultPath,
     reserviert Speicher und liest Datei ein.
     <a>    := Anfangsadresse der Datei im Speicher;
     <size> := L�nge  -"- .
     Ergebnis := 'Datei gefunden, genug Platz zum Einlesen gehabt'
  *)
  
  VAR         f: File;
             ok: BOOLEAN;
           path: PathList;
           read: LONGCARD;
       realname: ARRAY [0..127] OF CHAR;
       
  BEGIN
    path := StdPaths();
    SearchFile (name, path, fromStart, ok, realname);
    IF NOT ok THEN RETURN FALSE END;
    Open (f, realname, readOnly);
    size := FileSize (f);
    ALLOCATE (a, size);
    IF a = NIL THEN RETURN FALSE END;
    ReadBytes (f, a, size, read);
    IF size # read THEN RETURN FALSE END;
    Close (f);
    RETURN TRUE
  END ReadCompiler;


PROCEDURE Search (        a: ADDRESS; len: LONGCARD; targ1, targ2: CARDINAL;
                  VAR count: CARDINAL;
                    VAR pos: PosList);
  BEGIN
    ASSEMBLER
      MOVE.L   pos(A6),A1
      CLR.W    D3
      MOVE.L   a(A6),A0
      MOVE.L   len(A6),D1
      MOVE.W   targ1(A6),D0
      MOVE.W   targ2(A6),D4
   
   lp CMP.W    (A0)+,D0         ;Suchschleife
      BNE      nix
      CMP.W    (A0),D4
      BNE      nix
      MOVE.L   A0,D2
      SUB.L    a(A6),D2
      MOVE.L   D2,(A1)+
      ADDQ.L   #1,D3
  nix SUBQ.L   #2,D1
      BHI      lp
      
      MOVE.L   count(A6),A0
      MOVE.W   D3,(A0)          ;setze Count
    END
  END Search;


PROCEDURE encode (start, len, feedback, iter: CARDINAL): CARDINAL; (*$L-*)
    
  (* Schieberegister rechtsrum, Bits 0..<len>,
     R�ckkopplung aus Bit <feedback>, auf <start>-Wert loslassen.
     <iter> Iterationen durchf�hren; Ergebnis auf Cardinal k�rzen
  *)
  
  BEGIN
    ASSEMBLER
      MOVE.W  -(A3),D2        ;Iterationen
      MOVE.W  -(A3),D0        ;r�ckgef�hrtes Bit
      MOVE.W  -(A3),D4        ;Registerl�nge -1
      CLR.L   D1
      MOVE.W  -(A3),D1        ;Startwert
      BRA     l1
   l2 BTST    D0,D1           ;Bit0 := Bit0 EOR Bit(D0)
      BEQ     nochg           ; "
      BCHG    #0,D1           ; "
nochg LSR.L   #1,D1           ;einmal rechts schieben
      BCC     l1              ;und Bit0 in Bit(D4) rotieren
      BSET    D4,D1
   l1 DBF     D2,l2
      MOVE.W  D1,(A3)+        ;Ergebnis zur�ck
    END
  END encode;         (*$L+*)
  
  
PROCEDURE CalcSer (mySer: CARDINAL);
  
  (* �bergabe der Seriennummer in <mySer>.
     Setzt ARRAY <value> auf verschl�sselte Seriennummern.
     Verwendet Beschreibung der Schl�sselverfahren in
     <RegLen>, <FeedBack>, <Iterate>.           *)
  
  VAR  k: CARDINAL;
  
  BEGIN
    value [0] := mySer;
    WriteString ('   Schl�ssel'); WriteHex (value [0], 7);
    FOR k := 1 TO NrKeys DO
      value [k] := encode (mySer, RegLen[k], FeedBack[k], Iterate[k]);
      WriteHex (value[k], 7);
    END;
    WriteLn;
  END CalcSer;
  
  
PROCEDURE Check (mySer: CARDINAL);
  
  (*  Liest Datei <compname> nach Suche auf DefaultPath.
      Durchsucht nach Auftreten von <lead>, <value> und pr�ft
      jeweils, ob <expcount> Vorkommen gefunden.
      Bricht im Fehlerfall mit Meldung ab.
  *)
      
  VAR   a: ADDRESS;
        l: LONGCARD;
 count, k: CARDINAL;
   errmsg: ARRAY [0..127] OF CHAR;
    dummy: BOOLEAN;
  
  BEGIN
    CalcSer (mySer);
    IF ReadCompiler (a, l, compname) THEN
      FOR k := 0 TO NrKeys DO
        Search (a, l, lead [k], value [k], count, offsets [k]);
        IF count # expCount [k] THEN
          Concat ('Falsche Anzahl Eintr�ge: Schl�ssel ',
                   CardToStr (count, 0), errmsg, dummy);
          err (errmsg, FALSE)
        END;
      END
    ELSE
      err ('Compiler kann nicht gelesen werden!', FALSE);
    END;
  END Check;
  
  
VAR   mySer: CARDINAL;
          c: CHAR;

BEGIN
  
  (* Konstanten f�r Schl�ssel *)
  
  RegLen [1] := 17; FeedBack [1] := 7; Iterate [1] :=  39;
  RegLen [2] := 16; FeedBack [2] := 3; Iterate [2] := 367;
   
  (* Default-Seriennummern im Compiler *)
  
  expCount [0] := 3;  lead [0] := $0641;
  expCount [1] := 1;  lead [1] := $343C;
  expCount [2] := 1;  lead [2] := $0240;
  
  (* Seriennummern im Compiler suchen *)
  
  WriteString ('CheckSerial /1.0/:  Seriennummern in Compiler pr�fen ');
  WriteLn; WriteLn;
  
  
  (* neue Seriennummern eintragen *)
  
  LOOP
    WriteString ('Suchen der Seriennummern:'); WriteLn;
    WriteString ('   '); WriteString (compname);
    WriteString (' auf DefaultPath ?'); WriteLn;
    WriteString ('   Nummer eingeben (0 stoppt): ');
    ReadCard (mySer);
    IF mySer = 0 THEN EXIT END;
    
    Check (mySer);
    WriteString ('   fertig.'); WriteLn; WriteLn;
  
  END;
  
END CheckSerial. 
(* $FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$0000197F$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFF7D556$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A$FFFC363A�$00000362T.......T.......T.......T.......T.....T.T.......T.......T.......T.......T.......$00000156$00001978$FFF69E50$00001986$000019B1$FFF69E50$000019A3$00000362$FFF67E33$FFF67E33$FFF67E33$FFF67E33$FFF67E33$FFF67E33$0000160F$00001451���*)
