/*
 * pico-asm for Raspberry Pi Pico
 *
 * @version     1.2.0
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


/*
 * ASSEMBLY HEADER
 *
 * NOTE These macros need to be on separate lines
 */
.syntax unified                     // Use ARM unified syntax, ie.
                                    // mandate S suffix for lo registers
.thumb_func                         // This code uses Thumb instructions
.global main                        // Set entry point

/*
 * RUNTIME START
 */
main:
start:  b init

plot:   movs r0, #6                 // Set point x co-ord
        movs r1, #1                 // Set point y co-ord
        movs r3, #1                 // set point to set (0 = unset)
        bl ht16k33_plot             // Plot the point

        bl ht16k33_draw             // Draw the buffer

loop:   ldr r0, DELAY_TIME_MS       // Set the delay period
                                    // NOTE This form assembles as PC offset addressing,
                                    //      so make sure DELAY_TIME_MS is an address in the
                                    //      code space rather not the .data space
        bl sleep_ms                 // Delay

        b loop                      // Loop infinitely

init:   bl stdio_init_all           // Jump to SDK STDIO initialisation routine
        movs r0, #0x80              // Set the delay period
        lsls r0, #4
        bl sleep_ms                 // Delay to allow the STDIO-over-USB to ready

        bl i2c_config               // Initialise the I2C peripheral
        bl ht16k33_init             // Initialise the display

        b start
        
/*
 Use four-bytes to store the delay time so that we can load
 into r0 a 32-bit value, rather than move in an 8-bit value
 */
.align 4
DELAY_TIME_MS:  .word           500
CPUID:          .word           0xE000ED00          // Memory map address of CPUID register
TEXT0:          .asciz          "CPUID: 0x%08X\n"
