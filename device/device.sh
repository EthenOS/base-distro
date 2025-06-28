# Device naming

DEVICE_NAME=""
MANUFACTURER="ethen"
DEVICE_TYPE="Watch"

# Compiler settings
CFLAGS="-mtune=cortex-m4 -nostdlib -nostartfiles -c -T mcu/link.lds"
LDFLAGS="-mtune=cortex-m4 -nostdlib -nostartfiles -T mcu/link.lds -flto"

PREFIX="arm-none-eabi"
CC="$PREFIX-gcc"
AR="$PREFIX-ar"

# Library settings
LIBRARIES_NEEDED="mcu os"
