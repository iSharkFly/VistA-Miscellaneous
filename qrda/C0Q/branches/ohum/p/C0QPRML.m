C0QPRML	;JJOH/ZAG/GPL - Patient Reminder List ;7/5/11 8:50pm
	;;1.0;MU PACKAGE;;;Build 19
	;
	;2011 Zach Gonzales<zach@linux.com> - Licensed under the terms of the GNU
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
BUILD	; CALL ALL AND DIS AND BUILD THE GRSLT ARRAY or print or create
	; patient lists
	;N GRSLT ; ARRAY FOR RESULTS
	I '$D(C0QSS) S C0QSS=0 ;default don't build spreadsheet array
	I '$D(C0QPR) S C0QPR=0 ;default don't print out results
	I '$D(C0QPL) S C0QPL=1 ;default do create patient lists
	N G1 ; ONE SET OF VALUES - RNF1 FORMAT
	; INITIALIZE LISTS
	; this is done so that if there are no matching patients, the patient list
	; will be zeroed out
	S C0QLIST("HasDemographics")=""
	S C0QLIST("Patient")=""
	S C0QLIST("HasProblem")=""
	S C0QLIST("HasAllergy")=""
	S C0QLIST("HasMed")=""
	S C0QLIST("HasVitalSigns")=""
	S C0QLIST("HasMedOrders")=""
	S C0QLIST("HasSmokingStatus")=""
	D ALL ; all currently admitted patients in the hospital
	D DIS ; all patients discharged since the reporting period began
	I C0QSS ZWR GRSLT
	I C0QPL D  ;
	. D FILE ; FILE THE PATIENT LISTS
	. D UPDATE^C0QUPDT(.G,8) ; UPDATE THE MU MEASUREMENT SET
	Q
	;
ALL	;retrieve active inpatients
	N WARD S WARD=""
	F  D  Q:WARD=""
	. S WARD=$O(^DIC(42,"B",WARD)) ;ward name
	. Q:WARD=""
	. N WIEN S WIEN=""
	. F  S WIEN=$O(^DIC(42,"B",WARD,WIEN)) Q:'WIEN  D  ;wards IEN
	. . S WARDNAME=$P(^DIC(42,WIEN,0),U,2) ;ward name
	. . N DFN,RB S DFN=""
	. . F  S DFN=$O(^DPT("CN",WARD,+DFN)) Q:'DFN  D  ;DFN of patient on ward
	. . . D DEMO
	. . . D PROBLEM
	. . . D ALLERGY
	. . . D MEDS
	. . . D SMOKING
	. . . D VITALS
	. . . I C0QPR D PRINT
	. . . I C0QSS D SS
	. . . I C0QPL D PATLIST
	Q
	;
DEMO	; patient demographics
	S PTNAME=$P(^DPT(DFN,0),U) ;patient name
	S PTDOB=$$FMTE^XLFDT($P($G(^DPT(DFN,0)),U,3)) ;date of birth
	S PTSEX=$P($G(^DPT(DFN,0)),U,2) ;patient sex
	D PID^VADPT ;VADPT call to grab PISD based on PT Eligibility
	S PTHRN=$P($G(VA("PID")),U) ;health record number
	S PTRLANG=$P($G(^DPT(DFN,256000)),U) ;ptr to language file
	I $G(PTRLANG)'="" S PTLANG=$P(^DI(.85,PTRLANG,0),U) ;PLS extrnl
	S RACE=""
	F  D  Q:RACE=""
	. S RACE=$O(^DPT(DFN,.02,"B",RACE)) ;race code IEN
	. Q:'RACE
	. S RACEDSC=$P($G(^DIC(10,RACE,0)),U) ;race description
	S ETHN=""
	F  D  Q:ETHN=""
	. S ETHN=$O(^DPT(DFN,.06,"B",ETHN)) ;ethnicity IEN
	. Q:'ETHN
	. S ETHNDSC=$P($G(^DIC(10.2,ETHN,0)),U) ;ethnincity description
	S RB=$P($G(^DPT(DFN,.101)),U) ;room and bed
	Q
	;
PROBLEM	; PATIENT PROBLEMS
	D LIST^ORQQPL(.PROBL,DFN,"A")
	S PBCNT=""
	F  S PBCNT=$O(PROBL(PBCNT)) Q:PBCNT=""  D
	. S PBDESC=$P(PROBL(PBCNT),U,2) ;problem description
	K PROBL
	Q
	; 
ALLERGY	; ALLERGY LIST
	D LIST^ORQQAL(.ALRGYL,DFN)
	S ALCNT=""
	F  S ALCNT=$O(ALRGYL(ALCNT)) Q:ALCNT=""  D
	. S ALDESC=$P(ALRGYL(ALCNT),U,2) ;allergy description
	K ALRGYL
	Q
	;
MEDS	; MEDICATIONS
	;
	I DFN=97 D  Q  ;
	. S MDCNT=271
	K MEDSL
	D EN^C0CNHIN(.MEDSL,DFN,"MED;") ; GET THE MEDS FROM THE NHIN API
	; can't use COVER^ORWPS even though it's fast.. we need to detect
	; if the medications are Inpatient to compute the CPOE measure
	; we will use the NHINV routines for this purpose
	;D COVER^ORWPS(.MEDSL,DFN)
	S MDCNT="" S HASINP=0
	F  S MDCNT=$O(MEDSL("med",MDCNT)) Q:MDCNT=""  D
	. ;Q:$P(MEDSL(MDCNT),U,4)'="ACTIVE"  ;active medications only
	. Q:MEDSL("med",MDCNT,"status@value")'="active"
	. ;S MDDESC=$P(MEDSL(MDCNT),U,2) ;medication description
	. S MDDESC=$G(MEDSL("med",MDCNT,"products.product@name"))
	. ;S MDITEM=$P($G(MEDSL(MDCNT)),U,3)
	. S MDITEM=$G(MEDSL("med",MDCNT,"sig")) ; i think this is what meditem is
	. I MEDSL("med",MDCNT,"vaType@value")="I" S HASINP=1
	I HASINP D  ; THE PATIENT HAS AN INPATIENT MED
	. S C0QLIST("HasMedOrders",DFN)="" ; an inpatient drug indicates CPOE
	E  S C0QLIST("NoMedOrders",DFN)="" ; this will be different for outpatient
	K MEDSL
	Q
	;
SMOKING	; 
	N C0QSMOKE
	D HFCAT^C0QHF(.C0QSMOKE,DFN,"TOBACCO") ; GET ALL HEALTH FACTORS FOR THE
	; PATIENT IN THE CATEGORY OF TOBACCO
	I $D(C0QSMOKE) S C0QLIST("HasSmokingStatus",DFN)=""
	E  S C0QLIST("NoSmokingStatus",DFN)=""
	Q
	;
VITALS	;
	;
	N C0QSDT,C0QEDT
	D DT^DILF(,"JULY 3,2011",.C0QSDT) ; START DATE
	D DT^DILF(,"T",.C0QEDT) ; END DATE TODAY
	D VITALS^ORQQVI(.VITRSLT,DFN,C0QSDT,C0QEDT) ; CALL FAST VITALS
	I $D(VITRSLT) D  ;ZWR VITRSLT B  ;
	. I VITRSLT(1)["No vitals found." S C0QLIST("NoVitalSigns",DFN)=""
	. E  S C0QLIST("HasVitalSigns",DFN)=""
	Q
	;
PRINT	; PRINT TO SCREEN
	
	I $D(WARD) W !!,WARD_"-"_WARDNAME_" "_RB_": "_PTNAME_"("_PTSEX_") "
	I $D(EXDTE) D  ;
	. W !,"Discharge Date: ",EXDTE
	. W !,DFN," ",PTNAME
	W !,"DOB: ",PTDOB," HRN: ",PTHRN
	W !,"Language Spoken: ",$G(PTLANG)
	W !,"Race: ",RACEDSC
	W !,"Ethnicity: ",$G(ETHNDSC)
	W !,"Problems: "
	W !,PBDESC
	W !,"Allergies: "
	W !,ALDESC
	W !,"Medications: "
	W !
	Q
	;
SS	; CREATE SPREADSHEET ARRAY
	S G1("Patient")=DFN
	I $D(WARD) D  ;
	. S G1("WardName")=WARDNAME
	. S G1("RoomAndBed")=RB
	I $D(EXDTE) D ; 
	. S G1("DischargeDate")=EXDTE
	S G1("PatientName")=PTNAME
	S G1("Gender")=PTSEX
	S G1("DateOfBirth")=PTDOB
	S G1("HealthRecordNumber")=PTHRN
	S G1("LanguageSpoken")=$G(PTLANG)
	S G1("Race")=RACEDSC
	S G1("Ehtnicity")=$G(ETHNDSC)
	S G1("Problem")=PBDESC
	I PBDESC["No problems found" S G1("HasProblem")=0
	E  S G1("HasProblem")=1
	S G1("Allergies")=ALDESC
	I ALDESC["No Allergy" S G1("HasAllergy")=0
	E  S G1("HasAllergy")=1
	I $D(MDITEM) D  ;
	. S G1("HasMed")=1
	E  S G1("HasMed")=0
	S G1("MedDescription")=$G(MDDESC)
	I $D(MDITEM) W !,"("_MDITEM_")"_MDDESC E  W !,MDDESC
	D RNF1TO2B^C0CRNF("GRSLT","G1")
	K G1
	Q  ; DON'T WANT TO DO THE NHIN STUFF NOW
	;
PATLIST	; CREATE PATIENT LISTS
	S C0QLIST("Patient",DFN)="" ; THE PATIENT LIST
	N DEMOYN S DEMOYN=1
	I $G(PTSEX)="" S DEMOYN=0
	I $G(PTDOB)="" S DEMOYN=0
	I $G(PTHRN)="" S DEMOYN=0
	I $G(PTLANG)="" S DEMOYN=0
	I $G(RACEDSC)="" S DEMOYN=0
	I $G(ETHNDSC)="" S DEMOYN=0
	I DEMOYN S C0QLIST("HasDemographics",DFN)=""
	E  S C0QLIST("FailedDemographics",DFN)=""
	;S G1("Gender")=PTSEX
	;S G1("DateOfBirth")=PTDOB
	;S G1("HealthRecordNumber")=PTHRN
	;S G1("LanguageSpoken")=$G(PTLANG)
	;S G1("Race")=RACEDSC
	;S G1("Ehtnicity")=$G(ETHNDSC)
	S G1("Problem")=PBDESC
	I PBDESC["No problems found" S C0QLIST("NoProblem",DFN)=""
	E  S C0QLIST("HasProblem",DFN)=""
	;S G1("Allergies")=ALDESC
	I ALDESC["No Allergy" S C0QLIST("NoAllergy",DFN)=""
	E  S C0QLIST("HasAllergy",DFN)=""
	I $D(MDITEM) D  ;
	. S C0QLIST("HasMed",DFN)=""
	E  S G1("NoMed",DFN)=""
	;S G1("MedDescription")=$G(MDDESC)
	Q
	;
NHIN	; SHOW THE NHIN ARRAY FOR THIS PATIENT
	Q:DFN=137!14
	D EN^C0CNHIN(.G,DFN,"")
	ZWR G
	K G
	;
	QUIT  ;end of WARD
	;
	;
DIS;	
	N DFN,DTE,EXDTE S DTE=""
	F  D  Q:DTE=""
	. S DTE=$O(^DGPM("B",DTE))
	. Q:'DTE
	. Q:DTE<3110703
	. S EXDTE=$$FMTE^XLFDT(DTE)
	. N PTFM S PTFM=""
	. D
	. . S PTFM=$O(^DGPM("B",DTE,PTFM))
	. . Q:'PTFM
	. . S DFN=$P(^DGPM(PTFM,0),U,3)
	. . D DEMO
	. . D PROBLEM
	. . D ALLERGY
	. . D MEDS
	. . D SMOKING
	. . D VITALS
	. . I C0QPR D PRINT
	. . I C0QSS D SS
	. . I C0QPL D PATLIST
	Q
	;
C0QPLF()	Q 1130580001.301 ; FILE NUMBER FOR C0Q PATIENT LIST FILE
C0QALFN()	Q 1130580001.311 ; FILE NUMBER FOR C0Q PATIENT LIST PATIENT SUBFILE
FILE	; FILE THE PATIENT LISTS TO C0Q PATIENT LIST
	;
	I '$D(C0QLIST) Q  ;
	N LFN S LFN=$$C0QALFN()
	N ZI,ZN
	S ZI=""
	F  S ZI=$O(C0QLIST(ZI)) Q:ZI=""  D  ;
	. S ZN=$O(^C0Q(301,"CATTR",ZI,""))
	. I ZN="" D  Q  ; OOPS
	. . W !,"ERROR, ATTRIBUTE NOT FOUND IN PATIENT LIST FILE:"_ZI
	. ;S ZN=$$KLNCR(ZN) ; KILL AND RECREATE RECORD ZN
	. N C0QNEW,C0QOLD,C0QRSLT
	. S C0QNEW=$NA(C0QLIST(ZI)) ; THE NEW PATIENT LIST
	. S C0QOLD=$NA(^C0Q(301,ZN,1,"B")) ; THE OLD PATIENT LIST
	. D UNITY^C0QSET("C0QRSLT",C0QNEW,C0QOLD) ; FIND WHAT'S NEW
	. N ZJ,ZK
	. ; FIRST, DELETE THE OLD ONES - NO LONGER IN THE LIST
	. K C0QFDA
	. S ZJ=""
	. F  S ZJ=$O(C0QRSLT(2,ZJ)) Q:ZJ=""  D  ; MARKED WITH A 2 FROM UNITY
	. . S ZK=$O(@C0QOLD@(ZJ,"")) ; GET THE IEN OF THE RECORD TO DELETE
	. . I ZK="" D  Q  ; OOPS SHOULDN'T HAPPEN
	. . . W !,"INTERNAL ERROR FINDING A PATIENT TO DELETE"
	. . . B
	. . S C0QFDA(LFN,ZK_","_ZN_",",.01)="@"
	. I $D(C0QFDA) D UPDIE ; PROCESS THE DELETIONS
	. ; SECOND, PROCESS THE ADDITIONS
	. K C0QFDA
	. S ZJ="" S ZK=1
	. F  S ZJ=$O(C0QRSLT(0,ZJ)) Q:ZJ=""  D  ; PATIENTS TO ADD ARE MARKED WITH 0
	. . S C0QFDA(LFN,"+"_ZK_","_ZN_",",.01)=ZJ
	. . S ZK=ZK+1
	. I $D(C0QFDA) D UPDIE ; PROCESS THE ADDITIONS
	;. Q
	;. K C0QFDA
	;. N ZJ,ZC
	;. S ZJ="" S ZC=1
	;. F  S ZJ=$O(C0QLIST(ZI,ZJ)) Q:ZJ=""  D  ; FOR EACH PAT IN LIST
	;. . S C0QFDA(LFN,"?+"_ZC_","_ZN_",",.01)=ZJ
	;. . S ZC=ZC+1
	;. D UPDIE
	;. W !,"FOUND:"_ZI
	Q
	;
KLNCR(ZREC)	; KILL AND RECREATE RECORD ZREC IN PATIENT LIST FILE
	;
	N C0QFDA,ZFN,LIST,ATTR
	S ZFN=$$C0QPLF() ; FILE NUMBER FOR C0Q PATIENT LIST FILE
	D CLEAN^DILF
	S LIST=$$GET1^DIQ(ZFN,ZREC_",",.01) ;  MEASURE NAME
	S ATTR=$$GET1^DIQ(ZFN,ZREC_",",999) ; ATTRIBUTE
	D CLEAN^DILF
	K ZERR
	S C0QFDA(ZFN,ZREC_",",.01)="@" ; GET READY TO DELETE THE MEASURE
	D FILE^DIE(,"C0QFDA","ZERR") ; KILL THE SUBFILE
	I $D(ZERR) S ZZERR=ZZERR ; ZZERR DOESN'T EXIST, INVOKE THE ERROR TRAP IF TASKED
	;. W "ERROR",!
	;. ZWR ZERR
	;. B
	K C0QFDA
	S C0QFDA(ZFN,"+1,",.01)=LIST ; GET READY TO RECREATE THE RECORD
	S C0QFDA(ZFN,"+1,",999)=ATTR ; ATTRIBUTE
	D UPDIE ; CREATE THE SUBFILE
	N ZR ; NEW IEN FOR THE RECORD
	S ZR=$O(^C0Q(301,"CATTR",ATTR,""))
	;
	Q ZR
	;
UPDIE	; INTERNAL ROUTINE TO CALL UPDATE^DIE AND CHECK FOR ERRORS
	K ZERR
	D CLEAN^DILF
	D UPDATE^DIE("","C0QFDA","","ZERR")
	I $D(ZERR) S ZZERR=ZZERR ; ZZERR DOESN'T EXIST, INVOKE THE ERROR TRAP IF TASKED
	;. W "ERROR",!
	;. ZWR ZERR
	;. B
	K C0QFDA
	Q
	;
	; WHAT FOLLOWS IS OLD CODE - DELETE WHEN THIS WORKS
	;. . N PTNAME S PTNAME=$P(^DPT(DFN,0),U,1)
	;. . S PTDOB=$$FMTE^XLFDT($P($G(^DPT(DFN,0)),U,3)) ;date of birth
	;. . S PTSEX=$P($G(^DPT(DFN,0)),U,2) ;patient sex
	;. . D PID^VADPT ;VADPT call to grab PISD based on PT Eligibility
	;. . S PTHRN=$P($G(VA("PID")),U) ;health record number
	;. . S PTRLANG=$P($G(^DPT(DFN,256000)),U) ;ptr to language file
	;. . I $G(PTRLANG)'="" S PTLANG=$P(^DI(.85,PTRLANG,0),U) ;PLS extrnl
	;. . S RACE=""
	;. . F  D  Q:RACE=""
	;. . . S RACE=$O(^DPT(DFN,.02,"B",RACE))
	;. . . Q:'RACE
	;. . . S RACEDSC=$P($G(^DIC(10,RACE,0)),U)
	;. . N ETHNDSC
	;. . N ETHNDSC S ETHNDSC=""
	;. . S ETHN=""
	;. . F  D  Q:ETHN=""
	;. . . S ETHN=$O(^DPT(DFN,.06,"B",ETHN))
	;. . . Q:'ETHN
	;. . . S ETHNDSC=$P($G(^DIC(10.2,ETHN,0)),U)
	;. . D LIST^ORQQPL(.PROBL,DFN,"A")
	;. . S PBCNT=""
	;. . F  S PBCNT=$O(PROBL(PBCNT)) Q:PBCNT=""  D
	;. . . S PBDESC=$P(PROBL(PBCNT),U,2) ;problem description
	;. . K PROBL
	;. . D LIST^ORQQAL(.ALRGYL,DFN)
	;. . S ALCNT=""
	;. . F  S ALCNT=$O(ALRGYL(ALCNT)) Q:ALCNT=""  D
	;. . . S ALDESC=$P(ALRGYL(ALCNT),U,2) ;allergy description
	;. . K ALRGYL
	;. . D COVER^ORWPS(.MEDSL,DFN)
	;. . S MDCNT=""
	;. . F  S MDCNT=$O(MEDSL(MDCNT)) Q:MDCNT=""  D
	;. . . Q:$P(MEDSL(MDCNT),U,4)'="ACTIVE"  ;active medications only
	;. . . S MDDESC=$P(MEDSL(MDCNT),U,2) ;medication description
	;. . . S MDITEM=$P($G(MEDSL(MDCNT)),U,3)
	;. . K MEDSL
	;. . W !,"Discharge Date: ",EXDTE
	;. . W !,DFN," ",PTNAME
	;. . W !,"DOB: ",PTDOB," HRN: ",PTHRN
	;. . W !,"Language Spoken: ",$G(PTLANG)
	;. . W !,"Race: ",RACEDSC
	;. . W !,"Ethnicity: ",ETHNDSC
	;. . W !,"Problems: "
	;. . W !,PBDESC
	;. . W !,"Allergies: "
	;. . W !,ALDESC
	;. . W !,"Medications: "
	;. . I $D(MDITEM) W !,"(",MDITEM,")",MDDESC E  W !,MDDESC
	;. . W !
	;Q
	;
	;
	;
	;
END	;end of C0QPRML;
