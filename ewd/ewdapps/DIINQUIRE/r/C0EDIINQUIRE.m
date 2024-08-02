C0EDIINQUIRE ; EWD Wrapper around Inquire into File Entries option
 ;;
 ; All EPs public
 ;
 ; TODO:
 ; 1. Fileman controls file access based on very complex rules. Need to imp
 ; 2. Lazy loading of entries
 ; 3. Inquire needs to return structured data rather a blob--too hard right now.
 ;
FILES(sessid)  ; Get File of Files
 d clearList^%zewdAPI("file",sessid)                        ; Clean
 N FILE S FILE=""                                           ; Looper that is also the File Name
 FOR  S FILE=$O(^DIC("B",FILE)) QUIT:FILE=""  DO            ; ditto
 . N IEN S IEN=$O(^(FILE,""))                               ; IEN from 2nd subscript in B index
 . d appendToList^%zewdAPI("file",FILE,IEN,sessid)          ; Add to session
 Q ""
 ;
ENTRY(file)  ; Get first 20 Entries in a specific file
 d clearList^%zewdAPI("entry",sessid)                       ; Clean
 n glo s glo=^DIC(file,0,"GL")                              ; Get File Global
 s glo=$$CREF^DILF(glo)                                     ; Get the closed root reference
 N ENTRY S ENTRY=""                                         ; Looper that is also the Entry
 N CNT S CNT=0
 FOR  S ENTRY=$O(@glo@("B",ENTRY)) QUIT:ENTRY=""  QUIT:CNT>20  DO        ; ditto
 . N IEN S IEN=$O(^(ENTRY,""))                              ; IEN
 . d appendToList^%zewdAPI("entry",ENTRY,IEN,sessid)        ; Add to session
 . S CNT=CNT+1
 QUIT $$replaceOptionsByID^%zewdAPI("entry","entry",sessid) ; Replace current options
 ;
INQ(sessid) ; DIINQUIRE Application Output
 ;
 ; First, get the options
 n outopt   ; Output Options checkbox values
 d getCheckboxValues^%zewdAPI("outopt",.outopt,sessid)
 n capopts s capopts=""  ; Caption Options to get from checkbox values
 n i s i=""
 for  set i=$order(outopt(i)) q:i=""  s capopts=capopts_i
 ;
 ; Get File and Entry
 n file s file=$$getSessionValue^%zewdAPI("file",sessid)
 n entry s entry=$$getSessionValue^%zewdAPI("entry",sessid)
 ;
 ; Now actual VISTA work--write out the output to a file
 ; Note that HFS uniqueness is guaranteed by the device file configuration
 ; If you set IO=$$UNIQUE^%ZISUTL_$J in the pre-open execute, you are good.
 S IOP="HFS" D ^%ZIS    ; Open HFS Device
 U IO                   ; USE HFS Device
 D CAPTION^DIQ(file,entry,capopts)      ; Write Out Report
 D ^%ZISC               ; Close Device
 ; done
 ;
 ; This code doesn't work, and my debugger couldn't go through it.
 ; something is wrong--and I have an old version of GT.M--why is this happening?
 ; N PATH S PATH=$$PATH^MXMLPRSE(IO("CLOSE"))
 ; N FILE S FILE=$P(IO("CLOSE"),PATH,2)
 ; N RESULT S RESULT=$$FTG^%ZISH(PATH,FILE,$NAME(^TMP("EWDU",$J)),3) ; Doesn't work!!!
 ;
 ; ------------------> Read the File Back
 OPEN IO("CLOSE"):(READONLY:rewind)       ; Open Again for reading
 USE IO("CLOSE")        ; Use
 N CNT S CNT=1          ; Counter
 KILL ^TMP("EWDU",$J)   ; Kill TMP Global
 FOR  DO  Q:$ZEOF       ; Read the file
 . N % R %
 . S ^TMP("EWDU",$J,CNT)=%
 . S CNT=CNT+1
 C IO("CLOSE"):(delete) ; Close and delete
 ; <------------------ Close the File
 ;
 ; Move to EWD Session
 d clearSessionArray^%zewdAPI("DIINQUIRE",sessid)
 d mergeGlobalToSession^%zewdAPI($NAME(^TMP("EWDU",$J)),"DIINQUIRE",sessid)
 QUIT ""
