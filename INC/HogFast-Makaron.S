
;**MODIFIED to be size-optimized

;Uses a6=$dff002 as customs-base R=init+32768 using a5 instead of PC
;minimum #macros, use CALL EXEC,Eoldopen, bla bla...
;input: LibBits as per Setup.S. Symbols.S. Nothing else.
;doesn't interfere with normal SystemOff/on code.
;include only if it uses system. Doesn't use stack for init/exit.

;OBS! MAKE SURE FUTURE ROUTINES ARE PC-RELATIVE!!!
;if OpenLib/CloseLib is used, set LibBits!
;Bits 0-7=Dos,Int,Gfx,Con,Icon,MathF,MathT,MathI
;Presume that all macros destroy D0-D1/A0-A1, and preserves all other regs.
;Macros that use supplied work-registers preserve ALL registers.

;When calling a macro, A5 MUST BE INIT-ADR+32768 AND A6 MUST BE $DFF002!
;Most Macros CONTAIN GLOBAL LABELS, so use local only in-between Macro calls.
;Labels to define if relevant macros are used:
;Params (#Max longs)
;CurrHdl (current filehandle storage long)
;Buf (blk.b 81,0) for conversion & input routines
;_HexTbl contains HexS if NumHex used above.
;OBS! DO OPTI BY REGISTER-COMPARING (IFNC) **BUT NOT IF REGWRITE OR TEST AFTER!
;OBS! NO REPTs! ENDMs MUST BE ALONE ON A LINE!
;OBS! DO *NOT* USE +anything AS PARAMETER STRINGS/FLAGS! OS COMES IN-BETWEEN!
NrLibs	=(LibBits>>7)&1+(LibBits>>6)&1+(LibBits>>5)&1+(LibBits>>4)&1+(LibBits>>3)&1+(LibBits>>2)&1+(LibBits>>1)&1+LibBits&1
****************
CALL:	MACRO				;libshort,offset
	MOVE.L A6,-(SP)
	move.l \1Base-R(a5),a6
	jsr \2(a6)
	MOVE.L (SP)+,A6
	TST.L D0
	ENDM				;D0 TESTED AT EXIT!
****************
LMB:	MACRO
	btst #6,$bfe001
	ENDM				;EQ=PRESSED!
****************
RMB:	MACRO
	btst #10,$16-2(a6)
	ENDM				;EQ=PRESSED!
****************
	IFND WaitBlit2
WaitBlit2:MACRO				;a6=$dff002!
	btst #14,(a6)
	bne.s *-4
	ENDM
	ENDC
****************
SpecWBlit:MACRO				;a6=$dff002,DReg \1=#14!
	btst \1,(a6)
	bne.s *-2
	ENDM
****************
WaitBlitS:MACRO				;a6=$dff002,DReg \1=#14! see above
	btst \1,(a6)
	bne.s *-2
	ENDM
****************
INIT:	MACRO				;inits dc.w's
_Init:	;MOVEM.L D0-A7,SysRegs
	lea R(PC),a5			;base reg (for opti)(MAX 64K CODE!)
	clr.b -1(a0,d0.w)
;	lea CustBase-R(a5),a1
	lea Param-R(a5),a1
;	move.l (a1)+,a6			;custom regs base always!(for codesize)
	move.l 4.w,a6
	move.l a0,(a1)+			;paramstr ptr
	move.l a6,(a1)+			;ExecBase (for safety only!)
	bra.s SysSPCont			;GO ON, give us another one!
Params:	;blk.l 8,0			;max 8 params (ptrs)
Currhdl:dc.l 0				;current file handle. Set for WRITELN
Buf:	dc.b 0	;blk.b 81,0
	EVEN
;CustBase:dc.l $dff002
Param:	dc.l 0
ExecBase:dc.l 0
;SysRegs:blk.l 15,0
;SysSP:	dc.l 0
SysSPCont:
	ENDM
****************
EXIT:	MACRO				;restores registers except d0
;	MOVEM.L SysRegs+4-R(a5),D1-A7	;set d0 error value before this (or 0.)
	ENDM
****************
FAKEPARAM:MACRO				;"string". Fakes a DOS ParamStr.
	lea ._Fake(PC),a0		;PC because R not inited yet !!
	moveq #._FakeE-._Fake,d0
	bra.s ._FPs
._Fake:	dc.b \1,10
._FakeE:
	EVEN
._FPs:
	ENDM
****************
OpenLibs:MACRO				;NO PARAMS, BUT SET LibBits !!
_OpenLibs:				;NrLibs is precalced at top
	MOVEM.L A2/A6,-(SP)
	move.l ExecBase-R(a5),a6
	lea _LibBases-R(a5),a2
	IFNE LibBits&1
	lea DOSname-R(A5),a1
	bsr.s ._OL1
	ENDC
	IFNE LibBits&2
	lea INTname-R(A5),a1
	bsr.s ._OL1
	ENDC
	IFNE LibBits&4
	lea GFXname-R(A5),a1
	bsr.s ._OL1
	ENDC
	IFNE LibBits&8
	lea CONname-R(A5),a1
	bsr.s ._OL1
	ENDC
	IFNE LibBits&16
	lea ICONname-R(A5),a1
	bsr.s ._OL1
	ENDC
	IFNE LibBits&32
	lea MATHFname-R(A5),a1
	bsr.s ._OL1
	ENDC
	IFNE LibBits&64
	lea MATHTname-R(A5),a1
	bsr.s ._OL1
	ENDC
	IFNE LibBits&128
	lea MATHIname-R(A5),a1
	bsr.s ._OL1
	ENDC
._OL2:	MOVEM.L (SP)+,A2/A6
	IF NrLibs>4
	BRA _OLs
	ELSE
	BRA.S _OLs
	ENDC

._OL1:	moveq #0,d0
	jsr -408(a6)			;OldOpen
	move.l d0,(a2)+
	beq.s ._OL3
	RTS
._OL3:	addq.w #4,A7			;emulate rts
	bra.s ._OL2
_LibBases:
	IFNE LibBits&1
DosBase:dc.l 0
	ENDC
	IFNE LibBits&2
IntBase:dc.l 0
	ENDC
	IFNE LibBits&4
GfxBase:dc.l 0
	ENDC
	IFNE LibBits&8
ConBase:dc.l 0
	ENDC
	IFNE LibBits&16
IconBase:dc.l 0
	ENDC
	IFNE LibBits&32
MathFBase:dc.l 0
	ENDC
	IFNE LibBits&64
MathTBase:dc.l 0
	ENDC
	IFNE LibBits&128
MathIBase:dc.l 0
	ENDC

	IFNE LibBits&1
DosName:dc.b "dos.library",0
	ENDC
	IFNE LibBits&2
IntName:dc.b "intuition.library",0
	ENDC
	IFNE LibBits&4
GfxName:dc.b "graphics.library",0
	ENDC
	IFNE LibBits&8
ConName:dc.b "console.library",0
	ENDC
	IFNE LibBits&16
IconName:dc.b "icon.library",0
	ENDC
	IFNE LibBits&32
MathFName:dc.b "mathffp.library",0
	ENDC
	IFNE LibBits&64
MathTName:dc.b "mathtrans.library",0
	ENDC
	IFNE LibBits&128
MathIName:dc.b "mathieeedoubbas.library",0
	ENDC
	EVEN
_OLs:
	ENDM				;EQ=ERROR!
****************
CloseLibs:MACRO				;closes ev. open libs
_CloseLibs:
	MOVEM.L D2/A2/A6,-(SP)
	move.l ExecBase-R(a5),a6
	lea _LibBases-R(a5),a2
	moveq #NrLibs-1,d2
._CLl:	move.l (a2)+,d0
	beq.s ._CLn
	move.l d0,a1
	jsr -414(a6)			;CloseLib
._CLn:	dbra d2,._CLl
	MOVEM.L (SP)+,D2/A2/A6
	ENDM
****************
_LK:SET 0
LOCK:MACRO				;#Name,#Accessmode(_AccR or _AccW)
	IFNC \1,d1
	move.l \1,d1
	ENDC
	moveq \2,d0
	IF _LK=1
	jsr _LOCK-R(A5)
	ELSE
_LK:SET 1
	bsr.s _LOCK
	bra.s _LKs
_LOCK:
	MOVE.L A6,-(SP)
	move.l DosBase-R(a5),a6
	move.l d0,d2
	jsr -84(a6)			;Lock
	MOVE.L (SP)+,A6
	RTS

_LKs:	ENDC
	ENDM				;D0=lock (0=ERROR)
****************
_UL:SET 0
UNLOCK:MACRO				;#Lock
	IFNC \1,d1
	move.l \1,d1
	ENDC
	IF _UL=1
	jsr _UNLOCK-R(A5)
	ELSE
_UL:SET 1
	bsr.s _UNLOCK
	bra.s _ULs
_UNLOCK:
	MOVE.L A6,-(SP)
	move.l DosBase-R(a5),a6
	jsr -90(a6)			;UnLock
	MOVE.L (SP)+,A6
	RTS

_ULs:	ENDC
	ENDM
****************
_XM:SET 0
EXAMINE:MACRO				;#Lock,#InfoDestAddr
	IFNC \1,d1
	move.l \1,d1
	ENDC
	IFNC \2,d0
	move.l \2,d0
	ENDC
	IF _XM=1
	jsr _EXAMINE-R(A5)
	ELSE
_XM:SET 1
	bsr.s _EXAMINE
	bra.s _XMs
_EXAMINE:
	MOVE.L A6,-(SP)
	move.l DosBase-R(a5),a6
	move.l d0,d2
	jsr -102(a6)			;Examine
	MOVE.L (SP)+,A6
	tst.l d0
	RTS

_XMs:	ENDC
	ENDM				;EQ=ERROR!
****************
_OF:SET 0
OPENF:MACRO			;#Handle,#NAMEADDR,#ACCESSMODE(_RW/_OLD/_NEW)
	IFNC \2,d1
	move.l \2,d1			;file name adr
	ENDC
	IFNC \3,d0
	move.w \3,d0			;mode
	ENDC
	IF _OF=1
	jsr _OPENF-R(A5)
	move.l d0,\1
	ELSE
_OF:SET 1
	bsr.s _OPENF
	bra.s _OFs
_OPENF:

	MOVEM.L D2/A6,-(SP)
	move.l DOSbase-R(A5),a6
	moveq #0,d2
	move.w d0,d2
	jsr -30(a6)			;open
	MOVEM.L (SP)+,D2/A6
	RTS

_OFs:	ENDC
	move.l d0,\1
	ENDM				;EQ=ERROR! (D0=HANDLE!)
****************
_CF:SET 0
CLOSEF:MACRO				;#Handle->d1
	move.l \1,d1
	IF _CF=1
	beq.s _CFs\@
	jsr _CLOSEF-R(A5)
_CFs\@:
	ELSE
_CF:	SET 1
	beq.s _CFs
	bsr.s _CLOSEF
	bra.s _CFs
_CLOSEF:
	CALL DOS,DClose
	RTS

_CFs:	ENDC
	ENDM
****************
_RF:SET 0
READF:MACRO				;#Handle,#Addr,#Len
	IFNC \1,d1
	move.l \1,d1			;file handle
	ENDC
	IFNC \3,a0
	move.l \3,a0			;len (OBS! a0!)
	ENDC
	IFNC \2,d0
	move.l \2,d0			;addr
	ENDC
	IF _RF=1
	jsr _READF-R(A5)
	ELSE
_RF:SET 1
	bsr.s _READF
	bra.s _RFs
_READF:
	MOVEM.L D2-D3/A0/A6,-(SP)
	move.l DOSbase-R(A5),a6
	move.l d0,d2
	move.l a0,d3
	jsr -42(a6)			;read
	MOVEM.L (SP)+,D2-D3/A0/A6
	cmp.l a0,d0
	RTS

_RFs:	ENDC
	ENDM				;(NE=ERROR!),D0=#BYTES ACTUALLY READ!
****************
_RL:SET 0
READLN:MACRO			;NO PARAMS.Reads max 80 bytes to Buf&clrs last!
	IF _RL=1
	jsr _READLN-R(A5)
	ELSE
_RL:SET 1
	bsr.s _READLN
	bra.s _RLs
_READLN:
	MOVEM.L D2/A2,-(SP)
	lea Buf-R(a5),a2
	moveq #80,d2
	READF CurrHdl-R(a5),a2,d2
	cmp.w d2,d0
	bge.s ._RL1
	subq.w #1,d0
	clr.b (a2,d0.w)
._RL1:	MOVEM.L (SP)+,D2/A2
	RTS

_RLs:	ENDC
	ENDM				;D0=#BYTES READ (LE=ERROR!)
****************
_WF:SET 0
WRITEF:MACRO				;#Handle,#Addr,#Len
	IFNC \1,d1
	move.l \1,d1			;file handle
	ENDC
	IFNC \3,a0
	move.l \3,a0			;len (OBS! \2 must NEVER be a0!)
	ENDC
	IFNC \2,d0
	move.l \2,d0			;addr
	ENDC
	IF _WF=1
	jsr _WRITEF-R(A5)
	ELSE
_WF:SET 1
	bsr.s _WRITEF
	bra.s _WFs
_WRITEF:
	MOVEM.L D2-D3/A0/A6,-(SP)
	move.l d0,d2
	move.l a0,d3
	move.l DOSbase-R(A5),a6
	jsr DWrite(a6)			;write
	MOVEM.L (SP)+,D2-D3/A0/A6
	cmp.l a0,d0
	RTS

_WFs:	ENDC
	ENDM				;(NE=ERROR!),D0=#BYTES ACTUALLY WRITTEN
****************
WRITE:MACRO				;"Text" or Ascii-byte
	bra.s _WR1\@
_WR2\@:	dc.b \1
_WR3\@:
	EVEN
_WR1\@:	WRITEF CurrHdl-R(A5),#_WR2\@,#_WR3\@-_WR2\@
	ENDM				;D0=#BYTES ACTUALLY WRITTEN (LE=ERROR!)
****************
WRITELN:MACRO				;"Text" or Ascii-byte
	bra.s _WL1\@
_WL2\@:
	IFNB \1
	dc.b \1,10
	ELSE
	dc.b 10
	ENDC
_WL3\@:
	EVEN
_WL1\@:	lea _WL2\@(PC),a1
	WRITEF CurrHdl-R(A5),a1,#_WL3\@-_WL2\@
	ENDM				;D0=#BYTES ACTUALLY WRITTEN (LE=ERROR!)
****************
_WRA:SET 0
WRITEA:MACRO				;#TextPtr to 0-terminated string
	IFNC \1,a0
	move.l \1,a0
	ENDC
	IF _WRA=1
	jsr _WRITEA-R(A5)
	ELSE
_WRA:SET 1
	bsr.s _WRITEA
	bra.s _WRAs
_WRITEA:
	move.l a0,a1
._WRA1:	tst.b (a0)+
	bne.s ._WRA1
	subq.w #1,a0			;don't write the asciiz 0
	sub.l a1,a0
	WRITEF CurrHdl-R(A5),a1,a0	;because of load /3 BEFORE /2!
	RTS

_WRAs:	ENDC
	ENDM				;D0=#BYTES ACTUALLY WRITTEN (LE=ERROR!)
****************
_WLA:SET 0
WRITELNA:MACRO				;#TextPtr to 0-terminated string
	IFNC \1,a0
	move.l \1,a0
	ENDC
	IF _WLA=1
	jsr _WRITELNA-R(A5)
	ELSE
_WLA:SET 1
	bsr.s _WRITELNA
	bra.s _WLAs
_WRITELNA:
	move.l a0,a1
._WLA1:	tst.b (a0)+
	bne.s ._WLA1
	move.b #10,-1(a0)
	MOVE.L A0,-(SP)
	sub.l a1,a0
	WRITEF CurrHdl-R(A5),a1,a0	;because of load /3 BEFORE /2!
	MOVE.L (SP)+,A0
	clr.b -(a0)
	tst.l d0
	RTS

_WLAs:	ENDC
	ENDM				;D0=#BYTES ACTUALLY WRITTEN (LE=ERROR!)
****************
_LD:SET 0
LOADF:MACRO				;#Name,MemType (uses FileHdl)
	IFNC \1,d0
	move.l \1,d0
	ENDC
	moveq #\2,d1
	IF _LD=1
	jsr _LOADF-R(A5)
	ELSE
_LD:SET 1
	bsr.s _LOADF
	bra _LDs
_LOADF:
	MOVEM.L D2-D7/A2-A4/A6,-(SP)
	move.l ExecBase-R(a5),a6
	move.l DosBase-R(a5),a4
	moveq #-1,d6			;error-reg (- = allocErr!)
	move.l d0,a3			;nameadr
	move.l d1,a2			;memtype!
	move.l #260,d0
	jsr -198(a6)			;AllocMem
	move.l d0,d4			;memaddr
	beq.s _LDe
	move.l a3,d1
	moveq #_AccR,d2	
	exg a4,a6			;switch to DOS!
	jsr -84(a6)			;Lock
	move.l d0,d5
	beq.s _LDd
	move.l d5,d1
	move.l d4,d2
	jsr -102(a6)			;Examine
	tst.l d0
	beq.s _LDu
	move.l d4,a0
	move.l 124(a0),d7		;file size!
	moveq #1,d6			;non-zero -- succeeded!
_LDu:	move.l d5,d1
	jsr -90(a6)			;UnLock
_LDd:	exg a4,a6			;switch to exec!
	move.l #260,d0			;opti!
	move.l d4,a1
	jsr -210(a6)			;freemem
	tst.l d6
	bmi.s _LDe

	moveq #0,d6			;0=FILEERR!
	move.l d7,d0
	move.l a2,d1			;memtype
	jsr -198(a6)			;AllocMem
	move.l d0,d4			;memaddr
	beq.s _LDe
	exg a4,a6			;DOS!
	move.l a3,d1
	move.l #_Old,d2
	jsr -30(a6)			;open
	move.l d0,d5			;file handle
	beq.s _LD2
	move.l d5,d1			;filehdl
	move.l d4,d2			;addr
	move.l d7,d3			;maxlen
	jsr -42(a6)			;read
	cmp.l d7,d0
	bne.s _LDc
	move.l d7,d6			;loading ok! (set to size!)
_LDc:	move.l d5,d1
	jsr -36(a6)			;close!
_LD2:	move.l d6,d0
	bne.s _LDo			;ok? then don't dealloc!
	exg a4,a6			;EXEC!
	move.l d7,d0
	move.l d4,a1
	jsr -210(a6)			;freemem
_LDe:	move.l d6,d0			;len(auto-tst!)
_LDo:	move.l d4,a0
	MOVEM.L (SP)+,D2-D7/A2-A4/A6
	RTS

_LDs:	ENDC
	ENDM			;(-=ALLOCERR,0=FILEERR!), A0=ALLOC-ADDR,D0=LEN!
****************
_GP:SET 0
GETPARAMS:MACRO				;#ParamLine(->ASCIIZ),#Max nr of params
	IFNC \1,a0
	move.l \1,a0
	ENDC
	moveq \2-1,d0
	IF _GP=1
	jsr _GETPARAMS-R(A5)
	ELSE
_GP:SET 1
	bsr.s _GETPARAMS
	bra.s _GPs
_GETPARAMS:
	lea Params-R(a5),a1
	MOVE.L D2,-(SP)
	MOVE.W A1,-(SP)
._GP1:	move.l a0,d2
._GP2:	move.b (a0)+,d1
	beq.s ._GP3
	cmp.b #" ",d1			;Separators:SPACE
	beq.s ._GP3
	cmp.b #",",d1			;or COMMA
	bne.s ._GP2
._GP3:	subq.w #1,a0
	cmp.l d2,a0
	beq.s ._GP4			;if paramlen=0, don't count this param!
	move.l d2,(a1)+
._GP4:	clr.b (a0)+			;terminate param string
	tst.b d1
	dbeq d0,._GP1			;smartie!
	move.l a1,d0
	SUB.W (SP)+,D0
	MOVE.L (SP)+,D2
	asr.w #2,d0
	RTS

_GPs:	ENDC
	ENDM				;(EQ=NONE), D0=NR OF PARAMS FOUND
****************
_AL:SET 0
ALLOC:MACRO				;#Size,Type(1/2/4/$20000=P/C/F/Largest)
	IFNC \1,d0
	move.l \1,d0
	ENDC
	IF \2<128
	moveq #\2,d1
	ELSE
	move.l #\2,d1
	ENDC
	IF _AL=1
	jsr _ALLOC-R(A5)
	ELSE
_AL:SET 1
	bsr.s _ALLOC
	bra.s _ALs
_ALLOC:
	MOVE.L A6,-(SP)
	move.l ExecBase-R(a5),a6
	jsr -198(a6)			;AllocMem
	MOVE.L (SP)+,A6
	tst.l d0
	RTS

_ALs:	ENDC
	ENDM				;EQ=ERROR,D0=MemAddr
****************
_AA:SET 0
ALLOCA:MACRO				;#MemAddr,#Size
	IFNC \1,a1
	move.l \1,a1
	ENDC
	IFNC \2,d0
	move.l \2,d0
	ENDC
	IF _AA=1
	jsr _ALLOCA-R(A5)
	ELSE
_AA:SET 1
	bsr.s _ALLOCA
	bra.s _AAs
_ALLOCA:
	MOVE.L A6,-(SP)
	move.l ExecBase-R(a5),a6
	jsr -204(a6)			;AllocAbs
	MOVE.L (SP)+,A6
	tst.l d0
	RTS

_AAs:	ENDC
	ENDM				;EQ=ERROR!
****************
_FR:SET 0
FREE:MACRO				;#MemAddr,#Size
	move.l \1,d1
	beq.s _FRs\@
	move.l \2,d0
	move.l d1,a1
	IF _FR=1
	jsr _FREE-R(A5)
	ELSE
_FR:SET 1
	bsr.s _FREE
	bra.s _FRs\@
_FREE:
	CALL Exec,EFreeMem
	RTS
	ENDC
_FRs\@:
	ENDM
****************
_AV:SET 0
AVAIL:MACRO				;Type (No "#" !!)
	IF \1<128
	moveq #\1,d1
	ELSE
	move.l #\1,d1
	ENDC
	IF _AV=1
	jsr _AVAIL-R(A5)
	ELSE
_AV:SET 1
	bsr.s _AVAIL
	bra.s _AVs
_AVAIL:
	MOVE.L A6,-(SP)
	move.l ExecBase-R(a5),a6
	jsr -216(a6)			;AvailMem
	MOVE.L (SP)+,A6
	RTS

_AVs:	ENDC
	ENDM				;D0=AvailMem
****************
_NH:SET 0
NUMHEX:MACRO				;#ValueLong,#DestAddr
	IFNC \1,d0
	move.l \1,d0
	ENDC
	IFNC \2,a1
	move.l \2,a1
	ENDC
	IF _NH=1
	jsr _NUMHEX-R(A5)
	ELSE
_NH:SET 1
	bsr.s _NUMHEX
	bra.s _NHs
_NUMHEX:
	MOVEM.L D2-D5,-(SP)
	moveq #"$",d5			;const
	moveq #" ",d4			;const
	moveq #-1,d3			;1st-flag
	moveq #7,d1
._NH1:	rol.l #4,d0
	moveq #15,d2
	and.w d0,d2
	bne.s ._NH2
	cmp.w #1,d1			;at least 2 digits !!
	ble.s ._NH2			;if last 2 digit is 0, do it anyway!
	subq.w #1,d3			;instead of skip-bra!
._NH2:	addq.w #1,d3
	bgt.s ._NH3
	move.b d4,(a1)+			;feed initial space
	tst.w d3
	blt.s ._NH4
	addq.w #1,d3
	move.l a1,a0			;set $-ptr
	move.b d5,-(a0)			;replace space w/$
._NH3:	move.b _HexTbl(PC,d2.w),(a1)+
._NH4:	dbra d1,._NH1
	clr.b (a1)
	MOVEM.L (SP)+,D2-D5
	RTS
_HexTbl:dc.b "0123456789ABCDEF"
_NHs:	ENDC
	ENDM				;A0=$-ptr,A1=0-term-ptr,D0 INTACT!
****************
_ND:SET 0
NUMDEC:MACRO				;#ValueLong,#DestAddr
	IFNC \1,d0
	move.l \1,d0
	ENDC
	IFNC \2,a1
	move.l \2,a1
	ENDC
	IF _ND=1
	jsr _NUMDEC-R(A5)
	ELSE
_ND:SET 1
	bsr.s _NUMDEC
	bra.w _NDs
_NUMDEC:
	MOVEM.L D2-D5/A2,-(SP)		;d0=Value.L,a1=destaddr
	moveq #0,d3			;1st-non0-reg
	moveq #"0",d4			;constant
	lea _DecTbl-R(a5),a2		;a1=temp.addr,1st-non0-ptr >>A0
	moveq #8,d5
._ND1:	move.l (a2)+,d1

	moveq #"0",d2
	sub.l d1,d0
	bmi.s ._ND2

	addq.b #1,d2
	sub.l d1,d0
	bmi.s ._ND2
	addq.b #1,d2
	sub.l d1,d0
	bmi.s ._ND2
	addq.b #1,d2
	sub.l d1,d0
	bmi.s ._ND2
	addq.b #1,d2
	sub.l d1,d0
	bmi.s ._ND2
	addq.b #1,d2
	sub.l d1,d0
	bmi.s ._ND2
	addq.b #1,d2
	sub.l d1,d0
	bmi.s ._ND2
	addq.b #1,d2
	sub.l d1,d0
	bmi.s ._ND2
	addq.b #1,d2
	sub.l d1,d0
	bmi.s ._ND2

	addq.b #1,d2
	sub.l d1,d0

._ND2:	add.l d1,d0			;"restore" to above-0
	move.b d2,(a1)+
	or.b d2,d3
	cmp.b d4,d3
	bne.s ._ND3
	move.l a1,a0
._ND3:	dbra d5,._ND1
	add.b d4,d0
	cmp.b d4,d3
	bne.s ._ND4
	move.l a1,a0
._ND4:	move.b d0,(a1)+
	clr.b (a1)			;0-terminated!
	MOVEM.L (SP)+,D2-D5/A2
	RTS				;a0=1st-non0-ptr,a1=0-term-ptr
_DecTbl:dc.l 10^9,10^8,10^7,10^6,10^5,10^4,10^3,100,10
_NDs:	ENDC
	ENDM				;A0=1st-non0-ptr,A1=0-term-ptr
****************
_SR:SET 0
SEARCH:MACRO				;#Start,#End,#StringAddr(0-term.)
	IFNC \1,a0
	move.l \1,a0			;PREFERRABLY, USE A0 AS CALLREG!
	ENDC
	IFNC \2,d1
	move.l \2,d1			;STRING LEN = 2-32767!
	ENDC
	IFNC \3,a1
	move.l \3,a1
	ENDC
	IF _SR=1
	jsr _SEARCH-R(A5)
	ELSE
_SR:SET 1
	bsr.s _SEARCH
	bra.s _SRs
_SEARCH:
	MOVEM.L D2-D4/A2-A4,-(SP)
	moveq #0,d0			;default found-string length
	move.l d1,a4
	move.b -(a4),d4
	move.b (a1)+,d2
	move.b d2,(a4)
._SRl:cmp.b (a0)+,d2			;Loop
	bne.s ._SRl

	cmp.l a0,d1
	ble.s ._SRn			;searched all text

	move.l a0,a2
	move.l a1,a3
._SRi:	move.b (a3)+,d3
	beq.s ._SRf			;investigated til 0 = found!
	cmp.b (a2)+,d3
	beq.s ._SRi			;otherwise investigate til NE
	bra.s ._SRl			;if not found, continue search!
._SRf:	move.w a3,d0
	sub.w a1,d0			;stringlen
._SRn:	move.b d4,(a4)
	MOVEM.L (SP)+,D2-D4/A2-A4
	tst.w d0
	RTS

_SRs:	ENDC			;EQ=NOT FOUND, D0=len of string,A0=ADDR+1 !!
	ENDM			;YOU CAN USE BOTH D0.W AND D0.L !!
