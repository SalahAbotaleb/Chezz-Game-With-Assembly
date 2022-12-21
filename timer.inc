updatetime MACRO 
    local looper,outofloop,jmpinloop,jmpinloop2,skipinteration,continue, skipthispart,exitw,nn,Nempty,drawLoop,sec,con,lblprim,lblsec,filterW,continW,continuew,resettime,resetW
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
cmp al,dh ;lw msh ad b3d 8yr al rsm
jne jmpinloop2
jmp far ptr skipinteration
jmpinloop2:
mov al,time[di]
dec al
mov time[di],al
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

cmp time[di],0
je resettime
jmp far ptr skipinteration
resettime: 
mov timer[di],-1
getdb rowx,colx
mov bl,chezzT[bx]
mov bh,0
mov cl,4
shr bl,cl

cmp bl,0
je resetW
DrawPieceDB  PrimaryC,SecondaryC,0,0,0H,rowx,colx,begr,begc,endr,endc,res
resetW:
DrawPieceDB  PrimaryC,SecondaryC,0,0,0FH,rowx,colx,begr,begc,endr,endc,res

skipinteration:
inc di
cmp di,32
je outofloop
jmp far ptr looper
outofloop:

popa
ENDM updatetime