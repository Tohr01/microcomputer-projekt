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
ghdl -a -fsynopsys --workdir=$WORK_DIR memPkg.vhd opcodes_constants.vhd alu.vhd ramIO.vhd registerbank.vhd pipeline_cu.vhd pipeline_cu_testbench.vhd
echo "Started ghdl elaborate step" 
ghdl -e -fsynopsys --workdir=$WORK_DIR Control_Unit_tb
echo "Started ghdl run step"
ghdl -r -fsynopsys --workdir=$WORK_DIR Control_Unit_tb --vcd=$WAVEFORM_FILE

echo "Opening waveform file at $WAVEFORM_FILE"
gtkwave $WAVEFORM_FILE