SELECT 	BIT P3.2; bit chon mode
SLAV_1 	EQU 31H
SLAV_2 	EQU 32H
NOB		EQU 20H; luu gia tri so lan nhan nut
LCD_E	BIT	P3.3			
LCD_RS	BIT	P3.5
LCDADDR	EQU	6000H
LCD		BIT P3.4; bit kich hoat dong LCD
ORG 0000H
LJMP MAIN

ORG 0030H
MAIN: 
    MOV TMOD, #21H
    MOV TL1, #-3
    MOV TH1, #-3
    MOV SCON, #0D2H
	SETB TR1
    MOV P1, #0FFH
    MOV P2, #0FFH
	MOV NOB, #0
	MOV		DPTR, #LCDADDR
	ACALL	INIT_LCD
	ACALL	CLEAR

COMPARE:
    MOV TL0, #LOW(-50000); tao timer 0 delay luc chon mode
    MOV TH0, #HIGH(-50000)
    CLR TR0
    CLR TF0
    JB P3.2, SL2; chon mode

SL1:
    CLR TB8 
    CLR SM2
	ACALL	CLEAR	
	ACALL 	DISPLAYSTRING_1		
    MOV A, #SLAV_1
    ACALL PHAT 

    ACALL THU
    JB TF0, COMPARE
    CLR SM2
    CJNE A, #SLAV_1, COMPARE

TRANS_1: 
    SETB TB8
    MOV A, P1
    ACALL PHAT
    JZ COMPARE
    ACALL THU 
    JB TF0, COMPARE 
    CLR TB8
    CLR SM2
	CJNE A, #0FEH, XUAT_1; xem co nhan nut hay khong(1111 1110?)
	INC NOB; neu co tang so lan nhan nut len 1.
	ACALL WAIT_BUTTON; delay 250ms giam hien tuong rung phim
XUAT_1:
	MOV A, NOB; chuyen so lan nhan nut vao A
	ACALL   DOI_BCD; chuyen sang dang BCD
	ACALL 	HIEN_THI; xuat kieu BCD ra ma ASCII
    SJMP TRANS_1

SL2:
    CLR TB8 
    CLR SM2	
	ACALL	CLEAR	
	ACALL 	DISPLAYSTRING_2			
    MOV A, #SLAV_2
    ACALL PHAT 

    ACALL THU
    JB TF0, COMPARE
    CLR SM2
    CJNE A, #SLAV_2, COMPARE
	
TRANS_2: 
    SETB TB8
    MOV A, P1
    ACALL PHAT
    JZ COMPARE

    ACALL THU 
    JB TF0, COMPARE
	MOV R1,A
	ACALL THU
	MOV R2,A
//	MOV A,#20H
//	ACALL WRITETEXT
	MOV R3,#3FH
	ACALL HIEN_THI
	MOV A,#'C'
	ACALL WRITETEXT
    CLR TB8
    CLR SM2
 //   MOV P2, A
    SJMP TRANS_2

PHAT:
    JNB TI,$
    CLR TI
    MOV SBUF,A
    RET

THU:
    SETB TR0
OT: JB TF0, ET
    JNB RI, OT    
    MOV TL0, #LOW(-50000); neu quá 50ms chua thu xong thì reset
    MOV TH0, #HIGH(-50000)
    CLR TR0
    CLR TF0
    MOV A,SBUF
    CLR RI
ET: RET

DOI_BCD: 	MOV B,#100
			DIV AB
			MOV R1, A
			MOV A,B
			MOV B, #10
			DIV AB
			MOV R2,A
			MOV R3, B
			RET

HIEN_THI:
			MOV A, #0C0H
			ACALL WRITECOM
			MOV A,#30H
			ADD A, R1
			ACALL WRITETEXT
			MOV A,#30H
			ADD A, R2
			ACALL WRITETEXT
			MOV A,#30H
			ADD A, R3
			ACALL WRITETEXT
			RET

INIT_LCD:				  	 	
			MOV		A, #38H			   
			ACALL	WRITECOM		
			MOV		A, #0FH				
			ACALL	WRITECOM		
			MOV		A, #06H				  
			ACALL	WRITECOM		   
			RET

CLEAR:
			MOV		A, #01H				 
			ACALL	WRITECOM		
			RET

WRITECOM:	 				
			CLR 	LCD; kich LCD hoat dong
			MOV		DPTR, #LCDADDR 	
			SETB	LCD_E			  
			CLR		LCD_RS			  
			MOVX	@DPTR, A		  
			CLR		LCD_E 
			ACALL	WAIT_LCD		  
			RET
		
WRITETEXT:						
			CLR 	LCD; kich LCD hoat dong
			MOV		DPTR, #LCDADDR 			
			SETB	LCD_E				 
			SETB	LCD_RS				  
			MOVX	@DPTR, A			  
			CLR		LCD_E					
			ACALL	WAIT_LCD				 
			RET

WAIT_LCD:					   
			MOV		R6,#10				 
	DL1:			
			MOV		R7, #250			
			DJNZ 	R7, $
			DJNZ 	R6,DL1
			RET

WAIT_BUTTON:					   
			MOV R7, #3
		LP2:
			MOV R6,#200
		LP1:
			MOV R5,#250
			DJNZ R5,$
			DJNZ R6, LP1
			DJNZ R7, LP2
			RET

DISPLAYSTRING_1:					 
			PUSH 	0
			MOV		A,#0				
LOOP_1:
			MOV		DPTR, #MESS_SL1		
			MOV		R0,A				 
			MOVC	A,@A+DPTR			
			JZ 		EXIT_1					 		
			ACALL	WRITETEXT 			 
			MOV		A,R0				
			INC		A					
			SJMP	LOOP_1			  
EXIT_1:			
			POP 0
			RET

DISPLAYSTRING_2:					 
			PUSH 	0
			MOV		A,#0				
LOOP_2:
			MOV		DPTR, #MESS_SL2
			MOV		R0,A				 
			MOVC	A,@A+DPTR			
			JZ 		EXIT_2			 		
			ACALL	WRITETEXT 			 
			MOV		A,R0				
			INC		A					
			SJMP	LOOP_2			  
EXIT_2:			
			POP 0
			RET
TINH_BCD:
MOV B,#10
DIV AB
MOV 60H,A
MOV 61H,B
RET
			
MESS_SL1:	DB "SO LAN NHAN NUT: ", 0
MESS_SL2:	DB "TEMPERATURE:", 0

END
