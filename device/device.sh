# Device naming

DEVICE_NAME=""
MANUFACTURER="ethen"
DEVICE_TYPE="Watch"

# Compiler settings
CFLAGS="-Os -mtune=cortex-m4 -nostdlib -nostartfiles -c -T mcu/link.lds"
LDFLAGS="-Os -mtune=cortex-m4 -nostdlib -nostartfiles -T mcu/link.lds"

PREFIX="arm-none-eabi"
CC="$PREFIX-gcc"
AR="$PREFIX-ar"

# Library settings
LIBRARIES_NEEDED="mcu os"
