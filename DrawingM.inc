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
    local row,col
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
    row:
    inc bx
    col:
    inc si
    mov cx,si ;col
    mov dx,bx ;Row 
    mov al,color ;Pixel color
    mov ah,0ch ;Draw Pixel Command
    int 10h 
    cmp cx,tmpx
    jnz col
    sub si,25d
    cmp dx,tmpy
    jnz row

    popa
ENDM Drawsquare

initchezz MACRO pic,row,col,t,chezzP,chezzT
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
local sec,con,
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


DrawPieceDB MACRO PrimaryC,SecondaryC,dataloc,roffset,coffset,pieceColor,row,col,begr,begc,endr,endc,res
    local drawLoop,noerror,lblprim,lblsec,filter,contin,Nempty,exit,sec,con
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
    ;Nempty:
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

    mov ax,[si]
    cmp ax,-1
    JNZ Nempty
    mov ax,0
    cmp res,0
    jnz sec 
    mov al,PrimaryC
    jmp con
    sec:mov al,SecondaryC
    
    con:mov res,al
    Drawsquare col,row,begr,begc,res
    jmp exit
    
    Nempty:
    mov BX , dataloc ; BL contains index at the current drawn pixel
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
    exit:popa
ENDM DrawPieceDB