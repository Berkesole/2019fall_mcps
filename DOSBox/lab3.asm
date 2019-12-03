DATAS SEGMENT
    FILENAME  DB  'Input3.txt',0
    BUF  DB  105 DUP ('$')
    TEMP  DW  100 DUP (0)
    HANDLE  DW  ?
    MYNUM  DW  ?
    RENUM  DW  0
    FLAG DB 0
DATAS ENDS
STACK SEGMENT STACK
	DB 100 DUP (0)
STACK ENDS
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,ES:DATAS,SS:STACK
START:
	;初始化段基址
    MOV  AX,DATAS
    MOV  DS,AX
    MOV  ES,AX
    MOV  AX,STACK
    MOV  SS,AX

	LEA  DX,FILENAME
	MOV  AX,3D00H
	INT  21H
	MOV  HANDLE,AX
	;读取文件
	LEA  DX,BUF
	MOV  BX,[HANDLE]
	MOV  CX,505			
	MOV  AH,3FH
	INT  21H
	MOV  [MYNUM],AX		
	LEA  SI,BUF
	LEA  DI,TEMP
	MOV  CX,0
T_BEGIN: 
	MOV  BL,[SI]
	CMP  BL,20H
	JNZ  B
	MOV  BL,[FLAG]
	CMP  BL,1
	JNZ  D
	XOR  AX,AX
	SUB  AX,CX
	MOV  CX,AX
D:  
	MOV  [DI],CX
	;数字数目+1
	MOV  CX,[RENUM]
	INC  CX
	MOV  [RENUM],CX
	;为存储下一个数，需清零CX和FLAG
	XOR  CX,CX
	MOV  [FLAG],0
	;DI+2，按字存储
	INC  DI
	INC  DI
	;读取分析下一个字节
	INC  SI
	JMP  T_BEGIN
B:
	CMP  BL,2DH
	JNZ  C
	MOV  [FLAG],1
	INC  SI
	JMP  T_BEGIN
C: 
	CMP  BL,0AH
	JNZ  E
	MOV  BL,[FLAG]
	CMP  BL,1
	JNZ  G
	XOR  AX,AX
	SUB  AX,CX
	MOV  CX,AX
	;补码存储
G:  MOV  [DI],CX
	;数字数目加1
	MOV  CX,[RENUM]
	INC  CX
	MOV  [RENUM],CX
	;清零CX和FLAG
	XOR  CX,CX
	MOV  [FLAG],0
	;排序
	JMP   F
E: 
	;CX已处理的部分
	;BL新读入的部分
	;CX = CX * 10
	MOV  AX,10
	MUL  CX
	MOV  CX,AX
	;CX = CX + BX
	SUB  BL,30H
	XOR  BH,BH
	ADD  CX,BX
	;处理下一个数
	INC  SI
	JMP  T_BEGIN
F:  MOV  DX,1
L3: MOV  CX,[RENUM]
	SUB  CX,DX
	MOV  SI,0 ;初始化
L2: MOV  AL,BYTE PTR [TEMP+SI]
	MOV  AH,BYTE PTR [TEMP+SI+1]
	MOV  BL,BYTE PTR [TEMP+SI+2]
	MOV  BH,BYTE PTR [TEMP+SI+3]
	CMP  AX,BX
	JL   LB
	MOV  [TEMP+SI+2],AX
	MOV  [TEMP+SI],BX
	JMP  L1
LB: MOV  [TEMP+SI+2],BX
	MOV  [TEMP+SI],AX
L1: ADD  SI,2
	LOOP L2
	INC  DX
	MOV  CX,[RENUM]
	SUB  CX,1
	CMP  CX,DX
	JNE  L3
	;显示MODEL
	MOV  SI,0
	MOV  CX,[RENUM]
Z:  MOV  AL,BYTE PTR [TEMP+SI]
	MOV  AH,BYTE PTR [TEMP+SI+1]
	TEST AH,10000000B
	JZ   POSITIVE		    ;跳转到正数的处理
	JNZ  NEGATIVE           ;负数处理
POSITIVE:
    CALL DIS_P
	ADD  SI,2
	MOV  DL,20H
	MOV  AH,02H
	INT  21H
	LOOP Z
	JMP  MYEND
NEGATIVE:
    MOV DL,2DH
	MOV  AH,02H
	INT  21H
	CALL DIS_N
	ADD  SI,2
	MOV  DL,20H
	MOV  AH,02H
	INT  21H
	LOOP Z
	;终止
MYEND:
    MOV  AX,4C00H
    INT  21H
DIS_P:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV  AL,BYTE PTR [TEMP+SI]
	MOV  AH,BYTE PTR [TEMP+SI+1]
    MOV  BL,10
    MOV  CX,0
YAZHAN_POSI:
    DIV  BL
    MOV  DL,AH
    XOR  AH,AH
    XOR  DH,DH
    PUSH DX
    INC  CX
    CMP  AL,0
    JZ   CHUZHAN_POSI
    JMP  YAZHAN_POSI    
CHUZHAN_POSI:
    POP  DX
    ADD  DL,30H
    MOV  AH,2
    INT  21H
    LOOP CHUZHAN_POSI
    POP  DX
    POP  CX
    POP  BX
    POP  AX
    RET
DIS_N:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV  AL,BYTE PTR [TEMP+SI]
	MOV  AH,BYTE PTR [TEMP+SI+1]
	NOT  AX
	ADD  AX,1
    MOV  BL,10
    MOV  CX,0
YAZHAN_NEGA:
    DIV  BL
    MOV  DL,AH
    XOR  AH,AH
    XOR  DH,DH
    PUSH DX
    INC  CX
    CMP  AL,0
    JZ   CHUZHAN_NEGA
    JMP  YAZHAN_NEGA
CHUZHAN_NEGA:
    POP  DX
    ADD  DL,30H
    MOV  AH,2
    INT  21H
    LOOP CHUZHAN_NEGA
    POP  DX
    POP  CX
    POP  BX
    POP  AX
    RET 
CODES ENDS
END START
