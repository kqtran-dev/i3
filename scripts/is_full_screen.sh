#!/bin/bash
# is_windowed_borderless.sh - Check if active window is in windowed borderless mode
# Returns: 0 (true) if windowed borderless, 1 (false) otherwise, 2 on error

set -euo pipefail  # Best practices: exit on error, undefined vars, pipe failures

# Configuration - adjust these if needed
declare -r TOLERANCE=10  # Pixel tolerance for size comparison (some windows might be slightly off)

# Function to log errors to stderr
error_exit() {
    echo "Error: $1" >&2
    exit 2
}

# Function to clean up temporary files
cleanup() {
    rm -f /tmp/window_check_$$.tmp
}

# Set trap for cleanup
trap cleanup EXIT

# Check for required tools
for cmd in xdotool xwininfo xdpyinfo xprop; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        error_exit "$cmd not found. Please install it first."
    fi
done

# Get active window ID
WINDOW_ID=$(xdotool getactivewindow 2>/dev/null) || error_exit "Failed to get active window"

# Check if window exists
if ! xwininfo -id "$WINDOW_ID" >/dev/null 2>&1; then
    error_exit "Window $WINDOW_ID does not exist"
fi

# Get window dimensions
WINDOW_GEOM=$(xwininfo -id "$WINDOW_ID" | grep -E 'Width|Height' | awk '{print $NF}' | paste -sd ' ')
read -r WINDOW_WIDTH WINDOW_HEIGHT <<< "$WINDOW_GEOM"

# Validate we got numbers
if ! [[ "$WINDOW_WIDTH" =~ ^[0-9]+$ ]] || ! [[ "$WINDOW_HEIGHT" =~ ^[0-9]+$ ]]; then
    error_exit "Failed to parse window dimensions"
fi

# Get screen dimensions
SCREEN_GEOM=$(xdpyinfo | grep -m1 dimensions | awk '{print $2}')
if ! [[ "$SCREEN_GEOM" =~ ^[0-9]+x[0-9]+$ ]]; then
    error_exit "Failed to parse screen dimensions"
fi

SCREEN_WIDTH=$(echo "$SCREEN_GEOM" | cut -d'x' -f1)
SCREEN_HEIGHT=$(echo "$SCREEN_GEOM" | cut -d'x' -f2)

# Function to check if window is fullscreen according to window manager
is_fullscreen() {
    xprop -id "$WINDOW_ID" | grep -q "_NET_WM_STATE_FULLSCREEN"
}

# Check if window dimensions match screen dimensions (with tolerance)
width_diff=$((WINDOW_WIDTH - SCREEN_WIDTH))
height_diff=$((WINDOW_HEIGHT - SCREEN_HEIGHT))

# Convert to absolute values for comparison
abs_width_diff=${width_diff#-}
abs_height_diff=${height_diff#-}

# Debug output (can be disabled for production)
if [[ "${DEBUG:-0}" == "1" ]]; then
    echo "Window: ${WINDOW_WIDTH}x${WINDOW_HEIGHT} (ID: $WINDOW_ID)" >&2
    echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}" >&2
    echo "Tolerance: $TOLERANCE pixels" >&2
fi

# Main logic
if is_fullscreen; then
    # Window is explicitly fullscreen (handled by WM)
    echo "Window is in fullscreen mode (WM managed)" >&2
    exit 1
elif [ "$abs_width_diff" -le "$TOLERANCE" ] && [ "$abs_height_diff" -le "$TOLERANCE" ]; then
    # Window matches screen dimensions (windowed borderless)
    # echo "Window is in windowed borderless mode" >&2
    echo "Window is in windowed borderless mode" >&2
    exit 1
else
    # Window is normal windowed mode
    echo "Window is in normal windowed mode" >&2
    exit 0
fi
