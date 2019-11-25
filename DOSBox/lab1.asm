DATAS SEGMENT
    MAKEINFILE  DB  'Input1.txt',0
    MAKEOUTFILE  DB  'Output1.txt',0
    BUF DB 100,?,100 DUP ('$')
    TEMP  DB  100 DUP  ('$')
    HANDLEIN  DW  ?
    HANDLEOUT  DW  ?
DATAS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,ES:DATAS
     
START:
    MOV  AX,DATAS
    MOV  DS,AX
    MOV  ES,AX
    ;建立文件INPUT1.TXT
    LEA  DX,MAKEINFILE
    MOV  CX,0000H
    MOV  AH,3CH
    INT  21H
    MOV  HANDLEIN,AX
    ;建立文件OUTPUT1.TXT
    LEA  DX,MAKEOUTFILE
    MOV  CX,0000H
    MOV  AH,3CH
    INT  21H
    MOV  HANDLEOUT,AX
    ;键盘读入缓冲区
    LEA  DX,BUF
    MOV  AH,0AH
    INT  21H
    ;写入文件INPUT1.TXT
    MOV  BX,HANDLEIN
    XOR  CH,CH
    MOV  CL,[BUF+1]
    LEA  DX,BUF+2
    MOV  AH,40H
    INT  21H
    ;关闭文件INPUT1.TXT
    MOV  AH,3EH
    INT  21H
    ;打开文件INPUT1.TXT
    LEA  DX,MAKEINFILE
    MOV  AX,3D00H
    INT  21H
    MOV  HANDLEIN,AX
    ;读取文件INPUT1.TXT
    LEA  DX,TEMP
    XOR  CH,CH
    MOV  CL,[BUF+1]
    MOV  BX,HANDLEIN
    MOV  AH,3FH
    INT  21H
    ;变换大小写
    CLD
    LEA  SI,TEMP
	LEA  DI,TEMP
A:  LODSB
    CMP AL,61H
    JB  B
	CMP AL,7aH
	JA  B
	SUB  AL,20H
B:  STOSB
	MOV  DL,AL
    MOV  AH,02H
    INT  21H
	LOOP A
	;打开文件OUTPUT1.TXT
	LEA  DX,MAKEOUTFILE
    MOV  AX,3D01H
    INT  21H
    MOV  HANDLEOUT,AX
    ;写入文件OUTPUT1.TXT
    MOV  BX,HANDLEOUT
    XOR  CH,CH
    MOV  CL,[BUF+1]
    LEA  DX,TEMP
    MOV  AH,40H
    INT  21H
    ;关闭文件OUTPUT1.TXT
    MOV  AH,3EH
    INT  21H
    ;关闭文件INPUT1.TXT
    MOV  BX,HANDLEOUT
    MOV  AH,3EH
    INT  21H
    ;终止
    MOV  AX,4C00H
    INT  21H
         
CODES ENDS
END START
