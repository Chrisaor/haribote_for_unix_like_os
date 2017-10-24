; naskfunc
; TAB=4

[FORMAT "WCOFF"]				; 오브젝트 파일을 만드는 모드	
[INSTRSET "i486p"]				; 486명령까지 사용하고 싶다고 하는 기술
[BITS 32]					; 32비트 모드용의 기계어를 만들게 한다
[FILE "naskfunc.nas"]				; 원시 파일명 정보

		GLOBAL	_io_hlt, _io_cli, _io_sti, _io_stihlt
		GLOBAL	_io_in8,  _io_in16,  _io_in32
		GLOBAL	_io_out8, _io_out16, _io_out32
		GLOBAL	_io_load_eflags, _io_store_eflags
		GLOBAL	_load_gdtr, _load_idtr
		GLOBAL	_load_cr0, _store_cr0
		GLOBAL	_load_tr
		GLOBAL	_asm_inthandler20, _asm_inthandler21
		GLOBAL	_asm_inthandler2c, _asm_inthandler0d
		GLOBAL	_memtest_sub
		GLOBAL	_farjmp, _farcall
		GLOBAL	_asm_hrb_api, _start_app
		EXTERN	_inthandler20, _inthandler21
		EXTERN	_inthandler2c, _inthandler0d
		EXTERN	_hrb_api

[SECTION .text]

_io_hlt:	; void io_hlt(void);
		HLT
		RET

_io_cli:	; void io_cli(void);
		CLI
		RET

_io_sti:	; void io_sti(void);
		STI
		RET

_io_stihlt:	; void io_stihlt(void);
		STI
		HLT
		RET

_io_in8:	; int io_in8(int port);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,0
		IN		AL,DX
		RET

_io_in16:	; int io_in16(int port);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,0
		IN		AX,DX
		RET

_io_in32:	; int io_in32(int port);
		MOV		EDX,[ESP+4]		; port
		IN		EAX,DX
		RET

_io_out8:	; void io_out8(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		AL,[ESP+8]		; data
		OUT		DX,AL
		RET

_io_out16:	; void io_out16(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,[ESP+8]		; data
		OUT		DX,AX
		RET

_io_out32:	; void io_out32(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,[ESP+8]		; data
		OUT		DX,EAX
		RET

_io_load_eflags:	; int io_load_eflags(void);
		PUSHFD		; PUSH EFLAGS 라고 하는 의미
		POP		EAX
		RET

_io_store_eflags:	; void io_store_eflags(int eflags);
		MOV		EAX,[ESP+4]
		PUSH	EAX
		POPFD		; POP EFLAGS 라고 하는 의미
		RET

_load_gdtr:		; void load_gdtr(int limit, int addr);
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX
		LGDT	[ESP+6]
		RET

_load_idtr:		; void load_idtr(int limit, int addr);
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX
		LIDT	[ESP+6]
		RET

_load_cr0:		; int load_cr0(void);
		MOV		EAX,CR0
		RET

_store_cr0:		; void store_cr0(int cr0);
		MOV		EAX,[ESP+4]
		MOV		CR0,EAX
		RET

_load_tr:		; void load_tr(int tr);
		LTR		[ESP+4]			; tr
		RET

_asm_inthandler20:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		AX,SS
		CMP		AX,1*8
		JNE		.from_app
;	OS가 움직이고 있을 때 인터럽트 되었으므로 거의 지금까지 대로
		MOV		EAX,ESP
		PUSH	SS				; 인터럽트 시 SS를 보존
		PUSH	EAX				; 인터럽트 시 ESP를 보존
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler20
		ADD		ESP,8
		POPAD
		POP		DS
		POP		ES
		IRETD
.from_app:
;	어플리케이션이 움직이고 있을 때 인터럽트되었다
		MOV		EAX,1*8
		MOV		DS, AX			; DS만 OS용으로 한다
		MOV		ECX,[0xfe4]		; OS의 ESP
		ADD		ECX,-8
		MOV		[ECX+4], SS		; 인터럽트 시 SS를 보존
		MOV		[ECX  ], ESP		; 인터럽트 시 ESP를 보존
		MOV		SS,AX
		MOV		ES,AX
		MOV		ESP,ECX
		CALL	_inthandler20
		POP		ECX
		POP		EAX
		MOV		SS, AX			; SS를 어플리케이션용으로 되돌린다
		MOV		ESP, ECX		; ESP도 어플리케이션용으로 되돌린다
		POPAD
		POP		DS
		POP		ES
		IRETD

_asm_inthandler21:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		AX,SS
		CMP		AX,1*8
		JNE		.from_app
;	OS가 움직이고 있을 때 인터럽트 되었으므로 거의 지금까지 대로
		MOV		EAX,ESP
		PUSH	SS				; 인터럽트 시 SS를 보존
		PUSH	EAX				; 인터럽트 시 ESP를 보존
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler21
		ADD		ESP,8
		POPAD
		POP		DS
		POP		ES
		IRETD
.from_app:
;	어플리케이션이 움직이고 있을 때 인터럽트 되었다
		MOV		EAX,1*8
		MOV		DS, AX			; DS만 OS용으로 한다
		MOV		ECX,[0xfe4]		; OS의 ESP
		ADD		ECX,-8
		MOV		[ECX+4], SS		; 인터럽트 시 SS를 보존
		MOV		[ECX  ], ESP		; 인터럽트 시 ESP를 보존
		MOV		SS,AX
		MOV		ES,AX
		MOV		ESP,ECX
		CALL	_inthandler21
		POP		ECX
		POP		EAX
		MOV		SS, AX			; SS를 어플리케이션용으로 되돌린다
		MOV		ESP, ECX		; ESP도 어플리케이션용으로 되돌린다
		POPAD
		POP		DS
		POP		ES
		IRETD

_asm_inthandler2c:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		AX,SS
		CMP		AX,1*8
		JNE		.from_app
;	OS가 움직이고 있을 때 인터럽트 되었으므로 거의 지금까지 대로
		MOV		EAX,ESP
		PUSH	SS				; 인터럽트 시 SS를 보존
		PUSH	EAX				; 인터럽트 시 ESP를 보존
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler2c
		ADD		ESP,8
		POPAD
		POP		DS
		POP		ES
		IRETD
.from_app:
;	어플리케이션이 움직이고 있을 때 인터럽트 되었다
		MOV		EAX,1*8
		MOV		DS, AX			; DS만 OS용으로 한다
		MOV		ECX,[0xfe4]		; OS의 ESP
		ADD		ECX,-8
		MOV		[ECX+4], SS		; 인터럽트 시 SS를 보존
		MOV		[ECX  ], ESP		; 인터럽트 시 ESP를 보존
		MOV		SS,AX
		MOV		ES,AX
		MOV		ESP,ECX
		CALL	_inthandler2c
		POP		ECX
		POP		EAX
		MOV		SS, AX			; SS를 어플리케이션용으로 되돌린다
		MOV		ESP, ECX		; ESP도 어플리케이션용으로 되돌린다
		POPAD
		POP		DS
		POP		ES
		IRETD

_asm_inthandler0d:
		STI
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		AX,SS
		CMP		AX,1*8
		JNE		.from_app
;	OS가 움직이고 있을 때 인터럽트 되었으므로 거의 지금까지 대로
		MOV		EAX,ESP
		PUSH	SS				; 인터럽트 시 SS를 보존
		PUSH	EAX				; 인터럽트 시 ESP를 보존
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler0d
		ADD		ESP,8
		POPAD
		POP		DS
		POP		ES
		ADD		ESP, 4			; INT 0x0d 에서는, 이것이 필요
		IRETD
.from_app:
;	어플리케이션이 움직이고 있을 때 끼어들어졌다
		CLI
		MOV		EAX,1*8
		MOV		DS, AX			; 우선 DS만 OS용으로 한다
		MOV		ECX,[0xfe4]		; OS의 ESP
		ADD		ECX,-8
		MOV		[ECX+4], SS		; 인터럽트 시 SS를 보존
		MOV		[ECX  ], ESP		; 인터럽트 시 ESP를 보존
		MOV		SS,AX
		MOV		ES,AX
		MOV		ESP,ECX
		STI
		CALL	_inthandler0d
		CLI
		CMP		EAX,0
		JNE		.kill
		POP		ECX
		POP		EAX
		MOV		SS, AX			; SS를 어플리케이션용으로 되돌린다
		MOV		ESP, ECX		; ESP도 어플리케이션용으로 되돌린다
		POPAD
		POP		DS
		POP		ES
		ADD		ESP, 4			; INT 0x0d 에서는, 이것이 필요
		IRETD
.kill:
;	어플리케이션을 이상종료(ABEND) 시키기로 했다
		MOV		EAX,1*8			; OS용의 DS/SS
		MOV		ES,AX
		MOV		SS,AX
		MOV		DS,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		ESP,[0xfe4]		; start_app 때의 ESP에 억지로 되돌린다
		STI			; 변환 완료이므로 인터럽트 가능으로 되돌린다
		POPAD	; 보존해 둔 레지스터를 회복
		RET

_memtest_sub:	; unsigned int memtest_sub(unsigned int start, unsigned int end)
		PUSH	EDI						; (EBX, ESI, EDI 도 사용하고 싶기 때문에)
		PUSH	ESI
		PUSH	EBX
		MOV		ESI, 0xaa55aa55			; pat0 = 0xaa55aa55;
		MOV		EDI, 0x55aa55aa			; pat1 = 0x55aa55aa;
		MOV		EAX,[ESP+12+4]			; i = start;
mts_loop:
		MOV		EBX,EAX
		ADD		EBX, 0xffc				; p = i + 0xffc;
		MOV		EDX,[EBX]				; old = *p;
		MOV		[EBX], ESI				; *p = pat0;
		XOR		DWORD [EBX], 0xffffffff	; *p ^= 0xffffffff;
		CMP		EDI,[EBX]				; if (*p ! = pat1) goto fin;
		JNE		mts_fin
		XOR		DWORD [EBX], 0xffffffff	; *p ^= 0xffffffff;
		CMP		ESI,[EBX]				; if (*p ! = pat0) goto fin;
		JNE		mts_fin
		MOV		[EBX], EDX				; *p = old;
		ADD		EAX, 0x1000				; i += 0x1000;
		CMP		EAX,[ESP+12+8]			; if (i <= end) goto mts_loop;
		JBE		mts_loop
		POP		EBX
		POP		ESI
		POP		EDI
		RET
mts_fin:
		MOV		[EBX], EDX				; *p = old;
		POP		EBX
		POP		ESI
		POP		EDI
		RET

_farjmp:		; void farjmp(int eip, int cs);
		JMP		FAR	[ESP+4]				; eip, cs
		RET

_farcall:		; void farcall(int eip, int cs);
		CALL	FAR	[ESP+4]				; eip, cs
		RET

_asm_hrb_api:
		; 처음부터 인터럽트 금지가 되어 있다
		PUSH	DS
		PUSH	ES
		PUSHAD		; 보존을 위한 PUSH
		MOV		EAX,1*8
		MOV		DS, AX			; DS만 OS용으로 한다
		MOV		ECX,[0xfe4]		; OS의 ESP
		ADD		ECX,-40
		MOV		[ECX+32], ESP		; 어플리케이션의 ESP를 보존
		MOV		[ECX+36], SS		; 어플리케이션의 SS를 보존

; PUSHAD 한 값을 시스템의 스택에 카피한다
		MOV		EDX,[ESP   ]
		MOV		EBX,[ESP+ 4]
		MOV		[ECX   ], EDX	; hrb_api에 건네주기 위해 카피
		MOV		[ECX+ 4], EBX	; hrb_api에 건네주기 위해 카피
		MOV		EDX,[ESP+ 8]
		MOV		EBX,[ESP+12]
		MOV		[ECX+ 8], EDX	; hrb_api에 건네주기 위해 카피
		MOV		[ECX+12], EBX	; hrb_api에 건네주기 위해 카피
		MOV		EDX,[ESP+16]
		MOV		EBX,[ESP+20]
		MOV		[ECX+16], EDX	; hrb_api에 건네주기 위해 카피
		MOV		[ECX+20], EBX	; hrb_api에 건네주기 위해 카피
		MOV		EDX,[ESP+24]
		MOV		EBX,[ESP+28]
		MOV		[ECX+24], EDX	; hrb_api에 건네주기 위해 카피
		MOV		[ECX+28], EBX	; hrb_api에 건네주기 위해 카피

		MOV		ES, AX		; 나머지 세그먼트(segment) 레지스터도 OS용으로 한다
		MOV		SS,AX
		MOV		ESP,ECX
		STI			; 겨우 인터럽트 허가

		CALL	_hrb_api

		MOV		ECX,[ESP+32]	; 어플리케이션의 ESP를 생각해 낸다
		MOV		EAX,[ESP+36]	; 어플리케이션의 SS를 생각해 낸다
		CLI
		MOV		SS,AX
		MOV		ESP,ECX
		POPAD
		POP		ES
		POP		DS
		IRETD		; 이 명령이 자동으로 STI 해 준다

_start_app:		; void start_app(int eip, int cs, int esp, int ds);
		PUSHAD		; 32비트 레지스터를 전부 보존해 둔다
		MOV		EAX,[ESP+36]	; 어플리케이션용의 EIP
		MOV		ECX,[ESP+40]	; 어플리케이션용의 CS
		MOV		EDX,[ESP+44]	; 어플리케이션용의 ESP
		MOV		EBX,[ESP+48]	; 어플리케이션용의 DS/SS
		MOV		[0xfe4], ESP		; OS용의 ESP
		CLI			; 변환중에 인터럽트가 일어나기를 원하지 않기 때문에 금지
		MOV		ES,BX
		MOV		SS,BX
		MOV		DS,BX
		MOV		FS,BX
		MOV		GS,BX
		MOV		ESP,EDX
		STI			; 변환 완료이므로 인터럽트 가능으로 되돌린다
		PUSH	ECX				; far-CALL를 위해서 PUSH(cs)
		PUSH	EAX				; far-CALL를 위해서 PUSH(eip)
		CALL	FAR [ESP]		; 어플리케이션을 호출한다

;	어플리케이션가 종료하는 곳으로 돌아온다

		MOV		EAX,1*8			; OS용의 DS/SS
		CLI			; 또 바꾸므로 인터럽트 금지
		MOV		ES,AX
		MOV		SS,AX
		MOV		DS,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		ESP,[0xfe4]
		STI			; 변환 완료이므로 인터럽트 가능으로 되돌린다
		POPAD	; 보존해 둔 레지스터를 회복
		RET
