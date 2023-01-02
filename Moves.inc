include DrawingM.inc
include mymacros.inc

movepiece MACRO row,col,RecievedFlag
local lbl,sec,con,exit,cont1,resume,dexit,fexit,cont3,cont2,cont4,CONT6,white,black,movValidate,ChangeRecieved,SendData,cont5,cont7,anotherr,ccc,cont9,blck,disptimer,nopromotion
pusha
;RecievedFlag if 1  then skip validations and go replace it directly
;----
mov bx,RecievedFlag
cmp bx,1
JNE movValidate
jmp far ptr ChangeRecieved
;-----
movValidate:
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
push ax
mov ax,row
mov rowx,ax
mov ax,col
mov colx,ax
Drawtim 3
pop ax
jmp far ptr SendData
cont2:
cmp ax,0AH
jae black
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
getdb movr,movc
cmp playertpye,0

JNE blck
cmp chezzT[BX],10h
jb disptimer
jmp SendData
blck:
cmp chezzT[BX],10h
jae disptimer
jmp SendData

disptimer:
push ax
mov ax,row
mov rowx,ax
mov ax,col
mov colx,ax
Drawtim 3
pop ax
SendData:
;/******/
; promote row, col
mov BX,RecievedFlag
cmp BX,1
JNE CONT6
JMP FAR PTR dexit
CONT6:
mov ax,selectedr
mov SendROLD,ax

; mov dx,AX
; Displaynumber
; printnewline

mov ax,selectedc
mov SendCOLD,ax

; mov dx,AX
; Displaynumber
; printnewline

mov ax,movr
mov SendRNEW,ax

; mov dx,AX
; Displaynumber
; printnewline

mov ax,movc
mov SendCNEW,ax

; mov dx,AX
; Displaynumber
; Printnewline

CALL SEND 

;/******/
dexit:deselectp
jmp far ptr exit
;deselect then exit
ChangeRecieved:
; mov al,selected
; mov selectAtrec,al
getdb RecievedRNEW,RecievedCNEW
mov al,chezzT[bx]
cmp al,-1
jne cont9
jmp far ptr ccc
cont9:
mov al,playertpye
cmp al,1
jne anotherr
inc killbc
jmp ccc
anotherr:
inc killwc
ccc:replace RecievedROLD,RecievedCOLD,RecievedRNEW,RecievedCNEW
; pop selectedc
; cmp selectedc,-1
; push selectedc
; je exit
; mov selected,1
mov ax,selectedr
xor RecievedRNEW,ax
mov ax,selectedc
xor RecievedCNEW,ax
mov ax,RecievedCNEW

deselectp
or ax,RecievedRNEW
JNZ exit
mov selected,0
mov selectAtrec,0
jmp far ptr exit
;cont7:
;replace RecievedROLD,RecievedCOLD,RecievedRNEW,RecievedCNEW
exit:
popa    
ENDM movepiece

choosepiece MACRO PrimaryC,SecondaryC,chezzP,chezzT,chezzC,playertpye,moveavailc,takeavailc,prevR,prevC,success,begr,begc,endr,endc,res
    local leave,Q1,Q2,Qb2,whiteQ,blackQ,wnkingQ,wnueenQ,wnbishopQ,wnknightQ,wnrookQ,wnpawnQ,bnkingQ,bnqueenQ,bnbishopQ,bnknightQ,bnrookQ,bnpawnQ,skipwpawn,wking,wqueen,wrook,wbishop,wknight,wpawn,skipbpawn,bking,bqueen,brook,bbishop,bknight,bpawn,cont1,selectedn,validtime,validtocont,keepSelect,exist,begin
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
    ;should add the timer check here
    ;still under testing
    ;comment this for game to work without timer 
    ;timer is still not working 100%
    pusha


    ;/****************************************************************************************/
    ;validate choosen piece matches the player type 
    getdb prevR,prevC
    mov cl,chezzT[BX]
    shr cl,1
    shr cl,1
    shr cl,1
    shr cl,1
    xor cl,playertpye
    jz validtocont
    jmp far ptr leave
    ;/****************************************************************************************/
    validtocont:
    pusha 
    ;cmp avoidlp,0
    ;jz keepSelect
    ;push selectedr
    ;push selectedc
    ;jmp begin
    keepSelect:
    mov selected,0
    begin:
    getdb prevR,prevC
    mov dx,0
    mov dl,chezzN[BX]
    cmp dl,-1
    JE validtime
    mov bx,dx
    mov dx,0
    mov dl,time[bx]
    cmp dx,0
    JLE validtime
    jmp far ptr leave
    validtime:
    popa
;/****************************************************************************************/
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

    ;cmp avoidlp,0
    ;JZ exit
    ;pop selectedc
    ;pop selectedr
    exit:
    popa

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
    local exit,white,black,whitefirstmove,whitenotfirstmov,noenemyonleftup,noenemyonrighttup,enemyonleftup,enemyonrighttup,dofrblock,dosecmove,dosecmove2,CONWHITE,WHITENOTFIRSTMOVE
   
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

checkformate MACRO playertpye,threat,row,col,steps
    local lop,kingndown,kingn,exitup,exitdown,exitleft,exitright,validate,typ,typ2,highlightg,highlightr,typn,typn2,cont1,cont2,cont3,cont4,cont5,queennchup,queennchdown,rooknchup,rooknchdown,leaveall
;this macro checks if the king is in a threat or not
;check above
;//up///////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////
pusha
mov threat,0
getdb row,col
mov ax,0
mov al,chezzT[bx]
cmp ax,0Ah
ja typup ;to be removed if needed
mov currtype,0
jmp typ2up
typup:
mov currtype,1
typ2up:
mov dx,0 ;counter
mov cx,row
mov ax,col
lopup:
dec cx
cmp cx,0
jae cont1up
jmp far ptr exitup

cont1up:
cmp cx,8
jb cont2up
jmp far ptr exitup

cont2up:
cmp ax,0
jae cont3up
jmp far ptr exitup

cont3up:
cmp ax,8
jb cont4up
jmp far ptr exitup

cont4up:
mov tmpr,cx
mov tmpc,ax

getdb tmpr,tmpc

mov ax,0
mov al,chezzT[bx]
; cmp al,-1
; jne cont5
; jmp far ptr highlightG
; cont5:
cmp ax,0Ah
ja typnup ;to be removed if needed
mov nexttype,0
jmp typn2up
typnup:
mov nexttype,1
typn2up:
mov bx,0
mov bl,currtype
mov bh,nexttype
xor bl,bh
cmp bl,0

jne highlightRup
jmp far ptr exitup
highlightRup:
getdb tmpr,tmpc
mov chezzC[bx],4h
mov al,chezzT[bx]
and al,0fh
cmp al,1
jz queennchup
mov threat,1
jmp far ptr leaveall 
queennchup:
cmp al,2
jz rooknchup
mov threat,1
jmp far ptr leaveall 
rooknchup:
cmp dx,1
jne kingnup
cmp al,0
jnz kingnup
mov threat,1
jmp far ptr leaveall 
kingnup:
inc dx
cmp dx,steps
je exitup
jmp far ptr lopup
exitup:

;/down///////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////
pusha
mov threat,0
getdb row,col
mov ax,0
mov al,chezzT[bx]
cmp ax,0Ah
ja typdown ;to be removed if needed
mov currtype,0
jmp typ2down
typdown:
mov currtype,1
typ2down:
mov dx,0 ;counter
mov cx,row
mov ax,col
lopdown:
inc cx
cmp cx,0
jae cont1down
jmp far ptr exitdown

cont1down:
cmp cx,8
jb cont2down
jmp far ptr exitdown

cont2down:
cmp ax,0
jae cont3down
jmp far ptr exitdown

cont3down:
cmp ax,8
jb cont4down
jmp far ptr exitdown

cont4down:
mov tmpr,cx
mov tmpc,ax

getdb tmpr,tmpc

mov ax,0
mov al,chezzT[bx]
; cmp al,-1
; jne cont5
; jmp far ptr highlightG
; cont5:
cmp ax,0Ah
ja typndown ;to be removed if needed
mov nexttype,0
jmp typn2down
typndown:
mov nexttype,1
typn2down:
mov bx,0
mov bl,currtype
mov bh,nexttype
xor bl,bh
cmp bl,0

jne highlightRdown
jmp far ptr exitdown
highlightRdown:
getdb tmpr,tmpc
mov chezzC[bx],4h
mov al,chezzT[bx]
and al,0fh
cmp al,1
jz queennchdown
mov threat,1
jmp far ptr leaveall 
queennchdown:
cmp al,2
jz rooknchdown
mov threat,1
jmp far ptr leaveall 
rooknchdown:
cmp dx,1
jne kingndown
cmp al,0
jnz kingndown
mov threat,1
jmp far ptr leaveall 
kingndown:
inc dx
cmp dx,steps
je exitdown
jmp far ptr lopdown
exitdown:

;/left///////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////
pusha
mov threat,0
getdb row,col
mov ax,0
mov al,chezzT[bx]
cmp ax,0Ah
ja typleft ;to be removed if needed
mov currtype,0
jmp typ2left
typleft:
mov currtype,1
typ2left:
mov dx,0 ;counter
mov cx,row
mov ax,col
lopleft:
dec ax
cmp ax,0
jae cont1left
jmp far ptr exitleft

cont1left:
cmp ax,8
jb cont2left
jmp far ptr exitleft

cont2left:
cmp cx,0
jae cont3left
jmp far ptr exitleft

cont3left:
cmp cx,8
jb cont4left
jmp far ptr exitleft

cont4left:
mov tmpr,cx
mov tmpc,ax

getdb tmpr,tmpc

mov ax,0
mov al,chezzT[bx]
; cmp al,-1
; jne cont5
; jmp far ptr highlightG
; cont5:
cmp ax,0Ah
ja typnleft;to be removed if needed
mov nexttype,0
jmp typn2left
typnleft:
mov nexttype,1
typn2left:
mov bx,0
mov bl,currtype
mov bh,nexttype
xor bl,bh
cmp bl,0

jne highlightRleft
jmp far ptr exitleft
highlightRleft:
getdb tmpr,tmpc
mov chezzC[bx],4h
mov al,chezzT[bx]
and al,0fh
cmp al,1
jz queennchleft
mov threat,1
jmp far ptr leaveall 
queennchleft:
cmp al,2
jz rooknchleft
mov threat,1
jmp far ptr leaveall 
rooknchleft:
cmp dx,1
jne kingnleft
cmp al,0
jnz kingnleft
mov threat,1
jmp far ptr leaveall 
kingnleft:
inc dx
cmp dx,steps
je exitleft
jmp far ptr lopleft
exitleft:
;/right///////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////
pusha
mov threat,0
getdb row,col
mov ax,0
mov al,chezzT[bx]
cmp ax,0Ah
ja typright ;to be removed if needed
mov currtype,0
jmp typ2right
typright:
mov currtype,1
typ2right:
mov dx,0 ;counter
mov cx,row
mov ax,col
lopright:
inc ax
cmp ax,0
jae cont1right
jmp far ptr exitright

cont1right:
cmp ax,8
jb cont2right
jmp far ptr exitright

cont2right:
cmp cx,0
jae cont3right
jmp far ptr exitright

cont3right:
cmp cx,8
jb cont4right
jmp far ptr exitright

cont4right:
mov tmpr,cx
mov tmpc,ax

getdb tmpr,tmpc

mov ax,0
mov al,chezzT[bx]
; cmp al,-1
; jne cont5
; jmp far ptr highlightG
; cont5:
cmp ax,0Ah
ja typnright ;to be removed if needed
mov nexttype,0
jmp typn2right
typnright:
mov nexttype,1
typn2right:
mov bx,0
mov bl,currtype
mov bh,nexttype
xor bl,bh
cmp bl,0

jne highlightRright
jmp far ptr exitright
highlightRright:
getdb tmpr,tmpc
mov chezzC[bx],4h
mov al,chezzT[bx]
and al,0fh
cmp al,1
jz queennchright
mov threat,1
jmp far ptr leaveall 
queennchright:
cmp al,2
jz rooknchright
mov threat,1
jmp far ptr leaveall 
rooknchright:
cmp dx,1
jne kingnright
cmp al,0
jnz kingnright
mov threat,1
jmp far ptr leaveall 
kingnright:
inc dx
cmp dx,steps
je exitright
jmp far ptr lopright
exitright:



leaveall:
popa

ENDM

deinitAll MACRO 
mov keystrokeF , 0

mov SendROLD , -1
mov SendCOLD , -1

mov SendRNEW , -1
mov SendCNEW , -1

mov begr , 0
mov begc , 0
mov endr , 0
mov endc , 0
mov res , 0

mov tmpx , 0
mov tmpy , 0

mov row , 0
mov col , 0

mov rowx , 0
mov colx , 0

mov killWC , 0 ;counter for killed white

mov killBC , 0 ;counter for killed black

mov prevR , 0
mov prevC , 0

mov wkingR , 0
mov wkingC , 0

mov bkingR , 0
mov bkingC , 0

mov wkingdead , 0
mov bkingdead , 0
 
mov threat , 0

mov chooseR , 0
mov chooseC , 0

mov NUMCOLOR , 0Bh;color for timer number
mov backc , 06h ;color for background of timer
;temp variables first general, second for row, tird for col
mov tmpdb , 0
mov tmpdbr , 0
mov tmpdbc , 0
mov tmptype , 0
mov currtype , 0
mov nexttype , 0
mov tmpr , 0
mov tmpc , 0
mov movr , 0
mov movc , 0
mov tmpdb2 , 0
mov tmpnumber , 0h  ;number for timer put number in this variable before calling timer function proc
mov passer , 0h ;variable to be passed to procs
;selected variables and colors
mov selectedr , -1
mov selectedc , -1
mov selected , 0
mov selectAtrec , 0
mov moveavailc , 0Ah
mov takeavailc , 4h 

mov success , 0 ;0 for fail 1 for success
mov AvoidLp , 0
mov head , 0
mov VALUE  , 0     ;VALUE which will be sent or Received by user
mov initxS , 25     ;initial position for sender column
mov inityS , 9     ;initial position for sender row
mov initxR , 25     ;initial position for receiver column
mov inityR , 18    ;initial position for receiver row
mov rowInitChezz , 0
mov colInitChezz ,  0
mov typeInitChezz , 0
mov picInitChezz   , 0
;/*****************************************/
mov colorD , 0
mov rowD , 0
mov colD , 0
mov datalocD , 0

mov playtime , 0
mov playtimeS , 0
mov playtimeH , 0
mov counter , 0
;/*****************************************/
ENDM

deinitAll MACRO 
mov keystrokeF , 0

mov SendROLD , -1
mov SendCOLD , -1

mov SendRNEW , -1
mov SendCNEW , -1

mov begr , 0
mov begc , 0
mov endr , 0
mov endc , 0
mov res , 0

mov tmpx , 0
mov tmpy , 0

mov row , 0
mov col , 0

mov rowx , 0
mov colx , 0

mov killWC , 0 ;counter for killed white

mov killBC , 0 ;counter for killed black

mov prevR , 0
mov prevC , 0

mov wkingR , 0
mov wkingC , 0

mov bkingR , 0
mov bkingC , 0

mov wkingdead , 0
mov bkingdead , 0
 
mov threat , 0

mov chooseR , 0
mov chooseC , 0

mov NUMCOLOR , 0Bh;color for timer number
mov backc , 06h ;color for background of timer
;temp variables first general, second for row, tird for col
mov tmpdb , 0
mov tmpdbr , 0
mov tmpdbc , 0
mov tmptype , 0
mov currtype , 0
mov nexttype , 0
mov tmpr , 0
mov tmpc , 0
mov movr , 0
mov movc , 0
mov tmpdb2 , 0
mov tmpnumber , 0h  ;number for timer put number in this variable before calling timer function proc
mov passer , 0h ;variable to be passed to procs
;selected variables and colors
mov selectedr , -1
mov selectedc , -1
mov selected , 0
mov selectAtrec , 0
mov moveavailc , 0Ah
mov takeavailc , 4h 

mov success , 0 ;0 for fail 1 for success
mov AvoidLp , 0
mov head , 0
mov VALUE  , 0     ;VALUE which will be sent or Received by user
mov initxS , 25     ;initial position for sender column
mov inityS , 9     ;initial position for sender row
mov initxR , 25     ;initial position for receiver column
mov inityR , 18    ;initial position for receiver row
mov rowInitChezz , 0
mov colInitChezz ,  0
mov typeInitChezz , 0
mov picInitChezz   , 0
;/*****************************************/
mov colorD , 0
mov rowD , 0
mov colD , 0
mov datalocD , 0

mov playtime , 0
mov playtimeS , 0
mov playtimeH , 0
mov counter , 0
;/*****************************************/
ENDM


promote macro row,col
local nopromotion,promotion1,promotion2,mightpromomte,promotion3
;//////////////////////////////////////////
;check for promotion
;ispawn?
getdb row,col
mov al,chezzT[bx]
and al,0fh
cmp al,5
jz promotion1
jmp far ptr nopromotion
promotion1:
cmp row,0
jz promotion2
jmp far ptr mightpromomte
promotion2:
;///////////////////white promote to queen
mov promotflag,1
mov al,chezzT[BX]
sub al,4
mov chezzT[bx],al
mov ax,chezzP[bx]
mov ax,offset queenData;//might not work
add bx,bx
mov chezzP[bx],ax
DrawPieceDB PrimaryC,SecondaryC,0,0,0Fh,row,col,begr,begc,endr,endc,res ;drawing the piece at the new location
jmp far ptr nopromotion
mightpromomte:
cmp row,7
jz promotion3
jmp far ptr nopromotion

promotion3:
;///////////////////black promote to queen
mov promotflag,1
mov al,chezzT[BX]
sub al,4
mov chezzT[bx],al
mov ax,chezzP[bx]
mov ax,offset queenData;//might not work
add bx,bx
mov chezzP[bx],ax
DrawPieceDB PrimaryC,SecondaryC,0,0,0,row,col,begr,begc,endr,endc,res ;drawing the piece at the new location
nopromotion:
endm promote
