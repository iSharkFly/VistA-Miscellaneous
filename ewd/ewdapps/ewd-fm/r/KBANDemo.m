KBANDemo ; Test to demo EWD ; 8/2/11 1:53pm
 ;;
login(sessid)
 n error s error=""
 n un,pw
 s un=$$getTextValue^%zewdAPI("username",sessid)
 s pw=$$getPasswordValue^%zewdAPI("password",sessid)
 s %ZIS="0H",IOP="NULL"
 d ^%ZIS
 i POP s error="Programming error" d ^%ZTER g EXIT
 d SETUP^XUSRB() ; Set-up for GUI signon
 n RETURN
 D VALIDAV^XUSRB(.RETURN,$$ENCRYP^XUSRB1(un_";"_pw))
 i DUZ'>0 s error="Not a valid login"
 i error="" d  ; everything is okay; save symtab crap
 . d mergeArrayToSession^%zewdAPI(.DUZ,"DUZ",sessid)
 . d mergeArrayToSession^%zewdAPI(.IO,"IO",sessid)
 . d setSessionValue^%zewdAPI("U","^",sessid)
 q error
EXIT D:$G(DUZ) LOGOUT^XUSRB
 Q error
DisplayUserCharacteristics(sessid)
 D FillSymTab(sessid)
 d clearTextArea^%zewdAPI("display",sessid)
 ; d appendToTextArea^%zewdAPI("display","blha blha",sessid)
 N ZTQUEUED,ORHFS,ORSUB,ROOT,ORIO,ORHANDLE,ORWINDEV
 N IOM,IOSL,IOST,IOF,IOT,IOS,POP
 S (ORSUB,ROOT)="ORDATA",ORIO="OR WINDOWS HFS",ORTEXT=$NA(^TMP(ORSUB,$J,1)),ORHANDLE="ORWRP"
 S ORHFS=$$HFS^ORWRP(),ORWINDEV=1 ;Flag for printing to windows device
 D HFSOPEN^ORWRP(ORHANDLE,ORHFS,"W")
 I POP D  Q
 . I $D(ROOT) D SETITEM^ORWRP(.ROOT,"ERROR: Unable to open HFS file")
 D IOVAR^ORWRP(.ORIO,,,"P-WINHFS80")
 N $ETRAP,$ESTACK
 S $ETRAP="D ERR^ORWRP Q"
 U IO
 D ^XQUSR
 D HFSCLOSE^ORWRP(ORHANDLE,ORHFS)
 N txt M txt=@ORTEXT
 D mergeToTextArea^%zewdAPI("display",.txt,sessid)
 Q ""
SignonTxt(sessid)	;
 S U="^"
 D setSessionValue^%zewdAPI("signontxt","Welcome to Wonderful Veldt of EWD")
 Q ""
getUsernames(sessid)
 d clearList^%zewdAPI("user",sessid)
 n sam
 d LIST^DIC(200,"","@;.01","PKU","*","","","","","","sam")
 n i s i=0
 f  s i=$o(sam("DILIST",i)) q:i=""  d
 . n entry s entry=sam("DILIST",i,0)
 . d appendToList^%zewdAPI("user",$p(entry,U,2),$p(entry,U),sessid)
 quit ""
getInfo(sessid)
 S ^KBANSAM=1
 n DUZ s DUZ=$$getSessionValue^%zewdAPI("user",sessid)
 n Name s Name=$$GET1^DIQ(200,DUZ_",",.01)
 n officePhone s officePhone=$$GET1^DIQ(200,DUZ,"OFFICE PHONE")
 d setSessionValue^%zewdAPI("Name",Name,sessid)
 d setSessionValue^%zewdAPI("officePhone",officePhone,sessid)
 quit ""
savePhones(sessid)
 quit ""
CVC(sessid) ; Change verify code
 ; get stored session values for DUZ, IO, and U
 d FillSymTab(sessid)
 n VC1,VC2,VC3
 s VC1=$$getPasswordValue^%zewdAPI("vc1",sessid)
 s VC2=$$getPasswordValue^%zewdAPI("vc2",sessid)
 s VC3=$$getPasswordValue^%zewdAPI("vc3",sessid)
 n eVC1,eVC2,eVC3
 s eVC1=$$ENCRYP^XUSRB1(VC1)
 s eVC2=$$ENCRYP^XUSRB1(VC2)
 s eVC3=$$ENCRYP^XUSRB1(VC3)
 n vcString s vcString=eVC1_U_eVC2_U_eVC3
 n ret
 d CVC^XUSRB(.ret,vcString)
 i ret(0)=0 q ""
 i ret(0)>0 q ret(1)
FillSymTab(id) ; Fill symbol table
 d mergeArrayFromSession^%zewdAPI(.DUZ,"DUZ",id)
 d mergeArrayFromSession^%zewdAPI(.IO,"IO",id)
 s U=$$getSessionValue^%zewdAPI("U",id)
 quit
