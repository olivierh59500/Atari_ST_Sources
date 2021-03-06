
DEFINITION MODULE LibFiles;

(*$H+    erlaubt lokale Prozeduren bei 'LibQuery' *)

(*
 * Verwaltet die Speicherung von vielen Dateien in einer gro�en Datei.
 *
 * Beispielsweise werden die Symbol-Dateien (.DEF) des Compilers in
 * solch einer gro�en Datei gespeichert, weil dies Speicherplatz
 * spart und der Zugriff darauf schneller ist als wenn die Dateien
 * alle einzeln vom GEMDOS in einem Unterverzeichnis verwaltet w�rden.
 *
 * Der Nachteil dieses Verfahrens: Das Einf�gen neuer Dateien ist
 * aufwendiger. Deshalb sollte man nur solche Dateien in einer dieser
 * Library-Dateien zusammenfassen, die haupts�chlich gelesen werden
 * (so wie die mitgelieferten DEF-Dateien des Modula-Systems).
 *
 * Das Modul 'LibManager' zeigt eine beispielshafte Anwendung dieses Moduls.
 *)

FROM Files IMPORT File;
FROM Directory IMPORT FileAttrSet;
FROM SYSTEM IMPORT ADDRESS, BYTE;


TYPE    LibFile = RECORD
                    f: File;
                    private: ADDRESS
                  END;

        LibEntry = RECORD
                     name: ARRAY [0..11] OF CHAR;
                     attr: FileAttrSet;
                     time: CARDINAL; (* gepacktes Format ! *)
                     date: CARDINAL; (* gepacktes Format ! *)
                     size: LONGCARD;
                     start: LONGCARD
                   END;

        UserData = ARRAY [0..39] OF BYTE;

        LibQueryProc = PROCEDURE ( (* entry: *) LibEntry ): BOOLEAN;


PROCEDURE OpenLib ( VAR handle: LibFile; REF libraryName: ARRAY OF CHAR;
                    VAR reply: INTEGER );
  (*
   * �ffnet eine vorhandene Library-Datei mit dem Namen 'libraryName'
   * und liefert in 'handle' eine Zugriffskennung darauf.
   *
   * 'reply' liefert ggf. einen Fehlercode (negativ). Ist die Datei
   * keine Library-Datei, wird in 'reply' "fBadOp" geliefert.
   *
   * Am Ende sollte die Libary mit 'CloseLib' wieder geschlossen werden.
   *)

PROCEDURE LookUp ( VAR handle: LibFile; REF fileName: ARRAY OF CHAR;
                   VAR info: LibEntry; VAR reply: INTEGER );
  (*
   * Sucht die Datei namens 'fileName' innerhalb der Libary mit der
   * Zugriffskennung 'handle'. 'reply' liefert ggf. einen Fehlercode (negativ).
   *
   * Die gesuchte Datei mu� dann mit den Funktionen aus dem Binary-Modul
   * gelesen werden. Dazu findet sich in 'info.start' die Anfangsposition
   * in der Library-Datei, in 'info.size' deren L�nge. Mittels 'handle.f'
   * wird auf die Libary-Datei zugegriffen.
   * Siehe dazu das Modul 'LibManager' im UTILITY-Ordner.
   *)

PROCEDURE LibQuery ( VAR handle: LibFile; proc: LibQueryProc;
                     VAR reply: INTEGER );
  (*
   * Geht alle Dateien in der Library durch und ruft jedesmal 'proc' auf.
   *)

PROCEDURE CloseLib ( VAR handle: LibFile );
  (*
   * Schlie�t eine mit 'OpenLib' ge�ffnete Libary.
   *)

PROCEDURE CreateLib ( REF libraryName: ARRAY OF CHAR; VAR reply: INTEGER );
  (*
   * Erzeugt eine neue, leere Library-Datei.
   * 'reply' liefert ggf. einen Fehlercode (negativ).
   *)

PROCEDURE SetUserData ( REF libraryName: ARRAY OF CHAR;
                        REF data: ARRAY OF BYTE; VAR reply: INTEGER );
  (*
   * Jede Library-Datei hat ein Feld reserviert, in dem das Anwenderprogramm
   * beliebige Daten ablegen kann. Das Feld ist intern als 'UserData' (s.o.)
   * definiert, fa�t also maximal 'SIZE(UserData)' Bytes. Das Anwenderprogramm
   * kann mit dieser Prozedur das Feld der Libary-Datei 'libraryName' mit
   * den Daten 'data' beschreiben. Dabei darf das �bergebene Datum die Gr��e
   * von 'UserData' unter- aber nicht �berschreiten, andernfalls wird der
   * Laufzeitfehler 'MOSGlobals.StringOverflow' gemeldet.
   * 'reply' liefert einen neg. Wert, wenn die Library-Datei nicht ansprechbar
   * ist.
   * Die Library-Datei mu� bei Aufruf dieser Prozedur geschlossen sein!
   *)

PROCEDURE GetUserData ( REF libraryName: ARRAY OF CHAR;
                        VAR data: ARRAY OF BYTE; VAR reply: INTEGER );
  (*
   * Hiermit k�nnen die von 'SetUserData' eingetragenen Daten wieder
   * ermittelt werden. Die f�r 'user' �bergebene Variable mu� ausreichend
   * gro� f�r die Daten sein - es werden nur so viele Bytes ausgelesen,
   * wie die Variable fassen kann (einen Laufzeitfehler gibt's nicht).
   * 'reply' liefert einen neg. Wert, wenn die Library-Datei nicht ansprechbar
   * ist.
   * Die Library-Datei mu� bei Aufruf dieser Prozedur geschlossen sein!
   *)

PROCEDURE RemoveFile ( REF libraryName, fileName: ARRAY OF CHAR;
                       VAR damaged: BOOLEAN; VAR reply: INTEGER );
  (*
   * Enfernt die Datei 'fileName' aus dem Verzeichnis der Library namens
   * 'libraryName'. Dabei kann die L�nge der Library-Datei leider nicht
   * verringert werden - der belegte Platz in der Library bleibt unbenutzt.
   * Mit der Funktion 'CopyLib' kann die Library-Datei aber aufger�umt werden.
   * Liefert 'damaged' TRUE, ist die Lib-Datei defekt und kann nicht mehr
   * benutzt werden. Deshalb sollte sie dann gel�scht werden.
   * Die Library-Datei mu� bei Aufruf dieser Prozedur geschlossen sein!
   *)

PROCEDURE CopyLib ( REF sourceLib, destLib: ARRAY OF CHAR; VAR reply: INTEGER );
  (*
   * Kopiert die Libary in eine neue Datei. Dabei wird die Zieldatei
   * auf die kleinstm�gliche L�nge verk�rzt. Diese Funktion bietet sich
   * an, wenn 'RemoveFile' verwendet wurde, um den unbenutzten Platz in
   * der Lib-Datei zu eliminieren.
   * 'destLib' darf vorher nicht existieren, sonst wird die neue Datei nicht
   * erzeugt.
   * Die Library-Datei mu� bei Aufruf dieser Prozedur geschlossen sein!
   *)

PROCEDURE AddFile ( REF libraryName: ARRAY OF CHAR; VAR entry: LibEntry;
                    VAR damaged: BOOLEAN; VAR reply: INTEGER );
  (*
   * F�gt die in 'entry' beschriebene Datei ins Verzeichnis der Library
   * namens 'libraryName' ein. Die einzuf�gende Datei darf noch nicht
   * existieren.
   * In 'entry' m�ssen beim Aufruf alle Daten bis auf 'entry.start' initiali-
   * siert sein. Nach dem Aufruf erh�lt man in 'entry.start' die Dateiposi-
   * tion, an die die Daten der Datei geschrieben werden m�ssen (z.B. mit den
   * Funktionen aus 'Binary'). Es ist darauf zu achten, da� nicht mehr
   * Bytes geschrieben werden, als in 'entry.size' angegeben wurde!
   * Liefert 'damaged' TRUE, ist die Lib-Datei defekt und kann nicht mehr
   * benutzt werden. Deshalb sollte sie dann gel�scht werden.
   * Die Library-Datei mu� bei Aufruf dieser Prozedur geschlossen sein!
   *)

END LibFiles.
