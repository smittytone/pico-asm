/*
 * pico-asm for Raspberry Pi Pico
 *
 * @version     1.2.0
 * @author      smittytone
 * @copyright   2022
 * @licence     MIT
 *
 */


#include "i2c.S"


/*
 * CONSTANTS
 */
.equ    POP_X,      4                // Deltas for to set SP for pushing
.equ    POP_Y,      8                // and pulling X, Y, DX, DY to and
.equ    POP_DX,     12               // from the variable space within the
.equ    POP_DY,     16               // stack
.equ    PSX_X,      0
.equ    PSH_Y,      4
.equ    PSH_DX,     8
.equ    PSH_DY,     12


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
                                    // NOTE This form assembles as PC offset addressing,
                                    //      so make sure DELAY_TIME_MS is an address in the
                                    //      .code space rather not the .data space
        lsls r0, #4
        bl sleep_ms                 // Delay to allow the STDIO-over-USB to ready

        //bl i2c_config               // Initialise the I2C peripheral
        blx init_i2c
        bl ht16k33_init             // Initialise the display

        /*
         * Set up the variable space
         */
        mov r9, sp                  // r9 == SP, top of var store
        movs r0, #0
        push {r0}                   // Clear X...
        push {r0}                   // ...Y
        movs r0, #1
        push {r0}                   // Set DX...
        push {r0}                   // ...DY

loop:   bl ht16k33_clear            // Clear the buffer
        
        /*
         * Get X, Y and plot a dot at the
         * current co-ordinates
         */
        mov r10, sp                 // Record current SP
        mov sp, r9
        sub sp, #POP_Y
        pop {r1}                    // Get Y
        pop {r0}                    // Get X
        mov sp, r10                 // Restore SP

        bl plot                     // Plot at (X, Y)
               
        /*
         * Get X, Y, DX and DY, and set the updated
         * co-ordinates and direction flags.
         */
        mov r10, sp                 // Record current SP
        mov sp, r9                  // Set SP to var store
        sub sp, #POP_DY             // Get DY, DX, Y, X
        pop {r3}
        pop {r2}
        pop {r1}
        pop {r0}

setx:   cmp r2, #1                  // DX == 1?
        bne subx                    // N: goto subx
addx:   adds r0, #1                 // X += 1
        cmp r0, #6                  // X <= 6 ?
        bls stx                     // YES goto stx
        movs r2, #0                 // DX == 0
        mov sp, r9
        sub sp, #PSH_DX
        push {r2}
        b stx
subx:   subs r0, #1                 // X -= 1
        bne stx                     // X > 0 ? YES goto stx
        movs r2, #1                 // DX == 1
        mov sp, r9
        sub sp, #PSH_DX
        push {r2}
stx:    mov sp, r9
        push {r0}                   // Save X

sety:   cmp r3, #1                  // DY == 1?
        bne suby                    // N: goto suby
addy:   adds r1, #1                 // Y += 1
        cmp r1, #6                  // Y <= 6 ?
        bls sty                     // YES goto sty
        movs r3, #0                 // DY == 0
        mov sp, r9
        sub sp, #PSH_DY
        push {r3}
        b sty
suby:   subs r1, #1                 // Y -= 1
        bne sty                     // Y > 0 ? YES goto sty
        movs r3, #1                 // DY == 1
        mov sp, r9
        sub sp, #PSH_DY
        push {r3}
sty:    mov sp, r9
        sub sp, #PSH_Y
        push {r1}                   // Save Y

        mov sp, r10                 // Restore SP

        /*
         * End of loop code
         */
        bl print                    // Debug output

        ldr r0, DELAY_TIME_MS       // Set the delay period r0 = [DELAy_TIME_MS]
        bl sleep_ms                 // Delay
        
        b loop                      // Loop infinitely back to start

        /*
         * Plot X, Y on the LED
         */
plot:   push {LR}
        movs r2, #1                 // Set the pixel
        bl ht16k33_plot             // Plot the point
        bl ht16k33_draw             // Draw the buffer
        pop {PC}                    // RTS

        /*
         * Print X, Y, DX, DY values for debugging.
         */
print:  push {lr}
        
        ldr r0, =TEXT1              // Set the format string
        mov r10, sp                 // Record current SP
        mov sp, r9                  // Get Y and X
        sub sp, #POP_Y
        pop {r2}
        pop {r1}
        mov sp, r10                 // Restore SP
        bl printf                   // Output the string
        
        ldr r0, =TEXT2              // Set the format string
        mov r10, sp                 // Record current SP
        mov sp, r9                  // Get DY and DX
        sub sp, #POP_DY
        pop {r2}
        pop {r1}
        mov sp, r10                 // Restore SP
        bl printf                   // Output the string

        pop {pc}                    // RTS

        
/*
 * READ-ONLY DATA in .CODE
 */
.balign 4
DELAY_TIME_MS:  .word           500
TEXT1:          .asciz          "X: 0x%02X, Y: 0x%02X, "
TEXT2:          .asciz          "DX: 0x%02X, DY: 0x%02X\n"
TEXT3:          .asciz          "Done %i\n"
