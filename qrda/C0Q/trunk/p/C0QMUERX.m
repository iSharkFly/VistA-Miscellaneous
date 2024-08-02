C0QMUERX ; VEN - Analyze ERx Data for Patients ; 5/30/12 12:40pm
 ;;1.0;C0Q;;May 21, 2012;Build 44
 QUIT  ; No Entry from the top
 ;
UT ; Unit Tests
 N C0QDEBUG S C0QDEBUG=1
 W "Testing ^DPT B Index",!
 D EN("^DPT(""B"")")
 W !,"Testing B Index on a C0Q Patient List",!
 D EN("^C0Q(301,4,1,""B"")")
 W !,"Testing ^AUPNPAT B Index",!
 D EN("^AUPNPAT(""B"")")
 W !,"Testing Reminder Patient List B Index",!
 D EN("^PXRMXP(810.5,80,30,""B"")")
 W !,"Testing upright file ^DPT",!
 D EN("^DPT")
 W !,"Testing a file with no data",!
 D EN("^ALKJSDF")
 W !,"Testing a no valid parameters",!
 D EN("")
UT2 ; Units Tests 2 
 N C0QDEBUG S C0QDEBUG=1
 D EN("^C0Q(301,4,1,""B"")")
 QUIT
UT3 ; More Unit Tests
 N C0QDEBUG S C0QDEBUG=1
 D EN($$PATLN^C0QMU12("MU12-EP-HasERX"))
 W $$COUNT($$PATLN^C0QMU12("MU12-EP-HasERX"))
 QUIT
EN(C0QLIST) ; PEP - Analyze ERx Data and store
 ; Parameters:
 ; C0QLIST - Pass by Name. Global or Local Reference.
 ; Can be: ^DPT("B") for all patients or ^C0Q(301,2,1,"B") for a specific patient list
 ; Future: Can be a search template on file 2 or 9000001
 ;
 ; Check if XML Soap Message is installed
 I '$D(^C0PX("B","GETMEDS6")) WRITE "GETMEDS6 Soap Message not installed",! QUIT
 ;
 ; Check if SOAP^C0PWS2 exists
 I '$L($T(SOAP^C0PWS2)) WRITE "C0PWS2 Doesn't exist",! QUIT
 ;
 ; Check C0QLIST for sanity. Must be a single node.
 IF '($DATA(C0QLIST)#2)!(C0QLIST="") WRITE "You didn't pass the list",! QUIT
 ;
 ; Contents must be a Reference with Data
 IF '$DATA(@C0QLIST) WRITE "Destination doesn't contain any data",! QUIT
 ;
 ; Is this a B index?
 NEW C0QB
 IF $QSUBSCRIPT(C0QLIST,$QLENGTH(C0QLIST))="B" DO
 . SET C0QB=1
 . ; DEBUG
 . W:$G(C0QDEBUG) "B index passed",!
 . ; DEBUG
 ELSE  SET C0QB=0
 ;
 ; Make sure our TMP is empty
 K ^TMP($J)
 ;
 ; Walk the global
 N C0QWALK S C0QWALK=$SELECT(C0QB:"",'C0QB:0) ; Walker, start of $ORDER?
 N C0QDONE S C0QDONE=0 ; Finish Flag
 FOR  SET C0QWALK=$O(@C0QLIST@(C0QWALK)) QUIT:C0QDONE  DO
 . ; Are we done?
 . I C0QB,C0QWALK="" S C0QDONE=1 QUIT  ; If in index and we are out, done
 . I 'C0QB,'+C0QWALK S C0QDONE=1 QUIT  ; If not in index and we are not numeric, done
 . ;
 . N C0QDFN ; DFN of Patient
 . ; If Walking B Index and Index not numeric, grab DFN (assuming ^DPT or ^AUPNPAT)
 . ; TODO: Should I check that the global is ^DPT or ^AUPNPAT?
 . I C0QB,'+C0QWALK S C0QDFN=$O(@C0QLIST@(C0QWALK,""))
 . ; Otherwise, we will assume the contents of the index are the DFNs
 . E  S C0QDFN=C0QWALK
 . I $G(C0QDEBUG) W C0QDFN," "
 . ;
 . ; Now, check to see if the patient has e-Rx's
 . I $$HASERX(C0QDFN) S ^TMP($J,C0QDFN)=""
 ;
 W:$G(C0QDEBUG) ! ;
 ;
 ; Loop through collected DFNs, send to WS, and get data back, store in ^TMP($J,DFN)
 N C0QDFN S C0QDFN=0
 F  S C0QDFN=$O(^TMP($J,C0QDFN)) Q:C0QDFN=""  DO
 . N C0POUT
 . W:$G(C0QDEBUG) "Calling GETMEDS6 SOAP Web Service Call for "_C0QDFN,!
 . D SOAP^C0PWS2("C0POUT","GETMEDS6",DUZ,C0QDFN)
 . Q:$G(C0POUT(1,"RowCount"))=0 ; WS says no data
 . M ^TMP($J,C0QDFN)=C0POUT
 ;
 ; From the New Crop Meaningful Use documentation:
 ; Appendix G: Meaningful Use Certification FAQ Question 10
 ;
 ; DENOMINATOR                        NUMERATOR
 ; DeaClassCode = 0, 9                DeaClassCode = 0, 9
 ; PharmacyType = 1                   PharmacyType = 1
 ; PharmacyDetailType = 1, 2          PharmacyDetailType = 1, 2
 ; FinalDestinationType = 1, 2, 3, 4  FinalDestinationType = 3, 4
 ; FinalStatusType = 1, 4, 5          FinalStatusType = 1, 5
 ;
 ; DeMorgan's Law
 ; NOT(A or B) = NOT(A) and NOT(B)
 ; So to collect prescriptions for which DeaClassCode is 0 or 9
 ; We exclude all those who are not 0 AND not 9.
 ; See: http://en.wikipedia.org/wiki/De_Morgan%27s_laws#Negation_of_a_disjunction
 ;
 ; The algorithms below use an Onion Peeling method. Any prescription which
 ; fails makes you jump to the next prescription.
 ; The "Onion levels" are:
 ; DeaClassCode, PharamcyType, PharmacyDetailType, FinalDestinationType, FinalStatusType
 ;
 ; Now walk through collected DFNs and accumulate MU stats
 ;
 ; WARNING: Naked References below
 ; 
 N C0QDFN,C0QRXNO S (C0QDFN,C0QRXNO)=0
 N C0QD S C0QD=0 ; Denominator - Overall (cf C0QDP below)
 ;
 ; Calculate Denominator below
 F  S C0QDFN=$O(^TMP($J,C0QDFN)) Q:C0QDFN=""  DO
 . N C0QDP S C0QDP=0 ; Denominator - Patient Specific
 . F  S C0QRXNO=$O(^TMP($J,C0QDFN,C0QRXNO)) Q:C0QRXNO=""  DO
 .. W:$G(C0QDEBUG) "Patient "_C0QDFN_" Rx "_C0QRXNO,!
 .. ;
 .. I ^(C0QRXNO,"DeaClassCode") ; Change $REFERENCE
 .. ;
 .. N DEA S DEA=^("DeaClassCode")
 .. W:$G(C0QDEBUG) "DeaClassCode: "_DEA,!
 .. Q:((DEA'=0)&(DEA'=9))
 .. ;
 .. N PT S PT=^("PharmacyType")
 .. W:$G(C0QDEBUG) "PharmacyType: "_PT,!
 .. Q:(PT'=1)
 .. ;
 .. N PDT S PDT=^("PharmacyDetailType")
 .. W:$G(C0QDEBUG) "PharmacyDetailType: "_PDT,!
 .. Q:((PDT'=1)&(PDT'=2))
 .. ;
 .. N FDT S FDT=^("FinalDestinationType")
 .. W:$G(C0QDEBUG) "FinalDestinationType: "_FDT,!
 .. Q:((FDT'=1)&(FDT'=2)&(FDT'=3)&(FDT'=4))
 .. ;
 .. N FST S FST=^("FinalStatusType")
 .. W:$G(C0QDEBUG) "FinalStatusType: "_FST,!
 .. Q:((FST'=1)&(FST'=4)&(FST'=5))
 .. ;
 .. W:$G(C0QDEBUG) "Adding to Denominator",!
 .. S C0QDP=C0QDP+1
 .. S C0QD=C0QD+1
 . ;
 . ; SAVE C0QDP - while it lasts!
 . D SAVE(C0QLIST,C0QDFN,"ERXDEN",C0QDP)
 ;
 ; Calculate Numerator below
 N C0QDFN,C0QRXNO S (C0QDFN,C0QRXNO)=0
 N C0QN S C0QN=0 ; Numerator - Overall (cf C0QNP below)
 F  S C0QDFN=$O(^TMP($J,C0QDFN)) Q:C0QDFN=""  DO
 . N C0QNP S C0QNP=0 ; Numerator - Patient Specific
 . F  S C0QRXNO=$O(^TMP($J,C0QDFN,C0QRXNO)) Q:C0QRXNO=""  DO
 .. W:$G(C0QDEBUG) "Patient "_C0QDFN_" Rx "_C0QRXNO,!
 .. ;
 .. I ^(C0QRXNO,"DeaClassCode") ; Change $REFERENCE
 .. ;
 .. N DEA S DEA=^("DeaClassCode")
 .. W:$G(C0QDEBUG) "DeaClassCode: "_DEA,!
 .. Q:((DEA'=0)&(DEA'=9))
 .. ;
 .. N PT S PT=^("PharmacyType")
 .. W:$G(C0QDEBUG) "PharmacyType: "_PT,!
 .. Q:(PT'=1)
 .. ;
 .. N PDT S PDT=^("PharmacyDetailType")
 .. W:$G(C0QDEBUG) "PharmacyDetailType: "_PDT,!
 .. Q:((PDT'=1)&(PDT'=2))
 .. ;
 .. N FDT S FDT=^("FinalDestinationType")
 .. W:$G(C0QDEBUG) "FinalDestinationType: "_FDT,!
 .. Q:((FDT'=3)&(FDT'=4))
 .. ;
 .. N FST S FST=^("FinalStatusType")
 .. W:$G(C0QDEBUG) "FinalStatusType: "_FST,!
 .. Q:((FST'=1)&(FST'=5))
 .. ;
 .. W:$G(C0QDEBUG) "Adding to Numerator",!
 .. S C0QNP=C0QNP+1
 .. S C0QN=C0QN+1
 . ;
 . ; Save C0QNP while it lasts
 . D SAVE(C0QLIST,C0QDFN,"ERXNUM",C0QNP)
 ;
 S ^TMP($J)=C0QN_U_C0QD
 ;
 ; TODO: Over here, do something with the numerator and denominator..
 ; Probably store them somewhere.
 ; 
 I '$G(C0QDEBUG) K ^TMP($J) ; Empty out in production not testing
 QUIT
 ;
HASERX(DFN) ; $$ - Private; Has E-Prescriptions?
 ; Parameters
 ; - DFN by Value
 ; Output
 ; 0 or 1 (false or true)
 N ZI S ZI=""
 N ZERX S ZERX=$NA(^PS(55,DFN,"NVA"))
 N DONE,HASERX
 F  S ZI=$O(@ZERX@(ZI)) Q:ZI=""  Q:$G(DONE)  D
 . I $G(@ZERX@(ZI,1,1,0))["E-Rx Web" S (DONE,HASERX)=1
 Q +$G(HASERX)
 ;
SAVE(C0QLIST,C0QDFN,TYPE,COUNT) ; Proc - Private; Save Count in C0Q(301, file
 ; Layman's Explanation: Save the denominator or numerator for ePrescribing for
 ; each of the patients in the Subfile for that patient in ^C0Q(301,
 ; Still hard to understand though! Here's a demo:
 ; ^C0Q(301,IEN has a subfile under node 1 which stores the patients. E.g.
 ; ^C0Q(301,48,1,15,0)=91$
 ; ^C0Q(301,48,1,16,0)=93$
 ; ^C0Q(301,48,1,17,0)=173$
 ; 
 ; I store the numerator and denominator under each of the patients. The numerator
 ; stands for the number of prescriptions that were electronically transmitted;
 ; the denominator stands for the numbers of prescriptions that COULD HAVE BEEN
 ; electronically transmitted. End result for Patient 173 is as follows:
 ; ^C0Q(301,48,1,17,0)=173
 ; ^C0Q(301,48,1,17,1,0)="^1130580001.3111^2^2"
 ; ^C0Q(301,48,1,17,1,1,0)="ERXDEN^0"
 ; ^C0Q(301,48,1,17,1,2,0)="ERXNUM^0"
 ; ^C0Q(301,48,1,17,1,"B","ERXDEN",1)=""
 ; ^C0Q(301,48,1,17,1,"B","ERXNUM",2)=""
 ;
 ; Subroutine COUNT (below) goes and counts the data
 ; 
 ; Params:
 ; C0QLIST (by val): "B" x-ref where patients are located. Only supports ^C0Q(301, file.
 ; C0QDFN (by val): Patient DFN for whom to file data.
 ; TYPE (by val): Either ERXDEN or ERXNUM for eRx Denominator or eRx Numerator
 ; COUNT (by val): The number to save
 ;
 ; First, QUIT if this isn't a Quality Measures List?
 ; $QS(x,0) gets you the global name
 ; 
 ; This should give you an idea of what I am dealing with!
 ; 
 ; ^C0Q(301,48,1,15,0)=91
 ; ^C0Q(301,48,1,16,0)=93
 ; ^C0Q(301,48,1,17,0)=173
 ; ^C0Q(301,48,1,18,0)=174
 ; ^C0Q(301,48,1,"B",5,1)=""
 ; ^C0Q(301,48,1,"B",10,2)=""
 ; ^C0Q(301,48,1,"B",11,3)=""
 ; ^C0Q(301,48,1,"B",14,4)=""
 ;
 I $QS(C0QLIST,0)'="^C0Q" W:$G(C0QDEBUG) "Not Saving Patient "_C0QDFN,! QUIT
 ;
 ; Otherwise, prepare to save
 N C0QFDA ; Fileman Data Array
 N C0QIENS ; IENS
 N L1,L2 ; Top Level, Level 2
 S L1=$QS(C0QLIST,2) ; Top Level IEN
 S L2=$O(^C0Q(301,L1,1,"B",C0QDFN,"")) ; Patient IEN
 S C0QIENS="?+1"_C0QDFN_","_L2_","_L1_"," ; TODO: Here C0QDFN is a dummy for uniqueness in FDA, not meaningful! - DO BETTER!
 W:$G(C0QDEBUG) "IENs "_C0QIENS_" ready to file",!
 W:$G(C0QDEBUG) "Saving "_TYPE_" of "_COUNT_" for Patient "_$P(^DPT(C0QDFN,0),U)_" ("_C0QDFN_")",!
 S C0QFDA(1130580001.3111,C0QIENS,.01)=TYPE
 S C0QFDA(1130580001.3111,C0QIENS,.02)=COUNT
 ;
 W:$G(C0QDEBUG) "Fileman Data Array",!
 I $G(C0QDEBUG) N % S %=$NA(C0QFDA) F  S %=$Q(@%) Q:%=""  W %_": "_@%,!
 ;
 N C0QERR ; Errors
 D UPDATE^DIE("","C0QFDA","","C0QERR")
 ;
 I $D(C0QERR) DO
 . W "Error in filing data",!
 . N % S %=$NAME(C0QERR) F  S %=$Q(@%) Q:%=""  W %_": "_@%,!
 ;
 QUIT
 ;
COUNT(C0QLIST) ; $$ - Private; Count Numerator and Denominator for a Patient List
 ; Input: C0QLIST - Pass by Value - Patient Listing B index (only C0Q(301,IEN,1,"B", listing is supported)
 ; Output: (as string) NUMERATOR/DENOMINATOR
 ; 
 I $QS(C0QLIST,0)'="^C0Q" W:$G(C0QDEBUG) "Counting for files other than C0Q(301, not supported ",! QUIT "0/0"
 ; MEASURE -----------
 ; IEN -----------   |
 ; L1 ------|    |   |
 ;          V    V   V
 ; ^C0Q(301,48,1,2,1,1,0)="ERXDEN^0"
 ; ^C0Q(301,48,1,2,1,2,0)="ERXNUM^0"
 ; ^C0Q(301,48,1,2,1,"B","ERXDEN",1)=""
 ; ^C0Q(301,48,1,2,1,"B","ERXNUM",2)=""
 ; ^C0Q(301,48,1,2,1,"B"
 W:$G(C0QDEBUG) "DFN",?20,"Denominator",?40,"Numerator",!
 ;
 N L1 S L1=$QS(C0QLIST,2) ; Top Level IEN
 ;
 N DENTOT,NUMTOT S (DENTOT,NUMTOT)=0 ; Denominator Total, Numerator Total
 ;
 N C0QDFN S C0QDFN=0 ; Walker through B index
 F  S C0QDFN=$O(^C0Q(301,L1,1,"B",C0QDFN)) Q:C0QDFN=""  DO
 . N IEN S IEN=$O(^(C0QDFN,"")) ; naked naked - get IEN from B index
 . W:$G(C0QDEBUG) C0QDFN
 . ;
 . ; Denom Processing
 . N DENIEN S DENIEN=$O(^C0Q(301,L1,1,IEN,1,"B","ERXDEN","")) ; Denom IEN
 . N DEN S DEN=$S(DENIEN:$P(^C0Q(301,L1,1,IEN,1,DENIEN,0),U,2),1:"N/A") ; Denominator
 . W:$G(C0QDEBUG) ?20,DEN
 . S DENTOT=DENTOT+DEN ; Total it up (N/A becomes zero)
 . ;
 . N NUMIEN S NUMIEN=$O(^C0Q(301,L1,1,IEN,1,"B","ERXNUM","")) ; Numerator IEN
 . N NUM S NUM=$S(NUMIEN:$P(^C0Q(301,L1,1,IEN,1,NUMIEN,0),U,2),1:"N/A") ; Numerator
 . W:$G(C0QDEBUG) ?40,NUM
 . S NUMTOT=NUMTOT+NUM ; Total it up (N/A becomes zero)
 . ;
 . w:$G(C0QDEBUG) !
 ;
 ; Write the totals
 D:$G(C0QDEBUG)
 . W ?20,"==="
 . W ?40,"==="
 . W !
 . ;
 . W ?20,DENTOT
 . W ?40,NUMTOT
 . W !
 ;
 ; Quit with Numeartor/Denominator
 QUIT NUMTOT_"/"_DENTOT
