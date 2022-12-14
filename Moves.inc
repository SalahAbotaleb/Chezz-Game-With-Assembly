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
    
    Highpawn PrimaryC,SecondaryC,chezzP,chezzT,chezzC,playertpye,moveavailc,takeavailc,Row,Col,success,begr,begc,endr,endc,res
     
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








;dont compare memory locations
Highpawn MACRO PrimaryC,SecondaryC,chezzP,chezzT,chezzC,playertpye,moveavailc,takeavailc,Row,Col,success,begr,begc,endr,endc,res
    local blackpawn,notstartingpos,somethingintheway1,somethingintheway2,blackpawns,whitepawns,whitepawn,notstartingpos2,somethingintheway3,somethingintheway4,whitepawns2
    ;s is short for skip

    mov ax,row
    mov bx,col

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
 
    mov dx,0 
    mov dl,playertpye
    cmp dx,0
  
    JE blackpawns
    jmp far ptr blackpawn
    blackpawns:
    ;white pawn
    ;check if pawn is in starting position
    sub di,9h ;i dont know why it works for 9 it was supposed to work for 8
    mov ax,[di]
    add di,9h
    ;seeing if there is something in front of the pawn
    ;reach here
    
    cmp ax,-1
    JE somethingintheway1s
    jmp far ptr somethingintheway1
    somethingintheway1s:
    
    ;mov chezzC+di,moveavailc;might not work
    pusha 
    mov di,offset chezzC
    mov ax,8
    mov bx,row
    mul bl
    add ax,col
    mov di,ax
    push ax
    mov al,moveavailc
    mov [di],al;might not work
    pop ax
    popa 
    push bx
    mov bx,row
    sub bx,1

    DrawPieceDB moveavailc,moveavailc,0,0,0,0fh,bx,col,begr,begc,endr,endc,res 
    pop bx

    mov ax,row
    cmp ax,6h
    JE notstartingposs
    jmp far ptr notstartingpos
    notstartingposs:
    ;check if pawn can move 2 spaces
    
    sub di,16d
    mov ax,[di]
    add di,16d
    cmp ax,-1
    JE somethingintheway2s
    jmp far ptr somethingintheway2
    somethingintheway2s:
    pusha 
    mov di,offset chezzC
    mov ax,8
    mov bx,row
    mul bl
    add ax,col
    add di,ax
    push ax
    mov al,moveavailc
    mov [di],al;might not work
    pop ax
    popa 
    push bx
    mov bx,row
    sub bx,2
    DrawPieceDB moveavailc,moveavailc,0,0,0,0fh,bx,col,begr,begc,endr,endc,res
    pop bx

    somethingintheway2:
    notstartingpos:
    somethingintheway1:
    blackpawn:

ENDM Highpawn