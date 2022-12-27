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

wkingR DW 0
wkingC DW 0

bkingR DW 0
bkingC DW 0

wkingdead db 0
bkingdead db 0
 
threat db 0

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
playertpye DB 0;0 for white 1 for Black
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
black_win_msg DB "Black Win$"
white_win_msg DB "White Win$"
black_killed_msg DB "Black Kill: $"
white_killed_msg DB "White Kill: $"
seperation_line DB "---------------$"
notification_msg DB "Notification:-$"
first_name DB "First Name:-$"
second_name DB "Second Name:-$"

VALUE  db ?     ;VALUE which will be sent or Received by user
initxS db 25     ;initial position for sender column
inityS db 9     ;initial position for sender row
initxR db 25     ;initial position for receiver column
inityR db 18    ;initial position for receiver row

status_msg DB "Status:-$"
checkmate_msg DB "CheckMate$"
black_win_msg DB "Black Win$"
white_win_msg DB "White Win$"
black_killed_msg DB "Black Kill: $"
white_killed_msg DB "White Kill: $"
seperation_line DB "---------------$"
notification_msg DB "Notification:-$"
first_name DB "First Name:-$"
second_name DB "Second Name:-$"

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
; ;/*******/
; DrawPieceDW proc
;     pusha
;      ;***********Drawing the pixels
;     mov ax,rowD
;     mov cx,25d
;     mul cl
;     mov bx,ax

;     mov ax,colD
;     mul cl
;     ;now we have begging stored at ax for colD begging
;     ;and bx for rowD begging

;     mov begr,0
;     add begr,0
;     add begr,bx

;     mov begc,0
;     add begc,0
;     add begc,ax
     
;     mov endr,bx
;     mov endc,ax

;     add endr,25d
;     add endc,25d

;     mov cx,0
;     mov ah,0
;     mov ax,rowD
;     mov bx,2
;     div bl
;     xor cl,ah

;     mov ah,0
;     mov ax,colD
;     mov bx,2
;     div bl
;     xor cl,ah
    
;     mov res,cl


;     mov BX , datalocD ; BL contains index at the current drawn pixel
;     MOV CX,begc
;     MOV DX,begr
;     MOV AH,0ch
;     drawLoopd:
;     MOV AL,[BX]
;     cmp al,5
;     ja filterd
;     cmp res,0
;     jnz lblsecd 
;     lblprimd:mov al,PrimaryC
;     jmp contind
;     lblsecd:mov al,SecondaryC
;     jmp contind
;     filterd: mov al,colorD
;     contind:
;     INT 10h 
;     INC CX
;     INC BX
;     CMP CX,endc
;     JNE drawLoopd 
	
;     MOV CX ,begc
;     INC DX
;     CMP DX ,endr
;     JNE drawLoopd
;     ;************end drawing the pixels
;     popa
; DrawPieceDW endp

;/*******/
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



MAIN PROC FAR
    MOV AX , @DATA
    MOV DS , AX
    MOV AH, 0
    MOV AL, 13h
    INT 10h

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

    DisplayStringGraphicMode status_msg,8,25,1
    DisplayStringGraphicMode white_killed_msg,12,26,2
    DisplaynumberGraphicMode killWC,37,2
    DisplayStringGraphicMode black_killed_msg,12,26,3
    DisplaynumberGraphicMode killBC,37,3
    ;DisplayStringGraphicMode checkmate_msg,9,27,5
    ;DisplayStringGraphicMode black_win_msg,9,27,6
    ;DisplayStringGraphicMode white_win_msg,9,27,6
    DisplayStringGraphicMode seperation_line,15,25,7
    DisplayStringGraphicMode first_name,12,25,8
    DisplayStringGraphicMode seperation_line,15,25,16
    DisplayStringGraphicMode second_name,13,25,17
    



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

   ;/****************************************************************************************/
   CALL INITCONECT
   ;Q means the user wants to select
    Q:
    ;saving king coordinates
    ; pusha
    ; mov ax,chezznrev[4h]
    ; mov bx,00h
    ; mov bl,ah
    ; mov bkingr,bx
    ; mov bl,al
    ; mov bkingC,bx
    ; mov ax,chezznrev[14h]
    ; mov bx,00h
    ; mov bl,ah
    ; mov bkingr,bx
    ; mov bl,al
    ; mov bkingC,bx
    
    
    ;
    ;check king dead condition
    pusha
    cmp wkingdead,1
    jne wkingisalive
    jmp far ptr whitekingdead
    wkingisalive:
    cmp bkingdead,1
    jne bkingisalive
    jmp far ptr blackkingdead
    bkingisalive:
    popa
    ;//check for chekcmate
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
    mov roww,cx
    mov cx,0
    mov cl,al
    mov colw,cx
    ;checkformate playertpye,threat,roww,colw,7
    ;cmp threat,1
    jne notcheckmateend
    ;something needs to happen when his is checked
    ;gototextmode
    notcheckmateend:
    popa
    ;//check for chekcmate end
    ;////////////////////////
    updatetime
     ;/**********/
    push selectedr
    push selectedc
    mov AvoidLp,0
    CALL RECIEVE
    cmp EXIST,4
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
    mov AvoidLp,1
    jmp far ptr Reselectp
    ;choosepiece PrimaryC,SecondaryC,chezzP,chezzT,chezzC,playertpye,moveavailc,takeavailc,selectedr,selectedc,success,begr,begc,endr,endc,res
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
    cmp ah,3fH ; press Fn+F5 to start in game chatting
    JNE skip
    call IN_GAME_CHATTING
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
    ;drawkingdead
    pusha
    mov cx,60 ;Column
    mov dx,120 ;Row
    mov al,5 ;Pixel color
    mov ah,0ch ;Draw Pixel Command
    theultimateloopb:int 10h 
    inc cx
    cmp cx,120
    jne theultimateloopb
    mov cx,60 ;Column
    inc dx
    cmp dx,150
    jne theultimateloopb
    popa
    jmp far ptr death
    ;/****************************************************************************************/
    ;black king dead
    blackkingdead:
    pusha
    mov cx,60 ;Column
    mov dx,120 ;Row
    mov al,3  ;Pixel color
    mov ah,0ch ;Draw Pixel Command
    theultimateloopw:int 10h 
    inc cx
    cmp cx,120
    jne theultimateloopw
    popa
    jmp far ptr death
    ;white wins the game

    ;/****************************************************************************************/
    death:
    ;Press any key to exit
    mov  ah, 3eh
    lea  bx, debugFilename
    int  21h 
    returntoconsole
MAIN ENDP


IN_GAME_CHATTING proc near

    mainloop:

    mov ah,1    ;check if a key is pressed
    int 16h
    jz jumpReceive   ;if not then jmp to recieving mode
    jnz SEND         ;if yes jmp to send mode

    SEND:
    mov ah,0   ;clear buffer
    int 16h
    mov VALUE,al  ; save the key ascii code in al

    CMP al, 08h   ; check backpace
    jnz jumpenters
    cmp initxS, 39  ; check if the cursor is in the last column
    jne LOL
    printcharGraphics ' ',0 ; to be able to delete the last character in the right when backspacing from the line under it
    LOL:cmp initxS, 25
    JBE backlines   ; check if it is the last column in the left, so that we don't remove parts of the board
    dec initxS
    setCursor initxS,inityS
    printcharGraphics ' ',0 ; to delete when backspacing
    inc initxS
    setCursor initxS,inityS
    jmp backlines

    jumpenters: jmp ENTERS
    jumpReceive: jmp Receive

    backlines: cmp initxS, 25   ; to go to the row above when it is at the last column from the left
    jne ENTERS
    cmp inityS, 9   ; here to compare if it is the last row in the top or not, so that it doesn't delete any text or board drawing
    je ENTERS
    dec inityS
    setCursor 40,inityS
    saveCursorS
    jmp ENTERS

    

    ENTERS: CMP al,0Dh    ; check if the key is enter
    jnz ContLineS
    jz newlineS



    newlineS:
    CMP inityS,15   ;check if the cursor is in the bottom of the upper screen to scrollup one line
    jnz notlastlineS
    scrollupper
    setCursor 25,15 ; if so, leave at the bottom line after scrolling up one line
    jmp printcharS
    
    notlastlineS:inc inityS     
    mov initxS,25

    ContLineS:
    setCursor initxS,inityS  ; setting the cursor after newlineS
    CMP initxS,39        ; here we need to check when the x passes 39 so go to a newline
    JZ CheckBottomS               ; so we must check if it is in the bottom line or not
    jnz printcharS

    CheckBottomS:CMP inityS,15   ;check if the cursor is in the bottom of the upper screen to scrollup one line
    JNZ printcharS
    scrollupper
    setCursor 25,15 


    printcharS:
    cmp VALUE, 60h
    JE IgnoreS
    printcharGraphics VALUE,0fh          ; printing the char
    saveCursorS
    cmp initxS,25
    JAE IgnoreS
    setCursor 25,inityS

    
    IgnoreS:
    ;Check that Transmitter Holding Register is Empty

    mov dx,3FDH 		; Line Status Register
    AGAIN:In al , dx 	;Read Line Status
    test al , 00100000b
    jz Receive          ; Not empty

    ;If empty put the VALUE in Transmit data register

    mov dx , 3F8H		; Transmit data register
    mov al,VALUE        
    out dx , al             

    cmp al, 60H     ; press Esc to continue game
    je jumpExit
    saveCursorS          
    jmp mainloop


    jumpSend:jmp send

    jumpExit:jmp EXITT

    ;--------------------------------------------------
    ;--------------------------------------------------
    Receive:

    mov ah,1            ;check if there is key pressed then go to the sending mode
    int 16h
    jnz jumpSend

    ;Check that Data Ready

    mov dx , 3FDH		; Line Status Register
    in al , dx 
    test al , 1
    JZ Receive

    ;If Ready read the VALUE in Receive data register

    mov dx , 03F8H
    in al , dx 
    mov VALUE,al

    CMP al, 08h   ; check backpace
    jnz jumpenterr
    cmp initxR, 39  ; check if the cursor is in the last column
    jne LOLL
    printcharGraphics ' ',0h    ; to be able to delete the last character in the right when backspacing from the line under it
    LOLL:cmp initxR, 25
    JBE backliner   ; check if it is the last column in the left, so that we don't remove parts of the board
    dec initxR
    setCursor initxR,inityR
    printcharGraphics ' ',0h    ; to delete when backspacing
    inc initxR
    setCursor initxR,inityR
    jmp backliner

    jumpenterr: jmp ENTERR

    jumpExitt: jmp jumpExit

    backliner:cmp initxR,25  ; to go to the row above when it is at the last column from the left
    jne ENTERR
    cmp inityR, 18     ; here to compare if it is the last row in the top or not, so that it doesn't delete any text or board drawing
    je ENTERR
    dec inityR
    setCursor 40,inityR
    saveCursorR

    ENTERR:CMP VALUE,60h     ; press Esc to continue game
    je jumpExitt


    CMP VALUE,0Dh           ;check if the key pressed is enter
    JNZ ContLineR
    JZ newlineR

    newlineR:
    cmp inityR,24           ;check if the cursor is in the bottom of the lower screen to scrollup one line
    jnz notlastlineR
    scrolllower
    setCursor 25,24     ; if so, leave at the bottom line after scrolling up one line
    jmp printcharR

    notlastlineR: inc inityR
    mov initxR,25

    ContLineR:
    setCursor initxR,inityR     ; setting the cursor after newlineR
    CMP initxR,39               ; here we need to check when the x passes 79 so go to a newline
    JZ CheckBottomR                  ; so we must check if it is in the bottom line or not
    jnz printcharR

    CheckBottomR: cmp inityR,24    ;check if the cursor is in the bottom of the lower screen to scrollup one line
    jnz printcharR
    scrolllower
    setCursor 25,24

    printcharR:
    cmp VALUE, 60H
    JE IgnoreR
    printcharGraphics VALUE, 0fh             ; printing the char
    saveCursorR
    cmp initxR,25
    JAE IgnoreR
    setCursor 25,inityR

    IgnoreR:

    jmp mainloop        


    EXITT:
RET
IN_GAME_CHATTING ENDP
end main