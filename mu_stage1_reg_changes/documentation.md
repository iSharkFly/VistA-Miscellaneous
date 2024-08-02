# Stage 1 Meaningful Use enhancements for Patient Registration for WV
NB: This works in conjunction with the new language file. See \[Language File(\].

# Transported fields
	                                           UP    SEND  DATA                USER
	                                           DATE  SEC.  COMES   SITE  RSLV  OVER
	FILE #      FILE NAME                      DD    CODE  W/FILE  DATA  PTRS  RIDE
	-------------------------------------------------------------------------------
	
	2           PATIENT                        YES   NO    NO                  NO
	Partial DD: subDD: 2          fld: .351     (DATE OF DEATH, transported for xrefs)
	                              fld: 250043.1 (PRELIMINARY CAUSE OF DEATH)
	                              fld: 256000   (LANGUAGE PREFERENCE)
	            subDD: 2.0256001 (LANGUAGE SKILLS SUB-FIELD)
	
	200         NEW PERSON                     YES   NO    NO                  NO
	Partial DD: subDD: 200        fld: 256000   (PREFERRED LANGUAGE)
	            subDD: 200.0256001 (LANGUAGE SKILLS SUB-FIELD)


## Language and Interpreter Language
The routines `DG10`, `DGREG`, and `DGPMV` have been modifed to call `D REGMU^VWUTIL` for patients. This routine calls edits fields using the input template `VW LOCAL REGISTRATION TEMPLATE`. The routines correspond to the 3 ways you can enter a patient into VISTA.

* DG REGISTER PATIENT		Register a Patient		DGREG
* DG LOAD PATIENT DATA		Load/Edit Patient Data	DG10
* DG ADMIT PATIENT			Admit a Patient			DGPMV

The post-install routine POST^VWREGPI adds the input template `VW LOCAL REGISTRATION TEMPLATE` to field REGISTRATION TEMPLATE (LOCAL) in file MAS PARAMETERS. This shows the language questions in the 10/10 form processor (DGRP).

The routine VWUTIL gets called to do the ^DIE call to VW LOCAL REGISTRATION TEMPLATE. It's therefore shipped.

The routine ORCXPND1 was modified to display Language Preference from the Patient File.

The routine DGRP2 was modified to correct the display of Interpreter Language. Previously it got the language text from field 1, but in the new language file, the appropriate field is .01.

## Preliminary Cause of Death
* The routine DGDEATH now asks for the Preliminary Cause of Death if a Date of Death is entered. If the date of death is not entered or deleted, the preliminary cause of death is not asked.
* The Date of Death field in the patient file has a Mumps type cross-reference that deletes the preliminary cause of death if the date of death is modified or deleted.
* The routine DGRPD in RMKff was modified to display Preliminary Cause of Death.
* The VW ENTER PRELIM CAUSE OF DEATH is a new menu option off the DG BED CONTROL menu. For discharged patients who are discharged as DEAD, this menu option allows you to enter a Preliminary Cause of Death. The reason this menu option is not on DG REGISTRATION MENU as well is that DG REGISTRATION MENU already includes the menu option DG DEATH ENTRY, which will call routine DGDEATH.
