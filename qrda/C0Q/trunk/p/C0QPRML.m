C0QPRML	;JJOH/ZAG/GPL - Patient Reminder List ;7/5/11 8:50pm
	;;1.0;C0Q;;May 21, 2012;Build 33
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
	. D UPDATE^C0QUPDT(.G,9) ; UPDATE THE MU MEASUREMENT SET
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
	. . . D MEDS4
	       . . . D RECON2
	       . . . D ADVDIR
	. . . D SMOKING
	. . . D VITALS
	       . . . D VTE1
	       . . . D EDTIME
	. . . I C0QPR D PRINT
	. . . I C0QSS D SS
	. . . I C0QPL D PATLIST
	Q
	;
DEMO	; patient demographics
	K PTDOB
	N PTNAME,PTSEX,PTHRN,PTRLANG,PTLANG,RACE,RACEDSC,ETHN,ETHNDSC,RB
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
	N DEMOYN S DEMOYN=1
	I $G(PTSEX)="" S DEMOYN=0
	I $G(PTDOB)="" S DEMOYN=0
	I $G(PTHRN)="" S DEMOYN=0
	I $G(PTLANG)="" S DEMOYN=0
	I $G(RACEDSC)="" S DEMOYN=0
	I $G(ETHNDSC)="" S DEMOYN=0
	I DEMOYN S C0QLIST("HasDemographics",DFN)=""
	E  S C0QLIST("FailedDemographics",DFN)=""
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
MEDS2	; MEDICATIONS
	;
	K MEDSL,MDDESC,MDITEM
	D COVER^ORWPS(.MEDSL,DFN) ; CPRS MED LIST
	I '$D(MEDSL) D  ;
	. S C0QLIST("NoMedOrders",DFN)=""
	. I $$HFYN^C0QHF(DFN,"MEDS HAVE BEEN REVIEWED") D  ;
	. . S C0QLIST("HasMed",DFN)=""
	. E  S C0QLIST("NoMed",DFN)=""
	S MDCNT="" S HASINP=0
	F  S MDCNT=$O(MEDSL(MDCNT)) Q:MDCNT=""  D  ;
	. ;Q:$P(MEDSL(MDCNT),U,4)'="ACTIVE"  ;active medications only
	. ;S C0QLIST("HasMedOrders",DFN)=""
	. S C0QLIST("HasMed",DFN)=""
	. S MDDESC=$P(MEDSL(MDCNT),U,2) ;medication description
	. S MDITEM=$P($G(MEDSL(MDCNT)),U,3)
	. I $P($P(MEDSL(MDCNT),"^",1),";",2)="I" S HASINP=1
	I HASINP D  ; THE PATIENT HAS AN INPATIENT MED
	. S C0QLIST("HasMedOrders",DFN)="" ; an inpatient drug indicates CPOE
	E  S C0QLIST("NoMedOrders",DFN)="" ; this will be different for outpatient
	K MEDSL
	Q
	;
MEDS3	; USE THE REMINDER INDEX ^PXRMINDX TO CHECK FOR MEDS
	;
	S C0QPXRM=$NA(^PXRMINDX(55,"PI")) ; REMINDER INDEX FOR DRUGS
	I $D(@C0QPXRM@(DFN)) D  ; HAS MEDS
	. S C0QLIST("HasMed",DFN)=""
	. S C0QLIST("HasMedOrders",DFN)=""
	E  D  ; NO MEDS
	. S C0QLIST("NoMed",DFN)=""
	. S C0QLIST("NoMedOrders",DFN)=""
	Q
	;
MEDS4	; USE OCL^PSOORRL TO GET ALL MEDS
	N BEG,END
	S BEG=$$DT^C0PCUR("JULY 3,2011")
	S END=$$DT^C0PCUR("NOW")
	D OCL^PSOORRL(DFN,BEG,END)  ;DBIA #2400
	N C0QMEDS
	M C0QMEDS=^TMP("PS",$J) ; MEDS RETURNED FROM CALL
	N FOUND
	N ZI
	I '$D(C0QMEDS(1)) D  Q  ; QUIT IF NO MEDS
	. S C0QLIST("NoMed",DFN)=""
	E  D  ; HAS MEDS
	. S C0QLIST("HasMed",DFN)=""  
	S ZI="" S FOUND=0
	F  S ZI=$O(C0QMEDS(ZI)) Q:ZI=""  D  ; FOR EACH MED
	. N ZM
	. S ZM=$G(C0QMEDS(ZI,0)) ;THE MEDICATION
	. I $P($P(ZM,"^",1),";",2)="I" D  ; IE 1U;I FOR AN INPATIENT UNIT DOSE
	. . S FOUND=1
	I FOUND S C0QLIST("HasMedOrders",DFN)="" ; MET CPOE MEASURE
	E  S C0QLIST("NoMedOrders",DFN)=""
	Q
	;
RECON	; MEDICATIONS RECONCILIATION
	; 
	I $$HASNTYN^C0QNOTES("MED/SURG NURSING ADMISSION ASSESSMENT",DFN) D  ;
	. S C0QLIST("XferOfCare",DFN)="" ; transfer of care patient
	N HASRECON S HASRECON=0
	N GT,G
	S GT(4,"HasMedRecon","MEDICATION RECONCILIATION COMPLET")=""
	S GT(5,"HasMedRecon","Medication Reconcilation Complete")=""
	I $$TXTALL^C0QNOTES(.G,.GT,DFN) D  ; SEARCH ALL NOTES FOR MED RECON
	. S HASRECON=1
	;N ZT
	;S ZT="MEDICATION RECONCILIATION COMPLET"
	;I $$NTTXT^C0QNOTES("ER NURSE NOTE",ZT,DFN) D  ;
	;. S HASRECON=1
	;E  D  ;
	;. S ZT="Medication Reconcilation Complete"
	;. I $$NTTXT^C0QNOTES("MED/SURG NURSING ADMISSION ASSESSMENT",ZT,DFN) D  ;
	;. . S HASRECON=1
	;I $$HFYN^C0QHF("MEDS HAVE BEEN REVIEWED",DFN) S HASRECON=1
	I HASRECON D  ;
	. S C0QLIST("HasMedRecon",DFN)=""
	E  S C0QLIST("NoMedRecon",DFN)=""
	Q
	;
RECON2	; USE HEALTH FACTORS FOR MEDICATION RECONCILIATION
	I $$HASNTYN^C0QNOTES("MED/SURG NURSING ADMISSION ASSESSMENT",DFN) D  ;
	. S C0QLIST("XferOfCare",DFN)="" ; transfer of care patient
	I $$HFYN^C0QHF(DFN,"Medication Reconciliation Completed: Yes") D  ;
	. S C0QLIST("HasMedRecon",DFN)=""
	E  S C0QLIST("NoMedRecon",DFN)=""
	Q
	;
ADVDIR	; ADVANCE DIRECTIVE
	;
	I $$AGE^C0QUTIL(DFN)>64 D  ; ONLY FOR PATIENTS 65 AND OLDER
	. S C0QLIST("Over65",DFN)=""
	. I $$HASNTYN^C0QNOTES("ADVANCE DIRECTIVE",DFN) D  ;
	. . S C0QLIST("HasAdvanceDirective",DFN)=""
	. E  D  ;
	. . S C0QLIST("NoAdvanceDirective",DFN)=""
	Q
	;
SMOKING	;
	I $$INLIST("HasSmokingStatus",DFN) D  Q  ; ALREADY HAS SMOKING STATUS CHECK
	. S C0QLIST("HasSmokingStatus",DFN)=""
	. S C0QLIST("Over12",DFN)=""
	I $$INLIST("NoSmokingStatus",DFN) D  Q  ; ALREADY HAS SMOKING STATUS CHECK
	. S C0QLIST("NoSmokingStatus",DFN)=""
	. S C0QLIST("Over12",DFN)=""
	N C0QSMOKE,C0QSYN
	S C0QSYN=0
	I $$AGE^C0QUTIL(DFN)<13 Q  ; DON'T CHECK UNDER AGE 13
	D HFCAT^C0QHF(.C0QSMOKE,DFN,"TOBACCO") ; GET ALL HEALTH FACTORS FOR THE
	; PATIENT IN THE CATEGORY OF TOBACCO
	I $D(C0QSMOKE) S C0QSYN=1
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Quit Smokeless Tobacco <1 Yr Ago")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Quit Smokeless Tobacco > 20 Yrs Ago")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Quit Smokeless Tobacco: 1-5 Yrs Ago")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Quit Smokeless Tobacco: 10-20 Yrs Ago")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Quit Smokeless Tobacco: 5-10 Yrs Ago")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Quit Smoking")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Quit Smoking < 1 Yr Ago")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Quit Smoking > 20 Yrs Ago")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Quit Smoking: 1-5 Yrs Ago")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Quit Smoking: 10-20 Yrs Ago")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Quit Smoking: 5-10 Yrs Ago")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKELESS TOBACCO USER")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKELESS: 1-5 YRS AGO")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKELESS: 10-20 YRS AGO")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKELESS: 5-10 YRS AGO")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKELESS: < 1 YR AGO")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKELESS: > 20 YRS AGO")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKER")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKER 10-20 YRS")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKER 20+ YRS")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKER < 1 YR")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKER < 1 YR AGO")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKER > 20 YRS AGO")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKER: 1-5 YRS")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKER: 1-5 YRS AGO")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKER: 10-20 YRS AGO")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKER: 5-10 YRS")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKER: 5-10 YRS AGO")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"PREVIOUS SMOKELESS TOBACCO USER")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"LIFETIME NON-SMOKER")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smokeless Tobacco User")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smoker")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smoker (PMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoke Exposure/2nd Hand Exposure")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 1-5 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 10-20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 5-10 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For < 1 Yr")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For > 20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Tobacco User")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 1-5 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 10-20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 5-10 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for < 1 Yr")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for > 20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoker (HPI)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoking (FMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoking (PMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoking Cessation (OPH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"LIFETIME NON-SMOKER")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smokeless Tobacco User")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smoker")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smoker (PMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoke Exposure/2nd Hand Exposure")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 1-5 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 10-20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 5-10 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For < 1 Yr")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For > 20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Tobacco User")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 1-5 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 10-20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 5-10 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for < 1 Yr")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for > 20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoker (HPI)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoking (FMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoking (PMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Non-Smoker")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"LIFETIME NON-SMOKER")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smokeless Tobacco User")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smoker")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smoker (PMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoke Exposure/2nd Hand Exposure")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 1-5 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 10-20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 5-10 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For < 1 Yr")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For > 20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Tobacco User")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 1-5 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 10-20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 5-10 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for < 1 Yr")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for > 20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoker (HPI)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoking (FMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoking (PMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"LIFETIME NON-SMOKER")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smokeless Tobacco User")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smoker")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smoker (PMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoke Exposure/2nd Hand Exposure")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 1-5 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 10-20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 5-10 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For < 1 Yr")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For > 20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Tobacco User")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 1-5 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 10-20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 5-10 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for < 1 Yr")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for > 20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoker (HPI)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoking (FMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoking (PMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Non-Smoker")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"LIFETIME NON-SMOKER")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smokeless Tobacco User")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smoker")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Former Smoker (PMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoke Exposure/2nd Hand Exposure")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 1-5 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 10-20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For 5-10 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For < 1 Yr")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoked For > 20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Tobacco User")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 1-5 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 10-20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for 5-10 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for < 1 Yr")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smokeless Used for > 20 Yrs")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoker (HPI)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoking (FMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Smoking (PMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Non-Smoker")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Non-Smoker (PMH)")
	S:'C0QSYN C0QSYN=$$HFYN^C0QHF(DFN,"Non-Tobacco User")
	S C0QLIST("Over12",DFN)=""
	N GT
	S GT(1,"HasSmokingStatus","SMOK")=""
	S GT(2,"HasSmokingStatus","Smok")=""
	S GT(3,"HasSmokingStatus","smok")=""
	;N ZT
	;S ZT="Smok"
	;S:'C0QSYN C0QSYN=$$NTTXT^C0QNOTES("ER NURSE NOTE",ZT,DFN)  ;
	I 'C0QSYN D  ;
	. N G
	. S OK=$$TXTALL^C0QNOTES(.G,.GT,DFN)
	. I $D(G) S C0QSYN=1
	I C0QSYN S C0QLIST("HasSmokingStatus",DFN)=""
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
VTE1	; VTE PROPHYLAXIS WITHIN 24HRS OF ARRIVAL
	;
	I $$HFYN^C0QHF(DFN,"VTE PROPHYLAXIS WITHIN 24HRS OF ARRIVAL") D  ;
	. S C0QLIST("HasVTE24",DFN)=""
	E  S C0QLIST("NoVTE24",DFN)="" 
	Q
	;
EDTIME	; CHECK FOR EMERGENCY DEPT TIME FACTORS
	N FOUND
	S FOUND=0
	I $$HFYN^C0QHF(DFN,"ED ARRIVAL TIME") S FOUND=1
	I '$$HFYN^C0QHF(DFN,"ED DEPARTURE TIME") S FOUND=0
	I '$$HFYN^C0QHF(DFN,"TIME DECISION TO ADMIT MADE") S FOUND=0
	I FOUND D  ; 
	. S C0QLIST("HasEDtime",DFN)=""
	E  S C0QLIST("NoEDtime",DFN)=""
	Q
	;
INLIST(ZLIST,DFN)	; EXTRINSIC FOR IS PATIENT ALREADY IN LIST ZLIST
	N ZL,ZR
	S ZL=$O(^C0Q(301,"CATTR",ZLIST,"")) ; IEN OF LIST IN C0Q PATIENT LIST FILE
	I ZL="" Q 0 ; LIST DOES NOT EXIST
	S ZR=0 ; ASSUME NOT IN LIST
	I $D(^C0Q(301,ZL,1,"B",DFN)) S ZR=1 ; PATIENT IS IN LIST
	Q ZR
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
	;I DEMOYN S C0QLIST("HasDemographics",DFN)=""
	;E  S C0QLIST("FailedDemographics",DFN)=""
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
	;I $D(MDITEM) D  ;
	       ;. S C0QLIST("HasMed",DFN)=""
	;E  S G1("NoMed",DFN)=""
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
	. Q:$P(DTE,".")<3110703
	. S EXDTE=$$FMTE^XLFDT(DTE)
	. N PTFM S PTFM=""
	. D
	. . S PTFM=$O(^DGPM("B",DTE,PTFM))
	. . Q:'PTFM
	. . S DFN=$P(^DGPM(PTFM,0),U,3)
	       . . S C0QLIST("Patient",DFN)=""
	. . D DEMO
	. . D PROBLEM
	. . D ALLERGY
	. . D MEDS4
	       . . D RECON2
	       . . D ADVDIR
	. . D SMOKING
	. . D VITALS
	       . . D VTE1
	       . . D EDTIME
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
