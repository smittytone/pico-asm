/*
 * pico-asm for Raspberry Pi Pico
 *
 * @version     1.3.0
 * @author      smittytone
 * @copyright   2022
 * @licence     MIT
 *
 */


/*
 * INCLUDES
 */
#include "hardware/regs/addressmap.h"
#include "hardware/regs/sio.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/pads_bank0.h"
#include "hardware/regs/i2c.h"


/*
 * CONSTANTS
 */
.equ    SDA_PIN,            8
.equ    SCL_PIN,            9
.equ    HT16K33_i2C_ADDR,   0x70

/*
 * ASSEMBLY HEADER
 *
 * NOTE These macros need to be on separate lines
 */
.syntax unified                     // Use ARM unified syntax, ie.
                                    // mandate S suffix for lo registers
.thumb_func                         // This code uses Thumb instructions
.global init_i2c                    // Set entry point


/*
 * RUNTIME START
 */
init_i2c:
    
    push {lr}

    /*
     * SDA Pin ************************************
     */
    movs r0, #SDA_PIN
    movs r3, #1
    lsls r3, r0                     // Pin number * 2
    ldr r2, GPIO_BASE
    str r3, [r2, #SIO_GPIO_OE_SET_OFFSET]
    str r3, [r2, #SIO_GPIO_OUT_CLR_OFFSET]

    /*
     * Set pin function to I2C
     */
    ldr r2, PAD_BANK_BASE
    lsls r3, r0, #2                 // Pin number * 4
    add r2, r3
    movs r1, #0x5A                  // Slew slow b0,0, schmitt Y b1,1,
                                    // PD N b2,0, PU Y b3,1, drive 4ma b5:4,01,
                                    // input Y b6,1
    ldr r4, SET_REG_OFFSET
    orrs r2, r4
    str r1, [r2, #PADS_BANK0_GPIO8_OFFSET]
    
    /*
     * Set pin IO for I2C
     */
    lsls r0, #3                     // Pin number * 8
    ldr r2, IO_BANK_BASE
    adds r2, r0                     // Add offset for pin
    movs r1, #IO_BANK0_GPIO8_CTRL_FUNCSEL_VALUE_I2C0_SDA
    str r1, [r2, #IO_BANK0_GPIO8_CTRL_OFFSET]

    /*
     * SDA Pin ************************************
     */
    movs r0, #SCL_PIN
    movs r3, #1
    lsls r3, r0                     // Pin number * 2
    ldr r2, GPIO_BASE
    str r3, [r2, #SIO_GPIO_OE_SET_OFFSET]
    str r3, [r2, #SIO_GPIO_OUT_CLR_OFFSET]

    /*
     * Set pin function to I2C
     */
    ldr r2, PAD_BANK_BASE
    lsls r3, r0, #2                 // Pin number * 4
    add r2, r3
    movs r1, #0x5A
    ldr r4, SET_REG_OFFSET
    orrs r2, r4
    str r1, [r2, #PADS_BANK0_GPIO9_OFFSET]

    /*
     * Set pin IO for I2C
     */
    lsls r0, #3                     // Pin number * 8
    ldr r2, IO_BANK_BASE
    adds r2, r0                     // Add offset for pin
    movs r1, #IO_BANK0_GPIO9_CTRL_FUNCSEL_VALUE_I2C0_SCL
    str r1, [r2, #IO_BANK0_GPIO9_CTRL_OFFSET]
        
    /*
     * I2C ***************************************
     */

    ldr r0, =TEXT3              // Set the format string
    movs r1, #3
    bl printf                   // Output the string

    // Disable I2C to set the target device address
    // NOTE Don't set frequency: 400kHz is default
    ldr r2, I2C_BASE
    movs r0, #1
    ldr r4, CLR_REG_OFFSET
    orrs r2, r4
    str r0, [r2, #I2C_IC_ENABLE_OFFSET]
    
    // Set the address
    ldr r2, I2C_BASE
    movs r0, #HT16K33_i2C_ADDR
    ldr r4, SET_REG_OFFSET
    orrs r3, r4
    str r3, [r2, #I2C_IC_TAR_OFFSET]

    // Enable I2C
    ldr r2, I2C_BASE
    movs r0, #1
    ldr r4, SET_REG_OFFSET
    orrs r2, r4
    str r0, [r2, #I2C_IC_ENABLE_OFFSET]




    /*
     * Exit back to main ***************************
     */
    pop {r7}
    mov lr, r7
    bx lr

        
/*
 * READ-ONLY DATA in .CODE
 */
.balign 4
GPIO_BASE:      .word           SIO_BASE                // Pins base address
PAD_BANK_BASE:  .word           PADS_BANK0_BASE         // PAD Bank 0 base address
IO_BANK_BASE:   .word           IO_BANK0_BASE           // IO Bank 0 base address
I2C_BASE:       .word           I2C0_BASE               // I2C 0 base address
SET_REG_OFFSET: .word           REG_ALIAS_SET_BITS      // Set register bits
CLR_REG_OFFSET: .word           REG_ALIAS_CLR_BITS      // Clear register bits
