include mymacros.inc
.286
.MODEL SMALL
.STACK 64
.DATA

MSG1  DB  "Please Enter Your Name: $"
MSG2  DB  13,"Invalid! Re-Enter your Name: $"
INPUT_NAME DB  30,?,30 DUP('$')

.CODE
MAIN PROC FAR
    MOV AX, @DATA
    MOV DS, AX
     
    clearscreen 
    MOV AH, 9H
    LEA DX, MSG1                ; display "Please Enter Your Name: "
    INT 21H
    
    START:    
    MOV AH, 0AH
    LEA DX, INPUT_NAME          ; for inputing the name
    INT 21H
    
    MOV CL, INPUT_NAME+1        ; check for null input
    CMP CL, 0H                  ; if(len == 0)
    JE wrong                    ;    jump to wrong
    
    MOV CL, INPUT_NAME+1        ; check length of string, must be smaller than 15
    CMP CL, 15D                 ; if(len > 15)
    JA WRONG                    ;    jump to wrong
    
    LEA SI, INPUT_NAME+2        ; for iterating over every character in string
    MOV CL, INPUT_NAME+1        ; get the length of string from actual size in variable name (input_name)
    MOV CH, 0H                  ; setting CX
    
    FOR:
        CMP CX, 0
        JE ENDD

        MOV BL, [SI]             ; work on BL register to check every character if not alphabet
        
        CMP BL, 61H              ; if (BL > 'a')
        JAE ALPHABET_SMALL      ;   jump to check for (BL < 'z')
        
        CMP BL, 41H              ; if (BL > 'A')
        JAE ALPHABET_CAPITAL    ;   jump to check for (BL < 'Z')
        
        CMP BL, 20H              ; to check for spaces ' '
        JE RETURN 
         
        CMP BL, 41H             ; to check for other characters in the ascii table
        JL WRONG                ; jump to wrong
        
        RETURN: 

        INC SI
        LOOP FOR     
    ENDD:

    
    returntoconsole
    
    
    WRONG:
        clearscreen
        
        MOV AH, 9
        LEA DX, MSG2            ; display "Invalid! Re-Enter your Name: "
        INT 21H
        
        JMP START               ; Start again
        
    ALPHABET_SMALL:             ; if (BL > 'z')
        CMP BL,7AH              ;   jump to wrong
        JA WRONG                ; else  
        JMP RETURN              ;   jump to return label
    
    ALPHABET_CAPITAL:           ; if (BL > 'z')
        CMP BL, 5AH             ;   jump to wrong
        JA  WRONG               ; else
        JMP RETURN              ;   jump to return label
MAIN ENDP    
END MAIN