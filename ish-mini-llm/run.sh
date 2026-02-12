#!/bin/sh
#
# Quick launcher for MiniLLM
# Usage:
#   sh run.sh              # Interactive mode
#   sh run.sh chat         # Chat directly
#   sh run.sh server       # Start server
#   sh run.sh download ID  # Download model
#

cd "$(dirname "$0")"
exec python3 app.py "$@"
