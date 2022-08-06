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
init:   bl stdio_init_all           // Jump to SDK STDIO initialisation routine
        movs r0, #0x80              // Set the delay period
        lsls r0, #4
        bl sleep_ms                 // Delay to allow the STDIO-over-USB to ready

        movs r0, #LED_PIN           // Set the pin number
        bl gpio_init                // Jump to SDK GPIO initialisation routine

        movs r0, #LED_PIN           // Set the pin number
        movs r1, #GPIO_DIR_OUT      // Set the pin direction
        bl gpio_set_direction       // Jump to SDK pin direction routine

        b info                      // Jump to the CPU info readout

loop:   movs r0, #LED_PIN           // Set the pin number
        movs r1, #PIN_HIGH          // Set the pin state
        bl gpio_set_state           // Jump to SDK pin state routine

        ldr r0, DELAY_TIME_MS       // Set the delay period
                                    // NOTE This form assembles as PC offset addressing,
                                    //      so make sure DELAY_TIME_MS is an address in the
                                    //      code space rather not the .data space
        bl sleep_ms                 // Delay

        movs r0, #LED_PIN           // Set the pin number
        movs r1, #PIN_LOW           // Set the pin state
        bl gpio_set_state           // Jump to SDK pin state routine

        ldr r0, DELAY_TIME_MS       // Set the delay period
        bl sleep_ms                 // Delay

        b loop                      // Loop infinitely

info:   ldr r5, CPUID               // Get the address of CPUID
        ldr r5, [r5]                // Get the contents of CPUID

        // Write out the CPUID register
        ldr r0, =TEXT0              // Set the printf format string
        movs r1, r5                 // Set the printf value
        bl printf

        // Write out the part number
        ldr r0, =TEXT1              // Set the format string
        movs r1, r5                 // Set the printf value to the CPUID value
        movs r3, #0xFF              // Set the AND mask
        lsls r3, #8
        adds r3, #0xF0
        ands r1, r3                 // Mask CPUID bits 15-4
        lsrs r3, #4
        bl printf

        // Write out the revision
        ldr r0, =TEXT2              // Set the format string
        movs r1, r5                 // Set the printf value to the CPUID value
        movs r3, #0x0F              // Set the AND mask
        lsls r3, #20
        ands r1, r3                 // Mask CPUID bits 23-20
        lsrs r3, #20
        bl printf

        // Write out the variant number
        ldr r0, =TEXT3              // Set the format string
        movs r1, r5                 // Set the printf value to the CPUID value
        movs r3, #0x0F              // Set the AND mask
        ands r1, r3                 // Mask CPUID bits 3-0
        bl printf

        // FROM 1.0.1 -- unified syntax test
        movs r0, #0                 // Clear r0
        mvns r0, r0                 // NOT r0 0x00000000 -> 0xFFFFFFFF
        movs r1, #1                 // r1 = 1
        rsbs r1, #0                 // r1 = 0 - r1 = 0xFFFFFFFF
        cmp r0, r1                  // r1 == r2?
        bne xinfo                   // Jump out if r1 != r2

        ldr r0, =TEXT4              // Output match message
        bl printf

 xinfo: b loop                      // Jump back to the LED flash loop

/*
 Use four-bytes to store the delay time so that we can load
 into r0 a 32-bit value, rather than move in an 8-bit value
 */
.align 4
DELAY_TIME_MS:  .word           500
CPUID:          .word           0xE000ED00          // Memory map address of CPUID register
TEXT0:          .asciz          "CPUID: 0x%08X\n"
TEXT1:          .asciz          "Part:  0x%08X\n"
TEXT2:          .asciz          "Rev:   0x%08X\n"
TEXT3:          .asciz          "Var:   0x%08X\n"
TEXT4:          .asciz          "MATCH\n"
