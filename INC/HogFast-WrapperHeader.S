	INCLUDE "A:INC/StdMacros.S"	;ensures 0 dependencies on demo/Makaron
	IF WORKMODE=_db
CRUNCHED=0	;set to 1 when the data has been written
FINAL	=0	;set to 1 to strip timing- or testcode and similar
DEBUG	=1	;allow ciaa ints (jerky framerate) and disallow demo coppers
ORGIT	=1	;MUST be 0 if MemAlloc used!
	ENDC

	IF WORKMODE=_co
CRUNCHED=0	;set to 1 when the data has been written
FINAL	=0	;set to 1 to strip timing- or testcode and similar
DEBUG	=0	;allow ciaa ints (jerky framerate) and disallow demo coppers
ORGIT	=1	;MUST be 0 if MemAlloc used!
	ENDC

	IF WORKMODE=_fi
CRUNCHED=0	;set to 1 when the data has been written
FINAL	=1	;set to 1 to strip timing- or testcode and similar
DEBUG	=0	;allow ciaa ints (jerky framerate) and disallow demo coppers
ORGIT	=1	;MUST be 0 if MemAlloc used!
	ENDC

	IF WORKMODE=_woCr
CRUNCHED=1	;set to 1 when the data has been written
FINAL	=1	;set to 1 to strip timing- or testcode and similar
DEBUG	=0	;allow ciaa ints (jerky framerate) and disallow demo coppers
ORGIT	=0	;MUST be 0 if MemAlloc used!
	ENDC

	IF WORKMODE=_wo
CRUNCHED=0	;set to 1 when the data has been written
FINAL	=0	;set to 1 to strip timing- or testcode and similar
DEBUG	=0	;allow ciaa ints (jerky framerate) and disallow demo coppers
ORGIT	=0	;MUST be 0 if MemAlloc used!
	ENDC

	JUMPPTR B

	IF ORGIT=1
	ORG _org			;should be as high as possible,
	LOAD _load			;add "chip free" to meet chipbot.
	ELSE
	IFND CLIPUBLIC
	SECTION PhotonChip,CODE_C
	ELSE
	SECTION Photon,CODE
	ENDC
	ENDC
B:
	IF MAKARON=1
	INCLUDE "A:INC/FINISHED/Symbols.S"		;OS values.
	ENDC
