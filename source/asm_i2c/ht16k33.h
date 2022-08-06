/*
 * pico-asm for Raspberry Pi Pico
 *
 * @version     1.2.0
 * @author      smittytone
 * @copyright   2022
 * @licence     MIT
 *
 */
#ifndef _HT16K33_HEADER_
#define _HT16K33_HEADER_


/*
 *  Includes
 */
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include "pico/stdlib.h"
#include "pico/binary_info.h"
#include "hardware/i2c.h"


/*
 *  Constants
 */
#define I2C_PORT                        i2c0
#define I2C_FREQUENCY                   400000

#define PIN_SDA                         8
#define PIN_SCL                         9

#define ON                              1
#define OFF                             0

// HT16K33 LED Matrix Commands
#define HT16K33_GENERIC_DISPLAY_ON      0x81
#define HT16K33_GENERIC_DISPLAY_OFF     0x80
#define HT16K33_GENERIC_SYSTEM_ON       0x21
#define HT16K33_GENERIC_SYSTEM_OFF      0x20
#define HT16K33_GENERIC_DISPLAY_ADDRESS 0x00
#define HT16K33_GENERIC_CMD_BRIGHTNESS  0xE0
#define HT16K33_GENERIC_CMD_BLINK       0x81
#define HT16K33_ADDRESS                 0x70


/*
 *  Function Prototypes
 */
// HT16K33
void ht16k33_init();
void ht16k33_power_on_or_off(uint8_t on);
void ht16k33_set_brightness(uint8_t brightness);
void ht16k33_plot(uint8_t x, uint8_t y, bool set);
void ht16k33_clear();
void ht16k33_draw();

// I2C
void i2c_write_byte(uint8_t byte);
void i2c_write_block(uint8_t *data, uint8_t count);


#endif  // _HT16K33_HEADER_
