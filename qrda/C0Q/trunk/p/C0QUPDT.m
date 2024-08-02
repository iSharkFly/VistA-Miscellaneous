C0QUPDT	; GPL - Quality Reporting List Update Routines ; 10/17/12 12:09pm
	;;1.0;QUALITY MEASURES;**1,5**;May 21, 2012;Build 32
	;Copyright 2009 George Lilly.  Licensed under the terms of the GNU
	;General Public License See attached copy of the License.
	;
	;This program is free software; you can redistribute it and/or modify
	;it under the terms of the GNU General Public License as published by
	;the Free Software Foundation; either version 2 of the License, or
	;(at your option) any later version.
	;
	;This program is distributed in the hope that it will be useful,
	;but WITHOUT ANY WARRANTY; without even the implied warranty of
	;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	;GNU General Public License for more details.
	;
	;You should have received a copy of the GNU General Public License along
	;with this program; if not, write to the Free Software Foundation, Inc.,
	;51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
	;
	Q
	;
C0QQFN()	Q 1130580001.101 ; FILE NUMBER FOR C0Q QUALITY MEASURE FILE
C0QMFN()	Q 1130580001.201 ; FILE NUMBER FOR C0Q MEASUREMENT FILE
C0QMMFN()	Q 1130580001.2011 ; FN FOR MEASURE SUBFILE
C0QMMNFN()	Q 1130580001.20111 ; FN FOR NUMERATOR SUBFILE
C0QMMDFN()	Q 1130580001.20112 ; FN FOR DENOMINATOR SUBFILE
RLSTFN()	Q 810.5 ; FN FOR REMINDER PATIENT LIST FILE
RLSTPFN()	Q 810.53 ; FN FOR REMINDER PATIENT LIST PATIENT SUBFILE
C0QPLF()	Q 1130580001.301 ; C0Q PATIENT LIST FILE
C0QALFN()	Q 1130580001.311 ; FILE NUMBER FOR C0Q PATIENT LIST PATIENT SUBFILE ;
	;
UPDATE(RNT,MSET)	; UPDATE A MEASURE SET BY ADDING NEW ENTRIES TO PATIENT
	; LISTS AND DELETING ENTRIES THAT ARE NO LONGER VALID. ALSO UPDATE
	; NUMERATOR AND DENOMINATOR COUNTS
	; MAKES HEAVY USE OF UNITY^C0QSET TO DETERMINE WHAT TO ADD AND DELETE
	;
	; THIS IS A REPLACEMENT FOR C0QRPC^C0QMAIN WHICH DELETES THE PATIENT
	; LISTS AND RECREATES THEM, WHICH IS A LOT OF UNNECESSARY PROCESSING
	;
	N ZI S ZI=""
	N C0QM ; FOR HOLDING THE MEASURES IN THE SET
	I $$GET1^DIQ($$C0QMFN,MSET_",",.05,"I")="Y" D  Q  ; IS IT LOCKED?
	. W !,"ERROR MEASURE SET IS LOCKED, EXITING"
	D LIST^DIC($$C0QMMFN,","_MSET_",",".01I;1.2I;2.2I") ; GET ALL THE MEASURES
	D DELIST("C0QM")
	N ZII S ZII=""
	F  S ZII=$O(C0QM(ZII)) Q:ZII=""  D  ; FOR EACH MEASURE
	. ; 
	. ; Special processing for eRx measure.
	. I $$GET1^DIQ(1130580001.101,+C0QM(ZII)_",",4,"I")="E" D ERXCOUNT(MSET,ZII) Q
	. ;
	. ; Otherwise, we go on
	. N C0QNL,C0QDL,C0QFLTN,C0QFLTD,C0QNALT ; VEN/SMH - line changed in *5 
	. S C0QFLTN=$P(C0QM(ZII),U,3) ;IEN OF NUMERATOR FILTER LIST
	. S C0QFLTD=$P(C0QM(ZII),U,4) ; IEN OF DENOMINATOR FILTER LIST
	. S ZI=$P(C0QM(ZII),U,1) ; IEN OF THE MEASURE IN THE C0Q QUALITY MEAS FILE
	. ;
	. ; Numerator
	. S C0QNL=$$GET1^DIQ($$C0QQFN,ZI_",",1,"I") ; NUMERATOR POINTER
	. I C0QNL="" D  ; CHECK ALTERNATE LIST
	. . S C0QNL=$$GET1^DIQ($$C0QQFN,ZI_",",1.1,"I") ; NUMERATOR POINTER
	. . I C0QNL'="" S C0QNALT=1
	. I C0QNL="" QUIT  ; No Numerator. Can't perform calculation.--smh
	. ;
	. ; Denominator
	. S C0QDL=$$GET1^DIQ($$C0QQFN,ZI_",",2,"I") ; DENOMINATOR POINTER
	. I C0QDL="" D  ; CHECK ALTERNATE LIST
	. . S C0QDL=$$GET1^DIQ($$C0QQFN,ZI_",",2.1,"I") ; DENOMINATOR POINTER
	. . I C0QDL'="" S C0QDALT=1
	. I C0QDL="" QUIT  ; No Denominator. Can't perform calcuation.--smh
	. ;
	. ; FIRST PROCESS THE NUMERATOR
	. ;
	. N C0QNEW ; REFERENCE TO NEW NUMBERATOR LIST B INDEX
	. I $G(C0QNALT)=1 D  ; USING ALTERNATE LIST FOR NUMERATOR
	. . S C0QNEW=$NA(^C0Q(301,C0QNL,1,"B")) ; B INDEX FOR THIS LIST
	. E  D  ; USE THE REMINDER PACKAGE PATIENT LISTS
	. . S C0QNEW=$NA(^PXRMXP(810.5,C0QNL,30,"B")) ; REMINDER LIST PATIENTS
	. I C0QFLTN'="" D  ; USE A NUMERATOR FILTER LIST
	. . N ZNEW
	. . S ZNEW=$NA(^C0Q(301,C0QFLTN,1,"B")) ; B INDEX OF FILTER LIST
	. . K C0QFLTRD
	. . D AND^C0QSET("C0QFLTRD",ZNEW,C0QNEW)
	. . S C0QNEW="C0QFLTRD"
	. N C0QOLD ; REFERENCE FOR OLD PATIENT LIST
	. S C0QOLD=$NA(^C0Q(201,MSET,5,ZII,1,"B")) ; NUMERATOR LIST IN MEASURE SET
	. N C0QRSLT ; ARRAY FOR THE UNITY DIFFERENCES
	. D UNITY^C0QSET("C0QRSLT",C0QNEW,C0QOLD) ; FIND THE DIFFERENCES
	. N C0QCNT
	. S C0QNCNT=$G(C0QRSLT("COUNT"))
	. I C0QNCNT="" D  ;
	. . S C0QNCNT=0 ; DEFAULT COUNT IS ZERO
	. . N GZZ S GZZ=""
	. . F  S GZZ=$O(C0QRSLT(0,GZZ)) Q:GZZ=""  D  ; EVERY ADD ENTRY
	. . . S C0QNCNT=C0QNCNT+1
	. . F  S GZZ=$O(C0QRSLT(1,GZZ)) Q:GZZ=""  D  ; EVERY EQUAL ENTRY
	. . . S C0QNCNT=C0QNCNT+1
	. K C0QFDA ; CLEAR THE FDA
	. N C0QONCNT ; OLD COUNT
	. S C0QONCNT=$$GET1^DIQ($$C0QMMFN(),ZII_","_MSET_",",1.1)
	. I C0QNCNT'=C0QONCNT D  ; COUNT HAS CHANGED
	. . S C0QFDA($$C0QMMFN(),ZII_","_MSET_",",1.1)=C0QNCNT ; NUMERATOR COUNT
	. . D UPDIE ; UPDATE THE NUMERATOR COUNT
	. I $D(C0QRSLT) D  ;B  ;
	. . ;ZWR C0QRSLT
	. ; FIRST PROCESS DELETIONS
	. K C0QFDA ; CLEAR OUT THE FDA
	. N ZG,ZIEN S ZG=""
	. F  S ZG=$O(C0QRSLT(2,ZG)) Q:ZG=""  D  ; FOR EACH DELETION
	. . S ZIEN=$O(@C0QOLD@(ZG,"")) ; IEN OF THE ENTRY
	. . I ZIEN="" D  Q  ; OOPS
	. . . W !,"ERROR DELETING ENTRY!! ",ZG
	. . S C0QFDA($$C0QMMNFN(),ZIEN_","_ZII_","_MSET_",",.01)="@" ; DELETE
	. I $D(C0QFDA) D UPDIE ; PROCESS
	. ; SECOND, PROCESS ADDITIONS
	. K C0QFDA ; CLEAR OUT THE FDA
	. N ZG,ZC S ZG="" S ZC=1
	. F  S ZG=$O(C0QRSLT(0,ZG)) Q:ZG=""  D  ; FOR EACH ADDITION
	. . S C0QFDA($$C0QMMNFN(),"+"_ZC_","_ZII_","_MSET_",",.01)=ZG ; ADD THE ENTRY
	. . S ZC=ZC+1
	. I $D(C0QFDA) D UPDIE ; PROCESS
	. ;
	. ; PROCESS THE DENOMINATOR
	. ;
	. N C0QNEW ; REFERENCE TO NEW NUMBERATOR LIST B INDEX
	. I $G(C0QNALT)=1 D  ; USING ALTERNATE LIST FOR NUMERATOR
	. . S C0QNEW=$NA(^C0Q(301,C0QDL,1,"B")) ; B INDEX FOR THIS LIST
	. E  D  ; USE THE REMINDER PACKAGE PATIENT LISTS
	. . S C0QNEW=$NA(^PXRMXP(810.5,C0QDL,30,"B")) ; REMINDER LIST PATIENTS
	. I C0QFLTD'="" D  ; USE A DENOMINATOR FILTER LIST
	. . N ZNEW
	. . S ZNEW=$NA(^C0Q(301,C0QFLTD,1,"B")) ; B INDEX OF FILTER LIST
	. . K C0QFLTRD
	. . D AND^C0QSET("C0QFLTRD",ZNEW,C0QNEW)
	. . S C0QNEW="C0QFLTRD"
	. N C0QOLD ; REFERENCE FOR OLD PATIENT LIST
	. S C0QOLD=$NA(^C0Q(201,MSET,5,ZII,3,"B")) ; DENOMINATOR LIST IN MEASURE SET
	. N C0QRSLT ; ARRAY FOR THE UNITY DIFFERENCES
	. D UNITY^C0QSET("C0QRSLT",C0QNEW,C0QOLD) ; FIND THE DIFFERENCES
	. N C0QDCNT
	. S C0QDCNT=$G(C0QRSLT("COUNT"))
	. I C0QDCNT="" D  ;
	. . S C0QDCNT=0 ; DEFAULT COUNT IS ZERO
	. . N GZZ S GZZ=""
	. . F  S GZZ=$O(C0QRSLT(0,GZZ)) Q:GZZ=""  D  ; EVERY ADD ENTRY
	. . . S C0QDCNT=C0QDCNT+1
	. . F  S GZZ=$O(C0QRSLT(1,GZZ)) Q:GZZ=""  D  ; EVERY EQUAL ENTRY
	. . . S C0QDCNT=C0QDCNT+1
	. K C0QFDA ; CLEAR THE FDA
	. N C0QODCNT ; OLD COUNT
	. S C0QODCNT=$$GET1^DIQ($$C0QMMFN(),ZII_","_MSET_",",2.1)
	. I C0QDCNT'=C0QODCNT D  ; COUNT HAS CHANGED
	. . S C0QFDA($$C0QMMFN(),ZII_","_MSET_",",2.1)=C0QDCNT ; DENOMINATOR COUNT
	. . D UPDIE ; UPDATE THE DENOMINATOR COUNT
	. I $D(C0QRSLT) D  ;B  ;
	. . ;ZWR C0QRSLT
	. I '$D(C0QRSLT) Q  ; NO RESULTS TO USE
	. ; FIRST PROCESS DELETIONS
	. K C0QFDA ; CLEAR OUT THE FDA
	. N ZG,ZIEN S ZG=""
	. F  S ZG=$O(C0QRSLT(2,ZG)) Q:ZG=""  D  ; FOR EACH DELETION
	. . S ZIEN=$O(@C0QOLD@(ZG,"")) ; IEN OF THE ENTRY
	. . I ZIEN="" D  Q  ; OOPS
	. . . W !,"ERROR DELETING ENTRY!! ",ZG
	. . S C0QFDA($$C0QMMDFN(),ZIEN_","_ZII_","_MSET_",",.01)="@" ; DELETE
	. I $D(C0QFDA) D UPDIE ; PROCESS
	. ; SECOND, PROCESS ADDITIONS
	. K C0QFDA ; CLEAR OUT THE FDA
	. N ZG,ZC S ZG="" S ZC=1
	. F  S ZG=$O(C0QRSLT(0,ZG)) Q:ZG=""  D  ; FOR EACH ADDITION
	. . S C0QFDA($$C0QMMDFN(),"+"_ZC_","_ZII_","_MSET_",",.01)=ZG ; ADD THE ENTRY
	. . S ZC=ZC+1
	. I $D(C0QFDA) D UPDIE ; PROCESS
	. ;
	. ; File Percentage
	. N C0QPCT ; PERCENT
	. D  ;
	. . I C0QDCNT>0 D  ;
	. . . S C0QPCT=$J(100*C0QNCNT/C0QDCNT,0,0)
	. . E  S C0QPCT=0
	. . K C0QFDA
	. . S C0QFDA($$C0QMMFN(),ZII_","_MSET_",",3)=C0QPCT ; PERCENT
	. . D UPDIE
	Q
	; 
DELIST(RTN)	; DECODES ^TMP("DILIST",$J) INTO
	; @RTN@(IEN)=INTERNAL VALUE^EXTERNAL VALUE
	; ADDED A B INDEX @RTN@("B",INTERNAL VALUE,IEN)=EXTERNAL VALUE
	N ZI,IV,EV,ZDI,ZIEN,FLTN,FLTD
	S ZI=""
	S ZDI=$NA(^TMP("DILIST",$J))
	K @RTN
	F  S ZI=$O(@ZDI@(1,ZI)) Q:ZI=""  D  ;
	. S EV=@ZDI@(1,ZI) ;EXTERNAL VALUE
	. S IV=$G(@ZDI@("ID",ZI,.01)) ; INTERNAL VALUE
	. S FLTN=$G(@ZDI@("ID",ZI,1.2)) ; NUMERATOR FILTER LIST
	. S FLTD=$G(@ZDI@("ID",ZI,2.2)) ; DENOMINATOR FILTER LIST
	. S ZIEN=@ZDI@(2,ZI) ; IEN
	. S @RTN@(ZIEN)=IV_"^"_EV_"^"_FLTN_"^"_FLTD
	. ;S @RTN@("B",IV,ZIEN)=EV
	Q
	;
UPDIE	; INTERNAL ROUTINE TO CALL UPDATE^DIE AND CHECK FOR ERRORS
	K ZERR
	D CLEAN^DILF
	D ZWRITE^C0QUTIL("C0QFDA")
	D UPDATE^DIE("","C0QFDA","","ZERR")
	I $D(ZERR) S ZZERR=ZZERR ; ZZERR DOESN'T EXIST, INVOKE THE ERROR TRAP IF TASKED
	;. W "ERROR",!
	;. ZWR ZERR
	;. B
	K C0QFDA
	Q
	;
ERXCOUNT(MSETIEN,MIEN)	; Private Proc; Get eRx and file as Numerator, Denominator, and %
	; Inputs:
	; MSETIEN - Measurement Set IEN - By Value
	; MIEN - Measurement IEN inside the Measurement Set - By Value
	; 
	; Optional Symtab input: C0QDEBUG to print out debug messages to STDOUT.
	; ZEXCEPT: C0QDEBUG ; For Dr. Ivey's parser.
	;
	; No check is done to see if the caller is sending bad data. Measurement must be
	; in a subfile under Measurement Set.
	;
	W:$G(C0QDEBUG) "Processing E-Prescribing Counts",!
	; Example of Data we go through in the C0Q Parameter File, so the code below
	; will make sense.
	; ^C0Q(401,"AMMS",2,1)=""
	; ^C0Q(401,"AMMS",2,2)=""
	; ^C0Q(401,"AQMS",6,2)=""
	; ^C0Q(401,"B","INPATIENT",2)=""
	; ^C0Q(401,"B","OUTPATIENT",1)=""
	; ^C0Q(401,"MU","MU12",1)=""
	; ^C0Q(401,"MU","MU12",2)=""
	; ^C0Q(401,"MUTYP","MU12","EP",1)=""
	; ^C0Q(401,"MUTYP","MU12","INP",2)=""
	;
	; Get Parameter year from the Parameters file.
	; 1. Get parameter associated with this measurement set from AMMS x-ref (new in C0Q*1*1).
	N C0QPARAM
	N % S %="" F  S %=$O(^C0Q(401,"AMMS",MSETIEN,%)) Q:%=""  S C0QPARAM(%)=""
	;
	; 2. Find the year for each of those--store as value of node; IEN still subscript.
	N % S %="" F  S %=$O(C0QPARAM(%)) Q:%=""  S C0QPARAM(%)=$$GET1^DIQ(1130580001.401,%_",",.02)
	;
	; 3. Now make sure that this parameter that point to an Outpatient Parameters
	; WARNING: CONFUSING CODE WRITTEN BY ME AHEAD
	; The % loop will stop with a valid value if found; % is used in the lines immediately below
	N % S %="" F  S %=$O(C0QPARAM(%)) Q:%=""  Q:$D(^C0Q(401,"MUTYP",C0QPARAM(%),"EP",%))
	;
	; 4. If % has a valid IEN (there can be multiple, we take the first), then off we go.
	; Otherwise, if it is back to "", we quit.
	N MUYEAR
	IF '% W "No suitable parameter found. Cannot determine Measurement Year.",! QUIT
	ELSE  S MUYEAR=C0QPARAM(%)
	; 
	; Now, based on the MU year, construct the patient list name that has the eRx data.
	N LISTNAME S LISTNAME=MUYEAR_"-"_"EP"_"-"_"HasERX"
	;
	; Call the API in C0QMUERX to get the counts already calculated
	; Data is returned NUM/DEN
	N COUNTS S COUNTS=$$COUNT^C0QMUERX($$PATLN^C0QMU12(LISTNAME))
	;
	; File the count
	N NUM S NUM=$P(COUNTS,"/") ; Numerator
	N DEN S DEN=$P(COUNTS,"/",2) ; Denominator
	;
	; Prepare FDA
	N C0QFDA,C0QERR
	S C0QFDA($$C0QMMFN(),MIEN_","_MSETIEN_",",1.1)=NUM ; Numerator
	S C0QFDA($$C0QMMFN(),MIEN_","_MSETIEN_",",2.1)=DEN ; Denominator
	S C0QFDA($$C0QMMFN(),MIEN_","_MSETIEN_",",3)=$S(DEN=0:0,1:$J(100*NUM/DEN,0,0)) ; Percentage; avoid dividing by zero!
	;
	; File FDA using Filer not updater (editing existing entry only)
	D FILE^DIE("ET",$NAME(C0QFDA),$NAME(C0QERR)) ; Flags: External, Transaction
	;
	; If error, print it out
	I $D(C0QERR) DO
	. W "Error filing data",!
	. N % S %=$NAME(C0QERR) F  S %=$Q(@%) Q:%=""  W %_": "_@%,!
	;
	QUIT
