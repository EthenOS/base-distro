#!/bin/bash

set -e

ROOT_DIR=$(pwd)

DEVICE_PATH=$ROOT_DIR/device
DEVICE_SH=$DEVICE_PATH/device.sh

if [ ! -f "$DEVICE_SH" ]; then
    echo "[ERROR] No device.sh found for $DEVICE_PATH"
    exit 1
fi

source "$DEVICE_SH"

echo "[INFO] Setting up Ninja build for $DEVICE_NAME ($MANUFACTURER) - Type: $DEVICE_TYPE"

cat > build.ninja <<EOF
# Auto-generated file. DO NOT EDIT!
ninja_required_version = 1.8

rule cc
  command = \$cc \$in \$cflags -o \$out
  depfile = \$out.d
rule ar
  command = \$ar rcs \$out \$in
rule s_compile
  command = \$cc \$in \$cflags -o \$out
rule link
  command = \$cc \$in \$ldflags -o \$out

cc = $CC
ar = $AR

cflags = $CFLAGS
ldflags = $LDFLAGS

EOF

libs=()

while read -r script; do
  dir=$(dirname "$script")

  # Extract variables safely without executing arbitrary code
  eval "$(
    cd "$dir"
    awk -F= '
      $1=="CUSTOM_BUILD"   { print $1"=\"" $2 "\"" }
      $1=="CUSTOM_CFLAGS" {
        gsub(/\(/,"\\(",$2); gsub(/\)/,"\\)",$2)
        printf("CUSTOM_CFLAGS=(%s)\n", $2)
      }
      $1=="IS_LIBRARY"     { print $1"=\"" $2 "\"" }
    ' ethen.sh
  )"

  # If custom build is enabled, maybe append flags
  if [[ "${CUSTOM_BUILD:-0}" == "1" ]]; then
    if (( ${#CUSTOM_CFLAGS[@]} > 0 )); then
        flags=""
        for f in "${CUSTOM_CFLAGS[@]}"; do
            flags+=" $f"
        done
        echo "cflags = \$cflags${flags}" >> build.ninja
    fi
fi


  # If library is requested, generate .o and .a
  if [[ "${IS_LIBRARY:-0}" == "1" ]]; then
    echo "# Building static lib for $dir" >> build.ninja

    # list .c and .s files (non-recursive)
    objs=()
    for src in "$dir"/*.c "$dir"/*.s; do
      [[ -f "$src" ]] || continue
      base=$(basename "$src")
      ext="${base##*.}"
      obj="$dir/${base%.*}.o"
      rulename=$([[ "$ext" == "c" ]] && echo cc || echo s_compile)
      echo "build $obj: $rulename $dir/$base" >> build.ninja
      objs+=("$obj")
    done

    libname=$(basename "$dir")
    libfile="$dir/lib${libname}.a"
    echo "build $libfile: ar ${objs[*]}" >> build.ninja
    libs+=("$libfile")
  fi
done < <(find . -type f -name 'ethen.sh' | sort)

echo "[INFO] Number of libraries: ${#libs[@]}"
# Final link step: combine all found libraries
if (( ${#libs[@]} > 0 )); then
  # List of libraries as space-separated
    linked_libs="${libs[*]}"
    echo "" >> build.ninja
    echo "# Link all libraries into 'ethen'" >> build.ninja
    echo "build ethen: link $linked_libs" >> build.ninja
    echo "" >> build.ninja
    echo "default ethen" >> build.ninja
fi

echo "[INFO] Ninja build file generated at build.ninja"

