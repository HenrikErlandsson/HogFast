;		x-----+-----------------------------------------*
;		|Name:| HogFast					|
;		+-----+-----------------------------------------+
;		|V1.22|	Small tweaks & cosmetics II		|
;		|V1.21|	Small tweaks & cosmetics		|
;		|V1.20|	Remove blank zeroes			|
;		|V1.19|	Transfer improvements from test		|
;		|V1.18|	Cosmetics				|
;		|V1.17|	Optimized, 1004b			|
;		|V1.16|	Optimizing, fixing			|
;		|V1.15|	Optimizing, cleaning			|
;		|V1.14|	RC1 test on 3.1 OK			|
;		|V1.13|	Allocating all slow on 2nd run		|
;		|V1.12|	Allocing mem for port			|
;		|V1.11|	Added port & msg + flow control		|
;		|V1.10|	Simplify memory allocation.		|
;		|V1.09|	Rewrote the entire program. Works.	|
;		|V1.08|	Tuned value for right Largest result.	|
;		|V1.07|	First implementation, success		|
;		|V1.06|	Assembles and runs in new env		|
;		|V1.05|	Removed demostuff to make pure CLI cmd.	|
;		|V1.04|	Cleaned up final wrapper with example.	|
;		+-----+-----------------------------------------+
;		|		© Photon of Scoopex		|
;		x-----------------------------------------------x

;HogFast applies A500 compomachine limits after booting without s-s, to ensure
;a demo doesn't use too much slowmem on 1.3/3.1 A500 512k/512k, and also hogs
;all real fastmem to run with the same memory speeds as such an Amiga.

;1.22 adds a toggle function which also allows viewing demos subsequently
;without having to reboot, either from harddisk or used on a packdisk.

;1. On first run, hogs all fast and all slow but 430K.
;2. On 2nd/4th/6th etc run, hogs remaining slow.
;3. On 3rd/5th/7th etc run, frees 430K slow - size of this program.

;echoes "<430K" if not enough slow in the A500
;error code 20/IF FAIL = too fragmented memory
;error code 15/FAIL: Error creating port.

	INCDIR ""
	INCLUDE "A:INC/FINISHED/Constants.S"	;HW values etc.

********** STD SYMBOLS *********

MAKARON	  =1		;if [part of] program uses OS lib functions.
CLIPUBLIC =1		;CLI template in Any mem
LibBits	  =%00000101	;MathI,MathT,MathF,Icon,Con, Gfx,Int,Dos.
WORKMODE  =_WO		;DBug,COding,FInal(wb .bin),WOcr,WO

MemChunkSize	=32*4+4	;size of FreeList
MaxSlowMem=430840	;1.3+3.1 tuned value to match 1.3 max Largest slowmem.

	INCLUDE "INC/HogFast-Symbols.S"

	INCLUDE "INC/HogFast-WrapperHeader.S"
	INCLUDE "INC/HogFast-Makaron.S"

;;********** CODE START *********

	INCLUDE "A:INC/FINISHED/Makaron/WrapperAlloc.S"	;sets a5/a6
;;    ---  custom code start  ---
	INIT
	move.l 4.w,a6
	OPENLIBS
	CALL DOS,DOutPut
	move.l d0,CurrHdl-R(A5)
	beq.w OsExit

;;1   ---  main start  ---
Main:
    *--- Check if port already exists ---*

	moveq #0,d6			;Called AddPort before?
ChkPortL:
	CALL EXEC,EForbid
	lea MyPortName(PC),a1
	CALL EXEC,EFindPort		;port already created?
	move.l d0,MyPortP-R(A5)
	CALL EXEC,EPermit
	move.l MyPortP(PC),d0
	bne.s PortFound
	tst.w d6
	bne.w ErrCrit

	bsr.w AllocStructs		;returns ptr in d0
	move.l d0,MyPortP-R(A5)
	beq.w ErrCrit

	move.l d0,a1
	lea _portName(a1),a2		;poke dynamic ptr
	move.l a2,_portNameP(a1)
	CALL EXEC,EAddPort		;no? then add port ONCE
	addq.w #1,d6
	bra.s ChkPortL
PortFound:

	move.l MyPortP(PC),a0		;did we PutMsg() yet?
	CALL EXEC,EGetMsg
	beq.s FirstRun			;no? then first run.
	add.w #_portMsgData-_portMsg,d0
	move.l d0,d6			;d6=msgDataP
	bra.w DontAllocFirst		;no? then first run.

;;2 *--- Alloc all fast, make list of slowmem chunks ---*

FirstRun:
	bsr.w AllocAllFast
	cmp.l a2,a4			;end of list?
	bhs.w ErrListFull

;;3 *--- Process Chunks ---*

ProcessChunks:
	move.l a4,a2			;end of list.
	move.l a3,a4
	move.l #MaxSlowMem,d7
	moveq #0,d6			;sum of freed
FreeL:
	cmp.l a2,a4
	bhs.s FreeLE

	cmp.l d7,d6
	bhs.s FreeLE
	
	move.l (a4)+,a1
	move.l (a4)+,d0
	add.l d0,d6
	FREE a1,d0
	BRA.S FreeL

FreeLE:
	sub.l d7,d6			;actual freed slowmem - 430K
	bhi.s Go430K
	beq.s Done430K
	WRITE "<"			;just warn, best effort.
	bra.s Done430K
Go430K:
	ALLOC d6,_Fast			;make it so. exactly 430K left.
	move.l d6,-(a4)
	move.l d0,-(a4)
Done430K:
	bsr.s PutMyMsg			;put a bunch of zeroes as msg.


Success:
	WRITE "43"
;End:
;;4   ---  main end, OS-friendly cleanup  ---
OsExit:
	WRITELN "0K"
	CLOSELIBS
	EXIT

QUIT:	moveq #0,d6
BAIL:	INCLUDE "A:INC/FINISHED/Makaron/WrapperDeAlloc.S"
CRIT:	move.l d6,d0				;Exiterror
	RTS

ErrListFull:
	moveq #20,d6
	bra.s BAIL			;FAIL: Memory list full.
ErrCrit:
	moveq #15,d6
	bra.s BAIL			;FAIL: Error creating port.

    *--- Common Functions ---*

PutMyMsg:
	move.l MyPortP(PC),a0
	lea _portMsg(a0),a1
	CALL EXEC,EPutMsg
	RTS

    *--- Subsequent runs toggle! ---*

DontAllocFirst:
	AVAIL _Fast+_Largest
	cmp.l #8*K,d0			;close to 0 slow
	blo.s ThirdRun			;(pockets can be freed between runs)

    *--- even: Alloc+PutMsg(restofslow) ---*

SecondRun:				;alloc and putmsg(restofslow)
	bsr.s AllocAllFast		;sets a3=memchunks
;NOTE: ignore List Full error - store any rem. slowmem chunks
	move.l d6,a2

    *--- Copy FreeList into Msg ---*
.l:
	move.l (a3)+,(a2)+
	bne.s .l
	bsr.s PutMyMsg			;store only the rem. slowmem chunks
	BRA.w OsExit			;"0K"

    *--- odd: dealloc restofslow ---*

ThirdRun:				;a2=getmsg ptr, dealloc restofslow
	move.l d6,a2
FreeL2:
	move.l (a2)+,d0			;ptr
	beq.s FreeL2Done
	move.l d0,a1
	move.l (a2)+,d0			;len
	FREE a1,d0
	bra.s FREEL2
FreeL2Done:
	bsr.s PutMyMsg
	BRA.w Success			;"430K"

    *--- Alloc mem for messaging structs ---*

AllocStructs:				;returns ptr or 0 in d0
	ALLOC #(MsgAllocE-MsgAlloc)+MemChunkSize,_Fast+_Clear
	beq.s .err

    *--- copy init data ---*		;leaves msg data blank

	lea MyMsgPort(PC),a0
	move.l d0,a1
	moveq #_portMsgData/2-1,d1
.lcopy:
	move.w (a0)+,(a1)+
	dbf d1,.lcopy
.err:
	RTS

    *--- Alloc all fast, list slowmem ---*

AllocAllFast:	;a2/a4=ChunksE,Chunks -> a4=real end of chunks
	lea MemChunks,a4
	lea MemChunksE-MemChunks(a4),a2	;save for later
	move.l a4,a3
AllocL:
	cmp.l a2,a4			;end of list?
	bhs.s AllocErrListFull

	AVAIL _Fast+_Largest
	move.l d0,d5
	beq.s AllocLE

	ALLOC d5,_Fast
	move.l d0,d4

	swap d0				;isSlowMem?
	sub.w #$c0,d0
	blo.s AllocL

	cmp.w #$dc-$c0,d0		;top of Ranger mem
	bhs.s AllocL

	move.l d4,(a4)+			;isSlowMem.
	move.l d5,(a4)+			;=these blocks should be freed later.
	bra.s AllocL
AllocLE:
AllocErrListFull:
	clr.l (a4)			;end marker
	RTS

********************  DATA  ********************

MsgAlloc:

    *--- Message Port ---*

_portNameP	=10
_portName	=34
_portMsg	=42
_portMsgData	=62

MyMsgPort:
MyMsgPortNode:
	dc.l 0,0
	dc.b 4,1
	dc.l MyPortName
MyMsgPortRest:
	dc.b 2,0		;PA_IGNORE, sigbit
	dc.l 0			;signal no task
	dcb.w 14/2,0		;msglist space

MyPortName:
	dc.b "HogFast",0

    *--- Message ---*
MyMsg:
MyMsgNode:
	dc.l 0,0	;succ,pred
	dc.b 5,1	;NT_MESSAGE,Pri > 0
	dc.l 0		;asciiz ptr to ID string
MyMsgReplyPortP:
	dc.l 0
MyMsgLength:
	dc.w MemChunkSize
MsgAllocE:

****************** DECOUPLED FROM WRAPPER ************************
R:	dc.l 0			;global ref, cut here.

    *--- Variables ---*

MyPortP:	dc.l 0

ReloTop:
E:				;end of binary
	SECTION HogFastData,BSS

    *--- Msg content ---*

MemChunks:
	ds.l MemChunkSize/4-1
MemChunksE:
	ds.l 1			;end marker
	END
