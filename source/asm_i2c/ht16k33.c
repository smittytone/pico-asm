/*
 * pico-asm for Raspberry Pi Pico
 *
 * @version     1.2.0
 * @author      smittytone
 * @copyright   2022
 * @licence     MIT
 *
 */
#include "ht16k33.h"


/*
 *  Globals
 */
// Graphics buffer
uint8_t buffer[8];


/*
 *  HT16K33 LED Matrix Functions
 */

void ht16k33_init() {
    // Initialize the matrix by powering up
    ht16k33_power_on_or_off(ON);
    ht16k33_set_brightness(2);
    ht16k33_clear();
    ht16k33_draw();
}

void ht16k33_power_on_or_off(uint8_t on) {
    // Power the LED on or off
    i2c_write_byte(on == ON ? HT16K33_GENERIC_SYSTEM_ON : HT16K33_GENERIC_DISPLAY_OFF);
    i2c_write_byte(on == ON ? HT16K33_GENERIC_DISPLAY_ON : HT16K33_GENERIC_SYSTEM_OFF);
}

void ht16k33_set_brightness(uint8_t brightness) {
    // Set the LED brightness
    if (brightness < 0 || brightness > 15) brightness = 15;
    i2c_write_byte(HT16K33_GENERIC_CMD_BRIGHTNESS | brightness);
}

void ht16k33_plot(uint8_t x, uint8_t y, bool is_set) {
    // Set or unset the specified pixel
    uint8_t col = buffer[x];

    if (is_set) {
        col = col | (1 << y);
    } else {
        col = col & ~(1 << y);
    }

    buffer[x] = col;
}

void ht16k33_clear() {
    // Clear the display buffer
    for (uint8_t i = 0 ; i < 8 ; ++i) buffer[i] = 0;
}

void ht16k33_draw() {
    // Set up the buffer holding the data to be
    // transmitted to the LED
    uint8_t output_buffer[17];
    for (uint8_t i = 0 ; i < 17 ; ++i) output_buffer[i] = 0;

    // Span the 8 bytes of the graphics buffer
    // across the 16 bytes of the LED's buffer
    for (uint8_t i = 0 ; i < 8 ; ++i) {
        uint8_t a = buffer[i];
        output_buffer[i * 2 + 1] = (a >> 1) + ((a << 7) & 0xFF);
    }

    // Write out the transmit buffer
    i2c_write_block(output_buffer, sizeof(output_buffer));
}


/*
 *  I2C Functions
 */
void i2c_write_byte(uint8_t byte) {
    // Convenience function to write a single byte to the matrix
    i2c_write_blocking(I2C_PORT, HT16K33_ADDRESS, &byte, 1, false);
}

void i2c_write_block(uint8_t *data, uint8_t count) {
    // Convenience function to write a 'count' bytes to the matrix
    i2c_write_blocking(I2C_PORT, HT16K33_ADDRESS, data, count, false);
}
