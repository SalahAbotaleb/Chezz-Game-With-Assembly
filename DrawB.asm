include mymacros.inc
include DrawingM.inc
.286
.Model Small
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

prevR DW 0
prevC DW 0

piecew EQU 25
pieceh EQU 25

PrimaryC DB 6h
SecondaryC DB 0Bh
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

chezzP DW 64 dup(-1)
chezzT DB 64 dup(-1)

.Code
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

    
	initchezz  rookData,0,0,12,chezzP,chezzT
    initchezz  rookData,0,7,12,chezzP,chezzT

    initchezz  horseData,0,1,14,chezzP,chezzT
    initchezz  horseData,0,6,14,chezzP,chezzT
    
    initchezz  bishopData,0,2,13,chezzP,chezzT
    initchezz  bishopData,0,5,13,chezzP,chezzT
    
    initchezz  queenData,0,3,11,chezzP,chezzT
    
    initchezz  kingData,0,4,10,chezzP,chezzT
    
    initchezz  soliderData,1,0,15,chezzP,chezzT
    initchezz  soliderData,1,1,15,chezzP,chezzT
    initchezz  soliderData,1,2,15,chezzP,chezzT
    initchezz  soliderData,1,3,15,chezzP,chezzT
    initchezz  soliderData,1,4,15,chezzP,chezzT
    initchezz  soliderData,1,5,15,chezzP,chezzT
    initchezz  soliderData,1,6,15,chezzP,chezzT
    initchezz  soliderData,1,7,15,chezzP,chezzT



    initchezz  rookData,7,0,02,chezzP,chezzT
    initchezz  rookData,7,7,02,chezzP,chezzT

    initchezz  horseData,7,1,04,chezzP,chezzT
    initchezz  horseData,7,6,04,chezzP,chezzT

    initchezz  bishopData,7,2,03,chezzP,chezzT
    initchezz  bishopData,7,5,03,chezzP,chezzT

    initchezz  queenData,7,3,01,chezzP,chezzT

    initchezz  kingData,7,4,00,chezzP,chezzT

    initchezz  soliderData,6,0,05,chezzP,chezzT
    initchezz  soliderData,6,1,05,chezzP,chezzT
    initchezz  soliderData,6,2,05,chezzP,chezzT
    initchezz  soliderData,6,3,05,chezzP,chezzT
    initchezz  soliderData,6,4,05,chezzP,chezzT
    initchezz  soliderData,6,5,05,chezzP,chezzT
    initchezz  soliderData,6,6,05,chezzP,chezzT
    initchezz  soliderData,6,7,05,chezzP,chezzT



    mov row,0
    mov col,0

    mov prevR,0
    mov prevC,0
    
    lea si,chezzP
    lea di,chezzT
    DrawPieceDB  0EH,0EH,[si],0,0,0h,row,col,begr,begc,endr,endc,res

    ;deletechezzD 0,2,chezzP,chezzT,begr,begc,res,PrimaryC,SecondaryC
    right:
    MOV AH , 0
    INT 16h
   
    cmp ah,4Dh  ;right condition
    JNE left
    inc col
    jmp validate
    
    left:
    cmp ah,04BH  ;left condition
    JNE up
    dec col
    jmp validate

    up:
    cmp ah,048H  ;up condition
    JNE down
    dec row
    jmp validate

    down:
    cmp ah,50H   ;down condition
    JNE validate
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
    mov bx,0
    mov bl,[di]
    cmp bl,1
    JE BlackP
    jmp far ptr whiteP
    blackP:DrawPieceDB  PrimaryC,SecondaryC,[si],0,0,0h,prevR,prevC,begr,begc,endr,endc,res
    jmp contDr
    whiteP:DrawPieceDB  PrimaryC,SecondaryC,[si],0,0,0Fh,prevR,prevC,begr,begc,endr,endc,res
    
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
    cmp bl,1
    JE Black
    jmp far ptr white
    Black:DrawPieceDB  0EH,0EH,[si],0,0,0h,row,col,begr,begc,endr,endc,res
    jmp right
    white:DrawPieceDB  0EH,0EH,[si],0,0,0Fh,row,col,begr,begc,endr,endc,res
    jmp right

    ;Press any key to exit
    returntoconsole
MAIN ENDP
end main