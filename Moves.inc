include DrawingM.inc
include mymacros.inc

movepiece MACRO row,col
local lbl,sec,con,exit,cont1,resume,dexit,fexit,cont3,cont2,cont4,white,black
pusha
;this function deselect a selected piece and removes highlights of squares
mov cx,row
mov dx,col
xor cx,selectedr
xor dx,selectedc
or cx,dx
cmp cx,0
jne con
jmp far ptr dexit
con:

;/**checking that the selected cell is one of highlighted cells**/
mov di,0


lbl:
;cx is pointing to row 
;dx is pointing to colomn
mov cx,0
mov dx,0
mov cl,storage[di]
inc di
mov dl,storage[di]
inc di

mov movr,cx
mov movc,dx

xor cx,row
xor dx,col
or cx,dx
cmp cx,0
jne cont1
jmp far ptr fexit
cont1:cmp di,head
jne lbl
jmp far ptr exit
;/**end checking**/
fexit:
;found an item and deselect then exit
mov cx,movr
mov dx,movc

getdb movr,movc
mov ax,0
mov al,chezzT[BX]
cmp al,-1
je cont4
jmp far ptr cont2
cont4:
replace selectedr,selectedc,movr,movc ;movr and movc can be replaced by row and col here
drawtim 3
jmp far ptr dexit
cont2:
cmp ax,0AH
ja black
jmp far ptr white
black:
;now the one to be killed is balck
;enqueue if needed the killed piece
inc killBC
kill movr,movc
jmp far ptr cont3
white:
;now the one to be killed is white
;enqueue if needed the killed piece
inc killWC
kill movr,movc
cont3: 
;replace and timer
replace selectedr,selectedc,movr,movc
mov ax,2C00h
INT 21h
getdb movr,movc
mov al,chezzN[bx]
mov bx,0
mov bl,al
mov Timer[bx],dh
drawtim 3
dexit: deselectp
;deselect then exit
exit:
popa    
ENDM movepiece

choosepiece MACRO PrimaryC,SecondaryC,chezzP,chezzT,chezzC,playertpye,moveavailc,takeavailc,prevR,prevC,success,begr,begc,endr,endc,res
    local leave,Q1,Q2,Qb2,whiteQ,blackQ,wnkingQ,wnueenQ,wnbishopQ,wnknightQ,wnrookQ,wnpawnQ,bnkingQ,bnqueenQ,bnbishopQ,bnknightQ,bnrookQ,bnpawnQ,skipwpawn,wking,wqueen,wrook,wbishop,wknight,wpawn,skipbpawn,bking,bqueen,brook,bbishop,bknight,bpawn,cont1,selectedn
;PrimaryC is the primary color
;SecondaryC is the secondary color
;chezzP is the piece array
;chezzT is the type array
;playertype is 0 for white and 1 for black
;moveavailc is the array of available moves
;takeavailc is the array of available takes
;prevR is the previous row
;prevC is the previous column
;success is the success flag
;wnkingQ means tha the piece is not white king 

    ; getdb prevR,prevC
    ; mov al,chezzT[BX]
    ; cmp al,-1
    ; jne cont1
    ; mov success,0
    ; jmp far ptr leave
    ; cont1:
    mov success,1
    mov ax,prevR
    mov bx,prevC

    lea si,chezzP
    lea di,chezzT
    mov ax,8
    mov bx,row
    mul bl
    add ax,col
    add di,ax
    add ax,ax
    add si,ax  
    mov ax,[di]

    ;check if position is empty
    cmp ax,-1
    JnE Q1
    jmp far ptr selectedn
    Q1:
    ;check if player is white ;kinda racist
    cmp playertpye,0;probably serial port
    JE whiteQ
    jmp far ptr blackQ
    whiteQ:
    ;white player
    ;check if piece is white
    and ax,0f0h
    cmp ax,00
    JE Q2
    jmp far ptr leave
    Q2:
    ;check if piece is king
    mov ax,[di]
    and ax,0fh
    cmp ax,0
    JE wking
    jmp far ptr wnkingQ
    wking:
    ;TODO call king function
    HighKing row,col
    jmp far ptr leave
    wnkingQ:
    ;check if piece is queen
    cmp ax,1
    JE wqueen
    jmp far ptr wnueenQ
    wqueen:

    ;TODO call queen function
    HighQueen row,col,10

    jmp far ptr leave
    wnueenQ:
    ;check if piece is rook
    cmp ax,2
    JE wrook
    jmp far ptr wnrookQ
    wrook:         
    
    ;TODO call rook function
    HighRook row,col,10

    jmp far ptr leave
    wnrookQ:
    ;check if piece is bishop
    cmp ax,3
    JE wbishop
    jmp far ptr wnbishopQ
    wbishop:

    ;TODO call bishop function
   
    HighBishop row,col,10

    jmp far ptr leave
    wnbishopQ:
    ;check if piece is knight

    cmp ax,4
    JE wknight
    jmp far ptr wnknightQ
    wknight:
   
    ;TODO call knight function
    HighKnight row,col
    jmp far ptr leave
    wnknightQ:
    ;check if piece is pawn
    cmp ax,5
    JE wpawn
    jmp far ptr wnpawnQ
    wpawn:
    
    Highpawnw row,col
     
    jmp far ptr leave
    wnpawnQ:
    jmp far ptr leave
    blackQ:
    ;black player
    ;check if piece is black
    and ax,0f0h
    cmp ax,00
    JNE Qb2
    jmp far ptr selectedn
    Qb2:
    ;check if piece is king
    mov ax,[di]
    and ax,0fh
    cmp ax,0
    JE bking
    jmp far ptr bnkingQ
    bking:

    ;TODO call king function
    HighKing row,col
    jmp far ptr leave
    bnkingQ:
    ;check if piece is queen

    cmp ax,1
    JE bqueen
    jmp far ptr bnqueenQ
    bqueen:

    ;TODO call queen function
    HighQueen row,col,10

    jmp far ptr leave
    bnqueenQ:
    ;check if piece is rook
    
    cmp ax,2
    JE brook
    jmp far ptr bnrookQ
    brook:
    
    ;TODO call rook function
    HighRook row,col,10


    jmp far ptr leave
    bnrookQ:
    ;check if piece is bishop
    cmp ax,3
    JE bbishop
    jmp far ptr bnbishopQ
    bbishop:

    ;TODO call bishop function
    HighBishop row,col,10
    
    jmp far ptr leave
    bnbishopQ:
    ;check if piece is knight
    
    cmp ax,4
    JE bknight
    jmp far ptr bnknightQ
    bknight:

    ;TODO call knight function
    HighKnight row,col
    jmp far ptr leave
    bnknightQ:
    ;check if piece is pawn
    cmp ax,5
    JE bpawn
    jmp far ptr bnpawnQ
    bpawn:

    ;TODO call pawn function
    Highpawnb row,col

    jmp far ptr leave
    bnpawnQ:
    ;jmp far ptr leave
    selectedn:
    mov success,0
    leave:
ENDM choosepiece

;/**************************************************************************/

HighKing MACRO row,col

drawSelf row,col
Drawup row,col,1
Drawdown row,col,1
Drawleft row,col,1
Drawright row,col,1
DrawLDD row,col,1
DrawRUD row,col,1
DrawLUD row,col,1
DrawRDD row,col,1

;castling ?

ENDM HighKing

HighQueen MACRO row,col,steps

drawSelf row,col
Drawup row,col,steps
Drawdown row,col,steps
Drawleft row,col,steps
Drawright row,col,steps
DrawLDD row,col,steps
DrawRUD row,col,steps
DrawLUD row,col,steps
DrawRDD row,col,steps

ENDM HighQueen

;/**************************************************************************/

HighRook MACRO row,col,steps

drawSelf row,col
Drawup row,col,steps
Drawdown row,col,steps
Drawleft row,col,steps
Drawright row,col,steps

ENDM HighRook


;/**************************************************************************/


HighBishop MACRO row,col,steps

drawSelf row,col
DrawLDD row,col,steps
DrawRUD row,col,steps
DrawLUD row,col,steps
DrawRDD row,col,steps


ENDM HighBishop

;/**************************************************************************/

HighKnight MACRO row,col

drawSelf row,col

DrawKnight row,col



ENDM HighKnight

;dont compare memory locations
Highpawnw MACRO row,col
    local exit,white,black,whitefirstmove,whitenotfirstmov,noenemyonleftup,noenemyonrighttup,enemyonleftup,enemyonrighttup,dofrblock,dosecmove,dosecmove2,CONWHITE
   
    drawSelf row,col

    mov ax,row
    mov cx,col
    ;takes
    dec ax
    dec cx
    mov tmpr,ax
    mov tmpc,cx
    getdb tmpr,tmpc
    mov dl,chezzT[bx]
    cmp dl,-1
    jne enemyonleftup
    jmp far ptr noenemyonleftup
    enemyonleftup:

    DrawLUD row,col,1h

    noenemyonleftup:
    mov ax,row
    mov cx,col
    dec ax
    inc cx
    mov tmpr,ax
    mov tmpc,cx
    getdb tmpr,tmpc
    mov dl,chezzT[bx]
    cmp dl,-1
    jne enemyonrighttup
    jmp far ptr noenemyonrighttup
    enemyonrighttup:
    
    DrawRUD row,col,1
    noenemyonrighttup:
    ;end takes
    ;start of first block move for white
    mov ax,row
    cmp ax,6h
    je whitefirstmove
    jmp far ptr whitenotfirstmove
    whitefirstmove:
    ;this is the first move for this pawn
    mov ax,row
    dec ax
    dec ax
    mov tmpr,ax
    getdb tmpr,col
    mov dl,chezzT[bx]
    cmp dl,-1
    je dosecmove
    jmp far ptr whitenotfirstmove
    dosecmove:
    
    mov ax,row
    dec ax
    mov tmpr,ax
    getdb tmpr,col
    mov dl,chezzT[bx]
    cmp dl,-1
    je dosecmove2
    jmp far ptr exit
    dosecmove2:
    drawup row,col,2


    whitenotfirstmove:
    mov ax,row
    dec ax
    mov tmpr,ax
    getdb tmpr,col
    mov dl,chezzT[bx]
    cmp dl,-1
    je dofrblock
    jmp far ptr black
    dofrblock:
    drawup row,col,1
    ;this is not first move for this pawn
    ;drawup row,col,1
    jmp white
    black:


    white:
    exit:
ENDM Highpawnw


Highpawnb MACRO row,col
local exit,black,whitefirstmove,blackfirstmove,blacknotfirstmove,noenemyonleftdown,noenemyonrighttdown,enemyonleftdown,enemyonrighttdown,dofrblockb,dosecmoveb,dosecmove2,dosecmoveb2
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    drawSelf row,col
    mov ax,row
    mov cx,col
    ;takes
    inc ax
    dec cx
    mov tmpr,ax
    mov tmpc,cx
    getdb tmpr,tmpc
    mov dl,chezzT[bx]
    cmp dl,-1
    jne enemyonleftdown
    jmp far ptr noenemyonleftdown
    enemyonleftdown:

    DrawLDD row,col,1h
 

    noenemyonleftdown:
    mov ax,row
    mov cx,col
    inc ax
    inc cx
    mov tmpr,ax
    mov tmpc,cx
    getdb tmpr,tmpc
    mov dl,chezzT[bx]
    cmp dl,-1
    jne enemyonrighttdown
    jmp far ptr noenemyonrighttdown
    enemyonrighttdown:
    
    DrawRDD row,col,1
    noenemyonrighttdown:
    ;end takes
    ;start of first block move for black
    mov ax,row
    cmp ax,1h
    je blackfirstmove
    jmp far ptr blacknotfirstmove
    blackfirstmove:
    ;this is the first move for this pawn
    mov ax,row
    inc ax
    inc ax
    mov tmpr,ax
    getdb tmpr,col
    mov dl,chezzT[bx]
    cmp dl,-1
    je dosecmoveb
    jmp far ptr blacknotfirstmove
    dosecmoveb:
    
    mov ax,row
    inc ax
    mov tmpr,ax
    getdb tmpr,col
    mov dl,chezzT[bx]
    cmp dl,-1
    je dosecmoveb2
    jmp far ptr exit
    dosecmoveb2:
    Drawdown row,col,2
    jmp far ptr exit

    blacknotfirstmove:
    mov ax,row
    inc ax
    mov tmpr,ax
    getdb tmpr,col
    mov dl,chezzT[bx]
    cmp dl,-1
    je dofrblockb
    jmp far ptr exit
    dofrblockb:
    Drawdown row,col,1
    ;this is not first move for this pawn
    




exit:
;;;;;;;;;;;;;;;;;;;;;


ENDM Highpawnb

;/**************************************************************************/

selectp MACRO r,c
mov dx,r
mov selectedr,dx
mov dx,c
mov selectedc,dx
mov selected,1
ENDM selectp

;/**************************************************************************/

deselectp MACRO
local lbl,sec,con,exit,white,black,cont1,resume
pusha
;this function deselect a selected piece and removes highlights of squares
mov selectedr,-1
mov selectedc,-1
mov selected,0

cmp head,0
jne resume
jmp far ptr exit
resume:
mov di,0
;/**recoloring highlighted cells and redrawing**/

mov cx,0
mov dx,0
lbl:
mov cl,storage[di]
inc di
mov dl,storage[di]
inc di

getdb cx,dx  
mov si,bx

;cx is pointing to row 
;dx is pointing to colomn

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
mov chezzC[si],bl
jmp con
sec:
mov bx,0
mov bl,SecondaryC
mov chezzC[si],bl
con:
mov tmpx,cx
mov tmpy,dx
mov al,chezzT[si]
cmp al,0Ah
jbe white
jmp far ptr black
white:
DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,tmpx,tmpy,begr,begc,endr,endc,res
jmp far ptr cont1
black:
DrawPieceDB  PrimaryC,SecondaryC,0,0,0,tmpx,tmpy,begr,begc,endr,endc,res
cont1:
;/**end of recoloring and redrawing**/
cmp di,head
je exit
jmp far ptr lbl
exit:
mov head,0
popa
ENDM deselectp
