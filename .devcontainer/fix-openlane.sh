#!/bin/bash

# Fix the existing OpenLane installation to run natively
cd /home/vscode/Desktop/work/tools/openlane_working_dir/openlane

# Set environment variables for native execution
export OPENLANE_ROOT=$(pwd)
export PATH="$OPENLANE_ROOT/scripts:$PATH"

# Make sure flow.tcl is executable
chmod +x flow.tcl

# Set Tcl library path
export TCLLIBPATH="$OPENLANE_ROOT/scripts $OPENLANE_ROOT/scripts/tcl_commands"

echo "OpenLane configured for native execution"
echo "Run: ./flow.tcl -interactive"
