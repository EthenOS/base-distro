#!/bin/bash

set -e

ROOT_DIR=$(pwd)

DEVICE_PATH=$ROOT_DIR/device
DEVICE_SH=$DEVICE_PATH/device.sh

if [ ! -f "$DEVICE_SH" ]; then
    echo "[ERROR] No device.sh found for $DEVICE_PATH"
    exit 1
fi

. "$DEVICE_SH"

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
  command = \$ld --start-group \$in --end-group \$ldflags -o \$out
rule bin
  command = \$objcopy -O binary \$in \$out

cc = $CC
ld = $LD
ar = $AR

cflags = $CFLAGS
ldflags = $LDFLAGS
objcopy = $OBJCOPY

EOF

libs=()

while read -r script; do
  dir=$(dirname "$script")

  eval "$(
  cd "$dir" || exit
    awk -F= '
      $1=="CUSTOM_BUILD"   { printf("%s=\"%s\"\n",$1,$2) }
      $1=="IS_LIBRARY"     { printf("%s=\"%s\"\n",$1,$2) }
      $1=="CUSTOM_CFLAGS"  { gsub(/^ *\(|\) *$/,"",$2); printf("CUSTOM_CFLAGS=(%s)\n",$2) }
      $1=="EXTERNAL_SUBDIRS" { gsub(/^ *\(|\) *$/,"",$2); printf("EXTERNAL_SUBDIRS=(%s)\n",$2) }
      $1=="EXTERNAL_EXTS"  { gsub(/^ *\(|\) *$/,"",$2); printf("EXTERNAL_EXTS=(%s)\n",$2) }
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
  if [[ "$IS_LIBRARY" == "1" ]]; then
    echo "# Building static lib for $dir" >> build.ninja
    objs=()

    for sub in "${EXTERNAL_SUBDIRS[@]:-}"; do
      src_root="$dir/$sub"
      echo "[DEBUG] Recursively searching in $src_root"

      while IFS= read -r src; do
        base=$(basename "$src")
        ext="${base##*.}"
        obj="$dir/${base%.*}.o"
        rule=$([[ "$ext" == "c" ]] && echo cc || echo s_compile)
        echo "build $obj: $rule $src" >> build.ninja
        objs+=("$obj")
        echo "[DEBUG] Added source: $src → $obj"
      done < <(find "$src_root" -type f \( -name '*.c' -o -name '*.s' \))
    done

    libname=$(basename "$dir")
    libfile="$dir/lib${libname}.a"
    echo "build $libfile: ar ${objs[*]}" >> build.ninja
    libs+=("$libfile")
    echo "[DEBUG] lib created: $libfile"
  fi
done < <(find . -type f -name 'ethen.sh' | sort)

echo "[INFO] Number of libraries: ${#libs[@]}"
# Final link step: combine all found libraries
if (( ${#libs[@]} > 0 )); then
  # List of libraries as space-separated
    linked_libs="${libs[*]}"
    echo "" >> build.ninja
    echo "# Link all libraries into 'firmware.elf'" >> build.ninja
    echo "build firmware.elf: link $linked_libs" >> build.ninja
    echo "" >> build.ninja
   

    # Add build step to convert ELF to binary
    echo "" >> build.ninja
    echo "# Convert ELF to binary format" >> build.ninja
    echo "build firmware.bin: bin firmware.elf" >> build.ninja
fi

echo "[INFO] Ninja build file generated at build.ninja"

