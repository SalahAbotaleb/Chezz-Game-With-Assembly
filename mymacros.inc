DisplayString MACRO STR
mov ah,9
mov dx,offset STR
int 21h 
ENDM STR

Readstring MACRO PromptMsg,Outputloc
mov ah,9
mov dx,offset PromptMsg
int 21h 
mov ah,0AH
mov dx,offset outputloc
int 21h
ENDM Readstring

Displaynumber MACRO
local lbl1,lbl2
pusha

mov bx,10d
mov cx,0

lbl1:
mov dx,0 
div bx
add dl,'0'
push dx
inc cx 
cmp ax,0
jnz lbl1

lbl2:
mov ah,2 
pop dx
int 21h
loop lbl2

popa

ENDM Displaynumber

ReadNumber MACRO PromptMsg,outputloc
push bx

mov ah,9
mov dx,offset PromptMsg
int 21h 
mov ah,0AH
mov dx,offset outputloc
int 21h

mov di,offset outputloc+2
mov cx,0
mov cl,outputloc+1 ;to get size of number entered by user
mov ax,0
lbl1:
mov bx,10d
mul bx

mov bl,[di]
mov bh,0
sub bl,'0'
add ax,bx
inc di
loop lbl1 
 
pop bx
ENDM ReadNumber

printnewline MACRO
    pusha
    mov ah,2 
    mov dl,10
    int 21h
    
    mov ah,2 
    mov dl,13
    int 21h
    popa
ENDM printnewline

returntoconsole MACRO
    MOV AH,4CH
    INT 21H
ENDM returntoconsole 

clearscreen MACRO 
mov ax,0600h ;clear the screen
mov bh,07 
mov cx,0 
mov dx,184FH
int 10h


mov ah,2
mov dx,0 ;move cursor
mov bh,0 ;move to current screen
int 10h

ENDM clearscreen

drawvertline  MACRO x1,y1,x2,y2,color 
    local back
    mov cx,x1 ;Column
    mov dx,y1 ;Row 
    mov al,color ;Pixel color
    mov ah,0ch ;Draw Pixel Command
back: int 10h 
 inc dx
 cmp dx,y2
 jnz back
ENDM drawvertline

drawHorizline  MACRO x1,y1,x2,y2,color 
    local back
    mov cx,x1 ;Column
    mov dx,y1 ;Row 
    mov al,color ;Pixel color
    mov ah,0ch ;Draw Pixel Command
back: int 10h 
 inc cx
 cmp cx,x2
 jnz back
ENDM drawhorizline

DisplaynumberAtloaction MACRO x,y

push ax
mov ah,2
mov dx,x ;move cursor
mov bh,y ;move to current screen
int 10h
pop ax

local lbl1,lbl2
pusha

mov bx,10d
mov cx,0

lbl1:
mov dx,0 
div bx
add dl,'0'
push dx
inc cx 
cmp ax,0
jnz lbl1

lbl2:
mov ah,2 
pop dx
int 21h
loop lbl2

popa

ENDM Displaynumber

prntSCol MACRO
local lbl1
pusha


lbl1:
mov ah,9 ;Display
mov bh,0 ;Page 0
mov al,[si]
mov cx,1 ;1 times
mov bl,0FAh ;Green (A) on white(F) background
int 10h

mov ah,86h
mov cx,10d
mov dx,10d
int 15h

mov ah,3h
mov bh,0h
int 10h

inc dl
mov ah,2
int 10h 

inc si
mov al,[si]
cmp al,'$'

jnz lbl1

popa
Endm prntSCol