;DisplayString STR -----displays string location STR
;DisplayStringGraphicMode ----- displays string location STR in graphics mode using string size and choosing which row and column
;ReadstringMsg PromptMsg,Outputloc----- takes string location promtmsg and displays it then ,puts it in location Outputloc
;Readstring Outputloc ----- puts string in location Outputloc
;Displaynumber ----- displays number stored in ax as decimal number
;DisplaynumberGraphicMode ----- displays decimal number in graphics mode
;ReadNumberMsg PromptMsg,outputloc ----- read a number and stores in ax with a message PromptMsg,also puts it in location Outputloc as ascii
;ReadNumber outputloc ----- read a number and stores in ax with no message output,also puts it in location Outputloc as ascii,no output msg on screen
;printnewline ----- goes to the next line
;returntoconsole ----- used at the end of the program
;clearscreen ----- clears the screen
;drawvertline x1,y1,x2,y2,color ----- draws a vertical line from (x1,y1) to (x2,y2) in the color {color}
;drawHorizline x1,y1,x2,y2,color ----- draws a hosrizontal line from (x1,y1) to (x2,y2) in the color {color}
;DisplaynumberAtloaction x,y ----- displays number at location (x1,y1)
;prntSCol ----- not working yet
;movecursorlocation x,y,pgn ----- moves cursor to a position x and y and pagenumber (pgn)
;Gotograpicsmode MACRO ----- changes mode to grapics mode
;GotoTextmode MACRO ----- changes mode to text mode
;drawhorizontallineinetextmode y ----- draws a horizontal line in text mode across the screen
;getcursorlocation MACRO ----- This function returns cursor location 
;printchar ----- print a character in text mode
;setCursor ----- sets cursor to a position x and y and pagenumber (0)
DisplayString MACRO STR
push ax
mov ah,9
mov dx,offset STR
int 21h 
pop ax
ENDM STR

DisplayStringGraphicMode MACRO STR,Size,Column,Row
pusha
mov si,@data;moves to si the location in memory of the data segment
mov ah,13h;service to print string in graphic mode
mov al,0;sub-service 0 all the characters will be in the same color(bl) and cursor position is not updated after the string is written
mov bh,0;Display page
mov bl,0Fh;color of the text
mov cx,Size;size of string
mov dl,Column
mov dh,Row
mov es,si;moves to es the location in memory of the data segment
mov bp,offset STR;mov bp the offset of the string
int 10h
popa
ENDM DisplayStringGraphicMode

ReadstringMsg MACRO PromptMsg,Outputloc
push ax
mov ah,9
mov dx,offset PromptMsg
int 21h 
mov ah,0AH
mov dx,offset outputloc
int 21h
pop ax
ENDM ReadstringMsg

Readstring MACRO Outputloc
push ax
mov ah,0AH
mov dx,offset outputloc
int 21h
pop ax
ENDM Readstring

Displaynumber MACRO ;displays number stored in ax as decimal number 
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

DisplaynumberGraphicMode Macro num,Column,Row
local equalsixteen,unitth,lessnine,ENDDD
pusha
mov  dl, Column  
mov  dh, Row   
mov  bh, 0    ;Display page
mov  ah, 02h  ;SetCursorPosition
int  10h

mov al, num
cmp num, 9
jbe lessnine
cmp num, 16
je equalsixteen

mov  al, num
shr  al, 3
add  al, '0'
mov  bl, 0Fh  ;Color is white
mov  bh, 0    ;Display page
mov  ah, 0Eh  ;Teletype
int  10h
jmp unitth

equalsixteen:
mov  al, num
shr  al, 4
add  al, '0'
mov  bl, 0Fh  ;Color is white
mov  bh, 0    ;Display page
mov  ah, 0Eh  ;Teletype
int  10h

unitth: 
inc dl
mov  al, num
sub  al, 10
add  al, '0'
mov  bl, 0Fh  ;Color is white
mov  bh, 0    ;Display page
mov  ah, 0Eh  ;Teletype
int  10h
jmp ENDDD

lessnine: 
mov  al, num
add  al, '0'
mov  bl, 0Fh  ;Color is white
mov  bh, 0    ;Display page
mov  ah, 0Eh  ;Teletype
int  10h
ENDDD:
popa
ENDM DisplaynumberGraphicMode

ReadNumberMsg MACRO PromptMsg,outputloc ;read a number and stores in ax with a message output
pusha

mov ah,9
mov dx,offset PromptMsg
int 21h 

mov ah,2 
mov dl,' '
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
 
pop a
ENDM ReadNumberMsg

ReadNumber MACRO outputloc ;read a number and stores in ax with no message output
pusha


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
 
pop a
ENDM ReadNumber

printnewline MACRO
    push ax
    push dx
    mov ah,2 
    mov dl,10
    int 21h
    
    mov ah,2 
    mov dl,13
    int 21h
    pop ax
    pop dx
ENDM printnewline

returntoconsole MACRO
    MOV AH,4CH
    INT 21H
ENDM returntoconsole 

clearscreen MACRO 
pusha
mov ax,0600h ;clear the screen
mov bh,07 
mov cx,0 
mov dx,184FH
int 10h


mov ah,2
mov dx,0 ;move cursor
mov bh,0 ;move to current screen
int 10h
popa
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


movecursorlocation MACRO x,y,pgn ;moves cursor to a position x and y and pagenumber (pgn)
pusha

mov bh,pgn
mov dh,y
mov dl,x
mov ah,2h
int 10h

popa   
ENDM movecursorlocation

Gotograpicsmode MACRO ;changes mode to grapics mode

pusha
mov ah, 0h
mov al, 13h
int 10h
popa

ENDM Gotograpicsmode

GotoTextmode MACRO ;changes mode to text mode

pusha
mov ax, 03h
int 10h
popa

ENDM GotoTextmode

drawhorizontallineinetextmode MACRO y ;draws a horizontal line in text mode across the screen
local hos
pusha
movecursorlocation -1,y,0H

mov cx,81d

hos:                    
pusha
mov ah,2H
mov dl,2dh
int 21h
popa

loop hos

popa
ENDM drawhorizontallineinetextmode 

getcursorlocation MACRO ;This function returns cursor location 

push ax
mov ah,3h
mov bh,0h
int 10h
pop ax

ENDM getcursorlocation

insert MACRO row,col

pusha
mov bx,head
mov ax,0
mov cx,0

mov al,row
mov cl,col

mov storage[bx],al ;moving row
inc head
mov bx,head
mov storage[bx],cl ;moving col
inc head

popa
ENDM insert

remove MACRO row,col
local exit
pusha

cmp head,0
je exit

dec head

mov bx,head
mov ax,0
mov cx,0

mov cl,storage[bx] ;retrieving row
dec head
mov bx,head
mov al,storage[bx] ;retrieving col

mov row,al
mov col,cl

exit:
popa
ENDM remove

printchar MACRO x
mov ah,2   
mov dl,x
int 21h
ENDM printchar

setCursor MACRO x,y
mov ah,2
mov bh,0
mov dl,x
mov dh,y
int 10h
ENDM setCursor
;This is a macro to clear the upper half of the screen when it's compleltely full of charachters
scrollupper MACRO
pusha
mov ah, 6               
mov al, 1               ; number of lines to scroll
mov bh, 0               ; attribute
mov ch, 9              ; row top
mov cl, 25               ; col left
mov dh, 15             ; row bottom
mov dl, 39              ; col right
int 10h 
popa
ENDM scrollupper 
;-----------------------------------------------------------------------------------------------
;This is a macro to clear the lower half of the screen when it's compleltely full of charachters

scrolllower MACRO
pusha
mov ah, 6               
mov al, 1               ; number of lines to scroll
mov bh, 0               ; attribute
mov ch, 18              ; row top
mov cl, 25              ; col left
mov dh, 24              ; row bottom
mov dl, 39              ; col right
int 10h 
popa
ENDM scrolllower

saveCursorS MACRO
pusha
mov ah,3h
mov bh,0h
int 10h
mov initxS,dl
mov inityS,dh
popa
ENDM saveCursorS  
;---------------------------------------------------------------------------------------------------
;this is a macro to get the cursor position of the Receive mode in dx "we need to save the cursor position every time we go to revieve mode or send mode"
saveCursorR MACRO
pusha
mov ah,3h
mov bh,0h
int 10h
mov initxR,dl
mov inityR,dh
popa
ENDM saveCursorR 

setCursor MACRO x,y
pusha
mov ah,2
mov bh,0
mov dl,x
mov dh,y
int 10h
popa
ENDM setCursor

printcharGraphics MACRO x,color
pusha
mov  al, x
mov  bl, color
mov  bh, 0    ;Display page
mov  ah, 0Eh
int  10h
popa
ENDM printcharGraphics

printcharGraphicsR MACRO x,color
pusha
mov  al, x
mov  bl, color
mov  bh, 0    ;Display page
mov  ah, 9
mov cx,1
int  10h
popa
ENDM printcharGraphicsR

concatStr MACRO str1,str2,dest
local newstr,newstr2,chck2,ext
pusha
mov si,0
mov bx,0

newstr:
mov al,str1[si]
mov dest[bx],al
inc si
inc bx
mov al,0
cmp str1[si],'$'
je chck2
cmp str1[si],13d
je chck2
jmp newstr
chck2:

mov dest[bx],' '
inc bx
mov si,0

newstr2:
mov al,str2[si]
mov dest[bx],al
inc si
inc bx
cmp str2[si],'$'
je ext
cmp str2[si],13d
je ext
jmp newstr2
ext:
popa
endm concatStr

filtername MACRO origin,dest
local newstr,incr,Lcheck,ext,fext,repeat,goout
mov si,0
mov bx,0
newstr2:
mov al,origin[si]
cmp al,64
jbe incr
mov dest[bx],al
inc bx
incr:inc si
cmp origin[si],'$'
je Lcheck
 
jmp newstr2
Lcheck:
dec bx
dec si
mov al,dest
cmp al,dest[bx]
je ext
mov al,dest[bx]
mov si,bx
dec si
repeat:
cmp si,-1
je fext
mov ah,dest[si]
mov dest[bx],ah
dec bx
dec si
jmp repeat
ext:
mov dest[bx],'$'
jmp goout
fext:
mov dest[bx],al
goout:
ENDM