
                          --- KIDS TEXT ----
Created by Sam Habiel on Thursday 12 April 2011 for WorldVistA.

                            --- WARNING ---
If you install the KIDS build produced by this tool on a production system 
containing pharmacy patient data, you will cause database corruption and 
jeopardize patient safety. 
                            --- WARNING ---

This KIDS Build transports the following files from a source system to a 
destination system and then syncs CPRS OE/RR files with the new files.
 ; ^PSDRUG      DRUG
 ; ^PS(50.7)    PHARMACY ORDERABLE ITEM
 ; ^PS(51.7)    DRUG TEXT
 ; ^PS(52.6)    IV ADDITIVES
 ; ^PS(52.7)    IV SOLUTIONS
 ; ^PS(50.4)    DRUG ELECTROLYTES

Workflow (using KIDS):
 ; On the Origin System:
 ; - Create a KIDS build that calls the following:
 ;  1. VWPSSXPD to call from top is the Environment Check for the 
 ;     Build
 ;  2. PRE^VWPSSXPD is the Pre-Init for the Destination System
 ;  3. POST^VWPSSXPD is the Post-Init for the Destination System
 ;  4. TRAN^VWPSSXPD is the Pre-Transport Routine for your originating system drug data
 ; - Generate the KIDS Build. The file will have all the Drug Data from the 
 ;   Origin System.
 ;
 ; On the Destination System:
 ; - Install the KIDS Build
 
The entry points in the attached routine (VWPSSXPD) can be used by
themselves to remove an old drug file and add a new one.

Documentation for using the Drug File updating utility WITH and WITHOUT KIDS 
can be found in VWPSSXPD.m.

KIDS file contains this routine plus a sample drug file to be installed 
into a destination system.

                          --- END KIDS TEXT ----
License is AGPL.

Author is Sam Habiel for WorldVistA.

Limitations/Ideas for Future Development:
- Not sure if the MEDICATION ROUTES should be transmitted or not. While 
  additions are allowed, they are by my experience uncommon.
- Many reference files (e.g. PACKAGE SIZE or DRUG UNITS) are not part of the 
  NDF, yet they are not user modifiable. Yet, they are referenced almost 
  exclusively from the National Drug Files; which means that they cannot be 
  changed without corrupting the NDF data. I am trying to find documentation 
  to say that they are standard.
- If the Administration Schedules from the originating system and destination
  system don't match, you need to either change the schedules on the orderable
  items, or make the schedules on the destination system the same as the
  ones from incoming drug file, otherwise, the problems you run into is this:
  - Orders do not calculate frequency correctly if the schedule is not present
    in the destination system. This means that the proper number of pills 
    cannot be calculated.
  - In Outpatient Pharmacy, Schedules do not expand into patient readable
    instructions
- If the National Drug Files are not up to date in the destination system, 
  there will be some broken pointers. All you have to do is update the NDF with 
  the latest patches.
- If some drugs are linked with lab tests, these need to be re-linked. 
  Preferably, these should be removed prior to transporting the drug file.


Remarks on Broken Pointers in Destination Systems as a result of using this 
package:
Because many files point to the Pharmacy Orderable Item and Drug files, you 
practically cannot use this package on a database that contains patient-
specific pharmacy data since all data will be corrupted.

When installing a new drug and pharmacy orderable item file, the following may 
be broken:
For Drug File:
- LAB TEST MONITOR field.
- SPECIMEN TYPE field.
- CLOZAPINE LAB TEST:LAB TEST MONITOR field
- CLOZAPINE LAB TEST:SPECIMEN TYPE field
- ATC CANISTER:WARD GROUP FOR CANISTER
- ACTIVITY LOG:INITIATOR OF ACTIVITY (field not used currently)
- NDC BY OUTPATIENT SITE:OUTPATIENT SITE
- IFCAP ITEM NUMBER:ITEM NUMBER (field not used currently)
- Custom UNIT DOSE MED ROUTE (field not used currently)
- NATIONAL DRUG FILE ENTRY (if you don't have a recently patched NDF)
- PSNDF VA PRODUCT NAME ENTRY (if you don't have a recently patched NDF).

For Pharmacy Orderable Item File:
- MEDICATION ROUTES (additions are allowed, not deletions)

The National Drug Files are Standardized. However, a system may be out of date. 
If you do not have the latest National Drug Files, you have will broken 
pointers if the source of your drug files has a more recent National Drug File. 
For best results, the source system and the destination system should have a 
commensurate NDF patch level.

To check for broken pointers, use the VERIFY FIELDs option in Fileman.
Here is an example of a drug file from a patched system installed on a system
that is not patched:

==============================================================================
GTM>D P^DI


VA FileMan 22.0


Select OPTION:    UTILITY FUNCTIONS
Select UTILITY OPTION:    VERIFY FIELDS

MODIFY WHAT FILE: DRUG//  
VERIFY WHICH FIELD:    PSNDF VA PRODUCT NAME ENTRY

DEVICE: HOME// 

VERIFY FIELDS REPORT
DRUG FILE (#50)                                   APR 16, 2012  12:40    PAGE 1
-------------------------------------------------------------------------------
   POINTER
(CANNOT CHECK CROSS-REFERENCE)

ENTRY#    GENERIC NAME                  ERROR
148       GUANFACINE 1MG TAB ER         No '21739' in pointed-to File
149       GUANFACINE 2MG TAB ER         No '21740' in pointed-to File
168       LURASIDONE 40MG TAB           No '22028' in pointed-to File
169       LURASIDONE 80MG TAB           No '22030' in pointed-to File
221       LEVONORGESTREL 1.5MG TAB      No '21157' in pointed-to File
450       LIDOCAINE 5% PATCH            No '22004' in pointed-to File
456       NEOMYCIN/POLYMYXIN/BACITRACIN OINT No '21497' in pointed-to File
485       MICONAZOLE 4% VAGINAL CREAM   No '22325' in pointed-to File
585       PALIPERIDONE 234MG INJ SUSP PFSNo '21021' in pointed-to File
586       PALIPERIDONE 156MG INJ SUSP PFSNo '21022' in pointed-to File
==============================================================================

Below you will find the pointer relations of all the files that are transmitted in this KIDS build.

    File/Package: DRUG                                               Date: APR 12,2012

  FILE (#)                                            POINTER           (#) FILE
   POINTER FIELD                                       TYPE           POINTER FIELD              FILE POINTED TO
------------------------------------------------------------------------------------------------------------------------------------
          L=Laygo      S=File not in set      N=Normal Ref.      C=Xref.
          *=Truncated      m=Multiple           v=Variable Pointer

                                                                  -------------------------------
  DRUG (#50)                                                      |                             |
    CORRESPONDING OUTPATIENT DRUG ..................  (N )->      |  50 DRUG                    |
    CORRESPONDING INPATIENT DRUG ...................  (N )->      |   PHARMACY ORDERABLE ITEM   |-> PHARMACY ORDERABLE ITEM (inc)
    FORMULARY ALTERNATIVE ..........................  (N C )->    |   ORDER UNIT                |-> ORDER UNIT (only modifiable 
                                                                                                       from FM, possibly standard)
  DUE QUESTIONNAIRE (#50.07301)                                   |                             |
    DRUG ...........................................  (N S C )->  |   LAB TEST MONITOR          |-> LABORATORY TEST (possible brok pt)
  DUE ANSWER SHEET (#50.0731)                                     |                             |
    DRUG ...........................................  (N S C )->  |   SPECIMEN TYPE             |-> TOPOGRAPHY FIELD (possible break)
  IV CATEGORY (#50.21)                                            |                             |
    IV DRUG:GENERIC DRUG ...........................  (N S )->    |   NATIONAL DRUG FILE ENTRY  |-> VA GENERIC (standard)
  DRUG COST (#50.9002)                                            |                             |
    PHYSICIAN DATA:DRUG ............................  (N S )->    |   PSNDF VA PRODUCT NAME EN* |-> VA PRODUCT (standard)
    DRUG DATA:DRUG .................................  (N S )->    |   PACKAGE SIZE              |-> PACKAGE SIZE (only mod from FM)
                                                                                                                 (possibly standard)
    DIVISION DATA:DRUG DATA:DRUG ...................  (N S )->    |   PACKAGE TYPE              |-> PACKAGE TYPE (only mod from FM)
                                                                                                                 (possibly standard)
  PRESCRIPTION (#52)                                              |                             |
    DRUG ...........................................  (N S C )->  |   NATIONAL DRUG CLASS       |-> VA DRUG CLASS (standard)
  PENDING OUTPATIENT O (#52.41)                                   |                             |
    DRUG ...........................................  (N S )->    |   UNIT DOSE MED ROUTE       |-> MEDICATION ROUTES (addable)
  IV ADDITIVES (#52.6)                                            |                             |
    GENERIC DRUG ...................................  (N S C )->  |   CORRESPONDING OUTPATIENT* |-> DRUG (this file)
  IV SOLUTIONS (#52.7)                                            |                             |
    GENERIC DRUG ...................................  (N S C )->  |   *PRIMARY DRUG             |-> PRIMARY DRUG (not used)
  NON-VERIFIED ORDERS (#53.1)                                     |                             |
    SOLUTION .......................................  (N S )->    |   UNIT                      |-> DRUG UNITS (only mod from FM)
                                                                                                               (possibly standard)
    DISPENSE DRUG ..................................  (N S )->    |   CORRESPONDING INPATIENT * |-> DRUG (this file)
  UNIT DOSE ORDER SET (#53.2102)                                  |                             |
    *DRUG:*DISPENSE DRUG ...........................  (N S C )->  |   *LAB TEST MONITOR         |-> LABORATORY TEST (not used)
    ORDERABLE ITEM:DISPENSE DRUG ...................  (N S )->    |   *SPECIMEN TYPE            |-> TOPOGRAPHY FIELD (not used)
  INPATIENT USER PARAM (#53.4502)                                 |                             |
    DISPENSE DRUG ..................................  (N S C )->  | m CLOZAPINE L:LAB TEST MO*  |-> LABORATORY TEST (broken)
  BCMA MISSING DOSE RE (#53.68)                                   |                             |
    DRUG REQUESTED .................................  (N S )->    |   CLOZAPINE L:SPECIMEN TY*  |-> TOPOGRAPHY FIELD (broken)
  BCMA UNABLE TO SCAN  (#53.771)                                  |                             |
    DISPENSE DRUG ..................................  (N S C )->  | m ATC CANISTE:WARD GROUP *  |-> WARD GROUP (site specific)
  BCMA MEDICATION VARI (#53.78)                                   |                             |
    DRUG SCANNED ...................................  (N S )->    |   ACTIVITY LO:INITIATOR O*  |-> NEW PERSON (not used)
  BCMA MEDICATION LOG (#53.795)                                   |                             |
    DISPENSE DRUG ..................................  (N S C )->  |   NDC BY OUTP:OUTPATIENT *  |-> OUTPATIENT SITE (site specific)
  PHARMACY PATIENT (#55.05)                                       |                             |
    NON-VA MEDS:DISPENSE DRUG ......................  (N S )->    | m DRUG TEXT E:DRUG TEXT E*  |-> DRUG TEXT (included)
    UNIT DOSE:*SOLUTION ............................  (N S )->    | m IFCAP ITEM :ITEM NUMBER*  |-> ITEM MASTER (WV empty file)
    UNIT DOSE:DISPENSE LOG:DISPENSE DRUG ...........  (N S )->    | m FORMULARY A:FORMULARY A*  |-> DRUG (this file)
    UNIT DOSE:DISPENSE DRUG ........................  (N S )->    |                             |
  UNIT DOSE PICK LIST  (#57.63)                                   |                             |
    WARD:PROVIDER:DRUG .............................  (N S )->    |                             |
  PHARMACY AOU STOCK (#58.11)                                     |                             |
    ITEM ...........................................  (N S )->    |                             |
  PHARMACY BACKORDER (#58.3)                                      |                             |
    ITEM ...........................................  (N S C )->  |                             |
  AR/WS STATS FILE (#58.52)                                       |                             |
    INPATIENT SITE:RECALCULATE AMIS:DRUG ...........  (N S )->    |                             |
  DRUG ACCOUNTABILITY  (#58.8001)                                 |                             |
    DRUG ...........................................  (N S C )->  |                             |
  DRUG ACCOUNTABILITY  (#58.81)                                   |                             |
    DRUG ...........................................  (N S )->    |                             |
  DRUG ACCOUNTABILITY  (#58.81125)                                |                             |
    INVOICE DATA:LINE ITEM DATA:DRUG ...............  (N S )->    |                             |
  CS WORKSHEET (#58.85)                                           |                             |
    DRUG ...........................................  (N S )->    |                             |
  CS DESTRUCTION (#58.86)                                         |                             |
    DRUG ...........................................  (N S )->    |                             |
    PRICE PER DISPENSE UNIT ........................  (N S )->    |                             |
  CS CORRECTION LOG (#58.87)                                      |                             |
    DRUG ...........................................  (N S )->    |                             |
  OUTPATIENT SITE (#59)                                           |                             |
    METHADONE DRUG .................................  (N S )->    |                             |
  PHARMACY SYSTEM (#59.7)                                         |                             |
    LAST DRUG CONVERTED ............................  (N S )->    |                             |
    LAST DRUG LINKED ...............................  (N S )->    |                             |
  RAD/NUC MED PATIENT (#70.15)                                    |                             |
    REGISTERE:EXAMINATION:MEDICATIONS:MED ADMINIS* .  (N S )->    |                             |
  NUC MED EXAM DATA (#70.21)                                      |                             |
    RADIOPHARMACEUTICALS:RADIOPHARMACEUTICAL .......  (N S )->    |                             |
  RAD/NUC MED PROCEDUR (#71.055)                                  |                             |
    DEFAULT MEDICATIONS:DEFAULT MEDICATION .........  (N S C )->  |                             |
    DEFAULT RADIOPHARMACEU:DEFAULT RADIOPHARMACEUTI*  (N S )->    |                             |
  RADIOPHARMACEUTICAL  (#71.9)                                    |                             |
    RADIOPHARM .....................................  (N S )->    |                             |
  ORDER STATISTICS (#100.1)                                       |                             |
    NAME v ...........................................(N S C L)-> |                             |
  PATIENT ALLERGIES (#120.8)                                      |                             |
    GMR ALLERGY v ....................................(N S L)->   |                             |
  SURGERY (#130.33)                                               |                             |
    MEDICATIONS ....................................  (N S )->    |                             |
    ANESTHESIA TECHNIQUE:ANESTHESIA AGENTS .........  (N S )->    |                             |
    ANESTHESIA TECHNIQUE:TEST DOSE .................  (N S )->    |                             |
  FEE BASIS PHARMACY I (#162.11)                                  |                             |
    PRESCRIPTION NUMBER:GENERIC DRUG ...............  (N S )->    |                             |
  TRANSFER PRICING TRA (#351.61)                                  |                             |
    DRUG ...........................................  (N S )->    |                             |
  IB BILL/CLAIMS PRESC (#362.4)                                   |                             |
    DRUG ...........................................  (N S )->    |                             |
  SECLUSION/RESTRAINT (#615.23)                                   |                             |
    MEDICATIONS ....................................  (N S )->    |                             |
  MEDICATION (#695)                                               |                             |
    GENERIC NAME ...................................  (N S C )->  |                             |
  GENERALIZED PROCEDUR (#699.53)                                  |                             |
    MEDICATIONS ....................................  (N S )->    |                             |
  ENDOSCOPY/CONSULT (#699.74)                                     |                             |
    PRESCRIPTION GIVEN .............................  (N S )->    |                             |
  UNIT DOSE LOCAL EXTR (#727.809)                                 |                             |
    BCMA DRUG DISPENSED ............................  (N S )->    |                             |
  IV DETAIL EXTRACT (#727.819)                                    |                             |
    BCMA DRUG DISPENSED ............................  (N S )->    |                             |
  IV EXTRACT DATA (#728.113)                                      |                             |
    DRUG ...........................................  (N S )->    |                             |
  UNIT DOSE EXTRACT DA (#728.904)                                 |                             |
    DRUG ...........................................  (N S )->    |                             |
  ROR REGISTRY PARAMET (#798.129)                                 |                             |
    LOCAL DRUG NAME ................................  (N S C )->  |                             |
  REMINDER FINDING ITE (#801.43)                                  |                             |
    FINDING ITEM v ...................................(N S L)->   |                             |
  REMINDER EXTRACT SUM (#810.31)                                  |                             |
    EXTRACT FINDINGS:FINDING ITEM v ..................(N S L)->   |                             |
    LREPI FINDING TOTALS:FINDING ITEM v ..............(N S L)->   |                             |
  REMINDER TERM (#811.52)                                         |                             |
    FINDINGS:FINDING ITEM v ..........................(N S L)->   |                             |
  REMINDER DEFINITION (#811.902)                                  |                             |
    FINDINGS:FINDING ITEM v ..........................(N S C L)-> |                             |
  APSP INTERVENTION (#9009032.4)                                  |                             |
    DRUG ...........................................  (N S )->    |                             |
                                                                  -------------------------------

    File/Package: PHARM ORD ITEM                                     Date: APR 12,2012

  FILE (#)                                            POINTER           (#) FILE
   POINTER FIELD                                       TYPE           POINTER FIELD              FILE POINTED TO
------------------------------------------------------------------------------------------------------------------------------------
          L=Laygo      S=File not in set      N=Normal Ref.      C=Xref.
          *=Truncated      m=Multiple           v=Variable Pointer

                                                                  -------------------------------
  DRUG (#50)                                                      |                             |
    PHARMACY ORDERABLE ITEM ........................  (N S C L)-> |  50.7 PHARMACY ORDERABLE I* |
  PRESCRIPTION (#52)                                              |                             |
    PHARMACY ORDERABLE ITEM ........................  (N S )->    |   DOSAGE FORM               |-> DOSAGE FORM (file locked down)
  PENDING OUTPATIENT O (#52.41)                                   |                             |
    PHARMACY ORDERABLE ITEM ........................  (N S )->    |   MED ROUTE                 |-> MEDICATION ROUTES (addable)
  IV ADDITIVES (#52.6)                                            |                             |
    PHARMACY ORDERABLE ITEM ........................  (N S C )->  | m DIVISION/SI:DIVISION/SI*  |-> OUTPATIENT SITE (not used)
  IV SOLUTIONS (#52.7)                                            |                             |
    PHARMACY ORDERABLE ITEM ........................  (N S C L)-> | m OI-DRUG TEX:OI-DRUG TEX*  |-> DRUG TEXT (used -- included)
  NON-VERIFIED ORDERS (#53.1)                                     |                             |
    ORDERABLE ITEM .................................  (N S )->    |                             |
  UNIT DOSE ORDER SET (#53.22)                                    |                             |
    ORDERABLE ITEM .................................  (N S )->    |                             |
  PICK LIST (#53.52)                                              |                             |
    PATIENT:ORDER:ORDERABLE ITEM ...................  (N S )->    |                             |
  BCMA MEDICATION LOG (#53.79)                                    |                             |
    ADMINISTRATION MEDICATION ......................  (N S )->    |                             |
  PHARMACY PATIENT (#55.01)                                       |                             |
    IV:ORDERABLE ITEM ..............................  (N S )->    |                             |
    NON-VA MEDS:ORDERABLE ITEM .....................  (N S )->    |                             |
    UNIT DOSE:ORDERABLE ITEM .......................  (N S )->    |                             |
                                                                  -------------------------------

    File/Package: DRUG TEXT                                          Date: APR 16,2012

  FILE (#)                                            POINTER           (#) FILE
   POINTER FIELD                                       TYPE           POINTER FIELD              FILE POINTED TO
------------------------------------------------------------------------------------------------------------------------------------
          L=Laygo      S=File not in set      N=Normal Ref.      C=Xref.
          *=Truncated      m=Multiple           v=Variable Pointer

                                                                  -------------------------------
  DRUG (#50.037)                                                  |                             |
    DRUG TEXT ENTRY ................................  (N S C )->  |  51.7 DRUG TEXT             |
  PHARMACY ORDERABLE I (#50.76)                                   |                             |
    OI-DRUG TEXT ENTRY .............................  (N S )->    |                             |
                                                                  -------------------------------

    File/Package: IV FILES                                           Date: APR 16,2012

  FILE (#)                                            POINTER           (#) FILE
   POINTER FIELD                                       TYPE           POINTER FIELD              FILE POINTED TO
------------------------------------------------------------------------------------------------------------------------------------
          L=Laygo      S=File not in set      N=Normal Ref.      C=Xref.
          *=Truncated      m=Multiple           v=Variable Pointer

                                                                  -------------------------------
  IV ADDITIVES (#52.62)                                           |                             |
    ELECTROYLTES:ELECTROLYTE .......................  (N )->      |  50.4 DRUG ELECTROLYTES     |
  IV SOLUTIONS (#52.702)                                          |                             |
    ELECTROLYTES ...................................  (N )->      |                             |
                                                                  -------------------------------
                                                                  -------------------------------
  IV CATEGORY (#50.2)                                             |                             |
    IV DRUG v ........................................(N S L)->   |  52.6 IV ADDITIVES          |
    IV DRUG v ........................................(N S L)->   |   GENERIC DRUG              |-> DRUG
  NON-VERIFIED ORDERS (#53.157)                                   |                             |
    ADDITIVE .......................................  (N S C )->  |   PHARMACY ORDERABLE ITEM   |-> PHARMACY ORDERABLE ITEM
  BCMA MISSING DOSE RE (#53.686)                                  |                             |
    ADDITIVES ......................................  (N S C )->  |   *PRIMARY DRUG             |-> PRIMARY DRUG
  BCMA UNABLE TO SCAN  (#53.7711)                                 |                             |
    ADDITIVE .......................................  (N S C )->  |   QUICK CODE:USUAL IV SO*   |-> IV SOLUTIONS
  BCMA MEDICATION LOG (#53.796)                                   |                             |
    ADDITIVES ......................................  (N S C )->  |   QUICK CODE:MED ROUTE      |-> MEDICATION ROUTES
  PHARMACY PATIENT (#55.02)                                       |                             |
    IV:ADDITIVE ....................................  (N S )->    | m ELECTROYLTES:ELECTROLYTE  |-> DRUG ELECTROLYTES
    BCMA ID:ADDITIVE ...............................  (N S )->    |                             |
  PHARMACY QUICK ORDER (#57.17)                                   |                             |
    ADDITIVE .......................................  (N S )->    |                             |
                                                                  -------------------------------
                                                                  -------------------------------
  IV CATEGORY (#50.2)                                             |                             |
    IV DRUG v ........................................(N S L)->   |  52.7 IV SOLUTIONS          |
    IV DRUG v ........................................(N S L)->   |   GENERIC DRUG              |-> DRUG
  IV ADDITIVES (#52.61)                                           |                             |
    QUICK CODE:USUAL IV SOLUTION ...................  (N )->      |   PHARMACY ORDERABLE ITEM   |-> PHARMACY ORDERABLE ITEM
  NON-VERIFIED ORDERS (#53.158)                                   |                             |
    SOLUTION .......................................  (N S C )->  |   *PRIMARY DRUG             |-> PRIMARY DRUG
  BCMA MISSING DOSE RE (#53.687)                                  |                             |
    SOLUTIONS ......................................  (N S C )->  | m ELECTROLYTES:ELECTROLYTES |-> DRUG ELECTROLYTES
  BCMA UNABLE TO SCAN  (#53.7712)                                 |                             |
    SOLUTIONS ......................................  (N S C )->  |                             |
  BCMA MEDICATION LOG (#53.797)                                   |                             |
    SOLUTIONS ......................................  (N S C )->  |                             |
  PHARMACY PATIENT (#55.1058)                                     |                             |
    BCMA ID:SOLUTION ...............................  (N S )->    |                             |
    IV:SOLUTION ....................................  (N S )->    |                             |
  PHARMACY QUICK ORDER (#57.18)                                   |                             |
    SOLUTION .......................................  (N S )->    |                             |
                                                                  -------------------------------

