# RP2040 Assembly Demo 1.2.0

Raspberry Pi Pico assembly language application demos.

Please see [blog.smittytone.net](https://blog.smittytone.net) for details.

Code in this repo uses the `.syntax unified` directive.

## Repo Structure

```
/pico-asm
|
|___/source
|   |___/asm_led_sdk        // Flash the Pico LED by calling the Pico SDK
|   |   |___CMakeLists.txt  // App CMake config file
|   |   |___main.S          // App assembly source
|   |   
|   |___/asm_ops            // Demo various ops
|   |   |___CMakeLists.txt  // App CMake config file
|   |   |___main.S          // App assembly source
|   |
|   |___/asm_i2c            // Demo I2C comms
|   |   |___CMakeLists.txt  // App CMake config file
|   |   |___main.S          // App assembly source
|   |   |___main_no_stack.S // Alternative app assembly source
|   |
|   |___/common             // Source files common to all apps
|       |___sdk_inlines.c   // Wrappers for SDK inline C functions
|
|___CMakeLists.txt          // Top-level project CMake config file
|___pico_sdk_import.cmake   // Raspberry Pi Pico SDK CMake import script
|___deploy.sh               // Build-and-deploy shell script
|
|___pico-asm.code-workspace // Visual Studio Code workspace
|___pico-asm.xcworkspace    // Xcode workspace
|
|___README.md
|___LICENSE.md
```

Code © 2022, Tony Smith, and is licensed under the terms of the [MIT Licence](./LICENSE.md)
