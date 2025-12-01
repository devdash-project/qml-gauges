#!/bin/bash
# Run the DevDash Gauges Explorer application
#
# Usage: ./scripts/run-explorer.sh [options]
#
# Options are passed directly to the Qt application

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
EXPLORER_BIN="$BUILD_DIR/explorer/qml-gauges-explorer"

# Check if built
if [[ ! -f "$EXPLORER_BIN" ]]; then
    echo "Error: Explorer not built. Run: cmake --build build"
    echo "Expected binary at: $EXPLORER_BIN"
    exit 1
fi

# Run the explorer
exec "$EXPLORER_BIN" "$@"
