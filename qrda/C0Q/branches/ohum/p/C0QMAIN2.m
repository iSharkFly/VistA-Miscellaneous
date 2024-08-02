C0QMAIN ; GPL - Quality Reporting Main Processing ;10/13/10  17:05
 ;;0.1;C0Q;nopatch;noreleasedate;
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
C0QQFN() Q 1130580001.101 ; FILE NUMBER FOR C0Q QUALITY MEASURE FILE
C0QMFN() Q 1130580001.201 ; FILE NUMBER FOR C0Q MEASUREMENT FILE
C0QMMFN() Q 1130580001.2011 ; FN FOR MEASURE SUBFILE
C0QMMNFN() Q 1130580001.20111 ; FN FOR NUMERATOR SUBFILE
C0QMMDFN() Q 1130580001.20112 ; FN FOR DENOMINATOR SUBFILE
RLSTFN() Q 810.5 ; FN FOR REMINDER PATIENT LIST FILE
RLSTPFN() Q 810.53 ; FN FOR REMINDER PATIENT LIST PATIENT SUBFILE
 ;
NBYP ; ENTRY POINT FOR COMMAND LINE BY PATIENT MEASURE LISTING
 ;
 S DIC=$$C0QMFN,DIC(0)="AEMQ" D ^DIC
 I Y<1 Q  ; EXIT
 N MSIEN S MSIEN=+Y
 W !,"NUMERATOR PATIENT LIST",!
 N C0QPAT
 D PATS(.C0QPAT,MSIEN,"N") ; GET THE NUMERATOR PATIENT LIST
 I $D(C0QPAT) D  ; LIST RETURNED
 .
 . ;
 Q
 ;
DBYP ; ENTRY POINT FOR COMMAND LINE BY PATIENT MEASURE LISTING
 ;
 S DIC=$$C0QMFN,DIC(0)="AEMQ" D ^DIC
 I Y<1 Q  ; EXIT
 N MSIEN S MSIEN=+Y
 N C0QPAT
 W !,"DENOMINATOR PATIENT LIST",!
 D PATS(.C0QPAT,MSIEN,"D") ; GET THE NUMERATOR PATIENT LIST
 I $D(C0QPAT) D  ; LIST RETURNED
 . ;
 . ;
 Q
 ;
PATS(ZRTN,MSIEN,NORD,PAT,EFORM) ; BUILDS A LIST OF PATIENTS AND THEIR MEASURES
 ; FOR MEASURE SET MSIEN. NORD="N" (DEFAULT) MEANS NUMERATOR PATIENTS
 ; NORD="D" MEANS DENOMINATOR PATIENTS 
 ; PAT IS THE IEN OF A SINGLE PATIENT FOR PROCESSING. IF PAT IS OMMITED OR "*",
 ;  ALL PATIENTS IN THE MEASURE SET NUM/DENOM WILL BE PROCESSED
 ; EFORM=1 MEANS ZRTN IS IN "EXTERNAL FORMAT" - THIS IS FOR USE AS AN RPC
 ; EXTERNAL FORMAT IS AN ARRAY OF STRINGS 
 ;  ZRTN(x)=DFN^NAME^MEASURE IEN^MEASURE NAME 
 ;  ONE FOR EACH MEASURE FOR EACH PATIENT IN THE NUMERATOR/DENOMINATOR
 ; EFORM=0 (DEFAULT) MEANS "INTERNAL FORMAT" - THIS IS FOR MUMPS CALLS
 ;  ZRTN(DFN,MEASURE IEN)="" IT IS A PAIR OF POINTERS IN INDEX FORMAT
 ;  ONE FOR EACH MEASURE FOR EACH PATIENT IN THE NUMERATOR/DENOMINATOR
 ;
 N ZI,ZJ,ZK,ZIDX
 S ZI=""
 ; GOING TO USE THE NUMERATOR BY PATIENT INDEX
 I '$D(NORD) S NORD="N"
 I '((NORD="N")!(NORD="D")) S NORD="N"
 I NORD="N" S ZIDX=$NA(^C0Q(201,"ANBYP"))
 E  S ZIDX=$NA(^C0Q(201,"ADBYP"))
 F  S ZI=$O(@ZIDX@(ZI)) Q:ZI=""  D  ; FOR EACH PATIENT
 . I $O(@ZIDX@(ZI,MSIEN,""))'="" D  ; IF PATIENT IS IN THIS SET
 . . W !,$$GET1^DIQ(2,ZI_",",.01) ;PATIENT NAME
 . E  Q  ; NEXT PATIENT
 . S (ZJ,ZK)=""
 . F  S ZJ=$O(@ZIDX@(ZI,MSIEN,ZJ)) Q:ZJ=""  D  ; FOR EACH MEASURE
 . . ;S ZL=$O(@ZIDX@(ZI,MSIEN,ZJ,"")) ; MEASURE IS FOURTH
 . . S ZK=""
 . . S ZK=$$GET1^DIQ($$C0QMMFN,ZJ_","_MSIEN_",",.01,"I")
 . . ;W !,"ZK:",ZK," ZJ:",ZJ," ZI",ZI,!
 . . W " ",$$GET1^DIQ($$C0QQFN,ZK_",",.01) ; MEASURE NAME
 Q
 ;
EN ; ENTRY POINT FOR COMMAND LINE AND MENU ACCESS TO C0QRPC
 ;
 S DIC=$$C0QMFN,DIC(0)="AEMQ" D ^DIC
 I Y<1 Q  ; EXIT
 N MSIEN S MSIEN=+Y
 D C0QRPC(.G,MSIEN)
 Q
 ;
C0QRPC(RTN,MSET,FMT,NOPURGE) ; RPC FORMAT 
 ; MSET IS THE NAME OR IEN OF THE MEASURE SET
 ; RTN IS THE RETURN ARRAY OF THE RESULTS PASSED BY REFERENCE
 ; FMT IS THE FORMAT OF THE OUTPUT - "ARRAY" OR "HTML" OR "XML"
 ;  NOTE: ARRAY IS DEFAULT AND THE OTHERS ARE NOT IMPLEMENTED YET
 ; IF NOPURGE IS 1, PATIENT LISTS WILL NOT BE DELETED BEFORE ADDING
 ; IF NOPURGE IS 0 OR OMITTED, PATIENT LISTS WILL BE DELETED THEN ADDED
 W !,"LOOKING FOR MEASURE SET ",MSET,!
 N ZI S ZI=""
 N C0QM ; FOR HOLDING THE MEASURES IN THE SET
 D LIST^DIC($$C0QMMFN,","_MSET_",",".01I") ; GET ALL THE MEASURES
 D DELIST("C0QM")
 N ZII S ZII=""
 F  S ZII=$O(C0QM(ZII)) Q:ZII=""  D  ; FOR EACH MEASURE
 . S ZI=$P(C0QM(ZII),U,1) ; IEN OF THE MEASURE IN THE C0Q QUALITY MEAS FILE
 . ;W $$GET1^DIQ($$C0QQFN,ZI_",","DISPLAY NAME"),!
 . ;N C0QNL,C0QDL ;NUMERATOR AND DENOMINATOR LIST POINTERS
 . W "MEASURE: ",$$GET1^DIQ($$C0QQFN,ZI_",",.01),! ; PRINT THE MEASURE NAME
 . ; FOLLOW THE POINTERS TO THE C0Q QUALITY MEASURE FILE AND GET LIST PTRS
 . S C0QNL=$$GET1^DIQ($$C0QQFN,ZI_",",1,"I") ; NUMERATOR POINTER
 . S C0QDL=$$GET1^DIQ($$C0QQFN,ZI_",",2,"I") ; DENOMINATOR POINTER
 . ; NOW FOLLOW THE LIST POINTERS TO THE REMINDER PATIENT LIST FILE
 . W "NUMERATOR: ",$$GET1^DIQ($$RLSTFN,C0QNL_",","NAME"),!
 . ; FIRST PROCESS THE NUMERATOR
 . K ^TMP("DILIST",$J)
 . D LIST^DIC($$RLSTPFN,","_C0QNL_",",".01I") ; GET THE LIST OF PATIENTS
 . ;D DELIST("G") ;
 . ;I $D(G) ZWR G
 . K C0QNUMP
 . N ZJ S ZJ=""
 . F  S ZJ=$O(^TMP("DILIST",$J,"ID",ZJ)) Q:ZJ=""  D  ;
 . . S ZDFN=^TMP("DILIST",$J,"ID",ZJ,.01)
 . . S C0QNUMP("N",ZJ,ZDFN)=""
 . ZWR ^TMP("DILIST",$J,1,*) ; LIST THE PATIENT NAMES
 . D ADDPATS(MSET,ZII,"C0QNUMP")
 . ; NEXT PROCESS THE DENOMINATOR
 . W "DENOMINATOR: ",$$GET1^DIQ($$RLSTFN,C0QDL_",","NAME"),!
 . K ^TMP("DILIST",$J)
 . D LIST^DIC($$RLSTPFN,","_C0QDL_",",".01I") ; GET THE LIST OF PATIENTS
 . ;D DELIST("G")
 . ;I $D(G) ZWR G
 . ;S ZJ=""
 . K C0QDEMP
 . F  S ZJ=$O(^TMP("DILIST",$J,"ID",ZJ)) Q:ZJ=""  D  ;
 . . S ZDFN=^TMP("DILIST",$J,"ID",ZJ,.01)
 . . S C0QDEMP("D",ZJ,ZDFN)=""
 . D ADDPATS(MSET,ZII,"C0QDEMP")
 . ZWR ^TMP("DILIST",$J,1,*) ; LIST THE PATIENT NAMES
 Q
 ;
ADDPATS(MSET,MEAS,PATS) ;ADD PATIENTS TO NUMERATOR AND DENOMINATOR
 ; OF MEASURE SET IEN MSET MEASURE IEN MEAS
 ; PATS IS OF THE FORM @PATS@("N",X,DFN)="" AND @PATS@("D",X,DFN)=""
 ; WHERE N IS FOR NUMERATOR AND D IS FOR DENOMINATOR AND X 1..N
 ; IF PATIENTS ARE ALREADY THERE, THEY WILL NOT BE ADDED AGAIN
 N C0QI,C0QJ
 N C0QFDA
 S C0QI=""
 F  S C0QI=$O(@PATS@("N",C0QI)) Q:C0QI=""  D  ; FOR EACH NUMERATOR PATIENT
 . S C0QFDA($$C0QMMNFN,"?+"_C0QI_","_MEAS_","_MSET_",",.01)=$O(@PATS@("N",C0QI,""))
 ;W "ADDING NUMERATOR",!
 ;I $D(C0QFDA) ZWR C0QFDA
 I $D(C0QFDA) D UPDIE
 K C0QFDA
 S C0QI=""
 F  S C0QI=$O(@PATS@("D",C0QI)) Q:C0QI=""  D  ; FOR EACH NUMERATOR PATIENT
 . S C0QFDA($$C0QMMDFN,"?+"_C0QI_","_MEAS_","_MSET_",",.01)=$O(@PATS@("D",C0QI,""))
 ;W "ADDING DENOMINATOR",!
 ;I $D(C0QFDA) ZWR C0QFDA
 I $D(C0QFDA) D UPDIE
 Q
 ;
DELIST(RTN) ; DECODES ^TMP("DILIST",$J) INTO
 ; @RTN@(IEN)=INTERNAL VALUE^EXTERNAL VALUE
 N ZI,IV,EV,ZDI,ZIEN
 S ZI=""
 S ZDI=$NA(^TMP("DILIST",$J))
 K @RTN
 F  S ZI=$O(@ZDI@(1,ZI)) Q:ZI=""  D  ;
 . S EV=@ZDI@(1,ZI) ;EXTERNAL VALUE
 . S IV=$G(@ZDI@("ID",ZI,.01)) ; INTERNAL VALUE
 . S ZIEN=@ZDI@(2,ZI) ; IEN
 . S @RTN@(ZIEN)=IV_"^"_EV
 Q
 ;
DELPATS(MSET,MEAS,NDEL) ; DELETE PATIENTS FROM NUMERATOR AND DENOMINATOR
 ; FOR A MEASURE (ONLY AFFECTS THE C0Q MEASURES FILE)
 ; MSET IS THE IEN OF THE MEASURE SET
 ; MEAS IS THE IEN OF THE MEASURE
 ; NDEL IS A LIST OF PATIENTS TO NOT DELETE (NOT IMPLEMENTED YET)
 ;  IN THE FORM @NDEL@("N",IEN,DFN)="" FOR NUMERATOR PATIENTS
 ;  AND @NDEL@("D",IEN,DFN)="" FOR DENOMINATOR PATIENTS WHERE IEN IS 
 ;  THE IEN OF THE PATIENT RECORD IN THE SUBFILE
 ;  THIS FEATURE WILL ALLOW EFFICIENCIES FOR LONG PATIENT LISTS
 ;  IN THAT PATIENTS THAT ARE GOING TO BE ADDED ARE NOT FIRST DELETED
 N C0QI,C0QJ
 D LIST^DIC($$C0QMMFN,","_MSET_",")
 K C0QFDA
 ZWR ^TMP("DILIST",$J,*)
 ZWR ^TMP("DIERR",$J,*)
 D 
 Q
 ;
UPDIE	; INTERNAL ROUTINE TO CALL UPDATE^DIE AND CHECK FOR ERRORS
 K ZERR
 D CLEAN^DILF
 D UPDATE^DIE("","C0QFDA","","ZERR")
 I $D(ZERR) D  ;
 . W "ERROR",!
 . ZWR ZERR
 . B
 K C0QFDA
 Q
 ;