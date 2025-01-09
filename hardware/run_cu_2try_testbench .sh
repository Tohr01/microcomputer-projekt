#!/bin/bash

cd "$(dirname "$0")" || exit

WORK_DIR="work";
WAVEFORM_FILE="$WORK_DIR/waveform.vcd"
if [ ! -d "$WORK_DIR" ]; then
    echo "Creating new work dir"
    mkdir $WORK_DIR
fi

echo "Deleting old contents of work dir"
rm "$WORK_DIR/*"

echo "Started ghdl analyse step"
ghdl -a --workdir=$WORK_DIR opcodes_constants.vhd alu.vhd control-unit_2try.vhd control-unit_2try_testbench.vhd
echo "Started ghdl elaborate step" 
ghdl -e --workdir=$WORK_DIR Control_Unit_tb
echo "Started ghdl run step"
ghdl -r --workdir=$WORK_DIR Control_Unit_tb --vcd=$WAVEFORM_FILE

echo "Opening waveform file at $WAVEFORM_FILE"
gtkwave $WAVEFORM_FILE