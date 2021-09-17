
SLAV_1 EQU 31H
ORG 0000H
LJMP MAIN

ORG 0030H
MAIN: 
    MOV TMOD, #20H
    MOV TL1, #-3
    MOV TH1, #-3
    MOV SCON, #0D2H
	SETB TR1
    SETB TB8
    MOV P1, #0FFH
    MOV P2, #0FFH
    CLR F0
N_COM:
    CLR SM2
COM:
    ACALL THU
    JB RB8, DT
CHECK:
    CJNE A, #SLAV_1, MUT
    SETB SM2
    MOV A, #SLAV_1
    ACALL PHAT
DT: 
	JNB SM2, MUT
    CLR SM2
	ACALL THU
    JNB RB8, CHECK
    SETB SM2
    MOV P2, A
    JZ N_COM
    MOV A, P1
	CJNE A, #0FEH, XUAT_1; xem co nut nhan chua
	ACALL DELAY10MS; delay giam hien tuong rung phim
XUAT_1:
	ACALL PHAT
    SJMP DT
MUT:
    MOV A, P1
    MOV P2, A
    SJMP COM

PHAT:
    JNB TI,$
    CLR TI
    MOV SBUF,A
    RET

THU:
    JNB RI,$
    MOV A,SBUF
    CLR RI
    RET
	
DELAY10MS:
			MOV R6,#40
		LP1:
			MOV R5,#250
			DJNZ R5,$
			DJNZ R6, LP1
			RET
END