updatetime MACRO 
    local looper,outofloop,jmpinloop,jmpinloop2,skipinteration,
pusha
;gets current time dx seconds and parts of a second ,cx hours and minutes
mov ax,2c00h
int 21h
mov bx,0
looper:

mov al,timer[bx]
cmp al,-1
jne jmpinloop
jmp far ptr skipinteration
jmpinloop:
cmp al,dh
jne jmpinloop2
jmp far ptr skipinteration
jmpinloop2:
mov al,time[bx]
dec al
mov time[bx],al

mov cx,chezznrev[bx]
mov ch,0
mov col,cx
mov cx,chezznrev[bx]
mov cl,ch
mov ch,0
mov row,cx
mov ah,0
mov tmpnumber,ax
Drawtim tmpnumber
mov timer[bx],dh

skipinteration:
inc bx
cmp bx,32
je outofloop
jmp far ptr looper
outofloop:
popa
ENDM updatetime