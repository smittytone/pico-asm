/*
 * pico-asm for Raspberry Pi Pico
 *
 * @version     1.2.0
 * @author      smittytone
 * @copyright   2022
 * @licence     MIT
 *
 */


#include "hardware/gpio.h"

/*
 * These functions are placeholders for SDK functions
 * that are marked as inline, ie. to be compiled in place.
 */

void gpio_set_direction(int pin, int direction) {
    gpio_set_dir(pin, direction);
}

void gpio_set_state(int pin, int state) {
    gpio_put(pin, state);
}
