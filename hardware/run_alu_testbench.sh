#!/bin/bash

cd "$(dirname "$0")";

WORK_DIR="work";
WAVEFORM_FILE="$WORK_DIR/waveform.vcd"
if [ ! -d "$WORK_DIR" ]; then
    echo "Creating new work dir"
    mkdir $WORK_DIR
fi

echo "Deleting old contents of work dir"
rm "$WORK_DIR/*"

echo "Started ghdl analyse step"
ghdl -a --workdir=$WORK_DIR alu_testbench.vhd alu.vhd 
echo "Started ghdl elaborate step" 
ghdl -e --workdir=$WORK_DIR tb_ALU
echo "Started ghdl run step"
ghdl -r --workdir=$WORK_DIR tb_alu --vcd=$WAVEFORM_FILE

echo "Opening waveform file at $WAVEFORM_FILE"
gtkwave $WAVEFORM_FILE