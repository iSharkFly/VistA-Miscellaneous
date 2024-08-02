ewdu ; JJIH/SMH - Utilities for EWD to VISTA interaction ; 11/18/11 5:39pm
 ;
r(sessid) ; Restore Symbol Table
 d mergeArrayFromSession^%zewdAPI(.DUZ,"DUZ",sessid)
 d mergeArrayFromSession^%zewdAPI(.IO,"IO",sessid)
 s U=$$getSessionValue^%zewdAPI("U",sessid)
 s DILOCKTM=$$getSessionValue^%zewdAPI("DILOCKTM",sessid)
 s DIQUIET=$$getSessionValue^%zewdAPI("DIQUIET",sessid)
 s DISYS=$$getSessionValue^%zewdAPI("DISYS",sessid)
 s DT=$$getSessionValue^%zewdAPI("DT",sessid)
 s DTIME=$$getSessionValue^%zewdAPI("DTIME",sessid)
 quit
 ;
s(sessid) ; Save to Symbol Table
 set DIQUIET=1 d DT^DICRW
 d mergeArrayToSession^%zewdAPI(.DUZ,"DUZ",sessid)
 d mergeArrayToSession^%zewdAPI(.IO,"IO",sessid)
 d setSessionValue^%zewdAPI("U","^",sessid)
 d setSessionValue^%zewdAPI("DILOCKTM",DILOCKTM,sessid)
 d setSessionValue^%zewdAPI("DIQUIET",DIQUIET,sessid)
 d setSessionValue^%zewdAPI("DISYS",DISYS,sessid)
 d setSessionValue^%zewdAPI("DT",DT,sessid)
 d setSessionValue^%zewdAPI("DTIME",DTIME,sessid)
 quit
 ;
 ; Custom Tag
SS(nodeOID,attrValues,docOID,technology) ; <vista:session> to get VISTA Session Variables
 N attr
 S attr("method")="r^ewdu"
 S attr("param1")="#ewd_sessid"
 S attr("type")="procedure"
 N xOID s xOID=$$addElementToDOM^%zewdDOM("ewd:execute",nodeOID,"",.attr)
 D removeIntermediateNode^%zewdDOM(nodeOID)
 quit
 ;
NULL ; Open Null Device
 s %ZIS="0H",IOP="NULL" d ^%ZIS
 i POP s $ec=",U1,"  ; this crashes everything... intended...
 q
 ;
setup(sessid) ; Set-up and SSO
 ; TODO: Set IO("CLNM")
 i '$data(IO) d NULL                  ; Open Null Device
 s IO("IP")=$$getServerValue^%zewdAPI("REMOTE_ADDR",sessid)
 n return
 d SETUP^XUSRB(.return)               ; Set-up and Try SSO
 ;0=server name, 1=volume, 2=uci, 3=device, 4=# attempts, 5=skip signon-screen,6=Domain Name, 7=Production (0=no, 1=Yes)
 i $g(return(5)),DUZ>0 q $$s(sessid)  ; Single Sign-On Successful; need redirect though here.
 e  d  q ""                           ; Otherwise, get INTRO text
 . N INTROTXT
 . D INTRO^XUSRB(.INTROTXT)
 . d mergeArrayToSession^%zewdAPI(.INTROTXT,"so.introtxt",sessid)
 . d setSessionValue^%zewdAPI("so.serverName",return(0),sessid)
 . d setSessionValue^%zewdAPI("so.volume",return(1),sessid)
 . d setSessionValue^%zewdAPI("so.uci",return(2),sessid)
 . ; Don't care about device! (return(3))
 . ; Number of Attempts (return(4))
 . d setSessionValue^%zewdAPI("so.fqdn",return(6),sessid)
 . d setSessionValue^%zewdAPI("so.prod",return(7),sessid)
 . ; 
 . ; Get the Date in the Symbol Table since $$SITE wants it
 . s DIQUIET=1 d DT^DICRW
 . ;
 . ; Get the site name and format it
 . n sitename s sitename=$P($$SITE^VASITE(),"^",2)
 . s sitename=$$TITLE^XLFSTR(sitename)
 . d setSessionValue^%zewdAPI("so.sitename",sitename,sessid)
 ; ---
so(sessid) ; SO from EWD; routes to $$SO
 ; TODO: Set IO("CLNM")
 d NULL                             ; IO set-up
 s IO("IP")=$$getServerValue^%zewdAPI("REMOTE_ADDR",sessid)
 d SETUP^XUSRB();                   ; This time, just need partition set-up
 n ac s ac=$$getSessionValue^%zewdAPI("ac",sessid)
 n vc s vc=$$getSessionValue^%zewdAPI("vc",sessid)
 n result s result=$$SO(ac,vc)
 ;
 ; Change Verify Code Logic Ahead... Damn Complex!
 i $l(result),result="CVC" d  q ""  ; User must change Verify Code
 . S DUZ=$$STATE^XWBSEC("XUS DUZ")  ; VISTA kills off DUZ if vc needs changing.
 .                                  ; That's fine when it can get it back. But we are not a stateful process.
 .                                  ; By the time the second request is made, XUS DUZ is gone gone gone.
 . d s(sessid)                      ; Save symbol table for next page (including DUZ)
 . d setRedirect^%zewdAPI("cvc",sessid) ; Next page is cvc.
 . d setSessionValue^%zewdAPI("cvcForced",1,sessid) ; Need to know that the user is toast!
 ;
 i $l(result) q result  ; General Error Message - User can't log-in
 ;
 e  d  q ""  ; Everything Okay
 . d s(sessid)
 . i $$isCheckboxOn^%zewdAPI("cvc","cvc",sessid) d setRedirect^%zewdAPI("cvc",sessid)
 ;
SO(ac,vc) ; Sign-on to VISTA, AV way
 ; TODO: Handle the rest of the return values
 N return
 ; if ac contains ;, then it contains the verify code
 ; else, send ac;vc
 if ac[";" d VALIDAV^XUSRB(.return,$$ENCRYP^XUSRB1(ac))
 else  d VALIDAV^XUSRB(.return,$$ENCRYP^XUSRB1(ac_";"_vc))
 i return(0)>0,'return(2) q "" ; Sign on successful!
 i return(0)=0,return(2) q "CVC"  ; Verify Code must be changed NOW!
 i $l(return(3)) q return(3)  ; Error Message returned whole
 ; Note: division selection not implemented here
 quit ""
 ; ---
sss(id) ; Test
 d setRedirect^%zewdAPI("index",id,"bb")
 q ""
whoami(sessid) ; Who Am I? PrePage Script
 d r(sessid)
 n Name s Name=$$GET1^DIQ(200,DUZ,.01) ; User Name
 d setSessionValue^%zewdAPI("Name",Name,sessid)
 q ""
cvc(sessid) ; Change Verify Code
 ; get stored session values for DUZ, IO, and U
 d r(sessid) ; Restore the Symbol Table
 n VC1,VC2,VC3
 s VC1=$$getPasswordValue^%zewdAPI("vc1",sessid)
 s VC2=$$getPasswordValue^%zewdAPI("vc2",sessid)
 s VC3=$$getPasswordValue^%zewdAPI("vc3",sessid)
 ; Uppercase them -- otherwise CVC will fail.
 s VC1=$$UP^XLFSTR(VC1)
 s VC2=$$UP^XLFSTR(VC2)
 s VC3=$$UP^XLFSTR(VC3)
 ; Roman Cipher them vista-wise
 n eVC1,eVC2,eVC3
 s eVC1=$$ENCRYP^XUSRB1(VC1)
 s eVC2=$$ENCRYP^XUSRB1(VC2)
 s eVC3=$$ENCRYP^XUSRB1(VC3)
 ; Set-up Call
 n vcString s vcString=eVC1_U_eVC2_U_eVC3
 n ret
 d CVC^XUSRB(.ret,vcString)
 i ret(0)=0 q ""  ; Success
 i ret(0)>0 q ret(1)  ; Failure
 ;;
 ;;return(0)=0
 ;;return(1)=0
 ;;return(2)=1
 ;;return(3)="VERIFY CODE must be changed before continued use."
 ;;return(4)=0
 ;;return(5)=0
 ;;return(6)=""
 ;;return(7)="Good evening DOCTOR,TEN"
 ;;return(8)="     You last signed on today at 22:19"
listEWDApps(sessid)  ; Lists all available EWD Applicaitons, not including ewdMgr. Intended to be an imitation of a menu.
 n apps  ; Will hold our applications
 do
 . n ewdpath s ewdpath=^zewd("config","applicationRootPath")
 . o "lsApps":(shell="/bin/bash":command="ls -1 "_ewdpath:READONLY)::"PIPE"
 . u "lsApps"
 . n line
 . n counter s counter=1
 . for  read line quit:$zeof  do
 . . i line="ewdMgr" quit  ; Don't include ewdMgr
 . . s apps(counter)=line
 . . s counter=counter+1
 . c "lsApps"
 . zwrite:$g(debug) apps
 . d mergeArrayToSession^%zewdAPI(.apps,"installedapps",sessid)
 ;
 ; Old code: uses JSON
 ; n appsjson s appsjson=$$arrayToJSON^%zewdJSON("apps")
 ; zwrite:$g(debug) appsjson
 ; d setSessionValue^%zewdAPI("appsjson",appsjson,sessid)
 ; 
 q ""
redir(sessid)
 n redirapp s redirapp=$$getRequestValue^%zewdAPI("nextapp",sessid)
 d setRedirect^%zewdAPI("index",sessid,redirapp)
 q ""
 ;
