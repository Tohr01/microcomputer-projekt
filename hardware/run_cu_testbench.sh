#!/bin/bash

cd "$(dirname "$0")" || exit

WORK_DIR="work";
WAVEFORM_FILE="$WORK_DIR/waveform-cu.vcd"
if [ ! -d "$WORK_DIR" ]; then
    echo "Creating new work dir"
    mkdir $WORK_DIR
fi

echo "Deleting old contents of work dir"
rm "$WORK_DIR/*"

echo "Started ghdl analyse step"
ghdl -a -fsynopsys --workdir=$WORK_DIR opcodes_constants.vhd memPkg.vhd alu.vhd registerbank.vhd ramIO.vhd control-unit.vhd control-unit_testbench.vhd
echo "Started ghdl elaborate step" 
ghdl -e -fsynopsys --workdir=$WORK_DIR tb_ControlUnit
echo "Started ghdl run step"
ghdl -r -fsynopsys --workdir=$WORK_DIR tb_ControlUnit --vcd=$WAVEFORM_FILE

echo "Opening waveform file at $WAVEFORM_FILE"
gtkwave $WAVEFORM_FILE