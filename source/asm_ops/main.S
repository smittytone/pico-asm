/*
 * pico-asm for Raspberry Pi Pico
 *
 * @version     1.1.0
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
.syntax     unified                     // Use ARM unified syntax, ie.
                                        // mandate S suffix for lo registers
.thumb_func                             // This code uses Thumb instructions
.global     main                        // Set entry point

/*
 * RUNTIME START
 */
main:
init:       bl stdio_init_all           // Jump to SDK STDIO initialisation routine
            movs r0, #0x80              // Set the delay period
            lsls r0, #4
            bl sleep_ms                 // Delay to allow the STDIO-over-USB to ready

            movs r0, #LED_PIN           // Set the pin number
            bl gpio_init                // Jump to SDK GPIO initialisation routine

            movs r0, #LED_PIN           // Set the pin number
            movs r1, #GPIO_DIR_OUT      // Set the pin direction
            bl gpio_set_direction       // Jump to SDK pin direction routine

            /*
                Set the flash delay time according to
                whether bits 15 and 7 of r0 are set.

                Change the value of TST_VAL to set
                different values of r0
             */
check_r0:   ldr r0, TST_VAL
            movs r4, #0x80              // Set bit 7
            lsls r4, #0x08              // Shift r4 left 8 times to set bit 15
            adds r4, #0x08              // Re-set bit 7
            tst r0, r4                  // R0 & R4
            beq set_delay               // PSR-Z set indicates bits clear
            ldr r5, DELAY_TIME_FAST     // Set the delay period
            b next

set_delay:  ldr r5, DELAY_TIME_SLOW     // Set the delay period

next:       bl output                   // Sets the LR to loop:

loop:       movs r0, #LED_PIN           // Set the pin number
            movs r1, #PIN_HIGH          // Set the pin state
            bl gpio_set_state           // Jump to SDK pin state routine

            movs r0, r5                 // Set the delay period
                                        // NOTE This form assembles as PC offset addressing,
                                        //      so make sure DELAY_TIME_MS is an address in the
                                        //      code space rather not the .data space
            bl sleep_ms                 // Delay

            movs r0, #LED_PIN           // Set the pin number
            movs r1, #PIN_LOW           // Set the pin state
            bl gpio_set_state           // Jump to SDK pin state routine

            movs r0, r5                 // Set the delay period
            bl sleep_ms                 // Delay

            b loop                      // Loop infinitely

output:     ldr r6, DELAY_TIME_FAST     // Set the comparison value
            cmp r5, r6                  // Is r5 set to 'fast', ie. bits 15, 7 set?
            bne use_unset               // No, jump to slow:

use_set:    ldr r0, =TEXT_SET           // Set r0 to point to output text
            b print                     // Jump to print:

use_unset:  ldr r0, =TEXT_UNSET         // Set r0 to point to output text

print:      push {LR}                   // Save the LR - it'll be changed by the next line
            bl printf                   // Call the Pico SDK's printf()
            pop {PC}                    // Get LR from the stack and put it in PC to jump back

/*
 * DATA
 */
.align 4
TST_VAL:            .word           0xFFFFFFFF
DELAY_TIME_SLOW:    .word           750
DELAY_TIME_FAST:    .word           250
TEXT_SET:           .asciz          "BITS 15 AND/OR 7 SET\n"
TEXT_UNSET:         .asciz          "BITS 15 AND/OR 7 NOT SET\n"
