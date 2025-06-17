cmake_minimum_required(VERSION 3.20)

project(base-distro VERSION 0.0.1)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_CROSSCOMPILING 1)

# /usr/lib/arm-none-eabi
set(GCC_PATH /usr/lib/arm-none-eabi)

set(CMAKE_C_COMPILER ${GCC_PATH}/bin/arm-none-eabi-gcc CACHE PATH "" FORCE)
