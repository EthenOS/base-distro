# Device naming

DEVICE_NAME=""
MANUFACTURER="ethen"
DEVICE_TYPE="Watch"

# Compiler settings
CFLAGS="-Os -mtune=cortex-m4 -nostdlib -nostartfiles -c -T mcu/link.lds -mfloat-abi=softfp -mfpu=fpv4-sp-d16 -ggdb -marm"
LDFLAGS="-nostdlib -T mcu/link.lds"

PREFIX="arm-none-eabi"
CC="$PREFIX-gcc"
LD="$PREFIX-ld"
AR="$PREFIX-ar"
OBJCOPY="$PREFIX-objcopy"

# Library settings
LIBRARIES_NEEDED="mcu os"
