/*
 * pico-asm for Raspberry Pi Pico
 *
 * @version     1.0.0
 * @author      smittytone
 * @copyright   2022
 * @licence     MIT
 *
 */


/*
 * CONSTANTS
 */
.equ    LED_PIN,        25
.equ    GPIO_DIR_IN,    0
.equ    GPIO_DIR_OUT,   1
.equ    PIN_HIGH,       1
.equ    PIN_LOW,        0
.equ    DELAY_TIME_MS,  200


/*
 * ASSEMBLY HEADER
 */
@ The following macros need to be on separate lines
.thumb_func                     @ Use Thumb instructions
.global main                    @ Set entry point


/*
 * RUNTIME START
 */
main:   bl stdio_init_all       @ Jump to SDK STDIO initialisation routine
        
        mov r0, #LED_PIN        @ Set the pin number
        bl gpio_init            @ Jump to SDK GPIO initialisation routine

        mov r0, #LED_PIN        @ Set the pin number
        mov r1, #GPIO_DIR_OUT   @ Set the pin direction
        bl gpio_set_direction   @ Jump to SDK pin direction routine

loop:   mov r0, #LED_PIN        @ Set the pin number
        mov r1, #PIN_HIGH       @ Set the pin state
        bl gpio_set_state       @ Jump to SDK pin state routine

        mov r0, #DELAY_TIME_MS  @ Set the delay period
        bl sleep_ms             @ Delay

        mov r0, #LED_PIN        @ Set the pin number
        mov r1, #PIN_LOW        @ Set the pin state
        bl gpio_set_state       @ Jump to SDK pin state routine

        mov r0, #DELAY_TIME_MS  @ Set the delay period
        bl sleep_ms             @ Delay
        
        b loop                  @ Loop infinitely

