include mymacros.inc
include DrawingM.inc
include Moves.inc
.Model MEDIUM
.286
.Stack 64
.Data

boardWidth EQU 200
boardHeight EQU 200

begr DW 0
begc DW 0
endr DW 0
endc DW 0
res db 0

tmpx DW 0
tmpy DW 0

row DW 0
col DW 0

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
Timer  DB 32 dup(-1)

;///////////////////////////////////////////
playertpye DB 1 ;0 for white 1 for Black
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

;///////////////////////////////////////////
.Code

;/*****************************************/

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
    exitw:popa
    ret
DrawPieceW ENDP

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
        replace 6,7,5,4
        replace 6,3,2,3
        replace 6,4,1,4

        replace 6,1,5,1
        replace 5,1,4,1
        kill 0,0
        kill 6,4
        kill 6,7
        initchezz  horseData,4,2,14h,chezzP,chezzT
        ;number,row,col,numcolor,backc
        drawtim  1,5,0,0bh,PrimaryC;not this is not primary color but rather the color of the background
      
        drawtim  3,0,5,0bh,PrimaryC
        drawtim  2,0,6,0bh,PrimaryC
        drawtim  1,0,4,0bh,PrimaryC
        
        selectp 6,5
        Drawup 6,5,10
        movepiece 1,5

    ;/******************end of test area***************************/

    mov row,0
    mov col,0

    mov prevR,0
    mov prevC,0
    
    lea si,chezzP
    lea di,chezzT
    DrawPieceDB  0EH,0EH,0,0,0h,row,col,begr,begc,endr,endc,res

    ;deletechezzD 0,2,chezzP,chezzT,begr,begc,res,PrimaryC,SecondaryC

; /**************************************************/
    ;Q means the user wants to select
    
    Q:
    MOV AH,1;every time looping we check here whether a key was selected or not
    INT 16h
    push ax
    jz noflush
    mov ah,0Ch
    INT 21h
    
    noflush:
    pop ax
    cmp ah,10h  ;press Q condition
    JE doQ
    jmp far ptr right
    doQ:
   
    cmp selected,0
    jne movepiece1
    jmp far ptr choosepiece1 
    movepiece1:

;calling function to move a piece
    push row
    push col
    movepiece row,col
    pop col
    pop row
    jmp far ptr Q
    choosepiece1:

    ;calling function to choose a piece
    mov success,1
    push row
    push col
    choosepiece PrimaryC,SecondaryC,chezzP,chezzT,chezzC,playertpye,moveavailc,takeavailc,prevR,prevC,success,begr,begc,endr,endc,res
    pop col
    pop row
    cmp success,1
    je suc
    jmp far ptr q
    suc:
    selectp row,col
    jmp Q

    ;///////////////////////////////////////////////////////
    right:
   
    cmp ah,20h  ;right condition
    JNE left
    inc col
    jmp validate
    
    left:
    cmp ah,01EH  ;left condition
    JNE up
    dec col
    jmp validate

    up:
    cmp ah,011H  ;up condition
    JNE down
    dec row
    jmp validate

    down:
    cmp ah,1FH   ;down condition
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

    ;Press any key to exit
    returntoconsole
MAIN ENDP
end main