DEFINITION MODULE PrgLoader;

(*
 * Mini-Version des "Loader"-Moduls von Megamax Modula-2.
 *
 * Dieses Modul kann nur Programme im GEMDOS-Format resident laden
 * und starten, jedoch keine einzelnen Module.
 *
 * Das Modul wurde am 20.12.90 erstellt von
 *   Thomas Tempelmann, Nordendstr. 64, D-8000 M�nchen 40.
 * Es wurde mit Megamax Modula-2 (Version 2.2) entwickelt.
 *)

FROM SYSTEM IMPORT ADDRESS, BYTE;

TYPE LoaderResults = (noError,       (* kein Fehler - Prg. geladen *)
                      alreadyLoaded, (* Programm ist bereits geladen *)
                      notFound,      (* Programmdatei nicht vorhanden *)
                      outOfMemory,   (* Speicher reicht nicht *)
                      badFile);      (* keine oder defekte Programmdatei *)

     ArgStr = ARRAY [0..127] OF BYTE; (* fertige Arg-Zeile im GEMDOS-Format *)


VAR  UsedHeapSize: LONGCARD;          (* = MAX(LONGCARD), wenn kein Mshrink *)


PROCEDURE LoadProgram (    name    : ARRAY OF CHAR;
                           heapSize: LONGCARD;
                       VAR result  : LoaderResults);
(*
 * L�dt ein Programm mit der angegeben Heap-Gr��e.
 * Ergebnis in 'result'.
 *)

PROCEDURE UnLoadProgram (    name    : ARRAY OF CHAR;
                         VAR result  : LoaderResults);
(*
 * Gibt geladenes Programm frei.
 * Ergebnis in 'result'.
 *)

PROCEDURE Arg (REF text: ARRAY OF CHAR): ArgStr;
(*
 * Erzeugt aus einer Argumentzeile (max. 125 Zeichen lang!) den f�r
 * 'CallProgram' ben�tigten Argumentstring im GEMDOS-Format.
 *)

CONST NoArg = ArgStr {BYTE(0) BY 128};
      NoEnv = ADDRESS (0);

PROCEDURE CallProgram (    name       : ARRAY OF CHAR;
                       REF argLine    : ArgStr;
                           environment: ADDRESS;
                       VAR exitCode   : LONGINT);
(*
 * Startet Programm, auch wenn es nicht geladen ist.
 * 'argLine' erh�lt die Command Line im GEMDOS-Format. Mit der obigens
 * Funktion "Arg" kann ein normaler Modula-String in dieses Format
 * konvertiert werden. Soll kein Argument �bergeben werden, kann "NoArg"
 * verwendet werden.
 * 'environment': Wenn Sie nicht wissen, wozu das gut ist, brauchen Sie's
 * auch nicht. �bergeben Sie dann einfach "NoEnv".
 * Ergebnis kommt in 'exitCode', wie bei Pexec().
 *)

PROCEDURE ProgramLoaded (filename: ARRAY OF CHAR): BOOLEAN;
(*
 * Liefert TRUE, wenn Programm geladen ist
 *)


TYPE QueryPrgProc = PROCEDURE (REF (*name       :*) ARRAY OF CHAR,
                                   (*noOfRuns   :*) CARDINAL,
                                   (*currentHeap:*) LONGCARD,
                                   (*neededHeap :*) LONGCARD ): BOOLEAN;

(*$H+*)
PROCEDURE QueryLoaded (call: QueryPrgProc);
(*
 * Ruft die in 'call' �bergebene Prozedur f�r alle derzeit geladenen
 * Programm jeweils einmal auf.
 * Parameter zu 'call':
 *   'name': Name des Programms.
 *   'noOfRuns': Anzahl, wie oft das geladene Programm schon gestartet wurde.
 *   'currentHeap': Ist das Programm noch nicht gestartet worden, ist
 *      hier die im Parameter 'heapSize' von 'LoadProgram' angegebene
 *      Heap-Gr��e enthalten, sonst die durch den Mshrink-Aufruf selbst
 *      eingestellte Gr��e.
 *   'neededHeap': Ist MAX (LONGCARD), bis das Programm gestartet wurde
 *      und mind. einmal 'Mshrink' aufgerufen hat.
 * 'call' kann FALSE zur�ckgeben, um die Aufrufe zu evtl. weiteren geladenen
 *   Programmen abzubrechen.
 *)

END PrgLoader.
