DrawBoard MACRO PrimaryC,SecondaryC,FileName,handle,dataloc,height,width
    local drawLoop
    ;primaryC is primary Color for the board which is at top left coener 
    ;secondaryC is secondart color next to first square 
    ;better to define primaryC and SecondaryC at begging of program
    pusha

    ;*************openning the file
    MOV AH, 3Dh
    MOV AL, 0 ; read only
    LEA DX, FileName
    INT 21h
    
    ; you should check carry flag to make sure it worked correctly
    ; carry = 0 -> successful , file handle -> AX
    ; carry = 1 -> failed , AX -> error code
    jnc noerror
    DisplayString errormsg
    noerror:
    MOV [handle], AX
    ;done opening the file

    ;**************Read the data from the file
    MOV AH,3Fh
    MOV BX, [handle]
    MOV CX,Width*Height ; number of bytes to read
    LEA DX, dataloc
    INT 21h
    ;************done reading the data from the file

    ;************close the file
    MOV AH, 3Eh
	MOV BX, [handle]
	INT 21h
    ;***********done closing the file

    ;***********Drawing the pixels
    LEA BX , dataloc ; BL contains index at the current drawn pixel
    MOV CX,0
    MOV DX,0
    MOV AH,0ch
    drawLoop:
    MOV AL,[BX]
    cmp al,1
    jnz filter
    mov al,SecondaryC
    jmp contin
    filter: mov al,PrimaryC
    contin:
    INT 10h 
    INC CX
    INC BX
    CMP CX,Width
    JNE drawLoop 
	
    MOV CX , 0
    INC DX
    CMP DX , Height
    JNE drawLoop
    ;************end drawing the pixels
    popa
ENDM DrawBoard

DrawPiece MACRO PrimaryC,SecondaryC,FileName,handle,dataloc,roffset,coffset,pieceColor,row,col,begr,begc,endr,endc,res
    local drawLoop,noerror,lblprim,lblsec,filter,contin
    ;primaryC is primary Color for the board which is at top left coener 
    ;secondaryC is secondart color next to first square 
    ;better to define primaryC and SecondaryC at begging of program
    ;row is from 0 to 7
    ;col is from 0 to 7
    ;piece color is the main color of the piece and secondary color will be background color
    ;roffset for row offset
    ;coffset for col offset
    pusha

    ;*************openning the file
    MOV AH, 3Dh
    MOV AL, 0 ; read only
    LEA DX, FileName
    INT 21h
    
    ; you should check carry flag to make sure it worked correctly
    ; carry = 0 -> successful , file handle -> AX
    ; carry = 1 -> failed , AX -> error code
    jnc noerror
    DisplayString errormsg
    noerror:
    MOV [handle], AX
    ;done opening the file

    ;**************Read the data from the file
    MOV AH,3Fh
    MOV BX, [handle]
    MOV CX,625d; number of bytes to read
    LEA DX, dataloc
    INT 21h
    ;************done reading the data from the file

    ;************close the file
    MOV AH, 3Eh
	MOV BX, [handle]
	INT 21h
    ;***********done closing the file

    ;***********Drawing the pixels
    mov ax,row
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,col
    mul cl
    ;now we have begging stored at ax for col begging
    ;and bx for row begging

    mov begr,0
    add begr,roffset
    add begr,bx

    mov begc,0
    add begc,coffset
    add begc,ax
     
    mov endr,bx
    mov endc,ax

    add endr,25d
    add endc,25d

    mov cx,0
    mov ah,0
    mov al,row
    mov bx,2
    div bl
    xor cl,ah

    mov ah,0
    mov al,col
    mov bx,2
    div bl
    xor cl,ah
    
    mov res,cl


    LEA BX , dataloc ; BL contains index at the current drawn pixel
    MOV CX,begc
    MOV DX,begr
    MOV AH,0ch
    drawLoop:
    MOV AL,[BX]
    cmp al,5
    ja filter
    cmp res,0
    jnz lblsec 
    lblprim:mov al,PrimaryC
    jmp contin
    lblsec:mov al,SecondaryC
    jmp contin
    filter: mov al,pieceColor
    contin:
    INT 10h 
    INC CX
    INC BX
    CMP CX,endc
    JNE drawLoop 
	
    MOV CX ,begc
    INC DX
    CMP DX ,endr
    JNE drawLoop
    ;************end drawing the pixels
    popa
ENDM DrawPiece

DrawPieceD MACRO PrimaryC,SecondaryC,dataloc,roffset,coffset,pieceColor,row,col,begr,begc,endr,endc,res
    local drawLoop,noerror,lblprim,lblsec,filter,contin
    ;primaryC is primary Color for the board which is at top left coener 
    ;secondaryC is secondart color next to first square 
    ;better to define primaryC and SecondaryC at begging of program
    ;row is from 0 to 7
    ;col is from 0 to 7
    ;piece color is the main color of the piece and secondary color will be background color
    ;roffset for row offset
    ;coffset for col offset
    pusha


    ;***********Drawing the pixels
    mov ax,row
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,col
    mul cl
    ;now we have begging stored at ax for col begging
    ;and bx for row begging

    mov begr,0
    add begr,roffset
    add begr,bx

    mov begc,0
    add begc,coffset
    add begc,ax
     
    mov endr,bx
    mov endc,ax

    add endr,25d
    add endc,25d

    mov cx,0
    mov ah,0
    mov ax,row
    mov bx,2
    div bl
    xor cl,ah

    mov ah,0
    mov ax,col
    mov bx,2
    div bl
    xor cl,ah
    
    mov res,cl


    LEA BX , dataloc ; BL contains index at the current drawn pixel
    MOV CX,begc
    MOV DX,begr
    MOV AH,0ch
    drawLoop:
    MOV AL,[BX]
    cmp al,5
    ja filter
    cmp res,0
    jnz lblsec 
    lblprim:mov al,PrimaryC
    jmp contin
    lblsec:mov al,SecondaryC
    jmp contin
    filter: mov al,pieceColor
    contin:
    INT 10h 
    INC CX
    INC BX
    CMP CX,endc
    JNE drawLoop 
	
    MOV CX ,begc
    INC DX
    CMP DX ,endr
    JNE drawLoop
    ;************end drawing the pixels
    popa
ENDM DrawPieceD

Drawsquare MACRO x,y,tmpx,tmpy,color
    local roow,cool
    ;x is row
    ;y is col
    pusha
    mov tmpx,0
    mov tmpy,0
    mov bx,x
    mov ax,0
    mov al,25d
    mul bl
    mov si,ax
    add al,25d
    mov tmpx,ax
    mov bx,y
    ;mov bl,y
    mov ax,25d
    mul bl
    mov bx,ax
    add ax,25d
    mov tmpy,ax
    dec tmpy
    dec tmpx

    dec bx
    dec si
    roow:
    inc bx
    cool:
    inc si
    mov cx,si ;col
    mov dx,bx ;Row 
    mov al,color ;Pixel color
    mov ah,0ch ;Draw Pixel Command
    int 10h 
    cmp cx,tmpx
    jnz cool
    sub si,25d
    cmp dx,tmpy
    jnz roow

    popa
ENDM Drawsquare

initchezz MACRO pic,row,col,t,chezzP,chezzT,n
;-1 means empty location
;t for type
pusha
lea si,chezzP
lea di,chezzT

mov bx,0
mov ax,8
mov bl,row
mul bl
add ax,col

add di,ax
mov bl,t
mov [di],bl

add ax,ax

add si,ax

lea ax,pic
mov [si],ax

popa
ENDM initchezz

deletechezz MACRO r,c,chezzP,chezzT
;-1 means empty location
pusha
lea si,chezzP
lea di,chezzT
mov ax,8
mov bl,r
mul bl
add ax,c

add si,ax
add di,ax
mov [di],-1

add si,ax
mov [si],-1

popa
ENDM deletechezz

deletechezzD MACRO r,c,chezzP,chezzT,begr,begc,res,PrimaryC,SecondaryC
local sec,con
;-1 means empty location
pusha
lea si,chezzP
lea di,chezzT
mov ax,8
mov bl,r
mul bl
add ax,c

add si,ax
add di,ax
mov bl,-1
mov [di],bl

add si,ax
mov ax,-1
mov [si],ax

 mov cx,0
    mov ah,0
    mov ax,r
    mov bx,2
    div bl
    xor cl,ah

    mov ah,0
    mov ax,c
    mov bx,2
    div bl
    xor cl,ah
    
    mov res,cl

    mov ax,0
    cmp res,0
    jnz sec 
    mov al,PrimaryC
    jmp con
    sec:mov al,SecondaryC
    con:mov res,al
    Drawsquare c,r,begr,begc,res
popa
ENDM deletechezzD


DrawPieceDB MACRO PrimaryC,SecondaryC,roffset,coffset,pieceColor,row,col,begr,begc,endr,endc,res
    ;/******DRAW PIECE FUNCTION WRAPPER********/
push bx
mov bx,row
mov rowW,bx

mov bx,col
mov colW,bx

mov bl,pieceColor
mov pieceColorW,bl

mov bl,PrimaryC
mov PrimaryCW,bl

mov bl,SecondaryC
mov SecondaryCW,bl

mov bl,res
mov resW,bl

mov bx,begr
mov begrW,bx

mov bx,begc
mov begcW,bx

mov bx,endr
mov endrW,bx

mov bx,endc
mov endcW,bx

mov bx,roffset
mov roffsetW,bx

mov bx,coffset
mov coffsetW,bx

call DrawPieceW

pop bx
ENDM DrawPieceDB

initchezzC MACRO PrimaryC,SecondaryC,chezzC,res
local redo,sec,con,exit
pusha
lea si,chezzC
mov cx,0
mov dx,0
;cx is pointing to row 
;dx is pointing to colomn

redo:
mov res,0
mov ax,cx
mov bx,2
div bl
xor res,ah
mov ax,dx
mov bx,2
div bl
xor res,ah
cmp res,0
jnz sec 
mov bx,0
mov bl,PrimaryC
mov [si],bl
jmp con
sec:
mov bx,0
mov bl,SecondaryC
mov [si],bl
con:
inc si
inc dx
cmp dx,8
jne redo
mov dx,0
inc cx
cmp cx,8
jnz redo
popa
ENDM initchezzC

getdb MACRO row,col
push ax
;places in bx the offset in the array
    mov al,8
    mov bx,row
    mul bl
    add ax,col
    mov bx,ax
pop ax 
ENDM getdb

getdW MACRO row,col
push ax
;places in bx the offset in the array
    mov al,8
    mov bx,row
    mul bl
    add ax,col
    add ax,ax
    mov bx,ax
pop ax 
ENDM getdW


drawSelf MACRO row,col
local typ,typ2,contDr,blackP,whiteP
;steps is max number
pusha
getdb row,col
mov ax,0
mov al,chezzT[bx]
mov chezzC[bx],0Ah
cmp ax,0Ah
ja blackP
jmp far ptr whiteP
    blackP: ;to be returned
    DrawPieceDB  0Ah,0Ah,0,0,0h,row,col,begr,begc,endr,endc,res
    jmp far ptr contDr
    whiteP:
    DrawPieceDB  0Ah,0Ah,0,0,0Fh,row,col,begr,begc,endr,endc,res
    contDr:
    
    mov ax,row
    mov cx,col
    mov tmpdbr,al
    mov tmpdbc,cl
    insert tmpdbr,tmpdbc
popa
ENDM drawSelf

;/**************************************************************************/


Drawup MACRO row,col,steps
local lop,exit,validate,typ,typ2,highlightg,highlightr,typn,typn2,cont1,cont2,cont3,cont4,cont5
;steps is max number
pusha

getdb row,col
mov ax,0
mov al,chezzT[bx]
cmp ax,0Ah
ja typ ;to be removed if needed
mov currtype,0
jmp typ2
typ:
mov currtype,1
typ2:
mov dx,0 ;counter
mov cx,row
mov ax,col
lop:
dec cx
cmp cx,0
jae cont1
jmp far ptr exit

cont1:
cmp cx,8
jb cont2
jmp far ptr exit

cont2:
cmp ax,0
jae cont3
jmp far ptr exit

cont3:
cmp ax,8
jb cont4
jmp far ptr exit

cont4:
mov tmpr,cx
mov tmpc,ax

getdb tmpr,tmpc

mov ax,0
mov al,chezzT[bx]
cmp al,-1
jne cont5
jmp far ptr highlightG
cont5:cmp ax,0Ah
ja typn ;to be removed if needed
mov nexttype,0
jmp typn2
typn:
mov nexttype,1
typn2:
mov bx,0
mov bl,currtype
mov bh,nexttype
xor bl,bh
cmp bl,0
jne highlightR
jmp far ptr exit
highlightR:
getdb tmpr,tmpc
mov chezzC[bx],4h
dec nexttype
and nexttype,0Fh
DrawPieceDB  4,4,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

jmp far ptr exit

highlightG:
getdb tmpr,tmpc
mov chezzC[bx],0Ah
dec nexttype
and nexttype,0Fh
DrawPieceDB  0Ah,0Ah,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

inc dx
cmp dx,steps
je exit
jmp far ptr lop
exit:
popa
ENDM Drawup


;/**************************************************************************/


Drawdown MACRO row,col,steps
local lop,exit,validate,typ,typ2,highlightg,highlightr,typn,typn2,cont1,cont2,cont3,cont4,cont5
;steps is max number
pusha

getdb row,col
mov ax,0
mov al,chezzT[bx]
cmp ax,0Ah
ja typ ;to be removed if needed
mov currtype,0
jmp typ2
typ:
mov currtype,1
typ2:
mov dx,0 ;counter
mov cx,row
mov ax,col
lop:
inc cx
cmp cx,0
jae cont1
jmp far ptr exit

cont1:
cmp cx,8
jb cont2
jmp far ptr exit

cont2:
cmp ax,0
jae cont3
jmp far ptr exit

cont3:
cmp ax,8
jb cont4
jmp far ptr exit

cont4:
mov tmpr,cx
mov tmpc,ax

getdb tmpr,tmpc
mov ax,0
mov al,chezzT[bx]
cmp al,-1
jne cont5
jmp far ptr highlightG
cont5:cmp ax,0Ah
ja typn ;to be removed if needed
mov nexttype,0
jmp typn2
typn:
mov nexttype,1
typn2:
mov bx,0
mov bl,currtype
mov bh,nexttype
xor bl,bh
cmp bl,0
jne highlightR
jmp far ptr exit
highlightR:
getdb tmpr,tmpc
mov chezzC[bx],4h
dec nexttype
and nexttype,0Fh
DrawPieceDB  4,4,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

jmp far ptr exit

highlightG:
getdb tmpr,tmpc
mov chezzC[bx],0Ah
dec nexttype
and nexttype,0Fh
DrawPieceDB  0Ah,0Ah,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

inc dx
cmp dx,steps
je exit
jmp far ptr lop
exit:
popa
ENDM Drawdown

Drawright MACRO row,col,steps
local lop,exit,validate,typ,typ2,highlightg,highlightr,typn,typn2,cont1,cont2,cont3,cont4,cont5
;steps is max number
pusha

getdb row,col
mov ax,0
mov al,chezzT[bx]
cmp ax,0Ah
ja typ ;to be removed if needed
mov currtype,0
jmp typ2
typ:
mov currtype,1
typ2:
mov dx,0 ;counter
mov cx,row
mov ax,col
lop:
inc ax
cmp cx,0
jae cont1
jmp far ptr exit

cont1:
cmp cx,8
jb cont2
jmp far ptr exit

cont2:
cmp ax,0
jae cont3
jmp far ptr exit

cont3:
cmp ax,8
jb cont4
jmp far ptr exit

cont4:
mov tmpr,cx
mov tmpc,ax

getdb tmpr,tmpc
mov ax,0
mov al,chezzT[bx]
cmp al,-1
jne cont5
jmp far ptr highlightG
cont5:cmp ax,0Ah
ja typn ;to be removed if needed
mov nexttype,0
jmp typn2
typn:
mov nexttype,1
typn2:
mov bx,0
mov bl,currtype
mov bh,nexttype
xor bl,bh
cmp bl,0
jne highlightR
jmp far ptr exit
highlightR:
getdb tmpr,tmpc
mov chezzC[bx],4h
dec nexttype
and nexttype,0Fh
DrawPieceDB  4,4,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

jmp far ptr exit

highlightG:
getdb tmpr,tmpc
mov chezzC[bx],0Ah
dec nexttype
and nexttype,0Fh
DrawPieceDB  0Ah,0Ah,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

inc dx
cmp dx,steps
je exit
jmp far ptr lop
exit:
popa
ENDM Drawright

;/************************************************************/


Drawleft MACRO row,col,steps
local lop,exit,validate,typ,typ2,highlightg,highlightr,typn,typn2,cont1,cont2,cont3,cont4,cont5
;steps is max number
pusha

getdb row,col
mov ax,0
mov al,chezzT[bx]
cmp ax,0Ah
ja typ ;to be removed if needed
mov currtype,0
jmp typ2
typ:
mov currtype,1
typ2:
mov dx,0 ;counter
mov cx,row
mov ax,col
lop:
dec ax
cmp cx,0
jae cont1
jmp far ptr exit

cont1:
cmp cx,8
jb cont2
jmp far ptr exit

cont2:
cmp ax,0
jae cont3
jmp far ptr exit

cont3:
cmp ax,8
jb cont4
jmp far ptr exit

cont4:
mov tmpr,cx
mov tmpc,ax

getdb tmpr,tmpc
mov ax,0
mov al,chezzT[bx]
cmp al,-1
jne cont5
jmp far ptr highlightG
cont5:cmp ax,0Ah
ja typn ;to be removed if needed
mov nexttype,0
jmp typn2
typn:
mov nexttype,1
typn2:
mov bx,0
mov bl,currtype
mov bh,nexttype
xor bl,bh
cmp bl,0
jne highlightR
jmp far ptr exit
highlightR:
getdb tmpr,tmpc
mov chezzC[bx],4h
dec nexttype
and nexttype,0Fh
DrawPieceDB  4,4,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

jmp far ptr exit

highlightG:
getdb tmpr,tmpc
mov chezzC[bx],0Ah
dec nexttype
and nexttype,0Fh
DrawPieceDB  0Ah,0Ah,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

inc dx
cmp dx,steps
je exit
jmp far ptr lop
exit:
popa
ENDM Drawleft

DrawRUD MACRO row,col,steps
local lop,exit,validate,typ,typ2,highlightg,highlightr,typn,typn2,cont1,cont2,cont3,cont4,cont5
;steps is max number
;DRAW RIGHT UP DIAGONAL
pusha

getdb row,col
mov ax,0
mov al,chezzT[bx]
cmp ax,0Ah
ja typ ;to be removed if needed
mov currtype,0
jmp typ2
typ:
mov currtype,1
typ2:
mov dx,0 ;counter
mov cx,row
mov ax,col
lop:
inc ax
dec cx
cmp cx,0
jae cont1
jmp far ptr exit

cont1:
cmp cx,8
jb cont2
jmp far ptr exit

cont2:
cmp ax,0
jae cont3
jmp far ptr exit

cont3:
cmp ax,8
jb cont4
jmp far ptr exit

cont4:
mov tmpr,cx
mov tmpc,ax

getdb tmpr,tmpc
mov ax,0
mov al,chezzT[bx]
cmp al,-1
jne cont5
jmp far ptr highlightG
cont5:cmp ax,0Ah
ja typn ;to be removed if needed
mov nexttype,0
jmp typn2
typn:
mov nexttype,1
typn2:
mov bx,0
mov bl,currtype
mov bh,nexttype
xor bl,bh
cmp bl,0
jne highlightR
jmp far ptr exit
highlightR:
getdb tmpr,tmpc
mov chezzC[bx],4h
dec nexttype
and nexttype,0Fh
DrawPieceDB  4,4,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

jmp far ptr exit

highlightG:
getdb tmpr,tmpc
mov chezzC[bx],0Ah
dec nexttype
and nexttype,0Fh
DrawPieceDB  0Ah,0Ah,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

inc dx
cmp dx,steps
je exit
jmp far ptr lop
exit:
popa
ENDM DrawRUD

DrawLDD MACRO row,col,steps
local lop,exit,validate,typ,typ2,highlightg,highlightr,typn,typn2,cont1,cont2,cont3,cont4,cont5
;steps is max number
;DRAW LEFT DOWN DIAGONAL
pusha

getdb row,col
mov ax,0
mov al,chezzT[bx]
cmp ax,0Ah
ja typ ;to be removed if needed
mov currtype,0
jmp typ2
typ:
mov currtype,1
typ2:
mov dx,0 ;counter
mov cx,row
mov ax,col
lop:
inc cx
dec ax
cmp cx,0
jae cont1
jmp far ptr exit

cont1:
cmp cx,8
jb cont2
jmp far ptr exit

cont2:
cmp ax,0
jae cont3
jmp far ptr exit

cont3:
cmp ax,8
jb cont4
jmp far ptr exit

cont4:
mov tmpr,cx
mov tmpc,ax

getdb tmpr,tmpc
mov ax,0
mov al,chezzT[bx]
cmp al,-1
jne cont5
jmp far ptr highlightG
cont5:cmp ax,0Ah
ja typn ;to be removed if needed
mov nexttype,0
jmp typn2
typn:
mov nexttype,1
typn2:
mov bx,0
mov bl,currtype
mov bh,nexttype
xor bl,bh
cmp bl,0
jne highlightR
jmp far ptr exit
highlightR:
getdb tmpr,tmpc
mov chezzC[bx],4h
dec nexttype
and nexttype,0Fh
DrawPieceDB  4,4,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

jmp far ptr exit

highlightG:
getdb tmpr,tmpc
mov chezzC[bx],0Ah
dec nexttype
and nexttype,0Fh
DrawPieceDB  0Ah,0Ah,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

inc dx
cmp dx,steps
je exit
jmp far ptr lop
exit:
popa
ENDM DrawLDD

DrawLUD MACRO row,col,steps
local lop,exit,validate,typ,typ2,highlightg,highlightr,typn,typn2,cont1,cont2,cont3,cont4,cont5
;steps is max number
;DRAW LEFT UP DIAGONAL
pusha

getdb row,col
mov ax,0
mov al,chezzT[bx]
cmp ax,0Ah
ja typ ;to be removed if needed
mov currtype,0
jmp typ2
typ:
mov currtype,1
typ2:
mov dx,0 ;counter
mov cx,row
mov ax,col
lop:
dec ax
dec cx
cmp cx,0
jae cont1
jmp far ptr exit

cont1:
cmp cx,8
jb cont2
jmp far ptr exit

cont2:
cmp ax,0
jae cont3
jmp far ptr exit

cont3:
cmp ax,8
jb cont4
jmp far ptr exit

cont4:
mov tmpr,cx
mov tmpc,ax

getdb tmpr,tmpc
mov ax,0
mov al,chezzT[bx]
cmp al,-1
jne cont5
jmp far ptr highlightG
cont5:cmp ax,0Ah
ja typn ;to be removed if needed
mov nexttype,0
jmp typn2
typn:
mov nexttype,1
typn2:
mov bx,0
mov bl,currtype
mov bh,nexttype
xor bl,bh
cmp bl,0
jne highlightR
jmp far ptr exit
highlightR:
getdb tmpr,tmpc
mov chezzC[bx],4h
dec nexttype
and nexttype,0Fh
DrawPieceDB  4,4,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

jmp far ptr exit

highlightG:
getdb tmpr,tmpc
mov chezzC[bx],0Ah
dec nexttype
and nexttype,0Fh
DrawPieceDB  0Ah,0Ah,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

inc dx
cmp dx,steps
je exit
jmp far ptr lop
exit:
popa
ENDM DrawLUP

DrawRDD MACRO row,col,steps
local lop,exit,validate,typ,typ2,highlightg,highlightr,typn,typn2,cont1,cont2,cont3,cont4,cont5
;steps is max number
;DRAW RIGHT DOWN DIAGONAL
pusha

getdb row,col
mov ax,0
mov al,chezzT[bx]
cmp ax,0Ah
ja typ ;to be removed if needed
mov currtype,0
jmp typ2
typ:
mov currtype,1
typ2:
mov dx,0 ;counter
mov cx,row
mov ax,col
lop:
inc ax
inc cx
cmp cx,0
jae cont1
jmp far ptr exit

cont1:
cmp cx,8
jb cont2
jmp far ptr exit

cont2:
cmp ax,0
jae cont3
jmp far ptr exit

cont3:
cmp ax,8
jb cont4
jmp far ptr exit

cont4:
mov tmpr,cx
mov tmpc,ax

getdb tmpr,tmpc
mov ax,0
mov al,chezzT[bx]
cmp al,-1
jne cont5
jmp far ptr highlightG
cont5:cmp ax,0Ah
ja typn ;to be removed if needed
mov nexttype,0
jmp typn2
typn:
mov nexttype,1
typn2:
mov bx,0
mov bl,currtype
mov bh,nexttype
xor bl,bh
cmp bl,0
jne highlightR
jmp far ptr exit
highlightR:
getdb tmpr,tmpc
mov chezzC[bx],4h
dec nexttype
and nexttype,0Fh
DrawPieceDB  4,4,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

jmp far ptr exit

highlightG:
getdb tmpr,tmpc
mov chezzC[bx],0Ah
dec nexttype
and nexttype,0Fh
DrawPieceDB  0Ah,0Ah,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

inc dx
cmp dx,steps
je exit
jmp far ptr lop
exit:
popa
ENDM DrawRDD

DrawKnight MACRO row,col
local lop,exit,validate,typ,typ2,highlightg,highlightr,typn,typn2,cont1,cont2,cont3,cont4,cont5,l1,l2,l3,l4,l5,l6,l7,l8,endl
;DRAW all knight moves
pusha

getdb row,col
mov ax,0
mov al,chezzT[bx]
cmp ax,0Ah
ja typ ;to be removed if needed
mov currtype,0
jmp typ2
typ:
mov currtype,1
typ2:
mov cx,row
mov ax,col
mov dx,0
lop:
;loop number 0
cmp dx,0
jne l1
mov cx,row
mov ax,col
sub ax,1
sub cx,2
l1:
;loop number 1
cmp dx,1
jne l2
mov cx,row
mov ax,col
sub ax,2
sub cx,1
l2:
;loop number 2
cmp dx,2
jne l3
mov cx,row
mov ax,col
add ax,1
sub cx,2
l3:
;loop number 3
cmp dx,3
jne l4
mov cx,row
mov ax,col
add ax,2
sub cx,1
l4:
;loop number 4
cmp dx,4
jne l5
mov cx,row
mov ax,col
add ax,2
add cx,1
l5:
;loop number 5
cmp dx,5
jne l6
mov cx,row
mov ax,col
add ax,1
add cx,2
l6:
;loop number 6
cmp dx,6
jne l7
mov cx,row
mov ax,col
sub ax,1
add cx,2
l7:
;loop number 7
cmp dx,7
jne l8
mov cx,row
mov ax,col
sub ax,2
add cx,1
l8:
push dx
cmp cx,0
jae cont1
jmp far ptr endl

cont1:
cmp cx,8
jb cont2
jmp far ptr endl

cont2:
cmp ax,0
jae cont3
jmp far ptr endl

cont3:
cmp ax,8
jb cont4
jmp far ptr endl

cont4:
mov tmpr,cx
mov tmpc,ax

getdb tmpr,tmpc
mov ax,0
mov al,chezzT[bx]
cmp al,-1
jne cont5
jmp far ptr highlightG
cont5:cmp ax,0Ah
ja typn ;to be removed if needed
mov nexttype,0
jmp typn2
typn:
mov nexttype,1
typn2:
mov bx,0
mov bl,currtype
mov bh,nexttype
xor bl,bh
cmp bl,0
jne highlightR
jmp far ptr endl
highlightR:
getdb tmpr,tmpc
mov chezzC[bx],4h
dec nexttype
and nexttype,0Fh
DrawPieceDB  4,4,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

jmp far ptr endl

highlightG:
getdb tmpr,tmpc
mov chezzC[bx],0Ah
dec nexttype
and nexttype,0Fh
DrawPieceDB  0Ah,0Ah,0,0,nexttype,tmpr,tmpc,begr,begc,endr,endc,res

mov ax,tmpc
mov cx,tmpr
mov tmpdbr,cl
mov tmpdbc,al
insert tmpdbr,tmpdbc

endl:
pop dx
inc dx
cmp dx,8
je exit
jmp far ptr lop
exit:
popa
ENDM DrawKnight








initchezzN MACRO PrimaryC,SecondaryC,chezzN
local redo,sec,con,exit
pusha
lea si,chezzN
lea di,chezznrev
mov cx,0
mov dx,0
mov bx,0
;cx is pointing to row 
;dx is pointing to colomn

redo:
cmp cx,1
ja next
mov [si],bl
push bx
mov bh,cl
mov bl,dl
mov [di],bx
inc di
inc di
pop bx
jmp con
next: cmp cx,6
jb con
mov ax,bx
sub ax,32
mov [si],ax

con:inc bx
inc si
inc dx
cmp dx,8
jne redo
mov dx,0
inc cx
cmp cx,8
jnz redo

popa
ENDM initchezzN


kill MACRO r,c
local sec,con
;-1 means empty location
pusha

getdb r,c
mov chezzC[BX],-1
mov chezzT[BX],-1
;;;handle chezznrev////////////////
push ax
push bx
mov al,chezzN[BX]
mov bx,00h
mov bl,al
mov time[bx],0
add bx,bx
mov chezznrev[BX],-1
pop bx 
pop ax
;;;/////////////////////////////////////end
mov ax,0
mov al,chezzN[BX]
mov chezzN[BX],-1
mov bx,ax
mov timer[BX],-1


getdW r,c
mov chezzP[BX],-1

 mov cx,0
    mov ah,0
    mov ax,r
    mov bx,2
    div bl
    xor cl,ah

    mov ah,0
    mov ax,c
    mov bx,2
    div bl
    xor cl,ah
    
    mov res,cl

    getdb r,c

    mov ax,0
    cmp res,0
    jnz sec 
    mov al,PrimaryC
    mov chezzC[BX],al
    jmp con
    sec:mov al,SecondaryC
    mov chezzC[BX],al
    con:mov res,al
    Drawsquare c,r,begr,begc,res ;to be removed
popa
ENDM kill

replace MACRO oldr,oldc,newr,newc
local sec,con,typ,typ2
;-1 means empty location
pusha


getdb oldr,oldc
mov ax,0
mov al,chezzT[bx]

cmp ax,0Ah
ja typ 
mov currtype,0
jmp typ2
typ:
mov currtype,1
typ2:
dec currtype
and currtype,0Fh

;/*****replacing data*****/
;moving at first data at new loction
getdb oldr,oldc
mov si,bx
getdb newr,newc
;si pointing to old location 
;bx pointing to new location
;cx is used as tmp intermediate variable
mov chezzC[si],-1

mov cl,chezzT[si]
mov chezzT[BX],cl
mov chezzT[si],-1

mov cl,chezzN[si]
mov chezzN[BX],cl
mov chezzN[si],-1

;mov bx,0
;mov bl,chezzN[si]
;mov timer[bx],-1

;;;chezzNrev handeling and time handeling
pusha
mov dx,newr
mov ax,newc
mov dh,dl
mov dl,al

getdb newr,newc

mov cl,chezzN[bx]
mov bx,0
mov bl,cl

mov time[bx],3
add bx,bx
mov chezznrev[BX],dx
popa
;under checking
;;;///////////////////////

pusha
mov ax,2C00h
INT 21h
getdb newr,newc
mov al,chezzN[bx]
mov bx,0
mov bl,al
mov Timer[bx],dh
popa



getdw oldr,oldc
mov si,bx
getdw newr,newc
mov cx,chezzP[si]
mov chezzP[bx],cx
mov chezzP[si],-1
;/*****end replacing data*****/
    mov cx,0
    mov ah,0
    mov ax,oldr
    mov bx,2
    div bl
    xor cl,ah

    mov ah,0
    mov ax,oldc
    mov bx,2
    div bl
    xor cl,ah
    
    mov res,cl
    getdb oldr,oldc

    mov ax,0
    cmp res,0
    jnz sec 
    mov al,PrimaryC
    mov chezzC[BX],al
    jmp con
    sec:mov al,SecondaryC
    mov chezzC[BX],al
    con:mov res,al
    Drawsquare oldc,oldr,begr,begc,res ;to be removed
    DrawPieceDB  PrimaryC,SecondaryC,0,0,currtype,newr,newc,begr,begc,endr,endc,res ;drawing the piece at the new location
    


popa
ENDM replace


drawtim MACRO number
;this was a macro now it only cals the proc
push ax 
mov ax,number
mov tmpnumber,ax
call Drawtimp 
pop ax
ENDM drawtim