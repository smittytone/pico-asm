cmake_minimum_required(VERSION 3.14)

include(pico_sdk_import.cmake)
project(pico-asm LANGUAGES C CXX ASM
                 VERSION 1.0.0)

add_executable(pico-asm
               asm_src/main.S
               asm_src/sdk_inlines.c)

pico_sdk_init()

target_link_libraries(pico-asm
                      pico_stdlib
                      hardware_gpio
                      hardware_i2c
                      hardware_spi
                      hardware_adc
                      hardware_uart)

pico_enable_stdio_usb(pico-asm 1)
pico_enable_stdio_uart(pico-asm 1)
pico_add_extra_outputs(pico-asm)
