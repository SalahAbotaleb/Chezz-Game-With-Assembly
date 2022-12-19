updatetime MACRO 
    local looper,outofloop,jmpinloop,jmpinloop2,skipinteration,continue, skipthispart,exitw,nn,Nempty,drawLoop,sec,con,lblprim,lblsec,filterW,continW,continuew,
pusha
;gets current time dx seconds and parts of a second ,cx hours and minutes
mov ax,2c00h
int 21h
mov di,0
looper:
;jmp far ptr outofloop
mov al,timer[di]
cmp al,-1
jne jmpinloop
jmp far ptr skipinteration
jmpinloop:
cmp al,dh ;lw ad b3d ysheel al rsm
jne jmpinloop2
jmp far ptr skipinteration
jmpinloop2:
mov al,time[di]
dec al
mov time[di],al
;///////////////////////////////////////
;solving the one stays problem
 pusha
 cmp al,0
 popa
 jz continue
 jmp far ptr skipthispart
 continue:
 pusha
 mov al,chezzT[di]
 shr al,1
 shr al,1
 shr al,1
 shr al,1
 sub al,-1
 and al,0fh
 mov bh,tmpdb2
 mov tmpdb2,al
 mov al,chezzC[bx]
 mov tmpdb,al
 ;;;;;
   ;local drawLoop,noerror,lblprim,lblsec,filter,contin,Nempty,exit,sec,con
    ;primaryC is primary Color for the board which is at top left coener 
    ;secondaryC is secondart color next to first square 
    ;better to define primaryC and SecondaryC at begging of program
    ;row is from 0 to 7
    ;col is from 0 to 7
    ;piece color is the main color of the piece and secondary color will be background color
    ;roffset for row offset
    ;coffset for col offset
    push di
    add di,di
    mov cx,chezznrev[di]
    mov ch,0
    mov colx,cx
    mov cx,chezznrev[di]
    mov cl,ch
    mov ch,0
    mov rowx,cx
    mov ah,0
    mov tmpnumber,ax
    pop di
    pusha
    cmp rowx,0FFh
    jne nn
    ;returntoconsole
    nn:
    ;***********Drawing the pixels
    ;Nempty:
    mov ax,rowx
    mov cx,25d
    mul cl
    mov bx,ax

    mov ax,colx
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
    mov ax,rowx
    mov bx,2
    div bl
    xor cl,ah

    mov ah,0
    mov ax,colx
    mov bx,2
    div bl
    xor cl,ah
    
    mov resw,cl

    getdw rowx,colx
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
    Drawsquare colx,rowx,begrW,begcW,resw
    jmp exitw
    
    Nempty:
    getdw rowx,colx
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
    getdb rowx,colx
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

    mov ax,rowx
    mov rowx,ax
    mov ax,colx
    mov colx,ax
    pop ax

    exitw:
    popa
 ;;;;;
 mov tmpdb2,bh
 popa
 skipthispart:
;///////////////////////////////////////
push di
add di,di
mov cx,chezznrev[di]
mov ch,0
mov colx,cx
mov cx,chezznrev[di]
mov cl,ch
mov ch,0
mov rowx,cx
mov ah,0
mov tmpnumber,ax
pop di

Drawtim tmpnumber

mov timer[di],dh

skipinteration:
inc di
cmp di,32
je outofloop
jmp far ptr looper
outofloop:

popa
ENDM updatetime