EXTRN SEND:FAR
EXTRN RECIEVE:FAR
EXTRN INITCONECT:FAR
EXTRN RecievedROLD:WORD
EXTRN RecievedCOLD:WORD
EXTRN RecievedRNEW:WORD
EXTRN RecievedCNEW:WORD
EXTRN Exist:BYTE
EXTRN INPUT_NAME:BYTE
EXTRN VALUER: BYTE
EXTRN playertpye:BYTE

PUBLIC SendROLD,SendCOLD,SendRNEW,SendCNEW,main

include mymacros.inc
include DrawingM.inc
include Moves.inc
include timer.inc       
.Model MEDIUM
.286
.Stack 64
.Data
boardWidth EQU 200
boardHeight EQU 200

keystrokeF DB 0

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

wkingR DW 0
wkingC DW 0

bkingR DW 0
bkingC DW 0

wkingdead db 0
bkingdead db 0
 
threat db 0

rowcheck DW 0
colcheck DW 0

chooseR DW 0
chooseC DW 0

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

constPrim DB 6h
constSec DB 7h

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
selectAtrec DB 0



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

;chezzP array of pointer for chezz pictures, chezzT array of type of each piece, chezzC array for chezz box color
chezzP DW 64 dup(-1)
chezzT DB 64 dup(-1)
chezzC DB 64 dup(-1)
chezzN DB 64 dup(-1) ;numbering of each piece
chezznrev Dw 32 dup(-1) ;reverse numbering of each piece
Timer  DB 32 dup(-1)
time DB 32 dup(0) 

timerBeg dw 0
timerEnd dw 32
;0 to 15 black pieces
;16 to 31 white pieces
;cronologicaly from left to right and top to bottom
;///////////////////////////////////////////
;playertpye DB 1;0 for white 1 for Black
;probably serial port
;you need to set player type


success DB 0 ;0 for fail 1 for success
AvoidLp DB 0
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

status_msg DB "Status:-$"
checkmate_msg DB "CheckMate$"
black_win_msg DB "Black Win$$"
white_win_msg DB "White Win$$"
black_killed_msg DB "Black Kill: $$$"
white_killed_msg DB "White Kill: $$$"
seperation_line DB "---------------$"
notification_msg DB "Notification:-$"
first_name DB "First Name:-$"
second_name DB "Second Name:-$"
Timer_Counter DB "Timer: $"

VALUE  db ?     ;VALUE which will be sent or Received by user
initxS db 25     ;initial position for sender column
inityS db 9     ;initial position for sender row
initxR db 25     ;initial position for receiver column
inityR db 18    ;initial position for receiver row
rowInitChezz DB ?
colInitChezz DB  ?
typeInitChezz DB ?
picInitChezz   DW ?
;/*****************************************/
colorD DB ?
rowD DW 0
colD DW 0
datalocD DW 0

playtime DB 0
playtimeS DB 0
playtimeH DB 0
counter DB 0

promotflag DB 0
;/*****************************************/
StackPA DW 0
StackPB DW 0
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
    exittt:
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
    getdb rowW,colW
    cmp chezzC[bx],-1
    je contDra
    mov al,chezzC[bx]
    mov PrimaryC,al
    mov al,chezzC[bx]
    mov SecondaryC,al
    contDra:
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
    mov al,constPrim
    mov PrimaryC ,al
    mov al,constSec
    mov SecondaryC,al
    ret
DrawPieceW ENDP

inittChezzW proc
pusha
lea si,chezzP
lea di,chezzT

mov bx,0
mov ax,8
mov bl,rowInitChezz
mul bl
add al,colInitChezz

add di,ax
mov bl,typeInitChezz
mov [di],bl

add ax,ax

add si,ax

mov ax,picInitChezz
mov [si],ax

popa
ret
inittChezzW ENDP


IN_GAME_CHATTING_recieve proc far
    pusha

    mov al,valueR
    CMP al, 08h   ; check backpace
    jz bckspace2
    jmp ContLineR
    bckspace2:
    dec initxR
    cmp initxR, 24d
    JE backliner   ; check if it is the last column in the left, so that we don't remove parts of the board
    setCursor initxR,inityR
    printcharGraphicsR ' ',0h    ; to delete when backspacing
    setCursor initxR,inityR
    jmp IgnoreR

    backliner:
    cmp inityR,18
    JNE contback
    inc initxR
    jmp IgnoreR
    contback:
    dec inityR
    mov initxr,39d
    setCursor 39d,inityR
    printcharGraphicsR ' ',0h    ; to delete when backspacing
    setCursor 39d,inityR
    JMP IgnoreR

    ContLineR:
    setCursor initxR,inityR     ; setting the cursor after newlineR
    printcharGraphicsR VALUEr, 0fh             ; printing the char
    
    inc initxR
    cmp initxR,40d
    JE resolveEnd
    jmp IgnoreR
    resolveEnd:
    mov initxR,25d

    cmp inityR,24d   ;check if the cursor is in the bottom of the lower screen to scrollup one line
    jNE okY  ;just new line
    scrolllower
    mov initxR,25d
    mov inityR,24d

    jmp IgnoreR

    okY:inc inityR
    IgnoreR:
    popa
    ret
IN_GAME_CHATTING_recieve ENDP
MAIN PROC FAR
    MOV AX , @DATA
    MOV DS , AX
    MOV AH, 0
    MOV AL, 13h
    INT 10h
    pop StackPA
    pop StackPB
    deinitAll
	;DrawBoard  PrimaryC,SecondaryC,boardFilename,Filehandle,boardData,boardHeight,boardWidth
    



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
    DrawBoard  PrimaryC,SecondaryC,boardFilename,Filehandle,boardData,boardHeight,boardWidth
    DrawPiece  PrimaryC,SecondaryC,RookFilename,filehandle,rookData,0,0,0h,0,0,begr,begc,endr,endc,res
    DrawPiece  PrimaryC,SecondaryC,horseFilename,filehandle,horseData,0,0,0h,0,1,begr,begc,endr,endc,res
    DrawPiece  PrimaryC,SecondaryC,bishopFilename,filehandle,bishopData,0,0,0h,0,2,begr,begc,endr,endc,res
    DrawPiece  PrimaryC,SecondaryC,queenFilename,filehandle,queenData,0,0,0h,0,3,begr,begc,endr,endc,res
    DrawPiece  PrimaryC,SecondaryC,kingFilename,filehandle,kingData,0,0,0h,0,4,begr,begc,endr,endc,res
    DrawPiece  PrimaryC,SecondaryC,soliderFilename,filehandle,soliderData,0,0,0h,1,0,begr,begc,endr,endc,res
   

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



    ;/*********/
	;DrawPieceDB  0EH,0EH,0,0,0h,row,col,begr,begc,endr,endc,res
    ;DrawPieceDB MACRO PrimaryC,SecondaryC,roffset,coffset,pieceColor,row,col,begr,begc,endr,endc,res
	;DrawPieceD MACRO PrimaryC,SecondaryC,dataloc,roffset,coffset,pieceColor,row,col,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0h,0,7,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0h,0,6,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0h,0,5,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0h,1,1,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0h,1,2,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0h,1,3,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0h,1,4,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0h,1,5,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0h,1,6,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0h,1,7,begr,begc,endr,endc,res


    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,7,7,begr,begc,endr,endc,res
	DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,7,0,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,7,1,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,7,6,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,7,2,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,7,5,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,7,3,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,7,4,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,6,0,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,6,1,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,6,2,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,6,3,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,6,4,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,6,5,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,6,6,begr,begc,endr,endc,res
    DrawPieceDB  PrimaryC,SecondaryC,0,0,0Fh,6,7,begr,begc,endr,endc,res

   
    ;-------
    
    DisplayStringGraphicMode status_msg,8,25,1
    DisplayStringGraphicMode white_killed_msg,12,26,2
    ;DisplaynumberGraphicMode killWC,37,2
    DisplayStringGraphicMode black_killed_msg,12,26,3
    DisplayStringGraphicMode Timer_Counter,7,26,5

    ;DisplaynumberGraphicMode killBC,37,3
    ;DisplayStringGraphicMode checkmate_msg,9,27,5
    ;DisplayStringGraphicMode black_win_msg,9,27,6
    ;DisplayStringGraphicMode white_win_msg,9,27,6
    DisplayStringGraphicMode seperation_line,15,25,7
    DisplayStringGraphicMode first_name,12,25,8
    DisplayStringGraphicMode seperation_line,15,25,16
    DisplayStringGraphicMode second_name,13,25,17
    pusha
    mov ax,2c00h
    int 21h
    ; mov playtimes,dh
    ; mov playtimeH,Cl
    mov Al,cl
    mov bl,3Ch
    mul bl
    add Al,dh
    mov playtime,al
    popa
    ;-------initializations

    ; cmp playertpye,0

    ; JE whiteb
    ; jmp blck
    ; whiteb:
    ; mov timerBeg,16
    ; mov timerend,32
    ; jmp initEnd
    ; blck:
    ; mov timerBeg,0
    ; mov timerend,16
    initEnd:
    ;-------


    ;/******************test area***************************/
        
         ;replace 6,7,5,4
         ;replace 6,3,2,3

    ;/******************end of test area***************************/
    
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
    mov keystrokeF,0
      DisplaynumberGraphicMode killBC,37,3
     ;;comment
     DisplaynumberGraphicMode killWC,37,2
    cmp wkingdead,1
    jne wkingisalive
    jmp far ptr whitekingdead
    wkingisalive:
    cmp bkingdead,1
    jne bkingisalive
    jmp far ptr blackkingdead
    bkingisalive:
    popa
    ;//check for checkmate
    pusha
    mov bx,0
    mov bl,playertpye
    shr bl,1
    shr bl,1
    shr bl,1
    shr bl,1
    add bl,5
    mov ax,chezznrev[bx]
    mov cx,0
    mov cl,ah
    mov rowcheck,cx
    mov cx,0
    mov cl,al
    mov colcheck,cx
    checkformate playertpye,threat,rowcheck,colcheck,7
    cmp threat,1
    jne notcheckmateend
    ;something needs to happen when his is checked
    DisplayStringGraphicMode checkmate_msg,9,26,6
    notcheckmateend:
    popa
    ;//check for chekcmate end
    ;/////////////////////////
    updatetime
     pusha
    mov ax,2c00h
    int 21h

    mov al,cl
    mov bl,3Ch
    mul bl
    add al,dh
    sub al,playtime
    mov counter,al

    movecursorlocation 33,5,0
    mov ax,0
    mov al,counter
    Displaynumber
    popa
     ;/**********/
    push selectedr
    push selectedc
    mov AvoidLp,0
    mov exist,0
    mov valueR,-1
    CALL RECIEVE
    cmp valueR,-1
    JE recCorr
    
    mov ah,0
    mov al,valueR
    ;movecursorlocation 1,1,0
    ;Displaynumber 
    call IN_GAME_CHATTING_recieve
    
    jmp far ptr NoUpdate
    recCorr:cmp EXIST,4
    JE ContUpdate
    jmp far ptr NoUpdate
    ContUpdate:
    ;
    ; mov ax,selectedr
    ; Displaynumber
    ; mov ax,selectedc
    ; Displaynumber
    ; mov al,selected
    ; mov ah,0
    ; Displaynumber
    ;
    mov exist,0
    mov al,selected
    mov selectAtrec,al
    movepiece RecievedRNEW,RecievedCNEW,1
    ;-----------------------------------------------promote RecievedRNEW,RecievedCNEW
    mov AvoidLp,1
    jmp far ptr Reselectp
    ;choosepiece PrimaryC,SecondaryC,chezzP,chezzT,chezzC,playertpye,moveavailc,takeavailc,selectedr,selectedc,success,begr,begc,endr,endc,res
    ;/**********/
    NoUpdate:
    mov ax,0
    MOV AH,1;every time looping we check here whether a key was selected or not
    INT 16h
    push ax
    jz noflush
    mov ah,0Ch
    INT 21h
    mov keystrokeF,1
    
    noflush:
    pop ax
    ;****
    ;cmp ah,3fH ; press Fn+F5 to start in game chatting
    ;JNE skip
    ;****
    ;call IN_GAME_CHATTING
    SKIP:cmp ah,1ch  ;press Q condition
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
    ;------------------------------------------------------promote row,col
    pop col
    pop row
    jmp far ptr DrawBckGnd ;need to be modified ;;
    choosepiece1:

    ;calling function to choose a piece
    mov ax,prevR
    mov chooseR,ax
    mov ax,prevC
    mov chooseC,ax
    mov success,0
    jmp far ptr NoReselect
    Reselectp:
    pop selectedc
    pop selectedr
    mov ax,selectedr
    mov ChooseR,ax
    ;Displaynumber
    ;printnewline
    mov ax,selectedc
    mov ChooseC,ax
    ;Displaynumber
    ;printnewline
    NoReselect:
    push row
    push col
    choosepiece PrimaryC,SecondaryC,chezzP,chezzT,chezzC,playertpye,moveavailc,takeavailc,chooseR,chooseC,success,begr,begc,endr,endc,res
    ;updatetime
    pop col
    pop row
    cmp avoidlp,0
    jz contcheck
    mov ah,0
    mov al,selectAtrec
    mov selected,al
    ;Displaynumber
    ;printnewline
    ;
    ; mov ax,selectedr
    ; Displaynumber
    ; mov ax,selectedc
    ; Displaynumber
    ; mov al,selected
    ;  mov ah,0
    ; Displaynumber
    ;
    jmp far ptr Q
    contcheck:
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
    
    cmp ah,0Eh
    je chat
    cmp al,'Z'
    ja Ascii2
    cmp al,'A'
    jae chat
    ;jmp retMain
    Ascii2:cmp al,'z'
    ja Ascii3
    cmp al,'a'
    jae chat
    Ascii3:cmp ah,39h
    jne retMain
    chat:call IN_GAME_CHATTING_send
    retMain:jmp far ptr Q ;if no key is pressed here we go to the beggining of the loop again
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
    ;drawkingdead
    ; pusha
    ; mov cx,60 ;Column
    ; mov dx,120 ;Row
    ; mov al,5 ;Pixel color
    ; mov ah,0ch ;Draw Pixel Command
    ; theultimateloopb:int 10h 
    ; inc cx
    ; cmp cx,120
    ; jne theultimateloopb
    ; mov cx,60 ;Column
    ; inc dx
    ; cmp dx,150
    ; jne theultimateloopb
    ; popa
    jmp far ptr death1
    ;/****************************************************************************************/
    ;black king dead
    blackkingdead:
    ; pusha
    ; mov cx,60 ;Column
    ; mov dx,120 ;Row
    ; mov al,3  ;Pixel color
    ; mov ah,0ch ;Draw Pixel Command
    ; theultimateloopw:int 10h 
    ; inc cx
    ; cmp cx,120
    ; jne theultimateloopw
    ; popa
    jmp far ptr death2
    ;white wins the game

    ;/****************************************************************************************/
    death1:
    ;Press any key to exit
    DisplayStringGraphicMode black_win_msg,9,27,6
    ssa:
    mov ah,0
    int 16h 
    cmp ah,1
    jne ssa
    push StackPB
    push StackPA
    ret
    death2:
    DisplayStringGraphicMode white_win_msg,9,27,6
    ssb:
    mov ah,0
    int 16h 
    cmp ah,1
    jne ssb
    push StackPB
    push StackPA
    ret
MAIN ENDP


IN_GAME_CHATTING_send proc near
    pusha
    mov value,al
    CMP al, 08h   ; check backpace
    jz bckspace2S
    jmp ContLineS
    bckspace2S:
    dec initxS
    cmp initxS, 24d
    JE backlinerS   ; check if it is the last column in the left, so that we don't remove parts of the board
    setCursor initxS,inityS
    printcharGraphicsR ' ',0h    ; to delete when backspacing
    setCursor initxS,inityS
    jmp IgnoreS

    backlinerS:
    cmp inityS,9
    JNE contbackS
    inc initxS
    jmp IgnoreS
    contbackS:
    dec inityS
    mov initxS,39d
    setCursor 39d,inityS
    printcharGraphicsR ' ',0h    ; to delete when backspacing
    setCursor 39d,inityS
    JMP IgnoreS

    ContLineS:
    setCursor initxS,inityS    ; setting the cursor after newlineR
    printcharGraphicsR VALUE, 0fh             ; printing the char
    
    inc initxS
    cmp initxS,40d
    JE resolveEndS
    jmp IgnoreS
    resolveEndS:
    mov initxS,25d

    cmp inityS,15d   ;check if the cursor is in the bottom of the lower screen to scrollup one line
    jNE okYS  ;just new line
    scrollupper
    mov initxS,25d
    mov inityS,15D

    jmp IgnoreS

    okYS:inc inityS  
    IgnoreS:
    ;Check that Transmitter Holding Register is Empty

    mov dx,3FDH 		; Line Status Register
    AGAIN:In al , dx 	;Read Line Status
    and al , 00100000b
    jz AGAIN          ; Not empty

    ;If empty put the VALUE in Transmit data register

    mov dx , 3F8H		; Transmit data register
    mov al,VALUE        
    out dx , al    

    EXITT:
    popa
RET
IN_GAME_CHATTING_send ENDP

end main