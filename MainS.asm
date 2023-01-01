EXTRN SUBPROG1:FAR
EXTRN Main:FAR
EXTRN MAINC:FAR

PUBLIC MSG1, MSG2, INPUT_NAME,Incomingname
include mymacros.inc 
.286
.MODEL MEDIUM
.STACK 64
.DATA

MSG1  DB  "Please Enter Your Name: $"
MSG2  DB  13,"Invalid! Re-Enter your Name: $"
INPUT_NAME DB  30,?,30 DUP('$')
Incomingname DB  30,?,30 DUP('$')

F1outputmsg  DB  "To start  chating  press F1 $"
F2outputmsg  DB  "To start the game  press F2 $"
escoutputmsg DB  "To end the program press Esc $"
sendchat     DB  "You send a Chat invitation to $"
sendgame     DB  "You send a Game invitation to $"
test3        DB  "Exit $" 

.CODE
SUBPROG2 PROC FAR
mov ax,@DATA
mov ds,ax

CALL SUBPROG1

GotoTextmode
clearscreen

looptillesc:;to keep lopping until the user press esc

movecursorlocation 19h,7h,0h    ;moves cursor to the middle of the page 

DisplayString F1outputmsg       ;prints the f1 message

movecursorlocation 19h,0Ah,0h    ;moves cursor to the middle of the page bellow the f1 message

DisplayString F2outputmsg       ;prints the f2 message

movecursorlocation 19h,0Dh,0h    ;moves cursor to the middle of the page bellow the f2 message

DisplayString escoutputmsg       ;prints the esc message

drawhorizontallineinetextmode 22d  ;prints a line at row 22

MOV AH,0h
INT 16H
CMP AH,3BH                     ; Check if user pressed F1 to go to chatting mode
jnz GAME
DisplayString sendchat         ;CALL Chatscreen
DisplayString INPUT_NAME+2
CALL mainc
clearscreen

GAME: 
CMP AH,3CH
jnz EXIT
DisplayString sendgame         ;CALL Game
DisplayString INPUT_NAME+2
Call MAIN
GotoTextmode
clearscreen



EXIT:
CMP Ah,1
Jnz goout
DisplayString test3       ;returntoconsole  ;Close Program
clearscreen
returntoconsole

goout:
;returntoconsole
mov ax,1
add ax,1
jz eeee
jmp far ptr looptillesc
eeee:
SUBPROG2 ENDP    
END SUBPROG2