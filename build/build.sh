#!/bin/bash

OUT_DIR=$(pwd)/out

ninja -C out ${@:2}
