C0QP1 ; VEN/SMH - Inits for Patch 1 ; 6/13/12 4:27pm
	;;1.0;C0Q;;May 21, 2012;Build 44
	;
POST ; Post-Install hook for Patch 1; PEP
	; Fire off the new x-refs for entries in the parameter file
	N C0QI S C0QI=0 ; Walk through starting with number 1
	F  S C0QI=$O(^C0Q(401,C0QI)) Q:'C0QI  D
	. N DA,DIK S DIK="^C0Q(401,",DIK(1)="2^AMMS",DA=C0QI D EN^DIK
	. N DA,DIK S DIK="^C0Q(401,",DIK(1)="2.1^AQMS",DA=C0QI D EN^DIK
