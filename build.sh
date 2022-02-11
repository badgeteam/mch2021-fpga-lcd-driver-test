#!/bin/bash
rm -rf build
mkdir build
yosys -p 'synth_ice40 -top chip -json build/project.json' project.v
nextpnr-ice40 --up5k --package sg48 --json build/project.json --pcf proto2.pcf --asc build/proto2.asc
icepack build/proto2.asc build/proto2.bin
