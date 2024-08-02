The following routines should be applied to WV 2.0 in order to install a new language file for use in Meaningful Use Stages 1 and 2.

More detailed documentation can be found on:
http://www.vistapedia.com/index.php/Language_File_%28.85%29

## Warning
DO NOT INSTALL THIS OVER MSC FILEMAN. THE NEW LANGUAGE FILE WILL BE PART OF THE SUCCESSOR OF MSC FILEMAN, FILEMAN V22.2.

## Getting the software
Download: 

## Installation Instructions
1. Import the routines from the file system using your Mumps implementation's Routine Input from RO format utility.
2. Run ^DINIT. Answer Yes to all Yes/No questions if unsure how to answer.
3. Run ^DMLAINIT. Answer Yes to all Yes/No questions.

### Example Install Transcript

	MU-beta>D ^%RI

	Routine Input Utility - Converts RO file to *.m files.

	Formfeed delimited <No>? 
	Input device: <terminal>: /home/sam/repo/lang/lang-file4mu1and2/VW-LanguageFiles-DMLAINITs-DINITs-2012-11-20.ro

	Lang file inits. Run ^DINIT first and then ^DMLAINITs.
	GT.M 20-NOV-2012 19:44:28


	Output directory : r/

	DINIT     DINIT011  DINIT012  DINIT013  DMLAI001  DMLAI002  DMLAI003  DMLAI004  
	DMLAI005  DMLAI006  DMLAI007  DMLAINI1  DMLAINI2  DMLAINI3  DMLAINI4  DMLAINI5  
	DMLAINIT  

	
	GTM>D ^DINIT
	
	
	VA FileMan V.22.0
	
	
	Initialize VA FileMan now?  NO//Y
	
	SITE NAME: Vista-Office EHR// 
	
	SITE NUMBER: 50// ..........................
	
	Now loading MUMPS Operating System File
	
	Do you want to change the MUMPS OPERATING SYSTEM File? NO//....
	
	Now loading DIALOG and LANGUAGE Files..............................................................
	
	
	TYPE OF MUMPS SYSTEM YOU ARE USING: GT.M(UNIX)//   
	
	Now loading other FileMan files--please wait..........................................................................................
	.............................................................................................................................
	..........
	
	The following files have been installed:
	   .11     INDEX
	   .2      DESTINATION
	   .31     KEY
	   .4      PRINT TEMPLATE
	   .401    SORT TEMPLATE
	   .402    INPUT TEMPLATE
	   .403    FORM
	   .404    BLOCK
	   .44     FOREIGN FORMAT
	   .46     IMPORT TEMPLATE
	   .5      FUNCTION
	   .6      DD AUDIT
	   .7      MUMPS OPERATING SYSTEM
	   .81     DATA TYPE
	   .83     COMPILED ROUTINE
	   .84     DIALOG
	   .85     LANGUAGE
	  1        FILE
	  1.1      AUDIT
	  1.11     ARCHIVAL ACTIVITY
	  1.12     FILEGRAM HISTORY
	  1.13     FILEGRAM ERROR LOG
	  1.2      ALTERNATE EDITOR
	  1.521    SQLI_SCHEMA
	  1.52101  SQLI_KEY_WORD
	  1.5211   SQLI_DATA_TYPE
	  1.5212   SQLI_DOMAIN
	  1.5213   SQLI_KEY_FORMAT
	  1.5214   SQLI_OUTPUT_FORMAT
	  1.5215   SQLI_TABLE
	  1.5216   SQLI_TABLE_ELEMENT
	  1.5217   SQLI_COLUMN
	  1.5218   SQLI_PRIMARY_KEY
	  1.5219   SQLI_FOREIGN_KEY
	  1.52191  SQLI_ERROR_TEXT
	  1.52192  SQLI_ERROR_LOG
	
	
	Re-indexing entries in the DIALOG file......................
	
	Compiling all forms ...
	
	   DICATT                          (#.001)
	   DIPTED                          (#.1001)
	   DIKC EDIT                       (#.1101)
	   DIKC EDIT UI                    (#.1102)
	   DIKK EDIT                       (#.3101)
	   DIBTED                          (#.40001)
	   DIETED                          (#.40101)
	   DIEDIT                          (#.40201)
	   DDGF BLOCK EDIT                 (#.40301)
	   DDGF PAGE ADD                   (#.40302)
	   DDGF PAGE EDIT                  (#.40303)
	   DDGF PAGE SELECT                (#.40304)
	   DDGF FORM EDIT                  (#.40305)
	   DDGF HEADER BLOCK EDIT          (#.40306)
	   DDGF FIELD ADD                  (#.40401)
	   DDGF FIELD CAPTION ONLY         (#.40402)
	   DDGF FIELD DD                   (#.40403)
	   DDGF FIELD FORM ONLY            (#.40404)
	   DDGF FIELD COMPUTED             (#.40405)
	   DDGF BLOCK ADD                  (#.40406)
	   DDGF BLOCK DELETE               (#.40407)
	   DDGF HEADER BLOCK SELECT        (#.40408)
	   DDXP FF FORM1                   (#.441)
	   DDMP SPECIFY IMPORT             (#.461)
	   XPD EDIT BUILD                  (#1)
	   XUEDIT CHARACTERISTICS          (#2)
	   XUEXISTING USER                 (#3)
	   XUDEVICE MT                     (#4)
	   XUDEVICE SDP                    (#5)
	   XUDEVICE SPL                    (#6)
	   XUDEVICE HFS                    (#7)
	   XUDEVICE CHAN                   (#8)
	   XU OPTION SCHEDULE              (#9)
	   XUSERDEACT                      (#10)
	   XUTM UCI ASSOC                  (#11)
	   XUSITEPARM                      (#12)
	   XUAUDIT                         (#13)
	   XUREACT USER                    (#14)
	   PRSA TD EDIT                    (#15)
	   PRSA OT REQ                     (#16)
	   PRSA TD DISP                    (#17)
	   PRSA TL EDIT                    (#18)
	   PRSA TL DISP                    (#19)
	   PRSA LV REQ                     (#20)
	   PRSA ED REQ                     (#21)
	   PRSA VC POST                    (#22)
	   PRSA PM POST                    (#23)
	   PRSA TD TL                      (#24)
	   PRSA TP POST1                   (#25)
	   PRSA TE EDIT                    (#26)
	   PRSA FEE POST                   (#27)
	   NURA-I-SERVICE                  (#28)
	   XU-PERSON CLASS                 (#29)
	   XUNEW USER                      (#30)
	   SPNLPFM1                        (#31)
	   SPNFFRM1                        (#32)
	   SPNFFRM2                        (#33)
	   SPNLPFM2                        (#34)
	   XPD EDIT MP                     (#35)
	   XPD EDIT GP                     (#36)
	   PRCHQ1                          (#37)
	   PRCHQ2                          (#38)
	   PRCHQ3                          (#39)
	   PRCHQ4                          (#40)
	   PRCHQ5                          (#41)
	   SPNLP FUN MES                   (#42)
	   SPNLP FIM FM1                   (#43)
	   SPNLP CHART FM1                 (#44)
	   SPNLP MS FM1                    (#45)
	   SPNE ENTER/EDIT SYNONYM         (#46)
	   LREPI                           (#47)
	   ENPR MS                         (#48)
	   ENPR ALL                        (#49)
	   ENPR PRELIM                     (#50)
	   ENPR AE                         (#51)
	   ENPR CO                         (#52)
	   ENPR CHG                        (#53)
	   ABSV ADD/EDIT MASTER            (#54)
	   XQEDTOPT                        (#55)
	   XU-INST-EDIT                    (#56)
	   LREPIPROT                       (#57)
	   XUTMKE ADD                      (#58)
	   WV PROC-FORM-1                  (#59)
	   WV NOTIF-FORM-1                 (#60)
	   WV PATIENT-FORM-1               (#61)
	   WV NOTIF-FORM-2                 (#62)
	   WV PROC-FORM-2-COLP             (#63)
	   WV NOTIFPURPOSE-FORM-1          (#64)
	   WV SITE PARAMS-FORM-1           (#65)
	   WV REFUSED PROCEDURE-ENTRY      (#66)
	   WV PROC-FORM-LAB                (#67)
	   XDR RESFILE FORM                (#68)
	   HL SITE PARAMETERS              (#69)
	   PSB PRN EFFECTIVENESS           (#70)
	   PSB MED LOG EDIT                (#71)
	   PSBO DL                         (#72)
	   PSBO WA                         (#73)
	   PSBO ML                         (#74)
	   PSBO MM                         (#75)
	   PSBO PE                         (#76)
	   PSB MISSING DOSE REQUEST        (#77)
	   PSBO MH                         (#78)
	   PSBO MV                         (#79)
	   PSB MISSING DOSE FOLLOWUP       (#80)
	   PSBO BL                         (#81)
	   PSBO MD                         (#82)
	   PSB NEW UD ENTRY                (#83)
	   PSB NEW IV ENTRY                (#84)
	   HL7 APP                         (#85)
	   HL7 LOGICAL LINK                (#86)
	   HL7 INTERFACE                   (#87)
	   SPNLP ASIA MES                  (#88)
	   PSB MED LOG EDIT IV             (#89)
	   SPNLP FAM FM1                   (#90)
	   SPNLP DIENER FM1                (#91)
	   SPNLP DUSOI FM1                 (#92)
	   XU-CLINICAL TRAINEE             (#93)
	   XUSSPKI                         (#94)
	   INSTITUTION EDIT                (#95)
	   PRSA LD POST                    (#96)
	   XUDEVICE LPD                    (#97)
	   XUDEVICE TRM                    (#98)
	   KMPD PARAMETERS EDIT            (#99)
	   LREPI9                          (#100)
	   XUDEVICE RES                    (#101)
	   PSBO BZ                         (#102)
	   ENIT EDIT                       (#103)
	   PXRM DIALOG EDIT                (#104)
	   XUSITEIP                        (#105)
	   PSB BCBU PARAMETERS             (#106)
	   PSBO XA                         (#107)
	   MD MAIN                         (#108)
	   PRSP ESR POST                   (#109)
	   PRSP EXT ABSENCE                (#110)
	
	
	INITIALIZATION COMPLETED IN 8 SECONDS.
	MU-beta>D ^DMLAINIT

	This version (#22.2) of 'DMLAINIT' was created on 20-NOV-2012
		 (at FILEMAN.MUMPS.ORG, by MSC FileMan 22.1043)

	I AM GOING TO SET UP THE FOLLOWING FILES:

	   .85       LANGUAGE  (including data)
	Note:  You already have the 'LANGUAGE' File.
	I will OVERWRITE your data with mine.

	SHALL I WRITE OVER FILE SECURITY CODES? No//   (No) [NB: Can answer either yes or no]

	ARE YOU SURE EVERYTHING'S OK? No// Y  (Yes)

	...HMMM, THIS MAY TAKE A FEW MOMENTS.....................
	OK, I'M DONE.
	NO SECURITY-CODE PROTECTION HAS BEEN MADE

