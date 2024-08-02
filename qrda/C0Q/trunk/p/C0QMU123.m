C0QMU123	; VEN/SMH - Clone a Measure Set and give a new name and filter. ; 10/23/12 1:07pm
	;;1.0;QUALITY MEASURES;**6**;
	; (C) George Lilly. Licensed under AGPL.
	QUIT
	;
CLONE(MSIEN,CLNNM,ISQM,FLNAME)	; Private $$ ; Clone a measure set into a new one
	; Input:
	; 1. Measurement Set IEN to clone
	; 2. Clinic Name for which this Measurement Set would apply (FT)
	; 3. Boolean: Is Quality Measure?
	; 4. Filter List Name
	;
	; Output:
	; IEN of Created measure set.
	;
	; Get data from Model Set
	N C0QIENS S C0QIENS=MSIEN_"," ; Input to GETS call
	N C0QOUT,C0QERR ; Output Variables in GETS call.
	D GETS^DIQ(1130580001.201,C0QIENS,"**","",$NA(C0QOUT),$NA(C0QERR))
	;
	I $D(C0QERR) S $EC=",U1," ; Crash in case of error. Shouldn't happen.
	;
	; Deal with D0 stuff first.
	; Merge D0 level into a new FDA array.
	N C0QNEW ; New FDA
	M C0QNEW(1130580001.201,"?+1,")=C0QOUT(1130580001.201,C0QIENS)
	;
	; Change .01
	; NOTE: Field name is 30 characters. But HL is max 30 chars too!
	; So we have to truncate it.
	; If Is Quality Measure, Use QM, otherwise, use Performance Report.
	S C0QNEW(1130580001.201,"?+1,",.01)=$E(CLNNM,1,27)_" "_$S(ISQM:"QM",1:"PR")
	;
	; Deal with D1 level
	N I S I=0 ; Looper
	N CNT S CNT=1 ; IENS counter ; Will become 2 and larger. Not to collide with the initial 1.
	;
	; For each record in D1 level
	F  S I=$O(C0QOUT(1130580001.2011,I)) Q:'I  D
	. S CNT=CNT+1
	. ; Grab the Measure field
	. S C0QNEW(1130580001.2011,"?+"_CNT_",?+1,",.01)=C0QOUT(1130580001.2011,I,.01)
	. ;
	. ; Put the Filter lists on
	. S C0QNEW(1130580001.2011,"?+"_CNT_",?+1,",1.2)=FLNAME
	. S C0QNEW(1130580001.2011,"?+"_CNT_",?+1,",2.2)=FLNAME
	;
	; File Data.
	N C0QIEN,C0QERR ; Returned IEN, Error array
	D UPDATE^DIE("E",$NA(C0QNEW),$NA(C0QIEN),$NA(C0QERR))
	I $D(C0QERR) S $EC=",U1,"
	;
	Q C0QIEN(1) ; Quit with IEN for ?+1.
	;
	; SAM(1130580001.201,"17,",.01)="DR OFFICE QM REPORT"
	; SAM(1130580001.201,"17,",.02)="AUG 1,2012"
	; SAM(1130580001.201,"17,",.03)="OCT 31,2012"
	; SAM(1130580001.201,"17,",.04)=""
	; SAM(1130580001.201,"17,",.05)=""
	; SAM(1130580001.201,"17,",.2)=""
	; SAM(1130580001.201,"17,",.3)=""
	; SAM(1130580001.201,"17,",.4)=""
	; SAM(1130580001.2011,"1,17,",.01)="MU EP NQF 0013"
	; SAM(1130580001.2011,"1,17,",1.1)=1
	; SAM(1130580001.2011,"1,17,",1.2)="MU12-EP-DR OFFICE-Patient"
	; SAM(1130580001.2011,"1,17,",2.1)=1
	; SAM(1130580001.2011,"1,17,",2.2)="MU12-EP-DR OFFICE-Patient"
	; SAM(1130580001.2011,"1,17,",3)=100
	; SAM(1130580001.2011,"2,17,",.01)="MU EP NQF 0028A"
	; SAM(1130580001.2011,"2,17,",1.1)=0
	; SAM(1130580001.2011,"2,17,",1.2)="MU12-EP-DR OFFICE-Patient"
	; SAM(1130580001.2011,"2,17,",2.1)=1
	; SAM(1130580001.2011,"2,17,",2.2)="MU12-EP-DR OFFICE-Patient"
	; SAM(1130580001.2011,"2,17,",3)=0
	; SAM(1130580001.2011,"3,17,",.01)="MU EP NQF 0028B"
	; SAM(1130580001.2011,"3,17,",1.1)=0
	; SAM(1130580001.2011,"3,17,",1.2)="MU12-EP-DR OFFICE-Patient"
	; SAM(1130580001.2011,"3,17,",2.1)=1
	; SAM(1130580001.2011,"3,17,",2.2)="MU12-EP-DR OFFICE-Patient"
	; SAM(1130580001.2011,"3,17,",3)=0
	; SAM(1130580001.2011,"4,17,",.01)="MU EP NQF 0421"
	; SAM(1130580001.2011,"4,17,",1.1)=1
	; SAM(1130580001.2011,"4,17,",1.2)="MU12-EP-DR OFFICE-Patient"
	; SAM(1130580001.2011,"4,17,",2.1)=1
	; SAM(1130580001.2011,"4,17,",2.2)="MU12-EP-DR OFFICE-Patient"
	; SAM(1130580001.2011,"4,17,",3)=100
	; SAM(1130580001.20111,"1,1,17,",.01)="MOUSE,MICKEY"
	; SAM(1130580001.20111,"1,4,17,",.01)="MOUSE,MICKEY"
	; SAM(1130580001.20112,"1,1,17,",.01)="MOUSE,MICKEY"
	; SAM(1130580001.20112,"1,2,17,",.01)="MOUSE,MICKEY"
	; SAM(1130580001.20112,"1,3,17,",.01)="MOUSE,MICKEY"
	; SAM(1130580001.20112,"1,4,17,",.01)="MOUSE,MICKEY"
	; 
