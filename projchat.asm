scrollupper MACRO
   
mov ah, 6               
mov al, 1               ; number of lines to scroll
mov bh, 7               ; attribute
mov ch, 1               ; row top
mov cl, 0               ; col left
mov dh, 10              ; row bottom
mov dl, 79              ; col right
int 10h 
  
ENDM scrollupper 


scrolllower MACRO
   
mov ah, 6               
mov al, 1               ; number of lines to scroll
mov bh, 7               ; attribute
mov ch, 13              ; row top
mov cl, 0               ; col left
mov dh, 22              ; row bottom
mov dl, 79              ; col right
int 10h 

ENDM scrolllower

saveCursorS MACRO
mov ah,3h
mov bh,0h
int 10h
mov initxS,dl
mov inityS,dh
ENDM saveCursorS  

saveCursorR MACRO
mov ah,3h
mov bh,0h
int 10h
mov initxR,dl
mov inityR,dh
ENDM saveCursorR 

include mymacros.inc
.MODEL SMALL
.STACK 64
.DATA
 
LINE  db 80 dup('-'),'$'
firstname db "First Name:-$"
secondname db "Second Name:-$"
returnmsg db "- To end Chat. Press Esc$"
VALUE  db ?     ;VALUE which will be sent or Received by user
initxS db 0     ;initial position for sender column
inityS db 1     ;initial position for sender row
initxR db 0     ;initial position for receiver column
inityR db 13    ;initial position for receiver row
receivermsg db  159 dup('$')                                       

.CODE

main proc far
    mov ax,@data
    mov ds,ax
     
; set divisor latch access bit

mov dx,3fbh 			; Line ContLinerol Register
mov al,10000000b		;Set Divisor Latch Access Bit
out dx,al               ;Out it

;Set LSB byte of the Baud Rate Divisor Latch register.

mov dx,3f8h			
mov al,0ch			
out dx,al

;Set MSB byte of the Baud Rate Divisor Latch register.

mov dx,3f9h
mov al,00h
out dx,al

;Set port configuration
mov dx,3fbh
mov al,00011011b
out dx,al     

;interface 

   mov ah, 0        ;text mode
   mov al, 3
   int 10h
   
   mov ax, 3        ;clear screen
   int 10h

   mov ah, 9
   mov dx, offset firstname
   int 21h 

   setCursor 0,11       ;setting cursor to middle of screen to printc the seperation line

   mov ah, 9
   mov dx, offset LINE
   int 21h

   setCursor 0,12

   mov ah, 9
   mov dx, offset secondname
   int 21h

   setCursor 0,23       ;setting cursor to end of screen to print the seperation line for the return message

   mov ah, 9
   mov dx, offset LINE
   int 21h   

   setCursor 0,24

   mov ah, 9
   mov dx, offset returnmsg
   int 21h

   setCursor 0,1        ;setting cursor to start the chatting


call chatting

chatting proc

mainloop:

mov ah,1    ;check if a key is pressed
int 16h
jz jumpReceive   ;if not then jmp to recieving mode
jnz send         ;if yes jmp to send mode


send:

mov ah,0   ;clear buffer
int 16h

mov VALUE,al  ; save the key ascii code in al

CMP al, 08h   ; backpace
jnz ENTERS
cmp initxS, 0   ; check if it not the end of line from the left
JE backlines
dec initxS
setCursor initxS,inityS     ;first dec the x_position then set cursor then print space, then we put the cursor back by incrementing the x_position
printchar ' '
inc initxS
setCursor initxS,inityS

backlines: cmp initxS, 0
jne ENTERS
cmp inityS, 1   ;if it is the end of line from left and not the first row, then backspace will set cursor to the end of the line above line from the right
je ENTERS
dec inityS
setCursor 80,inityS
saveCursorS

ENTERS: CMP al,0Dh    ; check if the key is enter
jnz ContLineS
jz newlineS

jumpReceive: jmp Receive


newlineS:
CMP inityS,10   ;check if the cursor is in the bottom of the upper screen to scrollup one line
jnz notlastlineS
scrollupper
setCursor 0,10
jmp printcharS
 
notlastlineS:inc inityS     
mov initxS,0

ContLineS:
setCursor initxS,inityS  ; setting the cursor after newlineS
CMP initxS,79           ; here we need to check when the x passes 79 so go to a newline
JZ CheckBottomS               ; so we must check if it is in the bottom line or not
jnz printcharS

CheckBottomS:CMP inityS,10    ;check if the cursor is in the bottom of the upper screen to scrollup one line
JNZ printcharS
scrollupper
setCursor 0,10 


printcharS:mov ah,2          ; printing the char
mov dl,VALUE
int 21h
  
;Check that Transmitter Holding Register is Empty

mov dx,3FDH 		; Line Status Register
AGAIN:In al , dx 	;Read Line Status
test al , 00100000b
jz Receive          ; Not empty

;If empty put the VALUE in Transmit data register

mov dx , 3F8H		; Transmit data register
mov al,VALUE        
out dx , al         

CMP al,27           ; check Esc key to end chatting mode
JZ jumpExit
saveCursorS          
jmp mainloop        


jumpSend:jmp send

jumpExit:jmp exit

Receive:

mov ah,1            ;check if there is key pressed then go to the sending mode
int 16h
jnz jumpSend

;Check that Data Ready

mov dx , 3FDH		; Line Status Register
in al , dx 
test al , 1
JZ Receive

;mov cx, 0

;If Ready read the VALUE in Receive data register

mov dx , 03F8H
in al , dx 
mov VALUE,al

CMP al, 08h   ; backpace
jnz ENTERR
cmp initxR, 0
JE backliner
dec initxR
setCursor initxR,inityR
printchar ' '
inc initxR
setCursor initxR,inityR

backliner:cmp initxR,0
jne ENTERR
cmp inityR, 13
je ENTERR
dec inityR
setCursor 80,inityR
saveCursorR

ENTERR:CMP VALUE,27            ;check if the Received data is Esc key to end chatting mode
JZ  jumpExit


CMP VALUE,0Dh           ;check if the key pressed is enter
JNZ ContLineR
JZ newlineR

newlineR:
cmp inityR,22           ;check if the cursor is in the bottom of the lower screen to scrollup one line
jnz notlastlineR
scrolllower
setCursor 0,22
jmp printcharR

notlastlineR: inc inityR
mov initxR,0

ContLineR:
setCursor initxR,inityR     ; setting the cursor after newlineR
CMP initxR,79               ; here we need to check when the x passes 79 so go to a newline
JZ CheckBottomR                  ; so we must check if it is in the bottom line or not
jnz printcharR

CheckBottomR: cmp inityR,22     ;check if the cursor is in the bottom of the lower screen to scrollup one line
jnz printcharR
scrolllower
setCursor 0,22

printcharR:mov ah,2             ; printing the char
mov dl,VALUE
int 21h

saveCursorR

jmp mainloop        


chatting endp


exit:

;; HERE SHOULD BE THE RETURN TO THE MAIN MENU
;--------------------------------------------
;--------------------------------------------
;--------------------------------------------
;--------------------------------------------

mov ah, 4ch
int 21h

main endp

end main