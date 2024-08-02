 ;GT.M version of page ewdError (patientportal application)
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
 w "HTTP/1.1 200 OK"_$c(13,10)
 w "Content-type: text/html"_$c(13,10,13,10)
 QUIT 1
 ;
body ;
 w ""_$c(13,10)
 w "<html>"_$c(13,10)
 w "<head>"_$c(13,10)
 w "<title>Enterprise Web Developer : A run-time error has occurred</title>"_$c(13,10)
 w "<style type=""text/css"">"_$c(13,10)
 w "   body {background: #ffffff ;}"_$c(13,10)
 w "   .headerBlock {width: 100% ; background : #111111 ; horizontal-align : center ; }"_$c(13,10)
 w "   .headerBlock[class] {width: 100% ; background : #111111 ; horizontal-align : center ; position: relative ; top : 30px ; border-right-style : solid ; border-right-width: 2px ; }"_$c(13,10)
 w "   #headerText {vertical-align: center ; font-family: Arial, sans-serif ; color: #dddddd ; font-size: 11pt ; margin-left: 10px}"_$c(13,10)
 w "   #headerSubject {vertical-align: center ; font-family: Arial, sans-serif ; color: #dddddd ; font-size: 11pt ; position: relative ; top: -30px ; text-align: center ;}"_$c(13,10)
 w "   .selectedTab {border-style: outset ; background: #eeeedd ; padding-left: 8px ; padding-right: 8px ;}"_$c(13,10)
 w "   .unselectedTab {border-style: groove ; padding-left: 8px ; padding-right: 8px ;}"_$c(13,10)
 w "   #tabs {cursor : pointer ; height: 20px ;  background : #cccccc ; text-align: center ; position: relative ; left: 25px ; font-family : Arial, Helvetica, sens-serif ; font-size: 11pt}"_$c(13,10)
 w "   #mainArea {background : #dfe2f1 ; padding: 0 ; horizontal-align: center ; width : 100% ; height: auto ; border-style: solid ; border-left-width: 1px ; border-right-width: 1px ; padding-top : 0px ; margin-top : 0px}"_$c(13,10)
 w "   #workArea {background : #ffffff ; horizontal-align: center ; position: relative ; top: -6px ; left: 25px ; width : 95% ; height: auto ; font-family : Arial, Helvetica, sens-serif ; font-size: 12pt ; border-style: outset}"_$c(13,10)
 w "   #pageTitle {width: 100% ; height: 50px ; text-align : center ; horizontal-align : center ; font-family: Arial, sans-serif ;}"_$c(13,10)
 w "   .footerBlock {width: 100% ; background : #111111 ; horizontal-align : center ;}"_$c(13,10)
 w "   .footerBlock[class] {width: 100% ; background : #111111 ; horizontal-align : center ; position: relative ; top : -15px ; border-right-style : solid ; border-right-width: 2px ; }"_$c(13,10)
 w "   #footerText {vertical-align: center ; font-family: Arial, sans-serif ; color: #dddddd ; font-size: 8pt ; margin-left : 10px}"_$c(13,10)
 w "   #tableblock {text-align: center ; margin-top: 40px}"_$c(13,10)
 w "   #hiddenForm {visibility: hidden ;}"_$c(13,10)
 w "</style>"_$c(13,10)
 w "</head>"_$c(13,10)
 w "<body>"_$c(13,10)
 w ""_$c(13,10)
 w "      <div id=""mainArea"">"_$c(13,10)
 w "        <div id=""pageTitle"">"_$c(13,10)
 w "           <h1>Enterprise Web Developer (Build 790)</h1>"_$c(13,10)
 w "        </div>"_$c(13,10)
 w ""_$c(13,10)
 w "        <div id=""workArea"">"_$c(13,10)
 w "          <div id=""tableblock"">"_$c(13,10)
 w "           <h3>An Error has occurred</h3>"_$c(13,10)
 w "           <br>"_$c(13,10)
 w "           <h3>"_$g(%KEY("error"))_"</h3>"_$c(13,10)
 w "          </div>"_$c(13,10)
 w "        </div>"_$c(13,10)
 w "     </div>"_$c(13,10)
 w ""_$c(13,10)
 w "     <div class=footerBlock>"_$c(13,10)
 w "              <p id=""footerText"">&nbsp;&copy; 2004-2009 M/Gateway Developments Ltd All Rights Reserved</p>"_$c(13,10)
 w "     </div>"_$c(13,10)
 w "</body>"_$c(13,10)
 w "</html>"_$c(13,10)
 QUIT
