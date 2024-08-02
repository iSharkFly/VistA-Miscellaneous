 ;GT.M version of page ccr (patientportal application)
 ;Compiled on Mon, 01 Mar 2010 17:10:44
 ;using Enterprise Web Developer (Build 790)
 QUIT
 ;
run ;
 n confirmText,ebToken,Error,formInfo,ok,sessid,sessionArray,tokens
 s ok=$$pre()
 i ok d body
 QUIT
 ;
pre() ;
 ;
 n ctype,ewdAction,headers,jump,quitStatus,pageTitle,stop,urlNo
 ;
 s confirmText="Click OK if you're sure you want to delete this record"
 s sessionArray("ewd_isFirstPage")="0"
 s sessionArray("ewd_sessid_timeout")="1200"
 s sessionArray("ewd_prePageScript")="TEST2^C0CRICH"
 s sessionArray("ewd_default_timeout")="1200"
 s sessionArray("ewd_persistRequest")="true"
 s sessionArray("ewd_pageTitle")=""
 s sessionArray("ewd_errorPage")="ewdError"
 s sessionArray("ewd_templatePrePageScript")=""
 s sessionArray("ewd_onErrorScript")=""
 s sessionArray("ewd_appName")="patientportal"
 s sessionArray("ewd_pageName")="ccr"
 s sessionArray("ewd_translationMode")="0"
 s sessionArray("ewd_technology")="gtm"
 s sessionArray("ewd_pageType")=""
 s Error=$$startSession^%zewdPHP("ccr",.%KEY,.%CGIEVAR,.sessionArray,.filesArray)
 s sessid=$g(sessionArray("ewd_sessid"))
 d mergeArrayFromSession^%zewdAPI(.headers,"ewd.header",sessid)
 s headers("Content-type")="text/xml"
 d mergeArrayToSession^%zewdAPI(.headers,"ewd.header",sessid)
 k headers
 i Error["Enterprise Web Developer Error :",$g(sessionArray("ewd_pageType"))="ajax" d
 . s Error=$p(Error,":",2,200)
 . s Error=$$replaceAll^%zewdAPI(Error,"<br>",": ")
 . s Error="EWD runtime error: "_Error
 i $e(Error,1,32)="Enterprise Web Developer Error :" d  QUIT 0
 . n errorPage
 . s errorPage=$g(sessionArray("ewd_errorPage"))
 . i errorPage="" s errorPage="ewdError"
 . i $g(sessionArray("ewd_pageType"))="ajax" s errorPage="ewdAjaxErrorRedirect"
 . d writeHTTPHeader^%zewdGTMRuntime(sessionArray("ewd_appName"),errorPage,,,sessid,Error)
 s stop=0
 i Error="" d  i stop QUIT 0
 . n nextpage
 . s nextpage=$$getSessionValue^%zewdAPI("ewd_nextPage",sessid)
 . i nextpage'="" d
 . . n x
 . . d writeHTTPHeader^%zewdGTMRuntime(sessionArray("ewd_appName"),nextpage,$$getSessionValue^%zewdAPI("ewd_token",sessid),$$getSessionValue^%zewdAPI("ewd_pageToken",sessid))
 . . s stop=1
 i $$getSessionValue^%zewdAPI("ewd_warning",sessid)'="" d
 . s Error=$$getSessionValue^%zewdAPI("ewd_warning",sessid)
 . d deleteFromSession^%zewdAPI("ewd_warning",sessid)
 w "HTTP/1.1 200 OK"_$c(13,10)
 s ctype="text/html"
 d mergeArrayFromSession^%zewdAPI(.headers,"ewd.header",sessid)
 i $d(headers) d
 . n lcname,name
 . s name=""
 . f  s name=$o(headers(name)) q:name=""  d
 . . s lcname=$$zcvt^%zewdAPI(name,"l")
 . . i lcname="content-type" s ctype=headers(name) q
 . . w name_": "_headers(name)_$c(13,10)
 w "Content-type: "_ctype_$c(13,10)
 w $c(13,10)
 QUIT 1
 ;
body ;
 s no=""
 i no?1N.N s no=no-1
 i no?1AP.ANP d
 . s p1=$e(no,1,$l(no)-1)
 . s p2=$e(no,$l(no))
 . s p2=$c($a(p2)-1)
 . s no=p1_p2
 s nul=""
 s endValue12=""
 i endValue12?1N.N s endValue12=endValue12+1
 f  q:'(($o(^%zewdSession("session",sessid,"CCR",no))'=endValue12)&($o(^%zewdSession("session",sessid,"CCR",no))'=nul))  d
 .s no=$o(^%zewdSession("session",sessid,"CCR",no))
 .s data=$g(^%zewdSession("session",sessid,"CCR",no))
 .w data
 .
 QUIT
