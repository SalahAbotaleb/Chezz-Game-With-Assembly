EXTRN SEND:FAR
EXTRN RECIEVE:FAR
EXTRN INITCONECT:FAR
EXTRN RecievedROLD:WORD
EXTRN RecievedCOLD:WORD
EXTRN RecievedRNEW:WORD
EXTRN RecievedCNEW:WORD
EXTRN Exist:BYTE

PUBLIC SendROLD,SendCOLD,SendRNEW,SendCNEW

include mymacros.inc
include DrawingM.inc
include Moves.inc
include timer.inc       
.Model MEDIUM
.286
.Stack 64
.Data
org(1000)
boardWidth EQU 200
boardHeight EQU 200

SendROLD DW -1
SendCOLD DW -1

SendRNEW DW -1
SendCNEW DW -1

begr DW 0
begc DW 0
endr DW 0
endc DW 0
res db 0

tmpx DW 0
tmpy DW 0

row DW 0
col DW 0

rowx DW 0
colx DW 0

killWC DB 0 ;counter for killed white
killBC DB 0 ;counter for killed black

prevR DW 0
prevC DW 0

piecew EQU 25
pieceh EQU 25


;colors 
;0  Black
;1  blue
;2  green
;3  Aqua
;4  Red
;5  Purple
;6  brown
;7  light gray
;8  dark Gray,
;9  Light Blue.
;A  Light Green
;B  Light Aqua
;C  Light Red
;D  Light Purple
;E  Yellow
;F  White


PrimaryC DB 6h
SecondaryC DB 7h

NUMCOLOR DB 0Bh;color for timer number
backc DB 06h ;color for background of timer
;temp variables first general, second for row, tird for col
tmpdb db ?
tmpdbr db ?
tmpdbc db ?
tmptype db ?
currtype db ?
nexttype db ?
tmpr dw ?
tmpc dw ?
movr dw ?
movc dw ?
tmpdb2 db ?
tmpnumber dw 0h  ;number for timer put number in this variable before calling timer function proc
passer dw 0h ;variable to be passed to procs
;selected variables and colors
selectedr DW -1
selectedc DW -1
selected DB 0

moveavailc DB 0Ah
takeavailc db 4h 

boardFilename DB 'chessB.bin', 0
rookFilename DB 'rook.bin',0
horseFilename DB 'horse.bin',0
kingFilename DB 'king.bin',0
soliderFilename DB 'solider.bin',0
bishopFilename DB 'bishop.bin',0
queenFilename DB 'queen.bin',0
debugFilename DB 'DEBUG.txt',0
debugfilehand DW ?

filehandle DW ?

boardData DB boardWidth*boardHeight dup(0)

rookData DB piecew*pieceh dup(0)
horseData DB piecew*pieceh dup(0)
bishopData DB piecew*pieceh dup(0)
queenData DB piecew*pieceh dup(0)
kingData DB piecew*pieceh dup(0)
soliderData DB piecew*pieceh dup(0)
errormsg db 'canot laod image file$'

;chezzP array of pointer for chezz pictures, chezzT array of type of each piece, chezzT array for chezz box color
chezzP DW 64 dup(-1)
chezzT DB 64 dup(-1)
chezzC DB 64 dup(-1)
chezzN DB 64 dup(-1) ;numbering of each piece
chezznrev Dw 32 dup(-1) ;reverse numbering of each piece
Timer  DB 32 dup(-1)
time DB 32 dup(0) 
;0 to 15 black pieces
;16 to 31 white pieces
;cronologicaly from left to right and top to bottom
;///////////////////////////////////////////
playertpye DB 0 ;0 for white 1 for Black
;probably serial port
;you need to set player type


success DB 0 ;0 for fail 1 for success

;///////////////////////////////////////////
head DW 0
storage DB 64 dup(-1)

;/******DRAW PIECE FUNCTION WRAPPER********/
PrimaryCW DB 0
SecondaryCW DB 0
rowW DW 0
colW DW 0
pieceColorW DB 0
resW DB 0
begrW DW 0
begcW DW 0
endrW DW 0
endcW DW 0
roffsetW DW 0
coffsetW DW 0
;/*****************************************/


.Code

;/*****************************************/
;procude that prints a number on the screen from 3 to 1
Drawtimp PROC
; local num1,num2,num3,notnum1,notnum2,notnum3,lop1,lop2,lop3,lop22,lop33,lop23,lop32,lop12,lop13
pusha
    mov ax,tmpnumber
    cmp ax,1
    je num1
    jmp far ptr notnum1
    num1:
    ;draw 1

    mov dx,0
    lop13:

    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl
    mov cx,dx
    push dx
    mov cx,dx
    mov cx,ax
    add dx,bx
    add dx,10d
    add cx,13d

    push ax
    mov al,backc
    mov ah,0ch
    INT 10h
    pop ax
    pop DX
    inc dx
    cmp dx,4
    jne lop13
 ;///////////////////
    mov dx,0
    lop12:

    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl
    mov cx,dx
    push dx
    mov dx,cx
    mov cx,ax
    add dx,bx
    add dx,10d
    add cx,11d

    push ax
    mov al,backc
    mov ah,0ch
    INT 10h
    pop ax
    pop DX
    inc dx
    cmp dx,4
    jne lop12
;///////////////////
    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl
    ;now we have begging stored at ax for colx begging
    ;and bx for rowx begging
    mov cx,ax
    mov dx,bx
    add dx,10d
    add cx,11d
    mov ah,0ch
    mov al,numcolor
    INT 10h

    mov bx,dx
    dec bx
    mov dx,0

;//////////////////
    lop1:

    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl
    mov cx,dx
    push dx
    mov cx,dx
    mov cx,ax
    add dx,bx
    add dx,10d
    add cx,12d

    push ax
    mov al,numcolor
    mov ah,0ch
    INT 10h
    pop ax
    pop DX
    inc dx
    cmp dx,5
    jne lop1

    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl

    mov cx,ax
    mov dx,bx
    add dx,14d
    add cx,11d
    mov ah,0ch
    mov al,numcolor
    INT 10h

    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl

    mov cx,ax
    mov dx,bx
    add dx,14d
    add cx,13d
    mov ah,0ch
    mov al,numcolor
    INT 10h

    ;;;;;;;;;;
    notnum1:
    cmp ax,2
    je num2
    jmp far ptr notnum2
    num2:
    ;draw 2

    mov cx,0
    lop2:
    mov dx,cx
    push cx
    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl
   
    mov cx,dx
    add cx,ax
    mov dx,bx
    add dx,12d
    add cx,11d

    push ax
    mov al,numcolor
    mov ah,0ch
    INT 10h
    pop ax
    pop cX
    inc cx
    cmp cx,3
    jne lop2

    ;second loop

    mov cx,0
    lop22:
    mov dx,cx
    push cx
    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl
       
    mov cx,dx
    add cx,ax
    mov dx,bx
    add dx,10d
    add cx,11d

    push ax
    mov al,numcolor
    mov ah,0ch
    INT 10h
    pop ax
    pop cX
    inc cx
    cmp cx,3
    jne lop22

    ;third loop

    mov cx,0
    lop23:

    mov dx,cx
    push cx
    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl
       
    mov cx,dx
    add cx,ax
    mov dx,bx
    add dx,14d
    add cx,11d

    push ax
    mov al,numcolor
    mov ah,0ch
    INT 10h
    pop ax
    pop cX
    inc cx
    cmp cx,3
    jne lop23

    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl

    mov cx,ax
    mov dx,bx
    add dx,11d
    add cx,13d
    mov ah,0ch
    mov al,numcolor
    INT 10h

    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl

    mov cx,ax
    mov dx,bx
    add dx,13d
    add cx,11d
    mov ah,0ch
    mov al,numcolor
    INT 10h


    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl

    mov cx,ax
    mov dx,bx
    add dx,13d
    add cx,13d
    mov ah,0ch
    mov al,backc
    INT 10h

    notnum2:
    cmp ax,3
    je num3
    jmp far ptr notnum3
    num3:
    ;draw 3

    mov cx,0
    lop3:
    mov dx,cx
    push cx
    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl
   
    mov cx,dx
    add cx,ax
    mov dx,bx
    add dx,12d
    add cx,11d

    push ax
    mov al,numcolor
    mov ah,0ch
    INT 10h
    pop ax
    pop cX
    inc cx
    cmp cx,3
    jne lop3

    ;second loop

    mov cx,0
    lop32:
    mov dx,cx
    push cx
    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl
       
    mov cx,dx
    add cx,ax
    mov dx,bx
    add dx,10d
    add cx,11d

    push ax
    mov al,numcolor
    mov ah,0ch
    INT 10h
    pop ax
    pop cX
    inc cx
    cmp cx,3
    jne lop32

    ;third loop

    mov cx,0
    lop33:

    mov dx,cx
    push cx
    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl
       
    mov cx,dx
    add cx,ax
    mov dx,bx
    add dx,14d
    add cx,11d

    push ax
    mov al,numcolor
    mov ah,0ch
    INT 10h
    pop ax
    pop cX
    inc cx
    cmp cx,3
    jne lop33

    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl

    mov cx,ax
    mov dx,bx
    add dx,11d
    add cx,13d
    mov ah,0ch
    mov al,numcolor
    INT 10h

    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
    mul cl

    mov cx,ax
    mov dx,bx
    add dx,13d
    add cx,13d
    mov ah,0ch
    mov al,numcolor
    INT 10h


    notnum3:
    popa
    ret;

Drawtimp ENDP

DrawPieceW PROC
    ;local drawLoop,noerror,lblprim,lblsec,filter,contin,Nempty,exit,sec,con
    ;primaryC is primary Color for the board which is at top left coener 
    ;secondaryC is secondart color next to first square 
    ;better to define primaryC and SecondaryC at begging of program
    ;row is from 0 to 7
    ;col is from 0 to 7
    ;piece color is the main color of the piece and secondary color will be background color
    ;roffset for row offset
    ;coffset for col offset
    pusha
    cmp rowW,0FFh
    jne nn
    ;returntoconsole
    nn:
    ;***********Drawing the pixels
    ;Nempty:
    mov ax,rowW
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colW
    mul cl
    ;now we have begging stored at ax for col begging
    ;and bx for row begging

    mov begrW,0
    mov cx,roffsetW
    add begrW,cx
    add begrW,bx

    mov begcW,0
    mov cx,coffsetW
    add begcW,cx
    add begcW,ax
     
    mov endrW,bx
    mov endcW,ax

    add endrW,25d
    add endcW,25d

    mov cx,0
    mov ah,0
    mov ax,rowW
    mov bx,2
    div bl
    xor cl,ah

    mov ah,0
    mov ax,colW
    mov bx,2
    div bl
    xor cl,ah
    
    mov resw,cl

    getdw rowW,colW
    mov ax,chezzP[bx]
    cmp ax,-1
    JNZ Nempty
    mov ax,0
    cmp resw,0
    jnz sec 
    mov al,PrimaryCW
    jmp con
    sec:mov al,SecondaryCW
    
    con:mov resw,al
    Drawsquare colW,rowW,begrW,begcW,resw
    jmp exitw
    
    Nempty:
    getdw rowW,colW
    mov bx,chezzP[bx]
    ;mov BX , dataloc ; BL contains index at the current drawn pixel
    MOV CX,begcW
    MOV DX,begrW
    MOV AH,0ch
    drawLoop:
    MOV AL,[BX]
    cmp al,5
    ja filterW
    cmp resw,0
    jnz lblsec 
    lblprim:mov al,PrimaryCW
    jmp continW
    lblsec:mov al,SecondaryCW
    jmp continW
    filterW: mov al,pieceColorW
    continW:
    INT 10h 
    INC CX
    INC BX
    CMP CX,endcW
    JNE drawLoop 
	
    MOV CX ,begcW
    INC DX
    CMP DX ,endrW
    JNE drawLoop
    ;************end drawing the pixels
    ;msh hetetak enta khales
    getdb roww,colw
    mov al,chezzN[BX]
    cmp al,-1
    jnz continuew
    jmp far ptr exitw
    continuew:
    mov ah,0
    mov bx,ax
    mov al,time[bx]
    mov ah,0
    mov passer,AX
    push ax

    mov ax,roww
    mov rowx,ax
    mov ax,colw
    mov colx,ax
    getdb rowx,colx
    mov cl,timer
    Drawtim passer
    pop ax

    ;////////////////////
    exitw:
    popa
    ret
DrawPieceW ENDP




MAIN PROC FAR
    MOV AX , @DATA
    MOV DS , AX
    MOV AH, 0
    MOV AL, 13h
    INT 10h

    ;/*********/
    ; mov al, 1
	; mov dx, offset debugFilename
	; mov ah, 3dh
	; int 21h
	; mov debugfilehand, ax
    ;/*********/
	DrawBoard  PrimaryC,SecondaryC,boardFilename,Filehandle,boardData,boardHeight,boardWidth
	DrawPiece  PrimaryC,SecondaryC,RookFilename,filehandle,rookData,0,0,0h,0,0,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,rookData,0,0,0h,0,7,begr,begc,endr,endc,res
    DrawPiece  PrimaryC,SecondaryC,horseFilename,filehandle,horseData,0,0,0h,0,1,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,horseData,0,0,0h,0,6,begr,begc,endr,endc,res
    DrawPiece  PrimaryC,SecondaryC,bishopFilename,filehandle,bishopData,0,0,0h,0,2,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,bishopData,0,0,0h,0,5,begr,begc,endr,endc,res
    DrawPiece  PrimaryC,SecondaryC,queenFilename,filehandle,queenData,0,0,0h,0,3,begr,begc,endr,endc,res
    DrawPiece  PrimaryC,SecondaryC,kingFilename,filehandle,kingData,0,0,0h,0,4,begr,begc,endr,endc,res
    DrawPiece  PrimaryC,SecondaryC,soliderFilename,filehandle,soliderData,0,0,0h,1,0,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0h,1,1,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0h,1,2,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0h,1,3,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0h,1,4,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0h,1,5,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0h,1,6,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0h,1,7,begr,begc,endr,endc,res


    DrawPieceD  PrimaryC,SecondaryC,rookData,0,0,0Fh,7,7,begr,begc,endr,endc,res
	DrawPieceD  PrimaryC,SecondaryC,rookData,0,0,0Fh,7,0,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,horseData,0,0,0Fh,7,1,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,horseData,0,0,0Fh,7,6,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,bishopData,0,0,0Fh,7,2,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,bishopData,0,0,0Fh,7,5,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,queenData,0,0,0Fh,7,3,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,kingData,0,0,0Fh,7,4,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0Fh,6,0,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0Fh,6,1,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0Fh,6,2,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0Fh,6,3,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0Fh,6,4,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0Fh,6,5,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0Fh,6,6,begr,begc,endr,endc,res
    DrawPieceD  PrimaryC,SecondaryC,soliderData,0,0,0Fh,6,7,begr,begc,endr,endc,res

    ;1x for black 
    ;0x for white
    ;0 for king
    ;1 for queen
    ;2 for rook
    ;3 for bishop
    ;4 for horse
    ;5 for solider/pawn
    ;    | 0         | 1          | 2         | 3          | 4         | 5         |
    ;------------------------------------------------
    ; 0  |white king|white queen |white  rook |white bishop|white horse|white  pawn|
    ; 1  |black king|black queen |black  rook |black bishop|black horse|black  pawn|
    ;pic,row,col,t,chezzP,chezzT
    initchezzN PrimaryC,SecondaryC,chezzN
    initchezzC PrimaryC,SecondaryC,chezzC,res
    initchezz  rookData,0,0,12h,chezzP,chezzT
    initchezz  rookData,0,7,12h,chezzP,chezzT

    initchezz  horseData,0,1,14h,chezzP,chezzT
    initchezz  horseData,0,6,14h,chezzP,chezzT
    
    initchezz  bishopData,0,2,13h,chezzP,chezzT
    initchezz  bishopData,0,5,13h,chezzP,chezzT
    
    initchezz  queenData,0,3,11h,chezzP,chezzT
    
    initchezz  kingData,0,4,10h,chezzP,chezzT
    
    initchezz  soliderData,1,0,15h,chezzP,chezzT
    initchezz  soliderData,1,1,15h,chezzP,chezzT
    initchezz  soliderData,1,2,15h,chezzP,chezzT
    initchezz  soliderData,1,3,15h,chezzP,chezzT
    initchezz  soliderData,1,4,15h,chezzP,chezzT
    initchezz  soliderData,1,5,15h,chezzP,chezzT
    initchezz  soliderData,1,6,15h,chezzP,chezzT
    initchezz  soliderData,1,7,15h,chezzP,chezzT

    ;/****************************************************************************************/

    initchezz  rookData,7,0,02h,chezzP,chezzT
    initchezz  rookData,7,7,02h,chezzP,chezzT

    initchezz  horseData,7,1,04h,chezzP,chezzT
    initchezz  horseData,7,6,04h,chezzP,chezzT

    initchezz  bishopData,7,2,03h,chezzP,chezzT
    initchezz  bishopData,7,5,03h,chezzP,chezzT

    initchezz  queenData,7,3,01h,chezzP,chezzT

    initchezz  kingData,7,4,00h,chezzP,chezzT

    initchezz  soliderData,6,0,05h,chezzP,chezzT
    initchezz  soliderData,6,1,05h,chezzP,chezzT
    initchezz  soliderData,6,2,05h,chezzP,chezzT
    initchezz  soliderData,6,3,05h,chezzP,chezzT
    initchezz  soliderData,6,4,05h,chezzP,chezzT
    initchezz  soliderData,6,5,05,chezzP,chezzT
    initchezz  soliderData,6,6,05h,chezzP,chezzT
    initchezz  soliderData,6,7,05h,chezzP,chezzT
    
    
    ;/******************test area***************************/
        
         ;replace 6,7,5,4
         ;replace 6,3,2,3

    ;/******************end of test area***************************/

    mov row,0
    mov col,0

    mov prevR,0
    mov prevC,0
    
    lea si,chezzP
    lea di,chezzT
    DrawPieceDB  0EH,0EH,0,0,0h,row,col,begr,begc,endr,endc,res


   ;/****************************************************************************************/
   CALL INITCONECT
   ;Q means the user wants to select
    Q:
    ;check king dead condition
    pusha
    mov ax,chezznrev[4]
    mov bx,00h
    mov bl,ah
    mov rowx,bx
    mov bl,al
    mov colx,bx
    getdb rowx,colx
    mov dl,chezzT[BX]
    cmp dl,00h
    JE bkingnotdead
    jmp far ptr blackkingdead
    bkingnotdead:
    mov ax,chezznrev[14]
    mov bx,00h
    mov bl,ah
    mov rowx,bx
    mov bl,al
    mov colx,bx
    getdb rowx,colx
    mov dl,chezzT[BX]
    cmp dl,10h
    JE wkingnotdead
    jmp far ptr blackkingdead
    wkingnotdead:
    popa
    ;////////////////////////
    updatetime
     ;/**********/
    CALL RECIEVE
    cmp EXIST,4
    JE ContUpdate
    jmp far ptr NoUpdate
    ContUpdate:
    mov exist,0
    movepiece RecievedRNEW,RecievedCNEW,1
    ;/**********/
    NoUpdate:
    MOV AH,1;every time looping we check here whether a key was selected or not
    INT 16h
    push ax
    jz noflush
    mov ah,0Ch
    INT 21h
    
    noflush:
    pop ax
    cmp ah,1Ch  ;press Q condition
    JE doQ
    jmp far ptr right
   ;/****************************************************************************************/
    doQ:
    ;/****/ here error

    getdb prevR,prevC
    mov dx,0
    mov dl,chezzN[BX]
    cmp dl,-1
    JE validtime
    mov bx,dx
    mov dx,0
    mov dl,time[bx]
    cmp dx,0
    JE validtime
    jmp far ptr q
    validtime:
    ;/*********/
    
    cmp selected,0
    jne movepiece1
    jmp far ptr choosepiece1 
    movepiece1:
;calling function to move a piece
    push row
    push col
    movepiece row,col,0
    pop col
    pop row
    jmp far ptr DrawBckGnd ;need to be modified ;;
    choosepiece1:

    ;calling function to choose a piece
    mov success,0
    push row
    push col
    choosepiece PrimaryC,SecondaryC,chezzP,chezzT,chezzC,playertpye,moveavailc,takeavailc,prevR,prevC,success,begr,begc,endr,endc,res
    pop col
    pop row
    cmp success,1
    je suc
    jmp far ptr right ;;;;;
    suc:
    selectp row,col
 ;/****************************************************************************************/
    DrawBckGnd:

    ;fuction that update
    mov ax,row
    mov bx,col
    
    mov prevR,ax
    mov prevC,bx

    lea si,chezzP
    lea di,chezzT
    mov ax,8
    mov bx,row
    mul bl
    add ax,col
    add di,ax
    add ax,ax
    add si,ax  
    mov ax,[si]
    
    mov bx,0
    mov bl,[di]

    shr bl,1
    shr bl,1
    shr bl,1
    shr bl,1
    ;we are moving the color bit to the lsb

    cmp bl,1
    JE BlackGND
    jmp far ptr whiteGND
    BlackGND:DrawPieceDB  0EH,0EH,0,0,0h,row,col,begr,begc,endr,endc,res
    jmp far ptr Q
    whiteGND:DrawPieceDB  0EH,0EH,0,0,0Fh,row,col,begr,begc,endr,endc,res
    jmp far ptr Q
     ;/****************************************************************************************/

    ;/****************************************************************************************/
    right:
   
    cmp ah,4DH  ;right condition
    JNE left
    inc col
    jmp validate
    
    left:
    cmp ah,4BH  ;left condition
    JNE up
    dec col
    jmp validate

    up:
    cmp ah,48H  ;up condition
    JNE down
    dec row
    jmp validate

    down:
    cmp ah,50H   ;down condition
    JE skipthis 
    jmp far ptr Q ;if no key is pressed here we go to the beggining of the loop again
    skipthis:
    inc row

    validate:
    mov ax,row
    mov bx,col
    cmp ax,8
    JAE resolve
    cmp ax,0
    JB resolve
    cmp bx,8
    JAE resolve
    cmp bx,0
    JB resolve
    
    jmp draw
    
    resolve:
    mov ah,2 
    mov dl,7
    int 21h 
    mov ax,prevR
    mov bx,prevC
    mov row,ax
    mov col,bx
    jmp far ptr Q

    draw:
    mov ax,row
    mov bx,col
    cmp prevR,ax
    jne nredraw ;no redraw if the user still on same cell
    cmp prevC,bx
    jne nredraw
    jmp far ptr Q

    nredraw:
    mov bx,0
    mov bl,[di]

    shr bl,1
    shr bl,1
    shr bl,1
    shr bl,1
    ;we are moving the color bit to the lsb

    cmp bl,1
    JE BlackP
    jmp far ptr whiteP
    mov bx,0
    blackP:
     getdb prevR,prevC
     mov al,chezzC[bx]
     mov tmpdb,al
    DrawPieceDB  tmpdb,tmpdb,0,0,0h,prevR,prevC,begr,begc,endr,endc,res
    jmp contDr
    whiteP:
     getdb prevR,prevC
     mov al,chezzC[bx]
     mov tmpdb,al
    DrawPieceDB  tmpdb,tmpdb,0,0,0Fh,prevR,prevC,begr,begc,endr,endc,res
    
    ;PrimaryC,SecondaryC,dataloc,roffset,coffset,pieceColor,row,col,begr,begc,endr,endc,res
    
    contDr:
    ;fuction that updates


    mov ax,row
    mov bx,col
    
    mov prevR,ax
    mov prevC,bx

    lea si,chezzP
    lea di,chezzT
    mov ax,8
    mov bx,row
    mul bl
    add ax,col
    add di,ax
    add ax,ax
    add si,ax  
    mov ax,[si]
    
    mov bx,0
    mov bl,[di]

    shr bl,1
    shr bl,1
    shr bl,1
    shr bl,1
    ;we are moving the color bit to the lsb

    cmp bl,1
    JE Black
    jmp far ptr white
    Black:DrawPieceDB  0EH,0EH,0,0,0h,row,col,begr,begc,endr,endc,res
    jmp far ptr Q
    white:DrawPieceDB  0EH,0EH,0,0,0Fh,row,col,begr,begc,endr,endc,res
    jmp far ptr Q
    ;/****************************************************************************************/
    ;white king dead
    whitekingdead:

    ;black wins the game

    jmp far ptr death
    ;/****************************************************************************************/
    ;black king dead
    blackkingdead:

    ;white wins the game

    ;/****************************************************************************************/
    death:
    ;Press any key to exit
    mov  ah, 3eh
    lea  bx, debugFilename
    int  21h 
    returntoconsole
MAIN ENDP
end main