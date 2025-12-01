#!/bin/bash
#
# Build qml-gauges project
#
# Usage:
#   ./scripts/build.sh              # Build with defaults
#   ./scripts/build.sh --clean      # Clean rebuild
#   ./scripts/build.sh --tests      # Build with tests enabled
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${PROJECT_DIR}/build"

# Default Qt path - can be overridden with QT_PATH env var
QT_PATH="${QT_PATH:-$HOME/Qt/6.10.1/gcc_arm64}"

# Parse arguments
CLEAN=false
TESTS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN=true
            shift
            ;;
        --tests)
            TESTS=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --clean     Clean build directory before building"
            echo "  --tests     Enable building unit tests"
            echo "  -h, --help  Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  QT_PATH     Path to Qt installation (default: ~/Qt/6.10.1/gcc_arm64)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Clean if requested
if [[ "$CLEAN" == "true" ]]; then
    echo "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
fi

# Configure
CMAKE_ARGS=(
    -B "$BUILD_DIR"
    -DCMAKE_PREFIX_PATH="$QT_PATH"
)

if [[ "$TESTS" == "true" ]]; then
    CMAKE_ARGS+=(-DBUILD_TESTS=ON)
fi

echo "Configuring with Qt from: $QT_PATH"
cmake "${CMAKE_ARGS[@]}"

# Build
echo "Building..."
cmake --build "$BUILD_DIR" -j$(nproc)

echo ""
echo "Build complete!"
echo "  Explorer: $BUILD_DIR/explorer/qml-gauges-explorer"
if [[ "$TESTS" == "true" ]]; then
    echo "  Tests:    $BUILD_DIR/tests/qml-loading-tests"
    echo "            $BUILD_DIR/tests/qml-gauges-tests"
fi
