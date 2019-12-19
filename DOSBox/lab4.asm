CODES SEGMENT 
ASSUME CS:CODES,DS:CODES 
MAIN PROC
STRING DB 0DH,0AH,'INPUT A NUMBER(0-20):',0DH,0AH,'$' 
ERROR DB 0DH,0AH,"OUT OF RANGE! $" 
YN DB 0DH,0AH,'CONTINUE (YES) ? $' 
    C10 DW 10 ;输入十进制转换的数 
    N DW ? ;要求阶乘的数 
    M DW ? ;步长 
    C DW ? ;进位 
    I DW ?
    DW ? 
START: 
    PUSH CS 
    POP DS 
    MOV DX,OFFSET STRING 
    MOV AH,9 
    INT 21H 
    CALL SHURU 
    CMP BP,10000 
    JBE CS_OK 
    MOV DX,OFFSET ERROR 
    MOV AH,9 
    INT 21H 
    JMP START 
CS_OK: 
    MOV N,BP 
    MOV AX,0E0DH 
    INT 10H 
    MOV AL,0AH 
    INT 10H ;换行
    CALL FRACTOR 
    MOV CX,DI 
ROUTPUT: ;循环输出 
    PUSH CX 
    MOV DI,CX 
    CALL OUTPUT 
    POP CX 
    DEC CX 
    CMP CX,0 
    JGE ROUTPUT 
EXIT: 
    MOV AX,4C00H 
    INT 21H 
    MAIN ENDP 


SHURU PROC ;输入----------------------------------
    PUSH DX
    PUSH CX 
    PUSH BX 
    PUSH AX 
    XOR BP,BP 
    MOV BX,10 
    MOV CX,5 
INPUT: 
    MOV AH,0 ;键盘输入数据 
    INT 16H 
    CMP AL,0DH ;以回车结束输入 
    JZ OK 
    CMP AL,'0' ;只允许输入 0~9 
    JB INPUT 
    CMP AL,'9' 
    JA INPUT 
    MOV AH,0EH ; 显示有效输入 
    INT 10H 
    AND AX,000FH 
    XCHG AX,BP 
    MUL BX ; 扩大10倍 
    ADD BP,AX ; 加一位 
    LOOP INPUT 
OK:
    NOP ;数值结果放入 BP ;恢复用到的寄存器 
    POP AX 
    POP BX 
    POP CX 
    POP DX 
    RET 
    SHURU ENDP 


    


CODES ENDS 
END START