updatetime MACRO 
    local looper,outofloop,jmpinloop,jmpinloop2,skipinteration,
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