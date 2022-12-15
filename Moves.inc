include DrawingM.inc
include mymacros.inc

movepiece MACRO PrimaryC,SecondaryC,dataloc,roffset,coffset,playertpye,row,col,begr,begc,endr,endc,res
    
ENDM movepiece

choosepiece MACRO PrimaryC,SecondaryC,chezzP,chezzT,chezzC,playertpye,moveavailc,takeavailc,prevR,prevC,success,begr,begc,endr,endc,res
    local leave,Q1,Q2,Qb2,whiteQ,blackQ,wnkingQ,wnueenQ,wnbishopQ,wnknightQ,wnrookQ,wnpawnQ,bnkingQ,bnqueenQ,bnbishopQ,bnknightQ,bnrookQ,bnpawnQ,skipwpawn
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
    jmp far ptr leave
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
    JnE wnkingQ
    
    ;TODO call king function

    jmp far ptr leave
    wnkingQ:
    ;check if piece is queen
    cmp ax,1
    JnE wnueenQ

    ;TODO call queen function

    jmp far ptr leave
    wnueenQ:
    ;check if piece is rook
    cmp ax,2
    JnE wnrookQ

    ;TODO call rook function
    
    jmp far ptr leave
    wnrookQ:
    ;check if piece is bishop
    cmp ax,3
    JnE wnbishopQ

    ;TODO call bishop function

    jmp far ptr leave
    wnbishopQ:
    ;check if piece is knight
    cmp ax,4
    JnE wnknightQ
   
    ;TODO call knight function
   
    jmp far ptr leave
    wnknightQ:
    ;check if piece is pawn
    cmp ax,5
    JE skipwpawn
    jmp far ptr wnpawnQ
    skipwpawn:
    
    Highpawn row,col,playertpye,success
     
    jmp far ptr leave
    wnpawnQ:
    jmp far ptr leave
    blackQ:
    ;black player
    ;check if piece is black
    and ax,0f0h
    cmp ax,00
    JNE Qb2
    jmp far ptr leave
    Qb2:
    ;check if piece is king
    mov ax,[di]
    and ax,0fh
    cmp ax,0
    JnE bnkingQ

    ;TODO call king function

    jmp far ptr leave
    bnkingQ:
    ;check if piece is queen
    cmp ax,1
    JnE bnqueenQ
    
    ;TODO call queen function

    jmp far ptr leave
    bnqueenQ:
    ;check if piece is rook
    cmp ax,2
    JnE bnrookQ
    
    ;TODO call rook function

    jmp far ptr leave
    bnrookQ:
    ;check if piece is bishop
    cmp ax,3
    JnE bnbishopQ

    ;TODO call bishop function
    
    jmp far ptr leave
    bnbishopQ:
    ;check if piece is knight
    cmp ax,4
    JnE bnknightQ

    ;TODO call knight function

    jmp far ptr leave
    bnknightQ:
    ;check if piece is pawn
    cmp ax,5
    JnE bnpawnQ

    ;TODO call pawn function

    jmp far ptr leave
    bnpawnQ:
    jmp far ptr leave


        






    leave:
ENDM choosepiece

HighRook MACRO PrimaryC,SecondaryC,chezzP,chezzT,chezzC,playertpye,moveavailc,takeavailc,Row,Col,success

ENDM HighRook


;/**************************************************************************/


Highbishop MACRO PrimaryC,SecondaryC,chezzP,chezzT,chezzC,playertpye,moveavailc,takeavailc,Row,Col,urow,drow,rcol,lcol,success
    local blackbishop,blockW,highlight,terminate

    ;cmp playertpye,0
    ;JnE blackbishop
    mov ax,row
    mov urow,ax
    mov cx,row
    mov drow,cx
    mov bx,Col
    mov rcol,bx
    mov dx,col
    mov lcol,dx


    highlight:
    pusha
    inc urow
    mov ax,urow
    cmp ax,8h
    JAE terminate
    dec drow
    mov cx,drow
    cmp cx,0h
    JB terminate
    inc rcol
    mov bx,rcol
    cmp bx,8h
    JAE terminate
    dec lcol
    mov dx,lcol
    cmp dx,0h
    JB terminate
    popa
    

    lea si,chezzP
    lea di,chezzT
    mov ax,8h
    mul bl
    add ax,col
    add di,ax
    add ax,ax
    add si,ax
    mov ax,[di]

    cmp ax,-1
    JnE blockW
    mov ax,moveavailc
    mov bx,8
    mul bl
    add ax,col
    mov [ax],1
    jmp highlight

    blockW:










 
  
    block:
    terminate:
  

ENDM Highbishop

;/**************************************************************************/


;dont compare memory locations
Highpawn MACRO row,col,playertpye,success
    local continuemove,exit,white,black,whitefirstmove,blackfirstmove,whitenotfirstmove,blacknotfirstmove,noenemyonleftup,noenemyonrightup,enemyonleftup,enemyonrightup,whsip1,whskip2,cnowhite
   
    mov success,1
    drawSelf row,col
    mov al,playertpye
    cmp al,0
    je conwhite
    jmp far ptr black
    conwhite:
    mov ax,row
    mov cx,col
    ;takes
    dec ax
    dec cx
    mov tmpr,ax
    mov tmpc,cx
    getdb tmpr,tmpc
    mov dx,chezzT[bx]
    cmp dx,-1
    jne enemyonleftup
    jmp far ptr noenemyonleftup
    enemyonleftup:

    DrawLUD row,col,1h

    noenemyonleftup:
    dec ax
    inc cx
    mov tmpr,ax
    mov tmpc,cx
    getdb tmpr,tmpc
    mov dx,chezzT[bx]
    cmp dx,-1
    jne enemyonrighttup
    jmp far ptr noenemyonrighttup
    enemyonrighttup:
    DrawRUD row,col,1
    noenemyonrighttup:
    ;end takes
    cmp ax,6h
    je whitefirstmove
    jmp far ptr whitenotfirstmove
    whitefirstmove:
    ;this is the first move for this pawn


    whitenotfirstmove:
    ;this is not first move for this pawn

    jmp white
    black:




    white:
    exit:
ENDM Highpawn

;/**************************************************************************/

selcectp MACRO r,c
mov dx,r
mov selectedr,dx
mov dx,c
mov selectedc,dx
mov selected,1
ENDM selectp

;/**************************************************************************/

deselectp MACRO
local lbl,sec,con,exit,white,black,cont1
pusha
;this function deselect a selected piece and removes highlights of squares
mov selectedr,-1
mov selectedc,-1
mov selected,0

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
