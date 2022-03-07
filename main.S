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


main:   mov r7, #0              @ 0 -> R7
        bl stdio_init_all       @ Jump to STDIO initialisation routine
loop:   ldr r0, =instr
        ldr r1, =outstr
        mov r4, #12
        mov r5, #13

        bl to_upper

        ldr r0, =outstr         @ 42949672 -> R0
        bl printf

        ldr r6, =50000000       @ Delay to slow speed of output strings
delay:  sub r6, #1
        bne delay

        b loop


.data                           @ Mark data start
instr:  .asciz  "This is the test string THAT we will convert!\n"
outstr: .fill   255, 1, 0
