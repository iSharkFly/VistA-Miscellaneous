jjihbb ; JJIH/SMH - Bed Board Stuff ; 9/22/11 3:27pm
 ;;0.5;INTRACARE SPECIFIC MODIFICATIONS;;
 ; (C) Sam Habiel
 ; Licensed under AGPL latest
 ; 
 ; Bed Board routine for EWD pages index.ewd and bb.ewd
 ;
 ; New in 0.3: 
 ; - Added a bunch of counts everywhere.
 ; 
 ; New in 0.4:
 ; - Added EDW and MOT fields
 ; - Patients with no beds are included!
 ; 
 ; New in 0.5:
 ; - Fixed division by zero problem if db is completely unconfigured
 ;
init(sessid)  ; Populate index.ewd with site name
 new DIQUIET set DIQUIET=1  ; Fileman - be quiet
 do DT^DICRW                ; Set-up miniumum variables for VISTA
 new sitename set sitename=$piece($$SITE^VASITE,"^",2)
 set sitename=$$TITLE^XLFSTR(sitename)  ; Make uppercase title case.
 do setSessionValue^%zewdAPI("sitename",sitename,sessid)
 quit ""
 ;
getbeds(sessid) ; Populate bb.ewd with bed board information
 ;
 ; To run this on your terminal, set debug to 1 and type: w $$getbeds^jjihbb(80)
 new debug set debug=0      ; Make this 1 to be talkative
 new DIQUIET set DIQUIET=1  ; Fileman - be quiet
 do DT^DICRW                ; Set-up miniumum variables for VISTA
 ; Ask Fileman for the list of the wards, taking out inactive ones
 ; File 42; .01 field only, "Packed Output, don't re-sort", use "B" index
 ; Screen inactive wards out using Fileman Screen on File.
 n wards1,err
 D LIST^DIC(42,"","@;.01","PQ","","","","B","S D0=Y D WIN^DGPMDDCF I 'X","","wards1","err")
 i $d(err) s $EC=",U101,"  ; we shouldn't ever have any messages - crash if so
 n wards2 ; better wards!
 m wards2=wards1("DILIST")
 ; expected output:
 ; wards2(0)="5^*^0^"
 ; wards2(0,"MAP")="IEN^.01"
 ; wards2(1,0)="15^Adolescent 2L 201-213 South"
 ; wards2(2,0)="11^Child 2R 214-225 South"
 ; wards2(3,0)="14^DAPA 3R 314-326"
 ; wards2(4,0)="13^General/Adult 3L 300-313 South"
 ; wards2(5,0)="10^Restore 1L 101-111 South"
 ; Now, walk the beds a la ABB^DGPMRBA1
 n wardbed  ; return array
 n i s i=0
 for  s i=$o(wards2(i)) q:'i  do
 . n wardien s wardien=$piece(wards2(i,0),"^")
 . zwrite:debug wardien
 . n roomien s roomien=0
 . for  s roomien=$o(^DG(405.4,"W",wardien,roomien)) q:'roomien  do
 . . zwrite:debug roomien
 . . quit:'$d(^DG(405.4,roomien,0))
 . . new bed set bed=$P(^(0),"^")
 . . new admien set admien=$o(^DGPM("ARM",roomien,0))
 . . new lodger,ptnode,edw,mot
 . . if admien d 
 . . . set lodger=^(admien)
 . . . set ptnode=^DGPM(admien,0) ; note naked sexy ref
 . . . set edw=+$p($g(^("JJIH0")),"^")
 . . . set mot=+$p($g(^("JJIH0")),"^",2)
 . . write:debug "ptnode: "_$g(ptnode),!
 . . write:debug "edw: "_$g(edw),!
 . . write:debug "mot: "_$g(mot),!
 . . ; 
 . . ; Bed Message
 . . ; pt name^pt sex^adm date^lodger^EDW^MOT^bed oos?^bed oos msg^bed oss comment
 . . n bedmsg
 . . i $g(ptnode) d  ; if we have a patient, that's the bed msg
 . . . n dfn s dfn=$p(ptnode,"^",3)
 . . . s bedmsg=$p(^DPT(dfn,0),"^",1,2) ; Patient name and sex
 . . . ; s $p(bedmsg,"^",3)=$$FMTE^XLFDT($p(ptnode,"^")) ; Admission date
 . . . s $p(bedmsg,"^",3)=$$DATE^TIULS($p(ptnode,"^"),"AMTH DD@HR:MIN") ; Admission date using TIU API
 . . . s $p(bedmsg,"^",4)=$g(lodger)
 . . . s $p(bedmsg,"^",5)=$g(edw)
 . . . s $p(bedmsg,"^",6)=$g(mot)
 . . d  ; Out of Service Checks?
 . . . n oos s oos=$$oos(roomien) ; 0 or 1^msg^comment
 . . . s $p(bedmsg,"^",7,9)=oos
 . . ;
 . . s wardbed($piece(wards2(i,0),"^",2),bed)=bedmsg
 ;
 ; Loop through inpatients to find patients without a bed
 ; Bed Message (reminder!)
 ; pt name^pt sex^adm date^lodger^EDW^MOT^bed oos?^bed oos msg^bed oss comment
 n i,j s (i,j)=""
 n counter s counter=0
 for  s i=$o(^DPT("CN",i)) q:i=""  for  s j=$o(^DPT("CN",i,j)) q:j=""  do
 . n admien s admien=^(j) ; Patient Movement IEN stored in Index
 . n dfn s dfn=j
 . n bed s bed=$get(^DPT(dfn,.101))
 . i bed'="" quit  ; if bed is not empty, quit!
 . s counter=counter+1
 . n wardname s wardname=^DPT(dfn,.1)
 . s wardbed(wardname,"NONE"_counter)=$p(^DPT(dfn,0),"^",1,2) ; name, sex
 . n admdate s admdate=$P(^DGPM(admien,0),"^")
 . s $p(wardbed(wardname,"NONE"_counter),"^",3)=$$DATE^TIULS(admdate,"AMTH DD@HR:MIN")
 . s $p(wardbed(wardname,"NONE"_counter),"^",4)=0 ; lodger
 . n edw s edw=+$p($g(^("JJIH0")),"^")
 . s $p(wardbed(wardname,"NONE"_counter),"^",5)=edw
 . n mot s mot=+$p($g(^("JJIH0")),"^",2)
 . s $p(wardbed(wardname,"NONE"_counter),"^",6)=mot
 ;
 ; Loop through lodgers to find lodgers without a bed
 ; Bed Message (reminder!)
 ; pt name^pt sex^adm date^lodger^EDW^MOT^bed oos?^bed oos msg^bed oss comment
 n i,j s (i,j)=""
 for  s i=$o(^DPT("LD",i)) q:i=""  for  s j=$o(^DPT("LD",i,j)) q:j=""  do
 . n admien s admien=^(j) ; Patient Movement IEN stored in Index
 . n dfn s dfn=j
 . n bed s bed=$get(^DPT(dfn,.108))
 . i bed'="" quit  ; if bed is not empty, quit!
 . s counter=counter+1
 . n wardname s wardname=^DPT(dfn,.107)
 . s wardbed(wardname,"NONE"_counter)=$p(^DPT(dfn,0),"^",1,2) ; name, sex
 . n admdate s admdate=$P(^DGPM(admien,0),"^")
 . s $p(wardbed(wardname,"NONE"_counter),"^",3)=$$DATE^TIULS(admdate,"AMTH DD@HR:MIN")
 . s $p(wardbed(wardname,"NONE"_counter),"^",4)=1 ; lodger
 . n edw s edw=+$p($g(^("JJIH0")),"^")
 . s $p(wardbed(wardname,"NONE"_counter),"^",5)=edw
 . n mot s mot=+$p($g(^("JJIH0")),"^",2)
 . s $p(wardbed(wardname,"NONE"_counter),"^",6)=mot
 ;
 ; Now loop through the results and count beds, males, and females
 ; Result will be in wardbed("ward name")=
 ; occ beds/total^occmale/maletotal^occfemale/femaletotal^oos^
 ; emptymale/emptyfemale/emptytotal
 n i s i="" n j s j=""  ; i loops through wards, j beds
 f  s i=$o(wardbed(i)) q:i=""  d
 . n nBed,nMale,nFemale,nOOS,nMaleBed,nFemaleBed,nEmptyMaleBed,nEmptyFemaleBed
 . s (nBed,nMale,nFemale,nOOS,nMaleBed,nFemaleBed,nEmptyMaleBed,nEmptyFemaleBed)=0
 . ;
 . f  s j=$o(wardbed(i,j)) q:j=""  d
 . . n node s node=wardbed(i,j)
 . . i +j s nBed=nBed+1 ; if bed is numeric, then count it as a bed. If NONE, won't count
 . . i $p(j,"-",3)["M" s nMaleBed=nMaleBed+1                ; Male Bed
 . . i $p(j,"-",3)["F" s nFemaleBed=nFemaleBed+1            ; Female Bed
 . . i $p(j,"-",3)["M"&($p(node,"^")="") s nEmptyMaleBed=nEmptyMaleBed+1     ; Empty Male Bed
 . . i $p(j,"-",3)["F"&($p(node,"^")="") s nEmptyFemaleBed=nEmptyFemaleBed+1 ; Empty Female Bed
 . . i $p(node,"^",2)="M" s nMale=nMale+1                   ; Male Patient
 . . i $p(node,"^",2)="F" s nFemale=nFemale+1               ; Female Patient
 . . i $p(node,"^",7)="1" s nOOS=nOOS+1                     ; Out of Service Bed
 . ;
 . n nOccupied s nOccupied=nMale+nFemale
 . n nAvailBed s nAvailBed=nBed-nOccupied
 . n % s %="/"
 . s wardbed(i)=nOccupied_%_nBed_U_nMale_%_nMaleBed_U_nFemale_%_nFemaleBed_U_nOOS_U_nEmptyMaleBed_%_nEmptyFemaleBed_%_nAvailBed
 ;
 ; Now, loop again and count the counts for a total census.
 n i s i=""
 n tBed,tMale,tFemale,tOOS s (tBed,tMale,tFemale,tOOS)=0  ; Totals
 f  s i=$o(wardbed(i)) q:i=""  d
 . n node s node=wardbed(i)
 . n nBed s nBed=$p($p(wardbed(i),"^"),"/",2)
 . n nMale s nMale=$p(wardbed(i),"^",2)
 . n nFemale s nFemale=$p(wardbed(i),"^",3)
 . n nOOS s nOOS=$p(wardbed(i),"^",4)
 . s tBed=tBed+nBed
 . s tMale=tMale+nMale
 . s tFemale=tFemale+nFemale
 . s tOOS=tOOS+nOOS
 ; done
 ;
 ; Set the totals at the top top node in the following format
 ; wardbed=beds^males^females^empty beds^occupancy %
 n tEmptyBed s tEmptyBed=tBed-(tMale+tFemale+tOOS) ; Empty beds
 ;
 n %occupancy
 ; Prevent div by zero error if beds are not there!!!
 i tBed=0 s %occupancy=0
 e  s %occupancy=(1-(tEmptyBed/tBed))*100 ; Reader: math quiz for you
 s %occupancy=$fn(%occupancy,"",0)  ; Round up to 0 decimal places
 ;
 s wardbed=tBed_U_tMale_U_tFemale_U_tEmptyBed_U_%occupancy
 ;
 ; Put it in the EWD Session
 do clearSessionArray^%zewdAPI("wardbed",sessid)
 do mergeArrayToSession^%zewdAPI(.wardbed,"wardbed",sessid)
 ;
 zwrite:debug wardbed
 quit ""
 ;
oos(bedien) ; Is the bed out of service ; Public $$
 ; Input: bedien
 ; Output: 0 -> not out of service -> Active
 ;         1^reason -> Out of service and reason
 ;
 ; First OOS date in the inverse index is the latest
 N X S X=$O(^DG(405.4,bedien,"I","AINV",0))
 I 'X Q 0  ; if none, quit
 ;
 S X=$O(^(+X,0)) ; Then get ifn
 Q:'$d(^DG(405.4,bedien,"I",+X,0)) 0  ; confirm that entry exists
 ;
 N DGND S DGND=^(0)                 ; Out of Service Node
 N OOSD S OOSD=$P(DGND,"^")         ; Out of Service Date
 N OOSR S OOSR=$P(DGND,"^",4)       ; Out of Service Restore
 N NOW S NOW=$$NOW^XLFDT()          ; Now
 ;
 I OOSD>NOW Q 0                     ; If OOSD in future, bed is active
 ;
 ; at this point, OOSD is now or in the past.
 ; Is there a restore date less than today's date? if yes, bed is active
 I OOSR'="",OOSR<NOW Q 0
 ;
 ; at this point, we are sure that the bed is inactive.
 N reasonifn s reasonifn=$p(DGND,"^",2)
 N comment s comment=$p(DGND,"^",3)
 Q 1_"^"_$$GET1^DIQ(405.5,reasonifn,.01)_"^"_comment
