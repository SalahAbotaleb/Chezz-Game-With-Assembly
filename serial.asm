EXTRN SendROLD:WORD
EXTRN SendCOLD:WORD

EXTRN SendRNEW:WORD
EXTRN SendCNEW:WORD

PUBLIC SEND,RECIEVE,RecievedROLD,RecievedCOLD,RecievedRNEW,RecievedCNEW,INITCONECT,Exist,valueR,goOutY
include mymacros.inc
.286
.MODEL SMALL
.STACK 64
.DATA
RecievedROLD DW -1
RecievedCOLD DW -1

RecievedRNEW DW -1
RecievedCNEW DW -1

Exist DB 0
valueR DB -1
goOutY DB 0
;/********************/
.code
INITCONECT PROC FAR   
    pusha            
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
    popa
  RET
INITCONECT ENDP

SEND PROC FAR   
    pusha  
    	mov dx , 3FDH		; Line Status Register
AGAIN1:  	In al , dx 			;Read Line Status
  		AND al , 00100000b
  		JZ AGAIN1
          
    mov dx , 3F8H		; Transmit data register
  	mov  AX,SendROLD
  	out dx , AX 

	mov dx , 3FDH		; Line Status Register
AGAIN2:  	In al , dx 			;Read Line Status
  		AND al , 00100000b
  		JZ AGAIN2

    mov dx , 3F8H		; Transmit data register
  	mov  AX,SendCOLD
  	out dx , AX 

	mov dx , 3FDH		; Line Status Register
AGAIN3:  	In al , dx 			;Read Line Status
  		AND al , 00100000b
  		JZ AGAIN3

    mov dx , 3F8H		; Transmit data register
  	mov  AX,SendRNEW
  	out dx , AX 

	mov dx , 3FDH		; Line Status Register
AGAIN4:  	In al , dx 			;Read Line Status
  		AND al , 00100000b
  		JZ AGAIN4

    mov dx , 3F8H		; Transmit data register
  	mov  AX,SendCNEW
  	out dx , AX 
    popa
  RET
SEND ENDP

RECIEVE PROC FAR               
     pusha
    ;Check that Data Ready
	    mov dx , 3FDH		; Line Status Register
	    in al , dx 
  		AND al , 1
      JNZ GoIN
      jmp far ptr GoOut
      GoIN:
      mov exist,4
      mov ah,0
      mov al,exist
     ;If Ready read the VALUE in Receive data register
      mov dx , 03F8H
  		in al , dx 
      ;********;

      cmp al,3Eh
     jne contck
      mov goOutY,1
      jmp goout
     contck:

    cmp al,'Z'
    ja Ascii2
    cmp al,'A'
    jae chatR

    Ascii2:cmp al,'z'
    ja Ascii3
    cmp al,'a'
    jae chatR
    Ascii3:cmp al,08h
    je chatR
    cmp al,20h
    je chatR
    jne bcontck
    chatR:mov valueR,al
    jmp GoOut
      ;********;
    bcontck:
    
      MOV AH,0
  		mov  RecievedROLD , AX
      

      ww:mov dx , 3FDH		; Line Status Register
	    in al , dx 
  		AND al , 1
      jz ww

      mov dx , 03F8H
  		in al , dx 
      MOV AH,0
  		mov  RecievedCOLD , AX

      ww2:
      mov dx , 3FDH		; Line Status Register
	    in al , dx 
  		AND al , 1
      jz ww2

      mov dx , 03F8H
  		in al , dx 
      MOV AH,0
  		mov  RecievedRNEW , AX


      ww3:
      mov dx , 3FDH		; Line Status Register
	    in al , dx 
  		AND al , 1
      jz ww3
      mov dx , 03F8H
  		in al , dx 
      MOV AH,0
  		mov  RecievedCNEW , AX
      
    
    GoOut:
    popa
  RET
RECIEVE ENDP
END 