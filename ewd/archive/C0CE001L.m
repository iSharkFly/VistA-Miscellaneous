 ;GT.M version of page loginPanel (patientportal application)
 ;Compiled on Mon, 01 Mar 2010 17:10:45
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
 s sessionArray("ewd_prePageScript")=""
 s sessionArray("ewd_default_timeout")="1200"
 s sessionArray("ewd_persistRequest")="true"
 s sessionArray("ewd_pageTitle")=""
 s sessionArray("ewd_errorPage")="ewdError"
 s sessionArray("ewd_templatePrePageScript")=""
 s sessionArray("ewd_onErrorScript")=""
 s sessionArray("ewd_appName")="patientportal"
 s sessionArray("ewd_pageName")="loginPanel"
 s sessionArray("ewd_translationMode")="0"
 s sessionArray("ewd_technology")="gtm"
 s sessionArray("ewd_pageType")="ajax"
 s tokens("ewdAjaxError")=$$setNextPageToken^%zewdGTMRuntime("ewdAjaxError")
 s Error=$$startSession^%zewdPHP("loginPanel",.%KEY,.%CGIEVAR,.sessionArray,.filesArray)
 s sessid=$g(sessionArray("ewd_sessid"))
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
 if ($g(Error)="") d
 .w "   <div id=""ewdscript"">"_$c(13,10)
 .w "EWD.page.yuiResourcePath = """_$$getSessionValue^%zewdAPI("yui.resourcePath",sessid)_""" ;"_""
 .w "if (EWD.page.yuiResourcePath == '') {"_""
 .w " alert('Unable to determine path to YUI resource file.  Did you run d install^%zewdYUIConf()?') ;"_""
 .w "}"_""
 .w "EWD.page.loadResource("""_$$getSessionValue^%zewdAPI("yui.resourceLoaderPath",sessid)_$$getSessionValue^%zewdAPI("yui.resourceLoader",sessid)_""",""js"") ;"_""
 .w "if (!EWD.yui) alert('YUI Javascript resource file ewdYUIResources.js was not found in the web server root path');"_""
 .w "if (!EWD.yui.build) alert('YUI Javascript resource file ewdYUIResources.js is out of date.  You must be using build 790');"_""
 .w "if (EWD.yui.build != 790) alert('YUI Javascript resource file ewdYUIResources.js is out of date.  You are using build ' + EWD.yui.build + ' but you should be using build 790');"_""
 .w "EWD.yui.version = """_$$getSessionValue^%zewdAPI("yui.resourcePath",sessid)_""" ;"_""
 .w "EWD.yui.resourceLoader.Dialog() ;"_""
 .w "document.getElementsByTagName('body')[0].className = 'yui-skin-sam' ;"_""
 .w "var fReturnloginPanel7=function() {"_""
 .w "EWD.yui.widgetIndex[""yuiDialogRegloginPanel7""]={widgetName:""loginPanel7"",tagId:""yuiDialogDivloginPanel7""};"_""
 .w "EWD.yui.moveDialogToBody('yuiDialogDivloginPanel7');"_""
 .w "EWD.yui.widget.loginPanel7=new YAHOO.widget.Dialog(""yuiDialogDivloginPanel7"",{iframe:true,width:""270px"",x:150,y:100});"_""
 .w "EWD.yui.widget.loginPanel7.render();"_""
 .w "};"_""
 .w "YAHOO.util.Event.onAvailable(""yuiDialogDivloginPanel7"",fReturnloginPanel7);"_""
 .w "   </div>"_$c(13,10)
 .w "   <div id=""yuiDialogRegloginPanel7"">"_$c(13,10)
 .w "      <div id=""yuiDialogDivloginPanel7"" style=""visibility:hidden"">"_$c(13,10)
 .w "         <div class=""hd"">"_$c(13,10)
 .w "Login"_""
 .w "         </div>"_$c(13,10)
 .w "         <div class=""bd"">"_$c(13,10)
 .w "Login Form will go here"_""
 .w "         </div>"_$c(13,10)
 .w "         <div class=""ft"">"_$c(13,10)
 .w "</div>"_$c(13,10)
 .w "      </div>"_$c(13,10)
 .w "   </div>"_$c(13,10)
 .
 w "<span id=""ewdajaxonload"">"_$c(13,10)
 w " var ewdtext='"_$$jsEscape^%zewdGTMRuntime(Error)_"' ; if (ewdtext != '') {    if (ewdtext.substring(0,11) == 'javascript:') {       ewdtext=ewdtext.substring(11) ;       eval(ewdtext) ;    }    else {       EWD.ajax.alert('"_$$htmlEscape^%zewdGTMRuntime($$jsEscape^%zewdGTMRuntime(Error))_"')    }"_$c(13,10)
 s id=""
 f  s id=$o(^%zewdSession("session","ewd_idList",id)) q:id=""  d
 . w "idPointer = document.getElementById('"_id_"') ; "
 . w "if (idPointer != null) idPointer.className='"_$g(^%zewdSession("session","ewd_idList"))_"' ; "
 s id=""
 f  s id=$o(^%zewdSession("session","ewd_errorFields",id)) q:id=""  d
 . w "idPointer = document.getElementById('"_id_"') ; "
 . w "if (idPointer != null) idPointer.className='"_$g(^%zewdSession("session","ewd_errorClass"))_"' ; "
 k ^%zewdSession("session","ewd_hasErrors")
 k ^%zewdSession("session","ewd_errorFields")
 k ^%zewdSession("session","ewd_idList")
 w " }"_""
 w "</span>"_$c(13,10)
 QUIT
