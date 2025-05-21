        .ORIG x3000  
        BR START
PROMPT1  .STRINGZ "Enter first number (4 digits): "
PROMPT2  .STRINGZ "Enter second number (4 digits): "
PROMPT3  .STRINGZ "Enter operation (+, -, *, /): "
ERR_DIV_ZERO .STRINGZ "Error: Divide by zero!"
ERR_OVERFLOW .STRINGZ "Error: Overflow!"
ERR_UNDERFLOW .STRINGZ "Error: Underflow!"
PTR      .FILL x4000
OPERATOR .BLKW 1
RESULT_STR .BLKW 5      ; result string

START   LD R6, PTR
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
        AND R0, R0, #0
        AND R2, R2, #0

INPUT_LOOP
        GETC
        LD R3, ASCII_OFFSET
ADD R1, R0, R3
        BRn INVALID_INPUT
        ADD R1, R1, #-10
        BRzp INVALID_INPUT

        JSR PUSH_STACK
        ADD R2, R2, #1
        ADD R4, R2, #-4
        BRn INPUT_LOOP
        JSR CALCULATE_INPUT
        RET

INVALID_INPUT
        LEA R0, PROMPT1
        PUTS
        BR READ_INPUT
        RET

CALCULATE_INPUT
        AND R0, R0, #0
        LD R3, PLACE_1000

        JSR POP_STACK
        ADD R1, R0, #0
        JSR MULTIPLY
        ADD R0, R0, R1
        LD R3, PLACE_100

        JSR POP_STACK
        ADD R1, R0, #0
        JSR MULTIPLY
        ADD R0, R0, R1
        LD R3, PLACE_10

        JSR POP_STACK
        ADD R1, R0, #0
        JSR MULTIPLY
        ADD R0, R0, R1
        LD R3, PLACE_1

        JSR POP_STACK
        ADD R1, R0, #0
        JSR MULTIPLY
        ADD R0, R0, R1
        RET

        JSR POP_STACK
        JSR MULTIPLY
        ADD R0, R0, R1
        LD R3, PLACE_100

        JSR POP_STACK
        JSR MULTIPLY
        ADD R0, R0, R1
        ADD R3, R3, #10

        JSR POP_STACK
        JSR MULTIPLY
        ADD R0, R0, R1
        ADD R3, R3, #1

        JSR POP_STACK
        JSR MULTIPLY
        ADD R0, R0, R1
        RET

PUSH_STACK
        ADD R6, R6, #-1
        STR R0, R6, #0
        RET

POP_STACK
        LDR R1, R6, #0
        ADD R6, R6, #1
        RET

READ_OP
        GETC
        LEA R1, OPERATOR
        STR R0, R1, #0
        RET

PERFORM_OP
        JSR POP_STACK
        ADD R1, R0, #0
        JSR POP_STACK
        ADD R2, R0, #0
        LEA R4, OPERATOR
        LDR R3, R4, #0

        LD R3, OP_ADD
        BRz ADDITION
        ADD R3, R3, #-1
        BRz SUBTRACTION
        ADD R3, R3, #-2
        BRz MULTIPLY
        ADD R3, R3, #-3
        BRz DIVISION
        RET

ADDITION
        ADD R0, R1, R2
        BRzp CHECK_OVERFLOW
        LEA R0, ERR_UNDERFLOW
        PUTS
        RET

CHECK_OVERFLOW
        BRzp DONE
        LEA R0, ERR_OVERFLOW
        PUTS
        RET

DONE
        RET

SUBTRACTION
        NOT R2, R2
        ADD R2, R2, #1
        ADD R0, R1, R2
        BRzp CHECK_OVERFLOW
        LEA R0, ERR_UNDERFLOW
        PUTS
        RET

MULTIPLY
        AND R0, R0, #0
        ADD R5, R3, #0  ; R3 is the multiplier
MUL_LOOP
        ADD R0, R0, R1
        ADD R5, R5, #-1
        BRp MUL_LOOP
        RET

DIVISION
        BRz DIV_BY_ZERO
        AND R0, R0, #0
        AND R5, R5, #0
DIV_LOOP
        ADD R1, R1, R2
        BRn DIV_DONE
        ADD R0, R0, #1
        BR DIV_LOOP
DIV_DONE
        ADD R5, R1, #0
        RET

DIV_BY_ZERO
        LEA R0, ERR_DIV_ZERO
        PUTS
        RET

PRINT_RESULT
        LD R5, ASCII_OFFSET_POS
ADD R0, R0, R5
        OUT
        RET

ASCII_OFFSET .FILL #-48
PLACE_1000 .FILL #1000
PLACE_100 .FILL #100
PLACE_10 .FILL #10
PLACE_1 .FILL #1
OP_ADD .FILL #-43
ASCII_OFFSET_POS .FILL #48
        .END
