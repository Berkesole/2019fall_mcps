DATAS SEGMENT
    ARRAY DB 100 DUP (0)
	MSG DB 'ENTER A NUMBER:','$'
	SIZEIN DB 0
DATAS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS
     
START:
	;段基址赋值
	MOV  AX,DATAS
    MOV  DS,AX
    ;提示输入
    LEA  DX,MSG
    MOV  AH,09H
    INT  21H
	;读取输入到AL
	MOV  AH,01H
	INT  21H
	;以十进制存储大小
	SUB  AL,30H
	MOV  [SIZEIN],AL
	;换行
	MOV  DL,0AH
	MOV  AH,02H
	INT  21H
	;填充二维数组，用十进制数填充
	MOV  CL,1
	MOV  DI,0
	;获取数组大小
	MOV  AL,[SIZEIN]
	MUL  AL
	;填充数组
A:	CMP  DI,AX
	;填充完毕，跳出
	JE   B
	MOV  ARRAY[DI],CL
	INC  CL
	INC  DI
	JMP  A
B:  MOV  SI,0 ;SI表示行
	MOV  DI,0 ;DI表示列
	MOV  CH,0 ;CH表示行或列的最大数目
	MOV  CL,[SIZEIN]
E:	CMP  SI,CX 
	JAE  C   ;比较SI和CX，如果 SI >= CX ，跳转到C结束
	CMP  DI,SI ;如果 DI = SI，表明这一行输出完了，输出下一行
	JA   D
	;获取行位置转为一维数组信息
	MOV  AL,[SIZEIN] 
	MUL  SI 
	MOV  AH,0 
	MOV  BX,AX 
	;获取输出元素
	MOV  AL,ARRAY[BX][DI] ;基址变址
	;十进制转为ASCII码
	ADD  AL,30H
	;一位数还是两位数
	CMP  AL,3AH
	;一位数直接输出
	JB   M
	;两位数的处理
	SUB  AL,30H
	MOV  AH,0
	MOV  DL,10
	;使用DIV获取十位和个位
	DIV  DL
	MOV  DL,AL
	;十位要保存，不然INT后就丢失了
	MOV  DH,AH
	;输出十位
	ADD  DL,30H
	MOV  AH,02H
	INT  21H
	;输出个位
	MOV  DL,DH
	ADD  DL,30H
	MOV  AH,02H
	INT  21H
	JMP  N
	;一位数的处理
M:  MOV  DL,AL
	MOV  AH,02H
	INT  21H
	;输出制表符，指向同一行的下一个数
N:  MOV  DL,09H
	MOV  AH,02H
	INT  21H
	INC  DI
	JMP  E
	;超出三角区域，行增加，列归零，输出换行
D:  INC  SI
	MOV  DI,0
	MOV  DL,0AH
	MOV  AH,02H
	INT  21H
	JMP  E
	;结束
C:  MOV  AX,4C00H
    INT  21H
         
CODES ENDS
END START
