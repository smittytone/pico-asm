/*
 * pico-asm for Raspberry Pi Pico
 *
 * @version     1.0.0
 * @author      smittytone
 * @copyright   2022
 * @licence     MIT
 *
 */

@ The following macros need to be on separate lines
.thumb_func                     @ Use Thumb instructions
.global main                    @ Set entry point


main:   bl stdio_init_all       @ Jump to STDIO initialisation routine
loop:   ldr r0, =instr          @ Capture address of in-string
        ldr r1, =outstr         @ Capture address of out-string
        mov r4, #12
        mov r5, #13

        bl to_upper             @ Jump to uppercase routine

        ldr r0, =outstr         @ 42949672 -> R0
        bl printf
        
        cmp r4, #12             @ Check r4 and r5 are untouched
        beq end
        cmp r5, #13
        beq end

        ldr r6, =50000000       @ Delay to slow speed of output strings
delay:  sub r6, #1
        bne delay

        b loop                  @ And back to the start

error:  ldr r0, =errstr
        bl printf
        wfi

.data                           @ Mark data start
instr:  .asciz  "This is the test string THAT we will convert!\n"
outstr: .fill   255, 1, 0       @ 255 bytes, initialised to zero
errstr: .asciz  "[ERROR] R4, R5 values not popped\n"