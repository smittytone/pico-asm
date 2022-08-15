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
.equ    COORD_X,    0               // Deltas within the variable
.equ    COORD_Y,    4               // store for X, Y, DX, DY 
.equ    DELTA_X,    8
.equ    DELTA_Y,    12


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
main:   bl stdio_init_all           // Jump to SDK STDIO initialisation routine
        movs r0, #0x80              // Set the delay period
                                    // NOTE This form assembles as PC offset addressing,
                                    //      so make sure DELAY_TIME_MS is an address in the
                                    //      .code space rather not the .data space
        lsls r0, #4
        bl sleep_ms                 // Delay to allow the STDIO-over-USB to ready

        bl i2c_config               // Initialise the I2C peripheral
        bl ht16k33_init             // Initialise the display

        /*
         * Set up the variable space
         */
        ldr r4, =VAR_SPACE          // r1 == &VAR_SPACE
        movs r0, #1                 // r0 = 1
        str r0, [r4, #DELTA_X]      // [r1 + 8] == 1
        str r0, [r4, #DELTA_Y]      // [r1 + 12] == 1

loop:   bl ht16k33_clear            // Clear the buffer
        
        /*
         * Get X, Y and plot a dot at the
         * current co-ordinates
         */
        ldr r4, =VAR_SPACE
        ldr r0, [r4, #COORD_X]
        ldr r1, [r4, #COORD_Y]
        bl plot

        /*
         *  Get X, Y, DX, DY and update their values
         * for the next loop
         */
        ldr r4, =VAR_SPACE
        ldr r0, [r4, #COORD_X]
        ldr r1, [r4, #COORD_Y]
        ldr r2, [r4, #DELTA_X]
        ldr r3, [r4, #DELTA_Y]

setx:   cmp r2, #1                  // DX == 1?
        bne subx                    // N: goto subx
addx:   adds r0, #1                 // X += 1
        cmp r0, #6                  // X <= 6 ?
        bls stx                     // YES goto stx
        movs r2, #0                 // DX == 0
        str r2, [r4, #DELTA_X]
        b stx
subx:   subs r0, #1                 // X -= 1
        bne stx                     // X > 0 ? YES goto stx
        movs r2, #1                 // DX == 1
        str r2, [r4, #DELTA_X]
stx:    str r0, [r4, #COORD_X]      // Save X

sety:   cmp r3, #1                  // DY == 1?
        bne suby                    // N: goto suby
addy:   adds r1, #1                 // Y += 1
        cmp r1, #6                  // Y <= 6 ?
        bls sty                     // YES goto sty
        movs r3, #0                 // DY == 0
        str r3, [r4, #DELTA_Y]
        b sty
suby:   subs r1, #1                 // Y -= 1
        bne sty                     // Y > 0 ? YES goto sty
        movs r3, #1                 // DY == 1
        str r3, [r4, #DELTA_Y]
sty:    str r1, [r4, #COORD_Y]      // Save Y
        
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
        
        ldr r4, =VAR_SPACE
        ldr r0, =TEXT1              // Set the format string
        ldr r1, [r4, #COORD_X]
        ldr r2, [r4, #COORD_Y]
        bl printf                   // Output the string
        
        ldr r0, =TEXT2              // Set the format string
        ldr r1, [r4, #DELTA_X]
        ldr r2, [r4, #DELTA_Y]            // Restore SP
        bl printf                   // Output the string

        pop {pc}                    // RTS

        
/*
 * READ-ONLY DATA in .CODE
 */
.balign 4
DELAY_TIME_MS:  .word           500
TEXT1:          .asciz          "X: 0x%02X, Y: 0x%02X, "
TEXT2:          .asciz          "DX: 0x%02X, DY: 0x%02X\n"


/*
 * READ/WRITE DATA in .DATA
 */
.data
.balign 4
VAR_SPACE:      .fill           16, 1, 0
