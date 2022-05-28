#!/usr/bin/env bash

set -e
set -u

rm -rf build
mkdir build

yosys -p 'synth_ice40 -retime -top chip -json build/project.json' project.v
nextpnr-ice40 --up5k --package sg48 --json build/project.json --pcf mch2022.pcf --asc build/bitstream.asc --pre-pack prepack.py --timing-allow-fail
icepack build/bitstream.asc build/bitstream.bin
