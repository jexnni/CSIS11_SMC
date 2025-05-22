        .ORIG x3000
        BR START

; initialize, messages, prompts user input
PROMPT1 .STRINGZ "Enter first number (4 digits): "
PROMPT2 .STRINGZ "Enter second number (4 digits): "
PROMPT3 .STRINGZ "Enter operation (+, -, *, /): "

ERR_DIV_ZERO .STRINGZ "Error: Divide by zero!"
ERR_OVERFLOW .STRINGZ "Error: Overflow!"
ERR_UNDERFLOW .STRINGZ "Error: Underflow!"

PTR .FILL x4000
OPERATOR .BLKW 1
RESULT_STR .BLKW 6

START LD R6, PTR
        LEA R0, PROMPT1
        PUTS
        JSR READ_INPUT
        JSR PUSH_STACK

        LEA R0, PROMPT2
        PUTS
        JSR READ_INPUT
        JSR PUSH_STACK

        LEA R0, PROMPT3
        PUTS
        JSR READ_OP
        JSR PERFORM_OP
        JSR PRINT_RESULT
        HALT

READ_INPUT
        AND R2, R2, #0
        AND R4, R4, #0
INPUT_LOOP
        GETC
        OUT
        LD R3, ASCII_OFFSET
        ADD R1, R0, R3
        BRn INVALID_INPUT
        ADD R3, R1, #-10
        BRzp INVALID_INPUT
        ADD R2, R2, #1
        ADD R5, R4, #0
        ADD R4, R4, R4
        ADD R4, R4, R4
        ADD R4, R4, R5
        ADD R4, R4, R4
        ADD R4, R4, R1
        ADD R3, R2, #-4
        BRn INPUT_LOOP
        ADD R0, R4, #0
        RET

; Read user input and add to stack
INVALID_INPUT
        LEA R0, PROMPT1
        PUTS
        BR START

PUSH_STACK
        ADD R6, R6, #-1
        STR R0, R6, #0
        RET

POP_STACK
        LDR R0, R6, #0
        ADD R6, R6, #1
        RET

READ_OP
        GETC
        OUT
        LEA R1, OPERATOR
        STR R0, R1, #0
        RET

; Math Magic
PERFORM_OP
        JSR POP_STACK
        ADD R1, R0, #0
        JSR POP_STACK
        ADD R2, R0, #0
        LEA R4, OPERATOR
        LDR R3, R4, #0

        LD R5, OP_ADD
        NOT R5, R5
        ADD R5, R5, #1
        ADD R7, R3, R5
        BRz DO_ADD

        LD R5, OP_SUB
        NOT R5, R5
        ADD R5, R5, #1
        ADD R7, R3, R5
        BRz SUBTRACTION

        LD R5, OP_MUL
        NOT R5, R5
        ADD R5, R5, #1
        ADD R7, R3, R5
        BRz MULTIPLY

        LD R5, OP_DIV
        NOT R5, R5
        ADD R5, R5, #1
        ADD R7, R3, R5
        BRz DIVISION
        RET

; Addition and addition
DO_ADD
        ADD R0, R1, R2
        BRn UNDERFLOW_ADD
        BRzp NO_OVERFLOW

UNDERFLOW_ADD
        LEA R0, ERR_UNDERFLOW
        PUTS
        RET

NO_OVERFLOW
        LD R3, MAX_VAL
        NOT R3, R3
        ADD R3, R3, #1
        ADD R4, R0, R3
        BRn OVERFLOW
        RET

OVERFLOW
        LEA R0, ERR_OVERFLOW
        PUTS
        RET

; Subtraction nad subtraction check
SUBTRACTION
        NOT R2, R2
        ADD R2, R2, #1
        ADD R0, R1, R2
        BRn UNDERFLOW_SUB
        RET
UNDERFLOW_SUB
        LEA R0, ERR_UNDERFLOW
        PUTS
        RET

;multiplication
MULTIPLY
        AND R0, R0, #0
        ADD R3, R2, #0
MUL_LOOP
        ADD R0, R0, R1
        ADD R3, R3, #-1
        BRp MUL_LOOP
        RET

;division and chekc
DIVISION
        ADD R3, R2, #0
        BRz DIV_BY_ZERO
        AND R0, R0, #0
        ADD R5, R1, #0
DIV_LOOP
        NOT R4, R2
        ADD R4, R4, #1
        ADD R5, R5, R4
        BRn DIV_DONE
        ADD R0, R0, #1
        BR DIV_LOOP
DIV_DONE
        RET

DIV_BY_ZERO
        LEA R0, ERR_DIV_ZERO
        PUTS
        RET

; prints result
PRINT_RESULT
        LD R2, ASCII_OFFSET_POS
        LEA R3, RESULT_STR
        AND R1, R1, #0
        ADD R5, R0, #0

        LD R4, PLACE_1000
        JSR DIVMOD
        STR R1, R3, #0
        ADD R3, R3, #1

        LD R4, PLACE_100
        JSR DIVMOD
        STR R1, R3, #0
        ADD R3, R3, #1

        LD R4, PLACE_10
        JSR DIVMOD
        STR R1, R3, #0
        ADD R3, R3, #1

        LD R4, PLACE_1
        JSR DIVMOD
        STR R1, R3, #0
        ADD R3, R3, #1

        AND R1, R1, #0
        STR R1, R3, #0

        LEA R3, RESULT_STR
PRINT_LOOP
        LDR R0, R3, #0
        BRz PRINT_DONE
        OUT
        ADD R3, R3, #1
        BR PRINT_LOOP
PRINT_DONE
        RET

DIVMOD
        AND R1, R1, #0
DIVMOD_LOOP
        NOT R6, R4
        ADD R6, R6, #1
        ADD R5, R5, R6
        BRn DIVMOD_END
        ADD R1, R1, #1
        BR DIVMOD_LOOP
DIVMOD_END
        ADD R5, R5, R4
        ADD R1, R1, R2
        RET

; data
ASCII_OFFSET .FILL #-48
PLACE_1000 .FILL #1000
PLACE_100 .FILL #100
PLACE_10 .FILL #10
PLACE_1 .FILL #1
MAX_VAL .FILL #9999
OP_ADD .FILL #43
OP_SUB .FILL #45
OP_MUL .FILL #42
OP_DIV .FILL #47
ASCII_OFFSET_POS .FILL #48
        .END
