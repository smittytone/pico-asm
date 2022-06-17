cmake_minimum_required(VERSION 3.14)

# Include app source code file(s)
add_executable(${APP_1_NAME}
               ${APP_1_SRC_DIRECTORY}/main.S
               ${APP_1_SRC_DIRECTORY}/sdk_inlines.c
)

# Link to built libraries
target_link_libraries(${APP_1_NAME} LINK_PUBLIC
                      pico_stdlib
                      hardware_gpio
                      hardware_i2c
                      hardware_spi
                      hardware_adc
                      hardware_uart)

# Enable/disable STDIO via USB and UART
pico_enable_stdio_usb(${APP_1_NAME} 1)
pico_enable_stdio_uart(${APP_1_NAME} 1)

# Enable extra build products
pico_add_extra_outputs(${APP_1_NAME})
