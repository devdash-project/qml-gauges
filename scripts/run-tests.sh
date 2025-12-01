#!/bin/bash
#
# Run qml-gauges unit tests
#
# Usage:
#   ./scripts/run-tests.sh              # Run all tests
#   ./scripts/run-tests.sh loading      # Run only loading tests (Catch2)
#   ./scripts/run-tests.sh qml          # Run only QML behavioral tests
#   ./scripts/run-tests.sh --verbose    # Verbose output
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${PROJECT_DIR}/build"

# Check if tests are built
if [[ ! -f "$BUILD_DIR/tests/qml-loading-tests" ]] && [[ ! -f "$BUILD_DIR/tests/qml-gauges-tests" ]]; then
    echo "Tests not built. Run: ./scripts/build.sh --tests"
    exit 1
fi

# Parse arguments
TEST_TYPE="all"
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        loading)
            TEST_TYPE="loading"
            shift
            ;;
        qml)
            TEST_TYPE="qml"
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [TYPE] [OPTIONS]"
            echo ""
            echo "Types:"
            echo "  loading     Run Catch2 QML loading tests only"
            echo "  qml         Run Qt Quick behavioral tests only"
            echo "  (default)   Run all tests"
            echo ""
            echo "Options:"
            echo "  -v, --verbose  Verbose output"
            echo "  -h, --help     Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Set QML import path
export QML2_IMPORT_PATH="$BUILD_DIR/qml"

FAILED=0

# Run loading tests (Catch2)
if [[ "$TEST_TYPE" == "all" ]] || [[ "$TEST_TYPE" == "loading" ]]; then
    if [[ -f "$BUILD_DIR/tests/qml-loading-tests" ]]; then
        echo "=== Running Catch2 QML Loading Tests ==="
        CATCH_ARGS=()
        if [[ "$VERBOSE" == "true" ]]; then
            CATCH_ARGS+=(-s)
        fi
        if "$BUILD_DIR/tests/qml-loading-tests" "${CATCH_ARGS[@]}"; then
            echo "✓ Loading tests passed"
        else
            echo "✗ Loading tests failed"
            FAILED=1
        fi
        echo ""
    else
        echo "Loading tests not built (qml-loading-tests not found)"
    fi
fi

# Run QML behavioral tests (Qt Quick Test)
if [[ "$TEST_TYPE" == "all" ]] || [[ "$TEST_TYPE" == "qml" ]]; then
    if [[ -f "$BUILD_DIR/tests/qml-gauges-tests" ]]; then
        echo "=== Running Qt Quick Behavioral Tests ==="
        QML_ARGS=()
        if [[ "$VERBOSE" == "true" ]]; then
            QML_ARGS+=(-v1)
        fi
        if "$BUILD_DIR/tests/qml-gauges-tests" "${QML_ARGS[@]}"; then
            echo "✓ QML behavioral tests passed"
        else
            echo "✗ QML behavioral tests failed"
            FAILED=1
        fi
        echo ""
    else
        echo "QML tests not built (qml-gauges-tests not found)"
    fi
fi

if [[ $FAILED -eq 0 ]]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed"
    exit 1
fi
