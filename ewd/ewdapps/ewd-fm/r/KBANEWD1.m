KBANEWD1 ; KBAN/SMH - Custom Tag Processor ; 8/14/11 9:08pm
 ;;
SS(nodeOID,attrValues,docOID,technology) ; <fm:session /> to get VISTA Session Variables
 N attr
 S attr("method")="SS2^KBANEWD1"
 S attr("param1")="#ewd_sessid"
 S attr("type")="procedure"
 N xOID s xOID=$$addElementToDOM^%zewdDOM("ewd:execute",nodeOID,"",.attr)
 D removeIntermediateNode^%zewdDOM(nodeOID)
 quit
SS2(sessid)
 d mergeArrayFromSession^%zewdAPI(.DUZ,"DUZ",sessid)
 d mergeArrayFromSession^%zewdAPI(.IO,"IO",sessid)
 s U=$$getSessionValue^%zewdAPI("U",sessid)
 quit
EDIT(nodeOID,attrValues,docOID,technology) ; Fileman Field Edit tag
 ; Get Attributes supplied to us: dd, fields, iens
 ;
 N attrs
 D getAttributeValues^%zewdCustomTags(nodeOID,.attrs)
 N DD S DD=$g(attrs("dd")) ; Data Dictionary
 N FIELDS S FIELDS=$g(attrs("fields")) ; Fields to Edit
 N IENS S IENS=$g(attrs("iens")) ; IENs to Edit
 ;
 ; Does our Form Tag Exist?
 N fOID S fOID=$$getElementById^%zewdDOM("fmEdit",docOID)
 ; -----
 ; If it doesn't exist, create it
 IF fOID="" DO
 . ; Create the Form Tag
 . ; Attributes
 . N attr
 . S attr("name")="fmEdit"
 . S attr("id")="fmEdit"
 . S attr("action")="ewd"
 . S attr("method")="post"
 . ;
 . ; Add form
 . S fOID=$$addElementToDOM^%zewdDOM("form",nodeOID,"",.attr,"")
 ; -----
 ; Destination Input Name
 N dst S dst="DD"_$TR(DD,".","_")_"F"_$TR(FIELDS,".","_")
 ;
 ; Build <ewd:execute> to set the value of the default; child of form in fOID
 K attr
 S attr("method")="XTARGET^KBANEWD1"
 S attr("param1")="#ewd_sessid"
 S attr("param2")=dst
 S attr("param3")=DD
 S attr("param4")=$$stripSpaces^%zewdAPI(phpVars($P(IENS,"&php;",2))) ; becomes #DUZ
 S attr("param5")=FIELDS
 S attr("type")="procedure"
 N xOID s xOID=$$addElementToDOM^%zewdDOM("ewd:execute",fOID,"",.attr)
 ;
 ; Add label
 N text S text=$$GET1^DID(DD,FIELDS,"","LABEL")  ; this should be i18n in MSC FM
 S text=text_": "
 K attr S attr("for")=dst
 N lOID s lOID=$$addElementToDOM^%zewdDOM("label",fOID,"",.attr,text)
 ; ------------
 ;
 ; Add Input Tag
 ; Attributes
 K attr
 S attr("type")="text"  ; Should be dynamic based on FM DataType
 S attr("name")=dst
 S attr("value")="*"
 ;
 ; Add input Tag under form tag
 N iOID S iOID=$$addElementToDOM^%zewdDOM("input",fOID,"",.attr,"")
 ;
 ; Remove custom tag
 D removeIntermediateNode^%zewdDOM(nodeOID)
 ;break
 QUIT
 ;
 ; ---
 ;
XTARGET(sessid,fieldName,DD,IENS,FIELDS) ; Proc - Xecute Target - Adds Default Value to Sess
 N VAL S VAL=$$GET1^DIQ(DD,IENS,FIELDS)
 D setSessionValue^%zewdAPI(fieldName,VAL,sessid)
 QUIT
 ;
 ; ---
 ;
VAL(sessid)
 D setSessionValue^%zewdAPI("tmp.error","Null Validation",sessid)
 D setSessionValue^%zewdAPI("tmp.name","testdiv",sessid) ; testdiv hardcoded for now.
 N KBANDD S KBANDD=+$TR($P(requestArray("name"),"DD",2),"_",".")  ; todo: check for 0 value
 N KBANF S KBANF=+$TR($P(requestArray("name"),"F",2),"_",".")     ; todo: check for 0 value
 N KBANIENS S KBANIENS=requestArray("iens")
 I $E(KBANIENS,$L(KBANIENS))'="," S KBANIENS=KBANIENS_","
 N KBANV S KBANV=requestArray("value")   ; todo: unescape urlencoding.
 N KBANRESULT ; Result
 N KBANMSG
 D VAL^DIE(KBANDD,KBANIENS,KBANF,"E",KBANV,.KBANRESULT,"","KBANMSG")
 I $D(KBANMSG) K ^ZZSAM M ^ZZSAM=KBANMSG
 ; KBANMSG(DIERR,1,TEXT,1) can be longer than one line (last subscript)... loop...
 ; HTML formatting for error message???
 I KBANRESULT="^" D setSessionValue^%zewdAPI("tmp.error",KBANMSG("DIERR",1,"TEXT",1),sessid)
 E  D
 . D setSessionValue^%zewdAPI("tmp.result","Success in Validating: "_$$SYMENC^MXMLUTL($$SYMENC^MXMLUTL(KBANRESULT(0))),sessid)
 . D setSessionValue^%zewdAPI("tmp.error","",sessid)
 QUIT ""
