#!/bin/bash
echo "Dot-Dash Log File:"
echo "=================="
if [ -f ~/Documents/Dot-Dash.log ]; then
    tail -50 ~/Documents/Dot-Dash.log
else
    echo "No log file found at ~/Documents/Dot-Dash.log"
fi
echo ""
echo "Press any key to continue..."
read -n 1
