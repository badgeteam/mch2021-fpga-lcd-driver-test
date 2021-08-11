#!/bin/bash
rm -rf simulation
mkdir simulation
cd simulation
verilator -Wall --trace  -cc ../lcd.v --exe ../lcd_tb.cpp
make -C obj_dir -f Vlcd.mk
./obj_dir/Vlcd
