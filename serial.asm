include mymacros.inc
.286
.MODEL SMALL
.STACK 64
.DATA
SendCurPosR DB 0d
SendCurPosC DB 0d
RecCurPosR DB 13d
RecCurPosC DB  0d

HoldDataFS DB 0d
HolDataS DB 0d

RecievedData DB 0

PrimaryN DB 'ZAHAR:$'
secondaryN DB 'SALAH:$'
.code
MAIN    PROC FAR               
        MOV AX,@DATA
        MOV DS,AX    
    clearscreen
    ;/********************/
    mov dx,3fbh 			; Line Control Register
    mov al,10000000b		;Set Divisor Latch Access Bit
    out dx,al				;Out it
    ;/********************/
    mov dx,3f8h			
    mov al,0ch			
    out dx,al
    ;/********************/
    mov dx,3f9h
    mov al,00h
    out dx,al
    ;/********************/
    mov dx,3fbh
    mov al,00011011b
    ;0:Access to Receiver buffer, Transmitter buffer
    ;0:Set Break disabled
    ;011:Even Parity
    ;0:One Stop Bit
    ;11:8bits
    out dx,al
    ;/********************/
    movecursorlocation SendCurPosC,SendCurPosR,0
    DisplayString PrimaryN
    movecursorlocation RecCurPosC,RecCurPosR,0
    DisplayString SecondaryN
    
    mov SendCurPosC,-1
    mov RecCurPosC,-1
    
    inc SendCurPosR
    inc RecCurPosR

    drawhorizontallineinetextmode 12
    ;/********************/
    checkSendOrRec: 
    mov al,HoldDataFS
    cmp al,1
    jz SendData
    
    mov ah,1
    int 16h
    jz checkRec
    mov HolDataS,al

    mov al,9
    mov ah,0CH
    INT 21h
    ;/********************/
    SendData:
    mov dx , 3FDH		; Line Status Register
    In al , dx 	;Read Line Status
  	AND al , 00100000b
  	JZ HoldData
    mov HoldDataFS,0
    mov dx , 3F8H		; Transmit data register
  	mov  al,HolDataS
  	out dx , al 

    cmp SendCurPosC,79d
    JNE checkRow
    inc SendCurPosR
    mov SendCurPosC,-1
    checkRow:
    inc SendCurPosC
    cmp SendCurPosR,12d
    JE checkRec                                 ;for project edit
    movecursorlocation SendCurPosC,SendCurPosR,0
    
    mov ah,2 
    mov dl,HolDataS
    int 21h
    jmp checkRec
    ;/********************/
    HoldData:
    mov HoldDataFS,1
    ;/********************/
    
    checkRec:
    ;Check that Data Ready
	    mov dx , 3FDH		; Line Status Register
	    in al , dx 
  		AND al , 1
        JNZ GoCont
        jmp far ptr checkSendOrRec
        GoCont:
     ;If Ready read the VALUE in Receive data register
  		mov dx , 03F8H
  		in al , dx 
  		mov  RecievedData , al

    ;/********************/
    cmp RecCurPosC,79d
    JNE checkRowR
    inc RecCurPosR
    mov RecCurPosC,-1
    checkRowR:
    inc RecCurPosC
    cmp RecCurPosR,12d
    JE exit                                 ;for project edit
    movecursorlocation RecCurPosC,RecCurPosR,0
    
    mov ah,2 
    mov dl,RecievedData
    int 21h

    exit:jmp far ptr checkSendOrRec
    ;/********************/
    returntoconsole
MAIN    ENDP
END MAIN