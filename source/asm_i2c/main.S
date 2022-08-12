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

.equ    pop_x,     4                // Deltas for to set SP for pushing
.equ    pop_y,     8                // and pulling X, Y, DX, DY to and
.equ    pop_dx,    12               // from the variable space within the
.equ    pop_dy,    16               // stack
.equ    psh_y,     4
.equ    psh_dx,    8
.equ    psh_dy,    12

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

        bl i2c_config               // Initialise the I2C peripheral
        bl ht16k33_init             // Initialise the display

        movs r7, #0                 // Set the X counter

        mov r9, sp                  // r9 == SP, top of var store
        movs r0, #0
        push {r0}                   // X
        push {r0}                   // Y
        movs r0, #1
        push {r0}                   // DX
        push {r0}                   // DY

loop:   bl ht16k33_clear            // Clear the buffer
        
        /*
            Get X, Y and plot a dot at the
            current co-ordinates
         */
        mov r10, sp                 // Record current SP
        mov sp, r9                  // Get Y, X
        sub sp, #pop_y
        pop {r1}
        pop {r0}
        mov sp, r10                 // Restore SP
        bl plot                     // Plot at (X, Y)

        bl print
        
        mov r10, sp                 // Hold current SP

        /*
            Get X, Y, DX and DY, and set the updated
            co-ordinates and direction flags.
         */
        mov sp, r9                  // Set SP to var store
        sub sp, #pop_dy             // Get DY, DX, Y, X
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
        sub sp, #psh_dx
        push {r2}
        b stx
subx:   subs r0, #1                 // X -= 1
        bne stx                     // X > 0 ? YES goto stx
        movs r2, #1                 // DX == 1
        mov sp, r9
        sub sp, #psh_dx
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
        sub sp, #psh_dy
        push {r3}
        b sty
suby:   subs r1, #1                 // Y -= 1
        bne sty                     // Y > 0 ? YES goto sty
        movs r3, #1                 // DY == 1
        mov sp, r9
        sub sp, #psh_dy
        push {r3}
sty:    mov sp, r9
        sub sp, #psh_y
        push {r1}                   // Save Y

        mov sp, r10                 // Restore SP
        
        bl print                    // Debug output

        ldr r0, DELAY_TIME_MS       // Set the delay period r0 = [DELAy_TIME_MS]
        bl sleep_ms                 // Delay
        
        b loop                      // Loop infinitely back to start

plot:   push {LR}
        bl ht16k33_plot             // Plot the point
        bl ht16k33_draw             // Draw the buffer
        pop {PC}                    // RTS

print:  push {lr}
        
        ldr r0, =TEXT1              // Set the format string
        mov r10, sp                 // Record current SP
        mov sp, r9                  // Get Y and X
        sub sp, #pop_y
        pop {r2}
        pop {r1}
        mov sp, r10                 // Restore SP
        bl printf                   // Output the string
        
        ldr r0, =TEXT2              // Set the format string
        mov r10, sp                 // Record current SP
        mov sp, r9                  // Get DY and DX
        sub sp, #pop_dy
        pop {r2}
        pop {r1}
        mov sp, r10                 // Restore SP
        bl printf                   // Output the string

        pop {pc}                    // RTS

        
/*
 DATA in .CODE
 */
.balign 4
DELAY_TIME_MS:  .word           500
TEXT1:          .asciz          "X: 0x%02X, Y: 0x%02X, "
TEXT2:          .asciz          "DX: 0x%02X, DY: 0x%02X\n"
