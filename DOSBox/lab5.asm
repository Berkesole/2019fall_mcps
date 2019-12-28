DATAS SEGMENT
    BUF DB 100,?,100 DUP ('$')
    TEMP  DW  100  DUP  ('$$')
	MSG DB 'ENTER:','$'
	FLAG DB 0
DATAS ENDS
STACK  SEGMENT STACK
	MYSTACK DW 100 DUP (0)
STACK ENDS
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,ES:DATAS,SS:STACK
START:
	;段基址赋值
	MOV  AX,DATAS
    MOV  DS,AX
    MOV  ES,AX
    MOV  AX,STACK
    MOV  SS,AX
    ;提示输入
    LEA  DX,MSG
    MOV  AH,09H
    INT  21H
	;读取输入到AL
	LEA  DX,BUF
	MOV  AH,0AH
	INT  21H
	;换行
	MOV  DL,0AH
	MOV  AH,02H
	INT  21H
	;转换后缀表达式
	;第一个字节存储在BUF+2
	LEA  SI,BUF+2
	;放在TEMP中
	LEA  DI,TEMP
	;清空CX,DX
	XOR  DX,DX
	XOR  CX,CX
	;DH：是否有一个数已分析但还未存储，1：是，0：否
	;DL：栈中的符号数
	;CX：存放刚分析完的数和分析一个数过程中的数
L0: MOV  BL,[SI]
	; (	
	CMP  BL,28H
	JNZ  L1
	;把左括号压栈
	XOR  BH,BH
	PUSH BX
	;栈中符号数目加一
	INC  DL
	;分析下一个字符
	INC  SI
	JMP  L0
L1: CMP  BL,29H	; )
	JNZ  L2
	;如果有一个数还未存储，先存储，没有就跳转到M0
	CMP  DH,1
	JNZ  M0
	MOV  [DI],CX
	;存储完成，CX归零
	XOR  CX,CX
	;由于按字存储，DI加二
	ADD  DI,2
	;存储完成，DH归零
	XOR  DH,DH
	;将一个字符出栈，栈中数目减一
M0: POP  BX
	DEC  DL
	;转换后缀表达式需要将栈中的符号和“(”比较
	;不是则输出到后缀表达式
	;是则弹出“左括号”，分析下一个字符
	;“)”从不入栈
R0: CMP  BX,0028H
	JNZ  R1
	;是“(”
	INC  SI
	JMP  L0
	;不是“(”
	;输出到后缀表达式
R1: MOV  [DI],BX
	ADD  DI,2
	;如果栈中没有符号，就不再弹出了，跳转到S3分析下一个字节
	CMP  DL,0
	JZ   S3
	;栈中还有字符，继续比对输出
	POP  BX
	DEC  DL
	JMP  R0
	;分析下一个字节
S3: JMP  L0
	;“+”“-”类似，不再具体注释
	;出栈的原则是：将遇上的第一个“(”之前的所有字符输出到后缀表达式
	;之后将自己入栈
L2: CMP  BL,2BH	; +
	JNZ  L3

	CMP  DH,1
	JNZ  D0
	;MOV  TEMP,CX
	
	MOV  [DI],CX
	XOR  CX,CX
	ADD  DI,2
	XOR  DH,DH
D0: CMP  DL,0
	JZ   S1
	POP  BX
	DEC  DL
R2: CMP  BX,0028H
	JNZ  R3
	PUSH BX
	INC  DL
S1: MOV  BX,002BH
	PUSH BX
	INC  DL
	INC  SI
	JMP  L0
R3: MOV  [DI],BX
	ADD  DI,2
	JMP  D0
	;POP  BX
	;DEC  DL
	;JMP  R2
L3: CMP BL,2DH ;-
	JNZ  L4

	CMP  DH,1
	JNZ  D1
	MOV  TEMP,CX

	MOV  [DI],CX
	XOR  CX,CX
	ADD  DI,2
	XOR  DH,DH
D1: CMP  DL,0
	JZ   S2
	POP  BX
	DEC  DL
R4: CMP  BX,0028H
	JNZ  R5
	PUSH BX
	INC  DL
S2: MOV  BX,002DH
	PUSH BX
	INC  DL
	INC  SI
	JMP  L0
R5: MOV  [DI],BX
	ADD  DI,2
	JMP  D1
	;POP  BX
	;DEC  DL
	;JMP  R4
	;文件以“0D0AH”结束，分析到0DH即可将所有符号出栈
	;注意数字也要存储
	;跳转到MYDO求值
L4: CMP  BL,0DH
	JNZ  L5
	CMP  DH,1
	JNZ  R6
	MOV  [DI],CX
	XOR  CX,CX
	ADD  DI,2
	XOR  DH,DH
R6: CMP  DL,0
	JZ   R7
	POP  BX
	DEC  DL
	MOV  [DI],BX
	ADD  DI,2
	JMP  R6
R7: JMP  MYDO
	;数字的处理
	;获取准确值
L5: SUB  BL,30H
	;CX = CX * 10 + BL
	MOV  AL,10
	MUL  CL
	MOV  CL,AL
	ADD  CL,BL
	;已经有数字被分析未存储，将DH置位
	MOV  DH,1
	INC  SI
	JMP  L0	
	;后缀表达式求

MYDO:
	;DI：源操作数的地址
	LEA  DI,TEMP
GETNUM:;严加控制，获取操作数
	MOV  CL,BYTE PTR [DI]
	MOV  CH,BYTE PTR [DI+1]
	;是“+”，弹出两个操作数相加，结果再存入
	CMP  CX,002BH	;+
	JNZ  MYMINUS
	POP  AX
	POP  BX
	ADD  AX,BX
	PUSH AX
	;分析下一个操作数
	ADD  DI,2
	JMP  GETNUM
MYMINUS:
	CMP  CX,002DH
	JNZ  A
	;是“-”，弹出两个操作数相减，结果再写入
	POP  BX
	POP  AX
	SUB  AX,BX
	PUSH AX
	;分析下一个操作数
	ADD  DI,2
	JMP  GETNUM
A:  CMP  CX,2424H
	;因为初始化为‘$’，所以是‘2424H’即为结束
	;弹出结果到AX，跳转到DIS显示
	JNZ  B
	POP  AX
	JMP  DIS
	;是数字，入栈
B:  PUSH CX
	ADD  DI,2
	JMP  GETNUM
DIS:TEST AH,10000000B
	JZ   POS			;跳转到正数的处理
	JNZ  MYNEG
	;正数的处理
POS:CALL DIS_P
	JMP  MYEND
	;负数的处理
MYNEG:
	CALL DIS_N
	;结束
MYEND:MOV  AX,4C00H
    INT  21H

DIS_P:PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ;MOV  AL,BYTE PTR [TEMP+SI]
	;MOV  AH,BYTE PTR [TEMP+SI+1]
    MOV  BL,10
    MOV  CX,0

YAZHAN_P:
    DIV  BL
    MOV  DL,AH
    XOR  AH,AH
    XOR  DH,DH
    PUSH DX
    INC  CX
    
    CMP  AL,0
    JZ   CHUZHAN_P
    JMP  YAZHAN_P
    
CHUZHAN_P:
    POP  DX
    ADD  DL,30H
    MOV  AH,2
    INT  21H
           
    LOOP CHUZHAN_P
    
    POP  DX
    POP  CX
    POP  BX
    POP  AX
    
    RET

DIS_N:PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ;MOV  AL,BYTE PTR [TEMP+SI]
	;MOV  AH,BYTE PTR [TEMP+SI+1]
	MOV  CX,AX
	MOV  DL,2DH
	MOV  AH,02H
	INT  21H
	MOV  AX,CX
	NOT  AX
	ADD  AX,1
    MOV  BL,10
    MOV  CX,0

YAZHAN_N:
    DIV  BL
    MOV  DL,AH
    XOR  AH,AH
    XOR  DH,DH
    PUSH DX
    INC  CX
    
    CMP  AL,0
    JZ   CHUZHAN_N
    JMP  YAZHAN_N
    
CHUZHAN_N:
    POP  DX
    ADD  DL,30H
    MOV  AH,2
    INT  21H
           
    LOOP CHUZHAN_N
    
    POP  DX
    POP  CX
    POP  BX
    POP  AX
    
    RET   
CODES ENDS
END START


