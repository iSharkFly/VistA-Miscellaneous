C0Q1P4	; GPL - Kids utilities for C0Q 1.0 patch 4 ; 8/2/12 2:46am
	;;1.0;QUALITY MEASURES;**4**
TRAN ; Unified Transport
	D TRAN101
	D TRAN201
	QUIT
	;
TRAN101 ; Remove Untransportable pointers in C0Q QUALITY MEASURE; Private EP    
	; NB: I am reaching into KIDS's data here. This may not work for future versions
	; of KIDS. However, I am exporting this only; once exported, it should work in
	; any version of KIDS.                                                      
	N XPDIEN S XPDIEN=$QS(XPDGREF,2) ; Get IEN of KIDS Transport Global         
	N X S X=$NA(^XTMP("XPDT",XPDIEN,"DATA",1130580001.101)) ; KIDS transports our data here
	N IEN S IEN=0 ; Looper                                                      
	F  S IEN=$O(@X@(IEN)) Q:'IEN  D  ; For each IEN, remove the following:      
	. S $P(@X@(IEN,0),U,2)="" ; Numerator Patient List                          
	. S $P(@X@(IEN,0),U,3)="" ; Denominator Patient List                        
	. S $P(@X@(IEN,7),U,4)="" ; Negative Numerator List                         
	. S $P(@X@(IEN,7),U,2)="" ; Alternate Numerator List                        
	. S $P(@X@(IEN,7),U,3)="" ; Alternate Denominator List                      
	. S $P(@X@(IEN,7),U,5)="" ; Alternate Negative Numerator List               
	;
	; Now oooo how fun I have to remove the pointer resolution data by hand.
	; D1 and D2 constitute the "address" of the origin data.
	; D1 is the IEN,node
	; D2 is the piece.
	; Depending on the combination of the node and the piece, we can decide to
	; remove the data (how fun). To make it clearer, I will use vars called
	; node and piece to be clear. Up above you have a reference of which nodes
	; and pieces we want to get rid of. This makes up the "TARGET LIST"
	;
	; TARGET LIST
	N TARLIST
	S TARLIST(0,2)=""
	S TARLIST(0,3)=""
	S TARLIST(7,4)=""
	S TARLIST(7,2)=""
	S TARLIST(7,3)=""
	S TARLIST(7,5)=""
	;
	N X,SUB
	F SUB="FRV1","FRV1K" S X=$NA(^XTMP("XPDT",XPDIEN,SUB,1130580001.101)) D
	. N D1,D2 S (D1,D2)=0
	. F  S D1=$O(@X@(D1)) Q:'D1  F  S D2=$O(@X@(D1,D2)) Q:'D2  D
	. . N NODE,PIECE
	. . S NODE=$P(D1,",",2)
	. . S PIECE=D2
	. . I $D(TARLIST(NODE,PIECE)) K ^(D2)
	QUIT
	;
TRAN201 ; Transport 201 (Measurement Sets file)
	N XPDIEN S XPDIEN=$QS(XPDGREF,2) ; Get IEN of KIDS Transport Global
	N X S X=$NA(^XTMP("XPDT",XPDIEN,"DATA",1130580001.201)) ; KIDS transports our data here
	N IEN1 S IEN1=0 ; Looper                                                      
	F  S IEN1=$O(@X@(IEN1)) Q:'IEN1  D 
	. N IEN2 S IEN2=0
	. F  S IEN2=$O(@X@(IEN1,5,IEN2)) Q:'IEN2  D
	. . N Y S Y=$NA(^(IEN2)) ;Grab the reference
	. . K @Y@(1),@Y@(2),@Y@(3),@Y@(4) ; nodes to kill off containing untransportable data
	QUIT
	;
POST401 ; Post 401
	
