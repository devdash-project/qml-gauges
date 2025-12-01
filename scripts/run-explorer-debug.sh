#!/bin/bash
# Run the DevDash Gauges Explorer with scene graph visualization
#
# Usage: ./scripts/run-explorer-debug.sh [mode]
#
# Modes:
#   overdraw   - Visualize overdraw (red = more draws)
#   batches    - Show draw call batching
#   clip       - Show clipping regions
#   changes    - Flash white on scene graph changes
#   render     - Detailed render timing info
#
# Default: overdraw

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
EXPLORER_BIN="$BUILD_DIR/explorer/qml-gauges-explorer"

# Check if built
if [[ ! -f "$EXPLORER_BIN" ]]; then
    echo "Error: Explorer not built. Run: cmake --build build"
    exit 1
fi

MODE="${1:-overdraw}"

case "$MODE" in
    overdraw)
        echo "=== Overdraw Visualization ==="
        echo "Colors indicate draw count per pixel:"
        echo "  Blue   = 1 draw"
        echo "  Green  = 2 draws"
        echo "  Red    = 3+ draws (optimize these areas)"
        echo ""
        export QSG_VISUALIZE=overdraw
        ;;
    batches)
        echo "=== Batch Visualization ==="
        echo "Each color = separate draw call batch"
        echo "Fewer colors = better batching"
        echo ""
        export QSG_VISUALIZE=batches
        ;;
    clip)
        echo "=== Clip Visualization ==="
        echo "Shows scissor clip regions in red"
        echo ""
        export QSG_VISUALIZE=clip
        ;;
    changes)
        echo "=== Change Visualization ==="
        echo "Flashes white when scene graph updates"
        echo "Constant flashing = unnecessary redraws"
        echo ""
        export QSG_VISUALIZE=changes
        ;;
    render)
        echo "=== Render Timing ==="
        echo "Outputs detailed render timing to console"
        echo ""
        export QSG_RENDER_TIMING=1
        ;;
    *)
        echo "Unknown mode: $MODE"
        echo "Available: overdraw, batches, clip, changes, render"
        exit 1
        ;;
esac

exec "$EXPLORER_BIN"
